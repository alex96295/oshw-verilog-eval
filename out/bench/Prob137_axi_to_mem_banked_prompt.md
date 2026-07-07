Design a module called TopModule. This module converts an AXI4 slave interface into banked memory access ports, distributing transactions across multiple independent memory banks based on address.

## Overview

TopModule is an AXI4-to-banked-memory converter. It accepts AXI4 transactions on a slave port and distributes them across multiple independent memory banks. Each bank is accessed via a simple memory interface (request/grant, address, write data, write enable/strobes, read data). Address bits are used to select which bank(s) to access; when a transaction spans multiple banks, the converter decomposes it into multiple bank accesses. This is useful for architectures with parallel memory banks and striped or interleaved addressing.

## Parameters

| Parameter | Meaning |
|-----------|---------|
| `AxiIdWidth`, `AxiAddrWidth`, `AxiDataWidth` | AXI4 widths. |
| `axi_aw_chan_t`, ..., `axi_resp_t` | AXI4 struct types. |
| `MemNumBanks` | Number of parallel memory banks. |
| Other parameters | Bank addressing, buffer configuration. |

## Interface

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clk_i` | input | - | Clock. |
| `rst_ni` | input | - | Active-low reset. |
| `slv_req_i` | input | `axi_req_t` | AXI4 request from master. |
| `slv_resp_o` | output | `axi_resp_t` | AXI4 response to master. |
| `mem_req_o[MemNumBanks-1:0]` | output array | struct | Memory request to each bank. |
| `mem_req_valid_o[MemNumBanks-1:0]` | output array | logic | Request valid for each bank. |
| `mem_req_ready_i[MemNumBanks-1:0]` | input array | logic | Request ready from each bank. |
| `mem_rsp_i[MemNumBanks-1:0]` | input array | struct | Memory response from each bank. |
| `mem_rsp_valid_i[MemNumBanks-1:0]` | input array | logic | Response valid from each bank. |
| `mem_rsp_ready_o[MemNumBanks-1:0]` | output array | logic | Response ready to each bank. |

## Behavioral requirements

- **Address-based bank selection.** Address bits (typically low-order bits) are used to determine which bank(s) handle a transaction. A transaction at address 0x0000 might go to bank 0; address 0x0100 to bank 1, etc. The exact mapping is determined by address width and bank count.
- **Request distribution.** Write and read requests are dispatched to the appropriate bank(s) based on the starting address and burst parameters. If a burst crosses a bank boundary, it is decomposed into multiple bank requests.
- **Response collection.** Read responses from multiple banks (if a burst spans banks) are collected and reordered (if necessary) before being presented as a single AXI4 response. Write responses are aggregated across banks.
- **Strobe handling.** Write strobes are adjusted per bank to reflect only the bytes that map to that bank.
- **Buffering and arbitration.** Internal buffers decouple the AXI4 interface from the memory interface; arbitration ensures fair access to banks if multiple requests target the same bank.
- **Reset behavior.** On reset, all buffers and request state are cleared.

## Throughput and latency

- **Latency.** Depends on the number of banks accessed and response latency.
- **Throughput.** Can be higher than a single-bank converter if banks operate in parallel; limited by the total bandwidth across all banks.

## Clock and reset domains

Single clock domain.

## Example behavior

With `MemNumBanks=4` and address bits [1:0] determining the bank, a write to address 0x1004 is routed to bank 1. A write to address 0x1000 with length=1 (two beats) might be routed as: beat 0 to bank 0 (address 0x1000), beat 1 to bank 1 (address 0x1004), operating in parallel on two banks.
