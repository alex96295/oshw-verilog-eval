Design a module called TopModule. This module implements a Trivium or Bivium stream-cipher keystream generator. It processes cryptographic key and initialization vector inputs, manages state seeding, and produces pseudo-random keystream output.

## Overview

TopModule is a Trivium-family keystream generator that implements iterative state initialization and continuous keystream production. The module accepts key and IV inputs, optionally supports full or partial state seeding, and outputs keystream bits. It includes lockup detection and error signaling for fault tolerance in cryptographic applications.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| `BiviumVariant` | Select Bivium (1) or Trivium (0). | Bit; Bivium uses 177-bit state, Trivium uses 288-bit state. |
| `OutputWidth` | Output keystream width, in bits. | Typically 64; ≤ StateWidth. |
| `StrictLockupProtection` | Enable strict lockup protection mechanisms. | Bit; if 1, enforce lockup avoidance checks. |
| `SeedType` | Seed initialization mode. | Enum: `SeedTypeStateFull` (full state), `SeedTypeStatePartial` (partial/iterative), or `SeedTypeKeyIv` (from key/IV). |
| `PartialSeedWidth` | Width of each partial seed word (if using partial seeding). | Integer; default typically 32 bits. |

## Interface

TopModule operates in a single clock domain with an active-low asynchronous reset.

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| `clk_i` | input | 1 | System clock. |
| `rst_ni` | input | 1 | Active-low asynchronous reset. |
| `en_i` | input | 1 | Enable signal: when asserted, produce keystream output on the next clock edge. |
| `allow_lockup_i` | input | 1 | When asserted, permit the state to reach zero (for initialization); normally zero after warmup. |
| `seed_en_i` | input | 1 | Seed operation enable: initiate seeding protocol. |
| `seed_done_o` | output | 1 | Asserted when seeding is complete and keystream can be generated. |
| `seed_req_o` | output | 1 | Request signal: asserted to indicate need for seed data on the next cycle. |
| `seed_ack_i` | input | 1 | Acknowledge: external seed provider asserts to confirm seed data is valid. |
| `seed_key_i` | input | `KeyIvWidth` | Cryptographic key input (typically 80 bits for Trivium). |
| `seed_iv_i` | input | `KeyIvWidth` | Initialization vector input (typically 80 bits). |
| `seed_state_full_i` | input | StateWidth | Full state for direct loading (if `SeedType = SeedTypeStateFull`). |
| `seed_state_partial_i` | input | `PartialSeedWidth` | Partial state word for iterative seeding. |
| `key_o` | output | `OutputWidth` | Keystream output bits. |
| `err_o` | output | 1 | Error flag: asserted if a fault or invalid state is detected. |

## Behavioral requirements

- **Seeding protocol.** When `seed_en_i` is asserted, the module enters a seeding phase. The method depends on `SeedType`:
  - **Full state seeding:** `seed_state_full_i` directly loads the internal state in one cycle.
  - **Partial state seeding:** The state is loaded word-by-word via `seed_state_partial_i`. The module uses `seed_req_o` to request each word and `seed_ack_i` to confirm arrival. Multiple cycles are required to fill the entire state.
  - **Key/IV seeding:** Loads `seed_key_i` and `seed_iv_i`, then performs initialization rounds (typically 4 full rotations or similar) before producing output.
- **Seeding complete signal.** `seed_done_o` is asserted when seeding finishes and the state is valid. Prior to this, `en_i` should not produce valid keystream (or output remains undefined).
- **Keystream generation.** Once `seed_done_o` is high, asserting `en_i` causes the state to advance and `key_o` is updated with the new keystream bits on the following cycle. Normal operation produces `OutputWidth` bits per cycle.
- **Lockup detection.** If the internal state reaches all-zero (an invalid condition), the `err_o` flag is asserted. Lockup is permitted only during seeding when `allow_lockup_i` is high; after warmup, zero state is an error.
- **Strict lockup protection.** If `StrictLockupProtection` is 1, additional internal checks prevent pathological states and ensure non-zero operation outside the seeding phase.
- **Reset behavior.** On reset (`rst_ni` low), clear internal state, set `seed_done_o` low, and deassert `err_o`. The module must be re-seeded after reset.
- **Error signal.** `err_o` is asserted and latched if any fault condition is detected (zero state during generation, handshake violations, parity errors). Clearing requires a reset or explicit error acknowledgment mechanism.

## Clock and Reset Domains

- Single synchronous clock domain (`clk_i`).
- Asynchronous active-low reset (`rst_ni`).

## Example seeding handshake (partial mode)

With `SeedType = SeedTypeStatePartial`, `PartialSeedWidth = 32`, `StateWidth = 288`:

| Cycle | `seed_en_i` | `seed_req_o` | `seed_ack_i` | `seed_state_partial_i` | Event | `seed_done_o` |
|-------|-----------|-----------|-----------|----------------------|-------|-------------|
| 0 | 1 | 0 | — | — | Seeding starts | 0 |
| 1 | 1 | 1 | 0 | — | Request word 0 | 0 |
| 2 | 1 | 1 | 1 | `32'hXXXX` | Word 0 captured | 0 |
| 3 | 1 | 1 | 0 | — | Request word 1 | 0 |
| ... | 1 | 1 | 1 | `32'hYYYY` | (9 total words for 288b) | 0 |
| 11 | 1 | 0 | — | — | Seeding complete | 1 |
| 12 | 0 | 0 | — | — | Ready for keystream | 1 |

Once `seed_done_o` rises, `en_i` can control keystream generation.
