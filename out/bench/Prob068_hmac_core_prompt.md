Design a module called TopModule. This module implements the HMAC (Hash-based Message Authentication Code) construction, orchestrating inner and outer SHA-2 hash computations over an i-pad/o-pad transformed key and a message stream.

## Overview

TopModule is an HMAC engine that computes the HMAC-SHA2 authentication code for a message using a symmetric key. It implements the standard HMAC construction: Hash((key XOR o_pad) || Hash((key XOR i_pad) || message)). The module manages two hash rounds (inner and outer), transforms the key with i-pad and o-pad, and orchestrates message feeding. It supports variable key lengths (128, 192, 256 bits) and multiple hash modes (SHA-256, SHA-384, SHA-512) via an internal SHA-2 compression core.

## Parameters

| Parameter | Meaning | Constraint |
|-----------|---------|------------|
| (derived from key_length_i, digest_size_i) | Block sizes: 512 bits for SHA-256, 1024 bits for SHA-384/512. Key lengths: 128–256 bits. | Determined by mode parameters. |

## Interface

| Port | Direction | Width / Type | Description |
|------|-----------|--------------|-------------|
| `clk_i` | input | 1 | Clock. State machine, FIFO pointers, and SHA-2 engine driven by rising edge. |
| `rst_ni` | input | 1 | Async active-low reset. State and key registers cleared. |
| `secret_key_i` | input | [1023:0] | Secret key (up to 1024 bits). If key length < 1024, upper bits are unused. The key is XORed with i_pad and o_pad. |
| `hmac_en_i` | input | 1 | HMAC enable. If high, HMAC operation proceeds; if low, hash operations are passed through unchanged (transparent mode). |
| `digest_size_i` | input | 3 (digest_mode_e) | Hash mode: SHA2_256, SHA2_384, SHA2_512. Determines hash block size and output size. |
| `key_length_i` | input | 3 (key_length_e) | Key length: Key_128, Key_192, Key_256, etc. Determines padding and transformation of key before use. |
| `reg_hash_start_i` | input | 1 | Register-accessible hash start signal. External request to start hash (passed to SHA-2 engine if hmac_en=0, or to inner hash if hmac_en=1). |
| `reg_hash_stop_i` | input | 1 | Register-accessible hash stop signal. |
| `reg_hash_continue_i` | input | 1 | Register-accessible hash continue signal. |
| `reg_hash_process_i` | input | 1 | Register-accessible hash process signal. Triggers round computation. |
| `hash_done_o` | output | 1 | Hash done signal. Asserted when the final hash (inner or outer, depending on HMAC state) completes. |
| `sha_hash_start_o` | output | 1 | SHA-2 engine hash start. Driven by FSM (either inner-hash start or outer-hash start depending on HMAC state). |
| `sha_hash_continue_o` | output | 1 | SHA-2 engine hash continue. Driven by FSM. |
| `sha_hash_process_o` | output | 1 | SHA-2 engine hash process. Driven by FSM. |
| `sha_hash_done_i` | input | 1 | SHA-2 engine hash done. Asserted when the SHA-2 engine completes a hash computation. |
| `sha_rvalid_o` | output | 1 | SHA-2 input (message) valid. Asserted when the HMAC module is feeding data to the SHA-2 engine (i-pad + message for inner, o-pad + inner digest for outer). |
| `sha_rdata_o` | output | sha_fifo32_t (32-bit data + 4-bit mask) | SHA-2 input (message) data: 32-bit word with per-byte valid mask. |
| `sha_rready_i` | input | 1 | SHA-2 input (message) ready. SHA-2 engine asserts when ready to consume a message word. |
| `fifo_rvalid_i` | input | 1 | External FIFO valid. Message data from external source (e.g., DMA or register). |
| `fifo_rdata_i` | input | sha_fifo32_t | External FIFO data: 32-bit message word with per-byte valid mask. |
| `fifo_rready_o` | output | 1 | External FIFO ready. HMAC asserts when ready to consume external message data. |
| `fifo_wsel_o` | output | 1 | FIFO write select. Selects which data source writes to internal FIFO (i-pad, o-pad, or external message). |
| `fifo_wvalid_o` | output | 1 | FIFO write valid. Asserted when writing to internal FIFO. |
| `fifo_wdata_sel_o` | output | [3:0] | FIFO write data select. Encodes which byte lanes are valid in the written word. |
| `fifo_wready_i` | input | 1 | Internal FIFO write ready. Backpressure signal from internal FIFO. |
| `message_length_i` | input | [63:0] | Message length in bits. Passed to SHA-2 engine for padding calculation. |
| `sha_message_length_o` | output | [63:0] | SHA-2 message length. Adjusted for inner or outer hash depending on HMAC round. |
| `idle_o` | output | 1 | Idle signal. High when HMAC is not processing (ready for new key or message). |

## Behavioral requirements

