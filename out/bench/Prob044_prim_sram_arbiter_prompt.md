Design a module called TopModule. This module implements a multi-port arbitration frontend for an SRAM, selecting among N requesters and multiplexing their transactions to a single SRAM port.

## Overview

TopModule is an N-to-1 SRAM arbiter that prioritizes and arbitrates among N independent requesters, each issuing read or write requests to the same SRAM. It forwards the highest-priority granted request to the SRAM interface and routes responses back to the requesting port. The module handles address, write data, and write-enable selection, and provides per-requester read response handling.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `N` | Number of requesters. | ≥ 1; typically 2–8. |
| `SramDw` | SRAM data width, in bits. | ≥ 1; typically 32 or 64. |
| `SramAw` | SRAM address width, in bits. | ≥ 1; typically 12–20. |
| `ArbiterImpl` | Arbitration implementation style. | String; e.g., "PPC" (priority/pseudo-random), "RR" (round-robin). |
| `EnMask` | Enable per-word write masks. | Bit; if 1, support `req_wmask_i` per request; if 0, all writes use full width. |

## Interface

TopModule operates in a single clock domain with an active-low asynchronous reset. All SRAM transactions are synchronous.

### Requester Interface (N ports, indexed 0 to N-1)

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `req_i[i]` | input | 1 | Request from requester i: asserted to issue a read or write. |
| `req_addr_i[i]` | input | `SramAw` | Address for requester i's transaction. |
| `req_write_i[i]` | input | 1 | Write flag for requester i: 1 = write, 0 = read. |
| `req_wdata_i[i]` | input | `SramDw` | Write data from requester i. |
| `req_wmask_i[i]` | input | `SramDw` | Write mask from requester i (per-byte or per-bit); only used if `EnMask = 1`. |
| `gnt_o[i]` | output | 1 | Grant to requester i: asserted if this requester's request is selected and forwarded to SRAM. |
| `rsp_rvalid_o[i]` | output | 1 | Read valid: strobed high when a read response is available for requester i. |
| `rsp_rdata_o[i]` | output | `SramDw` | Read data response for requester i. |
| `rsp_error_o[i]` | output | 2 | Error status for requester i's response: typically `[0]` = correctable error (ECC), `[1]` = uncorrectable error. |

### SRAM Interface

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk_i` | input | 1 | System clock. |
| `rst_ni` | input | 1 | Active-low asynchronous reset. |
| `sram_req_o` | output | 1 | Request to SRAM: strobed when a transaction is forwarded. |
| `sram_addr_o` | output | `SramAw` | Address multiplexed from winning requester. |
| `sram_write_o` | output | 1 | Write flag from winning requester. |
| `sram_wdata_o` | output | `SramDw` | Write data from winning requester. |
| `sram_wmask_o` | output | `SramDw` | Write mask from winning requester (or all 1's if `EnMask = 0`). |
| `sram_rvalid_i` | input | 1 | Read valid from SRAM: strobed when read data is ready. |
| `sram_rdata_i` | input | `SramDw` | Read data from SRAM. |
| `sram_rerror_i` | input | 2 | Read error from SRAM: error status bits (e.g., ECC flags). |

## Behavioral requirements

- **Arbitration.** At each cycle, the arbiter selects at most one requester whose `req_i` is asserted. The selection follows the configured arbitration policy (`ArbiterImpl`):
  - **PPC (priority):** Highest-index requester has highest priority.
  - **RR (round-robin):** Priority rotates in a round-robin fashion to ensure fairness.
  - Only the selected requester receives a grant (`gnt_o[winner] = 1`); others see `gnt_o = 0`.

- **Request multiplexing.** The grant signal identifies which requester's signals are forwarded to the SRAM:
  - `sram_addr_o` ← `req_addr_i[winner]`
  - `sram_write_o` ← `req_write_i[winner]`
  - `sram_wdata_o` ← `req_wdata_i[winner]`
  - `sram_wmask_o` ← `req_wmask_i[winner]` (if `EnMask = 1`), else all 1's.

- **Read response routing.** The SRAM returns read data and error status asynchronously (or with a latency independent of the arbiter). The arbiter tracks which requester issued the granted read, and routes the response to that requester:
  - When `sram_rvalid_i` pulses high, `rsp_rvalid_o[requester_id]` pulses.
  - `rsp_rdata_o[requester_id]` and `rsp_error_o[requester_id]` carry the response data and errors.
  - Other requesters see `rsp_rvalid_o = 0`.

- **Write acknowledgment.** Writes typically do not return data; `rsp_rvalid_o` remains low for write transactions. Error reporting for writes may use a separate mechanism or be reported asynchronously.

- **Request stalling.** If multiple requesters assert `req_i`, only the highest-priority (or next in round-robin order) receives a grant. Other requesters must hold their request until the arbiter cycles to them.

- **No write combining.** Each granted transaction is forwarded independently; the arbiter does not combine requests from different sources.

- **Reset behavior.** On reset (`rst_ni` low), all grant signals are deasserted, and response signals are cleared. Internal request tracking is reset.

- **Write mask handling.** If `EnMask = 0`, the write mask is forced to all 1's (full width writes). If `EnMask = 1`, the per-requester mask is forwarded to SRAM.

## Clock and Reset Domains

- Single synchronous clock domain (`clk_i`).
- Asynchronous active-low reset (`rst_ni`).

## Example: N = 2, SramDw = 32

| Cycle | `req_i[0]` | `req_addr_i[0]` | `req_write_i[0]` | `req_i[1]` | `req_addr_i[1]` | `gnt_o[0]` | `gnt_o[1]` | `sram_addr_o` | `sram_write_o` |
|-------|----------|---------------|----------------|-----------|--------------|-----------|-----------|-----------|-----------| 
| 0 | 0 | — | — | 0 | — | 0 | 0 | × | × |
| 1 | 1 | `12'h100` | 1 | 0 | — | 1 | 0 | `12'h100` | 1 |
| 2 | 1 | `12'h101` | 0 | 1 | `12'h200` | 0 | 1 | `12'h200` | 0 |
| 3 | 1 | `12'h102` | 0 | 0 | — | 1 | 0 | `12'h102` | 0 |

In cycle 1, requester 0's write request is granted. In cycle 2, with both requesting, requester 1 (higher priority in PPC) wins and its read is granted. In cycle 3, requester 0 is granted its turn.
