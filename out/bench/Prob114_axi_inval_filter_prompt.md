Design a module called TopModule. This module implements a cache-invalidation filter on the AXI4 bus, recognizing invalidation (CLFlush) transactions and filtering them from normal memory operations to prevent coherency issues.

## Overview

TopModule is a filtering bridge that sits on an AXI4 bus and recognizes cache-invalidation operations (typically signaled via the ATOP field or a dedicated invalidation protocol). When an invalidation request is detected, the module either forwards it to a special invalidation port or filters it out of the normal memory traffic, preventing it from interfering with coherent memory access patterns. Normal read and write transactions pass through unchanged.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `AxiIdWidth` | Width of the AXI4 ID field, in bits. | ≥ 1. |
| `AxiAddrWidth` | Width of the AXI4 address field, in bits. | ≥ 1. |
| `AxiDataWidth` | Width of the AXI4 data field, in bits. | ≥ 8. |
| `aw_chan_t`, `w_chan_t`, `b_chan_t`, `ar_chan_t`, `r_chan_t` | Struct types for AXI4 channels. | User-supplied. |

## Interface

### Clock and Reset
- `clk_i`: input, clock.
- `rst_ni`: input, active-low asynchronous reset.

### Slave Port (Upstream)
- `slv_aw_chan_i`: input, `aw_chan_t`. Address write channel.
- `slv_aw_valid_i`: input, logic. Valid flag for address write.
- `slv_aw_ready_o`: output, logic. Ready flag for address write.

- `slv_w_chan_i`: input, `w_chan_t`. Write data channel.
- `slv_w_valid_i`: input, logic. Valid flag for write data.
- `slv_w_ready_o`: output, logic. Ready flag for write data.

- `slv_b_chan_o`: output, `b_chan_t`. Write response channel.
- `slv_b_valid_o`: output, logic. Valid flag for write response.
- `slv_b_ready_i`: input, logic. Ready flag for write response.

- `slv_ar_chan_i`: input, `ar_chan_t`. Address read channel.
- `slv_ar_valid_i`: input, logic. Valid flag for address read.
- `slv_ar_ready_o`: output, logic. Ready flag for address read.

- `slv_r_chan_o`: output, `r_chan_t`. Read data channel.
- `slv_r_valid_o`: output, logic. Valid flag for read data.
- `slv_r_ready_i`: input, logic. Ready flag for read data.

### Master Port (Downstream)
- `mst_aw_chan_o`: output, `aw_chan_t`. Address write channel (filtered).
- `mst_aw_valid_o`: output, logic. Valid flag for address write.
- `mst_aw_ready_i`: input, logic. Ready flag for address write.

- `mst_w_chan_o`: output, `w_chan_t`. Write data channel (filtered).
- `mst_w_valid_o`: output, logic. Valid flag for write data.
- `mst_w_ready_i`: input, logic. Ready flag for write data.

- `mst_b_chan_i`: input, `b_chan_t`. Write response channel.
- `mst_b_valid_i`: input, logic. Valid flag for write response.
- `mst_b_ready_o`: output, logic. Ready flag for write response.

- `mst_ar_chan_o`: output, `ar_chan_t`. Address read channel (filtered).
- `mst_ar_valid_o`: output, logic. Valid flag for address read.
- `mst_ar_ready_i`: input, logic. Ready flag for address read.

- `mst_r_chan_i`: input, `r_chan_t`. Read data channel.
- `mst_r_valid_i`: input, logic. Valid flag for read data.
- `mst_r_ready_o`: output, logic. Ready flag for read data.

### Invalidation Port (Optional)
- `inval_aw_chan_o`: output, `aw_chan_t`. Invalidation write address.
- `inval_aw_valid_o`: output, logic. Valid flag for invalidation request.
- `inval_aw_ready_i`: input, logic. Ready flag for invalidation request.

- `inval_b_chan_i`: input, `b_chan_t`. Invalidation response.
- `inval_b_valid_i`: input, logic. Valid flag for invalidation response.
- `inval_b_ready_o`: output, logic. Ready flag for invalidation response.

## Behavioral Requirements

- **Invalidation Detection.** The module identifies invalidation transactions by examining the AW channel's ATOP field (or user-defined signal). Transactions with ATOP indicating a cache invalidation/CLFlush operation are marked as invalidations.

- **Filtering.** Invalidation write addresses are routed to the optional `inval_*` port and are prevented from reaching the main memory port. Their write responses are collected from the invalidation port and returned to the upstream master with the original ID and status.

- **Normal Traffic Pass-Through.** Non-invalidation AW, AR, W, B, and R transactions pass through the main master port unchanged. All other address bits, sizes, IDs, and control signals are preserved.

- **Response Routing.** B responses from the invalidation port are routed back to the upstream slave with the same ID as the corresponding invalidation AW request. B responses from the main master port are passed through normally.

- **Ordering.** Invalidation and normal write requests to the same address or ID may need serialization to prevent cache coherency violations. The module may enforce that no normal writes are in flight when an invalidation for the same address range is pending.

- **Handshake Transparency.** Valid and ready signals are propagated; a stalled invalidation port does not block normal traffic (unless ordering constraints require it).

- **Reset.** On release from reset (`rst_ni` assertion), all state is cleared.

## Throughput and Latency

- **Throughput:** Invalidations and normal traffic can proceed in parallel if the invalidation port is ready. Throughput is limited by the slowest port (main master or invalidation port).
- **Latency:** Minimal; filtering is combinational or with single-cycle buffering.

## Clock and Reset Domains

- All ports operate in the same `clk_i` domain.
- Reset is asynchronous (`rst_ni`, active low).

## Example Behavior

Assume ATOP values:
- Normal write: `atop = 6'b000000`
- CLFlush invalidation: `atop = 6'b111100`

- Slave sends AW with `atop = 6'b000000`: forwarded to `mst_aw_*`.
- Slave sends AW with `atop = 6'b111100`: forwarded to `inval_aw_*` instead, skipping the main master port.
- Invalidation response returns with the same ID as the original AW request.

Normal read and write traffic proceeds independently, improving throughput by isolating cache operations.
