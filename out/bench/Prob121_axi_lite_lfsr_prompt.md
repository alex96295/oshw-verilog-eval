Design a module called TopModule. This module is a pseudo-random stimulus and response generator for AXI4-Lite transactions, driven by an LFSR, useful for testing and automated stimulus generation.

## Overview

TopModule generates pseudo-random AXI4-Lite traffic using a Linear Feedback Shift Register (LFSR). It can act as either a master (generating random requests) or a slave (generating random responses and ready signals). The module is deterministic and repeatable given the same seed, making it useful for automated testing, randomized verification, and reproducible test scenarios without manual stimulus authoring.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `AxiAddrWidth` | Width of the AXI4-Lite address field, in bits. | ≥ 1. |
| `AxiDataWidth` | Width of the AXI4-Lite data field, in bits. | ≥ 8. |
| `LfsrWidth` | Width of the LFSR state, in bits. | ≥ 4; determines pseudo-random period. |
| `LfsrSeed` | Initial seed for the LFSR. | Positive integer. |

## Interface

### Clock and Reset
- `clk_i`: input, clock.
- `rst_ni`: input, active-low asynchronous reset.

### Control Signals
- `enable_i`: input, logic. Enable LFSR advancement and transaction generation.
- `seed_i`: input, logic `[LfsrWidth-1:0]`. New seed value.
- `seed_valid_i`: input, logic. When asserted with `seed_i`, reinitializes the LFSR to the provided seed.

### As a Master (Stimulus Generator; Example Configuration)

- `aw_addr_o`: output, logic `[AxiAddrWidth-1:0]`. Auto-generated write address.
- `aw_valid_o`: output, logic. Valid flag for address write.
- `aw_ready_i`: input, logic. Ready flag from slave.

- `w_data_o`: output, logic `[AxiDataWidth-1:0]`. Auto-generated write data.
- `w_strb_o`: output, logic `[AxiDataWidth/8-1:0]`. Auto-generated write strobes.
- `w_valid_o`: output, logic. Valid flag for write data.
- `w_ready_i`: input, logic. Ready flag from slave.

- `b_resp_i`: input, logic `[1:0]`. Write response from slave (may be ignored).
- `b_valid_i`: input, logic. Valid flag for write response.
- `b_ready_o`: output, logic. Ready flag for write response.

- `ar_addr_o`: output, logic `[AxiAddrWidth-1:0]`. Auto-generated read address.
- `ar_valid_o`: output, logic. Valid flag for address read.
- `ar_ready_i`: input, logic. Ready flag from slave.

- `r_data_i`: input, logic `[AxiDataWidth-1:0]`. Read data from slave (may be ignored).
- `r_resp_i`: input, logic `[1:0]`. Read response from slave (may be ignored).
- `r_valid_i`: input, logic. Valid flag for read data.
- `r_ready_o`: output, logic. Ready flag for read data.

### As a Slave (Response Generator; Alternate Configuration)

- `aw_addr_i`: input, logic `[AxiAddrWidth-1:0]`. Incoming write address.
- `aw_valid_i`: input, logic. Valid flag for address write.
- `aw_ready_o`: output, logic. Auto-generated ready flag.

- `w_data_i`: input, logic `[AxiDataWidth-1:0]`. Incoming write data.
- `w_strb_i`: input, logic `[AxiDataWidth/8-1:0]`. Incoming write strobes.
- `w_valid_i`: input, logic. Valid flag for write data.
- `w_ready_o`: output, logic. Auto-generated ready flag.

- `b_resp_o`: output, logic `[1:0]`. Auto-generated write response.
- `b_valid_o`: output, logic. Auto-generated valid flag for write response.
- `b_ready_i`: input, logic. Ready flag from master.

- `ar_addr_i`: input, logic `[AxiAddrWidth-1:0]`. Incoming read address.
- `ar_valid_i`: input, logic. Valid flag for address read.
- `ar_ready_o`: output, logic. Auto-generated ready flag.

- `r_data_o`: output, logic `[AxiDataWidth-1:0]`. Auto-generated read data.
- `r_resp_o`: output, logic `[1:0]`. Auto-generated read response.
- `r_valid_o`: output, logic. Auto-generated valid flag for read data.
- `r_ready_i`: input, logic. Ready flag from master.

## Behavioral Requirements

- **LFSR Implementation.** The module implements a Galois or Fibonacci LFSR with feedback taps defined by `LfsrWidth`. On each clock when `enable_i` is asserted, the LFSR state advances deterministically. The sequence is pseudo-random and fully repeatable given the same seed.

- **Master Mode (Stimulus Generation).** When configured as a master:
  - Address outputs (AW, AR) are derived from LFSR state or portions thereof, optionally masked/aligned to valid address ranges.
  - Write data and strobes are derived from LFSR outputs.
  - Valid signals are generated based on LFSR state or a configurable pattern (e.g., valid for N cycles, stall for M cycles).
  - Ready signals from the slave are collected but do not affect the LFSR sequence (deterministic stimulus).

- **Slave Mode (Response Generation).** When configured as a slave:
  - Incoming requests (valid signals) are collected.
  - Ready signals are generated based on LFSR state, simulating varied slave latencies.
  - Write responses are generated with pseudo-random response codes (OKAY, SLVERR, etc.) derived from LFSR.
  - Read responses are generated with pseudo-random data derived from LFSR.
  - The response rate is modulated by LFSR-derived ready signals.

- **Deterministic Repeatability.** The same seed always produces the same transaction sequence, enabling reproducible tests.

- **Seed Management.** When `seed_valid_i` is asserted alongside `seed_i`, the LFSR is reinitialized to the provided seed. This enables mid-simulation restart or multiple independent test phases within a single simulation.

- **Reset.** On release from reset (`rst_ni` assertion), the LFSR is initialized to `LfsrSeed`, all output channels are cleared (valid = 0), and the module is ready for stimulus generation.

- **Enable Control.** When `enable_i` is deasserted, the LFSR state does not advance; outputs remain stable based on the last LFSR value.

## Throughput and Latency

- **Throughput:** One LFSR-driven transaction per clock cycle (if enabled and slave ready).
- **Latency:** Combinational generation of addresses, data, and control signals from LFSR state.

## Clock and Reset Domains

- All ports operate in the same `clk_i` domain.
- Reset is asynchronous (`rst_ni`, active low).

## Example Behavior

With `LfsrWidth = 8`, `LfsrSeed = 8'h7E`:

**Master Mode:**
1. Cycle 0: LFSR = 8'h7E, generates AW to address derived from LFSR (e.g., 0x7E0), W data 8'h7E.
2. Cycle 1: LFSR advances, generates next transaction.
3. Seed can be changed at any time via `seed_valid_i`.

**Slave Mode:**
1. Incoming AW to address 0x1000: module generates ready signal based on LFSR state.
2. Incoming W data: module either accepts or stalls based on LFSR.
3. Module generates B response with pseudo-random resp code.
4. Incoming AR: module generates ready and R response similarly.

The module is useful for functional verification, stress testing, and corner-case exploration without explicit test case authoring.
