Design a module called TopModule. This module is an Ascon authenticated encryption hardware accelerator implementing the Ascon AEAD (Authenticated Encryption with Associated Data) cipher and hash functions via a TL-UL register interface, with key material sourced from the Key Manager, entropy from EDN, and error handling via alerts.

## Overview

TopModule provides hardware acceleration for the Ascon lightweight authenticated encryption algorithm (standardized by NIST). It accepts configuration and data input via TL-UL registers, streams plaintext/ciphertext/AAD (Associated Authenticated Data) through internal processing, and outputs encrypted/decrypted data and authentication tags. The module is lifecycle-gated (disabled outside DEV/PROD), uses sideload keys from the Key Manager, and reports completion via interrupts and busy flags.

## Parameters

| Parameter | Meaning |
|-----------|---------|
| `AlertAsyncOn` | Per-alert async/sync mode. |
| `AlertSkewCycles` | Alert propagation delay. |

(Internal parameters like Ascon permutation constants are typically fixed by the algorithm.)

## Interface

### Clocks & Resets
- `clk_i`, `rst_ni`: Main clock and active-low asynchronous reset.
- `rst_shadowed_ni`: Shadow reset for redundant state protection.
- `clk_edn_i`, `rst_edn_ni`: EDN (Entropy Distribution Network) clock and reset.

### TL-UL Register Bus
- `tl_i` (input): TL-UL host-to-device request (32-bit address, 32-bit data, write enable, etc.).
- `tl_o` (output): TL-UL device-to-host response (32-bit read data, valid, error).

Registers control Ascon operation (cipher selection, data input, output readback) and status (busy, done, error flags).

### Key Manager Interface
- `keymgr_key_i` (input): Sideload key from Key Manager (typically 256-bit key, valid flag, ready flag).

The sideload key is automatically available to Ascon; no explicit request is needed. Key Manager ensures the key is appropriate for the current device state.

### Lifecycle Gating
- `lc_escalate_en_i` (input): Lifecycle escalation enable; asserted if an error condition requires escalation to the reset manager.

### Entropy Interface
- `clk_edn_i`, `rst_edn_ni`: EDN clock and reset (independent of main `clk_i`).
- `edn_o` (output): Request to Entropy Distribution Network (edn_req, address/endpoint, etc.).
- `edn_i` (input): Response from EDN (edn_ack, edn_bus with entropy data, FIPS indicator).

Entropy is used for masking (side-channel resistance) and potentially for internal randomization (e.g., random injection of dummy operations).

### Idle Status
- `idle_o` (output): Mubi4-encoded idle signal; asserts when Ascon is not processing data (ready for new operation).

### Interrupts
- No dedicated interrupt outputs; completion is signaled via the idle flag and status registers.

Alternatively, completion can be polled via the STATUS register.

### Alerts
- `alert_tx_o[NumAlerts-1:0]` (output): Alert transmit (differential; typically recovery and fatal alerts).
- `alert_rx_i[NumAlerts-1:0]` (input): Alert acknowledge/ping.

Fatal alert on:
- Key manager key invalid or not ready.
- Escalation signal asserted (detected error requiring reset).
- Register integrity error.
- Ascon state machine corruption.

Recovery alert on:
- Invalid register writes (e.g., out-of-order commands).
- Entropy source failure (if masking is enabled).

## Control Registers (via TL-UL)

- **OPERATION**: Selects Ascon mode (ENC for encryption, DEC for decryption, HASH for hashing).
- **KEY_VALID** / **KEY_READY**: Status of sideload key from Key Manager.
- **CONFIG**: Cipher parameters (e.g., Ascon-128 vs. Ascon-80pq; not typically changed at runtime).
- **NONCE[0..3]**: Nonce input (128 bits for Ascon-128; 160 bits for Ascon-80pq).
- **AAD_LENGTH**: Length of associated authenticated data (bits or bytes).
- **PAYLOAD_LENGTH**: Length of plaintext/ciphertext payload.
- **AADATA[i]** (write-only): AAD data input (streamed in 32-bit words).
- **DATA_IN[i]** (write-only): Plaintext/ciphertext input data.
- **TAG_IN[i]** (write-only): Tag input for decryption verification.
- **DATA_OUT[i]** (read-only): Ciphertext/plaintext output (streamed 32-bit words).
- **TAG[i]** (read-only): Authentication tag output.
- **STATUS**: Current state (IDLE, ABSORBING, SQUEEZING, DONE, ERROR), progress counters.
- **INT_STATUS / INT_EN / INT_TEST**: Interrupt control (if interrupts are used).
- **ALERT_TEST**: Alert test injection.

