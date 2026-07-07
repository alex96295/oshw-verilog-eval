Design a module called TopModule. This module implements per-channel AXI4 FIFOs that buffer
transactions independently on each of the five AXI4 channels. It decouples the slave-side and
master-side timing, allowing independent clock or reset domains (same-clock variant) without
introducing extra latency beyond FIFO depth constraints.

## Overview

TopModule inserts independent, asynchronous FIFOs on each AXI4 channel (AW, W, B, AR, R). These FIFOs
decouple the slave-side protocol timing from the master-side timing: the slave can send transactions at
its own pace, and the master retrieves them at its own pace, with the FIFO absorbing any rate differences.
This is useful for buffering between different clock domains (with external CDC logic) or for intra-clock
isolation to improve timing. Each FIFO operates independently; one channel's congestion does not affect
others.

## Parameters

| Parameter | Meaning |
|-----------|---------|
| `aw_chan_t` | Struct type for the AXI write-address channel. |
| `w_chan_t` | Struct type for the AXI write-data channel. |
| `b_chan_t` | Struct type for the AXI write-response channel. |
| `ar_chan_t` | Struct type for the AXI read-address channel. |
| `r_chan_t` | Struct type for the AXI read-data channel. |
| `axi_req_t` | Struct type defining the complete AXI request. |
| `axi_resp_t` | Struct type defining the complete AXI response. |
| `FifoDepth` | Depth of each per-channel FIFO, in number of entries. Typical: 2–32. |

## Interface

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clk_i` | input | logic | Clock signal. All FIFO write and read logic is synchronous to this clock. |
| `rst_ni` | input | logic | Asynchronous active-low reset. |
| `slv_req_i` | input | `axi_req_t` | AXI4 request from the upstream slave. Valid signals indicate which channels have new data. |
| `slv_resp_o` | output | `axi_resp_t` | AXI4 response to the upstream slave. Ready signals indicate which channels have space in their FIFOs. |
| `mst_req_o` | output | `axi_req_t` | AXI4 request to the downstream master. Valid signals indicate which FIFO channels have data available. |
| `mst_resp_i` | input | `axi_resp_t` | AXI4 response from the downstream master. Ready signals allow the FIFOs to advance. |

## Behavioral requirements

- **Independent per-channel FIFOs.** Each of the five AXI4 channels operates an independent FIFO:
  - **AW FIFO**: Buffers write-address transactions.
  - **W FIFO**: Buffers write-data transactions.
  - **B FIFO**: Buffers write-response transactions.
  - **AR FIFO**: Buffers read-address transactions.
  - **R FIFO**: Buffers read-data transactions.
  
  Each FIFO has depth `FifoDepth` and operates on first-in, first-out order.

- **FIFO write-side (slave).** When the slave asserts valid on a channel and the FIFO is not full, the
  transaction is written into the FIFO on the next clock edge. The slave's ready signal for that channel
  reflects the FIFO's occupancy: ready=1 if space is available, ready=0 if full.

- **FIFO read-side (master).** The FIFO's output is always visible on the read side (oldest entry). The
  module asserts master-side valid when the FIFO is not empty. When the master asserts ready, the FIFO
  advances to the next entry (or becomes empty if no more data).

- **Asynchronous FIFOs (single-clock variant).** In a single-clock design, the FIFOs are implemented with
  standard read/write pointers, no Gray-code synchronization needed (pointers operate in the same clock).
  For multi-clock variants (not typical for this module), Gray-code pointer synchronization would be
  employed.

- **Full/empty tracking.** Each FIFO independently tracks full and empty states. Empty is signaled when
  the read pointer equals the write pointer. Full is signaled when (write_ptr + 1) mod FifoDepth equals
  read pointer.

- **Data latching.** Once written into the FIFO, transaction data is held and presented on the output
  combinationally (read-side data is a combinational function of FIFO RAM and read pointer). Valid/ready
  signals govern when data is consumed.

- **Burst handling.** Burst transactions (AW with length > 0, or AR with length > 0) have their full
  length encoded in the FIFO entry. The corresponding W and R beats are stored as separate FIFO entries.
  The module does not implicitly merge or split bursts; it buffers on a per-transaction (per-beat) basis.

- **Backpressure.** If any channel's FIFO is full, that channel's ready signal deasserts, stalling the
  slave. The slave may continue sending on other channels (if their FIFOs have space) since channels are
  independent.

- **Reset behavior.** On `rst_ni` assertion, all read/write pointers reset to zero, FIFOs are marked empty,
  and all valid/ready signals reset appropriately (all ready asserted, all valid deasserted).

- **Throughput.** In the absence of backpressure, throughput is one transaction per channel per clock cycle,
  limited by FIFO depth: after FifoDepth transactions accumulate without being consumed, backpressure is
  applied.

## Clock and reset domains

- Single clock domain: `clk_i` and `rst_ni`.

## Example behavior

1. **Write buffering.** Slave sends AW with valid=1; FIFO has space (FifoDepth=4, occupancy=1).
   - AW is written into AW FIFO on the next clock edge.
   - `slv_resp_o.aw_ready` remains asserted (FIFO still has space).
   - Master-side AW FIFO is now occupied; `mst_req_o.aw_valid` asserts.

2. **FIFO full.** Multiple AW transactions fill the AW FIFO to capacity (4 entries).
   - `slv_resp_o.aw_ready` deasserts.
   - Slave cannot send new AW until the master consumes one.

3. **Channel independence.** AW FIFO is full, but AR FIFO is empty.
   - `slv_resp_o.aw_ready` = 0, `slv_resp_o.ar_ready` = 1.
   - Slave can still send AR but not AW.
   - On master side, `mst_req_o.aw_valid` = 1 (data available), `mst_req_o.ar_valid` = 0 (no data).
