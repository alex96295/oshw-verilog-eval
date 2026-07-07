Design a module called TopModule. This module is a one-to-many demultiplexer for AXI4-Lite: it takes a single AXI4-Lite slave port (upstream) and routes transactions to one of N AXI4-Lite master ports (downstream) based on address decoding.

## Overview

TopModule acts as an address decoder and demultiplexer for AXI4-Lite traffic. It accepts AXI4-Lite requests on a single slave port and routes them to one of several downstream master ports based on the address field. Each downstream port is assigned an address range; requests with addresses in that range are routed to that port. Responses from the selected port are returned to the upstream slave. The module simplifies the integration of multiple AXI4-Lite peripherals behind a single master interface.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `NoMstPorts` | Number of downstream AXI4-Lite master ports. | ≥ 1. |
| `AxiAddrWidth` | Width of the AXI4-Lite address field, in bits. | ≥ 1. |
| `AxiDataWidth` | Width of the AXI4-Lite data field, in bits. | ≥ 8. |
| `aw_chan_t`, `w_chan_t`, `b_chan_t`, `ar_chan_t`, `r_chan_t` | Struct types for AXI4-Lite channels. | User-supplied; define packed structs for address, write data, write response, read address, read data. |
| `AddrRules` | Address-to-port mapping rules. | Array of rules specifying address ranges and target master port index. |

## Interface

### Clock and Reset
- `clk_i`: input, clock.
- `rst_ni`: input, active-low asynchronous reset.

### Slave Port (Upstream; Single Input)
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

### Master Ports (Downstream; array indexed `[0:NoMstPorts-1]`)
For each downstream master port:

- `mst_aw_chans_o`: output, array of `aw_chan_t`. Address write channels.
- `mst_aw_valids_o`: output, array of logic. Valid flags for address write.
- `mst_aw_readies_i`: input, array of logic. Ready flags for address write.

- `mst_w_chans_o`: output, array of `w_chan_t`. Write data channels.
- `mst_w_valids_o`: output, array of logic. Valid flags for write data.
- `mst_w_readies_i`: input, array of logic. Ready flags for write data.

- `mst_b_chans_i`: input, array of `b_chan_t`. Write response channels.
- `mst_b_valids_i`: input, array of logic. Valid flags for write response.
- `mst_b_readies_o`: output, array of logic. Ready flags for write response.

- `mst_ar_chans_o`: output, array of `ar_chan_t`. Address read channels.
- `mst_ar_valids_o`: output, array of logic. Valid flags for address read.
- `mst_ar_readies_i`: input, array of logic. Ready flags for address read.

- `mst_r_chans_i`: input, array of `r_chan_t`. Read data channels.
- `mst_r_valids_i`: input, array of logic. Valid flags for read data.
- `mst_r_readies_o`: output, array of logic. Ready flags for read data.

## Behavioral Requirements

- **Address Decoding.** The module decodes the address field of each incoming AW and AR request and selects the downstream master port based on `AddrRules`. If address `addr` falls within the range of rule `i`, the request is routed to `mst_port[i]`.

- **Single-Channel Routing.** Since AXI4-Lite does not have explicit master identifiers, the module uses address decoding alone to determine which downstream port receives the request. All channels (AW, W, AR) for a given transaction are routed to the same downstream port.

- **Write Path.** AW and W requests arriving at the slave are decoded and routed to the same downstream master. The module may buffer or pipeline them to ensure they remain paired. Write responses from the selected master are returned to the slave.

- **Read Path.** AR requests are decoded and routed. Read responses from the selected master are returned to the slave.

- **Address Errors.** If an address does not match any rule, the module returns a decode error (SLVERR or DECERR, depending on implementation) instead of forwarding the request.

- **Handshake Transparency.** Valid and ready signals are propagated according to the routing. A stalled downstream port causes the upstream port to become not ready.

- **Reset.** On release from reset (`rst_ni` assertion), all state is cleared and no transactions are in flight.

## Throughput and Latency

- **Throughput:** One transaction per clock cycle, subject to downstream port readiness and address decoding latency.
- **Latency:** Combinational address decoding and routing; minimal added latency.

## Clock and Reset Domains

- All ports operate in the same `clk_i` domain.
- Reset is asynchronous (`rst_ni`, active low).

## Example Behavior

Assume 2 downstream master ports with address rules:
- Master 0: 0x0000–0x0FFF
- Master 1: 0x1000–0x1FFF

1. Slave AW to address 0x0500: routed to `mst_aw_chans_o[0]`.
2. Slave AR to address 0x1200: routed to `mst_ar_chans_o[1]`.
3. Slave AW to address 0x2000 (out of range): returns SLVERR response.
4. Write response from `mst_b_chans_i[0]` is returned to `slv_b_chan_o`.
5. Read response from `mst_r_chans_i[1]` is returned to `slv_r_chan_o`.

Multiple transactions can be in flight to different downstream ports concurrently.
