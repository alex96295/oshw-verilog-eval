Design a module called TopModule. This module is a counter-based glitch filter for a single-bit input signal that eliminates transients by requiring the input to differ from its previous sample for at least a configurable threshold number of consecutive cycles.

## Overview

TopModule is a combinational and synchronous filter that removes noise from a single-bit input by tracking when the input has changed and remained different from the prior sample for at least `thresh_i` consecutive cycles. Instead of using a shift register, it maintains a difference counter that increments when the current synchronized input differs from the previous sample and saturates at the threshold value. When the counter reaches the threshold, the stored output value is updated. An optional asynchronous CDC stage can precede the filter to safely bring the input from an asynchronous source.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `AsyncOn` | Enable async CDC stage; if 1, input is synchronized via 2-stage flop. | 0 or 1 (bit). Default: 0. |
| `CntWidth` | Width of the difference counter, in bits. | >= 1 (int unsigned). Default: 2. |

`CntWidth` must be large enough to represent the maximum threshold value that will be passed via `thresh_i`.

## Interface

| Port        | Direction | Width        | Description |
|-------------|-----------|--------------|-------------|
| `clk_i`     | input     | 1            | System clock (active on rising edge). |
| `rst_ni`    | input     | 1            | Active-low synchronous reset. |
| `enable_i`  | input     | 1            | Filter enable. When 0, output is pass-through; when 1, output is registered. |
| `filter_i`  | input     | 1            | Raw input signal to be filtered. |
| `thresh_i`  | input     | `CntWidth`   | Threshold; counter must reach this value to update output. |
| `filter_o`  | output    | 1            | Filtered output. Updated when counter reaches threshold. |

## Behavioral requirements

- **Difference tracking.** The module tracks when the input signal differs from its immediately previous sample. Each cycle, compare the current synchronized input to the prior synchronized input value.
- **Counter logic.** If the synchronized input differs from the prior value, reset a counter to 0. Otherwise, if the counter is below `thresh_i`, increment it by 1. If the counter reaches or exceeds `thresh_i`, hold it at `thresh_i`.
- **Output update.** When the counter reaches `thresh_i`, the output register is updated with the current synchronized input value.
- **Output control.** When `enable_i = 0`, drive the output combinationally from the synchronized input (pass-through). When `enable_i = 1`, drive the output from the registered (settled) value.
- **Reset behavior.** On assertion of `rst_ni` (active-low), all internal registers are reset to 0.
- **Clock and reset domains.** All registers are clocked by `clk_i` and reset by `rst_ni` (active-low).

## Example

With `CntWidth = 2`, `thresh_i = 3'b11` (threshold = 3), and `enable_i = 1`:

| Cycle | `filter_i` | Synced input | Diff from prev? | Counter | Counter >= 3? | `filter_o` |
|-------|------------|--------------|-----------------|---------|---------------|-----------|
| 0     | 0          | 0            | —               | 0       | No            | 0         |
| 1     | 0          | 0            | No              | 1       | No            | 0         |
| 2     | 0          | 0            | No              | 2       | No            | 0         |
| 3     | 1          | 1            | Yes             | 0       | No            | 0         |
| 4     | 1          | 1            | No              | 1       | No            | 0         |
| 5     | 1          | 1            | No              | 2       | No            | 0         |
| 6     | 1          | 1            | No              | 3       | Yes           | 1         |

At cycle 6, the counter reaches the threshold (3), and `filter_o` is updated to 1.
