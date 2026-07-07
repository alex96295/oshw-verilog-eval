Design a module called TopModule. This module implements a SECDED (single-error-correct, double-error-detect) encoder that converts a 32-bit data word into a 39-bit codeword with error-correction capability.

## Overview

TopModule is a combinational error-correction-code (ECC) encoder that takes a 32-bit data input and produces a 39-bit codeword suitable for SECDED protection. The codeword consists of the original 32 data bits plus 7 parity bits that enable single-bit error correction and double-bit error detection. The encoder uses Hamming code construction with additional overall parity.

## Parameters

None. The module is fixed at 32-bit input and 39-bit output.

## Interface

TopModule is purely combinational; there is no clock or reset.

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `data_i` | input | 32 | Input data word to be encoded. |
| `data_o` | output | 39 | Output codeword: 32 data bits (in positions [31:0]) + 7 parity bits (in positions [38:32]). |

## Behavioral requirements

- **Codeword structure.** The output `data_o[38:0]` is organized as:
  - Bits [31:0]: Original data bits (unchanged).
  - Bit [32]: Parity bit P0 (Hamming parity for bit positions 1, 3, 5, 7, ...).
  - Bit [33]: Parity bit P1 (Hamming parity for bit positions 2, 3, 6, 7, ...).
  - Bit [34]: Parity bit P2 (Hamming parity for bit positions 4, 5, 6, 7, ...).
  - Bit [35]: Parity bit P3 (Hamming parity for bit positions 8–15).
  - Bit [36]: Parity bit P4 (Hamming parity for bit positions 16–31).
  - Bit [37]: Parity bit P5 (reserved or application-specific).
  - Bit [38]: Overall parity bit (XOR of all 39 bits).

- **Parity computation.** Each parity bit is a linear XOR of specific data bit positions according to the Hamming code scheme:
  - P0 = XOR of all data bits at positions where bit 0 of the position index is 1.
  - P1 = XOR of all data bits at positions where bit 1 of the position index is 1.
  - P2 = XOR of all data bits at positions where bit 2 of the position index is 1.
  - P3 = XOR of all data bits at positions where bit 3 of the position index is 1.
  - P4 = XOR of all data bits at positions where bit 4 of the position index is 1.
  - P5 = XOR of all data bits at positions where bit 5 of the position index is 1.
  - Overall parity = XOR of all 39 bits (including all data and parity bits).

- **Combinational operation.** The encoding is performed purely combinationally: `data_o` responds immediately to changes in `data_i` with no latching or pipeline delays.

- **Error correction capability.** The resulting codeword is suitable for:
  - Single-bit error correction: The syndrome (parity check result) identifies the position of a single corrupted bit.
  - Double-bit error detection: Two bit errors produce a non-zero syndrome with odd overall parity, flagging the error (though correction is not possible).

## Clock and Reset Domains

None. Combinational logic only.

## Example encoding

Input `data_i = 32'h00000001` (all zeros except bit 0 = 1):

- Data bits [31:0] = `32'h00000001`
- P0 (positions 1,3,5,...): Includes position 0 (set), so contributes 1. Result: parity bit = 1.
- P1 (positions 2,3,6,...): Does not include position 0. Result: parity bit = 0.
- P2 through P5: No position matches. Result: parity bits = 0.
- Overall parity: XOR of data bits (= 1) XOR all parity bits (= 1) = 0.
- Output `data_o = 39'h000000001` (7-bit parity field = 7'h0, appended as bits [38:32]).

Another example, `data_i = 32'hFFFFFFFF` (all ones):

- Data bits [31:0] = `32'hFFFFFFFF`
- All parity bits compute as XOR of 16+ ones, yielding either 0 or 1 depending on count.
- Overall parity computed to satisfy SECDED property.
- Output carries 7 parity bits encoding the data.

## Post-encoding operation

Once encoded, the 39-bit codeword is transmitted or stored. A SECDED decoder (Prob048) recovers the original data and detects/corrects single errors.