## Behavioral Requirements

### Ascon AEAD Cipher Operation (Encryption)

1. **Input Configuration**:
   - Software writes OPERATION = ENC.
   - Software writes NONCE (128 or 160 bits, depending on variant).
   - Software configures AAD_LENGTH and PAYLOAD_LENGTH.
   - Key Manager provides sideload key (KEY_VALID asserts).

2. **Absorption Phase** (Absorb AAD + Plaintext):
   - TopModule initializes internal state with key, nonce, and Ascon parameters.
   - Software writes AAD data to AADATA registers (up to AAD_LENGTH bits).
   - TopModule absorbs AAD into the internal state via the Ascon permutation.
   - Software writes plaintext data to DATA_IN registers (up to PAYLOAD_LENGTH bits).
   - TopModule absorbs plaintext and generates intermediate ciphertext.

3. **Squeezing Phase** (Output Ciphertext + Tag):
   - TopModule finalizes the state using the key.
   - TopModule outputs ciphertext (read-only, via DATA_OUT registers).
   - TopModule outputs a 128-bit authentication tag (read-only, via TAG registers).
   - STATUS.state transitions to DONE.

### Ascon AEAD Cipher Operation (Decryption)

1. Similar to encryption, but OPERATION = DEC.
2. Software writes AAD and ciphertext (instead of plaintext).
3. TopModule absorbs AAD and ciphertext, producing plaintext.
4. TopModule outputs plaintext and computes authentication tag.
5. Software reads the computed tag from TAG registers and compares against received tag.
6. If match, data is authenticated; if mismatch, decryption failed (tampering detected).

### Ascon Hash Operation

- OPERATION = HASH.
- Software writes data to be hashed (no key, no nonce, no AAD).
- TopModule applies the Ascon permutation to produce a hash output (256-bit or 512-bit, depending on variant).
- Result is available in TAG registers.

### Streaming Data Input/Output

- **Data Input**: Software writes plaintext/AAD/ciphertext in 32-bit chunks to AADATA / DATA_IN registers.
- **Data Output**: Software reads processed data from DATA_OUT and TAG registers in 32-bit chunks.
- Streaming is synchronous to `clk_i` TL-UL clock.

**Handling Partial Words**:
- If data length is not a multiple of 32 bits, TopModule pads the final word (typically with zeros).
- Software specifies byte length via register fields to indicate valid bytes in the last word.

### Ascon Permutation

TopModule internally implements the Ascon permutation (a 320-bit (40-byte) state update):
- Substitution layer (S-box).
- Linear layer (diffusion).
- Typically 12 rounds for initialization, 6 rounds for absorption, 8 rounds for finalization.

Exact round counts depend on the Ascon variant (Ascon-128 vs. Ascon-80pq).

### Key Integration

- Key Manager provides sideload key via `keymgr_key_i`.
- Key is incorporated into the Ascon state initialization and finalization.
- Key bits are mixed into the initial state; key is never directly output (remain secret).

### Masking & Side-Channel Resistance

- If Ascon is masked (boolean or arithmetic masking), TopModule requests random bits from EDN.
- Masking is applied to sensitive state values (e.g., S-box inputs) to resist differential power analysis (DPA).
- Entropy request is made asynchronously; if EDN does not respond, a recovery alert may be asserted, but operation can continue with reduced masking (graceful degradation).

### Error Conditions

1. **Key Not Ready**: If KEY_READY from Key Manager is not asserted when OPERATION is issued, TopModule returns to IDLE and asserts a fatal alert.
2. **Invalid Operation Sequence**: If software writes data before the state machine is in the ABSORBING phase, a recovery alert is asserted.
3. **Register Integrity Error**: If a register read/write detects parity/ECC error, fatal alert asserts.
4. **Escalation Triggered**: If `lc_escalate_en_i` is asserted (external error requiring system reset), TopModule aborts and asserts a fatal alert.
5. **Entropy Source Failure**: If EDN does not respond within timeout (if masking is enabled), recovery alert asserts; operation may continue with weaker security (or stall, depending on design).

### State Machine Overview

