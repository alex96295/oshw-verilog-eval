Design a module called TopModule. This module implements a single round of the Keccak-f[1600] permutation, the core function of SHA-3 and SHAKE. It accepts a 1600-bit state, applies the five Keccak transformation steps (theta, rho, pi, chi, iota) for one round, and outputs the transformed state.

## Overview

TopModule is a Keccak-f[1600] round processor. The Keccak-f permutation operates on a 1600-bit state organized as a 5×5×64 bit array (25 lanes of 64 bits each). A single round applies five transformations:
1. **Theta:** XOR each lane with parity of adjacent columns.
2. **Rho:** Rotate each lane by a fixed offset (determined by lane position).
3. **Pi:** Rearrange lanes within the 5×5 grid.
4. **Chi:** Non-linear step (XOR with AND of neighboring lanes).
5. **Iota:** XOR with a round-dependent constant.

The module supports optional 2-share DOM masking and external randomness input for masked Keccak. It includes a port for controlling which transformation steps to apply (for flexibility in pipelined or staged implementations).

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `Width` | State width in bits. | 1600 for Keccak-f[1600] (standard). Other widths (400, 800) possible but non-standard. Default 1600. |
| `W` | Lane width: Width / 25. | 64 for standard Keccak-f[1600]. |
| `L` | log2(W). | 6 for 64-bit lanes. |
| `MaxRound` | Maximum round index: 12 + 2*L. | 24 for Keccak-f[1600]. |
| `RndW` | log2(MaxRound + 1). | 5 bits for Keccak-f[1600]. |
| `DInWidth` | Data input width for state absorption. | 64 bits (single lane). |
| `DInEntry` | Number of lanes: Width / DInWidth. | 25 for Keccak-f[1600]. |
| `DInAddr` | Address width for lane selection: log2(DInEntry). | 5 bits for 25 lanes. |
| `EnMasking` | Enable 2-share DOM masking. If 1, state is split into two shares (masked Keccak). | bit, default 0. |
| `ForceRandExt` | Force external randomness input (for testing). | bit, default 0. |
| `Share` | Derived: 2 if EnMasking else 1. | int, read-only. |

## Interface

