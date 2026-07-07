Design a module called TopModule. This module is a one-hot validity checker: it validates that an input vector is one-hot encoded and reports errors when the encoding is invalid.

## Overview

TopModule checks whether an input vector is a valid one-hot encoding (exactly one bit set, or all bits clear) and produces an error signal when the encoding violates the one-hot property. The check optionally verifies consistency between the one-hot vector and an address index, and between the one-hot vector and an enable signal.

## Parameters

| Parameter | Meaning | Default | Range |
|-----------|---------|---------|-------|
| `AddrWidth` | Width of the optional address index input, in bits. | 5 | ≥ 1 |
| `OneHotWidth` | Width of the one-hot input vector. Derived as `2**AddrWidth`. | Derived | Derived |
| `AddrCheck` | When high, enable validation that the address index selects a valid bit in the one-hot vector. | 1 | 0 or 1 |
| `EnableCheck` | When high, enable validation that the one-hot vector consistency with the enable signal. | 1 | 0 or 1 |
| `StrictCheck` | When high, enforce strict matching: `(OR of one-hot bits) == enable_signal`. When low, only check that if one-hot is asserted, enable must be high. | 1 | 0 or 1 |
| `EnableAlertTriggerSVA` | Enable assertion checking (simulation / FPV). | 1 | 0 or 1 |

## Interface

| Port    | Direction | Width          | Description |
|---------|-----------|----------------|-------------|
| `clk_i` | input     | 1              | Clock (used for assertion timing). |
| `rst_ni` | input     | 1              | Asynchronous reset (active low). |
| `oh_i`  | input     | `OneHotWidth`  | One-hot encoded input to validate. |
| `addr_i` | input     | `AddrWidth`    | Optional address index. Used only if `AddrCheck` is enabled. |
| `en_i`  | input     | 1              | Optional enable signal. Used only if `EnableCheck` is enabled. |
| `err_o` | output    | 1              | Error flag: high when the one-hot vector violates any enabled check. Combinational. |

## Behavioral Requirements

**One-Hot Validation:**
- The input `oh_i` is valid one-hot if it contains zero or one bit set to high (not both zero and multiple ones).
- If `oh_i` is not zero and not one-hot, `err_o` is asserted immediately.

**Address Index Check (if `AddrCheck` enabled):**
- If any bit of `oh_i` is asserted, then `oh_i[addr_i]` must be high (the indexed bit must match the asserted one-hot bit).
- If `oh_i` has no bits set, the address check is satisfied.

**Enable Check (if `EnableCheck` enabled):**
- If `StrictCheck` is high: The OR-reduction of `oh_i` must equal `en_i`. An asserted one-hot implies enable, and an asserted enable implies one-hot.
- If `StrictCheck` is low: If any bit of `oh_i` is asserted, `en_i` must be high. But `en_i` can be high even if `oh_i` is all zeros.

**Error Output:**
- `err_o` is a combinational signal that asserts high when any enabled check fails.
- `err_o` remains high as long as the violation persists; it does not depend on reset state.

## Example Scenarios

Assume `OneHotWidth = 4`, `AddrWidth = 2`, `AddrCheck = 1`, `EnableCheck = 1`, `StrictCheck = 1`:

| `oh_i` | `addr_i` | `en_i` | `err_o` | Reason |
|--------|----------|--------|--------|--------|
| 0001   | 0        | 1      | 0      | Valid one-hot, address matches, enable matches. |
| 0010   | 1        | 1      | 0      | Valid one-hot, address matches, enable matches. |
| 0100   | 2        | 1      | 0      | Valid one-hot, address matches, enable matches. |
| 1000   | 3        | 1      | 0      | Valid one-hot, address matches, enable matches. |
| 0011   | 0        | 1      | 1      | Invalid: not one-hot (two bits set). |
| 0000   | 0        | 0      | 0      | Valid: zero one-hot, enable matches. |
| 0000   | 0        | 1      | 1      | Invalid: zero one-hot but enable high (strict check). |
| 0100   | 1        | 1      | 1      | Invalid: address index points to bit 1, but bit 2 is asserted. |

## Assertions and Diagnostics

When enabled via the `EnableAlertTriggerSVA` parameter, the module includes assertions that verify:
- The input is one-hot (or zero).
- The address index (if enabled) points to the asserted bit.
- The enable signal (if enabled) correctly reflects the presence of a one-hot bit.

These assertions are typically enabled during simulation and formal verification; they are not part of the primary error output.
