Design a module called TopModule. This module decodes a differential pair of signals (diff_p, diff_n) into logic-level outputs, detecting valid differential transitions and signaling single-event-upset (SEU) errors when differential integrity is violated.

## Overview

TopModule is a combinational and synchronous differential decoder that converts a differential pair (positive and negative lines) into single-ended logic outputs along with edge and error detection. The module monitors for rising and falling transitions on the differential lines and flags a signal integrity error (`sigint_o`) when both lines do not maintain the required anti-phase relationship (i.e., when they have the same value). An optional asynchronous CDC stage can protect the input from metastability before decoding.

## Parameters

| Parameter   | Meaning | Constraint |
|-------------|---------|------------|
| `AsyncOn`   | Enable async CDC stage; if 1, differential inputs are synchronized via 2-stage flops. | 0 or 1 (bit). Default: 0. |
| `SkewCycles` | Number of cycles allowed for skew between edges (async mode only). | >= 1 (int unsigned). Default: 1. |

When `AsyncOn = 0`, no CDC sync is applied and decoding is direct. When `AsyncOn = 1`, the differential pair is synchronized and skew between the edges of diff_p and diff_n is monitored over `SkewCycles` cycles.

## Interface

| Port        | Direction | Width | Description |
|-------------|-----------|-------|-------------|
| `clk_i`     | input     | 1     | System clock (active on rising edge). |
| `rst_ni`    | input     | 1     | Active-low synchronous reset. |
| `diff_pi`   | input     | 1     | Positive differential line. |
| `diff_ni`   | input     | 1     | Negative differential line. |
| `level_o`   | output    | 1     | Decoded logic level (registered). Reflects the synchronized diff_p value. |
| `rise_o`    | output    | 1     | Rising edge detected on the differential pair. |
| `fall_o`    | output    | 1     | Falling edge detected on the differential pair. |
| `event_o`   | output    | 1     | Edge event (rise OR fall). |
| `sigint_o`  | output    | 1     | Signal integrity error. Asserted when diff_p and diff_n are not in valid anti-phase. |

## Behavioral requirements

### Synchronization (AsyncOn = 1 only)

- Each differential line is synchronized independently through a 2-stage flip-flop chain, with diff_p resetting to 0 and diff_n resetting to 1 (ensuring valid anti-phase at reset).
- A skew counter monitors the time between edges on the two lines; if the skew exceeds `SkewCycles`, a signal integrity error is flagged.

### Synchronization (AsyncOn = 0)

- No CDC stage is applied; the raw differential inputs are used directly for decoding.

### Level decoding

- The logical level is determined by the synchronized (or raw) diff_p line. `level_o` is a registered output of this value.

### Edge detection

- `rise_o` and `fall_o` are asserted when transitions are detected on the decoded level:
  - `rise_o` is asserted when `level_o` transitions from 0 to 1.
  - `fall_o` is asserted when `level_o` transitions from 1 to 0.
- These are typically single-cycle pulses.

### Signal integrity monitoring

- The decoder verifies that diff_p and diff_n are always antiphase (one high, one low). When both lines are equal (both 0 or both 1), this indicates a differential fault (single-event upset, noise, or short circuit).
- `sigint_o` is asserted when this violation is detected.

### Reset behavior

- On assertion of `rst_ni` (active-low), the module is initialized such that diff_p is 0 and diff_n is 1, ensuring valid antiphase.
- All edge detection flags and error flags are reset to 0.

## Example (AsyncOn = 1, SkewCycles = 1)

| Cycle | `diff_pi` | `diff_ni` | Sync0_p | Sync1_p | Sync0_n | Sync1_n | `level_o` | `rise_o` | `fall_o` | `sigint_o` |
|-------|-----------|-----------|---------|---------|---------|---------|-----------|----------|----------|------------|
| 0     | 0         | 1         | ?       | 0       | ?       | 1       | 0         | 0        | 0        | 0          |
| 1     | 1         | 0         | 0       | 0       | 1       | 1       | 0         | 0        | 0        | 0          |
| 2     | 1         | 0         | 1 (meta)| 0       | 0 (meta)| 1       | 0         | 0        | 0        | 0          |
| 3     | 1         | 0         | 1       | 1       | 0       | 0       | 1         | 1        | 0        | 0          |
| 4     | 1         | 0         | 1       | 1       | 0       | 0       | 1         | 0        | 0        | 0          |
| 5     | 0         | 1         | 1       | 1       | 0       | 0       | 1         | 0        | 0        | 0          |
| 6     | 0         | 1         | 0 (meta)| 1       | 1 (meta)| 0       | 1         | 0        | 0        | 0          |
| 7     | 0         | 1         | 0       | 0       | 1       | 1       | 0         | 0        | 1        | 0          |

At cycle 3, both synchronized lines reach antiphase (diff_p=1, diff_n=0), level_o updates to 1, and rise_o pulses. At cycle 7, the transition reverses and fall_o pulses. Signal integrity is maintained throughout.
