Design a module called TopModule. This module is a configurable chain of register slices inserted into an AXI4 bus. It decouples the slave and master sides with a programmable number of pipeline stages on all five AXI4 channels.

## Overview

TopModule implements an AXI4 register slice pipeline. By setting the `NoCuts` parameter, you specify how many independent register stages to insert. With `NoCuts=0`, the module is a pass-through; with `NoCuts>0`, each of the five channels (AW, W, B, AR, R) receives `NoCuts` spill registers in series, introducing `NoCuts` cycles of latency and decoupling master and slave traffic patterns. Each register stage is independently handshaked, allowing back-pressure to propagate properly.

## Parameters

| Parameter | Meaning | Notes |
|-----------|---------|-------|
| `NoCuts` | Number of register stages to insert. | 0 = no pipeline; 1+ = that many stages on each channel. |
| `aw_chan_t`, `w_chan_t`, `b_chan_t`, `ar_chan_t`, `r_chan_t` | Struct types for each AXI4 channel. | Pre-defined struct types carrying payload. |
| `axi_req_t` | Combined request type (AW, W, AR channels + valid flags). | Carries all outbound channels. |
| `axi_resp_t` | Combined response type (B, R channels + ready flags). | Carries all inbound channels. |

## Interface

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clk_i` | input | - | Clock. |
| `rst_ni` | input | - | Active-low reset. |
| `slv_req_i` | input | `axi_req_t` | AXI4 request from upstream (slave): AW/W/AR channels with valid signals. |
| `slv_resp_o` | output | `axi_resp_t` | AXI4 response to upstream: B/R channels with ready signals. |
| `mst_req_o` | output | `axi_req_t` | AXI4 request to downstream (master): same as `slv_req_i` but delayed by `NoCuts` cycles and register-sliced. |
| `mst_resp_i` | input | `axi_resp_t` | AXI4 response from downstream. |

## Behavioral requirements

- **Register pipeline.** When `NoCuts > 0`, each channel is independently register-sliced `NoCuts` times. Each stage is a full register slice with separate valid/ready handshaking. When `NoCuts = 0`, the module acts as a direct pass-through (no registers).
- **Channel independence.** The AW, W, B, AR, and R channels are pipelined independently; a stall on one channel does not directly block another, but proper AXI4 ordering rules are maintained through the valid/ready protocol.
- **Latency.** Each transaction experiences `NoCuts` cycles of latency as it traverses the pipeline.
- **Backpressure.** Ready signals propagate backward through the stages properly, allowing a downstream ready=0 to eventually cause the slave-side ready to be deasserted.
- **Reset behavior.** On reset, all internal registers are cleared; valid flags go low.

## Throughput and latency

- **Latency.** `NoCuts` clock cycles on each channel.
- **Throughput.** Maximum throughput is one transaction per cycle per channel, once the pipeline fills.

## Clock and reset domains

Single clock domain. Reset (`rst_ni`) clears internal registers.

## Example behavior

With `NoCuts=2`, a write address from the slave takes two cycles to reach the master output. During those two cycles, a new write address can be accepted every cycle by the first stage. The ready signal for the slave will be deasserted if either the first or second stage is full.
