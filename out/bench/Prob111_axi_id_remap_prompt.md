Design a module called TopModule. This module remaps a wide or sparse AXI4 ID space onto a narrower one using a lookup table, preserving the original ID ordering guarantees while reducing ID width.

## Overview

TopModule acts as an ID remapper that narrows and consolidates the ID space on an AXI4 bus. It accepts transactions with a wide or sparsely-used ID field on the slave side and maps them to a narrower ID range on the master side via a user-provided lookup table. The module preserves the AXI4 requirement that responses are returned in the order matching their corresponding requests when IDs are unique. Write data (W), address read (AR), and write response (B) channels also participate in ID remapping where needed.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `AxiIdWidthSlvPort` | Width of the AXI4 ID field on the slave (upstream) side, in bits. | ≥ 1; typically larger than `AxiIdWidthMstPort`. |
| `AxiIdWidthMstPort` | Width of the AXI4 ID field on the master (downstream) side, in bits. | ≥ 1; typically smaller than `AxiIdWidthSlvPort`. |
| `slv_aw_chan_t`, `slv_w_chan_t`, `slv_b_chan_t`, `slv_ar_chan_t`, `slv_r_chan_t` | Struct types for the slave-side AXI4 channels. | User-supplied; define packed structs for AXI4 channels with ID width `AxiIdWidthSlvPort`. |
| `mst_aw_chan_t`, `mst_w_chan_t`, `mst_b_chan_t`, `mst_ar_chan_t`, `mst_r_chan_t` | Struct types for the master-side AXI4 channels. | User-supplied; define packed structs for AXI4 channels with ID width `AxiIdWidthMstPort`. |
| `IdMapTable` | Lookup table for ID remapping. | Array of size `2**AxiIdWidthSlvPort`, where `IdMapTable[slave_id] = master_id`. |

## Interface

### Clock and Reset
- `clk_i`: input, clock.
- `rst_ni`: input, active-low asynchronous reset.

### Slave Port (Upstream / Input Channels)
- `slv_aw_chans_i`: input, `slv_aw_chan_t`. Address write channel requests.
- `slv_aw_valids_i`: input, logic. Valid flag for address write.
- `slv_aw_readies_o`: output, logic. Ready flag for address write.

- `slv_w_chans_i`: input, `slv_w_chan_t`. Write data channel.
- `slv_w_valids_i`: input, logic. Valid flag for write data.
- `slv_w_readies_o`: output, logic. Ready flag for write data.

- `slv_b_chans_o`: output, `slv_b_chan_t`. Write response channel.
- `slv_b_valids_o`: output, logic. Valid flag for write response.
- `slv_b_readies_i`: input, logic. Ready flag for write response.

- `slv_ar_chans_i`: input, `slv_ar_chan_t`. Address read channel requests.
- `slv_ar_valids_i`: input, logic. Valid flag for address read.
- `slv_ar_readies_o`: output, logic. Ready flag for address read.

- `slv_r_chans_o`: output, `slv_r_chan_t`. Read data channel.
- `slv_r_valids_o`: output, logic. Valid flag for read data.
- `slv_r_readies_i`: input, logic. Ready flag for read data.

### Master Port (Downstream / Output Channels)
- `mst_aw_chans_o`: output, `mst_aw_chan_t`. Address write channel requests (remapped).
- `mst_aw_valids_o`: output, logic. Valid flag for address write.
- `mst_aw_readies_i`: input, logic. Ready flag for address write.

- `mst_w_chans_o`: output, `mst_w_chan_t`. Write data channel (passed through).
- `mst_w_valids_o`: output, logic. Valid flag for write data.
- `mst_w_readies_i`: input, logic. Ready flag for write data.

- `mst_b_chans_i`: input, `mst_b_chan_t`. Write response channel (from downstream).
- `mst_b_valids_i`: input, logic. Valid flag for write response.
- `mst_b_readies_o`: output, logic. Ready flag for write response.

- `mst_ar_chans_o`: output, `mst_ar_chan_t`. Address read channel requests (remapped).
- `mst_ar_valids_o`: output, logic. Valid flag for address read.
- `mst_ar_readies_i`: input, logic. Ready flag for address read.

- `mst_r_chans_i`: input, `mst_r_chan_t`. Read data channel (from downstream).
- `mst_r_valids_i`: input, logic. Valid flag for read data.
- `mst_r_readies_o`: output, logic. Ready flag for read data.

## Behavioral Requirements

- **ID Remapping (Forward Path).** When an address (AW or AR) request is accepted on the slave side, the module applies the lookup table: `master_id = IdMapTable[slave_id]`. The remapped ID is inserted into the corresponding master-side request. All other fields remain unchanged.

- **ID Unmapping (Return Path).** When a response (B or R channel) arrives from the master side, the module performs a reverse lookup to restore the original slave-side ID. This reverse mapping must be maintained by software (or the lookup table must support efficient inverse queries). The response is forwarded with the slave-side ID restored.

- **ID Ordering.** The module ensures that if two slave-side requests have the same remapped ID (`IdMapTable[id_a] == IdMapTable[id_b]`), they are serialized — the second request is not accepted until the first's response completes. This preserves AXI4's requirement that responses with the same ID are returned in order.

- **Write Data Passthrough.** Write data (W channel) passes through with no ID transformation. The module may buffer or pipeline W-channel requests to align with remapped AW requests.

- **Handshake Transparency.** Valid and ready signals pass through on all channels; there is no artificial deadlock risk if the upstream and downstream are ready.

- **Reset.** On release from reset (`rst_ni` assertion), any buffered state is cleared; outstanding transactions are forgotten.

- **Combinational or Pipelined.** ID remapping itself is combinational; a valid AW/AR input on the slave side immediately produces a valid output on the master side with the remapped ID (subject to downstream ready and ordering constraints).

## Throughput and Latency

- **Throughput:** One accepted slave request translates to one master request per clock cycle, subject to ID ordering constraints and downstream readiness.
- **Latency:** Combinational for the ID remap itself; total latency depends on buffering needs for W-channel alignment.

## Clock and Reset Domains

- All ports operate in the same `clk_i` domain.
- Reset is asynchronous (`rst_ni`, active low). State (if any) is cleared on reset.

## Example Behavior

Assume a sparse ID space with only a few active IDs, and the lookup table maps them as follows:
- `IdMapTable[0] = 0`
- `IdMapTable[5] = 1`
- `IdMapTable[15] = 2`
- Other entries are don't-care.

- Slave-side AW request with `id = 5`: Master-side AW output has `id = 1`.
- Slave-side AR request with `id = 15`: Master-side AR output has `id = 2`.
- Master-side B response with `id = 1`: Slave-side B output has `id = 5` (after reverse lookup or in-flight tracking).

The module prevents two slave requests with the same remapped ID from having overlapping lifetimes on the master side, ensuring correct response ordering.
