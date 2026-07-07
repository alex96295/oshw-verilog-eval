Design a module called TopModule. This module is a memory-mapped register file behind an AXI4-Lite slave port, providing hardware registers with configurable bit widths, read/write permissions, and optional read-only masks.

## Overview

TopModule presents a memory-mapped register file accessible via an AXI4-Lite slave interface. It implements a set of hardware registers (R/O, W/O, or R/W) with configurable address space, bit widths, and access masks. Software can read or write these registers via AXI4-Lite transactions; writes are gated by write-enable masks, and read-only bits return fixed values regardless of write attempts. The module is useful for configuration, status, and control registers in AXI4-Lite-based systems.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `AxiAddrWidth` | Width of the AXI4-Lite address field, in bits. | ≥ 1. |
| `AxiDataWidth` | Width of the AXI4-Lite data field, in bits. | ≥ 32. |
| `NumRegs` | Number of registers in the file. | ≥ 1. |
| `aw_chan_t`, `w_chan_t`, `b_chan_t`, `ar_chan_t`, `r_chan_t` | Struct types for AXI4-Lite channels. | User-supplied. |
| `RegConfig` | Array of register configuration. | Array `[0:NumRegs-1]` specifying address, width, access type (R/W/RO/WO), and masks for each register. |

## Interface

### Clock and Reset
- `clk_i`: input, clock.
- `rst_ni`: input, active-low asynchronous reset.

### Slave Port (Upstream; AXI4-Lite)
- `aw_chan_i`: input, `aw_chan_t`. Address write channel.
- `aw_valid_i`: input, logic. Valid flag for address write.
- `aw_ready_o`: output, logic. Ready flag for address write.

- `w_chan_i`: input, `w_chan_t`. Write data channel.
- `w_valid_i`: input, logic. Valid flag for write data.
- `w_ready_o`: output, logic. Ready flag for write data.

- `b_chan_o`: output, `b_chan_t`. Write response channel.
- `b_valid_o`: output, logic. Valid flag for write response.
- `b_ready_i`: input, logic. Ready flag for write response.

- `ar_chan_i`: input, `ar_chan_t`. Address read channel.
- `ar_valid_i`: input, logic. Valid flag for address read.
- `ar_ready_o`: output, logic. Ready flag for address read.

- `r_chan_o`: output, `r_chan_t`. Read data channel.
- `r_valid_o`: output, logic. Valid flag for read data.
- `r_ready_i`: input, logic. Ready flag for read data.

### Register Interface (Optional; For External Logic)
For each register (indexed by register number, not address):

- `reg_rd_data_o`: output, array of logic `[AxiDataWidth-1:0]`. Current register values.
- `reg_wr_en_i`: input, array of logic. Write enables from external logic.
- `reg_wr_data_i`: input, array of logic `[AxiDataWidth-1:0]`. Write data from external logic.
- `reg_rd_en_i`: input, array of logic. Read enables from external logic.

## Behavioral Requirements

- **Address Map.** Each register is assigned a base address within the AXI4-Lite address space. Addresses are typically word-aligned; lower bits select byte lanes within the word (per AXI4-Lite convention).

- **Write Path.** On an AW/W handshake:
  1. Address is decoded to select target register.
  2. Write data is extracted from the W payload according to write strobes (byte enables).
  3. If the register is R/W or W/O, bits specified in the write-enable mask are updated. Read-only bits are not modified.
  4. A write response is generated (OKAY if address is valid, DECERR if not).

- **Read Path.** On an AR handshake:
  1. Address is decoded to select target register.
  2. Register value is sampled and padded/masked as needed.
  3. If the register is R/O, the stored constant value is returned. If R/W or W/O, the current register value is returned.
  4. Read data is returned with response code (OKAY if valid, SLVERR or DECERR if invalid).

- **Write-Enable Masks.** For each R/W register, a write-enable mask specifies which bits are writable. Write attempts to read-only bits are silently discarded; the bits retain their current values.

- **Read-Only Masks.** R/O registers have fixed values that are returned on every read, regardless of any prior writes.

- **Access Decoding.** Addresses outside the register file return decode errors (DECERR). Misaligned addresses (depending on register width) may also return errors.

- **Atomic Writes.** Single-word writes are atomic; partial writes (e.g., writing to a 64-bit register with a 32-bit strobe) may write only the selected bytes (or stall, depending on configuration).

- **Response Generation.** All writes and reads receive timely responses. Responses include AXI-compliant response codes (OKAY, SLVERR, DECERR).

- **Reset.** On release from reset (`rst_ni` assertion), all R/W registers are cleared or initialized to their reset values. R/O registers always return their fixed values.

- **Handshake Transparency.** AXI4-Lite valid/ready handshaking is respected; the module may pipeline reads/writes if necessary.

## Throughput and Latency

- **Throughput:** One AW/W and one AR per clock cycle (if both write and read ports are ready).
- **Latency:** Combinational address decoding; register updates on next clock for writes; reads may have 1-2 cycle latency depending on buffering.

## Clock and Reset Domains

- All ports operate in the same `clk_i` domain.
- Reset is asynchronous (`rst_ni`, active low).

## Example Behavior

Assume 4 registers configured as follows:

| Register | Address | Width | Type | Reset Value |
|----------|---------|-------|------|-------------|
| 0 | 0x00 | 32 | R/W | 0 |
| 1 | 0x04 | 32 | R/O | 0xDEADBEEF |
| 2 | 0x08 | 32 | W/O | (write-only) |
| 3 | 0x0C | 32 | R/W | 0 |

1. Master writes address 0x00 with data 32'h12345678 (all strobes):
   - Register 0 is updated to 0x12345678.
   - B response returns OKAY.

2. Master reads address 0x04:
   - Register 1 returns its fixed value 0xDEADBEEF.
   - R response returns OKAY with data 0xDEADBEEF.

3. Master writes address 0x08 with data 32'hFFFFFFFF:
   - Register 2 is latched (W/O; no read possible).
   - B response returns OKAY.

4. Master reads address 0x08 (R/O not defined):
   - R response returns SLVERR or DECERR.

The module provides a simple, AXI4-Lite-compliant register file for configuration and status.
