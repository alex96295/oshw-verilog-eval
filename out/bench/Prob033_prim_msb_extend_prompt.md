Design a module called TopModule. This module performs sign or zero extension on a fixed-width input to produce a wider output word.

## Overview

TopModule is a purely combinational bit-width extension module that takes a narrow input and expands it to a wider output. The extension strategy depends on the relative widths: if the output width matches the input width, the value is passed through unchanged. If the output is wider, the high-order bits are filled by replicating the most significant bit of the input (sign extension), creating a sign-extended result.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `InWidth` | Width of the input, in bits. | >= 1 (int unsigned). Default: 2. |
| `OutWidth` | Width of the output, in bits. | >= InWidth (int unsigned). Default: 2. |

The module requires `OutWidth >= InWidth`; instantiations that violate this constraint may produce undefined results.

## Interface

All ports are combinational; there is no clock, no reset, and no state.

| Port    | Direction | Width       | Description |
|---------|-----------|-------------|-------------|
| `in_i`  | input     | `InWidth`   | Input value. |
| `out_o` | output    | `OutWidth`  | Extended output. |

## Behavioral requirements

- **Feed-through (equal widths).** If `OutWidth == InWidth`, `out_o` is driven directly from `in_i`. No extension occurs.
- **Sign extension (wider output).** If `OutWidth > InWidth`, the high-order `OutWidth - InWidth` bits of `out_o` are filled with copies of `in_i[InWidth-1]` (the most significant bit of the input). The low-order `InWidth` bits of `out_o` are driven from `in_i[InWidth-1:0]`.
- **Combinational.** The output responds combinationally to changes in the input; there is no latching, registration, or clocked behavior.

## Sign extension details

Sign extension replicates the MSB (most significant bit) of the input to all higher positions in the output. This preserves the sign of a two's-complement number when expanding its width:
- A positive number (MSB = 0) is extended with zeros: all upper bits become 0.
- A negative number (MSB = 1) is extended with ones: all upper bits become 1.

## Example

With `InWidth = 4`, `OutWidth = 8`:

| `in_i`   | `in_i[3]` (MSB) | `out_o` (binary) | `out_o` (hex) | Interpretation |
|----------|-----------------|-----------------|---------------|-----------------|
| 4'b0011  | 0               | 8'b00000011     | 0x03          | 3, extended with zeros |
| 4'b0111  | 0               | 8'b00000111     | 0x07          | 7, extended with zeros |
| 4'b1000  | 1               | 8'b11111000     | 0xF8          | -8 (2's compl), extended with ones |
| 4'b1111  | 1               | 8'b11111111     | 0xFF          | -1 (2's compl), extended with ones |

With `InWidth = 4`, `OutWidth = 4` (equal widths):

| `in_i`   | `out_o`   |
|----------|-----------|
| 4'b0011  | 4'b0011   |
| 4'b1111  | 4'b1111   |

Output is simply pass-through when widths match.