| Port | Direction | Width / Type | Description |
|------|-----------|--------------|-------------|
| `clk_i` | input | 1 | Clock. State update, round counter, and datapath driven by rising edge. |
| `rst_ni` | input | 1 | Async active-low reset. State cleared, round counter reset. |
| `valid_i` | input | 1 | Input valid. When asserted, data_i is absorbed into state at address addr_i. |
| `addr_i` | input | [DInAddr-1:0] | Lane address for state absorption (0..24 for standard Keccak-f[1600]). |
| `data_i` | input | [DInWidth-1:0] × Share | Input data (lane to absorb). If Share=2, array of two shares. |
| `ready_o` | output | 1 | Ready signal. High when the module is idle and ready to accept new state or absorption data. |
| `run_i` | input | 1 | Run signal. When asserted, triggers Keccak-f permutation execution starting at the current round. |
| `rand_valid_i` | input | 1 | Random data valid. When asserted, rand_data_i contains fresh entropy for masking. |
| `rand_early_i` | input | 1 | Random data early signal. Signals that random data will arrive early (for pipelined masking). |
| `rand_data_i` | input | [Width/2-1:0] | Random data (768 bits for standard Keccak-f[1600]; one share's worth of randomness). |
| `rand_aux_i` | input | 1 | Auxiliary random bit (used in certain masked implementations). |
| `rand_update_o` | output | 1 | Random update request. Asserted when the module needs fresh randomness. |
| `rand_consumed_o` | output | 1 | Random consumed signal. Asserted when randomness has been consumed and a new value is needed. |
| `complete_o` | output | 1 | Complete signal. Asserted when all 24 rounds of Keccak-f[1600] are finished. |
| `state_o` | output | [Width-1:0] × Share | Output state (1600-bit permuted state). If Share=2, array of two shares. |
| `lc_escalate_en_i` | input | lc_ctrl_pkg::lc_tx_t | Lifecycle escalation enable (for fault injection test). When asserted, triggers error detection. |
| `sparse_fsm_error_o` | output | 1 | FSM sparse encoding error. Asserted if FSM state is corrupted (indicates bit flip or attack). |
| `round_count_error_o` | output | 1 | Round counter error. Asserted if round counter reaches an invalid value. |
| `rst_storage_error_o` | output | 1 | Reset/storage error. Asserted if internal storage is corrupted. |
| `clear_i` | input | mubi4_t (multibit encoded) | Clear/wipe signal. When asserted, state is cleared (secured wipe). |

## Behavioral requirements

- **Keccak-f[1600] permutation.** The output state_o must be the correct result of applying 24 Keccak-f rounds to the input state. Each round applies theta, rho, pi, chi, iota transformations in sequence. The round-dependent constant used in iota is the standard Keccak round constant (RC[round]).

- **Round semantics.** The module iterates through rounds 0..23 on each run_i pulse. The run_i signal initiates the permutation. The module processes one or more rounds per cycle (depending on implementation: typically 1 round per cycle, but can be pipelined for higher throughput). The complete_o signal is asserted when all 24 rounds are done.

- **State absorption (XOR input).** When valid_i is asserted, data_i is XORed into the state at the lane indexed by addr_i. This allows external logic to absorb message data into the state. Absorption occurs before permutation.

- **Theta step.** Compute the XOR of each column's lanes, then XOR each lane with the parity of adjacent columns:
  ```
  C[x] = state[x, 0] XOR state[x, 1] XOR ... XOR state[x, 4]
  D[x] = C[x-1] XOR (C[x+1] <<< 1)
  output[x, y] = state[x, y] XOR D[x]
  ```
  (indices mod 5)

- **Rho step.** Rotate each lane left by a fixed offset table:
  ```
  output[x, y] = state[x, y] <<< offset[x, y]
  ```
  where offset table is standard for Keccak-f[1600].

- **Pi step.** Rearrange lanes:
  ```
  output[x, y] = state[y, 2x + 3y]
  ```
  (indices mod 5)

- **Chi step (non-linear).** For each lane:
  ```
  output[x, y] = state[x, y] XOR ((NOT state[x+1, y]) AND state[x+2, y])
  ```

- **Iota step.** XOR lane [0, 0] with the round constant:
  ```
  output[0, 0] = state[0, 0] XOR RC[round]
  ```
  (other lanes unchanged)

- **Masking (EnMasking=1).** The state is stored as two shares (XOR of shares = original state). All transformations preserve the share structure:
  - XOR operations: done per-share.
  - Rotations: done per-share.
  - Chi (AND): performed using masked AND gadget (e.g., DOM) to avoid unmasking.
  - Iota: XOR with round constant applied to share 0 only (or both shares depending on scheme).

- **Randomness input (EnMasking=1).** The module consumes randomness via rand_data_i and rand_valid_i to execute masked AND gates (chi step). rand_update_o is asserted when fresh randomness is needed; external logic supplies rand_data_i on rand_valid_i.

- **Fault detection (sparse FSM, error outputs).** The module includes sparse-encoded FSM state and error detection logic:
  - sparse_fsm_error_o: asserted if FSM state encoding is invalid.
  - round_count_error_o: asserted if round counter becomes invalid.
  - rst_storage_error_o: asserted if internal state storage is corrupted.

- **Lifecycle escalation (lc_escalate_en_i).** When asserted, triggers heightened error checking and may force the FSM to an error state (for security testing).

- **Clear/wipe (clear_i).** When asserted (multibit encoded for fault tolerance), the state is zeroed or overwritten with random data, erasing the sponge state (security feature).

## Clock domain

Single clock domain driven by `clk_i`; asynchronous reset via `rst_ni`.

## Latency

- Per-round: 1 cycle (typical) or multiple cycles if pipelined.
- Full permutation (24 rounds): ~24 cycles (unrolled: 1 cycle; fully pipelined: 1 cycle after steady-state).

## Example

Scenario: Apply a single Keccak-f[1600] permutation to a state, then output.

| Operation | Input | Round | State | Output | Notes |
|-----------|-------|-------|-------|--------|-------|
| Reset | - | - | 0x00...00 | - | State cleared. |
| Absorb data | valid=HIGH, addr=0, data=M[0] | - | M[0] at lane 0 | ready=HIGH | First lane XORed. |
| Absorb data | valid=HIGH, addr=1, data=M[1] | - | M[1] at lane 1 | ready=HIGH | More lanes absorbed. |
| Run permutation | run=HIGH | - | - | (computing) | Keccak-f execution begins. |
| (none) | (none) | 0..23 | (transforming) | (computing) | Theta, rho, pi, chi, iota applied per round. |
| Complete | - | 24 | (done) | state_o=result, complete=HIGH | Final permuted state output. |

Constraints:
- Data must be absorbed (valid_i asserted) before run_i to affect the permutation.
- Each addr_i must be in range 0..24 (for standard Keccak-f[1600]).
- Round counter must not wrap; if MaxRound is exceeded, round_count_error_o is asserted.
- For EnMasking=1, data_i and state_o are two-share arrays; external logic must handle masking/unmasking.
