
package prim_util_pkg;
  
  function automatic integer vbits(integer value);
    return (value == 1) ? 1 : $clog2(value);
  endfunction
  
  function automatic integer ceil_div(input integer dividend, input integer divisor);
    ceil_div = ((dividend % divisor) != 0) ? (dividend / divisor) + 1 : (dividend / divisor);
  endfunction
`ifdef INC_ASSERT
  
  
  
  
  
  bit end_of_simulation;`endif
endpackage

package aes_pkg;
parameter bit ClearStatusOnFatalAlert = 1'b0;
parameter int unsigned NumSharesKey = 2;
parameter int unsigned SliceSizeCtr = 16;
parameter int unsigned NumSlicesCtr = aes_reg_pkg::NumRegsIv * 32 / SliceSizeCtr;
parameter int unsigned SliceIdxWidth = prim_util_pkg::vbits(NumSlicesCtr);
parameter int unsigned SliceIdxMaxInc32 = 32 / SliceSizeCtr - 1;
parameter int unsigned WidthPRDClearing = 64;
parameter int unsigned NumChunksPRDClearing128 = 128/WidthPRDClearing;
parameter int unsigned NumChunksPRDClearing256 = 256/WidthPRDClearing;
parameter int unsigned WidthPRDSBox     = 8;  
                                              
                                              
parameter int unsigned WidthPRDData     = 16*WidthPRDSBox; 
parameter int unsigned WidthPRDKey      = 4*WidthPRDSBox;  
parameter int unsigned WidthPRDMasking  = WidthPRDData + WidthPRDKey;
parameter int ClearingLfsrWidth = 64;
typedef logic [ClearingLfsrWidth-1:0] clearing_lfsr_seed_t;
typedef logic [ClearingLfsrWidth-1:0][$clog2(ClearingLfsrWidth)-1:0] clearing_lfsr_perm_t;
parameter clearing_lfsr_seed_t RndCnstClearingLfsrSeedDefault = 64'hc32d580f74f1713a;
parameter clearing_lfsr_perm_t RndCnstClearingLfsrPermDefault = {
  128'hb33fdfc81deb6292c21f8a3102585067,
  256'h9c2f4be1bbe937b4b7c9d7f4e57568d99c8ae291a899143e0d8459d31b143223
};
parameter clearing_lfsr_perm_t RndCnstClearingSharePermDefault = {
  128'hf66fd61b27847edc2286706fb3a2e900,
  256'h9736b95ac3f3b5205caf8dc536aad73605d393c8dd94476e830e97891d4828d0
};
parameter int MaskingLfsrWidth = 160; 
typedef logic [MaskingLfsrWidth-1:0][$clog2(MaskingLfsrWidth)-1:0] masking_lfsr_perm_t;
parameter masking_lfsr_perm_t RndCnstMaskingLfsrPermDefault = {
  256'h17261943423e4c5c03872194050c7e5f8497081d96666d406f4b606473303469,
  256'h8e7c721c8832471f59919e0b128f067b25622768462e554d8970815d490d7f44,
  256'h048c867d907a239b20220f6c79071a852d76485452189f14091b1e744e396737,
  256'h4f785b772b352f6550613c58130a8b104a3f28019c9a380233956b00563a512c,
  256'h808d419d63982a16995e0e3b57826a36718a9329452492533d83115a75316e15
};
parameter int MaskingPrngStateWidth = 288;
typedef logic [MaskingPrngStateWidth-1:0] masking_lfsr_seed_t;
parameter masking_lfsr_seed_t RndCnstMaskingLfsrSeedDefault = {
  32'h758a4420,
  256'h31e1c461_6ea343ec_153282a3_0c132b57_23c5a4cf_4743b3c7_c32d580f_74f1713a
};
typedef enum integer {
  SBoxImplLut,                   
  SBoxImplCanright,              
  SBoxImplCanrightMasked,        
                                 
  SBoxImplCanrightMaskedNoreuse, 
                                 
  SBoxImplDom                    
                                 
} sbox_impl_e;
parameter int unsigned GCMDegree = 128;
parameter bit [GCMDegree-1:0] GCMIPoly = GCMDegree'(1'b1) << 7 |
                                         GCMDegree'(1'b1) << 2 |
                                         GCMDegree'(1'b1) << 1 |
                                         GCMDegree'(1'b1) << 0;
parameter int AES_OP_WIDTH             = 2;
parameter int AES_MODE_WIDTH           = 6;
parameter int AES_KEYLEN_WIDTH         = 3;
parameter int AES_PRNGRESEEDRATE_WIDTH = 3;
parameter int AES_GCMPHASE_WIDTH       = 6;
typedef enum logic [AES_OP_WIDTH-1:0] {
  AES_ENC = 2'b01,
  AES_DEC = 2'b10
} aes_op_e;
typedef enum logic [AES_MODE_WIDTH-1:0] {
  AES_ECB  = 6'b00_0001,
  AES_CBC  = 6'b00_0010,
  AES_CFB  = 6'b00_0100,
  AES_OFB  = 6'b00_1000,
  AES_CTR  = 6'b01_0000,
  AES_GCM  = 6'b10_0000,
  AES_NONE = 6'b11_1111
} aes_mode_e;
typedef enum logic [AES_OP_WIDTH-1:0] {
  CIPH_FWD = 2'b01,
  CIPH_INV = 2'b10
} ciph_op_e;
typedef enum logic [AES_KEYLEN_WIDTH-1:0] {
  AES_128 = 3'b001,
  AES_192 = 3'b010,
  AES_256 = 3'b100
} key_len_e;
typedef enum logic [AES_PRNGRESEEDRATE_WIDTH-1:0] {
  PER_1  = 3'b001,
  PER_64 = 3'b010,
  PER_8K = 3'b100
} prs_rate_e;
parameter int unsigned BlockCtrWidth = 13;
typedef enum logic [AES_GCMPHASE_WIDTH-1:0] {
  GCM_INIT    = 6'b00_0001,
  GCM_RESTORE = 6'b00_0010,
  GCM_AAD     = 6'b00_0100,
  GCM_TEXT    = 6'b00_1000,
  GCM_SAVE    = 6'b01_0000,
  GCM_TAG     = 6'b10_0000
} gcm_phase_e;
typedef struct packed {
  logic [31:7] unused;
  logic        alert_fatal_fault;
  logic        alert_recov_ctrl_update_err;
  logic        input_ready;
  logic        output_valid;
  logic        output_lost;
  logic        stall;
  logic        idle;
} status_t;
typedef struct packed {
  logic        recov_ctrl_update_err;
  logic        fatal_fault;
} alert_test_t;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  localparam int CipherCtrlStateWidth = 6;
  typedef enum logic [CipherCtrlStateWidth-1:0] {
    CIPHER_CTRL_IDLE        = 6'b001001,
    CIPHER_CTRL_INIT        = 6'b100011,
    CIPHER_CTRL_ROUND       = 6'b111101,
    CIPHER_CTRL_FINISH      = 6'b010000,
    CIPHER_CTRL_PRNG_RESEED = 6'b100100,
    CIPHER_CTRL_CLEAR_S     = 6'b111010,
    CIPHER_CTRL_CLEAR_KD    = 6'b001110,
    CIPHER_CTRL_ERROR       = 6'b010111
  } aes_cipher_ctrl_e;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  localparam int CtrStateWidth = 5;
  typedef enum logic [CtrStateWidth-1:0] {
    CTR_IDLE  = 5'b01110,
    CTR_INCR  = 5'b11000,
    CTR_ERROR = 5'b00001
  } aes_ctr_e;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  localparam int CtrlStateWidth = 6;
  typedef enum logic [CtrlStateWidth-1:0] {
    CTRL_IDLE        = 6'b001001,
    CTRL_LOAD        = 6'b100011,
    CTRL_GHASH_READY = 6'b111101,
    CTRL_PRNG_RESEED = 6'b010000,
    CTRL_FINISH      = 6'b100100,
    CTRL_CLEAR_I     = 6'b111010,
    CTRL_CLEAR_CO    = 6'b001110,
    CTRL_ERROR       = 6'b010111
  } aes_ctrl_e;
localparam int GhashStateWidth = 7;
typedef enum logic [GhashStateWidth-1:0] {
  GHASH_IDLE                    = 7'b1100001,
  GHASH_MULT                    = 7'b0010001,
  GHASH_ADD_S                   = 7'b0000110,
  GHASH_OUT                     = 7'b0110111,
  GHASH_ERROR                   = 7'b0111010,
  GHASH_MASKED_INIT             = 7'b1111100,
  GHASH_MASKED_ADD_STATE_SHARES = 7'b0101101,
  GHASH_MASKED_ADD_CORR         = 7'b0001000,
  GHASH_MASKED_SETTLE           = 7'b1001111
} aes_ghash_e;
parameter int Mux2SelWidth = 3;
typedef enum logic [Mux2SelWidth-1:0] {
  MUX2_SEL_0 = 3'b011,
  MUX2_SEL_1 = 3'b100
} mux2_sel_e;
parameter int Mux3SelWidth = 5;
typedef enum logic [Mux3SelWidth-1:0] {
  MUX3_SEL_0 = 5'b01110,
  MUX3_SEL_1 = 5'b11000,
  MUX3_SEL_2 = 5'b00001
} mux3_sel_e;
parameter int Mux4SelWidth = 5;
typedef enum logic [Mux4SelWidth-1:0] {
  MUX4_SEL_0 = 5'b01110,
  MUX4_SEL_1 = 5'b11000,
  MUX4_SEL_2 = 5'b00001,
  MUX4_SEL_3 = 5'b10111
} mux4_sel_e;
localparam int Mux5SelWidth = 6;
typedef enum logic [Mux5SelWidth-1:0] {
  MUX5_SEL_0 = 6'b110000,
  MUX5_SEL_1 = 6'b001000,
  MUX5_SEL_2 = 6'b000011,
  MUX5_SEL_3 = 6'b011101,
  MUX5_SEL_4 = 6'b111110
} mux5_sel_e;
parameter int Mux6SelWidth = 6;
typedef enum logic [Mux6SelWidth-1:0] {
  MUX6_SEL_0 = 6'b011101,
  MUX6_SEL_1 = 6'b110000,
  MUX6_SEL_2 = 6'b001000,
  MUX6_SEL_3 = 6'b000011,
  MUX6_SEL_4 = 6'b111110,
  MUX6_SEL_5 = 6'b100101
} mux6_sel_e;
parameter int DIPSelNum = 2;
parameter int DIPSelWidth = Mux2SelWidth;
typedef enum logic [DIPSelWidth-1:0] {
  DIP_DATA_IN = MUX2_SEL_0,
  DIP_CLEAR   = MUX2_SEL_1
} dip_sel_e;
parameter int SISelNum = 2;
parameter int SISelWidth = Mux2SelWidth;
typedef enum logic [SISelWidth-1:0] {
  SI_ZERO = MUX2_SEL_0,
  SI_DATA = MUX2_SEL_1
} si_sel_e;
parameter int AddSISelNum = 2;
parameter int AddSISelWidth = Mux2SelWidth;
typedef enum logic [AddSISelWidth-1:0] {
  ADD_SI_ZERO = MUX2_SEL_0,
  ADD_SI_IV   = MUX2_SEL_1
} add_si_sel_e;
parameter int StateSelNum = 3;
parameter int StateSelWidth = Mux3SelWidth;
typedef enum logic [StateSelWidth-1:0] {
  STATE_INIT  = MUX3_SEL_0,
  STATE_ROUND = MUX3_SEL_1,
  STATE_CLEAR = MUX3_SEL_2
} state_sel_e;
parameter int AddRKSelNum = 3;
parameter int AddRKSelWidth = Mux3SelWidth;
typedef enum logic [AddRKSelWidth-1:0] {
  ADD_RK_INIT  = MUX3_SEL_0,
  ADD_RK_ROUND = MUX3_SEL_1,
  ADD_RK_FINAL = MUX3_SEL_2
} add_rk_sel_e;
parameter int KeyInitSelNum = 3;
parameter int KeyInitSelWidth = Mux3SelWidth;
typedef enum logic [KeyInitSelWidth-1:0] {
  KEY_INIT_INPUT  = MUX3_SEL_0,
  KEY_INIT_KEYMGR = MUX3_SEL_1,
  KEY_INIT_CLEAR  = MUX3_SEL_2
} key_init_sel_e;
parameter int IVSelNum = 6;
parameter int IVSelWidth = Mux6SelWidth;
typedef enum logic [IVSelWidth-1:0] {
  IV_INPUT        = MUX6_SEL_0,
  IV_DATA_OUT     = MUX6_SEL_1,
  IV_DATA_OUT_RAW = MUX6_SEL_2,
  IV_DATA_IN_PREV = MUX6_SEL_3,
  IV_CTR          = MUX6_SEL_4,
  IV_CLEAR        = MUX6_SEL_5
} iv_sel_e;
parameter int KeyFullSelNum = 4;
parameter int KeyFullSelWidth = Mux4SelWidth;
typedef enum logic [KeyFullSelWidth-1:0] {
  KEY_FULL_ENC_INIT = MUX4_SEL_0,
  KEY_FULL_DEC_INIT = MUX4_SEL_1,
  KEY_FULL_ROUND    = MUX4_SEL_2,
  KEY_FULL_CLEAR    = MUX4_SEL_3
} key_full_sel_e;
parameter int KeyDecSelNum = 2;
parameter int KeyDecSelWidth = Mux2SelWidth;
typedef enum logic [KeyDecSelWidth-1:0] {
  KEY_DEC_EXPAND = MUX2_SEL_0,
  KEY_DEC_CLEAR  = MUX2_SEL_1
} key_dec_sel_e;
parameter int KeyWordsSelNum = 4;
parameter int KeyWordsSelWidth = Mux4SelWidth;
typedef enum logic [KeyWordsSelWidth-1:0] {
  KEY_WORDS_0123 = MUX4_SEL_0,
  KEY_WORDS_2345 = MUX4_SEL_1,
  KEY_WORDS_4567 = MUX4_SEL_2,
  KEY_WORDS_ZERO = MUX4_SEL_3
} key_words_sel_e;
parameter int RoundKeySelNum = 2;
parameter int RoundKeySelWidth = Mux2SelWidth;
typedef enum logic [RoundKeySelWidth-1:0] {
  ROUND_KEY_DIRECT = MUX2_SEL_0,
  ROUND_KEY_MIXED  = MUX2_SEL_1
} round_key_sel_e;
parameter int AddSOSelNum = 3;
parameter int AddSOSelWidth = Mux3SelWidth;
typedef enum logic [AddSOSelWidth-1:0] {
  ADD_SO_ZERO = MUX3_SEL_0,
  ADD_SO_IV   = MUX3_SEL_1,
  ADD_SO_DIP  = MUX3_SEL_2
} add_so_sel_e;
parameter int GHashInSelNum = 2;
parameter int GHashInSelWidth = Mux2SelWidth;
typedef enum logic [GHashInSelWidth-1:0] {
  GHASH_IN_DATA_IN_PREV = MUX2_SEL_0,
  GHASH_IN_DATA_OUT     = MUX2_SEL_1
} ghash_in_sel_e;
parameter int GHashAddInSelWidth = 3;
typedef enum logic [GHashAddInSelWidth-1:0] {
  ADD_IN_GHASH_IN = 3'b001,
  ADD_IN_CORR_A   = 3'b010,
  ADD_IN_CORR_B   = 3'b100,
  ADD_IN_ZERO     = 3'b000
} ghash_add_in_sel_e;
parameter int GHashStateSelNum = 5;
parameter int GHashStateSelWidth = Mux5SelWidth;
typedef enum logic [GHashStateSelWidth-1:0] {
  GHASH_STATE_RESTORE = MUX5_SEL_0,
  GHASH_STATE_INIT    = MUX5_SEL_1,
  GHASH_STATE_ADD     = MUX5_SEL_2,
  GHASH_STATE_ADD_S   = MUX5_SEL_3,
  GHASH_STATE_MULT    = MUX5_SEL_4
} ghash_state_sel_e;
parameter int GFMultInSelWidth = 3;
typedef enum logic [GFMultInSelWidth-1:0] {
  MULT_IN_STATE0 = 3'b001,
  MULT_IN_STATE1 = 3'b010,
  MULT_IN_S1     = 3'b100,
  MULT_IN_ZERO   = 3'b000
} gf_mult_in_sel_e;
parameter int DataOutSelNum = 2;
parameter int DataOutSelWidth = Mux2SelWidth;
typedef enum logic [DataOutSelWidth-1:0] {
  DATA_OUT_CIPHER = MUX2_SEL_0,
  DATA_OUT_GHASH  = MUX2_SEL_1
} data_out_sel_e;
parameter int Sp2VNum = 2;
parameter int Sp2VWidth = Mux2SelWidth;
typedef enum logic [Sp2VWidth-1:0] {
  SP2V_HIGH = MUX2_SEL_0,
  SP2V_LOW  = MUX2_SEL_1
} sp2v_e;
typedef logic [Sp2VWidth-1:0] sp2v_logic_t;
parameter sp2v_logic_t SP2V_LOGIC_HIGH = {SP2V_HIGH};
typedef struct packed {
  logic      manual_operation;
  prs_rate_e prng_reseed_rate;
  logic      sideload;
  key_len_e  key_len;
  aes_mode_e mode;
  aes_op_e   operation;
} ctrl_reg_t;
parameter ctrl_reg_t CTRL_RESET = '{
  manual_operation: aes_reg_pkg::AES_CTRL_SHADOWED_MANUAL_OPERATION_RESVAL,
  prng_reseed_rate: prs_rate_e'(aes_reg_pkg::AES_CTRL_SHADOWED_PRNG_RESEED_RATE_RESVAL),
  sideload:         aes_reg_pkg::AES_CTRL_SHADOWED_SIDELOAD_RESVAL,
  key_len:          key_len_e'(aes_reg_pkg::AES_CTRL_SHADOWED_KEY_LEN_RESVAL),
  mode:             aes_mode_e'(aes_reg_pkg::AES_CTRL_SHADOWED_MODE_RESVAL),
  operation:        aes_op_e'(aes_reg_pkg::AES_CTRL_SHADOWED_OPERATION_RESVAL)
};
typedef struct packed {
  logic [4:0] num_valid_bytes;
  gcm_phase_e phase;
} ctrl_gcm_reg_t;
function automatic logic [7:0] aes_mul2(logic [7:0] in);
  logic [7:0] out;
  out[7] = in[6];
  out[6] = in[5];
  out[5] = in[4];
  out[4] = in[3] ^ in[7];
  out[3] = in[2] ^ in[7];
  out[2] = in[1];
  out[1] = in[0] ^ in[7];
  out[0] = in[7];
  return out;
