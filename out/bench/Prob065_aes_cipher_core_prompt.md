Design a module called TopModule. This module is the AES encryption/decryption datapath, orchestrating the full AES cipher pipeline (SubBytes, ShiftRows, MixColumns, AddRoundKey) with masking support, entropy-driven PRNG reseed, and fault-detection FSM controls.

## Overview

TopModule is the cryptographic core of an AES implementation supporting AES-128/192/256 encryption and decryption. It accepts plaintext/ciphertext, a symmetric key, and operation control signals, then executes the AES round function sequentially (SubBytes, ShiftRows, MixColumns/InvMixColumns, AddRoundKey) for 10, 12, or 14 rounds depending on key length and direction. The module is built around a clocked state register (the 4×4 byte matrix) and a dual-key register (full key and decryption-key-schedule key). It includes:
- Configurable 2-share DOM masking for side-channel resistance.
- PRNG-based masked S-box and masking randomness generation.
- Sparse-encoded FSM with error detection for fault tolerance.
- Valid/ready handshake for input plaintext/ciphertext and output ciphertext/plaintext.
- Entropy input for PRNG reseed and fault clearing.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `AES192Enable` | Support AES-192. If 0, only AES-128/256. | bit, default 1. |
| `CiphOpFwdOnly` | Restrict to forward encryption only. If 1, CIPH_INV is not supported. | bit, default 0. |
| `SecMasking` | Enable 2-share DOM masking. If 1, state and key are shared; S-box is masked. | bit, default 1. |
| `SecSBoxImpl` | S-box implementation: SBoxImplLut, SBoxImplCanright, SBoxImplCanrightMasked, SBoxImplDom. | enum, default SBoxImplDom. |
| `SecAllowForcingMasks` | Allow software to force/override mask values for test. | bit, default 0. |
| `SecSkipPRNGReseeding` | Disable automatic PRNG reseed; entropy input ignored. | bit, default 0. |
| `EntropyWidth` | Width of entropy input bus (typically 32 or 64). | int, default 32. |
| `NumShares` | Derived: 2 if SecMasking else 1. | int, read-only. |
| `RndCnstMaskingLfsrSeed`, `RndCnstMaskingLfsrPerm` | PRNG constants (seed and permutation for LFSR-based masking). | logic vectors. |

## Interface

