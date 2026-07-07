Design a module called TopModule. This module is a dual-port AXI4-Lite mailbox with FIFOs and programmable threshold/interrupt, enabling inter-domain communication with flow control and signaling between two asynchronous or synchronous domains.

## Overview

TopModule implements a dual-port AXI4-Lite mailbox: two independent AXI4-Lite slave ports (Port A and Port B) provide write/read access to shared FIFO buffers. Each port can push messages to the other port and receive messages via its own input FIFO. Programmable threshold and interrupt signals allow one port to be notified when the other port has written data. The module is useful for inter-processor communication (IPC), interrupt signaling, and asynchronous message passing within a system.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `AxiAddrWidth` | Width of the AXI4-Lite address field, in bits. | ≥ 1; typically 2-8 bits for register map. |
| `AxiDataWidth` | Width of the AXI4-Lite data field, in bits. | ≥ 32. |
| `FifoDepth` | Depth of each FIFO (in data words). | ≥ 2. |
| `aw_chan_t`, `w_chan_t`, `b_chan_t`, `ar_chan_t`, `r_chan_t` | Struct types for AXI4-Lite channels. | User-supplied. |

## Interface

### Clock and Reset
- `clk_i`: input, clock.
- `rst_ni`: input, active-low asynchronous reset.

### Slave Port A (AXI4-Lite)
- `port_a_aw_chan_i`: input, `aw_chan_t`. Address write channel.
- `port_a_aw_valid_i`: input, logic. Valid flag for address write.
- `port_a_aw_ready_o`: output, logic. Ready flag for address write.

- `port_a_w_chan_i`: input, `w_chan_t`. Write data channel.
- `port_a_w_valid_i`: input, logic. Valid flag for write data.
- `port_a_w_ready_o`: output, logic. Ready flag for write data.

- `port_a_b_chan_o`: output, `b_chan_t`. Write response channel.
- `port_a_b_valid_o`: output, logic. Valid flag for write response.
- `port_a_b_ready_i`: input, logic. Ready flag for write response.

- `port_a_ar_chan_i`: input, `ar_chan_t`. Address read channel.
- `port_a_ar_valid_i`: input, logic. Valid flag for address read.
- `port_a_ar_ready_o`: output, logic. Ready flag for address read.

- `port_a_r_chan_o`: output, `r_chan_t`. Read data channel.
- `port_a_r_valid_o`: output, logic. Valid flag for read data.
- `port_a_r_ready_i`: input, logic. Ready flag for read data.

### Slave Port B (AXI4-Lite)
- `port_b_aw_chan_i`: input, `aw_chan_t`. Address write channel.
- `port_b_aw_valid_i`: input, logic. Valid flag for address write.
- `port_b_aw_ready_o`: output, logic. Ready flag for address write.

- `port_b_w_chan_i`: input, `w_chan_t`. Write data channel.
- `port_b_w_valid_i`: input, logic. Valid flag for write data.
- `port_b_w_ready_o`: output, logic. Ready flag for write data.

- `port_b_b_chan_o`: output, `b_chan_t`. Write response channel.
- `port_b_b_valid_o`: output, logic. Valid flag for write response.
- `port_b_b_ready_i`: input, logic. Ready flag for write response.

- `port_b_ar_chan_i`: input, `ar_chan_t`. Address read channel.
- `port_b_ar_valid_i`: input, logic. Valid flag for address read.
- `port_b_ar_ready_o`: output, logic. Ready flag for address read.

- `port_b_r_chan_o`: output, `r_chan_t`. Read data channel.
- `port_b_r_valid_o`: output, logic. Valid flag for read data.
- `port_b_r_ready_i`: input, logic. Ready flag for read data.

### Interrupt Signals
- `irq_a_o`: output, logic. Interrupt signal for Port A (asserted when Port B has written data and threshold is met).
- `irq_b_o`: output, logic. Interrupt signal for Port B (asserted when Port A has written data and threshold is met).

## Register Map (Per Port; Address-Mapped)

| Address | Name | Function |
|---------|------|----------|
| 0x00 | DATA | Message data (read/write FIFO). |
| 0x04 | STATUS | FIFO status (full, empty, count). |
| 0x08 | THRESH | Interrupt threshold (number of messages). |
| 0x0C | CTRL | Control register (enable, clear FIFO). |

## Behavioral Requirements

- **Dual-Port FIFOs.** The module maintains two independent FIFOs:
  - FIFO A: messages written by Port B, read by Port A.
  - FIFO B: messages written by Port A, read by Port B.

- **Write Path.** When Port A writes to address 0x00 (DATA register), the data is pushed into FIFO B. Similarly, Port B writes to FIFO A. If a FIFO is full, the write is stalled (ready = 0).

- **Read Path.** When Port A reads from address 0x00, data is popped from FIFO A. Reads from a non-empty FIFO return data with OKAY response. Reads from an empty FIFO return zeros with SLVERR (or wait if buffered).

- **Status Register.** Reads to address 0x04 return:
  - Bit [0]: FIFO empty flag.
  - Bit [1]: FIFO full flag.
  - Bits [7:2]: FIFO occupancy (number of messages).

- **Threshold Register.** Writes to address 0x08 set the interrupt threshold for that port. The IRQ is asserted when the corresponding FIFO occupancy >= threshold.

- **Interrupt Generation.** `irq_a_o` is asserted when FIFO A occupancy >= Port A's threshold. Similarly for Port B. This allows event-driven notification of arriving messages.

- **FIFO Overflow/Underflow.** Writes to a full FIFO are stalled (not accepted). Reads from an empty FIFO return error responses (SLVERR) or zeros.

- **Atomicity.** Single-word messages are atomic; no partial writes or reads.

- **Reset.** On release from reset (`rst_ni` assertion), all FIFOs are emptied, thresholds are cleared, and IRQs are deasserted.

- **Handshake Transparency.** AXI4-Lite handshakes are processed normally; stalls are reflected in the ready signals.

## Throughput and Latency

- **Throughput:** One message per port per clock cycle (if both ports are ready and FIFOs have space/data).
- **Latency:** Combinational address decoding; FIFO operations are 1-2 cycles depending on buffering.

## Clock and Reset Domains

- All ports operate in the same `clk_i` domain. If Port A and Port B are in different clock domains, clock-domain crossing logic (CDC) is required (not shown here).
- Reset is asynchronous (`rst_ni`, active low).

## Example Behavior

1. Port A writes 32'hDEADBEEF to address 0x00:
   - Data is pushed into FIFO B.
   - FIFO B occupancy increases; if >= threshold, `irq_b_o` asserts.

2. Port B reads from address 0x00:
   - If FIFO B has data, 32'hDEADBEEF is returned with OKAY.
   - FIFO B occupancy decreases; if < threshold, `irq_b_o` deasserts.

3. Port A reads status (address 0x04):
   - Returns FIFO A's occupancy, full, empty flags.

4. Port A writes threshold (address 0x08) with value 2:
   - IRQ A is asserted when FIFO A has >= 2 messages.

The module enables low-latency inter-processor messaging with programmable interrupt thresholds.
