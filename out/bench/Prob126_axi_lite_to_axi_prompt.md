Design a module called TopModule. This module is an AXI4-Lite to full AXI4 upconverter, enabling AXI4-Lite masters to communicate with AXI4 slaves by expanding protocol capabilities: length, burst type, atomic operations, and ID fields.

## Overview

TopModule bridges AXI4-Lite and full AXI4 protocols by upconverting AXI4-Lite single-beat transactions into full AXI4 transactions. AXI4-Lite is a simplified subset of AXI4: no bursts (single beat only), no atomics, and optionally narrower ID/address/data widths. This module expands AXI4-Lite requests by setting burst length to 1, burst type to INCR, and optionally expanding address/data/ID widths, allowing integration with AXI4-only slaves.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `LiteAxiAddrWidth` | Width of the AXI4-Lite address field, in bits. | ≥ 1; typically 32. |
| `LiteAxiDataWidth` | Width of the AXI4-Lite data field, in bits. | Typically 32 or 64. |
| `FullAxiAddrWidth` | Width of the full AXI4 address field, in bits. | ≥ `LiteAxiAddrWidth`. |
| `FullAxiDataWidth` | Width of the full AXI4 data field, in bits. | ≥ `LiteAxiDataWidth`. |
| `FullAxiIdWidth` | Width of the full AXI4 ID field, in bits. | ≥ 1; AXI4-Lite typically has no ID field or narrower. |
| `lite_aw_chan_t`, etc. | Struct types for AXI4-Lite channels. | User-supplied. |
| `full_aw_chan_t`, etc. | Struct types for full AXI4 channels. | User-supplied. |

## Interface

### Clock and Reset
- `clk_i`: input, clock.
- `rst_ni`: input, active-low asynchronous reset.

### Slave Port (Upstream; AXI4-Lite)
- `slv_aw_chan_i`: input, `lite_aw_chan_t`. Address write channel (AXI4-Lite: addr, no len/burst/atop/id).
- `slv_aw_valid_i`: input, logic. Valid flag for address write.
- `slv_aw_ready_o`: output, logic. Ready flag for address write.

- `slv_w_chan_i`: input, `lite_w_chan_t`. Write data channel (AXI4-Lite: data, strb).
- `slv_w_valid_i`: input, logic. Valid flag for write data.
- `slv_w_ready_o`: output, logic. Ready flag for write data.

- `slv_b_chan_o`: output, `lite_b_chan_t`. Write response channel (AXI4-Lite: resp).
- `slv_b_valid_o`: output, logic. Valid flag for write response.
- `slv_b_ready_i`: input, logic. Ready flag for write response.

- `slv_ar_chan_i`: input, `lite_ar_chan_t`. Address read channel (AXI4-Lite: addr).
- `slv_ar_valid_i`: input, logic. Valid flag for address read.
- `slv_ar_ready_o`: output, logic. Ready flag for address read.

- `slv_r_chan_o`: output, `lite_r_chan_t`. Read data channel (AXI4-Lite: data, resp).
- `slv_r_valid_o`: output, logic. Valid flag for read data.
- `slv_r_ready_i`: input, logic. Ready flag for read data.

### Master Port (Downstream; Full AXI4)
- `mst_aw_chan_o`: output, `full_aw_chan_t`. Address write channel (AXI4: addr, len=0, burst=INCR, id, no atop).
- `mst_aw_valid_o`: output, logic. Valid flag for address write.
- `mst_aw_ready_i`: input, logic. Ready flag for address write.

- `mst_w_chan_o`: output, `full_w_chan_t`. Write data channel (AXI4: data, strb, last=1 for all beats).
- `mst_w_valid_o`: output, logic. Valid flag for write data.
- `mst_w_ready_i`: input, logic. Ready flag for write data.

- `mst_b_chan_i`: input, `full_b_chan_t`. Write response channel (AXI4: id, resp).
- `mst_b_valid_i`: input, logic. Valid flag for write response.
- `mst_b_ready_o`: output, logic. Ready flag for write response.