| Port | Direction | Width / Type | Description |
|------|-----------|--------------|-------------|
| `clk_i` | input | 1 | Clock. State, keys, and FSM advance on rising edge. |
| `rst_ni` | input | 1 | Async active-low reset. State and keys cleared. |
| `in_valid_i` | input | SP2V (2 bits) | Sparse-encoded valid signal for plaintext/ciphertext input. `SP2V_HIGH` means input is ready on state_init_i. |
| `in_ready_o` | output | SP2V (2 bits) | Sparse-encoded ready signal for input. `SP2V_HIGH` means the module is ready to accept a new block. |
| `out_valid_o` | output | SP2V (2 bits) | Sparse-encoded valid signal for output ciphertext/plaintext. `SP2V_HIGH` means state_o contains the result. |
| `out_ready_i` | input | SP2V (2 bits) | Sparse-encoded ready signal for output. `SP2V_HIGH` means external logic has accepted the result. |
| `cfg_valid_i` | input | 1 | Configuration validity (used by control FSM to validate mode/key-length settings). |
| `op_i` | input | 2 (enum) | Operation: `CIPH_FWD` = encrypt, `CIPH_INV` = decrypt. Ignored if CiphOpFwdOnly=1. |
| `key_len_i` | input | 3 (enum) | Key length: `AES_128`, `AES_192`, `AES_256`. Determines round count. |
| `crypt_i` | input | SP2V (2 bits) | Sparse-encoded control. When high, instructs the core to begin encryption/decryption. |
| `crypt_o` | output | SP2V (2 bits) | Sparse-encoded status. Reflects crypt_i after FSM processing. |
| `dec_key_gen_i` | input | SP2V (2 bits) | Sparse-encoded request to generate decryption key schedule (for equivalent inverse cipher). |
| `dec_key_gen_o` | output | SP2V (2 bits) | Sparse-encoded status reflecting dec_key_gen_i after processing. |
| `prng_reseed_i` | input | 1 | Request to reseed the PRNG (used for masking entropy). When high, entropy_i is consumed. |
| `prng_reseed_o` | output | 1 | Status flag reflecting prng_reseed_i. |
| `key_clear_i` | input | 1 | Request to clear (zero) the key register. |
| `key_clear_o` | output | 1 | Status reflecting key_clear_i. |
| `data_out_clear_i` | input | 1 | Request to clear the output data register. |
| `data_out_clear_o` | output | 1 | Status reflecting data_out_clear_i. |
| `alert_fatal_i` | input | 1 | Fatal alert input (from external fault-detection circuitry). When asserted, FSM transitions to error state. |
| `alert_o` | output | 1 | Alert output. Asserted if an internal error is detected (FSM corruption, control signal mismatch, etc.). |
| `prd_clearing_state_i` | input | [3:0][3:0][7:0] × NumShares | Pseudo-random data for state clearing (fault recovery). |
| `prd_clearing_key_i` | input | [7:0][31:0] × NumShares | Pseudo-random data for key clearing. |
| `force_masks_i` | input | 1 | Force mask value (test feature; requires SecAllowForcingMasks=1). |
| `data_in_mask_o` | output | [3:0][3:0][7:0] | Masked input state (or mask share, depending on masking scheme). |
| `entropy_req_o` | output | 1 | Entropy request. Asserted when the module needs fresh entropy for PRNG reseed. |
| `entropy_ack_i` | input | 1 | Entropy acknowledge. When asserted, entropy_i is latched. |
| `entropy_i` | input | [EntropyWidth-1:0] | Fresh entropy from a true-random or pseudo-random source. Feeds the masking LFSR. |
| `state_init_i` | input | [3:0][3:0][7:0] × NumShares | Initial state (plaintext/ciphertext). If NumShares=2, two shares. |
| `key_init_i` | input | [7:0][31:0] × NumShares | Initial key (cipher key or first round key, depending on mode). |
| `state_o` | output | [3:0][3:0][7:0] × NumShares | Output state (ciphertext/plaintext). Updated when out_valid_o is high. |

## State & Control Flow

**Finite State Machine (Sparse-Encoded):**
- `CIPHER_CTRL_IDLE`: Waiting for in_valid_i and crypt_i.
- `CIPHER_CTRL_INIT`: Loading plaintext/ciphertext and initial round key (AddRoundKey before round 0).
- `CIPHER_CTRL_ROUND`: Executing SubBytes, ShiftRows, (optionally) MixColumns, AddRoundKey for rounds 0..n-2.
- `CIPHER_CTRL_FINISH`: Final round (no MixColumns), output result.
- `CIPHER_CTRL_PRNG_RESEED`: Consuming entropy and reseeding PRNG.
- `CIPHER_CTRL_CLEAR_S`, `CIPHER_CTRL_CLEAR_KD`: Clearing state or key using PRD.
- `CIPHER_CTRL_ERROR`: Detected FSM fault or external alert. Stays in error until reset.

**Handshake:** 
- Input (plaintext/ciphertext): in_valid_i and in_ready_o form a request/acknowledge pair. When both are high for one cycle, input is latched.
- Output (ciphertext/plaintext): out_valid_o and out_ready_i form a valid/ready pair. When both are high for one cycle, output is accepted and new inputs may begin.
- crypt_i triggers FSM to begin cipher operation after input is latched.

## Behavioral requirements

- **AES cipher conformance.** The output state_o must equal the standard AES encryption (op_i=CIPH_FWD) or decryption (op_i=CIPH_INV) of the input state_init_i using the key key_init_i, for the selected key_len_i (128, 192, or 256 bits). Round count is determined by key length: 10 rounds for 128-bit key, 12 for 192-bit, 14 for 256-bit.

