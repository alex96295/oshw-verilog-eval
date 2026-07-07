Design a module called TopModule. This module implements an AXI4 data-width upsizer that converts
transactions from a narrower slave data width to a wider master data width. It merges narrow bursts
into fewer wider bursts and handles byte-enable reconstruction.

## Overview

TopModule sits between an AXI4 slave with a narrow data bus and an AXI4 master with a wider data bus.
When the slave sends a write or read transaction, the module buffers the address transaction (AW or AR)
and collects successive write data beats (W) or waits for read responses (R) to merge them into wider
master-side transactions. For example, two 32-bit slave beats are merged into one 64-bit master beat.
The module adjusts address and length fields to account for the wider beat size, reconstructs byte-enables
to span the master's wider data width, and correctly routes responses (merging master B responses or
splitting master R beats as needed).

## Parameters

| Parameter | Meaning |
|-----------|---------|
| `SlaveDataWidth` | Data width of the slave port, in bits. Must be ≤ MasterDataWidth. |
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
| `mst_req_o` | output | `axi_req_t` | AXI4 request to the downstream master (data width = MasterDataWidth). Transactions are merged; address and length adjusted. |
| `mst_resp_i` | input | `axi_resp_t` | AXI4 response from the downstream master. |

## Behavioral requirements

- **Write upsizing.** When the slave sends an AW transaction with a certain length (number of narrow beats),
  the module computes how many wider master beats are needed. For example, 4 beats at 32-bit become 2 beats
  at 64-bit (assuming 2:1 width ratio). The module adjusts the AW length accordingly and sends it to the
  master. The module then collects multiple narrow W beats from the slave and merges them into wider W
  beats for the master. Once a complete wide beat is assembled, it is sent downstream. The last flag is
  correctly placed: 1 only on the final wider beat of the original burst.

- **Write-data merging.** The module buffers narrow W beats and collects enough to form a wide master beat.
  For a 1:2 width ratio (32-bit slave, 64-bit master), the module collects 2 consecutive slave W beats,
  merges their data (concatenation), merges their byte-enables, and sends a single 64-bit W beat. The
  last flag from the slave beats is used to identify transaction boundaries.

- **Write-response handling.** A single slave write transaction receives a single B response on the master
  side (one B per master AW). The B response is forwarded directly to the slave with ID and status
  preserved.

- **Read upsizing.** When the slave sends an AR transaction, the module adjusts the length to account for
  the wider data width. For example, if the slave requests 4 narrow beats, the module requests 2 wide
  beats from the master. The AR address remains the same (byte address).

- **Read-response spreading.** Master R beats (wide) are received and split back into narrower beats for
  the slave. Multiple slave R beats are generated from each master R beat (e.g., one 64-bit R becomes
  two 32-bit R beats). Byte-enables and data are correctly decomposed. The last flag is placed appropriately:
  1 only on the final narrow beat of each wide master beat, and 1 on the final narrow beat of the original
  slave request.

- **Byte-enable handling.** During merging, byte-enables from multiple narrow beats are concatenated to
  form wide byte-enables. During spreading, wide byte-enables are decomposed to narrower ones. The
  relative positions must be correct (e.g., slave beat N's byte-enables occupy the correct byte positions
  in the merged wide beat).

- **Address and length consistency.** Address remains the same (byte-granularity). Length is adjusted
  downward on the master side to account for the wider beat size.

- **Backpressure.** The slave's W and AR ready signals are asserted based on the module's internal
  buffer capacity and the master's readiness. If the module is waiting to collect enough beats before
  sending to the master, W_ready may deassert until a complete wide beat is assembled.

- **Reset behavior.** On `rst_ni` assertion, all buffering and tracking state resets.

## Clock and reset domains

- Single clock domain: `clk_i` and `rst_ni`.

## Example behavior

1. **2-beat 32-bit write → 1-beat 64-bit write.** Slave sends:
   - AW: address=0x2000, length=1 (2 beats), size=2 (4 bytes/beat), INCR.
   - W: Beat 0 (32-bit data=0xDEADBEEF, strb=8'hFF), Beat 1 (32-bit data=0xCAFEBABE, strb=8'h0F, last=1).
   
   Module merges and sends to master:
   - AW: address=0x2000, length=0 (1 beat), size=3 (8 bytes/beat).
   - W: (64-bit data=0xCAFEBABEDEADBEEF, strb=16'h0FFF, last=1).
   
   Master responds with 1 B. Module forwards to slave.

2. **4-beat 32-bit read → 2-beat 64-bit read → 4-beat split.** Slave sends AR (32-bit, 4 beats).
   Module adjusts to AR (64-bit, 2 beats) for master. Master responds with 2 R beats (64-bit each).
   Module spreads into 4 R beats (32-bit each) for slave.
