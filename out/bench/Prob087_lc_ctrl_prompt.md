Design a module called TopModule. This module is the Life Cycle Controller, managing silicon lifecycle state transitions (from TEST through PROD to RMA), broadcasting lifecycle signals to the rest of the device, authenticating state changes via token-based unlock, and interfacing with OTP and key management systems.

## Overview

TopModule implements a secure lifecycle state machine driven by token-authenticated commands. It maintains a lifecycle state variable (TEST, TEST_LOCKED, DEV, PROD, RMA, INVALID, etc.) in OTP memory, broadcasts the current state via differential signals to all consumers (key manager, entropy source, crypto blocks), handles state transitions via secret token verification, and provides a JTAG/DMI debug interface. The module gates sensitive device features based on the current lifecycle state.

## Parameters

| Parameter | Meaning |
|-----------|---------|
| `NumRmaAckSigs` | Number of RMA acknowledge signals to wait for before transitioning to RMA; default 2. |
| `AlertAsyncOn` | Per-alert async/sync mode. |
| `AlertSkewCycles` | Alert propagation delay. |
| `SiliconCreatorId`, `ProductId`, `RevisionId` | Device identification codes (read-only). |
| `IdcodeValue` | JTAG IDCODE value. |
| `UseDmiInterface` | Enable DMI (Debug Module Interface) in addition to JTAG. |
| `RndCnstLcKeymgrDiv*` | Random seeds for lifecycle-to-keymgr derivation isolation. |
| `SecVolatileRawUnlockEn` | Enable volatile (non-persisted) unlock for test; default 0 (off). |

## Interface

### Clocks & Resets
- `clk_i`, `rst_ni`: Main clock and active-low reset.
- `clk_kmac_i`, `rst_kmac_ni`: KMAC clock and reset (for lifecycle token hashing).
- `scan_rst_ni`: Scan reset (asynchronous, for test mode).

### TL-UL Register Buses
- `regs_tl_i` / `regs_tl_o`: Primary register interface for software (32-bit address, data).
- `dmi_tl_i` / `dmi_tl_o`: Debug Module Interface bus (DMI) for debug access, if enabled.

### JTAG Interface
- `jtag_i` (input): JTAG request (TCO, TDI, sel, capture, shift, update, reset).
- `jtag_o` (output): JTAG response (TDO).

Provides a test/debug port for device programming and lifecycle state inspection.

### Scan Mode
- `scanmode_i`: Mubi4 scan mode indicator; if asserted, lifecycle transitions are inhibited.

### OTP & Key Interface
- `otp_lc_data_i` (input): OTP life-cycle data (current state, transition count, device identity).
- `lc_otp_program_o` (output): Request to program OTP with new lifecycle state (after token authentication).
- `lc_otp_program_i` (input): Response from OTP controller (ack, error).
- `lc_otp_vendor_test_o` / `lc_otp_vendor_test_i`: Vendor test mode request/response.

### KMAC Interface
- `kmac_data_o` (output): Request to KMAC for token hashing/verification.
- `kmac_data_i` (input): Response from KMAC (hashed token and status).

Used to authenticate state transition tokens before committing a new lifecycle state to OTP.

### Broadcast Lifecycle Signals
Differential (paired) outputs signaling the current lifecycle state to all device subsystems:

- `lc_init_done_o`: Device initialization complete (INIT state on power-up).
- `lc_dft_en_o`: DFT (Design-For-Test) enabled (TEST state).
- `lc_raw_test_rma_o`: RMA (Return Merchandise Authorization) state indicator.
- `lc_nvm_debug_en_o`: Non-volatile memory debug enabled (DEV state).
- `lc_hw_debug_clr_o` / `lc_hw_debug_en_o`: Hardware debug clear/enable (DEV and TEST_UNLOCKED states).
- `lc_cpu_en_o`: CPU enabled (PROD and higher).
- `lc_creator_seed_sw_rw_en_o`, `lc_owner_seed_sw_rw_en_o`: Seed software read/write enable (manufacturer, owner setup).
- `lc_iso_part_sw_rd_en_o` / `lc_iso_part_sw_wr_en_o`: Isolated partition software read/write enable.
- `lc_seed_hw_rd_en_o`: Seed hardware read enable (internal to device).
- `lc_keymgr_en_o`: Key manager enabled (secret states, PROD and higher).
- `lc_escalate_en_o`: Escalation enabled (error response signal).
- `lc_check_byp_en_o`: Integrity check bypass (test/debug).
- `lc_clk_byp_req_o` / `lc_clk_byp_ack_i`: Clock bypass request/acknowledge (for low-power test).

