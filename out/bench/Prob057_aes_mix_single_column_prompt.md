Design a module called TopModule. This module is a combinational AES MixColumns operation for a single 4-byte column with direction control for encryption or decryption.

## Overview

TopModule implements the AES MixColumns step for a single 4-byte column of the state. It applies a GF(2^8) linear transformation to the 4 input bytes, composing a circulant matrix multiplication. The transformation differs for forward (encryption) and inverse (decryption) operations. The module is purely combinational and processes only one column at a time (the full 128-bit MixColumns would call this operation 4 times in parallel or sequentially).

## Parameters

None.

## Interface

All ports are combinational; there is no clock or reset.

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `op_i` | input | 2 | Cipher operation: `CIPH_FWD = 2'b01` (encryption/forward AES), `CIPH_INV = 2'b10` (decryption/inverse AES). Other values are undefined. |
| `data_i` | input | 32 | Input 4-byte column, organized as a 4-element array: `[3:0][7:0]` (byte index, bits within byte). `data_i[0]` is the most significant (first) byte, `data_i[3]` is the least significant (last). |
| `data_o` | output | 32 | Output 4-byte column after MixColumns transformation, in the same format. |

## Behavioral requirements

- **Column format.** The 32-bit input/output is hierarchically indexed: `data_i[row][bit]` where row ∈ {0,1,2,3}, bit ∈ {0..7}. `data_i[0]` is `data_i[31:24]`, `data_i[1]` is `data_i[23:16]`, etc.
- **MixColumns transformation.** The input column `[a, b, c, d]` is transformed as a 4-element vector via a 4x4 circulant matrix in GF(2^8):
  - **Forward (encryption):** Output is `[2a⊕3b⊕c⊕d, a⊕2b⊕3c⊕d, a⊕b⊕2c⊕3d, 3a⊕b⊕c⊕2d]` where ⊕ is XOR and multiplication is in GF(2^8) with irreducible polynomial x^8 + x^4 + x^3 + x + 1.
  - **Inverse (decryption):** Output is `[0xE·a⊕0xB·b⊕0xD·c⊕0x9·d, 0x9·a⊕0xE·b⊕0xB·c⊕0xD·d, 0xD·a⊕0x9·b⊕0xE·c⊕0xB·d, 0xB·a⊕0xD·b⊕0x9·c⊕0xE·d]` where coefficients are the inverse-matrix entries.
- **Purely combinational.** `data_o` is a combinational function of `op_i` and `data_i`; no latency beyond combinational propagation.
- **Undefined behavior.** If `op_i` is neither `CIPH_FWD` nor `CIPH_INV`, the output is undefined.

## Boundary conditions

- **Forward MixColumns identity.** With input `[x, 0, 0, 0]`, the forward output is `[2x, x, x, 3x]` (over GF(2^8)).
- **All-zero column.** Input `[0, 0, 0, 0]` always produces output `[0, 0, 0, 0]` (linear transform property).
- **Inverse cancellation.** Applying forward then inverse MixColumns to the same column recovers the original (within GF(2^8) arithmetic).

## Example

Forward MixColumns on column `[0x53, 0xD6, 0xAB, 0xAC]`:
- Output ≈ `[0xF5, 0x2B, 0x6F, 0x2C]` (exact value depends on GF(2^8) multiplications).
