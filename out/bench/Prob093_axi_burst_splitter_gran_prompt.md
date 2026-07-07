Design a module called TopModule. This module implements a granularity-based AXI4 burst splitter: it
accepts multi-beat write bursts and splits them into smaller bursts, each containing at most a
configured number of beats, preserving all protocol semantics and guaranteeing atomicity within each
original beat-aligned granule.

## Overview

TopModule operates on the full AXI4 write path (AW and W channels) and passes read transactions through
unchanged. It sits between an upstream slave and a downstream master. Each write burst arriving on the
AW channel is examined for its length (number of beats). If the burst exceeds a configured maximum
granule size, TopModule splits it into multiple smaller bursts, each containing up to the granule-size
number of beats. Each split burst is a complete, independent AXI transaction with its own write-address
and write-data, but all share the same ID (and other AXI metadata from the original burst). Write responses
from the master are collected and merged back into a single response per original slave request, preserving
the slave-side interface contract.

## Parameters

| Parameter | Meaning |
|-----------|---------|
| `AxiIdWidth` | Width of the AXI ID field. |
| `AxiMaxWriteTxns` | Maximum number of concurrent write transactions permitted downstream. |
| `aw_chan_t` | Struct type for the AXI write-address channel. Contains address, burst type, length, size, and ID. |
| `w_chan_t` | Struct type for the AXI write-data channel. Contains data and last flag. |
| `b_chan_t` | Struct type for the AXI write-response channel. Contains response status and ID. |
| `ar_chan_t` | Struct type for the AXI read-address channel. |
| `r_chan_t` | Struct type for the AXI read-data channel. |
| `axi_req_t` | Struct type defining the complete AXI request. |
| `axi_resp_t` | Struct type defining the complete AXI response. |
| `MaxBytesPerBeat` | The maximum number of bytes (8-bit units) per beat. Used in conjunction with write size to bound the number of beats per split. |

## Interface

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clk_i` | input | logic | Clock signal. |
| `rst_ni` | input | logic | Asynchronous active-low reset. |
| `slv_req_i` | input | `axi_req_t` | AXI4 request from upstream slave. |
| `slv_resp_o` | output | `axi_resp_t` | AXI4 response to upstream slave. |
| `mst_req_o` | output | `axi_req_t` | AXI4 request to downstream master. |
| `mst_resp_i` | input | `axi_resp_t` | AXI4 response from downstream master. |

## Behavioral requirements

- **Burst splitting logic.** When a write-address transaction arrives with length > (MaxBytesPerBeat / (1 << size)),
  the module splits it into N separate bursts, each with length ≤ the limit. The split bursts maintain
  the original address, incrementing appropriately for each subsequent burst according to AXI size/length rules.
  All split bursts carry the same ID and metadata as the original.
- **Write-data correspondence.** The W channel is reassigned such that each beat arriving on the slave
  port is routed to the correct downstream master port based on which split transaction it belongs to.
  The `last` flag is updated per split burst: set to 1 only on the final beat of each split, and 1 on
  the final beat of the original burst.
- **Read pass-through.** AR and R channels are passed through with no modification.
- **Response collection and merging.** Write responses (B channel) from the master are tracked by ID.
  For each original slave write-address request that was split into multiple downstream requests,
  responses are collected until all splits have responded. A single B response is then sent back to
  the slave with the original request's ID; the response status is the "worst" (e.g., SLVERR if any
  split returned an error).
- **Backpressure.** The module respects valid/ready handshakes on all channels. If the master cannot
  accept a new split transaction, the corresponding beat(s) on the slave W channel are held. The slave
  never receives a write-data `ready` signal unless the corresponding split transaction can proceed.
- **Burst type preservation.** INCR bursts remain INCR; WRAP and FIXED bursts are handled according to
  AXI spec (address does not increment for FIXED; WRAP bursts increment with wraparound).
- **Reset behavior.** On `rst_ni` assertion, all state machines and queues reset.

## Clock and reset domains

- Single clock domain: `clk_i` and `rst_ni`.

## Example behavior

Assume `MaxBytesPerBeat = 8` (64-bit words) and granule limit is 4 beats.

1. **8-beat write burst (size=3, length=7).** Incoming burst has 8 beats of 64-bit data.
   - Module splits into two downstream transactions: first with length=3 (4 beats), second with length=3 (4 beats).
   - Slave sees a single B response once both downstream B responses have arrived (or merged if on same cycle).

2. **4-beat write (within limit).** Incoming burst with length ≤ 3 passes through unchanged.
