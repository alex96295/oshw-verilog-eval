Design a module called TopModule. This module implements a full 1-to-N AXI4 demultiplexer with
ID remapping and in-flight transaction tracking. It routes a single upstream AXI4 slave port to one
of N downstream AXI4 master ports based on target address ranges or explicit select signals, and
handles ID conflicts by transparently remapping transaction IDs.

## Overview

TopModule accepts an AXI4 request from an upstream slave and routes transactions to one of N downstream
master ports. Unlike the simple demux, this implementation handles address decoding or select signals
that can change between transactions, and it ensures that IDs do not conflict across multiple masters
by transparently remapping them. Each transaction (identified by original slave ID) is tracked with a
record that stores the original ID and the target master port. When a response (B or R) arrives from a
master, the module uses this record to look up the original ID and remap it back before sending the
response to the slave. This allows the slave to see stable, non-conflicting IDs even if transactions
are interleaved across different masters.

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
| `AxiIdWidth` | Width of the AXI ID field. |
| `NoMstPorts` | Number of downstream master ports (N). Typical values: 2–16. |
| `MaxTxns` | Maximum number of in-flight transactions tracked. |

## Interface

| Port | Direction | Type | Description |
|------|-----------|------|-------------|
| `clk_i` | input | logic | Clock signal. |
| `rst_ni` | input | logic | Asynchronous active-low reset. |
| `slv_req_i` | input | `axi_req_t` | AXI4 request from the upstream slave. |
| `slv_resp_o` | output | `axi_resp_t` | AXI4 response to the upstream slave. |
| `mst_select_i` | input | logic [log2(NoMstPorts)-1:0] | Index of the target master port for the current request. Can change per transaction. |
| `mst_req_o` | output | `axi_req_t [NoMstPorts-1:0]` | Array of AXI4 requests to downstream masters. Each master receives its own ID space (remapped from the original slave IDs). |
| `mst_resp_i` | input | `axi_resp_t [NoMstPorts-1:0]` | Array of AXI4 responses from downstream masters (with remapped IDs). |

## Behavioral requirements

- **ID remapping on write.** When the slave sends an AW transaction:
  - The module allocates a local (master-side) ID from the target master's ID space.
  - The original slave ID is recorded in a transaction tracking table, along with the target master port.
  - The AW is forwarded to the target master with the remapped (local) ID.
  - This allows multiple slaves or different slave transactions to reuse the same master ID space.

- **ID remapping on read.** Similarly, when the slave sends an AR transaction:
  - A local ID is allocated from the target master's space.
  - The original slave ID and master port are recorded.
  - AR is forwarded to the master with the remapped ID.

- **Response ID remapping.** When a write response (B) arrives from a master:
  - The module looks up the transaction record using the (master_port, local_id) pair.
  - The response is remapped back to the original slave ID.
  - The remapped B response is sent to the slave.
  - The transaction record is deallocated.

- **Read response ID remapping.** When a read response (R) arrives from a master:
  - The transaction record is looked up using (master_port, local_id).
  - The response is remapped back to the original slave ID.
  - The remapped R response is sent to the slave.
  - If this is the last beat (R.last=1), the record is deallocated.

- **Write-data and read-data pass-through.** W channel data is forwarded to the target master as is.
  R channel data from the master is forwarded to the slave as is.

- **Transaction table tracking.** The module maintains a table (typically a CAM or queue) with entries
  for each in-flight transaction. Maximum capacity is `MaxTxns`. If the table is full, the slave's
  AW/AR ready signals are deasserted, preventing new transactions from entering.

- **Backpressure.** The slave's ready signals reflect the availability of:
  - The target master's readiness (for routing).
  - The transaction table capacity (for recording new transactions).

- **Reset behavior.** On `rst_ni` assertion, all tracking tables and output valid signals reset.

## Clock and reset domains

- Single clock domain: `clk_i` and `rst_ni`.

## Example behavior

1. **Dual-transaction interleaving.** Slave sends Transaction A (ID=5) to master 0, then Transaction B (ID=5)
   to master 1 (select signal changes).
   - Transaction A: Allocated local ID=0 for master 0. Recorded as {orig_id=5, mst_port=0}.
     Sent to master 0 with ID=0.
   - Transaction B: Allocated local ID=0 for master 1 (independent ID space). Recorded as {orig_id=5, mst_port=1}.
     Sent to master 1 with ID=0.
   - Master 0 responds with B(ID=0). Module remaps to B(ID=5) and sends to slave.
   - Master 1 responds with B(ID=0). Module remaps to B(ID=5) and sends to slave.
   - Slave sees two responses with the same ID, both correctly attributed to their respective transactions.

2. **Transaction table full.** Multiple in-flight transactions fill the tracking table.
   - Slave attempts to send AW. Table is full.
   - `slv_resp_o.aw_ready` deasserts.
   - Slave waits until a response completes and the record is deallocated.
