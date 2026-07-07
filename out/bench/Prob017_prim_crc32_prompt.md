Design a module called TopModule. This module is a streaming CRC-32 calculator that processes input data one or more bytes per clock cycle and maintains a running CRC-32 value.

## Overview

TopModule computes the CRC-32 checksum of a data stream. It accepts multi-byte input data at each clock cycle and produces a running CRC-32 output. The CRC can be initialized or reset via a dedicated set input, and the polynomial used is the standard CRC-32-IEEE polynomial (0x1EDC6F41 with the reflected algorithm). The module updates the CRC on each clock when either a set command is issued or new data is present.

## Parameters

| Parameter | Meaning | Default |
|-----------|---------|---------|
| `BytesPerWord` | Number of bytes in each input data word. | 4 |

The input data width is `8 * BytesPerWord` bits. For `BytesPerWord = 4`, the input is 32 bits (4 bytes).

## Interface

| Port           | Direction | Width   | Description |
|----------------|-----------|---------|-------------|
| `clk_i`        | input     | 1       | Clock. All state updates occur on the rising edge. |
| `rst_ni`       | input     | 1       | Asynchronous reset (active low). Initializes `crc_out_o` to 0xFFFFFFFF. |
| `set_crc_i`    | input     | 1       | Set/load input. When high and held for one cycle, loads the CRC with the inverse of `crc_in_i`. This is typically used to initialize or reinitialize the CRC. |
| `crc_in_i`     | input     | 32      | CRC initialization value. Used only when `set_crc_i` is high; the loaded value is `~crc_in_i`. |
| `data_valid_i` | input     | 1       | Data valid signal. When high, the input `data_i` is processed by the CRC. |
| `data_i`       | input     | 8*BytesPerWord | Input data bytes. Bytes are indexed from least significant to most significant. |
| `crc_out_o`    | output    | 32      | Current CRC-32 value, inverted (as is standard for CRC-32). This is the final checksum once all data has been processed. |

## Behavioral Requirements

**CRC Computation:**
- The CRC-32 algorithm is the standard reflected form with polynomial 0x1EDC6F41.
- When `set_crc_i` is high (for one cycle), the CRC state is set to the bitwise NOT of `crc_in_i`. (This is the standard initialization for reflected CRC-32: loading 0xFFFFFFFF is done by asserting `set_crc_i` and setting `crc_in_i` to 0x00000000.)
- When `data_valid_i` is high, each byte of `data_i` (from byte 0 to byte `BytesPerWord-1`) is fed into the CRC calculation in order.
- The CRC output `crc_out_o` is the bitwise NOT of the internal CRC state, following the standard CRC-32 convention.

**Update Logic:**
- The CRC is updated on each rising edge of `clk_i` if either `set_crc_i` or `data_valid_i` is high.
- If both signals are high simultaneously, `set_crc_i` takes precedence and the CRC is reloaded; `data_i` is ignored.
- If neither signal is high, the CRC state is held unchanged.

**Reset Behavior:**
- On asynchronous reset (`rst_ni` low), the internal CRC state is set to 0xFFFFFFFF, so `crc_out_o` immediately shows 0x00000000 (the inverted value).
- After reset release, the CRC can be driven by incoming data or by asserting `set_crc_i`.

**Data Order:**
- Input bytes are processed in order from `data_i[7:0]` (byte 0) through `data_i[8*BytesPerWord-1:8*(BytesPerWord-1)]`.

**Combinational Output:**
- `crc_out_o` is always the NOT of the internal CRC state and reflects the state at the current clock cycle (before the next update, if any).

## Example: CRC-32 of 0x01020304 with BytesPerWord = 4

1. Reset: `crc_out_o = 0x00000000` (internal state = 0xFFFFFFFF).
2. Cycle 1: Set `set_crc_i = 1`, `crc_in_i = 0x00000000` → internal state becomes 0xFFFFFFFF, output `crc_out_o = 0x00000000`.
3. Cycle 2: Set `data_valid_i = 1`, `data_i = 0x04030201` → CRC processes byte 0x01, then 0x02, then 0x03, then 0x04. Output reflects the updated CRC.
4. Subsequent cycles: If more data arrives, the CRC continues to update; if no data, output remains stable.

## Polynomial and Algorithm

- **Polynomial:** CRC-32-IEEE (0x1EDC6F41 in the reflected/input-reflected form).
- **Initial Value:** 0xFFFFFFFF (set via `crc_in_i` when `set_crc_i` is high).
- **Final XOR:** 0xFFFFFFFF (applied via the NOT at the output).
- **Reflected Input/Output:** Yes (standard for CRC-32-IEEE).

The CRC calculation is performed on a per-byte basis; when `BytesPerWord > 1`, all bytes are processed in a single cycle via a pipelined computation that avoids state updates mid-cycle.
