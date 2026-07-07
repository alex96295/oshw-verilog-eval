Design a module called TopModule. This module is a combinational AES ShiftRows operation that permutes a 4x4 state matrix of bytes with direction control for encryption or decryption.

## Overview

TopModule implements the AES ShiftRows step of the AES cipher. It treats the 128-bit state as a 4x4 array of bytes (indexed by row and column, with state row 0 being bits [127:120], row 1 being bits [95:88], etc., laid out column-major in the hardware interface). Each row is cyclically shifted by a fixed amount: row 0 is not shifted, row 1 is shifted left by 1 byte, row 2 by 2 bytes, and row 3 by 1 or 3 bytes depending on the cipher direction (forward vs. inverse). The module is purely combinational.

## Parameters

None.

## Interface

All ports are combinational; there is no clock or reset.

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `op_i` | input | 2 | Cipher operation: `CIPH_FWD = 2'b01` (encryption/forward AES), `CIPH_INV = 2'b10` (decryption/inverse AES). Other values are undefined. |
| `data_i` | input | 128 | Input 128-bit state, organized as 4 rows x 4 columns of bytes: `[3:0][3:0][7:0]` (row [major], column, byte). |
| `data_o` | output | 128 | Output 128-bit state after ShiftRows permutation, in the same format. |

## Behavioral requirements

- **State format.** The 128-bit input/output is hierarchically indexed: `data_i[row][col][bit]` where row ∈ {0,1,2,3}, col ∈ {0,1,2,3}, bit ∈ {0..7}. Row 0 occupies the most significant bytes, row 3 the least significant.
- **ShiftRows transformation.** The module permutes the state as follows:
  - **Row 0:** No shift; `data_o[0][j] = data_i[0][j]` for all j ∈ {0,1,2,3}.
  - **Row 1:** Left-rotate by 1 byte; `data_o[1][j] = data_i[1][(j+1) mod 4]`.
  - **Row 2:** Left-rotate by 2 bytes; `data_o[2][j] = data_i[2][(j+2) mod 4]`.
  - **Row 3:** Direction-dependent:
    - Forward (`CIPH_FWD`): Left-rotate by 1 byte; `data_o[3][j] = data_i[3][(j+1) mod 4]`.
    - Inverse (`CIPH_INV`): Right-rotate by 1 byte (equiv. left-rotate by 3); `data_o[3][j] = data_i[3][(j+3) mod 4]`.
- **Purely combinational.** `data_o` is a combinational function of `op_i` and `data_i`; no latency beyond combinational propagation.
- **Undefined behavior.** If `op_i` is neither `CIPH_FWD` nor `CIPH_INV`, the output is undefined (typically a default or error value).

## Example

Forward ShiftRows with `data_i[1] = [A, B, C, D]` (one row):
- `data_o[1] = [B, C, D, A]` (left-rotate by 1).

Inverse ShiftRows with `data_i[3] = [W, X, Y, Z]` (row 3):
- `data_o[3] = [X, Y, Z, W]` (right-rotate by 1, or left-rotate by 3).