endfunction
function automatic logic [7:0] aes_mul4(logic [7:0] in);
  return aes_mul2(aes_mul2(in));
endfunction
function automatic logic [7:0] aes_div2(logic [7:0] in);
  logic [7:0] out;
  out[7] = in[0];
  out[6] = in[7];
  out[5] = in[6];
  out[4] = in[5];
  out[3] = in[4] ^ in[0];
  out[2] = in[3] ^ in[0];
  out[1] = in[2];
  out[0] = in[1] ^ in[0];
  return out;
endfunction
function automatic logic [31:0] aes_circ_byte_shift(logic [31:0] in, logic [1:0] shift);
  logic [31:0] out;
  logic [31:0] s;
  s = {30'b0,shift};
  out = {in[8*((7-s)%4) +: 8], in[8*((6-s)%4) +: 8],
         in[8*((5-s)%4) +: 8], in[8*((4-s)%4) +: 8]};
  return out;
endfunction
function automatic logic [3:0][3:0][7:0] aes_transpose(logic [3:0][3:0][7:0] in);
  logic [3:0][3:0][7:0] transpose;
  transpose = '0;
  for (int j = 0; j < 4; j++) begin
    for (int i = 0; i < 4; i++) begin
      transpose[i][j] = in[j][i];
    end
  end
  return transpose;
endfunction
function automatic logic [127:0] aes_state_to_ghash_vec(logic [3:0][3:0][7:0] in);
  logic [127:0] out;
  logic [15:0][7:0] byte_vec;
  for (int i = 0; i < 4; i++) begin
    for (int j = 0; j < 4; j++) begin
      byte_vec[15 - 4*i - j] = in[j][i];
    end
  end
  out = byte_vec;
  return out;
endfunction
function automatic logic [127:0] aes_ghash_reverse_bit_order(logic [127:0] in);
  logic [127:0] out;
  for (int i = 0; i < 128; i++) begin
    out[i] = in[127-i];
  end
  return out;
endfunction
function automatic logic [3:0][7:0] aes_col_get(logic [3:0][3:0][7:0] in, logic [1:0] idx);
  logic [3:0][7:0] out;
  for (int i = 0; i < 4; i++) begin
    out[i] = in[i][idx];
  end
  return out;
endfunction
function automatic logic [7:0] aes_mvm(
  logic [7:0] vec_b,
  logic [7:0] mat_a [8]
);
  logic [7:0] vec_c;
  vec_c = '0;
  for (int i = 0; i < 8; i++) begin
    for (int j = 0; j < 8; j++) begin
      vec_c[i] = vec_c[i] ^ (mat_a[j][i] & vec_b[7-j]);
    end
  end
  return vec_c;
endfunction
function automatic integer aes_rot_int(integer in, integer num);
  integer out;
  if (in == 0) begin
    out = num - 1;
  end else begin
    out = in - 1;
  end
  return out;
endfunction
function automatic logic [3:0][7:0] aes_prd_get_lsbs(
  logic [(4*WidthPRDSBox)-1:0] in
);
  logic [3:0][7:0] prd_lsbs;
  for (int i = 0; i < 4; i++) begin
    prd_lsbs[i] = in[i*WidthPRDSBox +: 8];
  end
  return prd_lsbs;
endfunction
endpackage

package aes_reg_pkg;
  
  parameter int NumRegsKey = 8;
  parameter int NumRegsIv = 4;
  parameter int NumRegsData = 4;
  parameter int NumAlerts = 2;
  
  parameter int BlockAw = 8;
  
  parameter int NumRegs = 35;
  
  typedef enum int {
    AlertRecovCtrlUpdateErrIdx = 0,
    AlertFatalFaultIdx = 1
  } aes_alert_idx_t;
  
  
  
  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } fatal_fault;
    struct packed {
      logic        q;
      logic        qe;
    } recov_ctrl_update_err;
  } aes_reg2hw_alert_test_reg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } aes_reg2hw_key_share0_mreg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } aes_reg2hw_key_share1_mreg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } aes_reg2hw_iv_mreg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } aes_reg2hw_data_in_mreg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        re;
  } aes_reg2hw_data_out_mreg_t;
  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
      logic        re;
    } manual_operation;
    struct packed {
      logic [2:0]  q;
      logic        qe;
      logic        re;
    } prng_reseed_rate;
    struct packed {
      logic        q;
      logic        qe;
      logic        re;
    } sideload;
    struct packed {
      logic [2:0]  q;
      logic        qe;
      logic        re;
    } key_len;
    struct packed {
      logic [5:0]  q;
      logic        qe;
      logic        re;
    } mode;
    struct packed {
      logic [1:0]  q;
      logic        qe;
      logic        re;
    } operation;
  } aes_reg2hw_ctrl_shadowed_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } force_masks;
    struct packed {
      logic        q;
    } key_touch_forces_reseed;
  } aes_reg2hw_ctrl_aux_shadowed_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } prng_reseed;
    struct packed {
      logic        q;
    } data_out_clear;
    struct packed {
      logic        q;
    } key_iv_data_in_clear;
    struct packed {
      logic        q;
    } start;
  } aes_reg2hw_trigger_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } input_ready;
    struct packed {
      logic        q;
    } output_valid;
    struct packed {
      logic        q;
    } output_lost;
    struct packed {
      logic        q;
    } idle;
  } aes_reg2hw_status_reg_t;
  typedef struct packed {
    struct packed {
      logic [4:0]  q;
      logic        qe;
      logic        re;
    } num_valid_bytes;
    struct packed {
      logic [5:0]  q;
      logic        qe;
      logic        re;
    } phase;
  } aes_reg2hw_ctrl_gcm_shadowed_reg_t;
  typedef struct packed {
    logic [31:0] d;
  } aes_hw2reg_key_share0_mreg_t;
  typedef struct packed {
    logic [31:0] d;
  } aes_hw2reg_key_share1_mreg_t;
  typedef struct packed {
    logic [31:0] d;
  } aes_hw2reg_iv_mreg_t;
  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } aes_hw2reg_data_in_mreg_t;
  typedef struct packed {
    logic [31:0] d;
  } aes_hw2reg_data_out_mreg_t;
  typedef struct packed {
    struct packed {
      logic        d;
    } manual_operation;
    struct packed {
      logic [2:0]  d;
    } prng_reseed_rate;
    struct packed {
      logic        d;
    } sideload;
    struct packed {
      logic [2:0]  d;
    } key_len;
    struct packed {
      logic [5:0]  d;
    } mode;
    struct packed {
      logic [1:0]  d;
    } operation;
  } aes_hw2reg_ctrl_shadowed_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } prng_reseed;
    struct packed {
      logic        d;
      logic        de;
    } data_out_clear;
    struct packed {
      logic        d;
      logic        de;
    } key_iv_data_in_clear;
    struct packed {
      logic        d;
      logic        de;
    } start;
  } aes_hw2reg_trigger_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } alert_fatal_fault;
    struct packed {
      logic        d;
      logic        de;
    } alert_recov_ctrl_update_err;
    struct packed {
      logic        d;
      logic        de;
    } input_ready;
    struct packed {
      logic        d;
      logic        de;
    } output_valid;
    struct packed {
      logic        d;
      logic        de;
    } output_lost;
    struct packed {
      logic        d;
      logic        de;
    } stall;
    struct packed {
      logic        d;
      logic        de;
    } idle;
  } aes_hw2reg_status_reg_t;
  typedef struct packed {
    struct packed {
      logic [4:0]  d;
    } num_valid_bytes;
    struct packed {
      logic [5:0]  d;
    } phase;
  } aes_hw2reg_ctrl_gcm_shadowed_reg_t;
  
  typedef struct packed {
    aes_reg2hw_alert_test_reg_t alert_test; 
    aes_reg2hw_key_share0_mreg_t [7:0] key_share0; 
    aes_reg2hw_key_share1_mreg_t [7:0] key_share1; 
    aes_reg2hw_iv_mreg_t [3:0] iv; 
    aes_reg2hw_data_in_mreg_t [3:0] data_in; 
    aes_reg2hw_data_out_mreg_t [3:0] data_out; 
    aes_reg2hw_ctrl_shadowed_reg_t ctrl_shadowed; 
    aes_reg2hw_ctrl_aux_shadowed_reg_t ctrl_aux_shadowed; 
    aes_reg2hw_trigger_reg_t trigger; 
    aes_reg2hw_status_reg_t status; 
    aes_reg2hw_ctrl_gcm_shadowed_reg_t ctrl_gcm_shadowed; 
  } aes_reg2hw_t;
  
  typedef struct packed {
    aes_hw2reg_key_share0_mreg_t [7:0] key_share0; 
    aes_hw2reg_key_share1_mreg_t [7:0] key_share1; 
    aes_hw2reg_iv_mreg_t [3:0] iv; 
    aes_hw2reg_data_in_mreg_t [3:0] data_in; 
    aes_hw2reg_data_out_mreg_t [3:0] data_out; 
    aes_hw2reg_ctrl_shadowed_reg_t ctrl_shadowed; 
    aes_hw2reg_trigger_reg_t trigger; 
    aes_hw2reg_status_reg_t status; 
    aes_hw2reg_ctrl_gcm_shadowed_reg_t ctrl_gcm_shadowed; 
  } aes_hw2reg_t;
  
  parameter logic [BlockAw-1:0] AES_ALERT_TEST_OFFSET = 8'h 0;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE0_0_OFFSET = 8'h 4;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE0_1_OFFSET = 8'h 8;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE0_2_OFFSET = 8'h c;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE0_3_OFFSET = 8'h 10;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE0_4_OFFSET = 8'h 14;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE0_5_OFFSET = 8'h 18;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE0_6_OFFSET = 8'h 1c;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE0_7_OFFSET = 8'h 20;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE1_0_OFFSET = 8'h 24;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE1_1_OFFSET = 8'h 28;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE1_2_OFFSET = 8'h 2c;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE1_3_OFFSET = 8'h 30;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE1_4_OFFSET = 8'h 34;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE1_5_OFFSET = 8'h 38;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE1_6_OFFSET = 8'h 3c;
  parameter logic [BlockAw-1:0] AES_KEY_SHARE1_7_OFFSET = 8'h 40;
  parameter logic [BlockAw-1:0] AES_IV_0_OFFSET = 8'h 44;
  parameter logic [BlockAw-1:0] AES_IV_1_OFFSET = 8'h 48;
  parameter logic [BlockAw-1:0] AES_IV_2_OFFSET = 8'h 4c;
  parameter logic [BlockAw-1:0] AES_IV_3_OFFSET = 8'h 50;
  parameter logic [BlockAw-1:0] AES_DATA_IN_0_OFFSET = 8'h 54;
  parameter logic [BlockAw-1:0] AES_DATA_IN_1_OFFSET = 8'h 58;
  parameter logic [BlockAw-1:0] AES_DATA_IN_2_OFFSET = 8'h 5c;
  parameter logic [BlockAw-1:0] AES_DATA_IN_3_OFFSET = 8'h 60;
  parameter logic [BlockAw-1:0] AES_DATA_OUT_0_OFFSET = 8'h 64;
  parameter logic [BlockAw-1:0] AES_DATA_OUT_1_OFFSET = 8'h 68;
  parameter logic [BlockAw-1:0] AES_DATA_OUT_2_OFFSET = 8'h 6c;
  parameter logic [BlockAw-1:0] AES_DATA_OUT_3_OFFSET = 8'h 70;
  parameter logic [BlockAw-1:0] AES_CTRL_SHADOWED_OFFSET = 8'h 74;
  parameter logic [BlockAw-1:0] AES_CTRL_AUX_SHADOWED_OFFSET = 8'h 78;
  parameter logic [BlockAw-1:0] AES_CTRL_AUX_REGWEN_OFFSET = 8'h 7c;
  parameter logic [BlockAw-1:0] AES_TRIGGER_OFFSET = 8'h 80;
  parameter logic [BlockAw-1:0] AES_STATUS_OFFSET = 8'h 84;
  parameter logic [BlockAw-1:0] AES_CTRL_GCM_SHADOWED_OFFSET = 8'h 88;
  
  parameter logic [1:0] AES_ALERT_TEST_RESVAL = 2'h 0;
  parameter logic [0:0] AES_ALERT_TEST_RECOV_CTRL_UPDATE_ERR_RESVAL = 1'h 0;
  parameter logic [0:0] AES_ALERT_TEST_FATAL_FAULT_RESVAL = 1'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_0_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_0_KEY_SHARE0_0_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_1_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_1_KEY_SHARE0_1_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_2_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_2_KEY_SHARE0_2_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_3_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_3_KEY_SHARE0_3_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_4_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_4_KEY_SHARE0_4_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_5_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_5_KEY_SHARE0_5_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_6_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_6_KEY_SHARE0_6_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_7_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE0_7_KEY_SHARE0_7_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_0_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_0_KEY_SHARE1_0_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_1_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_1_KEY_SHARE1_1_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_2_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_2_KEY_SHARE1_2_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_3_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_3_KEY_SHARE1_3_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_4_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_4_KEY_SHARE1_4_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_5_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_5_KEY_SHARE1_5_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_6_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_6_KEY_SHARE1_6_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_7_RESVAL = 32'h 0;
  parameter logic [31:0] AES_KEY_SHARE1_7_KEY_SHARE1_7_RESVAL = 32'h 0;
  parameter logic [31:0] AES_IV_0_RESVAL = 32'h 0;
  parameter logic [31:0] AES_IV_0_IV_0_RESVAL = 32'h 0;
  parameter logic [31:0] AES_IV_1_RESVAL = 32'h 0;
  parameter logic [31:0] AES_IV_1_IV_1_RESVAL = 32'h 0;
  parameter logic [31:0] AES_IV_2_RESVAL = 32'h 0;
  parameter logic [31:0] AES_IV_2_IV_2_RESVAL = 32'h 0;
  parameter logic [31:0] AES_IV_3_RESVAL = 32'h 0;
  parameter logic [31:0] AES_IV_3_IV_3_RESVAL = 32'h 0;
  parameter logic [31:0] AES_DATA_OUT_0_RESVAL = 32'h 0;
  parameter logic [31:0] AES_DATA_OUT_0_DATA_OUT_0_RESVAL = 32'h 0;
  parameter logic [31:0] AES_DATA_OUT_1_RESVAL = 32'h 0;
  parameter logic [31:0] AES_DATA_OUT_1_DATA_OUT_1_RESVAL = 32'h 0;
  parameter logic [31:0] AES_DATA_OUT_2_RESVAL = 32'h 0;
  parameter logic [31:0] AES_DATA_OUT_2_DATA_OUT_2_RESVAL = 32'h 0;
  parameter logic [31:0] AES_DATA_OUT_3_RESVAL = 32'h 0;
  parameter logic [31:0] AES_DATA_OUT_3_DATA_OUT_3_RESVAL = 32'h 0;
  parameter logic [15:0] AES_CTRL_SHADOWED_RESVAL = 16'h 11fd;
  parameter logic [1:0] AES_CTRL_SHADOWED_OPERATION_RESVAL = 2'h 1;
  parameter logic [5:0] AES_CTRL_SHADOWED_MODE_RESVAL = 6'h 3f;
  parameter logic [2:0] AES_CTRL_SHADOWED_KEY_LEN_RESVAL = 3'h 1;
  parameter logic [0:0] AES_CTRL_SHADOWED_SIDELOAD_RESVAL = 1'h 0;
  parameter logic [2:0] AES_CTRL_SHADOWED_PRNG_RESEED_RATE_RESVAL = 3'h 1;
  parameter logic [0:0] AES_CTRL_SHADOWED_MANUAL_OPERATION_RESVAL = 1'h 0;
  parameter logic [10:0] AES_CTRL_GCM_SHADOWED_RESVAL = 11'h 401;
  parameter logic [5:0] AES_CTRL_GCM_SHADOWED_PHASE_RESVAL = 6'h 1;
  parameter logic [4:0] AES_CTRL_GCM_SHADOWED_NUM_VALID_BYTES_RESVAL = 5'h 10;
  
  typedef enum int {
    AES_ALERT_TEST,
    AES_KEY_SHARE0_0,
    AES_KEY_SHARE0_1,
    AES_KEY_SHARE0_2,
    AES_KEY_SHARE0_3,
    AES_KEY_SHARE0_4,
    AES_KEY_SHARE0_5,
    AES_KEY_SHARE0_6,
    AES_KEY_SHARE0_7,
    AES_KEY_SHARE1_0,
    AES_KEY_SHARE1_1,
    AES_KEY_SHARE1_2,
    AES_KEY_SHARE1_3,
    AES_KEY_SHARE1_4,
    AES_KEY_SHARE1_5,
    AES_KEY_SHARE1_6,
    AES_KEY_SHARE1_7,
    AES_IV_0,
    AES_IV_1,
    AES_IV_2,
    AES_IV_3,
    AES_DATA_IN_0,
    AES_DATA_IN_1,
    AES_DATA_IN_2,
    AES_DATA_IN_3,
    AES_DATA_OUT_0,
    AES_DATA_OUT_1,
    AES_DATA_OUT_2,
    AES_DATA_OUT_3,
    AES_CTRL_SHADOWED,
    AES_CTRL_AUX_SHADOWED,
    AES_CTRL_AUX_REGWEN,
    AES_TRIGGER,
    AES_STATUS,
    AES_CTRL_GCM_SHADOWED
  } aes_id_e;
  
  parameter logic [3:0] AES_PERMIT [35] = '{
    4'b 0001, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 0011, 
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 0011  
  };
