Design a module called TopModule. This module is an OTP (One-Time Programmable) memory macro
model: it simulates persistent non-volatile storage with read and program interfaces, supports
JTAG/scan test access, lifecycle-gated debug, and interfaces with power sequencing logic.

## Overview

TopModule is a behavioral model of an OTP memory macro used for secure key and configuration
storage. It provides parameterizable width and depth with a dedicated request/response interface
for read and program operations. The module integrates power sequencing signals for supply
voltage control during programming, test vectors for characterization, and full JTAG and scan
support for production test. Low-level register access via TileLink is available for diagnostic
purposes. DFT enable from lifecycle gating controls debug access. The module supports RACL
policies for register protection and reports configuration errors via alerts.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `Width` | Data width (bits per word). | Typical: 16. |
| `Depth` | Number of addressable rows. | Typical: 1024 (16 KB at 16-bit width). |
| `SizeWidth` | Width of the size field in read operations. | Typical: 2 (sizes 0, 1, 2, 3 = 1, 2, 4, 8 bytes). |
| `MemInitFile` | Path to initialization file (ELF or hex). | Optional; defaults to all zeros if empty string. |
| `VendorTestOffset` | Offset into memory for vendor test region. | Typical: 0 (no vendor test region). |
| `VendorTestSize` | Size of vendor test region in bytes. | Typical: 0 (disabled). |
| `EnableRacl` | Enable role-based access control. | 0 = disabled, 1 = enabled. |
| `RaclErrorRsp` | RACL error response mode. | Typically 1; when 1, access violations return error response. |
| `RaclPolicySelVec` | RACL policy selection per register. | Array of `top_racl_pkg::racl_policy_sel_t`. |

## Interface

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk_i` | input | 1 | System clock for registers and test interface. |
| `rst_ni` | input | 1 | Active-low asynchronous reset. |
| `prim_tl_i` | input | `tlul_h2d_t` | TileLink host-to-device for low-level register and diagnostic access. |
| `prim_tl_o` | output | `tlul_d2h_t` | TileLink device-to-host for register responses. |
| `lc_dft_en_i` | input | `lc_ctrl_pkg::lc_tx_t` | Lifecycle DFT enable; gates test access. |
| `obs_ctrl_i` | input | `ast_pkg::ast_obs_ctrl_t` | Observability control; selects internal signal for monitoring. |
| `otp_obs_o` | output | 8 | Observability output; digital signals indicating internal state. |
| `pwr_seq_o` | output | `pwr_seq_t` | Power sequence control output; drives supply voltage switching for programming. |
| `pwr_seq_h_i` | input | `pwr_seq_t` | Power sequence handshake input; confirms supply voltage state. |
| `ext_voltage_h_io` | inout | 1 | External voltage analog node; allows off-chip supply injection for characterization. |
| `test_i` | input | `otp_test_req_t` | OTP test request (command, address, data). |
| `test_o` | output | `otp_test_rsp_t` | OTP test response (read data, status). |
| `cio_test_o` | output | `otp_test_vect_t` | Test vector output; digital test signals for boundary scan. |
| `cio_test_en_o` | output | `otp_test_vect_t` | Test vector output enable; gates test vector drivers. |
| `scanmode_i` | input | `prim_mubi_pkg::mubi4_t` | Scan mode (MUBI4 encoded); high to activate scan chain. |
| `scan_en_i` | input | 1 | Scan enable; when high, scan data is shifted. |
| `scan_rst_ni` | input | 1 | Scan reset (active-low); resets scan chain state. |
| `otp_i` | input | `otp_ctrl_macro_req_t` | OTP controller request (read address, program address/data). |
| `otp_o` | output | `otp_ctrl_macro_rsp_t` | OTP controller response (read data, program status, error flags). |
| `racl_policies_i` | input | `top_racl_pkg::racl_policy_vec_t` | Lifecycle role-access policies. |
| `racl_error_o` | output | `top_racl_pkg::racl_error_log_t` | RACL access violation log. |
| `cfg_i` | input | `otp_cfg_t` | OTP macro configuration (timing, supply voltages). |
| `cfg_rsp_o` | output | `otp_cfg_rsp_t` | Configuration response / handshake. |

## Behavioral requirements

- **Dual interfaces for memory access.** The module supports two independent memory interfaces:
  - *OTP controller interface* (`otp_i`/`otp_o`): High-level command interface for read and program.
  - *Test interface* (`test_i`/`test_o`): Low-level test commands; behavior depends on `lc_dft_en_i`.

- **Read operation.** On a read request specifying an address and optional size (via SizeWidth), the module returns the data from that location. Reads are non-destructive and complete in one cycle.

- **Program (write) operation.** Program requests provide an address and data. The module initiates power sequence control (pwr_seq_o) to raise supply voltage, programs the OTP cell array, and returns completion status. Cells can typically only transition from 0 to 1 (one-time programmable); programming to 0 is illegal and returns an error status.

- **Power sequencing.** The `pwr_seq_o` output drives supply-voltage control (typically a voltage pump enable and target voltage level). The `pwr_seq_h_i` input confirms the new voltage is stable. The module waits for handshake before issuing program pulses to OTP cells.

- **Test vector interface.** The `test_i`/`test_o` and `cio_test_*` ports support production test (via JTAG or tester) when `lc_dft_en_i` is high. Test commands may access special test rows or perform characterization operations. When disabled, test access is denied.

- **JTAG/scan support.** Scan chain allows internal flip-flops and test structures to be accessed serially. When `scanmode_i` is high, data shifts on each clock from `scan_*` pins. Boundary-scan cells can observe power-supply and voltage-monitor signals.

- **Observability.** The `obs_ctrl_i` input selects which internal node to output on `otp_obs_o`. This is used for power and timing characterization during test.

- **Configuration and handshaking.** The `cfg_i` input provides macro configuration (e.g., sense amplifier timing, programming pulse width, voltage levels). Configuration changes are acknowledged on `cfg_rsp_o`.

- **RACL enforcement.** Register access is controlled by role-based policies when EnableRacl = 1. Violations are logged in `racl_error_o`.

## Example

Program and read a 16-bit secret key:
- Request: program address 0x100, data 0xABCD.
- Controller sets pwr_seq_o to raise voltage; waits for pwr_seq_h_i.
- Programs cell array with pattern; latches and verifies.
- Response: program success.
- Request: read address 0x100, size=2 (full word).
- Response: read_data = 0xABCD.
- Later, attempt to program same address to a different value.
- Response: program error (OTP cell cannot transition from 1 back to 0).
