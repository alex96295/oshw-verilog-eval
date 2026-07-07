Design a module called TopModule. This module is a fixed-priority arbiter that grants exclusive access to one of N requesters based on static priority ordering.

## Overview

TopModule arbitrates between N independent requesters, each submitting a request and providing an optional data payload. The arbiter uses a fixed priority scheme: request[0] has the highest priority, request[1] the next, and so on. On each cycle, only one requester may be granted (if any request is present). The arbiter passes through the data associated with the granted requester.

## Parameters

| Parameter | Meaning | Default |
|-----------|---------|---------|
| `N` | Number of requesters. | 8 |
| `DW` | Width of the data payload per requester, in bits. | 32 |
| `EnDataPort` | When 1, enable data payload passthrough; when 0, data_o is undriven. | 1 |
| `IdxW` | Width of the index output (computed as ceil(log2(N))). | — |

## Interface

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk_i` | input | 1 | System clock. |
| `rst_ni` | input | 1 | Asynchronous active-low reset. |
| `req_i` | input | N | Request vector: bit i is high when requester i is requesting access. |
| `data_i` | input | DW×N | Data payload array: data_i[i] is the data from requester i. |
| `gnt_o` | output | N | Grant vector: bit i is high when requester i is granted. Only one bit may be high per cycle. |
| `idx_o` | output | IdxW | Index of the granted requester (0 to N-1); only valid when valid_o is high. |
| `valid_o` | output | 1 | High when at least one requester has been granted (when req_i != 0). |
| `data_o` | output | DW | Data from the granted requester; valid when valid_o is high. |
| `ready_i` | input | 1 | Ready signal: when high, the arbiter may grant and transfer the current request. |

## Behavioral requirements

### Priority Arbitration
- When `ready_i` is high and one or more `req_i` bits are set, the arbiter grants the lowest-indexed requester with a request.
- For example, if req_i = 5'b01100, the arbiter grants requester[2] (index 2) because bit[2] is the lowest set bit.
- Only one `gnt_o` bit may be high per cycle.

### Data Passthrough
- When `EnDataPort = 1`, the data from the granted requester (data_i[granted_index]) is driven onto `data_o`.
- When `EnDataPort = 0`, `data_o` is not used.

### Combinational Arbitration
- The arbitration is purely combinational: `valid_o`, `gnt_o`, `idx_o`, and `data_o` respond immediately to changes in `req_i` and `ready_i`.
- `valid_o` is high whenever `req_i != 0` (at least one request is pending), independent of `ready_i`.
- Grant outputs (`gnt_o`) are high only when `ready_i` is also high.

### Ready Handshake
- When `ready_i` is low, no grant is issued (all `gnt_o` bits remain low), even if requests are present.
- When `ready_i` is high, a grant is issued for the highest-priority pending request.
- This implements a valid/ready handshake on the output side.

### Edge Cases
- **No requests.** When `req_i = 0`, `valid_o` is low, `gnt_o` is all zeros, and `data_o` is undefined.
- **N = 1 (single requester).** If only one requester is present, `gnt_o[0]` directly mirrors `valid_o & ready_i`, and `idx_o` is always 0.

## Example

With `N = 4`, `DW = 8`:

| Cycle | `req_i` | `data_i[0]` | `data_i[1]` | `data_i[2]` | `data_i[3]` | `ready_i` | `valid_o` | `gnt_o` | `idx_o` | `data_o` | Notes |
|-------|---------|---|---|---|---|---|---|---|---|---|---|
| 0 | 4'b0000 | — | — | — | — | 1 | 0 | 0 | — | — | No requests |
| 1 | 4'b1100 | — | — | 0x55 | 0x66 | 1 | 1 | 0100 | 2 | 0x55 | Requests from [3:2]; [2] highest priority |
| 2 | 4'b1101 | 0x11 | — | 0x55 | 0x66 | 1 | 1 | 0001 | 0 | 0x11 | Requests from [3,2,0]; [0] highest priority |
| 3 | 4'b1111 | 0x11 | 0x22 | 0x55 | 0x66 | 0 | 1 | 0000 | — | — | All request, but ready_i=0, no grant |
| 4 | 4'b1111 | 0x11 | 0x22 | 0x55 | 0x66 | 1 | 1 | 0001 | 0 | 0x11 | ready_i=1, [0] granted |

The fixed-priority scheme ensures deterministic arbitration with no starvation prevention (lower-priority requesters may starve if higher-priority ones continually request).
