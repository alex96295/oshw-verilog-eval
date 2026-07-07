Design a module called TopModule. This module converts the AXI4 ID field width between a wider master-side ID and a narrower slave-side ID (or vice versa), using a lookup table or dynamic mapping to preserve ID ordering guarantees.

## Overview

TopModule is an ID-width converter that bridges AXI4 buses with different ID field widths. Unlike prepend/remap which may be unidirectional, this module handles both width expansion and contraction. It maps transaction IDs from the wider side to the narrower side by reducing or expanding the ID bits while maintaining the AXI4 requirement that transactions with the same ID receive responses in order. The module tracks in-flight transaction IDs and applies a mapping strategy (e.g., stripping high bits, using a lookup table, or dynamic allocation) to ensure no ID collisions on the narrower side.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `MstAxiIdWidth` | Width of the AXI4 ID field on the master side, in bits. | ≥ 1. |
| `SlvAxiIdWidth` | Width of the AXI4 ID field on the slave side, in bits. | ≥ 1. May differ from `MstAxiIdWidth`. |
| `AxiAddrWidth` | Width of the AXI4 address field, in bits. | ≥ 1. |
| `AxiDataWidth` | Width of the AXI4 data field, in bits. | ≥ 8. |
| `aw_chan_t`, `w_chan_t`, `b_chan_t`, `ar_chan_t`, `r_chan_t` | Struct types for AXI4 channels. | User-supplied; must support both ID widths (templated or union-based). |

## Interface

### Clock and Reset
- `clk_i`: input, clock.
- `rst_ni`: input, active-low asynchronous reset.

### Master Side (Wider or Different ID Width)
- `mst_aw_chan_i`: input, `aw_chan_t` (with `MstAxiIdWidth` bits). Address write requests.
- `mst_aw_valid_i`: input, logic. Valid flag for address write.
- `mst_aw_ready_o`: output, logic. Ready flag for address write.

- `mst_w_chan_i`: input, `w_chan_t`. Write data.
- `mst_w_valid_i`: input, logic. Valid flag for write data.
- `mst_w_ready_o`: output, logic. Ready flag for write data.

- `mst_b_chan_o`: output, `b_chan_t` (with `MstAxiIdWidth` bits). Write responses.
- `mst_b_valid_o`: output, logic. Valid flag for write response.
- `mst_b_ready_i`: input, logic. Ready flag for write response.

- `mst_ar_chan_i`: input, `ar_chan_t` (with `MstAxiIdWidth` bits). Address read requests.
- `mst_ar_valid_i`: input, logic. Valid flag for address read.
- `mst_ar_ready_o`: output, logic. Ready flag for address read.

- `mst_r_chan_o`: output, `r_chan_t` (with `MstAxiIdWidth` bits). Read data responses.
- `mst_r_valid_o`: output, logic. Valid flag for read data.
- `mst_r_ready_i`: input, logic. Ready flag for read data.

### Slave Side (Narrower or Different ID Width)
- `slv_aw_chan_o`: output, `aw_chan_t` (with `SlvAxiIdWidth` bits). Address write requests (converted).
- `slv_aw_valid_o`: output, logic. Valid flag for address write.
- `slv_aw_ready_i`: input, logic. Ready flag for address write.

- `slv_w_chan_o`: output, `w_chan_t`. Write data (passed through).
- `slv_w_valid_o`: output, logic. Valid flag for write data.
- `slv_w_ready_i`: input, logic. Ready flag for write data.

- `slv_b_chan_i`: input, `b_chan_t` (with `SlvAxiIdWidth` bits). Write responses (from downstream).
- `slv_b_valid_i`: input, logic. Valid flag for write response.
- `slv_b_ready_o`: output, logic. Ready flag for write response.

- `slv_ar_chan_o`: output, `ar_chan_t` (with `SlvAxiIdWidth` bits). Address read requests (converted).
- `slv_ar_valid_o`: output, logic. Valid flag for address read.
- `slv_ar_ready_i`: input, logic. Ready flag for address read.

- `slv_r_chan_i`: input, `r_chan_t` (with `SlvAxiIdWidth` bits). Read data responses (from downstream).
- `slv_r_valid_i`: input, logic. Valid flag for read data.
- `slv_r_ready_o`: output, logic. Ready flag for read data.

## Behavioral Requirements

- **ID Width Conversion (Forward Path).** When an AW or AR request arrives on the master side with ID `mst_id`, the module converts it to `slv_id` for forwarding to the slave:
  - If `MstAxiIdWidth > SlvAxiIdWidth`: reduce by stripping high bits or mapping via table (e.g., `slv_id = mst_id[SlvAxiIdWidth-1:0]`).
  - If `MstAxiIdWidth < SlvAxiIdWidth`: expand by padding high bits with zeros or mapping (e.g., `slv_id = {(SlvAxiIdWidth - MstAxiIdWidth){1'b0}}, mst_id}`).
  - If widths are equal, pass through unchanged.

- **ID Tracking.** The module maintains a mapping table to track which master-side IDs are currently in flight and their corresponding slave-side IDs. This enables correct reverse mapping of responses.

- **ID Ordering Preservation.** If two master requests map to the same slave ID, they are serialized on the slave side to ensure AXI4 ordering. The module blocks new requests until prior ones with the same slave ID have received responses.

- **ID Width Conversion (Return Path).** When B or R responses arrive from the slave side with ID `slv_id`, the module performs a reverse lookup to find the original `mst_id` and returns the response with the correct master ID.

- **W Channel Passthrough.** Write data (W) passes through unchanged.

- **Handshake Transparency.** Valid and ready signals propagate; there is no artificial deadlock risk.

- **Reset.** On release from reset (`rst_ni` assertion), all mappings are cleared and no transactions are in flight.

## Throughput and Latency

- **Throughput:** Limited by ID collisions on the narrower side and downstream port readiness. One transaction per unique slave ID per round-trip.
- **Latency:** Combinational ID conversion; total latency depends on buffering for ordering enforcement.

## Clock and Reset Domains

- All ports operate in the same `clk_i` domain.
- Reset is asynchronous (`rst_ni`, active low).

## Example Behavior

Assume `MstAxiIdWidth = 8`, `SlvAxiIdWidth = 4`:

- Master-side AW with `id = 8'hA5` (binary: `10100101`):
  - Converted to `slv_id = 4'h5` (lower 4 bits: `0101`).
- Master-side AW with `id = 8'hB5` (binary: `10110101`):
  - Converted to `slv_id = 4'h5` (lower 4 bits: `0101`).
  - Since both map to slave ID 5, the second request is blocked until the first's response completes.
- Slave-side B response with `id = 4'h5`: module performs reverse lookup and returns with `mst_id = 8'hA5` (or 8'hB5 after the first completes).

The module preserves AXI4 ordering by serializing requests with the same slave ID.
