Design a module called TopModule. This module is a combinational Galois-field GF(2^n) multiplier, computing the product of two operands over the Galois field defined by a fixed irreducible polynomial.

## Overview

TopModule implements combinational multiplication in the Galois field GF(2^n). Given two n-bit operands (`operand_a_i` and `operand_b_i`), the module computes their product modulo an irreducible polynomial (`IPoly`) and outputs the n-bit result. The multiplication is performed either fully combinationally or in a pipelined manner across multiple cycles, depending on the `StagesPerCycle` parameter. In pipelined mode, a handshake-style request-acknowledge protocol controls the pipeline flow.

## Parameters

| Parameter               | Meaning | Constraint |
|-------------------------|---------|------------|
| `Width`                 | Field width, in bits. Defines GF(2^Width). | >= 1 (int unsigned). Default: 32. |
| `StagesPerCycle`        | Parallelism factor for combinational stages per cycle. | Must divide `Width` evenly and be a power of 2. Default: Width. |
| `IPoly`                 | The irreducible polynomial (in bit-vector form). | Width-bit value. Default: NIST GF(2^32) polynomial. |
| `OutputZeroUntilAck`    | If 1, output is zero until completion; if 0, output shows operand_a during operation. | 0 or 1 (bit). Default: 0. |

When `StagesPerCycle == Width`, the multiplier is fully combinational (1-cycle latency). For smaller `StagesPerCycle`, multiplication is decomposed into multiple cycles with an FSM pipeline.

## Interface

| Port         | Direction | Width      | Description |
|--------------|-----------|------------|-------------|
| `clk_i`      | input     | 1          | System clock (active on rising edge). |
| `rst_ni`     | input     | 1          | Active-low synchronous reset. |
| `req_i`      | input     | 1          | Request valid (initiate or continue multiplication). |
| `operand_a_i`| input     | `Width`    | Multiplicand (first operand). |
| `operand_b_i`| input     | `Width`    | Multiplier (second operand); interpreted as Loops slices of StagesPerCycle bits each. |
| `ack_pre_o`  | output    | 1          | Pre-acknowledgment: asserted on the cycle before the final result is ready (pipelined mode only). |
| `ack_o`      | output    | 1          | Acknowledgment: asserted on the cycle when the final result is ready and output is valid. |
| `prod_o`     | output    | `Width`    | Product output (final result when ack_o is asserted). |

## Behavioral requirements

### Fully combinational mode (StagesPerCycle == Width)

- `ack_o` is permanently asserted (always 1).
- `ack_pre_o` is unused (tied to 0).
- `prod_o` combinationally reflects the product of `operand_a_i` and `operand_b_i` computed in a single cycle.
- Latency: 0 cycles (combinational).

### Pipelined mode (StagesPerCycle < Width)

- **Operational phases.** The multiplication is decomposed into `Loops = Width / StagesPerCycle` phases. In each phase, a partial product is computed from `StagesPerCycle` bits of `operand_b`.
- **Request-acknowledge handshake.** When `req_i = 1`, the multiplier advances one phase per cycle (if not at the final phase). `ack_pre_o` is asserted when the counter is at `Loops - 2`, indicating one more cycle remains. `ack_o` is asserted when the counter reaches `Loops - 1`, indicating the result is final.
- **Pipeline stages.** At each phase, the module generates a partial product matrix by repeatedly doubling (in GF) the multiplicand operand_a, then selects bits from operand_b to perform accumulation (XOR). The result is registered and fed back for the next iteration.
- **Output behavior.** Before `ack_o` is asserted, `prod_o` reflects intermediate values. When `OutputZeroUntilAck = 1`, `prod_o` is forced to zero during computation and reveals the final result only when `ack_o` is asserted. When `OutputZeroUntilAck = 0`, `prod_o` shows `operand_a_i` during computation.
- **Phase alignment.** An internal counter tracks the current phase. When `req_i & ack_o` (handshake complete), the counter resets to 0.

## GF(2^n) arithmetic

- **Multiplication algorithm.** The product is computed by treating the second operand as a polynomial in GF(2) and iteratively multiplying by powers of the first operand, accumulating partial results with XOR.
- **Reduction.** All intermediate and final results are reduced modulo `IPoly` using a conditional XOR when the MSB is 1.
- **Doubling in GF.** Doubling operand A (GF(2) multiplication by x) is implemented as a left shift followed by a conditional XOR with IPoly if the MSB was 1.

## Example (fully combinational, Width = 8, IPoly = 0x1D)

| `operand_a_i` | `operand_b_i` | `prod_o` |
|---------------|---------------|----------|
| 0x02          | 0x02          | 0x04     |
| 0x03          | 0x05          | 0x0F     |
| 0x53          | 0xCA          | 0x01     |
| 0xFF          | 0xFF          | 0xE5     |

Results are GF(2^8) products; different values from integer multiplication due to polynomial reduction.

## Example (pipelined, Width = 8, StagesPerCycle = 4, Loops = 2, IPoly = 0x1D)

| Cycle | `req_i` | `ack_pre_o` | `ack_o` | Counter | `prod_o` (intermediate) | `prod_o` (final when ack_o=1) |
|-------|---------|-------------|---------|---------|-------------------------|-------------------------------|
| 0     | 1       | 0           | 0       | 0       | 0xXX (depends on init)  | —                             |
| 1     | 1       | 0           | 1       | 1       | (result of phase 0)     | Final product (phase 1 done)  |
| 2     | 0       | 0           | 0       | 0       | (held or zeroed)        | —                             |

When a request starts (cycle 0), phase 0 completes at cycle 1, and `ack_o` is asserted with the final result.
