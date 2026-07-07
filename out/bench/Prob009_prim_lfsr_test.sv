
package prim_cipher_pkg;
  
  
  
  parameter logic [15:0][3:0] PRINCE_SBOX4 = {4'h4, 4'hD, 4'h5, 4'hE,
                                              4'h0, 4'h8, 4'h7, 4'h6,
                                              4'h1, 4'h9, 4'hC, 4'hA,
                                              4'h2, 4'h3, 4'hF, 4'hB};
  parameter logic [15:0][3:0] PRINCE_SBOX4_INV = {4'h1, 4'hC, 4'hE, 4'h5,
                                                  4'h0, 4'h4, 4'h6, 4'hA,
                                                  4'h9, 4'h8, 4'hD, 4'hF,
                                                  4'h2, 4'h3, 4'h7, 4'hB};
  
  parameter logic [15:0][3:0] PRINCE_SHIFT_ROWS64  = '{4'hF, 4'hA, 4'h5, 4'h0,
                                                       4'hB, 4'h6, 4'h1, 4'hC,
                                                       4'h7, 4'h2, 4'hD, 4'h8,
                                                       4'h3, 4'hE, 4'h9, 4'h4};
  parameter logic [15:0][3:0] PRINCE_SHIFT_ROWS64_INV = '{4'hF, 4'h2, 4'h5, 4'h8,
                                                          4'hB, 4'hE, 4'h1, 4'h4,
                                                          4'h7, 4'hA, 4'hD, 4'h0,
                                                          4'h3, 4'h6, 4'h9, 4'hC};
  
  parameter logic [11:0][63:0] PRINCE_ROUND_CONST = {64'hC0AC29B7C97C50DD,
                                                     64'hD3B5A399CA0C2399,
                                                     64'h64A51195E0E3610D,
                                                     64'hC882D32F25323C54,
                                                     64'h85840851F1AC43AA,
                                                     64'h7EF84F78FD955CB1,
                                                     64'hBE5466CF34E90C6C,
                                                     64'h452821E638D01377,
                                                     64'h082EFA98EC4E6C89,
                                                     64'hA4093822299F31D0,
                                                     64'h13198A2E03707344,
                                                     64'h0000000000000000};
  
  parameter logic [63:0] PRINCE_ALPHA_CONST = 64'hC0AC29B7C97C50DD;
  
  parameter logic [15:0] PRINCE_SHIFT_ROWS_CONST0 = 16'h7BDE;
  parameter logic [15:0] PRINCE_SHIFT_ROWS_CONST1 = 16'hBDE7;
  parameter logic [15:0] PRINCE_SHIFT_ROWS_CONST2 = 16'hDE7B;
  parameter logic [15:0] PRINCE_SHIFT_ROWS_CONST3 = 16'hE7BD;
  
  function automatic logic [31:0] prince_shiftrows_32bit(logic [31:0]      state_in,
                                                         logic [15:0][3:0] shifts );
    logic [31:0] state_out;
    
    for (int k = 0; k < 32/2; k++) begin
      
      state_out[k*2  +: 2] = state_in[shifts[k]*2  +: 2];
    end
    return state_out;
  endfunction : prince_shiftrows_32bit
  function automatic logic [63:0] prince_shiftrows_64bit(logic [63:0]      state_in,
                                                         logic [15:0][3:0] shifts );
    logic [63:0] state_out;
    
    for (int k = 0; k < 64/4; k++) begin
      state_out[k*4  +: 4] = state_in[shifts[k]*4  +: 4];
    end
    return state_out;
  endfunction : prince_shiftrows_64bit
  
  function automatic logic [3:0] prince_nibble_red16(logic [15:0] vect);
    return vect[0 +: 4] ^ vect[4 +: 4] ^ vect[8 +: 4] ^ vect[12 +: 4];
  endfunction : prince_nibble_red16
  
  function automatic logic [31:0] prince_mult_prime_32bit(logic [31:0] state_in);
    logic [31:0] state_out;
    
    state_out[0  +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST3);
    state_out[4  +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST2);
    state_out[8  +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST1);
    state_out[12 +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST0);
    
    state_out[16 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST0);
    state_out[20 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST3);
    state_out[24 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST2);
    state_out[28 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST1);
    return state_out;
  endfunction : prince_mult_prime_32bit
  
  function automatic logic [63:0] prince_mult_prime_64bit(logic [63:0] state_in);
    logic [63:0] state_out;
    
    state_out[0  +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST3);
    state_out[4  +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST2);
    state_out[8  +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST1);
    state_out[12 +: 4] = prince_nibble_red16(state_in[ 0 +: 16] & PRINCE_SHIFT_ROWS_CONST0);
    
    state_out[16 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST0);
    state_out[20 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST3);
    state_out[24 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST2);
    state_out[28 +: 4] = prince_nibble_red16(state_in[16 +: 16] & PRINCE_SHIFT_ROWS_CONST1);
    
    state_out[32 +: 4] = prince_nibble_red16(state_in[32 +: 16] & PRINCE_SHIFT_ROWS_CONST0);
    state_out[36 +: 4] = prince_nibble_red16(state_in[32 +: 16] & PRINCE_SHIFT_ROWS_CONST3);
    state_out[40 +: 4] = prince_nibble_red16(state_in[32 +: 16] & PRINCE_SHIFT_ROWS_CONST2);
    state_out[44 +: 4] = prince_nibble_red16(state_in[32 +: 16] & PRINCE_SHIFT_ROWS_CONST1);
    
    state_out[48 +: 4] = prince_nibble_red16(state_in[48 +: 16] & PRINCE_SHIFT_ROWS_CONST3);
    state_out[52 +: 4] = prince_nibble_red16(state_in[48 +: 16] & PRINCE_SHIFT_ROWS_CONST2);
    state_out[56 +: 4] = prince_nibble_red16(state_in[48 +: 16] & PRINCE_SHIFT_ROWS_CONST1);
    state_out[60 +: 4] = prince_nibble_red16(state_in[48 +: 16] & PRINCE_SHIFT_ROWS_CONST0);
    return state_out;
  endfunction : prince_mult_prime_64bit
  
  
  
  
  parameter logic [15:0][3:0] PRESENT_SBOX4 = {4'h2, 4'h1, 4'h7, 4'h4,
                                               4'h8, 4'hF, 4'hE, 4'h3,
                                               4'hD, 4'hA, 4'h0, 4'h9,
                                               4'hB, 4'h6, 4'h5, 4'hC};
  parameter logic [15:0][3:0] PRESENT_SBOX4_INV = {4'hA, 4'h9, 4'h7, 4'h0,
                                                   4'h3, 4'h6, 4'h4, 4'hB,
                                                   4'hD, 4'h2, 4'h1, 4'hC,
                                                   4'h8, 4'hF, 4'hE, 4'h5};
  
  
  parameter logic [31:0][4:0] PRESENT_PERM32 = {5'd31, 5'd23, 5'd15, 5'd07,
                                                5'd30, 5'd22, 5'd14, 5'd06,
                                                5'd29, 5'd21, 5'd13, 5'd05,
                                                5'd28, 5'd20, 5'd12, 5'd04,
                                                5'd27, 5'd19, 5'd11, 5'd03,
                                                5'd26, 5'd18, 5'd10, 5'd02,
                                                5'd25, 5'd17, 5'd09, 5'd01,
                                                5'd24, 5'd16, 5'd08, 5'd00};
  parameter logic [31:0][4:0] PRESENT_PERM32_INV = {5'd31, 5'd27, 5'd23, 5'd19,
                                                    5'd15, 5'd11, 5'd07, 5'd03,
                                                    5'd30, 5'd26, 5'd22, 5'd18,
                                                    5'd14, 5'd10, 5'd06, 5'd02,
                                                    5'd29, 5'd25, 5'd21, 5'd17,
                                                    5'd13, 5'd09, 5'd05, 5'd01,
                                                    5'd28, 5'd24, 5'd20, 5'd16,
                                                    5'd12, 5'd08, 5'd04, 5'd00};
  
  parameter logic [63:0][5:0] PRESENT_PERM64 = {6'd63, 6'd47, 6'd31, 6'd15,
                                                6'd62, 6'd46, 6'd30, 6'd14,
                                                6'd61, 6'd45, 6'd29, 6'd13,
                                                6'd60, 6'd44, 6'd28, 6'd12,
                                                6'd59, 6'd43, 6'd27, 6'd11,
                                                6'd58, 6'd42, 6'd26, 6'd10,
                                                6'd57, 6'd41, 6'd25, 6'd09,
                                                6'd56, 6'd40, 6'd24, 6'd08,
                                                6'd55, 6'd39, 6'd23, 6'd07,
                                                6'd54, 6'd38, 6'd22, 6'd06,
                                                6'd53, 6'd37, 6'd21, 6'd05,
                                                6'd52, 6'd36, 6'd20, 6'd04,
                                                6'd51, 6'd35, 6'd19, 6'd03,
                                                6'd50, 6'd34, 6'd18, 6'd02,
                                                6'd49, 6'd33, 6'd17, 6'd01,
                                                6'd48, 6'd32, 6'd16, 6'd00};
  parameter logic [63:0][5:0] PRESENT_PERM64_INV = {6'd63, 6'd59, 6'd55, 6'd51,
                                                    6'd47, 6'd43, 6'd39, 6'd35,
                                                    6'd31, 6'd27, 6'd23, 6'd19,
                                                    6'd15, 6'd11, 6'd07, 6'd03,
                                                    6'd62, 6'd58, 6'd54, 6'd50,
                                                    6'd46, 6'd42, 6'd38, 6'd34,
                                                    6'd30, 6'd26, 6'd22, 6'd18,
                                                    6'd14, 6'd10, 6'd06, 6'd02,
                                                    6'd61, 6'd57, 6'd53, 6'd49,
                                                    6'd45, 6'd41, 6'd37, 6'd33,
                                                    6'd29, 6'd25, 6'd21, 6'd17,
                                                    6'd13, 6'd09, 6'd05, 6'd01,
                                                    6'd60, 6'd56, 6'd52, 6'd48,
                                                    6'd44, 6'd40, 6'd36, 6'd32,
                                                    6'd28, 6'd24, 6'd20, 6'd16,
                                                    6'd12, 6'd08, 6'd04, 6'd00};
  
  function automatic logic [63:0] present_update_key64(logic [63:0] key_in,
                                                       logic [4:0]  round_idx);
    logic [63:0] key_out;
    
    key_out = {key_in[63-61:0], key_in[63:64-61]};
    
    key_out[63 -: 4] = PRESENT_SBOX4[key_out[63 -: 4]];
    
    key_out[19:15] ^= round_idx;
    return key_out;
  endfunction : present_update_key64
  function automatic logic [79:0] present_update_key80(logic [79:0] key_in,
                                                       logic [4:0]  round_idx);
    logic [79:0] key_out;
    
    key_out = {key_in[79-61:0], key_in[79:80-61]};
    
    key_out[79 -: 4] = PRESENT_SBOX4[key_out[79 -: 4]];
    
    key_out[19:15] ^= round_idx;
    return key_out;
  endfunction : present_update_key80
  function automatic logic [127:0] present_update_key128(logic [127:0] key_in,
                                                         logic [4:0]   round_idx);
    logic [127:0] key_out;
    
    key_out = {key_in[127-61:0], key_in[127:128-61]};
    
    key_out[127 -: 4] = PRESENT_SBOX4[key_out[127 -: 4]];
    
    key_out[123 -: 4] = PRESENT_SBOX4[key_out[123 -: 4]];
    
    key_out[66:62] ^= round_idx;
    return key_out;
  endfunction : present_update_key128
  
  function automatic logic [63:0] present_inv_update_key64(logic [63:0] key_in,
                                                           logic [4:0]  round_idx);
    logic [63:0] key_out = key_in;
    
    key_out[19:15] ^= round_idx;
    
    key_out[63 -: 4] = PRESENT_SBOX4_INV[key_out[63 -: 4]];
    
    key_out = {key_out[60:0], key_out[63:61]};
    return key_out;
  endfunction : present_inv_update_key64
  function automatic logic [79:0] present_inv_update_key80(logic [79:0] key_in,
                                                           logic [4:0]  round_idx);
    logic [79:0] key_out = key_in;
    
    key_out[19:15] ^= round_idx;
    
    key_out[79 -: 4] = PRESENT_SBOX4_INV[key_out[79 -: 4]];
    
    key_out = {key_out[60:0], key_out[79:61]};
    return key_out;
  endfunction : present_inv_update_key80
  function automatic logic [127:0] present_inv_update_key128(logic [127:0] key_in,
                                                             logic [4:0]   round_idx);
    logic [127:0] key_out = key_in;
    
    key_out[66:62] ^= round_idx;
    
    key_out[123 -: 4] = PRESENT_SBOX4_INV[key_out[123 -: 4]];
    
    key_out[127 -: 4] = PRESENT_SBOX4_INV[key_out[127 -: 4]];
    
    key_out = {key_out[60:0], key_out[127:61]};
    return key_out;
  endfunction : present_inv_update_key128
  
  
  function automatic logic [63:0] present_get_dec_key64(logic [63:0] key_in,
                                                        
                                                        logic [4:0]  round_cnt);
    logic [63:0] key_out;
    key_out = key_in;
    for (int unsigned k = 0; k < round_cnt; k++) begin
      key_out = present_update_key64(key_out, 5'(k + 1));
    end
    return key_out;
  endfunction : present_get_dec_key64
  function automatic logic [79:0] present_get_dec_key80(logic [79:0] key_in,
                                                        
                                                        logic [4:0]  round_cnt);
    logic [79:0] key_out;
    key_out = key_in;
    for (int unsigned k = 0; k < round_cnt; k++) begin
      key_out = present_update_key80(key_out, 5'(k + 1));
    end
    return key_out;
  endfunction : present_get_dec_key80
  function automatic logic [127:0] present_get_dec_key128(logic [127:0] key_in,
                                                          
                                                          logic [4:0]   round_cnt);
    logic [127:0] key_out;
    key_out = key_in;
    for (int unsigned k = 0; k < round_cnt; k++) begin
      key_out = present_update_key128(key_out, 5'(k + 1));
    end
    return key_out;
  endfunction : present_get_dec_key128
  
  
  
  function automatic logic [7:0] sbox4_8bit(logic [7:0] state_in, logic [15:0][3:0] sbox4);
    logic [7:0] state_out;
    
    for (int k = 0; k < 8/4; k++) begin
      state_out[k*4  +: 4] = sbox4[state_in[k*4  +: 4]];
    end
    return state_out;
  endfunction : sbox4_8bit
  function automatic logic [15:0] sbox4_16bit(logic [15:0] state_in, logic [15:0][3:0] sbox4);
    logic [15:0] state_out;
    
    for (int k = 0; k < 2; k++) begin
      state_out[k*8  +: 8] = sbox4_8bit(state_in[k*8  +: 8], sbox4);
    end
    return state_out;
  endfunction : sbox4_16bit
  function automatic logic [31:0] sbox4_32bit(logic [31:0] state_in, logic [15:0][3:0] sbox4);
    logic [31:0] state_out;
    
    for (int k = 0; k < 4; k++) begin
      state_out[k*8  +: 8] = sbox4_8bit(state_in[k*8  +: 8], sbox4);
    end
    return state_out;
  endfunction : sbox4_32bit
  function automatic logic [63:0] sbox4_64bit(logic [63:0] state_in, logic [15:0][3:0] sbox4);
    logic [63:0] state_out;
    
    for (int k = 0; k < 8; k++) begin
      state_out[k*8  +: 8] = sbox4_8bit(state_in[k*8  +: 8], sbox4);
    end
    return state_out;
  endfunction : sbox4_64bit
  function automatic logic [7:0] perm_8bit(logic [7:0] state_in, logic [7:0][2:0] perm);
    logic [7:0] state_out;
    
    for (int k = 0; k < 8; k++) begin
      state_out[perm[k]] = state_in[k];
    end
    return state_out;
  endfunction : perm_8bit
    function automatic logic [15:0] perm_16bit(logic [15:0] state_in, logic [15:0][3:0] perm);
    logic [15:0] state_out;
    
    for (int k = 0; k < 16; k++) begin
      state_out[perm[k]] = state_in[k];
    end
    return state_out;
  endfunction : perm_16bit
  function automatic logic [31:0] perm_32bit(logic [31:0] state_in, logic [31:0][4:0] perm);
    logic [31:0] state_out;
    
    for (int k = 0; k < 32; k++) begin
      state_out[perm[k]] = state_in[k];
    end
    return state_out;
  endfunction : perm_32bit
  function automatic logic [63:0] perm_64bit(logic [63:0] state_in, logic [63:0][5:0] perm);
    logic [63:0] state_out;
    
    for (int k = 0; k < 64; k++) begin
      state_out[perm[k]] = state_in[k];
    end
    return state_out;
  endfunction : perm_64bit
endpackage : prim_cipher_pkg

`ifndef PRIM_ASSERT_SV
`define PRIM_ASSERT_SV
`define ASSERT_DEFAULT_CLK clk_i
`define ASSERT_DEFAULT_RST !rst_ni
`define PRIM_STRINGIFY(__x) `"__x`"
`define ASSERT_ERROR(__name)                                                             \
`ifdef UVM                                                                               \
  uvm_pkg::uvm_report_error("ASSERT FAILED", `PRIM_STRINGIFY(__name), uvm_pkg::UVM_NONE, \
                            `__FILE__, `__LINE__, "", 1);                                \
`else                                                                                    \
  $error("%0t: (%0s:%0d) [%m] [ASSERT FAILED] %0s", $time, `__FILE__, `__LINE__,         \
         `PRIM_STRINGIFY(__name));                                                       \
`endif
`define ASSERT_STATIC_LINT_ERROR(__name, __prop)     \
  localparam int __name = (__prop) ? 1 : 2;          \
  always_comb begin                                  \
    logic unused_assert_static_lint_error;           \
    unused_assert_static_lint_error = __name'(1'b1); \
  end
`define ASSERT_STATIC_IN_PACKAGE(__name, __prop)              \
  function automatic bit assert_static_in_package_``__name(); \
    bit unused_bit [((__prop) ? 1 : -1)];                     \
    unused_bit = '{default: 1'b0};                            \
    return unused_bit[0];                                     \
  endfunction
`ifdef VERILATOR
 `include "prim_assert_dummy_macros.svh"`elsif SYNTHESIS
 `include "prim_assert_dummy_macros.svh"`elsif YOSYS
 `include "prim_assert_yosys_macros.svh"
 `define INC_ASSERT`else
 
`define ASSERT_I(__name, __prop) \
  __name: assert (__prop)        \
    else begin                   \
      `ASSERT_ERROR(__name)      \
    end
`define ASSERT_INIT(__name, __prop)                                                  \
`ifdef FPV_ON                                                                        \
  if (!(__prop)) $fatal(2, "Fatal static assertion [%s]: (%s) is not true.",         \
                        (__name), (__prop));                                         \
`else                                                                                \
  initial begin                                                                      \
    __name: assert (__prop)                                                          \
      else begin                                                                     \
        `ASSERT_ERROR(__name)                                                        \
      end                                                                            \
  end                                                                                \
`endif
`define ASSERT_INIT_NET(__name, __prop)                                                   \
  initial begin                                                                      \
    
    
    
    #1ps;                                                                            \
    __name: assert (__prop)                                                          \
      else begin                                                                     \
        `ASSERT_ERROR(__name)                                                        \
      end                                                                            \
  end                                                                                \
`define ASSERT_FINAL(__name, __prop)                                         \
`ifndef FPV_ON                                                               \
  final begin                                                                \
    __name: assert (__prop || $test$plusargs("disable_assert_final_checks")) \
      else begin                                                             \
        `ASSERT_ERROR(__name)                                                \
      end                                                                    \
  end                                                                        \
`endif
`define ASSERT_AT_RESET(__name, __prop, __rst = `ASSERT_DEFAULT_RST)          \
  
  
  
  
  
  
  
  
  
  
`ifndef FPV_ON                                                                \
  __name: assert property (@(posedge __rst) $isunknown(__rst) || (__prop))    \
`else                                                                         \
  __name: assert property (@(posedge __rst) (__prop))                         \
`endif                                                                        \
    else begin                                                                \
      `ASSERT_ERROR(__name)                                                   \
    end
`define ASSERT_AT_RESET_AND_FINAL(__name, __prop, __rst = `ASSERT_DEFAULT_RST) \
    `ASSERT_AT_RESET(AtReset_``__name``, __prop, __rst)                        \
    `ASSERT_FINAL(Final_``__name``, __prop)
`define ASSERT(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop))       \
    else begin                                                                           \
      `ASSERT_ERROR(__name)                                                              \
    end
`define ASSERT_NEVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) not (__prop))         \
    else begin                                                                                 \
      `ASSERT_ERROR(__name)                                                                    \
    end
`define ASSERT_KNOWN(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifndef FPV_ON                                                                                \
  `ASSERT(__name, !$isunknown(__sig), __clk, __rst)                                           \
`endif
`define COVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
  __name: cover property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop));
`define ASSUME(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
  __name: assume property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop))       \
    else begin                                                                           \
      `ASSERT_ERROR(__name)                                                              \
    end
`define ASSUME_I(__name, __prop) \
  __name: assume (__prop)        \
    else begin                   \
      `ASSERT_ERROR(__name)      \
    end
 `define INC_ASSERT
`endif
`define ASSERT_PULSE(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
  `ASSERT(__name, $rose(__sig) |=> !(__sig), __clk, __rst)
`define ASSERT_IF(__name, __prop, __enable, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
  `ASSERT(__name, (__enable) |-> (__prop), __clk, __rst)
`define ASSERT_KNOWN_IF(__name, __sig, __enable, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifndef FPV_ON                                                                                             \
  `ASSERT_KNOWN(__name``KnownEnable, __enable, __clk, __rst)                                               \
  `ASSERT_IF(__name, !$isunknown(__sig), __enable, __clk, __rst)                                           \
`endif
`define ASSUME_FPV(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifdef FPV_ON                                                                                \
   `ASSUME(__name, __prop, __clk, __rst)                                                     \
`endif
`define ASSUME_I_FPV(__name, __prop) \
`ifdef FPV_ON                        \
   `ASSUME_I(__name, __prop)         \
`endif
`define COVER_FPV(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifdef FPV_ON                                                                               \
   `COVER(__name, __prop, __clk, __rst)                                                     \
`endif
`define ASSERT_FPV_LINEAR_FSM(__name, __state, __type, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
  `ifdef INC_ASSERT                                                                                              \
     bit __name``_cond;                                                                                          \
     always_ff @(posedge __clk or posedge __rst) begin                                                           \
       if (__rst) begin                                                                                          \
         __name``_cond <= 0;                                                                                     \
       end else begin                                                                                            \
         __name``_cond <= 1;                                                                                     \
       end                                                                                                       \
     end                                                                                                         \
     property __name``_p;                                                                                        \
       __type initial_state;                                                                                     \
       (!$stable(__state) & __name``_cond, initial_state = $past(__state)) |->                                   \
           (__state != initial_state) until !(__name``_cond);                                                    \
     endproperty                                                                                                 \
   `ASSERT(__name, __name``_p, __clk, 0)                                                                         \
  `endif
`ifndef PRIM_ASSERT_SEC_CM_SVH
`define PRIM_ASSERT_SEC_CM_SVH
`define _SEC_CM_ALERT_MAX_CYC 30
`define ASSERT_ERROR_TRIGGER_ERR(NAME_, HIER_, ERR_, GATE_, MAX_CYCLES_, ERR_NAME_, CLK_, RST_) \
  `ASSERT(FpvSecCm``NAME_``,                                                                    \
          $rose(HIER_.ERR_NAME_) && !(GATE_) |-> ##[0:MAX_CYCLES_] (ERR_),                      \
          CLK_, RST_)                                                                           \
  `ifdef INC_ASSERT                                                                             \
    assign HIER_.unused_assert_connected = 1'b1;                                                \
  `endif
`define ASSERT_ERROR_TRIGGER_ALERT(NAME_, HIER_, ALERT_, GATE_, MAX_CYCLES_, ERR_NAME_)    \
  `ASSERT_ERROR_TRIGGER_ERR(NAME_, HIER_, (ALERT_.alert_p), GATE_, MAX_CYCLES_, ERR_NAME_, \
                            `ASSERT_DEFAULT_CLK, `ASSERT_DEFAULT_RST)                      \
  `ASSUME_FPV(``NAME_``TriggerAfterAlertInit_S,                                            \
              $stable(rst_ni) == 0 |-> HIER_.ERR_NAME_ == 0 [*10])
`define ASSERT_ERROR_TRIGGER_ALERT_IN(NAME_, HIER_, ALERT_IN_, GATE_, MAX_CYCLES_, ERR_NAME_) \
  `ASSERT_ERROR_TRIGGER_ERR(NAME_, HIER_, ALERT_IN_, GATE_, MAX_CYCLES_, ERR_NAME_,           \
                            `ASSERT_DEFAULT_CLK, `ASSERT_DEFAULT_RST)
`define ASSERT_PRIM_COUNT_ERROR_TRIGGER_ALERT(NAME_, HIER_, ALERT_, GATE_ = 0, MAX_CYCLES_ = `_SEC_CM_ALERT_MAX_CYC) \
  `ASSERT_ERROR_TRIGGER_ALERT(NAME_, HIER_, ALERT_, GATE_, MAX_CYCLES_, err_o)
`define ASSERT_PRIM_DOUBLE_LFSR_ERROR_TRIGGER_ALERT(NAME_, HIER_, ALERT_, GATE_ = 0, MAX_CYCLES_ = `_SEC_CM_ALERT_MAX_CYC) \
  `ASSERT_ERROR_TRIGGER_ALERT(NAME_, HIER_, ALERT_, GATE_, MAX_CYCLES_, err_o)
`define ASSERT_PRIM_FSM_ERROR_TRIGGER_ALERT(NAME_, HIER_, ALERT_, GATE_ = 0, MAX_CYCLES_ = `_SEC_CM_ALERT_MAX_CYC) \
  `ASSERT_ERROR_TRIGGER_ALERT(NAME_, HIER_, ALERT_, GATE_, MAX_CYCLES_, unused_err_o)
`define ASSERT_PRIM_ONEHOT_ERROR_TRIGGER_ALERT(NAME_, HIER_, ALERT_, GATE_ = 0, MAX_CYCLES_ = `_SEC_CM_ALERT_MAX_CYC) \
  `ASSERT_ERROR_TRIGGER_ALERT(NAME_, HIER_, ALERT_, GATE_, MAX_CYCLES_, err_o)
`define ASSERT_PRIM_REG_WE_ONEHOT_ERROR_TRIGGER_ALERT(NAME_, REG_TOP_HIER_, ALERT_, GATE_ = 0, MAX_CYCLES_ = `_SEC_CM_ALERT_MAX_CYC) \
  `ASSERT_PRIM_ONEHOT_ERROR_TRIGGER_ALERT(NAME_, \
    REG_TOP_HIER_.u_prim_reg_we_check.u_prim_onehot_check, ALERT_, GATE_, MAX_CYCLES_)
`define ASSERT_PRIM_FIFO_SYNC_SINGLETON_ERROR_TRIGGER_ALERT(NAME, HIER_, ALERT_, GATE_ = 0, MAX_CYCLES_ = `_SEC_CM_ALERT_MAX_CYC) \
  `ASSERT_ERROR_TRIGGER_ALERT(NAME_, HIER_, ALERT_, GATE_, MAX_CYCLES_, err_o)
`define ASSERT_PRIM_COUNT_ERROR_TRIGGER_ALERT_IN(NAME_, HIER_, ALERT_, GATE_ = 0, MAX_CYCLES_ = 2) \
  `ASSERT_ERROR_TRIGGER_ALERT_IN(NAME_, HIER_, ALERT_, GATE_, MAX_CYCLES_, err_o)
`define ASSERT_PRIM_DOUBLE_LFSR_ERROR_TRIGGER_ALERT_IN(NAME_, HIER_, ALERT_, GATE_ = 0, MAX_CYCLES_ = 2) \
  `ASSERT_ERROR_TRIGGER_ALERT_IN(NAME_, HIER_, ALERT_, GATE_, MAX_CYCLES_, err_o)
`define ASSERT_PRIM_FSM_ERROR_TRIGGER_ALERT_IN(NAME_, HIER_, ALERT_, GATE_ = 0, MAX_CYCLES_ = 2) \
  `ASSERT_ERROR_TRIGGER_ALERT_IN(NAME_, HIER_, ALERT_, GATE_, MAX_CYCLES_, unused_err_o)
`define ASSERT_PRIM_ONEHOT_ERROR_TRIGGER_ALERT_IN(NAME_, HIER_, ALERT_, GATE_ = 0, MAX_CYCLES_ = 2) \
  `ASSERT_ERROR_TRIGGER_ALERT_IN(NAME_, HIER_, ALERT_, GATE_, MAX_CYCLES_, err_o)
`define ASSERT_PRIM_REG_WE_ONEHOT_ERROR_TRIGGER_ALERT_IN(NAME_, REG_TOP_HIER_, ALERT_, GATE_ = 0, MAX_CYCLES_ = 2) \
  `ASSERT_PRIM_ONEHOT_ERROR_TRIGGER_ALERT_IN(NAME_, \
    REG_TOP_HIER_.u_prim_reg_we_check.u_prim_onehot_check, ALERT_, GATE_, MAX_CYCLES_)
`define ASSERT_PRIM_FIFO_SYNC_SINGLETON_ERROR_TRIGGER_ALERT_IN(NAME, HIER_, ALERT_, GATE_ = 0, MAX_CYCLES_ = 2) \
  `ASSERT_ERROR_TRIGGER_ALERT_IN(NAME_, HIER_, ALERT_, GATE_, MAX_CYCLES_, err_o)
`define ASSERT_PRIM_FSM_ERROR_TRIGGER_ERR(NAME_, HIER_, ERR_, GATE_ = 0, MAX_CYCLES_ = 2, CLK_ = clk_i, RST_ = !rst_ni) \
  `ASSERT_ERROR_TRIGGER_ERR(NAME_, HIER_, ERR_, GATE_, MAX_CYCLES_, unused_err_o, CLK_, RST_)
`define ASSERT_PRIM_COUNT_ERROR_TRIGGER_ERR(NAME_, HIER_, ERR_, GATE_ = 0, MAX_CYCLES_ = 2, CLK_ = clk_i, RST_ = !rst_ni) \
  `ASSERT_ERROR_TRIGGER_ERR(NAME_, HIER_, ERR_, GATE_, MAX_CYCLES_, err_o, CLK_, RST_)
`define ASSERT_PRIM_DOUBLE_LFSR_ERROR_TRIGGER_ERR(NAME_, HIER_, ERR_, GATE_ = 0, MAX_CYCLES_ = 2, CLK_ = clk_i, RST_ = !rst_ni) \
  `ASSERT_ERROR_TRIGGER_ERR(NAME_, HIER_, ERR_, GATE_, MAX_CYCLES_, err_o, CLK_, RST_)
`define ASSERT_PRIM_ONEHOT_ERROR_TRIGGER_ERR(NAME_, HIER_, ERR_, GATE_ = 0, MAX_CYCLES_ = `_SEC_CM_ALERT_MAX_CYC, CLK_ = clk_i, RST_ = !rst_ni) \
  `ASSERT_ERROR_TRIGGER_ERR(NAME_, HIER_, ERR_, GATE_, MAX_CYCLES_, err_o, CLK_, RST_)
`define ASSERT_PRIM_REG_WE_ONEHOT_ERROR_TRIGGER_ERR(NAME_, REG_TOP_HIER_, ERR_, GATE_ = 0, MAX_CYCLES_ = `_SEC_CM_ALERT_MAX_CYC, CLK_ = clk_i, RST_ = !rst_ni) \
  `ASSERT_PRIM_ONEHOT_ERROR_TRIGGER_ERR(NAME_, \
    REG_TOP_HIER_.u_prim_reg_we_check.u_prim_onehot_check, ERR_, GATE_, MAX_CYCLES_, CLK_, RST_)
`endif 
`ifndef PRIM_FLOP_MACROS_SV
`define PRIM_FLOP_MACROS_SV
`define PRIM_FLOP_CLK clk_i
`define PRIM_FLOP_RST rst_ni
`define PRIM_FLOP_RESVAL '0
`define PRIM_FLOP_A(__d, __q, __resval = `PRIM_FLOP_RESVAL, __clk = `PRIM_FLOP_CLK, __rst_n = `PRIM_FLOP_RST) \
  always_ff @(posedge __clk or negedge __rst_n) begin \
    if (!__rst_n) begin                               \
      __q <= __resval;                                \
    end else begin                                    \
      __q <= __d;                                     \
    end                                               \
  end
`define PRIM_FLOP_SPARSE_FSM(__name, __d, __q, __type, __resval = `PRIM_FLOP_RESVAL, __clk = `PRIM_FLOP_CLK, __rst_n = `PRIM_FLOP_RST, __alert_trigger_sva_en = 1) \
  `ifdef SIMULATION                                   \
    prim_sparse_fsm_flop #(                           \
      .StateEnumT(__type),                            \
      .Width($bits(__type)),                          \
      .ResetValue($bits(__type)'(__resval)),          \
      .EnableAlertTriggerSVA(__alert_trigger_sva_en), \
      .CustomForceName(`PRIM_STRINGIFY(__q))          \
    ) __name (                                        \
      .clk_i   ( __clk   ),                           \
      .rst_ni  ( __rst_n ),                           \
      .state_i ( __d     ),                           \
      .state_o (         )                            \
    );                                                \
    `PRIM_FLOP_A(__d, __q, __resval, __clk, __rst_n)  \
    `ASSERT(``__name``_A, __q === ``__name``.state_o) \
  `else                                               \
    prim_sparse_fsm_flop #(                           \
      .StateEnumT(__type),                            \
      .Width($bits(__type)),                          \
      .ResetValue($bits(__type)'(__resval)),          \
      .EnableAlertTriggerSVA(__alert_trigger_sva_en)  \
    ) __name (                                        \
      .clk_i   ( __clk   ),                           \
      .rst_ni  ( __rst_n ),                           \
      .state_i ( __d     ),                           \
      .state_o ( __q     )                            \
    );                                                \
  `endif
`endif 
`endif 

module TopTestbench #(
  
  parameter int unsigned EntropyDw        = 1,
  parameter int unsigned StateOutDw       = 1,
  
  
  parameter int unsigned GalXorMinLfsrDw  = 4,
  parameter int unsigned GalXorMaxLfsrDw  = 64,
  parameter int unsigned FibXnorMinLfsrDw = 3,
  parameter int unsigned FibXnorMaxLfsrDw = 168,
  
  parameter int unsigned MaxLenSVAThresh  = 10,
  
  localparam int unsigned GalMaxGtFibMax  = GalXorMaxLfsrDw > FibXnorMaxLfsrDw,
  localparam int unsigned MaxLfsrDw       = GalXorMaxLfsrDw * GalMaxGtFibMax +
                                            FibXnorMaxLfsrDw * (1 - GalMaxGtFibMax),
  localparam int unsigned NumDuts         = 2*(FibXnorMaxLfsrDw - FibXnorMinLfsrDw + 1) +
                                            2*(GalXorMaxLfsrDw - GalXorMinLfsrDw + 1)
) (
  input                                      clk_i,
  input                                      rst_ni,
  input [NumDuts-1:0]                        load_ext_en_i,
  input [NumDuts-1:0][MaxLfsrDw-1:0]         seed_ext_i,
  input [NumDuts-1:0]                        lfsr_en_i,
  input [NumDuts-1:0][EntropyDw-1:0]         entropy_i,
  output logic [NumDuts-1:0][StateOutDw-1:0] state_o
);
  for (genvar k = GalXorMinLfsrDw; k <= GalXorMaxLfsrDw; k++) begin : gen_gal_xor_duts
    localparam int unsigned Idx = k - GalXorMinLfsrDw;
    TopModule #(.LfsrType("GAL_XOR"),
      .LfsrDw      ( k          ),
      .EntropyDw   ( EntropyDw  ),
      .StateOutDw  ( StateOutDw ),
      .DefaultSeed ( 1          ),
      
      .MaxLenSVA   ( k <= MaxLenSVAThresh )
    ) u_prim_lfsr (
      .clk_i,
      .rst_ni,
      .seed_en_i ( load_ext_en_i[Idx]  ),
      .seed_i    ( k'(seed_ext_i[Idx]) ),
      .lfsr_en_i ( lfsr_en_i[Idx]      ),
      .entropy_i ( entropy_i[Idx]      ),
      .state_o   ( state_o[Idx]        )
    );
  end
  
  
  for (genvar k = 16; k <= GalXorMaxLfsrDw; k = k*2)
  begin : gen_gal_xor_duts_nonlinear
    localparam int unsigned Idx = k - GalXorMinLfsrDw;
    TopModule #(.LfsrType("GAL_XOR"),
      .LfsrDw      ( k          ),
      .EntropyDw   ( EntropyDw  ),
      .StateOutDw  ( StateOutDw ),
      .DefaultSeed ( 1          ),
      
      .MaxLenSVA   ( k <= MaxLenSVAThresh ),
      .NonLinearOut (1)
    ) u_prim_lfsr (
      .clk_i,
      .rst_ni,
      .seed_en_i ( load_ext_en_i[Idx]  ),
      .seed_i    ( k'(seed_ext_i[Idx]) ),
      .lfsr_en_i ( lfsr_en_i[Idx]      ),
      .entropy_i ( entropy_i[Idx]      ),
      .state_o   ( state_o[Idx]        )
    );
  end
  for (genvar k = FibXnorMinLfsrDw; k <= FibXnorMaxLfsrDw; k++) begin : gen_fib_xnor_duts
    localparam int unsigned Idx = k - FibXnorMinLfsrDw + GalXorMaxLfsrDw - GalXorMinLfsrDw + 1;
    TopModule #(.LfsrType("FIB_XNOR"),
      .LfsrDw      ( k          ),
      .EntropyDw   ( EntropyDw  ),
      .StateOutDw  ( StateOutDw ),
      .DefaultSeed ( 1          ),
      
      .MaxLenSVA   ( k <= MaxLenSVAThresh )
    ) u_prim_lfsr (
      .clk_i,
      .rst_ni,
      .seed_en_i ( load_ext_en_i[Idx]  ),
      .seed_i    ( k'(seed_ext_i[Idx]) ),
      .lfsr_en_i ( lfsr_en_i[Idx]      ),
      .entropy_i ( entropy_i[Idx]      ),
      .state_o   ( state_o[Idx]        )
    );
  end
  
  
  for (genvar k = 16; k <= FibXnorMaxLfsrDw; k = k*2)
  begin : gen_fib_xnor_duts_nonlinear
    localparam int unsigned Idx = k - FibXnorMinLfsrDw + GalXorMaxLfsrDw - GalXorMinLfsrDw + 1;
    TopModule #(.LfsrType("FIB_XNOR"),
      .LfsrDw      ( k          ),
      .EntropyDw   ( EntropyDw  ),
      .StateOutDw  ( StateOutDw ),
      .DefaultSeed ( 1          ),
      
      .MaxLenSVA   ( k <= MaxLenSVAThresh ),
      .NonLinearOut (1)
    ) u_prim_lfsr (
      .clk_i,
      .rst_ni,
      .seed_en_i ( load_ext_en_i[Idx]  ),
      .seed_i    ( k'(seed_ext_i[Idx]) ),
      .lfsr_en_i ( lfsr_en_i[Idx]      ),
      .entropy_i ( entropy_i[Idx]      ),
      .state_o   ( state_o[Idx]        )
    );
  end
endmodule : TopTestbench
