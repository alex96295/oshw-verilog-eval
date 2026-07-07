Design a module called TopModule. This module implements a single Keccak-f[1600] round using 2-share DOM (Dominating Operations Masking) protection, with configurable phase selection for splitting theta/rho/pi and chi operations across multiple cycles.

## Overview

TopModule is a masked Keccak-f[1600] round processor optimized for 2-share Threshold Implementation (TI) or DOM. It applies the five transformation steps (theta, rho, pi, chi, iota) of a Keccak round to a masked state (two shares). The module allows phase-based splitting of operations:
- **Phase 1:** Theta, rho, pi.
- **Phase 2:** Chi, iota.

This permits distributing the computation across cycles to reduce glitch propagation and improve side-channel resistance. The chi step uses DOM-protected AND gates that consume fresh randomness to prevent share recombination.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `Width` | State width in bits. | 1600 for Keccak-f[1600]. |
| `W` | Lane width: Width / 25. | 64 for standard Keccak-f[1600]. |
| `L` | log2(W). | 6 for 64-bit lanes. |
| `MaxRound` | Maximum round index: 12 + 2*L. | 24 for Keccak-f[1600]. |
| `RndW` | log2(MaxRound + 1). | 5 bits. |
| `EnMasking` | Enable masking. If 1, state is two-share. (Typically hardwired to 1 for this module). | bit, default 0. |
| `ForceRandExt` | Force external randomness input (for testing). | bit, default 0. |
| `Share` | Derived: 2 if EnMasking else 1. | int, read-only. |

## Interface

| Port | Direction | Width / Type | Description |
|------|-----------|--------------|-------------|
| `clk_i` | input | 1 | Clock. State updates and phase transitions driven by rising edge. |
| `rst_ni` | input | 1 | Async active-low reset. State cleared. |
| `lc_escalate_en_i` | input | lc_ctrl_pkg::lc_tx_t | Lifecycle escalation signal for fault testing. |
| `rnd_i` | input | [RndW-1:0] | Round index (0..23 for standard Keccak-f[1600]). Selects the round constant for iota. |
| `phase_sel_i` | input | mubi4_t (multibit encoded) | Phase selector: MuBi4False = Phase 1 (theta/rho/pi), MuBi4True = Phase 2 (chi/iota). Determines which operations apply. |
| `dom_out_low_i` | input | 1 | DOM output low flag. Indicates low-latency path for output masking. |
| `dom_in_low_i` | input | 1 | DOM input low flag. Indicates low-latency path for input masking. |
| `dom_in_rand_ext_i` | input | 1 | DOM input random external flag. If high, randomness for chi is sourced externally. |
| `dom_update_i` | input | 1 | DOM update signal. When high, triggers masked operation and random consumption. |
| `rand_i` | input | [Width/2-1:0] | Randomness input (768 bits for standard Keccak-f[1600]). Used in chi step masked AND. |
| `s_i` | input | [Width-1:0] × Share | Input state (two 1600-bit shares). s_i[0] and s_i[1] are the two shares; XOR = masked state. |
| `s_o` | output | [Width-1:0] × Share | Output state (two 1600-bit shares after theta/rho/pi or chi/iota, depending on phase_sel_i). |

## Behavioral requirements

- **2-share masking.** The input state is provided as two shares (s_i[0], s_i[1]) such that s_i[0] XOR s_i[1] = actual state. All operations preserve the share structure:
  - XOR and rotation operations: applied to each share independently.
  - Chi (AND): performed using a 2-share masked AND gadget (e.g., DOM with fresh randomness) to prevent recombination.
  - Iota (XOR with constant): applied to one or both shares depending on scheme.

- **Phase 1 (theta/rho/pi).** When phase_sel_i selects Phase 1:
  1. **Theta:** XOR each lane with parity of adjacent columns (see Prob069 for theta definition). Applied per-share.
  2. **Rho:** Rotate each lane by fixed offsets (see Prob069). Applied per-share.
  3. **Pi:** Rearrange lanes within the 5×5 grid (see Prob069). Applied per-share.
  - Output s_o is the result of theta(rho(pi(s_i))).

