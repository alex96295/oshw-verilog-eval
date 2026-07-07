Design a module called TopModule. This module is a Serial Peripheral Interface (SPI) host controller that manages SPI bus transactions. It provides software-configurable control of SPI clocking, chip select, and data lines, with dual FIFOs for command/status and transmit/receive data, interrupt and alert signaling, and optional SPI pass-through mode.

## Overview

TopModule acts as an SPI host controller, exposing a TileLink Uncached Lightweight (TL-UL) register interface for configuration and status, and driving SPI bus I/O pins (clock, chip select, data lines). The module supports multiple SPI modes (Standard, Dual, Quad), command-driven operation with TX/RX FIFOs, configurable clock polarity and phase (CPOL/CPHA), per-chip-select line control, and optional hardware pass-through for direct SPI bus management. It also signals interrupts on SPI events and recovery/fatal alerts.

## Parameters

| Parameter | Type | Meaning |
|-----------|------|---------|
| `NumCS` | int unsigned | Number of chip select lines; default 1. If 1, allows SPI pass-through mode. |
| `AlertAsyncOn` | logic vector | Per-alert async/sync mode; default all 1 (async). |
| `AlertSkewCycles` | int unsigned | Alert propagation skew; default 1. |
| `EnableRacl` | bit | Enable RACL (Resource Access Control List) checks; default 0. |
| `RaclErrorRsp` | bit | Enable RACL error responses; default tracks `EnableRacl`. |
| `RaclPolicySelVec` | logic array | RACL policy selectors per register. |

## Interface

### Clocks & Resets
- `clk_i`: Main clock for TL-UL and SPI core logic (input, 1-bit).
- `rst_ni`: Active-low reset, synchronized to `clk_i` (input, 1-bit).

### TL-UL Register Bus
- `tl_i` (input): TL-UL host-to-device request channel (address, write data, valid, etc.).
- `tl_o` (output): TL-UL device-to-host response channel (read data, valid, error).

Both carry 32-bit addresses and data, with byte enables and size encoding. Register access is memory-mapped and synchronous to `clk_i`.

### SPI I/O Ports
- `cio_sck_o`, `cio_sck_en_o` (output): SPI clock and output-enable; `cio_sck_en_o` is the tri-state enable.
- `cio_csb_o[NumCS-1:0]`, `cio_csb_en_o[NumCS-1:0]` (output): Chip select lines and per-CS output-enables.
- `cio_sd_i[3:0]` (input): SPI data input (MISO or bidirectional data lines in Dual/Quad modes).
- `cio_sd_o[3:0]`, `cio_sd_en_o[3:0]` (output): SPI data output and per-line output-enables.

Output-enables are active-high; the actual bus is open-drain or open-source, controlled by these enables.

### SPI Pass-Through (NumCS == 1 only)
- `passthrough_i` (input): Contains `passthrough_en`, `sck`, `sck_en`, `csb`, `csb_en`, `s[3:0]`, `s_en[3:0]`. When `passthrough_en` is asserted, this port's signals override the internally-generated SPI outputs.
- `passthrough_o` (output): Currently unused (reserved).

### Interrupts & Alerts
- `intr_error_o` (output, 1-bit): Asserted on SPI errors (e.g., overflow, underflow, abort).
- `intr_spi_event_o` (output, 1-bit): Asserted on TX complete, RX data ready, or similar.
- `lsio_trigger_o` (output, 1-bit): Trigger signal for low-speed I/O logic (e.g., wakeup).
- `alert_tx_o[NumAlerts-1:0]` (output): Alert transmit wires (differential; one per alert class).
- `alert_rx_i[NumAlerts-1:0]` (input): Alert acknowledge/ping wires (differential; one per alert class).

### RACL (optional)
- `racl_policies_i` (input): RACL policy configuration.
- `racl_error_o` (output): RACL error log on access violations.

## Control & Status Registers (via TL-UL)

TopModule exposes the following register types (detailed addresses omitted):

- **CONTROL**: Output enable, SPI mode select (Standard/Dual/Quad), CPOL/CPHA, command/data FIFO enables.
- **CONFIG**: Clock divider, inter-frame spacing, chip select timing, byte order.
- **COMMAND_FIFO_STATUS / TXDATA_FIFO_STATUS / RXDATA_FIFO_STATUS**: FIFO occupancy, full/empty flags.
- **COMMAND**: Write-only; enqueues SPI commands (direction, length, chip select index).
- **TXDATA**: Write-only; loads TX data into the transmit FIFO.
- **RXDATA**: Read-only; reads received data from the RX FIFO.
- **STATUS**: Read-only; reports current SPI state, error flags, FIFO flags, and ready indicators.
- **INTR_STATE / INTR_ENABLE / INTR_TEST**: Interrupt status, masking, and test injection.
- **ALERT_TEST**: Test-inject alert signals.

## Behavioral Requirements

### Reset
- On reset (`rst_ni` low), all FIFOs are cleared, SPI outputs (clock, chip select, data) default to inactive (SCK low or high per CPOL, CSB high, SD lines tri-stated), and interrupts/alerts are cleared.

