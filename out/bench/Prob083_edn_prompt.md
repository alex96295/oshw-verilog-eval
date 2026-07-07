Design a module called TopModule. This module is an EDN (Entropy Distribution Network): it
distributes conditioned entropy from a CSRNG (cryptographically-secure random number generator)
to multiple endpoints via a request-acknowledge interface with configurable feature gating.

## Overview

TopModule is an entropy distribution hub that conditions and delivers random bits to multiple
downstream consumers (endpoints) in a SoC. It interfaces with a central CSRNG that provides high-quality
random bits, and distributes these via a parameterizable array of request/acknowledge handshake
endpoints. Each endpoint can request entropy independently; the module arbitrates and serializes
access to the CSRNG. The module includes a TileLink register interface for status and control,
configurable endpoint masks for gating, and interrupt signaling for request completion and errors.
Lifecycle control gates access, and alerts report errors.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `NumEndPoints` | Number of entropy distribution endpoints. | Typical: 8; each endpoint is independent. |
| `AlertAsyncOn` | Alert asynchronous enable mask. | Width `NumAlerts`. |
| `AlertSkewCycles` | Clock cycles of alert timing skew. | Typically 1. |

## Interface

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk_i` | input | 1 | System clock. |
| `rst_ni` | input | 1 | Active-low asynchronous reset. |
| `tl_i` | input | `tlul_h2d_t` | TileLink host-to-device for register and control access. |
| `tl_o` | output | `tlul_d2h_t` | TileLink device-to-host for register responses. |
| `edn_i` | input | `edn_req_t[NumEndPoints-1:0]` | EDN request array; each endpoint can request entropy. |
| `edn_o` | output | `edn_rsp_t[NumEndPoints-1:0]` | EDN response array; entropy delivery to each endpoint. |
| `csrng_cmd_o` | output | `csrng_pkg::csrng_req_t` | CSRNG command output; requests entropy from the central CSRNG. |
| `csrng_cmd_i` | input | `csrng_pkg::csrng_rsp_t` | CSRNG response input; entropy data and status from CSRNG. |
| `alert_rx_i` | input | `alert_rx_t[NumAlerts-1:0]` | Alert RX array. |
| `alert_tx_o` | output | `alert_tx_t[NumAlerts-1:0]` | Alert TX array. |
| `intr_edn_cmd_req_done_o` | output | 1 | Interrupt: CSRNG command request completed (entropy available). |
| `intr_edn_fatal_err_o` | output | 1 | Interrupt: fatal error detected (e.g., CSRNG failure, entropy request timeout). |

## Behavioral requirements

- **Endpoint request/response interface.** Each endpoint issues entropy requests via `edn_i[ep]` (valid signal + optional request parameters). The module responds with `edn_o[ep]` (valid signal + entropy data). Standard ready/valid handshaking applies to each endpoint independently.

- **Entropy arbitration.** When multiple endpoints request entropy simultaneously, the module arbitrates access to the single CSRNG interface. Arbitration is typically round-robin or priority-based (implementation-dependent). One endpoint is served at a time; others are queued.

- **CSRNG interface.** The module issues generate requests to the CSRNG via `csrng_cmd_o` (command: generate, reseed, update) and receives entropy/status via `csrng_cmd_i`. The CSRNG typically delivers entropy in fixed-size chunks (e.g., 128-bit blocks); the EDN distributes these to requesting endpoints.

- **Endpoint feature gating.** A control register can enable/disable individual endpoints, allowing selective entropy distribution. Requests from disabled endpoints are denied (error response or ignored).

- **Request completion signaling.** When a CSRNG entropy request completes, `intr_edn_cmd_req_done_o` is asserted to signal software that entropy is available. This allows software to poll status or wait via interrupt.

- **Error handling.** If the CSRNG fails to respond within a timeout, or if an invalid request is issued, `intr_edn_fatal_err_o` is asserted and error status is captured in registers. Recovery typically requires software intervention (e.g., re-initiate entropy request).

- **Register interface.** Control registers allow:
  - Endpoint enable mask.
  - CSRNG command issuance (generate, reseed).
  - Status: CSRNG response state, error flags.
  - Interrupt enable/status.

- **Entropy buffering (optional).** The module may buffer a limited amount of entropy (e.g., one 128-bit block) to service rapid successive requests without always hitting the CSRNG. Buffer status is reflected in registers.

## Example

Service two endpoints requesting entropy:
- Endpoint 0 asserts edn_i[0].req (request entropy).
- Endpoint 1 asserts edn_i[1].req at the same time.
- Arbiter selects endpoint 0 first (round-robin).
- EDN issues CSRNG generate request via csrng_cmd_o.
- After latency, CSRNG delivers 128-bit entropy via csrng_cmd_i.
- EDN delivers entropy to endpoint 0 via edn_o[0] (valid + data).
- Endpoint 0 consumes entropy (ready handshake).
- Next cycle, EDN services endpoint 1's request.
- If buffer was not previously full, a new CSRNG request may be pipelined.
- intr_edn_cmd_req_done_o pulses when each CSRNG request completes.
