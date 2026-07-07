Design a module called TopModule. This module is an AXI4 crossbar that allows read responses to be interleaved with writes to different addresses, improving throughput by decoupling read and write traffic across multiple masters and slaves.

## Overview

TopModule is an AXI4 crossbar interconnect that routes transactions from multiple master ports to multiple slave ports based on address decoding. Unlike a simple crossbar that serializes all traffic, this variant permits response interleaving: read responses can be returned out of program order relative to write acknowledgments, as long as they are separated by address or ID. The crossbar maintains address-to-slave routing tables and arbitrates access to each slave port.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `NoMstPorts` | Number of AXI4 master input ports. | ≥ 1. |
| `NoSlvPorts` | Number of AXI4 slave output ports. | ≥ 1. |
| `AxiIdWidth` | Width of the AXI4 ID field, in bits. | ≥ 1. |
| `AxiAddrWidth` | Width of the AXI4 address field, in bits. | ≥ 1. |
| `AxiDataWidth` | Width of the AXI4 data field, in bits. | ≥ 8. |
| `aw_chan_t`, `w_chan_t`, `b_chan_t`, `ar_chan_t`, `r_chan_t` | Struct types for AXI4 channels. | User-supplied. |
| `AddrRules` | Address-to-slave mapping rules. | Array of rules specifying address ranges and target slave index. |

## Interface

### Clock and Reset
- `clk_i`: input, clock.
- `rst_ni`: input, active-low asynchronous reset.

### Master Ports (Upstream; array indexed `[0:NoMstPorts-1]`)
For each master port:

- `mst_aw_chans_i`: input, array of `aw_chan_t`. Address write requests from this master.
- `mst_aw_valids_i`: input, array of logic. Valid flags for address write.
- `mst_aw_readies_o`: output, array of logic. Ready flags for address write.

- `mst_w_chans_i`: input, array of `w_chan_t`. Write data from this master.
- `mst_w_valids_i`: input, array of logic. Valid flags for write data.
- `mst_w_readies_o`: output, array of logic. Ready flags for write data.

- `mst_b_chans_o`: output, array of `b_chan_t`. Write responses to this master.
- `mst_b_valids_o`: output, array of logic. Valid flags for write response.
- `mst_b_readies_i`: input, array of logic. Ready flags for write response.

- `mst_ar_chans_i`: input, array of `ar_chan_t`. Address read requests from this master.
- `mst_ar_valids_i`: input, array of logic. Valid flags for address read.
- `mst_ar_readies_o`: output, array of logic. Ready flags for address read.

- `mst_r_chans_o`: output, array of `r_chan_t`. Read data to this master.
- `mst_r_valids_o`: output, array of logic. Valid flags for read data.
- `mst_r_readies_i`: input, array of logic. Ready flags for read data.

### Slave Ports (Downstream; array indexed `[0:NoSlvPorts-1]`)
For each slave port:

- `slv_aw_chans_o`: output, array of `aw_chan_t`. Address write requests to this slave.
- `slv_aw_valids_o`: output, array of logic. Valid flags for address write.
- `slv_aw_readies_i`: input, array of logic. Ready flags for address write.

- `slv_w_chans_o`: output, array of `w_chan_t`. Write data to this slave.
- `slv_w_valids_o`: output, array of logic. Valid flags for write data.
- `slv_w_readies_i`: input, array of logic. Ready flags for write data.

- `slv_b_chans_i`: input, array of `b_chan_t`. Write responses from this slave.
- `slv_b_valids_i`: input, array of logic. Valid flags for write response.
- `slv_b_readies_o`: output, array of logic. Ready flags for write response.

- `slv_ar_chans_o`: output, array of `ar_chan_t`. Address read requests to this slave.
- `slv_ar_valids_o`: output, array of logic. Valid flags for address read.
- `slv_ar_readies_i`: input, array of logic. Ready flags for address read.

- `slv_r_chans_i`: input, array of `r_chan_t`. Read data from this slave.
- `slv_r_valids_i`: input, array of logic. Valid flags for read data.
- `slv_r_readies_o`: output, array of logic. Ready flags for read data.

## Behavioral Requirements

- **Address Decoding.** AW and AR requests are routed to slave ports based on the address field and the `AddrRules` mapping. A request with address `addr` is routed to the slave port identified by the rule whose address range contains `addr`.

- **Arbitration.** When multiple masters request access to the same slave port on the same channel (AW, W, or AR), the crossbar arbitrates using a priority scheme (typically round-robin or a fixed priority order). The arbitration is fair and ensures no master is starved indefinitely.

- **Response Routing.** B responses from a slave are routed back to the master that issued the corresponding AW request (matched by the master port ID inserted during request routing). R responses follow the same principle.

- **Interleaved Responses.** The module allows read and write responses to be interleaved. For example, a read response to master 0 can be returned before a write response to master 1, even if the read was issued after the write. This improves throughput when slave ports have varying latencies.

- **W-Channel Decoupling.** Write data (W channel) is routed to the same slave as the corresponding AW request but may follow different timing due to AXI4's decoupling of address and data channels.

- **Handshake Transparency.** Valid and ready signals propagate according to the routing and arbitration logic. A stalled slave does not block other slaves' traffic.

- **Reset.** On release from reset (`rst_ni` assertion), all state is cleared and no transactions are in flight.

## Throughput and Latency

- **Throughput:** Multiple masters can send requests to different slaves concurrently. Transactions to the same slave are serialized per channel (AW, W, AR, B, R), but different channels can operate concurrently.
- **Latency:** Depends on arbitration and slave port latency. The crossbar introduces minimal combinational delay for routing and arbitration.

## Clock and Reset Domains

- All ports operate in the same `clk_i` domain.
- Reset is asynchronous (`rst_ni`, active low).

## Example Behavior

Assume 2 masters and 2 slaves, with address rules:
- Slave 0: addresses 0x0000–0x1FFF
- Slave 1: addresses 0x2000–0x3FFF

- Master 0 issues AW to address 0x0500: routed to Slave 0.
- Master 1 issues AR to address 0x2100: routed to Slave 1.
- Both requests can proceed in parallel.
- Slave 0's B response can return to Master 0 at the same time Slave 1's R response returns to Master 1, achieving better throughput through interleaving.
