Design a module called TopModule. This module is an escalation (escape) signal sender that drives differential escalation requests and monitors incoming responses over a hardened two-wire link.

## Overview

TopModule implements the transmit side of a differential escalation (esc) protocol, used to signal critical hardware faults that require immediate mitigation. It handles ping requests from the receiver, transmits escalation requests, and monitors differential response feedback. The module is optimized for hardened, low-latency critical signal paths.

## Parameters

| Parameter | Meaning | Default |
|-----------|---------|---------|
| `SkewCycles` | Number of clock cycles allowed for differential pair skew tolerance. | 1 |

## Interface

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk_i` | input | 1 | System clock. |
| `rst_ni` | input | 1 | Asynchronous active-low reset. |
| `ping_req_i` | input | 1 | Ping request from receiver: triggers a ping exchange test. |
| `ping_ok_o` | output | 1 | Ping successful: asserted when ping handshake completes. |
| `integ_fail_o` | output | 1 | Signal integrity failure: asserted when differential decoding detects errors. |
| `esc_req_i` | input | 1 | Escalation request: when high, assert escalation on the output link. |
| `esc_rx_i` | input | esc_rx_t | Differential response from receiver: contains resp_p and resp_n. |
| `esc_tx_o` | output | esc_tx_t | Differential escalation output: contains esc_p and esc_n. |

Where:
- `esc_tx_t.esc_p` / `esc_tx_t.esc_n` — differential escalation output pair.
- `esc_rx_t.resp_p` / `esc_rx_t.resp_n` — differential response feedback pair from receiver.

## Behavioral requirements

### Escalation Transmission
- When `esc_req_i` is high, the module drives the differential escalation output (esc_p high, esc_n low).
- The escalation state is held until the receiver responds or until new instructions are given.
- Escalation is the highest-priority signaling mechanism and takes precedence over normal operations.

### Ping Handshake
- When `ping_req_i` is asserted, the module initiates a ping test.
- It sends a ping signal transition on the escalation link to verify the receiver is responsive.
- Upon detecting the receiver's response, `ping_ok_o` is asserted.
- This allows continuous verification that the escalation link is functional.

### Response Decoding
- The module decodes incoming differential responses (resp_p/resp_n) from the receiver.
- Response decoding uses synchronous differential decoding with skew tolerance.
- Signal integrity on the response channel is continuously checked.

### Signal Integrity Monitoring
- If the incoming response pair violates differential encoding rules (e.g., both rails high or low), `integ_fail_o` is asserted.
- This flag latches and indicates a critical link fault.

### Timing
- Escalation transmission is combinational (as fast as logic allows) for critical-path performance.
- Response decoding includes a pipeline stage for synchronization and skew tolerance (controlled by `SkewCycles`).

### Reset
- On `rst_ni` assertion (active low), all state is reset, escalation is released, and the module re-initializes.

## Example

| Cycle | `ping_req_i` | `esc_req_i` | `esc_tx_o` | `esc_rx_i` (resp_p, resp_n) | `ping_ok_o` | `integ_fail_o` | Notes |
|-------|---|---|---|---|---|---|---|
| 0 | 0 | 0 | (0,0) quiet | (0,0) | 0 | 0 | Idle |
| 1 | 1 | 0 | ping_p high | (0,0) | 0 | 0 | Ping initiated |
| 2 | 1 | 0 | ping_n high | (1,0) resp | 0 | 0 | Receiver responds to ping |
| 3 | 0 | 0 | (0,0) quiet | (1,0) resp | 1 | 0 | Ping complete |
| 4 | 0 | 1 | esc_p high | (0,0) quiet | 1 | 0 | Escalation asserted |
| 5 | 0 | 1 | esc_p high | (1,0) resp | 1 | 0 | Receiver acknowledges escalation |
| 6 | 0 | 0 | (0,0) quiet | (0,0) quiet | 1 | 0 | Escalation released |

Actual timing depends on `SkewCycles` and clock speed; typically 1–2 cycles per state transition.