endpackage

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
module TopModule import aes_pkg::*;
#(
  parameter sbox_impl_e SecSBoxImpl = SBoxImplLut
) (
  input  logic                     clk_i,
  input  logic                     rst_ni,
  input  logic                     en_i,
  output logic                     out_req_o,
  input  logic                     out_ack_i,
  input  ciph_op_e                 op_i,
  input  logic               [7:0] data_i,
  input  logic               [7:0] mask_i,
  input  logic [WidthPRDSBox+19:0] prd_i,
  output logic               [7:0] data_o,
  output logic               [7:0] mask_o,
  output logic              [19:0] prd_o
);
  
  
  `ASSERT_STATIC_LINT_ERROR(AesSBoxSecSBoxImplNonDefault, SecSBoxImpl == SBoxImplDom)
  localparam bit SBoxMasked = (SecSBoxImpl == SBoxImplCanrightMasked ||
                               SecSBoxImpl == SBoxImplCanrightMaskedNoreuse ||
                               SecSBoxImpl == SBoxImplDom) ? 1'b1 : 1'b0;
  localparam bit SBoxSingleCycle = (SecSBoxImpl == SBoxImplDom) ? 1'b0 : 1'b1;
  if (!SBoxMasked) begin : gen_sbox_unmasked
    
    logic                     unused_clk;
    logic                     unused_rst;
    logic               [7:0] unused_mask;
    logic [WidthPRDSBox+19:0] unused_prd;
    assign unused_clk  = clk_i;
    assign unused_rst  = rst_ni;
    assign unused_mask = mask_i;
    assign unused_prd  = prd_i;
    if (SecSBoxImpl == SBoxImplCanright) begin : gen_sbox_canright
      aes_sbox_canright u_aes_sbox (
        .op_i   ( op_i   ),
        .data_i ( data_i ),
        .data_o ( data_o )
      );
    end else begin : gen_sbox_lut 
      aes_sbox_lut u_aes_sbox (
        .op_i   ( op_i   ),
        .data_i ( data_i ),
        .data_o ( data_o )
      );
    end
    assign mask_o = '0;
    assign prd_o  = '0;
  end else begin : gen_sbox_masked
    
    if (SecSBoxImpl == SBoxImplDom) begin : gen_sbox_dom
      aes_sbox_dom u_aes_sbox (
        .clk_i      ( clk_i       ),
        .rst_ni     ( rst_ni      ),
        .en_i       ( en_i        ),
        .out_req_o  ( out_req_o   ),
        .out_ack_i  ( out_ack_i   ),
        .op_i       ( op_i        ),
        .data_i     ( data_i      ),
        .mask_i     ( mask_i      ),
        .prd_i      ( prd_i[27:0] ),
        .data_o     ( data_o      ),
        .mask_o     ( mask_o      ),
        .prd_o      ( prd_o       )
      );
      `ASSERT_INIT(AesWidthPRDSBox, WidthPRDSBox == 8)
    end else if (SecSBoxImpl == SBoxImplCanrightMaskedNoreuse) begin :
        gen_sbox_canright_masked_noreuse
      
      logic        unused_clk;
      logic        unused_rst;
      logic [19:0] unused_prd;
      assign unused_clk = clk_i;
      assign unused_rst = rst_ni;
      assign unused_prd = prd_i[WidthPRDSBox+19:WidthPRDSBox];
      aes_sbox_canright_masked_noreuse u_aes_sbox (
        .op_i   ( op_i        ),
        .data_i ( data_i      ),
        .mask_i ( mask_i      ),
        .prd_i  ( prd_i[17:0] ),
        .data_o ( data_o      ),
        .mask_o ( mask_o      )
      );
      assign prd_o = '0;
      `ASSERT_INIT(AesWidthPRDSBox, WidthPRDSBox == 18)
    end else begin : gen_sbox_canright_masked 
      
      logic        unused_clk;
      logic        unused_rst;
      logic [19:0] unused_prd;
      assign unused_clk = clk_i;
      assign unused_rst = rst_ni;
      assign unused_prd = prd_i[WidthPRDSBox+19:WidthPRDSBox];
      aes_sbox_canright_masked u_aes_sbox (
        .op_i   ( op_i       ),
        .data_i ( data_i     ),
        .mask_i ( mask_i     ),
        .prd_i  ( prd_i[7:0] ),
        .data_o ( data_o     ),
        .mask_o ( mask_o     )
      );
      assign prd_o = '0;
      `ASSERT_INIT(AesWidthPRDSBox, WidthPRDSBox == 8)
    end
  end
  if (SBoxSingleCycle) begin : gen_req_singlecycle
    
    logic unused_out_ack;
    assign unused_out_ack = out_ack_i;
    
    assign out_req_o = en_i;
  end
endmodule

module aes_sbox_canright (
  input  aes_pkg::ciph_op_e op_i,
  input  logic [7:0]        data_i,
  output logic [7:0]        data_o
);
  import aes_pkg::*;
  import aes_sbox_canright_pkg::*;
  
  
  
  
  
  function automatic logic [3:0] aes_inverse_gf2p4(logic [3:0] gamma);
    logic [3:0] delta;
    logic [1:0] a, b, c, d;
    a          = gamma[3:2] ^ gamma[1:0];
    b          = aes_mul_gf2p2(gamma[3:2], gamma[1:0]);
    c          = aes_scale_omega2_gf2p2(aes_square_gf2p2(a));
    d          = aes_square_gf2p2(c ^ b);
    delta[3:2] = aes_mul_gf2p2(d, gamma[1:0]);
    delta[1:0] = aes_mul_gf2p2(d, gamma[3:2]);
    return delta;
  endfunction
  
  
  function automatic logic [7:0] aes_inverse_gf2p8(logic [7:0] gamma);
    logic [7:0] delta;
    logic [3:0] a, b, c, d;
    a          = gamma[7:4] ^ gamma[3:0];
    b          = aes_mul_gf2p4(gamma[7:4], gamma[3:0]);
    c          = aes_square_scale_gf2p4_gf2p2(a);
    d          = aes_inverse_gf2p4(c ^ b);
    delta[7:4] = aes_mul_gf2p4(d, gamma[3:0]);
    delta[3:0] = aes_mul_gf2p4(d, gamma[7:4]);
    return delta;
  endfunction
  
  
  
  logic [7:0] data_basis_x, data_inverse;
  
  assign data_basis_x = (op_i == CIPH_FWD) ? aes_mvm(data_i, A2X)         :
                        (op_i == CIPH_INV) ? aes_mvm(data_i ^ 8'h63, S2X) :
                                             aes_mvm(data_i, A2X);
  
  assign data_inverse = aes_inverse_gf2p8(data_basis_x);
  
  assign data_o       = (op_i == CIPH_FWD) ? aes_mvm(data_inverse, X2S) ^ 8'h63 :
                        (op_i == CIPH_INV) ? aes_mvm(data_inverse, X2A) :
                                             aes_mvm(data_inverse, X2S) ^ 8'h63;
endmodule

module aes_masked_inverse_gf2p4 (
  input  logic [3:0] b,
  input  logic [3:0] q,
  input  logic [1:0] r,
  input  logic [3:0] m1,
  output logic [3:0] b_inv
);
  import aes_pkg::*;
  import aes_sbox_canright_pkg::*;
  logic [1:0] b1, b0, q1, q0, c_inv, r_sq, m11, m10;
  assign b1  = b[3:2];
  assign b0  = b[1:0];
  assign q1  = q[3:2];
  assign q0  = q[1:0];
  assign m11 = m1[3:2];
  assign m10 = m1[1:0];
  
  logic [1:0] mul_b0_q1, mul_b1_q0, mul_q1_q0;
  assign mul_b0_q1 = aes_mul_gf2p2(b0, q1);
  assign mul_b1_q0 = aes_mul_gf2p2(b1, q0);
  assign mul_q1_q0 = aes_mul_gf2p2(q1, q0);
  
  logic [1:0] mul_b0_q1_buf, mul_b1_q0_buf, mul_q1_q0_buf;
  prim_buf #(
    .Width ( 6 )
  ) u_prim_buf_mul_bq01 (
    .in_i  ( {mul_b0_q1,     mul_b1_q0,     mul_q1_q0}     ),
    .out_o ( {mul_b0_q1_buf, mul_b1_q0_buf, mul_q1_q0_buf} )
  );
  
  
  
  
  
  
  
  
  
  logic [1:0] scale_omega2_b, scale_omega2_q;
  logic [1:0] mul_b1_b0;
  assign scale_omega2_b = aes_scale_omega2_gf2p2(aes_square_gf2p2(b1 ^ b0));
  assign scale_omega2_q = aes_scale_omega2_gf2p2(aes_square_gf2p2(q1 ^ q0));
  assign mul_b1_b0 = aes_mul_gf2p2(b1, b0);
  
  
  logic [1:0] scale_omega2_b_buf, scale_omega2_q_buf;
  prim_buf #(
    .Width ( 4 )
  ) u_prim_buf_scale_omega2_bq (
    .in_i  ( {scale_omega2_b,     scale_omega2_q}     ),
    .out_o ( {scale_omega2_b_buf, scale_omega2_q_buf} )
  );
  logic [1:0] mul_b1_b0_buf;
  prim_buf #(
    .Width ( 2 )
  ) u_prim_buf_mul_b1_b0 (
    .in_i  ( mul_b1_b0     ),
    .out_o ( mul_b1_b0_buf )
  );
  
  logic [1:0] c [6];
  logic [1:0] c_buf [6];
  assign c[0] = r        ^ scale_omega2_b_buf;
  assign c[1] = c_buf[0] ^ scale_omega2_q_buf;
  assign c[2] = c_buf[1] ^ mul_b1_b0_buf;
  assign c[3] = c_buf[2] ^ mul_b1_q0_buf;
  assign c[4] = c_buf[3] ^ mul_b0_q1_buf;
  assign c[5] = c_buf[4] ^ mul_q1_q0_buf;
  
  for (genvar i = 0; i < 6; i++) begin : gen_c_buf
    prim_buf #(
      .Width ( 2 )
    ) u_prim_buf_c_i (
      .in_i  ( c[i]     ),
      .out_o ( c_buf[i] )
    );
  end
  
  
  
  
  
  assign c_inv = aes_square_gf2p2(c_buf[5]);
  assign r_sq  = aes_square_gf2p2(r);
  
  
  
  
  
  
  
  
  logic [1:0] xor_q1_r_sq, xor_q0_q1, c1_inv, c2_inv;
  prim_xor2 #(
    .Width ( 2 )
  ) u_prim_xor_q1_r_sq (
    .in0_i ( q1          ),
    .in1_i ( r_sq        ),
    .out_o ( xor_q1_r_sq )
  );
  prim_xor2 #(
    .Width ( 2 )
  ) u_prim_xor_q0_q1 (
    .in0_i ( q0        ),
    .in1_i ( q1        ),
    .out_o ( xor_q0_q1 )
  );
  
  prim_xor2 #(
    .Width ( 2 )
  ) u_prim_c1_inv (
    .in0_i ( xor_q1_r_sq ),
    .in1_i ( c_inv       ),
    .out_o ( c1_inv      )
  );
  prim_xor2 #(
    .Width ( 2 )
  ) u_prim_c2_inv (
    .in0_i ( c1_inv    ),
    .in1_i ( xor_q0_q1 ),
    .out_o ( c2_inv    )
  );
  
  
  
  
  
  
  
  
  
  logic [1:0] mul_b0_c1_inv, mul_q0_c1_inv, mul_b1_c2_inv, mul_q1_c2_inv;
  assign mul_b0_c1_inv = aes_mul_gf2p2(b0, c1_inv);
  assign mul_q0_c1_inv = aes_mul_gf2p2(q0, c1_inv);
  assign mul_b1_c2_inv = aes_mul_gf2p2(b1, c2_inv);
  assign mul_q1_c2_inv = aes_mul_gf2p2(q1, c2_inv);
  
  
  logic [1:0] mul_b0_c1_inv_buf, mul_q0_c1_inv_buf, mul_b1_c2_inv_buf, mul_q1_c2_inv_buf;
  prim_buf #(
    .Width ( 8 )
  ) u_prim_buf_mul_bq01_c12_inv (
    .in_i  ( {mul_b0_c1_inv,     mul_q0_c1_inv,     mul_b1_c2_inv,     mul_q1_c2_inv}     ),
    .out_o ( {mul_b0_c1_inv_buf, mul_q0_c1_inv_buf, mul_b1_c2_inv_buf, mul_q1_c2_inv_buf} )
  );
  
  logic [1:0] b1_inv [4];
  logic [1:0] b1_inv_buf [4];
  logic [1:0] b0_inv [4];
  logic [1:0] b0_inv_buf [4];
  assign b1_inv[0] = m11           ^ mul_b0_c1_inv_buf;
  assign b1_inv[1] = b1_inv_buf[0] ^ mul_b0_q1_buf;
  assign b1_inv[2] = b1_inv_buf[1] ^ mul_q0_c1_inv_buf;
  assign b1_inv[3] = b1_inv_buf[2] ^ mul_q1_q0_buf;
  assign b0_inv[0] = m10           ^ mul_b1_c2_inv_buf;
  assign b0_inv[1] = b0_inv_buf[0] ^ mul_b1_q0_buf;
  assign b0_inv[2] = b0_inv_buf[1] ^ mul_q1_c2_inv_buf;
  assign b0_inv[3] = b0_inv_buf[2] ^ mul_q1_q0_buf;
  
  for (genvar i = 0; i < 4; i++) begin : gen_a01_inv_buf
    prim_buf #(
      .Width ( 2 )
    ) u_prim_buf_b1_inv_i (
      .in_i  ( b1_inv[i]     ),
      .out_o ( b1_inv_buf[i] )
    );
    prim_buf #(
      .Width ( 2 )
    ) u_prim_buf_b0_inv_i (
      .in_i  ( b0_inv[i]     ),
      .out_o ( b0_inv_buf[i] )
    );
  end
  
  assign b_inv = {b1_inv_buf[3], b0_inv_buf[3]};
