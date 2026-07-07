Design a module called TopModule. This module prepends constant high-order bits to AXI4 transaction IDs, widening the ID field to distinguish sources or add hierarchy information to transactions passing through it.

## Overview

TopModule acts as an ID-prepending bridge between a narrower-ID slave port and a wider-ID master port on an AXI4 bus. Each write address (AW) and read address (AR) channel request arriving on the slave side has its ID field extended by prepending a constant `pre_id_i` value in the high bits, while all other fields pass through unchanged. Write data (W), write response (B), and read data (R) channels pass through the master side with ID stripping in the return path — the prepended bits are removed from response IDs before returning them to the slave side.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `NoBus` | Number of independent AXI4 buses to bridge. | ≥ 1. |
| `AxiIdWidthSlvPort` | Width of the AXI4 ID field on the slave (upstream) side, in bits. | ≥ 1. |
| `AxiIdWidthMstPort` | Width of the AXI4 ID field on the master (downstream) side, in bits. | Must be > `AxiIdWidthSlvPort`. |
| `PreIdWidth` | Width of the prepended ID bits, in bits. | Automatically `AxiIdWidthMstPort - AxiIdWidthSlvPort`. |
| `slv_aw_chan_t`, `slv_w_chan_t`, `slv_b_chan_t`, `slv_ar_chan_t`, `slv_r_chan_t` | Struct types for the slave-side AXI4 channels. | User-supplied; define packed structs for address write, write data, write response, address read, read data. |
| `mst_aw_chan_t`, `mst_w_chan_t`, `mst_b_chan_t`, `mst_ar_chan_t`, `mst_r_chan_t` | Struct types for the master-side AXI4 channels. | User-supplied; define packed structs for AXI4 channels, with ID widths matching `AxiIdWidthMstPort`. |

## Interface

### Clock and Reset
- `clk_i`: input, clock.
- `rst_ni`: input, active-low asynchronous reset.

### Configuration
- `pre_id_i`: input, `PreIdWidth` bits. Constant value to prepend to slave IDs.

### Slave Port (Upstream / Input Channels)
For each of `NoBus` instances:

- `slv_aw_chans_i`: input, array `[NoBus-1:0]` of `slv_aw_chan_t`. Address write channel requests.
- `slv_aw_valids_i`: input, array `[NoBus-1:0]` of logic. Valid flags for `slv_aw_chans_i`.
- `slv_aw_readies_o`: output, array `[NoBus-1:0]` of logic. Ready flags for `slv_aw_chans_i`.

- `slv_w_chans_i`: input, array `[NoBus-1:0]` of `slv_w_chan_t`. Write data channel.
- `slv_w_valids_i`: input, array `[NoBus-1:0]` of logic. Valid flags for `slv_w_chans_i`.
- `slv_w_readies_o`: output, array `[NoBus-1:0]` of logic. Ready flags for `slv_w_chans_i`.

- `slv_b_chans_o`: output, array `[NoBus-1:0]` of `slv_b_chan_t`. Write response channel.
- `slv_b_valids_o`: output, array `[NoBus-1:0]` of logic. Valid flags for `slv_b_chans_o`.
- `slv_b_readies_i`: input, array `[NoBus-1:0]` of logic. Ready flags for `slv_b_chans_o`.

- `slv_ar_chans_i`: input, array `[NoBus-1:0]` of `slv_ar_chan_t`. Address read channel requests.
- `slv_ar_valids_i`: input, array `[NoBus-1:0]` of logic. Valid flags for `slv_ar_chans_i`.
- `slv_ar_readies_o`: output, array `[NoBus-1:0]` of logic. Ready flags for `slv_ar_chans_i`.

- `slv_r_chans_o`: output, array `[NoBus-1:0]` of `slv_r_chan_t`. Read data channel.
- `slv_r_valids_o`: output, array `[NoBus-1:0]` of logic. Valid flags for `slv_r_chans_o`.
- `slv_r_readies_i`: input, array `[NoBus-1:0]` of logic. Ready flags for `slv_r_chans_o`.

### Master Port (Downstream / Output Channels)
For each of `NoBus` instances:

