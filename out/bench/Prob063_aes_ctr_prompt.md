Design a module called TopModule. This module implements the counter-mode increment logic for AES-CTR, incrementing a 128-bit counter by 1 or 32 (for parallelism), with sparse-encoded FSM control.

## Overview

TopModule is a hardware counter-increment unit used in AES counter-mode (CTR) encryption. It maintains a 128-bit counter value split into 16-bit slices for selective update and provides handshake control for incrementing by 1 or 32 (for parallel block processing). The counter state is stored in registers, and the module presents a sparse-encoded FSM interface for fault detection.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| (implicit from aes_pkg) | SliceSizeCtr = 16 bits; NumSlicesCtr = 8 slices (128 bits total) | Derived constants. |

## Interface

| Port           | Direction | Width / Type | Description |
|----------------|-----------|--------------|-------------|
| `clk_i`        | input     | 1            | Clock. Counter updates on rising edge when an increment is requested and acknowledged. |
| `rst_ni`       | input     | 1            | Async active-low reset. Counter is zeroed on reset. |
| `inc32_i`      | input     | SP2V (2 bits) | Sparse-encoded request to increment by 32. `SP2V_HIGH` requests +32; `SP2V_LOW` requests no change. |
| `incr_i`       | input     | SP2V (2 bits) | Sparse-encoded request to increment by 1. `SP2V_HIGH` requests +1. Mutually exclusive with inc32_i. |
| `ready_o`      | output    | SP2V (2 bits) | Sparse-encoded ready signal. `SP2V_HIGH` indicates the counter is idle and ready to accept an increment request. |
| `alert_o`      | output    | 1            | Alert flag: asserted if FSM enters an error state (e.g., both inc32 and incr asserted simultaneously, or invalid SP2V encoding). |
| `ctr_i`        | input     | [7:0][15:0] | Counter input: 8 slices of 16 bits each, forming the 128-bit counter. Logically stored and updated each cycle. |
| `ctr_o`        | output    | [7:0][15:0] | Counter output: the current (or next-state) counter value, reflecting any pending increment. |
| `ctr_we_o`     | output    | SP2V [7:0]  | Write-enable for each of the 8 counter slices. Sparse-encoded; `SP2V_HIGH` on slice i indicates that slice is to be updated (incremented). |

## Timing & FSM

The module uses a sparse-encoded finite state machine with two main states:
- **CTR_IDLE (5'b01110):** Waiting for an increment request.
- **CTR_INCR (5'b11000):** Processing an increment.

Transitions occur on rising clock edges. If `inc32_i` or `incr_i` is asserted while idle, the FSM transitions to the increment state. The increment logic computes which slices to update (ripple-carry increment by 1 or 32 depending on the request). On the next cycle or immediately (depending on latency), the result is available on `ctr_o` with `ctr_we_o` selecting which slices write.

## Behavioral requirements

- **Counter semantics.** The counter is a 128-bit unsigned integer. Incrementing by 1 adds 1 to the counter; incrementing by 32 adds 32. Arithmetic wraps on overflow (modulo 2^128).

- **Slice-based increment.** To avoid updating the entire counter word on every increment, the module breaks the counter into 8 16-bit slices. When incrementing:
  - A +1 increment affects only the lowest slices that carry (starting from slice 0).
  - A +32 increment affects slices 0–1 (since 32 is within 16 bits, it may overflow into slice 1).
  - The `ctr_we_o` output is sparse-encoded, with one `SP2V_HIGH` per slice that must be updated; other slices receive `SP2V_LOW`.

- **Counter input/output.** The counter value is provided on `ctr_i` and fed back on `ctr_o`. The module does not maintain an internal register of the full counter; instead, it computes the next-state counter based on the request and updates slices. This allows the counter to be stored externally or as distributed state. If all slices receive write-enable asserts and are clocked, the counter advances.

- **Handshake.** `ready_o` is `SP2V_HIGH` in the IDLE state, signaling readiness. When `inc32_i` or `incr_i` is asserted while `ready_o` is high, the module transitions to INCR and computes the result. After one or more cycles, the module returns to IDLE with the new counter available. Requesting an increment while not ready may set `alert_o`.

- **Error detection.** Invalid sparse encodings on inc32_i, incr_i, or inconsistent FSM state transitions are flagged by setting `alert_o`. The FSM state itself is sparse-encoded to detect bit flips and assist in fault detection.

- **Combinational logic.** The increment computation is combinational. The counter value presented on `ctr_o` is the result of applying the requested increment to `ctr_i`.

## Clock domain

Single clock domain driven by `clk_i`; asynchronous reset via `rst_ni`.

## Example

Assuming counter is initially 0x00000000000000000000000000000001 (little-endian representation, so slice 0 = 0x0001, slice 1 = 0x0000, ...):

| Request | ctr_i (slices 0-1) | inc32_i | incr_i | ctr_o (slices 0-1) | ctr_we_o (slice 0, 1, others) |
|---------|-------------------|---------|--------|-------------------|-------|
| None | 0x0001, 0x0000 | LOW | LOW | 0x0001, 0x0000 | LOW, LOW, ... |
| +1 | 0x0001, 0x0000 | LOW | HIGH | 0x0002, 0x0000 | HIGH, LOW, ... |
| +32 from 0x0001, 0x0000 | 0x0001, 0x0000 | HIGH | LOW | 0x0021, 0x0000 | HIGH, LOW, ... |
| +32 from 0xFFFF, 0x0000 | 0xFFFF, 0x0000 | HIGH | LOW | 0x001F, 0x0001 | HIGH, HIGH, ... (slice 0 wraps, carry to 1) |

Notes: The counter is conceptually big-endian in AES (MSB first), but hardware may reverse byte/word order. The slice-based write-enable allows efficient pipelining in counter-mode parallelization.
