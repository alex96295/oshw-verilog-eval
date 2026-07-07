Design a module called TopModule. This module is a ROM controller: it manages boot ROM access with
transparent scrambling and KMAC-based integrity verification, gates access based on lifecycle, and
coordinates with power and key managers.

## Overview

TopModule is a ROM (read-only memory) controller that provides secure boot firmware storage. It
implements transparent scrambling of ROM contents using a supplied nonce and key, and verifies the
entire ROM against a KMAC-computed digest at boot time. After verification, the ROM switches to
simple passthrough mode. Two independent TileLink interfaces provide access to the ROM itself and
to control registers. The module coordinates with external managers (power manager, key manager)
via dedicated interfaces for boot status and key derivation. Lifecycle gating prevents ROM access
in certain states. The module supports flexible ROM size and optional scrambling disable for early
boot diagnostics.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `BootRomInitFile` | Path to boot ROM initialization file (ELF, hex, or verilog). | Optional; empty = all zeros. |
| `AlertAsyncOn` | Alert asynchronous enable mask. | Width `NumAlerts`. |
| `AlertSkewCycles` | Clock cycles of alert timing skew. | Typically 1. |
| `FlopToKmac` | Add register stage on KMAC output for timing. | 0 or 1. |
| `RndCnstScrNonce` | Scrambling nonce constant (64-bit). | Design-specific constant. |
| `RndCnstScrKey` | Scrambling key constant (128-bit). | Design-specific constant. |
| `MemSizeRom` | Total ROM size in bytes. | Typical: 0x8000 (32 KB). |
| `SecDisableScrambling` | Disable scrambling (security-critical; for test only). | 0 = scrambling enabled (default), 1 = disabled. |

## Interface

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk_i` | input | 1 | System clock. |
| `rst_ni` | input | 1 | Active-low asynchronous reset. |
| `rom_cfg_i` | input | `rom_cfg_t` | ROM configuration (from power manager or ROM itself); includes scramble control, digest address. |
| `rom_tl_i` | input | `tlul_h2d_t` | TileLink host-to-device for ROM memory read access. |
| `rom_tl_o` | output | `tlul_d2h_t` | TileLink device-to-host for ROM responses. |
| `regs_tl_i` | input | `tlul_h2d_t` | TileLink host-to-device for control registers. |
| `regs_tl_o` | output | `tlul_d2h_t` | TileLink device-to-host for register responses. |
| `alert_rx_i` | input | `alert_rx_t[NumAlerts-1:0]` | Alert RX array. |
| `alert_tx_o` | output | `alert_tx_t[NumAlerts-1:0]` | Alert TX array. |
| `pwrmgr_data_o` | output | `rom_ctrl_pkg::pwrmgr_data_t` | Boot status and control data for power manager (e.g., ROM check complete signal). |
| `keymgr_data_o` | output | `rom_ctrl_pkg::keymgr_data_t` | Boot status and control data for key manager (e.g., ROM check result). |
| `kmac_data_i` | input | `kmac_pkg::app_rsp_t` | KMAC application response (digest result, valid flag). |
| `kmac_data_o` | output | `kmac_pkg::app_req_t` | KMAC application request (message, strobe, last, start). |

## Behavioral requirements

- **Boot ROM and scrambling.** The ROM contents are initialized from `BootRomInitFile` at elaboration. Each word is XORed with a keystream derived from the address, nonce, and key constants using PRINCE or similar cipher in counter mode. Reads are decrypted transparently; writes are denied (ROM is read-only).

- **ROM integrity check via KMAC.** At boot, TopModule computes a KMAC digest of the entire ROM contents and compares it to a reference digest (either embedded in ROM or supplied via `rom_cfg_i`). The KMAC interface is used: the controller streams ROM words via `kmac_data_o` and receives the computed digest via `kmac_data_i`. If the digest matches, boot proceeds; if not, an alert is raised and boot is halted.

- **Two-phase operation.** 
  - *Boot phase*: ROM check is performed; accesses return error until verification completes.
  - *Run phase*: After verification succeeds, ROM becomes transparent; all TileLink read accesses are forwarded to the ROM memory with no scrambling (data is already decrypted during KMAC compute).

- **Register interface for control.** The `regs_tl_i`/`regs_tl_o` pair provide access to status and control registers, including:
  - ROM check result (pass/fail).
  - ROM check completion flag.
  - Optional debug/override control (e.g., to re-run check).

- **Configuration input.** The `rom_cfg_i` input provides runtime configuration (digest address, scramble enable/disable, check enable) from the power manager or a prior boot stage.

- **Coordination with managers.** The module signals boot status to the power manager and key manager via dedicated interfaces, allowing them to coordinate boot flow. For example, the power manager waits for ROM check completion before releasing the CPU.

- **Lifecycle gating.** ROM access may be denied in certain lifecycle states, returning error responses. Scrambling may be forcibly disabled in certain modes (e.g., diagnostic mode).

- **Scrambling bypass (test mode).** When `SecDisableScrambling = 1` or when `rom_cfg_i.disable_scramble` is set, decryption is skipped and raw ROM data is returned. This is security-critical and disabled in production.

- **Alert reporting.** Digest mismatch or other errors raise alerts via `alert_tx_o`.

## Example

Boot ROM digest check:
- At reset, ROM address range 0x0000-0x7FFF contains firmware (encrypted).
- ROM check address (last word, 0x7FFC) contains expected KMAC digest.
- TopModule reads ROM contents via internal path (bypassing TileLink), decrypts each word on-the-fly.
- Decrypted words are streamed to KMAC via `kmac_data_o`.
- KMAC computes digest over all decrypted words.
- Digest is compared to reference (from 0x7FFC).
- If match: `pwrmgr_data_o` signals completion; CPU can proceed.
- If mismatch: alert is raised; `pwrmgr_data_o` halts CPU; boot fails.
- After boot, ROM reads are simple address->data lookups with no decryption (transparent passthrough).
