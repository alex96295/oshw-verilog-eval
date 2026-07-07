Design a module called TopModule. This module is a full AXI4 crossbar: a configurable N-master-by-M-slave interconnect with address-based routing, ID remapping, and per-connection latency control.

## Overview

TopModule is an AXI4 crossbar (switch). It connects N AXI4 master ports to M AXI4 slave ports with full address-based routing. Each master can be routed to any subset of slaves based on address (defined via address rules). Transaction IDs are remapped at each connection to avoid ID collisions across masters. The crossbar supports configurable pipeline stages (register slices) on address and response paths for timing and dataflow control. Optional atomic operation (ATOP) support allows read-modify-write semantics across the fabric.

## Parameters

| Parameter | Meaning |
|-----------|---------|
| `Cfg` | xbar_cfg_t struct containing: NoSlvPorts (N), NoMstPorts (M), MaxMstTrans, MaxSlvTrans, address-map config, ID widths, etc. |
| `ATOPs` | Enable atomic operation support. |
| `Connectivity` | Bit matrix [NoSlvPorts-1:0][NoMstPorts-1:0]: Connectivity[s][m] = 1 if master m can reach slave s. |
| Channel struct types | slv_aw_chan_t, mst_aw_chan_t, w_chan_t, slv_b_chan_t, mst_b_chan_t, slv_ar_chan_t, mst_ar_chan_t, slv_r_chan_t, mst_r_chan_t, etc. |

## Interface

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clk_i` | input | - | Clock. |
| `rst_ni` | input | - | Active-low reset. |
| `slv_req_i[NoMstPorts-1:0]` | input array | axi_req_t | AXI4 requests from masters. |
| `slv_resp_o[NoMstPorts-1:0]` | output array | axi_resp_t | AXI4 responses to masters. |
| `mst_req_o[NoSlvPorts-1:0]` | output array | axi_req_t | AXI4 requests to slaves. |
| `mst_resp_i[NoSlvPorts-1:0]` | input array | axi_resp_t | AXI4 responses from slaves. |

## Behavioral requirements

- **Address-based routing.** Each write address (AW) and read address (AR) is examined; the address is matched against the address rules to determine which slave(s) are targeted. Write data (W) is routed to the same slave as the associated AW.
- **Address rules.** The `Cfg.NoAddrRules` address rules define ranges (start_addr, end_addr) and slave index (idx). A match occurs if start_addr <= requested_addr < end_addr.
- **ID remapping.** At each master-to-slave connection, the transaction ID is remapped to avoid collisions. A lookup table tracks the mapping from master-side ID to slave-side ID and back.
- **Routing matrix.** Connectivity parameter controls which masters can reach which slaves. If Connectivity[s][m] = 0, master m cannot be routed to slave s (request is held or error).
- **Pipeline stages.** LatencyMode and PipelineStages determine where register slices are inserted: on address channels (CUT_ALL_AX), on all ports (CUT_ALL_PORTS), etc.
- **Response collection.** Responses (B and R) from slaves are demultiplexed back to the originating master using the remapped ID lookup table.
- **Deadlock prevention.** The crossbar uses sufficient buffering and arbitration to prevent deadlock even with multiple masters and slaves.
- **ATOP support (optional).** If ATOPs enabled, atomic operations are forwarded to the slave and responses collected appropriately.
- **Reset behavior.** On reset, all arbitration state, ID tracking, and internal buffers are cleared.

## Throughput and latency

- **Latency.** Depends on `LatencyMode`: CUT_ALL_PORTS introduces latency on all paths; NO_LATENCY is combinational (dangerous for timing). Typically 1-4 cycles.
- **Throughput.** Bounded by per-master and per-slave bandwidths, plus arbitration fairness.

## Clock and reset domains

Single clock domain.

## Example behavior

With 2 masters (m=0,1) and 2 slaves (s=0,1), master 0 sends AW to address 0x1000 (routed to slave 0) with ID=3. Master 1 sends AW to address 0x3000 (routed to slave 1) with ID=5. The crossbar remaps: master 0 ID=3 becomes slave 0 ID=0 (or some other slot); master 1 ID=5 becomes slave 1 ID=0 (or another slot). When both slaves send B responses, they are demultiplexed back to masters 0 and 1 with their original IDs (3 and 5).
