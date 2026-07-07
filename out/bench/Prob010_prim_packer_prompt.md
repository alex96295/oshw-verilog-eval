Design a module called TopModule. This module is a variable-width-to-fixed-width data packer that accepts input data of width InW and produces aligned output words of width OutW.

## Overview

TopModule buffers variable-width input data and packs it into aligned fixed-width output words. Data arrives with optional masking (per-byte enable), accumulates in an internal buffer, and is emitted in OutW-bit chunks. The module uses an input/output ready/valid handshake and supports flush operations to drain remaining data even if the output buffer is not full.

## Parameters

| Parameter | Meaning | Default |
|-----------|---------|---------|
| `InW` | Input data width, in bits. | 32 |
| `OutW` | Output data width, in bits. | 32 |
| `HintByteData` | Hint: number of bytes (for internal optimization). | 0 |
| `EnProtection` | When 1, enable duplicate/redundancy checks on the accumulator. | 0 |

## Interface

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk_i` | input | 1 | System clock. |
| `rst_ni` | input | 1 | Asynchronous active-low reset. |
| `valid_i` | input | 1 | Input valid: asserted when data_i (and mask_i) are valid. |
| `data_i` | input | InW | Input data to pack. |
| `mask_i` | input | InW | Per-bit mask: bit j is high if data_i[j] is valid; zero bits are ignored. |
| `ready_o` | output | 1 | Input ready: asserted when the packer can accept new input data. |
| `valid_o` | output | 1 | Output valid: asserted when data_o (and mask_o) are valid and should be transferred. |
| `data_o` | output | OutW | Output data (a complete aligned word of width OutW). |
| `mask_o` | output | OutW | Output mask: per-bit valid flags for output data. |
| `ready_i` | input | 1 | Output ready: asserted when the downstream sink is ready to accept data_o. |
| `flush_i` | input | 1 | Flush: when high, drain any buffered partial data on the next cycle. |
| `flush_done_o` | output | 1 | Flush done: asserted when flush completes and buffer is empty. |
| `err_o` | output | 1 | Error flag (when EnProtection=1): asserted if redundancy check fails. |

## Behavioral requirements

### Packing Logic
- The module maintains an internal accumulator buffer of width `InW + OutW` bits, enough to hold one full output word plus partial input.
- As input data arrives (when both `valid_i` and `ready_o` are high), the masked bits are shifted into the accumulator.
- When the accumulator has at least `OutW` bits of valid data, an output word is formed and `valid_o` is asserted.
- The output is transferred when both `valid_o` and `ready_i` are high.

### Accumulation and Position Tracking
- An internal position counter tracks how many valid bits are in the accumulator (0 to InW + OutW).
- On each input cycle, the position advances by the number of set bits in `mask_i`.
- On each output cycle (when `ready_i` is high), the position decrements by `OutW`.

### Output Formation
- When at least `OutW` valid bits are accumulated, the next `OutW` bits are selected from the accumulator and driven onto `data_o` (right-aligned or least-significant-first).
- The corresponding output mask bits are set for the transferred bits; unused high bits are zero.

### Ready/Valid Handshake
- **Input side.** `ready_o` is high when the accumulator can accept more input (position + remaining bits < max capacity).
- **Output side.** `valid_o` is high when at least `OutW` bits are available (position >= OutW), or during flush when any bits remain.

### Flush Operation
- When `flush_i` is asserted, the packer drains any remaining partial data (even if less than OutW bits).
- Remaining bits are emitted on `data_o` (right-aligned), with the corresponding mask bits set.
- `flush_done_o` is asserted after the final flush data is transferred (when the accumulator is empty).

### Flush Pipeline
- Flush may take multiple cycles if the accumulator is full and output is not ready.
- `flush_done_o` remains asserted only after all data is drained and the accumulator is empty.

### Masking
- Only bits with `mask_i[j] = 1` are considered valid input.
- Bits with `mask_i[j] = 0` do not advance the position counter and do not contribute to output.
- This allows flexible input data widths and alignment.

### Redundancy (EnProtection Mode)
- When `EnProtection = 1`, the module maintains a duplicate accumulator and compares.
- If the two accumulators mismatch, `err_o` is asserted.
- In non-protected mode (`EnProtection = 0`), `err_o` remains low.

### Reset
- On `rst_ni` assertion (active low), the accumulator is cleared, position counter is zeroed, and `flush_done_o` is asserted.

## Example

With `InW = 8`, `OutW = 8`:

| Cycle | `valid_i` | `data_i` | `mask_i` | `ready_o` | `valid_o` | `data_o` | `ready_i` | Accum Pos | Notes |
|-------|---|---|---|---|---|---|---|---|---|
| 0 | 0 | — | 0 | 1 | 0 | — | 0 | 0 | Idle, accumulator empty |
| 1 | 1 | 0xAA | 0xFF | 1 | 0 | — | 0 | 8 | 8 bits input, not yet full output |
| 2 | 1 | 0x55 | 0xFF | 1 | 1 | 0xAA | 0 | 8 | 8 more bits input; first byte ready (0xAA) |
| 3 | 0 | — | 0 | 1 | 1 | 0x55 | 1 | 0 | Output transfers (0x55), accumulator drains |
| 4 | 1 | 0xCC | 0x0F | 1 | 0 | — | 0 | 4 | Partial input (4 bits of 0xCC), accumulator = 4 bits |
| 5 | 1 | 0xDD | 0xF0 | 1 | 1 | 0xCx | 0 | 12 | 4 more bits input; full output ready (0xCD) |
| 6 | 0 | — | 0 | 1 | 1 | 0xD0 | 1 | 0 | Output transfers; remaining partial data emitted |

Output words are left-aligned if the packer fills from least significant bits first.
