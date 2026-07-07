Design a module called TopModule. This module implements a complete dual-clock AXI4 clock-domain
crossing bridge. It contains both the source-clock and destination-clock halves integrated together,
providing a transparent, buffered path for AXI4 transactions between two independent clock domains.

## Overview

TopModule is a full AXI4 CDC bridge that internally integrates source and destination CDC FIFOs. It
accepts AXI4 requests and responses on the source-clock side and presents them on the destination-clock
side, with per-channel asynchronous FIFOs (AW, W, B, AR, R) safely crossing the clock domain boundary.
The module manages Gray-code pointer synchronization and backpressure independently for each channel,
allowing requests and responses to flow asynchronously between the two clock domains. Neither clock
domain can observe the other's state directly; synchronization is strictly through the FIFO pointers.

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
| `LogDepth` | Log base 2 of the FIFO depth per channel. Typical values: 1 to 4. |
| `SyncStages` | Number of flip-flop stages for Gray-code pointer synchronization. Typical value: 2. |

## Interface

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `src_clk_i` | input | logic | Source clock. All input signals on `src_req_i` and `src_resp_o.*.ready` are synchronous to this clock. |
| `src_rst_ni` | input | logic | Asynchronous active-low reset for the source clock domain. |
| `src_req_i` | input | `axi_req_t` | AXI4 request from the source-side upstream slave, carrying AW, W, and AR channels. |
| `src_resp_o` | output | `axi_resp_t` | AXI4 response to the source-side upstream slave, carrying valid signals for B and R channels when data is available from the destination side. |
| `dst_clk_i` | input | logic | Destination clock. All outputs on `dst_req_o` and inputs on `dst_resp_i.*.ready` are synchronous to this clock. |
| `dst_rst_ni` | input | logic | Asynchronous active-low reset for the destination clock domain. |
| `dst_req_o` | output | `axi_req_t` | AXI4 request presented to the destination-side downstream master, carrying AW, W, and AR channels. |
| `dst_resp_i` | input | `axi_resp_t` | AXI4 response from the destination-side downstream master, carrying B and R channels. |

## Behavioral requirements

- **Dual-clock independence.** Source and destination clocks are independent; no synchronous
  logic operates across both clocks. Synchronization is achieved through asynchronous FIFO pointers
  and Gray-code flip-flop chains.

- **Per-channel CDC FIFOs.** The module maintains five independent asynchronous FIFOs:
  - **AW FIFO** (src → dst): Write-address transactions.
  - **W FIFO** (src → dst): Write-data transactions.
  - **B FIFO** (dst → src): Write-response transactions.
  - **AR FIFO** (src → dst): Read-address transactions.
  - **R FIFO** (dst → src): Read-data transactions.
  
  Each FIFO has depth 2^LogDepth and operates independently.

- **Backpressure on write side.** Source-side ready signals (`src_resp_o.aw_ready`, `src_resp_o.w_ready`,
  `src_resp_o.ar_ready`) are asserted only when the corresponding FIFO has space. If any FIFO is full,
  its ready signal deasserts, preventing new transactions from entering.

- **Data presentation on read side.** Destination-side valid signals (`dst_req_o.aw_valid`, `dst_req_o.w_valid`,
  `dst_req_o.ar_valid`) are asserted when the corresponding FIFO contains data (synchronized write pointer
  differs from read pointer). The destination master can accept or reject data via its ready signals.

- **Response forwarding.** Write and read responses (B and R channels) arriving from the destination
  master are buffered in their respective FIFOs and presented to the source-side slave. The slave
  accepts or rejects them via its ready signals.

- **Gray-code synchronization.** Write pointers are Gray-encoded in their native clock domain, then
  synchronized via SyncStages flip-flop stages to the opposite clock domain. Similarly for read pointers.
  This ensures metastability-safe synchronization regardless of the relative clock frequencies.

- **Reset behavior.** Each clock domain has its own independent reset signal. On assertion of either
  `src_rst_ni` or `dst_rst_ni`, the corresponding side (including its FIFOs) resets. After reset, the
  module is ready to accept new transactions.

- **Throughput.** In the absence of backpressure, each channel can transfer one transaction per clock
  cycle (in its respective domain), limited only by FIFO depth (i.e., burst throughput is limited by
  FIFO depth; after LogDepth transactions, backpressure applies if not consumed).

## Clock domains

- **Source domain** (`src_clk_i`, `src_rst_ni`): All `src_*` signals.
- **Destination domain** (`dst_clk_i`, `dst_rst_ni`): All `dst_*` signals.

## Example behavior

1. **Single-beat write in one source clock cycle.** Source slave sends AW, W with valid=1; both
   FIFOs have space.
   - Both transactions are written into their respective FIFOs.
   - On the destination clock, after SyncStages delays, AW_valid and W_valid assert.
   - Destination master accepts both; FIFOs advance.
   - Response (B) is written into B FIFO on destination clock, synchronized back to source.
   - Source slave eventually sees B response on `src_resp_o.b_valid`.

2. **Backpressure from destination.** Destination master is busy; `dst_resp_i.*.ready` stays low.
   - `dst_req_o.*.valid` remains asserted (FIFO not empty).
   - Source FIFOs do not advance; write pointers stall.
   - If source continues sending, FIFOs fill. Once full, `src_resp_o.*.ready` deasserts.

3. **Independent response (read) path.** Destination sends AR; eventually master returns R.
   - AR enters AR FIFO, synchronized to destination, presented as AR_valid.
   - Master accepts AR and later returns R data.
   - R enters R FIFO, synchronized back to source clock.
   - Source slave is notified via `src_resp_o.r_valid`.
