Design a module called TopModule. This module is an always-on (AON) timer: it maintains
separate counters in two clock domains (bus and always-on), supports both wakeup and watchdog
modes with bark and bite responses, and generates interrupts and resets based on timeout events.

## Overview

TopModule is a dual-clock-domain timer for always-on (AON) functionality in low-power systems.
It provides two independent counter/compare pairs: one for wakeup generation and one for watchdog.
The wakeup timer can trigger system wake-up events; the watchdog timer can assert bark (warning)
and bite (hard reset) signals. The module operates in two independent clock domains: a main bus
clock for register access and an always-on clock for independent counter operation. Lifecycle
control gates certain operations based on system state. RACL policies govern register access,
and alerts are supported for error conditions.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `AlertAsyncOn` | Alert asynchronous enable mask. | Width `NumAlerts`; each bit selects async (1) or sync (0). |
| `AlertSkewCycles` | Clock cycles of alert timing skew. | Typically 1. |
| `EnableRacl` | Enable role-based access control. | 0 = disabled, 1 = enabled. |
| `RaclErrorRsp` | RACL error response mode. | Defaults to `EnableRacl`. |
| `RaclPolicySelVec` | RACL policy selection per register. | Array of `top_racl_pkg::racl_policy_sel_t`. |

## Interface

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk_i` | input | 1 | Main bus clock for register interface. |
| `clk_aon_i` | input | 1 | Always-on clock, independent of main clock; drives AON counters. |
| `rst_ni` | input | 1 | Active-low asynchronous reset for main clock domain. |
| `rst_aon_ni` | input | 1 | Active-low asynchronous reset for AON clock domain. |
| `tl_i` | input | `tlul_h2d_t` | TileLink host-to-device (main clock domain). |
| `tl_o` | output | `tlul_d2h_t` | TileLink device-to-host (main clock domain). |
| `alert_rx_i` | input | `alert_rx_t[NumAlerts-1:0]` | Alert RX array. |
| `alert_tx_o` | output | `alert_tx_t[NumAlerts-1:0]` | Alert TX array. |
| `racl_policies_i` | input | `top_racl_pkg::racl_policy_vec_t` | Lifecycle role-access policies. |
| `racl_error_o` | output | `top_racl_pkg::racl_error_log_t` | RACL access violation log. |
| `lc_escalate_en_i` | input | `lc_ctrl_pkg::lc_tx_t` | Lifecycle escalate enable; may disable watchdog or trigger bite. |
| `intr_wkup_timer_expired_o` | output | 1 | Wakeup timer expired interrupt; asserted when wakeup counter >= wakeup compare. |
| `intr_wdog_timer_bark_o` | output | 1 | Watchdog bark (warning) interrupt; asserted on watchdog timeout. |
| `nmi_wdog_timer_bark_o` | output | 1 | Watchdog bark as non-maskable interrupt (NMI). |
| `wkup_req_o` | output | 1 | Wakeup request output; signal to power manager to wake the system. |
| `aon_timer_rst_req_o` | output | 1 | AON timer reset request; may be asserted by watchdog bite or escalation. |
| `sleep_mode_i` | input | 1 | Sleep mode indicator; input from power manager or control logic indicating system sleep state. |

## Behavioral requirements

- **Dual-clock-domain design.** The module operates with independent main and AON clock domains. The wakeup and watchdog counters increment on the AON clock, while register access uses the main bus clock. Synchronization between domains is handled internally.

- **Wakeup timer.** The wakeup counter increments every AON clock cycle. When the counter >= the wakeup compare value, `intr_wkup_timer_expired_o` is asserted and `wkup_req_o` is driven to request system wake-up. These signals persist until cleared by register write or new compare value.

- **Watchdog timer.** The watchdog counter increments on the AON clock independently. Two thresholds exist:
  - *Bark threshold*: When counter >= bark_cmp, `intr_wdog_timer_bark_o` and `nmi_wdog_timer_bark_o` assert, warning of imminent reset.
  - *Bite threshold*: When counter >= bite_cmp (typically much larger), `aon_timer_rst_req_o` is driven to request a hard reset. The bite response may be gated by `lc_escalate_en_i`.

- **Sleep mode gating.** When `sleep_mode_i` is high, timer counters may be frozen or adjusted based on configuration to support low-power operation.

- **Lifecycle escalation.** The `lc_escalate_en_i` input from lifecycle control can force watchdog bark/bite behavior or disable watchdog entirely, providing emergency reset capability.

- **Register interface.** Wakeup and watchdog counters and thresholds are accessed via TileLink registers in the main clock domain. Writes are synchronized to the AON clock domain. Reads reflect the current counter value (synchronized back to main clock).

- **Optional RACL enforcement.** When EnableRacl = 1, register access respects role-based policies, with violations logged in `racl_error_o`.

- **Alert support.** Errors (e.g., access violations, watchdog escalation) may raise alerts via `alert_tx_o`, respecting the AlertAsyncOn parameter.

## Example

Configure a 100 ms wakeup timer and a 1 s watchdog on a 32 kHz AON clock:
- AON clock period: 31.25 µs (32000 cycles/sec).
- Wakeup counter threshold: 100 ms = 3200 cycles.
- Watchdog bark threshold: 800 ms = 25600 cycles.
- Watchdog bite threshold: 1 s = 32000 cycles.
- Write registers: `wkup_cmp = 3200`, `wdog_bark_cmp = 25600`, `wdog_bite_cmp = 32000`.
- After 100 ms, wakeup counter reaches 3200, `intr_wkup_timer_expired_o` asserts and `wkup_req_o` pulses.
- After 800 ms, watchdog counter reaches 25600, `intr_wdog_timer_bark_o` asserts (warning).
- If cleared before 1 s, no reset occurs. If not cleared, at 1 s counter reaches 32000, `aon_timer_rst_req_o` drives reset request (bite).
