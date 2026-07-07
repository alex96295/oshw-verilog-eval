Design a module called TopModule. This module implements a one-hot write-enable checker that validates that exactly one bit is asserted in a write-enable vector and reports any violations.

## Overview

TopModule is a fault-detection primitive that monitors a write-enable signal and flags errors when the signal is not one-hot (i.e., when zero or multiple bits are asserted simultaneously). It is commonly used in register file write-port arbitration and control logic to ensure that only one destination is selected at a time, detecting transient faults that might corrupt the control path.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `OneHotWidth` | Number of bits in the one-hot vector. | ≥ 1; typically 1–32. |

## Interface

TopModule operates in a single clock domain with an active-low asynchronous reset.

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk_i` | input | 1 | System clock. |
| `rst_ni` | input | 1 | Active-low asynchronous reset. |
| `oh_i` | input | `OneHotWidth` | Input write-enable (or select) vector to be checked. |
| `en_i` | input | 1 | Enable signal: when asserted, perform the one-hot check on the next rising clock edge. When low, error checking is disabled. |
| `err_o` | output | 1 | Error flag: asserted if `oh_i` is not one-hot (i.e., zero bits or multiple bits are set) when `en_i` is high. |

## Behavioral requirements

- **One-hot validation.** When `en_i` is asserted, `oh_i` is checked to ensure exactly one bit is set to 1 and all others are 0. A valid one-hot value has a population count of exactly 1.

- **Error detection.** If `oh_i` does not satisfy the one-hot property when checked (either zero bits or >1 bits are asserted), `err_o` is asserted, indicating a fault.

- **Enable gating.** The check is only performed when `en_i` is high. When `en_i` is low, the module does not evaluate `oh_i`, and `err_o` remains deasserted (or reflects the previous error state, depending on implementation; typically deasserted on disabled check).

- **Latching or strobing.** `err_o` may either:
  - Strobe high for one cycle if an error is detected, or
  - Latch high and persist until reset if an error occurs.
  - (Common practice is latching for fault visibility.)

- **Reset behavior.** On reset (`rst_ni` low), the error flag `err_o` is deasserted.

- **Combinational or registered.** The check logic itself is typically combinational (population count or simple AND/OR gates); however, if `err_o` is latched, the error result is registered. The module buffers `oh_i` internally to harden against transient glitches before evaluation.

## Clock and Reset Domains

- Single synchronous clock domain (`clk_i`).
- Asynchronous active-low reset (`rst_ni`).

## Example: OneHotWidth = 4

| Cycle | `oh_i` | `en_i` | `err_o` | Note |
|-------|--------|--------|--------|------|
| 0 | `4'b0001` | 1 | 0 | Valid one-hot |
| 1 | `4'b0010` | 1 | 0 | Valid one-hot |
| 2 | `4'b0000` | 1 | 1 | Zero bits: error |
| 3 | `4'b0011` | 1 | 1 | Two bits: error |
| 4 | `4'b0100` | 1 | 1 | Valid one-hot, but error latches if sticky |
| 5 | `4'b1000` | 0 | 1 | Check disabled; error may remain latched |
| Reset | — | — | — | 0 | Error cleared by reset |

The module continuously buffers the input `oh_i` and checks it when `en_i` is sampled high. If an error is detected, `err_o` is asserted and typically remains asserted until reset.
