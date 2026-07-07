Design a module called TopModule. This module is a width-converting FIFO: it accepts data at one width (input) and produces data at a different width (output), with packing or unpacking as needed.

## Overview

TopModule implements a FIFO that bridges two different data widths in a single clock domain. It handles both packing (accumulating multiple narrow inputs into a wide output) and unpacking (distributing a wide input across multiple narrow outputs). The FIFO maintains an internal buffer and a fill-level counter to track how many "output words" are available or how much space is available for input.

## Parameters

| Parameter | Meaning | Default |
|-----------|---------|---------|
| `InW`     | Input data width, in bits. | 32 |
| `OutW`    | Output data width, in bits. | 8 |
| `ClearOnRead` | When 1, the output buffer is cleared after a successful read; when 0, data persists. | 1 |

**Derived Parameters:**
- `MaxW = max(InW, OutW)`: the width of the internal storage buffer.
- `MinW = min(InW, OutW)`: the narrower of the two widths.
- `WidthRatio = MaxW / MinW`: the number of MinW-sized pieces per MaxW-sized piece.
- `DepthW = $clog2(WidthRatio)` bits: width for the internal fill counter.

**Operation Modes:**
- If `InW < OutW`: **Pack mode**. Multiple input words are accumulated into a wide output.
- If `InW > OutW`: **Unpack mode**. A wide input word is distributed across multiple output words.
- If `InW == OutW`: **Pass-through mode** (degenerate packing; WidthRatio = 1).

## Interface

| Port         | Direction | Width    | Description |
|-------------|-----------|----------|-------------|
| `clk_i`     | input     | 1        | Clock. All state updates occur on rising edge. |
| `rst_ni`    | input     | 1        | Asynchronous reset (active low). Clears internal buffer and counters. |
| `clr_i`     | input     | 1        | Clear input. When high, resets the FIFO state and internal counter. |
| `wvalid_i`  | input     | 1        | Write valid. When high and `wready_o` is high, `wdata_i` is written into the accumulator. |
| `wdata_i`   | input     | `InW`    | Write data. Captured when both `wvalid_i` and `wready_o` are high. |
| `wready_o`  | output    | 1        | Write ready. High when the FIFO can accept input (is not full). |
| `rvalid_o`  | output    | 1        | Read valid. High when the FIFO has data available to read. |
| `rdata_o`   | output    | `OutW`   | Read data. Output word extracted from the internal buffer (combinational in unpack mode, or pipelined in pack mode). |
| `rready_i`  | input     | 1        | Read ready. When high and `rvalid_o` is high, a word is consumed from the FIFO. |
| `depth_o`   | output    | `DepthW+1` | Fill level. For pack mode, counts partial fill; for unpack mode, counts remaining output words. |

## Behavioral Requirements (Pack Mode: InW < OutW)

**Accumulation:**
- Input data is packed (aligned and combined) into the wider internal buffer.
- As successive input words arrive, each is shifted and ORed into the buffer at position `depth * InW`.
- When `depth` reaches `WidthRatio`, a complete output word is formed.

**Output Trigger:**
- `rvalid_o` is high when the depth counter reaches `WidthRatio` (full output word available).
- `rdata_o` reflects the upper `OutW` bits of the accumulated buffer.

**Clear and Write-Ready:**
- `wready_o` is high when `depth < WidthRatio` and no clear is pending.
- When `rready_i` is asserted (consuming an output word) and depth reaches WidthRatio, the buffer is cleared (if `ClearOnRead = 1`) and depth resets to 0.

**Fill Counter:**
- `depth_o` counts the number of input words currently held in the accumulator [0, WidthRatio].
- Increments on a successful write, resets on a successful read (if ClearOnRead) or on clear.

## Behavioral Requirements (Unpack Mode: InW > OutW)

**Unpacking:**
- A wide input word is stored in the buffer and distributed across multiple output cycles.
- Each read extracts the lower `OutW` bits and right-shifts the buffer for the next output.
- A pointer (`ptr`) tracks which segment of the buffer is currently being output.

**Output Extraction:**
- `rdata_o` is combinational, extracting bits `[ptr * OutW +: OutW]` from the buffer.
- `rvalid_o` is high when depth is not zero (i.e., there is an unconsumed input word).

**Input and Clear:**
- A new wide input is accepted only when the FIFO is empty (`depth == 0`).
- `wready_o` is high when no data is pending or when all outputs have been consumed.
- After an input is accepted, `depth` is set to `WidthRatio` (the number of output words to come).

**Fill Counter:**
- `depth_o` counts the number of remaining output words from the current input [0, WidthRatio].
- Decrements on each successful read (if `rvalid_o && rready_i`).
- Resets to 0 after the last output is consumed or on clear.

## Example Scenarios

### Pack Mode (InW=4, OutW=8, ClearOnRead=1)

| Cycle | Event | `wdata_i` | `depth` | Buffer | `rvalid_o` | `rdata_o` |
|-------|-------|-----------|---------|--------|-----------|-----------|
| 0     | Write | 0x3       | 1       | 0x03   | 0         | --        |
| 1     | Write | 0x5       | 2       | 0x53   | 1         | 0x53      |
| 2     | Read  | --        | 0       | 0x00   | 0         | --        |
| 3     | Write | 0xA       | 1       | 0x0A   | 0         | --        |
| 4     | Write | 0xB       | 2       | 0xBA   | 1         | 0xBA      |

### Unpack Mode (InW=8, OutW=4, ClearOnRead=1)

| Cycle | Event  | `wdata_i` | `depth` | `rdata_o` | Ptr |
|-------|--------|-----------|---------|-----------|-----|
| 0     | Write  | 0xAB      | 2       | --        | 0   |
| 1     | Read   | --        | 1       | 0xB       | 1   |
| 2     | Read   | --        | 0       | --        | 0   |
| 3     | Write  | 0xCD      | 2       | 0xD       | 0   |
| 4     | Read   | --        | 1       | 0xC       | 1   |

## Reset and Clear Behavior

- On `rst_ni` low or `clr_i` high:
  - Internal buffer is zeroed.
  - Depth counter is reset to 0.
  - Pointers (in unpack mode) are reset to 0.
  - In pack mode, no partial inputs remain.
  - In unpack mode, no output words remain.

## Edge Cases

**Pack Mode, Width Mismatch:**
- If `InW` does not divide evenly into `OutW` but one is a multiple of the other, alignment is straightforward.
- Otherwise, implementation uses shifting logic to align inputs correctly.

**Unpack Mode, Partial Reads:**
- Successive reads extract segments of the wide word.
- Each read updates the pointer for the next segment until all outputs are consumed.

**Clear During Active Transfer:**
- Clearing mid-transfer immediately resets all counters and buffers.
- After clear, the FIFO behaves as if empty/ready for new input.

## Optional Behavior: ClearOnRead Parameter

- When `ClearOnRead = 1`, the buffer is cleared immediately after an output word is consumed (full cycle).
- When `ClearOnRead = 0`, the buffer persists; partial outputs remain until a new write overwrites them. This may be useful for repeated reads of the same data.