### Register-Driven Operation
- **Output Enable**: When `CONTROL.output_en` is low, all SPI I/O lines are tri-stated. When high, SPI outputs are driven per the current SPI transfer state.
- **Mode Configuration**: `CONTROL` register selects Standard (1-bit), Dual (2-bit), or Quad (4-bit) modes; this affects how `cio_sd_o/i` bits are interpreted and shifted.
- **CPOL/CPHA**: Polarity and phase configure clock inactive state and data sample/shift timing relative to clock edges.

### Command & Data FIFOs
- **TX FIFO**: Accepts 8-bit words. Parallel writes to `TXDATA` are buffered; data is shifted out serially per the command (direction and length).
- **RX FIFO**: Captures serial input and packs into 8-bit words; software reads via `RXDATA`.
- **Command FIFO**: Software writes commands specifying direction (TX, RX, bidirectional), transfer length in bits, and target chip select. Commands are executed in FIFO order.

### SPI Transfer Protocol
- **Chip Select Assertion**: CSB[i] is pulled low before transfer; timing is programmable (setup cycles).
- **Clock Generation**: SCK toggles at the configured rate; inactive state per CPOL.
- **Data Shifting**: On each clock edge (per CPHA), either shift out (TX) or shift in (RX) data. In bidirectional mode, both occur simultaneously.
- **Chip Select Negation**: CSB[i] is released (high) after the last bit; hold time is programmable.

### Error Handling
- **TX Underflow**: If TX FIFO is empty during a TX transfer, `intr_error_o` is asserted and the transfer may abort (hardware dependent).
- **RX Overflow**: If RX FIFO is full and new data arrives, `intr_error_o` is asserted; excess data may be lost.
- **Abort**: Software can issue an abort command to cease the current transfer and flush FIFOs.

### Interrupts & Status
- **TX Complete**: When all enqueued TX transfers are done and TX FIFO is empty, `intr_spi_event_o` may pulse.
- **RX Data Ready**: When RX FIFO has at least one word, `intr_spi_event_o` may be asserted (configurable).
- **Error Interrupt**: On any error condition, `intr_error_o` is asserted.
- **Status Register**: Reflects current SPI state (idle, busy, transfer phase), FIFO occupancy, and error flags.

### Pass-Through Mode
- If `NumCS == 1` and `passthrough_i.passthrough_en` is asserted, the external `passthrough_i` signals override all internally-generated SPI outputs. This allows external logic to control the SPI bus directly.
- If `NumCS > 1`, pass-through is disabled and `passthrough_i` must remain de-asserted.

## Multi-Chip-Select Operation
- Up to `NumCS` chip select lines are independently controlled. Each command in the command FIFO specifies the target CS index.
- `cio_csb_o[i]` and `cio_csb_en_o[i]` manage CS line `i` independently; only the active CS is driven low, others remain high.

## Timing & Performance
- **Clock Divider**: Configurable via `CONFIG` register; SCK frequency is `clk_i / (2 * divider + 2)` or similar (implementation-dependent).
- **Command Latency**: Commands are consumed from the FIFO on each cycle a transfer is not in progress; typical throughput is one command per clock if FIFOs are not empty/full.
- **Transfer Rate**: Bit rate on the SPI bus depends on the clock divider and mode (1 bit/cycle in Standard, 2 bits/cycle in Dual, 4 bits/cycle in Quad).

## Synchronization & Clock Domains
- All core logic (FIFOs, command state machine, register interface) is synchronous to `clk_i`.
- SPI I/O is driven directly by `clk_i`-based logic; no separate SPI clock domain.
- Alerts are synchronized asynchronously (if `AlertAsyncOn[i]` is high) or synchronously from `clk_i` to the system reset/clock.

## Example Scenario

1. Software writes to `CONTROL` register to enable output and select Quad mode, CPOL=0, CPHA=0.
2. Software writes to `TXDATA` FIFO with 4 bytes of TX payload.
3. Software writes a command to `COMMAND` FIFO: direction=TX, length=32 bits, chip_select=0.
4. TopModule asserts CSB[0] low.
5. TopModule generates SCK clock and shifts out TX data on SD[3:0] lines (4 bits per cycle).
6. After 8 clock cycles (32 bits / 4 bits per cycle), the transfer completes.
7. `intr_spi_event_o` is asserted (if enabled).
8. Software reads `STATUS` to confirm idle state and TX FIFO empty.

## Corner Cases & Constraints
- **Back-Pressure**: If TX FIFO runs out during a transfer, behavior depends on configuration: either abort the transfer, insert wait cycles, or assert an error.
- **Clock Polarity**: CPOL affects SCK's inactive state and first edge timing; ensure consistent setup with the target SPI device.
- **Quad Mode on Multi-CS**: In Quad mode, all 4 data lines are used; ensure no other device uses these lines while this CS is active.
- **Pass-Through vs. Internal Control**: Pass-through mode completely overrides internal SPI generation; no arbitration is performed.

