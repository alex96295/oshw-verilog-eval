Design a module called TopModule. This module converts an AXI4 slave interface into interleaved memory access across multiple banks, where consecutive data words are distributed round-robin across banks.

## Overview

TopModule is an AXI4-to-interleaved-memory converter. It takes AXI4 transactions and converts them into requests across multiple memory banks arranged in an interleaved (round-robin) fashion. With interleaving, byte 0 of the data word goes to bank 0, byte 1 to bank 1, etc., allowing parallel access to different portions of a wide data word. Alternatively, if `NumBanks` is small, consecutive addresses in a burst are interleaved across banks: address 0x0000 -> bank 0, 0x0004 -> bank 1, 0x0008 -> bank 0, etc. This maximizes bank parallelism.

## Parameters

| Parameter | Meaning |
|-----------|---------|
| `axi_req_t`, `axi_resp_t` | AXI4 struct types. |
| `AddrWidth`, `DataWidth`, `IdWidth` | Bit widths. |
| `NumBanks` | Number of interleaved memory banks. |
| `BufDepth` | Internal buffer depth. |
| `HideStrb` | Write strobe visibility. |
| `OutFifoDepth` | Output FIFO depth. |

## Interface

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clk_i` | input | - | Clock. |
| `rst_ni` | input | - | Active-low reset. |
| `slv_req_i` | input | `axi_req_t` | AXI4 request from master. |
| `slv_resp_o` | output | `axi_resp_t` | AXI4 response to master. |
| `mem_req_o[NumBanks-1:0]` | output array | struct | Memory request to each bank. |
| `mem_req_valid_o[NumBanks-1:0]` | output array | logic | Request valid for each bank. |
| `mem_req_ready_i[NumBanks-1:0]` | input array | logic | Request ready from each bank. |
| `mem_rsp_i[NumBanks-1:0]` | input array | struct | Memory response from each bank. |
| `mem_rsp_valid_i[NumBanks-1:0]` | input array | logic | Response valid from each bank. |
| `mem_rsp_ready_o[NumBanks-1:0]` | output array | logic | Response ready to each bank. |

## Behavioral requirements

- **Interleaved address mapping.** For a burst starting at address A with `NumBanks` banks, beat 0 is mapped to bank (A / (beat_size)) % NumBanks, beat 1 to bank ((A + beat_size) / beat_size) % NumBanks, etc. This distributes consecutive beats round-robin across banks.
- **Parallel requests.** Multiple banks can be accessed in parallel. If all beats of a burst target different banks, they can be requested in parallel (or nearly so).
- **Data word slicing (optional).** If `NumBanks` corresponds to the data word being sliced (e.g., `DataWidth / NumBanks` bits per bank), each bank handles a slice of the data word.
- **Response collection.** Read responses from multiple banks are collected and reassembled into the original wide data words in the correct order before being presented as AXI4 R beats.
- **Strobe computation.** Write strobes are computed per bank based on the interleaving pattern.
- **Buffering.** Internal FIFOs decouple the AXI4 side from memory side.
- **Reset behavior.** On reset, buffers and pending requests are cleared.

## Throughput and latency

- **Latency.** Depends on the number of banks accessed in parallel and memory response latency.
- **Throughput.** Can achieve higher throughput than a single-bank converter if banks are accessed in parallel.

## Clock and reset domains

Single clock domain.

## Example behavior

With `NumBanks=4` and `DataWidth=128` (4 bytes per bank), an AXI4 write with address 0x0000 and data [0xA, 0xB, 0xC, 0xD] distributes as: bank 0 <- 0xA, bank 1 <- 0xB, bank 2 <- 0xC, bank 3 <- 0xD, all four in parallel. A subsequent write to address 0x0004 distributes as: bank 0 <- next word byte 0, etc., again cycling through banks.