- `mst_aw_chans_o`: output, array `[NoBus-1:0]` of `mst_aw_chan_t`. Address write channel requests (widened).
- `mst_aw_valids_o`: output, array `[NoBus-1:0]` of logic. Valid flags for `mst_aw_chans_o`.
- `mst_aw_readies_i`: input, array `[NoBus-1:0]` of logic. Ready flags for `mst_aw_chans_o`.

- `mst_w_chans_o`: output, array `[NoBus-1:0]` of `mst_w_chan_t`. Write data channel (passed through).
- `mst_w_valids_o`: output, array `[NoBus-1:0]` of logic. Valid flags for `mst_w_chans_o`.
- `mst_w_readies_i`: input, array `[NoBus-1:0]` of logic. Ready flags for `mst_w_chans_o`.

- `mst_b_chans_i`: input, array `[NoBus-1:0]` of `mst_b_chan_t`. Write response channel (from downstream).
- `mst_b_valids_i`: input, array `[NoBus-1:0]` of logic. Valid flags for `mst_b_chans_i`.
- `mst_b_readies_o`: output, array `[NoBus-1:0]` of logic. Ready flags for `mst_b_chans_i`.

- `mst_ar_chans_o`: output, array `[NoBus-1:0]` of `mst_ar_chan_t`. Address read channel requests (widened).
- `mst_ar_valids_o`: output, array `[NoBus-1:0]` of logic. Valid flags for `mst_ar_chans_o`.
- `mst_ar_readies_i`: input, array `[NoBus-1:0]` of logic. Ready flags for `mst_ar_chans_o`.

- `mst_r_chans_i`: input, array `[NoBus-1:0]` of `mst_r_chan_t`. Read data channel (from downstream).
- `mst_r_valids_i`: input, array `[NoBus-1:0]` of logic. Valid flags for `mst_r_chans_i`.
- `mst_r_readies_o`: output, array `[NoBus-1:0]` of logic. Ready flags for `mst_r_chans_i`.

## Behavioral Requirements

- **ID Prepending (Forward Path).** When a write address or read address request is accepted on the slave side (valid & ready handshake), the module forms the outgoing master-side request with the ID field modified as follows: the high `PreIdWidth` bits of the master ID are set to `pre_id_i`, and the low `AxiIdWidthSlvPort` bits are set to the slave-side ID. All other AW and AR fields (address, burst, length, size, etc.) pass through unchanged.

- **ID Stripping (Return Path).** When write response (B channel) or read data (R channel) arrives from the master side, the module extracts the low `AxiIdWidthSlvPort` bits of the master ID and forwards them as the slave-side ID. The remainder of the response (response code, data, flags) passes through unchanged.

- **W Channel Passthrough.** Write data (W channel) and control signals pass through unchanged between slave and master sides.

- **Handshake Transparency.** Valid and ready signals pass through unchanged on all channels; there is no buffering or pipeline stage. A slave-side valid/ready handshake directly propagates to the master side, and master responses directly propagate back.

- **Reset.** On release from reset (`rst_ni` assertion), the module is combinational and has no state to initialize.

- **Multi-Bus Support.** The module implements `NoBus` independent ID prependers, each operating on its own AXI4 channel pair. Each bus index operates independently with no cross-talk.

## Throughput and Latency

- **Throughput:** No artificial backpressure; throughput is limited only by the downstream master port. One transaction can be accepted and forwarded per clock cycle on each channel where the upstream and downstream both assert handshake signals.
- **Latency:** Combinational. Outputs respond immediately (same cycle) to input changes.

## Clock and Reset Domains

- All ports operate in the same `clk_i` domain.
- Reset is asynchronous (`rst_ni`, active low). The module is combinational and has no reset-dependent state to clear.

## Example Behavior

Assume `AxiIdWidthSlvPort = 4`, `AxiIdWidthMstPort = 6`, `PreIdWidth = 2`, and `pre_id_i = 2'b11`:

- Slave-side AW request with `id = 4'b0101`:
  - Master-side AW output: `id = 6'b110101` (prepended `11` in high bits, original `0101` in low bits).
- Master-side B response with `id = 6'b110101`:
  - Slave-side B output: `id = 4'b0101` (low 4 bits extracted).

All other fields (address, len, size, burst, resp, data, last, user, etc.) remain unchanged through the prepending and stripping process.
