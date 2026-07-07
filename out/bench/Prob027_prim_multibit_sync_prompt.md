Design a module called TopModule. This module is a multi-bit clock-domain-crossing (CDC) synchronizer that safely transfers a wide data word from one clock domain to another using a staged synchronization pipeline.

## Overview

TopModule synchronizes a multi-bit wide data bus from a source clock domain to a destination clock domain using a configurable chain of pipelined stages. The module employs a first 2-stage flip-flop synchronizer on the input followed by one or more additional comparison stages to verify stability before committing the output. The output only updates when all staged signals are identical, indicating the data has settled through the synchronization delay and metastability has decayed.

## Parameters

| Parameter    | Meaning | Constraint |
|--------------|---------|------------|
| `Width`      | Width of the data bus to synchronize, in bits. | >= 1 (int unsigned). Default: 8. |
| `NumChecks`  | Number of stability check stages after the initial 2-stage sync. | >= 1 (int unsigned). Default: 1. |
| `ResetValue` | Reset value for the output register, in bits. | Width-bit logic. Default: 0. |

The total pipeline depth is 2 (initial sync) plus `NumChecks` stages.

## Interface

| Port      | Direction | Width   | Description |
|-----------|-----------|---------|-------------|
| `clk_i`   | input     | 1       | Destination clock domain. |
| `rst_ni`  | input     | 1       | Active-low asynchronous reset. |
| `data_i`  | input     | `Width` | Input data from source domain. |
| `data_o`  | output    | `Width` | Synchronized output in destination domain. |

## Behavioral requirements

- **2-stage synchronization.** The input (`data_i`) is first synchronized into the destination clock domain via a 2-stage flip-flop chain, reducing metastability risk.
- **Stability verification.** After the initial sync, the output is passed through `NumChecks` additional pipeline stages. At each stage, the module compares the current value to the prior stage; when all `NumChecks` comparisons show equality, the data is considered stable and the output updates.
- **Output update.** The final output (`data_o`) is updated only when all staged signals match, indicating the data has been consistent across the synchronization delay. Until stability is reached, the output holds its prior value.
- **Reset behavior.** On assertion of `rst_ni` (active-low, asynchronous), all internal registers and the output are reset to `ResetValue`.
- **Clock domain.** All clocked registers operate in the destination clock domain (`clk_i`).

## Timing and latency

- Latency from input change to output change: 2 + `NumChecks` clock cycles (minimum, assuming input is already settled in the source domain).
- The module assumes CDC-safe input behavior; if the input is changing rapidly in the source domain, the output may not capture every transition.

## Example

With `Width = 8`, `NumChecks = 1`, and `ResetValue = 0`:

| Cycle | `data_i` | Sync stage 0 | Sync stage 1 | Check stage | `data_o` (prev) | `data_o` (current) |
|-------|----------|--------------|--------------|-------------|-----------------|-------------------|
| 0     | 0x12     | unknown      | 0x00         | 0x00        | 0x00            | 0x00              |
| 1     | 0x12     | 0x?? (meta)  | 0x00         | 0x00        | 0x00            | 0x00              |
| 2     | 0x12     | 0x12         | 0x?? (meta)  | 0x00        | 0x00            | 0x00              |
| 3     | 0x12     | 0x12         | 0x12         | 0x?? (meta) | 0x00            | 0x00              |
| 4     | 0x12     | 0x12         | 0x12         | 0x12        | 0x00            | 0x12 (stable)     |

At cycle 4, all stages hold 0x12, stability is reached, and the output updates to 0x12.
