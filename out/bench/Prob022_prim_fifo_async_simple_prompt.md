Design a module called TopModule. This module is a simplified asynchronous FIFO with dual independent clock domains, optimized for minimal area and without fill-level counters. It uses a request-acknowledge handshake for data transfer.

## Overview

TopModule is a minimal asynchronous FIFO that bridges two independent clock domains. Unlike larger FIFOs with depth counters, this simple variant uses a req-ack handshake to synchronize the transfer of a single data word across the clock boundary. It is suitable for low-throughput, low-area applications where maximum latency tolerance is high and precise fill-level information is not required.

## Parameters

| Parameter | Meaning | Default |
|-----------|---------|---------|
| `Width`   | Width of the data payload in bits. | 16 |
| `EnRstChks` | Enable reset consistency checks in formal verification. | 0 |
| `EnRzHs`  | Enable reset zero handshake for additional reset safety. | 0 |

## Interface

### Write-Clock Domain

| Port         | Direction | Width   | Description |
|-------------|-----------|---------|-------------|
| `clk_wr_i`  | input     | 1       | Write-side clock. |
| `rst_wr_ni` | input     | 1       | Write-side asynchronous reset (active low). |
| `wvalid_i`  | input     | 1       | Write valid. When high and `wready_o` is high, `wdata_i` is captured and a request is initiated across the domain boundary. |
| `wready_o`  | output    | 1       | Write ready. High when no transfer is pending; low when a word is waiting to be delivered to the read domain. |
| `wdata_i`   | input     | `Width` | Write data. Captured and held when `wvalid_i` and `wready_o` are both high. |

### Read-Clock Domain

| Port         | Direction | Width   | Description |
|-------------|-----------|---------|-------------|
| `clk_rd_i`  | input     | 1       | Read-side clock. |
| `rst_rd_ni` | input     | 1       | Read-side asynchronous reset (active low). |
| `rvalid_o`  | output    | 1       | Read valid. High when data is available to be read (has arrived from the write domain). |
| `rready_i`  | input     | 1       | Read ready. When high and `rvalid_o` is high, the data is consumed and the next transfer can begin. |
| `rdata_o`   | output    | `Width` | Read data. The payload that crossed the clock boundary, captured and held until consumed. |

## Behavioral Requirements

**Write-Side Handshake:**
- When `wvalid_i` is high and `wready_o` is high, `wdata_i` is captured into an internal register and a request is initiated.
- `wready_o` is high when no pending transfer exists (the acknowledge from the read side has been received).
- `wready_o` is low when a word is waiting to be delivered; the write side must wait until the read side acknowledges.
- The write-side can accept a new word only after the previous one is acknowledged.

**Request-Acknowledge Crossing:**
- A request signal is generated in the write domain when data is ready.
- The request is synchronized to the read domain using a req-ack synchronizer (prim_sync_reqack), which safely handles the clock domain crossing.
- The acknowledge signal is synchronized back to the write domain.
- The synchronizer ensures mutual exclusion: requests and acknowledges do not overlap metastably.

**Read-Side Handshake:**
- `rvalid_o` is high when a request has arrived from the write domain (and has been synchronized).
- Data is presented on `rdata_o` and is held stable until consumed.
- When both `rvalid_o` and `rready_i` are high (on the rising edge of `clk_rd_i`), the read side acknowledges the transfer.
- The acknowledge is sent back to the write domain via the synchronizer.
- After acknowledgment, `rvalid_o` is cleared and `wready_o` in the write domain becomes high, allowing a new transfer.

**Data Stability:**
- `rdata_o` remains stable from the moment the request arrives until the read side acknowledges completion.
- The data is held by an internal register that is only updated when a new request arrives and the previous data has been consumed.

**Reset Behavior:**
- On reset of the write domain (`rst_wr_ni` low), the write-side state is cleared: `wready_o` becomes low initially, then high after reset release.
- On reset of the read domain (`rst_rd_ni` low), the read-side state is cleared: `rvalid_o` becomes low.
- No synchronization of reset between domains is required; the req-ack synchronizer handles initialization.

**Latency and Throughput:**
- Latency from write to read is approximately 2-3 cycles in each domain, depending on the synchronizer depth and relative clock phases.
- Throughput is limited by the round-trip latency: one new write can be initiated after the acknowledge returns.
- This design is suitable for low-throughput scenarios (e.g., interrupt signaling, configuration updates) rather than high-bandwidth streaming.

## Example Timing Scenario

Assume `Width = 8`:

1. **Reset state:** `wready_o = 1`, `rvalid_o = 0`.
2. **Write cycle 1 (clk_wr_i):** `wvalid_i = 1`, `wdata_i = 0x12`. Data is captured, request is initiated. `wready_o` becomes low.
3. **Synchronization delay (2+ cycles):** Request propagates through the synchronizer.
4. **Read side (clk_rd_i):** `rvalid_o` becomes high after sync delay. `rdata_o = 0x12`.
5. **Read cycle 1 (clk_rd_i):** `rready_i = 1`. Acknowledge is initiated.
6. **Synchronization delay (2+ cycles):** Acknowledge propagates back.
7. **Write side (clk_wr_i):** `wready_o` becomes high after ack sync delay.
8. **Write cycle 2:** New data can be written.

## Formal Verification Parameters

- **`EnRstChks`:** When enabled, assertions verify that reset is correctly synchronized.
- **`EnRzHs`:** When enabled, additional checks ensure that the handshake clears properly after reset release.

These parameters are primarily for formal verification and may not affect simulation behavior.

## Typical Use Cases

- Cross-domain interrupt signaling.
- Low-frequency configuration register updates.
- Single-item data transfers that do not require high throughput.