- **IDLE**: Waiting for OPERATION command from software.
- **ABSORBING**: Processing AAD and plaintext/ciphertext data.
- **SQUEEZING**: Finalizing state and outputting tag.
- **DONE**: Operation complete; data available for readout.
- **ERROR**: Fatal error detected; operation aborted; device requires reset.

### Reset Behavior

- On reset (`rst_ni` or `rst_shadowed_ni`), all state is cleared.
- All in-flight operations are aborted.
- Registers reset to defaults (IDLE state).
- Interrupts and alerts are cleared.

### Lifecycle Gating

- If device is not in DEV or PROD state (per `lc_escalate_en_i` or similar gating mechanism), Ascon may be disabled or return to IDLE without processing.
- (Exact gating depends on lifecycle implementation; shown via escalation signal.)

### Timing & Performance

- **Initialization**: 1-10 cycles (load key, nonce, parameters).
- **Absorption**: 1 cycle per 32-bit word absorbed (approx.), plus overhead for permutation rounds.
- **Finalization**: 10-50 cycles (depends on number of permutation rounds).
- **Overall Latency**: For a 1 KB payload with 16-byte AAD, typical latency is 500-2000 cycles (implementation-dependent).

### Output Validation

- **Ciphertext/Plaintext**: Byte-for-byte reconstruction of input data, encrypted/decrypted.
- **Tag**: 128-bit (Ascon-128) or 256-bit (Ascon-80pq) authentication tag, verified by software on decryption.

## Boundary Parameters & Constraints

- **Ascon Variant**: Typically Ascon-128 (128-bit key, 128-bit nonce, 128-bit tag) or Ascon-80pq (160-bit key, 160-bit nonce, 128-bit tag).
- **State Size**: 320 bits (40 bytes) for internal permutation state.
- **Maximum AAD Length**: Typically 2^64 bits (no practical limit at register interface).
- **Maximum Payload Length**: Typically 2^64 bits.
- **Streaming Granularity**: 32-bit words (TL-UL data width).

## Synchronization & Clocking

- Main logic operates synchronously to `clk_i` (TL-UL clock).
- EDN requests/responses are synchronized from `clk_edn_i` domain via CDC (Clock Domain Crossing) logic.
- Idle signal (`idle_o`) is differentially encoded (Mubi4) for fault tolerance.

## Example Scenario: Encryption

1. Software writes OPERATION = ENC, configures key (via Key Manager), nonce, AAD length (100 bytes), payload length (256 bytes).
2. Software writes 100 bytes of AAD data in 32-bit chunks to AADATA register.
3. TopModule absorbs AAD (permutation rounds applied).
4. Software writes 256 bytes of plaintext to DATA_IN register in 32-bit chunks.
5. TopModule absorbs plaintext and outputs corresponding ciphertext (to DATA_OUT register).
6. TopModule finalizes the state (additional permutation rounds).
7. TopModule outputs 128-bit authentication tag to TAG registers.
8. STATUS.state transitions to DONE.
9. Software reads DATA_OUT register to retrieve ciphertext, reads TAG register to get the tag.
10. Software transmits (ciphertext || tag) to recipient.

## Example Scenario: Decryption & Verification

1. Software receives (ciphertext || tag).
2. Software writes OPERATION = DEC, nonce, AAD length, ciphertext length.
3. Software writes AAD data to AADATA register.
4. Software writes received ciphertext to DATA_IN register.
5. TopModule absorbs AAD and ciphertext, outputting plaintext.
6. TopModule finalizes and computes tag.
7. Software reads plaintext from DATA_OUT, reads computed tag from TAG.
8. Software compares computed tag against received tag.
9. If match: plaintext is authentic; proceed.
10. If mismatch: tampering detected; discard plaintext and abort.

## Security Considerations

- **Authenticated Encryption**: Ascon ensures both confidentiality (encryption) and authenticity (tag). Both must be verified for security.
- **Nonce Uniqueness**: For each distinct key, every nonce used must be unique. Nonce reuse is catastrophic (leaks plaintext).
- **Key Isolation**: Keys are sourced from Key Manager and never directly accessible to software; maximizes key security.
- **Masking**: Ascon is masked to resist DPA; entropy source must provide sufficient randomness.
- **Constant-Time**: Ascon tag verification should be constant-time (no early exit on mismatch); TopModule implements this in hardware.

