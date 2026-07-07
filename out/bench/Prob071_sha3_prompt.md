Design a module called TopModule. This module is the SHA-3 / SHAKE sponge controller, orchestrating message absorption and digest squeezing using the Keccak-f[1600] permutation, with optional 2-share masking and output padding/rate control.

## Overview

TopModule is the top-level SHA-3 / SHAKE sponge controller. It manages the sponge construction: absorbing message blocks via XOR into the state, running Keccak-f[1600] permutations, and squeezing digest output. The module supports:
- Multiple SHA-3 modes (SHA-3-256, SHA-3-384, SHA-3-512) and SHAKE variants (SHAKE128, SHAKE256).
- Message padding (SHA-3-specific: pad10*1).
- Strength control (capacity bits reserved for security).
- Optional 2-share DOM masking for side-channel resistance.
- Sparse-encoded FSM with fault detection.
- Entropy input for PRNG and masked computation.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `EnMasking` | Enable 2-share masking. If 1, state and message are masked. | bit, default 0. |
| `Share` | Derived: 2 if EnMasking else 1. | int, read-only. |

## Interface

| Port | Direction | Width / Type | Description |
|------|-----------|--------------|-------------|
| `clk_i` | input | 1 | Clock. Sponge state, FSM, and permutation driven by rising edge. |
| `rst_ni` | input | 1 | Async active-low reset. State and FSM cleared. |
| `msg_valid_i` | input | 1 | Message valid. When asserted, msg_data_i is ready to be absorbed. |
| `msg_data_i` | input | [MsgWidth-1:0] × Share | Message data (typically 136 bytes for rate-1088, split into shares if EnMasking=1). |
| `msg_strb_i` | input | [MsgStrbW-1:0] | Message strobe (per-byte valid mask). Indicates which bytes of msg_data_i are valid. |
| `msg_ready_o` | output | 1 | Message ready. Asserted when module is ready to accept message data. |
| `rand_valid_i` | input | 1 | Random valid. When asserted, rand_data_i contains entropy for masking. |
| `rand_early_i` | input | 1 | Random early. Signals that random data will arrive early (for pipelined masking). |
| `rand_data_i` | input | [StateW/2-1:0] | Random data (one share's worth of Keccak state). |
| `rand_aux_i` | input | 1 | Auxiliary random bit. |
| `rand_update_o` | output | 1 | Random update request. Asserted when fresh entropy is needed. |
| `rand_consumed_o` | output | 1 | Random consumed. Asserted when randomness has been consumed. |
| `ns_data_i` | input | [NSRegisterSize*8-1:0] | Name/strength register input (controls hash mode and strength). |
| `mode_i` | input | sha3_mode_e (3 bits) | SHA-3 mode: SHA3_256, SHA3_384, SHA3_512, SHAKE128, SHAKE256, or SHA3_None. |
| `strength_i` | input | keccak_strength_e (2 bits) | Keccak strength: 128, 256 bits (or other security levels). Determines capacity. |
| `start_i` | input | 1 | Start signal. Initiates a new hash/SHAKE computation. |
| `process_i` | input | 1 | Process signal. Triggers message processing (absorption and permutation). |
| `run_i` | input | 1 | Run signal. Permits permutation execution. |
| `done_i` | input | mubi4_t (multibit encoded) | Done signal. When asserted, signals end of message (for padding). |
| `absorbed_o` | output | mubi4_t | Absorbed signal. Multibit encoded; asserted after message is absorbed and permutation completes. |
| `squeezing_o` | output | 1 | Squeezing signal. High when in squeeze phase (outputting digest). |
| `block_processed_o` | output | 1 | Block processed signal. Asserted after each block is absorbed and permuted. |
| `sha3_fsm_o` | output | sha3_st_e (3 bits) | FSM state output (for visibility). Indicates current sponge phase (idle, absorb, squeeze, etc.). |
| `state_valid_o` | output | 1 | State valid. Asserted when state_o contains valid output data. |
| `state_o` | output | [StateW-1:0] × Share | Output state (1600-bit Keccak state, or squeezed output in chunks). If Share=2, two shares. |
| `run_req_o` | output | 1 | Run request. Asserted when permutation (Keccak-f) needs to execute. |
| `run_ack_i` | input | 1 | Run acknowledge. Asserted when permutation is complete. |
| `lc_escalate_en_i` | input | lc_ctrl_pkg::lc_tx_t | Lifecycle escalation signal. |
| `error_o` | output | err_t (struct) | Error flags (alert, recov_alert, etc.). Indicates detected faults. |
| `sparse_fsm_error_o` | output | 1 | FSM sparse encoding error. |
| `count_error_o` | output | 1 | Message/round counter error. |
| `keccak_storage_rst_error_o` | output | 1 | Keccak storage/reset error. |

## Behavioral requirements

- **Sponge construction.** The SHA-3 / SHAKE sponge operates as follows:
  1. **Initialization:** State is set to zero.
  2. **Absorption:** Message blocks are XORed into the first `rate` bits of state. After each block, Keccak-f[1600] is applied.
  3. **Padding:** At end-of-message, pad10*1(domain, length) is applied to ensure security domain separation and length encoding.
  4. **Squeezing:** After the final permutation, output is extracted in `rate`-bit chunks, with permutation between chunks if needed.

- **SHA-3 modes.**
  - SHA-3-256: 256-bit output, capacity = 512 bits, rate = 1088 bits, domain = 0x06.
  - SHA-3-384: 384-bit output, capacity = 768 bits, rate = 832 bits, domain = 0x06.
  - SHA-3-512: 512-bit output, capacity = 1024 bits, rate = 576 bits, domain = 0x06.
  - SHAKE128: Variable-length output, capacity = 256 bits, rate = 1344 bits, domain = 0x1F.
  - SHAKE256: Variable-length output, capacity = 512 bits, rate = 1088 bits, domain = 0x1F.

- **Rate and capacity.** The rate (portion of state used for message) and capacity (reserved for security) depend on the mode_i and strength_i. The sponge ensures that the capacity is not accessible to the adversary.

- **Message absorption.** When msg_valid_i is asserted, msg_data_i (with per-byte validity from msg_strb_i) is XORed into the state at the rate portion. Multiple blocks can be absorbed sequentially before permutation (if the sponge is in absorb phase).

- **Padding (pad10*1).** After the final message block, padding is applied:
  ```
  padded = message || 0x06 || 0x00 || ... || 0x00 || 0x80
  ```
  where 0x06 is the SHA-3 domain separator (or 0x1F for SHAKE), and the final 0x80 indicates end of padding. The padding is such that the message length (including padding) is a multiple of the rate.

- **Keccak-f execution.** The module requests permutation via run_req_o. When run_ack_i is asserted, the Keccak-f permutation has completed. The permutation is pipelined with message absorption and squeezing.

- **Squeeze phase.** After the final permutation and padding, the module transitions to squeeze phase. Output is extracted in chunks of up to the rate width. state_o contains the squeezed data. For SHA-3, squeezing stops after the target output length; for SHAKE, squeezing continues until external logic asserts done_i.

- **FSM state machine.** The module uses a sparse-encoded FSM with states:
  - Idle: Waiting for start_i.
  - Absorb: Absorbing message blocks.
  - Squeeze: Outputting digest.
  - Error: FSM fault detected.

- **Masking (EnMasking=1).** If enabled, the state and message are split into two shares. Arithmetic operations (XOR) are performed per-share. The Keccak-f permutation is executed on both shares independently (or in a masked variant if Prob070 is used). External logic must manage share recombination or output in masked form.

- **Entropy input (rand_data_i, rand_valid_i).** When masking is enabled, the module may request fresh entropy for masked Keccak or PRNG operations. rand_update_o is asserted when fresh entropy is needed; external logic supplies rand_data_i on rand_valid_i.

- **Fault detection.** The module includes error detection:
  - sparse_fsm_error_o: FSM state encoding invalid.
  - count_error_o: Message count or round count corrupted.
  - keccak_storage_rst_error_o: Internal storage corruption.
  - error_o: Packed error flags (alert, recov_alert, fatal_alert).

## Clock domain

Single clock domain driven by `clk_i`; asynchronous reset via `rst_ni`.

## Latency

- Per-block latency: ~24 cycles (Keccak-f[1600] permutation) + overhead for absorption/squeezing.
- Total for full SHA-3-256: ~24–50 cycles (for small message; scales with message size).

## Example

Scenario: Compute SHA-3-256 of a message.

| Input | Cycle | FSM State | Message | State | Output | Notes |
|-------|-------|-----------|---------|-------|--------|-------|
| start=HIGH, mode=SHA3_256, strength=256 | 0 | Idle → Absorb | - | 0x00...00 | - | SHA-3-256 initialized. Rate = 1088 bits, capacity = 512 bits. |
| msg_valid=HIGH, msg_data=M[0] (136 bytes), msg_strb=all valid | 1-N | Absorb | M[0] | M[0] XORed into rate | - | Message block absorbed via XOR. |
| process=HIGH, run_i=HIGH | N+1 | Absorb → (Keccak-f running) | - | - | - | Keccak-f permutation requested. |
| run_ack=HIGH | N+25 | Squeeze | - | (permuted) | - | Keccak-f completes. Permuted state available. |
| done=HIGH | N+26 | Squeeze → (padding) | - | - | - | End-of-message signaled; padding applied. |
| (squeeze loop) | N+27...N+50 | Squeeze | - | - | state_o (first 136 bytes of output) | Output extracted in rate-sized chunks. |
| (final squeeze) | N+51 | Squeeze → Idle | - | - | state_o = H (256 bits / 32 bytes of SHA-3-256) | Final output ready. Digest = first 256 bits of state. |

Constraints:
- mode_i and strength_i must be consistent and remain stable during a hash computation.
- done_i must be asserted only after the final message block (padding requires special handling).
- For EnMasking=1, state_o and msg_data_i are shared; external logic must unsham.
- Message blocks must not exceed the rate (rate is determined by mode and strength).
