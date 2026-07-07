Design a module called TopModule. This module is a combinational SECDED (Single Error Correction, Double Error Detection) encoder using Hamming codes to encode 64-bit data into a 72-bit codeword.

## Overview

TopModule implements a Hamming-code SECDED encoder for fault-tolerant storage or transmission. It takes 64 bits of input data and produces a 72-bit output codeword: the original 64 bits plus 8 parity bits. The module is purely combinational — there is no clock, no reset, and no state. The encoding is deterministic and single-cycle.

## Parameters

None.

## Interface

All ports are combinational; there is no clock or reset.

| Port     | Direction | Width | Description |
|----------|-----------|-------|-------------|
| `data_i` | input     | 64    | Input data to encode. |
| `data_o` | output    | 72    | Encoded output: input data in bits [63:0] and parity bits in bits [71:64]. |

## Behavioral requirements

- **SECDED encoding (Hamming).** The module implements a Hamming linear code optimized for single error correction and double error detection. Each output parity bit is a linear combination (XOR) of specific input bits, as defined by the Hamming parity-check matrix.
- **Output composition.** `data_o[63:0]` is identical to `data_i[63:0]`. `data_o[71:64]` contains 8 parity bits computed from the input data and specific bit positions.
- **Deterministic computation.** `data_o` is purely combinational and responds immediately to changes in `data_i` with no latency.
- **Correctness.** The encoding is correct if, when the 72-bit codeword is fed through a corresponding Hamming SECDED decoder with no bit errors, the decoder recovers the original 64 bits and reports zero syndrome (no error).

## Example

With `data_i = 64'h0000000000000000`:

| Signal | Value |
|--------|-------|
| `data_o[71:64]` | 8'h00 |
| `data_o[63:0]` | 64'h0000000000000000 |

With `data_i = 64'hFFFFFFFFFFFFFFFF`:

| Signal | Value |
|--------|-------|
| `data_o[71:64]` | 8'hFF |
| `data_o[63:0]` | 64'hFFFFFFFFFFFFFFFF |
