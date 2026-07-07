Design a module called TopModule. This module joins two separate AXI4 interfaces—one read-only and one write-only—onto a single combined read-write AXI4 interface.

## Overview

TopModule is an AXI4 read/write joiner. It accepts two independent AXI4 connections: one carrying read transactions (AR/R channels only) and another carrying write transactions (AW/W/B channels only). These are merged into a single full AXI4 port that carries both read and write traffic. The module routes each channel from the appropriate source to the destination, with minimal logic.

## Parameters

| Parameter | Meaning |
|-----------|---------|
| `axi_req_t` | Type of AXI4 request struct (contains all address and data channels + valid flags). |
| `axi_resp_t` | Type of AXI4 response struct (contains B and R channels + ready flags). |

## Interface

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clk_i` | input | - | Clock. |
| `rst_ni` | input | - | Active-low reset. |
| `slv_read_req_i` | input | `axi_req_t` | Read-only request from a master: AR channel with valid. Other fields are unused. |
| `slv_read_resp_o` | output | `axi_resp_t` | Read response to the master: R channel with valid; other fields held low. |
| `slv_write_req_i` | input | `axi_req_t` | Write-only request from another master: AW and W channels with valid. Other fields are unused. |
| `slv_write_resp_o` | output | `axi_resp_t` | Write response to the master: B channel with valid. Other fields held low. |
| `mst_req_o` | output | `axi_req_t` | Combined AXI4 request to slave: all channels (AW, W, AR) from the appropriate source. |
| `mst_resp_i` | input | `axi_resp_t` | AXI4 response from slave: all channels (B, R). |

## Behavioral requirements

- **Channel routing.** AR valid/payload from `slv_read_req_i` drive `mst_req_o.ar`; R channel from `mst_resp_i` drives `slv_read_resp_o.r`. AW/W from `slv_write_req_i` drive `mst_req_o.aw`/`mst_req_o.w`; B from `mst_resp_i` drives `slv_write_resp_o.b`.
- **Ready signal routing.** `mst_resp_i.ar_ready` drives `slv_read_resp_o.ar_ready`. `mst_resp_i.aw_ready` and `mst_resp_i.w_ready` drive `slv_write_resp_o.aw_ready` and `slv_write_resp_o.w_ready`.
- **Unused channels.** AW/W fields in read requests are unused (held zero). AR field in write requests is unused. B/R channels in write/read responses are held zero on the unused side.
- **No ordering guarantees between read and write.** The module provides no special ordering; relative ordering of reads and writes depends on the slave and the protocol.
- **Combinational.** Routing is combinational; no clock cycles of latency.

## Throughput and latency

- **Latency.** Combinational (zero).
- **Throughput.** Independent read and write paths; one read and one write can progress in parallel, both limited by the master's per-channel bandwidth.

## Clock and reset domains

Single clock domain. Reset is provided but not required for combinational logic.

## Example behavior

A read master sends AR (read address) with ID=1 and address=0x1000. Simultaneously, a write master sends AW/W with ID=2 and address=0x2000. The combined master port carries both: AR and AW simultaneously, each with its own ID. Responses from the slave (R for ID=1, B for ID=2) are routed back to the respective read and write masters.