- `mst_ar_chan_o`: output, `full_aw_chan_t`. Address read channel (AXI4: addr, len=0, burst=INCR, id).
- `mst_ar_valid_o`: output, logic. Valid flag for address read.
- `mst_ar_ready_i`: input, logic. Ready flag for address read.

- `mst_r_chan_i`: input, `full_r_chan_t`. Read data channel (AXI4: id, data, resp, last=1 for all beats).
- `mst_r_valid_i`: input, logic. Valid flag for read data.
- `mst_r_ready_o`: output, logic. Ready flag for read data.

## Behavioral Requirements

- **Address Expansion (Write/Read Path).**
  - AXI4-Lite addresses are zero-extended to full AXI4 address width (if `FullAxiAddrWidth > LiteAxiAddrWidth`).
  - If `FullAxiAddrWidth < LiteAxiAddrWidth`, upper bits are truncated or an error is returned.

- **Data Expansion (Write Data).**
  - AXI4-Lite write data is packed into the full AXI4 data width. If widths match, data passes through. If `FullAxiDataWidth > LiteAxiDataWidth`, data is placed in the low bits; high bits are undefined or filled with zeros (configurable).
  - Write strobes are expanded correspondingly: AXI4-Lite strobes occupy the low byte lanes of the full AXI4 strobes.

- **Burst Expansion.**
  - AXI4-Lite requests (single-beat) are converted to AXI4 bursts with `len=0` (one beat) and `burst=INCR`.
  - `last` flag is set to 1 for the single W beat and all R beats (since len=0, all beats are final).

- **ID Expansion.**
  - If AXI4-Lite has no ID field, a default ID (0 or configurable) is inserted into AXI4 ID field. If AXI4-Lite has ID bits, they are zero-extended to full AXI4 ID width.
  - AXI4 B and R responses include ID fields; the module extracts the relevant bits and returns them to the AXI4-Lite slave (which may ignore them).

- **Atomic Operations.**
  - AXI4-Lite has no atomic support (`atop` field absent or ignored). The AXI4 side is set with `atop=NONE` or equivalent.

- **Response Pass-Through.**
  - Write responses (B) and read responses (R) from the AXI4 slave are passed back to the AXI4-Lite master with response codes preserved.

- **Handshake Transparency.**
  - Valid and ready signals are propagated; there is no artificial buffering or stalling (unless width conversion requires multi-cycle operation for data unpacking).

- **Reset.** On release from reset (`rst_ni` assertion), all state is cleared and no transactions are pending.

## Throughput and Latency

- **Throughput:** One AXI4-Lite transaction per AXI4 single-beat transaction. Throughput is limited by the downstream AXI4 port readiness.
- **Latency:** Combinational for most conversions; data width expansion may require 1 cycle if buffering is needed.

## Clock and Reset Domains

- All ports operate in the same `clk_i` domain.
- Reset is asynchronous (`rst_ni`, active low).

## Example Behavior

Assume `LiteAxiAddrWidth=32, LiteAxiDataWidth=32, FullAxiAddrWidth=40, FullAxiDataWidth=64, FullAxiIdWidth=4`:

1. AXI4-Lite AW to 0x1000 with W data 32'hDEADBEEF (strobes 4'hF):
   - Full AXI4 AW: addr=0x0000001000 (zero-extended), len=0, burst=INCR, id=0 (default).
   - Full AXI4 W: data=0x00000000DEADBEEF (padded with zeros), strb=0x0F (lower 4 bytes), last=1.

2. Full AXI4 B response: id=0, resp=OKAY:
   - AXI4-Lite B response: resp=OKAY (id field ignored).

3. AXI4-Lite AR to 0x2000:
   - Full AXI4 AR: addr=0x0000002000, len=0, burst=INCR, id=0.
   - Full AXI4 R response: data=0x0123456789ABCDEF (only lower 32 bits extracted for AXI4-Lite).
   - AXI4-Lite R: data=0x89ABCDEF (lower 32 bits), resp=OKAY.

The module enables seamless integration of AXI4-Lite masters with AXI4-only slaves.
