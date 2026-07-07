Design a module called TopModule. This module accepts AXI4 transactions on a slave port and forwards them to a master port, with a critical modification: the address field of each transaction is overwritten with a supplied remapped address value.

## Overview

TopModule acts as an AXI4 address rewriter. It passes all AXI4 write and read address channels through largely unchanged, but replaces the address with a value supplied externally. All other fields (ID, length, size, burst, lock, cache, protection, QoS, region, atomic operations, user) and all data/response channels are forwarded unmodified. This allows a simple pass-through address translation layer without disrupting bursts or response ordering.

## Parameters

| Parameter | Meaning |
|-----------|---------|
| `slv_req_t` | Type of slave-side AXI4 request (contains AW/W/AR channels and valid signals). |
| `mst_addr_t` | Type of the remapped address value (address word width). |
| `mst_req_t` | Type of master-side AXI4 request. |
| `axi_resp_t` | Type of AXI4 response (contains B/R channels and ready signals). |

## Interface

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clk_i` | input | - | Clock. |
| `rst_ni` | input | - | Active-low reset. |
| `slv_req_i` | input | `slv_req_t` | AXI4 request from slave: contains write address (AW) with address field to be replaced, write data (W), read address (AR), and corresponding valid signals. |
| `slv_resp_o` | output | `axi_resp_t` | AXI4 response to slave: contains write response (B) and ready signals for slave channels. |
| `mst_aw_addr_i` | input | `mst_addr_t` | Replacement address for write address channel. |
| `mst_ar_addr_i` | input | `mst_addr_t` | Replacement address for read address channel. |
| `mst_req_o` | output | `mst_req_t` | AXI4 request to master: contains AW/W/AR channels with the address field replaced. |
| `mst_resp_i` | input | `axi_resp_t` | AXI4 response from master. |

## Behavioral requirements

- **Address substitution.** For each AW (write address) beat, all fields except the address are copied from the slave request to the master request; the address is replaced with `mst_aw_addr_i`. Similarly, for each AR (read address) beat, all fields except the address are copied, and the address is replaced with `mst_ar_addr_i`.
- **Other channel pass-through.** The W (write data), B (write response), and R (read data) channels, including their valid/ready signals, are passed through unmodified.
- **Handshaking.** The module is combinational in the address path: when `slv_req_i.aw_valid` is asserted, `mst_req_o.aw_valid` is immediately asserted (assuming no combinational latency in the remapping logic). The ready signal from the master (`mst_resp_i.aw_ready`) drives the slave's ready response.
- **Reset behavior.** No state is reset; the module is purely combinational for address remapping.

## Throughput and latency

- **Latency.** Combinational: address remapping introduces no clock cycles of latency.
- **Throughput.** Limited only by the underlying AXI4 master's ability to accept write and read address channels.

## Clock and reset domains

Single clock domain (`clk_i`). Reset (`rst_ni`) is provided but not required for combinational operation.

## Example behavior

Assume a slave sends a write address with ID=5, address=0x1000, length=4, and the remapped address input is 0x8000. The module will forward ID=5, address=0x8000 (replaced), length=4 to the master. The ID and all other address fields remain unchanged; only the address itself is rewritten.