Each is a differential signal (Mubi4 or Mubi8 encoded) for fault tolerance.

### Power & Request/Acknowledge
- `pwr_lc_i` / `pwr_lc_o`: Power manager handshake (idle, power down request/response).
- `strap_en_override_o` (output): Override strap strobe enable (test feature).

### NVM RMA (Return Merchandise Authorization) Interface
- `lc_nvm_rma_seed_o` (output): Seed for RMA entropy generation.
- `lc_nvm_rma_req_o` (output): RMA state request to NVM controller.
- `lc_nvm_rma_ack_i[NumRmaAckSigs-1:0]` (input): Acknowledgments from NVM subsystems (must all assert before RMA transition completes).

### Device ID & Revision
- `otp_device_id_i` (input): Device ID from OTP (serial number, etc.).
- `otp_manuf_state_i` (input): Manufacturing state from OTP.
- `hw_rev_o` (output): Hardware revision output.

### Interrupts & Alerts
No dedicated interrupts, but:
- `alert_tx_o[NumAlerts-1:0]` (output): Fatal alert on state machine corruption or invalid transition.
- `alert_rx_i[NumAlerts-1:0]` (input): Alert acknowledge.
- Escalation (via `esc_*` ports) is used instead of traditional interrupts; see below.

### Escalation Channels
- `esc_scrap_state0_tx_i` / `esc_scrap_state0_rx_o`: Escalation channel 0 (input/output pair for differential signaling).
- `esc_scrap_state1_tx_i` / `esc_scrap_state1_rx_o`: Escalation channel 1.

These are used to report errors to an escalation manager, which may trigger system reset or tamper response.

## Control Registers (via TL-UL)

- **LC_STATE**: Read-only; reports current lifecycle state (decoded and raw).
- **LC_TRANSITION_CNT**: Transition counter (incremented on each state change).
- **LC_TRANSITION_TARGET**: Write-only; specifies the target state for a transition.
- **TRANSITION_TOKEN_[0..7]**: Write-only; token words for transition authentication (8 x 32-bit = 256-bit token).
- **TRANSITION_UNLOCK**: Write-only; triggers token verification and (if valid) OTP program request.

## Behavioral Requirements

### Lifecycle State Machine

TopModule maintains an internal state machine with the following states (in typical order):
- **RAW**: Initial state (before any programming).
- **TEST**: Full test access, no functionality restrictions.
- **TEST_LOCKED**: Test disabled (token-locked from TEST).
- **DEV**: Development state; CPU, key manager, debug enabled.
- **PROD**: Production; key manager enabled, debug restricted.
- **RMA**: Return merchandise; unlocks secrets for diagnostic/rework.
- **INVALID**: Corruption or fatal error; no transitions possible.

Not all states are present in all devices (parameters control which states are available).

### State Transition Protocol
1. Software writes the target state to `LC_TRANSITION_TARGET`.
2. Software writes the 256-bit transition token to `TRANSITION_TOKEN_[0..7]` registers.
3. Software writes `TRANSITION_UNLOCK` register to trigger authentication.
4. TopModule hashes the token using KMAC (via `kmac_data_o/i` handshake).
5. TopModule compares hashed token against the device's stored transition secret.
6. If match, TopModule requests OTP to program the new state via `lc_otp_program_o`.
7. On OTP acknowledgment, TopModule updates its internal state and broadcasts new lifecycle signals.
8. Software reads `LC_STATE` to confirm transition; `LC_TRANSITION_CNT` is incremented.

Invalid transitions (e.g., DEV -> TEST) are rejected; token mismatch causes a fatal alert.

### OTP Interaction
- On power-up, TopModule reads the current state from `otp_lc_data_i`.
- On a successful transition, TopModule asserts `lc_otp_program_o` with the new state encoded.
- OTP controller responds with `lc_otp_program_i.done` after writing; TopModule latches the new state.

