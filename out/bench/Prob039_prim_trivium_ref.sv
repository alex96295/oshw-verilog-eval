
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
module TopModule import prim_trivium_pkg::*;
#(
  parameter bit          BiviumVariant = 0,          
  parameter int unsigned OutputWidth = 64,           
  parameter bit          StrictLockupProtection = 1, 
                                                     
                                                     
                                                     
  parameter seed_type_e  SeedType = SeedTypeStateFull, 
                                                       
  parameter int unsigned PartialSeedWidth = PartialSeedWidthDefault,
  
  localparam int unsigned StateWidth = BiviumVariant ? BiviumStateWidth : TriviumStateWidth,
  parameter trivium_lfsr_seed_t RndCnstTriviumLfsrSeed = RndCnstTriviumLfsrSeedDefault,
  
  localparam logic [StateWidth-1:0] StateSeed = RndCnstTriviumLfsrSeed[StateWidth-1:0]
) (
  input logic clk_i,
  input logic rst_ni,
  input  logic                        en_i,                 
  input  logic                        allow_lockup_i,       
                                                            
                                                            
  input  logic                        seed_en_i,            
  output logic                        seed_done_o,          
  output logic                        seed_req_o,           
  input  logic                        seed_ack_i,           
  input  logic [KeyIvWidth-1:0]       seed_key_i,           
  input  logic [KeyIvWidth-1:0]       seed_iv_i,            
  input  logic [StateWidth-1:0]       seed_state_full_i,    
  input  logic [PartialSeedWidth-1:0] seed_state_partial_i, 
  output logic [OutputWidth-1:0] key_o, 
  output logic                   err_o  
                                        
                                        
                                        
                                        
);
  localparam int unsigned LastStatePartFractional = StateWidth % PartialSeedWidth != 0 ? 1 : 0;
  localparam int unsigned NumStateParts = StateWidth / PartialSeedWidth + LastStatePartFractional;
  localparam int unsigned NumBitsLastPart = StateWidth - (NumStateParts - 1) * PartialSeedWidth;
  localparam int unsigned LastStatePart = NumStateParts - 1;
  
  localparam int unsigned StateIdxWidth = prim_util_pkg::vbits(NumStateParts);
  logic [StateWidth-1:0] state_d, state_q;
  logic [StateWidth-1:0] state_update, state_seed;
  logic seed_req_d, seed_req_q;
  logic unused_seed;
  logic update, update_init, wr_en_seed;
  logic [StateIdxWidth-1:0] state_idx_d, state_idx_q;
  logic last_state_part;
  logic lockup, restore;
  assign update = en_i | update_init;
  assign wr_en_seed = seed_req_o & seed_ack_i;
  assign lockup = ~(|state_q);
  assign err_o = lockup;
  
  
  
  
  if (BiviumVariant) begin : gen_update_and_output_bivium
    always_comb begin
      state_update = state_q;
      for (int unsigned i = 0; i < OutputWidth; i++) begin
        key_o[i] = bivium_generate_key_stream(state_update);
        state_update = bivium_update_state(state_update);
      end
    end
  end else begin : gen_update_and_output_trivium
    always_comb begin
      state_update = state_q;
      for (int unsigned i = 0; i < OutputWidth; i++) begin
        key_o[i] = trivium_generate_key_stream(state_update);
        state_update = trivium_update_state(state_update);
      end
    end
  end
  
  
  
  if (SeedType == SeedTypeKeyIv) begin : gen_seed_type_key_iv
    if (BiviumVariant) begin : gen_seed_type_key_iv_bivium
      assign state_seed = bivium_seed_key_iv(seed_key_i, seed_iv_i);
    end else begin : gen_seed_type_key_iv_trivium
      assign state_seed = trivium_seed_key_iv(seed_key_i, seed_iv_i);
    end
  end else if (SeedType == SeedTypeStateFull) begin : gen_seed_type_state_full
    assign state_seed = seed_state_full_i;
  end else begin : gen_seed_type_state_partial
    
    
    
    
    
    
    
    always_comb begin
      state_seed = !update ? state_q : state_update;
      
      if (last_state_part) begin
        state_seed[StateWidth - 1 -: NumBitsLastPart] = seed_state_partial_i[NumBitsLastPart-1:0];
      end else begin
        state_seed[state_idx_q * PartialSeedWidth +: PartialSeedWidth] = seed_state_partial_i;
      end
    end
  end
  
  
  
  
  
  
  
  assign restore = lockup & (StrictLockupProtection | ~allow_lockup_i);
  assign state_d = restore     ? StateSeed    :
                   wr_en_seed  ? state_seed   :
                   update      ? state_update : state_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin : state_reg
    if (!rst_ni) begin
      state_q <= StateSeed;
    end else begin
      state_q <= state_d;
    end
  end
  
  assign seed_req_d = (seed_en_i | seed_req_q) & (~seed_ack_i | ~last_state_part);
  always_ff @(posedge clk_i or negedge rst_ni) begin : seed_req_reg
    if (!rst_ni) begin
      seed_req_q <= 1'b0;
    end else begin
      seed_req_q <= seed_req_d;
    end
  end
  assign seed_req_o = seed_en_i | seed_req_q;
  if (SeedType == SeedTypeKeyIv) begin : gen_key_iv_seed_handling
    
    
    
    localparam int unsigned NumInitUpdatesFractional = (StateWidth * 4) % OutputWidth != 0 ? 1 : 0;
    localparam int unsigned NumInitUpdates =
        (StateWidth * 4) / OutputWidth + NumInitUpdatesFractional;
    localparam int unsigned LastInitUpdate = NumInitUpdates - 1;
    localparam int unsigned InitUpdatesCtrWidth = prim_util_pkg::vbits(NumInitUpdates);
    logic [InitUpdatesCtrWidth-1:0] init_update_ctr_d, init_update_ctr_q;
    logic init_update_d, init_update_q;
    logic last_init_update;
    
    assign init_update_ctr_d = wr_en_seed    ? '0                       :
                               init_update_q ? init_update_ctr_q + 1'b1 : init_update_ctr_q;
    always_ff @(posedge clk_i or negedge rst_ni) begin : init_update_ctr_reg
      if (!rst_ni) begin
        init_update_ctr_q <= '0;
      end else begin
        init_update_ctr_q <= init_update_ctr_d;
      end
    end
    
    assign last_init_update = init_update_ctr_q == LastInitUpdate[InitUpdatesCtrWidth-1:0];
    assign init_update_d = wr_en_seed       ? 1'b1 :
                           last_init_update ? 1'b0 : init_update_q;
    always_ff @(posedge clk_i or negedge rst_ni) begin : init_update_reg
      if (!rst_ni) begin
        init_update_q <= 1'b0;
      end else begin
        init_update_q <= init_update_d;
      end
    end
    assign update_init = init_update_q;
    
    assign seed_done_o = init_update_q & last_init_update;
    
    assign state_idx_d = '0;
    assign state_idx_q = '0;
    assign last_state_part = 1'b0;
    assign unused_seed = ^{seed_state_full_i,
                           seed_state_partial_i,
                           state_idx_d,
                           state_idx_q,
                           last_state_part};
  end else if (SeedType == SeedTypeStateFull) begin : gen_full_seed_handling
    
    assign seed_done_o = seed_req_o & seed_ack_i;
    
    assign update_init = 1'b0;
    assign state_idx_d = '0;
    assign state_idx_q = '0;
    assign last_state_part = 1'b1;
    assign unused_seed = ^{seed_key_i,
                           seed_iv_i,
                           seed_state_partial_i,
                           state_idx_d,
                           state_idx_q,
                           last_state_part};
  end else begin : gen_partial_seed_handling
    
    
    assign last_state_part = state_idx_q == LastStatePart[StateIdxWidth-1:0];
    assign state_idx_d = wr_en_seed &  last_state_part ? '0                 :
                         wr_en_seed & ~last_state_part ? state_idx_q + 1'b1 : state_idx_q;
    always_ff @(posedge clk_i or negedge rst_ni) begin : state_idx_reg
      if (!rst_ni) begin
        state_idx_q <= '0;
      end else begin
        state_idx_q <= state_idx_d;
      end
    end
    
    assign seed_done_o = seed_req_o & seed_ack_i & last_state_part;
    
    assign update_init = 1'b0;
    assign unused_seed = ^{seed_key_i,
                           seed_iv_i,
                           seed_state_full_i};
  end
  
  
  
  
  
  
  
  
  `ASSERT(PrimTriviumPartialStateSeedWhileUpdate_A,
      (SeedType == SeedTypeStatePartial) && seed_req_o && en_i |-> OutputWidth >= MinNfsrWidth)
endmodule

package prim_trivium_pkg;
  typedef enum integer {
    SeedTypeKeyIv,        
                          
                          
    SeedTypeStateFull,    
    SeedTypeStatePartial  
  } seed_type_e;
  parameter int unsigned KeyIvWidth = 80;
  parameter int unsigned PartialSeedWidthDefault = 32;
  parameter int unsigned MinNfsrWidth = 84;
  
  
  parameter int TriviumLfsrWidth = 288;
  typedef logic [TriviumLfsrWidth-1:0] trivium_lfsr_seed_t;
  parameter trivium_lfsr_seed_t RndCnstTriviumLfsrSeedDefault = {
    32'h758a4420,
    256'h31e1c461_6ea343ec_153282a3_0c132b57_23c5a4cf_4743b3c7_c32d580f_74f1713a
  };
  
  
  
  parameter int unsigned TriviumMaxNfsrWidth = 111;
  parameter int TriviumStateWidth = TriviumLfsrWidth;
  function automatic logic [TriviumStateWidth-1:0] trivium_update_state(
    logic [TriviumStateWidth-1:0] in
  );
    logic [TriviumStateWidth-1:0] out;
    logic mul_90_91, mul_174_175, mul_285_286;
    logic add_65_92, add_161_176, add_242_287;
    
    mul_90_91 = in[90] & in[91];
    add_65_92 = in[65] ^ in[92];
    
    mul_174_175 = in[174] & in[175];
    add_161_176 = in[161] ^ in[176];
    
    mul_285_286 = in[285] & in[286];
    add_242_287 = in[242] ^ in[287];
    
    out[0] = in[68] ^ (mul_285_286 ^ add_242_287);
    out[93] = in[170] ^ (add_65_92 ^ mul_90_91);
    out[177] = in[263] ^ (mul_174_175 ^ add_161_176);
    
    out[92:1] = in[91:0];
    out[176:94] = in[175:93];
    out[287:178] = in[286:177];
    return out;
  endfunction
  function automatic logic trivium_generate_key_stream(
    logic [TriviumStateWidth-1:0] state
  );
    logic key;
    logic add_65_92, add_161_176, add_242_287;
    logic unused_state;
    add_65_92 = state[65] ^ state[92];
    add_161_176 = state[161] ^ state[176];
    add_242_287 = state[242] ^ state[287];
    key = add_161_176 ^ add_65_92 ^ add_242_287;
    unused_state = ^{state[286:243],
                     state[241:177],
                     state[175:162],
                     state[160:93],
                     state[91:66],
                     state[64:0]};
    return key;
  endfunction
  function automatic logic [TriviumStateWidth-1:0] trivium_seed_key_iv(
      logic [KeyIvWidth-1:0] key,
      logic [KeyIvWidth-1:0] iv
    );
    logic [TriviumStateWidth-1:0] state;
    
    state = {3'b111,   112'b0,      iv,  13'b0,   key};
    return state;
  endfunction
  
  
  
  parameter int unsigned BiviumMaxNfsrWidth = 93;
  parameter int BiviumStateWidth = 177;
  function automatic logic [BiviumStateWidth-1:0] bivium_update_state(
    logic [BiviumStateWidth-1:0] in
  );
    logic [BiviumStateWidth-1:0] out;
    logic mul_90_91, mul_174_175;
    logic add_65_92, add_161_176;
    
    mul_90_91 = in[90] & in[91];
    add_65_92 = in[65] ^ in[92];
    
    mul_174_175 = in[174] & in[175];
    add_161_176 = in[161] ^ in[176];
    
    out[0] = in[68] ^ (mul_174_175 ^ add_161_176);
    out[93] = in[170] ^ add_65_92 ^ mul_90_91;
    
    out[92:1] = in[91:0];
    out[176:94] = in[175:93];
    return out;
  endfunction
  function automatic logic bivium_generate_key_stream(
    logic [BiviumStateWidth-1:0] state
  );
    logic key;
    logic add_65_92, add_161_176;
    logic unused_state;
    add_65_92 = state[65] ^ state[92];
    add_161_176 = state[161] ^ state[176];
    key = add_161_176 ^ add_65_92;
    unused_state = ^{state[175:162],
                     state[160:93],
                     state[91:66],
                     state[64:0]};
    return key;
  endfunction
  function automatic logic [BiviumStateWidth-1:0] bivium_seed_key_iv(
      logic [KeyIvWidth-1:0] key,
      logic [KeyIvWidth-1:0] iv
    );
    logic [BiviumStateWidth-1:0] state;
    
    state = {4'b0,      iv,  13'b0,   key};
    return state;
  endfunction
endpackage

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