- **Phase 2 (chi/iota).** When phase_sel_i selects Phase 2:
  1. **Chi (DOM-protected AND):** For each lane [x, y]:
     ```
     output[x, y] = input[x, y] XOR ((NOT input[x+1, y]) AND input[x+2, y])
     ```
     Implemented using a 2-share masked AND: the AND gate requires fresh randomness (rand_i) to prevent share recombination.
  2. **Iota:** XOR lane [0, 0] with the round constant RC[rnd_i] (applied to one or both shares per scheme).
  - Output s_o is the result of iota(chi(s_i)).

- **Split-phase design.** The two phases can be executed in separate cycles:
  - Cycle N: phase_sel_i = Phase 1 → theta/rho/pi applied, output staged in intermediate register.
  - Cycle N+1: phase_sel_i = Phase 2, input is output from cycle N → chi/iota applied.
  - Or, both phases in one cycle if pipelined internally.

- **DOM-protected chi.** The chi step is the only non-linear (AND) operation and is the only step that risk share recombination. The module implements chi using a 2-share masked AND that consumes randomness rand_i to compute:
  ```
  (a0 AND b0) XOR (a0 AND b1) XOR (a1 AND b0) XOR (a1 AND b1) XOR rand
  ```
  where (a0, a1) and (b0, b1) are the two shares of operands a and b, and rand masks the result.

- **Round constant (iota).** The round constant RC[rnd_i] is applied based on rnd_i. Standard Keccak round constants are used.

- **Randomness input (rand_i).** When dom_update_i is high and chi operations are enabled (Phase 2), fresh randomness from rand_i is consumed. The module may pipeline randomness (rand_early_i would be used by the top-level Keccak module; this submodule consumes rand_i).

- **DOM flags (dom_out_low_i, dom_in_low_i, dom_in_rand_ext_i).** These flags control the masking/demasking and randomness flow:
  - dom_out_low_i: Select output masking latency.
  - dom_in_low_i: Select input unmasking latency.
  - dom_in_rand_ext_i: Route randomness from external source (if ForceRandExt=1).

- **Lifecycle escalation (lc_escalate_en_i).** When asserted, triggers fault testing or heightened error detection.

## Clock domain

Single clock domain driven by `clk_i`; asynchronous reset via `rst_ni`.

## Latency

- Per phase: typically 1–2 cycles (phase 1 can be 1 cycle; phase 2 may require 2 cycles for masked AND + iota).
- Full round with both phases: 2–4 cycles depending on pipelining.

## Example

Scenario: Execute a full Keccak round using phase-based split.

| Cycle | phase_sel_i | Input | Operation | Output | Notes |
|-------|-------------|-------|-----------|--------|-------|
| 0 | Phase 1 | s_i (two shares) | theta/rho/pi | s_o (theta/rho/pi applied) | First phase completes theta, rho, pi. Output staged. |
| 1 | Phase 2 | s_o (from cycle 0, now input) | chi/iota (dom_update=HIGH, rand valid) | s_o (chi/iota applied) | Second phase: chi consumes rand_i, iota adds RC[rnd_i]. |
| 2 | - | (steady state) | - | - | Next input can begin or previous output accepted. |

Alternatively, pipelined (both phases in one cycle if pre-staged):

| Cycle | phase_sel_i | Input | Operation | Output | Notes |
|-------|-------------|-------|-----------|--------|-------|
| 0 | Phase 1 | s_i[0] | theta/rho/pi | s_o (theta/rho/pi) | Phase 1 processes input. |
| 1 | Phase 2 | s_i[1] (next block) being absorbed; s_o from phase 1 now in chi/iota | chi/iota | s_o (full round result) | Pipelined: phase 2 processes prior phase 1 output while phase 1 processes new input. |

Constraints:
- For 2-share masking to be secure, randomness (rand_i) must be fresh and independent across cycles.
- phase_sel_i must be stable during computation; switching phases mid-operation can cause incorrect results.
- rnd_i must be in range 0..23 (for standard Keccak-f[1600]).
- Input and output are two-share arrays; external logic must handle unmasking if needed.