- **HMAC construction.** HMAC is computed as:
  ```
  HMAC(key, message) = Hash((key' XOR o_pad) || Hash((key' XOR i_pad) || message))
  ```
  where:
  - key' is the key padded or hashed to the block size (if original key length > block size, key' = Hash(key); else key' = key || 0...0).
  - i_pad = 0x36 repeated for block_size bytes.
  - o_pad = 0x5c repeated for block_size bytes.
  - block_size is 64 bytes for SHA-256, 128 bytes for SHA-384/512.

- **Two-round processing.** HMAC requires two hash computations:
  - **Inner hash:** Hash((key' XOR i_pad) || message).
  - **Outer hash:** Hash((key' XOR o_pad) || inner_digest).
  
  The module's FSM orchestrates these two rounds. It first feeds (i_pad XOR key') to the SHA-2 engine, then the external message, signals hash_done when the inner digest is ready. Then it feeds (o_pad XOR key') and the inner digest to the SHA-2 engine for the outer hash. When the outer hash is complete, the final HMAC output is ready.

- **Key transformation.** The secret_key_i is padded/truncated to match the block size of the selected hash mode:
  - For SHA-256: key' = key || 0x00...00 (padded to 64 bytes).
  - For SHA-384/512: key' = key || 0x00...00 (padded to 128 bytes).
  - If the key is longer than the block size (rare), key' = Hash(key) (not implemented in this variant; assumes key is pre-sized).

- **I-pad and O-pad generation.** The module computes i_pad_256 = (key' XOR i_value) and o_pad_256/512 = (key' XOR o_value) for the selected key length and hash mode. These are fed to the SHA-2 engine at the start of inner and outer hash rounds.

- **Message FIFO.** External message data arrives on fifo_rdata_i. The HMAC module consumes this data and feeds it to the SHA-2 engine (either for the inner hash or as padding/outer data depending on state).

- **Transparent mode (hmac_en_i = 0).** When hmac_en_i is low, the module acts as a pass-through: reg_hash_* signals are directly forwarded to sha_hash_* outputs, and external FIFO data is directly forwarded to the SHA-2 engine. The HMAC key transformation is skipped.

- **Message length handling.** The module adjusts the message_length_i based on the HMAC round:
  - For inner hash: sha_message_length_o = |i_pad || message|.
  - For outer hash: sha_message_length_o = |o_pad || inner_digest|.

- **FSM state machine.** The module cycles through states:
  - StIdle: Waiting for hash_start.
  - StIPad: Feeding i_pad XOR key' to SHA-2 engine.
  - StMsg: Feeding external message to SHA-2 engine.
  - StPushToMsgFifo: Buffering data internally.
  - StWaitResp: Waiting for inner hash to complete.
  - StOPad: Feeding o_pad XOR key' and inner digest to SHA-2 engine.
  - StDone: Outer hash complete; HMAC result ready.

- **Handshake protocol.** The HMAC module implements backpressure via fifo_wready_i (internal FIFO can accept data) and fifo_rready_o (HMAC ready to consume external message). The SHA-2 engine signals readiness via sha_rready_i (accepts input message words).

## Clock domain

Single clock domain driven by `clk_i`; asynchronous reset via `rst_ni`.

## Latency

- Inner hash: ~64 cycles (SHA-256) or ~80 cycles (SHA-384/512), plus message loading.
- Outer hash: ~64–80 cycles (same as inner).
- Total: ~128–160 cycles for a full HMAC computation of a single 512-bit / 1024-bit block.

## Example

Scenario: Compute HMAC-SHA256 of a 32-byte message with a 16-byte key.

| Operation | Input | FSM State | Output | Notes |
|-----------|-------|-----------|--------|-------|
| Reset | - | - | - | Registers cleared. |
| Start HMAC | hash_start=HIGH, key=K (128 bits), msg_len=32 | StIPad | - | Key transformation: key' = K || 0x00...00 (64 bytes). i_pad_256 computed. |
| Feed i_pad | (16 words × 64 bits = 128 bytes; i_pad is 64 bytes) | StIPad | fifo_wvalid=HIGH | First part of i_pad (8 × 32-bit words) fed to SHA-2 engine. |
| Feed message | (4 × 32-bit words = 16 bytes of message; padded to 64 bytes total) | StMsg | fifo_wvalid=HIGH | External message words fed to SHA-2 engine. |
| Inner hash complete | sha_hash_done_i=HIGH | StWaitResp | - | Inner digest from SHA-2 engine (32 bytes for SHA-256). |
| Feed o_pad + inner | (16 words × 64 bits = 128 bytes total; o_pad [64 bytes] + inner digest [32 bytes]) | StOPad | fifo_wvalid=HIGH | o_pad XOR key' and inner digest fed to SHA-2 engine. |
| Outer hash complete | sha_hash_done_i=HIGH | StDone | hash_done_o=HIGH | Final HMAC-SHA256 output ready. idle_o asserted. |

Constraints:
- key_length_i must match the actual key length (128, 192, or 256 bits).
- digest_size_i must match the chosen hash mode (SHA2_256, SHA2_384, or SHA2_512).
- Do not assert hash_start_i while a prior HMAC computation is still running (respect idle_o).
