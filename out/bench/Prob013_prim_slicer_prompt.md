Design a module called TopModule. This module is a combinational bit-slice selector: it
treats a wide input word as an array of fixed-width elements and drives the output with the
single element selected by an index.

## Overview

TopModule extracts one `OutW`-bit slice from a wider `InW`-bit input vector. Conceptually the
input is viewed as a packed array of equal-width elements, each `OutW` bits wide, laid out
from the least-significant bit upward. The `sel_i` index chooses which element appears on the
output. The module is purely combinational — there is no clock, no reset, and no state.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `InW`     | Width of the input vector, in bits. | `InW <= OutW * (2**IndexW)` must hold. |
| `OutW`    | Width of one output slice, in bits. | ≥ 1. |
| `IndexW`  | Width of the selection index, in bits. | Chosen so `2**IndexW` slices cover `InW`. |

The relationship `InW <= OutW * 2**IndexW` must be satisfied by the instantiation: the index
space must be large enough to address every bit of the input when partitioned into `OutW`-bit
elements. An implementation may assume this holds and need not produce a defined result for
parameterizations that violate it.

## Interface

All ports are combinational; there is no clock or reset.

| Port     | Direction | Width        | Description |
|----------|-----------|--------------|-------------|
| `sel_i`  | input     | `IndexW`     | Zero-based index of the slice to select. |
| `data_i` | input     | `InW`        | Input vector, interpreted as `2**IndexW` packed `OutW`-bit slices. |
| `data_o` | output    | `OutW`       | The selected slice. |

## Behavioral requirements

- **Slice selection.** Partition `data_i` into consecutive `OutW`-bit elements, element 0
  occupying the least-significant `OutW` bits, element 1 the next `OutW` bits, and so on.
  `data_o` must equal element number `sel_i`.
- **Out-of-range / padding.** The selectable index space (`2**IndexW` slices of `OutW` bits)
  may extend beyond `InW`. When the selected slice addresses bit positions at or above `InW`,
  those positions are treated as zero — i.e. the input is conceptually zero-extended up to
  `OutW * 2**IndexW` bits before slicing. A selection that lies entirely beyond the input
  therefore yields all zeros; a selection that straddles the boundary yields the valid input
  bits in the low positions and zeros in the high positions.
- **Purely combinational.** `data_o` must be a combinational function of `sel_i` and `data_i`
  only; it must respond immediately to input changes with no clocked or latched behavior.

## Example

With `InW = 16`, `OutW = 4`, `IndexW = 2` and `data_i = 16'hBEEF`:

| `sel_i` | `data_o` |
|---------|----------|
| 0       | `4'hF`   |
| 1       | `4'hE`   |
| 2       | `4'hE`   |
| 3       | `4'hB`   |

With `InW = 6`, `OutW = 4`, `IndexW = 2` and `data_i = 6'b10_1101` (the input covers only the
low 6 of the 16 addressable bits): `sel_i = 0` yields `4'b1101`; `sel_i = 1` yields
`4'b0010` (two valid input bits `10` in the low positions, zeros above); `sel_i = 2` and
`sel_i = 3` yield `4'b0000`.
