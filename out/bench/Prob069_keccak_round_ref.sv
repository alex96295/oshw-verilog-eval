
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
module prim_count
  import prim_count_pkg::*;
#(
  parameter int               Width = 2,
  
  
  parameter logic [Width-1:0] ResetValue = '0,
  
  
  parameter bit               EnableAlertTriggerSVA = 1,
  
  
  
  
  
  
  
  
  parameter action_mask_t     PossibleActions = {$bits(action_mask_t){1'b1}}
) (
  input clk_i,
  input rst_ni,
  input clr_i,
  input set_i,
  input [Width-1:0] set_cnt_i,                 
  input incr_en_i,
  input decr_en_i,
  input [Width-1:0] step_i,                    
  input commit_i,
  output logic [Width-1:0] cnt_o,              
  output logic [Width-1:0] cnt_after_commit_o, 
  output logic err_o
);
  
  
  
  
  localparam int NumCnt = 2;
  localparam logic [NumCnt-1:0][Width-1:0] ResetValues = {{Width{1'b1}} - ResetValue, 
                                                          ResetValue};                
  logic [NumCnt-1:0][Width-1:0] cnt_d, cnt_d_committed, cnt_q;
  
  
  
  
  logic [NumCnt-1:0][Width-1:0] fpv_force;
`ifndef PrimCountFpv
  assign fpv_force = '0;
`endif
  for (genvar k = 0; k < NumCnt; k++) begin : gen_cnts
    
    logic incr_en, decr_en;
    logic [Width-1:0] set_val;
    if (k == 0) begin : gen_up_cnt
      assign incr_en = incr_en_i;
      assign decr_en = decr_en_i;
      assign set_val = set_cnt_i;
    end else begin : gen_dn_cnt
      assign incr_en = decr_en_i;
      assign decr_en = incr_en_i;
      
      assign set_val = {Width{1'b1}} - set_cnt_i;
    end
    
    logic [Width:0] ext_cnt;
    assign ext_cnt = (decr_en) ? {1'b0, cnt_q[k]} - {1'b0, step_i} :
                     (incr_en) ? {1'b0, cnt_q[k]} + {1'b0, step_i} : {1'b0, cnt_q[k]};
    
    logic uflow, oflow;
    assign oflow = incr_en && ext_cnt[Width];
    assign uflow = decr_en && ext_cnt[Width];
    logic [Width-1:0] cnt_sat;
    assign cnt_sat = (uflow) ? '0            :
                     (oflow) ? {Width{1'b1}} : ext_cnt[Width-1:0];
    
    
    logic cnt_en;
    assign cnt_en = (incr_en ^ decr_en) &&
                    ((incr_en && !(&cnt_q[k])) ||
                    (decr_en && !(cnt_q[k] == '0)));
    
    assign cnt_d[k] = (clr_i)  ? ResetValues[k] :
                      (set_i)  ? set_val        :
                      (cnt_en) ? cnt_sat        : cnt_q[k];
    assign cnt_d_committed[k] = commit_i ? cnt_d[k] : cnt_q[k];
    logic [Width-1:0] cnt_unforced_q;
    prim_flop #(
      .Width(Width),
      .ResetValue(ResetValues[k])
    ) u_cnt_flop (
      .clk_i,
      .rst_ni,
      .d_i(cnt_d_committed[k]),
      .q_o(cnt_unforced_q)
    );
    
    assign cnt_q[k] = fpv_force[k] + cnt_unforced_q;
  end
  
  logic [Width:0] sum;
  assign sum = (cnt_q[0] + cnt_q[1]);
  
  logic err_d, err_q;
  assign err_d = (sum != {1'b0, {Width{1'b1}}});
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      err_q <= 1'b0;
    end else begin
      err_q <= err_d;
    end
  end
  assign err_o = err_q;
  
  assign cnt_o              = cnt_q[0];
  assign cnt_after_commit_o = cnt_d[0];
  
  
  
`ifdef INC_ASSERT
  
  
  
  
  
  logic fpv_err_present;
  assign fpv_err_present = |fpv_force;
  
  function automatic logic signed [Width+1:0] max(logic signed [Width+1:0] a,
                                                  logic signed [Width+1:0] b);
    return (a > b) ? a : b;
  endfunction
  function automatic logic signed [Width+1:0] min(logic signed [Width+1:0] a,
                                                  logic signed [Width+1:0] b);
    return (a < b) ? a : b;
  endfunction
  
  
  if (!(PossibleActions & Clr)) begin : g_check_no_clr
    `ASSERT(ClrNeverTrue_A, clr_i !== 1'b1)
  end
  if (!(PossibleActions & Set)) begin : g_check_no_set
    `ASSERT(SetNeverTrue_A, set_i !== 1'b1)
  end
  if (!(PossibleActions & Incr)) begin : g_check_no_incr
    `ASSERT(IncrNeverTrue_A, incr_en_i !== 1'b1)
  end
  if (!(PossibleActions & Decr)) begin : g_check_no_decr
    `ASSERT(DecrNeverTrue_A, decr_en_i !== 1'b1)
  end
  
  `ASSERT(CntNext_A,
      rst_ni
      |=>
      $past(!commit_i) || (cnt_o == $past(cnt_after_commit_o)),
      clk_i, err_d || fpv_err_present || !rst_ni)
  
  if (PossibleActions & Clr) begin : g_check_clr_fwd_a
    `ASSERT(ClrFwd_A,
            rst_ni && commit_i && clr_i
            |=>
            (cnt_o == ResetValue) &&
            (cnt_q[1] == ({Width{1'b1}} - ResetValue)),
            clk_i, err_d || fpv_err_present || !rst_ni)
  end
  
  if (PossibleActions & Set) begin : g_check_set_fwd_a
    `ASSERT(SetFwd_A,
        rst_ni && commit_i && set_i && !clr_i
        |=>
        (cnt_o == $past(set_cnt_i)) &&
        (cnt_q[1] == ({Width{1'b1}} - $past(set_cnt_i))),
        clk_i, err_d || fpv_err_present || !rst_ni)
  end
  
  if ((PossibleActions & Incr) && (PossibleActions & Decr)) begin : g_check_inc_and_dec
    `ASSERT(IncrDecrUpDnCnt_A,
        rst_ni && incr_en_i && decr_en_i && !(clr_i || set_i)
        |=>
        $stable(cnt_o) && $stable(cnt_q[1]),
        clk_i, err_d || fpv_err_present || !rst_ni)
  end
  
  if ((PossibleActions & Incr)) begin : g_check_incr
    `ASSERT(IncrUpCnt_A,
        rst_ni && incr_en_i && !(clr_i || set_i || decr_en_i) && commit_i
        |=>
        cnt_o == min($past(cnt_o) + $past({2'b0, step_i}), {2'b0, {Width{1'b1}}}),
        clk_i, err_d || fpv_err_present || !rst_ni)
    `ASSERT(IncrDnCnt_A,
        rst_ni && incr_en_i && !(clr_i || set_i || decr_en_i) && commit_i
        |=>
        cnt_q[1] == max($past(signed'({2'b0, cnt_q[1]})) - $past({2'b0, step_i}), '0),
        clk_i, err_d || fpv_err_present || !rst_ni)
    `ASSERT(UpCntIncrStable_A,
        incr_en_i && !(clr_i || set_i || decr_en_i) &&
        cnt_o == {Width{1'b1}}
        |=>
        $stable(cnt_o),
        clk_i, err_d || fpv_err_present || !rst_ni)
    `ASSERT(DnCntIncrStable_A,
        rst_ni && incr_en_i && !(clr_i || set_i || decr_en_i) &&
        cnt_q[1] == '0
        |=>
        $stable(cnt_q[1]),
        clk_i, err_d || fpv_err_present || !rst_ni)
  end
  
  if ((PossibleActions & Decr)) begin : g_check_decr
    `ASSERT(DecrUpCnt_A,
        rst_ni && decr_en_i && !(clr_i || set_i || incr_en_i) && commit_i
        |=>
        cnt_o == max($past(signed'({2'b0, cnt_o})) - $past({2'b0, step_i}), '0),
        clk_i, err_d || fpv_err_present || !rst_ni)
    `ASSERT(DecrDnCnt_A,
        rst_ni && decr_en_i && !(clr_i || set_i || incr_en_i) && commit_i
        |=>
        cnt_q[1] == min($past(cnt_q[1]) + $past({2'b0, step_i}), {2'b0, {Width{1'b1}}}),
        clk_i, err_d || fpv_err_present || !rst_ni)
    `ASSERT(UpCntDecrStable_A,
        decr_en_i && !(clr_i || set_i || incr_en_i) &&
        cnt_o == '0
        |=>
        $stable(cnt_o),
        clk_i, err_d || fpv_err_present || !rst_ni)
    `ASSERT(DnCntDecrStable_A,
        rst_ni && decr_en_i && !(clr_i || set_i || incr_en_i) &&
        cnt_q[1] == {Width{1'b1}}
        |=>
        $stable(cnt_q[1]),
        clk_i, err_d || fpv_err_present || !rst_ni)
  end
  
  
  `ASSERT(ChangeBackward_A,
          rst_ni ##1 $changed(cnt_o) && $changed(cnt_q[1])
          |->
          $past(clr_i || set_i || (commit_i && (incr_en_i || decr_en_i))),
          clk_i, err_d || fpv_err_present || !rst_ni)
  
  
  
  
  
  `ASSERT(CntErrReported_A, ##1 $past((cnt_q[1] + cnt_q[0]) != {Width{1'b1}}) == err_o)
 `ifdef PrimCountFpv
  `COVER(CntErr_C, err_o)`endif
  
  
  
  logic unused_assert_connected;
  `ASSERT_INIT_NET(AssertConnected_A, unused_assert_connected === 1'b1 || !EnableAlertTriggerSVA)
`endif
endmodule 

package prim_count_pkg;
  
  
  typedef logic [3:0] action_mask_t;
  typedef enum action_mask_t {Clr  = 4'h1,
                              Set  = 4'h2,
                              Incr = 4'h4,
                              Decr = 4'h8} action_e;
endpackage : prim_count_pkg

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
module prim_dom_and_2share #(
  parameter int DW = 64, 
  parameter bit Pipeline = 1'b0 
) (
  input clk_i,
  input rst_ni,
  input [DW-1:0] a0_i, 
  input [DW-1:0] a1_i, 
  input [DW-1:0] b0_i, 
  input [DW-1:0] b1_i, 
  input          z_valid_i, 
  input [DW-1:0] z_i,  
  output logic [DW-1:0] q0_o, 
  output logic [DW-1:0] q1_o, 
  output logic [DW-1:0] prd_o 
);
  logic [DW-1:0] t0_d, t0_q, t1_d, t1_q;
  logic [DW-1:0] t_a0b0, t_a1b1;
  logic [DW-1:0] t_a0b0_d, t_a1b1_d;
  logic [DW-1:0] t_a0b1, t_a1b0;
  
  
  
  
  assign t_a0b0_d = a0_i & b0_i;
  assign t_a1b1_d = a1_i & b1_i;
  
  assign t_a0b1 = a0_i & b1_i;
  assign t_a1b0 = a1_i & b0_i;
  
  
  
  
  
  prim_xor2 #(
    .Width ( DW*2 )
  ) u_prim_xor_t01 (
    .in0_i ( {t_a0b1, t_a1b0} ),
    .in1_i ( {z_i,    z_i}    ),
    .out_o ( {t0_d,   t1_d}   )
  );
  
  prim_flop_en #(
    .Width      ( DW*2 ),
    .ResetValue ( '0   )
  ) u_prim_flop_t01 (
    .clk_i  ( clk_i        ),
    .rst_ni ( rst_ni       ),
    .en_i   ( z_valid_i    ),
    .d_i    ( {t0_d, t1_d} ),
    .q_o    ( {t0_q, t1_q} )
  );
  
  
  
  if (Pipeline == 1'b1) begin : gen_inner_domain_regs
    
    
    
    logic [DW-1:0] t_a0b0_q, t_a1b1_q;
    prim_flop_en #(
      .Width      ( DW*2 ),
      .ResetValue ( '0   )
    ) u_prim_flop_tab01 (
      .clk_i  ( clk_i                ),
      .rst_ni ( rst_ni               ),
      .en_i   ( z_valid_i            ),
      .d_i    ( {t_a0b0_d, t_a1b1_d} ),
      .q_o    ( {t_a0b0_q, t_a1b1_q} )
    );
    assign t_a0b0 = t_a0b0_q;
    assign t_a1b1 = t_a1b1_q;
  end else begin : gen_no_inner_domain_regs
    
    
    
    
    assign t_a0b0 = t_a0b0_d;
    assign t_a1b1 = t_a1b1_d;
  end
  
  
  
  
  prim_xor2 #(
    .Width ( DW*2 )
  ) u_prim_xor_q01 (
    .in0_i ( {t_a0b0, t_a1b1} ),
    .in1_i ( {t0_q,   t1_q}   ),
    .out_o ( {q0_o,   q1_o}   )
  );
  
  
  
  
  
  
  assign prd_o = t1_q;
  
  
  
  
  
  
  
  
  `ASSUME_FPV(RandomReadyInShortTime_A,
    $changed(a0_i) || $changed(a1_i) || $changed(b0_i) || $changed(b1_i)
      |-> ##[0:2] z_valid_i,
    clk_i, !rst_ni)
  if (Pipeline == 0) begin: g_assert_stable
    
    
    
    `ASSUME(StableTwoCycles_M,
      ($changed(a0_i)  || $changed(a1_i) || $changed(b0_i) || $changed(b1_i))
        ##[0:$] z_valid_i |=>
        $stable(a0_i) && $stable(a1_i) && $stable(b0_i) && $stable(b1_i))
  end
  `ASSERT(UnmaskedAndMatched_A,
    z_valid_i |=> (q0_o ^ q1_o) ==
      (($past(a0_i) ^ $past(a1_i)) & ($past(b0_i) ^ $past(b1_i))),
    clk_i, !rst_ni)
endmodule

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
package prim_mubi_pkg;
  
  
  
  parameter int MuBi4Width = 4;
  typedef enum logic [MuBi4Width-1:0] {
    MuBi4True = 4'h6, 
    MuBi4False = 4'h9  
  } mubi4_t;
  
  `ASSERT_STATIC_IN_PACKAGE(CheckMuBi4ValsComplementary_A, MuBi4True == ~MuBi4False)
  
  function automatic logic mubi4_test_invalid(mubi4_t val);
    return ~(val inside {MuBi4True, MuBi4False});
  endfunction : mubi4_test_invalid
  
  function automatic mubi4_t mubi4_bool_to_mubi(logic val);
    return (val ? MuBi4True : MuBi4False);
  endfunction : mubi4_bool_to_mubi
  
  
  
  function automatic logic mubi4_test_true_strict(mubi4_t val);
    return MuBi4True == val;
  endfunction : mubi4_test_true_strict
  
  
  
  function automatic logic mubi4_logic_test_true_strict(logic [3:0] val);
    return MuBi4True == val;
  endfunction : mubi4_logic_test_true_strict
  
  
  
  function automatic logic mubi4_test_false_strict(mubi4_t val);
    return MuBi4False == val;
  endfunction : mubi4_test_false_strict
  
  
  
  function automatic logic mubi4_test_true_loose(mubi4_t val);
    return MuBi4False != val;
  endfunction : mubi4_test_true_loose
  
  
  
  function automatic logic mubi4_test_false_loose(mubi4_t val);
    return MuBi4True != val;
  endfunction : mubi4_test_false_loose
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi4_t mubi4_or(mubi4_t a, mubi4_t b, mubi4_t act);
    logic [MuBi4Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi4Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi4_t'(out);
  endfunction : mubi4_or
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi4_t mubi4_and(mubi4_t a, mubi4_t b, mubi4_t act);
    logic [MuBi4Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi4Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi4_t'(out);
  endfunction : mubi4_and
  
  
  
  function automatic mubi4_t mubi4_or_hi(mubi4_t a, mubi4_t b);
    return mubi4_or(a, b, MuBi4True);
  endfunction : mubi4_or_hi
  
  
  
  function automatic mubi4_t mubi4_and_hi(mubi4_t a, mubi4_t b);
    return mubi4_and(a, b, MuBi4True);
  endfunction : mubi4_and_hi
  
  
  
  function automatic mubi4_t mubi4_or_lo(mubi4_t a, mubi4_t b);
    return mubi4_or(a, b, MuBi4False);
  endfunction : mubi4_or_lo
  
  
  
  function automatic mubi4_t mubi4_and_lo(mubi4_t a, mubi4_t b);
    return mubi4_and(a, b, MuBi4False);
  endfunction : mubi4_and_lo
  
  
  
  parameter int MuBi8Width = 8;
  typedef enum logic [MuBi8Width-1:0] {
    MuBi8True = 8'h96, 
    MuBi8False = 8'h69  
  } mubi8_t;
  
  `ASSERT_STATIC_IN_PACKAGE(CheckMuBi8ValsComplementary_A, MuBi8True == ~MuBi8False)
  
  function automatic logic mubi8_test_invalid(mubi8_t val);
    return ~(val inside {MuBi8True, MuBi8False});
  endfunction : mubi8_test_invalid
  
  function automatic mubi8_t mubi8_bool_to_mubi(logic val);
    return (val ? MuBi8True : MuBi8False);
  endfunction : mubi8_bool_to_mubi
  
  
  
  function automatic logic mubi8_test_true_strict(mubi8_t val);
    return MuBi8True == val;
  endfunction : mubi8_test_true_strict
  
  
  
  function automatic logic mubi8_logic_test_true_strict(logic [7:0] val);
    return MuBi8True == val;
  endfunction : mubi8_logic_test_true_strict
  
  
  
  function automatic logic mubi8_test_false_strict(mubi8_t val);
    return MuBi8False == val;
  endfunction : mubi8_test_false_strict
  
  
  
  function automatic logic mubi8_test_true_loose(mubi8_t val);
    return MuBi8False != val;
  endfunction : mubi8_test_true_loose
  
  
  
  function automatic logic mubi8_test_false_loose(mubi8_t val);
    return MuBi8True != val;
  endfunction : mubi8_test_false_loose
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi8_t mubi8_or(mubi8_t a, mubi8_t b, mubi8_t act);
    logic [MuBi8Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi8Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi8_t'(out);
  endfunction : mubi8_or
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi8_t mubi8_and(mubi8_t a, mubi8_t b, mubi8_t act);
    logic [MuBi8Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi8Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi8_t'(out);
  endfunction : mubi8_and
  
  
  
  function automatic mubi8_t mubi8_or_hi(mubi8_t a, mubi8_t b);
    return mubi8_or(a, b, MuBi8True);
  endfunction : mubi8_or_hi
  
  
  
  function automatic mubi8_t mubi8_and_hi(mubi8_t a, mubi8_t b);
    return mubi8_and(a, b, MuBi8True);
  endfunction : mubi8_and_hi
  
  
  
  function automatic mubi8_t mubi8_or_lo(mubi8_t a, mubi8_t b);
    return mubi8_or(a, b, MuBi8False);
  endfunction : mubi8_or_lo
  
  
  
  function automatic mubi8_t mubi8_and_lo(mubi8_t a, mubi8_t b);
    return mubi8_and(a, b, MuBi8False);
  endfunction : mubi8_and_lo
  
  
  
  parameter int MuBi12Width = 12;
  typedef enum logic [MuBi12Width-1:0] {
    MuBi12True = 12'h696, 
    MuBi12False = 12'h969  
  } mubi12_t;
  
  `ASSERT_STATIC_IN_PACKAGE(CheckMuBi12ValsComplementary_A, MuBi12True == ~MuBi12False)
  
  function automatic logic mubi12_test_invalid(mubi12_t val);
    return ~(val inside {MuBi12True, MuBi12False});
  endfunction : mubi12_test_invalid
  
  function automatic mubi12_t mubi12_bool_to_mubi(logic val);
    return (val ? MuBi12True : MuBi12False);
  endfunction : mubi12_bool_to_mubi
  
  
  
  function automatic logic mubi12_test_true_strict(mubi12_t val);
    return MuBi12True == val;
  endfunction : mubi12_test_true_strict
  
  
  
  function automatic logic mubi12_logic_test_true_strict(logic [11:0] val);
    return MuBi12True == val;
  endfunction : mubi12_logic_test_true_strict
  
  
  
  function automatic logic mubi12_test_false_strict(mubi12_t val);
    return MuBi12False == val;
  endfunction : mubi12_test_false_strict
  
  
  
  function automatic logic mubi12_test_true_loose(mubi12_t val);
    return MuBi12False != val;
  endfunction : mubi12_test_true_loose
  
  
  
  function automatic logic mubi12_test_false_loose(mubi12_t val);
    return MuBi12True != val;
  endfunction : mubi12_test_false_loose
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi12_t mubi12_or(mubi12_t a, mubi12_t b, mubi12_t act);
    logic [MuBi12Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi12Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi12_t'(out);
  endfunction : mubi12_or
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi12_t mubi12_and(mubi12_t a, mubi12_t b, mubi12_t act);
    logic [MuBi12Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi12Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi12_t'(out);
  endfunction : mubi12_and
  
  
  
  function automatic mubi12_t mubi12_or_hi(mubi12_t a, mubi12_t b);
    return mubi12_or(a, b, MuBi12True);
  endfunction : mubi12_or_hi
  
  
  
  function automatic mubi12_t mubi12_and_hi(mubi12_t a, mubi12_t b);
    return mubi12_and(a, b, MuBi12True);
  endfunction : mubi12_and_hi
  
  
  
  function automatic mubi12_t mubi12_or_lo(mubi12_t a, mubi12_t b);
    return mubi12_or(a, b, MuBi12False);
  endfunction : mubi12_or_lo
  
  
  
  function automatic mubi12_t mubi12_and_lo(mubi12_t a, mubi12_t b);
    return mubi12_and(a, b, MuBi12False);
  endfunction : mubi12_and_lo
  
  
  
  parameter int MuBi16Width = 16;
  typedef enum logic [MuBi16Width-1:0] {
    MuBi16True = 16'h9696, 
    MuBi16False = 16'h6969  
  } mubi16_t;
  
  `ASSERT_STATIC_IN_PACKAGE(CheckMuBi16ValsComplementary_A, MuBi16True == ~MuBi16False)
  
  function automatic logic mubi16_test_invalid(mubi16_t val);
    return ~(val inside {MuBi16True, MuBi16False});
  endfunction : mubi16_test_invalid
  
  function automatic mubi16_t mubi16_bool_to_mubi(logic val);
    return (val ? MuBi16True : MuBi16False);
  endfunction : mubi16_bool_to_mubi
  
  
  
  function automatic logic mubi16_test_true_strict(mubi16_t val);
    return MuBi16True == val;
  endfunction : mubi16_test_true_strict
  
  
  
  function automatic logic mubi16_logic_test_true_strict(logic [15:0] val);
    return MuBi16True == val;
  endfunction : mubi16_logic_test_true_strict
  
  
  
  function automatic logic mubi16_test_false_strict(mubi16_t val);
    return MuBi16False == val;
  endfunction : mubi16_test_false_strict
  
  
  
  function automatic logic mubi16_test_true_loose(mubi16_t val);
    return MuBi16False != val;
  endfunction : mubi16_test_true_loose
  
  
  
  function automatic logic mubi16_test_false_loose(mubi16_t val);
    return MuBi16True != val;
  endfunction : mubi16_test_false_loose
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi16_t mubi16_or(mubi16_t a, mubi16_t b, mubi16_t act);
    logic [MuBi16Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi16Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi16_t'(out);
  endfunction : mubi16_or
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi16_t mubi16_and(mubi16_t a, mubi16_t b, mubi16_t act);
    logic [MuBi16Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi16Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi16_t'(out);
  endfunction : mubi16_and
  
  
  
  function automatic mubi16_t mubi16_or_hi(mubi16_t a, mubi16_t b);
    return mubi16_or(a, b, MuBi16True);
  endfunction : mubi16_or_hi
  
  
  
  function automatic mubi16_t mubi16_and_hi(mubi16_t a, mubi16_t b);
    return mubi16_and(a, b, MuBi16True);
  endfunction : mubi16_and_hi
  
  
  
  function automatic mubi16_t mubi16_or_lo(mubi16_t a, mubi16_t b);
    return mubi16_or(a, b, MuBi16False);
  endfunction : mubi16_or_lo
  
  
  
  function automatic mubi16_t mubi16_and_lo(mubi16_t a, mubi16_t b);
    return mubi16_and(a, b, MuBi16False);
  endfunction : mubi16_and_lo
  
  
  
  parameter int MuBi20Width = 20;
  typedef enum logic [MuBi20Width-1:0] {
    MuBi20True = 20'h69696, 
    MuBi20False = 20'h96969  
  } mubi20_t;
  
  `ASSERT_STATIC_IN_PACKAGE(CheckMuBi20ValsComplementary_A, MuBi20True == ~MuBi20False)
  
  function automatic logic mubi20_test_invalid(mubi20_t val);
    return ~(val inside {MuBi20True, MuBi20False});
  endfunction : mubi20_test_invalid
  
  function automatic mubi20_t mubi20_bool_to_mubi(logic val);
    return (val ? MuBi20True : MuBi20False);
  endfunction : mubi20_bool_to_mubi
  
  
  
  function automatic logic mubi20_test_true_strict(mubi20_t val);
    return MuBi20True == val;
  endfunction : mubi20_test_true_strict
  
  
  
  function automatic logic mubi20_logic_test_true_strict(logic [19:0] val);
    return MuBi20True == val;
  endfunction : mubi20_logic_test_true_strict
  
  
  
  function automatic logic mubi20_test_false_strict(mubi20_t val);
    return MuBi20False == val;
  endfunction : mubi20_test_false_strict
  
  
  
  function automatic logic mubi20_test_true_loose(mubi20_t val);
    return MuBi20False != val;
  endfunction : mubi20_test_true_loose
  
  
  
  function automatic logic mubi20_test_false_loose(mubi20_t val);
    return MuBi20True != val;
  endfunction : mubi20_test_false_loose
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi20_t mubi20_or(mubi20_t a, mubi20_t b, mubi20_t act);
    logic [MuBi20Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi20Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi20_t'(out);
  endfunction : mubi20_or
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi20_t mubi20_and(mubi20_t a, mubi20_t b, mubi20_t act);
    logic [MuBi20Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi20Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi20_t'(out);
  endfunction : mubi20_and
  
  
  
  function automatic mubi20_t mubi20_or_hi(mubi20_t a, mubi20_t b);
    return mubi20_or(a, b, MuBi20True);
  endfunction : mubi20_or_hi
  
  
  
  function automatic mubi20_t mubi20_and_hi(mubi20_t a, mubi20_t b);
    return mubi20_and(a, b, MuBi20True);
  endfunction : mubi20_and_hi
  
  
  
  function automatic mubi20_t mubi20_or_lo(mubi20_t a, mubi20_t b);
    return mubi20_or(a, b, MuBi20False);
  endfunction : mubi20_or_lo
  
  
  
  function automatic mubi20_t mubi20_and_lo(mubi20_t a, mubi20_t b);
    return mubi20_and(a, b, MuBi20False);
  endfunction : mubi20_and_lo
  
  
  
  parameter int MuBi24Width = 24;
  typedef enum logic [MuBi24Width-1:0] {
    MuBi24True = 24'h969696, 
    MuBi24False = 24'h696969  
  } mubi24_t;
  
  `ASSERT_STATIC_IN_PACKAGE(CheckMuBi24ValsComplementary_A, MuBi24True == ~MuBi24False)
  
  function automatic logic mubi24_test_invalid(mubi24_t val);
    return ~(val inside {MuBi24True, MuBi24False});
  endfunction : mubi24_test_invalid
  
  function automatic mubi24_t mubi24_bool_to_mubi(logic val);
    return (val ? MuBi24True : MuBi24False);
  endfunction : mubi24_bool_to_mubi
  
  
  
  function automatic logic mubi24_test_true_strict(mubi24_t val);
    return MuBi24True == val;
  endfunction : mubi24_test_true_strict
  
  
  
  function automatic logic mubi24_logic_test_true_strict(logic [23:0] val);
    return MuBi24True == val;
  endfunction : mubi24_logic_test_true_strict
  
  
  
  function automatic logic mubi24_test_false_strict(mubi24_t val);
    return MuBi24False == val;
  endfunction : mubi24_test_false_strict
  
  
  
  function automatic logic mubi24_test_true_loose(mubi24_t val);
    return MuBi24False != val;
  endfunction : mubi24_test_true_loose
  
  
  
  function automatic logic mubi24_test_false_loose(mubi24_t val);
    return MuBi24True != val;
  endfunction : mubi24_test_false_loose
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi24_t mubi24_or(mubi24_t a, mubi24_t b, mubi24_t act);
    logic [MuBi24Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi24Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi24_t'(out);
  endfunction : mubi24_or
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi24_t mubi24_and(mubi24_t a, mubi24_t b, mubi24_t act);
    logic [MuBi24Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi24Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi24_t'(out);
  endfunction : mubi24_and
  
  
  
  function automatic mubi24_t mubi24_or_hi(mubi24_t a, mubi24_t b);
    return mubi24_or(a, b, MuBi24True);
  endfunction : mubi24_or_hi
  
  
  
  function automatic mubi24_t mubi24_and_hi(mubi24_t a, mubi24_t b);
    return mubi24_and(a, b, MuBi24True);
  endfunction : mubi24_and_hi
  
  
  
  function automatic mubi24_t mubi24_or_lo(mubi24_t a, mubi24_t b);
    return mubi24_or(a, b, MuBi24False);
  endfunction : mubi24_or_lo
  
  
  
  function automatic mubi24_t mubi24_and_lo(mubi24_t a, mubi24_t b);
    return mubi24_and(a, b, MuBi24False);
  endfunction : mubi24_and_lo
  
  
  
  parameter int MuBi28Width = 28;
  typedef enum logic [MuBi28Width-1:0] {
    MuBi28True = 28'h6969696, 
    MuBi28False = 28'h9696969  
  } mubi28_t;
  
  `ASSERT_STATIC_IN_PACKAGE(CheckMuBi28ValsComplementary_A, MuBi28True == ~MuBi28False)
  
  function automatic logic mubi28_test_invalid(mubi28_t val);
    return ~(val inside {MuBi28True, MuBi28False});
  endfunction : mubi28_test_invalid
  
  function automatic mubi28_t mubi28_bool_to_mubi(logic val);
    return (val ? MuBi28True : MuBi28False);
  endfunction : mubi28_bool_to_mubi
  
  
  
  function automatic logic mubi28_test_true_strict(mubi28_t val);
    return MuBi28True == val;
  endfunction : mubi28_test_true_strict
  
  
  
  function automatic logic mubi28_logic_test_true_strict(logic [27:0] val);
    return MuBi28True == val;
  endfunction : mubi28_logic_test_true_strict
  
  
  
  function automatic logic mubi28_test_false_strict(mubi28_t val);
    return MuBi28False == val;
  endfunction : mubi28_test_false_strict
  
  
  
  function automatic logic mubi28_test_true_loose(mubi28_t val);
    return MuBi28False != val;
  endfunction : mubi28_test_true_loose
  
  
  
  function automatic logic mubi28_test_false_loose(mubi28_t val);
    return MuBi28True != val;
  endfunction : mubi28_test_false_loose
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi28_t mubi28_or(mubi28_t a, mubi28_t b, mubi28_t act);
    logic [MuBi28Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi28Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi28_t'(out);
  endfunction : mubi28_or
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi28_t mubi28_and(mubi28_t a, mubi28_t b, mubi28_t act);
    logic [MuBi28Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi28Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi28_t'(out);
  endfunction : mubi28_and
  
  
  
  function automatic mubi28_t mubi28_or_hi(mubi28_t a, mubi28_t b);
    return mubi28_or(a, b, MuBi28True);
  endfunction : mubi28_or_hi
  
  
  
  function automatic mubi28_t mubi28_and_hi(mubi28_t a, mubi28_t b);
    return mubi28_and(a, b, MuBi28True);
  endfunction : mubi28_and_hi
  
  
  
  function automatic mubi28_t mubi28_or_lo(mubi28_t a, mubi28_t b);
    return mubi28_or(a, b, MuBi28False);
  endfunction : mubi28_or_lo
  
  
  
  function automatic mubi28_t mubi28_and_lo(mubi28_t a, mubi28_t b);
    return mubi28_and(a, b, MuBi28False);
  endfunction : mubi28_and_lo
  
  
  
  parameter int MuBi32Width = 32;
  typedef enum logic [MuBi32Width-1:0] {
    MuBi32True = 32'h96969696, 
    MuBi32False = 32'h69696969  
  } mubi32_t;
  
  `ASSERT_STATIC_IN_PACKAGE(CheckMuBi32ValsComplementary_A, MuBi32True == ~MuBi32False)
  
  function automatic logic mubi32_test_invalid(mubi32_t val);
    return ~(val inside {MuBi32True, MuBi32False});
  endfunction : mubi32_test_invalid
  
  function automatic mubi32_t mubi32_bool_to_mubi(logic val);
    return (val ? MuBi32True : MuBi32False);
  endfunction : mubi32_bool_to_mubi
  
  
  
  function automatic logic mubi32_test_true_strict(mubi32_t val);
    return MuBi32True == val;
  endfunction : mubi32_test_true_strict
  
  
  
  function automatic logic mubi32_logic_test_true_strict(logic [31:0] val);
    return MuBi32True == val;
  endfunction : mubi32_logic_test_true_strict
  
  
  
  function automatic logic mubi32_test_false_strict(mubi32_t val);
    return MuBi32False == val;
  endfunction : mubi32_test_false_strict
  
  
  
  function automatic logic mubi32_test_true_loose(mubi32_t val);
    return MuBi32False != val;
  endfunction : mubi32_test_true_loose
  
  
  
  function automatic logic mubi32_test_false_loose(mubi32_t val);
    return MuBi32True != val;
  endfunction : mubi32_test_false_loose
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi32_t mubi32_or(mubi32_t a, mubi32_t b, mubi32_t act);
    logic [MuBi32Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi32Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return mubi32_t'(out);
  endfunction : mubi32_or
  
  
  
  
  
  
  
  
  
  
  
  function automatic mubi32_t mubi32_and(mubi32_t a, mubi32_t b, mubi32_t act);
    logic [MuBi32Width-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < MuBi32Width; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return mubi32_t'(out);
  endfunction : mubi32_and
  
  
  
  function automatic mubi32_t mubi32_or_hi(mubi32_t a, mubi32_t b);
    return mubi32_or(a, b, MuBi32True);
  endfunction : mubi32_or_hi
  
  
  
  function automatic mubi32_t mubi32_and_hi(mubi32_t a, mubi32_t b);
    return mubi32_and(a, b, MuBi32True);
  endfunction : mubi32_and_hi
  
  
  
  function automatic mubi32_t mubi32_or_lo(mubi32_t a, mubi32_t b);
    return mubi32_or(a, b, MuBi32False);
  endfunction : mubi32_or_lo
  
  
  
  function automatic mubi32_t mubi32_and_lo(mubi32_t a, mubi32_t b);
    return mubi32_and(a, b, MuBi32False);
  endfunction : mubi32_and_lo
endpackage : prim_mubi_pkg

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
module prim_sec_anchor_buf #(
  parameter int Width = 1
) (
  input        [Width-1:0] in_i,
  output logic [Width-1:0] out_o
);
  prim_buf #(
    .Width(Width)
  ) u_secure_anchor_buf (
    .in_i,
    .out_o
  );
endmodule

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
module prim_sparse_fsm_flop #(
  parameter int               Width      = 1,
  parameter type              StateEnumT = logic [Width-1:0],
  parameter logic [Width-1:0] ResetValue = '0,
  
  
  parameter bit               EnableAlertTriggerSVA = 1
`ifdef SIMULATION
  ,
  
  
  
  parameter string            CustomForceName = ""`endif
) (
  input             clk_i,
  input             rst_ni,
  input  StateEnumT state_i,
  output StateEnumT state_o
);
  logic unused_err_o;
  logic [Width-1:0] state_raw;
  prim_flop #(
    .Width(Width),
    .ResetValue(ResetValue)
  ) u_state_flop (
    .clk_i,
    .rst_ni,
    .d_i(state_i),
    .q_o(state_raw)
  );
  assign state_o = StateEnumT'(state_raw);
  `ifdef INC_ASSERT
  assign unused_err_o = is_undefined_state(state_o);
  function automatic logic is_undefined_state(StateEnumT sig);
    
    logic is_defined = 1'b0;
    for (int i = 0, StateEnumT t = t.first(); i < t.num(); i += 1, t = t.next()) begin
      is_defined |= (sig === t);
    end
    return ~is_defined;
  endfunction
  `else
    assign unused_err_o = 1'b0;`endif
  
  
  
  `ifdef INC_ASSERT
  logic unused_assert_connected;
  `ASSERT_INIT_NET(AssertConnected_A, unused_assert_connected === 1'b1 || !EnableAlertTriggerSVA)
  `endif
endmodule

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
package lc_ctrl_pkg;
  import prim_util_pkg::vbits;
  import lc_ctrl_state_pkg::*;
  
  typedef struct packed {
    logic lc_init;
  } pwr_lc_req_t;
  
  typedef struct packed {
    logic lc_done;
    logic lc_idle;
  } pwr_lc_rsp_t;
  
  parameter pwr_lc_rsp_t PWR_LC_RSP_DEFAULT = '{
    lc_done: 1'b1,
    lc_idle: 1'b1
  };
  
  
  
  parameter int NumTokens = 6;
  parameter int TokenIdxWidth = vbits(NumTokens);
  typedef enum logic [TokenIdxWidth-1:0] {
    
    
    ZeroTokenIdx       = 3'h0,
    RawUnlockTokenIdx  = 3'h1,
    TestUnlockTokenIdx = 3'h2,
    TestExitTokenIdx   = 3'h3,
    RmaTokenIdx        = 3'h4,
    
    
    InvalidTokenIdx    = 3'h5
  } token_idx_e;
  parameter int TokenMuxBits = 2**TokenIdxWidth*LcTokenWidth;
  typedef logic [TokenMuxBits-1:0] lc_token_mux_t;
  
  
  
  parameter int TxWidth = 4;
  
  
  typedef enum logic [TxWidth-1:0] {
    On  = 4'b0101,
    Off = 4'b1010
  } lc_tx_t;
  parameter lc_tx_t LC_TX_DEFAULT = lc_tx_t'(Off);
  parameter int RmaSeedWidth = 32;
  typedef logic [RmaSeedWidth-1:0] lc_nvm_rma_seed_t;
  parameter lc_nvm_rma_seed_t LC_NVM_RMA_SEED_DEFAULT = '0;
  parameter int LcKeymgrDivWidth = 128;
  typedef logic [LcKeymgrDivWidth-1:0] lc_keymgr_div_t;
  typedef struct packed {
    logic [lc_ctrl_reg_pkg::SiliconCreatorIdWidth-1:0] silicon_creator_id;
    logic [lc_ctrl_reg_pkg::ProductIdWidth-1:0]        product_id;
    logic [lc_ctrl_reg_pkg::RevisionIdWidth-1:0]       revision_id;
    logic [32-lc_ctrl_reg_pkg::RevisionIdWidth-1:0]    reserved;
  } lc_hw_rev_t;
  
  
  
  
  `ASSERT_STATIC_IN_PACKAGE(CheckLcTxValsComplementary_A, On == ~Off)
  
  `ASSERT_STATIC_IN_PACKAGE(LcMuBiWidthCheck_A, $bits(TxWidth) == $bits(prim_mubi_pkg::MuBi4Width))
  
  
  
  
  
  
  
  
  
  
  
  function automatic prim_mubi_pkg::mubi4_t lc_to_mubi4(lc_tx_t val);
    return prim_mubi_pkg::mubi4_t'(val ^ (On ^ prim_mubi_pkg::MuBi4True));
  endfunction : lc_to_mubi4
  
  
  function automatic prim_mubi_pkg::mubi4_t lc_to_mubi4_inv(lc_tx_t val);
    return prim_mubi_pkg::mubi4_t'(val ^ (Off ^ prim_mubi_pkg::MuBi4True));
  endfunction : lc_to_mubi4_inv
  
  function automatic prim_mubi_pkg::mubi8_t lc_to_mubi8(lc_tx_t val);
    return prim_mubi_pkg::mubi8_t'({
      lc_to_mubi4_inv(val),
      lc_to_mubi4(val)
    });
  endfunction : lc_to_mubi8
  function automatic lc_tx_t mubi4_to_lc(prim_mubi_pkg::mubi4_t val);
    return lc_tx_t'(val ^ (prim_mubi_pkg::MuBi4True ^ On));
  endfunction : mubi4_to_lc
  
  
  function automatic lc_tx_t mubi4_to_lc_inv(prim_mubi_pkg::mubi4_t val);
    return lc_tx_t'(val ^ (prim_mubi_pkg::MuBi4True ^ Off));
  endfunction : mubi4_to_lc_inv
  
  function automatic logic lc_tx_test_invalid(lc_tx_t val);
    return ~(val inside {On, Off});
  endfunction : lc_tx_test_invalid
  
  function automatic lc_tx_t lc_tx_bool_to_lc_tx(logic val);
    return (val ? On : Off);
  endfunction : lc_tx_bool_to_lc_tx
  
  
  
  function automatic logic lc_tx_test_true_strict(lc_tx_t val);
    return On == val;
  endfunction : lc_tx_test_true_strict
  
  
  
  function automatic logic lc_tx_test_false_strict(lc_tx_t val);
    return Off == val;
  endfunction : lc_tx_test_false_strict
  
  
  
  function automatic logic lc_tx_test_true_loose(lc_tx_t val);
    return Off != val;
  endfunction : lc_tx_test_true_loose
  
  
  
  function automatic logic lc_tx_test_false_loose(lc_tx_t val);
    return On != val;
  endfunction : lc_tx_test_false_loose
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  function automatic lc_tx_t lc_tx_or(lc_tx_t a, lc_tx_t b, lc_tx_t act);
    logic [TxWidth-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < TxWidth; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] || b_in[k];
      end else begin
        out[k] = a_in[k] && b_in[k];
      end
    end
    return lc_tx_t'(out);
  endfunction : lc_tx_or
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  function automatic lc_tx_t lc_tx_and(lc_tx_t a, lc_tx_t b, lc_tx_t act);
    logic [TxWidth-1:0] a_in, b_in, act_in, out;
    a_in = a;
    b_in = b;
    act_in = act;
    for (int k = 0; k < TxWidth; k++) begin
      if (act_in[k]) begin
        out[k] = a_in[k] && b_in[k];
      end else begin
        out[k] = a_in[k] || b_in[k];
      end
    end
    return lc_tx_t'(out);
  endfunction : lc_tx_and
  
  
  
  function automatic lc_tx_t lc_tx_or_hi(lc_tx_t a, lc_tx_t b);
    return lc_tx_or(a, b, On);
  endfunction : lc_tx_or_hi
  
  
  
  function automatic lc_tx_t lc_tx_and_hi(lc_tx_t a, lc_tx_t b);
    return lc_tx_and(a, b, On);
  endfunction : lc_tx_and_hi
  
  
  
  function automatic lc_tx_t lc_tx_or_lo(lc_tx_t a, lc_tx_t b);
    return lc_tx_or(a, b, Off);
  endfunction : lc_tx_or_lo
  
  
  
  function automatic lc_tx_t lc_tx_and_lo(lc_tx_t a, lc_tx_t b);
    return lc_tx_and(a, b, Off);
  endfunction : lc_tx_and_lo
  
  function automatic lc_tx_t lc_tx_inv(lc_tx_t a);
    return lc_tx_t'(~TxWidth'(a));
  endfunction : lc_tx_inv
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  localparam int FsmStateWidth = 16;
  typedef enum logic [FsmStateWidth-1:0] {
    ResetSt       = 16'b1111011010111100,
    IdleSt        = 16'b0000011110101101,
    ClkMuxSt      = 16'b1100111011001001,
    CntIncrSt     = 16'b0011001111000111,
    CntProgSt     = 16'b0000110001010100,
    TransCheckSt  = 16'b0110111010110000,
    TokenHashSt   = 16'b1101001000111111,
    NvmRmaSt      = 16'b1110100010001111,
    TokenCheck0St = 16'b0010000011000000,
    TokenCheck1St = 16'b1101010101101111,
    TransProgSt   = 16'b1000000110101011,
    PostTransSt   = 16'b0110110100101100,
    ScrapSt       = 16'b1010100001010001,
    EscalateSt    = 16'b1011110110011011,
    InvalidSt     = 16'b0011000101001100
  } fsm_state_e;
  
  
  
  
  
  
  
  
  
  
  `define TEST_UNLOCKED(idx)         \
        {2{ZeroTokenIdx}},           \
        {3{TestExitTokenIdx}},       \
        {(7-idx){InvalidTokenIdx,    \
                 ZeroTokenIdx}},     \
        {(2*idx+2){InvalidTokenIdx}}
  
  
  
  
  
  
  
  
  `define TEST_LOCKED(idx)         \
      ZeroTokenIdx,                \
      InvalidTokenIdx,             \
      {3{TestExitTokenIdx}},       \
      {(7-idx){TestUnlockTokenIdx, \
               InvalidTokenIdx}},  \
      {(2*idx+2){InvalidTokenIdx}}
  
  
  
  parameter token_idx_e [NumLcStates-1:0][NumLcStates-1:0] TransTokenIdxMatrix = {
    
    {21{InvalidTokenIdx}}, 
    
    ZeroTokenIdx,          
    {20{InvalidTokenIdx}}, 
    
    ZeroTokenIdx,          
    {20{InvalidTokenIdx}}, 
    
    ZeroTokenIdx,          
    RmaTokenIdx,           
    {19{InvalidTokenIdx}}, 
    
    ZeroTokenIdx,          
    RmaTokenIdx,           
    {19{InvalidTokenIdx}}, 
    
    `TEST_UNLOCKED(7),
    `TEST_LOCKED(6),
    `TEST_UNLOCKED(6),
    `TEST_LOCKED(5),
    `TEST_UNLOCKED(5),
    `TEST_LOCKED(4),
    `TEST_UNLOCKED(4),
    `TEST_LOCKED(3),
    `TEST_UNLOCKED(3),
    `TEST_LOCKED(2),
    `TEST_UNLOCKED(2),
    `TEST_LOCKED(1),
    `TEST_UNLOCKED(1),
    `TEST_LOCKED(0),
    `TEST_UNLOCKED(0),
    
    ZeroTokenIdx,          
    {4{InvalidTokenIdx}},  
    {8{RawUnlockTokenIdx,  
       InvalidTokenIdx}}   
  };
  
  `undef TEST_LOCKED
  `undef TEST_UNLOCKED
endpackage : lc_ctrl_pkg

package lc_ctrl_reg_pkg;
  
  parameter int SiliconCreatorIdWidth = 16;
  parameter int ProductIdWidth = 16;
  parameter int RevisionIdWidth = 8;
  parameter int NumTokenWords = 4;
  parameter int CsrLcStateWidth = 30;
  parameter int CsrLcCountWidth = 5;
  parameter int CsrLcIdStateWidth = 32;
  parameter int CsrOtpTestCtrlWidth = 32;
  parameter int CsrOtpTestStatusWidth = 32;
  parameter int NumDeviceIdWords = 8;
  parameter int NumManufStateWords = 8;
  parameter int NumAlerts = 3;
  
  parameter int RegsAw = 8;
  parameter int DmiAw = 12;
  
  parameter int NumRegsRegs = 35;
  parameter int NumRegsDmi = 0;
  
  typedef enum int {
    AlertFatalProgErrorIdx = 0,
    AlertFatalStateErrorIdx = 1,
    AlertFatalBusIntegErrorIdx = 2
  } lc_ctrl_alert_idx_t;
  
  
  
  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } fatal_bus_integ_error;
    struct packed {
      logic        q;
      logic        qe;
    } fatal_state_error;
    struct packed {
      logic        q;
      logic        qe;
    } fatal_prog_error;
  } lc_ctrl_reg2hw_alert_test_reg_t;
  typedef struct packed {
    logic [7:0]  q;
    logic        qe;
  } lc_ctrl_reg2hw_claim_transition_if_reg_t;
  typedef struct packed {
    logic        q;
    logic        qe;
  } lc_ctrl_reg2hw_transition_cmd_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } volatile_raw_unlock;
    struct packed {
      logic        q;
      logic        qe;
    } ext_clock_en;
  } lc_ctrl_reg2hw_transition_ctrl_reg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } lc_ctrl_reg2hw_transition_token_mreg_t;
  typedef struct packed {
    logic [29:0] q;
    logic        qe;
  } lc_ctrl_reg2hw_transition_target_reg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } lc_ctrl_reg2hw_otp_vendor_test_ctrl_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
    } otp_partition_error;
    struct packed {
      logic        d;
    } bus_integ_error;
    struct packed {
      logic        d;
    } state_error;
    struct packed {
      logic        d;
    } otp_error;
    struct packed {
      logic        d;
    } nvm_rma_error;
    struct packed {
      logic        d;
    } token_error;
    struct packed {
      logic        d;
    } transition_error;
    struct packed {
      logic        d;
    } transition_count_error;
    struct packed {
      logic        d;
    } transition_successful;
    struct packed {
      logic        d;
    } ext_clock_switched;
    struct packed {
      logic        d;
    } ready;
    struct packed {
      logic        d;
    } initialized;
  } lc_ctrl_hw2reg_status_reg_t;
  typedef struct packed {
    logic [7:0]  d;
  } lc_ctrl_hw2reg_claim_transition_if_reg_t;
  typedef struct packed {
    logic        d;
  } lc_ctrl_hw2reg_transition_regwen_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
    } volatile_raw_unlock;
    struct packed {
      logic        d;
    } ext_clock_en;
  } lc_ctrl_hw2reg_transition_ctrl_reg_t;
  typedef struct packed {
    logic [31:0] d;
  } lc_ctrl_hw2reg_transition_token_mreg_t;
  typedef struct packed {
    logic [29:0] d;
  } lc_ctrl_hw2reg_transition_target_reg_t;
  typedef struct packed {
    logic [31:0] d;
  } lc_ctrl_hw2reg_otp_vendor_test_ctrl_reg_t;
  typedef struct packed {
    logic [31:0] d;
  } lc_ctrl_hw2reg_otp_vendor_test_status_reg_t;
  typedef struct packed {
    logic [29:0] d;
  } lc_ctrl_hw2reg_lc_state_reg_t;
  typedef struct packed {
    logic [4:0]  d;
  } lc_ctrl_hw2reg_lc_transition_cnt_reg_t;
  typedef struct packed {
    logic [31:0] d;
  } lc_ctrl_hw2reg_lc_id_state_reg_t;
  typedef struct packed {
    struct packed {
      logic [15:0] d;
    } silicon_creator_id;
    struct packed {
      logic [15:0] d;
    } product_id;
  } lc_ctrl_hw2reg_hw_revision0_reg_t;
  typedef struct packed {
    struct packed {
      logic [23:0] d;
    } reserved;
    struct packed {
      logic [7:0]  d;
    } revision_id;
  } lc_ctrl_hw2reg_hw_revision1_reg_t;
  typedef struct packed {
    logic [31:0] d;
  } lc_ctrl_hw2reg_device_id_mreg_t;
  typedef struct packed {
    logic [31:0] d;
  } lc_ctrl_hw2reg_manuf_state_mreg_t;
  
  typedef struct packed {
    lc_ctrl_reg2hw_alert_test_reg_t alert_test; 
    lc_ctrl_reg2hw_claim_transition_if_reg_t claim_transition_if; 
    lc_ctrl_reg2hw_transition_cmd_reg_t transition_cmd; 
    lc_ctrl_reg2hw_transition_ctrl_reg_t transition_ctrl; 
    lc_ctrl_reg2hw_transition_token_mreg_t [3:0] transition_token; 
    lc_ctrl_reg2hw_transition_target_reg_t transition_target; 
    lc_ctrl_reg2hw_otp_vendor_test_ctrl_reg_t otp_vendor_test_ctrl; 
  } lc_ctrl_regs_reg2hw_t;
  
  typedef struct packed {
    lc_ctrl_hw2reg_status_reg_t status; 
    lc_ctrl_hw2reg_claim_transition_if_reg_t claim_transition_if; 
    lc_ctrl_hw2reg_transition_regwen_reg_t transition_regwen; 
    lc_ctrl_hw2reg_transition_ctrl_reg_t transition_ctrl; 
    lc_ctrl_hw2reg_transition_token_mreg_t [3:0] transition_token; 
    lc_ctrl_hw2reg_transition_target_reg_t transition_target; 
    lc_ctrl_hw2reg_otp_vendor_test_ctrl_reg_t otp_vendor_test_ctrl; 
    lc_ctrl_hw2reg_otp_vendor_test_status_reg_t otp_vendor_test_status; 
    lc_ctrl_hw2reg_lc_state_reg_t lc_state; 
    lc_ctrl_hw2reg_lc_transition_cnt_reg_t lc_transition_cnt; 
    lc_ctrl_hw2reg_lc_id_state_reg_t lc_id_state; 
    lc_ctrl_hw2reg_hw_revision0_reg_t hw_revision0; 
    lc_ctrl_hw2reg_hw_revision1_reg_t hw_revision1; 
    lc_ctrl_hw2reg_device_id_mreg_t [7:0] device_id; 
    lc_ctrl_hw2reg_manuf_state_mreg_t [7:0] manuf_state; 
  } lc_ctrl_regs_hw2reg_t;
  
  parameter logic [RegsAw-1:0] LC_CTRL_ALERT_TEST_OFFSET = 8'h 0;
  parameter logic [RegsAw-1:0] LC_CTRL_STATUS_OFFSET = 8'h 4;
  parameter logic [RegsAw-1:0] LC_CTRL_CLAIM_TRANSITION_IF_REGWEN_OFFSET = 8'h 8;
  parameter logic [RegsAw-1:0] LC_CTRL_CLAIM_TRANSITION_IF_OFFSET = 8'h c;
  parameter logic [RegsAw-1:0] LC_CTRL_TRANSITION_REGWEN_OFFSET = 8'h 10;
  parameter logic [RegsAw-1:0] LC_CTRL_TRANSITION_CMD_OFFSET = 8'h 14;
  parameter logic [RegsAw-1:0] LC_CTRL_TRANSITION_CTRL_OFFSET = 8'h 18;
  parameter logic [RegsAw-1:0] LC_CTRL_TRANSITION_TOKEN_0_OFFSET = 8'h 1c;
  parameter logic [RegsAw-1:0] LC_CTRL_TRANSITION_TOKEN_1_OFFSET = 8'h 20;
  parameter logic [RegsAw-1:0] LC_CTRL_TRANSITION_TOKEN_2_OFFSET = 8'h 24;
  parameter logic [RegsAw-1:0] LC_CTRL_TRANSITION_TOKEN_3_OFFSET = 8'h 28;
  parameter logic [RegsAw-1:0] LC_CTRL_TRANSITION_TARGET_OFFSET = 8'h 2c;
  parameter logic [RegsAw-1:0] LC_CTRL_OTP_VENDOR_TEST_CTRL_OFFSET = 8'h 30;
  parameter logic [RegsAw-1:0] LC_CTRL_OTP_VENDOR_TEST_STATUS_OFFSET = 8'h 34;
  parameter logic [RegsAw-1:0] LC_CTRL_LC_STATE_OFFSET = 8'h 38;
  parameter logic [RegsAw-1:0] LC_CTRL_LC_TRANSITION_CNT_OFFSET = 8'h 3c;
  parameter logic [RegsAw-1:0] LC_CTRL_LC_ID_STATE_OFFSET = 8'h 40;
  parameter logic [RegsAw-1:0] LC_CTRL_HW_REVISION0_OFFSET = 8'h 44;
  parameter logic [RegsAw-1:0] LC_CTRL_HW_REVISION1_OFFSET = 8'h 48;
  parameter logic [RegsAw-1:0] LC_CTRL_DEVICE_ID_0_OFFSET = 8'h 4c;
  parameter logic [RegsAw-1:0] LC_CTRL_DEVICE_ID_1_OFFSET = 8'h 50;
  parameter logic [RegsAw-1:0] LC_CTRL_DEVICE_ID_2_OFFSET = 8'h 54;
  parameter logic [RegsAw-1:0] LC_CTRL_DEVICE_ID_3_OFFSET = 8'h 58;
  parameter logic [RegsAw-1:0] LC_CTRL_DEVICE_ID_4_OFFSET = 8'h 5c;
  parameter logic [RegsAw-1:0] LC_CTRL_DEVICE_ID_5_OFFSET = 8'h 60;
  parameter logic [RegsAw-1:0] LC_CTRL_DEVICE_ID_6_OFFSET = 8'h 64;
  parameter logic [RegsAw-1:0] LC_CTRL_DEVICE_ID_7_OFFSET = 8'h 68;
  parameter logic [RegsAw-1:0] LC_CTRL_MANUF_STATE_0_OFFSET = 8'h 6c;
  parameter logic [RegsAw-1:0] LC_CTRL_MANUF_STATE_1_OFFSET = 8'h 70;
  parameter logic [RegsAw-1:0] LC_CTRL_MANUF_STATE_2_OFFSET = 8'h 74;
  parameter logic [RegsAw-1:0] LC_CTRL_MANUF_STATE_3_OFFSET = 8'h 78;
  parameter logic [RegsAw-1:0] LC_CTRL_MANUF_STATE_4_OFFSET = 8'h 7c;
  parameter logic [RegsAw-1:0] LC_CTRL_MANUF_STATE_5_OFFSET = 8'h 80;
  parameter logic [RegsAw-1:0] LC_CTRL_MANUF_STATE_6_OFFSET = 8'h 84;
  parameter logic [RegsAw-1:0] LC_CTRL_MANUF_STATE_7_OFFSET = 8'h 88;
  
  parameter logic [2:0] LC_CTRL_ALERT_TEST_RESVAL = 3'h 0;
  parameter logic [0:0] LC_CTRL_ALERT_TEST_FATAL_PROG_ERROR_RESVAL = 1'h 0;
  parameter logic [0:0] LC_CTRL_ALERT_TEST_FATAL_STATE_ERROR_RESVAL = 1'h 0;
  parameter logic [0:0] LC_CTRL_ALERT_TEST_FATAL_BUS_INTEG_ERROR_RESVAL = 1'h 0;
  parameter logic [11:0] LC_CTRL_STATUS_RESVAL = 12'h 0;
  parameter logic [7:0] LC_CTRL_CLAIM_TRANSITION_IF_RESVAL = 8'h 69;
  parameter logic [7:0] LC_CTRL_CLAIM_TRANSITION_IF_MUTEX_RESVAL = 8'h 69;
  parameter logic [0:0] LC_CTRL_TRANSITION_REGWEN_RESVAL = 1'h 0;
  parameter logic [0:0] LC_CTRL_TRANSITION_REGWEN_TRANSITION_REGWEN_RESVAL = 1'h 0;
  parameter logic [0:0] LC_CTRL_TRANSITION_CMD_RESVAL = 1'h 0;
  parameter logic [1:0] LC_CTRL_TRANSITION_CTRL_RESVAL = 2'h 0;
  parameter logic [31:0] LC_CTRL_TRANSITION_TOKEN_0_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_TRANSITION_TOKEN_1_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_TRANSITION_TOKEN_2_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_TRANSITION_TOKEN_3_RESVAL = 32'h 0;
  parameter logic [29:0] LC_CTRL_TRANSITION_TARGET_RESVAL = 30'h 0;
  parameter logic [31:0] LC_CTRL_OTP_VENDOR_TEST_CTRL_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_OTP_VENDOR_TEST_STATUS_RESVAL = 32'h 0;
  parameter logic [29:0] LC_CTRL_LC_STATE_RESVAL = 30'h 0;
  parameter logic [4:0] LC_CTRL_LC_TRANSITION_CNT_RESVAL = 5'h 0;
  parameter logic [31:0] LC_CTRL_LC_ID_STATE_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_HW_REVISION0_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_HW_REVISION1_RESVAL = 32'h 0;
  parameter logic [23:0] LC_CTRL_HW_REVISION1_RESERVED_RESVAL = 24'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_0_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_1_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_2_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_3_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_4_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_5_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_6_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_DEVICE_ID_7_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_MANUF_STATE_0_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_MANUF_STATE_1_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_MANUF_STATE_2_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_MANUF_STATE_3_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_MANUF_STATE_4_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_MANUF_STATE_5_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_MANUF_STATE_6_RESVAL = 32'h 0;
  parameter logic [31:0] LC_CTRL_MANUF_STATE_7_RESVAL = 32'h 0;
  
  typedef enum int {
    LC_CTRL_ALERT_TEST,
    LC_CTRL_STATUS,
    LC_CTRL_CLAIM_TRANSITION_IF_REGWEN,
    LC_CTRL_CLAIM_TRANSITION_IF,
    LC_CTRL_TRANSITION_REGWEN,
    LC_CTRL_TRANSITION_CMD,
    LC_CTRL_TRANSITION_CTRL,
    LC_CTRL_TRANSITION_TOKEN_0,
    LC_CTRL_TRANSITION_TOKEN_1,
    LC_CTRL_TRANSITION_TOKEN_2,
    LC_CTRL_TRANSITION_TOKEN_3,
    LC_CTRL_TRANSITION_TARGET,
    LC_CTRL_OTP_VENDOR_TEST_CTRL,
    LC_CTRL_OTP_VENDOR_TEST_STATUS,
    LC_CTRL_LC_STATE,
    LC_CTRL_LC_TRANSITION_CNT,
    LC_CTRL_LC_ID_STATE,
    LC_CTRL_HW_REVISION0,
    LC_CTRL_HW_REVISION1,
    LC_CTRL_DEVICE_ID_0,
    LC_CTRL_DEVICE_ID_1,
    LC_CTRL_DEVICE_ID_2,
    LC_CTRL_DEVICE_ID_3,
    LC_CTRL_DEVICE_ID_4,
    LC_CTRL_DEVICE_ID_5,
    LC_CTRL_DEVICE_ID_6,
    LC_CTRL_DEVICE_ID_7,
    LC_CTRL_MANUF_STATE_0,
    LC_CTRL_MANUF_STATE_1,
    LC_CTRL_MANUF_STATE_2,
    LC_CTRL_MANUF_STATE_3,
    LC_CTRL_MANUF_STATE_4,
    LC_CTRL_MANUF_STATE_5,
    LC_CTRL_MANUF_STATE_6,
    LC_CTRL_MANUF_STATE_7
  } lc_ctrl_regs_id_e;
  
  parameter logic [3:0] LC_CTRL_REGS_PERMIT [35] = '{
    4'b 0001, 
    4'b 0011, 
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
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
    4'b 1111  
  };
  
  parameter logic [DmiAw-1:0] LC_CTRL_DMI_OFFSET = 12'h 0;
  parameter int unsigned      LC_CTRL_DMI_SIZE   = 'h 1000;
  parameter int unsigned      LC_CTRL_DMI_IDX    = 0;
endpackage

package lc_ctrl_state_pkg;
  import prim_util_pkg::vbits;
  
  
  
  parameter int LcValueWidth = 16;
  parameter int NumLcStateValues = 20;
  parameter int LcStateWidth = NumLcStateValues * LcValueWidth;
  parameter int NumLcStates = 21;
  parameter int DecLcStateWidth = vbits(NumLcStates);
  parameter int NumSocDbgStateValues = 2;
  parameter int SocDbgStateWidth = NumSocDbgStateValues * LcValueWidth;
  parameter int NumOwnershipStateValues = 8;
  parameter int OwnershipStateWidth = NumOwnershipStateValues * LcValueWidth;
  parameter int NumAuthStateValues = 2;
  parameter int AuthStateWidth = NumAuthStateValues * LcValueWidth;
  
  parameter int DecLcStateNumRep = 32/DecLcStateWidth;
  parameter int ExtDecLcStateWidth = DecLcStateNumRep*DecLcStateWidth;
  parameter int NumLcCountValues = 24;
  parameter int LcCountWidth = NumLcCountValues * LcValueWidth;
  parameter int NumLcCountStates = 25;
  parameter int DecLcCountWidth = vbits(NumLcCountStates);
  
  
  
  parameter int NumLcIdStates = 2;
  parameter int DecLcIdStateWidth = vbits(NumLcIdStates+1);
  
  parameter int DecLcIdStateNumRep = 32/DecLcIdStateWidth;
  parameter int ExtDecLcIdStateWidth = DecLcIdStateNumRep*DecLcIdStateWidth;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  parameter logic [15:0] A0 = 16'b1010001101010010; 
  parameter logic [15:0] B0 = 16'b1011001101011010; 
  parameter logic [15:0] A1 = 16'b0111000110000001; 
  parameter logic [15:0] B1 = 16'b1111101111010001; 
  parameter logic [15:0] A2 = 16'b0011100111001010; 
  parameter logic [15:0] B2 = 16'b0011110111011011; 
  parameter logic [15:0] A3 = 16'b0100000001101011; 
  parameter logic [15:0] B3 = 16'b0100000011111111; 
  parameter logic [15:0] A4 = 16'b0111000001110000; 
  parameter logic [15:0] B4 = 16'b1111110011110010; 
  parameter logic [15:0] A5 = 16'b0110101010001000; 
  parameter logic [15:0] B5 = 16'b1111101110011110; 
  parameter logic [15:0] A6 = 16'b1001011000001110; 
  parameter logic [15:0] B6 = 16'b1111011011111111; 
  parameter logic [15:0] A7 = 16'b0111100111100000; 
  parameter logic [15:0] B7 = 16'b0111110111110101; 
  parameter logic [15:0] A8 = 16'b0101110011010100; 
  parameter logic [15:0] B8 = 16'b1111110111010100; 
  parameter logic [15:0] A9 = 16'b1001010010001001; 
  parameter logic [15:0] B9 = 16'b1011010110101001; 
  parameter logic [15:0] A10 = 16'b1100011011100101; 
  parameter logic [15:0] B10 = 16'b1100011111111101; 
  parameter logic [15:0] A11 = 16'b1001011111100100; 
  parameter logic [15:0] B11 = 16'b1011111111101101; 
  parameter logic [15:0] A12 = 16'b1011010000000011; 
  parameter logic [15:0] B12 = 16'b1011011101100011; 
  parameter logic [15:0] A13 = 16'b0101111010010000; 
  parameter logic [15:0] B13 = 16'b1111111010011101; 
  parameter logic [15:0] A14 = 16'b1000110001111100; 
  parameter logic [15:0] B14 = 16'b1110111011111100; 
  parameter logic [15:0] A15 = 16'b1010101010110000; 
  parameter logic [15:0] B15 = 16'b1010111111111100; 
  parameter logic [15:0] A16 = 16'b0010010011001101; 
  parameter logic [15:0] B16 = 16'b0111010111101111; 
  parameter logic [15:0] A17 = 16'b0101011000011000; 
  parameter logic [15:0] B17 = 16'b0101111010111101; 
  parameter logic [15:0] A18 = 16'b1101101100100001; 
  parameter logic [15:0] B18 = 16'b1101111100111111; 
  parameter logic [15:0] A19 = 16'b1100100101001001; 
  parameter logic [15:0] B19 = 16'b1111100101111101; 
  
  parameter logic [15:0] C0 = 16'b0011001110011001; 
  parameter logic [15:0] D0 = 16'b0111001111111011; 
  parameter logic [15:0] C1 = 16'b0010111000001101; 
  parameter logic [15:0] D1 = 16'b1010111101101111; 
  parameter logic [15:0] C2 = 16'b0001000011110101; 
  parameter logic [15:0] D2 = 16'b1011000111111101; 
  parameter logic [15:0] C3 = 16'b0011100001101010; 
  parameter logic [15:0] D3 = 16'b0011100001111111; 
  parameter logic [15:0] C4 = 16'b1111010010110000; 
  parameter logic [15:0] D4 = 16'b1111111011110111; 
  parameter logic [15:0] C5 = 16'b0100011000111101; 
  parameter logic [15:0] D5 = 16'b1110011010111101; 
  parameter logic [15:0] C6 = 16'b0110011000010010; 
  parameter logic [15:0] D6 = 16'b0111011100110010; 
  parameter logic [15:0] C7 = 16'b0010100101000101; 
  parameter logic [15:0] D7 = 16'b1110100101111111; 
  parameter logic [15:0] C8 = 16'b0011001000110000; 
  parameter logic [15:0] D8 = 16'b1111101011110100; 
  parameter logic [15:0] C9 = 16'b0100000110001100; 
  parameter logic [15:0] D9 = 16'b0101100111111100; 
  parameter logic [15:0] C10 = 16'b0111101110110000; 
  parameter logic [15:0] D10 = 16'b0111111111111000; 
  parameter logic [15:0] C11 = 16'b0001000111011000; 
  parameter logic [15:0] D11 = 16'b1101010111011011; 
  parameter logic [15:0] C12 = 16'b0011110001000000; 
  parameter logic [15:0] D12 = 16'b1111110101101000; 
  parameter logic [15:0] C13 = 16'b1110100100101010; 
  parameter logic [15:0] D13 = 16'b1110111101111011; 
  parameter logic [15:0] C14 = 16'b0001010011101100; 
  parameter logic [15:0] D14 = 16'b1011011011111110; 
  parameter logic [15:0] C15 = 16'b0101011000100010; 
  parameter logic [15:0] D15 = 16'b0101011001111011; 
  parameter logic [15:0] C16 = 16'b1010010100000110; 
  parameter logic [15:0] D16 = 16'b1010111111000110; 
  parameter logic [15:0] C17 = 16'b0001001100011011; 
  parameter logic [15:0] D17 = 16'b1001101110111111; 
  parameter logic [15:0] C18 = 16'b0110100010000011; 
  parameter logic [15:0] D18 = 16'b0110101111011111; 
  parameter logic [15:0] C19 = 16'b0011100100111000; 
  parameter logic [15:0] D19 = 16'b0011111100111110; 
  parameter logic [15:0] C20 = 16'b0010100011010010; 
  parameter logic [15:0] D20 = 16'b0011111011010111; 
  parameter logic [15:0] C21 = 16'b0000011111001000; 
  parameter logic [15:0] D21 = 16'b0101011111001101; 
  parameter logic [15:0] C22 = 16'b0100110001000100; 
  parameter logic [15:0] D22 = 16'b0110110011001100; 
  parameter logic [15:0] C23 = 16'b0001001111101001; 
  parameter logic [15:0] D23 = 16'b0101111111111111; 
  
  parameter logic [15:0] E0 = 16'b1001110100000011; 
  parameter logic [15:0] F0 = 16'b1111111110000011; 
  parameter logic [15:0] E1 = 16'b0001101000010111; 
  parameter logic [15:0] F1 = 16'b0111101101010111; 
  
  parameter logic [15:0] G0 = 16'b0010010100011101; 
  parameter logic [15:0] H0 = 16'b1011011110011111; 
  parameter logic [15:0] G1 = 16'b1100000011000011; 
  parameter logic [15:0] H1 = 16'b1100011111000011; 
  parameter logic [15:0] G2 = 16'b0010101000101001; 
  parameter logic [15:0] H2 = 16'b0111101000101111; 
  parameter logic [15:0] G3 = 16'b0101011011000000; 
  parameter logic [15:0] H3 = 16'b1101111011100010; 
  parameter logic [15:0] G4 = 16'b0011011010010100; 
  parameter logic [15:0] H4 = 16'b1011111010110111; 
  parameter logic [15:0] G5 = 16'b0100001111100000; 
  parameter logic [15:0] H5 = 16'b1101001111101010; 
  parameter logic [15:0] G6 = 16'b1111001000100011; 
  parameter logic [15:0] H6 = 16'b1111111000101011; 
  parameter logic [15:0] G7 = 16'b0100001100010100; 
  parameter logic [15:0] H7 = 16'b1101011101010111; 
  
  parameter logic [15:0] I0 = 16'b0001111010011000; 
  parameter logic [15:0] J0 = 16'b0011111110111111; 
  parameter logic [15:0] I1 = 16'b1110100001001011; 
  parameter logic [15:0] J1 = 16'b1110110111101111; 
  parameter logic [15:0] ZRO = 16'h0;
  
  
  
  
  
  
  
  typedef logic [LcStateWidth-1:0] lc_state_t;
  typedef enum lc_state_t {
    LcStRaw           = {ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO},
    LcStTestUnlocked0 = {A19, A18, A17, A16, A15, A14, A13, A12, A11, A10,  A9,  A8,  A7,  A6,  A5,  A4,  A3,  A2,  A1,  B0},
    LcStTestLocked0   = {A19, A18, A17, A16, A15, A14, A13, A12, A11, A10,  A9,  A8,  A7,  A6,  A5,  A4,  A3,  A2,  B1,  B0},
    LcStTestUnlocked1 = {A19, A18, A17, A16, A15, A14, A13, A12, A11, A10,  A9,  A8,  A7,  A6,  A5,  A4,  A3,  B2,  B1,  B0},
    LcStTestLocked1   = {A19, A18, A17, A16, A15, A14, A13, A12, A11, A10,  A9,  A8,  A7,  A6,  A5,  A4,  B3,  B2,  B1,  B0},
    LcStTestUnlocked2 = {A19, A18, A17, A16, A15, A14, A13, A12, A11, A10,  A9,  A8,  A7,  A6,  A5,  B4,  B3,  B2,  B1,  B0},
    LcStTestLocked2   = {A19, A18, A17, A16, A15, A14, A13, A12, A11, A10,  A9,  A8,  A7,  A6,  B5,  B4,  B3,  B2,  B1,  B0},
    LcStTestUnlocked3 = {A19, A18, A17, A16, A15, A14, A13, A12, A11, A10,  A9,  A8,  A7,  B6,  B5,  B4,  B3,  B2,  B1,  B0},
    LcStTestLocked3   = {A19, A18, A17, A16, A15, A14, A13, A12, A11, A10,  A9,  A8,  B7,  B6,  B5,  B4,  B3,  B2,  B1,  B0},
    LcStTestUnlocked4 = {A19, A18, A17, A16, A15, A14, A13, A12, A11, A10,  A9,  B8,  B7,  B6,  B5,  B4,  B3,  B2,  B1,  B0},
    LcStTestLocked4   = {A19, A18, A17, A16, A15, A14, A13, A12, A11, A10,  B9,  B8,  B7,  B6,  B5,  B4,  B3,  B2,  B1,  B0},
    LcStTestUnlocked5 = {A19, A18, A17, A16, A15, A14, A13, A12, A11, B10,  B9,  B8,  B7,  B6,  B5,  B4,  B3,  B2,  B1,  B0},
    LcStTestLocked5   = {A19, A18, A17, A16, A15, A14, A13, A12, B11, B10,  B9,  B8,  B7,  B6,  B5,  B4,  B3,  B2,  B1,  B0},
    LcStTestUnlocked6 = {A19, A18, A17, A16, A15, A14, A13, B12, B11, B10,  B9,  B8,  B7,  B6,  B5,  B4,  B3,  B2,  B1,  B0},
    LcStTestLocked6   = {A19, A18, A17, A16, A15, A14, B13, B12, B11, B10,  B9,  B8,  B7,  B6,  B5,  B4,  B3,  B2,  B1,  B0},
    LcStTestUnlocked7 = {A19, A18, A17, A16, A15, B14, B13, B12, B11, B10,  B9,  B8,  B7,  B6,  B5,  B4,  B3,  B2,  B1,  B0},
    LcStDev           = {A19, A18, A17, A16, B15, B14, B13, B12, B11, B10,  B9,  B8,  B7,  B6,  B5,  B4,  B3,  B2,  B1,  B0},
    LcStProd          = {A19, A18, A17, B16, A15, B14, B13, B12, B11, B10,  B9,  B8,  B7,  B6,  B5,  B4,  B3,  B2,  B1,  B0},
    LcStProdEnd       = {A19, A18, B17, A16, A15, B14, B13, B12, B11, B10,  B9,  B8,  B7,  B6,  B5,  B4,  B3,  B2,  B1,  B0},
    LcStRma           = {B19, B18, A17, B16, B15, B14, B13, B12, B11, B10,  B9,  B8,  B7,  B6,  B5,  B4,  B3,  B2,  B1,  B0},
    LcStScrap         = {B19, B18, B17, B16, B15, B14, B13, B12, B11, B10,  B9,  B8,  B7,  B6,  B5,  B4,  B3,  B2,  B1,  B0}
  } lc_state_e;
  typedef logic [LcCountWidth-1:0] lc_cnt_t;
  typedef enum lc_cnt_t {
    LcCnt0  = {ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO},
    LcCnt1  = {C23, C22, C21, C20, C19, C18, C17, C16, C15, C14, C13, C12, C11, C10,  C9,  C8,  C7,  C6,  C5,  C4,  C3,  C2,  C1,  D0},
    LcCnt2  = {C23, C22, C21, C20, C19, C18, C17, C16, C15, C14, C13, C12, C11, C10,  C9,  C8,  C7,  C6,  C5,  C4,  C3,  C2,  D1,  D0},
    LcCnt3  = {C23, C22, C21, C20, C19, C18, C17, C16, C15, C14, C13, C12, C11, C10,  C9,  C8,  C7,  C6,  C5,  C4,  C3,  D2,  D1,  D0},
    LcCnt4  = {C23, C22, C21, C20, C19, C18, C17, C16, C15, C14, C13, C12, C11, C10,  C9,  C8,  C7,  C6,  C5,  C4,  D3,  D2,  D1,  D0},
    LcCnt5  = {C23, C22, C21, C20, C19, C18, C17, C16, C15, C14, C13, C12, C11, C10,  C9,  C8,  C7,  C6,  C5,  D4,  D3,  D2,  D1,  D0},
    LcCnt6  = {C23, C22, C21, C20, C19, C18, C17, C16, C15, C14, C13, C12, C11, C10,  C9,  C8,  C7,  C6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt7  = {C23, C22, C21, C20, C19, C18, C17, C16, C15, C14, C13, C12, C11, C10,  C9,  C8,  C7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt8  = {C23, C22, C21, C20, C19, C18, C17, C16, C15, C14, C13, C12, C11, C10,  C9,  C8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt9  = {C23, C22, C21, C20, C19, C18, C17, C16, C15, C14, C13, C12, C11, C10,  C9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt10 = {C23, C22, C21, C20, C19, C18, C17, C16, C15, C14, C13, C12, C11, C10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt11 = {C23, C22, C21, C20, C19, C18, C17, C16, C15, C14, C13, C12, C11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt12 = {C23, C22, C21, C20, C19, C18, C17, C16, C15, C14, C13, C12, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt13 = {C23, C22, C21, C20, C19, C18, C17, C16, C15, C14, C13, D12, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt14 = {C23, C22, C21, C20, C19, C18, C17, C16, C15, C14, D13, D12, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt15 = {C23, C22, C21, C20, C19, C18, C17, C16, C15, D14, D13, D12, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt16 = {C23, C22, C21, C20, C19, C18, C17, C16, D15, D14, D13, D12, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt17 = {C23, C22, C21, C20, C19, C18, C17, D16, D15, D14, D13, D12, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt18 = {C23, C22, C21, C20, C19, C18, D17, D16, D15, D14, D13, D12, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt19 = {C23, C22, C21, C20, C19, D18, D17, D16, D15, D14, D13, D12, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt20 = {C23, C22, C21, C20, D19, D18, D17, D16, D15, D14, D13, D12, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt21 = {C23, C22, C21, D20, D19, D18, D17, D16, D15, D14, D13, D12, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt22 = {C23, C22, D21, D20, D19, D18, D17, D16, D15, D14, D13, D12, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt23 = {C23, D22, D21, D20, D19, D18, D17, D16, D15, D14, D13, D12, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0},
    LcCnt24 = {D23, D22, D21, D20, D19, D18, D17, D16, D15, D14, D13, D12, D11, D10,  D9,  D8,  D7,  D6,  D5,  D4,  D3,  D2,  D1,  D0}
  } lc_cnt_e;
  typedef logic [SocDbgStateWidth-1:0] soc_dbg_state_t;
  parameter soc_dbg_state_t SOC_DBG_STATE_DEFAULT = '0;
  typedef enum soc_dbg_state_t {
    SocDbgStBlank   = {ZRO, ZRO},
    SocDbgStPreProd = { E1,  E0},
    SocDbgStProd    = { F1,  F0}
  } soc_dbg_state_e;
  typedef logic [OwnershipStateWidth-1:0] ownership_state_t;
  typedef enum ownership_state_t {
    OwnershipStBlank     = {ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO, ZRO},
    OwnershipStLocked0   = { G7,  G6,  G5,  G4,  G3,  G2,  G1,  G0},
    OwnershipStReleased0 = { G7,  G6,  G5,  G4,  G3,  G2,  G1,  H0},
    OwnershipStLocked1   = { G7,  G6,  G5,  G4,  G3,  G2,  H1,  H0},
    OwnershipStReleased1 = { G7,  G6,  G5,  G4,  G3,  H2,  H1,  H0},
    OwnershipStLocked2   = { G7,  G6,  G5,  G4,  H3,  H2,  H1,  H0},
    OwnershipStReleased2 = { G7,  G6,  G5,  H4,  H3,  H2,  H1,  H0},
    OwnershipStLocked3   = { G7,  G6,  H5,  H4,  H3,  H2,  H1,  H0},
    OwnershipStScrapped  = { H7,  H6,  H5,  H4,  H3,  H2,  H1,  H0}
  } ownership_state_e;
  typedef logic [AuthStateWidth-1:0] auth_state_t;
  typedef enum auth_state_t {
    AuthStBlank    = {ZRO, ZRO},
    AuthStEnabled  = { I1,  I0},
    AuthStDisabled = { J1,  J0}
  } auth_state_e;
  
  typedef enum logic [DecLcStateWidth-1:0] {
    DecLcStRaw = 0,
    DecLcStTestUnlocked0 = 1,
    DecLcStTestLocked0 = 2,
    DecLcStTestUnlocked1 = 3,
    DecLcStTestLocked1 = 4,
    DecLcStTestUnlocked2 = 5,
    DecLcStTestLocked2 = 6,
    DecLcStTestUnlocked3 = 7,
    DecLcStTestLocked3 = 8,
    DecLcStTestUnlocked4 = 9,
    DecLcStTestLocked4 = 10,
    DecLcStTestUnlocked5 = 11,
    DecLcStTestLocked5 = 12,
    DecLcStTestUnlocked6 = 13,
    DecLcStTestLocked6 = 14,
    DecLcStTestUnlocked7 = 15,
    DecLcStDev = 16,
    DecLcStProd = 17,
    DecLcStProdEnd = 18,
    DecLcStRma = 19,
    DecLcStScrap = 20,
    DecLcStPostTrans = 21,
    DecLcStEscalate = 22,
    DecLcStInvalid = 23
  } dec_lc_state_e;
  typedef dec_lc_state_e [DecLcStateNumRep-1:0] ext_dec_lc_state_t;
  typedef enum logic [DecLcIdStateWidth-1:0] {
    DecLcIdBlank,
    DecLcIdPersonalized,
    DecLcIdInvalid
  } dec_lc_id_state_e;
  typedef logic [DecLcCountWidth-1:0] dec_lc_cnt_t;
  parameter int LcTokenWidth = 128;
  typedef logic [LcTokenWidth-1:0] lc_token_t;
endpackage : lc_ctrl_state_pkg

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
module keccak_2share
  import prim_mubi_pkg::*;
#(
  parameter int Width = 1600, 
  
  localparam int W        = Width/25,
  localparam int L        = $clog2(W),
  localparam int MaxRound = 12 + 2*L,           
  localparam int RndW     = $clog2(MaxRound+1), 
  
  parameter  bit EnMasking    = 1'b0, 
  parameter  bit ForceRandExt = 1'b0, 
                                      
                                      
  localparam int Share        = EnMasking ? 2 : 1
) (
  input clk_i,
  input rst_ni,
  input  lc_ctrl_pkg::lc_tx_t lc_escalate_en_i, 
  input [RndW-1:0] rnd_i, 
  
  input mubi4_t phase_sel_i,       
  input         dom_out_low_i,     
  input         dom_in_low_i,      
  input         dom_in_rand_ext_i, 
  input         dom_update_i,      
  input      [Width/2-1:0] rand_i, 
  
  input        [Width-1:0] s_i [Share],
  output logic [Width-1:0] s_o [Share]
);
  
  
  
  
  typedef logic [4:0][4:0][W-1:0] box_t;   
  typedef logic           [W-1:0] lane_t;  
  typedef logic [4:0]     [W-1:0] plane_t; 
  typedef logic [4:0][4:0]        slice_t; 
  typedef logic      [4:0][W-1:0] sheet_t; 
  typedef logic [4:0]             row_t;   
  typedef logic      [4:0]        col_t;   
  
  
  
  box_t state_in   [Share];
  box_t state_out  [Share];
  box_t theta_data [Share];
  box_t rho_data   [Share];
  box_t pi_data    [Share];
  box_t chi_data   [Share];
  box_t iota_data  [Share];
  box_t phase1_in  [Share];
  box_t phase1_out [Share];
  box_t phase2_in  [Share];
  box_t phase2_out [Share];
  
  
  
  
  if (!EnMasking) begin : gen_tie_unused
    logic unused_clk;
    logic unused_rst_n;
    mubi4_t unused_phase_sel;
    logic unused_dom_ctrl;
    logic [Width/2-1:0] unused_rand;
    assign unused_clk = clk_i;
    assign unused_rst_n = rst_ni;
    assign unused_phase_sel = phase_sel_i;
    assign unused_dom_ctrl =
        ^{dom_out_low_i, dom_in_low_i, dom_in_rand_ext_i, dom_update_i};
    assign unused_rand = rand_i;
  end
  
  
  
  for (genvar i = 0 ; i < Share ; i++) begin : g_state_inout
    assign state_in[i] = bitarray_to_box(s_i[i]);
    assign s_o[i]      = box_to_bitarray(state_out[i]);
  end : g_state_inout
  if (EnMasking) begin : g_2share_data
    assign phase1_in = state_in;
    assign phase2_in = state_in;
    always_comb begin
      unique case (phase_sel_i)
        MuBi4False: state_out = phase1_out;
        MuBi4True:  state_out = phase2_out;
        default:    state_out = phase1_out;
      endcase
    end
  end else begin : g_single_data
    assign phase1_in = state_in;
    assign phase2_in = phase1_out;
    assign state_out = phase2_out;
  end
  
  
  
  for (genvar i = 0 ; i < Share ; i++) begin : g_datapath
    
    assign theta_data[i] = theta(phase1_in[i]);
    
    
    assign pi_data[i]    = pi(rho_data[i]);
    
    
    
  end : g_datapath
  assign phase1_out = pi_data;
  
  if (EnMasking) begin : g_2share_iota
    assign iota_data[0]  = iota(chi_data[0], rnd_i);
    assign iota_data[1]  = chi_data[1];
  end else begin : g_single_iota
    assign iota_data[0]  = iota(chi_data[0], rnd_i);
  end
  if (EnMasking) begin : g_2share_chi
    
    
    localparam int unsigned WSheetHalf = $bits(sheet_t)/2;
    logic [4:0][WSheetHalf-1:0] in_prd, out_prd;
    
    
    
    for (genvar x = 0 ; x < 5 ; x++) begin : g_chi_w
      localparam int X1 = (x + 1) % 5;
      localparam int X2 = (x + 2) % 5;
      sheet_t sheet0[Share]; 
      sheet_t sheet1[Share]; 
      sheet_t sheet2[Share]; 
      assign sheet0[0] = ~phase2_in[0][X1];
      assign sheet0[1] = phase2_in[1][X1];
      assign sheet1[0] = phase2_in[0][X2];
      assign sheet1[1] = phase2_in[1][X2];
      
      logic [WSheetHalf-1:0] a0_l, a1_l, b0_l, b1_l;
      logic [WSheetHalf-1:0] a0_h, a1_h, b0_h, b1_h;
      logic [WSheetHalf-1:0] a0, a1, b0, b1, q0, q1;
      assign a0_l = {sheet0[0][0][W/2-1:0],
                     sheet0[0][1][W/2-1:0],
                     sheet0[0][2][W/2-1:0],
                     sheet0[0][3][W/2-1:0],
                     sheet0[0][4][W/2-1:0]};
      assign a1_l = {sheet0[1][0][W/2-1:0],
                     sheet0[1][1][W/2-1:0],
                     sheet0[1][2][W/2-1:0],
                     sheet0[1][3][W/2-1:0],
                     sheet0[1][4][W/2-1:0]};
      assign a0_h = {sheet0[0][0][W-1:W/2],
                     sheet0[0][1][W-1:W/2],
                     sheet0[0][2][W-1:W/2],
                     sheet0[0][3][W-1:W/2],
                     sheet0[0][4][W-1:W/2]};
      assign a1_h = {sheet0[1][0][W-1:W/2],
                     sheet0[1][1][W-1:W/2],
                     sheet0[1][2][W-1:W/2],
                     sheet0[1][3][W-1:W/2],
                     sheet0[1][4][W-1:W/2]};
      assign b0_l = {sheet1[0][0][W/2-1:0],
                     sheet1[0][1][W/2-1:0],
                     sheet1[0][2][W/2-1:0],
                     sheet1[0][3][W/2-1:0],
                     sheet1[0][4][W/2-1:0]};
      assign b1_l = {sheet1[1][0][W/2-1:0],
                     sheet1[1][1][W/2-1:0],
                     sheet1[1][2][W/2-1:0],
                     sheet1[1][3][W/2-1:0],
                     sheet1[1][4][W/2-1:0]};
      assign b0_h = {sheet1[0][0][W-1:W/2],
                     sheet1[0][1][W-1:W/2],
                     sheet1[0][2][W-1:W/2],
                     sheet1[0][3][W-1:W/2],
                     sheet1[0][4][W-1:W/2]};
      assign b1_h = {sheet1[1][0][W-1:W/2],
                     sheet1[1][1][W-1:W/2],
                     sheet1[1][2][W-1:W/2],
                     sheet1[1][3][W-1:W/2],
                     sheet1[1][4][W-1:W/2]};
      
      assign a0 = dom_in_low_i ? a0_l : a0_h;
      assign a1 = dom_in_low_i ? a1_l : a1_h;
      assign b0 = dom_in_low_i ? b0_l : b0_h;
      assign b1 = dom_in_low_i ? b1_l : b1_h;
      
      if (!ForceRandExt) begin : gen_in_prd_mux
        
        
        
        assign in_prd[x] = dom_in_rand_ext_i ? rand_i[x * WSheetHalf +: WSheetHalf] :
                                               out_prd[rot_int(x, 5)];
      end else begin : gen_no_in_prd_mux
        
        assign in_prd[x] = rand_i[x * WSheetHalf +: WSheetHalf];
        
        logic unused_out_prd;
        assign unused_out_prd = ^{dom_in_rand_ext_i, out_prd[rot_int(x, 5)]};
      end
      prim_dom_and_2share #(
        .DW (WSheetHalf), 
        .Pipeline(1) 
                     
      ) u_dom (
        .clk_i,
        .rst_ni,
        .a0_i      (a0),
        .a1_i      (a1),
        .b0_i      (b0),
        .b1_i      (b1),
        .z_valid_i (dom_update_i),
        .z_i       (in_prd[x]),
        .q0_o      (q0),
        .q1_o      (q1),
        .prd_o     (out_prd[x])
      );
      
      
      
      
      
      assign sheet2[0][4] = {2{q0[W/2*0+:W/2]}};
      assign sheet2[0][3] = {2{q0[W/2*1+:W/2]}};
      assign sheet2[0][2] = {2{q0[W/2*2+:W/2]}};
      assign sheet2[0][1] = {2{q0[W/2*3+:W/2]}};
      assign sheet2[0][0] = {2{q0[W/2*4+:W/2]}};
      assign sheet2[1][4] = {2{q1[W/2*0+:W/2]}};
      assign sheet2[1][3] = {2{q1[W/2*1+:W/2]}};
      assign sheet2[1][2] = {2{q1[W/2*2+:W/2]}};
      assign sheet2[1][1] = {2{q1[W/2*3+:W/2]}};
      assign sheet2[1][0] = {2{q1[W/2*4+:W/2]}};
      
      assign chi_data[0][x] = sheet2[0] ^ phase2_in[0][x];
      assign chi_data[1][x] = sheet2[1] ^ phase2_in[1][x];
    end : g_chi_w
    
    
    for (genvar x = 0 ; x < 5 ; x++) begin : g_2share_phase2_out_row
      for (genvar y = 0 ; y < 5 ; y++) begin : g_2share_phase2_out_col
        assign phase2_out[0][x][y] = dom_out_low_i ?
            { state_in[0][x][y][W-1:W/2], iota_data[0][x][y][W/2-1:0]} :
            {iota_data[0][x][y][W-1:W/2],  state_in[0][x][y][W/2-1:0]};
        assign phase2_out[1][x][y] = dom_out_low_i ?
            { state_in[1][x][y][W-1:W/2], iota_data[1][x][y][W/2-1:0]} :
            {iota_data[1][x][y][W-1:W/2],  state_in[1][x][y][W/2-1:0]};
      end
    end
  end else begin : g_single_chi
    assign chi_data[0] = chi(phase2_in[0]);
    assign phase2_out = iota_data;
  end
  
  
  
  
  localparam int RhoOffset [25]  = '{
    
         0,  36,   3, 105, 210, 
         1, 300,  10,  45,  66, 
       190,   6, 171,  15, 253, 
        28,  55, 153,  21, 120, 
        91, 276, 231, 136,  78  
  };
  for (genvar i = 0 ; i < Share ; i++) begin : g_rho
    box_t rho_in, rho_out;
    assign rho_in = theta_data[i];
    assign rho_data[i] = rho_out;
    for (genvar x = 0 ; x < 5 ; x++) begin : gen_rho_x
      for (genvar y = 0 ; y < 5 ; y++) begin : gen_rho_y
        localparam int Offset = RhoOffset[5*x+y]%W;
        localparam int ShiftAmt = W- Offset;
        if (Offset == 0) begin : gen_offset0
          assign rho_out[x][y][W-1:0] = rho_in[x][y][W-1:0];
        end else begin : gen_others
          assign rho_out[x][y][W-1:0] = {rho_in[x][y][0+:ShiftAmt],
                                         rho_in[x][y][ShiftAmt+:Offset]};
        end
      end
    end
  end : g_rho
  
  
  
  `ASSERT_INIT(ValidWidth_A,
      EnMasking == 0 && Width inside {25, 50, 100, 200, 400, 800, 1600} ||
      EnMasking == 1 && Width inside {50, 100, 200, 400, 800, 1600})
  `ASSERT_INIT(ValidW_A, W inside {1, 2, 4, 8, 16, 32, 64})
  `ASSERT_INIT(ValidL_A, L inside {0, 1, 2, 3, 4, 5, 6})
  `ASSERT_INIT(ValidRound_A, MaxRound <= 24) 
  
  lc_ctrl_pkg::lc_tx_t unused_lc_sig;
  assign unused_lc_sig = lc_escalate_en_i;
  if (EnMasking) begin : gen_selperiod_chk
    `ASSUME(SelStayTwoCycleIfTrue_A,
        ($past(phase_sel_i) == MuBi4False) && (phase_sel_i == MuBi4True)
        |=> phase_sel_i == MuBi4True, clk_i, !rst_ni ||
            lc_ctrl_pkg::lc_tx_test_true_loose(lc_escalate_en_i))
  end
  
  
  
  
  
  
  
  
  function automatic box_t bitarray_to_box(logic [Width-1:0] s_in);
    automatic box_t box;
    for (int y = 0 ; y < 5 ; y++) begin
      for (int x = 0 ; x < 5 ; x++) begin
        for (int z = 0 ; z < W ; z++) begin
          box[x][y][z] = s_in[W*(5*y+x) + z];
        end
      end
    end
    return box;
  endfunction : bitarray_to_box
  
  function automatic logic [Width-1:0] box_to_bitarray(box_t state);
    automatic logic [Width-1:0] bitarray;
    for (int y = 0 ; y < 5 ; y++) begin
      for (int x = 0 ; x < 5 ; x++) begin
        for (int z = 0 ; z < W ; z++) begin
          bitarray[W*(5*y+x)+z] = state[x][y][z];
        end
      end
    end
    return bitarray;
  endfunction : box_to_bitarray
  
  function automatic integer rot_int(integer in, integer num);
    integer out;
    if (in == 0) begin
      out = num - 1;
    end else begin
      out = in - 1;
    end
    return out;
  endfunction
  
  
  
  
  
  
  localparam int ThetaIndexX1 [5] = '{4, 0, 1, 2, 3}; 
  localparam int ThetaIndexX2 [5] = '{1, 2, 3, 4, 0}; 
  function automatic box_t theta(box_t state);
    plane_t c;
    plane_t d;
    box_t result;
    for (int x = 0 ; x < 5 ; x++) begin
      c[x] = state[x][0] ^ state[x][1] ^ state[x][2] ^ state[x][3] ^ state[x][4];
    end
    for (int x = 0 ; x < 5 ; x++) begin
      for (int z = 0 ; z < W ; z++) begin
        int index_z;
        index_z = (z == 0) ? W-1 : z-1; 
        d[x][z] = c[ThetaIndexX1[x]][z] ^ c[ThetaIndexX2[x]][index_z];
      end
    end
    for (int x = 0 ; x < 5 ; x++) begin
      for (int y = 0 ; y < 5 ; y++) begin
        result[x][y] = state[x][y] ^ d[x];
      end
    end
    return result;
  endfunction : theta
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  localparam int PiRotate [5][5] = '{
    
    '{   0,   3,   1,   4,   2},
    '{   1,   4,   2,   0,   3},
    '{   2,   0,   3,   1,   4},
    '{   3,   1,   4,   2,   0},
    '{   4,   2,   0,   3,   1} 
  };
  function automatic box_t pi(box_t state);
    box_t result;
    for (int x = 0 ; x < 5 ; x++) begin
      for (int y = 0 ; y < 5 ; y++) begin
        result[x][y][W-1:0] = state[PiRotate[x][y]][x][W-1:0];
      end
    end
    return result;
  endfunction : pi
  
  
  localparam int ChiIndexX1 [5] = '{1, 2, 3, 4, 0}; 
  localparam int ChiIndexX2 [5] = '{2, 3, 4, 0, 1}; 
  function automatic box_t chi(box_t state);
    box_t result;
    for (int x = 0 ; x < 5 ; x++) begin
      result[x] = state[x] ^ ((~state[ChiIndexX1[x]]) & state[ChiIndexX2[x]]);
    end
    return result;
  endfunction : chi
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  localparam logic [63:0] RC [24] = '{
     64'h 0000_0000_0000_0001, 
     64'h 0000_0000_0000_8082, 
     64'h 8000_0000_0000_808A, 
     64'h 8000_0000_8000_8000, 
     64'h 0000_0000_0000_808B, 
     64'h 0000_0000_8000_0001, 
     64'h 8000_0000_8000_8081, 
     64'h 8000_0000_0000_8009, 
     64'h 0000_0000_0000_008A, 
     64'h 0000_0000_0000_0088, 
     64'h 0000_0000_8000_8009, 
     64'h 0000_0000_8000_000A, 
     64'h 0000_0000_8000_808B, 
     64'h 8000_0000_0000_008B, 
     64'h 8000_0000_0000_8089, 
     64'h 8000_0000_0000_8003, 
     64'h 8000_0000_0000_8002, 
     64'h 8000_0000_0000_0080, 
     64'h 0000_0000_0000_800A, 
     64'h 8000_0000_8000_000A, 
     64'h 8000_0000_8000_8081, 
     64'h 8000_0000_0000_8080, 
     64'h 0000_0000_8000_0001, 
     64'h 8000_0000_8000_8008  
  };
  
  function automatic box_t iota(box_t state, logic [RndW-1:0] rnd);
    box_t result;
    result = state;
    result[0][0][W-1:0] = state[0][0][W-1:0] ^ RC[rnd][W-1:0];
    return result;
  endfunction : iota
  
  
  
  
  
  
  
  
endmodule

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
module TopModule
  import prim_mubi_pkg::*;
#(
  parameter int Width = 1600, 
  
  localparam int W        = Width/25,
  localparam int L        = $clog2(W),
  localparam int MaxRound = 12 + 2*L,           
  localparam int RndW     = $clog2(MaxRound+1), 
  
  parameter  int DInWidth = 64, 
  localparam int DInEntry = Width / DInWidth,
  localparam int DInAddr  = $clog2(DInEntry),
  
  parameter  bit EnMasking    = 1'b0,  
  parameter  bit ForceRandExt = 1'b0,  
                                       
                                       
  localparam int Share        = EnMasking ? 2 : 1
) (
  input clk_i,
  input rst_ni,
  
  input                valid_i,
  input [DInAddr-1:0]  addr_i,
  input [DInWidth-1:0] data_i [Share],
  output               ready_o,
  
  input                    run_i,  
  input                    rand_valid_i,
  input                    rand_early_i,
  input      [Width/2-1:0] rand_data_i,
  input                    rand_aux_i,
  output logic             rand_update_o,
  output logic             rand_consumed_o,
  output logic             complete_o, 
  
  output logic [Width-1:0] state_o [Share],
  
  input  lc_ctrl_pkg::lc_tx_t lc_escalate_en_i,
  
  
  output logic             sparse_fsm_error_o,
  
  output logic             round_count_error_o,
  
  
  output logic             rst_storage_error_o,
  input  prim_mubi_pkg::mubi4_t clear_i     
);
  import sha3_pkg::*;
  
  
  
  
  logic update_storage;
  
  logic rst_storage;
  
  
  
  logic xor_message;
  
  
  
  
  mubi4_t phase_sel;
  
  
  
  logic low_then_high_d, low_then_high_q;
  
  
  logic dom_out_low_d, dom_out_low_q;
  logic dom_in_low_d, dom_in_low_q;
  
  
  logic dom_in_rand_ext_d, dom_in_rand_ext_q;
  
  
  logic dom_update;
  
  logic inc_rnd_num;
  logic rst_rnd_num;
  
  
  
  logic rnd_eq_end;
  
  
  
  
  
  
  
  
  
  logic complete_d;
  
  
  
  
  logic [Width-1:0] keccak_out [Share];
  
  logic [RndW-1:0] round;
  
  logic               keccak_rand_update;
  logic               keccak_rand_consumed;
  logic [Width/2-1:0] keccak_rand_data;
  
  
  
  
  assign rnd_eq_end = (int'(round) == MaxRound - 1);
  keccak_st_e keccak_st, keccak_st_d;
  `PRIM_FLOP_SPARSE_FSM(u_state_regs, keccak_st_d, keccak_st, keccak_st_e, KeccakStIdle)
  
  
  always_comb begin
    
    keccak_st_d = keccak_st;
    xor_message    = 1'b 0;
    update_storage = 1'b 0;
    rst_storage    = 1'b 0;
    inc_rnd_num = 1'b 0;
    rst_rnd_num = 1'b 0;
    keccak_rand_update   = 1'b 0;
    keccak_rand_consumed = 1'b 0;
    phase_sel = MuBi4False;
    low_then_high_d = low_then_high_q;
    dom_in_low_d = dom_in_low_q;
    dom_in_rand_ext_d = dom_in_rand_ext_q;
    dom_update = 1'b 0;
    complete_d = 1'b 0;
    sparse_fsm_error_o = 1'b 0;
    unique case (keccak_st)
      KeccakStIdle: begin
        if (valid_i) begin
          
          keccak_st_d = KeccakStIdle;
          xor_message    = 1'b 1;
          update_storage = 1'b 1;
        end else if (prim_mubi_pkg::mubi4_test_true_strict(clear_i)) begin
          
          
          
          
          keccak_st_d = KeccakStIdle;
          rst_storage = 1'b 1;
        end else if (EnMasking && run_i) begin
          
          keccak_st_d = KeccakStPhase1;
          
          dom_in_low_d = low_then_high_q;
          dom_in_rand_ext_d = 1'b 0;
        end else if (!EnMasking && run_i) begin
          
          keccak_st_d = KeccakStActive;
        end else begin
          keccak_st_d = KeccakStIdle;
        end
      end
      KeccakStActive: begin
        
        update_storage = 1'b 1;
        if (rnd_eq_end) begin
          keccak_st_d = KeccakStIdle;
          rst_rnd_num = 1'b 1;
          complete_d  = 1'b 1;
        end else begin
          keccak_st_d = KeccakStActive;
          inc_rnd_num = 1'b 1;
        end
      end
      KeccakStPhase1: begin
        
        
        
        
        phase_sel = MuBi4False;
        dom_update = 1'b 0;
        
        
        
        
        
        
        
        
        
        if (rand_early_i || rand_valid_i) begin
          keccak_st_d = KeccakStPhase2Cycle1;
          update_storage = 1'b 1;
          keccak_rand_update = 1'b 1;
          
          low_then_high_d = rand_aux_i;
          
          dom_in_low_d = low_then_high_d;
          dom_in_rand_ext_d = 1'b 1;
        end else begin
          keccak_st_d = KeccakStPhase1;
        end
      end
      KeccakStPhase2Cycle1: begin
        
        
        
        phase_sel = MuBi4True;
        dom_update = 1'b 1;
        
        
        
        
        
        
        keccak_rand_update = 1'b 1;
        
        keccak_st_d = KeccakStPhase2Cycle2;
        
        dom_in_low_d = ~low_then_high_q;
        dom_in_rand_ext_d = 1'b 1;
      end
      KeccakStPhase2Cycle2: begin
        
        
        
        
        
        phase_sel = MuBi4True;
        dom_update = 1'b 1;
        
        
        
        
        
        
        
        keccak_rand_update = 1'b 1;
        
        
        
        
        keccak_rand_consumed = 1'b 1;
        
        update_storage = 1'b 1;
        
        keccak_st_d = KeccakStPhase2Cycle3;
        
        dom_in_low_d = low_then_high_q;
        dom_in_rand_ext_d = 1'b 0;
      end
      KeccakStPhase2Cycle3: begin
        
        
        
        
        
        phase_sel = MuBi4True;
        dom_update = 1'b 0;
        
        
        
        
        
        
        update_storage = 1'b 1;
        if (rnd_eq_end) begin
          
          keccak_st_d = KeccakStIdle;
          rst_rnd_num    = 1'b 1;
          complete_d     = 1'b 1;
        end else begin
          
          keccak_st_d = KeccakStPhase1;
          inc_rnd_num = 1'b 1;
          
          dom_in_low_d = low_then_high_q;
          dom_in_rand_ext_d = 1'b 0;
        end
      end
      KeccakStError: begin
        keccak_st_d = KeccakStError;
      end
      KeccakStTerminalError: begin
        
        keccak_st_d = keccak_st;
        sparse_fsm_error_o = 1'b 1;
      end
      default: begin
        keccak_st_d = KeccakStTerminalError;
        sparse_fsm_error_o = 1'b 1;
      end
    endcase
    
    
    
    if (lc_ctrl_pkg::lc_tx_test_true_loose(lc_escalate_en_i)) begin
      keccak_st_d = KeccakStTerminalError;
    end
  end
  
  
  assign dom_out_low_d = ~dom_in_low_d;
  if (EnMasking) begin : gen_regs_dom_ctrl
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        low_then_high_q <= 1'b 0;
        dom_out_low_q <= 1'b 0;
        dom_in_low_q <= 1'b 0;
      end else begin
        low_then_high_q <= low_then_high_d;
        dom_out_low_q <= dom_out_low_d;
        dom_in_low_q <= dom_in_low_d;
      end
    end
    if (!ForceRandExt) begin : gen_reg_dom_in_rand_ext
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          dom_in_rand_ext_q <= 1'b 0;
        end else begin
          dom_in_rand_ext_q <= dom_in_rand_ext_d;
        end
      end
    end else begin : gen_force_dom_in_rand_ext
      
      assign dom_in_rand_ext_q = 1'b 1;
      
      logic unused_dom_in_rand_ext;
      assign unused_dom_in_rand_ext = dom_in_rand_ext_d;
    end
  end else begin : gen_no_regs_dom_ctrl
    logic unused_dom_ctrl;
    assign unused_dom_ctrl =
        ^{low_then_high_d, dom_out_low_d, dom_in_low_d, dom_in_rand_ext_d};
    assign low_then_high_q = 1'b 0;
    assign dom_out_low_q = 1'b 0;
    assign dom_in_low_q = 1'b 0;
    assign dom_in_rand_ext_q = 1'b 0;
  end
  
  
  
  assign ready_o = (keccak_st == KeccakStIdle) ? 1'b 1 : 1'b 0;
  
  
  
  
  logic rst_n;
  prim_sec_anchor_buf #(
   .Width(1)
  ) u_prim_sec_anchor_buf (
    .in_i(rst_ni),
    .out_o(rst_n)
  );
  logic [Width-1:0] storage   [Share];
  logic [Width-1:0] storage_d [Share];
  always_ff @(posedge clk_i or negedge rst_n) begin
    if (!rst_n) begin
      storage <= '{default:'0};
    end else if (rst_storage) begin
      storage <= '{default:'0};
    end else if (update_storage) begin
      storage <= storage_d;
    end
  end
  assign state_o = storage;
  
  
  
  
  always_comb begin
    storage_d = keccak_out;
    if (xor_message) begin
      for (int j = 0 ; j < Share ; j++) begin
        for (int unsigned i = 0 ; i < DInEntry ; i++) begin
          
          
          
          if (addr_i == i[DInAddr-1:0]) begin
            storage_d[j][i*DInWidth+:DInWidth] =
              storage[j][i*DInWidth+:DInWidth] ^ data_i[j];
          end else begin
            storage_d[j][i*DInWidth+:DInWidth] = storage[j][i*DInWidth+:DInWidth];
          end
        end 
      end 
    end 
  end
  
  logic rst_storage_error;
  always_comb begin : chk_rst_storage
    rst_storage_error = 1'b 0;
    if (rst_storage) begin
      
      if ((keccak_st != KeccakStIdle) ||
        prim_mubi_pkg::mubi4_test_false_loose(clear_i)) begin
        rst_storage_error = 1'b 1;
      end
    end
  end : chk_rst_storage
  assign rst_storage_error_o = rst_storage_error ;
  
  
  
  keccak_2share #(
    .Width(Width),
    .EnMasking(EnMasking),
    .ForceRandExt(ForceRandExt)
  ) u_keccak_p (
    .clk_i,
    .rst_ni,
    .lc_escalate_en_i,
    .rnd_i(round),
    .phase_sel_i      (phase_sel),
    .dom_out_low_i    (dom_out_low_q),
    .dom_in_low_i     (dom_in_low_q),
    .dom_in_rand_ext_i(dom_in_rand_ext_q),
    .dom_update_i     (dom_update),
    .rand_i(keccak_rand_data),
    .s_i(storage),
    .s_o(keccak_out)
  );
  
  assign rand_update_o   = keccak_rand_update;
  assign rand_consumed_o = keccak_rand_consumed;
  assign keccak_rand_data = rand_data_i;
  
  
  
  prim_count #(
    .Width(RndW)
  ) u_round_count (
    .clk_i,
    .rst_ni,
    .clr_i(rst_rnd_num),
    .set_i(1'b0),
    .set_cnt_i('0),
    .incr_en_i(inc_rnd_num),
    .decr_en_i(1'b0),
    .step_i(RndW'(1)),
    .commit_i(1'b1),
    .cnt_o(round),
    .cnt_after_commit_o(),
    .err_o(round_count_error_o)
  );
  
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      complete_o <= 1'b 0;
    end else begin
      complete_o <= complete_d;
    end
  end
  
  
  
  
  `ASSERT_INIT(WidthDivisableByDInWidth_A, (Width % DInWidth) == 0)
  
  
  
  `ASSUME(OneHot0ValidAndRun_A, $onehot0({valid_i, run_i}), clk_i, !rst_ni)
  
  `ASSUME(ValidRunAssertStIdle_A, valid_i || run_i |-> keccak_st == KeccakStIdle, clk_i, !rst_ni)
  
  `ASSUME(ClearAssertStIdle_A,
    prim_mubi_pkg::mubi4_test_true_strict(clear_i)
     |-> keccak_st == KeccakStIdle, clk_i, !rst_ni)
  
  if (EnMasking) begin : gen_mask_st_chk
    `ASSERT(EnMaskingValidStates_A, keccak_st != KeccakStActive, clk_i, !rst_ni)
  end else begin : gen_unmask_st_chk
    `ASSERT(UnmaskValidStates_A, !(keccak_st
        inside {KeccakStPhase1, KeccakStPhase2Cycle1, KeccakStPhase2Cycle2, KeccakStPhase2Cycle3}),
        clk_i, !rst_ni)
  end
endmodule

package sha3_pkg;
  
  
  
  
  parameter int StateW = 1600;
  
  
  parameter int FnWidth = 32;  
  parameter int CsWidth = 256; 
  
  
  
  
  parameter int MaxFnEncodeSize = ($clog2(FnWidth+1) + 8 - 1) / 8 + 1;
  parameter int MaxCsEncodeSize = ($clog2(CsWidth+1) + 8 - 1) / 8 + 1;
  parameter int NSRegisterSizePre = FnWidth/8       + CsWidth/8
                                  + MaxFnEncodeSize + MaxCsEncodeSize;
  
  parameter int NSRegisterSize = ((NSRegisterSizePre + 4 - 1 ) / 4) * 4;
  
  
  
  
  parameter int PrefixSize = NSRegisterSize + 2;
  
  parameter int PrefixIndexW = $clog2(PrefixSize/64);
  
  
  
  
  
  
  
  
  
  
  parameter int MsgWidth = 64;
  parameter int MsgStrbW = MsgWidth / 8;
  
  
  
  
  
  
  
  
  
  
  
  
  typedef enum logic[1:0] {
    Sha3   = 2'b 00,
    Shake  = 2'b 10,
    CShake = 2'b 11
  } sha3_mode_e;
  
  
  
  
  typedef enum logic [2:0] {
    L128 = 3'b 000, 
    L224 = 3'b 001, 
    L256 = 3'b 010, 
    L384 = 3'b 011, 
    L512 = 3'b 100  
  } keccak_strength_e;
  parameter int unsigned KeccakRate [5] = '{
    1344/MsgWidth,  
    1152/MsgWidth,  
    1088/MsgWidth,  
     832/MsgWidth,  
     576/MsgWidth   
  };
  parameter int unsigned KeccakBitCapacity [5] = '{
    2 * 128, 
    2 * 224, 
    2 * 256, 
    2 * 384, 
    2 * 512  
  };
  parameter int unsigned MaxBlockSize = KeccakRate[0];
  parameter int unsigned KeccakEntries = 1600/MsgWidth;
  parameter int unsigned KeccakMsgAddrW = $clog2(KeccakEntries);
  parameter int unsigned KeccakCountW = $clog2(KeccakEntries+1);
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  localparam int StateWidth = 6;
  typedef enum logic [StateWidth-1:0] {
    StIdle_sparse = 6'b101100,
    
    
    
    
    
    StAbsorb_sparse = 6'b100001,
    
    
    
    
    
    
    
    
    
    
    
    
    StSqueeze_sparse = 6'b001011,
    
    
    
    StManualRun_sparse = 6'b010000,
    
    
    StFlush_sparse =  6'b000110,
    StTerminalError_sparse = 6'b111010
  } sha3_st_sparse_e;
  localparam int StateWidthLogic = 3;
  typedef enum logic [StateWidthLogic-1:0] {
    StIdle,
    StAbsorb,
    
    StSqueeze,
    StManualRun,
    StFlush,
    StError
  } sha3_st_e;
  function automatic sha3_st_e sparse2logic(sha3_st_sparse_e st);
    unique case (st)
      StIdle_sparse      : return StIdle;
      StAbsorb_sparse    : return StAbsorb;
      
      StSqueeze_sparse   : return StSqueeze;
      StManualRun_sparse : return StManualRun;
      StFlush_sparse     : return StFlush;
      default            : return StError;
    endcase
  endfunction : sparse2logic
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  localparam int KeccakFsmWidth = 6;
  typedef enum logic [KeccakFsmWidth-1:0] {
    KeccakStIdle = 6'b011111,
    
    
    KeccakStActive = 6'b000100,
    
    
    
    
    
    KeccakStPhase1 = 6'b101101,
    
    KeccakStPhase2Cycle1 = 6'b000011,
    
    
    KeccakStPhase2Cycle2 = 6'b011000,
    
    
    
    KeccakStPhase2Cycle3 = 6'b101010,
    
    
    
    KeccakStError = 6'b110001,
    KeccakStTerminalError = 6'b110110
  } keccak_st_e;
  
  
  
  typedef enum logic [7:0] {
    ErrNone = 8'h 00,
    
    
    
    ErrSha3SwControl = 8'h 80
  } err_code_e;
  typedef struct packed {
    logic        valid;
    err_code_e   code; 
    logic [23:0] info; 
  } err_t;
  
  
  
  
  
  
  
  
  function automatic logic [15:0] encode_bytepad_len(keccak_strength_e kstrength);
    logic [15:0] result;
    unique case (kstrength)
      L128: result = 16'h A801; 
      L224: result = 16'h 9001; 
      L256: result = 16'h 8801; 
      L384: result = 16'h 6801; 
      L512: result = 16'h 4801; 
      default: result = 16'h 0000;
    endcase
    return result;
  endfunction : encode_bytepad_len
endpackage : sha3_pkg
