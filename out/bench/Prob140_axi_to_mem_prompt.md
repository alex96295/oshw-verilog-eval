Design a module called TopModule. This module converts an AXI4 slave interface into a simple memory access interface, supporting optional banking and buffering, with minimal protocol overhead.

## Overview

TopModule is an AXI4-to-memory converter. It accepts AXI4 transactions on a slave port and converts them into a simple, narrow memory interface consisting of request/grant handshaking, address, data, and write-enable signals. The converter handles burst decomposition, address calculation, and buffering. Optional memory banking allows the converter to distribute transactions across multiple independent memory banks based on address. This is a general-purpose converter suitable for connecting AXI4 masters to simple memory subsystems.

## Parameters

| Parameter | Meaning |
|-----------|---------|
| `axi_req_t`, `axi_resp_t` | AXI4 struct types. |
| `AddrWidth`, `DataWidth`, `IdWidth` | Bit widths. |
| `NumBanks` | Number of memory banks (1 for single-bank, > 1 for banking). |
| `BufDepth` | Internal buffer/FIFO depth. |
| `HideStrb` | If true, write strobes are simplified. |
| `OutFifoDepth` | Output FIFO depth for read responses. |

## Interface

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clk_i` | input | - | Clock. |
| `rst_ni` | input | - | Active-low reset. |
| `slv_req_i` | input | `axi_req_t` | AXI4 request from master. |
| `slv_resp_o` | output | `axi_resp_t` | AXI4 response to master. |
| `mem_req_o[NumBanks-1:0]` | output array | struct | Memory request per bank: address, write data, write enable, ID, etc. |
| `mem_req_valid_o[NumBanks-1:0]` | output array | logic | Request valid per bank. |
| `mem_req_ready_i[NumBanks-1:0]` | input array | logic | Request ready per bank. |
| `mem_rsp_i[NumBanks-1:0]` | input array | struct | Memory response per bank: read data, ID. |
| `mem_rsp_valid_i[NumBanks-1:0]` | input array | logic | Response valid per bank. |
| `mem_rsp_ready_o[NumBanks-1:0]` | output array | logic | Response ready per bank. |

## Behavioral requirements

- **Burst decomposition.** AXI4 bursts with length > 0 are decomposed into individual memory requests, one per beat. Address is calculated per beat using standard AXI4 burst addressing (INCR, FIXED, WRAP).
- **Banking (optional).** If `NumBanks > 1`, address bits (or other criteria) select which bank handles each request. A multi-beat burst may be distributed across banks.
- **Write data handling.** Write data from the W channel is presented with each write address request, including strobes (write enables) per bank.
- **Read data collection.** Read data responses from memory are collected and presented as AXI4 R beats, with last=1 on the final beat of a burst.
- **Write response generation.** A single B response is generated once all write data for an address transaction has been acknowledged by memory.
- **Buffering.** Internal FIFOs decouple the AXI4 interface from the memory interface, allowing pipelining and burst handling.
- **ID preservation.** Transaction IDs are preserved and routed with responses.
- **Reset behavior.** On reset, all buffers and pending requests are cleared.

## Throughput and latency

- **Latency.** Depends on bank response latency and buffer depth; typically a few cycles.
- **Throughput.** Up to one beat per cycle when both sides are ready; parallelism across banks can increase effective throughput.

## Clock and reset domains

Single clock domain.

## Example behavior

A master sends an AXI4 write: AW with ID=2, address=0x100, length=3 (4 beats), size=2 (4 bytes), burst=INCR, followed by W with [0xAAAA, 0xBBBB, 0xCCCC, 0xDDDD]. The converter decomposes into 4 memory requests at addresses 0x100, 0x104, 0x108, 0x10C with data [0xAAAA, 0xBBBB, 0xCCCC, 0xDDDD]. Once all are granted and completed, a B response with ID=2 is sent back.
