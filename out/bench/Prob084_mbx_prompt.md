Design a module called TopModule. This module is a DOE mailbox (MBX): it provides a dual-interface
message mailbox for host-to-SoC communication with shared SRAM backend, arbiter for concurrent
access, and configurable interrupt/doorbell signaling.

## Overview

TopModule is a message mailbox controller for Denial-of-Service (DoE) protocol communication
between a host processor and a SoC. It provides two independent TileLink register/window interfaces:
one for core CPU access and one for SoC (host-facing) access. Both sides share a single SRAM
backend via an internal arbiter. The mailbox supports message-oriented communication with
configurable sizes, automatic object management, and doorbell/interrupt signaling to notify
the peer when messages are available. Lifecycle gating and RACL policies control access.
Optional interrupt and asynchronous-message support flags can be gated. The module arbitrates
SRAM read/write access between the two sides and manages address translation and access control.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `AlertAsyncOn` | Alert asynchronous enable mask. | Width `NumAlerts`. |
| `AlertSkewCycles` | Clock cycles of alert timing skew. | Typically 1. |
| `CfgSramAddrWidth` | SRAM address width for mailbox storage. | Typical: 32 bits. |
| `CfgSramDataWidth` | SRAM data width. | Typical: 32 bits. |
| `CfgObjectSizeWidth` | Width of object size field in bytes. | Typical: 11 bits (up to 2 KB per object). |
| `DoeIrqSupport` | Enable interrupt support feature. | 0 or 1; when 0, interrupt outputs are disabled. |
| `DoeAsyncMsgSupport` | Enable asynchronous message support feature. | 0 or 1; when 0, async features are disabled. |
| `EnableRacl` | Enable role-based access control. | 0 = disabled, 1 = enabled. |
| `RaclErrorRsp` | RACL error response mode. | Defaults to `EnableRacl`. |
| `RaclPolicySelVecSoc` | RACL policy for SoC-side registers. | Array per register. |
| `RaclPolicySelWinSocWdata` | RACL policy for SoC write data window. | Single policy. |
| `RaclPolicySelWinSocRdata` | RACL policy for SoC read data window. | Single policy. |
| `RaclPolicySelVecCore` | RACL policy for core-side registers. | Array per register. |

## Interface

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk_i` | input | 1 | System clock. |
| `rst_ni` | input | 1 | Active-low asynchronous reset. |
| `intr_mbx_ready_o` | output | 1 | Mailbox ready interrupt; asserted when mailbox is ready to accept new messages. |
| `intr_mbx_abort_o` | output | 1 | Mailbox abort interrupt; asserted when a message transfer is aborted. |
| `intr_mbx_error_o` | output | 1 | Mailbox error interrupt; asserted when an error condition is detected. |
| `doe_intr_support_o` | output | 1 | DOE interrupt support flag; indicates whether interrupt features are enabled (reflects DoeIrqSupport). |
| `doe_intr_en_o` | output | 1 | DOE interrupt enable; when high, all mailbox interrupts are routed to the host. |
| `doe_intr_o` | output | 1 | DOE interrupt output; combined interrupt to host (ORed from intr_mbx_*_o signals). |
| `doe_async_msg_support_o` | output | 1 | DOE async message support flag; indicates whether async features are enabled (reflects DoeAsyncMsgSupport). |
| `alert_rx_i` | input | `alert_rx_t[NumAlerts-1:0]` | Alert RX array. |
| `alert_tx_o` | output | `alert_tx_t[NumAlerts-1:0]` | Alert TX array. |
| `racl_policies_i` | input | `top_racl_pkg::racl_policy_vec_t` | Lifecycle role-access policies. |
| `racl_error_o` | output | `top_racl_pkg::racl_error_log_t` | RACL access violation log. |
| `core_tl_d_i` | input | `tlul_h2d_t` | TileLink host-to-device from core CPU (device side). |
| `core_tl_d_o` | output | `tlul_d2h_t` | TileLink device-to-host to core CPU. |
| `soc_tl_d_i` | input | `tlul_h2d_t` | TileLink host-to-device from SoC (host side) (device side). |
| `soc_tl_d_o` | output | `tlul_d2h_t` | TileLink device-to-host to SoC. |
| `sram_tl_h_i` | input | `tlul_d2h_t` | TileLink device-to-host from SRAM (host side, response). |
| `sram_tl_h_o` | output | `tlul_h2d_t` | TileLink host-to-device to SRAM (host side, request). |

## Behavioral requirements

- **Dual-interface mailbox.** TopModule presents two independent TileLink register/window interfaces:
  - *Core side* (`core_tl_d_i`/`core_tl_d_o`): Interface for the local SoC CPU or core.
  - *SoC/host side* (`soc_tl_d_i`/`soc_tl_d_o`): Interface for the external host or remote SoC.
  Both sides access the same logical mailbox via shared SRAM backend.

- **SRAM arbitration.** The internal arbiter grants SRAM access (via `sram_tl_h_o`/`sram_tl_h_i`) to either the core or SoC side based on priority or fairness. Concurrent accesses are serialized; one request is processed at a time, and the other waits.

- **Message object management.** The mailbox manages message objects, each with:
  - Object address (location in SRAM).
  - Object size (in bytes, up to CfgObjectSizeWidth bits).
  - Status (pending, complete, aborted, etc.).
  Control registers allow creating/closing objects and reading/writing data.

- **Register and data windows.** Two address ranges are exposed:
  - *Register window*: Control registers (object management, status, interrupt control).
  - *Data window*: Read/write data window (direct SRAM access at address of current object).

- **Doorbell and interrupt signaling.** When the core writes a message to the mailbox, it asserts a doorbell/ready signal. When the SoC reads the message and completes processing, it signals completion via an interrupt. If DoeIrqSupport = 1, interrupts are routed to the host via doe_intr_o.

- **Ready, abort, and error interrupts.**
  - `intr_mbx_ready_o`: Asserted when the mailbox is ready for a new message (previous message consumed).
  - `intr_mbx_abort_o`: Asserted if a message transfer is aborted (e.g., invalid size, timeout).
  - `intr_mbx_error_o`: Asserted on other errors (e.g., SRAM access failure, protocol violation).

- **Feature gating.** If DoeIrqSupport = 0, interrupt features are disabled; doe_intr_support_o = 0, and interrupt signals are not routed. If DoeAsyncMsgSupport = 0, async message handling is disabled; doe_async_msg_support_o = 0.

- **Access control via RACL.** When EnableRacl = 1, register and data window access on both core and SoC sides are subject to role-based policies. Violations are logged in `racl_error_o` and access is denied.

- **Concurrent access handling.** Both sides can read/write the mailbox concurrently (via arbiter). Status registers prevent data corruption (e.g., one side cannot write while the other is reading the same object).

## Example

Core-to-host message transfer:
- Core writes object size (256 bytes) via core-side register.
- Core writes message data (256 bytes) via core-side data window (accessing SRAM).
- Core sets a "ready" flag, asserting a doorbell signal to the host.
- Host observes ready signal (via interrupts or polling).
- Host reads object size via SoC-side register.
- Host reads message data (256 bytes) via SoC-side data window (SRAM arbiter grants SoC priority).
- Host processes message and writes response (256 bytes) via SoC-side data window to a response object.
- Host sets a "complete" flag, signaling back to core.
- Core observes completion interrupt (intr_mbx_ready_o).
- Core reads response data via core-side data window.
- Mailbox is now ready for the next message exchange.
