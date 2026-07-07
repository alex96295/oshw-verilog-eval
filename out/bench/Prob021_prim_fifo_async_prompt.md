Design a module called TopModule. This module is an asynchronous FIFO with dual independent clock domains, a configurable depth, and gray-coded pointer crossing for safe clock domain transitions.

## Overview

TopModule is a standard asynchronous FIFO that bridges two independent clock domains (write clock and read clock) with no frequency or phase relationship required. Write and read pointers are maintained in their respective clock domains and crossed to the opposite domain using gray-coded 2-stage synchronizers. The FIFO supports variable payload widths and data depths that are powers of 2, with optional fill-level counters in both domains.

## Parameters

| Parameter | Meaning | Default |
|-----------|---------|---------|
| `Width`   | Width of the data payload in bits. | 16 |
| `Depth`   | Capacity of the FIFO, in words (must be a power of 2). | 4 |
| `OutputZeroIfEmpty` | When 1, the read data output is zeroed if the FIFO is empty (optional for power reduction). | 0 |
| `OutputZeroIfInvalid` | Reserved for future use; currently unused. | 0 |

## Interface

### Write-Clock Domain

| Port        | Direction | Width            | Description |
|------------|-----------|------------------|-------------|
| `clk_wr_i` | input     | 1                | Write-side clock. |
| `rst_wr_ni` | input     | 1                | Write-side asynchronous reset (active low). Initializes write pointer and read pointer sync register to zero. |
| `wvalid_i` | input     | 1                | Input valid signal. When high and `wready_o` is high, `wdata_i` is written into the FIFO. |
| `wready_o` | output    | 1                | Write ready signal. High when the FIFO is not full (has at least one empty slot). |
| `wdata_i`  | input     | `Width`          | Write data. Captured when both `wvalid_i` and `wready_o` are high. |
| `wdepth_o` | output    | `DepthW`         | Write-side fill depth (approximate, due to clock domain crossing latency). Shows how many words are in the FIFO from the write domain's perspective. |

### Read-Clock Domain

| Port        | Direction | Width            | Description |
|------------|-----------|------------------|-------------|
| `clk_rd_i` | input     | 1                | Read-side clock. |
| `rst_rd_ni` | input     | 1                | Read-side asynchronous reset (active low). Initializes read pointer and write pointer sync register to zero. |
| `rvalid_o` | output    | 1                | Output valid signal. High when the FIFO contains at least one word available to read. |
| `rready_i` | input     | 1                | Read ready signal. When high and `rvalid_o` is high, the FIFO removes the current word and `rdata_o` updates to the next word. |
| `rdata_o`  | output    | `Width`          | Read data. Combinational output of the storage array indexed by the read pointer; updates immediately after a read. |
| `rdepth_o` | output    | `DepthW`         | Read-side fill depth (approximate). Shows how many words are in the FIFO from the read domain's perspective. |

## Behavioral Requirements

**Dual Clock Domains:**
- The write domain (clock `clk_wr_i`, reset `rst_wr_ni`) and read domain (clock `clk_rd_i`, reset `rst_rd_ni`) are independent and may operate at different frequencies, with no required phase alignment.
- Write pointers and associated data are maintained and updated entirely within the write domain.
- Read pointers and storage access are maintained entirely within the read domain.
- Synchronization between domains is achieved via gray-coded pointer crossing with 2-stage synchronizers.

**Write Port Behavior:**
- Data is written when both `wvalid_i` and `wready_o` are high, on the rising edge of `clk_wr_i`.
- `wready_o` is high when the write pointer does not equal the (synchronized, gray-decoded) read pointer with the MSB flipped—indicating the FIFO is not full.
- The write pointer increments on each successful write.
- `wdepth_o` provides the number of words currently in the FIFO as seen from the write clock domain, accounting for the latency of the read pointer synchronizer (typically 2 cycles).

**Read Port Behavior:**
- `rvalid_o` is high when the read pointer does not equal the synchronized write pointer, indicating at least one word is available.
- Data at `rdata_o` is combinational, directly indexed by the read pointer; it is available immediately.
- When both `rvalid_o` and `rready_i` are high (on the rising edge of `clk_rd_i`), the FIFO removes the word: the read pointer increments and `rdata_o` combinationally reflects the next word.
- `rdepth_o` provides the number of words currently in the FIFO as seen from the read clock domain.

**Gray Code Crossing:**
- Write and read pointers are stored in binary form in their respective clock domains but are converted to gray code before synchronization.
- The 2-stage synchronizer (prim_flop_2sync) safely handles the pointer crossing, ensuring metastability is resolved within 2 cycles.
- Gray code property: only one bit changes per increment, reducing metastability exposure.

**Fill Level Counters:**
- `wdepth_o` is calculated in the write domain as the difference between the write pointer and the synchronized read pointer (accounting for the MSB wrap-around).
- `rdepth_o` is calculated in the read domain as the difference between the synchronized write pointer and the read pointer.
- Due to clock domain crossing latency, these values are approximate; they may lag the true fill level by up to a few cycles.

**Reset Behavior:**
- Each domain resets independently. When `rst_wr_ni` is released, the write-side state initializes (pointers to zero).
- When `rst_rd_ni` is released, the read-side state initializes (pointers to zero).
- No reset synchronization between domains is required; each domain resets its synchronized copies of the opposite domain's pointers.

**Depth Calculation:**
- `DepthW = $clog2(Depth + 1)` bits are required to represent fill levels from 0 to Depth.
- The pointer width is `$clog2(Depth) + 1` bits (the extra bit is the wrap-around indicator used to distinguish full from empty).

## Example Timing Scenario

Assume `Width = 8`, `Depth = 4`:

1. **Reset:** `wdepth_o = 0`, `rdepth_o = 0`, `wready_o = 1`, `rvalid_o = 0`.
2. **Write 1 word (clk_wr_i):** `wvalid_i = 1`, `wdata_i = 0x12`, write succeeds. `wdepth_o` becomes 1 (but may lag).
3. **Write 2 more words:** 3 words are in the FIFO. `wready_o` remains high (not full).
4. **Read 1 word (clk_rd_i after sync delay):** `rvalid_o` becomes high (delayed by 2 cycles). `rready_i = 1`, first word exits. `rdata_o` updates to the second word.
5. **Continue:** Fill levels in each domain converge to approximately match the actual FIFO occupancy.

## Metastability and Safety

- Gray-coded pointers ensure only one bit toggles per transition, minimizing metastability risk.
- The 2-stage synchronizer (flop, flop) resolves metastability within ~2 destination clock cycles.
- After synchronization, the gray-decoded pointer in the destination domain is stable for comparison.

## Storage

- The FIFO uses a standard dual-port RAM or a set of registers (depending on Depth) to store the payload data.
- Write happens synchronously to `clk_wr_i`; read is combinational from the storage array.
