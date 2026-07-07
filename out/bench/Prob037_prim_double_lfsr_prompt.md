Design a module called TopModule. This module implements a redundant LFSR (Linear Feedback Shift Register) with mismatch detection. It maintains two identical LFSRs in parallel and compares their outputs to detect any divergence due to transient faults or corruption.

## Overview

TopModule is a cryptographic-grade LFSR primitive that runs two independent LFSR instances side by side, each with identical configurations and inputs. Both LFSRs advance in lockstep with the same seed, enable, and entropy inputs. The module continuously monitors the two LFSR outputs and reports an error flag if they ever diverge, indicating a fault condition.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `LfsrType` | LFSR type: "GAL_XOR" (Galois) or "FIB_XNOR" (Fibonacci). | String; defines feedback polynomial structure. |
| `LfsrDw` | Width of each LFSR state, in bits. | ≥ 1; typically 16, 32, 64. |
| `EntropyDw` | Width of the entropy input, in bits. | ≤ `LfsrDw`. |
| `StateOutDw` | Width of the output slice, in bits. | ≤ `LfsrDw`. |
| `DefaultSeed` | Initialization seed for both LFSRs. | `LfsrDw` bits; must not be all-zero for FIB_XNOR type. |
| `CustomCoeffs` | Custom feedback polynomial coefficients. | `LfsrDw` bits; MSB must be 1. If all-zero, default polynomial is used. |
| `StatePermEn` | Enable optional output permutation. | Bit; if 1, apply permutation before output. |
| `StatePerm` | Permutation indices for output bits. | Array of `LfsrDw` indices; only used if `StatePermEn` is 1. |

## Interface

TopModule operates in a single clock domain with an active-low asynchronous reset.

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk_i` | input | 1 | System clock. |
| `rst_ni` | input | 1 | Active-low asynchronous reset. |
| `seed_en_i` | input | 1 | Seed enable: when asserted, `seed_i` loads into both LFSRs on the next clock edge. |
| `seed_i` | input | `LfsrDw` | Seed value for initialization of both LFSRs. |
| `lfsr_en_i` | input | 1 | LFSR enable: when asserted, advance both LFSRs on the next clock edge. |
| `entropy_i` | input | `EntropyDw` | Entropy input XORed into the next state of both LFSRs (optional dithering). |
| `state_o` | output | `StateOutDw` | Selected output bits from the LFSR state; same from both LFSRs (they are identical). |
| `err_o` | output | 1 | Mismatch flag: asserted if the two LFSR states diverge. |

## Behavioral requirements

- **Dual LFSR operation.** Maintain two LFSRs with identical parameters. Both advance together according to `lfsr_en_i` and receive the same `entropy_i` and `seed_i` inputs.
- **State output.** `state_o` reflects the lower `StateOutDw` bits of the first LFSR state, optionally permuted if `StatePermEn` is 1. Under normal (non-faulty) operation, both LFSRs produce the same output.
- **Mismatch detection.** The error flag `err_o` is asserted combinationally whenever the internal state of the two LFSRs differs, indicating a detected fault. `err_o` remains asserted as long as the states mismatch.
- **Seeding.** When `seed_en_i` is asserted, both LFSRs load `seed_i` on the next clock edge, overriding normal operation.
- **Entropy injection.** When `lfsr_en_i` is asserted and `seed_en_i` is not, both LFSRs advance and XOR `entropy_i` (zero-padded to `LfsrDw` if needed) into the new state.
- **Lockup protection.** If either LFSR reaches an invalid state (all-zero for FIB_XNOR, all-one for GAL_XOR), automatic recovery to `DefaultSeed` may be enabled. This occurs independently in each LFSR; mismatch after lockup triggers `err_o`.
- **Reset behavior.** On reset (`rst_ni` low), both LFSRs initialize to `DefaultSeed`, and `err_o` is deasserted.
- **Permutation.** If `StatePermEn` is 1, each bit of `state_o` is assigned from `StatePerm[bit_index]` of the LFSR state, implementing arbitrary bit reordering.

## Clock and Reset Domains

- Single synchronous clock domain (`clk_i`).
- Asynchronous active-low reset (`rst_ni`).

## Example

With `LfsrType = "GAL_XOR"`, `LfsrDw = 8`, `StateOutDw = 8`, `DefaultSeed = 8'h01`:

| Event | `lfsr_en_i` | `seed_en_i` | `entropy_i` | `state_o` (both LFSRs) | `err_o` |
|-------|------------|-----------|-----------|----------------------|--------|
| Reset | — | — | — | `8'h01` | 0 |
| Clock 1 | 1 | 0 | `8'h00` | (next state) | 0 |
| Clock 2 | 1 | 0 | `8'h00` | (next state) | 0 |
| Clock 3 | 0 | 0 | × | (hold) | 0 |
| Seeded | 0 | 1 | × | `8'h01` | 0 |

If due to a transient fault, one LFSR advances while the other does not, the states diverge and `err_o` is immediately asserted, signaling a fault condition.
