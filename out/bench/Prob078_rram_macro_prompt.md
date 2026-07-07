Design a module called TopModule. This module is an RRAM (Resistive RAM) macro model: it
simulates a persistent ReRAM memory with programmable bit patterns, randomized operation latency,
and JTAG/scan test interfaces.

## Overview

TopModule is a behavioral model of an RRAM (Resistive RAM) memory macro for simulation purposes.
It provides a request/response interface for read and program (write) operations, with realistic
latency simulation (addresses are presented, and responses arrive after a randomized delay).
The module includes a TileLink register interface for low-level control, full JTAG interface for
testing, and scan chain support. RRAM cells retain their state across power cycles in simulation.
The module integrates with design-for-test infrastructure including observability and debug
access controlled by lifecycle signals.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `TotalPages` | Total number of 4-kB memory pages. | Typical: 4096 (16 MB total). |
| `DataWidth` | Width of data per RRAM word. | Typical: 128 bits. |
| `WordsPerPage` | Number of words per page. | Typical: 32 (page_size / word_width). |
| `TotalInfoPages` | Number of information/metadata pages. | Typical: 8. |
| `MaxWrWords` | Maximum number of words written in one operation. | Typical: 32. |

## Interface

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk_i` | input | 1 | System clock. |
| `rst_ni` | input | 1 | Active-low asynchronous reset. |
| `rram_macro_i` | input | `rram_ctrl_pkg::rram_macro_req_t` | RRAM request (address, command, write data); request/response handshaking via valid/ready. |
| `rram_macro_o` | output | `rram_ctrl_pkg::rram_macro_rsp_t` | RRAM response (read data, error status); valid when response available. |
| `prim_tl_i` | input | `tlul_h2d_t` | TileLink host-to-device for low-level programming and diagnostic access. |
| `prim_tl_o` | output | `tlul_d2h_t` | TileLink device-to-host for register responses. |
| `cio_tck_i` | input | 1 | JTAG test clock. |
| `cio_tdi_i` | input | 1 | JTAG test data input. |
| `cio_tms_i` | input | 1 | JTAG test mode select. |
| `cio_tdo_o` | output | 1 | JTAG test data output. |
| `cio_tdo_en_o` | output | 1 | JTAG test data output enable. |
| `lc_nvm_debug_en_i` | input | `lc_ctrl_pkg::lc_tx_t` | Lifecycle NVM (non-volatile memory) debug enable; gates debug access. |
| `scanmode_i` | input | `prim_mubi_pkg::mubi4_t` | Scan mode (MUBI4 encoded); when high, scan chain is active. |
| `scan_en_i` | input | 1 | Scan enable; gates scan operation. |
| `scan_rst_ni` | input | 1 | Scan reset (active-low); resets scan chain state. |
| `rram_test_analog_io` | inout | 1 | Analog test node (bidirectional); allows analog voltage probing/injection for characterization. |
| `obs_ctrl_i` | input | `ast_pkg::ast_obs_ctrl_t` | Observability control; selects which internal signal is routed to analog output. |
| `rram_obs_o` | output | 8 | Observability output; digital signals indicating internal state (e.g., row/column decoders, sense amplifier). |

## Behavioral requirements

- **Request/response interface.** The RRAM controller communicates with TopModule via `rram_macro_i` (request) and `rram_macro_o` (response). A request includes the operation type (read or program), address, and data (for write). The response includes the read data and error/status flags.

- **Latency simulation.** RRAM operations are not instantaneous. When a valid request is accepted, the module internally schedules the response to arrive after a randomized delay (typically 10-100 cycles) to simulate sense amplifier and programming circuitry delays. The response_valid signal indicates when the response is ready.

- **Read operation.** On a read request, the addressed memory location is retrieved after latency. The returned data reflects the current state of the RRAM cells (persisted across simulation runs if loaded from a file).

- **Program (write) operation.** On a program request, the addressed cells are set to the supplied pattern. The pattern may be partial (using a bitmask) to selectively update cells. After latency, a response confirms success or reports errors (e.g., over-voltage, cell stuck).

- **Memory persistence.** The RRAM content is retained in simulation; reads return data previously written. On reset, data is not cleared (simulating persistent storage). A separate initialization or erase operation may be needed to clear cells.

- **JTAG interface.** The JTAG pins (tck, tdi, tms, tdo, tdo_en) implement standard JTAG protocol for boundary scan, internal register access, and device identification. The tdo_en pin controls tri-state output.

- **Scan chain support.** When `scanmode_i` is high, scan mode is active. The module chains scan data from tdi through internal scan cells and out via tdo, shifting at each tck edge. Scan reset resets scan chain flip-flops.

- **Lifecycle gating.** Debug and test access (via JTAG, TileLink prim interface, and scan) are conditional on `lc_nvm_debug_en_i`. When disabled, debug access is denied and responses are error.

- **Observability.** The `obs_ctrl_i` input selects which internal node is output via `rram_obs_o` (8-bit bus) for power/performance characterization. The analog `rram_test_analog_io` may be driven by an on-chip circuit or left floating.

## Example

Simulate a program and read cycle:
- Request: program 16 cells at address 0x1000 with pattern 0xFFFF_FFFF.
- Request is accepted; latency counter starts (e.g., 50 cycles).
- After 50 cycles, response is valid with status = success.
- Request: read address 0x1000.
- Response arrives after latency; read_data = 0xFFFF_FFFF (pattern persists).
- Set lc_nvm_debug_en_i to disabled; subsequent requests return error status.
