
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

module TopModule (
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
