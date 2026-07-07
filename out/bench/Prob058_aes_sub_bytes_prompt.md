Design a module called TopModule. This module is a registered AES SubBytes operation that applies the AES S-box byte substitution to all 16 bytes of a 4x4 state matrix with masked I/O and PRD support for direction control.

## Overview

TopModule implements the AES SubBytes step with masked state and pseudo-random data (PRD) for fault tolerance and side-channel resistance. It applies the AES S-box (or its inverse) independently to each of the 16 state bytes. The module includes control signals for enable, output handshaking, error reporting, and parameterizable S-box implementation. This is a *pipelined* version with registered state inside; input and output ports are synchronous.

## Parameters

| Parameter | Type | Default | Meaning |
|-----------|------|---------|---------|
| `SecSBoxImpl` | sbox_impl_e | SBoxImplDom | S-box implementation variant: `SBoxImplLut` (lookup table, unmasked), `SBoxImplCanright` (polynomial-based, unmasked), `SBoxImplCanrightMasked` (masked Canright), `SBoxImplCanrightMaskedNoreuse` (masked variant), `SBoxImplDom` (DOM-masked, default). Masked variants accept `mask_i` and `prd_i`; unmasked versions ignore them. |

## Interface

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk_i` | input | 1 | Clock. |
| `rst_ni` | input | 1 | Active-low reset. |
| `en_i` | input | Sp2VWidth | Sparse 2-of-4 encoded enable (multi-bit Boolean with redundant encoding). `en_i` must be valid (encoding check); invalid encodings trigger `en_err`. |
| `out_req_o` | output | Sp2VWidth | Sparse 2-of-4 output request handshake signal. Indicates output data and status are valid. |
| `out_ack_i` | input | Sp2VWidth | Sparse 2-of-4 output acknowledge handshake signal. |
| `op_i` | input | 2 | Cipher operation: `CIPH_FWD = 2'b01` (encryption/SubBytes forward), `CIPH_INV = 2'b10` (decryption/SubBytes inverse, applies inverse S-box). |
| `data_i` | input | 128 | Input 4x4 state matrix, organized as `[3:0][3:0][7:0]` (row, column, byte bits). Each byte is substituted. |
| `mask_i` | input | 128 | Mask values (for masked implementations), same layout as `data_i`. |
| `prd_i` | input | 160 | Pseudo-random data for masking: 16 bytes × (8 + 20) bits = 160 bits total (each S-box output gets 20 bits of randomness). |
| `data_o` | output | 128 | Output 4x4 state matrix after SubBytes, same layout as `data_i`. For unmasked or correctly-unmasked outputs, represents the true result. |
| `mask_o` | output | 128 | Output mask (for masked implementations), same layout as `data_i`. For unmasked implementations, outputs zero. |
| `err_o` | output | 1 | Error flag: 1 if an error is detected (e.g., invalid encoding, control-flow violation). |

## Behavioral requirements

- **SubBytes transformation.** Each of the 16 state bytes is independently substituted:
  - **Forward** (`CIPH_FWD`): Byte `b` is replaced with `S[b]`, where `S` is the AES forward S-box (a 256-entry lookup table).
  - **Inverse** (`CIPH_INV`): Byte `b` is replaced with `S_inv[b]`, where `S_inv` is the AES inverse S-box.
- **Masked computation.** For masked S-box implementations:
  - `mask_i` provides input masking shares; the output `data_o` and `mask_o` maintain the masked representation (e.g., `data_o ⊕ mask_o` equals the true result).
  - `prd_i` provides randomness for masking refreshes and internal security.
  - Correctness: `data_o ⊕ mask_o` equals the S-box output of the unmasked input data.
- **Unmasked implementations.** If the S-box implementation is unmasked (e.g., `SBoxImplLut`, `SBoxImplCanright`):
  - `mask_i` and `prd_i` are unused (tied off as "unused" signals in the design).
  - `mask_o` is set to `0` (zero mask, data is plaintext).
  - `data_o` directly contains the S-box output.
- **Enable and handshaking.** 
  - `en_i` is a Sparse 2-of-4 encoded Boolean signal (fault-resistant). A valid encoding initiates SubBytes computation.
  - On a valid enable, the module processes the input and after pipelining, asserts `out_req_o` (Sparse 2-of-4 encoded) to signal output validity.
  - `out_ack_i` (also Sparse 2-of-4 encoded) is the downstream acknowledge; the module may stall or handshake depending on the implementation.
- **Error reporting.** If `en_i` is invalid (decoding fails), `err_o` is set; output data and `out_req_o` behavior is undefined or suppressed.
- **Reset behavior.** On `rst_ni == 0`, internal state is reset; outputs are deasserted or cleared.

## Timing / latency

The module is pipelined internally (typically 1–2 cycles depending on the S-box implementation). Output latency is parameterizable via the S-box implementation choice.

## Example

Forward SubBytes with input state byte `0x53`:
- Output byte = `S[0x53]` = `0xED` (from the AES forward S-box).

Inverse SubBytes with input state byte `0x53`:
- Output byte = `S_inv[0x53]` = some value different from forward.

With masking, the output `data_o ⊕ mask_o` should equal the unmasked result.