### Broadcast Signals (Lifecycle Output)
Each broadcast signal is a differential encoding (Mubi4 or Mubi8), meaning:
- Active (TRUE): Two differential pairs signaling "1" with specific bit patterns.
- Inactive (FALSE): Two differential pairs signaling "0" with complementary patterns.
- Error: Corrupted or transient mismatch triggers escalation alert.

The lifecycle signals enable/disable various device subsystems:
- **CPU enabled** in PROD and RMA; disabled in TEST, DEV.
- **Key manager** enabled in DEV, PROD, RMA; disabled in TEST.
- **Debug** enabled in TEST, DEV; disabled in PROD, RMA (but RMA allows debug for diagnostics).
- **NVM debug** (e.g., write OTP) allowed in DEV; restricted in PROD.
- **Escalation** always active; used for error response.

### RMA Transition
- RMA is a special state accessible only from PROD via a specific token.
- Requires acknowledgment from all NVM subsystems (FLASH, OTP, etc.) before commitment.
- TopModule waits for all `lc_nvm_rma_ack_i[i]` to assert; if timeout, escalation is triggered.
- Provides RMA seed to NVM controller for secure erase/rework.

### Token Authentication
- Tokens are 256 bits; device stores a secret.
- TopModule hashes (token || device_secret) using KMAC.
- Compares result against a pre-programmed OTP hash.
- Prevents unauthorized state transitions (e.g., by cloning OTP or injecting token).

### Scan Mode & Test
- If `scanmode_i` is asserted, all state transitions are blocked; allows scan without inadvertent state changes.
- `SecVolatileRawUnlockEn` parameter allows (if set) volatile unlock of TEST state without OTP; for manufacturing test only.

### Reset Behavior
- On reset, internal state is reloaded from OTP via `otp_lc_data_i`.
- Broadcast signals reflect the OTP state.
- No pending transitions are lost; OTP is the source of truth.

### Error Handling & Escalation
- **Invalid Transition**: Attempt to transition to an invalid state or from a state that disallows the target. Error logged; no state change.
- **Token Mismatch**: Hashed token does not match OTP. Escalation alert triggered (fatal).
- **FSM Corruption**: Internal state machine detects an undefined state. Fatal alert; requires reset.
- **OTP Program Failure**: OTP reports error during write. Escalation triggered; state reverts to pre-transition.
- **Timeout**: RMA acknowledgment or KMAC hashing does not complete in time. Escalation alert; state reverts.

All fatal errors assert `alert_tx_o` and/or escalation signals; device should reset or enter safe mode.

## JTAG & Debug Port
- JTAG interface allows external tools to read current lifecycle state and device ID.
- In TEST and DEV states, JTAG may allow programming of OTP or other debug functions.
- In PROD and RMA, JTAG is restricted or disabled.

## Synchronization & Timing
- All logic synchronous to `clk_i`.
- KMAC operations are asynchronous (in their own clock domain `clk_kmac_i`); synced back via handshake.
- OTP reads/writes are asynchronous (OTP has separate clock); synced via handshake.
- State broadcast signals are updated synchronously in `clk_i` domain but are sampled by many domains.

## Example Scenario

1. Device powers up in RAW state (from OTP).
2. TopModule broadcasts all lifecycle signals inactive (debug disabled, CPU disabled, etc.).
3. Software writes PROD token to `TRANSITION_TOKEN_[0..7]`, writes PROD to `LC_TRANSITION_TARGET`.
4. Software writes `TRANSITION_UNLOCK`.
5. TopModule hashes token via KMAC, compares against OTP secret.
6. Token matches; TopModule requests OTP to program new state.
7. OTP responds with ack; TopModule updates internal state to PROD.
8. TopModule asserts `lc_cpu_en_o`, `lc_keymgr_en_o` (PROD-specific).
9. Software reads `LC_STATE` register; confirms PROD.
10. Rest of device sees new lifecycle state and adjusts (CPU unlocks, key manager initializes).

## Constraint & Design Notes
- **Token Entropy**: Tokens must be cryptographically random (typical 256-bit entropy).
- **OTP Wear-Out**: Each state transition writes to OTP; device has a finite transition count (typically 16-24 per state per device life).
- **Broadcast Synchronization**: All downstream consumers must correctly interpret the differential lifecycle signals; errors in interpretation can lead to security bypasses.
- **RMA Complexity**: RMA requires coordination with multiple NVM subsystems; must ensure atomic commitment or safe rollback.