endmodule
module aes_masked_inverse_gf2p8 (
  input  logic [7:0] a,
  input  logic [7:0] m,
  input  logic [7:0] n,
  output logic [7:0] a_inv
);
  import aes_pkg::*;
  import aes_sbox_canright_pkg::*;
  logic [3:0] a1, a0, m1, m0, q, b_inv, s1, s0;
  logic [1:0] r;
  assign a1 = a[7:4];
  assign a0 = a[3:0];
  assign m1 = m[7:4];
  assign m0 = m[3:0];
  
  
  
  
  
  
  
  assign r = m1[3:2];
  assign q = n[7:4];
  assign s1 = n[7:4];
  assign s0 = n[3:0];
  
  logic [3:0] mul_a0_m1, mul_a1_m0, mul_m0_m1;
  assign mul_a0_m1 = aes_mul_gf2p4(a0, m1);
  assign mul_a1_m0 = aes_mul_gf2p4(a1, m0);
  assign mul_m0_m1 = aes_mul_gf2p4(m0, m1);
  
  logic [3:0] mul_a0_m1_buf, mul_a1_m0_buf, mul_m0_m1_buf;
  prim_buf #(
    .Width ( 12 )
  ) u_prim_buf_mul_bq01 (
    .in_i  ( {mul_a0_m1,     mul_a1_m0,     mul_m0_m1}     ),
    .out_o ( {mul_a0_m1_buf, mul_a1_m0_buf, mul_m0_m1_buf} )
  );
  
  
  
  
  
  
  
  
  
  logic [3:0] ss_a1_a0, ss_m1_m0;
  assign ss_a1_a0 = aes_square_scale_gf2p4_gf2p2(a1 ^ a0);
  assign ss_m1_m0 = aes_square_scale_gf2p4_gf2p2(m1 ^ m0);
  logic [3:0] mul_a1_a0;
  assign mul_a1_a0 = aes_mul_gf2p4(a1, a0);
  
  
  logic [3:0] mul_a1_a0_buf;
  prim_buf #(
    .Width ( 4 )
  ) u_prim_buf_mul_am01 (
    .in_i  ( mul_a1_a0     ),
    .out_o ( mul_a1_a0_buf )
  );
  
  logic [3:0] b [6];
  logic [3:0] b_buf [6];
  assign b[0] = q        ^ ss_a1_a0; 
  assign b[1] = b_buf[0] ^ ss_m1_m0; 
  assign b[2] = b_buf[1] ^ mul_a1_a0_buf;
  assign b[3] = b_buf[2] ^ mul_a1_m0_buf;
  assign b[4] = b_buf[3] ^ mul_a0_m1_buf;
  assign b[5] = b_buf[4] ^ mul_m0_m1_buf;
  
  for (genvar i = 0; i < 6; i++) begin : gen_b_buf
    prim_buf #(
      .Width ( 4 )
    ) u_prim_buf_b_i (
      .in_i  ( b[i]     ),
      .out_o ( b_buf[i] )
    );
  end
  
  
  
  
  aes_masked_inverse_gf2p4 u_aes_masked_inverse_gf2p4 (
    .b     ( b_buf[5] ),
    .q     ( q        ),
    .r     ( r        ),
    .m1    ( m1       ),
    .b_inv ( b_inv    )
  );
  
  
  
  logic [3:0] b_inv_buf;
  prim_buf #(
    .Width ( 4 )
  ) u_prim_buf_b_inv (
    .in_i  ( b_inv     ),
    .out_o ( b_inv_buf )
  );
  
  
  
  
  
  
  logic [3:0] xor_m1_m0, b2_inv;
  prim_xor2 #(
    .Width ( 4 )
  ) u_prim_xor_m1_m0 (
    .in0_i ( m1        ),
    .in1_i ( m0        ),
    .out_o ( xor_m1_m0 )
  );
  prim_xor2 #(
    .Width ( 4 )
  ) u_prim_xor_b2_inv (
    .in0_i ( b_inv_buf ),
    .in1_i ( xor_m1_m0 ),
    .out_o ( b2_inv    )
  );
  
  
  
  
  
  
  
  
  
  logic [3:0] mul_a0_b_inv, mul_m0_b_inv, mul_a1_b2_inv, mul_m1_b2_inv;
  assign mul_a0_b_inv  = aes_mul_gf2p4(a0, b_inv_buf);
  assign mul_m0_b_inv  = aes_mul_gf2p4(m0, b_inv_buf);
  assign mul_a1_b2_inv = aes_mul_gf2p4(a1, b2_inv);
  assign mul_m1_b2_inv = aes_mul_gf2p4(m1, b2_inv);
  
  
  logic [3:0] mul_a0_b_inv_buf, mul_m0_b_inv_buf, mul_a1_b2_inv_buf, mul_m1_b2_inv_buf;
  prim_buf #(
    .Width ( 16 )
  ) u_prim_buf_mul_bq01_c12_inv (
    .in_i  ( {mul_a0_b_inv,     mul_m0_b_inv,     mul_a1_b2_inv,     mul_m1_b2_inv}     ),
    .out_o ( {mul_a0_b_inv_buf, mul_m0_b_inv_buf, mul_a1_b2_inv_buf, mul_m1_b2_inv_buf} )
  );
  
  logic [3:0] a1_inv [4];
  logic [3:0] a1_inv_buf [4];
  logic [3:0] a0_inv [4];
  logic [3:0] a0_inv_buf [4];
  assign a1_inv[0] = s1            ^ mul_a0_b_inv_buf;
  assign a1_inv[1] = a1_inv_buf[0] ^ mul_a0_m1_buf;
  assign a1_inv[2] = a1_inv_buf[1] ^ mul_m0_b_inv_buf;
  assign a1_inv[3] = a1_inv_buf[2] ^ mul_m0_m1_buf;
  assign a0_inv[0] = s0            ^ mul_a1_b2_inv_buf; 
  assign a0_inv[1] = a0_inv_buf[0] ^ mul_a1_m0_buf;
  assign a0_inv[2] = a0_inv_buf[1] ^ mul_m1_b2_inv_buf;
  assign a0_inv[3] = a0_inv_buf[2] ^ mul_m0_m1_buf;
  
  for (genvar i = 0; i < 4; i++) begin : gen_a01_inv_buf
    prim_buf #(
      .Width ( 4 )
    ) u_prim_buf_a1_inv_i (
      .in_i  ( a1_inv[i]     ),
      .out_o ( a1_inv_buf[i] )
    );
    prim_buf #(
      .Width ( 4 )
    ) u_prim_buf_a0_inv_i (
      .in_i  ( a0_inv[i]     ),
      .out_o ( a0_inv_buf[i] )
    );
  end
  
  assign a_inv = {a1_inv_buf[3], a0_inv_buf[3]};
endmodule
module aes_sbox_canright_masked (
  input  aes_pkg::ciph_op_e op_i,
  input  logic [7:0]        data_i, 
  input  logic [7:0]        mask_i, 
  input  logic [7:0]        prd_i,  
  output logic [7:0]        data_o, 
  output logic [7:0]        mask_o  
);
  import aes_pkg::*;
  import aes_sbox_canright_pkg::*;
  
  
  
  logic [7:0] in_data_basis_x, out_data_basis_x;
  logic [7:0] in_mask_basis_x, out_mask_basis_x;
  
  assign in_data_basis_x = (op_i == CIPH_FWD) ? aes_mvm(data_i, A2X)         :
                           (op_i == CIPH_INV) ? aes_mvm(data_i ^ 8'h63, S2X) :
                                                aes_mvm(data_i, A2X);
  
  
  assign mask_o = prd_i;
  
  
  assign in_mask_basis_x  = (op_i == CIPH_FWD) ? aes_mvm(mask_i, A2X) :
                            (op_i == CIPH_INV) ? aes_mvm(mask_i, S2X) :
                                                 aes_mvm(mask_i, A2X);
  
  assign out_mask_basis_x = (op_i == CIPH_INV) ? aes_mvm(mask_o, A2X) :
                            (op_i == CIPH_FWD) ? aes_mvm(mask_o, S2X) :
                                                 aes_mvm(mask_o, S2X);
  
  aes_masked_inverse_gf2p8 u_aes_masked_inverse_gf2p8 (
    .a     ( in_data_basis_x  ), 
    .m     ( in_mask_basis_x  ), 
    .n     ( out_mask_basis_x ), 
    .a_inv ( out_data_basis_x )  
  );
  
  assign data_o = (op_i == CIPH_FWD) ? (aes_mvm(out_data_basis_x, X2S) ^ 8'h63) :
                  (op_i == CIPH_INV) ? (aes_mvm(out_data_basis_x, X2A))         :
                                       (aes_mvm(out_data_basis_x, X2S) ^ 8'h63);
endmodule

module aes_masked_inverse_gf2p4_noreuse (
  input  logic [3:0] b,
  input  logic [3:0] q,
  input  logic [1:0] r,
  input  logic [3:0] t,
  output logic [3:0] b_inv
);
  import aes_pkg::*;
  import aes_sbox_canright_pkg::*;
  logic [1:0] b1, b0, q1, q0, c_inv, r_sq, t1, t0;
  assign b1 = b[3:2];
  assign b0 = b[1:0];
  assign q1 = q[3:2];
  assign q0 = q[1:0];
  assign t1 = t[3:2];
  assign t0 = t[1:0];
  
  
  
  
  
  
  
  
  
  logic [1:0] scale_omega2_b, scale_omega2_q;
  logic [1:0] mul_b1_b0, mul_b1_q0, mul_b0_q1, mul_q1_q0;
  assign scale_omega2_b = aes_scale_omega2_gf2p2(aes_square_gf2p2(b1 ^ b0));
  assign scale_omega2_q = aes_scale_omega2_gf2p2(aes_square_gf2p2(q1 ^ q0));
  assign mul_b1_b0 = aes_mul_gf2p2(b1, b0);
  assign mul_b1_q0 = aes_mul_gf2p2(b1, q0);
  assign mul_b0_q1 = aes_mul_gf2p2(b0, q1);
  assign mul_q1_q0 = aes_mul_gf2p2(q1, q0);
  
  
  logic [1:0] scale_omega2_b_buf, scale_omega2_q_buf;
  prim_buf #(
    .Width ( 4 )
  ) u_prim_buf_scale_omega2_bq (
    .in_i  ( {scale_omega2_b,     scale_omega2_q}     ),
    .out_o ( {scale_omega2_b_buf, scale_omega2_q_buf} )
  );
  logic [1:0] mul_b1_b0_buf, mul_b1_q0_buf, mul_b0_q1_buf, mul_q1_q0_buf;
  prim_buf #(
    .Width ( 8 )
  ) u_prim_buf_mul_bq01 (
    .in_i  ( {mul_b1_b0,     mul_b1_q0,     mul_b0_q1,     mul_q1_q0}     ),
    .out_o ( {mul_b1_b0_buf, mul_b1_q0_buf, mul_b0_q1_buf, mul_q1_q0_buf} )
  );
  
  logic [1:0] c [6];
  logic [1:0] c_buf [6];
  assign c[0] = r        ^ scale_omega2_b_buf;
  assign c[1] = c_buf[0] ^ scale_omega2_q_buf;
  assign c[2] = c_buf[1] ^ mul_b1_b0_buf;
  assign c[3] = c_buf[2] ^ mul_b1_q0_buf;
  assign c[4] = c_buf[3] ^ mul_b0_q1_buf;
  assign c[5] = c_buf[4] ^ mul_q1_q0_buf;
  
  for (genvar i = 0; i < 6; i++) begin : gen_c_buf
    prim_buf #(
      .Width ( 2 )
    ) u_prim_buf_c_i (
      .in_i  ( c[i]     ),
      .out_o ( c_buf[i] )
    );
  end
  
  
  
  
  
  assign c_inv = aes_square_gf2p2(c_buf[5]);
  assign r_sq  = aes_square_gf2p2(r);
  
  
  
  
  
  
  
  
  
  logic [1:0] mul_b0_r_sq, mul_q0_c_inv, mul_q0_r_sq;
  logic [1:0] mul_b1_r_sq, mul_q1_c_inv, mul_q1_r_sq;
  assign mul_b0_r_sq  = aes_mul_gf2p2(b0, r_sq);
  assign mul_q0_c_inv = aes_mul_gf2p2(q0, c_inv);
  assign mul_q0_r_sq  = aes_mul_gf2p2(q0, r_sq);
  assign mul_b1_r_sq  = aes_mul_gf2p2(b1, r_sq);
  assign mul_q1_c_inv = aes_mul_gf2p2(q1, c_inv);
  assign mul_q1_r_sq  = aes_mul_gf2p2(q1, r_sq);
  
  
  logic [1:0] mul_b0_r_sq_buf, mul_q0_c_inv_buf, mul_q0_r_sq_buf;
  prim_buf #(
    .Width ( 6 )
  ) u_prim_buf_mul_bq0 (
    .in_i  ( {mul_b0_r_sq,     mul_q0_c_inv,     mul_q0_r_sq}     ),
    .out_o ( {mul_b0_r_sq_buf, mul_q0_c_inv_buf, mul_q0_r_sq_buf} )
  );
  logic [1:0] mul_b1_r_sq_buf, mul_q1_c_inv_buf, mul_q1_r_sq_buf;
  prim_buf #(
    .Width ( 6 )
  ) u_prim_buf_mul_bq1 (
    .in_i  ( {mul_b1_r_sq,     mul_q1_c_inv,     mul_q1_r_sq}     ),
    .out_o ( {mul_b1_r_sq_buf, mul_q1_c_inv_buf, mul_q1_r_sq_buf} )
  );
  
  logic [1:0] b1_inv [4];
  logic [1:0] b1_inv_buf [4];
  logic [1:0] b0_inv [4];
  logic [1:0] b0_inv_buf [4];
  assign b1_inv[0] = t1            ^ aes_mul_gf2p2(b0, c_inv); 
  assign b1_inv[1] = b1_inv_buf[0] ^ mul_b0_r_sq_buf;
  assign b1_inv[2] = b1_inv_buf[1] ^ mul_q0_c_inv_buf;
  assign b1_inv[3] = b1_inv_buf[2] ^ mul_q0_r_sq_buf;
  assign b0_inv[0] = t0            ^ aes_mul_gf2p2(b1, c_inv); 
  assign b0_inv[1] = b0_inv_buf[0] ^ mul_b1_r_sq_buf;
  assign b0_inv[2] = b0_inv_buf[1] ^ mul_q1_c_inv_buf;
  assign b0_inv[3] = b0_inv_buf[2] ^ mul_q1_r_sq_buf;
  
  for (genvar i = 0; i < 4; i++) begin : gen_a01_inv_buf
    prim_buf #(
      .Width ( 2 )
    ) u_prim_buf_b1_inv_i (
      .in_i  ( b1_inv[i]     ),
      .out_o ( b1_inv_buf[i] )
    );
    prim_buf #(
      .Width ( 2 )
    ) u_prim_buf_b0_inv_i (
      .in_i  ( b0_inv[i]     ),
      .out_o ( b0_inv_buf[i] )
    );
  end
  
  assign b_inv = {b1_inv_buf[3], b0_inv_buf[3]};
