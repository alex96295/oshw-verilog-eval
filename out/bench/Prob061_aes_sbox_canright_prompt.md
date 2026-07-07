Design a module called TopModule. This module implements the AES S-box (byte substitution) function using Canright's compact GF-tower construction. The module supports both forward encryption and inverse decryption operations on 8-bit values, with direction controlled by an operation input.

## Overview

TopModule performs the AES SubBytes transformation (forward or inverse). It computes the result of either the AES forward S-box or inverse S-box, applied to a single 8-bit input byte. The operation to perform is selected by a control signal. The computation uses Canright's isomorphic GF-tower technique to minimize area: the byte is transformed into an isomorphic representation in composite GF(2^4)^2, inverted there, and transformed back, with affine transformations applied at the boundaries.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| (none)    | This is a purely combinational module with no parameters. | N/A |

## Interface

All ports are combinational; there is no clock or reset.

| Port       | Direction | Width | Description |
|------------|-----------|-------|-------------|
| `op_i`     | input     | 2 bits (enum) | Operation selector: `CIPH_FWD` (2'b01) selects forward AES S-box; `CIPH_INV` (2'b10) selects inverse S-box. Default is treated as forward. |
| `data_i`   | input     | 8     | Plaintext/ciphertext byte to be substituted. |
| `data_o`   | output    | 8     | Substituted byte: the result of applying the selected S-box to `data_i`. |

## Behavioral requirements

- **Forward S-box (CIPH_FWD).** The output must be the standard AES forward S-box applied to the input byte, equivalent to the composition: affine transform (XOR with 0x63) → multiplicative inverse in GF(2^8) → affine transform (XOR with 0x63). The result is the byte-substitution used in the AES encryption SubBytes step.

- **Inverse S-box (CIPH_INV).** The output must be the standard AES inverse S-box applied to the input byte, the compositional inverse of the forward S-box. This is used in the AES decryption InvSubBytes step.

- **Canright isomorphic tower.** The implementation must use the composite field GF(2^4)^2 representation and perform the inversion there. This is an implementation detail visible only through correctness; the module must obey the behavioral contract of AES SubBytes, not encode internal tower structure.

- **Combinational.** The output is a purely combinational function of `op_i` and `data_i`; there is no latching, pipelining, or state.

- **Undefined operation.** If `op_i` is neither `CIPH_FWD` nor `CIPH_INV`, the output is undefined; the module need not produce a defined result.

## Example

Forward S-box (CIPH_FWD):

| `data_i` | `data_o` |
|----------|----------|
| 0x00     | 0x63     |
| 0x01     | 0x7c     |
| 0x02     | 0x77     |
| 0xfe     | 0x6b     |
| 0xff     | 0x16     |

Inverse S-box (CIPH_INV):

| `data_i` | `data_o` |
|----------|----------|
| 0x63     | 0x00     |
| 0x7c     | 0x01     |
| 0x77     | 0x02     |
| 0x6b     | 0xfe     |
| 0x16     | 0xff     |
