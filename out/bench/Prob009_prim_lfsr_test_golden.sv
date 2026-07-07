
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
module TopModule #(
  
  parameter                    LfsrType     = "GAL_XOR",
  
  parameter int unsigned       LfsrDw       = 32,
  
  localparam int unsigned      LfsrIdxDw    = $clog2(LfsrDw),
  
  parameter int unsigned       EntropyDw    =  8,
  
  parameter int unsigned       StateOutDw   =  8,
  
  parameter logic [LfsrDw-1:0] DefaultSeed  = LfsrDw'(1),
  
  parameter logic [LfsrDw-1:0] CustomCoeffs = '0,
  
  
  
  
  
  
  
  
  parameter bit                StatePermEn  = 1'b0,
  parameter logic [LfsrDw-1:0][LfsrIdxDw-1:0] StatePerm = '0,
  
  parameter bit                MaxLenSVA    = 1'b1,
  
  
  
  parameter bit                LockupSVA    = 1'b1,
  parameter bit                ExtSeedSVA   = 1'b1,
  
  
  
  parameter bit                NonLinearOut = 1'b0
) (
  input                         clk_i,
  input                         rst_ni,
  input                         seed_en_i, 
  input        [LfsrDw-1:0]     seed_i,    
  input                         lfsr_en_i, 
  input        [EntropyDw-1:0]  entropy_i, 
  output logic [StateOutDw-1:0] state_o    
);
  
  localparam int unsigned LUT_OFF = 3;
  localparam logic [167:0] LFSR_COEFFS [166] =
    '{ 168'h6,
       168'hC,
       168'h14,
       168'h30,
       168'h60,
       168'hB8,
       168'h110,
       168'h240,
       168'h500,
       168'h829,
       168'h100D,
       168'h2015,
       168'h6000,
       168'hD008,
       168'h12000,
       168'h20400,
       168'h40023,
       168'h90000,
       168'h140000,
       168'h300000,
       168'h420000,
       168'hE10000,
       168'h1200000,
       168'h2000023,
       168'h4000013,
       168'h9000000,
       168'h14000000,
       168'h20000029,
       168'h48000000,
       168'h80200003,
       168'h100080000,
       168'h204000003,
       168'h500000000,
       168'h801000000,
       168'h100000001F,
       168'h2000000031,
       168'h4400000000,
       168'hA000140000,
       168'h12000000000,
       168'h300000C0000,
       168'h63000000000,
       168'hC0000030000,
       168'h1B0000000000,
       168'h300003000000,
       168'h420000000000,
       168'hC00000180000,
       168'h1008000000000,
       168'h3000000C00000,
       168'h6000C00000000,
       168'h9000000000000,
       168'h18003000000000,
       168'h30000000030000,
       168'h40000040000000,
       168'hC0000600000000,
       168'h102000000000000,
       168'h200004000000000,
       168'h600003000000000,
       168'hC00000000000000,
       168'h1800300000000000,
       168'h3000000000000030,
       168'h6000000000000000,
       168'hD800000000000000,
       168'h10000400000000000,
       168'h30180000000000000,
       168'h60300000000000000,
       168'h80400000000000000,
       168'h140000028000000000,
       168'h300060000000000000,
       168'h410000000000000000,
       168'h820000000001040000,
       168'h1000000800000000000,
       168'h3000600000000000000,
       168'h6018000000000000000,
       168'hC000000018000000000,
       168'h18000000600000000000,
       168'h30000600000000000000,
       168'h40200000000000000000,
       168'hC0000000060000000000,
       168'h110000000000000000000,
       168'h240000000480000000000,
       168'h600000000003000000000,
       168'h800400000000000000000,
       168'h1800000300000000000000,
       168'h3003000000000000000000,
       168'h4002000000000000000000,
       168'hC000000000000000018000,
       168'h10000000004000000000000,
       168'h30000C00000000000000000,
       168'h600000000000000000000C0,
       168'hC00C0000000000000000000,
       168'h140000000000000000000000,
       168'h200001000000000000000000,
       168'h400800000000000000000000,
       168'hA00000000001400000000000,
       168'h1040000000000000000000000,
       168'h2004000000000000000000000,
       168'h5000000000028000000000000,
       168'h8000000004000000000000000,
       168'h18600000000000000000000000,
       168'h30000000000000000C00000000,
       168'h40200000000000000000000000,
       168'hC0300000000000000000000000,
       168'h100010000000000000000000000,
       168'h200040000000000000000000000,
       168'h5000000000000000A0000000000,
       168'h800000010000000000000000000,
       168'h1860000000000000000000000000,
       168'h3003000000000000000000000000,
       168'h4010000000000000000000000000,
       168'hA000000000140000000000000000,
       168'h10080000000000000000000000000,
       168'h30000000000000000000180000000,
       168'h60018000000000000000000000000,
       168'hC0000000000000000300000000000,
       168'h140005000000000000000000000000,
       168'h200000001000000000000000000000,
       168'h404000000000000000000000000000,
       168'h810000000000000000000000000102,
       168'h1000040000000000000000000000000,
       168'h3000000000000006000000000000000,
       168'h5000000000000000000000000000000,
       168'h8000000004000000000000000000000,
       168'h18000000000000000000000000030000,
       168'h30000000030000000000000000000000,
       168'h60000000000000000000000000000000,
       168'hA0000014000000000000000000000000,
       168'h108000000000000000000000000000000,
       168'h240000000000000000000000000000000,
       168'h600000000000C00000000000000000000,
       168'h800000040000000000000000000000000,
       168'h1800000000000300000000000000000000,
       168'h2000000000000010000000000000000000,
       168'h4008000000000000000000000000000000,
       168'hC000000000000000000000000000000600,
       168'h10000080000000000000000000000000000,
       168'h30600000000000000000000000000000000,
       168'h4A400000000000000000000000000000000,
       168'h80000004000000000000000000000000000,
       168'h180000003000000000000000000000000000,
       168'h200001000000000000000000000000000000,
       168'h600006000000000000000000000000000000,
       168'hC00000000000000006000000000000000000,
       168'h1000000000000100000000000000000000000,
       168'h3000000000000006000000000000000000000,
       168'h6000000003000000000000000000000000000,
       168'h8000001000000000000000000000000000000,
       168'h1800000000000000000000000000C000000000,
       168'h20000000000001000000000000000000000000,
       168'h48000000000000000000000000000000000000,
       168'hC0000000000000006000000000000000000000,
       168'h180000000000000000000000000000000000000,
       168'h280000000000000000000000000000005000000,
       168'h60000000C000000000000000000000000000000,
       168'hC00000000000000000000000000018000000000,
       168'h1800000600000000000000000000000000000000,
       168'h3000000C00000000000000000000000000000000,
       168'h4000000080000000000000000000000000000000,
       168'hC000300000000000000000000000000000000000,
       168'h10000400000000000000000000000000000000000,
       168'h30000000000000000000006000000000000000000,
       168'h600000000000000C0000000000000000000000000,
       168'hC0060000000000000000000000000000000000000,
       168'h180000006000000000000000000000000000000000,
       168'h3000000000C0000000000000000000000000000000,
       168'h410000000000000000000000000000000000000000,
       168'hA00140000000000000000000000000000000000000 };
  logic lockup;
  logic [LfsrDw-1:0] lfsr_d, lfsr_q;
  logic [LfsrDw-1:0] next_lfsr_state, coeffs;
  
  `ifdef SIMULATION`ifdef VERILATOR
      localparam logic [LfsrDw-1:0] DefaultSeedLocal = DefaultSeed;`else
    logic [LfsrDw-1:0] DefaultSeedLocal;
    logic prim_lfsr_use_default_seed;
    initial begin : p_randomize_default_seed
      if (!$value$plusargs("prim_lfsr_use_default_seed=%0d", prim_lfsr_use_default_seed)) begin
        
        `ASSERT_I(UseDefaultSeedRandomizeCheck_A, std::randomize(prim_lfsr_use_default_seed) with {
                                                  prim_lfsr_use_default_seed dist {0:/7, 1:/3};})
      end
      if (prim_lfsr_use_default_seed) begin
        DefaultSeedLocal = DefaultSeed;
      end else begin
        
        `ASSERT_I(DefaultSeedLocalRandomizeCheck_A, std::randomize(DefaultSeedLocal) with {
                                                    !(DefaultSeedLocal inside {'0, '1});})
      end
      $display("%m: DefaultSeed = 0x%0h, DefaultSeedLocal = 0x%0h", DefaultSeed, DefaultSeedLocal);
    end`endif`else
    localparam logic [LfsrDw-1:0] DefaultSeedLocal = DefaultSeed;
  `endif  
  
  
  
  if (64'(LfsrType) == 64'("GAL_XOR")) begin : gen_gal_xor
    
    if (CustomCoeffs > 0) begin : gen_custom
      assign coeffs = CustomCoeffs[LfsrDw-1:0];
    end else begin : gen_lut
      assign coeffs = LFSR_COEFFS[LfsrDw-LUT_OFF][LfsrDw-1:0];
      
      `ASSERT_INIT(MinLfsrWidth_A, LfsrDw >= $low(LFSR_COEFFS)+LUT_OFF)
      `ASSERT_INIT(MaxLfsrWidth_A, LfsrDw <= $high(LFSR_COEFFS)+LUT_OFF)
    end
    
    assign next_lfsr_state = LfsrDw'(entropy_i) ^ ({LfsrDw{lfsr_q[0]}} & coeffs) ^ (lfsr_q >> 1);
    
    assign lockup = ~(|lfsr_q);
    
    `ASSERT_INIT(DefaultSeedNzCheck_A, |DefaultSeedLocal)
  
  
  
  end else if (64'(LfsrType) == "FIB_XNOR") begin : gen_fib_xnor
    
    if (CustomCoeffs > 0) begin : gen_custom
      assign coeffs = CustomCoeffs[LfsrDw-1:0];
    end else begin : gen_lut
      assign coeffs = LFSR_COEFFS[LfsrDw-LUT_OFF][LfsrDw-1:0];
      
      `ASSERT_INIT(MinLfsrWidth_A, LfsrDw >= $low(LFSR_COEFFS)+LUT_OFF)
      `ASSERT_INIT(MaxLfsrWidth_A, LfsrDw <= $high(LFSR_COEFFS)+LUT_OFF)
    end
    
    assign next_lfsr_state = LfsrDw'(entropy_i) ^ {lfsr_q[LfsrDw-2:0], ~(^(lfsr_q & coeffs))};
    
    assign lockup = &lfsr_q;
    
    `ASSERT_INIT(DefaultSeedNzCheck_A, !(&DefaultSeedLocal))
  
  
  
  end else begin : gen_unknown_type
    assign coeffs = '0;
    assign next_lfsr_state = '0;
    assign lockup = 1'b0;
    `ASSERT_INIT(UnknownLfsrType_A, 0)
  end
  
  
  
  assign lfsr_d = (seed_en_i)           ? seed_i          :
                  (lfsr_en_i && lockup) ? DefaultSeedLocal     :
                  (lfsr_en_i)           ? next_lfsr_state :
                                          lfsr_q;
  logic [LfsrDw-1:0] sbox_out;
  if (NonLinearOut) begin : gen_out_non_linear
    
    
    
    
    
    
    
    
    
    
    
    
    localparam int NumSboxes = LfsrDw / 4;
    
    logic [3:0][NumSboxes-1:0][LfsrIdxDw-1:0] matrix_indices;
    for (genvar j = 0; j < LfsrDw; j++) begin : gen_input_idx_map
      assign matrix_indices[j / NumSboxes][j % NumSboxes] = j;
    end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    logic [3:0][NumSboxes-1:0][LfsrIdxDw-1:0] matrix_rotrev_indices;
    typedef logic [NumSboxes-1:0][LfsrIdxDw-1:0] matrix_col_t;
    
    function automatic matrix_col_t lrotcol(matrix_col_t col, integer shift);
      matrix_col_t out;
      for (int k = 0; k < NumSboxes; k++) begin
        out[(k + shift) % NumSboxes] = col[k];
      end
      return out;
    endfunction : lrotcol
    
    function automatic matrix_col_t revcol(matrix_col_t col);
      return {<<LfsrIdxDw{col}};
    endfunction : revcol
    always_comb begin : p_rotrev
      matrix_rotrev_indices[0] = matrix_indices[0];
      matrix_rotrev_indices[1] = lrotcol(matrix_indices[1], NumSboxes/2);
      matrix_rotrev_indices[2] = revcol(matrix_indices[2]);
      matrix_rotrev_indices[3] = revcol(lrotcol(matrix_indices[3], 1));
    end
    
    logic [LfsrDw-1:0][LfsrIdxDw-1:0] sbox_in_indices;
    for (genvar k = 0; k < LfsrDw; k++) begin : gen_reverse_upper
      assign sbox_in_indices[k] = matrix_rotrev_indices[k % 4][k / 4];
    end
`ifndef SYNTHESIS
      
      logic [LfsrDw-1:0] sbox_perm_test;
      always_comb begin : p_perm_check
        for (int k = 0; k < LfsrDw; k++) begin
          sbox_perm_test[sbox_in_indices[k]] = 1'b1;
        end
      end
      
      `ASSERT(SboxPermutationCheck_A, &sbox_perm_test)
`endif
`ifdef FPV_ON
      
      
      
      int shift;
      int unsigned sk, sj;
      `ASSUME(SjSkRange_M, (sj < NumSboxes) && (sk < NumSboxes))
      `ASSUME(SjSkDifferent_M, sj != sk)
      `ASSUME(SjSkStable_M, ##1 $stable(sj) && $stable(sk) && $stable(shift))
      `ASSERT(SboxInputIndexGroupIsUnique_A,
          !((((sbox_in_indices[sj * 4 + 0] + shift) % LfsrDw) == sbox_in_indices[sk * 4 + 0]) &&
            (((sbox_in_indices[sj * 4 + 1] + shift) % LfsrDw) == sbox_in_indices[sk * 4 + 1]) &&
            (((sbox_in_indices[sj * 4 + 2] + shift) % LfsrDw) == sbox_in_indices[sk * 4 + 2]) &&
            (((sbox_in_indices[sj * 4 + 3] + shift) % LfsrDw) == sbox_in_indices[sk * 4 + 3])))
      
      
      int y;
      int unsigned ik;
      `ASSUME(IkYRange_M, (ik < LfsrDw) && (y == 1 || y == -1))
      `ASSUME(IkStable_M, ##1 $stable(ik) && $stable(y))
      `ASSERT(IndicesNotAdjacent_A, (sbox_in_indices[ik] - sbox_in_indices[(ik + y) % LfsrDw]) != 1)`endif
    
    for (genvar k = 0; k < NumSboxes; k++) begin : gen_sboxes
      logic [3:0] sbox_in;
      assign sbox_in = {lfsr_q[sbox_in_indices[k*4 + 3]],
                        lfsr_q[sbox_in_indices[k*4 + 2]],
                        lfsr_q[sbox_in_indices[k*4 + 1]],
                        lfsr_q[sbox_in_indices[k*4 + 0]]};
      assign sbox_out[k*4 +: 4] = prim_cipher_pkg::PRINCE_SBOX4[sbox_in];
    end
  end else begin : gen_out_passthru
    assign sbox_out = lfsr_q;
  end
  
  if (StatePermEn) begin : gen_state_perm
    for (genvar k = 0; k < StateOutDw; k++) begin : gen_perm_loop
      assign state_o[k] = sbox_out[StatePerm[k]];
    end
    
    
    if (LfsrDw > StateOutDw) begin : gen_tieoff_unused
      logic unused_sbox_out;
      assign unused_sbox_out = ^sbox_out;
    end
  end else begin : gen_no_state_perm
    assign state_o = StateOutDw'(sbox_out);
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin : p_reg
    if (!rst_ni) begin
      lfsr_q <= DefaultSeedLocal;
    end else begin
      lfsr_q <= lfsr_d;
    end
  end
  
  
  
  `ASSERT_KNOWN(DataKnownO_A, state_o)
`ifndef SYNTHESIS
  function automatic logic [LfsrDw-1:0] compute_next_state(logic [LfsrDw-1:0]    lfsrcoeffs,
                                                           logic [EntropyDw-1:0] entropy,
                                                           logic [LfsrDw-1:0]    current_state);
    logic state0;
    logic [LfsrDw-1:0] next_state;
    next_state = current_state;
    
    if (64'(LfsrType) == 64'("GAL_XOR")) begin
      if (next_state == 0) begin
        next_state = DefaultSeedLocal;
      end else begin
        state0 = next_state[0];
        next_state = next_state >> 1;
        if (state0) next_state ^= lfsrcoeffs;
        next_state ^= LfsrDw'(entropy);
      end
    
    end else if (64'(LfsrType) == "FIB_XNOR") begin
      if (&next_state) begin
        next_state = DefaultSeedLocal;
      end else begin
        state0 = ~(^(next_state & lfsrcoeffs));
        next_state = next_state << 1;
        next_state[0] = state0;
        next_state ^= LfsrDw'(entropy);
      end
    end else begin
      $error("unknown lfsr type");
    end
    return next_state;
  endfunction : compute_next_state
  
  
  
  
  
  
  
  `ASSERT(NextStateCheck_A, ##1 lfsr_en_i && !seed_en_i |=> lfsr_q ==
      compute_next_state(coeffs, $past(entropy_i), $past(lfsr_q)))
  
  if (StatePermEn) begin : gen_perm_check
    
    logic [LfsrDw-1:0] lfsr_perm_test;
    initial begin : p_perm_check
      lfsr_perm_test = '0;
      for (int k = 0; k < LfsrDw; k++) begin
        lfsr_perm_test[StatePerm[k]] = 1'b1;
      end
      
      `ASSERT_I(PermutationCheck_A, &lfsr_perm_test)
    end
  end
`endif
  `ASSERT_INIT(InputWidth_A, LfsrDw >= EntropyDw)
  `ASSERT_INIT(OutputWidth_A, LfsrDw >= StateOutDw)
  
  `ASSERT(CoeffCheck_A, coeffs[LfsrDw-1])
  
  `ASSERT_KNOWN(OutputKnown_A, state_o)
  if (!StatePermEn && !NonLinearOut) begin : gen_output_sva
    `ASSERT(OutputCheck_A, state_o == StateOutDw'(lfsr_q))
  end
  
  
  `ASSERT(NoLockups_A, lfsr_en_i && !entropy_i && !seed_en_i |=> !lockup)
  
  if (ExtSeedSVA) begin : gen_ext_seed_sva
    
    
    
    `ASSERT(ExtDefaultSeedInputCheck_A, (seed_en_i && rst_ni) |=> lfsr_q == $past(seed_i))
  end
  
  
  
  if (LockupSVA) begin : gen_lockup_mechanism_sva
    
    `ASSERT(LfsrLockupCheck_A, lfsr_en_i && lockup && !seed_en_i |=> !lockup)
  end
  
  if(NonLinearOut) begin : gen_nonlinear_align_check_sva
    `ASSERT_INIT(SboxByteAlign_A, 2**$clog2(LfsrDw) == LfsrDw && LfsrDw >= 16)
  end
  if (MaxLenSVA) begin : gen_max_len_sva
`ifndef SYNTHESIS
    
    
    logic [LfsrDw-1:0] cnt_d, cnt_q;
    logic perturbed_d, perturbed_q;
    logic [LfsrDw-1:0] cmp_val;
    assign cmp_val = {{(LfsrDw-1){1'b1}}, 1'b0}; 
    assign cnt_d = (lfsr_en_i && lockup)             ? '0           :
                   (lfsr_en_i && (cnt_q == cmp_val)) ? '0           :
                   (lfsr_en_i)                       ? cnt_q + 1'b1 :
                                                       cnt_q;
    assign perturbed_d = perturbed_q | (|entropy_i) | seed_en_i;
    always_ff @(posedge clk_i or negedge rst_ni) begin : p_max_len
      if (!rst_ni) begin
        cnt_q       <= '0;
        perturbed_q <= 1'b0;
      end else begin
        cnt_q       <= cnt_d;
        perturbed_q <= perturbed_d;
      end
    end
    `ASSERT(MaximalLengthCheck0_A, cnt_q == 0 |-> lfsr_q == DefaultSeedLocal,
        clk_i, !rst_ni || perturbed_q)
    `ASSERT(MaximalLengthCheck1_A, cnt_q != 0 |-> lfsr_q != DefaultSeedLocal,
        clk_i, !rst_ni || perturbed_q)
`endif
  end
endmodule

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