- **Round function.** Each round applies:
  1. SubBytes: S-box substitution on each of the 16 bytes.
  2. ShiftRows: Cyclic byte shifts per row.
  3. MixColumns (rounds 0..n-2) or no MixColumns (final round): Linear transformation per column (skipped in final round).
  4. AddRoundKey: XOR with the round key.
  (For decryption, the order and transformations may differ per the Equivalent Inverse Cipher or Inverse Cipher variant; the module supports both.)

- **Key schedule.** The module maintains a full 8-word (256-bit) key register. The key_expand submodule derives the next round key from the current round key and round number. For encryption, keys are derived in forward order; for decryption, keys are derived in inverse order or the Equivalent Inverse Cipher uses a pre-computed Inverse Key Schedule.

- **Masking (SecMasking=1).** State and key are stored as two shares (XORed shares equal the secret). Arithmetic operations (XOR) are performed per-share. The S-box is replaced with a masked variant that accepts share input and produces share output without ever unmasking the value. The PRNG supplies random masks. On output, the shares are not automatically unmasked by the module; if unmasking is required, it is external.

- **PRNG & entropy.** An LFSR-based PRNG generates masking randomness during round operations. When entropy_req_o is asserted and entropy_ack_i is high, fresh entropy from entropy_i reseeds the PRNG state. If SecSkipPRNGReseeding=1, entropy input is ignored.

- **Fault detection & clearing.** If the FSM detects corruption (sparse encoding violation, unexpected transition), alert_o is asserted and FSM enters ERROR state. External logic may assert alert_fatal_i to force the FSM to error state. The CLEAR_S and CLEAR_KD states overwrite state and key with pseudo-random values (prd_clearing_state_i, prd_clearing_key_i) to prevent state leakage. These operations are non-destructive (they overwrite with random, not useful computation), used for fault recovery and cleanup.

- **Data in/out masking.** data_in_mask_o exposes the input mask (or a masked version of input state) for verification or testing. force_masks_i allows test vectors to override PRNG masks (if SecAllowForcingMasks=1).

## Timing

- **Latency.** The cipher core takes multiple cycles: 1 cycle for INIT, then 1 cycle per round (10/12/14 cycles depending on key length), then 1 cycle for FINISH = 12/14/16 cycles total (approximately). Entropy/PRNG reseed may add cycles if entropy input stalls.
- **Pipelining.** Not internally pipelined; rounds are sequential. Multiple blocks may be submitted back-to-back (pipelined at the interface level) by respecting handshake timing.

## Clock domain

Single clock domain driven by `clk_i`; asynchronous reset via `rst_ni`.

## Limitations & assumptions

- **No on-chip key derivation.** The initial key key_init_i is assumed to be the first round key (or the original cipher key, depending on external key scheduling). If using the built-in key_expand, external logic must pre-compute and load keys.
- **Masking domain.** SecMasking uses 2-share Boolean masking; higher-order masking is not supported.
- **No GCM integration.** This is the cipher core only; AES-GCM requires GHASH (separate module).

## Example

Scenario: Encrypt a 128-bit plaintext with AES-128.

| Cycle | Input | FSM State | Internal State | Output | Notes |
|-------|-------|-----------|-----------------|--------|-------|
| 0 | Reset | - | 0x00...00 | - | All registers cleared. |
| 1 | in_valid=HIGH, plaintext=P, key=K | IDLE | - | in_ready=HIGH | Ready for input. |
| 2 | crypt=HIGH | INIT | P (initial state) | - | AddRoundKey with round-0 key. |
| 3-11 | (none) | ROUND (rounds 0-8) | transformed state | - | SubBytes, ShiftRows, MixColumns, AddRoundKey loop. |
| 12 | out_ready=HIGH | FINISH | final transformed state | out_valid=HIGH, state_o=C | Final round (no MixColumns). Output ciphertext C. |
| 13 | - | IDLE | C retained | - | Awaiting next plaintext. |

Constraints:
- key_len_i must match the actual key length (128, 192, or 256 bits).
- Do not assert in_valid_i and crypt_i in the same cycle; follow the handshake protocol.
- If SecMasking=1, state_init_i, key_init_i, and state_o are shared; external logic must unsham or work with shares.
