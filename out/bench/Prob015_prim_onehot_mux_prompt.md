Design a module called TopModule. This module is a one-hot multiplexer: it selects one of multiple input vectors using a one-hot select signal.

## Overview

TopModule is a purely combinational multiplexer that uses a one-hot select vector to choose one of several input data words. Each bit position of the select signal corresponds to one of the input candidates; when that bit is high, the corresponding input is passed to the output. The select signal must be one-hot (exactly zero or one bit asserted) for correct operation.

## Parameters

| Parameter | Meaning | Default |
|-----------|---------|---------|
| `Width`   | Width of each input and output data word, in bits. | 32 |
| `Inputs`  | Number of input candidates to multiplex. | 8 |

## Interface

| Port        | Direction | Width        | Description |
|------------|-----------|--------------|-------------|
| `clk_i`    | input     | 1            | Clock (unused; present for interface compatibility). |
| `rst_ni`   | input     | 1            | Reset (unused; present for interface compatibility). |
| `in_i`     | input     | `Inputs × Width` | Array of `Inputs` data words, each `Width` bits wide. Word `i` occupies bits `in_i[i]`. |
| `sel_i`    | input     | `Inputs`     | One-hot select signal. Exactly zero or one bit should be high. Bit `i` selects `in_i[i]`. |
| `out_o`    | output    | `Width`      | Selected input word; pure combinational function of `in_i` and `sel_i`. |

## Behavioral Requirements

- **One-hot selection:** When `sel_i[i]` is high, `out_o` equals `in_i[i]`.
- **Multiple selects disabled:** If more than one bit of `sel_i` is asserted (not one-hot), the output is the bitwise OR of all selected inputs. This is a violation of the one-hot contract and correct behavior is not guaranteed.
- **No select:** If no bit of `sel_i` is asserted (all zeros), the output is all zeros.
- **Combinational:** Output updates immediately with input changes; no state or clock dependence (clock and reset are present but unused).
- **Assertion:** The module asserts (at elaboration time or runtime) that `sel_i` is one-hot; incorrect select encoding may trigger an error.

## Example

With `Width = 8` and `Inputs = 4`:

| `in_i[0]` | `in_i[1]` | `in_i[2]` | `in_i[3]` | `sel_i` | `out_o` |
|-----------|-----------|-----------|-----------|---------|---------|
| 0x12      | 0x34      | 0x56      | 0x78      | 0001    | 0x12    |
| 0x12      | 0x34      | 0x56      | 0x78      | 0010    | 0x34    |
| 0x12      | 0x34      | 0x56      | 0x78      | 0100    | 0x56    |
| 0x12      | 0x34      | 0x56      | 0x78      | 1000    | 0x78    |
| 0x12      | 0x34      | 0x56      | 0x78      | 0000    | 0x00    |
