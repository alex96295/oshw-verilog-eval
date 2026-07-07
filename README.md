# Open Source HW (OSHW) SystemVerilog evaluation benchmark for LLMs

This repository builds a benchmark dataset from open-source hardware (OSHW)
SystemVerilog designs to assess LLM-based RTL **design** and **verification**
capabilities.

For each `(DUT, testbench)` pair, the reference RTL design and testbench are turned
into single-source, self-contained files, and an LLM generates a natural-language
specification prompt from the reference RTL (without leaking implementation details).
The generated spec is what an LLM-under-test is asked to implement; the self-checking
testbench then verifies its answer against the golden reference.

The initial designs are drawn from
[OpenTitan](https://github.com/lowRISC/opentitan) (`hw/ip/prim/` primitives and
peripheral IPs) and the [PULP platform](https://github.com/pulp-platform)
([axi](https://github.com/pulp-platform/axi)), but the flow is source-agnostic and works
with any OSHW design that ships a [Bender](https://github.com/pulp-platform/bender)
manifest or a hand-authored `Bender.yml` wrapper.

The idea of this repository is inspired by
[verilog-eval](https://github.com/NVlabs/verilog-eval) from NVIDIA.

## Dependencies

* [Bender](https://github.com/pulp-platform/bender) >= 0.32, built with the `slang`
  feature (provides the `pickle` command). The `slang` feature is on by default.
* Python >= 3.11 and [uv](https://github.com/astral-sh/uv) for the spec generator.

Additionally, set `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, or another provider's key in
your environment to use a cloud LLM provider, or create a **key.cfg** file in the
format:

```
OPENAI_API_KEY= 'xxxxxxx'
ANTHROPIC_API_KEY= 'xxxxxxx'
VERTEX_SERVICE_ACCOUNT_PATH= 'xxxxxxx'
VERTEX_REGION= 'xxxxxxx'
```

Keys already present in the environment take precedence over `key.cfg`.

## Getting started

All design sources are **vendored** — there are no Git submodules. Each asset directory holds
a `Bender.yml` with a `vendor_package` stanza that pins the exact upstream revision(s), a
committed `vendor/` subtree with the curated source subset, and (where needed) reproducible
`patches/`. A fresh checkout is fully self-contained: pickling needs no submodule init and no
network.

* **OpenTitan** (`assets/opentitan/`) — a curated subset of the
  [OpenTitan](https://github.com/lowRISC/opentitan) tree. Patches in
  `assets/opentitan/patches/` carry a few tool-specific parse fixes and the formal-testbench
  wiring described below.

* **PULP axi** (`assets/axi/`) — the [axi](https://github.com/pulp-platform/axi) library plus
  its transitive dependencies (`common_cells`, `common_verification`, `tech_cells_generic`),
  each vendored as its own `vendor_package` pinned to the revision axi's `Bender.lock`
  resolved. axi is not self-contained (its RTL instantiates `common_cells` modules), so the
  dependencies are vendored alongside it rather than fetched on demand.

To refresh a vendored subset from upstream and re-apply its patches (only needed to change a
pinned revision):

```bash
(cd assets/opentitan && bender vendor init)   # or assets/axi
```

## Setup

### Bender (with the `slang`/`pickle` feature)

The `pickle` command is backed by [Slang](https://github.com/MikePopoloski/slang), so
building Bender requires a **C++20-capable compiler** (e.g. Clang >= 17) and **CMake**.

Install a released Bender:

```sh
# get latest stable rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# bender >= 0.32 (slang/pickle is part of the default feature set)
cargo install --git https://github.com/pulp-platform/bender --tag v0.32.0
```

Alternatively, build a local checkout and point `BENDER_BIN` at it (useful for
development, and how CI/this repo can pin an exact revision):

```sh
git clone https://github.com/pulp-platform/bender
(cd bender && CXX=clang++ cargo build --release)
export BENDER_BIN="$PWD/bender/target/release/bender"
```

The generator resolves `bender` in this order: `BENDER_BIN`, then
`./bender/target/release/bender`, then `bender` on `PATH`.

### Python environment (uv)

```sh
uv sync
```

This creates a virtual environment and installs the (minimal) dependencies declared in
`pyproject.toml`.

## Usage

List the `(RTL DUT, TB)` pairs and their source asset in a JSON file. A sample is
provided in `$ROOT/assets.json`. Then run:

```bash
./scripts/bench-gen.sh \
  --json assets.json \
  --out out \
  --provider openai \
  --model gpt-4o-2024-08-06 \
  --key-cfg ./key.cfg \
  --max-token 8192 \
  --tokens 60000 \
  --temperature 0.6 \
  --top-p 0.95 \
  --concurrency 8
```

Notes:

* Input (`--tokens`) and output (`--max-token`) token budgets should respect the RPM
  and TPM limits of the chosen model.
* Specs for all designs are generated **concurrently** (`--concurrency`).
* A spec quality/leakage **review pass** runs by default; disable it with
  `--no-review`.
* Runs are **idempotent**: designs whose bench artifacts already exist are skipped.
  Use `--force` to regenerate.
* Per-design failures are collected and reported in a summary at the end (the run does
  not abort on the first error).

## Output

| Name | Description |
|-------------------------------------|----------------------------------------------------------------------------------------------------------|
| `$ROOT/out/bench/ProbXXX_<dut>_ref.sv` | Reference DUT RTL design (single-source, comment-stripped), reachable modules only. |
| `$ROOT/out/bench/ProbXXX_<dut>_test.sv` | Self-checking testbench with the reference DUT removed, so the assessed LLM's own `TopModule` is compiled against it in-the-loop. |
| `$ROOT/out/bench/ProbXXX_<dut>_test_golden.sv` | Reference testbench instantiating the reference DUT. Golden reference for comparison with the LLM-generated RTL. |
| `$ROOT/out/bench/ProbXXX_<dut>_prompt.txt` | LLM-generated natural-language input spec (plain text) based on the reference design. |
| `$ROOT/out/bench/ProbXXX_<dut>_prompt.md` | Same spec in Markdown (human-readable companion). |

Module and testbench identifiers are normalized to `TopModule` and `TopTestbench` in the
emitted `.sv` files.

## How it works

For each design, `bender pickle` flattens and trims the sources into self-contained files:

```bash
# reference RTL (_ref.sv): reachable modules from the DUT top only
bender -d <asset> pickle -t rtl --top <dut> --strip-comments --squash-newlines -o <ref.sv>

# golden (_test_golden.sv): testbench + reference DUT, reachable from the TB top
bender -d <asset> pickle -t rtl -t test -t simulation --top <tb> --strip-comments --squash-newlines -o <golden.sv>
```

`--top` trims unreachable files via Slang's reachability analysis, so each emitted file
contains only the modules the DUT/TB actually needs.

Since the testbench instantiates the DUT, the golden pickle already contains everything.
The `_test.sv` handed to the assessed LLM is the golden with the reference
`module TopModule … endmodule` definition removed, leaving an instantiation slot for the
LLM's own implementation. Identifiers are normalized to `TopModule`/`TopTestbench`.

### Testbenches: OpenTitan's formal (FPV) harnesses

OpenTitan does not ship standalone simulation testbenches for its primitives — its
non-primitive IPs use UVM (which does not pickle), and its primitives are verified
**formally**. For the primitives that carry a formal-property setup, we pickle that setup as
the golden: OpenTitan's `hw/ip/prim/fpv/` provides, per design, a testbench harness
(`*_tb.sv`), an assertion module of formal properties (`*_assert_fpv.sv`, a mostly black-box
reference model built from the DUT's ports), and a `bind` file wiring the properties onto the
DUT. Because a `bind` module is a separate elaboration root that `--top` reachability would
otherwise drop, the vendored harness is patched (see `assets/opentitan/patches/`) to
instantiate its bind module, so the pickled golden carries the DUT **and** its formal
specification. A small number of white-box assertions that reach into OpenTitan-internal
signals are removed by the same patch, so the LLM's own `TopModule` — which need not
replicate those internals — still elaborates against `_test.sv`. Checking an answer against
these properties requires a formal tool (e.g. JasperGold, SymbiYosys), not plain simulation.

Designs without such a setup are emitted RTL-only (`_ref.sv` + spec, no `_test*.sv`).

## Example

An exemplary input `assets.json`:

```json
{
  "assets/opentitan": [
    ["prim_fifo_sync",  "hw/ip/prim/rtl/prim_fifo_sync.sv", "hw/ip/prim/fpv/tb/prim_fifo_sync_tb.sv"],
    ["prim_lfsr",       "hw/ip/prim/rtl/prim_lfsr.sv",      "hw/ip/prim/fpv/tb/prim_lfsr_tb.sv"],
    ["uart",            "hw/ip/uart/rtl/uart.sv",           ""]
  ],
  "assets/axi": [
    ["axi_cut",   "vendor/axi/src/axi_cut.sv",   ""],
    ["axi_demux", "vendor/axi/src/axi_demux.sv", ""]
  ]
}
```

Each tuple, from left to right:

* top-level module name (the DUT);
* `.sv` source file path used to derive the `--top` module name (stem = module name);
* `.sv` source file with a testbench for the DUT — leave `""` if none.

The JSON key (e.g. `"assets/opentitan"` or `"assets/axi"`) must point to a directory
containing a `Bender.yml`; source paths in each tuple are relative to that directory and
resolve into its committed `vendor/` subtree. OpenTitan's non-primitive IPs use full UVM
testbenches which are not pickle-compatible; use `""` for those.
