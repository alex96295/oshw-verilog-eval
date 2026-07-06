# Open Source HW (OSHW) SystemVerilog evaluation benchmark for LLMs

This repository builds a benchmark dataset from open-source hardware (OSHW)
SystemVerilog designs to assess LLM-based RTL **design** and **verification**
capabilities.

For each `(DUT, testbench)` pair, the reference RTL design and testbench are turned
into single-source, self-contained files, and an LLM generates a natural-language
specification prompt from the reference RTL (without leaking implementation details).
The generated spec is what an LLM-under-test is asked to implement; the self-checking
testbench then verifies its answer against the golden reference.

The initial designs are drawn from the
[PULP platform](https://github.com/pulp-platform) IP libraries (e.g.
[common_cells](https://github.com/pulp-platform/common_cells),
[axi](https://github.com/pulp-platform/axi)), but the flow is source-agnostic and works
with any OSHW design that ships a [Bender](https://github.com/pulp-platform/bender)
manifest.

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

This project uses Git submodules (the OSHW design sources) that have to be initialized.
Either clone the repository recursively:

```bash
git clone --recursive <url>
```

or fetch the submodules afterwards:

```bash
git submodule update --init --recursive
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

## Example

An exemplary input `assets.json`:

```json
{
  "assets/common_cells": [
    ["delta_counter", "delta_counter.sv", ""],
    ["fifo_v3", "fifo_v3.sv", "fifo_tb.sv"]
  ]
}
```

Each tuple, from left to right:

* top-level module name (the DUT);
* `.sv` source file (relative to the asset dir) where the DUT is declared;
* `.sv` source file with a testbench for the DUT — leave `""` if none.
