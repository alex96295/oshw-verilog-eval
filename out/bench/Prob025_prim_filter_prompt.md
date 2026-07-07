Design a module called TopModule. This module is a glitch filter for a single-bit input signal, eliminating short transients by settling-time detection.

## Overview

TopModule is a combinational and synchronous filter that removes noise and glitches from a single-bit input by tracking when the input signal has settled to a stable value for a minimum number of clock cycles. The module captures when all bits in a shift register have become uniform (all 0s or all 1s), indicating the input has remained at a single value long enough to be considered stable, and updates the output when this settle condition is met. An optional asynchronous CDC (clock-domain crossing) stage can precede the filter to safely bring the input from an asynchronous source.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `AsyncOn` | Enable async CDC stage; if 1, input is synchronized via 2-stage flop. | 0 or 1 (bit). Default: 0. |
| `Cycles` | Number of consecutive identical samples required to declare settle. | >= 1 (int unsigned). Default: 4. |

When `AsyncOn = 0`, the filter runs synchronously in a single clock domain. When `AsyncOn = 1`, the input is first synchronized via a 2-stage flip-flop pipeline to safely cross domains.

## Interface

| Port        | Direction | Width | Description |
|-------------|-----------|-------|-------------|
| `clk_i`     | input     | 1     | System clock (active on rising edge). |
| `rst_ni`    | input     | 1     | Active-low synchronous reset. |
| `enable_i`  | input     | 1     | Filter enable. When 0, output is pass-through; when 1, output is registered. |
| `filter_i`  | input     | 1     | Raw input signal to be filtered. |
| `filter_o`  | output    | 1     | Filtered output. Updated only when input has settled. |

## Behavioral requirements

- **Settle detection.** Internally maintain a shift register of width `Cycles`. On each clock cycle, shift in the synchronized (or raw) input value. When all `Cycles` bits of this register equal 0 or all equal 1 (i.e., the register pattern is uniform), the input is considered settled.
- **Output update.** When settle is detected, capture the synchronized input value into a register. The output (`filter_o`) then drives this stored value.
- **Enable control.** When `enable_i = 0`, the output is combinationally driven by the synchronized input (pass-through, no filtering). When `enable_i = 1`, the output is driven by the registered settled value.
- **Reset behavior.** On assertion of `rst_ni` (active-low), all internal registers are reset to 0.
- **Clock and reset domains.** All registers are clocked by `clk_i` and reset by `rst_ni` (active-low). If `AsyncOn = 1`, the internal 2-stage sync is also clocked by `clk_i` with the same reset.

## Example

With `Cycles = 4` and `enable_i = 1`, when `filter_i` stabilizes at a single value for 4 consecutive cycles:

| Cycle | `filter_i` | Internal shift register | Settle detected? | `filter_o` |
|-------|------------|------------------------|------------------|-----------|
| 0     | 0          | 0000                   | Yes (all 0s)     | 0         |
| 1     | 0          | 0000                   | Yes              | 0         |
| 2     | 1          | 0001                   | No               | 0         |
| 3     | 1          | 0011                   | No               | 0         |
| 4     | 1          | 0111                   | No               | 0         |
| 5     | 1          | 1111                   | Yes (all 1s)     | 1         |
| 6     | 1          | 1111                   | Yes              | 1         |

At cycle 5, the register becomes all 1s, settle is asserted, and `filter_o` is updated to 1 on the next cycle.
