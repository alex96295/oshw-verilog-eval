
package top_pkg;
localparam int TL_AW=32;
localparam int TL_DW=32;    
localparam int TL_AIW=8;    
localparam int TL_DIW=1;    
localparam int TL_AUW=23;   
localparam int TL_DUW=14;   
localparam int TL_DBW=(TL_DW>>3);
localparam int TL_SZW=$clog2($clog2(TL_DBW)+1);
localparam int unsigned AlertSkewCycles = 1;
localparam int SecVolatileRawUnlockEn = 0;
endpackage

package prim_alert_pkg;
  typedef struct packed {
    logic alert_p;
    logic alert_n;
  } alert_tx_t;
  typedef struct packed {
    logic ping_p;
    logic ping_n;
    logic ack_p;
    logic ack_n;
  } alert_rx_t;
  parameter alert_tx_t ALERT_TX_DEFAULT = '{alert_p:  1'b0,
                                            alert_n:  1'b1};
  parameter alert_rx_t ALERT_RX_DEFAULT = '{ping_p: 1'b0,
                                            ping_n: 1'b1,
                                            ack_p: 1'b0,
                                            ack_n: 1'b1};
endpackage : prim_alert_pkg

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
module prim_alert_sender
  import prim_alert_pkg::*;
#(
  
  parameter bit AsyncOn = 1'b1,
  
  parameter int unsigned SkewCycles = 1,
  
  
  parameter bit IsFatal = 1'b0
) (
  input             clk_i,
  input             rst_ni,
  
  input             alert_test_i,
  
  input             alert_req_i,
  output logic      alert_ack_o,
  
  output logic      alert_state_o,
  
  input alert_rx_t  alert_rx_i,
  
  output alert_tx_t alert_tx_o
);
  
  
  
  logic ping_sigint, ping_event, ping_n, ping_p;
  
  prim_sec_anchor_buf #(
    .Width(2)
  ) u_prim_buf_ping (
    .in_i({alert_rx_i.ping_n,
           alert_rx_i.ping_p}),
    .out_o({ping_n,
            ping_p})
  );
  prim_diff_decode #(
    .AsyncOn(AsyncOn),
    .SkewCycles(SkewCycles)
  ) u_decode_ping (
    .clk_i,
    .rst_ni,
    .diff_pi  ( ping_p      ),
    .diff_ni  ( ping_n      ),
    .level_o  (             ),
    .rise_o   (             ),
    .fall_o   (             ),
    .event_o  ( ping_event  ),
    .sigint_o ( ping_sigint )
  );
  logic ack_sigint, ack_level, ack_n, ack_p;
  
  prim_sec_anchor_buf #(
    .Width(2)
  ) u_prim_buf_ack (
    .in_i({alert_rx_i.ack_n,
           alert_rx_i.ack_p}),
    .out_o({ack_n,
            ack_p})
  );
  prim_diff_decode #(
    .AsyncOn(AsyncOn),
    .SkewCycles(SkewCycles)
  ) u_decode_ack (
    .clk_i,
    .rst_ni,
    .diff_pi  ( ack_p      ),
    .diff_ni  ( ack_n      ),
    .level_o  ( ack_level  ),
    .rise_o   (            ),
    .fall_o   (            ),
    .event_o  (            ),
    .sigint_o ( ack_sigint )
  );
  
  
  
  typedef enum logic [2:0] {
    Idle,
    AlertHsPhase1,
    AlertHsPhase2,
    PingHsPhase1,
    PingHsPhase2,
    Pause0,
    Pause1
    } state_e;
  state_e state_d, state_q;
  logic alert_pq, alert_nq, alert_pd, alert_nd;
  logic sigint_detected;
  assign sigint_detected = ack_sigint | ping_sigint;
  
  assign alert_tx_o.alert_p = alert_pq;
  assign alert_tx_o.alert_n = alert_nq;
  
  logic alert_set_d, alert_set_q, alert_clr;
  logic alert_test_set_d, alert_test_set_q;
  logic ping_set_d, ping_set_q, ping_clr;
  logic alert_req_trigger, alert_test_trigger, ping_trigger;
  
  logic alert_req;
  prim_sec_anchor_buf #(
    .Width(1)
  ) u_prim_buf_in_req (
    .in_i(alert_req_i),
    .out_o(alert_req)
  );
  assign alert_req_trigger = alert_req | alert_set_q;
  if (IsFatal) begin : gen_fatal
    assign alert_set_d = alert_req_trigger;
  end else begin : gen_recov
    assign alert_set_d = (alert_clr) ? 1'b0 : alert_req_trigger;
  end
  
  assign alert_test_trigger = alert_test_i | alert_test_set_q;
  assign alert_test_set_d = (alert_clr) ? 1'b0 : alert_test_trigger;
  logic alert_trigger;
  assign alert_trigger = alert_req_trigger | alert_test_trigger;
  assign ping_trigger = ping_set_q | ping_event;
  assign ping_set_d  = (ping_clr) ? 1'b0 : ping_trigger;
  
  assign alert_ack_o = alert_clr & alert_set_q;
  assign alert_state_o = alert_set_q;
  
  
  
  
  
  
  always_comb begin : p_fsm
    
    state_d   = state_q;
    alert_pd  = 1'b0;
    alert_nd  = 1'b1;
    ping_clr  = 1'b0;
    alert_clr = 1'b0;
    unique case (state_q)
      Idle: begin
        
        if (alert_trigger || ping_trigger) begin
          state_d = (alert_trigger) ? AlertHsPhase1 : PingHsPhase1;
          alert_pd = 1'b1;
          alert_nd = 1'b0;
        end
      end
      
      AlertHsPhase1: begin
        if (ack_level) begin
          state_d  = AlertHsPhase2;
        end else begin
          alert_pd = 1'b1;
          alert_nd = 1'b0;
        end
      end
      
      AlertHsPhase2: begin
        if (!ack_level) begin
          state_d = Pause0;
          alert_clr = 1'b1;
        end
      end
      
      PingHsPhase1: begin
        if (ack_level) begin
          state_d  = PingHsPhase2;
        end else begin
          alert_pd = 1'b1;
          alert_nd = 1'b0;
        end
      end
      
      PingHsPhase2: begin
        if (!ack_level) begin
          ping_clr = 1'b1;
          state_d = Pause0;
        end
      end
      
      Pause0: begin
        state_d = Pause1;
      end
      
      Pause1: begin
        state_d = Idle;
      end
      
      default : state_d = Idle;
    endcase
    
    
    
    if (sigint_detected) begin
      state_d   = Idle;
      alert_pd  = 1'b0;
      alert_nd  = 1'b0;
      ping_clr  = 1'b1;
      alert_clr = 1'b0;
    end
  end
  
  prim_sec_anchor_flop #(
    .Width     (2),
    .ResetValue(2'b10)
  ) u_prim_flop_alert (
    .clk_i,
    .rst_ni,
    .d_i({alert_nd, alert_pd}),
    .q_o({alert_nq, alert_pq})
  );
  always_ff @(posedge clk_i or negedge rst_ni) begin : p_reg
    if (!rst_ni) begin
      state_q          <= Idle;
      alert_set_q      <= 1'b0;
      alert_test_set_q <= 1'b0;
      ping_set_q       <= 1'b0;
    end else begin
      state_q          <= state_d;
      alert_set_q      <= alert_set_d;
      alert_test_set_q <= alert_test_set_d;
      ping_set_q       <= ping_set_d;
    end
  end
  
  
  
`ifdef INC_ASSERT
  
  `ASSERT_KNOWN(AlertPKnownO_A, alert_tx_o)
  if (AsyncOn) begin : gen_async_assert
    sequence PingSigInt_S;
      alert_rx_i.ping_p == alert_rx_i.ping_n [*2];
    endsequence
    sequence AckSigInt_S;
      alert_rx_i.ping_p == alert_rx_i.ping_n [*2];
    endsequence
  `ifndef FPV_ALERT_NO_SIGINT_ERR
    
    
    `ASSERT(SigIntPing_A, ##1 PingSigInt_S |->
        ##[SkewCycles+2:SkewCycles+3] alert_tx_o.alert_p == alert_tx_o.alert_n)
    `ASSERT(SigIntAck_A, ##1 AckSigInt_S |->
        ##[SkewCycles+2:SkewCycles+3] alert_tx_o.alert_p == alert_tx_o.alert_n)
  `endif
    
    `ASSERT(InBandInitFsm_A, PingSigInt_S or AckSigInt_S |->
        ##[SkewCycles+2:SkewCycles+3] state_q == Idle)
    `ASSERT(InBandInitPing_A, PingSigInt_S or AckSigInt_S |->
        ##[SkewCycles+2:SkewCycles+3] !ping_set_q)
    
    `ASSERT(DiffEncoding_A, (alert_rx_i.ack_p ^ alert_rx_i.ack_n) &&
        (alert_rx_i.ping_p ^ alert_rx_i.ping_n) |->
        ##[SkewCycles+2:SkewCycles+4] alert_tx_o.alert_p ^ alert_tx_o.alert_n)
    
    
    
    `ASSERT(PingHs_A, ##1 $changed(alert_rx_i.ping_p) &&
        (alert_rx_i.ping_p ^ alert_rx_i.ping_n) ##2 state_q == Idle |=>
        ##[0:1] $rose(alert_tx_o.alert_p), clk_i,
        !rst_ni || (alert_tx_o.alert_p == alert_tx_o.alert_n))
  end else begin : gen_sync_assert
    sequence PingSigInt_S;
      alert_rx_i.ping_p == alert_rx_i.ping_n;
    endsequence
    sequence AckSigInt_S;
      alert_rx_i.ping_p == alert_rx_i.ping_n;
    endsequence
  `ifndef FPV_ALERT_NO_SIGINT_ERR
    
    `ASSERT(SigIntPing_A, PingSigInt_S |=>
        alert_tx_o.alert_p == alert_tx_o.alert_n)
    `ASSERT(SigIntAck_A,  AckSigInt_S |=>
        alert_tx_o.alert_p == alert_tx_o.alert_n)
  `endif
    
    `ASSERT(InBandInitFsm_A, PingSigInt_S or AckSigInt_S |=> state_q == Idle)
    `ASSERT(InBandInitPing_A, PingSigInt_S or AckSigInt_S |=> !ping_set_q)
    
    `ASSERT(DiffEncoding_A, (alert_rx_i.ack_p ^ alert_rx_i.ack_n) &&
        (alert_rx_i.ping_p ^ alert_rx_i.ping_n) |=> alert_tx_o.alert_p ^ alert_tx_o.alert_n)
    
    
    
    `ASSERT(PingHs_A, ##1 $changed(alert_rx_i.ping_p) && state_q == Idle |=>
        $rose(alert_tx_o.alert_p), clk_i, !rst_ni || (alert_tx_o.alert_p == alert_tx_o.alert_n))
  end
  
  `ASSERT(AlertState0_A, alert_set_q === alert_state_o)
  if (IsFatal) begin : gen_fatal_assert
    `ASSERT(AlertState1_A, alert_req_i |=> alert_state_o)
    `ASSERT(AlertState2_A, alert_state_o |=> $stable(alert_state_o))
    `ASSERT(AlertState3_A, alert_ack_o |=> alert_state_o)
  end else begin : gen_recov_assert
    `ASSERT(AlertState1_A, alert_req_i && !alert_clr |=> alert_state_o)
    `ASSERT(AlertState2_A, alert_req_i && alert_ack_o |=> !alert_state_o)
  end
  
  `ASSERT(AlertTest1_A, alert_test_i && !alert_req_i && !alert_state_o |=> $stable(alert_state_o))
  
  `ASSERT(AlertHs_A, alert_req_i && state_q == Idle |=> $rose(alert_tx_o.alert_p),
      clk_i, !rst_ni || (alert_tx_o.alert_p == alert_tx_o.alert_n))
  
  `ASSERT(AlertTestHs_A, alert_test_i && state_q == Idle |=> $rose(alert_tx_o.alert_p),
      clk_i, !rst_ni || (alert_tx_o.alert_p == alert_tx_o.alert_n))
`endif
`ifdef FPV_ALERT_NO_SIGINT_ERR
  
  `ASSUME_FPV(AckPFollowsAlertP_S, alert_rx_i.ack_p == $past(alert_tx_o.alert_p))
  `ASSUME_FPV(AckNFollowsAlertN_S, alert_rx_i.ack_n == $past(alert_tx_o.alert_n))
  `ASSUME_FPV(TriggerAlertInit_S, $stable(rst_ni) == 0 |=> alert_rx_i.ping_p == alert_rx_i.ping_n)
  `ASSUME_FPV(PingDiffPair_S, ##2 alert_rx_i.ping_p != alert_rx_i.ping_n)`endif
endmodule : prim_alert_sender

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
module prim_ascon_duplex
  import prim_ascon_pkg::*;
 (
  input logic clk_i,
  input logic rst_ni,
  input duplex_variant_e ascon_variant,
  input duplex_op_e ascon_operation,
  input  logic start_i,
  output logic done_o,
  output prim_mubi_pkg::mubi4_t idle_o,
  
  
  input prim_mubi_pkg::mubi4_t no_ad_i,
  input prim_mubi_pkg::mubi4_t no_msg_i,
  input logic [127:0] key_i,
  input logic [127:0] nonce_i,
  
  input  logic [127:0]          data_in_i,
  input  logic   [4:0]          data_in_valid_bytes_i,
  input  prim_mubi_pkg::mubi4_t last_block_ad_i,
  input  prim_mubi_pkg::mubi4_t last_block_msg_i,
  input  logic                  data_in_valid_i,
  output logic                  data_in_ready_o,
  
  output logic [127:0] data_out_o,
  input  logic         data_out_ready_i,
  output logic         data_out_valid_o,
  output logic [127:0] tag_out_o,
  output logic         tag_out_valid_o,
  output duplex_fsm_state_e fsm_state_o,
  output logic err_o
);
logic unused_data_out_ready_i;
assign unused_data_out_ready_i = data_out_ready_i;
logic round_count_error;
logic sparse_fsm_error;
logic set_round_counter;
logic inc_round_counter;
logic [4:0][63:0] ascon_state_q, ascon_state_d;
always_ff @(posedge clk_i or negedge rst_ni) begin : ascon_state_reg
  if (!rst_ni) begin
    ascon_state_q <= '0;
  end else begin
    ascon_state_q <= ascon_state_d;
  end
end
logic [319:0] state_to_round;
logic [319:0] state_from_round;
logic [4:0][63:0] round_to_mux;
assign round_to_mux = state_from_round;
duplex_fsm_state_e fsm_state_d, fsm_state_q;
perm_offset_e perm_offset;
assign fsm_state_o = fsm_state_q;
logic  [63:0] iv;
assign iv = (ascon_variant == ASCON_128) ? IV_128 : IV_128A;
prim_mubi_pkg::mubi4_t complete_block;
assign complete_block =  (ascon_variant == ASCON_128  && data_in_valid_bytes_i ==  8)
                       ||(ascon_variant == ASCON_128A && data_in_valid_bytes_i == 16) ?
                          prim_mubi_pkg::MuBi4True : prim_mubi_pkg::MuBi4False;
logic [127:0] empty_padding;
assign empty_padding = get_padding_mask(5'b00000);
logic [127:0] valid_bytes_bit_mask;
assign valid_bytes_bit_mask = bin2thermo(data_in_valid_bytes_i);
logic [127:0] padding_byte_bit_mask;
assign padding_byte_bit_mask = get_padding_mask(data_in_valid_bytes_i);
logic [127:0] data_in_valid_bytes;
assign data_in_valid_bytes = data_in_i & valid_bytes_bit_mask;
logic  [127:0] data_out;
assign data_out = (data_in_i ^ {ascon_state_q[0], ascon_state_q[1]}) & valid_bytes_bit_mask;
logic [127:0] data_in_padded;
logic [127:0] data_out_padded; 
always_comb begin
  if (prim_mubi_pkg::mubi4_test_true_strict(complete_block)) begin
      data_in_padded = data_in_valid_bytes;
      data_out_padded = data_out;
    end else begin
      data_in_padded = data_in_valid_bytes | padding_byte_bit_mask;
      data_out_padded = data_out | padding_byte_bit_mask;
  end
end
assign data_out_o  = data_out;
assign  tag_out_o  = ({ascon_state_q[3], ascon_state_q[4]} ^ key_i);
logic [AsconRoundCountW-1:0] current_round;
prim_count #(
    .Width(AsconRoundCountW)
) u_round_counter (
    .clk_i,
    .rst_ni,
    .clr_i(1'b0),
    .set_i(set_round_counter),
    .set_cnt_i(perm_offset),
    .incr_en_i(inc_round_counter),
    .decr_en_i(1'b0),
    .step_i(AsconRoundCountW'(1)),
    .commit_i(1'b1),
    .cnt_o(current_round),
    .cnt_after_commit_o(),
    .err_o(round_count_error)
  );
padding_mux_e sel_padding;
ascon_word_mux_e sel_mux_word0;
ascon_word_mux_e sel_mux_word1;
ascon_word_mux_e sel_mux_word2;
ascon_word_mux_e sel_mux_word3;
ascon_word_mux_e sel_mux_word4;
word_low_key_hi_mux_e sel_mux_key_word1;
key_hi_low_mux_e      sel_mux_key_word2;
key_hi_low_mux_e      sel_mux_key_word3;
ascon_round_input_mux_e sel_round_input;
logic set_dom_sep;
logic [4:0][63:0] xor_with_state;
logic      [63:0] word4_dom_sep;
logic     [127:0] data_to_duplex;
always_comb begin : Padding
  unique case (sel_padding)
    DATA_IN_PAD:  data_to_duplex = data_in_padded;
    DATA_OUT_PAD: data_to_duplex = data_out_padded;
    EMPTY_PAD:    data_to_duplex = empty_padding;
    default:      data_to_duplex = empty_padding;
  endcase
end
always_comb begin : state_input
  unique case (sel_round_input)
    STATE:    state_to_round = ascon_state_q;
    BLINDING: state_to_round = '0;
    default:  state_to_round = '0;
  endcase
end
assign xor_with_state[0] = data_to_duplex[127:64];
always_comb begin : state_word0
  unique case (sel_mux_word0)
    INIT:    ascon_state_d[0] = iv;
    ABSORB:  ascon_state_d[0] = ascon_state_q[0] ^ xor_with_state[0];
    KEEP:    ascon_state_d[0] = ascon_state_q[0];
    ROUND:   ascon_state_d[0] = round_to_mux[0];
    default: ascon_state_d[0] = ascon_state_q[0];
  endcase
end
always_comb begin : key_word1
  unique case (sel_mux_key_word1)
    WORD:    xor_with_state[1] = data_to_duplex[63:0];
    KEY:     xor_with_state[1] = key_i[127:64];
    default: xor_with_state[1] = key_i[127:64];
  endcase
end
always_comb begin : state_word1
  unique case (sel_mux_word1)
    INIT:    ascon_state_d[1] = key_i[127:64];
    ABSORB:  ascon_state_d[1] = ascon_state_q[1] ^ xor_with_state[1];
    KEEP:    ascon_state_d[1] = ascon_state_q[1];
    ROUND:   ascon_state_d[1] = round_to_mux[1];
    default: ascon_state_d[1] = ascon_state_q[1];
  endcase
end
always_comb begin : key_word2
  unique case (sel_mux_key_word2)
    KEY_LOW: xor_with_state[2] = key_i[63:0];
    KEY_HI:  xor_with_state[2] = key_i[127:64];
    default: xor_with_state[2] = key_i[127:64];
  endcase
end
always_comb begin : state_word2
  unique case (sel_mux_word2)
    INIT:    ascon_state_d[2] = key_i[63:0];
    ABSORB:  ascon_state_d[2] = ascon_state_q[2] ^ xor_with_state[2];
    KEEP :   ascon_state_d[2] = ascon_state_q[2];
    ROUND:   ascon_state_d[2] = round_to_mux[2];
    default: ascon_state_d[2] = ascon_state_q[2];
  endcase
end
always_comb begin : key_word3
  unique case (sel_mux_key_word3)
    KEY_LOW: xor_with_state[3] = key_i[63:0];
    KEY_HI:  xor_with_state[3] = key_i[127:64];
    default: xor_with_state[3] = key_i[127:64];
  endcase
end
always_comb begin : state_word3
  unique case (sel_mux_word3)
    INIT:    ascon_state_d[3] = nonce_i[127:64];
    ABSORB:  ascon_state_d[3] = ascon_state_q[3] ^ xor_with_state[3];
    KEEP:    ascon_state_d[3] = ascon_state_q[3];
    ROUND:   ascon_state_d[3] = round_to_mux[3];
    default: ascon_state_d[3] = ascon_state_q[3];
  endcase
end
assign word4_dom_sep = {ascon_state_q[4][63:1], ascon_state_q[4][0] ^ set_dom_sep};
assign xor_with_state[4] = key_i[63:0];
always_comb begin : state_word4
  unique case (sel_mux_word4)
    INIT:    ascon_state_d[4] = nonce_i[63:0];
    ABSORB:  ascon_state_d[4] = word4_dom_sep ^ xor_with_state[4];
    KEEP:    ascon_state_d[4] = word4_dom_sep;
    ROUND:   ascon_state_d[4] = round_to_mux[4];
    default: ascon_state_d[4] = word4_dom_sep;
  endcase
end
always_comb begin : p_fsm
  
  fsm_state_d = fsm_state_q;
  data_in_ready_o = 1'b0;
  data_out_valid_o = 1'b0;
  tag_out_valid_o = 1'b0;
  sparse_fsm_error = 1'b0;
  set_round_counter = 1'b0;
  inc_round_counter = 1'b0;
  perm_offset = P12;
  done_o = 1'b0;
  idle_o = prim_mubi_pkg::MuBi4False;
  
  set_dom_sep   = 1'b0;
  sel_mux_word0 = KEEP;
  sel_mux_word1 = KEEP;
  sel_mux_word2 = KEEP;
  sel_mux_word3 = KEEP;
  sel_mux_word4 = KEEP;
  sel_mux_key_word3 = KEY_HI;
  sel_mux_key_word2 = KEY_LOW;
  sel_mux_key_word1 = KEY;
  sel_padding = EMPTY_PAD;
  sel_round_input = BLINDING;
  unique case (fsm_state_q)
    Idle: begin
      idle_o = prim_mubi_pkg::MuBi4True;
      if (start_i) begin
        fsm_state_d = Init;
      end
    end
    Init: begin
      sel_mux_word0 = INIT;
      sel_mux_word1 = INIT;
      sel_mux_word2 = INIT;
      sel_mux_word3 = INIT;
      sel_mux_word4 = INIT;
      fsm_state_d = PermInit;
      perm_offset = P12;
      set_round_counter = 1'b1;
    end
    PermInit: begin
      sel_round_input = STATE;
      sel_mux_word0 = ROUND;
      sel_mux_word1 = ROUND;
      sel_mux_word2 = ROUND;
      sel_mux_word3 = ROUND;
      sel_mux_word4 = ROUND;
      if (current_round == ROUND_MAX) begin
        fsm_state_d = Xor0Key;
      end else begin
        inc_round_counter = 1'b1;
      end
    end
    Xor0Key: begin
      sel_mux_word3 = ABSORB;
      sel_mux_key_word3 = KEY_HI;
      sel_mux_word4 = ABSORB;
      if (prim_mubi_pkg::mubi4_test_true_strict(no_ad_i)) begin
        fsm_state_d = XorDomSep;
      end else begin
        fsm_state_d = AbsorbAD;
      end
    end
    AbsorbAD: begin
      
      data_in_ready_o = 1'b1;
      if (data_in_valid_i) begin
        sel_mux_word0 = ABSORB;
        sel_padding = DATA_IN_PAD;
        if (ascon_variant == ASCON_128A) begin
          sel_mux_word1 = ABSORB;
          sel_mux_key_word1 = WORD;
        end
        if (prim_mubi_pkg::mubi4_test_true_strict(last_block_ad_i)) begin
          if (prim_mubi_pkg::mubi4_test_true_strict(complete_block)) begin
            fsm_state_d = PermADEmpty;
          end else begin
            fsm_state_d = PermADLast;
          end
        end else begin 
          fsm_state_d = PermAD;
        end
      end
      if (ascon_variant == ASCON_128) begin
        perm_offset = P6;
      end else begin 
        perm_offset = P8;
      end
      set_round_counter = 1'b1;
    end
    PermAD: begin
      sel_round_input = STATE;
      sel_mux_word0 = ROUND;
      sel_mux_word1 = ROUND;
      sel_mux_word2 = ROUND;
      sel_mux_word3 = ROUND;
      sel_mux_word4 = ROUND;
      if (current_round == ROUND_MAX) begin
        fsm_state_d = AbsorbAD;
      end else begin
        inc_round_counter = 1'b1;
      end
    end
    PermADLast: begin
      sel_round_input = STATE;
      sel_mux_word0 = ROUND;
      sel_mux_word1 = ROUND;
      sel_mux_word2 = ROUND;
      sel_mux_word3 = ROUND;
      sel_mux_word4 = ROUND;
      if (current_round == ROUND_MAX) begin
        fsm_state_d = XorDomSep;
      end else begin
        inc_round_counter = 1'b1;
      end
    end
    PermADEmpty: begin
      sel_round_input = STATE;
      sel_mux_word0 = ROUND;
      sel_mux_word1 = ROUND;
      sel_mux_word2 = ROUND;
      sel_mux_word3 = ROUND;
      sel_mux_word4 = ROUND;
      if (current_round == ROUND_MAX) begin
        fsm_state_d = AbsorbADEmpty;
      end else begin
        inc_round_counter = 1'b1;
      end
    end
    AbsorbADEmpty: begin
      sel_mux_word0 = ABSORB;
      sel_padding = EMPTY_PAD;
      fsm_state_d = PermADLast;
      if (ascon_variant == ASCON_128) begin
        perm_offset = P6;
      end else begin 
        perm_offset = P8;
        
        
        
        sel_mux_word1 = ABSORB;
        sel_padding = EMPTY_PAD;
      end
      set_round_counter = 1'b1;
    end
    XorDomSep: begin
      set_dom_sep = 1'b1;
      sel_mux_word4 = KEEP;
      if (prim_mubi_pkg::mubi4_test_true_strict(no_msg_i)) begin
        fsm_state_d = AbsorbMSGEmpty;
      end else begin
        fsm_state_d = AbsorbMSG;
      end
    end
    AbsorbMSG: begin
      data_in_ready_o = 1'b1;
      if (data_in_valid_i) begin
        data_out_valid_o = 1'b1;
        if (ascon_operation == ASCON_ENC) begin
          sel_mux_word0 = ABSORB;
          sel_padding = DATA_IN_PAD;
          if (ascon_variant == ASCON_128A) begin
            sel_mux_word1 = ABSORB;
          end
        end else begin 
          sel_mux_word0 = ABSORB;
          sel_padding = DATA_OUT_PAD;
          if (ascon_variant == ASCON_128A) begin
            sel_mux_word1 = ABSORB;
            sel_mux_key_word1 = WORD;
          end
        end
        if (prim_mubi_pkg::mubi4_test_true_strict(last_block_msg_i)) begin
          if (prim_mubi_pkg::mubi4_test_true_strict(complete_block)) begin 
            fsm_state_d = PermMSGEmpty;
          end else begin 
            fsm_state_d = XorKey0;
          end
        end else begin
          fsm_state_d = PermMSG;
        end
      end
      if (ascon_variant == ASCON_128) begin
        perm_offset = P6;
      end else begin 
        perm_offset = P8;
      end
      set_round_counter = 1'b1;
    end
    PermMSG: begin
      sel_round_input = STATE;
      sel_mux_word0 = ROUND;
      sel_mux_word1 = ROUND;
      sel_mux_word2 = ROUND;
      sel_mux_word3 = ROUND;
      sel_mux_word4 = ROUND;
      if (current_round == ROUND_MAX) begin
        fsm_state_d = AbsorbMSG;
      end else begin
        inc_round_counter = 1'b1;
      end
    end
    PermMSGEmpty: begin
      sel_round_input = STATE;
      sel_mux_word0 = ROUND;
      sel_mux_word1 = ROUND;
      sel_mux_word2 = ROUND;
      sel_mux_word3 = ROUND;
      sel_mux_word4 = ROUND;
      if (current_round == ROUND_MAX) begin
        fsm_state_d = AbsorbMSGEmpty;
      end else begin
        inc_round_counter = 1'b1;
      end
    end
    AbsorbMSGEmpty: begin
      
      sel_padding = EMPTY_PAD;
      sel_mux_word0 = ABSORB;
      if (ascon_variant == ASCON_128A) begin
        
        
        
        sel_mux_word1 = ABSORB;
        sel_mux_key_word1 = WORD;
      end
      fsm_state_d = XorKey0;
    end
    XorKey0: begin
      if (ascon_variant == ASCON_128) begin
        sel_mux_word1 = ABSORB;
        sel_mux_key_word1 = KEY;
        sel_mux_word2 = ABSORB;
        sel_mux_key_word2 = KEY_LOW;
      end else begin 
        sel_mux_word2 = ABSORB;
        sel_mux_key_word2 = KEY_HI;
        sel_mux_word3 = ABSORB;
        sel_mux_key_word3 = KEY_LOW;
      end
      fsm_state_d = PermFinal;
      set_round_counter = 1'b1;
      perm_offset = P12;
    end
    PermFinal: begin
      sel_round_input = STATE;
      sel_mux_word0 = ROUND;
      sel_mux_word1 = ROUND;
      sel_mux_word2 = ROUND;
      sel_mux_word3 = ROUND;
      sel_mux_word4 = ROUND;
      if (current_round == ROUND_MAX) begin
        fsm_state_d = SqueezeTagXorKey;
      end else begin
        inc_round_counter = 1'b1;
      end
    end
    SqueezeTagXorKey: begin
      tag_out_valid_o = 1'b1;
      fsm_state_d = Idle;
      done_o = 1'b1;
    end
    Error: begin
      fsm_state_d = Error;
      sparse_fsm_error = 1'b1;
    end
    default: begin
      fsm_state_d = Error;
      sparse_fsm_error = 1'b1;
    end
  endcase
end
`PRIM_FLOP_SPARSE_FSM(u_state_regs, fsm_state_d, fsm_state_q, duplex_fsm_state_e, Idle)
logic mubi_error;
assign mubi_error = prim_mubi_pkg::mubi4_test_invalid(no_ad_i)
                  | prim_mubi_pkg::mubi4_test_invalid(no_msg_i)
                  | prim_mubi_pkg::mubi4_test_invalid(complete_block)
                  | prim_mubi_pkg::mubi4_test_invalid(last_block_ad_i)
                  | prim_mubi_pkg::mubi4_test_invalid(last_block_msg_i);
assign err_o = round_count_error | sparse_fsm_error | mubi_error;
prim_ascon_round u_prim_ascon_round (
  .state_o(state_from_round),
  .state_i(state_to_round),
  .rcon_i(get_ascon_rcon(current_round))
);
endmodule

package prim_ascon_pkg;
parameter int AsconRoundCountW = 4;
typedef enum logic [3:0] {
  P12 = 4'b0000,
  P8  = 4'b0100,
  P6  = 4'b0110
} perm_offset_e;
parameter int DUPLEX_OP_WIDTH = 3;
typedef enum logic [DUPLEX_OP_WIDTH-1:0] {
  ASCON_ENC  = 3'b001,
  ASCON_DEC  = 3'b010,
  ASCON_HASH = 3'b100
} duplex_op_e;
parameter int DUPLEX_VARIANT_WIDTH = 2;
typedef enum logic [DUPLEX_VARIANT_WIDTH-1:0] {
  ASCON_128  = 2'b01,
  ASCON_128A = 2'b10
} duplex_variant_e;
localparam logic [63:0] IV_128  = 64'h80400c0600000000;
localparam logic [63:0] IV_128A = 64'h80800c0800000000;
localparam logic [3:0] ROUND_MAX = 4'b1011;
function automatic logic [7:0] get_ascon_rcon(logic [3:0] round);
  logic [7:0] result;
  unique case (round)
    4'b0000: result = 8'hf0;
    4'b0001: result = 8'he1;
    4'b0010: result = 8'hd2;
    4'b0011: result = 8'hc3;
    4'b0100: result = 8'hb4;
    4'b0101: result = 8'ha5;
    4'b0110: result = 8'h96;
    4'b0111: result = 8'h87;
    4'b1000: result = 8'h78;
    4'b1001: result = 8'h69;
    4'b1010: result = 8'h5a;
    4'b1011: result = 8'h4b;
    default: result = 8'h00;
  endcase
  return result;
endfunction
parameter int KEY_HI_LOW_MUX_WIDTH = 1;
typedef enum logic [KEY_HI_LOW_MUX_WIDTH-1:0] {
  KEY_LOW = 1'b0,
  KEY_HI  = 1'b1
} key_hi_low_mux_e;
parameter int WORD_LOW_KEY_HI_MUX_WIDTH = 1;
typedef enum logic [WORD_LOW_KEY_HI_MUX_WIDTH-1:0] {
  WORD = 1'b0,
  KEY  = 1'b1
} word_low_key_hi_mux_e;
parameter int ASCON_WORD_MUX_WIDTH = 2;
typedef enum logic [ASCON_WORD_MUX_WIDTH-1:0] {
  INIT   = 2'b00,
  ABSORB = 2'b01,
  KEEP   = 2'b10,
  ROUND  = 2'b11
} ascon_word_mux_e;
parameter int ROUND_INPUT_MUX_WIDTH = 1;
typedef enum logic [ROUND_INPUT_MUX_WIDTH-1:0] {
  STATE    = 1'b0,
  BLINDING = 1'b1
} ascon_round_input_mux_e;
parameter int PADDING_MUX_WIDTH = 2;
typedef enum logic [PADDING_MUX_WIDTH-1:0] {
  DATA_IN_PAD  = 2'b00,
  DATA_OUT_PAD = 2'b01,
  EMPTY_PAD    = 2'b10
} padding_mux_e;
localparam int AsconDuplexFSMStateWidth = 10;
typedef enum logic [AsconDuplexFSMStateWidth-1:0] {
  Idle             = 10'b1010101110,
  Init             = 10'b0110000110,
  PermInit         = 10'b1011110110,
  Xor0Key          = 10'b0001010011,
  AbsorbAD         = 10'b1110010000,
  PermAD           = 10'b1101101101,
  XorDomSep        = 10'b0100110010,
  AbsorbMSG        = 10'b0011100011,
  PermMSG          = 10'b0001001100,
  AbsorbMSGEmpty   = 10'b0100101100,
  XorKey0          = 10'b1000011011,
  PermFinal        = 10'b0011010000,
  SqueezeTagXorKey = 10'b1111010111,
  PermADLast       = 10'b1010000010,
  AbsorbADEmpty    = 10'b1101111011,
  PermMSGEmpty     = 10'b1011111000,
  PermADEmpty      = 10'b0010111100,
  Error            = 10'b0100011110
} duplex_fsm_state_e;
function automatic logic [127:0] bin2thermo(logic [4:0] valid_bytes);
  logic [127:0] valid_bytes_mask;
  unique case (valid_bytes)
    5'b00000 : valid_bytes_mask =               {128{1'b0}};
    5'b00001 : valid_bytes_mask = {  {8{1'b1}}, {120{1'b0}}};
    5'b00010 : valid_bytes_mask = { {16{1'b1}}, {112{1'b0}}};
    5'b00011 : valid_bytes_mask = { {24{1'b1}}, {104{1'b0}}};
    5'b00100 : valid_bytes_mask = { {32{1'b1}},  {96{1'b0}}};
    5'b00101 : valid_bytes_mask = { {40{1'b1}},  {88{1'b0}}};
    5'b00110 : valid_bytes_mask = { {48{1'b1}},  {80{1'b0}}};
    5'b00111 : valid_bytes_mask = { {56{1'b1}},  {72{1'b0}}};
    5'b01000 : valid_bytes_mask = { {64{1'b1}},  {64{1'b0}}};
    5'b01001 : valid_bytes_mask = { {72{1'b1}},  {56{1'b0}}};
    5'b01010 : valid_bytes_mask = { {80{1'b1}},  {48{1'b0}}};
    5'b01011 : valid_bytes_mask = { {88{1'b1}},  {40{1'b0}}};
    5'b01100 : valid_bytes_mask = { {96{1'b1}},  {32{1'b0}}};
    5'b01101 : valid_bytes_mask = {{104{1'b1}},  {24{1'b0}}};
    5'b01110 : valid_bytes_mask = {{112{1'b1}},  {16{1'b0}}};
    5'b01111 : valid_bytes_mask = {{120{1'b1}},   {8{1'b0}}};
    default :  valid_bytes_mask =  {128{1'b1}};
  endcase
  return valid_bytes_mask;
endfunction
function automatic logic [127:0] get_padding_mask(logic [4:0] valid_bytes);
  logic [127:0] padding_byte_mask;
  unique case (valid_bytes)
    5'b00000 : padding_byte_mask = {             8'h80, {120{1'b0}}};
    5'b00001 : padding_byte_mask = {  {8{1'b0}}, 8'h80, {112{1'b0}}};
    5'b00010 : padding_byte_mask = { {16{1'b0}}, 8'h80, {104{1'b0}}};
    5'b00011 : padding_byte_mask = { {24{1'b0}}, 8'h80,  {96{1'b0}}};
    5'b00100 : padding_byte_mask = { {32{1'b0}}, 8'h80,  {88{1'b0}}};
    5'b00101 : padding_byte_mask = { {40{1'b0}}, 8'h80,  {80{1'b0}}};
    5'b00110 : padding_byte_mask = { {48{1'b0}}, 8'h80,  {72{1'b0}}};
    5'b00111 : padding_byte_mask = { {56{1'b0}}, 8'h80,  {64{1'b0}}};
    5'b01000 : padding_byte_mask = { {64{1'b0}}, 8'h80,  {56{1'b0}}};
    5'b01001 : padding_byte_mask = { {72{1'b0}}, 8'h80,  {48{1'b0}}};
    5'b01010 : padding_byte_mask = { {80{1'b0}}, 8'h80,  {40{1'b0}}};
    5'b01011 : padding_byte_mask = { {88{1'b0}}, 8'h80,  {32{1'b0}}};
    5'b01100 : padding_byte_mask = { {96{1'b0}}, 8'h80,  {24{1'b0}}};
    5'b01101 : padding_byte_mask = {{104{1'b0}}, 8'h80,  {16{1'b0}}};
    5'b01110 : padding_byte_mask = {{112{1'b0}}, 8'h80,   {8{1'b0}}};
    5'b01111 : padding_byte_mask = {{120{1'b0}}, 8'h80             };
    default :  padding_byte_mask =  {128{1'b0}};
  endcase
  return padding_byte_mask;
endfunction
endpackage : prim_ascon_pkg

module prim_ascon_round (
  output logic [319:0] state_o,
  input  logic [319:0] state_i,
  input  logic   [7:0] rcon_i
);
  logic [319:0] ark_w, sbox_w;
  
  assign ark_w = state_i ^ {64'h0, 64'h0, 56'h0, rcon_i, 64'h0, 64'h0};
  
  logic [63:0] x_w  [5];
  logic [ 4:0] xtranspose_w [64];
  logic [ 4:0] ytranspose_w [64];
  logic [63:0] y_w  [5];
  assign x_w[0] = ark_w[ 63:  0];
  assign x_w[1] = ark_w[127: 64];
  assign x_w[2] = ark_w[191:128];
  assign x_w[3] = ark_w[255:192];
  assign x_w[4] = ark_w[319:256];
  for (genvar i = 0; i < 64; i = i + 1) begin : gen_sbox_transpose
    assign xtranspose_w[i] = {x_w[4][i],
                              x_w[3][i],
                              x_w[2][i],
                              x_w[1][i],
                              x_w[0][i]};
    prim_ascon_sbox u_sbox (
      .state_i(xtranspose_w[i]),
      .state_o(ytranspose_w[i])
    );
    assign {y_w[4][i],
            y_w[3][i],
            y_w[2][i],
            y_w[1][i],
            y_w[0][i]} = ytranspose_w[i];
  end
  assign sbox_w = {y_w[4], y_w[3], y_w[2], y_w[1], y_w[0]};
  
  logic [63:0] xl_w [5];
  logic [63:0] yl_w [5];
  assign xl_w[0] = sbox_w[ 63:  0];
  assign xl_w[1] = sbox_w[127: 64];
  assign xl_w[2] = sbox_w[191:128];
  assign xl_w[3] = sbox_w[255:192];
  assign xl_w[4] = sbox_w[319:256];
  assign yl_w[0] = xl_w[0] ^ {xl_w[0][18:0], xl_w[0][63:19]} ^ {xl_w[0][27:0], xl_w[0][63:28]};
  assign yl_w[1] = xl_w[1] ^ {xl_w[1][60:0], xl_w[1][63:61]} ^ {xl_w[1][38:0], xl_w[1][63:39]};
  assign yl_w[2] = xl_w[2] ^ {xl_w[2][   0], xl_w[2][63: 1]} ^ {xl_w[2][ 5:0], xl_w[2][63: 6]};
  assign yl_w[3] = xl_w[3] ^ {xl_w[3][ 9:0], xl_w[3][63:10]} ^ {xl_w[3][16:0], xl_w[3][63:17]};
  assign yl_w[4] = xl_w[4] ^ {xl_w[4][ 6:0], xl_w[4][63: 7]} ^ {xl_w[4][40:0], xl_w[4][63:41]};
  assign state_o = {yl_w[4], yl_w[3], yl_w[2], yl_w[1], yl_w[0]};
endmodule

module prim_ascon_sbox (
  output logic [4:0] state_o,
  input  logic [4:0] state_i
);
  logic [4:0] temp_w [4];
  assign temp_w[0] = state_i;
  assign temp_w[1] = {temp_w[0][3] ^ temp_w[0][4],
                      temp_w[0][3],
                      temp_w[0][1] ^ temp_w[0][2],
                      temp_w[0][1],
                      temp_w[0][0] ^ temp_w[0][4]
                      };
  assign temp_w[2] = {temp_w[1][4] ^ ((~temp_w[1][0]) & temp_w[1][1]),
                      temp_w[1][3] ^ ((~temp_w[1][4]) & temp_w[1][0]),
                      temp_w[1][2] ^ ((~temp_w[1][3]) & temp_w[1][4]),
                      temp_w[1][1] ^ ((~temp_w[1][2]) & temp_w[1][3]),
                      temp_w[1][0] ^ ((~temp_w[1][1]) & temp_w[1][2])
                      };
  assign temp_w[3] = {temp_w[2][4],
                      temp_w[2][3] ^ temp_w[2][2],
                      ~temp_w[2][2],
                      temp_w[2][1] ^ temp_w[2][0],
                      temp_w[2][0] ^ temp_w[2][4]
                      };
  assign state_o = temp_w[3];
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
module prim_diff_decode #(
  
  parameter bit AsyncOn = 1'b0,
  
  
  
  
  
  parameter int unsigned SkewCycles = 1
) (
  input        clk_i,
  input        rst_ni,
  
  input        diff_pi,
  input        diff_ni,
  
  
  output logic level_o,
  output logic rise_o,
  output logic fall_o,
  
  output logic event_o,
  
  output logic sigint_o
);
  logic level_d, level_q;
  
  
  
  if (AsyncOn) begin : gen_async
    typedef enum logic [1:0] {IsStd, IsSkewing, SigInt} state_e;
    state_e state_d, state_q;
    logic diff_p_edge, diff_n_edge, diff_check_ok, level;
    
    logic diff_pq, diff_nq, diff_pd, diff_nd;
    
    
    logic [prim_util_pkg::vbits(SkewCycles + 1)-1:0] skew_cnt_d, skew_cnt_q;
    prim_flop_2sync #(
      .Width(1),
      .ResetValue('0)
    ) i_sync_p (
      .clk_i,
      .rst_ni,
      .d_i(diff_pi),
      .q_o(diff_pd)
    );
    prim_flop_2sync #(
      .Width(1),
      .ResetValue(1'b1)
    ) i_sync_n (
      .clk_i,
      .rst_ni,
      .d_i(diff_ni),
      .q_o(diff_nd)
    );
    
    assign diff_p_edge   = diff_pq ^ diff_pd;
    assign diff_n_edge   = diff_nq ^ diff_nd;
    
    assign diff_check_ok = diff_pd ^ diff_nd;
    
    assign level         = diff_pd;
    
    assign level_o  = level_d;
    assign event_o = rise_o | fall_o;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    always_comb begin : p_diff_fsm
      
      state_d    = state_q;
      level_d    = level_q;
      skew_cnt_d = skew_cnt_q;
      rise_o     = 1'b0;
      fall_o     = 1'b0;
      sigint_o   = 1'b0;
      unique case (state_q)
        
        
        IsStd: begin
          if (diff_check_ok) begin
            level_d = level;
            if (diff_p_edge && diff_n_edge) begin
              if (level) begin
                rise_o = 1'b1;
              end else begin
                fall_o = 1'b1;
              end
            end
          end else begin
            if (SkewCycles == 0) begin
              
              state_d  = SigInt;
              sigint_o = 1'b1;
            end else begin
              
              state_d    = IsSkewing;
              skew_cnt_d = 1;
            end
          end
        end
        
        IsSkewing: begin
          if (diff_check_ok) begin
            state_d    = IsStd;
            level_d    = level;
            
            skew_cnt_d = '0;
            
            if (level) rise_o = 1'b1;
            else       fall_o = 1'b1;
          end else begin
            if (skew_cnt_q < SkewCycles) begin
              
              skew_cnt_d = skew_cnt_q + 1;
            end else begin
              
              state_d    = SigInt;
              sigint_o   = 1'b1;
              skew_cnt_d = '0;
            end
          end
        end
        
        SigInt: begin
          sigint_o = 1'b1;
          if (diff_check_ok) begin
            state_d  = IsStd;
            sigint_o = 1'b0;
            level_d  = level;
            
            if (level) rise_o = 1'b1;
            else       fall_o = 1'b1;
          end
        end
        default : ;
      endcase
    end
    always_ff @(posedge clk_i or negedge rst_ni) begin : p_sync_reg
      if (!rst_ni) begin
        state_q    <= IsStd;
        diff_pq    <= 1'b0;
        diff_nq    <= 1'b1;
        level_q    <= 1'b0;
        skew_cnt_q <= '0;
      end else begin
        state_q    <= state_d;
        diff_pq    <= diff_pd;
        diff_nq    <= diff_nd;
        level_q    <= level_d;
        skew_cnt_q <= skew_cnt_d;
      end
    end
  
  
  
  end else begin : gen_no_async
    logic diff_pq, diff_pd;
    
    assign diff_pd = diff_pi;
    
    
    
    prim_xnor2 #(
      .Width (1)
    ) u_xnor2_sigint (
      .in0_i (diff_pi),
      .in1_i (diff_ni),
      .out_o (sigint_o)
    );
    assign level_o = (sigint_o) ? level_q : diff_pi;
    assign level_d = level_o;
    
    assign rise_o  = (~diff_pq &  diff_pi) & ~sigint_o;
    assign fall_o  = ( diff_pq & ~diff_pi) & ~sigint_o;
    assign event_o = rise_o | fall_o;
    always_ff @(posedge clk_i or negedge rst_ni) begin : p_edge_reg
      if (!rst_ni) begin
        diff_pq  <= 1'b0;
        level_q  <= 1'b0;
      end else begin
        diff_pq  <= diff_pd;
        level_q  <= level_d;
      end
    end
  end
  
  
  
  
  
  
  `ASSERT(SigintLevelCheck_A, ##1 sigint_o |-> $stable(level_o))
  
  `ASSERT(SigintEventCheck_A, sigint_o |-> !event_o)
  `ASSERT(SigintRiseCheck_A,  sigint_o |-> !rise_o)
  `ASSERT(SigintFallCheck_A,  sigint_o |-> !fall_o)
  if (AsyncOn) begin : gen_async_assert
    
`ifdef INC_ASSERT
  `ifndef FPV_ALERT_NO_SIGINT_ERR
    
    
    
    `ASSERT(SigintCheck0_A,
            gen_async.diff_pd == gen_async.diff_nd [* (SkewCycles + 1)] |-> sigint_o)
    
    
    
    
    if (SkewCycles == 1) begin : gen_specific_skew_asserts
      `ASSERT(SigintCheck1_A,
          ##1 (gen_async.diff_pd ^ gen_async.diff_nd) &&
          $stable(gen_async.diff_pd) && $stable(gen_async.diff_nd) ##1
          $rose(gen_async.diff_pd) && $stable(gen_async.diff_nd) ##1
          $stable(gen_async.diff_pd) && $fell(gen_async.diff_nd)
          |-> rise_o)
      `ASSERT(SigintCheck2_A,
          ##1 (gen_async.diff_pd ^ gen_async.diff_nd) &&
          $stable(gen_async.diff_pd) && $stable(gen_async.diff_nd) ##1
          $fell(gen_async.diff_pd) && $stable(gen_async.diff_nd) ##1
          $stable(gen_async.diff_pd) && $rose(gen_async.diff_nd)
          |-> fall_o)
      `ASSERT(SigintCheck3_A,
          ##1 (gen_async.diff_pd ^ gen_async.diff_nd) &&
          $stable(gen_async.diff_pd) && $stable(gen_async.diff_nd) ##1
          $rose(gen_async.diff_nd) && $stable(gen_async.diff_pd) ##1
          $stable(gen_async.diff_nd) && $fell(gen_async.diff_pd)
          |-> fall_o)
      `ASSERT(SigintCheck4_A,
          ##1 (gen_async.diff_pd ^ gen_async.diff_nd) &&
          $stable(gen_async.diff_pd) && $stable(gen_async.diff_nd) ##1
          $fell(gen_async.diff_nd) && $stable(gen_async.diff_pd) ##1
          $stable(gen_async.diff_nd) && $rose(gen_async.diff_pd)
          |-> rise_o)
    end
    `endif
    
    
    `ASSERT(RiseCheck_A,
        !sigint_o ##1 $rose(gen_async.diff_pd) && (gen_async.diff_pd ^ gen_async.diff_nd) |->
        ##[0:SkewCycles] rise_o,  clk_i, !rst_ni || sigint_o)
    `ASSERT(FallCheck_A,
        !sigint_o ##1 $fell(gen_async.diff_pd) && (gen_async.diff_pd ^ gen_async.diff_nd) |->
        ##[0:SkewCycles] fall_o,  clk_i, !rst_ni || sigint_o)
    `ASSERT(EventCheck_A,
        !sigint_o ##1 $changed(gen_async.diff_pd) && (gen_async.diff_pd ^ gen_async.diff_nd) |->
        ##[0:SkewCycles] event_o, clk_i, !rst_ni || sigint_o)
    
    
    `ASSERT(LevelCheck0_A,
        
        !sigint_o && (gen_async.diff_pd ^ gen_async.diff_nd) [* (SkewCycles + 1)] |->
        gen_async.diff_pd == level_o,
        clk_i, !rst_ni || sigint_o)
`endif
  end else begin : gen_sync_assert
    
  `ifndef FPV_ALERT_NO_SIGINT_ERR
    
    `ASSERT(SigintCheck_A, diff_pi == diff_ni |-> sigint_o)
  `endif
    
    `ASSERT(RiseCheck_A,  ##1 $rose(diff_pi)    && (diff_pi ^ diff_ni) |->  rise_o)
    `ASSERT(FallCheck_A,  ##1 $fell(diff_pi)    && (diff_pi ^ diff_ni) |->  fall_o)
    `ASSERT(EventCheck_A, ##1 $changed(diff_pi) && (diff_pi ^ diff_ni) |-> event_o)
    
    `ASSERT(LevelCheck_A, (diff_pi ^ diff_ni) |-> diff_pi == level_o)
  end
endmodule : prim_diff_decode

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
module prim_onehot_check #(
  parameter int unsigned AddrWidth   = 5,
  
  parameter int unsigned OneHotWidth = 2**AddrWidth,
  
  parameter bit          AddrCheck   = 1,
  
  parameter bit          EnableCheck = 1,
  
  
  parameter bit          StrictCheck = 1,
  
  
  parameter bit EnableAlertTriggerSVA = 1
) (
  
  input                          clk_i,
  input                          rst_ni,
  input  logic [OneHotWidth-1:0] oh_i,
  input  logic [AddrWidth-1:0]   addr_i,
  input  logic                   en_i,
  output logic                   err_o
);
  
  
  
  `ASSERT_INIT(NumSources_A, OneHotWidth >= 1)
  `ASSERT_INIT(AddrWidth_A, AddrWidth >= 1)
  `ASSERT_INIT(AddrRange_A, OneHotWidth <= 2**AddrWidth)
  `ASSERT_INIT(AddrImpliesEnable_A, AddrCheck && EnableCheck || !AddrCheck)
  
  
  localparam int NumLevels = AddrWidth;
  logic [2**(NumLevels+1)-2:0] or_tree;
  logic [2**(NumLevels+1)-2:0] and_tree; 
  logic [2**(NumLevels+1)-2:0] err_tree; 
  for (genvar level = 0; level < NumLevels+1; level++) begin : gen_tree
    
    
    
    
    
    
    
    
    
    
    
    localparam int Base0 = (2**level)-1;
    localparam int Base1 = (2**(level+1))-1;
    for (genvar offset = 0; offset < 2**level; offset++) begin : gen_level
      localparam int Pa = Base0 + offset;
      localparam int C0 = Base1 + 2*offset;
      localparam int C1 = Base1 + 2*offset + 1;
      
      if (level == NumLevels) begin : gen_leafs
        if (offset < OneHotWidth) begin : gen_assign
          assign or_tree[Pa]  = oh_i[offset];
          assign and_tree[Pa] = oh_i[offset];
        end else begin : gen_tie_off
          assign or_tree[Pa]  = 1'b0;
          assign and_tree[Pa] = 1'b0;
        end
        assign err_tree[Pa] = 1'b0;
      
      end else begin : gen_nodes
        assign or_tree[Pa]  = or_tree[C0] || or_tree[C1];
        assign and_tree[Pa] = (!addr_i[AddrWidth-1-level] && and_tree[C0]) ||
                              (addr_i[AddrWidth-1-level] && and_tree[C1]);
        assign err_tree[Pa] = (or_tree[C0] && or_tree[C1]) || err_tree[C0] || err_tree[C1];
      end
    end : gen_level
  end : gen_tree
  
  
  
  logic enable_err, addr_err, oh0_err;
  assign err_o = oh0_err || enable_err || addr_err;
  
  assign oh0_err = err_tree[0];
  `ASSERT(Onehot0Check_A, !$onehot0(oh_i) |-> err_o)
  
  
  if (EnableCheck) begin : gen_enable_check
    if (StrictCheck) begin : gen_strict
      assign enable_err = or_tree[0] ^ en_i;
      `ASSERT(EnableCheck_A, (|oh_i) != en_i |-> err_o)
    end else begin : gen_not_strict
      assign enable_err = !en_i && or_tree[0];
      `ASSERT(EnableCheck_A, !en_i && (|oh_i) |-> err_o)
    end
  end else begin : gen_no_enable_check
    logic unused_or_tree;
    assign unused_or_tree = ^or_tree;
    assign enable_err = 1'b0;
  end
  
  if (AddrCheck) begin : gen_addr_check_strict
    assign addr_err = or_tree[0] ^ and_tree[0];
    `ASSERT(AddrCheck_A, oh_i[addr_i] != (|oh_i) |-> err_o)
  end else begin : gen_no_addr_check_strict
    logic unused_and_tree;
    assign unused_and_tree = ^and_tree;
    assign addr_err = 1'b0;
  end
  
  
  
  
  
  
  
  
  
  
  
`ifdef INC_ASSERT
  logic unused_assert_connected;
  `ASSERT_INIT_NET(AssertConnected_A, unused_assert_connected === 1'b1 || !EnableAlertTriggerSVA)
`endif
endmodule : prim_onehot_check

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
module prim_reg_we_check #(
  parameter int unsigned OneHotWidth  = 32
) (
  
  input                          clk_i,
  input                          rst_ni,
  input  logic [OneHotWidth-1:0] oh_i,
  input  logic                   en_i,
  output logic                   err_o
);
  
  logic [OneHotWidth-1:0] oh_buf;
  prim_buf #(
    .Width(OneHotWidth)
  ) u_prim_buf (
    .in_i(oh_i),
    .out_o(oh_buf)
  );
  prim_onehot_check #(
    .OneHotWidth(OneHotWidth),
    .AddrWidth  (prim_util_pkg::vbits(OneHotWidth)),
    .EnableCheck(1),
    
    
    
    
    .AddrCheck(0),
    
    
    
    .StrictCheck(0)
  ) u_prim_onehot_check (
    .clk_i,
    .rst_ni,
    .oh_i(oh_buf),
    .addr_i('0),
    .en_i,
    .err_o
  );
endmodule : prim_reg_we_check

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
module prim_sec_anchor_flop #(
  parameter int               Width      = 1,
  parameter logic [Width-1:0] ResetValue = 0
) (
  input                    clk_i,
  input                    rst_ni,
  input        [Width-1:0] d_i,
  output logic [Width-1:0] q_o
);
  prim_flop #(
    .Width(Width),
    .ResetValue(ResetValue)
  ) u_secure_anchor_flop (
    .clk_i,
    .rst_ni,
    .d_i,
    .q_o
  );
endmodule

module prim_secded_inv_39_32_dec (
  input        [38:0] data_i,
  output logic [31:0] data_o,
  output logic [6:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
    syndrome_o[0] = ^((data_i ^ 39'h2A00000000) & 39'h012606BD25);
    syndrome_o[1] = ^((data_i ^ 39'h2A00000000) & 39'h02DEBA8050);
    syndrome_o[2] = ^((data_i ^ 39'h2A00000000) & 39'h04413D89AA);
    syndrome_o[3] = ^((data_i ^ 39'h2A00000000) & 39'h0831234ED1);
    syndrome_o[4] = ^((data_i ^ 39'h2A00000000) & 39'h10C2C1323B);
    syndrome_o[5] = ^((data_i ^ 39'h2A00000000) & 39'h202DCC624C);
    syndrome_o[6] = ^((data_i ^ 39'h2A00000000) & 39'h4098505586);
    
    data_o[0] = (syndrome_o == 7'h19) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'h54) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h61) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h34) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h1a) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'h15) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h2a) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h4c) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h45) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h38) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h49) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'hd) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h51) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h31) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h68) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'h7) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h1c) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'hb) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h25) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h26) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h46) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'he) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h70) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h32) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h2c) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h13) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h23) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h62) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h4a) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h29) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h16) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h52) ^ data_i[31];
    
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);
  end
endmodule : prim_secded_inv_39_32_dec

module prim_secded_inv_39_32_enc (
  input        [31:0] data_i,
  output logic [38:0] data_o
);
  always_comb begin : p_encode
    data_o = 39'(data_i);
    data_o[32] = ^(data_o & 39'h002606BD25);
    data_o[33] = ^(data_o & 39'h00DEBA8050);
    data_o[34] = ^(data_o & 39'h00413D89AA);
    data_o[35] = ^(data_o & 39'h0031234ED1);
    data_o[36] = ^(data_o & 39'h00C2C1323B);
    data_o[37] = ^(data_o & 39'h002DCC624C);
    data_o[38] = ^(data_o & 39'h0098505586);
    data_o ^= 39'h2A00000000;
  end
endmodule : prim_secded_inv_39_32_enc

module prim_secded_inv_64_57_dec (
  input        [63:0] data_i,
  output logic [56:0] data_o,
  output logic [6:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
    syndrome_o[0] = ^((data_i ^ 64'h5400000000000000) & 64'h0303FFF800007FFF);
    syndrome_o[1] = ^((data_i ^ 64'h5400000000000000) & 64'h057C1FF801FF801F);
    syndrome_o[2] = ^((data_i ^ 64'h5400000000000000) & 64'h09BDE1F87E0781E1);
    syndrome_o[3] = ^((data_i ^ 64'h5400000000000000) & 64'h11DEEE3B8E388E22);
    syndrome_o[4] = ^((data_i ^ 64'h5400000000000000) & 64'h21EF76CDB2C93244);
    syndrome_o[5] = ^((data_i ^ 64'h5400000000000000) & 64'h41F7BB56D5525488);
    syndrome_o[6] = ^((data_i ^ 64'h5400000000000000) & 64'h81FBDDA769A46910);
    
    data_o[0] = (syndrome_o == 7'h7) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'hb) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h13) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h23) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h43) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'hd) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h15) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h25) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h45) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h19) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h29) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'h49) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h31) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h51) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h61) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'he) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h16) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'h26) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h46) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h1a) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h2a) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'h4a) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h32) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h52) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h62) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h1c) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h2c) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h4c) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h34) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h54) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h64) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h38) ^ data_i[31];
    data_o[32] = (syndrome_o == 7'h58) ^ data_i[32];
    data_o[33] = (syndrome_o == 7'h68) ^ data_i[33];
    data_o[34] = (syndrome_o == 7'h70) ^ data_i[34];
    data_o[35] = (syndrome_o == 7'h1f) ^ data_i[35];
    data_o[36] = (syndrome_o == 7'h2f) ^ data_i[36];
    data_o[37] = (syndrome_o == 7'h4f) ^ data_i[37];
    data_o[38] = (syndrome_o == 7'h37) ^ data_i[38];
    data_o[39] = (syndrome_o == 7'h57) ^ data_i[39];
    data_o[40] = (syndrome_o == 7'h67) ^ data_i[40];
    data_o[41] = (syndrome_o == 7'h3b) ^ data_i[41];
    data_o[42] = (syndrome_o == 7'h5b) ^ data_i[42];
    data_o[43] = (syndrome_o == 7'h6b) ^ data_i[43];
    data_o[44] = (syndrome_o == 7'h73) ^ data_i[44];
    data_o[45] = (syndrome_o == 7'h3d) ^ data_i[45];
    data_o[46] = (syndrome_o == 7'h5d) ^ data_i[46];
    data_o[47] = (syndrome_o == 7'h6d) ^ data_i[47];
    data_o[48] = (syndrome_o == 7'h75) ^ data_i[48];
    data_o[49] = (syndrome_o == 7'h79) ^ data_i[49];
    data_o[50] = (syndrome_o == 7'h3e) ^ data_i[50];
    data_o[51] = (syndrome_o == 7'h5e) ^ data_i[51];
    data_o[52] = (syndrome_o == 7'h6e) ^ data_i[52];
    data_o[53] = (syndrome_o == 7'h76) ^ data_i[53];
    data_o[54] = (syndrome_o == 7'h7a) ^ data_i[54];
    data_o[55] = (syndrome_o == 7'h7c) ^ data_i[55];
    data_o[56] = (syndrome_o == 7'h7f) ^ data_i[56];
    
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);
  end
endmodule : prim_secded_inv_64_57_dec

module prim_secded_inv_64_57_enc (
  input        [56:0] data_i,
  output logic [63:0] data_o
);
  always_comb begin : p_encode
    data_o = 64'(data_i);
    data_o[57] = ^(data_o & 64'h0103FFF800007FFF);
    data_o[58] = ^(data_o & 64'h017C1FF801FF801F);
    data_o[59] = ^(data_o & 64'h01BDE1F87E0781E1);
    data_o[60] = ^(data_o & 64'h01DEEE3B8E388E22);
    data_o[61] = ^(data_o & 64'h01EF76CDB2C93244);
    data_o[62] = ^(data_o & 64'h01F7BB56D5525488);
    data_o[63] = ^(data_o & 64'h01FBDDA769A46910);
    data_o ^= 64'h5400000000000000;
  end
endmodule : prim_secded_inv_64_57_enc

package prim_secded_pkg;
  typedef enum int {
    SecdedHsiao,
    SecdedHamming,
    SecdedInvHsiao,
    SecdedInvHamming
  } prim_secded_type_e;
  typedef enum int {
    SecdedNone,
    Secded_22_16,
    Secded_28_22,
    Secded_39_32,
    Secded_64_57,
    Secded_72_64,
    SecdedHamming_22_16,
    SecdedHamming_39_32,
    SecdedHamming_72_64,
    SecdedHamming_76_68,
    SecdedInv_22_16,
    SecdedInv_28_22,
    SecdedInv_39_32,
    SecdedInv_64_57,
    SecdedInv_72_64,
    SecdedInvHamming_22_16,
    SecdedInvHamming_39_32,
    SecdedInvHamming_72_64,
    SecdedInvHamming_76_68
  } prim_secded_e;
  
  function automatic bit is_width_valid(prim_secded_type_e sd_type, int width);
    unique case (sd_type)
      SecdedHsiao:
        unique case (width)
          16: return 1'b1;
          22: return 1'b1;
          32: return 1'b1;
          57: return 1'b1;
          64: return 1'b1;
          default: return 1'b0;
        endcase
      SecdedHamming:
        unique case (width)
          16: return 1'b1;
          32: return 1'b1;
          64: return 1'b1;
          68: return 1'b1;
          default: return 1'b0;
        endcase
      SecdedInvHsiao:
        unique case (width)
          16: return 1'b1;
          22: return 1'b1;
          32: return 1'b1;
          57: return 1'b1;
          64: return 1'b1;
          default: return 1'b0;
        endcase
      SecdedInvHamming:
        unique case (width)
          16: return 1'b1;
          32: return 1'b1;
          64: return 1'b1;
          68: return 1'b1;
          default: return 1'b0;
        endcase
      default: return 1'b0;
    endcase
  endfunction : is_width_valid
  
  
  function automatic int get_synd_width(prim_secded_type_e sd_type, int width);
    unique case (sd_type)
      SecdedHsiao:
        unique case (width)
          16: return 6;
          22: return 6;
          32: return 7;
          57: return 7;
          64: return 8;
          default: return 0;
        endcase
      SecdedHamming:
        unique case (width)
          16: return 6;
          32: return 7;
          64: return 8;
          68: return 8;
          default: return 0;
        endcase
      SecdedInvHsiao:
        unique case (width)
          16: return 6;
          22: return 6;
          32: return 7;
          57: return 7;
          64: return 8;
          default: return 0;
        endcase
      SecdedInvHamming:
        unique case (width)
          16: return 6;
          32: return 7;
          64: return 8;
          68: return 8;
          default: return 0;
        endcase
      default: return 0;
    endcase
  endfunction : get_synd_width
  function automatic int get_full_width(prim_secded_type_e sd_type, int width);
    return width + get_synd_width(sd_type, width);
  endfunction : get_full_width
  function automatic int get_ecc_data_width(prim_secded_e ecc_type);
    case (ecc_type)
      Secded_22_16: return 16;
      Secded_28_22: return 22;
      Secded_39_32: return 32;
      Secded_64_57: return 57;
      Secded_72_64: return 64;
      SecdedHamming_22_16: return 16;
      SecdedHamming_39_32: return 32;
      SecdedHamming_72_64: return 64;
      SecdedHamming_76_68: return 68;
      SecdedInv_22_16: return 16;
      SecdedInv_28_22: return 22;
      SecdedInv_39_32: return 32;
      SecdedInv_64_57: return 57;
      SecdedInv_72_64: return 64;
      SecdedInvHamming_22_16: return 16;
      SecdedInvHamming_39_32: return 32;
      SecdedInvHamming_72_64: return 64;
      SecdedInvHamming_76_68: return 68;
      
      default: return 32;
    endcase
  endfunction
  function automatic int get_ecc_parity_width(prim_secded_e ecc_type);
    case (ecc_type)
      Secded_22_16: return 6;
      Secded_28_22: return 6;
      Secded_39_32: return 7;
      Secded_64_57: return 7;
      Secded_72_64: return 8;
      SecdedHamming_22_16: return 6;
      SecdedHamming_39_32: return 7;
      SecdedHamming_72_64: return 8;
      SecdedHamming_76_68: return 8;
      SecdedInv_22_16: return 6;
      SecdedInv_28_22: return 6;
      SecdedInv_39_32: return 7;
      SecdedInv_64_57: return 7;
      SecdedInv_72_64: return 8;
      SecdedInvHamming_22_16: return 6;
      SecdedInvHamming_39_32: return 7;
      SecdedInvHamming_72_64: return 8;
      SecdedInvHamming_76_68: return 8;
      default: return 0;
    endcase
  endfunction
  parameter logic [5:0] Secded2216ZeroEcc = 6'h0;
  parameter logic [21:0] Secded2216ZeroWord = 22'h0;
  typedef struct packed {
    logic [15:0] data;
    logic [5:0] syndrome;
    logic [1:0]  err;
  } secded_22_16_t;
  parameter logic [5:0] Secded2822ZeroEcc = 6'h0;
  parameter logic [27:0] Secded2822ZeroWord = 28'h0;
  typedef struct packed {
    logic [21:0] data;
    logic [5:0] syndrome;
    logic [1:0]  err;
  } secded_28_22_t;
  parameter logic [6:0] Secded3932ZeroEcc = 7'h0;
  parameter logic [38:0] Secded3932ZeroWord = 39'h0;
  typedef struct packed {
    logic [31:0] data;
    logic [6:0] syndrome;
    logic [1:0]  err;
  } secded_39_32_t;
  parameter logic [6:0] Secded6457ZeroEcc = 7'h0;
  parameter logic [63:0] Secded6457ZeroWord = 64'h0;
  typedef struct packed {
    logic [56:0] data;
    logic [6:0] syndrome;
    logic [1:0]  err;
  } secded_64_57_t;
  parameter logic [7:0] Secded7264ZeroEcc = 8'h0;
  parameter logic [71:0] Secded7264ZeroWord = 72'h0;
  typedef struct packed {
    logic [63:0] data;
    logic [7:0] syndrome;
    logic [1:0]  err;
  } secded_72_64_t;
  parameter logic [5:0] SecdedHamming2216ZeroEcc = 6'h0;
  parameter logic [21:0] SecdedHamming2216ZeroWord = 22'h0;
  typedef struct packed {
    logic [15:0] data;
    logic [5:0] syndrome;
    logic [1:0]  err;
  } secded_hamming_22_16_t;
  parameter logic [6:0] SecdedHamming3932ZeroEcc = 7'h0;
  parameter logic [38:0] SecdedHamming3932ZeroWord = 39'h0;
  typedef struct packed {
    logic [31:0] data;
    logic [6:0] syndrome;
    logic [1:0]  err;
  } secded_hamming_39_32_t;
  parameter logic [7:0] SecdedHamming7264ZeroEcc = 8'h0;
  parameter logic [71:0] SecdedHamming7264ZeroWord = 72'h0;
  typedef struct packed {
    logic [63:0] data;
    logic [7:0] syndrome;
    logic [1:0]  err;
  } secded_hamming_72_64_t;
  parameter logic [7:0] SecdedHamming7668ZeroEcc = 8'h0;
  parameter logic [75:0] SecdedHamming7668ZeroWord = 76'h0;
  typedef struct packed {
    logic [67:0] data;
    logic [7:0] syndrome;
    logic [1:0]  err;
  } secded_hamming_76_68_t;
  parameter logic [5:0] SecdedInv2216ZeroEcc = 6'h2A;
  parameter logic [21:0] SecdedInv2216ZeroWord = 22'h2A0000;
  typedef struct packed {
    logic [15:0] data;
    logic [5:0] syndrome;
    logic [1:0]  err;
  } secded_inv_22_16_t;
  parameter logic [5:0] SecdedInv2822ZeroEcc = 6'h2A;
  parameter logic [27:0] SecdedInv2822ZeroWord = 28'hA800000;
  typedef struct packed {
    logic [21:0] data;
    logic [5:0] syndrome;
    logic [1:0]  err;
  } secded_inv_28_22_t;
  parameter logic [6:0] SecdedInv3932ZeroEcc = 7'h2A;
  parameter logic [38:0] SecdedInv3932ZeroWord = 39'h2A00000000;
  typedef struct packed {
    logic [31:0] data;
    logic [6:0] syndrome;
    logic [1:0]  err;
  } secded_inv_39_32_t;
  parameter logic [6:0] SecdedInv6457ZeroEcc = 7'h2A;
  parameter logic [63:0] SecdedInv6457ZeroWord = 64'h5400000000000000;
  typedef struct packed {
    logic [56:0] data;
    logic [6:0] syndrome;
    logic [1:0]  err;
  } secded_inv_64_57_t;
  parameter logic [7:0] SecdedInv7264ZeroEcc = 8'hAA;
  parameter logic [71:0] SecdedInv7264ZeroWord = 72'hAA0000000000000000;
  typedef struct packed {
    logic [63:0] data;
    logic [7:0] syndrome;
    logic [1:0]  err;
  } secded_inv_72_64_t;
  parameter logic [5:0] SecdedInvHamming2216ZeroEcc = 6'h2A;
  parameter logic [21:0] SecdedInvHamming2216ZeroWord = 22'h2A0000;
  typedef struct packed {
    logic [15:0] data;
    logic [5:0] syndrome;
    logic [1:0]  err;
  } secded_inv_hamming_22_16_t;
  parameter logic [6:0] SecdedInvHamming3932ZeroEcc = 7'h2A;
  parameter logic [38:0] SecdedInvHamming3932ZeroWord = 39'h2A00000000;
  typedef struct packed {
    logic [31:0] data;
    logic [6:0] syndrome;
    logic [1:0]  err;
  } secded_inv_hamming_39_32_t;
  parameter logic [7:0] SecdedInvHamming7264ZeroEcc = 8'hAA;
  parameter logic [71:0] SecdedInvHamming7264ZeroWord = 72'hAA0000000000000000;
  typedef struct packed {
    logic [63:0] data;
    logic [7:0] syndrome;
    logic [1:0]  err;
  } secded_inv_hamming_72_64_t;
  parameter logic [7:0] SecdedInvHamming7668ZeroEcc = 8'hAA;
  parameter logic [75:0] SecdedInvHamming7668ZeroWord = 76'hAA00000000000000000;
  typedef struct packed {
    logic [67:0] data;
    logic [7:0] syndrome;
    logic [1:0]  err;
  } secded_inv_hamming_76_68_t;
  function automatic logic [21:0]
      prim_secded_22_16_enc (logic [15:0] data_i);
    logic [21:0] data_o;
    data_o = 22'(data_i);
    data_o[16] = ^(data_o & 22'h00496E);
    data_o[17] = ^(data_o & 22'h00F20B);
    data_o[18] = ^(data_o & 22'h008ED8);
    data_o[19] = ^(data_o & 22'h007714);
    data_o[20] = ^(data_o & 22'h00ACA5);
    data_o[21] = ^(data_o & 22'h0011F3);
    return data_o;
  endfunction
  function automatic secded_22_16_t
      prim_secded_22_16_dec (logic [21:0] data_i);
    logic [15:0] data_o;
    logic [5:0] syndrome_o;
    logic [1:0]  err_o;
    secded_22_16_t dec;
    
    syndrome_o[0] = ^(data_i & 22'h01496E);
    syndrome_o[1] = ^(data_i & 22'h02F20B);
    syndrome_o[2] = ^(data_i & 22'h048ED8);
    syndrome_o[3] = ^(data_i & 22'h087714);
    syndrome_o[4] = ^(data_i & 22'h10ACA5);
    syndrome_o[5] = ^(data_i & 22'h2011F3);
    
    data_o[0] = (syndrome_o == 6'h32) ^ data_i[0];
    data_o[1] = (syndrome_o == 6'h23) ^ data_i[1];
    data_o[2] = (syndrome_o == 6'h19) ^ data_i[2];
    data_o[3] = (syndrome_o == 6'h7) ^ data_i[3];
    data_o[4] = (syndrome_o == 6'h2c) ^ data_i[4];
    data_o[5] = (syndrome_o == 6'h31) ^ data_i[5];
    data_o[6] = (syndrome_o == 6'h25) ^ data_i[6];
    data_o[7] = (syndrome_o == 6'h34) ^ data_i[7];
    data_o[8] = (syndrome_o == 6'h29) ^ data_i[8];
    data_o[9] = (syndrome_o == 6'he) ^ data_i[9];
    data_o[10] = (syndrome_o == 6'h1c) ^ data_i[10];
    data_o[11] = (syndrome_o == 6'h15) ^ data_i[11];
    data_o[12] = (syndrome_o == 6'h2a) ^ data_i[12];
    data_o[13] = (syndrome_o == 6'h1a) ^ data_i[13];
    data_o[14] = (syndrome_o == 6'hb) ^ data_i[14];
    data_o[15] = (syndrome_o == 6'h16) ^ data_i[15];
    
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [27:0]
      prim_secded_28_22_enc (logic [21:0] data_i);
    logic [27:0] data_o;
    data_o = 28'(data_i);
    data_o[22] = ^(data_o & 28'h03003FF);
    data_o[23] = ^(data_o & 28'h010FC0F);
    data_o[24] = ^(data_o & 28'h0271C71);
    data_o[25] = ^(data_o & 28'h03B6592);
    data_o[26] = ^(data_o & 28'h03DAAA4);
    data_o[27] = ^(data_o & 28'h03ED348);
    return data_o;
  endfunction
  function automatic secded_28_22_t
      prim_secded_28_22_dec (logic [27:0] data_i);
    logic [21:0] data_o;
    logic [5:0] syndrome_o;
    logic [1:0]  err_o;
    secded_28_22_t dec;
    
    syndrome_o[0] = ^(data_i & 28'h07003FF);
    syndrome_o[1] = ^(data_i & 28'h090FC0F);
    syndrome_o[2] = ^(data_i & 28'h1271C71);
    syndrome_o[3] = ^(data_i & 28'h23B6592);
    syndrome_o[4] = ^(data_i & 28'h43DAAA4);
    syndrome_o[5] = ^(data_i & 28'h83ED348);
    
    data_o[0] = (syndrome_o == 6'h7) ^ data_i[0];
    data_o[1] = (syndrome_o == 6'hb) ^ data_i[1];
    data_o[2] = (syndrome_o == 6'h13) ^ data_i[2];
    data_o[3] = (syndrome_o == 6'h23) ^ data_i[3];
    data_o[4] = (syndrome_o == 6'hd) ^ data_i[4];
    data_o[5] = (syndrome_o == 6'h15) ^ data_i[5];
    data_o[6] = (syndrome_o == 6'h25) ^ data_i[6];
    data_o[7] = (syndrome_o == 6'h19) ^ data_i[7];
    data_o[8] = (syndrome_o == 6'h29) ^ data_i[8];
    data_o[9] = (syndrome_o == 6'h31) ^ data_i[9];
    data_o[10] = (syndrome_o == 6'he) ^ data_i[10];
    data_o[11] = (syndrome_o == 6'h16) ^ data_i[11];
    data_o[12] = (syndrome_o == 6'h26) ^ data_i[12];
    data_o[13] = (syndrome_o == 6'h1a) ^ data_i[13];
    data_o[14] = (syndrome_o == 6'h2a) ^ data_i[14];
    data_o[15] = (syndrome_o == 6'h32) ^ data_i[15];
    data_o[16] = (syndrome_o == 6'h1c) ^ data_i[16];
    data_o[17] = (syndrome_o == 6'h2c) ^ data_i[17];
    data_o[18] = (syndrome_o == 6'h34) ^ data_i[18];
    data_o[19] = (syndrome_o == 6'h38) ^ data_i[19];
    data_o[20] = (syndrome_o == 6'h3b) ^ data_i[20];
    data_o[21] = (syndrome_o == 6'h3d) ^ data_i[21];
    
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [38:0]
      prim_secded_39_32_enc (logic [31:0] data_i);
    logic [38:0] data_o;
    data_o = 39'(data_i);
    data_o[32] = ^(data_o & 39'h002606BD25);
    data_o[33] = ^(data_o & 39'h00DEBA8050);
    data_o[34] = ^(data_o & 39'h00413D89AA);
    data_o[35] = ^(data_o & 39'h0031234ED1);
    data_o[36] = ^(data_o & 39'h00C2C1323B);
    data_o[37] = ^(data_o & 39'h002DCC624C);
    data_o[38] = ^(data_o & 39'h0098505586);
    return data_o;
  endfunction
  function automatic secded_39_32_t
      prim_secded_39_32_dec (logic [38:0] data_i);
    logic [31:0] data_o;
    logic [6:0] syndrome_o;
    logic [1:0]  err_o;
    secded_39_32_t dec;
    
    syndrome_o[0] = ^(data_i & 39'h012606BD25);
    syndrome_o[1] = ^(data_i & 39'h02DEBA8050);
    syndrome_o[2] = ^(data_i & 39'h04413D89AA);
    syndrome_o[3] = ^(data_i & 39'h0831234ED1);
    syndrome_o[4] = ^(data_i & 39'h10C2C1323B);
    syndrome_o[5] = ^(data_i & 39'h202DCC624C);
    syndrome_o[6] = ^(data_i & 39'h4098505586);
    
    data_o[0] = (syndrome_o == 7'h19) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'h54) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h61) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h34) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h1a) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'h15) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h2a) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h4c) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h45) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h38) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h49) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'hd) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h51) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h31) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h68) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'h7) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h1c) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'hb) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h25) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h26) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h46) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'he) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h70) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h32) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h2c) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h13) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h23) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h62) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h4a) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h29) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h16) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h52) ^ data_i[31];
    
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [63:0]
      prim_secded_64_57_enc (logic [56:0] data_i);
    logic [63:0] data_o;
    data_o = 64'(data_i);
    data_o[57] = ^(data_o & 64'h0103FFF800007FFF);
    data_o[58] = ^(data_o & 64'h017C1FF801FF801F);
    data_o[59] = ^(data_o & 64'h01BDE1F87E0781E1);
    data_o[60] = ^(data_o & 64'h01DEEE3B8E388E22);
    data_o[61] = ^(data_o & 64'h01EF76CDB2C93244);
    data_o[62] = ^(data_o & 64'h01F7BB56D5525488);
    data_o[63] = ^(data_o & 64'h01FBDDA769A46910);
    return data_o;
  endfunction
  function automatic secded_64_57_t
      prim_secded_64_57_dec (logic [63:0] data_i);
    logic [56:0] data_o;
    logic [6:0] syndrome_o;
    logic [1:0]  err_o;
    secded_64_57_t dec;
    
    syndrome_o[0] = ^(data_i & 64'h0303FFF800007FFF);
    syndrome_o[1] = ^(data_i & 64'h057C1FF801FF801F);
    syndrome_o[2] = ^(data_i & 64'h09BDE1F87E0781E1);
    syndrome_o[3] = ^(data_i & 64'h11DEEE3B8E388E22);
    syndrome_o[4] = ^(data_i & 64'h21EF76CDB2C93244);
    syndrome_o[5] = ^(data_i & 64'h41F7BB56D5525488);
    syndrome_o[6] = ^(data_i & 64'h81FBDDA769A46910);
    
    data_o[0] = (syndrome_o == 7'h7) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'hb) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h13) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h23) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h43) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'hd) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h15) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h25) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h45) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h19) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h29) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'h49) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h31) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h51) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h61) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'he) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h16) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'h26) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h46) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h1a) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h2a) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'h4a) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h32) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h52) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h62) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h1c) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h2c) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h4c) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h34) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h54) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h64) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h38) ^ data_i[31];
    data_o[32] = (syndrome_o == 7'h58) ^ data_i[32];
    data_o[33] = (syndrome_o == 7'h68) ^ data_i[33];
    data_o[34] = (syndrome_o == 7'h70) ^ data_i[34];
    data_o[35] = (syndrome_o == 7'h1f) ^ data_i[35];
    data_o[36] = (syndrome_o == 7'h2f) ^ data_i[36];
    data_o[37] = (syndrome_o == 7'h4f) ^ data_i[37];
    data_o[38] = (syndrome_o == 7'h37) ^ data_i[38];
    data_o[39] = (syndrome_o == 7'h57) ^ data_i[39];
    data_o[40] = (syndrome_o == 7'h67) ^ data_i[40];
    data_o[41] = (syndrome_o == 7'h3b) ^ data_i[41];
    data_o[42] = (syndrome_o == 7'h5b) ^ data_i[42];
    data_o[43] = (syndrome_o == 7'h6b) ^ data_i[43];
    data_o[44] = (syndrome_o == 7'h73) ^ data_i[44];
    data_o[45] = (syndrome_o == 7'h3d) ^ data_i[45];
    data_o[46] = (syndrome_o == 7'h5d) ^ data_i[46];
    data_o[47] = (syndrome_o == 7'h6d) ^ data_i[47];
    data_o[48] = (syndrome_o == 7'h75) ^ data_i[48];
    data_o[49] = (syndrome_o == 7'h79) ^ data_i[49];
    data_o[50] = (syndrome_o == 7'h3e) ^ data_i[50];
    data_o[51] = (syndrome_o == 7'h5e) ^ data_i[51];
    data_o[52] = (syndrome_o == 7'h6e) ^ data_i[52];
    data_o[53] = (syndrome_o == 7'h76) ^ data_i[53];
    data_o[54] = (syndrome_o == 7'h7a) ^ data_i[54];
    data_o[55] = (syndrome_o == 7'h7c) ^ data_i[55];
    data_o[56] = (syndrome_o == 7'h7f) ^ data_i[56];
    
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [71:0]
      prim_secded_72_64_enc (logic [63:0] data_i);
    logic [71:0] data_o;
    data_o = 72'(data_i);
    data_o[64] = ^(data_o & 72'h00B9000000001FFFFF);
    data_o[65] = ^(data_o & 72'h005E00000FFFE0003F);
    data_o[66] = ^(data_o & 72'h0067003FF003E007C1);
    data_o[67] = ^(data_o & 72'h00CD0FC0F03C207842);
    data_o[68] = ^(data_o & 72'h00B671C711C4438884);
    data_o[69] = ^(data_o & 72'h00B5B65926488C9108);
    data_o[70] = ^(data_o & 72'h00CBDAAA4A91152210);
    data_o[71] = ^(data_o & 72'h007AED348D221A4420);
    return data_o;
  endfunction
  function automatic secded_72_64_t
      prim_secded_72_64_dec (logic [71:0] data_i);
    logic [63:0] data_o;
    logic [7:0] syndrome_o;
    logic [1:0]  err_o;
    secded_72_64_t dec;
    
    syndrome_o[0] = ^(data_i & 72'h01B9000000001FFFFF);
    syndrome_o[1] = ^(data_i & 72'h025E00000FFFE0003F);
    syndrome_o[2] = ^(data_i & 72'h0467003FF003E007C1);
    syndrome_o[3] = ^(data_i & 72'h08CD0FC0F03C207842);
    syndrome_o[4] = ^(data_i & 72'h10B671C711C4438884);
    syndrome_o[5] = ^(data_i & 72'h20B5B65926488C9108);
    syndrome_o[6] = ^(data_i & 72'h40CBDAAA4A91152210);
    syndrome_o[7] = ^(data_i & 72'h807AED348D221A4420);
    
    data_o[0] = (syndrome_o == 8'h7) ^ data_i[0];
    data_o[1] = (syndrome_o == 8'hb) ^ data_i[1];
    data_o[2] = (syndrome_o == 8'h13) ^ data_i[2];
    data_o[3] = (syndrome_o == 8'h23) ^ data_i[3];
    data_o[4] = (syndrome_o == 8'h43) ^ data_i[4];
    data_o[5] = (syndrome_o == 8'h83) ^ data_i[5];
    data_o[6] = (syndrome_o == 8'hd) ^ data_i[6];
    data_o[7] = (syndrome_o == 8'h15) ^ data_i[7];
    data_o[8] = (syndrome_o == 8'h25) ^ data_i[8];
    data_o[9] = (syndrome_o == 8'h45) ^ data_i[9];
    data_o[10] = (syndrome_o == 8'h85) ^ data_i[10];
    data_o[11] = (syndrome_o == 8'h19) ^ data_i[11];
    data_o[12] = (syndrome_o == 8'h29) ^ data_i[12];
    data_o[13] = (syndrome_o == 8'h49) ^ data_i[13];
    data_o[14] = (syndrome_o == 8'h89) ^ data_i[14];
    data_o[15] = (syndrome_o == 8'h31) ^ data_i[15];
    data_o[16] = (syndrome_o == 8'h51) ^ data_i[16];
    data_o[17] = (syndrome_o == 8'h91) ^ data_i[17];
    data_o[18] = (syndrome_o == 8'h61) ^ data_i[18];
    data_o[19] = (syndrome_o == 8'ha1) ^ data_i[19];
    data_o[20] = (syndrome_o == 8'hc1) ^ data_i[20];
    data_o[21] = (syndrome_o == 8'he) ^ data_i[21];
    data_o[22] = (syndrome_o == 8'h16) ^ data_i[22];
    data_o[23] = (syndrome_o == 8'h26) ^ data_i[23];
    data_o[24] = (syndrome_o == 8'h46) ^ data_i[24];
    data_o[25] = (syndrome_o == 8'h86) ^ data_i[25];
    data_o[26] = (syndrome_o == 8'h1a) ^ data_i[26];
    data_o[27] = (syndrome_o == 8'h2a) ^ data_i[27];
    data_o[28] = (syndrome_o == 8'h4a) ^ data_i[28];
    data_o[29] = (syndrome_o == 8'h8a) ^ data_i[29];
    data_o[30] = (syndrome_o == 8'h32) ^ data_i[30];
    data_o[31] = (syndrome_o == 8'h52) ^ data_i[31];
    data_o[32] = (syndrome_o == 8'h92) ^ data_i[32];
    data_o[33] = (syndrome_o == 8'h62) ^ data_i[33];
    data_o[34] = (syndrome_o == 8'ha2) ^ data_i[34];
    data_o[35] = (syndrome_o == 8'hc2) ^ data_i[35];
    data_o[36] = (syndrome_o == 8'h1c) ^ data_i[36];
    data_o[37] = (syndrome_o == 8'h2c) ^ data_i[37];
    data_o[38] = (syndrome_o == 8'h4c) ^ data_i[38];
    data_o[39] = (syndrome_o == 8'h8c) ^ data_i[39];
    data_o[40] = (syndrome_o == 8'h34) ^ data_i[40];
    data_o[41] = (syndrome_o == 8'h54) ^ data_i[41];
    data_o[42] = (syndrome_o == 8'h94) ^ data_i[42];
    data_o[43] = (syndrome_o == 8'h64) ^ data_i[43];
    data_o[44] = (syndrome_o == 8'ha4) ^ data_i[44];
    data_o[45] = (syndrome_o == 8'hc4) ^ data_i[45];
    data_o[46] = (syndrome_o == 8'h38) ^ data_i[46];
    data_o[47] = (syndrome_o == 8'h58) ^ data_i[47];
    data_o[48] = (syndrome_o == 8'h98) ^ data_i[48];
    data_o[49] = (syndrome_o == 8'h68) ^ data_i[49];
    data_o[50] = (syndrome_o == 8'ha8) ^ data_i[50];
    data_o[51] = (syndrome_o == 8'hc8) ^ data_i[51];
    data_o[52] = (syndrome_o == 8'h70) ^ data_i[52];
    data_o[53] = (syndrome_o == 8'hb0) ^ data_i[53];
    data_o[54] = (syndrome_o == 8'hd0) ^ data_i[54];
    data_o[55] = (syndrome_o == 8'he0) ^ data_i[55];
    data_o[56] = (syndrome_o == 8'h6d) ^ data_i[56];
    data_o[57] = (syndrome_o == 8'hd6) ^ data_i[57];
    data_o[58] = (syndrome_o == 8'h3e) ^ data_i[58];
    data_o[59] = (syndrome_o == 8'hcb) ^ data_i[59];
    data_o[60] = (syndrome_o == 8'hb3) ^ data_i[60];
    data_o[61] = (syndrome_o == 8'hb5) ^ data_i[61];
    data_o[62] = (syndrome_o == 8'hce) ^ data_i[62];
    data_o[63] = (syndrome_o == 8'h79) ^ data_i[63];
    
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [21:0]
      prim_secded_hamming_22_16_enc (logic [15:0] data_i);
    logic [21:0] data_o;
    data_o = 22'(data_i);
    data_o[16] = ^(data_o & 22'h00AD5B);
    data_o[17] = ^(data_o & 22'h00366D);
    data_o[18] = ^(data_o & 22'h00C78E);
    data_o[19] = ^(data_o & 22'h0007F0);
    data_o[20] = ^(data_o & 22'h00F800);
    data_o[21] = ^(data_o & 22'h1FFFFF);
    return data_o;
  endfunction
  function automatic secded_hamming_22_16_t
      prim_secded_hamming_22_16_dec (logic [21:0] data_i);
    logic [15:0] data_o;
    logic [5:0] syndrome_o;
    logic [1:0]  err_o;
    secded_hamming_22_16_t dec;
    
    syndrome_o[0] = ^(data_i & 22'h01AD5B);
    syndrome_o[1] = ^(data_i & 22'h02366D);
    syndrome_o[2] = ^(data_i & 22'h04C78E);
    syndrome_o[3] = ^(data_i & 22'h0807F0);
    syndrome_o[4] = ^(data_i & 22'h10F800);
    syndrome_o[5] = ^(data_i & 22'h3FFFFF);
    
    data_o[0] = (syndrome_o == 6'h23) ^ data_i[0];
    data_o[1] = (syndrome_o == 6'h25) ^ data_i[1];
    data_o[2] = (syndrome_o == 6'h26) ^ data_i[2];
    data_o[3] = (syndrome_o == 6'h27) ^ data_i[3];
    data_o[4] = (syndrome_o == 6'h29) ^ data_i[4];
    data_o[5] = (syndrome_o == 6'h2a) ^ data_i[5];
    data_o[6] = (syndrome_o == 6'h2b) ^ data_i[6];
    data_o[7] = (syndrome_o == 6'h2c) ^ data_i[7];
    data_o[8] = (syndrome_o == 6'h2d) ^ data_i[8];
    data_o[9] = (syndrome_o == 6'h2e) ^ data_i[9];
    data_o[10] = (syndrome_o == 6'h2f) ^ data_i[10];
    data_o[11] = (syndrome_o == 6'h31) ^ data_i[11];
    data_o[12] = (syndrome_o == 6'h32) ^ data_i[12];
    data_o[13] = (syndrome_o == 6'h33) ^ data_i[13];
    data_o[14] = (syndrome_o == 6'h34) ^ data_i[14];
    data_o[15] = (syndrome_o == 6'h35) ^ data_i[15];
    
    err_o[0] = syndrome_o[5];
    err_o[1] = |syndrome_o[4:0] & ~syndrome_o[5];
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [38:0]
      prim_secded_hamming_39_32_enc (logic [31:0] data_i);
    logic [38:0] data_o;
    data_o = 39'(data_i);
    data_o[32] = ^(data_o & 39'h0056AAAD5B);
    data_o[33] = ^(data_o & 39'h009B33366D);
    data_o[34] = ^(data_o & 39'h00E3C3C78E);
    data_o[35] = ^(data_o & 39'h0003FC07F0);
    data_o[36] = ^(data_o & 39'h0003FFF800);
    data_o[37] = ^(data_o & 39'h00FC000000);
    data_o[38] = ^(data_o & 39'h3FFFFFFFFF);
    return data_o;
  endfunction
  function automatic secded_hamming_39_32_t
      prim_secded_hamming_39_32_dec (logic [38:0] data_i);
    logic [31:0] data_o;
    logic [6:0] syndrome_o;
    logic [1:0]  err_o;
    secded_hamming_39_32_t dec;
    
    syndrome_o[0] = ^(data_i & 39'h0156AAAD5B);
    syndrome_o[1] = ^(data_i & 39'h029B33366D);
    syndrome_o[2] = ^(data_i & 39'h04E3C3C78E);
    syndrome_o[3] = ^(data_i & 39'h0803FC07F0);
    syndrome_o[4] = ^(data_i & 39'h1003FFF800);
    syndrome_o[5] = ^(data_i & 39'h20FC000000);
    syndrome_o[6] = ^(data_i & 39'h7FFFFFFFFF);
    
    data_o[0] = (syndrome_o == 7'h43) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'h45) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h46) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h47) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h49) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'h4a) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h4b) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h4c) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h4d) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h4e) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h4f) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'h51) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h52) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h53) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h54) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'h55) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h56) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'h57) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h58) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h59) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h5a) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'h5b) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h5c) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h5d) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h5e) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h5f) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h61) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h62) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h63) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h64) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h65) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h66) ^ data_i[31];
    
    err_o[0] = syndrome_o[6];
    err_o[1] = |syndrome_o[5:0] & ~syndrome_o[6];
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [71:0]
      prim_secded_hamming_72_64_enc (logic [63:0] data_i);
    logic [71:0] data_o;
    data_o = 72'(data_i);
    data_o[64] = ^(data_o & 72'h00AB55555556AAAD5B);
    data_o[65] = ^(data_o & 72'h00CD9999999B33366D);
    data_o[66] = ^(data_o & 72'h00F1E1E1E1E3C3C78E);
    data_o[67] = ^(data_o & 72'h0001FE01FE03FC07F0);
    data_o[68] = ^(data_o & 72'h0001FFFE0003FFF800);
    data_o[69] = ^(data_o & 72'h0001FFFFFFFC000000);
    data_o[70] = ^(data_o & 72'h00FE00000000000000);
    data_o[71] = ^(data_o & 72'h7FFFFFFFFFFFFFFFFF);
    return data_o;
  endfunction
  function automatic secded_hamming_72_64_t
      prim_secded_hamming_72_64_dec (logic [71:0] data_i);
    logic [63:0] data_o;
    logic [7:0] syndrome_o;
    logic [1:0]  err_o;
    secded_hamming_72_64_t dec;
    
    syndrome_o[0] = ^(data_i & 72'h01AB55555556AAAD5B);
    syndrome_o[1] = ^(data_i & 72'h02CD9999999B33366D);
    syndrome_o[2] = ^(data_i & 72'h04F1E1E1E1E3C3C78E);
    syndrome_o[3] = ^(data_i & 72'h0801FE01FE03FC07F0);
    syndrome_o[4] = ^(data_i & 72'h1001FFFE0003FFF800);
    syndrome_o[5] = ^(data_i & 72'h2001FFFFFFFC000000);
    syndrome_o[6] = ^(data_i & 72'h40FE00000000000000);
    syndrome_o[7] = ^(data_i & 72'hFFFFFFFFFFFFFFFFFF);
    
    data_o[0] = (syndrome_o == 8'h83) ^ data_i[0];
    data_o[1] = (syndrome_o == 8'h85) ^ data_i[1];
    data_o[2] = (syndrome_o == 8'h86) ^ data_i[2];
    data_o[3] = (syndrome_o == 8'h87) ^ data_i[3];
    data_o[4] = (syndrome_o == 8'h89) ^ data_i[4];
    data_o[5] = (syndrome_o == 8'h8a) ^ data_i[5];
    data_o[6] = (syndrome_o == 8'h8b) ^ data_i[6];
    data_o[7] = (syndrome_o == 8'h8c) ^ data_i[7];
    data_o[8] = (syndrome_o == 8'h8d) ^ data_i[8];
    data_o[9] = (syndrome_o == 8'h8e) ^ data_i[9];
    data_o[10] = (syndrome_o == 8'h8f) ^ data_i[10];
    data_o[11] = (syndrome_o == 8'h91) ^ data_i[11];
    data_o[12] = (syndrome_o == 8'h92) ^ data_i[12];
    data_o[13] = (syndrome_o == 8'h93) ^ data_i[13];
    data_o[14] = (syndrome_o == 8'h94) ^ data_i[14];
    data_o[15] = (syndrome_o == 8'h95) ^ data_i[15];
    data_o[16] = (syndrome_o == 8'h96) ^ data_i[16];
    data_o[17] = (syndrome_o == 8'h97) ^ data_i[17];
    data_o[18] = (syndrome_o == 8'h98) ^ data_i[18];
    data_o[19] = (syndrome_o == 8'h99) ^ data_i[19];
    data_o[20] = (syndrome_o == 8'h9a) ^ data_i[20];
    data_o[21] = (syndrome_o == 8'h9b) ^ data_i[21];
    data_o[22] = (syndrome_o == 8'h9c) ^ data_i[22];
    data_o[23] = (syndrome_o == 8'h9d) ^ data_i[23];
    data_o[24] = (syndrome_o == 8'h9e) ^ data_i[24];
    data_o[25] = (syndrome_o == 8'h9f) ^ data_i[25];
    data_o[26] = (syndrome_o == 8'ha1) ^ data_i[26];
    data_o[27] = (syndrome_o == 8'ha2) ^ data_i[27];
    data_o[28] = (syndrome_o == 8'ha3) ^ data_i[28];
    data_o[29] = (syndrome_o == 8'ha4) ^ data_i[29];
    data_o[30] = (syndrome_o == 8'ha5) ^ data_i[30];
    data_o[31] = (syndrome_o == 8'ha6) ^ data_i[31];
    data_o[32] = (syndrome_o == 8'ha7) ^ data_i[32];
    data_o[33] = (syndrome_o == 8'ha8) ^ data_i[33];
    data_o[34] = (syndrome_o == 8'ha9) ^ data_i[34];
    data_o[35] = (syndrome_o == 8'haa) ^ data_i[35];
    data_o[36] = (syndrome_o == 8'hab) ^ data_i[36];
    data_o[37] = (syndrome_o == 8'hac) ^ data_i[37];
    data_o[38] = (syndrome_o == 8'had) ^ data_i[38];
    data_o[39] = (syndrome_o == 8'hae) ^ data_i[39];
    data_o[40] = (syndrome_o == 8'haf) ^ data_i[40];
    data_o[41] = (syndrome_o == 8'hb0) ^ data_i[41];
    data_o[42] = (syndrome_o == 8'hb1) ^ data_i[42];
    data_o[43] = (syndrome_o == 8'hb2) ^ data_i[43];
    data_o[44] = (syndrome_o == 8'hb3) ^ data_i[44];
    data_o[45] = (syndrome_o == 8'hb4) ^ data_i[45];
    data_o[46] = (syndrome_o == 8'hb5) ^ data_i[46];
    data_o[47] = (syndrome_o == 8'hb6) ^ data_i[47];
    data_o[48] = (syndrome_o == 8'hb7) ^ data_i[48];
    data_o[49] = (syndrome_o == 8'hb8) ^ data_i[49];
    data_o[50] = (syndrome_o == 8'hb9) ^ data_i[50];
    data_o[51] = (syndrome_o == 8'hba) ^ data_i[51];
    data_o[52] = (syndrome_o == 8'hbb) ^ data_i[52];
    data_o[53] = (syndrome_o == 8'hbc) ^ data_i[53];
    data_o[54] = (syndrome_o == 8'hbd) ^ data_i[54];
    data_o[55] = (syndrome_o == 8'hbe) ^ data_i[55];
    data_o[56] = (syndrome_o == 8'hbf) ^ data_i[56];
    data_o[57] = (syndrome_o == 8'hc1) ^ data_i[57];
    data_o[58] = (syndrome_o == 8'hc2) ^ data_i[58];
    data_o[59] = (syndrome_o == 8'hc3) ^ data_i[59];
    data_o[60] = (syndrome_o == 8'hc4) ^ data_i[60];
    data_o[61] = (syndrome_o == 8'hc5) ^ data_i[61];
    data_o[62] = (syndrome_o == 8'hc6) ^ data_i[62];
    data_o[63] = (syndrome_o == 8'hc7) ^ data_i[63];
    
    err_o[0] = syndrome_o[7];
    err_o[1] = |syndrome_o[6:0] & ~syndrome_o[7];
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [75:0]
      prim_secded_hamming_76_68_enc (logic [67:0] data_i);
    logic [75:0] data_o;
    data_o = 76'(data_i);
    data_o[68] = ^(data_o & 76'h00AAB55555556AAAD5B);
    data_o[69] = ^(data_o & 76'h00CCD9999999B33366D);
    data_o[70] = ^(data_o & 76'h000F1E1E1E1E3C3C78E);
    data_o[71] = ^(data_o & 76'h00F01FE01FE03FC07F0);
    data_o[72] = ^(data_o & 76'h00001FFFE0003FFF800);
    data_o[73] = ^(data_o & 76'h00001FFFFFFFC000000);
    data_o[74] = ^(data_o & 76'h00FFE00000000000000);
    data_o[75] = ^(data_o & 76'h7FFFFFFFFFFFFFFFFFF);
    return data_o;
  endfunction
  function automatic secded_hamming_76_68_t
      prim_secded_hamming_76_68_dec (logic [75:0] data_i);
    logic [67:0] data_o;
    logic [7:0] syndrome_o;
    logic [1:0]  err_o;
    secded_hamming_76_68_t dec;
    
    syndrome_o[0] = ^(data_i & 76'h01AAB55555556AAAD5B);
    syndrome_o[1] = ^(data_i & 76'h02CCD9999999B33366D);
    syndrome_o[2] = ^(data_i & 76'h040F1E1E1E1E3C3C78E);
    syndrome_o[3] = ^(data_i & 76'h08F01FE01FE03FC07F0);
    syndrome_o[4] = ^(data_i & 76'h10001FFFE0003FFF800);
    syndrome_o[5] = ^(data_i & 76'h20001FFFFFFFC000000);
    syndrome_o[6] = ^(data_i & 76'h40FFE00000000000000);
    syndrome_o[7] = ^(data_i & 76'hFFFFFFFFFFFFFFFFFFF);
    
    data_o[0] = (syndrome_o == 8'h83) ^ data_i[0];
    data_o[1] = (syndrome_o == 8'h85) ^ data_i[1];
    data_o[2] = (syndrome_o == 8'h86) ^ data_i[2];
    data_o[3] = (syndrome_o == 8'h87) ^ data_i[3];
    data_o[4] = (syndrome_o == 8'h89) ^ data_i[4];
    data_o[5] = (syndrome_o == 8'h8a) ^ data_i[5];
    data_o[6] = (syndrome_o == 8'h8b) ^ data_i[6];
    data_o[7] = (syndrome_o == 8'h8c) ^ data_i[7];
    data_o[8] = (syndrome_o == 8'h8d) ^ data_i[8];
    data_o[9] = (syndrome_o == 8'h8e) ^ data_i[9];
    data_o[10] = (syndrome_o == 8'h8f) ^ data_i[10];
    data_o[11] = (syndrome_o == 8'h91) ^ data_i[11];
    data_o[12] = (syndrome_o == 8'h92) ^ data_i[12];
    data_o[13] = (syndrome_o == 8'h93) ^ data_i[13];
    data_o[14] = (syndrome_o == 8'h94) ^ data_i[14];
    data_o[15] = (syndrome_o == 8'h95) ^ data_i[15];
    data_o[16] = (syndrome_o == 8'h96) ^ data_i[16];
    data_o[17] = (syndrome_o == 8'h97) ^ data_i[17];
    data_o[18] = (syndrome_o == 8'h98) ^ data_i[18];
    data_o[19] = (syndrome_o == 8'h99) ^ data_i[19];
    data_o[20] = (syndrome_o == 8'h9a) ^ data_i[20];
    data_o[21] = (syndrome_o == 8'h9b) ^ data_i[21];
    data_o[22] = (syndrome_o == 8'h9c) ^ data_i[22];
    data_o[23] = (syndrome_o == 8'h9d) ^ data_i[23];
    data_o[24] = (syndrome_o == 8'h9e) ^ data_i[24];
    data_o[25] = (syndrome_o == 8'h9f) ^ data_i[25];
    data_o[26] = (syndrome_o == 8'ha1) ^ data_i[26];
    data_o[27] = (syndrome_o == 8'ha2) ^ data_i[27];
    data_o[28] = (syndrome_o == 8'ha3) ^ data_i[28];
    data_o[29] = (syndrome_o == 8'ha4) ^ data_i[29];
    data_o[30] = (syndrome_o == 8'ha5) ^ data_i[30];
    data_o[31] = (syndrome_o == 8'ha6) ^ data_i[31];
    data_o[32] = (syndrome_o == 8'ha7) ^ data_i[32];
    data_o[33] = (syndrome_o == 8'ha8) ^ data_i[33];
    data_o[34] = (syndrome_o == 8'ha9) ^ data_i[34];
    data_o[35] = (syndrome_o == 8'haa) ^ data_i[35];
    data_o[36] = (syndrome_o == 8'hab) ^ data_i[36];
    data_o[37] = (syndrome_o == 8'hac) ^ data_i[37];
    data_o[38] = (syndrome_o == 8'had) ^ data_i[38];
    data_o[39] = (syndrome_o == 8'hae) ^ data_i[39];
    data_o[40] = (syndrome_o == 8'haf) ^ data_i[40];
    data_o[41] = (syndrome_o == 8'hb0) ^ data_i[41];
    data_o[42] = (syndrome_o == 8'hb1) ^ data_i[42];
    data_o[43] = (syndrome_o == 8'hb2) ^ data_i[43];
    data_o[44] = (syndrome_o == 8'hb3) ^ data_i[44];
    data_o[45] = (syndrome_o == 8'hb4) ^ data_i[45];
    data_o[46] = (syndrome_o == 8'hb5) ^ data_i[46];
    data_o[47] = (syndrome_o == 8'hb6) ^ data_i[47];
    data_o[48] = (syndrome_o == 8'hb7) ^ data_i[48];
    data_o[49] = (syndrome_o == 8'hb8) ^ data_i[49];
    data_o[50] = (syndrome_o == 8'hb9) ^ data_i[50];
    data_o[51] = (syndrome_o == 8'hba) ^ data_i[51];
    data_o[52] = (syndrome_o == 8'hbb) ^ data_i[52];
    data_o[53] = (syndrome_o == 8'hbc) ^ data_i[53];
    data_o[54] = (syndrome_o == 8'hbd) ^ data_i[54];
    data_o[55] = (syndrome_o == 8'hbe) ^ data_i[55];
    data_o[56] = (syndrome_o == 8'hbf) ^ data_i[56];
    data_o[57] = (syndrome_o == 8'hc1) ^ data_i[57];
    data_o[58] = (syndrome_o == 8'hc2) ^ data_i[58];
    data_o[59] = (syndrome_o == 8'hc3) ^ data_i[59];
    data_o[60] = (syndrome_o == 8'hc4) ^ data_i[60];
    data_o[61] = (syndrome_o == 8'hc5) ^ data_i[61];
    data_o[62] = (syndrome_o == 8'hc6) ^ data_i[62];
    data_o[63] = (syndrome_o == 8'hc7) ^ data_i[63];
    data_o[64] = (syndrome_o == 8'hc8) ^ data_i[64];
    data_o[65] = (syndrome_o == 8'hc9) ^ data_i[65];
    data_o[66] = (syndrome_o == 8'hca) ^ data_i[66];
    data_o[67] = (syndrome_o == 8'hcb) ^ data_i[67];
    
    err_o[0] = syndrome_o[7];
    err_o[1] = |syndrome_o[6:0] & ~syndrome_o[7];
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [21:0]
      prim_secded_inv_22_16_enc (logic [15:0] data_i);
    logic [21:0] data_o;
    data_o = 22'(data_i);
    data_o[16] = ^(data_o & 22'h00496E);
    data_o[17] = ^(data_o & 22'h00F20B);
    data_o[18] = ^(data_o & 22'h008ED8);
    data_o[19] = ^(data_o & 22'h007714);
    data_o[20] = ^(data_o & 22'h00ACA5);
    data_o[21] = ^(data_o & 22'h0011F3);
    data_o ^= 22'h2A0000;
    return data_o;
  endfunction
  function automatic secded_inv_22_16_t
      prim_secded_inv_22_16_dec (logic [21:0] data_i);
    logic [15:0] data_o;
    logic [5:0] syndrome_o;
    logic [1:0]  err_o;
    secded_inv_22_16_t dec;
    
    syndrome_o[0] = ^((data_i ^ 22'h2A0000) & 22'h01496E);
    syndrome_o[1] = ^((data_i ^ 22'h2A0000) & 22'h02F20B);
    syndrome_o[2] = ^((data_i ^ 22'h2A0000) & 22'h048ED8);
    syndrome_o[3] = ^((data_i ^ 22'h2A0000) & 22'h087714);
    syndrome_o[4] = ^((data_i ^ 22'h2A0000) & 22'h10ACA5);
    syndrome_o[5] = ^((data_i ^ 22'h2A0000) & 22'h2011F3);
    
    data_o[0] = (syndrome_o == 6'h32) ^ data_i[0];
    data_o[1] = (syndrome_o == 6'h23) ^ data_i[1];
    data_o[2] = (syndrome_o == 6'h19) ^ data_i[2];
    data_o[3] = (syndrome_o == 6'h7) ^ data_i[3];
    data_o[4] = (syndrome_o == 6'h2c) ^ data_i[4];
    data_o[5] = (syndrome_o == 6'h31) ^ data_i[5];
    data_o[6] = (syndrome_o == 6'h25) ^ data_i[6];
    data_o[7] = (syndrome_o == 6'h34) ^ data_i[7];
    data_o[8] = (syndrome_o == 6'h29) ^ data_i[8];
    data_o[9] = (syndrome_o == 6'he) ^ data_i[9];
    data_o[10] = (syndrome_o == 6'h1c) ^ data_i[10];
    data_o[11] = (syndrome_o == 6'h15) ^ data_i[11];
    data_o[12] = (syndrome_o == 6'h2a) ^ data_i[12];
    data_o[13] = (syndrome_o == 6'h1a) ^ data_i[13];
    data_o[14] = (syndrome_o == 6'hb) ^ data_i[14];
    data_o[15] = (syndrome_o == 6'h16) ^ data_i[15];
    
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [27:0]
      prim_secded_inv_28_22_enc (logic [21:0] data_i);
    logic [27:0] data_o;
    data_o = 28'(data_i);
    data_o[22] = ^(data_o & 28'h03003FF);
    data_o[23] = ^(data_o & 28'h010FC0F);
    data_o[24] = ^(data_o & 28'h0271C71);
    data_o[25] = ^(data_o & 28'h03B6592);
    data_o[26] = ^(data_o & 28'h03DAAA4);
    data_o[27] = ^(data_o & 28'h03ED348);
    data_o ^= 28'hA800000;
    return data_o;
  endfunction
  function automatic secded_inv_28_22_t
      prim_secded_inv_28_22_dec (logic [27:0] data_i);
    logic [21:0] data_o;
    logic [5:0] syndrome_o;
    logic [1:0]  err_o;
    secded_inv_28_22_t dec;
    
    syndrome_o[0] = ^((data_i ^ 28'hA800000) & 28'h07003FF);
    syndrome_o[1] = ^((data_i ^ 28'hA800000) & 28'h090FC0F);
    syndrome_o[2] = ^((data_i ^ 28'hA800000) & 28'h1271C71);
    syndrome_o[3] = ^((data_i ^ 28'hA800000) & 28'h23B6592);
    syndrome_o[4] = ^((data_i ^ 28'hA800000) & 28'h43DAAA4);
    syndrome_o[5] = ^((data_i ^ 28'hA800000) & 28'h83ED348);
    
    data_o[0] = (syndrome_o == 6'h7) ^ data_i[0];
    data_o[1] = (syndrome_o == 6'hb) ^ data_i[1];
    data_o[2] = (syndrome_o == 6'h13) ^ data_i[2];
    data_o[3] = (syndrome_o == 6'h23) ^ data_i[3];
    data_o[4] = (syndrome_o == 6'hd) ^ data_i[4];
    data_o[5] = (syndrome_o == 6'h15) ^ data_i[5];
    data_o[6] = (syndrome_o == 6'h25) ^ data_i[6];
    data_o[7] = (syndrome_o == 6'h19) ^ data_i[7];
    data_o[8] = (syndrome_o == 6'h29) ^ data_i[8];
    data_o[9] = (syndrome_o == 6'h31) ^ data_i[9];
    data_o[10] = (syndrome_o == 6'he) ^ data_i[10];
    data_o[11] = (syndrome_o == 6'h16) ^ data_i[11];
    data_o[12] = (syndrome_o == 6'h26) ^ data_i[12];
    data_o[13] = (syndrome_o == 6'h1a) ^ data_i[13];
    data_o[14] = (syndrome_o == 6'h2a) ^ data_i[14];
    data_o[15] = (syndrome_o == 6'h32) ^ data_i[15];
    data_o[16] = (syndrome_o == 6'h1c) ^ data_i[16];
    data_o[17] = (syndrome_o == 6'h2c) ^ data_i[17];
    data_o[18] = (syndrome_o == 6'h34) ^ data_i[18];
    data_o[19] = (syndrome_o == 6'h38) ^ data_i[19];
    data_o[20] = (syndrome_o == 6'h3b) ^ data_i[20];
    data_o[21] = (syndrome_o == 6'h3d) ^ data_i[21];
    
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [38:0]
      prim_secded_inv_39_32_enc (logic [31:0] data_i);
    logic [38:0] data_o;
    data_o = 39'(data_i);
    data_o[32] = ^(data_o & 39'h002606BD25);
    data_o[33] = ^(data_o & 39'h00DEBA8050);
    data_o[34] = ^(data_o & 39'h00413D89AA);
    data_o[35] = ^(data_o & 39'h0031234ED1);
    data_o[36] = ^(data_o & 39'h00C2C1323B);
    data_o[37] = ^(data_o & 39'h002DCC624C);
    data_o[38] = ^(data_o & 39'h0098505586);
    data_o ^= 39'h2A00000000;
    return data_o;
  endfunction
  function automatic secded_inv_39_32_t
      prim_secded_inv_39_32_dec (logic [38:0] data_i);
    logic [31:0] data_o;
    logic [6:0] syndrome_o;
    logic [1:0]  err_o;
    secded_inv_39_32_t dec;
    
    syndrome_o[0] = ^((data_i ^ 39'h2A00000000) & 39'h012606BD25);
    syndrome_o[1] = ^((data_i ^ 39'h2A00000000) & 39'h02DEBA8050);
    syndrome_o[2] = ^((data_i ^ 39'h2A00000000) & 39'h04413D89AA);
    syndrome_o[3] = ^((data_i ^ 39'h2A00000000) & 39'h0831234ED1);
    syndrome_o[4] = ^((data_i ^ 39'h2A00000000) & 39'h10C2C1323B);
    syndrome_o[5] = ^((data_i ^ 39'h2A00000000) & 39'h202DCC624C);
    syndrome_o[6] = ^((data_i ^ 39'h2A00000000) & 39'h4098505586);
    
    data_o[0] = (syndrome_o == 7'h19) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'h54) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h61) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h34) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h1a) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'h15) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h2a) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h4c) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h45) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h38) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h49) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'hd) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h51) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h31) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h68) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'h7) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h1c) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'hb) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h25) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h26) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h46) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'he) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h70) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h32) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h2c) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h13) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h23) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h62) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h4a) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h29) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h16) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h52) ^ data_i[31];
    
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [63:0]
      prim_secded_inv_64_57_enc (logic [56:0] data_i);
    logic [63:0] data_o;
    data_o = 64'(data_i);
    data_o[57] = ^(data_o & 64'h0103FFF800007FFF);
    data_o[58] = ^(data_o & 64'h017C1FF801FF801F);
    data_o[59] = ^(data_o & 64'h01BDE1F87E0781E1);
    data_o[60] = ^(data_o & 64'h01DEEE3B8E388E22);
    data_o[61] = ^(data_o & 64'h01EF76CDB2C93244);
    data_o[62] = ^(data_o & 64'h01F7BB56D5525488);
    data_o[63] = ^(data_o & 64'h01FBDDA769A46910);
    data_o ^= 64'h5400000000000000;
    return data_o;
  endfunction
  function automatic secded_inv_64_57_t
      prim_secded_inv_64_57_dec (logic [63:0] data_i);
    logic [56:0] data_o;
    logic [6:0] syndrome_o;
    logic [1:0]  err_o;
    secded_inv_64_57_t dec;
    
    syndrome_o[0] = ^((data_i ^ 64'h5400000000000000) & 64'h0303FFF800007FFF);
    syndrome_o[1] = ^((data_i ^ 64'h5400000000000000) & 64'h057C1FF801FF801F);
    syndrome_o[2] = ^((data_i ^ 64'h5400000000000000) & 64'h09BDE1F87E0781E1);
    syndrome_o[3] = ^((data_i ^ 64'h5400000000000000) & 64'h11DEEE3B8E388E22);
    syndrome_o[4] = ^((data_i ^ 64'h5400000000000000) & 64'h21EF76CDB2C93244);
    syndrome_o[5] = ^((data_i ^ 64'h5400000000000000) & 64'h41F7BB56D5525488);
    syndrome_o[6] = ^((data_i ^ 64'h5400000000000000) & 64'h81FBDDA769A46910);
    
    data_o[0] = (syndrome_o == 7'h7) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'hb) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h13) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h23) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h43) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'hd) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h15) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h25) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h45) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h19) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h29) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'h49) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h31) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h51) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h61) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'he) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h16) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'h26) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h46) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h1a) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h2a) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'h4a) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h32) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h52) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h62) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h1c) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h2c) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h4c) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h34) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h54) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h64) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h38) ^ data_i[31];
    data_o[32] = (syndrome_o == 7'h58) ^ data_i[32];
    data_o[33] = (syndrome_o == 7'h68) ^ data_i[33];
    data_o[34] = (syndrome_o == 7'h70) ^ data_i[34];
    data_o[35] = (syndrome_o == 7'h1f) ^ data_i[35];
    data_o[36] = (syndrome_o == 7'h2f) ^ data_i[36];
    data_o[37] = (syndrome_o == 7'h4f) ^ data_i[37];
    data_o[38] = (syndrome_o == 7'h37) ^ data_i[38];
    data_o[39] = (syndrome_o == 7'h57) ^ data_i[39];
    data_o[40] = (syndrome_o == 7'h67) ^ data_i[40];
    data_o[41] = (syndrome_o == 7'h3b) ^ data_i[41];
    data_o[42] = (syndrome_o == 7'h5b) ^ data_i[42];
    data_o[43] = (syndrome_o == 7'h6b) ^ data_i[43];
    data_o[44] = (syndrome_o == 7'h73) ^ data_i[44];
    data_o[45] = (syndrome_o == 7'h3d) ^ data_i[45];
    data_o[46] = (syndrome_o == 7'h5d) ^ data_i[46];
    data_o[47] = (syndrome_o == 7'h6d) ^ data_i[47];
    data_o[48] = (syndrome_o == 7'h75) ^ data_i[48];
    data_o[49] = (syndrome_o == 7'h79) ^ data_i[49];
    data_o[50] = (syndrome_o == 7'h3e) ^ data_i[50];
    data_o[51] = (syndrome_o == 7'h5e) ^ data_i[51];
    data_o[52] = (syndrome_o == 7'h6e) ^ data_i[52];
    data_o[53] = (syndrome_o == 7'h76) ^ data_i[53];
    data_o[54] = (syndrome_o == 7'h7a) ^ data_i[54];
    data_o[55] = (syndrome_o == 7'h7c) ^ data_i[55];
    data_o[56] = (syndrome_o == 7'h7f) ^ data_i[56];
    
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [71:0]
      prim_secded_inv_72_64_enc (logic [63:0] data_i);
    logic [71:0] data_o;
    data_o = 72'(data_i);
    data_o[64] = ^(data_o & 72'h00B9000000001FFFFF);
    data_o[65] = ^(data_o & 72'h005E00000FFFE0003F);
    data_o[66] = ^(data_o & 72'h0067003FF003E007C1);
    data_o[67] = ^(data_o & 72'h00CD0FC0F03C207842);
    data_o[68] = ^(data_o & 72'h00B671C711C4438884);
    data_o[69] = ^(data_o & 72'h00B5B65926488C9108);
    data_o[70] = ^(data_o & 72'h00CBDAAA4A91152210);
    data_o[71] = ^(data_o & 72'h007AED348D221A4420);
    data_o ^= 72'hAA0000000000000000;
    return data_o;
  endfunction
  function automatic secded_inv_72_64_t
      prim_secded_inv_72_64_dec (logic [71:0] data_i);
    logic [63:0] data_o;
    logic [7:0] syndrome_o;
    logic [1:0]  err_o;
    secded_inv_72_64_t dec;
    
    syndrome_o[0] = ^((data_i ^ 72'hAA0000000000000000) & 72'h01B9000000001FFFFF);
    syndrome_o[1] = ^((data_i ^ 72'hAA0000000000000000) & 72'h025E00000FFFE0003F);
    syndrome_o[2] = ^((data_i ^ 72'hAA0000000000000000) & 72'h0467003FF003E007C1);
    syndrome_o[3] = ^((data_i ^ 72'hAA0000000000000000) & 72'h08CD0FC0F03C207842);
    syndrome_o[4] = ^((data_i ^ 72'hAA0000000000000000) & 72'h10B671C711C4438884);
    syndrome_o[5] = ^((data_i ^ 72'hAA0000000000000000) & 72'h20B5B65926488C9108);
    syndrome_o[6] = ^((data_i ^ 72'hAA0000000000000000) & 72'h40CBDAAA4A91152210);
    syndrome_o[7] = ^((data_i ^ 72'hAA0000000000000000) & 72'h807AED348D221A4420);
    
    data_o[0] = (syndrome_o == 8'h7) ^ data_i[0];
    data_o[1] = (syndrome_o == 8'hb) ^ data_i[1];
    data_o[2] = (syndrome_o == 8'h13) ^ data_i[2];
    data_o[3] = (syndrome_o == 8'h23) ^ data_i[3];
    data_o[4] = (syndrome_o == 8'h43) ^ data_i[4];
    data_o[5] = (syndrome_o == 8'h83) ^ data_i[5];
    data_o[6] = (syndrome_o == 8'hd) ^ data_i[6];
    data_o[7] = (syndrome_o == 8'h15) ^ data_i[7];
    data_o[8] = (syndrome_o == 8'h25) ^ data_i[8];
    data_o[9] = (syndrome_o == 8'h45) ^ data_i[9];
    data_o[10] = (syndrome_o == 8'h85) ^ data_i[10];
    data_o[11] = (syndrome_o == 8'h19) ^ data_i[11];
    data_o[12] = (syndrome_o == 8'h29) ^ data_i[12];
    data_o[13] = (syndrome_o == 8'h49) ^ data_i[13];
    data_o[14] = (syndrome_o == 8'h89) ^ data_i[14];
    data_o[15] = (syndrome_o == 8'h31) ^ data_i[15];
    data_o[16] = (syndrome_o == 8'h51) ^ data_i[16];
    data_o[17] = (syndrome_o == 8'h91) ^ data_i[17];
    data_o[18] = (syndrome_o == 8'h61) ^ data_i[18];
    data_o[19] = (syndrome_o == 8'ha1) ^ data_i[19];
    data_o[20] = (syndrome_o == 8'hc1) ^ data_i[20];
    data_o[21] = (syndrome_o == 8'he) ^ data_i[21];
    data_o[22] = (syndrome_o == 8'h16) ^ data_i[22];
    data_o[23] = (syndrome_o == 8'h26) ^ data_i[23];
    data_o[24] = (syndrome_o == 8'h46) ^ data_i[24];
    data_o[25] = (syndrome_o == 8'h86) ^ data_i[25];
    data_o[26] = (syndrome_o == 8'h1a) ^ data_i[26];
    data_o[27] = (syndrome_o == 8'h2a) ^ data_i[27];
    data_o[28] = (syndrome_o == 8'h4a) ^ data_i[28];
    data_o[29] = (syndrome_o == 8'h8a) ^ data_i[29];
    data_o[30] = (syndrome_o == 8'h32) ^ data_i[30];
    data_o[31] = (syndrome_o == 8'h52) ^ data_i[31];
    data_o[32] = (syndrome_o == 8'h92) ^ data_i[32];
    data_o[33] = (syndrome_o == 8'h62) ^ data_i[33];
    data_o[34] = (syndrome_o == 8'ha2) ^ data_i[34];
    data_o[35] = (syndrome_o == 8'hc2) ^ data_i[35];
    data_o[36] = (syndrome_o == 8'h1c) ^ data_i[36];
    data_o[37] = (syndrome_o == 8'h2c) ^ data_i[37];
    data_o[38] = (syndrome_o == 8'h4c) ^ data_i[38];
    data_o[39] = (syndrome_o == 8'h8c) ^ data_i[39];
    data_o[40] = (syndrome_o == 8'h34) ^ data_i[40];
    data_o[41] = (syndrome_o == 8'h54) ^ data_i[41];
    data_o[42] = (syndrome_o == 8'h94) ^ data_i[42];
    data_o[43] = (syndrome_o == 8'h64) ^ data_i[43];
    data_o[44] = (syndrome_o == 8'ha4) ^ data_i[44];
    data_o[45] = (syndrome_o == 8'hc4) ^ data_i[45];
    data_o[46] = (syndrome_o == 8'h38) ^ data_i[46];
    data_o[47] = (syndrome_o == 8'h58) ^ data_i[47];
    data_o[48] = (syndrome_o == 8'h98) ^ data_i[48];
    data_o[49] = (syndrome_o == 8'h68) ^ data_i[49];
    data_o[50] = (syndrome_o == 8'ha8) ^ data_i[50];
    data_o[51] = (syndrome_o == 8'hc8) ^ data_i[51];
    data_o[52] = (syndrome_o == 8'h70) ^ data_i[52];
    data_o[53] = (syndrome_o == 8'hb0) ^ data_i[53];
    data_o[54] = (syndrome_o == 8'hd0) ^ data_i[54];
    data_o[55] = (syndrome_o == 8'he0) ^ data_i[55];
    data_o[56] = (syndrome_o == 8'h6d) ^ data_i[56];
    data_o[57] = (syndrome_o == 8'hd6) ^ data_i[57];
    data_o[58] = (syndrome_o == 8'h3e) ^ data_i[58];
    data_o[59] = (syndrome_o == 8'hcb) ^ data_i[59];
    data_o[60] = (syndrome_o == 8'hb3) ^ data_i[60];
    data_o[61] = (syndrome_o == 8'hb5) ^ data_i[61];
    data_o[62] = (syndrome_o == 8'hce) ^ data_i[62];
    data_o[63] = (syndrome_o == 8'h79) ^ data_i[63];
    
    err_o[0] = ^syndrome_o;
    err_o[1] = ~err_o[0] & (|syndrome_o);
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [21:0]
      prim_secded_inv_hamming_22_16_enc (logic [15:0] data_i);
    logic [21:0] data_o;
    data_o = 22'(data_i);
    data_o[16] = ^(data_o & 22'h00AD5B);
    data_o[17] = ^(data_o & 22'h00366D);
    data_o[18] = ^(data_o & 22'h00C78E);
    data_o[19] = ^(data_o & 22'h0007F0);
    data_o[20] = ^(data_o & 22'h00F800);
    data_o[21] = ^(data_o & 22'h1FFFFF);
    data_o ^= 22'h2A0000;
    return data_o;
  endfunction
  function automatic secded_inv_hamming_22_16_t
      prim_secded_inv_hamming_22_16_dec (logic [21:0] data_i);
    logic [15:0] data_o;
    logic [5:0] syndrome_o;
    logic [1:0]  err_o;
    secded_inv_hamming_22_16_t dec;
    
    syndrome_o[0] = ^((data_i ^ 22'h2A0000) & 22'h01AD5B);
    syndrome_o[1] = ^((data_i ^ 22'h2A0000) & 22'h02366D);
    syndrome_o[2] = ^((data_i ^ 22'h2A0000) & 22'h04C78E);
    syndrome_o[3] = ^((data_i ^ 22'h2A0000) & 22'h0807F0);
    syndrome_o[4] = ^((data_i ^ 22'h2A0000) & 22'h10F800);
    syndrome_o[5] = ^((data_i ^ 22'h2A0000) & 22'h3FFFFF);
    
    data_o[0] = (syndrome_o == 6'h23) ^ data_i[0];
    data_o[1] = (syndrome_o == 6'h25) ^ data_i[1];
    data_o[2] = (syndrome_o == 6'h26) ^ data_i[2];
    data_o[3] = (syndrome_o == 6'h27) ^ data_i[3];
    data_o[4] = (syndrome_o == 6'h29) ^ data_i[4];
    data_o[5] = (syndrome_o == 6'h2a) ^ data_i[5];
    data_o[6] = (syndrome_o == 6'h2b) ^ data_i[6];
    data_o[7] = (syndrome_o == 6'h2c) ^ data_i[7];
    data_o[8] = (syndrome_o == 6'h2d) ^ data_i[8];
    data_o[9] = (syndrome_o == 6'h2e) ^ data_i[9];
    data_o[10] = (syndrome_o == 6'h2f) ^ data_i[10];
    data_o[11] = (syndrome_o == 6'h31) ^ data_i[11];
    data_o[12] = (syndrome_o == 6'h32) ^ data_i[12];
    data_o[13] = (syndrome_o == 6'h33) ^ data_i[13];
    data_o[14] = (syndrome_o == 6'h34) ^ data_i[14];
    data_o[15] = (syndrome_o == 6'h35) ^ data_i[15];
    
    err_o[0] = syndrome_o[5];
    err_o[1] = |syndrome_o[4:0] & ~syndrome_o[5];
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [38:0]
      prim_secded_inv_hamming_39_32_enc (logic [31:0] data_i);
    logic [38:0] data_o;
    data_o = 39'(data_i);
    data_o[32] = ^(data_o & 39'h0056AAAD5B);
    data_o[33] = ^(data_o & 39'h009B33366D);
    data_o[34] = ^(data_o & 39'h00E3C3C78E);
    data_o[35] = ^(data_o & 39'h0003FC07F0);
    data_o[36] = ^(data_o & 39'h0003FFF800);
    data_o[37] = ^(data_o & 39'h00FC000000);
    data_o[38] = ^(data_o & 39'h3FFFFFFFFF);
    data_o ^= 39'h2A00000000;
    return data_o;
  endfunction
  function automatic secded_inv_hamming_39_32_t
      prim_secded_inv_hamming_39_32_dec (logic [38:0] data_i);
    logic [31:0] data_o;
    logic [6:0] syndrome_o;
    logic [1:0]  err_o;
    secded_inv_hamming_39_32_t dec;
    
    syndrome_o[0] = ^((data_i ^ 39'h2A00000000) & 39'h0156AAAD5B);
    syndrome_o[1] = ^((data_i ^ 39'h2A00000000) & 39'h029B33366D);
    syndrome_o[2] = ^((data_i ^ 39'h2A00000000) & 39'h04E3C3C78E);
    syndrome_o[3] = ^((data_i ^ 39'h2A00000000) & 39'h0803FC07F0);
    syndrome_o[4] = ^((data_i ^ 39'h2A00000000) & 39'h1003FFF800);
    syndrome_o[5] = ^((data_i ^ 39'h2A00000000) & 39'h20FC000000);
    syndrome_o[6] = ^((data_i ^ 39'h2A00000000) & 39'h7FFFFFFFFF);
    
    data_o[0] = (syndrome_o == 7'h43) ^ data_i[0];
    data_o[1] = (syndrome_o == 7'h45) ^ data_i[1];
    data_o[2] = (syndrome_o == 7'h46) ^ data_i[2];
    data_o[3] = (syndrome_o == 7'h47) ^ data_i[3];
    data_o[4] = (syndrome_o == 7'h49) ^ data_i[4];
    data_o[5] = (syndrome_o == 7'h4a) ^ data_i[5];
    data_o[6] = (syndrome_o == 7'h4b) ^ data_i[6];
    data_o[7] = (syndrome_o == 7'h4c) ^ data_i[7];
    data_o[8] = (syndrome_o == 7'h4d) ^ data_i[8];
    data_o[9] = (syndrome_o == 7'h4e) ^ data_i[9];
    data_o[10] = (syndrome_o == 7'h4f) ^ data_i[10];
    data_o[11] = (syndrome_o == 7'h51) ^ data_i[11];
    data_o[12] = (syndrome_o == 7'h52) ^ data_i[12];
    data_o[13] = (syndrome_o == 7'h53) ^ data_i[13];
    data_o[14] = (syndrome_o == 7'h54) ^ data_i[14];
    data_o[15] = (syndrome_o == 7'h55) ^ data_i[15];
    data_o[16] = (syndrome_o == 7'h56) ^ data_i[16];
    data_o[17] = (syndrome_o == 7'h57) ^ data_i[17];
    data_o[18] = (syndrome_o == 7'h58) ^ data_i[18];
    data_o[19] = (syndrome_o == 7'h59) ^ data_i[19];
    data_o[20] = (syndrome_o == 7'h5a) ^ data_i[20];
    data_o[21] = (syndrome_o == 7'h5b) ^ data_i[21];
    data_o[22] = (syndrome_o == 7'h5c) ^ data_i[22];
    data_o[23] = (syndrome_o == 7'h5d) ^ data_i[23];
    data_o[24] = (syndrome_o == 7'h5e) ^ data_i[24];
    data_o[25] = (syndrome_o == 7'h5f) ^ data_i[25];
    data_o[26] = (syndrome_o == 7'h61) ^ data_i[26];
    data_o[27] = (syndrome_o == 7'h62) ^ data_i[27];
    data_o[28] = (syndrome_o == 7'h63) ^ data_i[28];
    data_o[29] = (syndrome_o == 7'h64) ^ data_i[29];
    data_o[30] = (syndrome_o == 7'h65) ^ data_i[30];
    data_o[31] = (syndrome_o == 7'h66) ^ data_i[31];
    
    err_o[0] = syndrome_o[6];
    err_o[1] = |syndrome_o[5:0] & ~syndrome_o[6];
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [71:0]
      prim_secded_inv_hamming_72_64_enc (logic [63:0] data_i);
    logic [71:0] data_o;
    data_o = 72'(data_i);
    data_o[64] = ^(data_o & 72'h00AB55555556AAAD5B);
    data_o[65] = ^(data_o & 72'h00CD9999999B33366D);
    data_o[66] = ^(data_o & 72'h00F1E1E1E1E3C3C78E);
    data_o[67] = ^(data_o & 72'h0001FE01FE03FC07F0);
    data_o[68] = ^(data_o & 72'h0001FFFE0003FFF800);
    data_o[69] = ^(data_o & 72'h0001FFFFFFFC000000);
    data_o[70] = ^(data_o & 72'h00FE00000000000000);
    data_o[71] = ^(data_o & 72'h7FFFFFFFFFFFFFFFFF);
    data_o ^= 72'hAA0000000000000000;
    return data_o;
  endfunction
  function automatic secded_inv_hamming_72_64_t
      prim_secded_inv_hamming_72_64_dec (logic [71:0] data_i);
    logic [63:0] data_o;
    logic [7:0] syndrome_o;
    logic [1:0]  err_o;
    secded_inv_hamming_72_64_t dec;
    
    syndrome_o[0] = ^((data_i ^ 72'hAA0000000000000000) & 72'h01AB55555556AAAD5B);
    syndrome_o[1] = ^((data_i ^ 72'hAA0000000000000000) & 72'h02CD9999999B33366D);
    syndrome_o[2] = ^((data_i ^ 72'hAA0000000000000000) & 72'h04F1E1E1E1E3C3C78E);
    syndrome_o[3] = ^((data_i ^ 72'hAA0000000000000000) & 72'h0801FE01FE03FC07F0);
    syndrome_o[4] = ^((data_i ^ 72'hAA0000000000000000) & 72'h1001FFFE0003FFF800);
    syndrome_o[5] = ^((data_i ^ 72'hAA0000000000000000) & 72'h2001FFFFFFFC000000);
    syndrome_o[6] = ^((data_i ^ 72'hAA0000000000000000) & 72'h40FE00000000000000);
    syndrome_o[7] = ^((data_i ^ 72'hAA0000000000000000) & 72'hFFFFFFFFFFFFFFFFFF);
    
    data_o[0] = (syndrome_o == 8'h83) ^ data_i[0];
    data_o[1] = (syndrome_o == 8'h85) ^ data_i[1];
    data_o[2] = (syndrome_o == 8'h86) ^ data_i[2];
    data_o[3] = (syndrome_o == 8'h87) ^ data_i[3];
    data_o[4] = (syndrome_o == 8'h89) ^ data_i[4];
    data_o[5] = (syndrome_o == 8'h8a) ^ data_i[5];
    data_o[6] = (syndrome_o == 8'h8b) ^ data_i[6];
    data_o[7] = (syndrome_o == 8'h8c) ^ data_i[7];
    data_o[8] = (syndrome_o == 8'h8d) ^ data_i[8];
    data_o[9] = (syndrome_o == 8'h8e) ^ data_i[9];
    data_o[10] = (syndrome_o == 8'h8f) ^ data_i[10];
    data_o[11] = (syndrome_o == 8'h91) ^ data_i[11];
    data_o[12] = (syndrome_o == 8'h92) ^ data_i[12];
    data_o[13] = (syndrome_o == 8'h93) ^ data_i[13];
    data_o[14] = (syndrome_o == 8'h94) ^ data_i[14];
    data_o[15] = (syndrome_o == 8'h95) ^ data_i[15];
    data_o[16] = (syndrome_o == 8'h96) ^ data_i[16];
    data_o[17] = (syndrome_o == 8'h97) ^ data_i[17];
    data_o[18] = (syndrome_o == 8'h98) ^ data_i[18];
    data_o[19] = (syndrome_o == 8'h99) ^ data_i[19];
    data_o[20] = (syndrome_o == 8'h9a) ^ data_i[20];
    data_o[21] = (syndrome_o == 8'h9b) ^ data_i[21];
    data_o[22] = (syndrome_o == 8'h9c) ^ data_i[22];
    data_o[23] = (syndrome_o == 8'h9d) ^ data_i[23];
    data_o[24] = (syndrome_o == 8'h9e) ^ data_i[24];
    data_o[25] = (syndrome_o == 8'h9f) ^ data_i[25];
    data_o[26] = (syndrome_o == 8'ha1) ^ data_i[26];
    data_o[27] = (syndrome_o == 8'ha2) ^ data_i[27];
    data_o[28] = (syndrome_o == 8'ha3) ^ data_i[28];
    data_o[29] = (syndrome_o == 8'ha4) ^ data_i[29];
    data_o[30] = (syndrome_o == 8'ha5) ^ data_i[30];
    data_o[31] = (syndrome_o == 8'ha6) ^ data_i[31];
    data_o[32] = (syndrome_o == 8'ha7) ^ data_i[32];
    data_o[33] = (syndrome_o == 8'ha8) ^ data_i[33];
    data_o[34] = (syndrome_o == 8'ha9) ^ data_i[34];
    data_o[35] = (syndrome_o == 8'haa) ^ data_i[35];
    data_o[36] = (syndrome_o == 8'hab) ^ data_i[36];
    data_o[37] = (syndrome_o == 8'hac) ^ data_i[37];
    data_o[38] = (syndrome_o == 8'had) ^ data_i[38];
    data_o[39] = (syndrome_o == 8'hae) ^ data_i[39];
    data_o[40] = (syndrome_o == 8'haf) ^ data_i[40];
    data_o[41] = (syndrome_o == 8'hb0) ^ data_i[41];
    data_o[42] = (syndrome_o == 8'hb1) ^ data_i[42];
    data_o[43] = (syndrome_o == 8'hb2) ^ data_i[43];
    data_o[44] = (syndrome_o == 8'hb3) ^ data_i[44];
    data_o[45] = (syndrome_o == 8'hb4) ^ data_i[45];
    data_o[46] = (syndrome_o == 8'hb5) ^ data_i[46];
    data_o[47] = (syndrome_o == 8'hb6) ^ data_i[47];
    data_o[48] = (syndrome_o == 8'hb7) ^ data_i[48];
    data_o[49] = (syndrome_o == 8'hb8) ^ data_i[49];
    data_o[50] = (syndrome_o == 8'hb9) ^ data_i[50];
    data_o[51] = (syndrome_o == 8'hba) ^ data_i[51];
    data_o[52] = (syndrome_o == 8'hbb) ^ data_i[52];
    data_o[53] = (syndrome_o == 8'hbc) ^ data_i[53];
    data_o[54] = (syndrome_o == 8'hbd) ^ data_i[54];
    data_o[55] = (syndrome_o == 8'hbe) ^ data_i[55];
    data_o[56] = (syndrome_o == 8'hbf) ^ data_i[56];
    data_o[57] = (syndrome_o == 8'hc1) ^ data_i[57];
    data_o[58] = (syndrome_o == 8'hc2) ^ data_i[58];
    data_o[59] = (syndrome_o == 8'hc3) ^ data_i[59];
    data_o[60] = (syndrome_o == 8'hc4) ^ data_i[60];
    data_o[61] = (syndrome_o == 8'hc5) ^ data_i[61];
    data_o[62] = (syndrome_o == 8'hc6) ^ data_i[62];
    data_o[63] = (syndrome_o == 8'hc7) ^ data_i[63];
    
    err_o[0] = syndrome_o[7];
    err_o[1] = |syndrome_o[6:0] & ~syndrome_o[7];
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
  function automatic logic [75:0]
      prim_secded_inv_hamming_76_68_enc (logic [67:0] data_i);
    logic [75:0] data_o;
    data_o = 76'(data_i);
    data_o[68] = ^(data_o & 76'h00AAB55555556AAAD5B);
    data_o[69] = ^(data_o & 76'h00CCD9999999B33366D);
    data_o[70] = ^(data_o & 76'h000F1E1E1E1E3C3C78E);
    data_o[71] = ^(data_o & 76'h00F01FE01FE03FC07F0);
    data_o[72] = ^(data_o & 76'h00001FFFE0003FFF800);
    data_o[73] = ^(data_o & 76'h00001FFFFFFFC000000);
    data_o[74] = ^(data_o & 76'h00FFE00000000000000);
    data_o[75] = ^(data_o & 76'h7FFFFFFFFFFFFFFFFFF);
    data_o ^= 76'hAA00000000000000000;
    return data_o;
  endfunction
  function automatic secded_inv_hamming_76_68_t
      prim_secded_inv_hamming_76_68_dec (logic [75:0] data_i);
    logic [67:0] data_o;
    logic [7:0] syndrome_o;
    logic [1:0]  err_o;
    secded_inv_hamming_76_68_t dec;
    
    syndrome_o[0] = ^((data_i ^ 76'hAA00000000000000000) & 76'h01AAB55555556AAAD5B);
    syndrome_o[1] = ^((data_i ^ 76'hAA00000000000000000) & 76'h02CCD9999999B33366D);
    syndrome_o[2] = ^((data_i ^ 76'hAA00000000000000000) & 76'h040F1E1E1E1E3C3C78E);
    syndrome_o[3] = ^((data_i ^ 76'hAA00000000000000000) & 76'h08F01FE01FE03FC07F0);
    syndrome_o[4] = ^((data_i ^ 76'hAA00000000000000000) & 76'h10001FFFE0003FFF800);
    syndrome_o[5] = ^((data_i ^ 76'hAA00000000000000000) & 76'h20001FFFFFFFC000000);
    syndrome_o[6] = ^((data_i ^ 76'hAA00000000000000000) & 76'h40FFE00000000000000);
    syndrome_o[7] = ^((data_i ^ 76'hAA00000000000000000) & 76'hFFFFFFFFFFFFFFFFFFF);
    
    data_o[0] = (syndrome_o == 8'h83) ^ data_i[0];
    data_o[1] = (syndrome_o == 8'h85) ^ data_i[1];
    data_o[2] = (syndrome_o == 8'h86) ^ data_i[2];
    data_o[3] = (syndrome_o == 8'h87) ^ data_i[3];
    data_o[4] = (syndrome_o == 8'h89) ^ data_i[4];
    data_o[5] = (syndrome_o == 8'h8a) ^ data_i[5];
    data_o[6] = (syndrome_o == 8'h8b) ^ data_i[6];
    data_o[7] = (syndrome_o == 8'h8c) ^ data_i[7];
    data_o[8] = (syndrome_o == 8'h8d) ^ data_i[8];
    data_o[9] = (syndrome_o == 8'h8e) ^ data_i[9];
    data_o[10] = (syndrome_o == 8'h8f) ^ data_i[10];
    data_o[11] = (syndrome_o == 8'h91) ^ data_i[11];
    data_o[12] = (syndrome_o == 8'h92) ^ data_i[12];
    data_o[13] = (syndrome_o == 8'h93) ^ data_i[13];
    data_o[14] = (syndrome_o == 8'h94) ^ data_i[14];
    data_o[15] = (syndrome_o == 8'h95) ^ data_i[15];
    data_o[16] = (syndrome_o == 8'h96) ^ data_i[16];
    data_o[17] = (syndrome_o == 8'h97) ^ data_i[17];
    data_o[18] = (syndrome_o == 8'h98) ^ data_i[18];
    data_o[19] = (syndrome_o == 8'h99) ^ data_i[19];
    data_o[20] = (syndrome_o == 8'h9a) ^ data_i[20];
    data_o[21] = (syndrome_o == 8'h9b) ^ data_i[21];
    data_o[22] = (syndrome_o == 8'h9c) ^ data_i[22];
    data_o[23] = (syndrome_o == 8'h9d) ^ data_i[23];
    data_o[24] = (syndrome_o == 8'h9e) ^ data_i[24];
    data_o[25] = (syndrome_o == 8'h9f) ^ data_i[25];
    data_o[26] = (syndrome_o == 8'ha1) ^ data_i[26];
    data_o[27] = (syndrome_o == 8'ha2) ^ data_i[27];
    data_o[28] = (syndrome_o == 8'ha3) ^ data_i[28];
    data_o[29] = (syndrome_o == 8'ha4) ^ data_i[29];
    data_o[30] = (syndrome_o == 8'ha5) ^ data_i[30];
    data_o[31] = (syndrome_o == 8'ha6) ^ data_i[31];
    data_o[32] = (syndrome_o == 8'ha7) ^ data_i[32];
    data_o[33] = (syndrome_o == 8'ha8) ^ data_i[33];
    data_o[34] = (syndrome_o == 8'ha9) ^ data_i[34];
    data_o[35] = (syndrome_o == 8'haa) ^ data_i[35];
    data_o[36] = (syndrome_o == 8'hab) ^ data_i[36];
    data_o[37] = (syndrome_o == 8'hac) ^ data_i[37];
    data_o[38] = (syndrome_o == 8'had) ^ data_i[38];
    data_o[39] = (syndrome_o == 8'hae) ^ data_i[39];
    data_o[40] = (syndrome_o == 8'haf) ^ data_i[40];
    data_o[41] = (syndrome_o == 8'hb0) ^ data_i[41];
    data_o[42] = (syndrome_o == 8'hb1) ^ data_i[42];
    data_o[43] = (syndrome_o == 8'hb2) ^ data_i[43];
    data_o[44] = (syndrome_o == 8'hb3) ^ data_i[44];
    data_o[45] = (syndrome_o == 8'hb4) ^ data_i[45];
    data_o[46] = (syndrome_o == 8'hb5) ^ data_i[46];
    data_o[47] = (syndrome_o == 8'hb6) ^ data_i[47];
    data_o[48] = (syndrome_o == 8'hb7) ^ data_i[48];
    data_o[49] = (syndrome_o == 8'hb8) ^ data_i[49];
    data_o[50] = (syndrome_o == 8'hb9) ^ data_i[50];
    data_o[51] = (syndrome_o == 8'hba) ^ data_i[51];
    data_o[52] = (syndrome_o == 8'hbb) ^ data_i[52];
    data_o[53] = (syndrome_o == 8'hbc) ^ data_i[53];
    data_o[54] = (syndrome_o == 8'hbd) ^ data_i[54];
    data_o[55] = (syndrome_o == 8'hbe) ^ data_i[55];
    data_o[56] = (syndrome_o == 8'hbf) ^ data_i[56];
    data_o[57] = (syndrome_o == 8'hc1) ^ data_i[57];
    data_o[58] = (syndrome_o == 8'hc2) ^ data_i[58];
    data_o[59] = (syndrome_o == 8'hc3) ^ data_i[59];
    data_o[60] = (syndrome_o == 8'hc4) ^ data_i[60];
    data_o[61] = (syndrome_o == 8'hc5) ^ data_i[61];
    data_o[62] = (syndrome_o == 8'hc6) ^ data_i[62];
    data_o[63] = (syndrome_o == 8'hc7) ^ data_i[63];
    data_o[64] = (syndrome_o == 8'hc8) ^ data_i[64];
    data_o[65] = (syndrome_o == 8'hc9) ^ data_i[65];
    data_o[66] = (syndrome_o == 8'hca) ^ data_i[66];
    data_o[67] = (syndrome_o == 8'hcb) ^ data_i[67];
    
    err_o[0] = syndrome_o[7];
    err_o[1] = |syndrome_o[6:0] & ~syndrome_o[7];
    dec.data      = data_o;
    dec.syndrome  = syndrome_o;
    dec.err       = err_o;
    return dec;
  endfunction
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

module prim_subreg
  import prim_subreg_pkg::*;
#(
  parameter int            DW       = 32,
  parameter sw_access_e    SwAccess = SwAccessRW,
  parameter logic [DW-1:0] RESVAL   = '0 ,   
  parameter bit            Mubi     = 1'b0
) (
  input clk_i,
  input rst_ni,
  
  
  input          we,
  input [DW-1:0] wd,
  
  input          de,
  input [DW-1:0] d,
  
  output logic          qe,
  output logic [DW-1:0] q,
  
  
  
  output logic [DW-1:0] ds,
  output logic [DW-1:0] qs
);
  logic          wr_en;
  logic [DW-1:0] wr_data;
  prim_subreg_arb #(
    .DW       ( DW       ),
    .SwAccess ( SwAccess ),
    .Mubi     ( Mubi     )
  ) wr_en_data_arb (
    .we,
    .wd,
    .de,
    .d,
    .q,
    .wr_en,
    .wr_data
  );
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      q <= RESVAL;
    end else if (wr_en) begin
      q <= wr_data;
    end
  end
  
  assign ds = wr_en ? wr_data : qs;
  assign qe = we;
  if (SwAccess == SwAccessRC) begin : gen_rc
    
    
    assign qs = de && we ? d : q;
  end else begin : gen_no_rc
    assign qs = q;
  end
endmodule

module prim_subreg_arb
  import prim_subreg_pkg::*;
#(
  parameter int         DW       = 32,
  parameter sw_access_e SwAccess = SwAccessRW,
  parameter bit         Mubi     = 1'b0
) (
  
  
  input          we,
  input [DW-1:0] wd,
  
  input          de,
  input [DW-1:0] d,
  
  input [DW-1:0] q,
  
  output logic          wr_en,
  output logic [DW-1:0] wr_data
);
  import prim_mubi_pkg::*;
  if ((SwAccess == SwAccessRW) || (SwAccess == SwAccessWO)) begin : gen_w
    assign wr_en   = we | de;
    assign wr_data = (we == 1'b1) ? wd : d; 
    
    logic [DW-1:0] unused_q;
    
    
    assign unused_q = q;
    
    
  end else if (SwAccess == SwAccessRO) begin : gen_ro
    assign wr_en   = de;
    assign wr_data = d;
    
    logic          unused_we;
    logic [DW-1:0] unused_wd;
    logic [DW-1:0] unused_q;
    
    
    assign unused_we = we;
    assign unused_wd = wd;
    assign unused_q  = q;
    
    
  end else if (SwAccess == SwAccessW1S) begin : gen_w1s
    
    
    
    assign wr_en   = we | de;
    if (Mubi) begin : gen_mubi
      if (DW == 4) begin : gen_mubi4
        assign wr_data = prim_mubi_pkg::mubi4_or_hi(prim_mubi_pkg::mubi4_t'(de ? d : q),
                                                    (we ? prim_mubi_pkg::mubi4_t'(wd) :
                                                          prim_mubi_pkg::MuBi4False));
      end else if (DW == 8) begin : gen_mubi8
        assign wr_data = prim_mubi_pkg::mubi8_or_hi(prim_mubi_pkg::mubi8_t'(de ? d : q),
                                                    (we ? prim_mubi_pkg::mubi8_t'(wd) :
                                                          prim_mubi_pkg::MuBi8False));
      end else if (DW == 12) begin : gen_mubi12
        assign wr_data = prim_mubi_pkg::mubi12_or_hi(prim_mubi_pkg::mubi12_t'(de ? d : q),
                                                     (we ? prim_mubi_pkg::mubi12_t'(wd) :
                                                           prim_mubi_pkg::MuBi12False));
      end else if (DW == 16) begin : gen_mubi16
        assign wr_data = prim_mubi_pkg::mubi16_or_hi(prim_mubi_pkg::mubi16_t'(de ? d : q),
                                                     (we ? prim_mubi_pkg::mubi16_t'(wd) :
                                                           prim_mubi_pkg::MuBi16False));
      end else begin : gen_invalid_mubi
        $error("%m: Invalid width for MuBi");
      end
    end else begin : gen_non_mubi
      assign wr_data = (de ? d : q) | (we ? wd : '0);
    end
  end else if (SwAccess == SwAccessW1C) begin : gen_w1c
    
    
    
    assign wr_en   = we | de;
    if (Mubi) begin : gen_mubi
      if (DW == 4) begin : gen_mubi4
        assign wr_data = prim_mubi_pkg::mubi4_and_hi(prim_mubi_pkg::mubi4_t'(de ? d : q),
                                                     (we ? prim_mubi_pkg::mubi4_t'(~wd) :
                                                           prim_mubi_pkg::MuBi4True));
      end else if (DW == 8) begin : gen_mubi8
        assign wr_data = prim_mubi_pkg::mubi8_and_hi(prim_mubi_pkg::mubi8_t'(de ? d : q),
                                                     (we ? prim_mubi_pkg::mubi8_t'(~wd) :
                                                           prim_mubi_pkg::MuBi8True));
      end else if (DW == 12) begin : gen_mubi12
        assign wr_data = prim_mubi_pkg::mubi12_and_hi(prim_mubi_pkg::mubi12_t'(de ? d : q),
                                                      (we ? prim_mubi_pkg::mubi12_t'(~wd) :
                                                            prim_mubi_pkg::MuBi12True));
      end else if (DW == 16) begin : gen_mubi16
        assign wr_data = prim_mubi_pkg::mubi16_and_hi(prim_mubi_pkg::mubi16_t'(de ? d : q),
                                                      (we ? prim_mubi_pkg::mubi16_t'(~wd) :
                                                            prim_mubi_pkg::MuBi16True));
      end else begin : gen_invalid_mubi
        $error("%m: Invalid width for MuBi");
      end
    end else begin : gen_non_mubi
      assign wr_data = (de ? d : q) & (we ? ~wd : '1);
    end
  end else if (SwAccess == SwAccessW0C) begin : gen_w0c
    assign wr_en   = we | de;
    if (Mubi) begin : gen_mubi
      if (DW == 4) begin : gen_mubi4
        assign wr_data = prim_mubi_pkg::mubi4_and_hi(prim_mubi_pkg::mubi4_t'(de ? d : q),
                                                     (we ? prim_mubi_pkg::mubi4_t'(wd) :
                                                           prim_mubi_pkg::MuBi4True));
      end else if (DW == 8) begin : gen_mubi8
        assign wr_data = prim_mubi_pkg::mubi8_and_hi(prim_mubi_pkg::mubi8_t'(de ? d : q),
                                                     (we ? prim_mubi_pkg::mubi8_t'(wd) :
                                                           prim_mubi_pkg::MuBi8True));
      end else if (DW == 12) begin : gen_mubi12
        assign wr_data = prim_mubi_pkg::mubi12_and_hi(prim_mubi_pkg::mubi12_t'(de ? d : q),
                                                      (we ? prim_mubi_pkg::mubi12_t'(wd) :
                                                            prim_mubi_pkg::MuBi12True));
      end else if (DW == 16) begin : gen_mubi16
        assign wr_data = prim_mubi_pkg::mubi16_and_hi(prim_mubi_pkg::mubi16_t'(de ? d : q),
                                                      (we ? prim_mubi_pkg::mubi16_t'(wd) :
                                                            prim_mubi_pkg::MuBi16True));
      end else begin : gen_invalid_mubi
        $error("%m: Invalid width for MuBi");
      end
    end else begin : gen_non_mubi
      assign wr_data = (de ? d : q) & (we ? wd : '1);
    end
  end else if (SwAccess == SwAccessRC) begin : gen_rc
    
    
    assign wr_en  = we | de;
    if (Mubi) begin : gen_mubi
      if (DW == 4) begin : gen_mubi4
        assign wr_data = prim_mubi_pkg::mubi4_and_hi(prim_mubi_pkg::mubi4_t'(de ? d : q),
                                                     (we ? prim_mubi_pkg::MuBi4False :
                                                           prim_mubi_pkg::MuBi4True));
      end else if (DW == 8) begin : gen_mubi8
        assign wr_data = prim_mubi_pkg::mubi8_and_hi(prim_mubi_pkg::mubi8_t'(de ? d : q),
                                                     (we ? prim_mubi_pkg::MuBi8False :
                                                           prim_mubi_pkg::MuBi8True));
      end else if (DW == 12) begin : gen_mubi12
        assign wr_data = prim_mubi_pkg::mubi12_and_hi(prim_mubi_pkg::mubi12_t'(de ? d : q),
                                                      (we ? prim_mubi_pkg::MuBi12False :
                                                            prim_mubi_pkg::MuBi12True));
      end else if (DW == 16) begin : gen_mubi16
        assign wr_data = prim_mubi_pkg::mubi16_and_hi(prim_mubi_pkg::mubi16_t'(de ? d : q),
                                                      (we ? prim_mubi_pkg::mubi16_t'(wd) :
                                                            prim_mubi_pkg::MuBi16True));
      end else begin : gen_invalid_mubi
        $error("%m: Invalid width for MuBi");
      end
    end else begin : gen_non_mubi
      assign wr_data = (de ? d : q) & (we ? '0 : '1);
    end
    
    logic [DW-1:0] unused_wd;
    
    
    assign unused_wd = wd;
    
    
  end else begin : gen_hw
    assign wr_en   = de;
    assign wr_data = d;
    
    logic          unused_we;
    logic [DW-1:0] unused_wd;
    logic [DW-1:0] unused_q;
    
    
    assign unused_we = we;
    assign unused_wd = wd;
    assign unused_q  = q;
    
    
  end
endmodule

module prim_subreg_ext #(
  parameter int unsigned DW = 32
) (
  input          re,
  input          we,
  input [DW-1:0] wd,
  input [DW-1:0] d,
  
  output logic          qe,
  output logic          qre,
  output logic [DW-1:0] q,
  output logic [DW-1:0] ds,
  output logic [DW-1:0] qs
);
  
  
  assign ds = d;
  assign qs = d;
  assign q = wd;
  assign qe = we;
  assign qre = re;
endmodule

package prim_subreg_pkg;
  
  typedef enum logic [2:0] {
    SwAccessRW  = 3'd0, 
    SwAccessRO  = 3'd1, 
    SwAccessWO  = 3'd2, 
    SwAccessW1C = 3'd3, 
    SwAccessW1S = 3'd4, 
    SwAccessW0C = 3'd5, 
    SwAccessRC  = 3'd6  
  } sw_access_e;
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
module prim_subreg_shadow
  import prim_subreg_pkg::*;
#(
  parameter int            DW       = 32,
  parameter sw_access_e    SwAccess = SwAccessRW,
  parameter logic [DW-1:0] RESVAL   = '0,    
  parameter bit            Mubi     = 1'b0
) (
  input clk_i,
  input rst_ni,
  input rst_shadowed_ni,
  
  
  input          re,
  
  input          we,
  input [DW-1:0] wd,
  
  input          de,
  input [DW-1:0] d,
  
  output logic          qe,
  output logic [DW-1:0] q,
  output logic [DW-1:0] ds,
  output logic [DW-1:0] qs,
  
  output logic phase,
  
  output logic err_update,
  output logic err_storage
);
  
  
  
  `ASSERT_INIT(CheckSwAccessIsLegal_A,
      SwAccess inside {SwAccessRW, SwAccessRO, SwAccessWO, SwAccessW1S, SwAccessW0C})
  localparam sw_access_e InvertedSwAccess = (SwAccess == SwAccessW1S) ? SwAccessW0C :
                                            (SwAccess == SwAccessW0C) ? SwAccessW1S : SwAccess;
  
  logic          phase_clear;
  logic          phase_q;
  logic          shadow_we, committed_we;
  logic          committed_de;
  
  logic          committed_qe;
  logic [DW-1:0] shadow_wd, shadow_q, committed_q;
  logic [DW-1:0] committed_qs;
  
  
  logic          wr_en;
  logic [DW-1:0] wr_data;
  
  prim_subreg_arb #(
    .DW      (DW),
    .SwAccess(SwAccess),
    .Mubi    (Mubi)
  ) wr_en_data_arb (
    .we     (we),
    .wd     (wd),
    .de     (de),
    .d      (d),
    .q      (q),
    .wr_en  (wr_en),
    .wr_data(wr_data)
  );
  
  
  
  assign phase_clear = (SwAccess == SwAccessRO) ? 1'b0 : re;
  
  
  
  always_ff @(posedge clk_i or negedge rst_ni) begin : phase_reg
    if (!rst_ni) begin
      phase_q <= 1'b0;
    end else if (wr_en && !err_storage && !err_update) begin
      phase_q <= ~phase_q;
    end else if (phase_clear || err_storage || err_update) begin
      phase_q <= 1'b0;
    end
  end
  
  
  
  
  
  always_ff @(posedge clk_i or negedge rst_shadowed_ni) begin
    if (!rst_shadowed_ni) begin
      shadow_q <= ~RESVAL;
    end else if (shadow_we) begin
      shadow_q <= shadow_wd;
    end
  end
  if (InvertedSwAccess == SwAccess) begin : gen_shadow_reg_std
    
    logic          shadow_wr_en;
    logic [DW-1:0] shadow_wr_data;
    
    
    prim_subreg_arb #(
      .DW      (DW),
      .SwAccess(InvertedSwAccess),
      .Mubi    (Mubi)
    ) wr_en_data_arb_shadow (
      .we     (we),
      .wd     (~wr_data),
      .de     (de),
      .d      (~d),
      .q      (shadow_q),
      .wr_en  (shadow_wr_en),
      .wr_data(shadow_wr_data)
    );
    always_comb begin
      shadow_we = 1'b0;
      shadow_wd = shadow_wr_data;
      if (!err_storage) begin
        if (err_update || phase_clear) begin
          
          shadow_we = 1'b1;
          shadow_wd = ~committed_q;
        end else if (!phase_q && shadow_wr_en) begin
          
          shadow_we = 1'b1;
          shadow_wd = shadow_wr_data;
        end
      end
    end
    
    assign err_update = (~shadow_q != wr_data) ? phase_q & wr_en : 1'b0;
  end else begin : gen_shadow_reg_wxx
    
    
    
    
    
    
    logic          shadow_wr_en_phase0, shadow_wr_en_phase1;
    logic [DW-1:0] shadow_wr_data_phase0, shadow_wr_data_phase1;
    
    
    prim_subreg_arb #(
      .DW      (DW),
      .SwAccess(SwAccessRW),
      .Mubi    (Mubi)
    ) wr_en_data_arb_phase0 (
      .we     (we),
      .wd     (~wd),
      .de     (de),
      .d      (~d),
      .q      (shadow_q),
      .wr_en  (shadow_wr_en_phase0),
      .wr_data(shadow_wr_data_phase0)
    );
    
    
    
    prim_subreg_arb #(
      .DW      (DW),
      .SwAccess(InvertedSwAccess),
      .Mubi    (Mubi)
    ) wr_en_data_arb_phase1 (
      .we     (we),
      .wd     (~wr_data),
      .de     (de),
      .d      (~d),
      .q      (~committed_q),
      .wr_en  (shadow_wr_en_phase1),
      .wr_data(shadow_wr_data_phase1)
    );
    always_comb begin
      shadow_we = 1'b0;
      shadow_wd = shadow_wr_data_phase0;
      if (!err_storage) begin
        if (err_update || phase_clear) begin
          
          shadow_we = 1'b1;
          shadow_wd = ~committed_q;
        end else if (!phase_q) begin
          
          shadow_we = shadow_wr_en_phase0;
          shadow_wd = shadow_wr_data_phase0;
        end else begin
          
          shadow_we = shadow_wr_en_phase1;
          shadow_wd = shadow_wr_data_phase1;
        end
      end
    end
    
    
    
    
    assign err_update = (phase_q && wr_en) ? (~shadow_q != wd) : 1'b0;
  end
  
  
  
  assign committed_we = we & phase_q & ~err_update & ~err_storage;
  assign committed_de = de & phase_q & ~err_update & ~err_storage;
  prim_subreg #(
    .DW      (DW),
    .SwAccess(SwAccess),
    .RESVAL  (RESVAL),
    .Mubi    (Mubi)
  ) committed_reg (
    .clk_i (clk_i),
    .rst_ni(rst_ni),
    .we    (committed_we),
    .wd    (wr_data),
    .de    (committed_de),
    .d     (d),
    .qe    (committed_qe),
    .q     (committed_q),
    .ds    (ds),
    .qs    (committed_qs)
  );
  
  assign phase = phase_q;
  
  
  assign err_storage = (~shadow_q != committed_q) ? ~phase_q : 1'b0;
  
  assign qe = committed_qe;
  assign q  = committed_q;
  assign qs = committed_qs;
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
module prim_sync_reqack #(
  parameter bit EnRstChks = 1'b0,   
  parameter bit EnRzHs = 1'b0       
                                    
                                    
) (
  input  clk_src_i,       
  input  rst_src_ni,      
  input  clk_dst_i,       
  input  rst_dst_ni,      
  input  logic req_chk_i, 
  input  logic src_req_i, 
  output logic src_ack_o, 
  output logic dst_req_o, 
  input  logic dst_ack_i  
);
  
  logic unused_req_chk;
  assign unused_req_chk = req_chk_i;
  if (EnRzHs) begin : gen_rz_hs_protocol
    
    
    
    
    typedef enum logic {
      LoSt = 1'b0,
      HiSt = 1'b1
    } rz_fsm_e;
    
    rz_fsm_e src_fsm_d, src_fsm_q;
    rz_fsm_e dst_fsm_d, dst_fsm_q;
    logic src_ack, dst_ack;
    logic src_req, dst_req;
    
    always_comb begin : src_fsm
      src_fsm_d = src_fsm_q;
      src_ack_o = 1'b0;
      unique case (src_fsm_q)
        LoSt: begin
          
          
          if (!src_ack && src_req_i) begin
            src_fsm_d = HiSt;
          end
        end
        HiSt: begin
          
          src_ack_o = src_ack;
          
          
          if (!src_req_i || src_ack) begin
            src_fsm_d = LoSt;
          end
        end
        
        
        default: ;
        
        
      endcase
    end
    
    prim_flop_2sync #(
      .Width(1)
    ) ack_sync (
      .clk_i  (clk_src_i),
      .rst_ni (rst_src_ni),
      .d_i    (dst_ack),
      .q_o    (src_ack)
    );
    
    always_ff @(posedge clk_src_i or negedge rst_src_ni) begin
      if (!rst_src_ni) begin
        src_fsm_q <= LoSt;
      end else begin
        src_fsm_q <= src_fsm_d;
      end
    end
    assign src_req = logic'(src_fsm_q);
    
    always_comb begin : dst_fsm
      dst_fsm_d = dst_fsm_q;
      dst_req_o = 1'b0;
      unique case (dst_fsm_q)
        LoSt: begin
          if (dst_req) begin
            
            dst_req_o = 1'b1;
            
            
            if (dst_ack_i) begin
              dst_fsm_d = HiSt;
            end
          end
        end
        HiSt: begin
          
          if (!dst_req) begin
            dst_fsm_d = LoSt;
          end
        end
        
        
        default: ;
        
        
      endcase
    end
    
    prim_flop_2sync #(
      .Width(1)
    ) req_sync (
      .clk_i  (clk_dst_i),
      .rst_ni (rst_dst_ni),
      .d_i    (src_req),
      .q_o    (dst_req)
    );
    
    always_ff @(posedge clk_dst_i or negedge rst_dst_ni) begin
      if (!rst_dst_ni) begin
        dst_fsm_q <= LoSt;
      end else begin
        dst_fsm_q <= dst_fsm_d;
      end
    end
    assign dst_ack = logic'(dst_fsm_q);
  end else begin : gen_nrz_hs_protocol
    
    
    
    
    typedef enum logic {
      EVEN, ODD
    } sync_reqack_fsm_e;
    
    sync_reqack_fsm_e src_fsm_ns, src_fsm_cs;
    sync_reqack_fsm_e dst_fsm_ns, dst_fsm_cs;
    logic src_req_d, src_req_q, src_ack;
    logic dst_ack_d, dst_ack_q, dst_req;
    logic src_handshake, dst_handshake;
    assign src_handshake = src_req_i & src_ack_o;
    assign dst_handshake = dst_req_o & dst_ack_i;
    
    prim_flop_2sync #(
      .Width(1)
    ) req_sync (
      .clk_i  (clk_dst_i),
      .rst_ni (rst_dst_ni),
      .d_i    (src_req_q),
      .q_o    (dst_req)
    );
    
    prim_flop_2sync #(
      .Width(1)
    ) ack_sync (
      .clk_i  (clk_src_i),
      .rst_ni (rst_src_ni),
      .d_i    (dst_ack_q),
      .q_o    (src_ack)
    );
    
    always_comb begin : src_fsm
      src_fsm_ns = src_fsm_cs;
      
      src_req_d = src_req_q;
      src_ack_o = 1'b0;
      unique case (src_fsm_cs)
        EVEN: begin
          
          src_req_d = src_req_i;
          src_ack_o = src_ack;
          
          if (src_handshake) begin
            src_fsm_ns = ODD;
          end
        end
        ODD: begin
          
          
          src_req_d = ~src_req_i;
          src_ack_o = ~src_ack;
          
          if (src_handshake) begin
            src_fsm_ns = EVEN;
          end
        end
        
        
        default: ;
        
        
      endcase
    end
    
    always_comb begin : dst_fsm
      dst_fsm_ns = dst_fsm_cs;
      
      dst_req_o = 1'b0;
      dst_ack_d = dst_ack_q;
      unique case (dst_fsm_cs)
        EVEN: begin
          
          dst_req_o = dst_req;
          dst_ack_d = dst_ack_i;
          
          if (dst_handshake) begin
            dst_fsm_ns = ODD;
          end
        end
        ODD: begin
          
          
          dst_req_o = ~dst_req;
          dst_ack_d = ~dst_ack_i;
          
          if (dst_handshake) begin
            dst_fsm_ns = EVEN;
          end
        end
        
        
        default: ;
        
        
      endcase
    end
    
    always_ff @(posedge clk_src_i or negedge rst_src_ni) begin
      if (!rst_src_ni) begin
        src_fsm_cs <= EVEN;
        src_req_q  <= 1'b0;
      end else begin
        src_fsm_cs <= src_fsm_ns;
        src_req_q  <= src_req_d;
      end
    end
    always_ff @(posedge clk_dst_i or negedge rst_dst_ni) begin
      if (!rst_dst_ni) begin
        dst_fsm_cs <= EVEN;
        dst_ack_q  <= 1'b0;
      end else begin
        dst_fsm_cs <= dst_fsm_ns;
        dst_ack_q  <= dst_ack_d;
      end
    end
  end
  
  
  
  `ifdef INC_ASSERT
    
    
    logic effective_rst_n;
    assign effective_rst_n = rst_src_ni && rst_dst_ni;
    logic chk_flag;
    always_ff @(posedge clk_src_i or negedge effective_rst_n) begin
      if (!effective_rst_n) begin
        chk_flag <= '0;
      end else if (src_req_i && !chk_flag) begin
        chk_flag <= 1'b1;
      end
    end
    
    
    
    `ASSERT(SyncReqAckHoldReq, $fell(src_req_i) && req_chk_i && chk_flag |->
        $fell(src_ack_o), clk_src_i, !rst_src_ni || !rst_dst_ni || !req_chk_i || !chk_flag)
  `endif
  
  `ASSERT(SyncReqAckAckNeedsReq, dst_ack_i |->
      dst_req_o, clk_dst_i, !rst_src_ni || !rst_dst_ni)
  if (EnRstChks) begin : gen_assert_en_rst_chks
  `ifdef INC_ASSERT
    
    
    
    
    
    
    
    
    
    
    
    logic src_reset_flag;
    always_ff @(posedge clk_src_i or negedge rst_src_ni) begin
      if (!rst_src_ni) begin
        src_reset_flag <= '0;
      end else if(src_req_i) begin
        src_reset_flag <= 1'b1;
      end
    end
    logic dst_reset_flag;
    always_ff @(posedge clk_dst_i or negedge rst_dst_ni) begin
      if (!rst_dst_ni) begin
        dst_reset_flag <= '0;
      end else if (dst_req_o) begin
        dst_reset_flag <= 1'b1;
      end
    end
    
    
    
    `ASSERT(SyncReqAckRstSrc, $fell(rst_src_ni) |->
        (!src_reset_flag throughout !dst_reset_flag[->1]),
        clk_src_i, 0)
    `ASSERT(SyncReqAckRstDst, $fell(rst_dst_ni) |->
        (!dst_reset_flag throughout !src_reset_flag[->1]),
        clk_dst_i, 0)
  `endif
  end
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
module prim_sync_reqack_data #(
  parameter int unsigned Width       = 1,
  parameter bit          EnRstChks   = 1'b0, 
                                             
  parameter bit          DataSrc2Dst = 1'b1, 
                                             
  parameter bit          DataReg     = 1'b0, 
                                             
  parameter bit          EnRzHs      = 1'b0  
                                             
                                             
) (
  input  clk_src_i,       
  input  rst_src_ni,      
  input  clk_dst_i,       
  input  rst_dst_ni,      
  input  logic req_chk_i, 
  input  logic src_req_i, 
  output logic src_ack_o, 
  output logic dst_req_o, 
  input  logic dst_ack_i, 
  input  logic [Width-1:0] data_i,
  output logic [Width-1:0] data_o
);
  
  
  
  prim_sync_reqack #(
    .EnRstChks(EnRstChks),
    .EnRzHs(EnRzHs)
  ) u_prim_sync_reqack (
    .clk_src_i,
    .rst_src_ni,
    .clk_dst_i,
    .rst_dst_ni,
    .req_chk_i,
    .src_req_i,
    .src_ack_o,
    .dst_req_o,
    .dst_ack_i
  );
  
  
  
  
  
  
  
  
  if (DataSrc2Dst == 1'b0 && DataReg == 1'b1) begin : gen_data_reg
    logic             data_we;
    logic [Width-1:0] data_d, data_q;
    
    assign data_we = dst_req_o & dst_ack_i;
    assign data_d  = data_i;
    always_ff @(posedge clk_dst_i or negedge rst_dst_ni) begin
      if (!rst_dst_ni) begin
        data_q <= '0;
      end else if (data_we) begin
        data_q <= data_d;
      end
    end
    assign data_o = data_q;
  end else begin : gen_no_data_reg
    
    assign data_o = data_i;
  end
  
  
  
  if (DataSrc2Dst == 1'b1) begin : gen_assert_data_src2dst
`ifdef INC_ASSERT
    
    
    logic effective_rst_n;
    assign effective_rst_n = rst_src_ni && rst_dst_ni;
    logic chk_flag_d, chk_flag_q;
    assign chk_flag_d = src_req_i && !chk_flag_q ? 1'b1 : chk_flag_q;
    always_ff @(posedge clk_src_i or negedge effective_rst_n) begin
      if (!effective_rst_n) begin
        chk_flag_q <= '0;
      end else begin
        chk_flag_q <= chk_flag_d;
      end
    end
    
    
    
    `ASSERT(SyncReqAckDataHoldSrc2Dst, !$stable(data_i) && chk_flag_q |->
        (!src_req_i || (src_req_i && src_ack_o)),
        clk_src_i, !rst_src_ni || !rst_dst_ni || !chk_flag_q)
    
    `ASSERT_INIT(SyncReqAckDataReg, DataSrc2Dst && !DataReg)
`endif
  end else if (DataSrc2Dst == 1'b0 && DataReg == 1'b0) begin : gen_assert_data_dst2src
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
`ifdef INC_ASSERT
    
    
    logic effective_rst_n;
    assign effective_rst_n = rst_src_ni && rst_dst_ni;
    logic chk_flag_d, chk_flag_q;
    assign chk_flag_d = src_req_i && !chk_flag_q ? 1'b1 : chk_flag_q;
    always_ff @(posedge clk_src_i or negedge effective_rst_n) begin
      if (!effective_rst_n) begin
        chk_flag_q <= '0;
      end else begin
        chk_flag_q <= chk_flag_d;
      end
    end
    
    
    `ASSERT(SyncReqAckDataHoldDst2SrcA,
            chk_flag_q && src_req_i && src_ack_o |->
            $past(data_o, 2) == data_o && $past(data_o) == data_o,
            clk_src_i, !rst_src_ni || !rst_dst_ni || !chk_flag_q)
    `ASSERT(SyncReqAckDataHoldDst2SrcB,
            chk_flag_q && $past(src_req_i && src_ack_o) |-> $past(data_o) == data_o,
            clk_src_i, !rst_src_ni || !rst_dst_ni || !chk_flag_q)
`endif
  end
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
module tlul_adapter_reg
  import tlul_pkg::*;
  import prim_mubi_pkg::mubi4_t;
#(
  parameter  bit CmdIntgCheck      = 0,  
  parameter  bit EnableRspIntgGen  = 0,  
  parameter  bit EnableDataIntgGen = 0,  
  parameter  int RegAw             = 8,  
  parameter  int RegDw             = 32, 
  parameter  int AccessLatency     = 0,  
  localparam int RegBw             = RegDw/8
) (
  input clk_i,
  input rst_ni,
  
  input  tl_h2d_t tl_i,
  output tl_d2h_t tl_o,
  
  input  mubi4_t  en_ifetch_i,
  output logic    intg_error_o,
  
  output logic             re_o,
  output logic             we_o,
  output logic [RegAw-1:0] addr_o,
  output logic [RegDw-1:0] wdata_o,
  output logic [RegBw-1:0] be_o,
  input                    busy_i,
  
  
  input        [RegDw-1:0] rdata_i,
  
  input                    error_i
);
  `ASSERT_INIT(AllowedLatency_A, AccessLatency inside {0, 1})
  localparam int IW  = $bits(tl_i.a_source);
  localparam int SZW = $bits(tl_i.a_size);
  logic outstanding_q;    
  logic a_ack, d_ack;
  logic [RegDw-1:0] rdata, rdata_q;
  logic             error_q, error, err_internal, instr_error, intg_error;
  logic addr_align_err;     
  logic tl_err;             
  logic [IW-1:0]  reqid_q;
  logic [SZW-1:0] reqsz_q;
  tl_d_op_e       rspop_q;
  logic rd_req, wr_req;
  assign a_ack   = tl_i.a_valid & tl_o.a_ready;
  assign d_ack   = tl_o.d_valid & tl_i.d_ready;
  
  assign wr_req  = a_ack & ((tl_i.a_opcode == PutFullData) | (tl_i.a_opcode == PutPartialData));
  assign rd_req  = a_ack & (tl_i.a_opcode == Get);
  assign we_o    = wr_req & ~err_internal;
  assign re_o    = rd_req & ~err_internal;
  assign wdata_o = tl_i.a_data;
  assign be_o    = tl_i.a_mask;
  if (RegAw <= 2) begin : gen_only_one_reg
    assign addr_o  = '0;
  end else begin : gen_more_regs
    assign addr_o  = {tl_i.a_address[RegAw-1:2], 2'b00}; 
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)    outstanding_q <= 1'b0;
    else if (a_ack) outstanding_q <= 1'b1;
    else if (d_ack) outstanding_q <= 1'b0;
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      reqid_q <= '0;
      reqsz_q <= '0;
      rspop_q <= AccessAck;
    end else if (a_ack) begin
      reqid_q <= tl_i.a_source;
      reqsz_q <= tl_i.a_size;
      
      rspop_q <= (rd_req) ? AccessAckData : AccessAck ;
    end
  end
  if (AccessLatency == 1) begin : gen_access_latency1
    logic a_ack_q, err_internal_q, wr_req_q;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        a_ack_q <= 1'b0;
        err_internal_q <= 1'b0;
        wr_req_q <= 1'b0;
        rdata_q  <= '0;
        error_q  <= 1'b0;
      end else begin
        a_ack_q <= a_ack;
        err_internal_q <= err_internal;
        wr_req_q <= wr_req;
        rdata_q  <= rdata;
        error_q  <= error;
      end
    end
    always_comb begin
      if (a_ack_q) begin
        rdata = (error_i || err_internal_q || wr_req_q) ? '1 : rdata_i;
        error = error_i || err_internal_q;
      end else begin
        rdata = rdata_q;
        error = error_q;
      end
    end
  end else begin : gen_access_latency0
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        rdata_q <= '0;
        error_q <= 1'b0;
      end else if (a_ack) begin
        rdata_q <= (error_i || err_internal || wr_req) ? '1 : rdata_i;
        error_q <= error_i || err_internal;
      end
    end
    assign rdata = rdata_q;
    assign error = error_q;
  end
  tlul_pkg::tl_d2h_t tl_o_pre;
  assign tl_o_pre = '{
    a_ready:  ~(outstanding_q | busy_i),
    d_valid:  outstanding_q,
    d_opcode: rspop_q,
    d_param:  '0,
    d_size:   reqsz_q,
    d_source: reqid_q,
    d_sink:   '0,
    d_data:   rdata,
    d_user:   '0,
    d_error:  error
  };
  
  tlul_rsp_intg_gen #(
    .EnableRspIntgGen(EnableRspIntgGen),
    .EnableDataIntgGen(EnableDataIntgGen),
    .UserInIsZero(1'b1)
  ) u_rsp_intg_gen (
    .tl_i(tl_o_pre),
    .tl_o(tl_o)
  );
  if (CmdIntgCheck) begin : gen_cmd_intg_check
    logic intg_error_q;
    tlul_cmd_intg_chk u_cmd_intg_chk (
      .tl_i(tl_i),
      .err_o(intg_error)
    );
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        intg_error_q <= 1'b0;
      end else if (intg_error) begin
        intg_error_q <= 1'b1;
      end
    end
    assign intg_error_o = intg_error_q;
  end else begin : gen_no_cmd_intg_check
    assign intg_error = 1'b0;
    assign intg_error_o = 1'b0;
  end
  
  
  
  
  assign instr_error = prim_mubi_pkg::mubi4_test_true_strict(tl_i.a_user.instr_type) &
                       prim_mubi_pkg::mubi4_test_false_loose(en_ifetch_i);
  assign err_internal = addr_align_err | tl_err | instr_error | intg_error;
  
  
  
  
  always_comb begin
    if (wr_req) begin
      
      addr_align_err = |tl_i.a_address[1:0];
    end else begin
      
      addr_align_err = 1'b0;
    end
  end
  
  tlul_err u_err (
    .clk_i,
    .rst_ni,
    .tl_i,
    .err_o (tl_err)
  );
  `ASSERT_INIT(MatchedWidth_A, RegDw == top_pkg::TL_DW)
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
module tlul_cmd_intg_chk import tlul_pkg::*; (
  
  input  tl_h2d_t tl_i,
  
  output logic err_o
);
  logic [1:0] err;
  logic data_err;
  tl_h2d_cmd_intg_t cmd;
  assign cmd = extract_h2d_cmd_intg(tl_i);
  prim_secded_inv_64_57_dec u_chk (
    .data_i({tl_i.a_user.cmd_intg, H2DCmdMaxWidth'(cmd)}),
    .data_o(),
    .syndrome_o(),
    .err_o(err)
  );
  tlul_data_integ_dec u_tlul_data_integ_dec (
    .data_intg_i({tl_i.a_user.data_intg, DataMaxWidth'(tl_i.a_data)}),
    .data_err_o(data_err)
  );
  
  
  
  
  
  
  
  
  assign err_o = tl_i.a_valid & (|err | (|data_err));
  
  
  logic unused_tl;
  assign unused_tl = |tl_i;
  `ASSERT_INIT(PayLoadWidthCheck, $bits(tl_h2d_cmd_intg_t) <= H2DCmdMaxWidth)
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
module tlul_data_integ_dec import tlul_pkg::*; (
  
  input        [DataMaxWidth+DataIntgWidth-1:0] data_intg_i,
  output logic                                  data_err_o
);
  logic [1:0] data_err;
  prim_secded_inv_39_32_dec u_data_chk (
    .data_i(data_intg_i),
    .data_o(),
    .syndrome_o(),
    .err_o(data_err)
  );
  assign data_err_o = |data_err;
endmodule : tlul_data_integ_dec

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
module tlul_data_integ_enc import tlul_pkg::*; (
  
  input        [DataMaxWidth-1:0]               data_i,
  output logic [DataMaxWidth+DataIntgWidth-1:0] data_intg_o
);
  prim_secded_inv_39_32_enc u_data_gen (
    .data_i,
    .data_o(data_intg_o)
  );
endmodule : tlul_data_integ_enc

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
module tlul_err import tlul_pkg::*; (
  input clk_i,
  input rst_ni,
  input tl_h2d_t tl_i,
  output logic err_o
);
  localparam int IW  = $bits(tl_i.a_source);
  localparam int SZW = $bits(tl_i.a_size);
  localparam int DW  = $bits(tl_i.a_data);
  localparam int MW  = $bits(tl_i.a_mask);
  localparam int SubAW = $clog2(DW/8);
  logic opcode_allowed, a_config_allowed;
  logic op_full, op_partial, op_get;
  assign op_full    = (tl_i.a_opcode == PutFullData);
  assign op_partial = (tl_i.a_opcode == PutPartialData);
  assign op_get     = (tl_i.a_opcode == Get);
  
  logic instr_wr_err;
  assign instr_wr_err = prim_mubi_pkg::mubi4_test_true_strict(tl_i.a_user.instr_type) &
                        (op_full | op_partial);
  logic instr_type_err;
  assign instr_type_err = prim_mubi_pkg::mubi4_test_invalid(tl_i.a_user.instr_type);
  
  assign err_o = ~(opcode_allowed & a_config_allowed) | instr_wr_err | instr_type_err;
  
  assign opcode_allowed = (tl_i.a_opcode == PutFullData)
                        | (tl_i.a_opcode == PutPartialData)
                        | (tl_i.a_opcode == Get);
  
  logic addr_sz_chk;    
  logic mask_chk;       
  logic fulldata_chk;   
  localparam bit [MW-1:0] MaskOne = 1;
  logic [MW-1:0] mask;
  assign mask = MaskOne << tl_i.a_address[SubAW-1:0];
  always_comb begin
    addr_sz_chk  = 1'b0;
    mask_chk     = 1'b0;
    fulldata_chk = 1'b0; 
    if (tl_i.a_valid) begin
      unique case (tl_i.a_size)
        'h0: begin 
          addr_sz_chk  = 1'b1;
          mask_chk     = ~|(tl_i.a_mask & ~mask);
          fulldata_chk = |(tl_i.a_mask & mask);
        end
        'h1: begin 
          addr_sz_chk  = ~tl_i.a_address[0];
          
          mask_chk     = (tl_i.a_address[1]) ? ~|(tl_i.a_mask & 4'b0011)
                       : ~|(tl_i.a_mask & 4'b1100);
          fulldata_chk = (tl_i.a_address[1]) ? &tl_i.a_mask[3:2] : &tl_i.a_mask[1:0] ;
        end
        'h2: begin 
          addr_sz_chk  = ~|tl_i.a_address[SubAW-1:0];
          mask_chk     = 1'b1;
          fulldata_chk = &tl_i.a_mask[3:0];
        end
        default: begin 
          addr_sz_chk  = 1'b0;
          mask_chk     = 1'b0;
          fulldata_chk = 1'b0;
        end
      endcase
    end
  end
  assign a_config_allowed = addr_sz_chk
                          & mask_chk
                          & (op_get | op_partial | fulldata_chk) ;
  
  `ASSERT_INIT(dataWidthOnly32_A, DW == 32)
endmodule

package tlul_pkg;
  
  
  
  
  
  
  parameter ArbiterImpl = "PPC";
  typedef enum logic [2:0] {
    PutFullData    = 3'h 0,
    PutPartialData = 3'h 1,
    Get            = 3'h 4
  } tl_a_op_e;
  typedef enum logic [2:0] {
    AccessAck     = 3'h 0,
    AccessAckData = 3'h 1
  } tl_d_op_e;
  parameter int H2DCmdMaxWidth  = 57;
  parameter int H2DCmdIntgWidth = 7;
  parameter int H2DCmdFullWidth = H2DCmdMaxWidth + H2DCmdIntgWidth;
  parameter int D2HRspMaxWidth  = 57;
  parameter int D2HRspIntgWidth = 7;
  parameter int D2HRspFullWidth = D2HRspMaxWidth + D2HRspIntgWidth;
  parameter int DataMaxWidth    = 32;
  parameter int DataIntgWidth   = 7;
  parameter int DataFullWidth   = DataMaxWidth + DataIntgWidth;
  parameter int RsvdWidth       = top_pkg::TL_AUW - prim_mubi_pkg::MuBi4Width -
                                  H2DCmdIntgWidth - DataIntgWidth;
  
  
  parameter logic [top_pkg::TL_DW-1:0] DataWhenInstrError = '0;
  
  
  parameter logic [top_pkg::TL_DW-1:0] DataWhenError      = {top_pkg::TL_DW{1'b1}};
  typedef struct packed {
    logic [RsvdWidth-1:0]       rsvd;
    prim_mubi_pkg::mubi4_t      instr_type;
    logic [H2DCmdIntgWidth-1:0] cmd_intg;
    logic [DataIntgWidth-1:0]   data_intg;
  } tl_a_user_t;
  parameter tl_a_user_t TL_A_USER_DEFAULT = '{
    rsvd: '0,
    instr_type: prim_mubi_pkg::MuBi4False,
    cmd_intg:  {H2DCmdIntgWidth{1'b1}},
    data_intg: {DataIntgWidth{1'b1}}
  };
  typedef struct packed {
    prim_mubi_pkg::mubi4_t        instr_type;
    logic   [top_pkg::TL_AW-1:0]  addr;
    tl_a_op_e                     opcode;
    logic  [top_pkg::TL_DBW-1:0]  mask;
  } tl_h2d_cmd_intg_t;
  typedef struct packed {
    logic                         a_valid;
    tl_a_op_e                     a_opcode;
    logic                  [2:0]  a_param;
    logic  [top_pkg::TL_SZW-1:0]  a_size;
    logic  [top_pkg::TL_AIW-1:0]  a_source;
    logic   [top_pkg::TL_AW-1:0]  a_address;
    logic  [top_pkg::TL_DBW-1:0]  a_mask;
    logic   [top_pkg::TL_DW-1:0]  a_data;
    tl_a_user_t                   a_user;
    logic                         d_ready;
  } tl_h2d_t;
  
  
  
  
  
  
  localparam logic [top_pkg::TL_DW-1:0] BlankedAData = {top_pkg::TL_DW{1'b1}};
  localparam tl_h2d_t TL_H2D_DEFAULT = '{
    d_ready:  1'b1,
    a_opcode: tl_a_op_e'('0),
    a_user:   TL_A_USER_DEFAULT,
    a_data:   BlankedAData,
    default:  '0
  };
  typedef struct packed {
    logic [D2HRspIntgWidth-1:0]    rsp_intg;
    logic [DataIntgWidth-1:0]      data_intg;
  } tl_d_user_t;
  parameter tl_d_user_t TL_D_USER_DEFAULT = '{
    rsp_intg: {D2HRspIntgWidth{1'b1}},
    data_intg: {DataIntgWidth{1'b1}}
  };
  typedef struct packed {
    logic                         d_valid;
    tl_d_op_e                     d_opcode;
    logic                  [2:0]  d_param;
    logic  [top_pkg::TL_SZW-1:0]  d_size;   
    logic  [top_pkg::TL_AIW-1:0]  d_source;
    logic  [top_pkg::TL_DIW-1:0]  d_sink;
    logic   [top_pkg::TL_DW-1:0]  d_data;
    tl_d_user_t                   d_user;
    logic                         d_error;
    logic                         a_ready;
  } tl_d2h_t;
  typedef struct packed {
    tl_d_op_e                     opcode;
    logic  [top_pkg::TL_SZW-1:0]  size;
    
    
    
    
    
    logic                         error;
  } tl_d2h_rsp_intg_t;
  localparam tl_d2h_t TL_D2H_DEFAULT = '{
    a_ready:  1'b1,
    d_opcode: tl_d_op_e'('0),
    d_user:   TL_D_USER_DEFAULT,
    default:  '0
  };
  
  function automatic logic tl_a_user_chk(tl_a_user_t user);
    logic malformed_err;
    logic unused_user;
    unused_user = |user;
    malformed_err = prim_mubi_pkg::mubi4_test_invalid(user.instr_type);
    return malformed_err;
  endfunction 
  
  function automatic tl_h2d_cmd_intg_t extract_h2d_cmd_intg(tl_h2d_t tl);
    tl_h2d_cmd_intg_t payload;
    logic unused_tlul;
    unused_tlul = ^tl;
    payload.addr = tl.a_address;
    payload.opcode = tl.a_opcode;
    payload.mask = tl.a_mask;
    payload.instr_type = tl.a_user.instr_type;
    return payload;
  endfunction 
  
  function automatic tl_d2h_rsp_intg_t extract_d2h_rsp_intg(tl_d2h_t tl);
    tl_d2h_rsp_intg_t payload;
    logic unused_tlul;
    unused_tlul = ^tl;
    payload.opcode = tl.d_opcode;
    payload.size   = tl.d_size;
    
    payload.error  = tl.d_error;
    return payload;
  endfunction 
  
  function automatic logic [H2DCmdIntgWidth-1:0] get_cmd_intg(tl_h2d_t tl);
    logic [H2DCmdIntgWidth-1:0] cmd_intg;
    logic [H2DCmdMaxWidth-1:0] unused_cmd_payload;
    tl_h2d_cmd_intg_t cmd;
    cmd = extract_h2d_cmd_intg(tl);
    {cmd_intg, unused_cmd_payload} =
        prim_secded_pkg::prim_secded_inv_64_57_enc(H2DCmdMaxWidth'(cmd));
   return cmd_intg;
  endfunction  
  
  function automatic logic [DataIntgWidth-1:0] get_data_intg(logic [top_pkg::TL_DW-1:0] data);
    logic [DataIntgWidth-1:0] data_intg;
    logic [top_pkg::TL_DW-1:0] unused_data;
    logic [DataIntgWidth + top_pkg::TL_DW - 1 : 0] enc_data;
    enc_data = prim_secded_pkg::prim_secded_inv_39_32_enc(data);
    data_intg = enc_data[DataIntgWidth + top_pkg::TL_DW - 1 : top_pkg::TL_DW];
    unused_data = enc_data[top_pkg::TL_DW - 1 : 0];
    return data_intg;
  endfunction  
  
  function automatic logic [H2DCmdIntgWidth-1:0] get_bad_cmd_intg(tl_h2d_t tl);
    logic [H2DCmdIntgWidth-1:0] cmd_intg;
    cmd_intg = get_cmd_intg(tl);
    return ~cmd_intg;
  endfunction 
  
  function automatic logic [H2DCmdIntgWidth-1:0] get_bad_data_intg(logic [top_pkg::TL_DW-1:0] data);
    logic [H2DCmdIntgWidth-1:0] data_intg;
    data_intg = get_data_intg(data);
    return ~data_intg;
  endfunction 
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
module tlul_rsp_intg_gen import tlul_pkg::*; #(
  parameter bit EnableRspIntgGen = 1'b1,
  parameter bit EnableDataIntgGen = 1'b1,
  parameter bit UserInIsZero = 1'b0,
  parameter bit RspIntgInIsZero = UserInIsZero
) (
  
  input  tl_d2h_t tl_i,
  output tl_d2h_t tl_o
);
  logic [D2HRspIntgWidth-1:0] rsp_intg;
  if (EnableRspIntgGen) begin : gen_rsp_intg
    tl_d2h_rsp_intg_t rsp;
    logic [D2HRspMaxWidth-1:0] unused_payload;
    assign rsp = extract_d2h_rsp_intg(tl_i);
    prim_secded_inv_64_57_enc u_rsp_gen (
      .data_i(D2HRspMaxWidth'(rsp)),
      .data_o({rsp_intg, unused_payload})
    );
  end else if (RspIntgInIsZero) begin : gen_zero_rsp_intg
    assign rsp_intg = 0;
  end else begin : gen_passthrough_rsp_intg
    assign rsp_intg = tl_i.d_user.rsp_intg;
  end
  logic [DataIntgWidth-1:0] data_intg;
  if (EnableDataIntgGen) begin : gen_data_intg
    logic [DataMaxWidth-1:0] unused_data;
    tlul_data_integ_enc u_tlul_data_integ_enc (
      .data_i(DataMaxWidth'(tl_i.d_data)),
      .data_intg_o({data_intg, unused_data})
    );
  end else if (UserInIsZero) begin : gen_zero_data_intg
    assign data_intg = 0;
  end else begin : gen_passthrough_data_intg
    assign data_intg = tl_i.d_user.data_intg;
  end
  always_comb begin
    tl_o = tl_i;
    tl_o.d_user.rsp_intg = rsp_intg;
    tl_o.d_user.data_intg = data_intg;
  end
  logic unused_tl;
  assign unused_tl = ^tl_i;
  `ASSERT_INIT(PayLoadWidthCheck, $bits(tl_d2h_rsp_intg_t) <= D2HRspMaxWidth)
  `ASSERT_INIT(DataWidthCheck_A, $bits(tl_i.d_data) <= DataMaxWidth)
`ifndef SYNTHESIS
  always @(tl_i) begin
    `ASSERT_I(RspZero_A, tl_i.d_valid & RspIntgInIsZero -> ~|tl_i.d_user.rsp_intg)
    `ASSERT_I(UserZero_A, tl_i.d_valid & UserInIsZero -> ~|tl_i.d_user)
  end
`endif
endmodule 

package edn_pkg;
  
  
  
  parameter int unsigned   ENDPOINT_BUS_WIDTH = 32;
  parameter int unsigned   FIPS_ENDPOINT_BUS_WIDTH = entropy_src_pkg::FIPS_BUS_WIDTH +
                           ENDPOINT_BUS_WIDTH;
  
  typedef struct packed {
    logic                                 edn_req;
  } edn_req_t;
  typedef struct packed {
    logic                                 edn_ack;
    logic                                 edn_fips;
    logic [ENDPOINT_BUS_WIDTH-1:0]        edn_bus;
  } edn_rsp_t;
  parameter edn_req_t EDN_REQ_DEFAULT = '0;
  parameter edn_rsp_t EDN_RSP_DEFAULT = '0;
  parameter csrng_pkg::csrng_cmd_t BOOT_UNINSTANTIATE = 32'h5;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  localparam int StateWidth = 9;
  typedef enum logic [StateWidth-1:0] {
    Idle                = 9'b011000001, 
    BootLoadIns         = 9'b111000111, 
    BootInsAckWait      = 9'b001111001, 
    BootLoadGen         = 9'b000000011, 
    BootGenAckWait      = 9'b001110111, 
    BootPulse           = 9'b010101001, 
    BootDone            = 9'b011110000, 
    BootLoadUni         = 9'b100110101, 
    BootUniAckWait      = 9'b000101100, 
    AutoLoadIns         = 9'b110111100, 
    AutoFirstAckWait    = 9'b110100011, 
    AutoAckWait         = 9'b010010010, 
    AutoDispatch        = 9'b101100001, 
    AutoCaptGenCnt      = 9'b100001110, 
    AutoSendGenCmd      = 9'b111011101, 
    AutoCaptReseedCnt   = 9'b010111111, 
    AutoSendReseedCmd   = 9'b001101010, 
    SWPortMode          = 9'b010010101, 
    RejectCsrngEntropy  = 9'b000011000, 
    Error               = 9'b101111110  
  } state_e;
endpackage : edn_pkg

package csrng_pkg;
  parameter int unsigned NumAppsLg = $clog2(csrng_reg_pkg::NumApps);
  
  
  
  
  parameter int unsigned BlkLen = 128;
  
  parameter int unsigned KeyLen = 256;
  
  parameter int unsigned SeedLen = BlkLen + KeyLen;
  
  
  parameter int unsigned CtrLen = 32;
  parameter int unsigned RsCtrWidth = 32;
  
  parameter int unsigned GenBitsCtrWidth = 12;
  
  parameter int unsigned CmdWidth = 3;
  parameter int unsigned InstIdWidth = 4;
  
  parameter int unsigned CmdBusWidth = 32;
  
  parameter int unsigned CmdMaxClen = 12;
  parameter int unsigned CmdFifoDepth = 2;
  parameter int unsigned CmdFifoDepthLg = $clog2(CmdFifoDepth);
  parameter int unsigned GENBITS_BUS_WIDTH = BlkLen;
  parameter int unsigned FIPS_GENBITS_BUS_WIDTH = entropy_src_pkg::FIPS_BUS_WIDTH +
                         GENBITS_BUS_WIDTH;
  
  
  
  typedef struct packed {
    logic                   csrng_req_valid;
    logic [CmdBusWidth-1:0] csrng_req_bus;
    logic                   genbits_ready;
  } csrng_req_t;
  parameter int unsigned CmdStatusWidth = 3;
  typedef enum logic [CmdStatusWidth-1:0] {
    CMD_STS_SUCCESS              = 'h0,
    CMD_STS_INVALID_ACMD         = 'h1,
    CMD_STS_INVALID_GEN_CMD      = 'h2,
    CMD_STS_INVALID_CMD_SEQ      = 'h3,
    CMD_STS_RESEED_CNT_EXCEEDED  = 'h4,
    CMD_STS_UNDRIVEN             = 'z
  } csrng_cmd_sts_e;
  typedef struct packed {
    logic                         csrng_req_ready;
    logic                         csrng_rsp_ack;
    csrng_cmd_sts_e               csrng_rsp_sts;
    logic                         genbits_valid;
    logic                         genbits_fips;
    logic [GENBITS_BUS_WIDTH-1:0] genbits_bus;
  } csrng_rsp_t;
  parameter csrng_req_t CSRNG_REQ_DEFAULT = '{default: '0};
  parameter csrng_rsp_t CSRNG_RSP_DEFAULT = '0;
  typedef enum logic [CmdWidth-1:0] {
    INV  = 3'h0,
    INS  = 3'h1,
    RES  = 3'h2,
    GEN  = 3'h3,
    UPD  = 3'h4,
    UNI  = 3'h5
  } acmd_e;
  typedef struct packed {
    logic  [7:0] resv;
    logic [11:0] glen;
    logic  [3:0] flag0;
    logic  [3:0] clen;
    logic        gap; 
    acmd_e       acmd;
  } csrng_cmd_t;
  
  
  
  typedef struct packed {
    logic                   fips;
    logic  [RsCtrWidth-1:0] rs_ctr;
    logic     [SeedLen-1:0] pdata;
    logic   [NumAppsLg-1:0] inst_id;
    acmd_e                  cmd;
    logic      [KeyLen-1:0] key;
    logic      [BlkLen-1:0] v;
  } csrng_core_data_t;
  typedef struct packed {
    logic [KeyLen-1:0] key;
    logic [BlkLen-1:0] v;
  } csrng_key_v_t;
  
  
  typedef struct packed {
    logic                  fips;
    logic                  inst_state;
    logic     [KeyLen-1:0] key;
    logic     [BlkLen-1:0] v;
    logic [RsCtrWidth-1:0] rs_ctr;
  } csrng_state_t;
  parameter int unsigned StateWidth    = $bits(csrng_state_t);
  parameter int unsigned MainSmStateWidth = 6;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  typedef enum logic [MainSmStateWidth-1:0] {
    MainSmIdle        = 6'b110111, 
    MainSmParseCmd    = 6'b011101, 
    MainSmEntropyReq  = 6'b001110, 
    MainSmCmdPrep     = 6'b000011, 
    MainSmCmdVld      = 6'b010000, 
    MainSmClrAData    = 6'b111010, 
    MainSmCmdCompWait = 6'b100100, 
    MainSmError       = 6'b101001  
  } main_sm_state_e;
  parameter int CsKeymgrDivWidth = 384;
  typedef logic [CsKeymgrDivWidth-1:0] cs_keymgr_div_t;
endpackage : csrng_pkg

package csrng_reg_pkg;
  
  parameter int NumApps = 3;
  parameter int NumAlerts = 2;
  
  parameter int BlockAw = 7;
  
  parameter int NumRegs = 24;
  
  typedef enum int {
    AlertRecovAlertIdx = 0,
    AlertFatalAlertIdx = 1
  } csrng_alert_idx_t;
  
  
  
  typedef struct packed {
    struct packed {
      logic        q;
    } cs_fatal_err;
    struct packed {
      logic        q;
    } cs_hw_inst_exc;
    struct packed {
      logic        q;
    } cs_entropy_req;
    struct packed {
      logic        q;
    } cs_cmd_req_done;
  } csrng_reg2hw_intr_state_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } cs_fatal_err;
    struct packed {
      logic        q;
    } cs_hw_inst_exc;
    struct packed {
      logic        q;
    } cs_entropy_req;
    struct packed {
      logic        q;
    } cs_cmd_req_done;
  } csrng_reg2hw_intr_enable_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } cs_fatal_err;
    struct packed {
      logic        q;
      logic        qe;
    } cs_hw_inst_exc;
    struct packed {
      logic        q;
      logic        qe;
    } cs_entropy_req;
    struct packed {
      logic        q;
      logic        qe;
    } cs_cmd_req_done;
  } csrng_reg2hw_intr_test_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } fatal_alert;
    struct packed {
      logic        q;
      logic        qe;
    } recov_alert;
  } csrng_reg2hw_alert_test_reg_t;
  typedef struct packed {
    struct packed {
      logic [3:0]  q;
    } fips_force_enable;
    struct packed {
      logic [3:0]  q;
    } read_int_state;
    struct packed {
      logic [3:0]  q;
    } sw_app_enable;
    struct packed {
      logic [3:0]  q;
    } enable;
  } csrng_reg2hw_ctrl_reg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } csrng_reg2hw_cmd_req_reg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } csrng_reg2hw_reseed_interval_reg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        re;
  } csrng_reg2hw_genbits_reg_t;
  typedef struct packed {
    logic [2:0]  q;
  } csrng_reg2hw_int_state_read_enable_reg_t;
  typedef struct packed {
    logic [3:0]  q;
    logic        qe;
  } csrng_reg2hw_int_state_num_reg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        re;
  } csrng_reg2hw_int_state_val_reg_t;
  typedef struct packed {
    logic [2:0]  q;
  } csrng_reg2hw_fips_force_reg_t;
  typedef struct packed {
    logic [4:0]  q;
    logic        qe;
  } csrng_reg2hw_err_code_test_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } cs_fatal_err;
    struct packed {
      logic        d;
      logic        de;
    } cs_hw_inst_exc;
    struct packed {
      logic        d;
      logic        de;
    } cs_entropy_req;
    struct packed {
      logic        d;
      logic        de;
    } cs_cmd_req_done;
  } csrng_hw2reg_intr_state_reg_t;
  typedef struct packed {
    logic [31:0] d;
  } csrng_hw2reg_reseed_counter_mreg_t;
  typedef struct packed {
    struct packed {
      logic [2:0]  d;
      logic        de;
    } cmd_sts;
    struct packed {
      logic        d;
      logic        de;
    } cmd_ack;
    struct packed {
      logic        d;
      logic        de;
    } cmd_rdy;
  } csrng_hw2reg_sw_cmd_sts_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
    } genbits_fips;
    struct packed {
      logic        d;
    } genbits_vld;
  } csrng_hw2reg_genbits_vld_reg_t;
  typedef struct packed {
    logic [31:0] d;
  } csrng_hw2reg_genbits_reg_t;
  typedef struct packed {
    logic [31:0] d;
  } csrng_hw2reg_int_state_val_reg_t;
  typedef struct packed {
    logic [15:0] d;
    logic        de;
  } csrng_hw2reg_hw_exc_sts_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } cmd_stage_reseed_cnt_alert;
    struct packed {
      logic        d;
      logic        de;
    } cmd_stage_invalid_cmd_seq_alert;
    struct packed {
      logic        d;
      logic        de;
    } cmd_stage_invalid_acmd_alert;
    struct packed {
      logic        d;
      logic        de;
    } cs_bus_cmp_alert;
    struct packed {
      logic        d;
      logic        de;
    } acmd_flag0_field_alert;
    struct packed {
      logic        d;
      logic        de;
    } fips_force_enable_field_alert;
    struct packed {
      logic        d;
      logic        de;
    } read_int_state_field_alert;
    struct packed {
      logic        d;
      logic        de;
    } sw_app_enable_field_alert;
    struct packed {
      logic        d;
      logic        de;
    } enable_field_alert;
  } csrng_hw2reg_recov_alert_sts_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } fifo_state_err;
    struct packed {
      logic        d;
      logic        de;
    } fifo_read_err;
    struct packed {
      logic        d;
      logic        de;
    } fifo_write_err;
    struct packed {
      logic        d;
      logic        de;
    } ctr_err;
    struct packed {
      logic        d;
      logic        de;
    } aes_cipher_sm_err;
    struct packed {
      logic        d;
      logic        de;
    } ctr_drbg_sm_err;
    struct packed {
      logic        d;
      logic        de;
    } main_sm_err;
    struct packed {
      logic        d;
      logic        de;
    } cmd_stage_sm_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_genbits_err;
    struct packed {
      logic        d;
      logic        de;
    } sfifo_cmd_err;
  } csrng_hw2reg_err_code_reg_t;
  typedef struct packed {
    logic [5:0]  d;
    logic        de;
  } csrng_hw2reg_main_sm_state_reg_t;
  
  typedef struct packed {
    csrng_reg2hw_intr_state_reg_t intr_state; 
    csrng_reg2hw_intr_enable_reg_t intr_enable; 
    csrng_reg2hw_intr_test_reg_t intr_test; 
    csrng_reg2hw_alert_test_reg_t alert_test; 
    csrng_reg2hw_ctrl_reg_t ctrl; 
    csrng_reg2hw_cmd_req_reg_t cmd_req; 
    csrng_reg2hw_reseed_interval_reg_t reseed_interval; 
    csrng_reg2hw_genbits_reg_t genbits; 
    csrng_reg2hw_int_state_read_enable_reg_t int_state_read_enable; 
    csrng_reg2hw_int_state_num_reg_t int_state_num; 
    csrng_reg2hw_int_state_val_reg_t int_state_val; 
    csrng_reg2hw_fips_force_reg_t fips_force; 
    csrng_reg2hw_err_code_test_reg_t err_code_test; 
  } csrng_reg2hw_t;
  
  typedef struct packed {
    csrng_hw2reg_intr_state_reg_t intr_state; 
    csrng_hw2reg_reseed_counter_mreg_t [2:0] reseed_counter; 
    csrng_hw2reg_sw_cmd_sts_reg_t sw_cmd_sts; 
    csrng_hw2reg_genbits_vld_reg_t genbits_vld; 
    csrng_hw2reg_genbits_reg_t genbits; 
    csrng_hw2reg_int_state_val_reg_t int_state_val; 
    csrng_hw2reg_hw_exc_sts_reg_t hw_exc_sts; 
    csrng_hw2reg_recov_alert_sts_reg_t recov_alert_sts; 
    csrng_hw2reg_err_code_reg_t err_code; 
    csrng_hw2reg_main_sm_state_reg_t main_sm_state; 
  } csrng_hw2reg_t;
  
  parameter logic [BlockAw-1:0] CSRNG_INTR_STATE_OFFSET = 7'h 0;
  parameter logic [BlockAw-1:0] CSRNG_INTR_ENABLE_OFFSET = 7'h 4;
  parameter logic [BlockAw-1:0] CSRNG_INTR_TEST_OFFSET = 7'h 8;
  parameter logic [BlockAw-1:0] CSRNG_ALERT_TEST_OFFSET = 7'h c;
  parameter logic [BlockAw-1:0] CSRNG_REGWEN_OFFSET = 7'h 10;
  parameter logic [BlockAw-1:0] CSRNG_CTRL_OFFSET = 7'h 14;
  parameter logic [BlockAw-1:0] CSRNG_CMD_REQ_OFFSET = 7'h 18;
  parameter logic [BlockAw-1:0] CSRNG_RESEED_INTERVAL_OFFSET = 7'h 1c;
  parameter logic [BlockAw-1:0] CSRNG_RESEED_COUNTER_0_OFFSET = 7'h 20;
  parameter logic [BlockAw-1:0] CSRNG_RESEED_COUNTER_1_OFFSET = 7'h 24;
  parameter logic [BlockAw-1:0] CSRNG_RESEED_COUNTER_2_OFFSET = 7'h 28;
  parameter logic [BlockAw-1:0] CSRNG_SW_CMD_STS_OFFSET = 7'h 2c;
  parameter logic [BlockAw-1:0] CSRNG_GENBITS_VLD_OFFSET = 7'h 30;
  parameter logic [BlockAw-1:0] CSRNG_GENBITS_OFFSET = 7'h 34;
  parameter logic [BlockAw-1:0] CSRNG_INT_STATE_READ_ENABLE_OFFSET = 7'h 38;
  parameter logic [BlockAw-1:0] CSRNG_INT_STATE_READ_ENABLE_REGWEN_OFFSET = 7'h 3c;
  parameter logic [BlockAw-1:0] CSRNG_INT_STATE_NUM_OFFSET = 7'h 40;
  parameter logic [BlockAw-1:0] CSRNG_INT_STATE_VAL_OFFSET = 7'h 44;
  parameter logic [BlockAw-1:0] CSRNG_FIPS_FORCE_OFFSET = 7'h 48;
  parameter logic [BlockAw-1:0] CSRNG_HW_EXC_STS_OFFSET = 7'h 4c;
  parameter logic [BlockAw-1:0] CSRNG_RECOV_ALERT_STS_OFFSET = 7'h 50;
  parameter logic [BlockAw-1:0] CSRNG_ERR_CODE_OFFSET = 7'h 54;
  parameter logic [BlockAw-1:0] CSRNG_ERR_CODE_TEST_OFFSET = 7'h 58;
  parameter logic [BlockAw-1:0] CSRNG_MAIN_SM_STATE_OFFSET = 7'h 5c;
  
  parameter logic [3:0] CSRNG_INTR_TEST_RESVAL = 4'h 0;
  parameter logic [0:0] CSRNG_INTR_TEST_CS_CMD_REQ_DONE_RESVAL = 1'h 0;
  parameter logic [0:0] CSRNG_INTR_TEST_CS_ENTROPY_REQ_RESVAL = 1'h 0;
  parameter logic [0:0] CSRNG_INTR_TEST_CS_HW_INST_EXC_RESVAL = 1'h 0;
  parameter logic [0:0] CSRNG_INTR_TEST_CS_FATAL_ERR_RESVAL = 1'h 0;
  parameter logic [1:0] CSRNG_ALERT_TEST_RESVAL = 2'h 0;
  parameter logic [0:0] CSRNG_ALERT_TEST_RECOV_ALERT_RESVAL = 1'h 0;
  parameter logic [0:0] CSRNG_ALERT_TEST_FATAL_ALERT_RESVAL = 1'h 0;
  parameter logic [31:0] CSRNG_RESEED_COUNTER_0_RESVAL = 32'h 0;
  parameter logic [31:0] CSRNG_RESEED_COUNTER_0_RESEED_COUNTER_0_RESVAL = 32'h 0;
  parameter logic [31:0] CSRNG_RESEED_COUNTER_1_RESVAL = 32'h 0;
  parameter logic [31:0] CSRNG_RESEED_COUNTER_1_RESEED_COUNTER_1_RESVAL = 32'h 0;
  parameter logic [31:0] CSRNG_RESEED_COUNTER_2_RESVAL = 32'h 0;
  parameter logic [31:0] CSRNG_RESEED_COUNTER_2_RESEED_COUNTER_2_RESVAL = 32'h 0;
  parameter logic [1:0] CSRNG_GENBITS_VLD_RESVAL = 2'h 0;
  parameter logic [31:0] CSRNG_GENBITS_RESVAL = 32'h 0;
  parameter logic [31:0] CSRNG_INT_STATE_VAL_RESVAL = 32'h 0;
  
  typedef enum int {
    CSRNG_INTR_STATE,
    CSRNG_INTR_ENABLE,
    CSRNG_INTR_TEST,
    CSRNG_ALERT_TEST,
    CSRNG_REGWEN,
    CSRNG_CTRL,
    CSRNG_CMD_REQ,
    CSRNG_RESEED_INTERVAL,
    CSRNG_RESEED_COUNTER_0,
    CSRNG_RESEED_COUNTER_1,
    CSRNG_RESEED_COUNTER_2,
    CSRNG_SW_CMD_STS,
    CSRNG_GENBITS_VLD,
    CSRNG_GENBITS,
    CSRNG_INT_STATE_READ_ENABLE,
    CSRNG_INT_STATE_READ_ENABLE_REGWEN,
    CSRNG_INT_STATE_NUM,
    CSRNG_INT_STATE_VAL,
    CSRNG_FIPS_FORCE,
    CSRNG_HW_EXC_STS,
    CSRNG_RECOV_ALERT_STS,
    CSRNG_ERR_CODE,
    CSRNG_ERR_CODE_TEST,
    CSRNG_MAIN_SM_STATE
  } csrng_id_e;
  
  parameter logic [3:0] CSRNG_PERMIT [24] = '{
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 0011, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 0001, 
    4'b 0001, 
    4'b 1111, 
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 1111, 
    4'b 0001, 
    4'b 0011, 
    4'b 0011, 
    4'b 1111, 
    4'b 0001, 
    4'b 0001  
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

package keymgr_pkg;
  parameter int KeyWidth = 256;
  parameter int CDIs = 2; 
  parameter int CdiWidth = prim_util_pkg::vbits(CDIs);
  parameter int OtbnKeyWidth = 384;
  parameter int DigestWidth = 128;     
  parameter int KmacDataIfWidth = 64;  
  parameter int KeyMgrStages = 3; 
  parameter int SwBindingWidth = 32 * keymgr_reg_pkg::NumSwBindingReg;
  parameter int SaltWidth = 32 * keymgr_reg_pkg::NumSaltReg;
  parameter int Shares = 2; 
  parameter int KeyVersionWidth = 32;  
  
  parameter int HealthStateWidth = 128;
  parameter int DevIdWidth = 256;
  parameter int MaxWidth = 256;
  
  
  
  
  typedef logic [KeyWidth-1:0] seed_t;
  parameter seed_t RndCnstRevisionSeedDefault =
    256'h69802e51_bacf8874_e650d692_e3d8a646_2d3f158f_0bf7961d_d346f880_b4d52170;
  parameter seed_t RndCnstCreatorIdentitySeedDefault =
    256'h344bff84_d3edf83e_aa565c5e_6c2d22f2_75283734_15cf6d83_32cd3752_731817c;
  parameter seed_t RndCnstOwnerIntIdentitySeedDefault =
    256'h32a37bf9_2627382b_47180548_1fc4b847_a7eba1ce_c13e80ab_030f847e_9bd902e;
  parameter seed_t RndCnstOwnerIdentitySeedDefault =
    256'hc1ba416c_822ad676_e4f54f36_33d8dc7e_00ccfb8b_92209f1b_d3229348_275ebda;
  parameter seed_t RndCnstSoftOutputSeedDefault =
    256'h23cbe85e_62e39992_4ab8d6a6_acbf12f0_0ca6f488_63eaa428_ffb11b26_c5282b14;
  parameter seed_t RndCnstHardOutputSeedDefault =
    256'h877ef0b9_aceaefc5_693b1aa7_e43a7f3d_ee7d63b6_4e73e182_b49cbf87_2872f2c;
  
  
  parameter seed_t RndCnstNoneSeedDefault =
    256'h6013ba4d_8d04fe4f_80cb0472_536c9679_08b82f1d_98a4e405_cb4680ec_3a4a8d7a;
  parameter seed_t RndCnstAesSeedDefault =
    256'he16a8fa9_5b613cd5_fb9ad23f_bd8347e1_64e45dac_5d08a41b_e83caa37_e03d9482;
  parameter seed_t RndCnstKmacSeedDefault =
    256'hc57f4c0b_b308e83f_3fc4bc63_d87dd67d_9071dc1c_e19484c8_3c94fb97_dd634369;
  parameter seed_t RndCnstOtbnSeedDefault =
    256'hcbcb4d2d_0abeb81b_ca7451ae_d1e2479d_ba13530a_d046b945_646aa127_bd4f6a38;
  parameter seed_t RndCnstCdiDefault =
    256'h54180905_d14c1d2f_2dda1522_f332bc0e_fcd6b92f_f0f9db75_3a9a9544_26a42eab;
  
  
  
  parameter int LfsrWidth = 64;
  typedef logic [LfsrWidth-1:0] lfsr_seed_t;
  typedef logic [LfsrWidth-1:0][$clog2(LfsrWidth)-1:0] lfsr_perm_t;
  parameter lfsr_seed_t RndCnstLfsrSeedDefault = 64'h22d326255bd24320;
  parameter lfsr_perm_t RndCnstLfsrPermDefault = {
    128'h16108c9f9008aa37e5118d1ec1df64a7,
    256'h24f3f1b73537f42d38383ee8f897286df81d49ab54b6bbbb666cbd1a16c41252
  };
  
  parameter int RandWidth = LfsrWidth / 2;
  typedef logic [RandWidth-1:0][$clog2(RandWidth)-1:0] rand_perm_t;
  parameter rand_perm_t RndCnstRandPermDefault = {
    160'h62089181d2a6be2ce145e2e27099ededbd7dceb0
  };
  
  
  parameter int AdvDataWidth = SwBindingWidth + 2*KeyWidth + DevIdWidth + HealthStateWidth;
  parameter int IdDataWidth = KeyWidth;
  
  parameter int GenDataWidth = 32 + SaltWidth + KeyWidth*2;
  parameter int StageWidth = $clog2(KeyMgrStages);
  
  
  
  
  parameter int KDFMaxWidth = 1984;
  
  typedef enum logic [1:0] {
    Creator,
    OwnerInt,
    Owner,
    Disable
  } keymgr_stage_e;
  
  typedef enum logic [1:0] {
    None,
    Aes,
    Kmac,
    Otbn
  } keymgr_key_dest_e;
  
  typedef enum logic [1:0] {
    AesIdx,
    KmacIdx,
    OtbnIdx,
    LastIdx
  } keymgr_sideload_slot_idx_e;
  
  typedef enum logic {
    HwKey = 0,
    SwKey = 1
  } keymgr_gen_out_e;
  
  typedef enum logic [2:0] {
    OpAdvance = 0,
    OpGenId = 1,
    OpGenSwOut = 2,
    OpGenHwOut = 3,
    OpDisable = 4
  } keymgr_ops_e;
  
  typedef enum logic [2:0] {
    StReset,
    StInit,
    StCreatorRootKey,
    StOwnerIntKey,
    StOwnerKey,
    StDisabled,
    StInvalid
  } keymgr_working_state_e;
  
  typedef enum logic [1:0] {
    OpIdle = 0,
    OpWip = 1,
    OpDoneSuccess = 2,
    OpDoneFail = 3
  } keymgr_op_status_e;
  
  
  
  
  
  typedef enum logic [1:0] {
    SyncErrInvalidOp,
    SyncErrInvalidIn,
    SyncErrLastIdx
  } keymgr_sync_error_e;
  typedef enum logic [1:0] {
    AsyncErrShadowUpdate,
    AsyncErrLastIdx
  } keymgr_async_error_e;
  typedef enum logic [1:0] {
    SyncFaultKmacOp,
    SyncFaultKmacOut,
    SyncFaultSideSel,
    SyncFaultLastIdx
  } keymgr_sync_fault_e;
  typedef enum logic [3:0] {
    AsyncFaultKmacCmd,
    AsyncFaultKmacFsm,
    AsyncFaultKmacDone,
    AsyncFaultRegIntg,
    AsyncFaultShadow,
    AsyncFaultFsmIntg,
    AsyncFaultFsmChk,
    AsyncFaultCntErr,
    AsyncFaultRCntErr,
    AsyncFaultSideErr,
    AsyncFaultKeyEcc,
    AsyncFaultLastIdx
  } keymgr_async_fault_e;
  
  
  typedef enum logic [2:0] {
    ErrInvalidOp,
    ErrInvalidIn,
    ErrShadowUpdate,
    ErrLastPos
  } keymgr_err_pos_e;
  
  typedef enum logic [3:0] {
    FaultKmacCmd,
    FaultKmacFsm,
    FaultKmacDone,
    FaultKmacOp,
    FaultKmacOut,
    FaultRegIntg,
    FaultShadow,
    FaultCtrlFsm,
    FaultCtrlFsmChk,
    FaultCtrlCnt,
    FaultReseedCnt,
    FaultSideFsm,
    FaultSideSel,
    FaultKeyEcc,
    FaultLastPos
  } keymgr_fault_pos_e;
  typedef enum logic [2:0] {
    KeyUpdateIdle,
    KeyUpdateRandom,
    KeyUpdateRoot,
    KeyUpdateKmac,
    KeyUpdateWipe
  } keymgr_key_update_e;
  typedef enum logic [2:0] {
    SideLoadClrIdle,
    SideLoadClrAes,
    SideLoadClrKmac,
    SideLoadClrOtbn
  } keymgr_sideload_clr_e;
  
  typedef struct packed {
    logic valid;
    logic [Shares-1:0][KeyWidth-1:0] key;
  } hw_key_req_t;
  
  typedef struct packed {
    logic valid;
    logic [Shares-1:0][OtbnKeyWidth-1:0] key;
  } otbn_key_req_t;
  parameter hw_key_req_t HW_KEY_REQ_DEFAULT = '{
    valid: 1'b0,
    key: {Shares{KeyWidth'(32'hDEADBEEF)}}
  };
  parameter otbn_key_req_t OTBN_KEY_REQ_DEFAULT = '{
    valid: 1'b0,
    key: {Shares{OtbnKeyWidth'(32'hDEADBEEF)}}
  };
  
  
  
  typedef enum logic [1:0] {
    KeyMgrEnCtrl,
    KeyMgrEnCfgEn,
    KeyMgrEnSwBindingEn,
    KeyMgrEnLast
  } keymgr_lc_en_usage_e;
  
  function automatic logic[RandWidth-1:0] perm_data (logic [RandWidth-1:0] data,
    rand_perm_t perm_sel);
    for (int k = 0; k < 32; k++) begin : gen_data_loop
      perm_data[k] = data[perm_sel[k]];
    end
  endfunction
  
  function automatic logic valid_data_chk (logic [KeyWidth-1:0] value);
    return |value & ~&value;
  endfunction
endpackage : keymgr_pkg

package keymgr_reg_pkg;
  
  parameter int NumSaltReg = 8;
  parameter int NumSwBindingReg = 8;
  parameter int NumOutReg = 8;
  parameter int NumKeyVersion = 1;
  parameter int NumAlerts = 2;
  
  parameter int BlockAw = 8;
  
  parameter int NumRegs = 63;
  
  typedef enum int {
    AlertRecovOperationErrIdx = 0,
    AlertFatalFaultErrIdx = 1
  } keymgr_alert_idx_t;
  
  
  
  typedef struct packed {
    logic        q;
  } keymgr_reg2hw_intr_state_reg_t;
  typedef struct packed {
    logic        q;
  } keymgr_reg2hw_intr_enable_reg_t;
  typedef struct packed {
    logic        q;
    logic        qe;
  } keymgr_reg2hw_intr_test_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } fatal_fault_err;
    struct packed {
      logic        q;
      logic        qe;
    } recov_operation_err;
  } keymgr_reg2hw_alert_test_reg_t;
  typedef struct packed {
    logic        q;
  } keymgr_reg2hw_start_reg_t;
  typedef struct packed {
    struct packed {
      logic [1:0]  q;
    } dest_sel;
    struct packed {
      logic        q;
    } cdi_sel;
    struct packed {
      logic [2:0]  q;
    } operation;
  } keymgr_reg2hw_control_shadowed_reg_t;
  typedef struct packed {
    logic [2:0]  q;
  } keymgr_reg2hw_sideload_clear_reg_t;
  typedef struct packed {
    logic [15:0] q;
  } keymgr_reg2hw_reseed_interval_shadowed_reg_t;
  typedef struct packed {
    logic        q;
    logic        qe;
  } keymgr_reg2hw_sw_binding_regwen_reg_t;
  typedef struct packed {
    logic [31:0] q;
  } keymgr_reg2hw_sealing_sw_binding_mreg_t;
  typedef struct packed {
    logic [31:0] q;
  } keymgr_reg2hw_attest_sw_binding_mreg_t;
  typedef struct packed {
    logic [31:0] q;
  } keymgr_reg2hw_salt_mreg_t;
  typedef struct packed {
    logic [31:0] q;
  } keymgr_reg2hw_key_version_mreg_t;
  typedef struct packed {
    logic [31:0] q;
  } keymgr_reg2hw_max_creator_key_ver_shadowed_reg_t;
  typedef struct packed {
    logic [31:0] q;
  } keymgr_reg2hw_max_owner_int_key_ver_shadowed_reg_t;
  typedef struct packed {
    logic [31:0] q;
  } keymgr_reg2hw_max_owner_key_ver_shadowed_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } key_ecc;
    struct packed {
      logic        q;
    } side_ctrl_sel;
    struct packed {
      logic        q;
    } side_ctrl_fsm;
    struct packed {
      logic        q;
    } reseed_cnt;
    struct packed {
      logic        q;
    } ctrl_fsm_cnt;
    struct packed {
      logic        q;
    } ctrl_fsm_chk;
    struct packed {
      logic        q;
    } ctrl_fsm_intg;
    struct packed {
      logic        q;
    } shadow;
    struct packed {
      logic        q;
    } regfile_intg;
    struct packed {
      logic        q;
    } kmac_out;
    struct packed {
      logic        q;
    } kmac_op;
    struct packed {
      logic        q;
    } kmac_done;
    struct packed {
      logic        q;
    } kmac_fsm;
    struct packed {
      logic        q;
    } cmd;
  } keymgr_reg2hw_fault_status_reg_t;
  typedef struct packed {
    logic        d;
    logic        de;
  } keymgr_hw2reg_intr_state_reg_t;
  typedef struct packed {
    logic        d;
  } keymgr_hw2reg_cfg_regwen_reg_t;
  typedef struct packed {
    logic        d;
    logic        de;
  } keymgr_hw2reg_start_reg_t;
  typedef struct packed {
    logic        d;
  } keymgr_hw2reg_sw_binding_regwen_reg_t;
  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } keymgr_hw2reg_sw_share0_output_mreg_t;
  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } keymgr_hw2reg_sw_share1_output_mreg_t;
  typedef struct packed {
    logic [2:0]  d;
    logic        de;
  } keymgr_hw2reg_working_state_reg_t;
  typedef struct packed {
    logic [1:0]  d;
    logic        de;
  } keymgr_hw2reg_op_status_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } invalid_shadow_update;
    struct packed {
      logic        d;
      logic        de;
    } invalid_kmac_input;
    struct packed {
      logic        d;
      logic        de;
    } invalid_op;
  } keymgr_hw2reg_err_code_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } key_ecc;
    struct packed {
      logic        d;
      logic        de;
    } side_ctrl_sel;
    struct packed {
      logic        d;
      logic        de;
    } side_ctrl_fsm;
    struct packed {
      logic        d;
      logic        de;
    } reseed_cnt;
    struct packed {
      logic        d;
      logic        de;
    } ctrl_fsm_cnt;
    struct packed {
      logic        d;
      logic        de;
    } ctrl_fsm_chk;
    struct packed {
      logic        d;
      logic        de;
    } ctrl_fsm_intg;
    struct packed {
      logic        d;
      logic        de;
    } shadow;
    struct packed {
      logic        d;
      logic        de;
    } regfile_intg;
    struct packed {
      logic        d;
      logic        de;
    } kmac_out;
    struct packed {
      logic        d;
      logic        de;
    } kmac_op;
    struct packed {
      logic        d;
      logic        de;
    } kmac_done;
    struct packed {
      logic        d;
      logic        de;
    } kmac_fsm;
    struct packed {
      logic        d;
      logic        de;
    } cmd;
  } keymgr_hw2reg_fault_status_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } invalid_digest;
    struct packed {
      logic        d;
      logic        de;
    } invalid_key;
    struct packed {
      logic        d;
      logic        de;
    } invalid_key_version;
    struct packed {
      logic        d;
      logic        de;
    } invalid_health_state;
    struct packed {
      logic        d;
      logic        de;
    } invalid_dev_id;
    struct packed {
      logic        d;
      logic        de;
    } invalid_owner_seed;
    struct packed {
      logic        d;
      logic        de;
    } invalid_creator_seed;
  } keymgr_hw2reg_debug_reg_t;
  
  typedef struct packed {
    keymgr_reg2hw_intr_state_reg_t intr_state; 
    keymgr_reg2hw_intr_enable_reg_t intr_enable; 
    keymgr_reg2hw_intr_test_reg_t intr_test; 
    keymgr_reg2hw_alert_test_reg_t alert_test; 
    keymgr_reg2hw_start_reg_t start; 
    keymgr_reg2hw_control_shadowed_reg_t control_shadowed; 
    keymgr_reg2hw_sideload_clear_reg_t sideload_clear; 
    keymgr_reg2hw_reseed_interval_shadowed_reg_t reseed_interval_shadowed; 
    keymgr_reg2hw_sw_binding_regwen_reg_t sw_binding_regwen; 
    keymgr_reg2hw_sealing_sw_binding_mreg_t [7:0] sealing_sw_binding; 
    keymgr_reg2hw_attest_sw_binding_mreg_t [7:0] attest_sw_binding; 
    keymgr_reg2hw_salt_mreg_t [7:0] salt; 
    keymgr_reg2hw_key_version_mreg_t [0:0] key_version; 
    keymgr_reg2hw_max_creator_key_ver_shadowed_reg_t max_creator_key_ver_shadowed; 
    keymgr_reg2hw_max_owner_int_key_ver_shadowed_reg_t max_owner_int_key_ver_shadowed; 
    keymgr_reg2hw_max_owner_key_ver_shadowed_reg_t max_owner_key_ver_shadowed; 
    keymgr_reg2hw_fault_status_reg_t fault_status; 
  } keymgr_reg2hw_t;
  
  typedef struct packed {
    keymgr_hw2reg_intr_state_reg_t intr_state; 
    keymgr_hw2reg_cfg_regwen_reg_t cfg_regwen; 
    keymgr_hw2reg_start_reg_t start; 
    keymgr_hw2reg_sw_binding_regwen_reg_t sw_binding_regwen; 
    keymgr_hw2reg_sw_share0_output_mreg_t [7:0] sw_share0_output; 
    keymgr_hw2reg_sw_share1_output_mreg_t [7:0] sw_share1_output; 
    keymgr_hw2reg_working_state_reg_t working_state; 
    keymgr_hw2reg_op_status_reg_t op_status; 
    keymgr_hw2reg_err_code_reg_t err_code; 
    keymgr_hw2reg_fault_status_reg_t fault_status; 
    keymgr_hw2reg_debug_reg_t debug; 
  } keymgr_hw2reg_t;
  
  parameter logic [BlockAw-1:0] KEYMGR_INTR_STATE_OFFSET = 8'h 0;
  parameter logic [BlockAw-1:0] KEYMGR_INTR_ENABLE_OFFSET = 8'h 4;
  parameter logic [BlockAw-1:0] KEYMGR_INTR_TEST_OFFSET = 8'h 8;
  parameter logic [BlockAw-1:0] KEYMGR_ALERT_TEST_OFFSET = 8'h c;
  parameter logic [BlockAw-1:0] KEYMGR_CFG_REGWEN_OFFSET = 8'h 10;
  parameter logic [BlockAw-1:0] KEYMGR_START_OFFSET = 8'h 14;
  parameter logic [BlockAw-1:0] KEYMGR_CONTROL_SHADOWED_OFFSET = 8'h 18;
  parameter logic [BlockAw-1:0] KEYMGR_SIDELOAD_CLEAR_OFFSET = 8'h 1c;
  parameter logic [BlockAw-1:0] KEYMGR_RESEED_INTERVAL_REGWEN_OFFSET = 8'h 20;
  parameter logic [BlockAw-1:0] KEYMGR_RESEED_INTERVAL_SHADOWED_OFFSET = 8'h 24;
  parameter logic [BlockAw-1:0] KEYMGR_SW_BINDING_REGWEN_OFFSET = 8'h 28;
  parameter logic [BlockAw-1:0] KEYMGR_SEALING_SW_BINDING_0_OFFSET = 8'h 2c;
  parameter logic [BlockAw-1:0] KEYMGR_SEALING_SW_BINDING_1_OFFSET = 8'h 30;
  parameter logic [BlockAw-1:0] KEYMGR_SEALING_SW_BINDING_2_OFFSET = 8'h 34;
  parameter logic [BlockAw-1:0] KEYMGR_SEALING_SW_BINDING_3_OFFSET = 8'h 38;
  parameter logic [BlockAw-1:0] KEYMGR_SEALING_SW_BINDING_4_OFFSET = 8'h 3c;
  parameter logic [BlockAw-1:0] KEYMGR_SEALING_SW_BINDING_5_OFFSET = 8'h 40;
  parameter logic [BlockAw-1:0] KEYMGR_SEALING_SW_BINDING_6_OFFSET = 8'h 44;
  parameter logic [BlockAw-1:0] KEYMGR_SEALING_SW_BINDING_7_OFFSET = 8'h 48;
  parameter logic [BlockAw-1:0] KEYMGR_ATTEST_SW_BINDING_0_OFFSET = 8'h 4c;
  parameter logic [BlockAw-1:0] KEYMGR_ATTEST_SW_BINDING_1_OFFSET = 8'h 50;
  parameter logic [BlockAw-1:0] KEYMGR_ATTEST_SW_BINDING_2_OFFSET = 8'h 54;
  parameter logic [BlockAw-1:0] KEYMGR_ATTEST_SW_BINDING_3_OFFSET = 8'h 58;
  parameter logic [BlockAw-1:0] KEYMGR_ATTEST_SW_BINDING_4_OFFSET = 8'h 5c;
  parameter logic [BlockAw-1:0] KEYMGR_ATTEST_SW_BINDING_5_OFFSET = 8'h 60;
  parameter logic [BlockAw-1:0] KEYMGR_ATTEST_SW_BINDING_6_OFFSET = 8'h 64;
  parameter logic [BlockAw-1:0] KEYMGR_ATTEST_SW_BINDING_7_OFFSET = 8'h 68;
  parameter logic [BlockAw-1:0] KEYMGR_SALT_0_OFFSET = 8'h 6c;
  parameter logic [BlockAw-1:0] KEYMGR_SALT_1_OFFSET = 8'h 70;
  parameter logic [BlockAw-1:0] KEYMGR_SALT_2_OFFSET = 8'h 74;
  parameter logic [BlockAw-1:0] KEYMGR_SALT_3_OFFSET = 8'h 78;
  parameter logic [BlockAw-1:0] KEYMGR_SALT_4_OFFSET = 8'h 7c;
  parameter logic [BlockAw-1:0] KEYMGR_SALT_5_OFFSET = 8'h 80;
  parameter logic [BlockAw-1:0] KEYMGR_SALT_6_OFFSET = 8'h 84;
  parameter logic [BlockAw-1:0] KEYMGR_SALT_7_OFFSET = 8'h 88;
  parameter logic [BlockAw-1:0] KEYMGR_KEY_VERSION_OFFSET = 8'h 8c;
  parameter logic [BlockAw-1:0] KEYMGR_MAX_CREATOR_KEY_VER_REGWEN_OFFSET = 8'h 90;
  parameter logic [BlockAw-1:0] KEYMGR_MAX_CREATOR_KEY_VER_SHADOWED_OFFSET = 8'h 94;
  parameter logic [BlockAw-1:0] KEYMGR_MAX_OWNER_INT_KEY_VER_REGWEN_OFFSET = 8'h 98;
  parameter logic [BlockAw-1:0] KEYMGR_MAX_OWNER_INT_KEY_VER_SHADOWED_OFFSET = 8'h 9c;
  parameter logic [BlockAw-1:0] KEYMGR_MAX_OWNER_KEY_VER_REGWEN_OFFSET = 8'h a0;
  parameter logic [BlockAw-1:0] KEYMGR_MAX_OWNER_KEY_VER_SHADOWED_OFFSET = 8'h a4;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE0_OUTPUT_0_OFFSET = 8'h a8;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE0_OUTPUT_1_OFFSET = 8'h ac;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE0_OUTPUT_2_OFFSET = 8'h b0;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE0_OUTPUT_3_OFFSET = 8'h b4;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE0_OUTPUT_4_OFFSET = 8'h b8;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE0_OUTPUT_5_OFFSET = 8'h bc;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE0_OUTPUT_6_OFFSET = 8'h c0;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE0_OUTPUT_7_OFFSET = 8'h c4;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE1_OUTPUT_0_OFFSET = 8'h c8;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE1_OUTPUT_1_OFFSET = 8'h cc;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE1_OUTPUT_2_OFFSET = 8'h d0;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE1_OUTPUT_3_OFFSET = 8'h d4;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE1_OUTPUT_4_OFFSET = 8'h d8;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE1_OUTPUT_5_OFFSET = 8'h dc;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE1_OUTPUT_6_OFFSET = 8'h e0;
  parameter logic [BlockAw-1:0] KEYMGR_SW_SHARE1_OUTPUT_7_OFFSET = 8'h e4;
  parameter logic [BlockAw-1:0] KEYMGR_WORKING_STATE_OFFSET = 8'h e8;
  parameter logic [BlockAw-1:0] KEYMGR_OP_STATUS_OFFSET = 8'h ec;
  parameter logic [BlockAw-1:0] KEYMGR_ERR_CODE_OFFSET = 8'h f0;
  parameter logic [BlockAw-1:0] KEYMGR_FAULT_STATUS_OFFSET = 8'h f4;
  parameter logic [BlockAw-1:0] KEYMGR_DEBUG_OFFSET = 8'h f8;
  
  parameter logic [0:0] KEYMGR_INTR_TEST_RESVAL = 1'h 0;
  parameter logic [0:0] KEYMGR_INTR_TEST_OP_DONE_RESVAL = 1'h 0;
  parameter logic [1:0] KEYMGR_ALERT_TEST_RESVAL = 2'h 0;
  parameter logic [0:0] KEYMGR_ALERT_TEST_RECOV_OPERATION_ERR_RESVAL = 1'h 0;
  parameter logic [0:0] KEYMGR_ALERT_TEST_FATAL_FAULT_ERR_RESVAL = 1'h 0;
  parameter logic [0:0] KEYMGR_CFG_REGWEN_RESVAL = 1'h 1;
  parameter logic [0:0] KEYMGR_CFG_REGWEN_EN_RESVAL = 1'h 1;
  parameter logic [0:0] KEYMGR_SW_BINDING_REGWEN_RESVAL = 1'h 1;
  parameter logic [0:0] KEYMGR_SW_BINDING_REGWEN_EN_RESVAL = 1'h 1;
  
  typedef enum int {
    KEYMGR_INTR_STATE,
    KEYMGR_INTR_ENABLE,
    KEYMGR_INTR_TEST,
    KEYMGR_ALERT_TEST,
    KEYMGR_CFG_REGWEN,
    KEYMGR_START,
    KEYMGR_CONTROL_SHADOWED,
    KEYMGR_SIDELOAD_CLEAR,
    KEYMGR_RESEED_INTERVAL_REGWEN,
    KEYMGR_RESEED_INTERVAL_SHADOWED,
    KEYMGR_SW_BINDING_REGWEN,
    KEYMGR_SEALING_SW_BINDING_0,
    KEYMGR_SEALING_SW_BINDING_1,
    KEYMGR_SEALING_SW_BINDING_2,
    KEYMGR_SEALING_SW_BINDING_3,
    KEYMGR_SEALING_SW_BINDING_4,
    KEYMGR_SEALING_SW_BINDING_5,
    KEYMGR_SEALING_SW_BINDING_6,
    KEYMGR_SEALING_SW_BINDING_7,
    KEYMGR_ATTEST_SW_BINDING_0,
    KEYMGR_ATTEST_SW_BINDING_1,
    KEYMGR_ATTEST_SW_BINDING_2,
    KEYMGR_ATTEST_SW_BINDING_3,
    KEYMGR_ATTEST_SW_BINDING_4,
    KEYMGR_ATTEST_SW_BINDING_5,
    KEYMGR_ATTEST_SW_BINDING_6,
    KEYMGR_ATTEST_SW_BINDING_7,
    KEYMGR_SALT_0,
    KEYMGR_SALT_1,
    KEYMGR_SALT_2,
    KEYMGR_SALT_3,
    KEYMGR_SALT_4,
    KEYMGR_SALT_5,
    KEYMGR_SALT_6,
    KEYMGR_SALT_7,
    KEYMGR_KEY_VERSION,
    KEYMGR_MAX_CREATOR_KEY_VER_REGWEN,
    KEYMGR_MAX_CREATOR_KEY_VER_SHADOWED,
    KEYMGR_MAX_OWNER_INT_KEY_VER_REGWEN,
    KEYMGR_MAX_OWNER_INT_KEY_VER_SHADOWED,
    KEYMGR_MAX_OWNER_KEY_VER_REGWEN,
    KEYMGR_MAX_OWNER_KEY_VER_SHADOWED,
    KEYMGR_SW_SHARE0_OUTPUT_0,
    KEYMGR_SW_SHARE0_OUTPUT_1,
    KEYMGR_SW_SHARE0_OUTPUT_2,
    KEYMGR_SW_SHARE0_OUTPUT_3,
    KEYMGR_SW_SHARE0_OUTPUT_4,
    KEYMGR_SW_SHARE0_OUTPUT_5,
    KEYMGR_SW_SHARE0_OUTPUT_6,
    KEYMGR_SW_SHARE0_OUTPUT_7,
    KEYMGR_SW_SHARE1_OUTPUT_0,
    KEYMGR_SW_SHARE1_OUTPUT_1,
    KEYMGR_SW_SHARE1_OUTPUT_2,
    KEYMGR_SW_SHARE1_OUTPUT_3,
    KEYMGR_SW_SHARE1_OUTPUT_4,
    KEYMGR_SW_SHARE1_OUTPUT_5,
    KEYMGR_SW_SHARE1_OUTPUT_6,
    KEYMGR_SW_SHARE1_OUTPUT_7,
    KEYMGR_WORKING_STATE,
    KEYMGR_OP_STATUS,
    KEYMGR_ERR_CODE,
    KEYMGR_FAULT_STATUS,
    KEYMGR_DEBUG
  } keymgr_id_e;
  
  parameter logic [3:0] KEYMGR_PERMIT [63] = '{
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 0011, 
    4'b 0001, 
    4'b 0001, 
    4'b 0011, 
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
    4'b 0001, 
    4'b 1111, 
    4'b 0001, 
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
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 0011, 
    4'b 0001  
  };
endpackage

module TopModule
  import ascon_reg_pkg::*;
  import ascon_pkg::*;
#(
  parameter logic [NumAlerts-1:0] AlertAsyncOn    = {NumAlerts{1'b1}},
  
  parameter int unsigned          AlertSkewCycles = 1
) (
  input clk_i,
  input rst_ni,
  input rst_shadowed_ni,
  
  output prim_mubi_pkg::mubi4_t idle_o,
   
  input  lc_ctrl_pkg::lc_tx_t lc_escalate_en_i,
  
  input  logic              clk_edn_i,
  input  logic              rst_edn_ni,
  output edn_pkg::edn_req_t edn_o,
  input  edn_pkg::edn_rsp_t edn_i,
  
  input  keymgr_pkg::hw_key_req_t keymgr_key_i,
  
  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,
  
  input  prim_alert_pkg::alert_rx_t [NumAlerts-1:0] alert_rx_i,
  output prim_alert_pkg::alert_tx_t [NumAlerts-1:0] alert_tx_o
);
  localparam int unsigned EntropyWidth = edn_pkg::ENDPOINT_BUS_WIDTH;
  
  ascon_reg2hw_t reg2hw;
  ascon_hw2reg_t hw2reg;
  logic [EntropyWidth-1:0] edn_data;
  logic                    edn_req;
  logic                    edn_ack;
  logic [NumAlerts-1:0] alert;
  logic ascon_fatal_alert;
  logic ascon_recov_alert;
  logic intg_err_alert;
  logic shadowed_storage_err;
  logic shadowed_update_err;
  ascon_reg_top u_reg (
    .clk_i,
    .rst_ni,
    .rst_shadowed_ni,
    .tl_i,
    .tl_o,
    .reg2hw (reg2hw),
    .hw2reg (hw2reg),
    .intg_err_o(intg_err_alert),
    .shadowed_storage_err_o(shadowed_storage_err),
    .shadowed_update_err_o (shadowed_update_err)
  );
  ascon_core ascon_core (
    .clk_i (clk_i),
    .rst_ni(rst_ni),
    .lc_escalate_en_i(lc_escalate_en_i),
    .alert_recov_o(ascon_recov_alert),
    .alert_fatal_o(ascon_fatal_alert),
    .error_recov_i(shadowed_update_err),
    .error_fatal_i(alert[1]),
    .keymgr_key_i,
    .reg2hw(reg2hw),
    .hw2reg(hw2reg),
    .idle_o(idle_o)
  );
  
  prim_sync_reqack_data #(
    .Width(EntropyWidth),
    .DataSrc2Dst(1'b0),
    .DataReg(1'b0)
  ) u_prim_sync_reqack_data (
    .clk_src_i  ( clk_i         ),
    .rst_src_ni ( rst_ni        ),
    .clk_dst_i  ( clk_edn_i     ),
    .rst_dst_ni ( rst_edn_ni    ),
    .req_chk_i  ( 1'b1          ),
    .src_req_i  ( edn_req       ),
    .src_ack_o  ( edn_ack       ),
    .dst_req_o  ( edn_o.edn_req ),
    .dst_ack_i  ( edn_i.edn_ack ),
    .data_i     ( edn_i.edn_bus ),
    .data_o     ( edn_data      )
  );
  
  logic                      unused_edn_fips;
  assign unused_edn_fips = edn_i.edn_fips;
  
  logic   [EntropyWidth-1:0] unused_edn_data;
  logic                      unused_edn_ack;
  assign unused_edn_data = edn_data;
  assign edn_req = 1'b0;
  assign unused_edn_ack = edn_ack;
  
  assign alert[1] = ascon_fatal_alert | intg_err_alert |shadowed_storage_err;
  assign alert[0] = ascon_recov_alert | shadowed_update_err;
  logic [NumAlerts-1:0] alert_test;
  assign alert_test = {
    reg2hw.alert_test.fatal_fault.q &
    reg2hw.alert_test.fatal_fault.qe,
    reg2hw.alert_test.recov_ctrl_update_err.q &
    reg2hw.alert_test.recov_ctrl_update_err.qe
  };
  for (genvar i = 0; i < NumAlerts; i++) begin : gen_alert_tx
    prim_alert_sender #(
      .AsyncOn(AlertAsyncOn[i]),
      .SkewCycles(AlertSkewCycles),
      .IsFatal(i)
    ) u_prim_alert_sender (
      .clk_i,
      .rst_ni,
      .alert_test_i  ( alert_test[i] ),
      .alert_req_i   ( alert[i]      ),
      .alert_ack_o   (               ),
      .alert_state_o (               ),
      .alert_rx_i    ( alert_rx_i[i] ),
      .alert_tx_o    ( alert_tx_o[i] )
    );
  end
endmodule

module ascon_core
  import ascon_reg_pkg::*;
  import ascon_pkg::*;
(
  input clk_i,
  input rst_ni,
  
  input  lc_ctrl_pkg::lc_tx_t lc_escalate_en_i,
  
  output logic alert_recov_o,
  output logic alert_fatal_o,
  
  input logic error_recov_i,
  input logic error_fatal_i,
  
  input keymgr_pkg::hw_key_req_t keymgr_key_i,
  
  input  ascon_reg2hw_t reg2hw,
  output ascon_hw2reg_t hw2reg,
  output prim_mubi_pkg::mubi4_t idle_o
);
  
  logic [3:0][31:0] data_share0_in_d;
  logic [3:0][31:0] data_share0_in_q;
  logic [3:0]       data_share0_in_new_d, data_share0_in_new_q;
  logic             data_share0_in_new;
  logic             data_share0_in_load;
  logic [3:0][31:0] data_share1_in_d;
  logic [3:0][31:0] data_share1_in_q;
  logic [3:0]       data_share1_in_new_d, data_share1_in_new_q;
  logic             data_share1_in_new;
  logic             data_share1_in_load;
  logic [3:0][31:0] tag_in_q;
  logic [3:0]       tag_in_new_d, tag_in_new_q;
  logic             tag_in_new;
  logic             tag_in_load;
  logic [3:0][31:0] nonce_share0_in_d;
  logic [3:0][31:0] nonce_share0_in_q;
  logic [3:0]       nonce_share0_in_new_d, nonce_share0_in_new_q;
  logic             nonce_share0_in_new;
  logic             nonce_share0_in_load;
  logic [3:0][31:0] nonce_share1_in_d;
  logic [3:0][31:0] nonce_share1_in_q;
  logic [3:0]       nonce_share1_in_new_d, nonce_share1_in_new_q;
  logic             nonce_share1_in_new;
  logic             nonce_share1_in_load;
  logic [3:0][31:0] key_share0_in_d;
  logic [3:0][31:0] key_share0_in_q;
  logic [3:0]       key_share0_in_new_d, key_share0_in_new_q;
  logic             key_share0_in_new;
  logic             key_share0_in_load;
  logic [3:0][31:0] key_share1_in_d;
  logic [3:0][31:0] key_share1_in_q;
  logic [3:0]       key_share1_in_new_d, key_share1_in_new_q;
  logic             key_share1_in_new;
  logic             key_share1_in_load;
  logic force_data_overwrite;
  logic manual_start_trigger;
  logic sideload_key;
  logic start, start_ok, wipe;
  logic masked_ad_input;
  logic masked_msg_input;
  logic [4:0] valid_bytes;
  prim_mubi_pkg::mubi4_t no_ad;
  prim_mubi_pkg::mubi4_t no_msg;
  data_type_in_e data_type_last;
  data_type_in_e data_type_start;
  prim_ascon_pkg::duplex_op_e      operation;
  prim_ascon_pkg::duplex_variant_e variant;
  logic [127:0]     msg_out;
  logic [3:0][31:0] msg_out_d;
  logic [3:0][31:0] msg_out_q;
  logic             msg_out_valid;
  logic             msg_out_we;
  logic [3:0][31:0] unused_msg_out_q;
  logic [3:0]       msg_out_read_d, msg_out_read_q;
  logic             msg_out_read;
  logic             msg_out_ready;
  logic [127:0]     tag_out;
  logic [3:0][31:0] tag_out_d;
  logic [3:0][31:0] tag_out_q;
  logic             tag_out_valid;
  logic             tag_out_we;
  logic [3:0][31:0] unused_tag_out_q;
  logic [3:0]       tag_out_read_d, tag_out_read_q;
  logic             tag_out_read;
  logic             tag_out_ready;
  prim_mubi_pkg::mubi4_t duplex_idle;
  assign idle_o = duplex_idle;
  logic duplex_done;
  logic ascon_error;
  logic duplex_fatal_error;
  assign alert_fatal_o = duplex_fatal_error;
  lc_ctrl_pkg::lc_tx_t      unused_lc_escalate_en_i;
  keymgr_pkg::hw_key_req_t  unused_keymgr_key_i;
  prim_mubi_pkg::mubi4_t tag_match;
  prim_mubi_pkg::mubi4_t tag_calculated;
  
  logic  unused_sideload_key;
  assign unused_sideload_key = sideload_key;
  assign unused_keymgr_key_i = keymgr_key_i;
  
  
  logic  unused_masked_msg_input;
  logic  unused_masked_ad_input;
  assign unused_masked_ad_input  = masked_ad_input;
  assign unused_masked_msg_input = masked_msg_input;
  
  assign unused_lc_escalate_en_i = lc_escalate_en_i;
  
  for (genvar i = 0; i < NumRegsKey; i++) begin : gen_hw_ext_key_regs
    
    assign key_share0_in_d[i] = reg2hw.key_share0[i].q;
    assign key_share1_in_d[i] = reg2hw.key_share1[i].q;
    
    always_ff @(posedge clk_i or negedge rst_ni) begin : input_reg_key_share0
      if (!rst_ni) begin
        key_share0_in_q[i] <= '{default: '0};
      end else if (reg2hw.key_share0[i].qe) begin
        key_share0_in_q[i] <= key_share0_in_d[i];
      end
    end
    assign hw2reg.key_share0[i].d = '0;
    always_ff @(posedge clk_i or negedge rst_ni) begin : input_reg_key_share1
      if (!rst_ni) begin
        key_share1_in_q[i] <= '{default: '0};
      end else if (reg2hw.key_share1[i].qe) begin
        key_share1_in_q[i] <= key_share1_in_d[i];
      end
    end
    assign hw2reg.key_share1[i].d = '0;
  end
  for (genvar i = 0; i < NumRegsData; i++) begin : gen_hw_ext_data_regs
    
    assign data_share0_in_d[i] = reg2hw.data_in_share0[i].q;
    assign data_share1_in_d[i] = reg2hw.data_in_share1[i].q;
    
    always_ff @(posedge clk_i or negedge rst_ni) begin : input_data_share0
      if (!rst_ni) begin
        data_share0_in_q[i] <= '{default: '0};
      end else if (reg2hw.data_in_share0[i].qe) begin
        data_share0_in_q[i] <= data_share0_in_d[i];
      end
    end
    assign hw2reg.data_in_share0[i].d = '0;
    always_ff @(posedge clk_i or negedge rst_ni) begin : input_data_share1
      if (!rst_ni) begin
        data_share1_in_q[i] <= '{default: '0};
      end else if (reg2hw.data_in_share1[i].qe) begin
        data_share1_in_q[i] <= data_share1_in_d[i];
      end
    end
    assign hw2reg.data_in_share1[i].d = '0;
  end
  for (genvar i = 0; i < NumRegsNonce; i++) begin : gen_hw_ext_nonce_regs
    
    assign nonce_share0_in_d[i] = reg2hw.nonce_share0[i].q;
    assign nonce_share1_in_d[i] = reg2hw.nonce_share1[i].q;
    
    always_ff @(posedge clk_i or negedge rst_ni) begin : input_reg_nonce_share0
      if (!rst_ni) begin
        nonce_share0_in_q[i] <= '{default: '0};
      end else if (reg2hw.nonce_share0[i].qe) begin
        nonce_share0_in_q[i] <= nonce_share0_in_d[i];
      end
    end
    assign hw2reg.nonce_share0[i].d = '0;
    always_ff @(posedge clk_i or negedge rst_ni) begin : input_reg_nonce_share1
      if (!rst_ni) begin
        nonce_share1_in_q[i] <= '{default: '0};
      end else if (reg2hw.nonce_share1[i].qe) begin
        nonce_share1_in_q[i] <= nonce_share1_in_d[i];
      end
    end
    assign hw2reg.nonce_share1[i].d = '0;
  end
  
  for (genvar i = 0; i < NumRegsData; i++) begin : gen_hw_ext_data_output_regs
    always_ff @(posedge clk_i or negedge rst_ni) begin : reg_msg_out
      if (!rst_ni) begin
        msg_out_q[i] <= '{default: '0};
      end else if (msg_out_we) begin
        msg_out_q[i] <= msg_out_d[i];
      end
    end
    assign unused_msg_out_q[i] = reg2hw.msg_out[i].q;
    
    assign hw2reg.msg_out[i].d = msg_out_q[i];
  end
  for (genvar i = 0; i < NumRegsTag; i++) begin : gen_hw_ext_tag_output_regs
    always_ff @(posedge clk_i or negedge rst_ni) begin : reg_tag_out
      if (!rst_ni) begin
        tag_out_q[i] <= '{default: '0};
      end else if (tag_out_we) begin
        tag_out_q[i] <= tag_out_d[i];
      end
    end
    assign unused_tag_out_q[i] = reg2hw.tag_out[i].q;
    
    assign hw2reg.tag_out[i].d = tag_out_q[i];
  end
  
  assign operation            = reg2hw.ctrl_shadowed.operation.q;
  assign variant              = reg2hw.ctrl_shadowed.ascon_variant.q;
  assign sideload_key         = reg2hw.ctrl_shadowed.sideload_key.q;
  assign masked_msg_input     = reg2hw.ctrl_shadowed.masked_msg_input.q;
  assign masked_ad_input      = reg2hw.ctrl_shadowed.masked_ad_input.q;
  
  assign force_data_overwrite = reg2hw.ctrl_aux_shadowed.force_data_overwrite.q;
  assign manual_start_trigger = reg2hw.ctrl_aux_shadowed.manual_start_trigger.q;
  
  assign valid_bytes          = reg2hw.block_ctrl_shadowed.valid_bytes.q;
  assign data_type_last       = reg2hw.block_ctrl_shadowed.data_type_last.q;
  assign data_type_start      = reg2hw.block_ctrl_shadowed.data_type_start.q;
  logic no_msg_mubi4invalid;
  logic no_ad_mubi4invalid;
  always_comb begin : sanitize_mubi_reg
  
  
  
    if(prim_mubi_pkg::mubi4_test_invalid(reg2hw.ctrl_shadowed.no_ad.q)) begin
      no_ad_mubi4invalid = 1'b1;
      no_ad              = prim_mubi_pkg::MuBi4False;
    end else begin
      no_ad_mubi4invalid = 1'b0;
      no_ad              = reg2hw.ctrl_shadowed.no_ad.q;
    end
    if(prim_mubi_pkg::mubi4_test_invalid(reg2hw.ctrl_shadowed.no_msg.q)) begin
      no_msg_mubi4invalid = 1'b1;
      no_msg              = prim_mubi_pkg::MuBi4True;
    end else begin
      no_msg_mubi4invalid = 1'b0;
      no_msg              = reg2hw.ctrl_shadowed.no_msg.q;
    end
  end
  assign alert_recov_o = no_ad_mubi4invalid | no_msg_mubi4invalid;
  
  assign start                = reg2hw.trigger.start.q;
  assign wipe                 = reg2hw.trigger.wipe.q;
  
  assign hw2reg.trigger.start.d  = 1'b0;
  assign hw2reg.trigger.start.de = 1'b1;
  
  assign hw2reg.trigger.wipe.d  = 1'b0;
  assign hw2reg.trigger.wipe.de = 1'b1;
  logic  unused_wipe;
  assign unused_wipe = wipe;
  
  logic unused_manual_start_trigger;
  assign unused_manual_start_trigger = manual_start_trigger;
  
  logic unused_force_data_overwrite;
  assign unused_force_data_overwrite = force_data_overwrite;
  
  assign hw2reg.status.idle.d  = prim_mubi_pkg::mubi4_test_true_strict(duplex_idle);
  assign hw2reg.status.idle.de = 1'b1;
  assign hw2reg.status.ascon_error.d  = ascon_error;
  assign hw2reg.status.ascon_error.de = 1'b1;
  assign hw2reg.status.alert_recov_ctrl_update_err.d  = error_recov_i;
  assign hw2reg.status.alert_recov_ctrl_update_err.de = 1'b1;
  assign hw2reg.status.alert_fatal_fault.d  = error_fatal_i;
  assign hw2reg.status.alert_fatal_fault.de = 1'b1;
  
  assign hw2reg.status.stall.d  = 1'b0;
  assign hw2reg.status.stall.de = 1'b1;
  assign hw2reg.status.wait_edn.d  = 1'b0;
  assign hw2reg.status.wait_edn.de = 1'b1;
  logic  data_in_valid;
  assign data_in_valid = data_share1_in_new & data_share0_in_new;
  logic  data_in_ready;
  logic  data_in_read;
  assign data_in_read = data_in_ready & data_in_valid;
  assign data_share1_in_load = data_in_read;
  assign data_share0_in_load = data_in_read;
  logic msg_out_reg_valid;
  logic tag_out_reg_valid;
  always_ff @(posedge clk_i or negedge rst_ni) begin : track_output_status
    if (!rst_ni) begin
      msg_out_reg_valid <= 1'b0;
      tag_out_reg_valid <= 1'b0;
    end else begin
      
      
      
      if (msg_out_we) begin
        msg_out_reg_valid <= 1'b1;
      end else if (data_in_read) begin
        msg_out_reg_valid <= 1'b0;
      end
      
      
      if (tag_out_we) begin
        tag_out_reg_valid <= 1'b1;
      end else if (tag_out_read) begin
        tag_out_reg_valid <= 1'b0;
      end
    end
  end
  
  
  assign hw2reg.output_valid.msg_valid.d  = msg_out_reg_valid;
  assign hw2reg.output_valid.msg_valid.de = 1'b1;
  assign hw2reg.output_valid.tag_valid.d  = tag_out_reg_valid;
  assign hw2reg.output_valid.tag_valid.de = 1'b1;
  
  prim_ascon_pkg::duplex_fsm_state_e duplex_fsm_state;
  assign hw2reg.fsm_state.d  = {{(32-prim_ascon_pkg::AsconDuplexFSMStateWidth){1'b0}},
                                duplex_fsm_state};
  logic [31:0] unused_fsm_state_q;
  logic        unused_fsm_state_qe;
  assign unused_fsm_state_q  = reg2hw.fsm_state.q;
  assign unused_fsm_state_qe = reg2hw.fsm_state.qe;
  
  
  
  assign key_share0_in_new_d = key_share0_in_load ? '0 : key_share0_in_new_q |
      {reg2hw.key_share0[3].qe, reg2hw.key_share0[2].qe,
       reg2hw.key_share0[1].qe, reg2hw.key_share0[0].qe};
  assign key_share0_in_new = &key_share0_in_new_q;
  assign key_share1_in_new_d = key_share1_in_load ? '0 : key_share1_in_new_q |
      {reg2hw.key_share1[3].qe, reg2hw.key_share1[2].qe,
       reg2hw.key_share1[1].qe, reg2hw.key_share1[0].qe};
  assign key_share1_in_new = &key_share1_in_new_q;
  assign nonce_share0_in_new_d = nonce_share0_in_load ? '0 : nonce_share0_in_new_q |
      {reg2hw.nonce_share0[3].qe, reg2hw.nonce_share0[2].qe,
       reg2hw.nonce_share0[1].qe, reg2hw.nonce_share0[0].qe};
  assign nonce_share0_in_new = &nonce_share0_in_new_q;
  assign nonce_share1_in_new_d = nonce_share1_in_load ? '0 : nonce_share1_in_new_q |
      {reg2hw.nonce_share1[3].qe, reg2hw.nonce_share1[2].qe,
       reg2hw.nonce_share1[1].qe, reg2hw.nonce_share1[0].qe};
  assign nonce_share1_in_new = &nonce_share1_in_new_q;
  assign data_share0_in_new_d = data_share0_in_load ? '0 : data_share0_in_new_q |
      {reg2hw.data_in_share0[3].qe, reg2hw.data_in_share0[2].qe,
       reg2hw.data_in_share0[1].qe, reg2hw.data_in_share0[0].qe};
  assign data_share0_in_new = &data_share0_in_new_q;
  assign data_share1_in_new_d = data_share1_in_load ? '0 : data_share1_in_new_q |
      {reg2hw.data_in_share1[3].qe, reg2hw.data_in_share1[2].qe,
       reg2hw.data_in_share1[1].qe, reg2hw.data_in_share1[0].qe};
  assign data_share1_in_new = &data_share1_in_new_q;
  assign tag_in_new_d = tag_in_load ? '0 : tag_in_new_q |
      {reg2hw.tag_in[3].qe, reg2hw.tag_in[2].qe, reg2hw.tag_in[1].qe, reg2hw.tag_in[0].qe};
  assign tag_in_new = &tag_in_new_d;
  assign msg_out_read_d = msg_out_we ? '0 : msg_out_read_q |
      {reg2hw.msg_out[3].re, reg2hw.msg_out[2].re, reg2hw.msg_out[1].re, reg2hw.msg_out[0].re};
  assign msg_out_read = &msg_out_read_q;
  assign tag_out_read_d = tag_out_we ? '0 : tag_out_read_q |
      {reg2hw.tag_out[3].re, reg2hw.tag_out[2].re, reg2hw.tag_out[1].re, reg2hw.tag_out[0].re};
  assign tag_out_read = &tag_out_read_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin : reg_edge_detection
    if (!rst_ni) begin
      key_share0_in_new_q   <= '0;
      key_share1_in_new_q   <= '0;
      nonce_share0_in_new_q <= '0;
      nonce_share1_in_new_q <= '0;
      data_share0_in_new_q  <= '0;
      data_share1_in_new_q  <= '0;
      tag_in_new_q          <= '0;
      msg_out_read_q        <= '0;
      tag_out_read_q        <= '0;
    end else begin
      key_share0_in_new_q   <= key_share0_in_new_d;
      key_share1_in_new_q   <= key_share1_in_new_d;
      nonce_share0_in_new_q <= nonce_share0_in_new_d;
      nonce_share1_in_new_q <= nonce_share1_in_new_d;
      data_share0_in_new_q  <= data_share0_in_new_d;
      data_share1_in_new_q  <= data_share1_in_new_d;
      tag_in_new_q          <= tag_in_new_d;
      msg_out_read_q        <= msg_out_read_d;
      tag_out_read_q        <= tag_out_read_d;
    end
  end
  
  logic key_error, nonce_error;
  logic no_new_key, no_new_nonce;
  assign no_new_key   = !(key_share0_in_new & key_share1_in_new);
  assign key_error    = no_new_key;
  assign no_new_nonce = !(nonce_share0_in_new & nonce_share1_in_new);
  assign nonce_error  = no_new_nonce;
  
  assign start_ok = start & !(key_error | nonce_error);
  
  
  assign key_share0_in_load = start_ok;
  assign key_share1_in_load = start_ok;
  assign nonce_share0_in_load = start_ok;
  assign nonce_share1_in_load = start_ok;
    
  assign hw2reg.error.no_key.d  = key_error;
  assign hw2reg.error.no_key.de = start;
  assign hw2reg.error.no_nonce.d  = nonce_error;
  assign hw2reg.error.no_nonce.de = start;
  
  logic flag_error;
  
  assign flag_error = (prim_mubi_pkg::mubi4_test_true_strict(no_ad) &&
                      ((data_type_start == AD_IN) || (data_type_last == AD_IN))) ||
                      (prim_mubi_pkg::mubi4_test_true_strict(no_msg) &&
                      ((data_type_start == MSG_IN) || (data_type_last == MSG_IN)));
  assign hw2reg.error.flag_input_missmatch.d  = flag_error;
  assign hw2reg.error.flag_input_missmatch.de = prim_mubi_pkg::mubi4_test_false_strict(
                                                  duplex_idle);
  
  logic order_error;
  logic msg_received_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin : reg_track_msg
    if (!rst_ni) begin
      msg_received_q <= 1'b0;
    end else if (duplex_done) begin
      msg_received_q <= 1'b0;
    end else if ((data_type_start == MSG_IN) || (data_type_last == MSG_IN)) begin
      msg_received_q <= 1'b1;
    end
  end
  assign order_error = msg_received_q & ((data_type_start == AD_IN) || (data_type_last == AD_IN));
  assign hw2reg.error.wrong_order.d  = order_error;
  assign hw2reg.error.wrong_order.de = prim_mubi_pkg::mubi4_test_false_strict(duplex_idle);
  assign ascon_error = key_error | nonce_error | flag_error | order_error;
  
  
  
  
  
  
  
  
  logic track_reset_msg_q;
  logic track_reset_tag_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin : reg_track_reset
    if (!rst_ni) begin
      track_reset_msg_q <= 1'b1;
      track_reset_tag_q <= 1'b1;
    end else begin
      if (msg_out_we) begin
        track_reset_msg_q <= 1'b0;
      end
      if (tag_out_we) begin
        track_reset_tag_q <= 1'b0;
      end
    end
  end
  assign msg_out_ready = msg_out_read | track_reset_msg_q;
  
  
  assign msg_out_we = msg_out_valid & msg_out_ready;
  assign tag_out_ready = tag_out_read | track_reset_tag_q;
  
  
  
  assign tag_out_we = tag_out_valid & tag_out_ready;
  
  for (genvar i = 0; i < NumRegsTag; i++) begin : gen_tag_in_conversion
    assign tag_in_q[i] = reg2hw.tag_in[i].q;
  end
  assign tag_match = (tag_in_q == tag_out_q) ? prim_mubi_pkg::MuBi4True :
                                               prim_mubi_pkg::MuBi4False;
  
  
  
  
  assign tag_calculated = (tag_in_new && !tag_out_ready) ? prim_mubi_pkg::MuBi4True :
                                                           prim_mubi_pkg::MuBi4False;
  always_comb begin : tag_recoding
    
    
    
    if (prim_mubi_pkg::mubi4_test_true_strict(tag_calculated)) begin
      if (prim_mubi_pkg::mubi4_test_true_strict(tag_match)) begin
        hw2reg.output_valid.tag_comparison_valid.d  = 2'b01;
      end else begin
        hw2reg.output_valid.tag_comparison_valid.d  = 2'b10;
      end
    end else begin
      hw2reg.output_valid.tag_comparison_valid.d  = 2'b00;
    end
  end
  assign hw2reg.output_valid.tag_comparison_valid.de = 1'b1;
  
  
  
  assign tag_in_load = tag_out_read | start_ok;
  
  logic [3:0][31:0] key_in;
  logic [3:0][31:0] data_in;
  logic [3:0][31:0] nonce_in;
  for (genvar i = 0; i < 4; i++) begin : gen_combine_shares
    assign nonce_in[i] = nonce_share0_in_q[i] ^ nonce_share1_in_q[i];
    assign key_in[i] = key_share0_in_q[i] ^ key_share1_in_q[i];
    assign data_in[i] = data_share0_in_q[i] ^ data_share1_in_q[i];
  end
  prim_mubi_pkg::mubi4_t last_ad_block;
  prim_mubi_pkg::mubi4_t last_msg_block;
  assign last_ad_block  = (data_type_last ==  AD_IN) ? prim_mubi_pkg::MuBi4True :
                                                       prim_mubi_pkg::MuBi4False;
  assign last_msg_block = (data_type_last == MSG_IN) ? prim_mubi_pkg::MuBi4True :
                                                       prim_mubi_pkg::MuBi4False;
  assign msg_out_d = swap_endianess_byte(msg_out);
  assign tag_out_d = swap_endianess_byte(tag_out);
  
  prim_ascon_duplex ascon_duplex (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .ascon_variant(variant),
    .ascon_operation(operation),
    .start_i(start_ok),
    .done_o(duplex_done),
    .idle_o(duplex_idle),
    
    
    .no_ad_i(no_ad),
    .no_msg_i(no_msg),
    .key_i(swap_endianess_byte(key_in)),
    .nonce_i(swap_endianess_byte(nonce_in)),
    
    .data_in_i(swap_endianess_byte(data_in)),
    .data_in_valid_bytes_i(valid_bytes),
    .last_block_ad_i(last_ad_block),
    .last_block_msg_i(last_msg_block),
    .data_in_valid_i(data_in_valid),
    .data_in_ready_o(data_in_ready),
    
    .data_out_o(msg_out),
    .data_out_ready_i(msg_out_ready),
    .data_out_valid_o(msg_out_valid),
    .tag_out_o(tag_out),
    .tag_out_valid_o(tag_out_valid),
    .fsm_state_o(duplex_fsm_state),
    .err_o(duplex_fatal_error)
  );
  
  logic unused_alert_signals;
  assign unused_alert_signals = ^reg2hw.alert_test;
endmodule

package ascon_pkg;
typedef enum logic [11:0] {
  MSG_IN  = {prim_mubi_pkg::MuBi4True, prim_mubi_pkg::MuBi4False, prim_mubi_pkg::MuBi4False},
  AD_IN   = {prim_mubi_pkg::MuBi4False, prim_mubi_pkg::MuBi4True, prim_mubi_pkg::MuBi4False},
  TAG_IN  = {prim_mubi_pkg::MuBi4False, prim_mubi_pkg::MuBi4False, prim_mubi_pkg::MuBi4True},
  NONE_IN = {prim_mubi_pkg::MuBi4False, prim_mubi_pkg::MuBi4False, prim_mubi_pkg::MuBi4False}
} data_type_in_e;
function automatic logic [127:0] swap_endianess_byte(logic [127:0] vector_in);
  logic [127:0] vector_out;
  
  
  
  
  
  
  
  
  
  
  
  
  
  vector_out[127:120] = vector_in[7:0];
  vector_out[119:112] = vector_in[15:8];
  vector_out[111:104] = vector_in[23:16];
  vector_out[103:96]  = vector_in[31:24];
  vector_out[95:88]   = vector_in[39:32];
  vector_out[87:80]   = vector_in[47:40];
  vector_out[79:72]   = vector_in[55:48];
  vector_out[71:64]   = vector_in[63:56];
  vector_out[63:56]   = vector_in[71:64];
  vector_out[55:48]   = vector_in[79:72];
  vector_out[47:40]   = vector_in[87:80];
  vector_out[39:32]   = vector_in[95:88];
  vector_out[31:24]   = vector_in[103:96];
  vector_out[23:16]   = vector_in[111:104];
  vector_out[15:8]    = vector_in[119:112];
  vector_out[7:0]     = vector_in[127:120];
  return vector_out;
endfunction
endpackage

package ascon_reg_pkg;
  
  parameter int NumRegsKey = 4;
  parameter int NumRegsNonce = 4;
  parameter int NumRegsData = 4;
  parameter int NumRegsTag = 4;
  parameter int NumAlerts = 2;
  
  parameter int BlockAw = 8;
  
  
  
  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } fatal_fault;
    struct packed {
      logic        q;
      logic        qe;
    } recov_ctrl_update_err;
  } ascon_reg2hw_alert_test_reg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } ascon_reg2hw_key_share0_mreg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } ascon_reg2hw_key_share1_mreg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } ascon_reg2hw_nonce_share0_mreg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } ascon_reg2hw_nonce_share1_mreg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } ascon_reg2hw_data_in_share0_mreg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } ascon_reg2hw_data_in_share1_mreg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } ascon_reg2hw_tag_in_mreg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        re;
  } ascon_reg2hw_msg_out_mreg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        re;
  } ascon_reg2hw_tag_out_mreg_t;
  typedef struct packed {
    struct packed {
      logic [3:0]  q;
    } no_ad;
    struct packed {
      logic [3:0]  q;
    } no_msg;
    struct packed {
      logic        q;
    } masked_msg_input;
    struct packed {
      logic        q;
    } masked_ad_input;
    struct packed {
      logic        q;
    } sideload_key;
    struct packed {
      logic [1:0]  q;
    } ascon_variant;
    struct packed {
      logic [2:0]  q;
    } operation;
  } ascon_reg2hw_ctrl_shadowed_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } force_data_overwrite;
    struct packed {
      logic        q;
    } manual_start_trigger;
  } ascon_reg2hw_ctrl_aux_shadowed_reg_t;
  typedef struct packed {
    struct packed {
      logic [4:0]  q;
    } valid_bytes;
    struct packed {
      logic [11:0] q;
    } data_type_last;
    struct packed {
      logic [11:0] q;
    } data_type_start;
  } ascon_reg2hw_block_ctrl_shadowed_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } wipe;
    struct packed {
      logic        q;
    } start;
  } ascon_reg2hw_trigger_reg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } ascon_reg2hw_fsm_state_reg_t;
  typedef struct packed {
    logic [31:0] d;
  } ascon_hw2reg_key_share0_mreg_t;
  typedef struct packed {
    logic [31:0] d;
  } ascon_hw2reg_key_share1_mreg_t;
  typedef struct packed {
    logic [31:0] d;
  } ascon_hw2reg_nonce_share0_mreg_t;
  typedef struct packed {
    logic [31:0] d;
  } ascon_hw2reg_nonce_share1_mreg_t;
  typedef struct packed {
    logic [31:0] d;
  } ascon_hw2reg_data_in_share0_mreg_t;
  typedef struct packed {
    logic [31:0] d;
  } ascon_hw2reg_data_in_share1_mreg_t;
  typedef struct packed {
    logic [31:0] d;
  } ascon_hw2reg_msg_out_mreg_t;
  typedef struct packed {
    logic [31:0] d;
  } ascon_hw2reg_tag_out_mreg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } start;
    struct packed {
      logic        d;
      logic        de;
    } wipe;
  } ascon_hw2reg_trigger_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } idle;
    struct packed {
      logic        d;
      logic        de;
    } stall;
    struct packed {
      logic        d;
      logic        de;
    } wait_edn;
    struct packed {
      logic        d;
      logic        de;
    } ascon_error;
    struct packed {
      logic        d;
      logic        de;
    } alert_recov_ctrl_update_err;
    struct packed {
      logic        d;
      logic        de;
    } alert_fatal_fault;
  } ascon_hw2reg_status_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } msg_valid;
    struct packed {
      logic        d;
      logic        de;
    } tag_valid;
    struct packed {
      logic [1:0]  d;
      logic        de;
    } tag_comparison_valid;
  } ascon_hw2reg_output_valid_reg_t;
  typedef struct packed {
    logic [31:0] d;
  } ascon_hw2reg_fsm_state_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } no_key;
    struct packed {
      logic        d;
      logic        de;
    } no_nonce;
    struct packed {
      logic        d;
      logic        de;
    } wrong_order;
    struct packed {
      logic        d;
      logic        de;
    } flag_input_missmatch;
  } ascon_hw2reg_error_reg_t;
  
  typedef struct packed {
    ascon_reg2hw_alert_test_reg_t alert_test; 
    ascon_reg2hw_key_share0_mreg_t [3:0] key_share0; 
    ascon_reg2hw_key_share1_mreg_t [3:0] key_share1; 
    ascon_reg2hw_nonce_share0_mreg_t [3:0] nonce_share0; 
    ascon_reg2hw_nonce_share1_mreg_t [3:0] nonce_share1; 
    ascon_reg2hw_data_in_share0_mreg_t [3:0] data_in_share0; 
    ascon_reg2hw_data_in_share1_mreg_t [3:0] data_in_share1; 
    ascon_reg2hw_tag_in_mreg_t [3:0] tag_in; 
    ascon_reg2hw_msg_out_mreg_t [3:0] msg_out; 
    ascon_reg2hw_tag_out_mreg_t [3:0] tag_out; 
    ascon_reg2hw_ctrl_shadowed_reg_t ctrl_shadowed; 
    ascon_reg2hw_ctrl_aux_shadowed_reg_t ctrl_aux_shadowed; 
    ascon_reg2hw_block_ctrl_shadowed_reg_t block_ctrl_shadowed; 
    ascon_reg2hw_trigger_reg_t trigger; 
    ascon_reg2hw_fsm_state_reg_t fsm_state; 
  } ascon_reg2hw_t;
  
  typedef struct packed {
    ascon_hw2reg_key_share0_mreg_t [3:0] key_share0; 
    ascon_hw2reg_key_share1_mreg_t [3:0] key_share1; 
    ascon_hw2reg_nonce_share0_mreg_t [3:0] nonce_share0; 
    ascon_hw2reg_nonce_share1_mreg_t [3:0] nonce_share1; 
    ascon_hw2reg_data_in_share0_mreg_t [3:0] data_in_share0; 
    ascon_hw2reg_data_in_share1_mreg_t [3:0] data_in_share1; 
    ascon_hw2reg_msg_out_mreg_t [3:0] msg_out; 
    ascon_hw2reg_tag_out_mreg_t [3:0] tag_out; 
    ascon_hw2reg_trigger_reg_t trigger; 
    ascon_hw2reg_status_reg_t status; 
    ascon_hw2reg_output_valid_reg_t output_valid; 
    ascon_hw2reg_fsm_state_reg_t fsm_state; 
    ascon_hw2reg_error_reg_t error; 
  } ascon_hw2reg_t;
  
  parameter logic [BlockAw-1:0] ASCON_ALERT_TEST_OFFSET = 8'h 0;
  parameter logic [BlockAw-1:0] ASCON_KEY_SHARE0_0_OFFSET = 8'h 4;
  parameter logic [BlockAw-1:0] ASCON_KEY_SHARE0_1_OFFSET = 8'h 8;
  parameter logic [BlockAw-1:0] ASCON_KEY_SHARE0_2_OFFSET = 8'h c;
  parameter logic [BlockAw-1:0] ASCON_KEY_SHARE0_3_OFFSET = 8'h 10;
  parameter logic [BlockAw-1:0] ASCON_KEY_SHARE1_0_OFFSET = 8'h 14;
  parameter logic [BlockAw-1:0] ASCON_KEY_SHARE1_1_OFFSET = 8'h 18;
  parameter logic [BlockAw-1:0] ASCON_KEY_SHARE1_2_OFFSET = 8'h 1c;
  parameter logic [BlockAw-1:0] ASCON_KEY_SHARE1_3_OFFSET = 8'h 20;
  parameter logic [BlockAw-1:0] ASCON_NONCE_SHARE0_0_OFFSET = 8'h 24;
  parameter logic [BlockAw-1:0] ASCON_NONCE_SHARE0_1_OFFSET = 8'h 28;
  parameter logic [BlockAw-1:0] ASCON_NONCE_SHARE0_2_OFFSET = 8'h 2c;
  parameter logic [BlockAw-1:0] ASCON_NONCE_SHARE0_3_OFFSET = 8'h 30;
  parameter logic [BlockAw-1:0] ASCON_NONCE_SHARE1_0_OFFSET = 8'h 34;
  parameter logic [BlockAw-1:0] ASCON_NONCE_SHARE1_1_OFFSET = 8'h 38;
  parameter logic [BlockAw-1:0] ASCON_NONCE_SHARE1_2_OFFSET = 8'h 3c;
  parameter logic [BlockAw-1:0] ASCON_NONCE_SHARE1_3_OFFSET = 8'h 40;
  parameter logic [BlockAw-1:0] ASCON_DATA_IN_SHARE0_0_OFFSET = 8'h 44;
  parameter logic [BlockAw-1:0] ASCON_DATA_IN_SHARE0_1_OFFSET = 8'h 48;
  parameter logic [BlockAw-1:0] ASCON_DATA_IN_SHARE0_2_OFFSET = 8'h 4c;
  parameter logic [BlockAw-1:0] ASCON_DATA_IN_SHARE0_3_OFFSET = 8'h 50;
  parameter logic [BlockAw-1:0] ASCON_DATA_IN_SHARE1_0_OFFSET = 8'h 54;
  parameter logic [BlockAw-1:0] ASCON_DATA_IN_SHARE1_1_OFFSET = 8'h 58;
  parameter logic [BlockAw-1:0] ASCON_DATA_IN_SHARE1_2_OFFSET = 8'h 5c;
  parameter logic [BlockAw-1:0] ASCON_DATA_IN_SHARE1_3_OFFSET = 8'h 60;
  parameter logic [BlockAw-1:0] ASCON_TAG_IN_0_OFFSET = 8'h 64;
  parameter logic [BlockAw-1:0] ASCON_TAG_IN_1_OFFSET = 8'h 68;
  parameter logic [BlockAw-1:0] ASCON_TAG_IN_2_OFFSET = 8'h 6c;
  parameter logic [BlockAw-1:0] ASCON_TAG_IN_3_OFFSET = 8'h 70;
  parameter logic [BlockAw-1:0] ASCON_MSG_OUT_0_OFFSET = 8'h 74;
  parameter logic [BlockAw-1:0] ASCON_MSG_OUT_1_OFFSET = 8'h 78;
  parameter logic [BlockAw-1:0] ASCON_MSG_OUT_2_OFFSET = 8'h 7c;
  parameter logic [BlockAw-1:0] ASCON_MSG_OUT_3_OFFSET = 8'h 80;
  parameter logic [BlockAw-1:0] ASCON_TAG_OUT_0_OFFSET = 8'h 84;
  parameter logic [BlockAw-1:0] ASCON_TAG_OUT_1_OFFSET = 8'h 88;
  parameter logic [BlockAw-1:0] ASCON_TAG_OUT_2_OFFSET = 8'h 8c;
  parameter logic [BlockAw-1:0] ASCON_TAG_OUT_3_OFFSET = 8'h 90;
  parameter logic [BlockAw-1:0] ASCON_CTRL_SHADOWED_OFFSET = 8'h 94;
  parameter logic [BlockAw-1:0] ASCON_CTRL_AUX_SHADOWED_OFFSET = 8'h 98;
  parameter logic [BlockAw-1:0] ASCON_CTRL_AUX_REGWEN_OFFSET = 8'h 9c;
  parameter logic [BlockAw-1:0] ASCON_BLOCK_CTRL_SHADOWED_OFFSET = 8'h a0;
  parameter logic [BlockAw-1:0] ASCON_TRIGGER_OFFSET = 8'h a4;
  parameter logic [BlockAw-1:0] ASCON_STATUS_OFFSET = 8'h a8;
  parameter logic [BlockAw-1:0] ASCON_OUTPUT_VALID_OFFSET = 8'h ac;
  parameter logic [BlockAw-1:0] ASCON_FSM_STATE_OFFSET = 8'h b0;
  parameter logic [BlockAw-1:0] ASCON_FSM_STATE_REGREN_OFFSET = 8'h b4;
  parameter logic [BlockAw-1:0] ASCON_ERROR_OFFSET = 8'h b8;
  
  parameter logic [1:0] ASCON_ALERT_TEST_RESVAL = 2'h 0;
  parameter logic [0:0] ASCON_ALERT_TEST_RECOV_CTRL_UPDATE_ERR_RESVAL = 1'h 0;
  parameter logic [0:0] ASCON_ALERT_TEST_FATAL_FAULT_RESVAL = 1'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE0_0_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE0_0_KEY_SHARE0_0_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE0_1_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE0_1_KEY_SHARE0_1_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE0_2_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE0_2_KEY_SHARE0_2_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE0_3_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE0_3_KEY_SHARE0_3_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE1_0_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE1_0_KEY_SHARE1_0_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE1_1_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE1_1_KEY_SHARE1_1_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE1_2_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE1_2_KEY_SHARE1_2_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE1_3_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_KEY_SHARE1_3_KEY_SHARE1_3_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_NONCE_SHARE0_0_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_NONCE_SHARE0_1_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_NONCE_SHARE0_2_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_NONCE_SHARE0_3_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_NONCE_SHARE1_0_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_NONCE_SHARE1_1_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_NONCE_SHARE1_2_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_NONCE_SHARE1_3_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_DATA_IN_SHARE0_0_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_DATA_IN_SHARE0_1_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_DATA_IN_SHARE0_2_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_DATA_IN_SHARE0_3_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_DATA_IN_SHARE1_0_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_DATA_IN_SHARE1_1_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_DATA_IN_SHARE1_2_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_DATA_IN_SHARE1_3_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_MSG_OUT_0_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_MSG_OUT_1_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_MSG_OUT_2_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_MSG_OUT_3_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_TAG_OUT_0_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_TAG_OUT_1_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_TAG_OUT_2_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_TAG_OUT_3_RESVAL = 32'h 0;
  parameter logic [31:0] ASCON_FSM_STATE_RESVAL = 32'h 0;
  
  typedef enum int {
    ASCON_ALERT_TEST,
    ASCON_KEY_SHARE0_0,
    ASCON_KEY_SHARE0_1,
    ASCON_KEY_SHARE0_2,
    ASCON_KEY_SHARE0_3,
    ASCON_KEY_SHARE1_0,
    ASCON_KEY_SHARE1_1,
    ASCON_KEY_SHARE1_2,
    ASCON_KEY_SHARE1_3,
    ASCON_NONCE_SHARE0_0,
    ASCON_NONCE_SHARE0_1,
    ASCON_NONCE_SHARE0_2,
    ASCON_NONCE_SHARE0_3,
    ASCON_NONCE_SHARE1_0,
    ASCON_NONCE_SHARE1_1,
    ASCON_NONCE_SHARE1_2,
    ASCON_NONCE_SHARE1_3,
    ASCON_DATA_IN_SHARE0_0,
    ASCON_DATA_IN_SHARE0_1,
    ASCON_DATA_IN_SHARE0_2,
    ASCON_DATA_IN_SHARE0_3,
    ASCON_DATA_IN_SHARE1_0,
    ASCON_DATA_IN_SHARE1_1,
    ASCON_DATA_IN_SHARE1_2,
    ASCON_DATA_IN_SHARE1_3,
    ASCON_TAG_IN_0,
    ASCON_TAG_IN_1,
    ASCON_TAG_IN_2,
    ASCON_TAG_IN_3,
    ASCON_MSG_OUT_0,
    ASCON_MSG_OUT_1,
    ASCON_MSG_OUT_2,
    ASCON_MSG_OUT_3,
    ASCON_TAG_OUT_0,
    ASCON_TAG_OUT_1,
    ASCON_TAG_OUT_2,
    ASCON_TAG_OUT_3,
    ASCON_CTRL_SHADOWED,
    ASCON_CTRL_AUX_SHADOWED,
    ASCON_CTRL_AUX_REGWEN,
    ASCON_BLOCK_CTRL_SHADOWED,
    ASCON_TRIGGER,
    ASCON_STATUS,
    ASCON_OUTPUT_VALID,
    ASCON_FSM_STATE,
    ASCON_FSM_STATE_REGREN,
    ASCON_ERROR
  } ascon_id_e;
  
  parameter logic [3:0] ASCON_PERMIT [47] = '{
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
    4'b 1111, 
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 1111, 
    4'b 0001, 
    4'b 0001  
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
module ascon_reg_top (
  input clk_i,
  input rst_ni,
  input rst_shadowed_ni,
  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,
  
  output ascon_reg_pkg::ascon_reg2hw_t reg2hw, 
  input  ascon_reg_pkg::ascon_hw2reg_t hw2reg, 
  output logic shadowed_storage_err_o,
  output logic shadowed_update_err_o,
  
  output logic intg_err_o
);
  import ascon_reg_pkg::* ;
  localparam int AW = 8;
  localparam int DW = 32;
  localparam int DBW = DW/8;                    
  
  logic           reg_we;
  logic           reg_re;
  logic [AW-1:0]  reg_addr;
  logic [DW-1:0]  reg_wdata;
  logic [DBW-1:0] reg_be;
  logic [DW-1:0]  reg_rdata;
  logic           reg_error;
  logic          addrmiss, wr_err;
  logic [DW-1:0] reg_rdata_next;
  logic reg_busy;
  tlul_pkg::tl_h2d_t tl_reg_h2d;
  tlul_pkg::tl_d2h_t tl_reg_d2h;
  
  logic intg_err;
  tlul_cmd_intg_chk u_chk (
    .tl_i(tl_i),
    .err_o(intg_err)
  );
  
  logic reg_we_err;
  logic [46:0] reg_we_check;
  prim_reg_we_check #(
    .OneHotWidth(47)
  ) u_prim_reg_we_check (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .oh_i  (reg_we_check),
    .en_i  (reg_we && !addrmiss),
    .err_o (reg_we_err)
  );
  logic err_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      err_q <= '0;
    end else if (intg_err || reg_we_err) begin
      err_q <= 1'b1;
    end
  end
  
  
  assign intg_err_o = err_q | intg_err | reg_we_err;
  
  tlul_pkg::tl_d2h_t tl_o_pre;
  tlul_rsp_intg_gen #(
    .EnableRspIntgGen(1),
    .EnableDataIntgGen(1)
  ) u_rsp_intg_gen (
    .tl_i(tl_o_pre),
    .tl_o(tl_o)
  );
  assign tl_reg_h2d = tl_i;
  assign tl_o_pre   = tl_reg_d2h;
  tlul_adapter_reg #(
    .RegAw(AW),
    .RegDw(DW),
    .EnableDataIntgGen(0)
  ) u_reg_if (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),
    .tl_i (tl_reg_h2d),
    .tl_o (tl_reg_d2h),
    .en_ifetch_i(prim_mubi_pkg::MuBi4False),
    .intg_error_o(),
    .we_o    (reg_we),
    .re_o    (reg_re),
    .addr_o  (reg_addr),
    .wdata_o (reg_wdata),
    .be_o    (reg_be),
    .busy_i  (reg_busy),
    .rdata_i (reg_rdata),
    .error_i (reg_error)
  );
  
  assign reg_rdata = reg_rdata_next ;
  assign reg_error = addrmiss | wr_err | intg_err;
  
  
  
  logic alert_test_we;
  logic alert_test_recov_ctrl_update_err_wd;
  logic alert_test_fatal_fault_wd;
  logic key_share0_0_we;
  logic [31:0] key_share0_0_wd;
  logic key_share0_1_we;
  logic [31:0] key_share0_1_wd;
  logic key_share0_2_we;
  logic [31:0] key_share0_2_wd;
  logic key_share0_3_we;
  logic [31:0] key_share0_3_wd;
  logic key_share1_0_we;
  logic [31:0] key_share1_0_wd;
  logic key_share1_1_we;
  logic [31:0] key_share1_1_wd;
  logic key_share1_2_we;
  logic [31:0] key_share1_2_wd;
  logic key_share1_3_we;
  logic [31:0] key_share1_3_wd;
  logic nonce_share0_0_we;
  logic [31:0] nonce_share0_0_wd;
  logic nonce_share0_1_we;
  logic [31:0] nonce_share0_1_wd;
  logic nonce_share0_2_we;
  logic [31:0] nonce_share0_2_wd;
  logic nonce_share0_3_we;
  logic [31:0] nonce_share0_3_wd;
  logic nonce_share1_0_we;
  logic [31:0] nonce_share1_0_wd;
  logic nonce_share1_1_we;
  logic [31:0] nonce_share1_1_wd;
  logic nonce_share1_2_we;
  logic [31:0] nonce_share1_2_wd;
  logic nonce_share1_3_we;
  logic [31:0] nonce_share1_3_wd;
  logic data_in_share0_0_we;
  logic [31:0] data_in_share0_0_wd;
  logic data_in_share0_1_we;
  logic [31:0] data_in_share0_1_wd;
  logic data_in_share0_2_we;
  logic [31:0] data_in_share0_2_wd;
  logic data_in_share0_3_we;
  logic [31:0] data_in_share0_3_wd;
  logic data_in_share1_0_we;
  logic [31:0] data_in_share1_0_wd;
  logic data_in_share1_1_we;
  logic [31:0] data_in_share1_1_wd;
  logic data_in_share1_2_we;
  logic [31:0] data_in_share1_2_wd;
  logic data_in_share1_3_we;
  logic [31:0] data_in_share1_3_wd;
  logic tag_in_0_we;
  logic [31:0] tag_in_0_wd;
  logic tag_in_1_we;
  logic [31:0] tag_in_1_wd;
  logic tag_in_2_we;
  logic [31:0] tag_in_2_wd;
  logic tag_in_3_we;
  logic [31:0] tag_in_3_wd;
  logic msg_out_0_re;
  logic [31:0] msg_out_0_qs;
  logic msg_out_1_re;
  logic [31:0] msg_out_1_qs;
  logic msg_out_2_re;
  logic [31:0] msg_out_2_qs;
  logic msg_out_3_re;
  logic [31:0] msg_out_3_qs;
  logic tag_out_0_re;
  logic [31:0] tag_out_0_qs;
  logic tag_out_1_re;
  logic [31:0] tag_out_1_qs;
  logic tag_out_2_re;
  logic [31:0] tag_out_2_qs;
  logic tag_out_3_re;
  logic [31:0] tag_out_3_qs;
  logic ctrl_shadowed_re;
  logic ctrl_shadowed_we;
  logic [2:0] ctrl_shadowed_operation_qs;
  logic [2:0] ctrl_shadowed_operation_wd;
  logic ctrl_shadowed_operation_storage_err;
  logic ctrl_shadowed_operation_update_err;
  logic [1:0] ctrl_shadowed_ascon_variant_qs;
  logic [1:0] ctrl_shadowed_ascon_variant_wd;
  logic ctrl_shadowed_ascon_variant_storage_err;
  logic ctrl_shadowed_ascon_variant_update_err;
  logic ctrl_shadowed_sideload_key_qs;
  logic ctrl_shadowed_sideload_key_wd;
  logic ctrl_shadowed_sideload_key_storage_err;
  logic ctrl_shadowed_sideload_key_update_err;
  logic ctrl_shadowed_masked_ad_input_qs;
  logic ctrl_shadowed_masked_ad_input_wd;
  logic ctrl_shadowed_masked_ad_input_storage_err;
  logic ctrl_shadowed_masked_ad_input_update_err;
  logic ctrl_shadowed_masked_msg_input_qs;
  logic ctrl_shadowed_masked_msg_input_wd;
  logic ctrl_shadowed_masked_msg_input_storage_err;
  logic ctrl_shadowed_masked_msg_input_update_err;
  logic [3:0] ctrl_shadowed_no_msg_qs;
  logic [3:0] ctrl_shadowed_no_msg_wd;
  logic ctrl_shadowed_no_msg_storage_err;
  logic ctrl_shadowed_no_msg_update_err;
  logic [3:0] ctrl_shadowed_no_ad_qs;
  logic [3:0] ctrl_shadowed_no_ad_wd;
  logic ctrl_shadowed_no_ad_storage_err;
  logic ctrl_shadowed_no_ad_update_err;
  logic ctrl_aux_shadowed_re;
  logic ctrl_aux_shadowed_we;
  logic ctrl_aux_shadowed_manual_start_trigger_qs;
  logic ctrl_aux_shadowed_manual_start_trigger_wd;
  logic ctrl_aux_shadowed_manual_start_trigger_storage_err;
  logic ctrl_aux_shadowed_manual_start_trigger_update_err;
  logic ctrl_aux_shadowed_force_data_overwrite_qs;
  logic ctrl_aux_shadowed_force_data_overwrite_wd;
  logic ctrl_aux_shadowed_force_data_overwrite_storage_err;
  logic ctrl_aux_shadowed_force_data_overwrite_update_err;
  logic ctrl_aux_regwen_we;
  logic ctrl_aux_regwen_qs;
  logic ctrl_aux_regwen_wd;
  logic block_ctrl_shadowed_re;
  logic block_ctrl_shadowed_we;
  logic [11:0] block_ctrl_shadowed_data_type_start_qs;
  logic [11:0] block_ctrl_shadowed_data_type_start_wd;
  logic block_ctrl_shadowed_data_type_start_storage_err;
  logic block_ctrl_shadowed_data_type_start_update_err;
  logic [11:0] block_ctrl_shadowed_data_type_last_qs;
  logic [11:0] block_ctrl_shadowed_data_type_last_wd;
  logic block_ctrl_shadowed_data_type_last_storage_err;
  logic block_ctrl_shadowed_data_type_last_update_err;
  logic [4:0] block_ctrl_shadowed_valid_bytes_qs;
  logic [4:0] block_ctrl_shadowed_valid_bytes_wd;
  logic block_ctrl_shadowed_valid_bytes_storage_err;
  logic block_ctrl_shadowed_valid_bytes_update_err;
  logic trigger_we;
  logic trigger_start_qs;
  logic trigger_start_wd;
  logic trigger_wipe_qs;
  logic trigger_wipe_wd;
  logic status_idle_qs;
  logic status_stall_qs;
  logic status_wait_edn_qs;
  logic status_ascon_error_qs;
  logic status_alert_recov_ctrl_update_err_qs;
  logic status_alert_fatal_fault_qs;
  logic output_valid_msg_valid_qs;
  logic output_valid_tag_valid_qs;
  logic [1:0] output_valid_tag_comparison_valid_qs;
  logic fsm_state_re;
  logic [31:0] fsm_state_qs;
  logic fsm_state_regren_we;
  logic fsm_state_regren_qs;
  logic fsm_state_regren_wd;
  logic error_no_key_qs;
  logic error_no_nonce_qs;
  logic error_wrong_order_qs;
  logic error_flag_input_missmatch_qs;
  
  
  logic alert_test_qe;
  logic [1:0] alert_test_flds_we;
  assign alert_test_qe = &alert_test_flds_we;
  
  prim_subreg_ext #(
    .DW    (1)
  ) u_alert_test_recov_ctrl_update_err (
    .re     (1'b0),
    .we     (alert_test_we),
    .wd     (alert_test_recov_ctrl_update_err_wd),
    .d      ('0),
    .qre    (),
    .qe     (alert_test_flds_we[0]),
    .q      (reg2hw.alert_test.recov_ctrl_update_err.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.alert_test.recov_ctrl_update_err.qe = alert_test_qe;
  
  prim_subreg_ext #(
    .DW    (1)
  ) u_alert_test_fatal_fault (
    .re     (1'b0),
    .we     (alert_test_we),
    .wd     (alert_test_fatal_fault_wd),
    .d      ('0),
    .qre    (),
    .qe     (alert_test_flds_we[1]),
    .q      (reg2hw.alert_test.fatal_fault.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.alert_test.fatal_fault.qe = alert_test_qe;
  
  
  logic key_share0_0_qe;
  logic [0:0] key_share0_0_flds_we;
  assign key_share0_0_qe = &key_share0_0_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share0_0 (
    .re     (1'b0),
    .we     (key_share0_0_we),
    .wd     (key_share0_0_wd),
    .d      (hw2reg.key_share0[0].d),
    .qre    (),
    .qe     (key_share0_0_flds_we[0]),
    .q      (reg2hw.key_share0[0].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.key_share0[0].qe = key_share0_0_qe;
  
  
  logic key_share0_1_qe;
  logic [0:0] key_share0_1_flds_we;
  assign key_share0_1_qe = &key_share0_1_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share0_1 (
    .re     (1'b0),
    .we     (key_share0_1_we),
    .wd     (key_share0_1_wd),
    .d      (hw2reg.key_share0[1].d),
    .qre    (),
    .qe     (key_share0_1_flds_we[0]),
    .q      (reg2hw.key_share0[1].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.key_share0[1].qe = key_share0_1_qe;
  
  
  logic key_share0_2_qe;
  logic [0:0] key_share0_2_flds_we;
  assign key_share0_2_qe = &key_share0_2_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share0_2 (
    .re     (1'b0),
    .we     (key_share0_2_we),
    .wd     (key_share0_2_wd),
    .d      (hw2reg.key_share0[2].d),
    .qre    (),
    .qe     (key_share0_2_flds_we[0]),
    .q      (reg2hw.key_share0[2].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.key_share0[2].qe = key_share0_2_qe;
  
  
  logic key_share0_3_qe;
  logic [0:0] key_share0_3_flds_we;
  assign key_share0_3_qe = &key_share0_3_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share0_3 (
    .re     (1'b0),
    .we     (key_share0_3_we),
    .wd     (key_share0_3_wd),
    .d      (hw2reg.key_share0[3].d),
    .qre    (),
    .qe     (key_share0_3_flds_we[0]),
    .q      (reg2hw.key_share0[3].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.key_share0[3].qe = key_share0_3_qe;
  
  
  logic key_share1_0_qe;
  logic [0:0] key_share1_0_flds_we;
  assign key_share1_0_qe = &key_share1_0_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share1_0 (
    .re     (1'b0),
    .we     (key_share1_0_we),
    .wd     (key_share1_0_wd),
    .d      (hw2reg.key_share1[0].d),
    .qre    (),
    .qe     (key_share1_0_flds_we[0]),
    .q      (reg2hw.key_share1[0].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.key_share1[0].qe = key_share1_0_qe;
  
  
  logic key_share1_1_qe;
  logic [0:0] key_share1_1_flds_we;
  assign key_share1_1_qe = &key_share1_1_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share1_1 (
    .re     (1'b0),
    .we     (key_share1_1_we),
    .wd     (key_share1_1_wd),
    .d      (hw2reg.key_share1[1].d),
    .qre    (),
    .qe     (key_share1_1_flds_we[0]),
    .q      (reg2hw.key_share1[1].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.key_share1[1].qe = key_share1_1_qe;
  
  
  logic key_share1_2_qe;
  logic [0:0] key_share1_2_flds_we;
  assign key_share1_2_qe = &key_share1_2_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share1_2 (
    .re     (1'b0),
    .we     (key_share1_2_we),
    .wd     (key_share1_2_wd),
    .d      (hw2reg.key_share1[2].d),
    .qre    (),
    .qe     (key_share1_2_flds_we[0]),
    .q      (reg2hw.key_share1[2].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.key_share1[2].qe = key_share1_2_qe;
  
  
  logic key_share1_3_qe;
  logic [0:0] key_share1_3_flds_we;
  assign key_share1_3_qe = &key_share1_3_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_key_share1_3 (
    .re     (1'b0),
    .we     (key_share1_3_we),
    .wd     (key_share1_3_wd),
    .d      (hw2reg.key_share1[3].d),
    .qre    (),
    .qe     (key_share1_3_flds_we[0]),
    .q      (reg2hw.key_share1[3].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.key_share1[3].qe = key_share1_3_qe;
  
  
  logic nonce_share0_0_qe;
  logic [0:0] nonce_share0_0_flds_we;
  assign nonce_share0_0_qe = &nonce_share0_0_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_nonce_share0_0 (
    .re     (1'b0),
    .we     (nonce_share0_0_we),
    .wd     (nonce_share0_0_wd),
    .d      (hw2reg.nonce_share0[0].d),
    .qre    (),
    .qe     (nonce_share0_0_flds_we[0]),
    .q      (reg2hw.nonce_share0[0].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.nonce_share0[0].qe = nonce_share0_0_qe;
  
  
  logic nonce_share0_1_qe;
  logic [0:0] nonce_share0_1_flds_we;
  assign nonce_share0_1_qe = &nonce_share0_1_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_nonce_share0_1 (
    .re     (1'b0),
    .we     (nonce_share0_1_we),
    .wd     (nonce_share0_1_wd),
    .d      (hw2reg.nonce_share0[1].d),
    .qre    (),
    .qe     (nonce_share0_1_flds_we[0]),
    .q      (reg2hw.nonce_share0[1].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.nonce_share0[1].qe = nonce_share0_1_qe;
  
  
  logic nonce_share0_2_qe;
  logic [0:0] nonce_share0_2_flds_we;
  assign nonce_share0_2_qe = &nonce_share0_2_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_nonce_share0_2 (
    .re     (1'b0),
    .we     (nonce_share0_2_we),
    .wd     (nonce_share0_2_wd),
    .d      (hw2reg.nonce_share0[2].d),
    .qre    (),
    .qe     (nonce_share0_2_flds_we[0]),
    .q      (reg2hw.nonce_share0[2].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.nonce_share0[2].qe = nonce_share0_2_qe;
  
  
  logic nonce_share0_3_qe;
  logic [0:0] nonce_share0_3_flds_we;
  assign nonce_share0_3_qe = &nonce_share0_3_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_nonce_share0_3 (
    .re     (1'b0),
    .we     (nonce_share0_3_we),
    .wd     (nonce_share0_3_wd),
    .d      (hw2reg.nonce_share0[3].d),
    .qre    (),
    .qe     (nonce_share0_3_flds_we[0]),
    .q      (reg2hw.nonce_share0[3].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.nonce_share0[3].qe = nonce_share0_3_qe;
  
  
  logic nonce_share1_0_qe;
  logic [0:0] nonce_share1_0_flds_we;
  assign nonce_share1_0_qe = &nonce_share1_0_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_nonce_share1_0 (
    .re     (1'b0),
    .we     (nonce_share1_0_we),
    .wd     (nonce_share1_0_wd),
    .d      (hw2reg.nonce_share1[0].d),
    .qre    (),
    .qe     (nonce_share1_0_flds_we[0]),
    .q      (reg2hw.nonce_share1[0].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.nonce_share1[0].qe = nonce_share1_0_qe;
  
  
  logic nonce_share1_1_qe;
  logic [0:0] nonce_share1_1_flds_we;
  assign nonce_share1_1_qe = &nonce_share1_1_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_nonce_share1_1 (
    .re     (1'b0),
    .we     (nonce_share1_1_we),
    .wd     (nonce_share1_1_wd),
    .d      (hw2reg.nonce_share1[1].d),
    .qre    (),
    .qe     (nonce_share1_1_flds_we[0]),
    .q      (reg2hw.nonce_share1[1].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.nonce_share1[1].qe = nonce_share1_1_qe;
  
  
  logic nonce_share1_2_qe;
  logic [0:0] nonce_share1_2_flds_we;
  assign nonce_share1_2_qe = &nonce_share1_2_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_nonce_share1_2 (
    .re     (1'b0),
    .we     (nonce_share1_2_we),
    .wd     (nonce_share1_2_wd),
    .d      (hw2reg.nonce_share1[2].d),
    .qre    (),
    .qe     (nonce_share1_2_flds_we[0]),
    .q      (reg2hw.nonce_share1[2].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.nonce_share1[2].qe = nonce_share1_2_qe;
  
  
  logic nonce_share1_3_qe;
  logic [0:0] nonce_share1_3_flds_we;
  assign nonce_share1_3_qe = &nonce_share1_3_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_nonce_share1_3 (
    .re     (1'b0),
    .we     (nonce_share1_3_we),
    .wd     (nonce_share1_3_wd),
    .d      (hw2reg.nonce_share1[3].d),
    .qre    (),
    .qe     (nonce_share1_3_flds_we[0]),
    .q      (reg2hw.nonce_share1[3].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.nonce_share1[3].qe = nonce_share1_3_qe;
  
  
  logic data_in_share0_0_qe;
  logic [0:0] data_in_share0_0_flds_we;
  assign data_in_share0_0_qe = &data_in_share0_0_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_data_in_share0_0 (
    .re     (1'b0),
    .we     (data_in_share0_0_we),
    .wd     (data_in_share0_0_wd),
    .d      (hw2reg.data_in_share0[0].d),
    .qre    (),
    .qe     (data_in_share0_0_flds_we[0]),
    .q      (reg2hw.data_in_share0[0].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.data_in_share0[0].qe = data_in_share0_0_qe;
  
  
  logic data_in_share0_1_qe;
  logic [0:0] data_in_share0_1_flds_we;
  assign data_in_share0_1_qe = &data_in_share0_1_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_data_in_share0_1 (
    .re     (1'b0),
    .we     (data_in_share0_1_we),
    .wd     (data_in_share0_1_wd),
    .d      (hw2reg.data_in_share0[1].d),
    .qre    (),
    .qe     (data_in_share0_1_flds_we[0]),
    .q      (reg2hw.data_in_share0[1].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.data_in_share0[1].qe = data_in_share0_1_qe;
  
  
  logic data_in_share0_2_qe;
  logic [0:0] data_in_share0_2_flds_we;
  assign data_in_share0_2_qe = &data_in_share0_2_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_data_in_share0_2 (
    .re     (1'b0),
    .we     (data_in_share0_2_we),
    .wd     (data_in_share0_2_wd),
    .d      (hw2reg.data_in_share0[2].d),
    .qre    (),
    .qe     (data_in_share0_2_flds_we[0]),
    .q      (reg2hw.data_in_share0[2].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.data_in_share0[2].qe = data_in_share0_2_qe;
  
  
  logic data_in_share0_3_qe;
  logic [0:0] data_in_share0_3_flds_we;
  assign data_in_share0_3_qe = &data_in_share0_3_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_data_in_share0_3 (
    .re     (1'b0),
    .we     (data_in_share0_3_we),
    .wd     (data_in_share0_3_wd),
    .d      (hw2reg.data_in_share0[3].d),
    .qre    (),
    .qe     (data_in_share0_3_flds_we[0]),
    .q      (reg2hw.data_in_share0[3].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.data_in_share0[3].qe = data_in_share0_3_qe;
  
  
  logic data_in_share1_0_qe;
  logic [0:0] data_in_share1_0_flds_we;
  assign data_in_share1_0_qe = &data_in_share1_0_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_data_in_share1_0 (
    .re     (1'b0),
    .we     (data_in_share1_0_we),
    .wd     (data_in_share1_0_wd),
    .d      (hw2reg.data_in_share1[0].d),
    .qre    (),
    .qe     (data_in_share1_0_flds_we[0]),
    .q      (reg2hw.data_in_share1[0].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.data_in_share1[0].qe = data_in_share1_0_qe;
  
  
  logic data_in_share1_1_qe;
  logic [0:0] data_in_share1_1_flds_we;
  assign data_in_share1_1_qe = &data_in_share1_1_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_data_in_share1_1 (
    .re     (1'b0),
    .we     (data_in_share1_1_we),
    .wd     (data_in_share1_1_wd),
    .d      (hw2reg.data_in_share1[1].d),
    .qre    (),
    .qe     (data_in_share1_1_flds_we[0]),
    .q      (reg2hw.data_in_share1[1].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.data_in_share1[1].qe = data_in_share1_1_qe;
  
  
  logic data_in_share1_2_qe;
  logic [0:0] data_in_share1_2_flds_we;
  assign data_in_share1_2_qe = &data_in_share1_2_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_data_in_share1_2 (
    .re     (1'b0),
    .we     (data_in_share1_2_we),
    .wd     (data_in_share1_2_wd),
    .d      (hw2reg.data_in_share1[2].d),
    .qre    (),
    .qe     (data_in_share1_2_flds_we[0]),
    .q      (reg2hw.data_in_share1[2].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.data_in_share1[2].qe = data_in_share1_2_qe;
  
  
  logic data_in_share1_3_qe;
  logic [0:0] data_in_share1_3_flds_we;
  assign data_in_share1_3_qe = &data_in_share1_3_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_data_in_share1_3 (
    .re     (1'b0),
    .we     (data_in_share1_3_we),
    .wd     (data_in_share1_3_wd),
    .d      (hw2reg.data_in_share1[3].d),
    .qre    (),
    .qe     (data_in_share1_3_flds_we[0]),
    .q      (reg2hw.data_in_share1[3].q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.data_in_share1[3].qe = data_in_share1_3_qe;
  
  
  logic tag_in_0_qe;
  logic [0:0] tag_in_0_flds_we;
  prim_flop #(
    .Width(1),
    .ResetValue(0)
  ) u_tag_in0_qe (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .d_i(&tag_in_0_flds_we),
    .q_o(tag_in_0_qe)
  );
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessWO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_tag_in_0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (tag_in_0_we),
    .wd     (tag_in_0_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (tag_in_0_flds_we[0]),
    .q      (reg2hw.tag_in[0].q),
    .ds     (),
    
    .qs     ()
  );
  assign reg2hw.tag_in[0].qe = tag_in_0_qe;
  
  
  logic tag_in_1_qe;
  logic [0:0] tag_in_1_flds_we;
  prim_flop #(
    .Width(1),
    .ResetValue(0)
  ) u_tag_in1_qe (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .d_i(&tag_in_1_flds_we),
    .q_o(tag_in_1_qe)
  );
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessWO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_tag_in_1 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (tag_in_1_we),
    .wd     (tag_in_1_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (tag_in_1_flds_we[0]),
    .q      (reg2hw.tag_in[1].q),
    .ds     (),
    
    .qs     ()
  );
  assign reg2hw.tag_in[1].qe = tag_in_1_qe;
  
  
  logic tag_in_2_qe;
  logic [0:0] tag_in_2_flds_we;
  prim_flop #(
    .Width(1),
    .ResetValue(0)
  ) u_tag_in2_qe (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .d_i(&tag_in_2_flds_we),
    .q_o(tag_in_2_qe)
  );
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessWO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_tag_in_2 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (tag_in_2_we),
    .wd     (tag_in_2_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (tag_in_2_flds_we[0]),
    .q      (reg2hw.tag_in[2].q),
    .ds     (),
    
    .qs     ()
  );
  assign reg2hw.tag_in[2].qe = tag_in_2_qe;
  
  
  logic tag_in_3_qe;
  logic [0:0] tag_in_3_flds_we;
  prim_flop #(
    .Width(1),
    .ResetValue(0)
  ) u_tag_in3_qe (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .d_i(&tag_in_3_flds_we),
    .q_o(tag_in_3_qe)
  );
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessWO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_tag_in_3 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (tag_in_3_we),
    .wd     (tag_in_3_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (tag_in_3_flds_we[0]),
    .q      (reg2hw.tag_in[3].q),
    .ds     (),
    
    .qs     ()
  );
  assign reg2hw.tag_in[3].qe = tag_in_3_qe;
  
  
  prim_subreg_ext #(
    .DW    (32)
  ) u_msg_out_0 (
    .re     (msg_out_0_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.msg_out[0].d),
    .qre    (reg2hw.msg_out[0].re),
    .qe     (),
    .q      (reg2hw.msg_out[0].q),
    .ds     (),
    .qs     (msg_out_0_qs)
  );
  
  
  prim_subreg_ext #(
    .DW    (32)
  ) u_msg_out_1 (
    .re     (msg_out_1_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.msg_out[1].d),
    .qre    (reg2hw.msg_out[1].re),
    .qe     (),
    .q      (reg2hw.msg_out[1].q),
    .ds     (),
    .qs     (msg_out_1_qs)
  );
  
  
  prim_subreg_ext #(
    .DW    (32)
  ) u_msg_out_2 (
    .re     (msg_out_2_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.msg_out[2].d),
    .qre    (reg2hw.msg_out[2].re),
    .qe     (),
    .q      (reg2hw.msg_out[2].q),
    .ds     (),
    .qs     (msg_out_2_qs)
  );
  
  
  prim_subreg_ext #(
    .DW    (32)
  ) u_msg_out_3 (
    .re     (msg_out_3_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.msg_out[3].d),
    .qre    (reg2hw.msg_out[3].re),
    .qe     (),
    .q      (reg2hw.msg_out[3].q),
    .ds     (),
    .qs     (msg_out_3_qs)
  );
  
  
  prim_subreg_ext #(
    .DW    (32)
  ) u_tag_out_0 (
    .re     (tag_out_0_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.tag_out[0].d),
    .qre    (reg2hw.tag_out[0].re),
    .qe     (),
    .q      (reg2hw.tag_out[0].q),
    .ds     (),
    .qs     (tag_out_0_qs)
  );
  
  
  prim_subreg_ext #(
    .DW    (32)
  ) u_tag_out_1 (
    .re     (tag_out_1_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.tag_out[1].d),
    .qre    (reg2hw.tag_out[1].re),
    .qe     (),
    .q      (reg2hw.tag_out[1].q),
    .ds     (),
    .qs     (tag_out_1_qs)
  );
  
  
  prim_subreg_ext #(
    .DW    (32)
  ) u_tag_out_2 (
    .re     (tag_out_2_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.tag_out[2].d),
    .qre    (reg2hw.tag_out[2].re),
    .qe     (),
    .q      (reg2hw.tag_out[2].q),
    .ds     (),
    .qs     (tag_out_2_qs)
  );
  
  
  prim_subreg_ext #(
    .DW    (32)
  ) u_tag_out_3 (
    .re     (tag_out_3_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.tag_out[3].d),
    .qre    (reg2hw.tag_out[3].re),
    .qe     (),
    .q      (reg2hw.tag_out[3].q),
    .ds     (),
    .qs     (tag_out_3_qs)
  );
  
  
  prim_subreg_shadow #(
    .DW      (3),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (3'h0),
    .Mubi    (1'b0)
  ) u_ctrl_shadowed_operation (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    .rst_shadowed_ni (rst_shadowed_ni),
    
    .re     (ctrl_shadowed_re),
    .we     (ctrl_shadowed_we),
    .wd     (ctrl_shadowed_operation_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.ctrl_shadowed.operation.q),
    .ds     (),
    
    .qs     (ctrl_shadowed_operation_qs),
    
    .phase  (),
    
    .err_update  (ctrl_shadowed_operation_update_err),
    .err_storage (ctrl_shadowed_operation_storage_err)
  );
  
  prim_subreg_shadow #(
    .DW      (2),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (2'h0),
    .Mubi    (1'b0)
  ) u_ctrl_shadowed_ascon_variant (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    .rst_shadowed_ni (rst_shadowed_ni),
    
    .re     (ctrl_shadowed_re),
    .we     (ctrl_shadowed_we),
    .wd     (ctrl_shadowed_ascon_variant_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.ctrl_shadowed.ascon_variant.q),
    .ds     (),
    
    .qs     (ctrl_shadowed_ascon_variant_qs),
    
    .phase  (),
    
    .err_update  (ctrl_shadowed_ascon_variant_update_err),
    .err_storage (ctrl_shadowed_ascon_variant_storage_err)
  );
  
  prim_subreg_shadow #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_ctrl_shadowed_sideload_key (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    .rst_shadowed_ni (rst_shadowed_ni),
    
    .re     (ctrl_shadowed_re),
    .we     (ctrl_shadowed_we),
    .wd     (ctrl_shadowed_sideload_key_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.ctrl_shadowed.sideload_key.q),
    .ds     (),
    
    .qs     (ctrl_shadowed_sideload_key_qs),
    
    .phase  (),
    
    .err_update  (ctrl_shadowed_sideload_key_update_err),
    .err_storage (ctrl_shadowed_sideload_key_storage_err)
  );
  
  prim_subreg_shadow #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_ctrl_shadowed_masked_ad_input (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    .rst_shadowed_ni (rst_shadowed_ni),
    
    .re     (ctrl_shadowed_re),
    .we     (ctrl_shadowed_we),
    .wd     (ctrl_shadowed_masked_ad_input_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.ctrl_shadowed.masked_ad_input.q),
    .ds     (),
    
    .qs     (ctrl_shadowed_masked_ad_input_qs),
    
    .phase  (),
    
    .err_update  (ctrl_shadowed_masked_ad_input_update_err),
    .err_storage (ctrl_shadowed_masked_ad_input_storage_err)
  );
  
  prim_subreg_shadow #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_ctrl_shadowed_masked_msg_input (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    .rst_shadowed_ni (rst_shadowed_ni),
    
    .re     (ctrl_shadowed_re),
    .we     (ctrl_shadowed_we),
    .wd     (ctrl_shadowed_masked_msg_input_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.ctrl_shadowed.masked_msg_input.q),
    .ds     (),
    
    .qs     (ctrl_shadowed_masked_msg_input_qs),
    
    .phase  (),
    
    .err_update  (ctrl_shadowed_masked_msg_input_update_err),
    .err_storage (ctrl_shadowed_masked_msg_input_storage_err)
  );
  
  prim_subreg_shadow #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (4'h6),
    .Mubi    (1'b0)
  ) u_ctrl_shadowed_no_msg (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    .rst_shadowed_ni (rst_shadowed_ni),
    
    .re     (ctrl_shadowed_re),
    .we     (ctrl_shadowed_we),
    .wd     (ctrl_shadowed_no_msg_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.ctrl_shadowed.no_msg.q),
    .ds     (),
    
    .qs     (ctrl_shadowed_no_msg_qs),
    
    .phase  (),
    
    .err_update  (ctrl_shadowed_no_msg_update_err),
    .err_storage (ctrl_shadowed_no_msg_storage_err)
  );
  
  prim_subreg_shadow #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (4'h9),
    .Mubi    (1'b0)
  ) u_ctrl_shadowed_no_ad (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    .rst_shadowed_ni (rst_shadowed_ni),
    
    .re     (ctrl_shadowed_re),
    .we     (ctrl_shadowed_we),
    .wd     (ctrl_shadowed_no_ad_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.ctrl_shadowed.no_ad.q),
    .ds     (),
    
    .qs     (ctrl_shadowed_no_ad_qs),
    
    .phase  (),
    
    .err_update  (ctrl_shadowed_no_ad_update_err),
    .err_storage (ctrl_shadowed_no_ad_storage_err)
  );
  
  
  logic ctrl_aux_shadowed_gated_we;
  assign ctrl_aux_shadowed_gated_we = ctrl_aux_shadowed_we & ctrl_aux_regwen_qs;
  
  prim_subreg_shadow #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_ctrl_aux_shadowed_manual_start_trigger (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    .rst_shadowed_ni (rst_shadowed_ni),
    
    .re     (ctrl_aux_shadowed_re),
    .we     (ctrl_aux_shadowed_gated_we),
    .wd     (ctrl_aux_shadowed_manual_start_trigger_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.ctrl_aux_shadowed.manual_start_trigger.q),
    .ds     (),
    
    .qs     (ctrl_aux_shadowed_manual_start_trigger_qs),
    
    .phase  (),
    
    .err_update  (ctrl_aux_shadowed_manual_start_trigger_update_err),
    .err_storage (ctrl_aux_shadowed_manual_start_trigger_storage_err)
  );
  
  prim_subreg_shadow #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_ctrl_aux_shadowed_force_data_overwrite (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    .rst_shadowed_ni (rst_shadowed_ni),
    
    .re     (ctrl_aux_shadowed_re),
    .we     (ctrl_aux_shadowed_gated_we),
    .wd     (ctrl_aux_shadowed_force_data_overwrite_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.ctrl_aux_shadowed.force_data_overwrite.q),
    .ds     (),
    
    .qs     (ctrl_aux_shadowed_force_data_overwrite_qs),
    
    .phase  (),
    
    .err_update  (ctrl_aux_shadowed_force_data_overwrite_update_err),
    .err_storage (ctrl_aux_shadowed_force_data_overwrite_storage_err)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW0C),
    .RESVAL  (1'h1),
    .Mubi    (1'b0)
  ) u_ctrl_aux_regwen (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (ctrl_aux_regwen_we),
    .wd     (ctrl_aux_regwen_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (ctrl_aux_regwen_qs)
  );
  
  
  prim_subreg_shadow #(
    .DW      (12),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (12'h0),
    .Mubi    (1'b0)
  ) u_block_ctrl_shadowed_data_type_start (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    .rst_shadowed_ni (rst_shadowed_ni),
    
    .re     (block_ctrl_shadowed_re),
    .we     (block_ctrl_shadowed_we),
    .wd     (block_ctrl_shadowed_data_type_start_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.block_ctrl_shadowed.data_type_start.q),
    .ds     (),
    
    .qs     (block_ctrl_shadowed_data_type_start_qs),
    
    .phase  (),
    
    .err_update  (block_ctrl_shadowed_data_type_start_update_err),
    .err_storage (block_ctrl_shadowed_data_type_start_storage_err)
  );
  
  prim_subreg_shadow #(
    .DW      (12),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (12'h0),
    .Mubi    (1'b0)
  ) u_block_ctrl_shadowed_data_type_last (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    .rst_shadowed_ni (rst_shadowed_ni),
    
    .re     (block_ctrl_shadowed_re),
    .we     (block_ctrl_shadowed_we),
    .wd     (block_ctrl_shadowed_data_type_last_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.block_ctrl_shadowed.data_type_last.q),
    .ds     (),
    
    .qs     (block_ctrl_shadowed_data_type_last_qs),
    
    .phase  (),
    
    .err_update  (block_ctrl_shadowed_data_type_last_update_err),
    .err_storage (block_ctrl_shadowed_data_type_last_storage_err)
  );
  
  prim_subreg_shadow #(
    .DW      (5),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (5'h1f),
    .Mubi    (1'b0)
  ) u_block_ctrl_shadowed_valid_bytes (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    .rst_shadowed_ni (rst_shadowed_ni),
    
    .re     (block_ctrl_shadowed_re),
    .we     (block_ctrl_shadowed_we),
    .wd     (block_ctrl_shadowed_valid_bytes_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.block_ctrl_shadowed.valid_bytes.q),
    .ds     (),
    
    .qs     (block_ctrl_shadowed_valid_bytes_qs),
    
    .phase  (),
    
    .err_update  (block_ctrl_shadowed_valid_bytes_update_err),
    .err_storage (block_ctrl_shadowed_valid_bytes_storage_err)
  );
  
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_trigger_start (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (trigger_we),
    .wd     (trigger_start_wd),
    
    .de     (hw2reg.trigger.start.de),
    .d      (hw2reg.trigger.start.d),
    
    .qe     (),
    .q      (reg2hw.trigger.start.q),
    .ds     (),
    
    .qs     (trigger_start_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_trigger_wipe (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (trigger_we),
    .wd     (trigger_wipe_wd),
    
    .de     (hw2reg.trigger.wipe.de),
    .d      (hw2reg.trigger.wipe.d),
    
    .qe     (),
    .q      (reg2hw.trigger.wipe.q),
    .ds     (),
    
    .qs     (trigger_wipe_qs)
  );
  
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_idle (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.idle.de),
    .d      (hw2reg.status.idle.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_idle_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_stall (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.stall.de),
    .d      (hw2reg.status.stall.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_stall_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_wait_edn (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.wait_edn.de),
    .d      (hw2reg.status.wait_edn.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_wait_edn_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_ascon_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.ascon_error.de),
    .d      (hw2reg.status.ascon_error.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_ascon_error_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_alert_recov_ctrl_update_err (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.alert_recov_ctrl_update_err.de),
    .d      (hw2reg.status.alert_recov_ctrl_update_err.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_alert_recov_ctrl_update_err_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_alert_fatal_fault (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.alert_fatal_fault.de),
    .d      (hw2reg.status.alert_fatal_fault.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_alert_fatal_fault_qs)
  );
  
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_output_valid_msg_valid (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.output_valid.msg_valid.de),
    .d      (hw2reg.output_valid.msg_valid.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (output_valid_msg_valid_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_output_valid_tag_valid (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.output_valid.tag_valid.de),
    .d      (hw2reg.output_valid.tag_valid.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (output_valid_tag_valid_qs)
  );
  
  prim_subreg #(
    .DW      (2),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (2'h0),
    .Mubi    (1'b0)
  ) u_output_valid_tag_comparison_valid (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.output_valid.tag_comparison_valid.de),
    .d      (hw2reg.output_valid.tag_comparison_valid.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (output_valid_tag_comparison_valid_qs)
  );
  
  logic fsm_state_qe;
  logic [0:0] fsm_state_flds_we;
  
  assign fsm_state_qe = &fsm_state_flds_we;
  prim_subreg_ext #(
    .DW    (32)
  ) u_fsm_state (
    .re     (fsm_state_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.fsm_state.d),
    .qre    (),
    .qe     (fsm_state_flds_we[0]),
    .q      (reg2hw.fsm_state.q),
    .ds     (),
    .qs     (fsm_state_qs)
  );
  assign reg2hw.fsm_state.qe = fsm_state_qe;
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW0C),
    .RESVAL  (1'h1),
    .Mubi    (1'b0)
  ) u_fsm_state_regren (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (fsm_state_regren_we),
    .wd     (fsm_state_regren_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (fsm_state_regren_qs)
  );
  
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_no_key (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.error.no_key.de),
    .d      (hw2reg.error.no_key.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (error_no_key_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_no_nonce (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.error.no_nonce.de),
    .d      (hw2reg.error.no_nonce.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (error_no_nonce_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_wrong_order (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.error.wrong_order.de),
    .d      (hw2reg.error.wrong_order.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (error_wrong_order_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_flag_input_missmatch (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.error.flag_input_missmatch.de),
    .d      (hw2reg.error.flag_input_missmatch.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (error_flag_input_missmatch_qs)
  );
  logic [46:0] addr_hit;
  always_comb begin
    addr_hit = '0;
    addr_hit[ 0] = (reg_addr == ASCON_ALERT_TEST_OFFSET);
    addr_hit[ 1] = (reg_addr == ASCON_KEY_SHARE0_0_OFFSET);
    addr_hit[ 2] = (reg_addr == ASCON_KEY_SHARE0_1_OFFSET);
    addr_hit[ 3] = (reg_addr == ASCON_KEY_SHARE0_2_OFFSET);
    addr_hit[ 4] = (reg_addr == ASCON_KEY_SHARE0_3_OFFSET);
    addr_hit[ 5] = (reg_addr == ASCON_KEY_SHARE1_0_OFFSET);
    addr_hit[ 6] = (reg_addr == ASCON_KEY_SHARE1_1_OFFSET);
    addr_hit[ 7] = (reg_addr == ASCON_KEY_SHARE1_2_OFFSET);
    addr_hit[ 8] = (reg_addr == ASCON_KEY_SHARE1_3_OFFSET);
    addr_hit[ 9] = (reg_addr == ASCON_NONCE_SHARE0_0_OFFSET);
    addr_hit[10] = (reg_addr == ASCON_NONCE_SHARE0_1_OFFSET);
    addr_hit[11] = (reg_addr == ASCON_NONCE_SHARE0_2_OFFSET);
    addr_hit[12] = (reg_addr == ASCON_NONCE_SHARE0_3_OFFSET);
    addr_hit[13] = (reg_addr == ASCON_NONCE_SHARE1_0_OFFSET);
    addr_hit[14] = (reg_addr == ASCON_NONCE_SHARE1_1_OFFSET);
    addr_hit[15] = (reg_addr == ASCON_NONCE_SHARE1_2_OFFSET);
    addr_hit[16] = (reg_addr == ASCON_NONCE_SHARE1_3_OFFSET);
    addr_hit[17] = (reg_addr == ASCON_DATA_IN_SHARE0_0_OFFSET);
    addr_hit[18] = (reg_addr == ASCON_DATA_IN_SHARE0_1_OFFSET);
    addr_hit[19] = (reg_addr == ASCON_DATA_IN_SHARE0_2_OFFSET);
    addr_hit[20] = (reg_addr == ASCON_DATA_IN_SHARE0_3_OFFSET);
    addr_hit[21] = (reg_addr == ASCON_DATA_IN_SHARE1_0_OFFSET);
    addr_hit[22] = (reg_addr == ASCON_DATA_IN_SHARE1_1_OFFSET);
    addr_hit[23] = (reg_addr == ASCON_DATA_IN_SHARE1_2_OFFSET);
    addr_hit[24] = (reg_addr == ASCON_DATA_IN_SHARE1_3_OFFSET);
    addr_hit[25] = (reg_addr == ASCON_TAG_IN_0_OFFSET);
    addr_hit[26] = (reg_addr == ASCON_TAG_IN_1_OFFSET);
    addr_hit[27] = (reg_addr == ASCON_TAG_IN_2_OFFSET);
    addr_hit[28] = (reg_addr == ASCON_TAG_IN_3_OFFSET);
    addr_hit[29] = (reg_addr == ASCON_MSG_OUT_0_OFFSET);
    addr_hit[30] = (reg_addr == ASCON_MSG_OUT_1_OFFSET);
    addr_hit[31] = (reg_addr == ASCON_MSG_OUT_2_OFFSET);
    addr_hit[32] = (reg_addr == ASCON_MSG_OUT_3_OFFSET);
    addr_hit[33] = (reg_addr == ASCON_TAG_OUT_0_OFFSET);
    addr_hit[34] = (reg_addr == ASCON_TAG_OUT_1_OFFSET);
    addr_hit[35] = (reg_addr == ASCON_TAG_OUT_2_OFFSET);
    addr_hit[36] = (reg_addr == ASCON_TAG_OUT_3_OFFSET);
    addr_hit[37] = (reg_addr == ASCON_CTRL_SHADOWED_OFFSET);
    addr_hit[38] = (reg_addr == ASCON_CTRL_AUX_SHADOWED_OFFSET);
    addr_hit[39] = (reg_addr == ASCON_CTRL_AUX_REGWEN_OFFSET);
    addr_hit[40] = (reg_addr == ASCON_BLOCK_CTRL_SHADOWED_OFFSET);
    addr_hit[41] = (reg_addr == ASCON_TRIGGER_OFFSET);
    addr_hit[42] = (reg_addr == ASCON_STATUS_OFFSET);
    addr_hit[43] = (reg_addr == ASCON_OUTPUT_VALID_OFFSET);
    addr_hit[44] = (reg_addr == ASCON_FSM_STATE_OFFSET);
    addr_hit[45] = (reg_addr == ASCON_FSM_STATE_REGREN_OFFSET);
    addr_hit[46] = (reg_addr == ASCON_ERROR_OFFSET);
  end
  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0 ;
  
  always_comb begin
    wr_err = (reg_we &
              ((addr_hit[ 0] & (|(ASCON_PERMIT[ 0] & ~reg_be))) |
               (addr_hit[ 1] & (|(ASCON_PERMIT[ 1] & ~reg_be))) |
               (addr_hit[ 2] & (|(ASCON_PERMIT[ 2] & ~reg_be))) |
               (addr_hit[ 3] & (|(ASCON_PERMIT[ 3] & ~reg_be))) |
               (addr_hit[ 4] & (|(ASCON_PERMIT[ 4] & ~reg_be))) |
               (addr_hit[ 5] & (|(ASCON_PERMIT[ 5] & ~reg_be))) |
               (addr_hit[ 6] & (|(ASCON_PERMIT[ 6] & ~reg_be))) |
               (addr_hit[ 7] & (|(ASCON_PERMIT[ 7] & ~reg_be))) |
               (addr_hit[ 8] & (|(ASCON_PERMIT[ 8] & ~reg_be))) |
               (addr_hit[ 9] & (|(ASCON_PERMIT[ 9] & ~reg_be))) |
               (addr_hit[10] & (|(ASCON_PERMIT[10] & ~reg_be))) |
               (addr_hit[11] & (|(ASCON_PERMIT[11] & ~reg_be))) |
               (addr_hit[12] & (|(ASCON_PERMIT[12] & ~reg_be))) |
               (addr_hit[13] & (|(ASCON_PERMIT[13] & ~reg_be))) |
               (addr_hit[14] & (|(ASCON_PERMIT[14] & ~reg_be))) |
               (addr_hit[15] & (|(ASCON_PERMIT[15] & ~reg_be))) |
               (addr_hit[16] & (|(ASCON_PERMIT[16] & ~reg_be))) |
               (addr_hit[17] & (|(ASCON_PERMIT[17] & ~reg_be))) |
               (addr_hit[18] & (|(ASCON_PERMIT[18] & ~reg_be))) |
               (addr_hit[19] & (|(ASCON_PERMIT[19] & ~reg_be))) |
               (addr_hit[20] & (|(ASCON_PERMIT[20] & ~reg_be))) |
               (addr_hit[21] & (|(ASCON_PERMIT[21] & ~reg_be))) |
               (addr_hit[22] & (|(ASCON_PERMIT[22] & ~reg_be))) |
               (addr_hit[23] & (|(ASCON_PERMIT[23] & ~reg_be))) |
               (addr_hit[24] & (|(ASCON_PERMIT[24] & ~reg_be))) |
               (addr_hit[25] & (|(ASCON_PERMIT[25] & ~reg_be))) |
               (addr_hit[26] & (|(ASCON_PERMIT[26] & ~reg_be))) |
               (addr_hit[27] & (|(ASCON_PERMIT[27] & ~reg_be))) |
               (addr_hit[28] & (|(ASCON_PERMIT[28] & ~reg_be))) |
               (addr_hit[29] & (|(ASCON_PERMIT[29] & ~reg_be))) |
               (addr_hit[30] & (|(ASCON_PERMIT[30] & ~reg_be))) |
               (addr_hit[31] & (|(ASCON_PERMIT[31] & ~reg_be))) |
               (addr_hit[32] & (|(ASCON_PERMIT[32] & ~reg_be))) |
               (addr_hit[33] & (|(ASCON_PERMIT[33] & ~reg_be))) |
               (addr_hit[34] & (|(ASCON_PERMIT[34] & ~reg_be))) |
               (addr_hit[35] & (|(ASCON_PERMIT[35] & ~reg_be))) |
               (addr_hit[36] & (|(ASCON_PERMIT[36] & ~reg_be))) |
               (addr_hit[37] & (|(ASCON_PERMIT[37] & ~reg_be))) |
               (addr_hit[38] & (|(ASCON_PERMIT[38] & ~reg_be))) |
               (addr_hit[39] & (|(ASCON_PERMIT[39] & ~reg_be))) |
               (addr_hit[40] & (|(ASCON_PERMIT[40] & ~reg_be))) |
               (addr_hit[41] & (|(ASCON_PERMIT[41] & ~reg_be))) |
               (addr_hit[42] & (|(ASCON_PERMIT[42] & ~reg_be))) |
               (addr_hit[43] & (|(ASCON_PERMIT[43] & ~reg_be))) |
               (addr_hit[44] & (|(ASCON_PERMIT[44] & ~reg_be))) |
               (addr_hit[45] & (|(ASCON_PERMIT[45] & ~reg_be))) |
               (addr_hit[46] & (|(ASCON_PERMIT[46] & ~reg_be)))));
  end
  
  assign alert_test_we = addr_hit[0] & reg_we & !reg_error;
  assign alert_test_recov_ctrl_update_err_wd = reg_wdata[0];
  assign alert_test_fatal_fault_wd = reg_wdata[1];
  assign key_share0_0_we = addr_hit[1] & reg_we & !reg_error;
  assign key_share0_0_wd = reg_wdata[31:0];
  assign key_share0_1_we = addr_hit[2] & reg_we & !reg_error;
  assign key_share0_1_wd = reg_wdata[31:0];
  assign key_share0_2_we = addr_hit[3] & reg_we & !reg_error;
  assign key_share0_2_wd = reg_wdata[31:0];
  assign key_share0_3_we = addr_hit[4] & reg_we & !reg_error;
  assign key_share0_3_wd = reg_wdata[31:0];
  assign key_share1_0_we = addr_hit[5] & reg_we & !reg_error;
  assign key_share1_0_wd = reg_wdata[31:0];
  assign key_share1_1_we = addr_hit[6] & reg_we & !reg_error;
  assign key_share1_1_wd = reg_wdata[31:0];
  assign key_share1_2_we = addr_hit[7] & reg_we & !reg_error;
  assign key_share1_2_wd = reg_wdata[31:0];
  assign key_share1_3_we = addr_hit[8] & reg_we & !reg_error;
  assign key_share1_3_wd = reg_wdata[31:0];
  assign nonce_share0_0_we = addr_hit[9] & reg_we & !reg_error;
  assign nonce_share0_0_wd = reg_wdata[31:0];
  assign nonce_share0_1_we = addr_hit[10] & reg_we & !reg_error;
  assign nonce_share0_1_wd = reg_wdata[31:0];
  assign nonce_share0_2_we = addr_hit[11] & reg_we & !reg_error;
  assign nonce_share0_2_wd = reg_wdata[31:0];
  assign nonce_share0_3_we = addr_hit[12] & reg_we & !reg_error;
  assign nonce_share0_3_wd = reg_wdata[31:0];
  assign nonce_share1_0_we = addr_hit[13] & reg_we & !reg_error;
  assign nonce_share1_0_wd = reg_wdata[31:0];
  assign nonce_share1_1_we = addr_hit[14] & reg_we & !reg_error;
  assign nonce_share1_1_wd = reg_wdata[31:0];
  assign nonce_share1_2_we = addr_hit[15] & reg_we & !reg_error;
  assign nonce_share1_2_wd = reg_wdata[31:0];
  assign nonce_share1_3_we = addr_hit[16] & reg_we & !reg_error;
  assign nonce_share1_3_wd = reg_wdata[31:0];
  assign data_in_share0_0_we = addr_hit[17] & reg_we & !reg_error;
  assign data_in_share0_0_wd = reg_wdata[31:0];
  assign data_in_share0_1_we = addr_hit[18] & reg_we & !reg_error;
  assign data_in_share0_1_wd = reg_wdata[31:0];
  assign data_in_share0_2_we = addr_hit[19] & reg_we & !reg_error;
  assign data_in_share0_2_wd = reg_wdata[31:0];
  assign data_in_share0_3_we = addr_hit[20] & reg_we & !reg_error;
  assign data_in_share0_3_wd = reg_wdata[31:0];
  assign data_in_share1_0_we = addr_hit[21] & reg_we & !reg_error;
  assign data_in_share1_0_wd = reg_wdata[31:0];
  assign data_in_share1_1_we = addr_hit[22] & reg_we & !reg_error;
  assign data_in_share1_1_wd = reg_wdata[31:0];
  assign data_in_share1_2_we = addr_hit[23] & reg_we & !reg_error;
  assign data_in_share1_2_wd = reg_wdata[31:0];
  assign data_in_share1_3_we = addr_hit[24] & reg_we & !reg_error;
  assign data_in_share1_3_wd = reg_wdata[31:0];
  assign tag_in_0_we = addr_hit[25] & reg_we & !reg_error;
  assign tag_in_0_wd = reg_wdata[31:0];
  assign tag_in_1_we = addr_hit[26] & reg_we & !reg_error;
  assign tag_in_1_wd = reg_wdata[31:0];
  assign tag_in_2_we = addr_hit[27] & reg_we & !reg_error;
  assign tag_in_2_wd = reg_wdata[31:0];
  assign tag_in_3_we = addr_hit[28] & reg_we & !reg_error;
  assign tag_in_3_wd = reg_wdata[31:0];
  assign msg_out_0_re = addr_hit[29] & reg_re & !reg_error;
  assign msg_out_1_re = addr_hit[30] & reg_re & !reg_error;
  assign msg_out_2_re = addr_hit[31] & reg_re & !reg_error;
  assign msg_out_3_re = addr_hit[32] & reg_re & !reg_error;
  assign tag_out_0_re = addr_hit[33] & reg_re & !reg_error;
  assign tag_out_1_re = addr_hit[34] & reg_re & !reg_error;
  assign tag_out_2_re = addr_hit[35] & reg_re & !reg_error;
  assign tag_out_3_re = addr_hit[36] & reg_re & !reg_error;
  assign ctrl_shadowed_re = addr_hit[37] & reg_re & !reg_error;
  assign ctrl_shadowed_we = addr_hit[37] & reg_we & !reg_error;
  assign ctrl_shadowed_operation_wd = reg_wdata[2:0];
  assign ctrl_shadowed_ascon_variant_wd = reg_wdata[4:3];
  assign ctrl_shadowed_sideload_key_wd = reg_wdata[5];
  assign ctrl_shadowed_masked_ad_input_wd = reg_wdata[6];
  assign ctrl_shadowed_masked_msg_input_wd = reg_wdata[7];
  assign ctrl_shadowed_no_msg_wd = reg_wdata[11:8];
  assign ctrl_shadowed_no_ad_wd = reg_wdata[15:12];
  assign ctrl_aux_shadowed_re = addr_hit[38] & reg_re & !reg_error;
  assign ctrl_aux_shadowed_we = addr_hit[38] & reg_we & !reg_error;
  assign ctrl_aux_shadowed_manual_start_trigger_wd = reg_wdata[0];
  assign ctrl_aux_shadowed_force_data_overwrite_wd = reg_wdata[1];
  assign ctrl_aux_regwen_we = addr_hit[39] & reg_we & !reg_error;
  assign ctrl_aux_regwen_wd = reg_wdata[0];
  assign block_ctrl_shadowed_re = addr_hit[40] & reg_re & !reg_error;
  assign block_ctrl_shadowed_we = addr_hit[40] & reg_we & !reg_error;
  assign block_ctrl_shadowed_data_type_start_wd = reg_wdata[11:0];
  assign block_ctrl_shadowed_data_type_last_wd = reg_wdata[23:12];
  assign block_ctrl_shadowed_valid_bytes_wd = reg_wdata[28:24];
  assign trigger_we = addr_hit[41] & reg_we & !reg_error;
  assign trigger_start_wd = reg_wdata[0];
  assign trigger_wipe_wd = reg_wdata[1];
  assign fsm_state_re = addr_hit[44] & reg_re & !reg_error;
  assign fsm_state_regren_we = addr_hit[45] & reg_we & !reg_error;
  assign fsm_state_regren_wd = reg_wdata[0];
  
  always_comb begin
    reg_we_check = '0;
    reg_we_check[0] = alert_test_we;
    reg_we_check[1] = key_share0_0_we;
    reg_we_check[2] = key_share0_1_we;
    reg_we_check[3] = key_share0_2_we;
    reg_we_check[4] = key_share0_3_we;
    reg_we_check[5] = key_share1_0_we;
    reg_we_check[6] = key_share1_1_we;
    reg_we_check[7] = key_share1_2_we;
    reg_we_check[8] = key_share1_3_we;
    reg_we_check[9] = nonce_share0_0_we;
    reg_we_check[10] = nonce_share0_1_we;
    reg_we_check[11] = nonce_share0_2_we;
    reg_we_check[12] = nonce_share0_3_we;
    reg_we_check[13] = nonce_share1_0_we;
    reg_we_check[14] = nonce_share1_1_we;
    reg_we_check[15] = nonce_share1_2_we;
    reg_we_check[16] = nonce_share1_3_we;
    reg_we_check[17] = data_in_share0_0_we;
    reg_we_check[18] = data_in_share0_1_we;
    reg_we_check[19] = data_in_share0_2_we;
    reg_we_check[20] = data_in_share0_3_we;
    reg_we_check[21] = data_in_share1_0_we;
    reg_we_check[22] = data_in_share1_1_we;
    reg_we_check[23] = data_in_share1_2_we;
    reg_we_check[24] = data_in_share1_3_we;
    reg_we_check[25] = tag_in_0_we;
    reg_we_check[26] = tag_in_1_we;
    reg_we_check[27] = tag_in_2_we;
    reg_we_check[28] = tag_in_3_we;
    reg_we_check[29] = 1'b0;
    reg_we_check[30] = 1'b0;
    reg_we_check[31] = 1'b0;
    reg_we_check[32] = 1'b0;
    reg_we_check[33] = 1'b0;
    reg_we_check[34] = 1'b0;
    reg_we_check[35] = 1'b0;
    reg_we_check[36] = 1'b0;
    reg_we_check[37] = ctrl_shadowed_we;
    reg_we_check[38] = ctrl_aux_shadowed_gated_we;
    reg_we_check[39] = ctrl_aux_regwen_we;
    reg_we_check[40] = block_ctrl_shadowed_we;
    reg_we_check[41] = trigger_we;
    reg_we_check[42] = 1'b0;
    reg_we_check[43] = 1'b0;
    reg_we_check[44] = 1'b0;
    reg_we_check[45] = fsm_state_regren_we;
    reg_we_check[46] = 1'b0;
  end
  
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      addr_hit[0]: begin
        reg_rdata_next[0] = '0;
        reg_rdata_next[1] = '0;
      end
      addr_hit[1]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[2]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[3]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[4]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[5]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[6]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[7]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[8]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[9]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[10]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[11]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[12]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[13]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[14]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[15]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[16]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[17]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[18]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[19]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[20]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[21]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[22]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[23]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[24]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[25]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[26]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[27]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[28]: begin
        reg_rdata_next[31:0] = '0;
      end
      addr_hit[29]: begin
        reg_rdata_next[31:0] = msg_out_0_qs;
      end
      addr_hit[30]: begin
        reg_rdata_next[31:0] = msg_out_1_qs;
      end
      addr_hit[31]: begin
        reg_rdata_next[31:0] = msg_out_2_qs;
      end
      addr_hit[32]: begin
        reg_rdata_next[31:0] = msg_out_3_qs;
      end
      addr_hit[33]: begin
        reg_rdata_next[31:0] = tag_out_0_qs;
      end
      addr_hit[34]: begin
        reg_rdata_next[31:0] = tag_out_1_qs;
      end
      addr_hit[35]: begin
        reg_rdata_next[31:0] = tag_out_2_qs;
      end
      addr_hit[36]: begin
        reg_rdata_next[31:0] = tag_out_3_qs;
      end
      addr_hit[37]: begin
        reg_rdata_next[2:0] = ctrl_shadowed_operation_qs;
        reg_rdata_next[4:3] = ctrl_shadowed_ascon_variant_qs;
        reg_rdata_next[5] = ctrl_shadowed_sideload_key_qs;
        reg_rdata_next[6] = ctrl_shadowed_masked_ad_input_qs;
        reg_rdata_next[7] = ctrl_shadowed_masked_msg_input_qs;
        reg_rdata_next[11:8] = ctrl_shadowed_no_msg_qs;
        reg_rdata_next[15:12] = ctrl_shadowed_no_ad_qs;
      end
      addr_hit[38]: begin
        reg_rdata_next[0] = ctrl_aux_shadowed_manual_start_trigger_qs;
        reg_rdata_next[1] = ctrl_aux_shadowed_force_data_overwrite_qs;
      end
      addr_hit[39]: begin
        reg_rdata_next[0] = ctrl_aux_regwen_qs;
      end
      addr_hit[40]: begin
        reg_rdata_next[11:0] = block_ctrl_shadowed_data_type_start_qs;
        reg_rdata_next[23:12] = block_ctrl_shadowed_data_type_last_qs;
        reg_rdata_next[28:24] = block_ctrl_shadowed_valid_bytes_qs;
      end
      addr_hit[41]: begin
        reg_rdata_next[0] = trigger_start_qs;
        reg_rdata_next[1] = trigger_wipe_qs;
      end
      addr_hit[42]: begin
        reg_rdata_next[0] = status_idle_qs;
        reg_rdata_next[1] = status_stall_qs;
        reg_rdata_next[2] = status_wait_edn_qs;
        reg_rdata_next[3] = status_ascon_error_qs;
        reg_rdata_next[4] = status_alert_recov_ctrl_update_err_qs;
        reg_rdata_next[5] = status_alert_fatal_fault_qs;
      end
      addr_hit[43]: begin
        reg_rdata_next[0] = output_valid_msg_valid_qs;
        reg_rdata_next[1] = output_valid_tag_valid_qs;
        reg_rdata_next[3:2] = output_valid_tag_comparison_valid_qs;
      end
      addr_hit[44]: begin
        reg_rdata_next[31:0] = fsm_state_qs;
      end
      addr_hit[45]: begin
        reg_rdata_next[0] = fsm_state_regren_qs;
      end
      addr_hit[46]: begin
        reg_rdata_next[0] = error_no_key_qs;
        reg_rdata_next[1] = error_no_nonce_qs;
        reg_rdata_next[2] = error_wrong_order_qs;
        reg_rdata_next[3] = error_flag_input_missmatch_qs;
      end
      default: begin
        reg_rdata_next = '1;
      end
    endcase
  end
  
  logic shadow_busy;
  logic rst_done;
  logic shadow_rst_done;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rst_done <= '0;
    end else begin
      rst_done <= 1'b1;
    end
  end
  always_ff @(posedge clk_i or negedge rst_shadowed_ni) begin
    if (!rst_shadowed_ni) begin
      shadow_rst_done <= '0;
    end else begin
      shadow_rst_done <= 1'b1;
    end
  end
  
  assign shadow_busy = ~(rst_done & shadow_rst_done);
  
  assign shadowed_storage_err_o = |{
    ctrl_shadowed_operation_storage_err,
    ctrl_shadowed_ascon_variant_storage_err,
    ctrl_shadowed_sideload_key_storage_err,
    ctrl_shadowed_masked_ad_input_storage_err,
    ctrl_shadowed_masked_msg_input_storage_err,
    ctrl_shadowed_no_msg_storage_err,
    ctrl_shadowed_no_ad_storage_err,
    ctrl_aux_shadowed_manual_start_trigger_storage_err,
    ctrl_aux_shadowed_force_data_overwrite_storage_err,
    block_ctrl_shadowed_data_type_start_storage_err,
    block_ctrl_shadowed_data_type_last_storage_err,
    block_ctrl_shadowed_valid_bytes_storage_err
  };
  assign shadowed_update_err_o = |{
    ctrl_shadowed_operation_update_err,
    ctrl_shadowed_ascon_variant_update_err,
    ctrl_shadowed_sideload_key_update_err,
    ctrl_shadowed_masked_ad_input_update_err,
    ctrl_shadowed_masked_msg_input_update_err,
    ctrl_shadowed_no_msg_update_err,
    ctrl_shadowed_no_ad_update_err,
    ctrl_aux_shadowed_manual_start_trigger_update_err,
    ctrl_aux_shadowed_force_data_overwrite_update_err,
    block_ctrl_shadowed_data_type_start_update_err,
    block_ctrl_shadowed_data_type_last_update_err,
    block_ctrl_shadowed_valid_bytes_update_err
  };
  
  assign reg_busy = shadow_busy;
  
  
  
  logic unused_wdata;
  logic unused_be;
  assign unused_wdata = ^reg_wdata;
  assign unused_be = ^reg_be;
  
  `ASSERT_PULSE(wePulse, reg_we, clk_i, !rst_ni)
  `ASSERT_PULSE(rePulse, reg_re, clk_i, !rst_ni)
  `ASSERT(reAfterRv, $rose(reg_re || reg_we) |=> tl_o_pre.d_valid, clk_i, !rst_ni)
  `ASSERT(en2addrHit, (reg_we || reg_re) |-> $onehot0(addr_hit), clk_i, !rst_ni)
  
  
  
endmodule

package entropy_src_pkg;
  
  
  
  parameter int  CSRNG_BUS_WIDTH = 384;
  parameter int  FIPS_BUS_WIDTH  = 1;
  parameter int  FIPS_CSRNG_BUS_WIDTH = FIPS_BUS_WIDTH + CSRNG_BUS_WIDTH;
  
  
  
  
  parameter int BucketHtDataMaxWidth = 4;
  function automatic integer bucket_ht_data_width(integer rng_bus_width);
    return rng_bus_width >= BucketHtDataMaxWidth ? BucketHtDataMaxWidth : rng_bus_width;
  endfunction
  function automatic integer num_bucket_ht_inst(integer rng_bus_width);
    return prim_util_pkg::ceil_div(rng_bus_width, bucket_ht_data_width(rng_bus_width));
  endfunction
  
  typedef struct packed {
    logic es_ack;
    logic [CSRNG_BUS_WIDTH-1:0] es_bits;
    logic [FIPS_BUS_WIDTH-1:0] es_fips;
  } entropy_src_hw_if_rsp_t;
  typedef struct packed {
    logic es_req;
  } entropy_src_hw_if_req_t;
  parameter entropy_src_hw_if_req_t ENTROPY_SRC_HW_IF_REQ_DEFAULT = '{default: '0};
  parameter entropy_src_hw_if_rsp_t ENTROPY_SRC_HW_IF_RSP_DEFAULT = '{default: '0};
  
  typedef struct packed {
    logic rng_bit_en;
    logic clear;
    logic active;
    logic [15:0] thresh_hi;
    logic [15:0] thresh_lo;
    logic window_wrap_pulse;
    logic threshold_scope;
  } entropy_src_xht_meta_req_t;
  typedef struct packed {
    logic[15:0] test_cnt_hi;
    logic[15:0] test_cnt_lo;
    logic continuous_test;
    logic test_fail_hi_pulse;
    logic test_fail_lo_pulse;
  } entropy_src_xht_meta_rsp_t;
  parameter entropy_src_xht_meta_req_t ENTROPY_SRC_XHT_META_REQ_DEFAULT = '{default: '0};
  parameter entropy_src_xht_meta_rsp_t ENTROPY_SRC_XHT_META_RSP_DEFAULT =
      '{test_cnt_lo: 16'hffff, default: '0};
  parameter int HT_WATERMARK_NUM_WIDTH = 4;
  typedef enum logic [HT_WATERMARK_NUM_WIDTH-1:0] {
    REPCNT_HI  = 0,
    REPCNTS_HI = 1,
    ADAPTP_HI  = 2,
    ADAPTP_LO  = 3,
    BUCKET_HI  = 4,
    MARKOV_HI  = 5,
    MARKOV_LO  = 6,
    EXTHT_HI   = 7,
    EXTHT_LO   = 8
  } ht_watermark_num_e;
endpackage : entropy_src_pkg
