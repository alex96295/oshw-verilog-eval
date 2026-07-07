
package prim_sha2_pkg;
  localparam int NumRound256 = 64;   
  localparam int NumRound512 = 80;   
  typedef logic [31:0] sha_word32_t;
  typedef logic [63:0] sha_word64_t;
  localparam int WordByte32 = $bits(sha_word32_t)/8;
  localparam int WordByte64 = $bits(sha_word64_t)/8;
  typedef struct packed {
    sha_word32_t           data;
    logic [WordByte32-1:0] mask; 
                                 
  } sha_fifo32_t;
  typedef struct packed {
    sha_word64_t           data;
    logic [WordByte64-1:0] mask; 
                                 
  } sha_fifo64_t;
  typedef enum logic [1:0] {
    FifoIdle,
    FifoLoadFromFifo,
    FifoWait
  } fifoctl_state_e;
  
  typedef enum logic [3:0] {
    SHA2_256  = 4'b0001,
    SHA2_384  = 4'b0010,
    SHA2_512  = 4'b0100,
    SHA2_None = 4'b1000
  } digest_mode_e;
  
  typedef enum logic [5:0] {
    Key_128  = 6'b00_0001,
    Key_256  = 6'b00_0010,
    Key_384  = 6'b00_0100,
    Key_512  = 6'b00_1000,
    Key_1024 = 6'b01_0000,
    Key_None = 6'b10_0000
  } key_length_e;
  localparam sha_word32_t InitHash_256 [8]= '{
    32'h 6a09_e667, 32'h bb67_ae85, 32'h 3c6e_f372, 32'h a54f_f53a,
    32'h 510e_527f, 32'h 9b05_688c, 32'h 1f83_d9ab, 32'h 5be0_cd19
  };
  localparam sha_word64_t InitHash_384 [8]= '{
    64'h cbbb_9d5d_c105_9ed8, 64'h 629a_292a_367c_d507, 64'h 9159_015a_3070_dd17,
    64'h 152f_ecd8_f70e_5939, 64'h 6733_2667_ffc0_0b31, 64'h 8eb4_4a87_6858_1511,
    64'h db0c_2e0d_64f9_8fa7, 64'h 47b5_481d_befa_4fa4
  };
  localparam sha_word64_t InitHash_512 [8]= '{
    64'h 6a09_e667_f3bc_c908, 64'h bb67_ae85_84ca_a73b, 64'h 3c6e_f372_fe94_f82b,
    64'h a54f_f53a_5f1d_36f1, 64'h 510e_527f_ade6_82d1, 64'h 9b05_688c_2b3e_6c1f,
    64'h 1f83_d9ab_fb41_bd6b, 64'h 5be0_cd19_137e_2179
  };
  
  localparam sha_word32_t CubicRootPrime256 [NumRound256] = '{
    32'h 428a_2f98, 32'h 7137_4491, 32'h b5c0_fbcf, 32'h e9b5_dba5,
    32'h 3956_c25b, 32'h 59f1_11f1, 32'h 923f_82a4, 32'h ab1c_5ed5,
    32'h d807_aa98, 32'h 1283_5b01, 32'h 2431_85be, 32'h 550c_7dc3,
    32'h 72be_5d74, 32'h 80de_b1fe, 32'h 9bdc_06a7, 32'h c19b_f174,
    32'h e49b_69c1, 32'h efbe_4786, 32'h 0fc1_9dc6, 32'h 240c_a1cc,
    32'h 2de9_2c6f, 32'h 4a74_84aa, 32'h 5cb0_a9dc, 32'h 76f9_88da,
    32'h 983e_5152, 32'h a831_c66d, 32'h b003_27c8, 32'h bf59_7fc7,
    32'h c6e0_0bf3, 32'h d5a7_9147, 32'h 06ca_6351, 32'h 1429_2967,
    32'h 27b7_0a85, 32'h 2e1b_2138, 32'h 4d2c_6dfc, 32'h 5338_0d13,
    32'h 650a_7354, 32'h 766a_0abb, 32'h 81c2_c92e, 32'h 9272_2c85,
    32'h a2bf_e8a1, 32'h a81a_664b, 32'h c24b_8b70, 32'h c76c_51a3,
    32'h d192_e819, 32'h d699_0624, 32'h f40e_3585, 32'h 106a_a070,
    32'h 19a4_c116, 32'h 1e37_6c08, 32'h 2748_774c, 32'h 34b0_bcb5,
    32'h 391c_0cb3, 32'h 4ed8_aa4a, 32'h 5b9c_ca4f, 32'h 682e_6ff3,
    32'h 748f_82ee, 32'h 78a5_636f, 32'h 84c8_7814, 32'h 8cc7_0208,
    32'h 90be_fffa, 32'h a450_6ceb, 32'h bef9_a3f7, 32'h c671_78f2
  };
  
  localparam sha_word64_t CubicRootPrime512 [NumRound512] = '{
    64'h 428a_2f98_d728_ae22, 64'h 7137_4491_23ef_65cd, 64'h b5c0_fbcf_ec4d_3b2f,
    64'h e9b5_dba5_8189_dbbc, 64'h 3956_c25b_f348_b538, 64'h 59f1_11f1_b605_d019,
    64'h 923f_82a4_af19_4f9b, 64'h ab1c_5ed5_da6d_8118, 64'h d807_aa98_a303_0242,
    64'h 1283_5b01_4570_6fbe, 64'h 2431_85be_4ee4_b28c, 64'h 550c_7dc3_d5ff_b4e2,
    64'h 72be_5d74_f27b_896f, 64'h 80de_b1fe_3b16_96b1, 64'h 9bdc_06a7_25c7_1235,
    64'h c19b_f174_cf69_2694, 64'h e49b_69c1_9ef1_4ad2, 64'h efbe_4786_384f_25e3,
    64'h 0fc1_9dc6_8b8c_d5b5, 64'h 240c_a1cc_77ac_9c65, 64'h 2de9_2c6f_592b_0275,
    64'h 4a74_84aa_6ea6_e483, 64'h 5cb0_a9dc_bd41_fbd4, 64'h 76f9_88da_8311_53b5,
    64'h 983e_5152_ee66_dfab, 64'h a831_c66d_2db4_3210, 64'h b003_27c8_98fb_213f,
    64'h bf59_7fc7_beef_0ee4, 64'h c6e0_0bf3_3da8_8fc2, 64'h d5a7_9147_930a_a725,
    64'h 06ca_6351_e003_826f, 64'h 1429_2967_0a0e_6e70, 64'h 27b7_0a85_46d2_2ffc,
    64'h 2e1b_2138_5c26_c926, 64'h 4d2c_6dfc_5ac4_2aed, 64'h 5338_0d13_9d95_b3df,
    64'h 650a_7354_8baf_63de, 64'h 766a_0abb_3c77_b2a8, 64'h 81c2_c92e_47ed_aee6,
    64'h 9272_2c85_1482_353b, 64'h a2bf_e8a1_4cf1_0364, 64'h a81a_664b_bc42_3001,
    64'h c24b_8b70_d0f8_9791, 64'h c76c_51a3_0654_be30, 64'h d192_e819_d6ef_5218,
    64'h d699_0624_5565_a910, 64'h f40e_3585_5771_202a, 64'h 106a_a070_32bb_d1b8,
    64'h 19a4_c116_b8d2_d0c8, 64'h 1e37_6c08_5141_ab53, 64'h 2748_774c_df8e_eb99,
    64'h 34b0_bcb5_e19b_48a8, 64'h 391c_0cb3_c5c9_5a63, 64'h 4ed8_aa4a_e341_8acb,
    64'h 5b9c_ca4f_7763_e373, 64'h 682e_6ff3_d6b2_b8a3, 64'h 748f_82ee_5def_b2fc,
    64'h 78a5_636f_4317_2f60, 64'h 84c8_7814_a1f0_ab72, 64'h 8cc7_0208_1a64_39ec,
    64'h 90be_fffa_2363_1e28, 64'h a450_6ceb_de82_bde9, 64'h bef9_a3f7_b2c6_7915,
    64'h c671_78f2_e372_532b, 64'h ca27_3ece_ea26_619c, 64'h d186_b8c7_21c0_c207,
    64'h eada_7dd6_cde0_eb1e, 64'h f57d_4f7f_ee6e_d178, 64'h 06f0_67aa_7217_6fba,
    64'h 0a63_7dc5_a2c8_98a6, 64'h 113f_9804_bef9_0dae, 64'h 1b71_0b35_131c_471b,
    64'h 28db_77f5_2304_7d84, 64'h 32ca_ab7b_40c7_2493, 64'h 3c9e_be0a_15c9_bebc,
    64'h 431d_67c4_9c10_0d4c, 64'h 4cc5_d4be_cb3e_42b6, 64'h 597f_299c_fc65_7e2a,
    64'h 5fcb_6fab_3ad6_faec, 64'h 6c44_198c_4a47_5817
  };
  function automatic sha_word32_t conv_endian32(input sha_word32_t v, input logic swap);
    sha_word32_t conv_data;
    conv_data = {<<8{v}};
    conv_endian32 = (swap) ? conv_data : v;
  endfunction : conv_endian32
  function automatic sha_word32_t rotr32(input sha_word32_t v, input integer amt);
    rotr32 = (v >> amt) | (v << (32-amt));
  endfunction : rotr32
  function automatic sha_word64_t rotr64(input sha_word64_t v, input integer amt);
    rotr64 = (v >> amt) | (v << (64-amt));
  endfunction : rotr64
  function automatic sha_word32_t shiftr32(input sha_word32_t v, input integer amt);
    shiftr32 = (v >> amt);
  endfunction : shiftr32
  function automatic sha_word64_t shiftr64(input sha_word64_t v, input integer amt);
    shiftr64 = (v >> amt);
  endfunction : shiftr64
  
  function automatic sha_word64_t [7:0] compress_multi_256(input sha_word32_t w,
                                                           input sha_word32_t k,
                                                           input sha_word64_t [7:0] h_i);
    
    automatic sha_word32_t sigma_0, sigma_1, ch, maj, temp1, temp2;
    sigma_1 = rotr32(h_i[4][31:0], 6) ^ rotr32(h_i[4][31:0], 11) ^ rotr32(h_i[4][31:0], 25);
    ch = (h_i[4][31:0] & h_i[5][31:0]) ^ (~h_i[4][31:0] & h_i[6][31:0]);
    temp1 = (h_i[7][31:0] + sigma_1 + ch + k + w);
    sigma_0 = rotr32(h_i[0][31:0], 2) ^ rotr32(h_i[0][31:0], 13) ^ rotr32(h_i[0][31:0], 22);
    maj = (h_i[0][31:0] & h_i[1][31:0]) ^ (h_i[0][31:0] & h_i[2][31:0]) ^
          (h_i[1][31:0] & h_i[2][31:0]);
    temp2 = (sigma_0 + maj);
    
    compress_multi_256[7] = {32'b0, h_i[6][31:0]};          
    compress_multi_256[6] = {32'b0, h_i[5][31:0]};          
    compress_multi_256[5] = {32'b0, h_i[4][31:0]};          
    compress_multi_256[4] = {32'b0, h_i[3][31:0] + temp1};  
    compress_multi_256[3] = {32'b0, h_i[2][31:0]};          
    compress_multi_256[2] = {32'b0, h_i[1][31:0]};          
    compress_multi_256[1] = {32'b0, h_i[0][31:0]};          
    compress_multi_256[0] = {32'b0, (temp1 + temp2)};       
  endfunction : compress_multi_256
  
  function automatic sha_word32_t [7:0] compress_256(input sha_word32_t w,
                                                     input sha_word32_t k,
                                                     input sha_word32_t [7:0] h_i);
    automatic sha_word32_t sigma_0, sigma_1, ch, maj, temp1, temp2;
    sigma_1 = rotr32(h_i[4], 6) ^ rotr32(h_i[4], 11) ^ rotr32(h_i[4], 25);
    ch = (h_i[4] & h_i[5]) ^ (~h_i[4] & h_i[6]);
    temp1 = (h_i[7] + sigma_1 + ch + k + w);
    sigma_0 = rotr32(h_i[0], 2) ^ rotr32(h_i[0], 13) ^ rotr32(h_i[0], 22);
    maj = (h_i[0] & h_i[1]) ^ (h_i[0] & h_i[2]) ^
          (h_i[1] & h_i[2]);
    temp2 = (sigma_0 + maj);
    compress_256[7] = h_i[6];          
    compress_256[6] = h_i[5];          
    compress_256[5] = h_i[4];          
    compress_256[4] = h_i[3] + temp1;  
    compress_256[3] = h_i[2];          
    compress_256[2] = h_i[1];          
    compress_256[1] = h_i[0];          
    compress_256[0] = temp1 + temp2;       
  endfunction : compress_256
  
  function automatic sha_word64_t [7:0] compress_512(input sha_word64_t w,
                                                     input sha_word64_t k,
                                                     input sha_word64_t [7:0] h_i);
    automatic sha_word64_t sigma_0, sigma_1, ch, maj, temp1, temp2;
    sigma_1 = rotr64(h_i[4], 14) ^ rotr64(h_i[4], 18) ^ rotr64(h_i[4], 41);
    ch = (h_i[4] & h_i[5]) ^ (~h_i[4] & h_i[6]);
    temp1 = (h_i[7] + sigma_1 + ch + k + w);
    sigma_0 = rotr64(h_i[0], 28) ^ rotr64(h_i[0], 34) ^ rotr64(h_i[0], 39);
    maj = (h_i[0] & h_i[1]) ^ (h_i[0] & h_i[2]) ^ (h_i[1] & h_i[2]);
    temp2 = (sigma_0 + maj);
    compress_512[7] = h_i[6];          
    compress_512[6] = h_i[5];          
    compress_512[5] = h_i[4];          
    compress_512[4] = h_i[3] + temp1;  
    compress_512[3] = h_i[2];          
    compress_512[2] = h_i[1];          
    compress_512[1] = h_i[0];          
    compress_512[0] = (temp1 + temp2); 
  endfunction : compress_512
  function automatic sha_word32_t calc_w_256(input sha_word32_t w_0,
                                             input sha_word32_t w_1,
                                             input sha_word32_t w_9,
                                             input sha_word32_t w_14);
    automatic sha_word32_t sum0, sum1;
    sum0 = rotr32(w_1,   7) ^ rotr32(w_1,  18) ^ shiftr32(w_1,   3);
    sum1 = rotr32(w_14, 17) ^ rotr32(w_14, 19) ^ shiftr32(w_14, 10);
    calc_w_256 = w_0 + sum0 + w_9 + sum1;
  endfunction : calc_w_256
  function automatic sha_word64_t calc_w_512(input sha_word64_t w_0,
                                             input sha_word64_t w_1,
                                             input sha_word64_t w_9,
                                             input sha_word64_t w_14);
    automatic sha_word64_t sum0, sum1;
    sum0 = rotr64(w_1,   1) ^ rotr64(w_1,  8) ^ shiftr64(w_1,   7);
    sum1 = rotr64(w_14, 19) ^ rotr64(w_14, 61) ^ shiftr64(w_14, 6);
    calc_w_512 = w_0 + sum0 + w_9 + sum1;
  endfunction : calc_w_512
  typedef enum logic [31:0] {
    NoError                    = 32'h 0000_0000,
    
    
    
    
    
    
    SwPushMsgWhenShaDisabled   = 32'h 0000_0001,
    SwHashStartWhenShaDisabled = 32'h 0000_0002,
    SwUpdateSecretKeyInProcess = 32'h 0000_0003,
    SwHashStartWhenActive      = 32'h 0000_0004,
    SwPushMsgWhenDisallowed    = 32'h 0000_0005,
    SwInvalidConfig            = 32'h 0000_0006
  } err_code_e;
endpackage : prim_sha2_pkg

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
module TopModule import prim_sha2_pkg::*; (
  input clk_i,
  input rst_ni,
  input [1023:0]      secret_key_i, 
  input               hmac_en_i,
  input digest_mode_e digest_size_i,
  input key_length_e  key_length_i,
  input        reg_hash_start_i,
  input        reg_hash_stop_i,
  input        reg_hash_continue_i,
  input        reg_hash_process_i,
  output logic hash_done_o,
  output logic sha_hash_start_o,
  output logic sha_hash_continue_o,
  output logic sha_hash_process_o,
  input        sha_hash_done_i,
  
  output logic        sha_rvalid_o,
  output sha_fifo32_t sha_rdata_o,
  input               sha_rready_i,
  input               fifo_rvalid_i,
  input  sha_fifo32_t fifo_rdata_i,
  output logic        fifo_rready_o,
  
  output logic       fifo_wsel_o,      
  output logic       fifo_wvalid_o,
  
  output logic [3:0] fifo_wdata_sel_o,
  input              fifo_wready_i,
  input  [63:0] message_length_i,
  output [63:0] sha_message_length_o,
  output logic idle_o
);
  localparam int unsigned BlockSizeSHA256     = 512;
  localparam int unsigned BlockSizeSHA512     = 1024;
  localparam int unsigned BlockSizeBitsSHA256 = $clog2(BlockSizeSHA256);
  localparam int unsigned BlockSizeBitsSHA512 = $clog2(BlockSizeSHA512);
  localparam int unsigned HashWordBitsSHA256  = $clog2($bits(sha_word32_t));
  localparam bit [63:0] BlockSizeSHA256in64  = 64'(BlockSizeSHA256);
  localparam bit [63:0] BlockSizeSHA512in64  = 64'(BlockSizeSHA512);
  logic hash_start;    
  logic hash_continue; 
  logic hash_process;  
  logic hmac_hash_done;
  logic [BlockSizeSHA256-1:0] i_pad_256;
  logic [BlockSizeSHA512-1:0] i_pad_512;
  logic [BlockSizeSHA256-1:0] o_pad_256;
  logic [BlockSizeSHA512-1:0] o_pad_512;
  logic [63:0] txcount, txcount_d; 
  logic [BlockSizeBitsSHA512-HashWordBitsSHA256-1:0] pad_index_512;
  logic [BlockSizeBitsSHA256-HashWordBitsSHA256-1:0] pad_index_256;
  logic clr_txcount, load_txcount, inc_txcount;
  logic hmac_sha_rvalid;
  logic idle_d, idle_q;
  logic reg_hash_stop_d, reg_hash_stop_q;
  typedef enum logic [1:0] {
    SelIPad,
    SelOPad,
    SelFifo
  } sel_rdata_t;
  sel_rdata_t sel_rdata;
  typedef enum logic {
    SelIPadMsg,
    SelOPadMsg
  } sel_msglen_t;
  sel_msglen_t sel_msglen;
  typedef enum logic {
    Inner,  
    Outer   
  } round_t ;
  logic update_round ;
  round_t round_q, round_d;
  typedef enum logic [2:0] {
    StIdle,
    StIPad,
    StMsg,              
    StPushToMsgFifo,    
    StWaitResp,         
    StOPad,
    StDone              
  } st_e ;
  st_e st_q, st_d;
  logic clr_fifo_wdata_sel;
  logic txcnt_eq_blksz;
  logic reg_hash_process_flag;
  assign sha_hash_start_o    = (hmac_en_i) ? hash_start    : reg_hash_start_i;
  assign sha_hash_continue_o = (hmac_en_i) ? hash_continue : reg_hash_continue_i;
  assign sha_hash_process_o  = (hmac_en_i) ? reg_hash_process_i | hash_process : reg_hash_process_i;
  assign hash_done_o         = (hmac_en_i) ? hmac_hash_done                    : sha_hash_done_i;
  assign pad_index_512 = txcount[BlockSizeBitsSHA512-1:HashWordBitsSHA256];
  assign pad_index_256 = txcount[BlockSizeBitsSHA256-1:HashWordBitsSHA256];
  
  always_comb begin : adjust_key_pad_length
    
    i_pad_256 = '{default: '0};
    i_pad_512 = '{default: '0};
    o_pad_256 = '{default: '0};
    o_pad_512 = '{default: '0};
    unique case (key_length_i)
      Key_128: begin
        i_pad_256 = {secret_key_i[1023:896],
                    {(BlockSizeSHA256-128){1'b0}}} ^ {(BlockSizeSHA256/8){8'h36}};
        i_pad_512 = {secret_key_i[1023:896],
                    {(BlockSizeSHA512-128){1'b0}}} ^ {(BlockSizeSHA512/8){8'h36}};
        o_pad_256 = {secret_key_i[1023:896],
                    {(BlockSizeSHA256-128){1'b0}}} ^ {(BlockSizeSHA256/8){8'h5c}};
        o_pad_512 = {secret_key_i[1023:896],
                    {(BlockSizeSHA512-128){1'b0}}} ^ {(BlockSizeSHA512/8){8'h5c}};
      end
      Key_256: begin
        i_pad_256 = {secret_key_i[1023:768],
                    {(BlockSizeSHA256-256){1'b0}}} ^ {(BlockSizeSHA256/8){8'h36}};
        i_pad_512 = {secret_key_i[1023:768],
                    {(BlockSizeSHA512-256){1'b0}}} ^ {(BlockSizeSHA512/8){8'h36}};
        o_pad_256 = {secret_key_i[1023:768],
                    {(BlockSizeSHA256-256){1'b0}}} ^ {(BlockSizeSHA256/8){8'h5c}};
        o_pad_512 = {secret_key_i[1023:768],
                    {(BlockSizeSHA512-256){1'b0}}} ^ {(BlockSizeSHA512/8){8'h5c}};
      end
      Key_384: begin
        i_pad_256 = {secret_key_i[1023:640],
                    {(BlockSizeSHA256-384){1'b0}}} ^ {(BlockSizeSHA256/8){8'h36}};
        i_pad_512 = {secret_key_i[1023:640],
                    {(BlockSizeSHA512-384){1'b0}}} ^ {(BlockSizeSHA512/8){8'h36}};
        o_pad_256 = {secret_key_i[1023:640],
                    {(BlockSizeSHA256-384){1'b0}}} ^ {(BlockSizeSHA256/8){8'h5c}};
        o_pad_512 = {secret_key_i[1023:640],
                    {(BlockSizeSHA512-384){1'b0}}} ^ {(BlockSizeSHA512/8){8'h5c}};
      end
      Key_512: begin
        i_pad_256 = secret_key_i[1023:512] ^ {(BlockSizeSHA256/8){8'h36}};
        i_pad_512 = {secret_key_i[1023:512],
                    {(BlockSizeSHA512-512){1'b0}}} ^ {(BlockSizeSHA512/8){8'h36}};
        o_pad_256 = secret_key_i[1023:512] ^ {(BlockSizeSHA256/8){8'h5c}};
        o_pad_512 = {secret_key_i[1023:512],
                    {(BlockSizeSHA512-512){1'b0}}} ^ {(BlockSizeSHA512/8){8'h5c}};
      end
      Key_1024: begin 
        
        i_pad_256 = '{default: '0};
        i_pad_512 = secret_key_i[1023:0]   ^ {(BlockSizeSHA512/8){8'h36}};
        
        o_pad_256 = '{default: '0};
        o_pad_512 = secret_key_i[1023:0]   ^ {(BlockSizeSHA512/8){8'h5c}};
      end
      default: begin
      end
    endcase
  end
  assign fifo_rready_o = (hmac_en_i) ? (st_q == StMsg) & sha_rready_i : sha_rready_i ;
  
  assign sha_rvalid_o  = (!hmac_en_i) ? fifo_rvalid_i : hmac_sha_rvalid ;
  assign sha_rdata_o =
    (!hmac_en_i)    ? fifo_rdata_i                                                             :
    (sel_rdata == SelIPad && digest_size_i == SHA2_256)
                  ? '{data: i_pad_256[(BlockSizeSHA256-1)-32*pad_index_256-:32], mask: '1} :
    (sel_rdata == SelIPad && ((digest_size_i == SHA2_384) || (digest_size_i == SHA2_512)))
                  ? '{data: i_pad_512[(BlockSizeSHA512-1)-32*pad_index_512-:32], mask: '1} :
    (sel_rdata == SelOPad && digest_size_i == SHA2_256)
                  ? '{data: o_pad_256[(BlockSizeSHA256-1)-32*pad_index_256-:32], mask: '1} :
    (sel_rdata == SelOPad && ((digest_size_i == SHA2_384) || (digest_size_i == SHA2_512)))
                  ? '{data: o_pad_512[(BlockSizeSHA512-1)-32*pad_index_512-:32], mask: '1} :
    
                  fifo_rdata_i;
  logic [63:0] sha_msg_len;
  always_comb begin: assign_sha_message_length
    sha_msg_len = '0;
    if (!hmac_en_i) begin
      sha_msg_len = message_length_i;
    
    
    end else if (sel_msglen == SelIPadMsg) begin
      if (digest_size_i == SHA2_256) begin
        sha_msg_len = message_length_i + BlockSizeSHA256in64;
      end else if ((digest_size_i == SHA2_384) || (digest_size_i == SHA2_512)) begin
        sha_msg_len = message_length_i + BlockSizeSHA512in64;
      
      
      end else begin
        sha_msg_len = '0;
      end
    end else begin 
      
      if (digest_size_i == SHA2_256) begin
        sha_msg_len = BlockSizeSHA256in64 + 64'd256;
      end else if (digest_size_i == SHA2_384) begin
        sha_msg_len = BlockSizeSHA512in64 + 64'd384;
      end else begin 
        sha_msg_len = BlockSizeSHA512in64 + 64'd512;
      end
    end
  end
  assign sha_message_length_o = sha_msg_len;
  always_comb begin
    txcnt_eq_blksz = '0;
    unique case (digest_size_i)
      SHA2_256: txcnt_eq_blksz = (txcount[BlockSizeBitsSHA256-1:0] == '0) && (txcount != '0);
      SHA2_384: txcnt_eq_blksz = (txcount[BlockSizeBitsSHA512-1:0] == '0) && (txcount != '0);
      SHA2_512: txcnt_eq_blksz = (txcount[BlockSizeBitsSHA512-1:0] == '0) && (txcount != '0);
      default;
    endcase
  end
  assign inc_txcount = sha_rready_i && sha_rvalid_o;
  
  
  
  
  
  always_comb begin
    txcount_d = txcount;
    if (clr_txcount) begin
      txcount_d = '0;
    end else if (load_txcount) begin
      
      
      unique case (digest_size_i)
        SHA2_256: txcount_d = message_length_i + BlockSizeSHA256in64;
        SHA2_384: txcount_d = message_length_i + BlockSizeSHA512in64;
        SHA2_512: txcount_d = message_length_i + BlockSizeSHA512in64;
        default : txcount_d = message_length_i + '0;
      endcase
    end else if (inc_txcount) begin
      txcount_d[63:5] = txcount[63:5] + 1'b1; 
    end
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) txcount <= '0;
    else         txcount <= txcount_d;
  end
  
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      reg_hash_process_flag <= 1'b0;
    end else if (reg_hash_process_i) begin
      reg_hash_process_flag <= 1'b1;
    end else if (hmac_hash_done || reg_hash_start_i || reg_hash_continue_i) begin
      reg_hash_process_flag <= 1'b0;
    end
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      round_q <= Inner;
    end else if (update_round) begin
      round_q <= round_d;
    end
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      fifo_wdata_sel_o <= '0;
    end else if (clr_fifo_wdata_sel) begin
      fifo_wdata_sel_o <= '0;
    end else if (fifo_wsel_o && fifo_wvalid_o) begin
      fifo_wdata_sel_o <= fifo_wdata_sel_o + 1'b1; 
    end
  end
  assign sel_msglen = (round_q == Inner) ? SelIPadMsg : SelOPadMsg ;
  always_ff @(posedge clk_i or negedge rst_ni) begin : state_ff
    if (!rst_ni) st_q <= StIdle;
    else         st_q <= st_d;
  end
  always_comb begin : next_state
    hmac_hash_done     = 1'b0;
    hmac_sha_rvalid    = 1'b0;
    clr_txcount        = 1'b0;
    load_txcount       = 1'b0;
    update_round       = 1'b0;
    round_d            = Inner;
    fifo_wsel_o        = 1'b0;   
    fifo_wvalid_o      = 1'b0;
    clr_fifo_wdata_sel = 1'b1;
    sel_rdata          = SelFifo;
    hash_start         = 1'b0;
    hash_continue      = 1'b0;
    hash_process       = 1'b0;
    st_d               = st_q;
    unique case (st_q)
      StIdle: begin
        
        
        
        update_round = 1'b1;
        round_d      = Inner;
        if (hmac_en_i && reg_hash_start_i) begin
          st_d = StIPad; 
          clr_txcount  = 1'b1;
          hash_start   = 1'b1;
        end else if (hmac_en_i && reg_hash_continue_i) begin
          st_d = StMsg; 
          load_txcount  = 1'b1;
          hash_continue = 1'b1;
        end else begin
          st_d = StIdle;
        end
      end
      StIPad: begin
        sel_rdata = SelIPad;
        if (txcnt_eq_blksz) begin
          st_d = StMsg;
          hmac_sha_rvalid = 1'b0; 
        end else begin
          st_d = StIPad;
          hmac_sha_rvalid = 1'b1;
        end
      end
      StMsg: begin
        sel_rdata   = SelFifo;
        fifo_wsel_o = (round_q == Outer);
        if ( (((round_q == Inner) && reg_hash_process_flag) || (round_q == Outer))
            && (txcount >= sha_message_length_o)) begin
          st_d    = StWaitResp;
          hmac_sha_rvalid = 1'b0; 
          hash_process    = (round_q == Outer);
        end else if (txcnt_eq_blksz && (txcount >= sha_message_length_o)
                     && reg_hash_stop_q && (round_q == Inner)) begin
          
          
          
          st_d =  StWaitResp;
          hmac_sha_rvalid = 1'b0;
        end else begin
          st_d            = StMsg;
          hmac_sha_rvalid = fifo_rvalid_i;
        end
      end
      StWaitResp: begin
        hmac_sha_rvalid = 1'b0;
        if (sha_hash_done_i) begin
          if (round_q == Outer) begin
            st_d = StDone;
          end else begin 
            if (reg_hash_stop_q) begin
              st_d = StDone;
            end else begin
              st_d = StPushToMsgFifo;
            end
          end
        end else begin
          st_d = StWaitResp;
        end
      end
      StPushToMsgFifo: begin
        hmac_sha_rvalid    = 1'b0;
        fifo_wsel_o        = 1'b1;
        fifo_wvalid_o      = 1'b1;
        clr_fifo_wdata_sel = 1'b0;
        if (fifo_wready_i && (((fifo_wdata_sel_o == 4'd7) && (digest_size_i == SHA2_256)) ||
                             ((fifo_wdata_sel_o == 4'd15) && (digest_size_i == SHA2_512)) ||
                             ((fifo_wdata_sel_o == 4'd11) && (digest_size_i == SHA2_384)))) begin
          st_d = StOPad;
          clr_txcount  = 1'b1;
          update_round = 1'b1;
          round_d      = Outer;
          hash_start   = 1'b1;
        end else begin
          st_d = StPushToMsgFifo;
        end
      end
      StOPad: begin
        sel_rdata   = SelOPad;
        fifo_wsel_o = 1'b1; 
        if (txcnt_eq_blksz) begin
          st_d = StMsg;
          hmac_sha_rvalid = 1'b0; 
        end else begin
          st_d = StOPad;
          hmac_sha_rvalid = 1'b1;
        end
      end
      StDone: begin
        
        st_d = StIdle;
        hmac_hash_done = 1'b1;
      end
      default: begin
        st_d = StIdle;
      end
    endcase
  end
  
  
  assign reg_hash_stop_d = (reg_hash_stop_i == 1'b1)                            ? 1'b1 :
                           (sha_hash_done_i == 1'b1 && reg_hash_stop_q == 1'b1) ? 1'b0 :
                                                                                  reg_hash_stop_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      reg_hash_stop_q <= 1'b0;
    end else begin
      reg_hash_stop_q <= reg_hash_stop_d;
    end
  end
  
  assign idle_d =
      
      (reg_hash_start_i || reg_hash_continue_i) ? 1'b0 :
      
      (st_q == StIdle) ? 1'b1 :
      
      
      (txcnt_eq_blksz && reg_hash_stop_d) ? 1'b1 :
      
      idle_q;
  assign idle_o = idle_d;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      idle_q <= 1'b1;
    end else begin
      idle_q <= idle_d;
    end
  end
  
  
  
  `ASSERT(ValidSelRdata_A, hmac_en_i |-> sel_rdata inside {SelIPad, SelOPad, SelFifo})
  `ASSERT(ValidDigestSize_A, (hmac_en_i && (sel_msglen == SelOPadMsg)) |->
      digest_size_i inside {SHA2_256, SHA2_384, SHA2_512})
endmodule