endmodule
module aes_masked_inverse_gf2p8_noreuse (
  input  logic [7:0] a,    
  input  logic [7:0] m,    
  input  logic [7:0] n,    
  input  logic [9:0] prd,  
  output logic [7:0] a_inv 
);
  import aes_pkg::*;
  import aes_sbox_canright_pkg::*;
  logic [3:0] a1, a0, m1, m0, q, b_inv, s1, s0, t;
  logic [1:0] r;
  assign a1 = a[7:4];
  assign a0 = a[3:0];
  assign m1 = m[7:4];
  assign m0 = m[3:0];
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  assign r  = prd[1:0];
  assign q  = prd[5:2];
  assign t  = prd[9:6];
  assign s1 = n[7:4];
  assign s0 = n[3:0];
  
  
  
  
  
  
  
  
  
  logic [3:0] ss_a1_a0, ss_m1_m0;
  assign ss_a1_a0 = aes_square_scale_gf2p4_gf2p2(a1 ^ a0);
  assign ss_m1_m0 = aes_square_scale_gf2p4_gf2p2(m1 ^ m0);
  logic [3:0] mul_a1_a0, mul_a1_m0, mul_a0_m1, mul_m0_m1;
  assign mul_a1_a0 = aes_mul_gf2p4(a1, a0);
  assign mul_a1_m0 = aes_mul_gf2p4(a1, m0);
  assign mul_a0_m1 = aes_mul_gf2p4(a0, m1);
  assign mul_m0_m1 = aes_mul_gf2p4(m0, m1);
  
  
  logic [3:0] mul_a1_a0_buf, mul_a1_m0_buf, mul_a0_m1_buf, mul_m0_m1_buf;
  prim_buf #(
    .Width ( 16 )
  ) u_prim_buf_mul_am01 (
    .in_i  ( {mul_a1_a0,     mul_a1_m0,     mul_a0_m1,     mul_m0_m1}     ),
    .out_o ( {mul_a1_a0_buf, mul_a1_m0_buf, mul_a0_m1_buf, mul_m0_m1_buf} )
  );
  
  logic [3:0] b [6];
  logic [3:0] b_buf [6];
  assign b[0] = q        ^ ss_a1_a0; 
  assign b[1] = b_buf[0] ^ ss_m1_m0; 
  assign b[2] = b_buf[1] ^ mul_a1_a0_buf;
  assign b[3] = b_buf[2] ^ mul_a1_m0_buf;
  assign b[4] = b_buf[3] ^ mul_a0_m1_buf;
  assign b[5] = b_buf[4] ^ mul_m0_m1_buf;
  
  for (genvar i = 0; i < 6; i++) begin : gen_b_buf
    prim_buf #(
      .Width ( 4 )
    ) u_prim_buf_b_i (
      .in_i  ( b[i]     ),
      .out_o ( b_buf[i] )
    );
  end
  
  
  
  
  aes_masked_inverse_gf2p4_noreuse u_aes_masked_inverse_gf2p4 (
    .b     ( b_buf[5] ),
    .q     ( q        ),
    .r     ( r        ),
    .t     ( t        ),
    .b_inv ( b_inv    )
  );
  
  
  
  logic [3:0] b_inv_buf;
  prim_buf #(
    .Width ( 4 )
  ) u_prim_buf_b_inv (
    .in_i  ( b_inv     ),
    .out_o ( b_inv_buf )
  );
  
  
  
  
  
  
  
  
  
  logic [3:0] mul_a0_b_inv, mul_a0_t, mul_m0_b_inv, mul_m0_t;
  logic [3:0] mul_a1_b_inv, mul_a1_t, mul_m1_b_inv, mul_m1_t;
  assign mul_a0_b_inv = aes_mul_gf2p4(a0, b_inv_buf);
  assign mul_a0_t     = aes_mul_gf2p4(a0, t);
  assign mul_m0_b_inv = aes_mul_gf2p4(m0, b_inv_buf);
  assign mul_m0_t     = aes_mul_gf2p4(m0, t);
  assign mul_a1_b_inv = aes_mul_gf2p4(a1, b_inv_buf);
  assign mul_a1_t     = aes_mul_gf2p4(a1, t);
  assign mul_m1_b_inv = aes_mul_gf2p4(m1, b_inv_buf);
  assign mul_m1_t     = aes_mul_gf2p4(m1, t);
  
  
  logic [3:0] mul_a0_b_inv_buf, mul_a0_t_buf, mul_m0_b_inv_buf, mul_m0_t_buf;
  prim_buf #(
    .Width ( 16 )
  ) u_prim_buf_mul_am0 (
    .in_i  ( {mul_a0_b_inv,     mul_a0_t,     mul_m0_b_inv,     mul_m0_t}     ),
    .out_o ( {mul_a0_b_inv_buf, mul_a0_t_buf, mul_m0_b_inv_buf, mul_m0_t_buf} )
  );
  logic [3:0] mul_a1_b_inv_buf, mul_a1_t_buf, mul_m1_b_inv_buf, mul_m1_t_buf;
  prim_buf #(
    .Width ( 16 )
  ) u_prim_buf_mul_am1 (
    .in_i  ( {mul_a1_b_inv,     mul_a1_t,     mul_m1_b_inv,     mul_m1_t}     ),
    .out_o ( {mul_a1_b_inv_buf, mul_a1_t_buf, mul_m1_b_inv_buf, mul_m1_t_buf} )
  );
  
  logic [3:0] a1_inv [4];
  logic [3:0] a1_inv_buf [4];
  logic [3:0] a0_inv [4];
  logic [3:0] a0_inv_buf [4];
  assign a1_inv[0] = s1            ^ mul_a0_b_inv_buf;
  assign a1_inv[1] = a1_inv_buf[0] ^ mul_a0_t_buf;
  assign a1_inv[2] = a1_inv_buf[1] ^ mul_m0_b_inv_buf;
  assign a1_inv[3] = a1_inv_buf[2] ^ mul_m0_t_buf;
  assign a0_inv[0] = s0            ^ mul_a1_b_inv_buf;
  assign a0_inv[1] = a0_inv_buf[0] ^ mul_a1_t_buf;
  assign a0_inv[2] = a0_inv_buf[1] ^ mul_m1_b_inv_buf;
  assign a0_inv[3] = a0_inv_buf[2] ^ mul_m1_t_buf;
  
  for (genvar i = 0; i < 4; i++) begin : gen_a01_inv_buf
    prim_buf #(
      .Width ( 4 )
    ) u_prim_buf_a1_inv_i (
      .in_i  ( a1_inv[i]     ),
      .out_o ( a1_inv_buf[i] )
    );
    prim_buf #(
      .Width ( 4 )
    ) u_prim_buf_a0_inv_i (
      .in_i  ( a0_inv[i]     ),
      .out_o ( a0_inv_buf[i] )
    );
  end
  
  assign a_inv = {a1_inv_buf[3], a0_inv_buf[3]};
