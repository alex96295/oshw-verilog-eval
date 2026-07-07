Design a module called TopModule. This module is a combinational one-hot encoder: it converts a binary index into a one-hot encoded output vector.

## Overview

TopModule is a purely combinational encoder that converts a binary input index into a one-hot output representation. For each possible index value, exactly one bit of the output is asserted while all others are zero—unless the enable input is low, in which case the entire output is zero.

## Parameters

| Parameter | Meaning | Default |
|-----------|---------|---------|
| `OneHotWidth` | Width of the one-hot output vector; the number of distinct index values that can be encoded. | 32 |
| `InputWidth` | Width of the binary index input. Derived as `$clog2(OneHotWidth)`. | Derived |

The relationship between `OneHotWidth` and `InputWidth` is fixed: `InputWidth = $clog2(OneHotWidth)`. For example, if `OneHotWidth = 32`, then `InputWidth = 5`.

## Interface

All ports are combinational; there is no clock or reset.

| Port       | Direction | Width         | Description |
|------------|-----------|---------------|-------------|
| `in_i`     | input     | `InputWidth`  | Binary index (0 to OneHotWidth-1). |
| `en_i`     | input     | 1             | Enable signal. When high, the indexed output bit is asserted. When low, all output bits are zero. |
| `out_o`    | output    | `OneHotWidth` | One-hot encoded output. Bit `i` is high if and only if `in_i == i && en_i == 1`. |

## Behavioral Requirements

- **Encoding:** `out_o[i]` is high if and only if `in_i == i` AND `en_i` is high.
- **Disabled output:** When `en_i` is low, all bits of `out_o` are zero, regardless of `in_i`.
- **Combinational:** The output is a purely combinational function of the inputs; there is no state or latching.
- **Out-of-range behavior:** `in_i` is expected to be in the range [0, OneHotWidth-1]. Behavior for out-of-range values is undefined (the module makes no guarantees).

## Example

With `OneHotWidth = 4` and `InputWidth = 2`:

| `in_i` | `en_i` | `out_o` |
|--------|--------|---------|
| 0      | 1      | 0001    |
| 1      | 1      | 0010    |
| 2      | 1      | 0100    |
| 3      | 1      | 1000    |
| 0      | 0      | 0000    |
| 2      | 0      | 0000    |
| 3      | 1      | 1000    |
