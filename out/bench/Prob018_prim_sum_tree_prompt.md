Design a module called TopModule. This module is a parallel summation tree: it computes the sum of multiple inputs, each with an associated validity flag, producing a combined sum and valid output.

## Overview

TopModule performs a tree-based reduction to sum multiple input values in parallel. Each input has a validity flag indicating whether that input contributes to the sum. The output is the sum of all valid inputs, along with a flag indicating whether any input was valid. Summation may be optionally saturated to prevent overflow.

## Parameters

| Parameter | Meaning | Default |
|-----------|---------|---------|
| `NumSrc`  | Number of input values to sum. | 32 |
| `InWidth` | Width of each input value, in bits. | 8 |
| `Saturate` | When 1, the output is saturated (clamped) on overflow to the maximum value. When 0, overflow wraps. | 1 |
| `OutWidth` | Width of the output sum, in bits. Derived as `Saturate ? InWidth : InWidth + NumLevels`, where `NumLevels = $clog2(NumSrc)`. | Derived |

When `Saturate = 1`, all outputs fit within `InWidth` bits. When `Saturate = 0`, the output width expands to accommodate the worst-case sum without saturation.

## Interface

| Port          | Direction | Width           | Description |
|---------------|-----------|-----------------|-------------|
| `clk_i`       | input     | 1               | Clock (unused; present for interface compatibility). |
| `rst_ni`      | input     | 1               | Reset (unused; present for interface compatibility). |
| `values_i`    | input     | `NumSrc × InWidth` | Array of `NumSrc` input values, each `InWidth` bits wide. |
| `valid_i`     | input     | `NumSrc`        | Validity flags for each input. `valid_i[i]` is high if `values_i[i]` should be included in the sum. |
| `sum_value_o` | output    | `OutWidth`      | Sum of all valid inputs. If no inputs are valid, the sum is zero. |
| `sum_valid_o` | output    | 1               | Valid flag: high if at least one input had `valid_i[i] = 1`. |

## Behavioral Requirements

**Summation Logic:**
- `sum_valid_o` is high if and only if at least one bit of `valid_i` is asserted.
- `sum_value_o` is the arithmetic sum of all inputs where `valid_i[i] = 1`.
- If no inputs are valid (`valid_i` is all zeros), then `sum_value_o` is zero.

**Saturation (if enabled):**
- When `Saturate = 1`, the sum is clamped to the maximum value representable in `InWidth` bits (2^InWidth - 1) if overflow occurs.
- When `Saturate = 0`, overflow wraps (modular arithmetic).

**Tree Structure:**
- The summation is performed using a binary tree to reduce latency. The module is combinational; no clock or reset affects the computation.
- Clock and reset ports are present but unused (for interface uniformity).

**Valid Propagation:**
- A valid output is produced whenever at least one input is marked valid.

## Example: NumSrc=4, InWidth=8, Saturate=1

| `values_i` | `valid_i` | `sum_value_o` | `sum_valid_o` | Comment |
|------------|-----------|---------------|---------------|---------| 
| [10, 20, 30, 40] | 1111 | 100 | 1 | All valid; sum = 10+20+30+40 = 100. |
| [10, 20, 30, 40] | 1100 | 70 | 1 | Only indices 2,3 valid; sum = 30+40 = 70. |
| [200, 100, 0, 0] | 1100 | 255 | 1 | Saturated: 200+100=300, clamped to 255. |
| [10, 20, 30, 40] | 1000 | 40 | 1 | Only index 3 valid; sum = 40. |
| [10, 20, 30, 40] | 0000 | 0 | 0 | No inputs valid; sum = 0, valid = 0. |
| [255, 255, 0, 0] | 1100 | 255 | 1 | Saturated: 255+255=510, clamped to 255. |

## Latency and Throughput

- The summation is **combinational** (tree-based reduction).
- Output updates immediately when inputs change.
- There is no pipeline latency.
- Throughput is one result per clock cycle (all inputs and outputs are combinational).