endmodule
module aes_sbox_canright_masked_noreuse (
  input  aes_pkg::ciph_op_e op_i,
  input  logic        [7:0] data_i, 
  input  logic        [7:0] mask_i, 
  input  logic       [17:0] prd_i,  
                                    
  output logic        [7:0] data_o, 
  output logic        [7:0] mask_o  
);
  import aes_pkg::*;
  import aes_sbox_canright_pkg::*;
  
  
  
  logic [7:0] in_data_basis_x, out_data_basis_x;
  logic [7:0] in_mask_basis_x, out_mask_basis_x;
  
  assign in_data_basis_x = (op_i == CIPH_FWD) ? aes_mvm(data_i, A2X)         :
                           (op_i == CIPH_INV) ? aes_mvm(data_i ^ 8'h63, S2X) :
                                                aes_mvm(data_i, A2X);
  
  
  assign mask_o = prd_i[7:0];
  
  logic [9:0] prd_masking;
  assign prd_masking = prd_i[17:8];
  
  
  assign in_mask_basis_x  = (op_i == CIPH_FWD) ? aes_mvm(mask_i, A2X) :
                            (op_i == CIPH_INV) ? aes_mvm(mask_i, S2X) :
                                                 aes_mvm(mask_i, A2X);
  
  assign out_mask_basis_x = (op_i == CIPH_INV) ? aes_mvm(mask_o, A2X) :
                            (op_i == CIPH_FWD) ? aes_mvm(mask_o, S2X) :
                                                 aes_mvm(mask_o, S2X);
  
  aes_masked_inverse_gf2p8_noreuse u_aes_masked_inverse_gf2p8 (
    .a     ( in_data_basis_x  ), 
    .m     ( in_mask_basis_x  ), 
    .n     ( out_mask_basis_x ), 
    .prd   ( prd_masking      ), 
    .a_inv ( out_data_basis_x )  
  );
  
  assign data_o = (op_i == CIPH_FWD) ? (aes_mvm(out_data_basis_x, X2S) ^ 8'h63) :
                  (op_i == CIPH_INV) ? (aes_mvm(out_data_basis_x, X2A))         :
                                       (aes_mvm(out_data_basis_x, X2S) ^ 8'h63);
endmodule

package aes_sbox_canright_pkg;
  
  
  function automatic logic [1:0] aes_mul_gf2p2(logic [1:0] g, logic [1:0] d);
    logic [1:0] f;
    logic       a, b, c;
    a    = g[1] & d[1];
    b    = (^g) & (^d);
    c    = g[0] & d[0];
    f[1] = a ^ b;
    f[0] = c ^ b;
    return f;
  endfunction
  
  
  function automatic logic [1:0] aes_scale_omega2_gf2p2(logic [1:0] g);
    logic [1:0] d;
    d[1] = g[0];
    d[0] = g[1] ^ g[0];
    return d;
  endfunction
  
  
  function automatic logic [1:0] aes_scale_omega_gf2p2(logic [1:0] g);
    logic [1:0] d;
    d[1] = g[1] ^ g[0];
    d[0] = g[1];
    return d;
  endfunction
  
  
  function automatic logic [1:0] aes_square_gf2p2(logic [1:0] g);
    logic [1:0] d;
    d[1] = g[0];
    d[0] = g[1];
    return d;
  endfunction
  
  
  function automatic logic [3:0] aes_mul_gf2p4(logic [3:0] gamma, logic [3:0] delta);
    logic [3:0] theta;
    logic [1:0] a, b, c;
    a          = aes_mul_gf2p2(gamma[3:2], delta[3:2]);
    b          = aes_mul_gf2p2(gamma[3:2] ^ gamma[1:0], delta[3:2] ^ delta[1:0]);
    c          = aes_mul_gf2p2(gamma[1:0], delta[1:0]);
    theta[3:2] = a ^ aes_scale_omega2_gf2p2(b);
    theta[1:0] = c ^ aes_scale_omega2_gf2p2(b);
    return theta;
  endfunction
  
  
  function automatic logic [3:0] aes_square_scale_gf2p4_gf2p2(logic [3:0] gamma);
    logic [3:0] delta;
    logic [1:0] a, b;
    a          = gamma[3:2] ^ gamma[1:0];
    b          = aes_square_gf2p2(gamma[1:0]);
    delta[3:2] = aes_square_gf2p2(a);
    delta[1:0] = aes_scale_omega_gf2p2(b);
    return delta;
  endfunction
  
  
  
  
  
  
  
  parameter logic [7:0] A2X [8] = '{8'h98, 8'hf3, 8'hf2, 8'h48, 8'h09, 8'h81, 8'ha9, 8'hff};
  parameter logic [7:0] X2A [8] = '{8'h64, 8'h78, 8'h6e, 8'h8c, 8'h68, 8'h29, 8'hde, 8'h60};
  parameter logic [7:0] X2S [8] = '{8'h58, 8'h2d, 8'h9e, 8'h0b, 8'hdc, 8'h04, 8'h03, 8'h24};
  parameter logic [7:0] S2X [8] = '{8'h8c, 8'h79, 8'h05, 8'heb, 8'h12, 8'h04, 8'h51, 8'h53};
endpackage

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
typedef struct packed {
  logic [7:0] prd_1;
  logic [3:0] prd_2;
  logic [7:0] prd_3;
  logic [7:0] prd_4;
} aes_sbox_dom_prd_in_t;
typedef struct packed {
  logic [3:0] prd_1;
  logic [7:0] prd_2;
  logic [7:0] prd_3;
} aes_sbox_dom_prd_out_t;
module aes_dom_indep_mul_gf2pn #(
  parameter int unsigned NPower   = 4,
  parameter bit          Pipeline = 1'b0
) (
  input  logic              clk_i,
  input  logic              rst_ni,
  input  logic              we_i,
  input  logic [NPower-1:0] a_x,    
  input  logic [NPower-1:0] a_y,    
  input  logic [NPower-1:0] b_x,    
  input  logic [NPower-1:0] b_y,    
  input  logic [NPower-1:0] z_0,    
  output logic [NPower-1:0] a_q,    
  output logic [NPower-1:0] b_q     
);
  import aes_sbox_canright_pkg::*;
  
  
  
  
  logic [NPower-1:0] mul_ax_ay_d, mul_bx_by_d;
  if (NPower == 4) begin : gen_inner_mul_gf2p4
    assign mul_ax_ay_d = aes_mul_gf2p4(a_x, a_y);
    assign mul_bx_by_d = aes_mul_gf2p4(b_x, b_y);
  end else begin : gen_inner_mul_gf2p2
    assign mul_ax_ay_d = aes_mul_gf2p2(a_x, a_y);
    assign mul_bx_by_d = aes_mul_gf2p2(b_x, b_y);
  end
  
  logic [NPower-1:0] mul_ax_by, mul_ay_bx;
  if (NPower == 4) begin : gen_cross_mul_gf2p4
    assign mul_ax_by = aes_mul_gf2p4(a_x, b_y);
    assign mul_ay_bx = aes_mul_gf2p4(a_y, b_x);
  end else begin : gen_cross_mul_gf2p2
    assign mul_ax_by = aes_mul_gf2p2(a_x, b_y);
    assign mul_ay_bx = aes_mul_gf2p2(a_y, b_x);
  end
  
  
  
  
  logic [NPower-1:0] aq_z0_d, bq_z0_d;
  logic [NPower-1:0] aq_z0_q, bq_z0_q;
  assign aq_z0_d = z_0 ^ mul_ax_by;
  assign bq_z0_d = z_0 ^ mul_ay_bx;
  
  prim_flop_en #(
    .Width      ( 2*NPower ),
    .ResetValue ( '0       )
  ) u_prim_flop_abq_z0 (
    .clk_i  ( clk_i              ),
    .rst_ni ( rst_ni             ),
    .en_i   ( we_i               ),
    .d_i    ( {aq_z0_d, bq_z0_d} ),
    .q_o    ( {aq_z0_q, bq_z0_q} )
  );
  
  
  
  logic [NPower-1:0] mul_ax_ay, mul_bx_by;
  if (Pipeline == 1'b1) begin : gen_pipeline
    
    
    
    logic [NPower-1:0] mul_ax_ay_q, mul_bx_by_q;
    prim_flop_en #(
      .Width      ( 2*NPower ),
      .ResetValue ( '0       )
    ) u_prim_flop_mul_abx_aby (
      .clk_i  ( clk_i                      ),
      .rst_ni ( rst_ni                     ),
      .en_i   ( we_i                       ),
      .d_i    ( {mul_ax_ay_d, mul_bx_by_d} ),
      .q_o    ( {mul_ax_ay_q, mul_bx_by_q} )
    );
    assign mul_ax_ay = mul_ax_ay_q;
    assign mul_bx_by = mul_bx_by_q;
  end else begin : gen_no_pipeline
    
    
    
    
    
    logic [NPower-1:0] mul_ax_ay_buf, mul_bx_by_buf;
    prim_buf #(
      .Width  ( 2*NPower )
    ) u_prim_buf_mul_abx_aby (
      .in_i  ( {mul_ax_ay_d,   mul_bx_by_d}   ),
      .out_o ( {mul_ax_ay_buf, mul_bx_by_buf} )
    );
    assign mul_ax_ay = mul_ax_ay_buf;
    assign mul_bx_by = mul_bx_by_buf;
  end
  
  
  
  assign a_q = mul_ax_ay ^ aq_z0_q;
  assign b_q = mul_bx_by ^ bq_z0_q;
  
  `ASSERT_INIT(AesDomIndepMulPower, NPower == 4 || NPower == 2)
endmodule
module aes_dom_dep_mul_gf2pn_unopt #(
  parameter int unsigned NPower   = 4,
  parameter bit          Pipeline = 1'b0
) (
  input  logic              clk_i,
  input  logic              rst_ni,
  input  logic              we_i,
  input  logic [NPower-1:0] a_x,    
  input  logic [NPower-1:0] a_y,    
  input  logic [NPower-1:0] b_x,    
  input  logic [NPower-1:0] b_y,    
  input  logic [NPower-1:0] a_z,    
  input  logic [NPower-1:0] b_z,    
  input  logic [NPower-1:0] z_0,    
  output logic [NPower-1:0] a_q,    
  output logic [NPower-1:0] b_q     
);
  import aes_sbox_canright_pkg::*;
  
  
  
  
  logic [NPower-1:0] a_yz_d, b_yz_d;
  logic [NPower-1:0] a_yz_q, b_yz_q;
  assign a_yz_d = a_y ^ a_z;
  assign b_yz_d = b_y ^ b_z;
  
  prim_flop_en #(
    .Width      ( 2*NPower ),
    .ResetValue ( '0       )
  ) u_prim_flop_ab_yz (
    .clk_i  ( clk_i            ),
    .rst_ni ( rst_ni           ),
    .en_i   ( we_i             ),
    .d_i    ( {a_yz_d, b_yz_d} ),
    .q_o    ( {a_yz_q, b_yz_q} )
  );
  
  
  
  logic [NPower-1:0] a_mul_x_z, b_mul_x_z;
  aes_dom_indep_mul_gf2pn #(
    .NPower   ( NPower   ),
    .Pipeline ( Pipeline )
  ) u_aes_dom_indep_mul_gf2pn (
    .clk_i  ( clk_i     ),
    .rst_ni ( rst_ni    ),
    .we_i   ( we_i      ),
    .a_x    ( a_x       ), 
    .a_y    ( a_z       ), 
    .b_x    ( b_x       ), 
    .b_y    ( b_z       ), 
    .z_0    ( z_0       ), 
    .a_q    ( a_mul_x_z ), 
    .b_q    ( b_mul_x_z )  
  );
  
  
  
  logic [NPower-1:0] a_x_calc, b_x_calc;
  if (Pipeline == 1'b1) begin : gen_pipeline
    
    
    
    logic [NPower-1:0] a_x_q, b_x_q;
    prim_flop_en #(
      .Width      ( 2*NPower ),
      .ResetValue ( '0       )
    ) u_prim_flop_ab_x (
      .clk_i  ( clk_i          ),
      .rst_ni ( rst_ni         ),
      .en_i   ( we_i           ),
      .d_i    ( {a_x,   b_x}   ),
      .q_o    ( {a_x_q, b_x_q} )
    );
    assign a_x_calc = a_x_q;
    assign b_x_calc = b_x_q;
  end else begin : gen_no_pipeline
    
    
    
    
    assign a_x_calc = a_x;
    assign b_x_calc = b_x;
  end
  
  
  
  
  logic [NPower-1:0] b;
  assign b = a_yz_q ^ b_yz_q;
  logic [NPower-1:0] a_mul_ax_b, b_mul_bx_b;
  if (NPower == 4) begin : gen_mul_gf2p4
    assign a_mul_ax_b = aes_mul_gf2p4(a_x_calc, b);
    assign b_mul_bx_b = aes_mul_gf2p4(b_x_calc, b);
  end else begin : gen_mul_gf2p2
    assign a_mul_ax_b = aes_mul_gf2p2(a_x_calc, b);
    assign b_mul_bx_b = aes_mul_gf2p2(b_x_calc, b);
  end
  
  
  
  assign a_q = a_mul_x_z ^ a_mul_ax_b;
  assign b_q = b_mul_x_z ^ b_mul_bx_b;
  
  `ASSERT_INIT(AesDomDepMulUnoptPower, NPower == 4 || NPower == 2)
endmodule
module aes_dom_dep_mul_gf2pn #(
  parameter int unsigned NPower      = 4,
  parameter bit          Pipeline    = 1'b0,
  parameter bit          PreDomIndep = 1'b0 
                                            
                                            
                                            
                                            
                                            
) (
  input  logic                clk_i,
  input  logic                rst_ni,
  input  logic                we_i,
  input  logic   [NPower-1:0] a_x,    
  input  logic   [NPower-1:0] a_y,    
  input  logic   [NPower-1:0] b_x,    
  input  logic   [NPower-1:0] b_y,    
  input  logic   [NPower-1:0] a_x_q,  
  input  logic   [NPower-1:0] a_y_q,  
  input  logic   [NPower-1:0] b_x_q,  
  input  logic   [NPower-1:0] b_y_q,  
  input  logic   [NPower-1:0] z_0,    
  input  logic   [NPower-1:0] z_1,    
  output logic   [NPower-1:0] a_q,    
  output logic   [NPower-1:0] b_q,    
  output logic [2*NPower-1:0] prd_o   
);
  import aes_sbox_canright_pkg::*;
  
  
  
  
  logic [NPower-1:0] a_yz0_d, b_yz0_d;
  logic [NPower-1:0] a_yz0_q, b_yz0_q;
  assign a_yz0_d = a_y ^ z_0;
  assign b_yz0_d = b_y ^ z_0;
  
  prim_flop_en #(
    .Width      ( 2*NPower ),
    .ResetValue ( '0       )
  ) u_prim_flop_ab_yz0 (
    .clk_i  ( clk_i              ),
    .rst_ni ( rst_ni             ),
    .en_i   ( we_i               ),
    .d_i    ( {a_yz0_d, b_yz0_d} ),
    .q_o    ( {a_yz0_q, b_yz0_q} )
  );
  
  
  
  
  
  
  
  
  logic [NPower-1:0] mul_ax_z0, mul_bx_z0;
  if (NPower == 4) begin : gen_corr_mul_gf2p4
    assign mul_ax_z0 = aes_mul_gf2p4(a_x, z_0);
    assign mul_bx_z0 = aes_mul_gf2p4(b_x, z_0);
  end else begin : gen_corr_mul_gf2p2
    assign mul_ax_z0 = aes_mul_gf2p2(a_x, z_0);
    assign mul_bx_z0 = aes_mul_gf2p2(b_x, z_0);
  end
  
  logic [NPower-1:0] mul_ax_z0_buf, mul_bx_z0_buf;
  prim_buf #(
    .Width ( 2*NPower )
  ) u_prim_buf_mul_abx_z0 (
    .in_i  ( {mul_ax_z0,     mul_bx_z0}     ),
    .out_o ( {mul_ax_z0_buf, mul_bx_z0_buf} )
  );
  
  logic [NPower-1:0] axz0_z1_d, bxz0_z1_d;
  logic [NPower-1:0] axz0_z1_q, bxz0_z1_q;
  assign axz0_z1_d = mul_ax_z0_buf ^ z_1;
  assign bxz0_z1_d = mul_bx_z0_buf ^ z_1;
  
  prim_flop_en #(
    .Width      ( 2*NPower ),
    .ResetValue ( '0       )
  ) u_prim_flop_abxz0_z1 (
    .clk_i  ( clk_i                  ),
    .rst_ni ( rst_ni                 ),
    .en_i   ( we_i                   ),
    .d_i    ( {axz0_z1_d, bxz0_z1_d} ),
    .q_o    ( {axz0_z1_q, bxz0_z1_q} )
  );
  
  
  
  
  
  
  assign prd_o = {b_yz0_q, bxz0_z1_q};
  
  
  
  logic [NPower-1:0] a_x_calc, b_x_calc, a_y_calc, b_y_calc;
  if (Pipeline == 1'b1 && PreDomIndep != 1'b1) begin : gen_pipeline_use
    
    
    
    
    
    assign a_x_calc = a_x_q;
    assign b_x_calc = b_x_q;
    assign a_y_calc = a_y_q;
    assign b_y_calc = b_y_q;
  end else begin : gen_no_pipeline_use
    
    
    
    
    assign a_x_calc = a_x;
    assign b_x_calc = b_x;
    assign a_y_calc = a_y;
    assign b_y_calc = b_y;
    
    if (PreDomIndep != 1'b1) begin : gen_ab_x_q
      logic [NPower-1:0] unused_a_x_q, unused_b_x_q;
      assign unused_a_x_q = a_x_q;
      assign unused_b_x_q = b_x_q;
    end
    logic [NPower-1:0] unused_a_y_q, unused_b_y_q;
    assign unused_a_y_q = a_y_q;
    assign unused_b_y_q = b_y_q;
  end
  
  
  
  
  
  
  
  
  
  
  
  
  if (PreDomIndep == 1'b1) begin : gen_pre_dom_indep
    
    
    
    
    
    logic [NPower-1:0] mul_ax_ay_d, mul_bx_by_d;
    logic [NPower-1:0] mul_ax_ay_q, mul_bx_by_q;
    if (NPower == 4) begin : gen_inner_mul_gf2p4
      assign mul_ax_ay_d = aes_mul_gf2p4(a_x_calc, a_y_calc);
      assign mul_bx_by_d = aes_mul_gf2p4(b_x_calc, b_y_calc);
    end else begin : gen_inner_mul_gf2p2
      assign mul_ax_ay_d = aes_mul_gf2p2(a_x_calc, a_y_calc);
      assign mul_bx_by_d = aes_mul_gf2p2(b_x_calc, b_y_calc);
    end
    
    prim_flop_en #(
      .Width      ( 2*NPower ),
      .ResetValue ( '0       )
    ) u_prim_flop_mul_abx_aby (
      .clk_i  ( clk_i                      ),
      .rst_ni ( rst_ni                     ),
      .en_i   ( we_i                       ),
      .d_i    ( {mul_ax_ay_d, mul_bx_by_d} ),
      .q_o    ( {mul_ax_ay_q, mul_bx_by_q} )
    );
    
    
    logic [NPower-1:0] mul_ax_byz0, mul_bx_ayz0;
    if (NPower == 4) begin : gen_cross_mul_gf2p4
      assign mul_ax_byz0 = aes_mul_gf2p4(a_x_q, b_yz0_q);
      assign mul_bx_ayz0 = aes_mul_gf2p4(b_x_q, a_yz0_q);
    end else begin : gen_cross_mul_gf2p2
      assign mul_ax_byz0 = aes_mul_gf2p2(a_x_q, b_yz0_q);
      assign mul_bx_ayz0 = aes_mul_gf2p2(b_x_q, a_yz0_q);
    end
    
    logic [NPower-1:0] mul_ax_byz0_buf, mul_bx_ayz0_buf;
    prim_buf #(
      .Width ( 2*NPower )
    ) u_prim_buf_mul_abx_bayz0 (
      .in_i  ( {mul_ax_byz0,     mul_bx_ayz0}     ),
      .out_o ( {mul_ax_byz0_buf, mul_bx_ayz0_buf} )
    );
    
    assign a_q = axz0_z1_q ^ mul_ax_ay_q ^ mul_ax_byz0_buf;
    assign b_q = bxz0_z1_q ^ mul_bx_by_q ^ mul_bx_ayz0_buf;
  end else begin : gen_not_pre_dom_indep
    
    
    
    
    logic [NPower-1:0] a_b, b_b;
    assign a_b = a_y_calc ^ b_yz0_q;
    assign b_b = b_y_calc ^ a_yz0_q;
    
    logic [NPower-1:0] a_b_buf, b_b_buf;
    prim_buf #(
      .Width ( 2*NPower )
    ) u_prim_buf_ab_b (
      .in_i  ( {a_b,     b_b}     ),
      .out_o ( {a_b_buf, b_b_buf} )
    );
    
    logic [NPower-1:0] a_mul_ax_b, b_mul_bx_b;
    if (NPower == 4) begin : gen_mul_gf2p4
      assign a_mul_ax_b = aes_mul_gf2p4(a_x_calc, a_b_buf);
      assign b_mul_bx_b = aes_mul_gf2p4(b_x_calc, b_b_buf);
    end else begin : gen_mul_gf2p2
      assign a_mul_ax_b = aes_mul_gf2p2(a_x_calc, a_b_buf);
      assign b_mul_bx_b = aes_mul_gf2p2(b_x_calc, b_b_buf);
    end
    
    logic [NPower-1:0] a_mul_ax_b_buf, b_mul_bx_b_buf;
    prim_buf #(
      .Width ( 2*NPower )
    ) u_prim_buf_ab_mul_abx_b (
      .in_i  ( {a_mul_ax_b,     b_mul_bx_b}     ),
      .out_o ( {a_mul_ax_b_buf, b_mul_bx_b_buf} )
    );
    
    assign a_q = axz0_z1_q ^ a_mul_ax_b_buf;
    assign b_q = bxz0_z1_q ^ b_mul_bx_b_buf;
  end
  
  `ASSERT_INIT(AesDomDepMulPower, NPower == 4 || NPower == 2)
endmodule
module aes_dom_inverse_gf2p4 #(
  parameter bit PipelineMul = 1'b1
) (
  input  logic        clk_i,
  input  logic        rst_ni,
  input  logic  [1:0] we_i,
  input  logic  [3:0] a_gamma,
  input  logic  [3:0] b_gamma,
  input  logic  [3:0] prd_2_i,
  input  logic  [7:0] prd_3_i,
  output logic  [3:0] a_gamma_inv,
  output logic  [3:0] b_gamma_inv,
  output logic  [7:0] prd_2_o,
  output logic  [7:0] prd_3_o
);
  import aes_sbox_canright_pkg::*;
  
  
  
  
  logic [1:0] a_gamma1, a_gamma0, b_gamma1, b_gamma0, a_gamma1_gamma0, b_gamma1_gamma0;
  assign a_gamma1 = a_gamma[3:2];
  assign a_gamma0 = a_gamma[1:0];
  assign b_gamma1 = b_gamma[3:2];
  assign b_gamma0 = b_gamma[1:0];
  logic [1:0] a_gamma_ss_d, b_gamma_ss_d;
  logic [1:0] a_gamma_ss_q, b_gamma_ss_q;
  assign a_gamma_ss_d = aes_scale_omega2_gf2p2(aes_square_gf2p2(a_gamma1 ^ a_gamma0));
  assign b_gamma_ss_d = aes_scale_omega2_gf2p2(aes_square_gf2p2(b_gamma1 ^ b_gamma0));
  prim_flop_en #(
    .Width      ( 4  ),
    .ResetValue ( '0 )
  ) u_prim_flop_ab_gamma_ss (
    .clk_i  ( clk_i                        ),
    .rst_ni ( rst_ni                       ),
    .en_i   ( we_i[0]                      ),
    .d_i    ( {a_gamma_ss_d, b_gamma_ss_d} ),
    .q_o    ( {a_gamma_ss_q, b_gamma_ss_q} )
  );
  logic [1:0] a_gamma1_q, a_gamma0_q, b_gamma1_q, b_gamma0_q;
  prim_flop_en #(
    .Width      ( 8  ),
    .ResetValue ( '0 )
  ) u_prim_flop_ab_gamma10 (
    .clk_i  ( clk_i                                            ),
    .rst_ni ( rst_ni                                           ),
    .en_i   ( we_i[0]                                          ),
    .d_i    ( {a_gamma1,   a_gamma0,   b_gamma1,   b_gamma0}   ),
    .q_o    ( {a_gamma1_q, a_gamma0_q, b_gamma1_q, b_gamma0_q} )
  );
  logic [3:0] b_gamma10_prd2;
  aes_dom_dep_mul_gf2pn #(
    .NPower      ( 2           ),
    .Pipeline    ( PipelineMul ),
    .PreDomIndep ( 1'b0        )
  ) u_aes_dom_mul_gamma1_gamma0 (
    .clk_i  ( clk_i           ),
    .rst_ni ( rst_ni          ),
    .we_i   ( we_i[0]         ),
    .a_x    ( a_gamma1        ), 
    .a_y    ( a_gamma0        ), 
    .b_x    ( b_gamma1        ), 
    .b_y    ( b_gamma0        ), 
    .a_x_q  ( a_gamma1_q      ), 
    .a_y_q  ( a_gamma0_q      ), 
    .b_x_q  ( b_gamma1_q      ), 
    .b_y_q  ( b_gamma0_q      ), 
    .z_0    ( prd_2_i[1:0]    ), 
    .z_1    ( prd_2_i[3:2]    ), 
    .a_q    ( a_gamma1_gamma0 ), 
    .b_q    ( b_gamma1_gamma0 ), 
    .prd_o  ( b_gamma10_prd2  )  
  );
  
  
  
  
  
  
  
  
  
  
  
  
  assign prd_2_o = {b_gamma1_q, b_gamma10_prd2[3:2], b_gamma0_q, b_gamma10_prd2[1:0]};
  
  
  
  
  logic [1:0] a_omega, b_omega;
  assign a_omega = aes_square_gf2p2(a_gamma1_gamma0 ^ a_gamma_ss_q);
  assign b_omega = aes_square_gf2p2(b_gamma1_gamma0 ^ b_gamma_ss_q);
  
  logic [1:0] a_omega_buf, b_omega_buf;
  prim_buf #(
    .Width ( 4 )
  ) u_prim_buf_ab_omega (
    .in_i  ( {a_omega,     b_omega}     ),
    .out_o ( {a_omega_buf, b_omega_buf} )
  );
  
  logic [1:0] a_gamma1_qq, a_gamma0_qq, b_gamma1_qq, b_gamma0_qq, a_omega_buf_q, b_omega_buf_q;
  if (PipelineMul == 1'b1) begin: gen_prim_flop_omega_gamma10
    
    
    prim_flop_en #(
      .Width      ( 8  ),
      .ResetValue ( '0 )
    ) u_prim_flop_ab_gamma10_q (
      .clk_i  ( clk_i                                                ),
      .rst_ni ( rst_ni                                               ),
      .en_i   ( we_i[1]                                              ),
      .d_i    ( {a_gamma1_q,  a_gamma0_q,  b_gamma1_q,  b_gamma0_q}  ),
      .q_o    ( {a_gamma1_qq, a_gamma0_qq, b_gamma1_qq, b_gamma0_qq} )
    );
    
    prim_flop_en #(
      .Width      ( 4  ),
      .ResetValue ( '0 )
    ) u_prim_flop_ab_omega_buf (
      .clk_i  ( clk_i                          ),
      .rst_ni ( rst_ni                         ),
      .en_i   ( we_i[1]                        ),
      .d_i    ( {a_omega_buf,   b_omega_buf}   ),
      .q_o    ( {a_omega_buf_q, b_omega_buf_q} )
    );
  end else begin : gen_no_prim_flop_ab_y10
    
    
    
    assign a_gamma1_qq = '0;
    assign a_gamma0_qq = '0;
    assign b_gamma1_qq = '0;
    assign b_gamma0_qq = '0;
    assign a_omega_buf_q = '0;
    assign b_omega_buf_q = '0;
  end
  
  logic [3:0] b_gamma1_omega_prd3;
  aes_dom_dep_mul_gf2pn #(
    .NPower      ( 2           ),
    .Pipeline    ( PipelineMul ),
    .PreDomIndep ( 1'b0        )
  ) u_aes_dom_mul_omega_gamma1 (
    .clk_i  ( clk_i               ),
    .rst_ni ( rst_ni              ),
    .we_i   ( we_i[1]             ),
    .a_x    ( a_gamma1_q          ), 
    .a_y    ( a_omega_buf         ), 
    .b_x    ( b_gamma1_q          ), 
    .b_y    ( b_omega_buf         ), 
    .a_x_q  ( a_gamma1_qq         ), 
    .a_y_q  ( a_omega_buf_q       ), 
    .b_x_q  ( b_gamma1_qq         ), 
    .b_y_q  ( b_omega_buf_q       ), 
    .z_0    ( prd_3_i[5:4]        ), 
    .z_1    ( prd_3_i[7:6]        ), 
    .a_q    ( a_gamma_inv[1:0]    ), 
    .b_q    ( b_gamma_inv[1:0]    ), 
    .prd_o  ( b_gamma1_omega_prd3 )  
  );
  logic [3:0] b_gamma0_omega_prd3;
  aes_dom_dep_mul_gf2pn #(
    .NPower      ( 2           ),
    .Pipeline    ( PipelineMul ),
    .PreDomIndep ( 1'b0        )
  ) u_aes_dom_mul_omega_gamma0 (
    .clk_i  ( clk_i               ),
    .rst_ni ( rst_ni              ),
    .we_i   ( we_i[1]             ),
    .a_x    ( a_omega_buf         ), 
    .a_y    ( a_gamma0_q          ), 
    .b_x    ( b_omega_buf         ), 
    .b_y    ( b_gamma0_q          ), 
    .a_x_q  ( a_omega_buf_q       ), 
    .a_y_q  ( a_gamma0_qq         ), 
    .b_x_q  ( b_omega_buf_q       ), 
    .b_y_q  ( b_gamma0_qq         ), 
    .z_0    ( prd_3_i[1:0]        ), 
    .z_1    ( prd_3_i[3:2]        ), 
    .a_q    ( a_gamma_inv[3:2]    ), 
    .b_q    ( b_gamma_inv[3:2]    ), 
    .prd_o  ( b_gamma0_omega_prd3 )  
  );
  
  
  
  
  assign prd_3_o = {b_gamma1_omega_prd3, b_gamma0_omega_prd3};
endmodule
module aes_dom_inverse_gf2p8 #(
  parameter bit PipelineMul = 1'b1
) (
  input  logic                  clk_i,
  input  logic                  rst_ni,
  input  logic            [3:0] we_i,
  input  logic            [7:0] a_y,     
  input  logic            [7:0] b_y,     
  input  aes_sbox_dom_prd_in_t  prd_i,   
  output logic            [7:0] a_y_inv, 
  output logic            [7:0] b_y_inv, 
  output aes_sbox_dom_prd_out_t prd_o    
);                                       
  import aes_sbox_canright_pkg::*;
  
  
  
  
  logic [3:0] a_y1, a_y0, b_y1, b_y0, a_y1_y0, b_y1_y0;
  assign a_y1 = a_y[7:4];
  assign a_y0 = a_y[3:0];
  assign b_y1 = b_y[7:4];
  assign b_y0 = b_y[3:0];
  logic [3:0] a_y_ss_d, b_y_ss_d;
  logic [3:0] a_y_ss_q, b_y_ss_q;
  assign a_y_ss_d = aes_square_scale_gf2p4_gf2p2(a_y1 ^ a_y0);
  assign b_y_ss_d = aes_square_scale_gf2p4_gf2p2(b_y1 ^ b_y0);
  prim_flop_en #(
    .Width      ( 8  ),
    .ResetValue ( '0 )
  ) u_prim_flop_ab_y_ss (
    .clk_i  ( clk_i                ),
    .rst_ni ( rst_ni               ),
    .en_i   ( we_i[0]              ),
    .d_i    ( {a_y_ss_d, b_y_ss_d} ),
    .q_o    ( {a_y_ss_q, b_y_ss_q} )
  );
  logic [3:0] a_y1_q, a_y0_q, b_y1_q, b_y0_q;
  if (PipelineMul == 1'b1) begin: gen_prim_flop_ab_y10
    
    
    prim_flop_en #(
      .Width      ( 16  ),
      .ResetValue ( '0  )
    ) u_prim_flop_ab_y10 (
      .clk_i  ( clk_i                            ),
      .rst_ni ( rst_ni                           ),
      .en_i   ( we_i[0]                          ),
      .d_i    ( {a_y1,   a_y0,   b_y1,   b_y0}   ),
      .q_o    ( {a_y1_q, a_y0_q, b_y1_q, b_y0_q} )
    );
  end else begin : gen_no_prim_flop_ab_y10
    
    
    
    assign a_y1_q = '0;
    assign a_y0_q = '0;
    assign b_y1_q = '0;
    assign b_y0_q = '0;
  end
  logic [7:0] b_y10_prd1;
  aes_dom_dep_mul_gf2pn #(
    .NPower      ( 4           ),
    .Pipeline    ( PipelineMul ),
    .PreDomIndep ( 1'b0        )
  ) u_aes_dom_mul_y1_y0 (
    .clk_i  ( clk_i            ),
    .rst_ni ( rst_ni           ),
    .we_i   ( we_i[0]          ),
    .a_x    ( a_y1             ), 
    .a_y    ( a_y0             ), 
    .b_x    ( b_y1             ), 
    .b_y    ( b_y0             ), 
    .a_x_q  ( a_y1_q           ), 
    .a_y_q  ( a_y0_q           ), 
    .b_x_q  ( b_y1_q           ), 
    .b_y_q  ( b_y0_q           ), 
    .z_0    ( prd_i.prd_1[3:0] ), 
    .z_1    ( prd_i.prd_1[7:4] ), 
    .a_q    ( a_y1_y0          ), 
    .b_q    ( b_y1_y0          ), 
    .prd_o  ( b_y10_prd1       )  
  );
  logic [3:0] a_gamma, b_gamma;
  assign a_gamma = a_y_ss_q ^ a_y1_y0;
  assign b_gamma = b_y_ss_q ^ b_y1_y0;
  
  logic [3:0] a_gamma_buf, b_gamma_buf;
  prim_buf #(
    .Width ( 8 )
  ) u_prim_buf_ab_gamma (
    .in_i  ( {a_gamma,     b_gamma}     ),
    .out_o ( {a_gamma_buf, b_gamma_buf} )
  );
  
  
  
  
  assign prd_o.prd_1 = b_y10_prd1[3:0];
  logic [3:0] unused_prd;
  assign unused_prd  = b_y10_prd1[7:4];
  
  
  
  logic [3:0] a_theta, b_theta;
  
  aes_dom_inverse_gf2p4 #(
    .PipelineMul ( PipelineMul )
  ) u_aes_dom_inverse_gf2p4 (
    .clk_i       ( clk_i       ),
    .rst_ni      ( rst_ni      ),
    .we_i        ( we_i[2:1]   ),
    .a_gamma     ( a_gamma_buf ),
    .b_gamma     ( b_gamma_buf ),
    .prd_2_i     ( prd_i.prd_2 ),
    .prd_3_i     ( prd_i.prd_3 ),
    .a_gamma_inv ( a_theta     ),
    .b_gamma_inv ( b_theta     ),
    .prd_2_o     ( prd_o.prd_2 ),
    .prd_3_o     ( prd_o.prd_3 )
  );
  
  
  
  
  logic [3:0] a_y1_qqq, a_y0_qqq, b_y1_qqq, b_y0_qqq;
  prim_flop_en #(
    .Width      ( 16 ),
    .ResetValue ( '0 )
  ) u_prim_flop_ab_y10_qqq (
    .clk_i  ( clk_i                                    ),
    .rst_ni ( rst_ni                                   ),
    .en_i   ( we_i[2]                                  ),
    .d_i    ( {a_y1,     a_y0,     b_y1,     b_y0}     ),
    .q_o    ( {a_y1_qqq, a_y0_qqq, b_y1_qqq, b_y0_qqq} )
  );
  aes_dom_indep_mul_gf2pn #(
    .NPower   ( 4           ),
    .Pipeline ( PipelineMul )
  ) u_aes_dom_mul_theta_y1 (
    .clk_i  ( clk_i            ),
    .rst_ni ( rst_ni           ),
    .we_i   ( we_i[3]          ),
    .a_x    ( a_y1_qqq         ), 
    .a_y    ( a_theta          ), 
    .b_x    ( b_y1_qqq         ), 
    .b_y    ( b_theta          ), 
    .z_0    ( prd_i.prd_4[7:4] ), 
    .a_q    ( a_y_inv[3:0]     ), 
    .b_q    ( b_y_inv[3:0]     )  
  );
  aes_dom_indep_mul_gf2pn #(
    .NPower   ( 4           ),
    .Pipeline ( PipelineMul )
  ) u_aes_dom_mul_theta_y0 (
    .clk_i  ( clk_i            ),
    .rst_ni ( rst_ni           ),
    .we_i   ( we_i[3]          ),
    .a_x    ( a_theta          ), 
    .a_y    ( a_y0_qqq         ), 
    .b_x    ( b_theta          ), 
    .b_y    ( b_y0_qqq         ), 
    .z_0    ( prd_i.prd_4[3:0] ), 
    .a_q    ( a_y_inv[7:4]     ), 
    .b_q    ( b_y_inv[7:4]     )  
  );
endmodule
module aes_sbox_dom
#(
  parameter bit PipelineMul = 1'b1
) (
  input  logic              clk_i,
  input  logic              rst_ni,
  input  logic              en_i,
  output logic              out_req_o,
  input  logic              out_ack_i,
  input  aes_pkg::ciph_op_e op_i,
  input  logic        [7:0] data_i, 
  input  logic        [7:0] mask_i, 
  input  logic       [27:0] prd_i,  
                                    
  output logic        [7:0] data_o, 
  output logic        [7:0] mask_o, 
  output logic       [19:0] prd_o   
);
  import aes_pkg::*;
  import aes_sbox_canright_pkg::*;
  logic            [7:0] in_data_basis_x, out_data_basis_x;
  logic            [7:0] in_mask_basis_x, out_mask_basis_x;
  logic            [3:0] we;
  aes_sbox_dom_prd_in_t  in_prd;
  aes_sbox_dom_prd_out_t out_prd;
  
  assign in_data_basis_x = (op_i == CIPH_FWD) ? aes_mvm(data_i, A2X)         :
                           (op_i == CIPH_INV) ? aes_mvm(data_i ^ 8'h63, S2X) :
                                                aes_mvm(data_i, A2X);
  
  
  assign in_mask_basis_x = (op_i == CIPH_FWD) ? aes_mvm(mask_i, A2X) :
                           (op_i == CIPH_INV) ? aes_mvm(mask_i, S2X) :
                                                aes_mvm(mask_i, A2X);
  
  aes_dom_inverse_gf2p8 #(
    .PipelineMul ( PipelineMul )
  ) u_aes_dom_inverse_gf2p8 (
    .clk_i   ( clk_i            ),
    .rst_ni  ( rst_ni           ),
    .we_i    ( we               ),
    .a_y     ( in_data_basis_x  ), 
    .b_y     ( in_mask_basis_x  ), 
    .prd_i   ( in_prd           ), 
    .a_y_inv ( out_data_basis_x ), 
    .b_y_inv ( out_mask_basis_x ), 
    .prd_o   ( out_prd          )  
  );
  
  assign data_o = (op_i == CIPH_FWD) ? (aes_mvm(out_data_basis_x, X2S) ^ 8'h63) :
                  (op_i == CIPH_INV) ? (aes_mvm(out_data_basis_x, X2A))         :
                                       (aes_mvm(out_data_basis_x, X2S) ^ 8'h63);
  
  
  assign mask_o = (op_i == CIPH_FWD) ? aes_mvm(out_mask_basis_x, X2S) :
                  (op_i == CIPH_INV) ? aes_mvm(out_mask_basis_x, X2A) :
                                       aes_mvm(out_mask_basis_x, X2S);
  
  logic [2:0] count_d, count_q;
  assign count_d = (out_req_o && out_ack_i) ? '0             :
                   out_req_o                ? count_q        :
                   en_i                     ? count_q + 3'd1 : count_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin : reg_count
    if (!rst_ni) begin
      count_q <= '0;
    end else begin
      count_q <= count_d;
    end
  end
  assign out_req_o = en_i & count_q == 3'd4;
  
  assign we[0] = en_i & count_q == 3'd0;
  assign we[1] = en_i & count_q == 3'd1;
  assign we[2] = en_i & count_q == 3'd2;
  assign we[3] = en_i & count_q == 3'd3;
  
  
  assign in_prd = '{prd_1: prd_i[7:0],
                    prd_2: prd_i[11:8],
                    prd_3: prd_i[19:12],
                    prd_4: prd_i[27:20]};
  assign prd_o = {out_prd.prd_3, out_prd.prd_2, out_prd.prd_1};
endmodule

module aes_sbox_lut (
  input  aes_pkg::ciph_op_e op_i,
  input  logic [7:0]        data_i,
  output logic [7:0]        data_o
);
  import aes_pkg::*;
  
  localparam logic [7:0] SBOX_FWD [256] = '{
    8'h63, 8'h7C, 8'h77, 8'h7B, 8'hF2, 8'h6B, 8'h6F, 8'hC5,
    8'h30, 8'h01, 8'h67, 8'h2B, 8'hFE, 8'hD7, 8'hAB, 8'h76,
    8'hCA, 8'h82, 8'hC9, 8'h7D, 8'hFA, 8'h59, 8'h47, 8'hF0,
    8'hAD, 8'hD4, 8'hA2, 8'hAF, 8'h9C, 8'hA4, 8'h72, 8'hC0,
    8'hB7, 8'hFD, 8'h93, 8'h26, 8'h36, 8'h3F, 8'hF7, 8'hCC,
    8'h34, 8'hA5, 8'hE5, 8'hF1, 8'h71, 8'hD8, 8'h31, 8'h15,
    8'h04, 8'hC7, 8'h23, 8'hC3, 8'h18, 8'h96, 8'h05, 8'h9A,
    8'h07, 8'h12, 8'h80, 8'hE2, 8'hEB, 8'h27, 8'hB2, 8'h75,
    8'h09, 8'h83, 8'h2C, 8'h1A, 8'h1B, 8'h6E, 8'h5A, 8'hA0,
    8'h52, 8'h3B, 8'hD6, 8'hB3, 8'h29, 8'hE3, 8'h2F, 8'h84,
    8'h53, 8'hD1, 8'h00, 8'hED, 8'h20, 8'hFC, 8'hB1, 8'h5B,
    8'h6A, 8'hCB, 8'hBE, 8'h39, 8'h4A, 8'h4C, 8'h58, 8'hCF,
    8'hD0, 8'hEF, 8'hAA, 8'hFB, 8'h43, 8'h4D, 8'h33, 8'h85,
    8'h45, 8'hF9, 8'h02, 8'h7F, 8'h50, 8'h3C, 8'h9F, 8'hA8,
    8'h51, 8'hA3, 8'h40, 8'h8F, 8'h92, 8'h9D, 8'h38, 8'hF5,
    8'hBC, 8'hB6, 8'hDA, 8'h21, 8'h10, 8'hFF, 8'hF3, 8'hD2,
    8'hCD, 8'h0C, 8'h13, 8'hEC, 8'h5F, 8'h97, 8'h44, 8'h17,
    8'hC4, 8'hA7, 8'h7E, 8'h3D, 8'h64, 8'h5D, 8'h19, 8'h73,
    8'h60, 8'h81, 8'h4F, 8'hDC, 8'h22, 8'h2A, 8'h90, 8'h88,
    8'h46, 8'hEE, 8'hB8, 8'h14, 8'hDE, 8'h5E, 8'h0B, 8'hDB,
    8'hE0, 8'h32, 8'h3A, 8'h0A, 8'h49, 8'h06, 8'h24, 8'h5C,
    8'hC2, 8'hD3, 8'hAC, 8'h62, 8'h91, 8'h95, 8'hE4, 8'h79,
    8'hE7, 8'hC8, 8'h37, 8'h6D, 8'h8D, 8'hD5, 8'h4E, 8'hA9,
    8'h6C, 8'h56, 8'hF4, 8'hEA, 8'h65, 8'h7A, 8'hAE, 8'h08,
    8'hBA, 8'h78, 8'h25, 8'h2E, 8'h1C, 8'hA6, 8'hB4, 8'hC6,
    8'hE8, 8'hDD, 8'h74, 8'h1F, 8'h4B, 8'hBD, 8'h8B, 8'h8A,
    8'h70, 8'h3E, 8'hB5, 8'h66, 8'h48, 8'h03, 8'hF6, 8'h0E,
    8'h61, 8'h35, 8'h57, 8'hB9, 8'h86, 8'hC1, 8'h1D, 8'h9E,
    8'hE1, 8'hF8, 8'h98, 8'h11, 8'h69, 8'hD9, 8'h8E, 8'h94,
    8'h9B, 8'h1E, 8'h87, 8'hE9, 8'hCE, 8'h55, 8'h28, 8'hDF,
    8'h8C, 8'hA1, 8'h89, 8'h0D, 8'hBF, 8'hE6, 8'h42, 8'h68,
    8'h41, 8'h99, 8'h2D, 8'h0F, 8'hB0, 8'h54, 8'hBB, 8'h16
  };
  localparam logic [7:0] SBOX_INV [256] = '{
    8'h52, 8'h09, 8'h6a, 8'hd5, 8'h30, 8'h36, 8'ha5, 8'h38,
    8'hbf, 8'h40, 8'ha3, 8'h9e, 8'h81, 8'hf3, 8'hd7, 8'hfb,
    8'h7c, 8'he3, 8'h39, 8'h82, 8'h9b, 8'h2f, 8'hff, 8'h87,
    8'h34, 8'h8e, 8'h43, 8'h44, 8'hc4, 8'hde, 8'he9, 8'hcb,
    8'h54, 8'h7b, 8'h94, 8'h32, 8'ha6, 8'hc2, 8'h23, 8'h3d,
    8'hee, 8'h4c, 8'h95, 8'h0b, 8'h42, 8'hfa, 8'hc3, 8'h4e,
    8'h08, 8'h2e, 8'ha1, 8'h66, 8'h28, 8'hd9, 8'h24, 8'hb2,
    8'h76, 8'h5b, 8'ha2, 8'h49, 8'h6d, 8'h8b, 8'hd1, 8'h25,
    8'h72, 8'hf8, 8'hf6, 8'h64, 8'h86, 8'h68, 8'h98, 8'h16,
    8'hd4, 8'ha4, 8'h5c, 8'hcc, 8'h5d, 8'h65, 8'hb6, 8'h92,
    8'h6c, 8'h70, 8'h48, 8'h50, 8'hfd, 8'hed, 8'hb9, 8'hda,
    8'h5e, 8'h15, 8'h46, 8'h57, 8'ha7, 8'h8d, 8'h9d, 8'h84,
    8'h90, 8'hd8, 8'hab, 8'h00, 8'h8c, 8'hbc, 8'hd3, 8'h0a,
    8'hf7, 8'he4, 8'h58, 8'h05, 8'hb8, 8'hb3, 8'h45, 8'h06,
    8'hd0, 8'h2c, 8'h1e, 8'h8f, 8'hca, 8'h3f, 8'h0f, 8'h02,
    8'hc1, 8'haf, 8'hbd, 8'h03, 8'h01, 8'h13, 8'h8a, 8'h6b,
    8'h3a, 8'h91, 8'h11, 8'h41, 8'h4f, 8'h67, 8'hdc, 8'hea,
    8'h97, 8'hf2, 8'hcf, 8'hce, 8'hf0, 8'hb4, 8'he6, 8'h73,
    8'h96, 8'hac, 8'h74, 8'h22, 8'he7, 8'had, 8'h35, 8'h85,
    8'he2, 8'hf9, 8'h37, 8'he8, 8'h1c, 8'h75, 8'hdf, 8'h6e,
    8'h47, 8'hf1, 8'h1a, 8'h71, 8'h1d, 8'h29, 8'hc5, 8'h89,
    8'h6f, 8'hb7, 8'h62, 8'h0e, 8'haa, 8'h18, 8'hbe, 8'h1b,
    8'hfc, 8'h56, 8'h3e, 8'h4b, 8'hc6, 8'hd2, 8'h79, 8'h20,
    8'h9a, 8'hdb, 8'hc0, 8'hfe, 8'h78, 8'hcd, 8'h5a, 8'hf4,
    8'h1f, 8'hdd, 8'ha8, 8'h33, 8'h88, 8'h07, 8'hc7, 8'h31,
    8'hb1, 8'h12, 8'h10, 8'h59, 8'h27, 8'h80, 8'hec, 8'h5f,
    8'h60, 8'h51, 8'h7f, 8'ha9, 8'h19, 8'hb5, 8'h4a, 8'h0d,
    8'h2d, 8'he5, 8'h7a, 8'h9f, 8'h93, 8'hc9, 8'h9c, 8'hef,
    8'ha0, 8'he0, 8'h3b, 8'h4d, 8'hae, 8'h2a, 8'hf5, 8'hb0,
    8'hc8, 8'heb, 8'hbb, 8'h3c, 8'h83, 8'h53, 8'h99, 8'h61,
    8'h17, 8'h2b, 8'h04, 8'h7e, 8'hba, 8'h77, 8'hd6, 8'h26,
    8'he1, 8'h69, 8'h14, 8'h63, 8'h55, 8'h21, 8'h0c, 8'h7d
  };
  
  assign data_o = (op_i == CIPH_FWD) ? SBOX_FWD[data_i] :
                  (op_i == CIPH_INV) ? SBOX_INV[data_i] : SBOX_FWD[data_i];
endmodule
