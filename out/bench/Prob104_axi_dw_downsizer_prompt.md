Design a module called TopModule. This module implements an AXI4 data-width downsizer that converts
transactions from a wider slave data width to a narrower master data width. It splits wide bursts into
multiple narrower bursts and handles byte-enable reconstruction.

## Overview

TopModule sits between an AXI4 slave with a wide data bus and an AXI4 master with a narrower data bus.
When the slave sends a write or read transaction, the module splits the address transaction (AW or AR)
and associated write data (W) into multiple narrower transactions. For example, a 64-bit wide burst
is split into 32-bit wide beats. The module adjusts address and length fields to account for the
narrower beat size, reconstructs byte-enables to align with the master's smaller data width, and
correctly routes split write and read responses back to the slave (merging multiple master B responses
into a single slave B response, or splitting master R beats into multiple slave R beats as needed).

## Parameters

| Parameter | Meaning |
|-----------|---------|
| `SlaveDataWidth` | Data width of the slave port, in bits. Must be ≥ MasterDataWidth. |
| `MasterDataWidth` | Data width of the master port, in bits. |
| `aw_chan_t` | Struct type for the AXI write-address channel. |
| `w_chan_t` | Struct type for the AXI write-data channel. |
| `b_chan_t` | Struct type for the AXI write-response channel. |
| `ar_chan_t` | Struct type for the AXI read-address channel. |
| `r_chan_t` | Struct type for the AXI read-data channel. |
| `axi_req_t` | Struct type defining the complete AXI request. |
| `axi_resp_t` | Struct type defining the complete AXI response. |
| `MaxTxns` | Maximum number of in-flight write transactions tracked. |

## Interface

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clk_i` | input | logic | Clock signal. |
| `rst_ni` | input | logic | Asynchronous active-low reset. |
| `slv_req_i` | input | `axi_req_t` | AXI4 request from the upstream slave (data width = SlaveDataWidth). |
| `slv_resp_o` | output | `axi_resp_t` | AXI4 response to the upstream slave. |
| `mst_req_o` | output | `axi_req_t` | AXI4 request to the downstream master (data width = MasterDataWidth). Transactions are split; address and length adjusted. |
| `mst_resp_i` | input | `axi_resp_t` | AXI4 response from the downstream master. |

## Behavioral requirements

- **Write downsizing.** When the slave sends an AW transaction with a certain length (number of beats at
  the slave's width), the module computes how many beats are needed at the master's (narrower) width.
  Each slave beat corresponds to (`SlaveDataWidth` / `MasterDataWidth`) master beats. The module generates
  multiple AW transactions on the master side, each with appropriately reduced length and updated addresses.
  Example: 4-beat AW at 64-bit becomes 8-beat AW at 32-bit (each 64-bit beat splits into 2 32-bit beats).

- **Write-data splitting.** Each W beat from the slave carries `SlaveDataWidth` bits of data and
  `SlaveDataWidth/8` byte-enable bits. The module splits this into multiple narrower W beats, each
  carrying `MasterDataWidth` bits. Byte-enables are preserved per output beat. The last flag is
  correctly placed: 1 only on the last narrower beat within each wide slave beat, and 1 on the final
  beat of the original burst.

- **Write-response merging.** For each slave write (identified by ID), the module expects multiple B
  responses from the master (one per split transaction). The module collects them and merges into a
  single B response to the slave. The response status is typically the worst (SLVERR if any split failed).

- **Read downsizing.** When the slave sends an AR transaction, the module computes the required number of
  narrower master beats and generates appropriate AR transactions. Addresses are incremented per beat
  according to AXI size/burst rules.

- **Read-response spreading.** Master R beats (narrow) are collected and spread back to the slave as
  wider beats. Multiple narrow master beats are combined into wider slave beats, with data concatenation
  and byte-enable reconstruction. The response status and last flag are correctly derived.

- **Byte-enable handling.** The module carefully manages byte-enables during splitting (mapping slave
  byte-enables to correct positions in split master beats) and recombination (reconstructing wide
  byte-enables from narrower splits).

- **Address calculation.** Addresses are adjusted when issuing multiple split transactions to the master.
  For INCR bursts, each subsequent transaction starts at (original_address + offset), where offset
  accounts for the cumulative narrower beats sent.

- **Backpressure.** The slave's ready signals reflect the master's readiness and the capacity of the
  response collection state (if full, ready deasserts).

- **Reset behavior.** On `rst_ni` assertion, all tracking and buffering state resets.

## Clock and reset domains

- Single clock domain: `clk_i` and `rst_ni`.

## Example behavior

1. **4-beat 64-bit write → 8 32-bit beats.** Slave sends:
   - AW: address=0x1000, length=3 (4 beats), size=3 (8 bytes/beat), INCR.
   - W: Beat 0 (64-bit data, 8'hFF), ..., Beat 3 (64-bit data, 8'hAA).
   
   Module sends to master:
   - AW: address=0x1000, length=1 (2 beats), size=2 (4 bytes/beat). [and later, second AW at 0x1008, etc.]
   - W: Beat 0 (32-bit data from upper half of slave beat 0), Beat 1 (32-bit data from lower half of slave beat 0), ...
   
   Master responds with 2 B responses (one per master AW). Module merges into 1 B to slave.

2. **2-beat 32-bit read.** Slave sends AR (32-bit, 2 beats). Master responds with 2 R beats.
   These are repacked and delivered to the slave (no widening needed; this would be a downsizer with equal widths,
   or more commonly, downsizer is used for writes primarily).
