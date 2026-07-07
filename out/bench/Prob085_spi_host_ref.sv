
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

package top_racl_pkg;
  
  parameter int unsigned NrRaclPolicies = 1;
  
  parameter int unsigned RaclPolicySelLen = prim_util_pkg::vbits(NrRaclPolicies);
  
  typedef logic [RaclPolicySelLen-1:0] racl_policy_sel_t;
  
  parameter bit ErrorRsp = 0;
  
  parameter int unsigned NrRaclBits = 1;
  
  parameter int unsigned NrCtnUidBits = 1;
  
  typedef logic [NrRaclBits-1:0] racl_role_t;
  
  typedef logic [NrCtnUidBits-1:0] ctn_uid_t;
  
  typedef logic [(2**NrRaclBits)-1:0] racl_role_vec_t;
  
  typedef struct packed {
    racl_role_vec_t write_perm;    
    racl_role_vec_t read_perm;     
  } racl_policy_t;
  
  typedef struct packed {
    logic [top_pkg::TL_AW-1:0] base;       
    logic [top_pkg::TL_AW-1:0] limit;      
    racl_policy_sel_t          policy_sel; 
    logic                      enable;     
  } racl_range_t;
  
  typedef racl_policy_t [NrRaclPolicies-1:0] racl_policy_vec_t;
  
  parameter racl_policy_vec_t RACL_POLICY_VEC_DEFAULT = '0;
  
  parameter racl_range_t RACL_RANGE_T_DEFAULT = '0;
  
  parameter racl_role_vec_t RACL_POLICY_ROT_PRIVATE_RD = 2'h0;
  
  parameter racl_role_vec_t RACL_POLICY_ROT_PRIVATE_WR = 2'h0;
  
  typedef struct packed {
    logic                      valid;        
    logic                      overflow;     
    racl_role_t                racl_role;
    ctn_uid_t                  ctn_uid;
    logic                      read_access;  
    logic [top_pkg::TL_AW-1:0] request_address;
  } racl_error_log_t;
  
  function automatic racl_role_t tlul_extract_racl_role_bits(logic [tlul_pkg::RsvdWidth-1:0] rsvd);
    
    logic unused_rsvd_bits;
    unused_rsvd_bits = ^{rsvd};
    return racl_role_t'(rsvd[0:0]);
  endfunction
  
  function automatic ctn_uid_t tlul_extract_ctn_uid_bits(logic [tlul_pkg::RsvdWidth-1:0] rsvd);
    
    logic unused_rsvd_bits;
    unused_rsvd_bits = ^{rsvd};
    return ctn_uid_t'(rsvd[0:0]);
  endfunction
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
module prim_arbiter_fixed #(
  parameter int N   = 8,
  parameter int DW  = 32,
  
  
  parameter bit EnDataPort = 1,
  
  localparam int IdxW = $clog2(N)
) (
  
  input clk_i,
  input rst_ni,
  input        [ N-1:0]    req_i,
  input        [DW-1:0]    data_i [N],
  output logic [ N-1:0]    gnt_o,
  output logic [IdxW-1:0]  idx_o,
  output logic             valid_o,
  output logic [DW-1:0]    data_o,
  input                    ready_i
);
  `ASSERT_INIT(CheckNGreaterZero_A, N > 0)
  
  if (N == 1) begin : gen_degenerate_case
    assign valid_o  = req_i[0];
    assign data_o   = data_i[0];
    assign gnt_o[0] = valid_o & ready_i;
    assign idx_o    = '0;
  end else begin : gen_normal_case
    
    
    logic [2**(IdxW+1)-2:0]           req_tree;
    logic [2**(IdxW+1)-2:0]           gnt_tree;
    logic [2**(IdxW+1)-2:0][IdxW-1:0] idx_tree;
    logic [2**(IdxW+1)-2:0][DW-1:0]   data_tree;
    for (genvar level = 0; level < IdxW+1; level++) begin : gen_tree
      
      
      
      
      
      
      
      
      
      
      
      localparam int Base0 = (2**level)-1;
      localparam int Base1 = (2**(level+1))-1;
      for (genvar offset = 0; offset < 2**level; offset++) begin : gen_level
        localparam int Pa = Base0 + offset;
        localparam int C0 = Base1 + 2*offset;
        localparam int C1 = Base1 + 2*offset + 1;
        
        
        if (level == IdxW) begin : gen_leafs
          if (offset < N) begin : gen_assign
            
            assign req_tree[Pa]      = req_i[offset];
            assign idx_tree[Pa]      = offset;
            assign data_tree[Pa]     = data_i[offset];
            
            assign gnt_o[offset]     = gnt_tree[Pa];
          end else begin : gen_tie_off
            
            assign req_tree[Pa]  = '0;
            assign idx_tree[Pa]  = '0;
            assign data_tree[Pa] = '0;
            logic unused_sigs;
            assign unused_sigs = gnt_tree[Pa];
          end
        
        end else begin : gen_nodes
          
          logic sel; 
          always_comb begin : p_node
            
            sel = ~req_tree[C0];
            
            req_tree[Pa]  = req_tree[C0] | req_tree[C1];
            
            idx_tree[Pa]  = (sel) ? idx_tree[C1]  : idx_tree[C0];
            data_tree[Pa] = (sel) ? data_tree[C1] : data_tree[C0];
            
            gnt_tree[C0] = gnt_tree[Pa] & ~sel;
            gnt_tree[C1] = gnt_tree[Pa] &  sel;
          end
        end
      end : gen_level
    end : gen_tree
    
    if (EnDataPort) begin : gen_data_port
      assign data_o      = data_tree[0];
    end else begin : gen_no_dataport
      logic [DW-1:0] unused_data;
      assign unused_data = data_tree[0];
      assign data_o = '1;
    end
    assign idx_o       = idx_tree[0];
    assign valid_o     = req_tree[0];
    
    assign gnt_tree[0] = valid_o & ready_i;
  end
  
  
  
  
  
  `ASSERT_KNOWN(ValidKnown_A, valid_o)
  `ASSERT_KNOWN(GrantKnown_A, gnt_o)
  `ASSERT_KNOWN(IdxKnown_A, idx_o)
  
  `ASSERT(Priority_A, |req_i |-> req_i[idx_o] && (((N'(1'b1) << idx_o) - 1'b1) & req_i) == '0)
  
  `ASSERT(CheckHotOne_A, $onehot0(gnt_o))
  
  `ASSERT(GntImpliesReady_A, |gnt_o |-> ready_i)
  
  `ASSERT(GntImpliesValid_A, |gnt_o |-> valid_o)
  
  `ASSERT(ReqAndReadyImplyGrant_A, |req_i && ready_i |-> |gnt_o)
  
  `ASSERT(ReqImpliesValid_A, |req_i |-> valid_o)
  
  `ASSERT(ReadyAndValidImplyGrant_A, ready_i && valid_o |-> |gnt_o)
  
  `ASSERT(NoReadyValidNoGrant_A, !(ready_i || valid_o) |-> gnt_o == 0)
  
  `ASSERT(IndexIsCorrect_A, ready_i && valid_o |-> gnt_o[idx_o] && req_i[idx_o])
if (EnDataPort) begin: gen_data_port_assertion
  
  `ASSERT(DataFlow_A, ready_i && valid_o |-> data_o == data_i[idx_o])
end
endmodule : prim_arbiter_fixed

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
`ifndef PRIM_FIFO_ASSERT_SVH
`define PRIM_FIFO_ASSERT_SVH
`define ASSERT_PRIM_FIFO_SYNC_ERROR_TRIGGERS_ALERT(NAME_, HIER_, ALERT_, GATE_ = 0, MAX_CYCLES_ = `_SEC_CM_ALERT_MAX_CYC) \
  `ASSERT_PRIM_COUNT_ERROR_TRIGGER_ALERT(``NAME_``WptrCheck_A,                                                            \
                                         HIER_.gen_normal_fifo.u_fifo_cnt.gen_secure_ptrs.u_wptr,                         \
                                         ALERT_,                                                                          \
                                         GATE_,                                                                           \
                                         MAX_CYCLES_)                                                                     \
  `ASSERT_PRIM_COUNT_ERROR_TRIGGER_ALERT(``NAME_``RptrCheck_A,                                                            \
                                         HIER_.gen_normal_fifo.u_fifo_cnt.gen_secure_ptrs.u_rptr,                         \
                                         ALERT_,                                                                          \
                                         GATE_,                                                                           \
                                         MAX_CYCLES_)
`define ASSERT_PRIM_FIFO_SYNC_ERROR_TRIGGERS_ALERT1(NAME_, HIER_, ALERT_, GATE_ = 0, MAX_CYCLES_ = `_SEC_CM_ALERT_MAX_CYC) \
  `ASSERT_ERROR_TRIGGER_ALERT(``NAME_``FullCheck_A,                                                                        \
                              HIER_,                                                                                       \
                              ALERT_,                                                                                      \
                              GATE_,                                                                                       \
                              MAX_CYCLES_,                                                                                 \
                              err_o)
`define ASSERT_PRIM_FIFO_SYNC_ERROR_TRIGGERS_ALERT1_IN(NAME_, HIER_, ALERT_, GATE_ = 0, MAX_CYCLES_ = 2) \
  `ASSERT_ERROR_TRIGGER_ALERT_IN(``NAME_``FullCheck_A,                                                   \
                                 HIER_,                                                                  \
                                 ALERT_,                                                                 \
                                 GATE_,                                                                  \
                                 MAX_CYCLES_,                                                            \
                                 err_o)
`endif 
module prim_fifo_sync #(
  parameter int unsigned Width       = 16,
  parameter bit Pass                 = 1'b1, 
  parameter int unsigned Depth       = 4,
  parameter bit OutputZeroIfEmpty    = 1'b1, 
  parameter bit NeverClears          = 1'b0, 
  parameter bit Secure               = 1'b0, 
  
  localparam int          DepthW     = prim_util_pkg::vbits(Depth+1)
) (
  input                   clk_i,
  input                   rst_ni,
  
  input                   clr_i,
  
  input                   wvalid_i,
  output                  wready_o,
  input   [Width-1:0]     wdata_i,
  
  output                  rvalid_o,
  input                   rready_i,
  output  [Width-1:0]     rdata_o,
  
  output                  full_o,
  output  [DepthW-1:0]    depth_o,
  output                  err_o
);
  
  if (Depth == 0) begin : gen_passthru_fifo
    `ASSERT_INIT(paramCheckPass, Pass == 1)
    assign depth_o = 1'b0; 
    
    assign rvalid_o = wvalid_i;
    assign rdata_o = wdata_i;
    
    assign wready_o = rready_i;
    assign full_o = 1'b1;
    
    logic unused_clr;
    assign unused_clr = clr_i;
    
    assign err_o = 1'b 0;
  
  end else if (Depth == 1) begin : gen_singleton_fifo
    
    logic full_d, full_q;
    assign full_o = full_q;
    assign depth_o = full_q;
    assign wready_o = ~full_q;
    
    
    assign rvalid_o = full_q || (Pass && wvalid_i);
    
    
    
    
    
    assign full_d = (rvalid_o ? !rready_i : wvalid_i) && !clr_i;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        full_q <= 1'b0;
      end else begin
        full_q <= full_d;
      end
    end
    logic [Width-1:0] storage;
    always_ff @(posedge clk_i) begin
      if (wvalid_i && wready_o) storage <= wdata_i;
    end
    logic [Width-1:0] rdata_int;
    assign rdata_int = (full_q || Pass == 1'b0) ? storage : wdata_i;
    assign rdata_o = (OutputZeroIfEmpty && !rvalid_o) ? Width'(0) : rdata_int;
    
    
    
    
    
    
    
    if (!Secure) begin : gen_not_secure
      assign err_o = 1'b0;
    end else begin : gen_secure
      logic inv_full;
      prim_flop #(
        .Width(1),
        .ResetValue(1'b1)
      ) u_inv_full (
        .clk_i,
        .rst_ni,
        .d_i (~full_d),
        .q_o (inv_full)
      );
      logic err_d, err_q;
      assign err_d = ~(full_q ^ inv_full);
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          err_q <= 1'b0;
        end else begin
          err_q <= err_d;
        end
      end
      assign err_o = err_q;
    end
  
  end else begin : gen_normal_fifo
    localparam int unsigned PtrW = prim_util_pkg::vbits(Depth);
    logic [PtrW-1:0] fifo_wptr, fifo_rptr;
    logic            fifo_incr_wptr, fifo_incr_rptr, fifo_empty;
    
    logic under_rst;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        under_rst <= 1'b1;
      end else if (under_rst) begin
        under_rst <= ~under_rst;
      end
    end
    logic empty;
    
    
    
    assign wready_o = ~full_o & ~under_rst;
    prim_fifo_sync_cnt #(
      .Depth(Depth),
      .Secure(Secure),
      .NeverClears(NeverClears)
    ) u_fifo_cnt (
      .clk_i,
      .rst_ni,
      .clr_i,
      .incr_wptr_i(fifo_incr_wptr),
      .incr_rptr_i(fifo_incr_rptr),
      .wptr_o(fifo_wptr),
      .rptr_o(fifo_rptr),
      .full_o,
      .empty_o(fifo_empty),
      .depth_o,
      .err_o
    );
    assign fifo_incr_wptr = wvalid_i & wready_o;
    assign fifo_incr_rptr = rvalid_o & rready_i & ~under_rst;
    logic [Depth-1:0][Width-1:0] storage;
    logic [Width-1:0] storage_rdata;
    assign storage_rdata = storage[fifo_rptr];
    always_ff @(posedge clk_i)
      if (fifo_incr_wptr) begin
        storage[fifo_wptr] <= wdata_i;
      end
    logic [Width-1:0] rdata_int;
    if (Pass == 1'b1) begin : gen_pass
      assign rdata_int = (fifo_empty && wvalid_i) ? wdata_i : storage_rdata;
      assign empty = fifo_empty & ~wvalid_i;
      assign rvalid_o = ~empty & ~under_rst;
    end else begin : gen_nopass
      assign rdata_int = storage_rdata;
      assign empty = fifo_empty;
      assign rvalid_o = ~empty;
    end
    if (OutputZeroIfEmpty == 1'b1) begin : gen_output_zero
      assign rdata_o = empty ? Width'(0) : rdata_int;
    end else begin : gen_no_output_zero
      assign rdata_o = rdata_int;
    end
    `ASSERT(depthShallNotExceedParamDepth, !empty |-> depth_o <= DepthW'(Depth))
    `ASSERT(OnlyRvalidWhenNotUnderRst_A, rvalid_o -> ~under_rst)
  end 
  if (NeverClears) begin : gen_never_clears
    `ASSERT(NeverClears_A, !clr_i)
  end
  
  
  
  `ASSERT_KNOWN_IF(DataKnown_A, rdata_o, rvalid_o)
  `ASSERT_KNOWN(DepthKnown_A, depth_o)
  `ASSERT_KNOWN(RvalidKnown_A, rvalid_o)
  `ASSERT_KNOWN(WreadyKnown_A, wready_o)
`ifdef INC_ASSERT
  
  
  
  
  
  
  
  logic unused_assert_connected;
  if (Depth == 1 && Secure) begin : gen_secure_singleton
    `ASSERT_INIT_NET(AssertConnected_A, unused_assert_connected === 1'b1)
  end
`endif
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
module prim_fifo_sync_cnt #(
  
  parameter int unsigned Depth = 4,
  
  parameter bit Secure = 1'b0,
  
  parameter bit NeverClears = 1'b0,
  
  localparam int unsigned PtrW = prim_util_pkg::vbits(Depth),
  
  localparam int unsigned DepthW = prim_util_pkg::vbits(Depth+1)
) (
  input clk_i,
  input rst_ni,
  input clr_i,
  input incr_wptr_i,
  input incr_rptr_i,
  
  output logic [PtrW-1:0] wptr_o,
  output logic [PtrW-1:0] rptr_o,
  output logic full_o,
  output logic empty_o,
  
  
  output logic [DepthW-1:0] depth_o,
  output logic err_o
);
  
  localparam int unsigned WrapPtrW = PtrW + 1;
  logic [WrapPtrW-1:0] wptr_wrap_cnt_q, wptr_wrap_set_cnt,
                       rptr_wrap_cnt_q, rptr_wrap_set_cnt;
  
  assign wptr_o = wptr_wrap_cnt_q[PtrW-1:0];
  assign rptr_o = rptr_wrap_cnt_q[PtrW-1:0];
  
  logic wptr_wrap_msb, rptr_wrap_msb;
  assign wptr_wrap_msb = wptr_wrap_cnt_q[WrapPtrW-1];
  assign rptr_wrap_msb = rptr_wrap_cnt_q[WrapPtrW-1];
  
  logic wptr_wrap_set, rptr_wrap_set;
  assign wptr_wrap_set = incr_wptr_i & (wptr_o == PtrW'(Depth-1));
  assign rptr_wrap_set = incr_rptr_i & (rptr_o == PtrW'(Depth-1));
  
  assign wptr_wrap_set_cnt = {~wptr_wrap_msb, {(WrapPtrW-1){1'b0}}};
  assign rptr_wrap_set_cnt = {~rptr_wrap_msb, {(WrapPtrW-1){1'b0}}};
  
  assign full_o = wptr_wrap_cnt_q == (rptr_wrap_cnt_q ^ {1'b1, {(WrapPtrW-1){1'b0}}});
  
  assign empty_o = wptr_wrap_cnt_q == rptr_wrap_cnt_q;
  
  
  
  
  
  assign depth_o = full_o                         ? DepthW'(Depth) :
                   wptr_wrap_msb == rptr_wrap_msb ? DepthW'(wptr_o) - DepthW'(rptr_o) :
                   DepthW'(Depth) - DepthW'(rptr_o) + DepthW'(wptr_o);
  if (Secure) begin : gen_secure_ptrs
    logic wptr_err;
    prim_count #(
      .Width(WrapPtrW),
      .PossibleActions((NeverClears ? prim_count_pkg::action_mask_t'(0) : prim_count_pkg::Clr) |
                       prim_count_pkg::Set | prim_count_pkg::Incr)
    ) u_wptr (
      .clk_i,
      .rst_ni,
      .clr_i,
      .set_i(wptr_wrap_set),
      .set_cnt_i(wptr_wrap_set_cnt),
      .incr_en_i(incr_wptr_i),
      .decr_en_i(1'b0),
      .step_i(WrapPtrW'(1'b1)),
      .commit_i(1'b1),
      .cnt_o(wptr_wrap_cnt_q),
      .cnt_after_commit_o(),
      .err_o(wptr_err)
    );
    logic rptr_err;
    prim_count #(
      .Width(WrapPtrW),
      .PossibleActions((NeverClears ? prim_count_pkg::action_mask_t'(0) : prim_count_pkg::Clr) |
                       prim_count_pkg::Set | prim_count_pkg::Incr)
    ) u_rptr (
      .clk_i,
      .rst_ni,
      .clr_i,
      .set_i(rptr_wrap_set),
      .set_cnt_i(rptr_wrap_set_cnt),
      .incr_en_i(incr_rptr_i),
      .decr_en_i(1'b0),
      .step_i(WrapPtrW'(1'b1)),
      .commit_i(1'b1),
      .cnt_o(rptr_wrap_cnt_q),
      .cnt_after_commit_o(),
      .err_o(rptr_err)
    );
    assign err_o = wptr_err | rptr_err;
  end else begin : gen_normal_ptrs
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        wptr_wrap_cnt_q <= {WrapPtrW{1'b0}};
      end else if (clr_i) begin
        wptr_wrap_cnt_q <= {WrapPtrW{1'b0}};
      end else if (wptr_wrap_set) begin
        wptr_wrap_cnt_q <= wptr_wrap_set_cnt;
      end else if (incr_wptr_i) begin
        wptr_wrap_cnt_q <= wptr_wrap_cnt_q + {{(WrapPtrW-1){1'b0}}, 1'b1};
      end
    end
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        rptr_wrap_cnt_q <= {WrapPtrW{1'b0}};
      end else if (clr_i) begin
        rptr_wrap_cnt_q <= {WrapPtrW{1'b0}};
      end else if (rptr_wrap_set) begin
        rptr_wrap_cnt_q <= rptr_wrap_set_cnt;
      end else if (incr_rptr_i) begin
        rptr_wrap_cnt_q <= rptr_wrap_cnt_q + {{(WrapPtrW-1){1'b0}}, 1'b1};
      end
    end
    assign err_o = '0;
  end
  if (NeverClears) begin : gen_never_clears
    `ASSERT(NeverClears_A, !clr_i)
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
module prim_intr_hw # (
  
  
  parameter int unsigned Width = 1,
  parameter bit          FlopOutput = 1,
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  parameter              IntrT = "Event" 
) (
  
  input  clk_i,
  input  rst_ni,
  input  [Width-1:0]  event_intr_i,
  
  input  [Width-1:0]  reg2hw_intr_enable_q_i,
  input  [Width-1:0]  reg2hw_intr_test_q_i,
  input               reg2hw_intr_test_qe_i,
  input  [Width-1:0]  reg2hw_intr_state_q_i,
  output              hw2reg_intr_state_de_o,
  output [Width-1:0]  hw2reg_intr_state_d_o,
  
  output logic [Width-1:0]  intr_o
);
  logic [Width-1:0] status; 
  if (IntrT == "Event") begin : g_intr_event
    logic  [Width-1:0]    new_event;
    assign new_event =
               (({Width{reg2hw_intr_test_qe_i}} & reg2hw_intr_test_q_i) | event_intr_i);
    assign hw2reg_intr_state_de_o = |new_event;
    
    
    assign hw2reg_intr_state_d_o  =  new_event | reg2hw_intr_state_q_i;
    assign status = reg2hw_intr_state_q_i ;
  end : g_intr_event
  else if (IntrT == "Status") begin : g_intr_status
    logic [Width-1:0] test_q; 
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) test_q <= '0;
      else if (reg2hw_intr_test_qe_i) test_q <= reg2hw_intr_test_q_i;
    end
    
    assign hw2reg_intr_state_de_o = 1'b 1; 
    assign hw2reg_intr_state_d_o  = event_intr_i | test_q;
    assign status = event_intr_i | test_q;
    
    
    logic unused_reg2hw;
    assign unused_reg2hw = ^reg2hw_intr_state_q_i;
  end : g_intr_status
  if (FlopOutput == 1) begin : gen_flop_intr_output
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        intr_o <= '0;
      end else begin
        intr_o <= status & reg2hw_intr_enable_q_i;
      end
    end
  end else begin : gen_intr_passthrough_output
    logic unused_clk;
    logic unused_rst_n;
    assign unused_clk = clk_i;
    assign unused_rst_n = rst_ni;
    assign intr_o = reg2hw_intr_state_q_i & reg2hw_intr_enable_q_i;
  end
  `ASSERT_INIT(IntrTKind_A, IntrT inside {"Event", "Status"})
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

module prim_onehot_enc #(
  parameter int unsigned OneHotWidth = 32,
  localparam int unsigned InputWidth = $clog2(OneHotWidth)
) (
  input  logic [InputWidth-1:0]  in_i,
  input  logic                   en_i, 
  output logic [OneHotWidth-1:0] out_o
);
  for (genvar i = 0; i < OneHotWidth; ++i) begin : g_out
    assign out_o[i] = (in_i == i) & en_i;
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
module prim_packer_fifo #(
  parameter int InW  = 32,
  parameter int OutW = 8,
  parameter bit ClearOnRead = 1'b1, 
  
  localparam int MaxW = (InW > OutW) ? InW : OutW,
  localparam int MinW = (InW < OutW) ? InW : OutW,
  localparam int DepthW = $clog2(MaxW/MinW)
) (
  input logic clk_i ,
  input logic rst_ni,
  input logic               clr_i,
  input logic               wvalid_i,
  input logic  [InW-1:0]    wdata_i,
  output logic              wready_o,
  output logic              rvalid_o,
  output logic [OutW-1:0]   rdata_o,
  input logic               rready_i,
  output logic [DepthW:0]   depth_o
);
  localparam int unsigned   WidthRatio = MaxW / MinW;
  localparam bit [DepthW:0] FullDepth = WidthRatio[DepthW:0];
  localparam bit [DepthW:0] DepthOne = 1;
  
  logic  load_data;
  logic  clear_data;
  logic  clear_status;
  
  logic [DepthW:0] depth_q, depth_d;
  logic [MaxW-1:0] data_q, data_d;
  logic            clr_q, clr_d;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      depth_q <= '0;
      data_q  <= '0;
      clr_q   <= 1'b1;
    end else begin
      depth_q <= depth_d;
      data_q  <= data_d;
      clr_q   <= clr_d;
    end
  end
  
  assign clr_d = clr_i;
  assign depth_o = depth_q;
  if (InW < OutW) begin : gen_pack_mode
    logic [MaxW-1:0] wdata_shifted;
    assign wdata_shifted = {{OutW - InW{1'b0}}, wdata_i} << (depth_q*InW);
    assign clear_status = (rready_i && rvalid_o) || clr_q;
    assign clear_data = (ClearOnRead && clear_status) || clr_q;
    assign load_data = wvalid_i && wready_o;
    assign depth_d =  clear_status ? '0 :
           load_data ? (depth_q + DepthOne):
           depth_q;
    assign data_d = clear_data ? '0 :
           load_data ? (wdata_shifted | (depth_q == 0 ? '0 : data_q)) :
           data_q;
    
    assign wready_o = !(depth_q == FullDepth) && !clr_q;
    assign rdata_o =  data_q;
    assign rvalid_o = (depth_q == FullDepth) && !clr_q;
  end else begin : gen_unpack_mode
    logic [MaxW-1:0] rdata_shifted;
    logic            pull_data;
    logic [DepthW:0] ptr_q, ptr_d;
    logic [DepthW:0] lsb_is_one;
    logic [DepthW:0] max_value;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        ptr_q   <= '0;
      end else begin
        ptr_q   <= ptr_d;
      end
    end
    assign lsb_is_one = {{DepthW{1'b0}},1'b1};
    assign max_value = FullDepth;
    assign rdata_shifted = data_q >> ptr_q*OutW;
    assign clear_status = (rready_i && (depth_q == lsb_is_one)) || clr_q;
    assign clear_data = (ClearOnRead && clear_status) || clr_q;
    assign load_data = wvalid_i && wready_o;
    assign pull_data = rvalid_o && rready_i;
    assign depth_d =  clear_status ? '0 :
           load_data ? max_value :
           pull_data ? (depth_q - DepthOne) :
           depth_q;
    assign ptr_d =  clear_status ? '0 :
           pull_data ? (ptr_q + DepthOne) :
           ptr_q;
    assign data_d = clear_data ? '0 :
           load_data ? wdata_i :
           data_q;
    
    assign wready_o = (depth_q == '0) && !clr_q;
    assign rdata_o =  rdata_shifted[OutW-1:0];
    assign rvalid_o = !(depth_q == '0) && !clr_q;
    
    if (InW > OutW) begin : gen_unused
      logic [MaxW-MinW-1:0] unused_rdata_shifted;
      assign unused_rdata_shifted = rdata_shifted[MaxW-1:MinW];
    end
  end
  
  
  
  
  `ASSERT(ValidOPairedWithReadyI_A,
          rvalid_o && !rready_i && !clr_i |=> rvalid_o)
  
  `ASSERT(DataOStableWhenPending_A,
          ##1 rvalid_o && $past(rvalid_o)
          && !$past(rready_i) && !$past(clr_i) |-> $stable(rdata_o))
endmodule

module prim_racl_error_arb
  import top_racl_pkg::*;
#(
  parameter int unsigned N = 8
) (
  input  logic            clk_i,
  input  logic            rst_ni,
  input  racl_error_log_t error_log_i[N],
  output racl_error_log_t error_log_o
);
  
  logic [N-1:0] error_valid, any_valid_overflow;
  for (genvar i = 0; i < N; i++) begin : gen_extract_valid
    assign error_valid[i]        = error_log_i[i].valid;
    assign any_valid_overflow[i] = error_log_i[i].valid & error_log_i[i].overflow;
  end
  
  
  logic [$bits(racl_error_log_t)-1:0] racl_error_logic;
  racl_error_log_t                    racl_error_arb;
  logic [N-1:0]                       gnt;
  prim_arbiter_fixed #(
    .N  ( N                       ),
    .DW ( $bits(racl_error_log_t) )
  ) u_prim_err_arb (
    .clk_i,
    .rst_ni,
    .req_i    ( error_valid      ),
    .data_i   ( error_log_i      ),
    .gnt_o    ( gnt              ),
    .idx_o    (                  ),
    .valid_o  (                  ),
    .data_o   ( racl_error_logic ),
    .ready_i  ( 1'b1             )
  );
  assign racl_error_arb = racl_error_log_t'(racl_error_logic);
  
  
  
  
  logic overflow;
  assign overflow = |any_valid_overflow | (racl_error_arb.valid & |(error_valid & ~gnt));
  
  assign error_log_o.valid           = racl_error_arb.valid;
  assign error_log_o.racl_role       = racl_error_arb.racl_role;
  assign error_log_o.ctn_uid         = racl_error_arb.ctn_uid;
  assign error_log_o.read_access     = racl_error_arb.read_access;
  assign error_log_o.request_address = racl_error_arb.request_address;
  assign error_log_o.overflow        = overflow;
  
  logic unused_signals;
  assign unused_signals = racl_error_arb.overflow;
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
module tlul_adapter_racl
  import tlul_pkg::*;
  import prim_mubi_pkg::mubi4_t;
#(
  parameter bit EnableRacl             = 0,          
  parameter bit RaclErrorRsp           = EnableRacl, 
  parameter int RaclPolicySelNumRanges = 1           
) (
  input                                                          clk_i,
  input                                                          rst_ni,
  
  input  tlul_pkg::tl_h2d_t                                      tl_h2d_i,
  output tlul_pkg::tl_d2h_t                                      tl_d2h_o,
  output tlul_pkg::tl_h2d_t                                      tl_filtered_h2d_o,
  input  tlul_pkg::tl_d2h_t                                      tl_filtered_d2h_i,
  
  input  top_racl_pkg::racl_policy_vec_t                         racl_policies_i,
  output top_racl_pkg::racl_error_log_t                          racl_error_o,
  input  top_racl_pkg::racl_range_t [RaclPolicySelNumRanges-1:0] racl_policy_sel_ranges_i
);
  if (EnableRacl) begin : gen_racl_role_logic
    
    top_racl_pkg::racl_role_t racl_role;
    assign racl_role = top_racl_pkg::tlul_extract_racl_role_bits(tl_h2d_i.a_user.rsvd);
    top_racl_pkg::racl_role_vec_t racl_role_vec;
    prim_onehot_enc #(
      .OneHotWidth( $bits(top_racl_pkg::racl_role_vec_t) )
    ) u_racl_role_encode (
      .in_i ( racl_role     ),
      .en_i ( 1'b1          ),
      .out_o( racl_role_vec )
    );
    logic rd_req, wr_req, racl_read_allowed, racl_write_allowed, racl_error;
    logic [RaclPolicySelNumRanges-1:0] range_read_allowed;
    logic [RaclPolicySelNumRanges-1:0] range_write_allowed;
    for (genvar r = 0; r < RaclPolicySelNumRanges; r++) begin : gen_racl_range_check
      top_racl_pkg::racl_range_t range;
      top_racl_pkg::racl_policy_t policy;
      logic range_match;
      assign range = racl_policy_sel_ranges_i[r];
      assign policy = racl_policies_i[range.policy_sel];
      
      assign range_match = range.enable
                           & tl_h2d_i.a_address >= range.base
                           & tl_h2d_i.a_address <= range.limit;
      
      assign range_read_allowed[r]  = range_match & |(policy.read_perm  & racl_role_vec);
      assign range_write_allowed[r] = range_match & |(policy.write_perm & racl_role_vec);
    end
    assign racl_read_allowed  = |range_read_allowed;
    assign racl_write_allowed = |range_write_allowed;
    assign rd_req             = tl_h2d_i.a_valid & (tl_h2d_i.a_opcode == tlul_pkg::Get);
    assign wr_req             = tl_h2d_i.a_valid & (tl_h2d_i.a_opcode == tlul_pkg::PutFullData |
                                                    tl_h2d_i.a_opcode == tlul_pkg::PutPartialData);
    assign racl_error         = (rd_req & ~racl_read_allowed) | (wr_req & ~racl_write_allowed);
    assign racl_error_o.valid = racl_error & tl_d2h_o.a_ready;
    tlul_request_loopback #(
      .ErrorRsp ( RaclErrorRsp )
    ) u_loopback (
      .clk_i        ( clk_i             ),
      .rst_ni       ( rst_ni            ),
      .squash_req_i ( racl_error        ),
      .tl_h2d_i     ( tl_h2d_i          ),
      .tl_d2h_o     ( tl_d2h_o          ),
      .tl_h2d_o     ( tl_filtered_h2d_o ),
      .tl_d2h_i     ( tl_filtered_d2h_i )
    );
    
    assign racl_error_o.overflow    = 1'b0;
    assign racl_error_o.read_access = tl_h2d_i.a_opcode == tlul_pkg::Get;
    assign racl_error_o.racl_role   = racl_role;
    assign racl_error_o.ctn_uid     = top_racl_pkg::tlul_extract_ctn_uid_bits(tl_h2d_i.a_user.rsvd);
    assign racl_error_o.request_address = tl_h2d_i.a_address;
  end else begin : gen_no_racl_role_logic
    
    assign tl_filtered_h2d_o = tl_h2d_i;
    assign tl_d2h_o          = tl_filtered_d2h_i;
    assign racl_error_o      = '0;
    
    logic unused_signals;
    assign unused_signals = ^racl_policy_sel_ranges_i;
  end
  
  logic unused_policy_sel;
  assign unused_policy_sel = ^racl_policies_i;
  `ASSERT(RaclAdapterNumRanges, EnableRacl |-> RaclPolicySelNumRanges > 0)
  
  `ASSERT_KNOWN(RaclAdapterErrorKnown_A, racl_error_o.valid)
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
module tlul_adapter_reg_racl
  import tlul_pkg::*;
  import prim_mubi_pkg::mubi4_t;
#(
  parameter  bit CmdIntgCheck      = 0,           
  parameter  bit EnableRspIntgGen  = 0,           
  parameter  bit EnableDataIntgGen = 0,           
  parameter  int RegAw             = 8,           
  parameter  int RegDw             = 32,          
  parameter  int AccessLatency     = 0,           
  parameter  bit EnableRacl        = 0,           
  parameter  bit RaclErrorRsp      = EnableRacl,  
  parameter  top_racl_pkg::racl_policy_sel_t RaclPolicySelVec  = 0, 
                                                                    
  localparam int RegBw             = RegDw/8
) (
  input clk_i,
  input rst_ni,
  
  input  tl_h2d_t tl_i,
  output tl_d2h_t tl_o,
  
  input  mubi4_t  en_ifetch_i,
  output logic    intg_error_o,
  
  input  top_racl_pkg::racl_policy_vec_t racl_policies_i,
  output top_racl_pkg::racl_error_log_t  racl_error_o,
  
  output logic             re_o,
  output logic             we_o,
  output logic [RegAw-1:0] addr_o,
  output logic [RegDw-1:0] wdata_o,
  output logic [RegBw-1:0] be_o,
  input                    busy_i,
  
  
  input        [RegDw-1:0] rdata_i,
  
  input                    error_i
);
  tl_h2d_t tl_h2d_filtered;
  tl_d2h_t tl_d2h_filtered;
  if (EnableRacl) begin : gen_racl_role_logic
    
    top_racl_pkg::racl_role_t racl_role;
    assign racl_role = top_racl_pkg::tlul_extract_racl_role_bits(tl_i.a_user.rsvd);
    top_racl_pkg::racl_role_vec_t racl_role_vec;
    prim_onehot_enc #(
      .OneHotWidth( $bits(top_racl_pkg::racl_role_vec_t) )
    ) u_racl_role_encode (
      .in_i ( racl_role     ),
      .en_i ( 1'b1          ),
      .out_o( racl_role_vec )
    );
    logic rd_req, wr_req, racl_read_allowed, racl_write_allowed, racl_error;
    assign rd_req             = tl_i.a_valid & (tl_i.a_opcode == tlul_pkg::Get);
    assign wr_req             = tl_i.a_valid & (tl_i.a_opcode == tlul_pkg::PutFullData |
                                                tl_i.a_opcode == tlul_pkg::PutPartialData);
    assign racl_read_allowed  = (|(racl_policies_i[RaclPolicySelVec].read_perm  & racl_role_vec));
    assign racl_write_allowed = (|(racl_policies_i[RaclPolicySelVec].write_perm & racl_role_vec));
    assign racl_error         = (rd_req & ~racl_read_allowed) | (wr_req & ~racl_write_allowed);
    assign racl_error_o.valid = racl_error & tl_o.a_ready;
    tlul_request_loopback #(
      .ErrorRsp(RaclErrorRsp)
    ) u_loopback (
      .clk_i,
      .rst_ni,
      .squash_req_i ( racl_error      ),
      .tl_h2d_i     ( tl_i            ),
      .tl_d2h_o     ( tl_o            ),
      .tl_h2d_o     ( tl_h2d_filtered ),
      .tl_d2h_i     ( tl_d2h_filtered )
    );
    
    assign racl_error_o.overflow        = 1'b0;
    assign racl_error_o.read_access     = tl_i.a_opcode == tlul_pkg::Get;
    assign racl_error_o.racl_role       = racl_role;
    assign racl_error_o.ctn_uid         = top_racl_pkg::tlul_extract_ctn_uid_bits(tl_i.a_user.rsvd);
    assign racl_error_o.request_address = tl_i.a_address;
  end else begin : gen_no_racl_role_logic
    
    assign tl_h2d_filtered  = tl_i;
    assign tl_o             = tl_d2h_filtered;
    assign racl_error_o     = '0;
  end
  tlul_adapter_reg #(
    .CmdIntgCheck       (CmdIntgCheck),
    .EnableRspIntgGen   (EnableRspIntgGen),
    .EnableDataIntgGen  (EnableDataIntgGen),
    .RegAw              (RegAw),
    .RegDw              (RegDw),
    .AccessLatency      (AccessLatency)
  ) tlul_adapter_reg (
    .clk_i,
    .rst_ni,
    .tl_i(tl_h2d_filtered),
    .tl_o(tl_d2h_filtered),
    .en_ifetch_i,
    .intg_error_o,
    .re_o,
    .we_o,
    .addr_o,
    .wdata_o,
    .be_o,
    .busy_i,
    .rdata_i,
    .error_i
  );
  
  logic unused_policy;
  assign unused_policy = ^racl_policies_i;
  
  `ASSERT_KNOWN(RaclAdapterRegErrorKnown_A, racl_error_o.valid)
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
module tlul_adapter_sram
  import tlul_pkg::*;
  import prim_mubi_pkg::mubi4_t;
#(
  parameter int SramAw            = 12,
  parameter int SramDw            = 32, 
  parameter int SramDepth         = 2**SramAw, 
  parameter int Outstanding       = 1,  
  parameter int SramBusBankAW     = 12, 
                                        
  parameter bit ByteAccess        = 1,  
                                        
                                        
  parameter bit ErrOnWrite        = 0,  
  parameter bit ErrOnRead         = 0,  
  parameter bit CmdIntgCheck      = 0,  
  parameter bit EnableRspIntgGen  = 0,  
  parameter bit EnableDataIntgGen = 0,  
  parameter bit EnableDataIntgPt  = 0,  
  parameter bit SecFifoPtr        = 0,  
  parameter bit EnableReadback    = 0,  
  parameter bit DataXorAddr       = 0,  
  localparam int WidthMult        = SramDw / top_pkg::TL_DW,
  localparam int IntgWidth        = tlul_pkg::DataIntgWidth * WidthMult,
  localparam int DataOutW         = EnableDataIntgPt ? SramDw + IntgWidth : SramDw
) (
  input   clk_i,
  input   rst_ni,
  
  input   tl_h2d_t          tl_i,
  output  tl_d2h_t          tl_o,
  
  input   mubi4_t en_ifetch_i,
  
  output logic                 req_o,
  output mubi4_t               req_type_o,
  input                        gnt_i,
  output logic                 we_o,
  output logic [SramAw-1:0]    addr_o,
  output logic [DataOutW-1:0]  wdata_o,
  output logic [DataOutW-1:0]  wmask_o,
  output logic                 intg_error_o,
  output logic [RsvdWidth-1:0] user_rsvd_o,
  input        [DataOutW-1:0]  rdata_i,
  input                        rvalid_i,
  input        [1:0]           rerror_i, 
  output logic                 compound_txn_in_progress_o,
  input  mubi4_t               readback_en_i,
  output logic                 readback_error_o,
  input  logic                 wr_collision_i,
  input  logic                 write_pending_i
);
  localparam int SramByte = SramDw/8;
  localparam int DataBitWidth = prim_util_pkg::vbits(SramByte);
  localparam int WoffsetWidth = (SramByte == top_pkg::TL_DBW) ? 1 :
                                DataBitWidth - prim_util_pkg::vbits(top_pkg::TL_DBW);
  logic error_det; 
  logic error_internal; 
  logic wr_attr_error;
  logic instr_error;
  logic wr_vld_error;
  logic rd_vld_error;
  logic rsp_fifo_error;
  logic sramreqfifo_error;
  logic reqfifo_error;
  logic intg_error;
  logic tlul_error;
  logic readback_error;
  logic sram_byte_readback_error;
  logic addr_miss_error;
  
  logic readback_error_q;
  if (EnableReadback) begin : gen_cmd_readback_check
    assign readback_error = sram_byte_readback_error;
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        readback_error_q <= '0;
      end else if (readback_error) begin
        readback_error_q <= 1'b1;
      end
    end
  end else begin : gen_no_readback_check
    logic unused_sram_byte_readback_error;
    assign unused_sram_byte_readback_error = sram_byte_readback_error;
    assign readback_error = '0;
    assign readback_error_q = '0;
  end
  
  
  assign readback_error_o = readback_error | readback_error_q;
  
  if (CmdIntgCheck) begin : gen_cmd_intg_check
    tlul_cmd_intg_chk u_cmd_intg_chk (
      .tl_i(tl_i),
      .err_o (intg_error)
    );
  end else begin : gen_no_cmd_intg_check
    assign intg_error = '0;
  end
  
  logic intg_error_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      intg_error_q <= '0;
    end else if (intg_error || rsp_fifo_error || sramreqfifo_error || reqfifo_error) begin
      intg_error_q <= 1'b1;
    end
  end
  
  
  assign intg_error_o = intg_error | rsp_fifo_error | sramreqfifo_error |
      reqfifo_error | intg_error_q;
  
  
  assign wr_attr_error = (ByteAccess == 0) &&
                         (tl_i.a_opcode == PutFullData || tl_i.a_opcode == PutPartialData) &&
                         (tl_i.a_mask != '1 || tl_i.a_size != 2'h2);
  
  
  assign instr_error = prim_mubi_pkg::mubi4_test_invalid(tl_i.a_user.instr_type) |
                       (prim_mubi_pkg::mubi4_test_true_strict(tl_i.a_user.instr_type) &
                        prim_mubi_pkg::mubi4_test_false_loose(en_ifetch_i));
  if (ErrOnWrite == 1) begin : gen_no_writes
    assign wr_vld_error = tl_i.a_opcode != Get;
  end else begin : gen_writes_allowed
    assign wr_vld_error = 1'b0;
  end
  if (ErrOnRead == 1) begin: gen_no_reads
    assign rd_vld_error = tl_i.a_opcode == Get;
  end else begin : gen_reads_allowed
    assign rd_vld_error = 1'b0;
  end
  if (2**SramAw == SramDepth) begin : gen_no_addr_chk
    
    
    assign addr_miss_error = 1'b0;
  end else begin : gen_addr_chk
    
    
    assign addr_miss_error = tl_i.a_address[DataBitWidth +: SramAw] >= SramDepth;
  end
  
  tlul_err u_err (
    .clk_i,
    .rst_ni,
    .tl_i(tl_i),
    .err_o (tlul_error)
  );
  
  assign error_det = wr_attr_error | wr_vld_error | rd_vld_error | instr_error |
                     tlul_error    | intg_error   | addr_miss_error;
  
  tl_h2d_t tl_i_int;
  
  tl_d2h_t tl_o_int;
  
  tl_d2h_t tl_out;
  
  logic unused_tl_i_int;
  assign unused_tl_i_int = ^tl_i_int;
  tlul_rsp_intg_gen #(
    .EnableRspIntgGen(EnableRspIntgGen),
    .EnableDataIntgGen(EnableDataIntgGen),
    .RspIntgInIsZero(1'b1)
  ) u_rsp_gen (
    .tl_i(tl_out),
    .tl_o
  );
  
  tlul_sram_byte #(
    .EnableIntg(ByteAccess & EnableDataIntgPt & !ErrOnWrite),
    .Outstanding(Outstanding),
    .EnableReadback(EnableReadback)
  ) u_sram_byte (
    .clk_i,
    .rst_ni,
    .tl_i,
    .tl_o(tl_out),
    .tl_sram_o(tl_i_int),
    .tl_sram_i(tl_o_int),
    .error_i(error_det),
    .error_o(error_internal),
    .alert_o(sram_byte_readback_error),
    .compound_txn_in_progress_o,
    .readback_en_i,
    .wr_collision_i,
    .write_pending_i
  );
  typedef struct packed {
    logic [top_pkg::TL_DBW-1:0] mask ; 
    logic [WoffsetWidth-1:0]    woffset ; 
  } sram_req_t ;
  typedef struct packed {
    logic [SramBusBankAW-1:0] addr; 
  } sram_req_addr_t ;
  typedef struct packed {
    logic                       is_read ;
    logic                       error ;
    prim_mubi_pkg::mubi4_t      instr_type;
    logic [top_pkg::TL_SZW-1:0] size ;
    logic [top_pkg::TL_AIW-1:0] source ;
  } req_t ;
  typedef struct packed {
    logic [top_pkg::TL_DW-1:0] data ;
    logic [DataIntgWidth-1:0]  data_intg ;
    logic                      error ;
  } rsp_t ;
  localparam int SramReqWidth = $bits(sram_req_t);
  localparam int SramReqFifoWidth = SramReqWidth + (DataXorAddr ? SramBusBankAW : 0);
  localparam int ReqFifoWidth = $bits(req_t) ;
  localparam int RspFifoWidth = $bits(rsp_t) ;
  
  
  
  
  logic reqfifo_wvalid, reqfifo_wready;
  logic reqfifo_rvalid, reqfifo_rready;
  req_t reqfifo_wdata,  reqfifo_rdata;
  logic sramreqfifo_wvalid, sramreqfifo_wready;
  logic sramreqfifo_rready;
  
  
  
  sram_req_t                   sram_req_wdata, sram_req_rdata;
  logic [SramBusBankAW-1:0]    sram_addr_wdata, sram_addr_rdata;
  logic [SramReqFifoWidth-1:0] sramreqfifo_wdata, sramreqfifo_rdata;
  if (DataXorAddr) begin : gen_combine_with_addr
    assign sramreqfifo_wdata = {sram_addr_wdata, sram_req_wdata};
    assign {sram_addr_rdata, sram_req_rdata} = sramreqfifo_rdata;
  end else begin : gen_combine_without_addr
    assign sramreqfifo_wdata = sram_req_wdata;
    assign sram_addr_rdata = '0;
    assign sram_req_rdata = sramreqfifo_rdata;
  end
  logic rspfifo_wvalid, rspfifo_wready;
  logic rspfifo_rvalid, rspfifo_rready;
  rsp_t rspfifo_wdata,  rspfifo_rdata;
  logic a_ack, d_ack, sram_ack;
  assign a_ack    = tl_i_int.a_valid & tl_o_int.a_ready ;
  assign d_ack    = tl_o_int.d_valid & tl_i_int.d_ready ;
  assign sram_ack = req_o        & gnt_i ;
  
  logic d_valid, d_error;
  always_comb begin
    d_valid = 1'b0;
    if (reqfifo_rvalid) begin
      if (reqfifo_rdata.error) begin
        
        d_valid = 1'b1;
      end else if (reqfifo_rdata.is_read) begin
        d_valid = rspfifo_rvalid;
      end else begin
        
        d_valid = 1'b1;
      end
    end else begin
      d_valid = 1'b0;
    end
  end
  always_comb begin
    d_error = 1'b0;
    if (reqfifo_rvalid) begin
      if (reqfifo_rdata.is_read) begin
        d_error = rspfifo_rdata.error | reqfifo_rdata.error;
      end else begin
        d_error = reqfifo_rdata.error;
      end
    end else begin
      d_error = 1'b0;
    end
  end
  logic vld_rd_rsp;
  assign vld_rd_rsp = d_valid & rspfifo_rvalid & reqfifo_rdata.is_read;
  
  
  logic [top_pkg::TL_DW-1:0] error_blanking_data;
  assign error_blanking_data = (prim_mubi_pkg::mubi4_test_true_strict(reqfifo_rdata.instr_type)) ?
                                 DataWhenInstrError :
                                 DataWhenError;
  
  
  
  logic [top_pkg::TL_DW-1:0] unused_instr, unused_data;
  logic [DataIntgWidth-1:0] error_instr_integ, error_data_integ;
  tlul_data_integ_enc u_tlul_data_integ_enc_instr (
    .data_i(DataMaxWidth'(DataWhenInstrError)),
    .data_intg_o({error_instr_integ, unused_instr})
  );
  tlul_data_integ_enc u_tlul_data_integ_enc_data (
    .data_i(DataMaxWidth'(DataWhenError)),
    .data_intg_o({error_data_integ, unused_data})
  );
  logic [DataIntgWidth-1:0] error_blanking_integ;
  assign error_blanking_integ = (prim_mubi_pkg::mubi4_test_true_strict(reqfifo_rdata.instr_type)) ?
                                 error_instr_integ :
                                 error_data_integ;
  logic [top_pkg::TL_DW-1:0] d_data;
  assign d_data = (vld_rd_rsp & ~d_error) ? rspfifo_rdata.data   
                                          : error_blanking_data; 
  
  
  logic [DataIntgWidth-1:0] data_intg;
  assign data_intg = (reqfifo_rdata.error) ? error_blanking_integ    : 
                     (vld_rd_rsp)          ? rspfifo_rdata.data_intg : 
                     prim_secded_pkg::SecdedInv3932ZeroEcc;            
  
  
  
  
  
  logic missed_err_gnt_d, missed_err_gnt_q;
  
  assign missed_err_gnt_d = error_internal & tl_i_int.a_valid & ~tl_o_int.a_ready;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      missed_err_gnt_q <= 1'b0;
    end else begin
      missed_err_gnt_q <= missed_err_gnt_d;
    end
  end
  assign tl_o_int = '{
      d_valid  : d_valid ,
      d_opcode : (d_valid && !reqfifo_rdata.is_read) ? AccessAck : AccessAckData,
      d_param  : '0,
      d_size   : (d_valid) ? reqfifo_rdata.size : '0,
      d_source : (d_valid) ? reqfifo_rdata.source : '0,
      d_sink   : 1'b0,
      d_data   : d_data,
      d_user   : '{default: '0, data_intg: data_intg},
      d_error  : d_valid && d_error,
      a_ready  : (gnt_i | missed_err_gnt_q) & reqfifo_wready & sramreqfifo_wready
  };
  
  
  
  
  
  
  assign req_o       = tl_i_int.a_valid & reqfifo_wready & ~error_internal;
  assign req_type_o  = tl_i_int.a_user.instr_type;
  assign we_o        = tl_i_int.a_valid & (tl_i_int.a_opcode inside {PutFullData, PutPartialData});
  assign addr_o      = (tl_i_int.a_valid) ? tl_i_int.a_address[DataBitWidth+:SramAw] : '0;
  assign user_rsvd_o = (tl_i_int.a_valid) ? tl_i_int.a_user.rsvd : '0;
  
  
  
  logic [WoffsetWidth-1:0] woffset;
  if (top_pkg::TL_DW != SramDw) begin : gen_wordwidthadapt
    assign woffset = tl_i_int.a_address[DataBitWidth-1:prim_util_pkg::vbits(top_pkg::TL_DBW)];
  end else begin : gen_no_wordwidthadapt
    assign woffset = '0;
  end
  
  
  
  localparam int DataWidth = EnableDataIntgPt ? top_pkg::TL_DW + DataIntgWidth : top_pkg::TL_DW;
  
  logic [WidthMult-1:0][DataWidth-1:0] wmask_combined;
  logic [WidthMult-1:0][DataWidth-1:0] wdata_combined;
  
  logic [WidthMult-1:0][top_pkg::TL_DW-1:0] wmask_int;
  logic [WidthMult-1:0][top_pkg::TL_DW-1:0] wdata_int;
  
  logic [WidthMult-1:0][DataIntgWidth-1:0] wmask_intg;
  logic [WidthMult-1:0][DataIntgWidth-1:0] wdata_intg;
  always_comb begin
    wmask_int = '0;
    wdata_int = '0;
    if (tl_i_int.a_valid) begin
      for (int i = 0 ; i < top_pkg::TL_DW/8 ; i++) begin
        wmask_int[woffset][8*i +: 8] = {8{tl_i_int.a_mask[i]}};
        wdata_int[woffset][8*i +: 8] = (tl_i_int.a_mask[i] && we_o) ? tl_i_int.a_data[8*i+:8] : '0;
      end
    end
  end
  always_comb begin
    wmask_intg  = '0;
    wdata_intg  = '0;
    if (tl_i_int.a_valid) begin
      wmask_intg[woffset] = {DataIntgWidth{1'b1}};
      wdata_intg[woffset] = tl_i_int.a_user.data_intg;
    end
  end
  for (genvar i = 0; i < WidthMult; i++) begin : gen_write_output
    if (EnableDataIntgPt) begin : gen_combined_output
      assign wmask_combined[i] = {wmask_intg[i], wmask_int[i]};
      assign wdata_combined[i] = {wdata_intg[i], wdata_int[i]};
    end else begin : gen_ft_output
      logic unused_w;
      assign wmask_combined[i] = wmask_int[i];
      assign wdata_combined[i] = wdata_int[i];
      assign unused_w = |wmask_intg & |wdata_intg;
    end
  end
  assign wmask_o = wmask_combined;
  assign wdata_o = wdata_combined;
  assign reqfifo_wvalid = a_ack ; 
  assign reqfifo_wdata  = '{
    is_read: tl_i_int.a_opcode == Get,
    error:  error_internal,
    instr_type: tl_i_int.a_user.instr_type,
    size:   tl_i_int.a_size,
    source: tl_i_int.a_source
  }; 
  assign reqfifo_rready = d_ack ;
  
  assign sram_req_wdata = '{
    mask    : tl_i_int.a_mask,
    woffset : woffset
  };
  assign sramreqfifo_wvalid = sram_ack & ~we_o;
  assign sramreqfifo_rready = rspfifo_wvalid;
  assign rspfifo_wvalid = rvalid_i & reqfifo_rvalid;
  assign sram_addr_wdata = tl_i_int.a_address[DataBitWidth+:SramBusBankAW];
  
  logic [WidthMult-1:0][DataWidth-1:0] rdata_reshaped;
  logic [DataWidth-1:0] rdata_tlword;
  
  assign rdata_reshaped = rdata_i;
  if (EnableDataIntgPt) begin : gen_no_rmask
    always_comb begin
      
      
      rdata_tlword = prim_secded_pkg::SecdedInv3932ZeroWord;
      
      
      
      if (|sram_req_rdata.mask) begin
        
        if (DataXorAddr) begin : gen_data_xor_addr
          
          
          
          
          
          rdata_tlword = {
              rdata_reshaped[sram_req_rdata.woffset][DataWidth-1:top_pkg::TL_DW],
              rdata_reshaped[sram_req_rdata.woffset][top_pkg::TL_DW-1:0] ^
                  {{(top_pkg::TL_DW-SramBusBankAW){1'b0}}, sram_addr_rdata}
          };
        end else begin: gen_no_data_xor_addr
          rdata_tlword = rdata_reshaped[sram_req_rdata.woffset];
        end
      end
    end
  end else begin : gen_rmask
    logic [DataWidth-1:0] rmask;
    always_comb begin
      rmask = '0;
      for (int i = 0 ; i < top_pkg::TL_DW/8 ; i++) begin
        rmask[8*i +: 8] = {8{sram_req_rdata.mask[i]}};
      end
    end
    
    assign rdata_tlword = rdata_reshaped[sram_req_rdata.woffset] & rmask;
  end
  assign rspfifo_wdata  = '{
    data      : rdata_tlword[top_pkg::TL_DW-1:0],
    data_intg : EnableDataIntgPt ? rdata_tlword[DataWidth-1 -: DataIntgWidth] : '0,
    error     : rerror_i[1] 
  };
  assign rspfifo_rready = reqfifo_rdata.is_read & ~reqfifo_rdata.error & reqfifo_rready;
  
  logic unused_rerror;
  assign unused_rerror = rerror_i[0];
  
  
  
  
  
  
  
  
  
  prim_fifo_sync #(
    .Width       (ReqFifoWidth),
    .Pass        (1'b0),
    .Depth       (Outstanding),
    .NeverClears (1'b1),
    .Secure      (SecFifoPtr)
  ) u_reqfifo (
    .clk_i,
    .rst_ni,
    .clr_i   (1'b0),
    .wvalid_i(reqfifo_wvalid),
    .wready_o(reqfifo_wready),
    .wdata_i (reqfifo_wdata),
    .rvalid_o(reqfifo_rvalid),
    .rready_i(reqfifo_rready),
    .rdata_o (reqfifo_rdata),
    .full_o  (),
    .depth_o (),
    .err_o   (reqfifo_error)
  );
  
  
  
  
  prim_fifo_sync #(
    .Width             (SramReqFifoWidth),
    .Pass              (1'b0),
    .Depth             (Outstanding),
    .NeverClears       (1'b1),
    .Secure            (SecFifoPtr),
    .OutputZeroIfEmpty (1)
  ) u_sramreqfifo (
    .clk_i,
    .rst_ni,
    .clr_i   (1'b0),
    .wvalid_i(sramreqfifo_wvalid),
    .wready_o(sramreqfifo_wready),
    .wdata_i (sramreqfifo_wdata),
    .rvalid_o(),
    .rready_i(sramreqfifo_rready),
    .rdata_o (sramreqfifo_rdata),
    .full_o  (),
    .depth_o (),
    .err_o   (sramreqfifo_error)
  );
  if (!DataXorAddr) begin : gen_no_data_xor_addr_fifo
    
    
    logic unused_sram_addresses;
    assign unused_sram_addresses = ^{sram_addr_wdata, sram_addr_rdata};
  end
  
  
  
  
  
  
  prim_fifo_sync #(
    .Width       (RspFifoWidth),
    .Pass        (1'b1),
    .Depth       (Outstanding),
    .NeverClears (1'b1),
    .Secure      (SecFifoPtr)
  ) u_rspfifo (
    .clk_i,
    .rst_ni,
    .clr_i   (1'b0),
    .wvalid_i(rspfifo_wvalid),
    .wready_o(rspfifo_wready),
    .wdata_i (rspfifo_wdata),
    .rvalid_o(rspfifo_rvalid),
    .rready_i(rspfifo_rready),
    .rdata_o (rspfifo_rdata),
    .full_o  (),
    .depth_o (),
    .err_o   (rsp_fifo_error)
  );
  
  `ASSERT(rvalidHighReqFifoEmpty, rvalid_i |-> reqfifo_rvalid)
  
  
  `ASSERT(rvalidHighWhenRspFifoFull, rvalid_i |-> rspfifo_wready)
  
  `ASSERT_INIT(adapterNoReadOrWrite, (ErrOnWrite & ErrOnRead) == 0)
  `ASSERT_INIT(SramDwHasByteGranularity_A, SramDw % 8 == 0)
  `ASSERT_INIT(SramDwIsMultipleOfTlulWidth_A, SramDw % top_pkg::TL_DW == 0)
  
  
  `ASSERT_INIT(SramAwCorrectlySizedForDepth_A,
      ((SramDepth & (SramDepth - 1)) == 0) ? (2**SramAw == SramDepth) :
                                             ($clog2(SramDepth) == SramAw))
  
  `ASSERT_INIT(DataIntgOptions_A, ~(EnableDataIntgGen & EnableDataIntgPt))
  
  `ASSERT_KNOWN(ReqOutKnown_A,   req_o  )
  `ASSERT_KNOWN(WeOutKnown_A,    we_o   )
  `ASSERT_KNOWN(AddrOutKnown_A,  addr_o )
  `ASSERT_KNOWN(WdataOutKnown_A, wdata_o)
  `ASSERT_KNOWN(WmaskOutKnown_A, wmask_o)
  
  
  
  
  
  
  
  
  `ASSERT_KNOWN(TlOutValidKnown_A, tl_o.d_valid)
  `ASSERT(TlOutKnownIfFifoKnown_A, !$isunknown(rspfifo_rdata) -> !$isunknown(tl_o))
  
  `ASSERT(DValidNeedsReqFifoRValid_A, d_valid -> reqfifo_rvalid)
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
module tlul_adapter_sram_racl
  import tlul_pkg::*;
  import prim_mubi_pkg::mubi4_t;
#(
  parameter int SramAw            = 12,
  parameter int SramDw            = 32,         
  parameter int Outstanding       = 1,          
  parameter int SramBusBankAW     = 12,         
                                                
  parameter bit ByteAccess        = 1,          
                                                
                                                
                                                
  parameter bit ErrOnWrite        = 0,          
  parameter bit ErrOnRead         = 0,          
  parameter bit CmdIntgCheck      = 0,          
  parameter bit EnableRspIntgGen  = 0,          
  parameter bit EnableDataIntgGen = 0,          
  parameter bit EnableDataIntgPt  = 0,          
  parameter bit SecFifoPtr        = 0,          
  parameter bit EnableReadback    = 0,          
  parameter bit DataXorAddr       = 0,          
  parameter bit EnableRacl        = 0,          
  parameter bit RaclErrorRsp      = EnableRacl, 
  parameter int RaclPolicySelNumRanges = 1,     
  localparam int WidthMult        = SramDw / top_pkg::TL_DW,
  localparam int IntgWidth        = tlul_pkg::DataIntgWidth * WidthMult,
  localparam int DataOutW         = EnableDataIntgPt ? SramDw + IntgWidth : SramDw
) (
  input   clk_i,
  input   rst_ni,
  
  input   tl_h2d_t          tl_i,
  output  tl_d2h_t          tl_o,
  
  input   mubi4_t en_ifetch_i,
  
  output logic                 req_o,
  output mubi4_t               req_type_o,
  input                        gnt_i,
  output logic                 we_o,
  output logic [SramAw-1:0]    addr_o,
  output logic [DataOutW-1:0]  wdata_o,
  output logic [DataOutW-1:0]  wmask_o,
  output logic                 intg_error_o,
  output logic [RsvdWidth-1:0] user_rsvd_o,
  input        [DataOutW-1:0]  rdata_i,
  input                        rvalid_i,
  input        [1:0]           rerror_i, 
  output logic                 compound_txn_in_progress_o,
  input  mubi4_t               readback_en_i,
  output logic                 readback_error_o,
  input  logic                 wr_collision_i,
  input  logic                 write_pending_i,
  
  input  top_racl_pkg::racl_policy_vec_t racl_policies_i,
  output top_racl_pkg::racl_error_log_t  racl_error_o,
  input  top_racl_pkg::racl_range_t [RaclPolicySelNumRanges-1:0] racl_policy_sel_ranges_i
);
  tl_h2d_t tl_h2d_filtered;
  tl_d2h_t tl_d2h_filtered;
  tlul_adapter_racl #(
    .EnableRacl               ( EnableRacl             ),
    .RaclErrorRsp             ( RaclErrorRsp           ),
    .RaclPolicySelNumRanges   ( RaclPolicySelNumRanges )
  ) tlul_adapter_racl(
    .clk_i                    ( clk_i                    ),
    .rst_ni                   ( rst_ni                   ),
    .tl_h2d_i                 ( tl_i                     ),
    .tl_d2h_o                 ( tl_o                     ),
    .tl_filtered_h2d_o        ( tl_h2d_filtered          ),
    .tl_filtered_d2h_i        ( tl_d2h_filtered          ),
    .racl_policies_i          ( racl_policies_i          ),
    .racl_error_o             ( racl_error_o             ),
    .racl_policy_sel_ranges_i ( racl_policy_sel_ranges_i )
  );
  tlul_adapter_sram #(
    .SramAw            ( SramAw            ),
    .SramDw            ( SramDw            ),
    .Outstanding       ( Outstanding       ),
    .SramBusBankAW     ( SramBusBankAW     ),
    .ByteAccess        ( ByteAccess        ),
    .ErrOnWrite        ( ErrOnWrite        ),
    .ErrOnRead         ( ErrOnRead         ),
    .CmdIntgCheck      ( CmdIntgCheck      ),
    .EnableRspIntgGen  ( EnableRspIntgGen  ),
    .EnableDataIntgGen ( EnableDataIntgGen ),
    .EnableDataIntgPt  ( EnableDataIntgPt  ),
    .SecFifoPtr        ( SecFifoPtr        ),
    .EnableReadback    ( EnableReadback    ),
    .DataXorAddr       ( DataXorAddr       )
  ) tlul_adapter_sram (
    .clk_i,
    .rst_ni,
    .tl_i(tl_h2d_filtered),
    .tl_o(tl_d2h_filtered),
    .en_ifetch_i,
    .req_o,
    .req_type_o,
    .gnt_i,
    .we_o,
    .addr_o,
    .wdata_o,
    .wmask_o,
    .intg_error_o,
    .user_rsvd_o,
    .rdata_i,
    .rvalid_i,
    .rerror_i,
    .compound_txn_in_progress_o,
    .readback_en_i,
    .readback_error_o,
    .wr_collision_i,
    .write_pending_i
  );
  
  `ASSERT_KNOWN(RaclAdapterSramErrorKnown_A, racl_error_o.valid)
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

module tlul_err_resp #(
  
  
  parameter bit ReturnBlankResp = 0
) (
  input                     clk_i,
  input                     rst_ni,
  input  tlul_pkg::tl_h2d_t tl_h_i,
  output tlul_pkg::tl_d2h_t tl_h_o
);
  import tlul_pkg::*;
  import prim_mubi_pkg::*;
  tl_a_op_e                          err_opcode;
  logic [$bits(tl_h_i.a_source)-1:0] err_source;
  logic [$bits(tl_h_i.a_size)-1:0]   err_size;
  logic                              err_rsp_pending;
  mubi4_t                            err_instr_type;
  tlul_pkg::tl_d2h_t                 tl_h_o_int;
  tlul_rsp_intg_gen #(
    .EnableRspIntgGen(1),
    .EnableDataIntgGen(1)
  ) u_intg_gen (
    .tl_i(tl_h_o_int),
    .tl_o(tl_h_o)
  );
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      err_rsp_pending <= 1'b0;
      err_source      <= {top_pkg::TL_AIW{1'b0}};
      err_opcode      <= Get;
      err_size        <= '0;
      err_instr_type  <= MuBi4False;
    end else if (err_rsp_pending && tl_h_i.d_ready) begin
      err_rsp_pending <= 1'b0;
    end else if (tl_h_i.a_valid && tl_h_o_int.a_ready) begin
      err_rsp_pending <= 1'b1;
      err_source      <= tl_h_i.a_source;
      err_opcode      <= tl_h_i.a_opcode;
      err_size        <= tl_h_i.a_size;
      err_instr_type  <= tl_h_i.a_user.instr_type;
    end
  end
  assign tl_h_o_int.a_ready  = ~err_rsp_pending;
  assign tl_h_o_int.d_valid  = err_rsp_pending;
  if (ReturnBlankResp) begin : gen_zero_resp
    assign tl_h_o_int.d_data = '0;
  end else begin : gen_err_resp
    assign tl_h_o_int.d_data   = (mubi4_test_true_strict(err_instr_type)) ? DataWhenInstrError :
                                                                            DataWhenError;
  end
  assign tl_h_o_int.d_source = err_source;
  assign tl_h_o_int.d_sink   = '0;
  assign tl_h_o_int.d_param  = '0;
  assign tl_h_o_int.d_size   = err_size;
  assign tl_h_o_int.d_opcode = (err_opcode == Get) ? AccessAckData : AccessAck;
  assign tl_h_o_int.d_user   = '0;
  assign tl_h_o_int.d_error  = ~ReturnBlankResp;
  
  logic unused_tl_h;
  assign unused_tl_h = ^{tl_h_i, err_instr_type};
endmodule

module tlul_fifo_sync #(
  parameter bit          ReqPass = 1'b1,
  parameter bit          RspPass = 1'b1,
  parameter int unsigned ReqDepth = 2,
  parameter int unsigned RspDepth = 2,
  parameter int unsigned SpareReqW = 1,
  parameter int unsigned SpareRspW = 1
) (
  input                     clk_i,
  input                     rst_ni,
  input  tlul_pkg::tl_h2d_t tl_h_i,
  output tlul_pkg::tl_d2h_t tl_h_o,
  output tlul_pkg::tl_h2d_t tl_d_o,
  input  tlul_pkg::tl_d2h_t tl_d_i,
  input  [SpareReqW-1:0]    spare_req_i,
  output [SpareReqW-1:0]    spare_req_o,
  input  [SpareRspW-1:0]    spare_rsp_i,
  output [SpareRspW-1:0]    spare_rsp_o
);
  
  
  
  
  
  localparam int unsigned REQFIFO_INTG_WIDTH = tlul_pkg::H2DCmdIntgWidth + tlul_pkg::DataIntgWidth;
  localparam int unsigned REQFIFO_WIDTH = $bits(tlul_pkg::tl_h2d_t) -2 + SpareReqW -
                                            REQFIFO_INTG_WIDTH;
  prim_fifo_sync #(.Width(REQFIFO_WIDTH), .Pass(ReqPass), .Depth(ReqDepth)) reqfifo (
    .clk_i,
    .rst_ni,
    .clr_i         (1'b0          ),
    .wvalid_i      (tl_h_i.a_valid),
    .wready_o      (tl_h_o.a_ready),
    .wdata_i       ({tl_h_i.a_opcode,
                     tl_h_i.a_param,
                     tl_h_i.a_size,
                     tl_h_i.a_source,
                     tl_h_i.a_address,
                     tl_h_i.a_mask,
                     tl_h_i.a_data,
                     tl_h_i.a_user.rsvd,
                     tl_h_i.a_user.instr_type,
                     spare_req_i}),
    .rvalid_o      (tl_d_o.a_valid),
    .rready_i      (tl_d_i.a_ready),
    .rdata_o       ({tl_d_o.a_opcode,
                     tl_d_o.a_param,
                     tl_d_o.a_size,
                     tl_d_o.a_source,
                     tl_d_o.a_address,
                     tl_d_o.a_mask,
                     tl_d_o.a_data,
                     tl_d_o.a_user.rsvd,
                     tl_d_o.a_user.instr_type,
                     spare_req_o}),
    .full_o        (),
    .depth_o       (),
    .err_o         ());
  
  localparam int NumBufferBitsReqFifoIntg = $bits({
    tl_h_i.a_valid,
    tl_d_i.a_ready
  });
  logic [NumBufferBitsReqFifoIntg-1:0] buf_reqfifo_intg_in, buf_reqfifo_intg_out;
  logic reqfifo_intg_a_valid_buf;
  logic reqfifo_intg_a_ready_buf;
  assign buf_reqfifo_intg_in = {
    tl_h_i.a_valid,
    tl_d_i.a_ready
  };
  assign {
    reqfifo_intg_a_valid_buf,
    reqfifo_intg_a_ready_buf
  } = buf_reqfifo_intg_out;
  prim_buf #(
    .Width(NumBufferBitsReqFifoIntg)
  ) u_reqfifo_intg_prim_buf (
    .in_i(buf_reqfifo_intg_in),
    .out_o(buf_reqfifo_intg_out)
  );
  prim_fifo_sync #(.Width(REQFIFO_INTG_WIDTH), .Pass(ReqPass), .Depth(ReqDepth)) reqfifo_intg (
    .clk_i,
    .rst_ni,
    .clr_i         (1'b0          ),
    .wvalid_i      (reqfifo_intg_a_valid_buf),
    .wready_o      (),
    .wdata_i       ({tl_h_i.a_user.cmd_intg,
                     tl_h_i.a_user.data_intg}),
    .rvalid_o      (),
    .rready_i      (reqfifo_intg_a_ready_buf),
    .rdata_o       ({tl_d_o.a_user.cmd_intg,
                     tl_d_o.a_user.data_intg}),
    .full_o        (),
    .depth_o       (),
    .err_o         ());
  
  
  
  localparam int unsigned RSPFIFO_INTG_WIDTH = $bits(tlul_pkg::tl_d_user_t);
  localparam int unsigned RSPFIFO_WIDTH = $bits(tlul_pkg::tl_d2h_t) -2 + SpareRspW -
                                            RSPFIFO_INTG_WIDTH;
  prim_fifo_sync #(.Width(RSPFIFO_WIDTH), .Pass(RspPass), .Depth(RspDepth)) rspfifo (
    .clk_i,
    .rst_ni,
    .clr_i         (1'b0          ),
    .wvalid_i      (tl_d_i.d_valid),
    .wready_o      (tl_d_o.d_ready),
    .wdata_i       ({tl_d_i.d_opcode,
                     tl_d_i.d_param ,
                     tl_d_i.d_size  ,
                     tl_d_i.d_source,
                     tl_d_i.d_sink  ,
                     (tl_d_i.d_opcode == tlul_pkg::AccessAckData) ? tl_d_i.d_data :
                                                                    {top_pkg::TL_DW{1'b0}} ,
                     tl_d_i.d_error ,
                     spare_rsp_i}),
    .rvalid_o      (tl_h_o.d_valid),
    .rready_i      (tl_h_i.d_ready),
    .rdata_o       ({tl_h_o.d_opcode,
                     tl_h_o.d_param ,
                     tl_h_o.d_size  ,
                     tl_h_o.d_source,
                     tl_h_o.d_sink  ,
                     tl_h_o.d_data  ,
                     tl_h_o.d_error ,
                     spare_rsp_o}),
    .full_o        (),
    .depth_o       (),
    .err_o         ());
  
  localparam int NumBufferBitsRspFifoIntg = $bits({
    tl_d_i.d_valid,
    tl_h_i.d_ready
  });
  logic [NumBufferBitsRspFifoIntg-1:0] buf_rspfifo_intg_in, buf_rspfifo_intg_out;
  logic rspfifo_intg_d_valid_buf;
  logic rspfifo_intg_d_ready_buf;
  assign buf_rspfifo_intg_in = {
    tl_d_i.d_valid,
    tl_h_i.d_ready
  };
  assign {
    rspfifo_intg_d_valid_buf,
    rspfifo_intg_d_ready_buf
  } = buf_rspfifo_intg_out;
  prim_buf #(
    .Width(NumBufferBitsRspFifoIntg)
  ) u_rspfifo_intg_prim_buf (
    .in_i(buf_rspfifo_intg_in),
    .out_o(buf_rspfifo_intg_out)
  );
  prim_fifo_sync #(.Width(RSPFIFO_INTG_WIDTH), .Pass(RspPass), .Depth(RspDepth)) rspfifo_intg (
    .clk_i,
    .rst_ni,
    .clr_i         (1'b0          ),
    .wvalid_i      (rspfifo_intg_d_valid_buf),
    .wready_o      (),
    .wdata_i       (tl_d_i.d_user),
    .rvalid_o      (),
    .rready_i      (rspfifo_intg_d_ready_buf),
    .rdata_o       (tl_h_o.d_user),
    .full_o        (),
    .depth_o       (),
    .err_o         ());
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

module tlul_request_loopback
  import tlul_pkg::*;
#(
  parameter bit ErrorRsp = 1  
) (
  input  logic              clk_i,
  input  logic              rst_ni,
  input  logic              squash_req_i,
  input  tlul_pkg::tl_h2d_t tl_h2d_i,   
  output tlul_pkg::tl_d2h_t tl_d2h_o,   
  output tlul_pkg::tl_h2d_t tl_h2d_o,   
  input  tlul_pkg::tl_d2h_t tl_d2h_i    
);
  
  
  
  logic loopback_request;
  assign loopback_request = tl_h2d_i.a_valid & squash_req_i;
  tlul_pkg::tl_h2d_t tl_muxed_h2d [2];
  tlul_pkg::tl_d2h_t tl_muxed_d2h [2];
  tlul_pkg::tl_h2d_t tl_error_h2d;
  tlul_pkg::tl_d2h_t tl_error_d2h;
  
  assign tl_h2d_o = tl_muxed_h2d[0];
  assign tl_muxed_d2h[0] = tl_d2h_i;
  
  assign tl_error_h2d = tl_muxed_h2d[1];
  assign tl_muxed_d2h[1] = tl_error_d2h;
  
  
  
  tlul_socket_1n #(
    .N(2),
    .ExplicitErrs(0)
  ) u_socket (
    .clk_i,
    .rst_ni,
    .tl_h_i       (tl_h2d_i),
    .tl_h_o       (tl_d2h_o),
    .tl_d_o       (tl_muxed_h2d),
    .tl_d_i       (tl_muxed_d2h),
    .dev_select_i (loopback_request)
  );
  
  tlul_pkg::tl_d2h_t tl_razwi_rsp_pre_intg;
  logic loopback_valid_q;
  prim_flop #(
    .Width(1)
  ) u_loopback_valid (
    .clk_i  ( clk_i                ),
    .rst_ni ( rst_ni               ),
    .d_i    ( tl_error_h2d.a_valid ),
    .q_o    ( loopback_valid_q     )
  );
  logic [$bits(tlul_pkg::tl_d_op_e)-1:0] d_opcode_q;
  prim_flop #(
    .Width($bits(tlul_pkg::tl_d_op_e)),
    .ResetValue({AccessAck})
  ) u_rsp_opcode (
    .clk_i  ( clk_i                                                      ),
    .rst_ni ( rst_ni                                                     ),
    .d_i    ( (tl_error_h2d.a_opcode == Get) ? AccessAckData : AccessAck ),
    .q_o    ( d_opcode_q                                                 )
  );
  assign tl_razwi_rsp_pre_intg.d_opcode = tlul_pkg::tl_d_op_e'(d_opcode_q);
  prim_flop #(
    .Width(top_pkg::TL_SZW)
  ) u_rsp_size (
    .clk_i  ( clk_i                        ),
    .rst_ni ( rst_ni                       ),
    .d_i    ( tl_error_h2d.a_size          ),
    .q_o    ( tl_razwi_rsp_pre_intg.d_size )
  );
  prim_flop #(
    .Width(top_pkg::TL_AIW)
  ) u_rsp_source (
    .clk_i  ( clk_i                          ),
    .rst_ni ( rst_ni                         ),
    .d_i    ( tl_error_h2d.a_source          ),
    .q_o    ( tl_razwi_rsp_pre_intg.d_source )
  );
  
  assign tl_razwi_rsp_pre_intg.d_valid = loopback_valid_q;
  assign tl_razwi_rsp_pre_intg.a_ready = 1'b1;
  assign tl_razwi_rsp_pre_intg.d_param = '0;
  assign tl_razwi_rsp_pre_intg.d_sink  = '0;
  assign tl_razwi_rsp_pre_intg.d_data  = '0;
  assign tl_razwi_rsp_pre_intg.d_user  = '0;
  assign tl_razwi_rsp_pre_intg.d_error = ErrorRsp;
  
  tlul_rsp_intg_gen gen_intg_razwi_rsp (
    .tl_i ( tl_razwi_rsp_pre_intg ),
    .tl_o ( tl_error_d2h          )
  );
  
  logic unused_tlul_signals;
  assign unused_tlul_signals = ^{tl_error_h2d.a_param,
                                 tl_error_h2d.a_address,
                                 tl_error_h2d.a_mask,
                                 tl_error_h2d.a_data,
                                 tl_error_h2d.a_user,
                                 tl_error_h2d.d_ready};
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
module tlul_socket_1n #(
  parameter int unsigned  N            = 4,
  parameter bit           HReqPass     = 1'b1,
  parameter bit           HRspPass     = 1'b1,
  parameter bit [N-1:0]   DReqPass     = {N{1'b1}},
  parameter bit [N-1:0]   DRspPass     = {N{1'b1}},
  parameter bit [3:0]     HReqDepth    = 4'h1,
  parameter bit [3:0]     HRspDepth    = 4'h1,
  parameter bit [N*4-1:0] DReqDepth    = {N{4'h1}},
  parameter bit [N*4-1:0] DRspDepth    = {N{4'h1}},
  parameter bit           ExplicitErrs = 1'b1,
  
  
  
  localparam int unsigned NWD = $clog2(ExplicitErrs ? N+1 : N)
) (
  input                     clk_i,
  input                     rst_ni,
  input  tlul_pkg::tl_h2d_t tl_h_i,
  output tlul_pkg::tl_d2h_t tl_h_o,
  output tlul_pkg::tl_h2d_t tl_d_o    [N],
  input  tlul_pkg::tl_d2h_t tl_d_i    [N],
  input  [NWD-1:0]          dev_select_i
);
  `ASSERT_INIT(maxN, N < 64)
  
  
  
  
  logic [NWD-1:0] dev_select_t;
  tlul_pkg::tl_h2d_t   tl_t_o;
  tlul_pkg::tl_d2h_t   tl_t_i;
  tlul_fifo_sync #(
    .ReqPass(HReqPass),
    .RspPass(HRspPass),
    .ReqDepth(HReqDepth),
    .RspDepth(HRspDepth),
    .SpareReqW(NWD)
  ) fifo_h (
    .clk_i,
    .rst_ni,
    .tl_h_i,
    .tl_h_o,
    .tl_d_o     (tl_t_o),
    .tl_d_i     (tl_t_i),
    .spare_req_i (dev_select_i),
    .spare_req_o (dev_select_t),
    .spare_rsp_i (1'b0),
    .spare_rsp_o ());
  
  
  
  localparam int MaxOutstanding = 2**top_pkg::TL_AIW; 
  localparam int OutstandingW = $clog2(MaxOutstanding+1);
  logic [OutstandingW-1:0] num_req_outstanding;
  logic [NWD-1:0]          dev_select_outstanding;
  logic                    hold_all_requests;
  logic                    accept_t_req, accept_t_rsp;
  assign  accept_t_req = tl_t_o.a_valid & tl_t_i.a_ready;
  assign  accept_t_rsp = tl_t_i.d_valid & tl_t_o.d_ready;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      num_req_outstanding <= '0;
      dev_select_outstanding <= '0;
    end else if (accept_t_req) begin
      if (!accept_t_rsp) begin
        num_req_outstanding <= num_req_outstanding + 1'b1;
      end
      dev_select_outstanding <= dev_select_t;
    end else if (accept_t_rsp) begin
      num_req_outstanding <= num_req_outstanding - 1'b1;
    end
  end
  `ASSERT(NotOverflowed_A,
          accept_t_req && !accept_t_rsp -> num_req_outstanding <= MaxOutstanding)
  assign hold_all_requests =
      (num_req_outstanding != '0) &
      (dev_select_t != dev_select_outstanding);
  
  
  tlul_pkg::tl_h2d_t   tl_u_o [N+1];
  tlul_pkg::tl_d2h_t   tl_u_i [N+1];
  
  
  tlul_pkg::tl_a_user_t blanked_auser;
  assign blanked_auser = '{
    rsvd: tl_t_o.a_user.rsvd,
    instr_type: tl_t_o.a_user.instr_type,
    cmd_intg: tlul_pkg::get_bad_cmd_intg(tl_t_o),
    data_intg: tlul_pkg::get_bad_data_intg(tlul_pkg::BlankedAData)
  };
  
  for (genvar i = 0 ; i < N ; i++) begin : gen_u_o
    logic dev_select;
    assign dev_select = dev_select_t == NWD'(i) & ~hold_all_requests;
    assign tl_u_o[i].a_valid   = tl_t_o.a_valid & dev_select;
    assign tl_u_o[i].a_opcode  = tl_t_o.a_opcode;
    assign tl_u_o[i].a_param   = tl_t_o.a_param;
    assign tl_u_o[i].a_size    = tl_t_o.a_size;
    assign tl_u_o[i].a_source  = tl_t_o.a_source;
    assign tl_u_o[i].a_address = tl_t_o.a_address;
    assign tl_u_o[i].a_mask    = tl_t_o.a_mask;
    assign tl_u_o[i].a_data    = dev_select ?
                                 tl_t_o.a_data :
                                 tlul_pkg::BlankedAData;
    assign tl_u_o[i].a_user    = dev_select ?
                                 tl_t_o.a_user :
                                 blanked_auser;
    assign tl_u_o[i].d_ready   = tl_t_o.d_ready;
  end
  tlul_pkg::tl_d2h_t tl_t_p ;
  
  logic hfifo_reqready;
  always_comb begin
    hfifo_reqready = tl_u_i[N].a_ready; 
    for (int idx = 0 ; idx < N ; idx++) begin
      
      if (dev_select_t == NWD'(idx)) hfifo_reqready = tl_u_i[idx].a_ready;
    end
    if (hold_all_requests) hfifo_reqready = 1'b0;
  end
  
  
  assign tl_t_i.a_ready = tl_t_o.a_valid & hfifo_reqready;
  always_comb begin
    tl_t_p = tl_u_i[N];
    for (int idx = 0 ; idx < N ; idx++) begin
      if (dev_select_outstanding == NWD'(idx)) tl_t_p = tl_u_i[idx];
    end
  end
  assign tl_t_i.d_valid  = tl_t_p.d_valid ;
  assign tl_t_i.d_opcode = tl_t_p.d_opcode;
  assign tl_t_i.d_param  = tl_t_p.d_param ;
  assign tl_t_i.d_size   = tl_t_p.d_size  ;
  assign tl_t_i.d_source = tl_t_p.d_source;
  assign tl_t_i.d_sink   = tl_t_p.d_sink  ;
  assign tl_t_i.d_data   = tl_t_p.d_data  ;
  assign tl_t_i.d_user   = tl_t_p.d_user  ;
  assign tl_t_i.d_error  = tl_t_p.d_error ;
  
  for (genvar i = 0 ; i < N ; i++) begin : gen_dfifo
    tlul_fifo_sync #(
      .ReqPass(DReqPass[i]),
      .RspPass(DRspPass[i]),
      .ReqDepth(DReqDepth[i*4+:4]),
      .RspDepth(DRspDepth[i*4+:4])
    ) fifo_d (
      .clk_i,
      .rst_ni,
      .tl_h_i      (tl_u_o[i]),
      .tl_h_o      (tl_u_i[i]),
      .tl_d_o      (tl_d_o[i]),
      .tl_d_i      (tl_d_i[i]),
      .spare_req_i (1'b0),
      .spare_req_o (),
      .spare_rsp_i (1'b0),
      .spare_rsp_o ());
  end
  
  
  if ($clog2(N+1) <= NWD) begin : gen_err_resp
    assign tl_u_o[N].d_ready     = tl_t_o.d_ready;
    assign tl_u_o[N].a_valid     = tl_t_o.a_valid &
                                   (dev_select_t >= NWD'(N)) &
                                   ~hold_all_requests;
    assign tl_u_o[N].a_opcode    = tl_t_o.a_opcode;
    assign tl_u_o[N].a_param     = tl_t_o.a_param;
    assign tl_u_o[N].a_size      = tl_t_o.a_size;
    assign tl_u_o[N].a_source    = tl_t_o.a_source;
    assign tl_u_o[N].a_address   = tl_t_o.a_address;
    assign tl_u_o[N].a_mask      = tl_t_o.a_mask;
    assign tl_u_o[N].a_data      = tl_t_o.a_data;
    assign tl_u_o[N].a_user      = tl_t_o.a_user;
    tlul_err_resp err_resp (
      .clk_i,
      .rst_ni,
      .tl_h_i     (tl_u_o[N]),
      .tl_h_o     (tl_u_i[N])
    );
  end else begin : gen_no_err_resp 
    assign tl_u_o[N] = '0;
    assign tl_u_i[N] = '0;
    logic unused_sig;
    assign unused_sig = ^tl_u_o[N];
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
module tlul_sram_byte import tlul_pkg::*; #(
  parameter bit EnableIntg     = 0, 
  parameter int Outstanding    = 1,
  parameter bit EnableReadback = 0  
                                    
) (
  input clk_i,
  input rst_ni,
  input tl_h2d_t tl_i,
  output tl_d2h_t tl_o,
  output tl_h2d_t tl_sram_o,
  input tl_d2h_t tl_sram_i,
  
  
  
  
  input error_i,
  output logic error_o,
  output logic alert_o,
  output logic compound_txn_in_progress_o,
  input prim_mubi_pkg::mubi4_t readback_en_i,
  input logic wr_collision_i,
  input logic write_pending_i
);
  import prim_mubi_pkg::mubi4_t;
  import prim_mubi_pkg::mubi4_test_true_loose;
  import prim_mubi_pkg::mubi4_test_false_strict;
  import prim_mubi_pkg::MuBi4True;
  import prim_mubi_pkg::MuBi4False;
  import prim_mubi_pkg::MuBi4Width;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  localparam int StateWidth = 8;
  typedef enum logic [StateWidth-1:0] {
    StPassThru              = 8'b01111110,
    StWaitRd                = 8'b00000010,
    StWriteCmd              = 8'b11110001,
    StWrReadBackInit        = 8'b10011001,
    StWrReadBack            = 8'b00001111,
    StWrReadBackDWait       = 8'b00110000,
    StRdReadBack            = 8'b10101100,
    StRdReadBackDWait       = 8'b11000000,
    StByteWrReadBackInit    = 8'b01010111,
    StByteWrReadBack        = 8'b11100111,
    StByteWrReadBackDWait   = 8'b11111111
  } state_e;
  if (EnableIntg) begin : gen_integ_handling
    
    logic stall_host;
    logic wait_phase;
    logic rd_phase;
    logic rd_wait;
    logic wr_phase;
    logic rdback_phase;
    logic rdback_phase_wrreadback;
    logic rdback_wait;
    logic readback_err;
    logic sync_fifo_a_size_outputs_mismatch;
    logic sync_fifo_outputs_mismatch;
    logic tl_i_fifo_intg_err, tl_intg_err;
    state_e state_d, state_q;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        state_q <= StPassThru;
      end else begin
        state_q <= state_d;
      end
    end
    
    logic a_ack;  
    logic d_ack;  
    logic sram_a_ack; 
    logic sram_d_ack; 
    logic wr_txn;
    logic byte_wr_txn;
    logic byte_req_ack;
    logic hold_tx_data;
    localparam int unsigned PendingTxnCntW = prim_util_pkg::vbits(Outstanding+1);
    
    typedef struct packed {
      tl_a_op_e                       a_opcode;
      logic                     [2:0] a_param;
      logic     [top_pkg::TL_SZW-1:0] a_size;
      logic     [top_pkg::TL_AIW-1:0] a_source;
      logic      [top_pkg::TL_AW-1:0] a_address;
      logic     [top_pkg::TL_DBW-1:0] a_mask;
      logic      [top_pkg::TL_DW-1:0] a_data;
      logic [tlul_pkg::RsvdWidth-1:0] a_user_rsvd;
      prim_mubi_pkg::mubi4_t          a_user_instr_type;
    } tl_txn_data_t;
    typedef struct packed {
      logic [tlul_pkg::H2DCmdIntgWidth-1:0] a_user_cmd_intg;
      logic   [tlul_pkg::DataIntgWidth-1:0] a_user_data_intg;
    } tl_txn_intg_t;
    tl_txn_data_t held_data;
    tl_txn_intg_t held_intg;
    
    typedef struct packed {
      logic [PendingTxnCntW-1:0]  pending_txn_cnt;
      logic [top_pkg::TL_SZW-1:0] a_size;
      logic                       size_fifo_rdy;
    } sync_fifo_a_size_outputs_t;
    sync_fifo_a_size_outputs_t sync_fifo_a_size_outputs;
    sync_fifo_a_size_outputs_t sync_fifo_a_size_shadow_outputs;
    assign a_ack = tl_i.a_valid & tl_o.a_ready;
    assign d_ack = tl_o.d_valid & tl_i.d_ready;
    assign sram_a_ack = tl_sram_o.a_valid & tl_sram_i.a_ready;
    assign sram_d_ack = tl_sram_i.d_valid & tl_sram_o.d_ready;
    assign wr_txn = (tl_i.a_opcode == PutFullData) | (tl_i.a_opcode == PutPartialData);
    assign byte_req_ack = byte_wr_txn & a_ack & ~error_i;
    assign byte_wr_txn = tl_i.a_valid & ~&tl_i.a_mask & wr_txn;
    
    assign alert_o = readback_err | sync_fifo_a_size_outputs_mismatch |
      sync_fifo_outputs_mismatch | tl_intg_err;
    logic                     rdback_chk_ok;
    mubi4_t                   rdback_check_q, rdback_check_d;
    mubi4_t                   rdback_en_q, rdback_en_d;
    logic [31:0]              rdback_data_exp_q, rdback_data_exp_d;
    logic [DataIntgWidth-1:0] rdback_data_exp_intg_q, rdback_data_exp_intg_d;
    if (EnableReadback) begin : gen_readback_logic
      logic rdback_chk_ok_unbuf;
      assign rdback_chk_ok_unbuf = (rdback_data_exp_q == tl_sram_i.d_data);
      prim_sec_anchor_buf #(
        .Width(1)
      ) u_rdback_chk_ok_buf (
        .in_i (rdback_chk_ok_unbuf),
        .out_o(rdback_chk_ok)
      );
      prim_flop #(
        .Width(MuBi4Width),
        .ResetValue(MuBi4Width'(MuBi4False))
      ) u_rdback_check_flop (
        .clk_i,
        .rst_ni,
        .d_i(MuBi4Width'(rdback_check_d)),
        .q_o({rdback_check_q})
      );
      prim_flop #(
        .Width(MuBi4Width),
        .ResetValue(MuBi4Width'(MuBi4False))
      ) u_rdback_en_flop (
        .clk_i,
        .rst_ni,
        .d_i(MuBi4Width'(rdback_en_d)),
        .q_o({rdback_en_q})
      );
      prim_flop #(
        .Width(32),
        .ResetValue(0)
      ) u_rdback_data_exp (
        .clk_i,
        .rst_ni,
        .d_i(rdback_data_exp_d),
        .q_o(rdback_data_exp_q)
      );
      prim_flop #(
        .Width(DataIntgWidth),
        .ResetValue(0)
      ) u_rdback_data_exp_intg (
        .clk_i,
        .rst_ni,
        .d_i(rdback_data_exp_intg_d),
        .q_o(rdback_data_exp_intg_q)
      );
    
    
    
    
    `ASSERT(WRCollisionDuringReadBack_A, (rdback_phase | rdback_phase_wrreadback) &
        mubi4_test_true_loose(rdback_en_q) |-> !wr_collision_i)
    
    
    
    
    `ASSERT(NoPendingWriteAfterWrite_A, wr_phase & mubi4_test_true_loose(rdback_en_q)
        |=> write_pending_i)
    end else begin: gen_no_readback_logic
      assign rdback_chk_ok          = 1'b0;
      assign rdback_check_q         = MuBi4False;
      assign rdback_en_q            = MuBi4False;
      assign rdback_data_exp_q      = 1'b0;
      assign rdback_data_exp_intg_q = 1'b0;
      logic unused_rdback;
      assign unused_rdback = ^{rdback_check_d, rdback_data_exp_d, rdback_data_exp_intg_d,
                               rdback_en_d};
    end
    
    always_comb begin
      rd_wait = 1'b0;
      wait_phase = 1'b0;
      stall_host = 1'b0;
      wr_phase = 1'b0;
      rd_phase = 1'b0;
      rdback_phase = 1'b0;
      rdback_phase_wrreadback = 1'b0;
      rdback_wait = 1'b0;
      state_d = state_q;
      hold_tx_data = 1'b0;
      readback_err = 1'b0;
      rdback_check_d = rdback_check_q;
      rdback_en_d = rdback_en_q;
      rdback_data_exp_d  = rdback_data_exp_q;
      rdback_data_exp_intg_d  = rdback_data_exp_intg_q;
      unique case (state_q)
        StPassThru: begin
          if (mubi4_test_true_loose(rdback_en_q) && mubi4_test_true_loose(rdback_check_q)) begin
            
            
            
            
            rdback_wait    = 1'b1;
            rdback_check_d = MuBi4False;
            
            if (!rdback_chk_ok) begin
              readback_err = 1'b1;
            end
          end
          if (byte_wr_txn) begin
            rd_phase = 1'b1;
            if (byte_req_ack) begin
              state_d = StWaitRd;
            end
          end else if (a_ack && mubi4_test_true_loose(rdback_en_q) && !error_i) begin
            
            
            
            hold_tx_data = 1'b1;
            state_d      = wr_txn ? StWrReadBackInit : StRdReadBack;
          end
          if (!tl_sram_o.a_valid && !tl_o.d_valid &&
              mubi4_test_false_strict(rdback_check_q)) begin
            
            rdback_en_d = readback_en_i;
          end
        end
        
        
        
        StWaitRd: begin
          rd_phase = 1'b1;
          stall_host = 1'b1;
          if (sync_fifo_a_size_outputs.pending_txn_cnt == PendingTxnCntW'(1)) begin
            rd_wait = 1'b1;
            if (sram_d_ack) begin
              state_d = StWriteCmd;
            end
          end
        end
        StWriteCmd: begin
          stall_host = 1'b1;
          wr_phase = 1'b1;
          if (sram_a_ack) begin
            state_d = mubi4_test_true_loose(rdback_en_q) ? StByteWrReadBackInit : StPassThru;
            rdback_check_d         = mubi4_test_true_loose(rdback_en_q) ? MuBi4True : MuBi4False;
            rdback_data_exp_d      = tl_sram_o.a_data;
            rdback_data_exp_intg_d = tl_sram_o.a_user.data_intg;
          end
        end
        StWrReadBackInit: begin
          
          
          if (EnableReadback == 0) begin : gen_inv_state_StWrReadBackInit
            
            readback_err = 1'b1;
          end
          
          stall_host = 1'b1;
          
          
          if (sync_fifo_a_size_outputs.pending_txn_cnt == PendingTxnCntW'(1)) begin
            wait_phase  = 1'b1;
            
            
            rdback_check_d         = mubi4_test_true_loose(rdback_en_q) ? MuBi4True : MuBi4False;
            rdback_data_exp_d      = held_data.a_data;
            rdback_data_exp_intg_d = held_intg.a_user_data_intg;
            if (d_ack) begin
              
              
              state_d = StWrReadBack;
            end else  begin
              
              state_d = StWrReadBackDWait;
            end
          end
        end
        StWrReadBack: begin
          
          if (EnableReadback == 0) begin : gen_inv_state_StWrReadBack
            
            readback_err = 1'b1;
          end
          stall_host = 1'b1;
          rdback_phase = 1'b1;
          state_d = StPassThru;
        end
        StWrReadBackDWait: begin
          
          
          if (EnableReadback == 0) begin : gen_inv_state_StWrReadBackDWait
            
            readback_err = 1'b1;
          end
          
          wait_phase  = 1'b1;
          stall_host = 1'b1;
          if (d_ack) begin
            
            
            state_d = StWrReadBack;
          end
        end
        StByteWrReadBackInit: begin
          
          
          if (EnableReadback == 0) begin : gen_inv_state_StByteWrReadBackInit
            
            readback_err = 1'b1;
          end
          
          
          stall_host = 1'b1;
          
          
          wait_phase  = 1'b1;
          if (d_ack) begin
            
            
            state_d = StByteWrReadBack;
          end else begin
            
            
            
            
            state_d = StByteWrReadBackDWait;
          end
        end
        StByteWrReadBack: begin
          
          
          if (EnableReadback == 0) begin : gen_inv_state_StByteWrReadBack
            
            readback_err = 1'b1;
          end
          stall_host = 1'b1;
          rdback_phase_wrreadback = 1'b1;
          state_d = StPassThru;
        end
        StByteWrReadBackDWait: begin
          if (EnableReadback == 0) begin : gen_inv_state_StByteWrReadBackDWait
            
            readback_err = 1'b1;
          end
          stall_host = 1'b1;
          
          wait_phase  = 1'b1;
          if (d_ack) begin
            
            
            state_d = StByteWrReadBack;
          end
        end
        StRdReadBack: begin
          if (EnableReadback == 0) begin : gen_inv_state_StRdReadBack
            
            readback_err = 1'b1;
          end
          
          
          stall_host = 1'b1;
          
          
          if (sync_fifo_a_size_outputs.pending_txn_cnt == PendingTxnCntW'(1)) begin
            rdback_phase = 1'b1;
            if (d_ack) begin
              state_d                = StPassThru;
              
              rdback_check_d         = mubi4_test_true_loose(rdback_en_q) ? MuBi4True : MuBi4False;
              rdback_data_exp_d      = tl_o.d_data;
              rdback_data_exp_intg_d = tl_o.d_user.data_intg;
            end else  begin
              
              state_d = StRdReadBackDWait;
            end
          end
        end
        StRdReadBackDWait : begin
          if (EnableReadback == 0) begin : gen_inv_state_StRdReadBackDWait
            
            readback_err = 1'b1;
          end
          stall_host = 1'b1;
          if (d_ack) begin
            
            
            state_d                = StPassThru;
            
            rdback_check_d         = mubi4_test_true_loose(rdback_en_q) ? MuBi4True : MuBi4False;
            rdback_data_exp_d      = tl_o.d_data;
            rdback_data_exp_intg_d = tl_o.d_user.data_intg;
          end
        end
        default: begin
          readback_err = 1'b1;
        end
      endcase 
    end
    tl_txn_data_t txn_data;
    tl_txn_intg_t txn_intg;
    logic fifo_rdy_data, fifo_rdy_intg;
    logic txn_data_intg_wr;
    localparam int TxnDataWidth = $bits(tl_txn_data_t);
    localparam int TxnIntgWidth = $bits(tl_txn_intg_t);
    assign txn_data = '{
      a_opcode: tl_i.a_opcode,
      a_param: tl_i.a_param,
      a_size: tl_i.a_size,
      a_source: tl_i.a_source,
      a_address: tl_i.a_address,
      a_mask: tl_i.a_mask,
      a_data: tl_i.a_data,
      a_user_rsvd: tl_i.a_user.rsvd,
      a_user_instr_type: tl_i.a_user.instr_type
    };
    assign txn_intg = '{
      a_user_cmd_intg: tl_i.a_user.cmd_intg,
      a_user_data_intg: tl_i.a_user.data_intg
    };
    assign txn_data_intg_wr = hold_tx_data | byte_req_ack;
    prim_fifo_sync #(
      .Width(TxnDataWidth),
      .Pass(1'b0),
      .Depth(1),
      .OutputZeroIfEmpty(1'b0),
      .NeverClears(1'b1)
    ) u_sync_fifo_data (
      .clk_i,
      .rst_ni,
      .clr_i(1'b0),
      .wvalid_i(txn_data_intg_wr),
      .wready_o(fifo_rdy_data),
      .wdata_i(txn_data),
      .rvalid_o(),
      .rready_i(sram_a_ack),
      .rdata_o(held_data),
      .full_o(),
      .depth_o(),
      .err_o()
    );
     
    localparam int NumBufferBitsSyncIntg = $bits({
      txn_data_intg_wr,
      sram_a_ack
    });
    logic [NumBufferBitsSyncIntg-1:0] buf_sync_fifo_intg_in, buf_sync_fifo_intg_out;
    logic txn_data_intg_wr_buf;
    logic sram_a_ack_buf;
    assign buf_sync_fifo_intg_in = {
      txn_data_intg_wr,
      sram_a_ack
    };
    assign {
      txn_data_intg_wr_buf,
      sram_a_ack_buf
    } = buf_sync_fifo_intg_out;
    prim_buf #(
      .Width(NumBufferBitsSyncIntg)
    ) u_sync_fifo_intg_prim_buf (
      .in_i(buf_sync_fifo_intg_in),
      .out_o(buf_sync_fifo_intg_out)
    );
    prim_fifo_sync #(
      .Width(TxnIntgWidth),
      .Pass(1'b0),
      .Depth(1),
      .OutputZeroIfEmpty(1'b0),
      .NeverClears(1'b1)
    ) u_sync_fifo_intg (
      .clk_i,
      .rst_ni,
      .clr_i(1'b0),
      .wvalid_i(txn_data_intg_wr_buf),
      .wready_o(fifo_rdy_intg),
      .wdata_i(txn_intg),
      .rvalid_o(),
      .rready_i(sram_a_ack_buf),
      .rdata_o(held_intg),
      .full_o(),
      .depth_o(),
      .err_o()
    );
    
    assign sync_fifo_outputs_mismatch = (fifo_rdy_data != fifo_rdy_intg);
    
    tl_a_user_t tl_i_fifo_a_user;
    tl_h2d_t tl_i_fifo;
    assign tl_i_fifo_a_user = '{
      rsvd: held_data.a_user_rsvd,
      instr_type: held_data.a_user_instr_type,
      cmd_intg: held_intg.a_user_cmd_intg,
      data_intg: held_intg.a_user_data_intg
    };
    assign tl_i_fifo = '{
      a_valid: sram_a_ack,
      a_opcode: held_data.a_opcode,
      a_param: held_data.a_param,
      a_size: held_data.a_size,
      a_source: held_data.a_source,
      a_address: held_data.a_address,
      a_mask: held_data.a_mask,
      a_data: held_data.a_data,
      a_user: tl_i_fifo_a_user,
      d_ready:  1'b1
    };
    tlul_cmd_intg_chk u_cmd_intg_chk (
      .tl_i(tl_i_fifo),
      .err_o (tl_i_fifo_intg_err)
    );
    
    
    
    
    logic enable_intg_check_cmp_q;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        enable_intg_check_cmp_q <= 1'b0;
      end else if (txn_data_intg_wr)begin
        enable_intg_check_cmp_q <= 1'b1;
      end
    end
    assign tl_intg_err = enable_intg_check_cmp_q & tl_i_fifo_intg_err;
    
    logic [top_pkg::TL_DW-1:0] rsp_data;
    always_ff @(posedge clk_i) begin
      if (sram_d_ack && rd_wait) begin
        rsp_data <= tl_sram_i.d_data;
      end
    end
    
    
    
    
    logic [top_pkg::TL_DW-1:0] combined_data, unused_data;
    always_comb begin
      for (int i = 0; i < top_pkg::TL_DBW; i++) begin
        combined_data[i*8 +: 8] = held_data.a_mask[i] ?
                                  held_data.a_data[i*8 +: 8] :
                                  rsp_data[i*8 +: 8];
      end
    end
    
    
    
    logic [tlul_pkg::DataIntgWidth-1:0] data_intg;
    tlul_data_integ_enc u_tlul_data_integ_enc (
      .data_i(combined_data),
      .data_intg_o({data_intg, unused_data})
    );
    tl_a_user_t combined_user;
    always_comb begin
      combined_user.cmd_intg   = held_intg.a_user_cmd_intg;
      combined_user.data_intg  = data_intg;
      combined_user.rsvd       = held_data.a_user_rsvd;
      combined_user.instr_type = held_data.a_user_instr_type;
    end
    localparam int unsigned AccessSize = $clog2(top_pkg::TL_DBW);
    always_comb begin
      
      tl_sram_o = tl_i;
      
      tl_sram_o.d_ready = tl_i.d_ready | rd_wait | rdback_wait;
      
      
      
      
      
      
      if (wr_phase | rdback_phase | rdback_phase_wrreadback) begin
        tl_sram_o.a_valid   = 1'b1;
        
        tl_sram_o.a_opcode  = wr_phase ? PutFullData : Get;
        
        
        tl_sram_o.a_size =
            (wr_phase | rdback_phase_wrreadback) ? top_pkg::TL_SZW'(AccessSize) : held_data.a_size;
        tl_sram_o.a_mask =
            (wr_phase | rdback_phase_wrreadback) ? '{default: '1}               : held_data.a_mask;
        
        
        tl_sram_o.a_address = held_data.a_address;
        tl_sram_o.a_address[AccessSize-1:0] =
            (wr_phase | rdback_phase_wrreadback) ? '0 : held_data.a_address[AccessSize-1:0];
        tl_sram_o.a_source  = held_data.a_source;
        tl_sram_o.a_param   = held_data.a_param;
        tl_sram_o.a_data    = wr_phase ? combined_data : '0;
        tl_sram_o.a_user    = wr_phase ? combined_user : '0;
      
      end else if (rd_phase) begin
        
        tl_sram_o.a_address[AccessSize-1:0] = '0;
        
        if (!error_i || stall_host) begin
          
          
          tl_sram_o.a_size    = top_pkg::TL_SZW'(AccessSize);
          tl_sram_o.a_mask    = '{default: '1};
          
          tl_sram_o.a_valid   = tl_i.a_valid & ~stall_host;
          tl_sram_o.a_opcode  = Get;
        end
      end else if (wait_phase) begin
        
        
        tl_sram_o.a_valid = 1'b0;
      end
    end
    
    `ASSERT(TlulSramByteTlSize_A, top_pkg::TL_SZW >= $clog2(AccessSize + 1))
    assign error_o = error_i & ~stall_host;
    prim_fifo_sync #(
      .Width(top_pkg::TL_SZW),
      .Pass(1'b0),
      .Depth(Outstanding),
      .OutputZeroIfEmpty(1'b1),
      .NeverClears(1'b1)
    ) u_sync_fifo_a_size (
      .clk_i,
      .rst_ni,
      .clr_i(1'b0),
      .wvalid_i(a_ack),
      .wready_o(sync_fifo_a_size_outputs.size_fifo_rdy),
      .wdata_i(tl_i.a_size),
      .rvalid_o(),
      .rready_i(d_ack),
      .rdata_o(sync_fifo_a_size_outputs.a_size),
      .full_o(),
      .depth_o(sync_fifo_a_size_outputs.pending_txn_cnt),
      .err_o()
    );
    
    localparam int NumBufferBitsSyncASize = $bits({
      a_ack,
      tl_i.a_size,
      d_ack
    });
    logic [NumBufferBitsSyncASize-1:0] buf_sync_fifo_a_size_in, buf_sync_fifo_a_size_out;
    logic a_ack_buf;
    logic d_ack_buf;
    logic [top_pkg::TL_SZW-1:0] a_size_buf;
    assign buf_sync_fifo_a_size_in = {
      a_ack,
      tl_i.a_size,
      d_ack
    };
    assign {
      a_ack_buf,
      a_size_buf,
      d_ack_buf
    } = buf_sync_fifo_a_size_out;
    
    prim_buf #(
      .Width(NumBufferBitsSyncASize)
    ) u_sync_fifo_a_size_prim_buf (
      .in_i(buf_sync_fifo_a_size_in),
      .out_o(buf_sync_fifo_a_size_out)
    );
    prim_fifo_sync #(
      .Width(top_pkg::TL_SZW),
      .Pass(1'b0),
      .Depth(Outstanding),
      .OutputZeroIfEmpty(1'b1),
      .NeverClears(1'b1)
    ) u_sync_fifo_a_size_shadow (
      .clk_i,
      .rst_ni,
      .clr_i(1'b0),
      .wvalid_i(a_ack_buf),
      .wready_o(sync_fifo_a_size_shadow_outputs.size_fifo_rdy),
      .wdata_i(a_size_buf),
      .rvalid_o(),
      .rready_i(d_ack_buf),
      .rdata_o(sync_fifo_a_size_shadow_outputs.a_size),
      .full_o(),
      .depth_o(sync_fifo_a_size_shadow_outputs.pending_txn_cnt),
      .err_o()
    );
    
    assign sync_fifo_a_size_outputs_mismatch =
      (sync_fifo_a_size_shadow_outputs != sync_fifo_a_size_outputs);
    always_comb begin
      tl_o = tl_sram_i;
      
      tl_o.a_ready = tl_sram_i.a_ready & ~stall_host & fifo_rdy_data &
        sync_fifo_a_size_outputs.size_fifo_rdy;
      
      
      tl_o.d_valid = tl_sram_i.d_valid & ~rd_wait & ~rdback_wait;
      
      
      
      tl_o.d_size  = sync_fifo_a_size_outputs.a_size;
    end 
    
    
    logic unused_tl;
    assign unused_tl = |tl_sram_i.d_size;
    
    `ASSERT(ByteAccessStateChange_A, a_ack & wr_txn & ~&tl_i.a_mask & ~error_i |=>
      state_q inside {StWaitRd})
    
    `ASSERT(ReadCompleteStateChange_A,
        (state_q == StWaitRd) && (sync_fifo_a_size_outputs.pending_txn_cnt == 1) &&
        sram_d_ack |=> state_q == StWriteCmd)
    
    
    
    
    
    
    `ASSERT(ReadbackAccessAlwaysGranted_A, (rdback_phase | rdback_phase_wrreadback) && !error_i
      |-> tl_sram_i.a_ready)
    
    
    `ASSERT(ReadbackDataImmediatelyAvailable_A, (state_q == StPassThru) &&
      mubi4_test_true_loose(rdback_en_q) && mubi4_test_true_loose(rdback_check_q) &&
      !error_i|-> tl_sram_i.d_valid)
    
    
    
    `ASSERT(WrReadBackInitPendingTxn_A,
      (state_q == StByteWrReadBackInit) |-> sync_fifo_a_size_outputs.pending_txn_cnt ==
      PendingTxnCntW'(1))
    assign compound_txn_in_progress_o = wr_phase | rdback_phase | rdback_phase_wrreadback;
  end else begin : gen_no_integ_handling
    
    assign tl_sram_o = tl_i;
    assign tl_o = tl_sram_i;
    assign error_o = error_i;
    assign alert_o = 1'b0;
    assign compound_txn_in_progress_o = 1'b0;
    
    mubi4_t unused_readback_en;
    assign unused_readback_en = readback_en_i;
  end
  
  logic unused_write_pending, unused_wr_collision;
  assign unused_write_pending = write_pending_i;
  assign unused_wr_collision = wr_collision_i;
  
  
  `ASSERT_INIT(SramReadbackAndIntg,
      (EnableReadback && EnableIntg) || (!EnableReadback && (EnableIntg || !EnableIntg)))
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
  import spi_host_reg_pkg::*;
#(
  parameter logic [NumAlerts-1:0]           AlertAsyncOn              = {NumAlerts{1'b1}},
  
  parameter int unsigned                    AlertSkewCycles           = 1,
  parameter int unsigned                    NumCS                     = 1,
  parameter bit                             EnableRacl                = 1'b0,
  parameter bit                             RaclErrorRsp              = EnableRacl,
  parameter top_racl_pkg::racl_policy_sel_t RaclPolicySelVec[NumRegs] = '{NumRegs{0}},
  parameter top_racl_pkg::racl_policy_sel_t RaclPolicySelWinRXDATA    = 0,
  parameter top_racl_pkg::racl_policy_sel_t RaclPolicySelWinTXDATA    = 0
) (
  input              clk_i,
  input              rst_ni,
  
  input              tlul_pkg::tl_h2d_t tl_i,
  output             tlul_pkg::tl_d2h_t tl_o,
  
  input  prim_alert_pkg::alert_rx_t [NumAlerts-1:0] alert_rx_i,
  output prim_alert_pkg::alert_tx_t [NumAlerts-1:0] alert_tx_o,
  
  input  top_racl_pkg::racl_policy_vec_t racl_policies_i,
  output top_racl_pkg::racl_error_log_t  racl_error_o,
  
  output logic             cio_sck_o,
  output logic             cio_sck_en_o,
  output logic [NumCS-1:0] cio_csb_o,
  output logic [NumCS-1:0] cio_csb_en_o,
  output logic [3:0]       cio_sd_o,
  output logic [3:0]       cio_sd_en_o,
  input        [3:0]       cio_sd_i,
  
  input  spi_device_pkg::passthrough_req_t passthrough_i,
  output spi_device_pkg::passthrough_rsp_t passthrough_o,
  output logic             lsio_trigger_o,
  output logic             intr_error_o,
  output logic             intr_spi_event_o
);
  import spi_host_cmd_pkg::*;
  localparam int CSW = prim_util_pkg::vbits(NumCS);
  spi_host_reg2hw_t reg2hw;
  spi_host_hw2reg_t hw2reg;
  top_racl_pkg::racl_error_log_t racl_error[3];
  if (EnableRacl) begin : gen_racl_error_arb
    
    prim_racl_error_arb #(
      .N ( 3 )
    ) u_prim_err_arb (
      .clk_i,
      .rst_ni,
      .error_log_i ( racl_error   ),
      .error_log_o ( racl_error_o )
    );
  end else begin : gen_no_racl_error_arb
    logic unused_signals;
    always_comb begin
      unused_signals = ^{racl_error[0] ^ racl_error[1] ^ racl_error[2]};
      racl_error_o   = '0;
    end
  end
  tlul_pkg::tl_h2d_t fifo_win_h2d [2];
  tlul_pkg::tl_d2h_t fifo_win_d2h [2];
  
  logic [NumAlerts-1:0] alert_test, alerts;
  spi_host_reg_top #(
    .EnableRacl       ( EnableRacl       ),
    .RaclErrorRsp     ( RaclErrorRsp     ),
    .RaclPolicySelVec ( RaclPolicySelVec )
  ) u_reg (
    .clk_i,
    .rst_ni,
    .tl_i             ( tl_i                   ),
    .tl_o             ( tl_o                   ),
    .tl_win_o         ( fifo_win_h2d           ),
    .tl_win_i         ( fifo_win_d2h           ),
    .reg2hw,
    .hw2reg,
    
    .intg_err_o       ( alerts[0]              ),
    .racl_policies_i  ( racl_policies_i        ),
    .racl_error_o     ( racl_error[0]          )
  );
  
  assign alert_test = {
    reg2hw.alert_test.q &
    reg2hw.alert_test.qe
  };
  for (genvar i = 0; i < NumAlerts; i++) begin : gen_alert_tx
    prim_alert_sender #(
      .AsyncOn(AlertAsyncOn[i]),
      .SkewCycles(AlertSkewCycles),
      .IsFatal(1'b1)
    ) u_prim_alert_sender (
      .clk_i,
      .rst_ni,
      .alert_test_i  ( alert_test[i] ),
      .alert_req_i   ( alerts[0]     ),
      .alert_ack_o   (               ),
      .alert_state_o (               ),
      .alert_rx_i    ( alert_rx_i[i] ),
      .alert_tx_o    ( alert_tx_o[i] )
    );
  end
  logic             sck;
  logic [NumCS-1:0] csb;
  logic [3:0]       sd_out;
  logic [3:0]       sd_en, sd_en_core;
  logic [3:0]       sd_i;
  logic             output_en;
  assign output_en = reg2hw.control.output_en;
  assign sd_en     = output_en ? sd_en_core : 4'h0;
  if (NumCS == 1) begin : gen_passthrough_implementation
    logic passthrough_en;
    assign passthrough_en  = passthrough_i.passthrough_en;
    logic        pt_sck;
    logic        pt_sck_en;
    logic [0:0]  pt_csb;
    logic [0:0]  pt_csb_en;
    logic [3:0]  pt_sd_out;
    logic [3:0]  pt_sd_en;
    assign pt_sck       = passthrough_i.sck;
    assign pt_sck_en    = passthrough_i.sck_en;
    assign pt_csb[0]    = passthrough_i.csb;
    assign pt_csb_en[0] = passthrough_i.csb_en;
    assign pt_sd_out    = passthrough_i.s;
    assign pt_sd_en     = passthrough_i.s_en;
    assign cio_sck_o    = passthrough_en ? pt_sck    : sck;
    assign cio_sck_en_o = passthrough_en ? pt_sck_en : output_en;
    assign cio_csb_o    = passthrough_en ? pt_csb    : csb;
    assign cio_csb_en_o = passthrough_en ? pt_csb_en : output_en;
    assign cio_sd_o     = passthrough_en ? pt_sd_out : sd_out;
    assign cio_sd_en_o  = passthrough_en ? pt_sd_en  : sd_en;
  end                   : gen_passthrough_implementation
  else begin            : gen_passthrough_ignore
     
    `ASSERT(PassthroughNumCSCompat_A, !passthrough_i.passthrough_en, clk_i, rst_ni)
    assign cio_sck_o    = sck;
    assign cio_sck_en_o = output_en;
    assign cio_csb_o    = csb;
    assign cio_csb_en_o = {NumCS{output_en}};
    assign cio_sd_o     = sd_out;
    assign cio_sd_en_o  = sd_en;
    logic       unused_pt_en;
    logic       unused_pt_sck;
    logic       unused_pt_sck_en;
    logic       unused_pt_csb;
    logic       unused_pt_csb_en;
    logic [3:0] unused_pt_sd_out;
    logic [3:0] unused_pt_sd_en;
    assign unused_pt_en     = passthrough_i.passthrough_en;
    assign unused_pt_sck    = passthrough_i.sck;
    assign unused_pt_sck_en = passthrough_i.sck_en;
    assign unused_pt_csb    = passthrough_i.csb;
    assign unused_pt_csb_en = passthrough_i.csb_en;
    assign unused_pt_sd_out = passthrough_i.s;
    assign unused_pt_sd_en  = passthrough_i.s_en;
  end                   : gen_passthrough_ignore
  assign passthrough_o.s = cio_sd_i;
  assign sd_i            = cio_sd_i;
  assign hw2reg.status.byteorder.d  = ByteOrder;
  assign hw2reg.status.byteorder.de = 1'b1;
  logic command_valid;
  logic core_command_valid;
  logic command_busy;
  logic core_command_ready;
  command_t core_command, command;
  logic [CSW-1:0] core_command_csid, command_csid;
  logic error_csid_inval;
  logic error_cmd_inval;
  logic error_busy;
  logic test_csid_inval;
  logic test_dir_inval;
  logic test_speed_inval;
  assign test_csid_inval  = (reg2hw.csid.q >= NumCS);
  always_comb begin
    test_speed_inval           = 1'b1;
    test_dir_inval             = 1'b1;
    unique case (reg2hw.command.speed.q)
      Standard: begin
        test_dir_inval   = 1'b0;
        test_speed_inval = 1'b0;
      end
      Dual, Quad: begin
        test_dir_inval   = (reg2hw.command.direction.q == Bidir);
        test_speed_inval = 1'b0;
      end
      default: begin
      end
    endcase
  end
  always_comb begin
    command.segment.cmd_rd_en = 1'b0;
    command.segment.cmd_wr_en = 1'b0;
    unique case (reg2hw.command.direction.q)
      RdOnly: begin
        command.segment.cmd_rd_en = 1'b1;
      end
      WrOnly: begin
        command.segment.cmd_wr_en = 1'b1;
      end
      Bidir: begin
        command.segment.cmd_rd_en = 1'b1;
        command.segment.cmd_wr_en = 1'b1;
      end
      default: begin
      end
    endcase
  end
  assign error_csid_inval = command_valid & ~command_busy &
                            test_csid_inval;
  assign error_cmd_inval  = command_valid & ~command_busy &
                            (test_speed_inval | test_dir_inval);
  assign command_csid = (test_csid_inval) ? '0 : reg2hw.csid.q[CSW-1:0];
  assign command.configopts.clkdiv   = reg2hw.configopts.clkdiv.q;
  assign command.configopts.csnidle  = reg2hw.configopts.csnidle.q;
  assign command.configopts.csnlead  = reg2hw.configopts.csnlead.q;
  assign command.configopts.csntrail = reg2hw.configopts.csntrail.q;
  assign command.configopts.full_cyc = reg2hw.configopts.fullcyc.q;
  assign command.configopts.cpha     = reg2hw.configopts.cpha.q;
  assign command.configopts.cpol     = reg2hw.configopts.cpol.q;
  assign command.segment.len         = reg2hw.command.len.q;
  assign command.segment.csaat       = reg2hw.command.csaat.q;
  assign command.segment.speed       = reg2hw.command.speed.q;
  logic [3:0] cmd_qes;
  assign cmd_qes = {
      reg2hw.command.len.qe,
      reg2hw.command.speed.qe,
      reg2hw.command.direction.qe,
      reg2hw.command.csaat.qe
  };
  
  assign command_valid = |cmd_qes;
  logic active;
  logic rx_stall;
  logic tx_stall;
  assign hw2reg.status.ready.d    = ~command_busy;
  assign hw2reg.status.active.d   = active;
  assign hw2reg.status.rxstall.d  = rx_stall;
  assign hw2reg.status.txstall.d  = tx_stall;
  assign hw2reg.status.ready.de   = 1'b1;
  assign hw2reg.status.active.de  = 1'b1;
  assign hw2reg.status.rxstall.de = 1'b1;
  assign hw2reg.status.txstall.de = 1'b1;
  logic sw_rst;
  logic [3:0]  cmd_qd;
  spi_host_command_queue #(
    .CmdDepth(CmdDepth),
    .NumCS(NumCS)
  ) u_cmd_queue (
    .clk_i,
    .rst_ni,
    .command_i            (command),
    .command_csid_i       (command_csid),
    .command_valid_i      (command_valid),
    .command_busy_o       (command_busy),
    .core_command_o       (core_command),
    .core_command_csid_o  (core_command_csid),
    .core_command_valid_o (core_command_valid),
    .core_command_ready_i (core_command_ready),
    .error_busy_o         (error_busy),
    .qd_o                 (cmd_qd),
    .sw_rst_i             (sw_rst)
  );
  logic [31:0] tx_data;
  logic [3:0]  tx_be;
  logic        tx_valid;
  logic        tx_ready;
  logic [31:0] rx_data;
  logic        rx_valid;
  logic        rx_ready;
  spi_host_window #(
    .EnableRacl             ( EnableRacl             ),
    .RaclErrorRsp           ( RaclErrorRsp           ),
    .RaclPolicySelWinRXDATA ( RaclPolicySelWinRXDATA ),
    .RaclPolicySelWinTXDATA ( RaclPolicySelWinTXDATA )
  ) u_window (
    .clk_i,
    .rst_ni,
    .rx_win_i         ( fifo_win_h2d[0]             ),
    .rx_win_o         ( fifo_win_d2h[0]             ),
    .tx_win_i         ( fifo_win_h2d[1]             ),
    .tx_win_o         ( fifo_win_d2h[1]             ),
    .tx_data_o        ( tx_data                     ),
    .tx_be_o          ( tx_be                       ),
    .tx_valid_o       ( tx_valid                    ),
    .rx_data_i        ( rx_data                     ),
    .rx_ready_o       ( rx_ready                    ),
    .racl_policies_i  ( racl_policies_i             ),
    .racl_error_tx_o  ( racl_error[1]               ),
    .racl_error_rx_o  ( racl_error[2]               )
  );
  logic [31:0] core_tx_data;
  logic [3:0]  core_tx_be;
  logic        core_tx_valid;
  logic        core_tx_ready;
  logic        core_tx_byte_select_full;
  logic [31:0] core_rx_data;
  logic        core_rx_valid;
  logic        core_rx_ready;
  logic [7:0]  rx_watermark;
  logic [7:0]  tx_watermark;
  logic [7:0]  rx_qd;
  logic [7:0]  tx_qd;
  logic        tx_empty, tx_full, tx_wm;
  logic        rx_empty, rx_full, rx_wm;
  assign rx_watermark = reg2hw.control.rx_watermark.q;
  assign tx_watermark = reg2hw.control.tx_watermark.q;
  assign hw2reg.status.txqd.d    = tx_qd;
  assign hw2reg.status.rxqd.d    = rx_qd;
  assign hw2reg.status.cmdqd.d   = cmd_qd;
  assign hw2reg.status.txwm.d    = tx_wm;
  assign hw2reg.status.rxwm.d    = rx_wm;
  assign hw2reg.status.rxempty.d = rx_empty;
  assign hw2reg.status.txempty.d = tx_empty;
  assign hw2reg.status.rxfull.d  = rx_full;
  assign hw2reg.status.txfull.d  = tx_full;
  assign hw2reg.status.txqd.de    = 1'b1;
  assign hw2reg.status.rxqd.de    = 1'b1;
  assign hw2reg.status.cmdqd.de   = 1'b1;
  assign hw2reg.status.txwm.de    = 1'b1;
  assign hw2reg.status.rxwm.de    = 1'b1;
  assign hw2reg.status.rxempty.de = 1'b1;
  assign hw2reg.status.txempty.de = 1'b1;
  assign hw2reg.status.rxfull.de  = 1'b1;
  assign hw2reg.status.txfull.de  = 1'b1;
  logic error_overflow, error_underflow;
  logic error_access_inval;
  
  
  assign error_overflow    = tx_valid & ~tx_ready;
  assign error_underflow   = rx_ready & ~rx_valid;
  logic access_valid;
  assign error_access_inval = tx_valid & ~access_valid;
  always_comb begin
    unique case (tx_be)
      4'b1000,
      4'b0100,
      4'b0010,
      4'b0001,
      4'b1100,
      4'b0110,
      4'b0011,
      4'b1111: begin
        access_valid = 1'b1;
      end
      default: begin
        access_valid = 1'b0;
      end
    endcase
  end
  logic tx_valid_checked;
  assign tx_valid_checked = tx_valid & ~error_overflow & ~error_access_inval;
  
  
  
  
  spi_host_data_fifos #(
    .TxDepth(TxDepth),
    .RxDepth(RxDepth),
    .SwapBytes(~ByteOrder)
  ) u_data_fifos (
    .clk_i,
    .rst_ni,
    .tx_data_i                  (tx_data),
    .tx_be_i                    (tx_be),
    .tx_valid_i                 (tx_valid_checked),
    .tx_ready_o                 (tx_ready),
    .tx_watermark_i             (tx_watermark),
    .core_tx_data_o             (core_tx_data),
    .core_tx_be_o               (core_tx_be),
    .core_tx_valid_o            (core_tx_valid),
    .core_tx_ready_i            (core_tx_ready),
    .core_tx_byte_select_full_i (core_tx_byte_select_full),
    .core_rx_data_i             (core_rx_data),
    .core_rx_valid_i            (core_rx_valid),
    .core_rx_ready_o            (core_rx_ready),
    .rx_data_o                  (rx_data),
    .rx_valid_o                 (rx_valid),
    .rx_ready_i                 (rx_ready),
    .rx_watermark_i             (rx_watermark),
    .tx_empty_o                 (tx_empty),
    .tx_full_o                  (tx_full),
    .tx_qd_o                    (tx_qd),
    .tx_wm_o                    (tx_wm),
    .rx_empty_o                 (rx_empty),
    .rx_full_o                  (rx_full),
    .rx_qd_o                    (rx_qd),
    .rx_wm_o                    (rx_wm),
    .sw_rst_i                   (sw_rst)
);
  logic en_sw;
  logic enb_error;
  logic en;
  assign en     = en_sw & ~enb_error;
  assign sw_rst = reg2hw.control.sw_rst.q;
  assign en_sw  = reg2hw.control.spien.q;
  spi_host_core #(
    .NumCS(NumCS)
  ) u_spi_core (
    .clk_i,
    .rst_ni,
    .command_i             (core_command),
    .command_csid_i        (core_command_csid),
    .command_valid_i       (core_command_valid),
    .command_ready_o       (core_command_ready),
    .en_i                  (en),
    .tx_data_i             (core_tx_data),
    .tx_be_i               (core_tx_be),
    .tx_valid_i            (core_tx_valid),
    .tx_ready_o            (core_tx_ready),
    .tx_byte_select_full_o (core_tx_byte_select_full),
    .rx_data_o             (core_rx_data),
    .rx_valid_o            (core_rx_valid),
    .rx_ready_i            (core_rx_ready),
    .sck_o                 (sck),
    .csb_o                 (csb),
    .sd_o                  (sd_out),
    .sd_en_o               (sd_en_core),
    .sd_i,
    .rx_stall_o            (rx_stall),
    .tx_stall_o            (tx_stall),
    .sw_rst_i              (sw_rst),
    .active_o              (active)
  );
  logic event_error;
  logic [5:0] error_vec;
  logic [5:0] error_mask;
  logic [5:0] sw_error_status;
  assign error_vec  = {
      error_access_inval,
      error_csid_inval,
      error_cmd_inval,
      error_underflow,
      error_overflow,
      error_busy
  };
  
  
  
  
  
  assign error_mask = {
      1'b1, 
      reg2hw.error_enable.csidinval.q,
      reg2hw.error_enable.cmdinval.q,
      reg2hw.error_enable.underflow.q,
      reg2hw.error_enable.overflow.q,
      reg2hw.error_enable.cmdbusy.q
  };
  assign hw2reg.error_status.accessinval.d  = error_access_inval;
  assign hw2reg.error_status.csidinval.d    = error_csid_inval;
  assign hw2reg.error_status.cmdinval.d     = error_cmd_inval;
  assign hw2reg.error_status.underflow.d    = error_underflow;
  assign hw2reg.error_status.overflow.d     = error_overflow;
  assign hw2reg.error_status.cmdbusy.d      = error_busy;
  
  
  assign hw2reg.error_status.accessinval.de = error_access_inval;
  assign hw2reg.error_status.csidinval.de   = error_csid_inval;
  assign hw2reg.error_status.cmdinval.de    = error_cmd_inval;
  assign hw2reg.error_status.underflow.de   = error_underflow;
  assign hw2reg.error_status.overflow.de    = error_overflow;
  assign hw2reg.error_status.cmdbusy.de     = error_busy;
  assign sw_error_status[5] = reg2hw.error_status.accessinval.q;
  assign sw_error_status[4] = reg2hw.error_status.csidinval.q;
  assign sw_error_status[3] = reg2hw.error_status.cmdinval.q;
  assign sw_error_status[2] = reg2hw.error_status.underflow.q;
  assign sw_error_status[1] = reg2hw.error_status.overflow.q;
  assign sw_error_status[0] = reg2hw.error_status.cmdbusy.q;
  assign event_error   = |(error_vec & error_mask);
  assign enb_error     = |sw_error_status;
  prim_intr_hw #(.Width(1)) intr_hw_error (
    .clk_i,
    .rst_ni,
    .event_intr_i           (event_error),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.error.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.error.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.error.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.error.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.error.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.error.d),
    .intr_o                 (intr_error_o)
  );
  logic status_spi_event;
  logic status_idle, status_ready, status_tx_wm, status_rx_wm, status_tx_empty, status_rx_full;
  logic [5:0] event_vector;
  logic [5:0] event_mask;
  assign status_idle     = ~active;
  assign status_ready    = ~command_busy;
  assign status_tx_wm    = tx_wm;
  assign status_rx_wm    = rx_wm;
  assign status_tx_empty = tx_empty;
  assign status_rx_full  = rx_full;
  assign event_vector = {
    status_idle,
    status_ready,
    status_tx_wm,
    status_rx_wm,
    status_tx_empty,
    status_rx_full
  };
  assign event_mask = {
    reg2hw.event_enable.idle.q,
    reg2hw.event_enable.ready.q,
    reg2hw.event_enable.txwm.q,
    reg2hw.event_enable.rxwm.q,
    reg2hw.event_enable.txempty.q,
    reg2hw.event_enable.rxfull.q
  };
  
  assign status_spi_event = |(event_vector & event_mask);
  
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      lsio_trigger_o <= 1'b0;
    end else begin
      lsio_trigger_o <= tx_wm | rx_wm;
    end
  end
  prim_intr_hw #(
    .Width(1),
    .IntrT("Status")
  ) intr_hw_spi_event (
    .clk_i,
    .rst_ni,
    .event_intr_i           (status_spi_event),
    .reg2hw_intr_enable_q_i (reg2hw.intr_enable.spi_event.q),
    .reg2hw_intr_test_q_i   (reg2hw.intr_test.spi_event.q),
    .reg2hw_intr_test_qe_i  (reg2hw.intr_test.spi_event.qe),
    .reg2hw_intr_state_q_i  (reg2hw.intr_state.spi_event.q),
    .hw2reg_intr_state_de_o (hw2reg.intr_state.spi_event.de),
    .hw2reg_intr_state_d_o  (hw2reg.intr_state.spi_event.d),
    .intr_o                 (intr_spi_event_o)
  );
  `ASSERT_KNOWN(TlDValidKnownO_A, tl_o.d_valid)
  `ASSERT_KNOWN(TlAReadyKnownO_A, tl_o.a_ready)
  `ASSERT_KNOWN(AlertKnownO_A, alert_tx_o)
  `ASSERT_KNOWN(CioSckKnownO_A, cio_sck_o)
  `ASSERT_KNOWN(CioSckEnKnownO_A, cio_sck_en_o)
  `ASSERT_KNOWN(CioCsbKnownO_A, cio_csb_o)
  `ASSERT_KNOWN(CioCsbEnKnownO_A, cio_csb_en_o)
  `ASSERT_KNOWN_IF(CioSdKnownO_A, cio_sd_o, !passthrough_i.passthrough_en |
    (passthrough_i.passthrough_en && passthrough_i.csb_en && !passthrough_i.csb),
    passthrough_i.sck_en & passthrough_i.sck)
  `ASSERT_KNOWN(CioSdEnKnownO_A, cio_sd_en_o)
  `ASSERT_KNOWN(IntrSpiEventKnownO_A, intr_spi_event_o)
  `ASSERT_KNOWN(IntrErrorKnownO_A, intr_error_o)
  `ASSERT_KNOWN(LsioTriggerKnown_A, lsio_trigger_o)
  `ASSERT_KNOWN(RaclErrorValidKnown_A, racl_error_o.valid)
  
  
  
  `ASSERT(PassthroughConn_A, passthrough_o.s === cio_sd_i)
  
  `ASSERT_PRIM_REG_WE_ONEHOT_ERROR_TRIGGER_ALERT(RegWeOnehotCheck_A, u_reg, alert_tx_o[0])
endmodule : TopModule

module spi_host_byte_merge (
  input               clk_i,
  input               rst_ni,
  input        [7:0]  byte_i,
  input               byte_last_i,
  input               byte_valid_i,
  output logic        byte_ready_o,
  output logic [31:0] word_o,
  output logic        word_valid_o,
  input               word_ready_i,
  input               sw_rst_i
);
  logic               clr;
  logic               byte_valid;
  logic               byte_ready;
  logic               last_q;
  logic               last_d;
  logic               do_fill;
  logic               byte_incoming;
  
  assign clr = sw_rst_i;
  assign byte_incoming = byte_valid_i & byte_ready_o;
  assign last_d       = sw_rst_i                     ? 1'b0 :
                        byte_incoming && byte_last_i ? 1'b1 :
                        word_valid_o                 ? 1'b0 :
                        last_q;
  assign do_fill      = last_q & ~word_valid_o;
  assign byte_valid   = do_fill | byte_valid_i;
  assign byte_ready_o = byte_ready & ~do_fill;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      last_q <= 1'b0;
    end else begin
      last_q <= last_d;
    end
  end
  prim_packer_fifo #(
    .InW(8),
    .OutW(32)
  ) u_packer (
    .clk_i,
    .rst_ni,
    .clr_i    (clr),
    .wdata_i  (do_fill ? 8'h0 : byte_i),
    .wvalid_i (byte_valid),
    .wready_o (byte_ready),
    .rdata_o  (word_o),
    .rvalid_o (word_valid_o),
    .rready_i (word_ready_i),
    .depth_o  ()
  );
endmodule : spi_host_byte_merge

module spi_host_byte_select (
  input               clk_i,
  input               rst_ni,
  input       [31:0]  word_i,
  input        [3:0]  word_be_i,
  input               word_valid_i,
  output logic        word_ready_o,
  output logic  [7:0] byte_o,
  output logic        byte_valid_o,
  input               byte_ready_i,
  input               flush_i,
  input               sw_rst_i
);
  logic       [35:0]  wdata_be;
  logic               do_drain;
  logic               byte_en;
  logic               byte_valid;
  logic               byte_ready;
  logic               clr;
  assign clr          = flush_i | sw_rst_i;
  assign byte_valid_o = byte_valid & byte_en;
  assign do_drain     = byte_valid & ~byte_en;
  assign byte_ready   = byte_ready_i | do_drain;
  for(genvar ii = 0; ii < 4; ii = ii + 1) begin : gen_map_data_be
    assign wdata_be[9*ii +: 9] = { word_be_i[ii], word_i[8*ii +: 8] };
  end : gen_map_data_be
  prim_packer_fifo #(
    .InW(36),
    .OutW(9)
  ) u_packer (
    .clk_i,
    .rst_ni,
    .clr_i     (clr),
    .wdata_i   (wdata_be),
    .wvalid_i  (word_valid_i),
    .wready_o  (word_ready_o),
    .rdata_o   ({byte_en, byte_o}),
    .rvalid_o  (byte_valid),
    .rready_i  (byte_ready),
    .depth_o   ()
  );
endmodule : spi_host_byte_select

package spi_host_cmd_pkg;
  parameter int CmdSize = 56;
  
  typedef enum logic [1:0] {
     Dummy  = 2'b00,
     RdOnly = 2'b01,
     WrOnly = 2'b10,
     Bidir  = 2'b11
   } reg_direction_t;
  
  typedef enum logic [1:0] {
     Standard = 2'b00,
     Dual     = 2'b01,
     Quad     = 2'b10,
     RsvdSpd  = 2'b11
   } speed_t;
  typedef struct packed {
    logic [15:0] clkdiv;
    logic [3:0]  csnidle;
    logic [3:0]  csnlead;
    logic [3:0]  csntrail;
    logic        full_cyc;
    logic        cpha;
    logic        cpol;
  } configopts_t;
  typedef struct packed {
    logic [1:0]  speed;
    logic        cmd_wr_en;
    logic        cmd_rd_en;
    logic [19:0] len;
    logic        csaat;
  } segment_t;
  typedef struct packed {
    segment_t segment;
    configopts_t configopts;
  } command_t;
endpackage

module spi_host_command_queue #(
  parameter int          CmdDepth = 4,
  parameter int unsigned NumCS    = 1,
  localparam int CSW              = prim_util_pkg::vbits(NumCS)
) (
  input                              clk_i,
  input                              rst_ni,
  input  spi_host_cmd_pkg::command_t command_i,
  input  logic [CSW-1:0]             command_csid_i,
  input                              command_valid_i,
  output logic                       command_busy_o,
  output spi_host_cmd_pkg::command_t core_command_o,
  output logic [CSW-1:0]             core_command_csid_o,
  output logic                       core_command_valid_o,
  input                              core_command_ready_i,
  output logic [3:0]                 qd_o,
  output logic                       error_busy_o,
  input                              sw_rst_i
);
  localparam int CmdDepthW = prim_util_pkg::vbits(CmdDepth+1);
  logic command_ready;
  assign command_busy_o = ~command_ready;
  assign error_busy_o   = command_valid_i & command_busy_o;
  logic [CmdDepthW-1:0] cmd_depth;
  prim_fifo_sync #(
    .Width($bits(spi_host_cmd_pkg::command_t) + CSW),
    .Pass(0),
    .Depth(CmdDepth)
  ) cmd_fifo (
    .clk_i,
    .rst_ni,
    .clr_i    (sw_rst_i),
    .wvalid_i (command_valid_i),
    .wready_o (command_ready),
    .wdata_i  ({command_i, command_csid_i}),
    .rvalid_o (core_command_valid_o),
    .rready_i (core_command_ready_i),
    .rdata_o  ({core_command_o, core_command_csid_o}),
    .full_o   (),
    .depth_o  (cmd_depth),
    .err_o    ()
  );
  assign qd_o = 4'(cmd_depth);
endmodule : spi_host_command_queue

module spi_host_core #(
  parameter  int NumCS = 1,
  localparam int CSW   = prim_util_pkg::vbits(NumCS)
) (
  input                             clk_i,
  input                             rst_ni,
  input spi_host_cmd_pkg::command_t command_i,
  input logic [CSW-1:0]             command_csid_i,
  input                             command_valid_i,
  output                            command_ready_o,
  input                             en_i,
  input        [31:0]               tx_data_i,
  input        [3:0]                tx_be_i,
  input                             tx_valid_i,
  output logic                      tx_ready_o,
  output logic                      tx_byte_select_full_o,
  output logic [31:0]               rx_data_o,
  output logic                      rx_valid_o,
  input                             rx_ready_i,
  input                             sw_rst_i,
  
  output logic                      sck_o,
  output logic [NumCS-1:0]          csb_o,
  output logic [3:0]                sd_o,
  output logic [3:0]                sd_en_o,
  input [3:0]                       sd_i,
  
  output logic                      rx_stall_o,
  output logic                      tx_stall_o,
  output logic                      active_o
);
  logic       rx_valid_sr;
  logic       rx_ready_sr;
  logic       rx_last_sr;
  logic [7:0] rx_data_sr;
  logic       tx_valid_sr;
  logic       tx_ready_sr;
  logic       tx_flush_sr;
  logic [7:0] tx_data_sr;
  logic       wr_en;
  logic       rd_en;
  logic       wr_ready;
  logic       rd_ready;
  logic       sample_en;
  logic       shift_en;
  logic [1:0] speed;
  logic       full_cyc;
  logic       last_read;
  logic       last_write;
  spi_host_byte_merge u_merge (
    .clk_i,
    .rst_ni,
    .byte_i       (rx_data_sr),
    .byte_last_i  (rx_last_sr),
    .byte_valid_i (rx_valid_sr),
    .byte_ready_o (rx_ready_sr),
    .word_o       (rx_data_o),
    .word_valid_o (rx_valid_o),
    .word_ready_i (rx_ready_i),
    .sw_rst_i
  );
  spi_host_byte_select u_select (
    .clk_i,
    .rst_ni,
    .word_i       (tx_data_i),
    .word_be_i    (tx_be_i),
    .word_valid_i (tx_valid_i),
    .word_ready_o (tx_ready_o),
    .byte_o       (tx_data_sr),
    .byte_valid_o (tx_valid_sr),
    .byte_ready_i (tx_ready_sr),
    .flush_i      (tx_flush_sr),
    .sw_rst_i
  );
  
  
  
  
  
  assign tx_byte_select_full_o = tx_valid_sr;
  spi_host_shift_register u_shift_reg (
    .clk_i,
    .rst_ni,
    .wr_en_i      (wr_en),
    .wr_ready_o   (wr_ready),
    .rd_en_i      (rd_en),
    .rd_ready_o   (rd_ready),
    .speed_i      (speed),
    .shift_en_i   (shift_en),
    .sample_en_i  (sample_en),
    .last_read_i  (last_read),
    .last_write_i (last_write),
    .full_cyc_i   (full_cyc),
    .tx_data_i    (tx_data_sr),
    .tx_valid_i   (tx_valid_sr),
    .tx_ready_o   (tx_ready_sr),
    .tx_flush_o   (tx_flush_sr),
    .rx_data_o    (rx_data_sr),
    .rx_valid_o   (rx_valid_sr),
    .rx_ready_i   (rx_ready_sr),
    .rx_last_o    (rx_last_sr),
    .sw_rst_i,
    .sd_o         (sd_o),
    .sd_i         (sd_i)
  );
  spi_host_fsm #(
    .NumCS(NumCS)
  ) u_fsm (
    .clk_i,
    .rst_ni,
    .en_i,
    .command_i,
    .command_csid_i,
    .command_valid_i,
    .command_ready_o,
    .sck_o,
    .csb_o,
    .sd_en_o,
    .last_read_o      (last_read),
    .last_write_o     (last_write),
    .wr_en_o          (wr_en),
    .sr_wr_ready_i    (wr_ready),
    .rd_en_o          (rd_en),
    .sr_rd_ready_i    (rd_ready),
    .sample_en_o      (sample_en),
    .shift_en_o       (shift_en),
    .speed_o          (speed),
    .full_cyc_o       (full_cyc),
    .sw_rst_i,
    .rx_stall_o,
    .tx_stall_o,
    .active_o
  );
endmodule : spi_host_core

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
module spi_host_data_fifos #(
  parameter int         TxDepth   = 72,
  parameter int         RxDepth   = 64,
  parameter logic       SwapBytes = 0
) (
  input               clk_i,
  input               rst_ni,
  input        [31:0] tx_data_i,
  input        [3:0]  tx_be_i,
  input               tx_valid_i,
  output logic        tx_ready_o,
  input        [7:0]  tx_watermark_i,
  output logic [31:0] core_tx_data_o,
  output logic [3:0]  core_tx_be_o,
  output logic        core_tx_valid_o,
  input               core_tx_ready_i,
  input               core_tx_byte_select_full_i,
  input        [31:0] core_rx_data_i,
  input               core_rx_valid_i,
  output logic        core_rx_ready_o,
  output logic [31:0] rx_data_o,
  output logic        rx_valid_o,
  input               rx_ready_i,
  input        [7:0]  rx_watermark_i,
  input               sw_rst_i,
  output logic        tx_empty_o,
  output logic        tx_full_o,
  output logic [7:0]  tx_qd_o,
  output logic        tx_wm_o,
  output logic        rx_empty_o,
  output logic        rx_full_o,
  output logic [7:0]  rx_qd_o,
  output logic        rx_wm_o
);
  localparam int RxDepthW = prim_util_pkg::vbits(RxDepth+1);
  localparam int TxDepthW = prim_util_pkg::vbits(TxDepth+1);
  logic [31:0] tx_data_ordered;
  logic [3:0]  tx_be_ordered;
  logic [31:0] rx_data_unordered;
  if (SwapBytes) begin : gen_swap
    assign tx_data_ordered = { << 8 {tx_data_i} };
    assign tx_be_ordered   = { << { tx_be_i} };
    assign rx_data_o       = { << 8 { rx_data_unordered } };
  end else begin : gen_do_not_swap
    assign tx_data_ordered = tx_data_i;
    assign tx_be_ordered   = tx_be_i;
    assign rx_data_o       = rx_data_unordered;
  end : gen_do_not_swap
  logic [35:0]         tx_data_be;
  logic [35:0]         core_tx_data_be;
  logic [TxDepthW-1:0] tx_depth;
  
  
  assign tx_qd_o = 8'(tx_depth) + {7'b0, core_tx_byte_select_full_i};
  assign tx_data_be = { tx_data_ordered, tx_be_ordered };
  assign { core_tx_data_o, core_tx_be_o } = core_tx_data_be;
  prim_fifo_sync #(
    .Width(36),
    .Pass(1),
    .Depth(TxDepth)
  ) u_tx_fifo (
    .clk_i,
    .rst_ni,
    .clr_i    (sw_rst_i),
    .wvalid_i (tx_valid_i),
    .wready_o (tx_ready_o),
    .wdata_i  (tx_data_be),
    .rvalid_o (core_tx_valid_o),
    .rready_i (core_tx_ready_i),
    .rdata_o  (core_tx_data_be),
    .full_o   (),
    .depth_o  (tx_depth),
    .err_o    ()
  );
  logic [RxDepthW-1:0] rx_depth;
  assign rx_qd_o = 8'(rx_depth);
  prim_fifo_sync #(
    .Width(32),
    .Pass(1),
    .Depth(RxDepth)
  ) u_rx_fifo (
    .clk_i,
    .rst_ni,
    .clr_i    (sw_rst_i),
    .wvalid_i (core_rx_valid_i),
    .wready_o (core_rx_ready_o),
    .wdata_i  (core_rx_data_i),
    .rvalid_o (rx_valid_o),
    .rready_i (rx_ready_i),
    .rdata_o  (rx_data_unordered),
    .full_o   (),
    .depth_o  (rx_depth),
    .err_o    ()
  );
  
  
  assign tx_empty_o = (tx_qd_o == 0);
  assign rx_empty_o = (rx_qd_o == 0);
  assign tx_full_o  = (tx_qd_o >= 8'(TxDepth) + 1); 
  assign rx_full_o  = (rx_qd_o >= 8'(RxDepth));
  assign tx_wm_o    = (tx_qd_o <  tx_watermark_i);
  assign rx_wm_o    = (rx_qd_o >= rx_watermark_i);
  
  
  `ASSERT_INIT(TxDepth_A, TxDepth < (2**$size(tx_qd_o)) - 1)
endmodule : spi_host_data_fifos

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
module spi_host_fsm
  import spi_host_cmd_pkg::*;
#(
  parameter  int NumCS = 1,
  localparam int CSW   = prim_util_pkg::vbits(NumCS)
) (
  input                              clk_i,
  input                              rst_ni,
  input                              en_i,
  input  command_t                   command_i,
  input  logic [CSW-1:0]             command_csid_i,
  input                              command_valid_i,
  output logic                       command_ready_o,
  output logic                       sck_o,
  output logic [NumCS-1:0]           csb_o,
  output logic [3:0]                 sd_en_o,
  output logic                       last_read_o,
  output logic                       last_write_o,
  output logic                       wr_en_o,
  input                              sr_wr_ready_i,
  output logic                       rd_en_o,
  input                              sr_rd_ready_i,
  output logic                       sample_en_o,
  output logic                       shift_en_o,
  output logic [1:0]                 speed_o,
  output logic                       full_cyc_o,
  output logic                       rx_stall_o,
  output logic                       tx_stall_o,
  output logic                       active_o,
  input                              sw_rst_i
);
  logic             is_idle;
  logic [15:0]      clkdiv, clkdiv_q;
  logic [15:0]      clk_cntr_q, clk_cntr_d;
  logic             clk_cntr_en;
  logic [CSW-1:0]   csid;
  logic [CSW-1:0]   csid_q;
  logic [3:0]       csnidle, csntrail, csnlead;
  logic [3:0]       csnidle_q, csntrail_q, csnlead_q;
  logic             full_cyc, cpha, cpol;
  logic             full_cyc_q, cpha_q, cpol_q;
  
  
  
  
  
  
  
  
  
  
  logic [1:0]       cmd_speed_d, cmd_speed_q;
  logic             cmd_wr_en_d, cmd_wr_en_q;
  logic             cmd_rd_en_d, cmd_rd_en_q;
  logic [19:0]      cmd_len_d, cmd_len_q;
  logic             csaat;
  logic             csaat_q;
  logic [2:0]       bit_cntr_d, bit_cntr_q;
  logic [19:0]      byte_cntr_cpha0_d, byte_cntr_cpha1_d, byte_cntr_cpha0_q, byte_cntr_cpha1_q;
  logic [19:0]      byte_cntr_early, byte_cntr_late;
  logic [3:0]       wait_cntr_d, wait_cntr_q;
  logic             last_bit, last_byte;
  logic             state_changing;
  logic             byte_starting, byte_starting_cpha0, byte_starting_cpha1;
  logic             bit_shifting, bit_shifting_cpha0, bit_shifting_cpha1;
  logic             byte_ending, byte_ending_cpha0, byte_ending_cpha1;
  logic             sample_en_d, sample_en_q, sample_en_q2;
  logic             config_changed;
  logic             fsm_en;
  
  logic             new_command;
  logic             csb_single_d;
  logic [NumCS-1:0] csb_q;
  logic             sck_d, sck_q;
  logic wr_en_internal, rd_en_internal, sample_en_internal, shift_en_internal;
  logic stall;
  assign stall = rx_stall_o | tx_stall_o;
  
  assign wr_en_o     = wr_en_internal & ~stall;
  assign rd_en_o     = rd_en_internal & ~stall;
  assign sample_en_o = sample_en_internal & ~stall;
  assign shift_en_o  = shift_en_internal & ~stall;
  typedef enum logic [2:0] {
    Idle,
    WaitLead,
    InternalClkLow,
    InternalClkHigh,
    WaitTrail,
    WaitIdle,
    CSBSwitch,
    IdleCSBActive
  } spi_host_st_e;
  spi_host_st_e state_q, state_d;
  logic command_ready_int;
  assign command_ready_o = command_ready_int & ~stall;
  assign new_command    = command_valid_i && command_ready_int;
  assign config_changed = (command_i.configopts.cpol     != cpol_q) ||
                          (command_i.configopts.cpha     != cpha_q) ||
                          (command_i.configopts.full_cyc != full_cyc_q) ||
                          (command_i.configopts.csnidle  != csnidle_q) ||
                          (command_i.configopts.csntrail != csntrail_q) ||
                          (command_i.configopts.csnlead  != csnlead_q) ||
                          (command_i.configopts.clkdiv   != clkdiv_q);
  always_comb begin
    csid      = new_command ? command_csid_i : csid_q;
    cpol      = new_command ? command_i.configopts.cpol : cpol_q;
    cpha      = new_command ? command_i.configopts.cpha : cpha_q;
    full_cyc  = new_command ? command_i.configopts.full_cyc : full_cyc_q;
    csnidle   = new_command ? command_i.configopts.csnidle : csnidle_q;
    csnlead   = new_command ? command_i.configopts.csnlead : csnlead_q;
    csntrail  = new_command ? command_i.configopts.csntrail : csntrail_q;
    clkdiv    = new_command ? command_i.configopts.clkdiv : clkdiv_q;
    csaat     = new_command ? command_i.segment.csaat : csaat_q;
    cmd_len_d   = new_command ? command_i.segment.len : cmd_len_q;
    cmd_wr_en_d = new_command ? command_i.segment.cmd_wr_en : cmd_wr_en_q;
    cmd_rd_en_d = new_command ? command_i.segment.cmd_rd_en : cmd_rd_en_q;
    cmd_speed_d = new_command ? command_i.segment.speed : cmd_speed_q;
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      csid_q      <= {CSW{1'b0}};
      cpol_q      <= 1'b0;
      cpha_q      <= 1'b0;
      full_cyc_q  <= 1'b0;
      csnidle_q   <= 4'h0;
      csnlead_q   <= 4'h0;
      csntrail_q  <= 4'h0;
      clkdiv_q    <= 16'h0;
      csaat_q     <= 1'b0;
      cmd_rd_en_q <= 1'b0;
      cmd_wr_en_q <= 1'b0;
      cmd_speed_q <= 2'b00;
      cmd_len_q   <= 20'h0;
    end else begin
      csid_q      <= (new_command && !stall) ? csid : csid_q;
      cpol_q      <= (new_command && !stall) ? cpol : cpol_q;
      cpha_q      <= (new_command && !stall) ? cpha : cpha_q;
      full_cyc_q  <= (new_command && !stall) ? full_cyc : full_cyc_q;
      csnidle_q   <= (new_command && !stall) ? csnidle : csnidle_q;
      csnlead_q   <= (new_command && !stall) ? csnlead : csnlead_q;
      csntrail_q  <= (new_command && !stall) ? csntrail : csntrail_q;
      clkdiv_q    <= (new_command && !stall) ? clkdiv : clkdiv_q;
      csaat_q     <= (new_command && !stall) ? csaat : csaat_q;
      cmd_wr_en_q <= (new_command && !stall) ? cmd_wr_en_d : cmd_wr_en_q;
      cmd_rd_en_q <= (new_command && !stall) ? cmd_rd_en_d : cmd_rd_en_q;
      cmd_speed_q <= (new_command && !stall) ? cmd_speed_d : cmd_speed_q;
      cmd_len_q   <= (new_command && !stall) ? cmd_len_d : cmd_len_q;
    end
  end
  assign is_idle     = (state_q == Idle) || (state_q == IdleCSBActive);
  assign active_o   = ~is_idle;
  
  assign clk_cntr_d = sw_rst_i              ? 16'h0 :
                      !clk_cntr_en          ? clk_cntr_q :
                      new_command           ? clkdiv :
                      is_idle               ? clk_cntr_q :
                      (clk_cntr_q == 16'h0) ? clkdiv :
                      clk_cntr_q - 1;
  assign tx_stall_o = wr_en_internal & ~sr_wr_ready_i;
  assign rx_stall_o = rd_en_internal & ~sr_rd_ready_i;
  assign clk_cntr_en = en_i;
  assign fsm_en = (clk_cntr_en && ((clk_cntr_q == 0) || is_idle));
  spi_host_st_e next_state_after_idle;
  always_comb begin
    if (command_valid_i) begin
      if (config_changed) begin
         next_state_after_idle = CSBSwitch;
      end else begin
         next_state_after_idle = WaitLead;
      end
    end else begin
      next_state_after_idle = Idle;
    end
  end
  spi_host_st_e next_state_after_idle_csb_active;
  logic         command_ready_idle_csb_active;
  always_comb begin
    if (command_valid_i) begin
      if (command_csid_i != csid_q) begin
        
        
        
        
        
        
        next_state_after_idle_csb_active = WaitTrail;
        
        command_ready_idle_csb_active = 1'b0;
      end else begin
        if (cpha_q) begin
          next_state_after_idle_csb_active = InternalClkHigh;
        end else begin
          next_state_after_idle_csb_active = InternalClkLow;
        end
        command_ready_idle_csb_active = 1'b1;
      end
    end else begin
      next_state_after_idle_csb_active = IdleCSBActive;
      command_ready_idle_csb_active = 1'b1;
    end
  end
  
  
  
  always_comb begin
    state_d = state_q;
    command_ready_int = 1'b0;
    if (sw_rst_i) begin
      state_d = Idle;
    end else if (fsm_en) begin
      unique case (state_q)
        Idle: begin
          
          command_ready_int = 1'b1;
          state_d = next_state_after_idle;
        end
        WaitLead: begin
          
          if (wait_cntr_q == 4'h0) begin
            state_d = InternalClkHigh;
          end
        end
        InternalClkLow: begin
          
          
          
          
          if (!last_bit || !last_byte || !cpha_q) begin
            state_d = InternalClkHigh;
          end else if (!csaat_q) begin
            state_d = WaitTrail;
          end else begin
            state_d = next_state_after_idle_csb_active;
            command_ready_int = command_ready_idle_csb_active;
          end
        end
        InternalClkHigh: begin
          
          
          
          
          
          if (!last_bit || !last_byte || cpha_q) begin
            state_d = InternalClkLow;
          
          end else if (!csaat_q) begin
            state_d = WaitTrail;
          end else begin
            state_d = next_state_after_idle_csb_active;
            command_ready_int = command_ready_idle_csb_active;
          end
        end
        WaitTrail: begin
          
          if (wait_cntr_q == 4'h0) begin
            state_d = WaitIdle;
          end
        end
        WaitIdle: begin
          
          if (wait_cntr_q == 4'h0) begin
            
            command_ready_int = 1'b1;
            state_d = next_state_after_idle;
          end
        end
        CSBSwitch: begin
          
          
          
          if (wait_cntr_q == 4'h0) begin
            state_d = WaitLead;
          end else begin
            state_d = CSBSwitch;
          end
        end
        IdleCSBActive: begin
          
          state_d = next_state_after_idle_csb_active;
          command_ready_int = command_ready_idle_csb_active;
        end
        default: begin
          command_ready_int  = 1'b0;
          state_d = Idle;
        end
      endcase
    end
  end
  
  
  
  
  
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      state_q    <= Idle;
      clk_cntr_q <= 16'h0;
    end else begin
      state_q    <= stall ? state_q : state_d;
      clk_cntr_q <= stall ? clk_cntr_q : clk_cntr_d;
    end
  end
  logic segment_rd_en, segment_rd_en_cpha0, segment_rd_en_cpha1;
  assign state_changing = (state_q != state_d);
  assign byte_starting_cpha0 = ~sw_rst_i & state_changing &
                               ((state_d == WaitLead) |
                                (state_d == InternalClkLow & bit_cntr_q==0));
  assign bit_shifting_cpha0  = ~sw_rst_i & state_changing &
                               (state_d == InternalClkLow & bit_cntr_q != 0);
  assign byte_ending_cpha0   = ~sw_rst_i & state_changing &
                               (state_q == InternalClkHigh & bit_cntr_q == 0);
  assign segment_rd_en_cpha0 = cmd_rd_en_q;
  
  
  
  
  
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      segment_rd_en_cpha1   <= 1'b0;
    end else if (state_changing && !stall) begin
      segment_rd_en_cpha1   <= segment_rd_en_cpha0;
    end
  end
  
  
  
  assign byte_starting_cpha1 = ~sw_rst_i & state_changing &
                                (state_d == InternalClkHigh & bit_cntr_q==0);
  assign bit_shifting_cpha1  = ~sw_rst_i & state_changing &
                               (state_d == InternalClkHigh & bit_cntr_q != 0);
  assign byte_ending_cpha1   = ~sw_rst_i & state_changing &
                               (state_q == InternalClkLow & bit_cntr_q == 0);
  assign byte_starting = (cpha == 1'b0) ? byte_starting_cpha0 :
                                          byte_starting_cpha1;
  assign byte_ending   = (cpha == 1'b0) ? byte_ending_cpha0 :
                                          byte_ending_cpha1;
  assign bit_shifting  = (cpha == 1'b0) ? bit_shifting_cpha0 :
                                          bit_shifting_cpha1;
  assign speed_o       = cmd_speed_q;
  assign segment_rd_en = (cpha == 1'b0) ? segment_rd_en_cpha0:
                                          segment_rd_en_cpha1;
  assign byte_cntr_early = (cpha == 1'b0) ? byte_cntr_cpha0_d :
                                            byte_cntr_cpha1_d;
  assign byte_cntr_late  = (cpha == 1'b0) ? byte_cntr_cpha0_q :
                                            byte_cntr_cpha1_q;
  logic [2:0] shift_size;
  logic [2:0] start_bit;
  always_comb begin
    if (!cmd_rd_en_d && !cmd_wr_en_d) begin
      
      
      
      
      
      shift_size = 0;
      start_bit = 3'h0;
    end else begin
      unique case (cmd_speed_d)
        Standard: begin
          shift_size = 3'h1;
          start_bit  = 3'h7;
        end
        Dual:     begin
          shift_size = 3'h2;
          start_bit  = 3'h6;
        end
        Quad:     begin
          shift_size = 3'h4;
          start_bit  = 3'h4;
        end
        default: begin
          
          shift_size = 3'h1;
          start_bit  = 3'h1;
        end
      endcase
    end
  end
  assign bit_cntr_d = sw_rst_i         ? 3'h0 :
                      !fsm_en          ? bit_cntr_q :
                      byte_starting    ? start_bit :
                      bit_shifting     ? bit_cntr_q - shift_size :
                      bit_cntr_q;
  assign last_bit  = (bit_cntr_q == 3'h0);
  
  
  
  
  
  
  always_comb begin
    if (cpha_q) begin
      last_byte = (byte_cntr_cpha1_q == 20'h0);
    end else begin
      last_byte = (byte_cntr_cpha0_q == 20'h0);
    end
  end
  
  
  assign byte_cntr_cpha0_d = sw_rst_i    ? 20'h0 :
                             !fsm_en     ? byte_cntr_cpha0_q :
                             new_command ? cmd_len_d :
                             byte_ending_cpha0 ? byte_cntr_cpha0_q - 1 :
                             byte_cntr_cpha0_q;
  assign byte_cntr_cpha1_d = sw_rst_i          ? 20'h0 :
                             !fsm_en           ? byte_cntr_cpha1_q :
                             new_command       ? cmd_len_d :
                             byte_ending_cpha1 ? byte_cntr_cpha1_q - 1 :
                             byte_cntr_cpha1_q;
  always_comb begin
    if(sw_rst_i) begin
      wait_cntr_d = 4'b0;
    end else if (!fsm_en) begin
      wait_cntr_d = wait_cntr_q;
    end else if (state_changing) begin
      unique case (state_d)
         WaitLead: begin
           wait_cntr_d = csnlead;
         end
         WaitTrail: begin
           wait_cntr_d = csntrail;
         end
         WaitIdle: begin
           wait_cntr_d = csnidle;
         end
         CSBSwitch: begin
           wait_cntr_d = csnidle;
         end
         default: begin
           
           
           wait_cntr_d = 4'b0;
         end
      endcase
    end else if (wait_cntr_q == 0) begin
      wait_cntr_d = 4'h0;
    end else begin
      wait_cntr_d = wait_cntr_q - 1;
    end
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      bit_cntr_q        <= 3'h0;
      byte_cntr_cpha0_q <= 20'h0;
      byte_cntr_cpha1_q <= 20'h0;
      wait_cntr_q       <= 4'h0;
    end else begin
      bit_cntr_q        <= stall ? bit_cntr_q        : bit_cntr_d;
      byte_cntr_cpha0_q <= stall ? byte_cntr_cpha0_q : byte_cntr_cpha0_d;
      byte_cntr_cpha1_q <= stall ? byte_cntr_cpha1_q : byte_cntr_cpha1_d;
      wait_cntr_q       <= stall ? wait_cntr_q       : wait_cntr_d;
    end
  end
  assign wr_en_internal    = byte_starting & cmd_wr_en_d;
  assign shift_en_internal = bit_shifting;
  assign rd_en_internal    = byte_ending & segment_rd_en;
  assign sample_en_d       = byte_starting | shift_en_o;
  assign full_cyc_o        = full_cyc;
  assign last_read_o       = (byte_cntr_late == 'h0) & rd_en_o & sr_rd_ready_i;
  assign last_write_o      = (byte_cntr_early == 'h0) & wr_en_o & sr_wr_ready_i;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      sample_en_q <= 1'b0;
      sample_en_q2 <= 1'b0;
    end else begin
      sample_en_q  <= (fsm_en && !stall) ? sample_en_d : sample_en_q;
      sample_en_q2 <= (fsm_en && !stall) ? sample_en_q : sample_en_q2;
    end
  end
  assign sample_en_internal = full_cyc_o ? sample_en_q2 : sample_en_q;
  always_comb begin
    unique case (state_d)
      WaitLead, InternalClkLow, InternalClkHigh, IdleCSBActive, WaitTrail:
        csb_single_d = 1'b0;
      default:
        csb_single_d = 1'b1;
    endcase
  end
  assign sck_d = cpol ? (state_d != InternalClkHigh) :
                        (state_d == InternalClkHigh);
  assign sck_o = sck_q;
  prim_flop_en u_sck_flop (
    .clk_i,
    .rst_ni,
    .en_i(~stall),
    .d_i(sck_d),
    .q_o(sck_q)
  );
  for (genvar ii = 0; ii < NumCS; ii = ii + 1) begin : gen_csb_gen
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        csb_q[ii] <= 1'b1;
      end else begin
        csb_q[ii] <= (csid != ii) ? 1'b1 :
                     !stall       ? csb_single_d :
                     csb_q[ii];
      end
    end
  end : gen_csb_gen
  
  
  
  
  
  
  logic cmd_wr_en_last_bit;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      cmd_wr_en_last_bit <= 1'b0;
    end else if (cmd_wr_en_q & last_bit) begin
      cmd_wr_en_last_bit <= 1'b1;
    end else if (byte_ending) begin
      cmd_wr_en_last_bit <= 1'b0;
    end else begin 
      cmd_wr_en_last_bit <= cmd_wr_en_last_bit;
    end
  end
  assign csb_o = csb_q;
  always_comb begin
    if (&csb_o) begin
      sd_en_o[3:0] = 4'h0;
    end else begin
      unique case (speed_o)
        Standard: begin
          
          sd_en_o[0]   = cmd_wr_en_q | cmd_wr_en_last_bit;
          sd_en_o[1]   = 1'b0;
          sd_en_o[3:2] = 2'b00;
        end
        Dual:     begin
          sd_en_o[1:0] = {2{cmd_wr_en_q}};
          sd_en_o[3:2] = 2'b00;
        end
        Quad:     begin
          sd_en_o[3:0] = {4{cmd_wr_en_q}};
        end
        default: begin
          
          sd_en_o[3:0] = 4'h0;
        end
      endcase
    end
  end
  
  
  
  `ASSERT(BidirOnlyInStdMode_A,
      cmd_speed_d == Standard || !(cmd_rd_en_d && cmd_wr_en_d),
      clk_i, rst_ni)
  `ASSERT(ValidSpeed_A, cmd_speed_d != RsvdSpd, clk_i, rst_ni)
  `ASSERT(ValidCSID_A, csid < NumCS, clk_i, rst_ni)
endmodule

package spi_host_reg_pkg;
  
  parameter logic ByteOrder = 1;
  parameter int TxDepth = 72;
  parameter int RxDepth = 64;
  parameter int CmdDepth = 4;
  parameter int NumAlerts = 1;
  
  parameter int BlockAw = 6;
  
  parameter int NumRegs = 12;
  
  typedef enum int {
    AlertFatalFaultIdx = 0
  } spi_host_alert_idx_t;
  
  
  
  typedef struct packed {
    struct packed {
      logic        q;
    } spi_event;
    struct packed {
      logic        q;
    } error;
  } spi_host_reg2hw_intr_state_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } spi_event;
    struct packed {
      logic        q;
    } error;
  } spi_host_reg2hw_intr_enable_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } spi_event;
    struct packed {
      logic        q;
      logic        qe;
    } error;
  } spi_host_reg2hw_intr_test_reg_t;
  typedef struct packed {
    logic        q;
    logic        qe;
  } spi_host_reg2hw_alert_test_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } spien;
    struct packed {
      logic        q;
    } sw_rst;
    struct packed {
      logic        q;
    } output_en;
    struct packed {
      logic [7:0]  q;
    } tx_watermark;
    struct packed {
      logic [7:0]  q;
    } rx_watermark;
  } spi_host_reg2hw_control_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } cpol;
    struct packed {
      logic        q;
    } cpha;
    struct packed {
      logic        q;
    } fullcyc;
    struct packed {
      logic [3:0]  q;
    } csnlead;
    struct packed {
      logic [3:0]  q;
    } csntrail;
    struct packed {
      logic [3:0]  q;
    } csnidle;
    struct packed {
      logic [15:0] q;
    } clkdiv;
  } spi_host_reg2hw_configopts_reg_t;
  typedef struct packed {
    logic [31:0] q;
  } spi_host_reg2hw_csid_reg_t;
  typedef struct packed {
    struct packed {
      logic [19:0] q;
      logic        qe;
    } len;
    struct packed {
      logic [1:0]  q;
      logic        qe;
    } direction;
    struct packed {
      logic [1:0]  q;
      logic        qe;
    } speed;
    struct packed {
      logic        q;
      logic        qe;
    } csaat;
  } spi_host_reg2hw_command_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } csidinval;
    struct packed {
      logic        q;
    } cmdinval;
    struct packed {
      logic        q;
    } underflow;
    struct packed {
      logic        q;
    } overflow;
    struct packed {
      logic        q;
    } cmdbusy;
  } spi_host_reg2hw_error_enable_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } accessinval;
    struct packed {
      logic        q;
    } csidinval;
    struct packed {
      logic        q;
    } cmdinval;
    struct packed {
      logic        q;
    } underflow;
    struct packed {
      logic        q;
    } overflow;
    struct packed {
      logic        q;
    } cmdbusy;
  } spi_host_reg2hw_error_status_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } idle;
    struct packed {
      logic        q;
    } ready;
    struct packed {
      logic        q;
    } txwm;
    struct packed {
      logic        q;
    } rxwm;
    struct packed {
      logic        q;
    } txempty;
    struct packed {
      logic        q;
    } rxfull;
  } spi_host_reg2hw_event_enable_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } spi_event;
    struct packed {
      logic        d;
      logic        de;
    } error;
  } spi_host_hw2reg_intr_state_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } ready;
    struct packed {
      logic        d;
      logic        de;
    } active;
    struct packed {
      logic        d;
      logic        de;
    } txfull;
    struct packed {
      logic        d;
      logic        de;
    } txempty;
    struct packed {
      logic        d;
      logic        de;
    } txstall;
    struct packed {
      logic        d;
      logic        de;
    } txwm;
    struct packed {
      logic        d;
      logic        de;
    } rxfull;
    struct packed {
      logic        d;
      logic        de;
    } rxempty;
    struct packed {
      logic        d;
      logic        de;
    } rxstall;
    struct packed {
      logic        d;
      logic        de;
    } byteorder;
    struct packed {
      logic        d;
      logic        de;
    } rxwm;
    struct packed {
      logic [3:0]  d;
      logic        de;
    } cmdqd;
    struct packed {
      logic [7:0]  d;
      logic        de;
    } rxqd;
    struct packed {
      logic [7:0]  d;
      logic        de;
    } txqd;
  } spi_host_hw2reg_status_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } accessinval;
    struct packed {
      logic        d;
      logic        de;
    } csidinval;
    struct packed {
      logic        d;
      logic        de;
    } cmdinval;
    struct packed {
      logic        d;
      logic        de;
    } underflow;
    struct packed {
      logic        d;
      logic        de;
    } overflow;
    struct packed {
      logic        d;
      logic        de;
    } cmdbusy;
  } spi_host_hw2reg_error_status_reg_t;
  
  typedef struct packed {
    spi_host_reg2hw_intr_state_reg_t intr_state; 
    spi_host_reg2hw_intr_enable_reg_t intr_enable; 
    spi_host_reg2hw_intr_test_reg_t intr_test; 
    spi_host_reg2hw_alert_test_reg_t alert_test; 
    spi_host_reg2hw_control_reg_t control; 
    spi_host_reg2hw_configopts_reg_t configopts; 
    spi_host_reg2hw_csid_reg_t csid; 
    spi_host_reg2hw_command_reg_t command; 
    spi_host_reg2hw_error_enable_reg_t error_enable; 
    spi_host_reg2hw_error_status_reg_t error_status; 
    spi_host_reg2hw_event_enable_reg_t event_enable; 
  } spi_host_reg2hw_t;
  
  typedef struct packed {
    spi_host_hw2reg_intr_state_reg_t intr_state; 
    spi_host_hw2reg_status_reg_t status; 
    spi_host_hw2reg_error_status_reg_t error_status; 
  } spi_host_hw2reg_t;
  
  parameter logic [BlockAw-1:0] SPI_HOST_INTR_STATE_OFFSET = 6'h 0;
  parameter logic [BlockAw-1:0] SPI_HOST_INTR_ENABLE_OFFSET = 6'h 4;
  parameter logic [BlockAw-1:0] SPI_HOST_INTR_TEST_OFFSET = 6'h 8;
  parameter logic [BlockAw-1:0] SPI_HOST_ALERT_TEST_OFFSET = 6'h c;
  parameter logic [BlockAw-1:0] SPI_HOST_CONTROL_OFFSET = 6'h 10;
  parameter logic [BlockAw-1:0] SPI_HOST_STATUS_OFFSET = 6'h 14;
  parameter logic [BlockAw-1:0] SPI_HOST_CONFIGOPTS_OFFSET = 6'h 18;
  parameter logic [BlockAw-1:0] SPI_HOST_CSID_OFFSET = 6'h 1c;
  parameter logic [BlockAw-1:0] SPI_HOST_COMMAND_OFFSET = 6'h 20;
  parameter logic [BlockAw-1:0] SPI_HOST_ERROR_ENABLE_OFFSET = 6'h 2c;
  parameter logic [BlockAw-1:0] SPI_HOST_ERROR_STATUS_OFFSET = 6'h 30;
  parameter logic [BlockAw-1:0] SPI_HOST_EVENT_ENABLE_OFFSET = 6'h 34;
  
  parameter logic [1:0] SPI_HOST_INTR_TEST_RESVAL = 2'h 0;
  parameter logic [0:0] SPI_HOST_INTR_TEST_ERROR_RESVAL = 1'h 0;
  parameter logic [0:0] SPI_HOST_INTR_TEST_SPI_EVENT_RESVAL = 1'h 0;
  parameter logic [0:0] SPI_HOST_ALERT_TEST_RESVAL = 1'h 0;
  parameter logic [0:0] SPI_HOST_ALERT_TEST_FATAL_FAULT_RESVAL = 1'h 0;
  parameter logic [24:0] SPI_HOST_COMMAND_RESVAL = 25'h 0;
  parameter logic [0:0] SPI_HOST_COMMAND_CSAAT_RESVAL = 1'h 0;
  parameter logic [1:0] SPI_HOST_COMMAND_SPEED_RESVAL = 2'h 0;
  parameter logic [1:0] SPI_HOST_COMMAND_DIRECTION_RESVAL = 2'h 0;
  parameter logic [19:0] SPI_HOST_COMMAND_LEN_RESVAL = 20'h 0;
  
  parameter logic [BlockAw-1:0] SPI_HOST_RXDATA_OFFSET = 6'h 24;
  parameter int unsigned        SPI_HOST_RXDATA_SIZE   = 'h 4;
  parameter int unsigned        SPI_HOST_RXDATA_IDX    = 0;
  parameter logic [BlockAw-1:0] SPI_HOST_TXDATA_OFFSET = 6'h 28;
  parameter int unsigned        SPI_HOST_TXDATA_SIZE   = 'h 4;
  parameter int unsigned        SPI_HOST_TXDATA_IDX    = 1;
  
  typedef enum int {
    SPI_HOST_INTR_STATE,
    SPI_HOST_INTR_ENABLE,
    SPI_HOST_INTR_TEST,
    SPI_HOST_ALERT_TEST,
    SPI_HOST_CONTROL,
    SPI_HOST_STATUS,
    SPI_HOST_CONFIGOPTS,
    SPI_HOST_CSID,
    SPI_HOST_COMMAND,
    SPI_HOST_ERROR_ENABLE,
    SPI_HOST_ERROR_STATUS,
    SPI_HOST_EVENT_ENABLE
  } spi_host_id_e;
  
  parameter logic [3:0] SPI_HOST_PERMIT [12] = '{
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 0001, 
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
module spi_host_reg_top
  # (
    parameter bit          EnableRacl           = 1'b0,
    parameter bit          RaclErrorRsp         = 1'b1,
    parameter top_racl_pkg::racl_policy_sel_t RaclPolicySelVec[spi_host_reg_pkg::NumRegs] =
      '{spi_host_reg_pkg::NumRegs{0}}
  ) (
  input clk_i,
  input rst_ni,
  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,
  
  output tlul_pkg::tl_h2d_t tl_win_o  [2],
  input  tlul_pkg::tl_d2h_t tl_win_i  [2],
  
  output spi_host_reg_pkg::spi_host_reg2hw_t reg2hw, 
  input  spi_host_reg_pkg::spi_host_hw2reg_t hw2reg, 
  
  input  top_racl_pkg::racl_policy_vec_t racl_policies_i,
  output top_racl_pkg::racl_error_log_t  racl_error_o,
  
  output logic intg_err_o
);
  import spi_host_reg_pkg::* ;
  localparam int AW = 6;
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
  logic [11:0] reg_we_check;
  prim_reg_we_check #(
    .OneHotWidth(12)
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
  tlul_pkg::tl_h2d_t tl_socket_h2d [3];
  tlul_pkg::tl_d2h_t tl_socket_d2h [3];
  logic [1:0] reg_steer;
  
  assign tl_reg_h2d = tl_socket_h2d[2];
  assign tl_socket_d2h[2] = tl_reg_d2h;
  assign tl_win_o[0] = tl_socket_h2d[0];
  assign tl_socket_d2h[0] = tl_win_i[0];
  assign tl_win_o[1] = tl_socket_h2d[1];
  assign tl_socket_d2h[1] = tl_win_i[1];
  
  tlul_socket_1n #(
    .N            (3),
    .HReqPass     (1'b1),
    .HRspPass     (1'b1),
    .DReqPass     ({3{1'b1}}),
    .DRspPass     ({3{1'b1}}),
    .HReqDepth    (4'h0),
    .HRspDepth    (4'h0),
    .DReqDepth    ({3{4'h0}}),
    .DRspDepth    ({3{4'h0}}),
    .ExplicitErrs (1'b0)
  ) u_socket (
    .clk_i  (clk_i),
    .rst_ni (rst_ni),
    .tl_h_i (tl_i),
    .tl_h_o (tl_o_pre),
    .tl_d_o (tl_socket_h2d),
    .tl_d_i (tl_socket_d2h),
    .dev_select_i (reg_steer)
  );
  
  always_comb begin
    reg_steer =
        tl_i.a_address[AW-1:0] inside {[36:39]} ? 2'd0 :
        tl_i.a_address[AW-1:0] inside {[40:43]} ? 2'd1 :
        
        2'd2;
    
    if (intg_err) begin
      reg_steer = 2'd2;
    end
  end
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
    
    .error_i (reg_error | (RaclErrorRsp & racl_error_o.valid))
  );
  
  assign reg_rdata = reg_rdata_next ;
  assign reg_error = addrmiss | wr_err | intg_err;
  
  
  
  logic intr_state_we;
  logic intr_state_error_qs;
  logic intr_state_error_wd;
  logic intr_state_spi_event_qs;
  logic intr_enable_we;
  logic intr_enable_error_qs;
  logic intr_enable_error_wd;
  logic intr_enable_spi_event_qs;
  logic intr_enable_spi_event_wd;
  logic intr_test_we;
  logic intr_test_error_wd;
  logic intr_test_spi_event_wd;
  logic alert_test_we;
  logic alert_test_wd;
  logic control_we;
  logic [7:0] control_rx_watermark_qs;
  logic [7:0] control_rx_watermark_wd;
  logic [7:0] control_tx_watermark_qs;
  logic [7:0] control_tx_watermark_wd;
  logic control_output_en_qs;
  logic control_output_en_wd;
  logic control_sw_rst_qs;
  logic control_sw_rst_wd;
  logic control_spien_qs;
  logic control_spien_wd;
  logic [7:0] status_txqd_qs;
  logic [7:0] status_rxqd_qs;
  logic [3:0] status_cmdqd_qs;
  logic status_rxwm_qs;
  logic status_byteorder_qs;
  logic status_rxstall_qs;
  logic status_rxempty_qs;
  logic status_rxfull_qs;
  logic status_txwm_qs;
  logic status_txstall_qs;
  logic status_txempty_qs;
  logic status_txfull_qs;
  logic status_active_qs;
  logic status_ready_qs;
  logic configopts_we;
  logic [15:0] configopts_clkdiv_qs;
  logic [15:0] configopts_clkdiv_wd;
  logic [3:0] configopts_csnidle_qs;
  logic [3:0] configopts_csnidle_wd;
  logic [3:0] configopts_csntrail_qs;
  logic [3:0] configopts_csntrail_wd;
  logic [3:0] configopts_csnlead_qs;
  logic [3:0] configopts_csnlead_wd;
  logic configopts_fullcyc_qs;
  logic configopts_fullcyc_wd;
  logic configopts_cpha_qs;
  logic configopts_cpha_wd;
  logic configopts_cpol_qs;
  logic configopts_cpol_wd;
  logic csid_we;
  logic [31:0] csid_qs;
  logic [31:0] csid_wd;
  logic command_we;
  logic command_csaat_wd;
  logic [1:0] command_speed_wd;
  logic [1:0] command_direction_wd;
  logic [19:0] command_len_wd;
  logic error_enable_we;
  logic error_enable_cmdbusy_qs;
  logic error_enable_cmdbusy_wd;
  logic error_enable_overflow_qs;
  logic error_enable_overflow_wd;
  logic error_enable_underflow_qs;
  logic error_enable_underflow_wd;
  logic error_enable_cmdinval_qs;
  logic error_enable_cmdinval_wd;
  logic error_enable_csidinval_qs;
  logic error_enable_csidinval_wd;
  logic error_status_we;
  logic error_status_cmdbusy_qs;
  logic error_status_cmdbusy_wd;
  logic error_status_overflow_qs;
  logic error_status_overflow_wd;
  logic error_status_underflow_qs;
  logic error_status_underflow_wd;
  logic error_status_cmdinval_qs;
  logic error_status_cmdinval_wd;
  logic error_status_csidinval_qs;
  logic error_status_csidinval_wd;
  logic error_status_accessinval_qs;
  logic error_status_accessinval_wd;
  logic event_enable_we;
  logic event_enable_rxfull_qs;
  logic event_enable_rxfull_wd;
  logic event_enable_txempty_qs;
  logic event_enable_txempty_wd;
  logic event_enable_rxwm_qs;
  logic event_enable_rxwm_wd;
  logic event_enable_txwm_qs;
  logic event_enable_txwm_wd;
  logic event_enable_ready_qs;
  logic event_enable_ready_wd;
  logic event_enable_idle_qs;
  logic event_enable_idle_wd;
  
  
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_state_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_state_we),
    .wd     (intr_state_error_wd),
    
    .de     (hw2reg.intr_state.error.de),
    .d      (hw2reg.intr_state.error.d),
    
    .qe     (),
    .q      (reg2hw.intr_state.error.q),
    .ds     (),
    
    .qs     (intr_state_error_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_state_spi_event (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.intr_state.spi_event.de),
    .d      (hw2reg.intr_state.spi_event.d),
    
    .qe     (),
    .q      (reg2hw.intr_state.spi_event.q),
    .ds     (),
    
    .qs     (intr_state_spi_event_qs)
  );
  
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_enable_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_enable_we),
    .wd     (intr_enable_error_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_enable.error.q),
    .ds     (),
    
    .qs     (intr_enable_error_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_enable_spi_event (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_enable_we),
    .wd     (intr_enable_spi_event_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_enable.spi_event.q),
    .ds     (),
    
    .qs     (intr_enable_spi_event_qs)
  );
  
  logic intr_test_qe;
  logic [1:0] intr_test_flds_we;
  assign intr_test_qe = &intr_test_flds_we;
  
  prim_subreg_ext #(
    .DW    (1)
  ) u_intr_test_error (
    .re     (1'b0),
    .we     (intr_test_we),
    .wd     (intr_test_error_wd),
    .d      ('0),
    .qre    (),
    .qe     (intr_test_flds_we[0]),
    .q      (reg2hw.intr_test.error.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.intr_test.error.qe = intr_test_qe;
  
  prim_subreg_ext #(
    .DW    (1)
  ) u_intr_test_spi_event (
    .re     (1'b0),
    .we     (intr_test_we),
    .wd     (intr_test_spi_event_wd),
    .d      ('0),
    .qre    (),
    .qe     (intr_test_flds_we[1]),
    .q      (reg2hw.intr_test.spi_event.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.intr_test.spi_event.qe = intr_test_qe;
  
  logic alert_test_qe;
  logic [0:0] alert_test_flds_we;
  assign alert_test_qe = &alert_test_flds_we;
  prim_subreg_ext #(
    .DW    (1)
  ) u_alert_test (
    .re     (1'b0),
    .we     (alert_test_we),
    .wd     (alert_test_wd),
    .d      ('0),
    .qre    (),
    .qe     (alert_test_flds_we[0]),
    .q      (reg2hw.alert_test.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.alert_test.qe = alert_test_qe;
  
  
  prim_subreg #(
    .DW      (8),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (8'h7f),
    .Mubi    (1'b0)
  ) u_control_rx_watermark (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (control_we),
    .wd     (control_rx_watermark_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.control.rx_watermark.q),
    .ds     (),
    
    .qs     (control_rx_watermark_qs)
  );
  
  prim_subreg #(
    .DW      (8),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (8'h0),
    .Mubi    (1'b0)
  ) u_control_tx_watermark (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (control_we),
    .wd     (control_tx_watermark_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.control.tx_watermark.q),
    .ds     (),
    
    .qs     (control_tx_watermark_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_control_output_en (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (control_we),
    .wd     (control_output_en_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.control.output_en.q),
    .ds     (),
    
    .qs     (control_output_en_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_control_sw_rst (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (control_we),
    .wd     (control_sw_rst_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.control.sw_rst.q),
    .ds     (),
    
    .qs     (control_sw_rst_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_control_spien (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (control_we),
    .wd     (control_spien_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.control.spien.q),
    .ds     (),
    
    .qs     (control_spien_qs)
  );
  
  
  prim_subreg #(
    .DW      (8),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (8'h0),
    .Mubi    (1'b0)
  ) u_status_txqd (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.txqd.de),
    .d      (hw2reg.status.txqd.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_txqd_qs)
  );
  
  prim_subreg #(
    .DW      (8),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (8'h0),
    .Mubi    (1'b0)
  ) u_status_rxqd (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.rxqd.de),
    .d      (hw2reg.status.rxqd.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_rxqd_qs)
  );
  
  prim_subreg #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (4'h0),
    .Mubi    (1'b0)
  ) u_status_cmdqd (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.cmdqd.de),
    .d      (hw2reg.status.cmdqd.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_cmdqd_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_rxwm (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.rxwm.de),
    .d      (hw2reg.status.rxwm.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_rxwm_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_byteorder (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.byteorder.de),
    .d      (hw2reg.status.byteorder.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_byteorder_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_rxstall (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.rxstall.de),
    .d      (hw2reg.status.rxstall.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_rxstall_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_rxempty (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.rxempty.de),
    .d      (hw2reg.status.rxempty.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_rxempty_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_rxfull (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.rxfull.de),
    .d      (hw2reg.status.rxfull.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_rxfull_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_txwm (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.txwm.de),
    .d      (hw2reg.status.txwm.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_txwm_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_txstall (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.txstall.de),
    .d      (hw2reg.status.txstall.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_txstall_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_txempty (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.txempty.de),
    .d      (hw2reg.status.txempty.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_txempty_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_txfull (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.txfull.de),
    .d      (hw2reg.status.txfull.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_txfull_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_active (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.active.de),
    .d      (hw2reg.status.active.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_active_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_ready (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.ready.de),
    .d      (hw2reg.status.ready.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (status_ready_qs)
  );
  
  
  prim_subreg #(
    .DW      (16),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (16'h0),
    .Mubi    (1'b0)
  ) u_configopts_clkdiv (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (configopts_we),
    .wd     (configopts_clkdiv_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.configopts.clkdiv.q),
    .ds     (),
    
    .qs     (configopts_clkdiv_qs)
  );
  
  prim_subreg #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (4'h0),
    .Mubi    (1'b0)
  ) u_configopts_csnidle (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (configopts_we),
    .wd     (configopts_csnidle_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.configopts.csnidle.q),
    .ds     (),
    
    .qs     (configopts_csnidle_qs)
  );
  
  prim_subreg #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (4'h0),
    .Mubi    (1'b0)
  ) u_configopts_csntrail (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (configopts_we),
    .wd     (configopts_csntrail_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.configopts.csntrail.q),
    .ds     (),
    
    .qs     (configopts_csntrail_qs)
  );
  
  prim_subreg #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (4'h0),
    .Mubi    (1'b0)
  ) u_configopts_csnlead (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (configopts_we),
    .wd     (configopts_csnlead_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.configopts.csnlead.q),
    .ds     (),
    
    .qs     (configopts_csnlead_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_configopts_fullcyc (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (configopts_we),
    .wd     (configopts_fullcyc_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.configopts.fullcyc.q),
    .ds     (),
    
    .qs     (configopts_fullcyc_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_configopts_cpha (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (configopts_we),
    .wd     (configopts_cpha_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.configopts.cpha.q),
    .ds     (),
    
    .qs     (configopts_cpha_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_configopts_cpol (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (configopts_we),
    .wd     (configopts_cpol_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.configopts.cpol.q),
    .ds     (),
    
    .qs     (configopts_cpol_qs)
  );
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_csid (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csid_we),
    .wd     (csid_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csid.q),
    .ds     (),
    
    .qs     (csid_qs)
  );
  
  logic command_qe;
  logic [3:0] command_flds_we;
  assign command_qe = &command_flds_we;
  
  prim_subreg_ext #(
    .DW    (1)
  ) u_command_csaat (
    .re     (1'b0),
    .we     (command_we),
    .wd     (command_csaat_wd),
    .d      ('0),
    .qre    (),
    .qe     (command_flds_we[0]),
    .q      (reg2hw.command.csaat.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.command.csaat.qe = command_qe;
  
  prim_subreg_ext #(
    .DW    (2)
  ) u_command_speed (
    .re     (1'b0),
    .we     (command_we),
    .wd     (command_speed_wd),
    .d      ('0),
    .qre    (),
    .qe     (command_flds_we[1]),
    .q      (reg2hw.command.speed.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.command.speed.qe = command_qe;
  
  prim_subreg_ext #(
    .DW    (2)
  ) u_command_direction (
    .re     (1'b0),
    .we     (command_we),
    .wd     (command_direction_wd),
    .d      ('0),
    .qre    (),
    .qe     (command_flds_we[2]),
    .q      (reg2hw.command.direction.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.command.direction.qe = command_qe;
  
  prim_subreg_ext #(
    .DW    (20)
  ) u_command_len (
    .re     (1'b0),
    .we     (command_we),
    .wd     (command_len_wd),
    .d      ('0),
    .qre    (),
    .qe     (command_flds_we[3]),
    .q      (reg2hw.command.len.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.command.len.qe = command_qe;
  
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h1),
    .Mubi    (1'b0)
  ) u_error_enable_cmdbusy (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (error_enable_we),
    .wd     (error_enable_cmdbusy_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.error_enable.cmdbusy.q),
    .ds     (),
    
    .qs     (error_enable_cmdbusy_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h1),
    .Mubi    (1'b0)
  ) u_error_enable_overflow (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (error_enable_we),
    .wd     (error_enable_overflow_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.error_enable.overflow.q),
    .ds     (),
    
    .qs     (error_enable_overflow_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h1),
    .Mubi    (1'b0)
  ) u_error_enable_underflow (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (error_enable_we),
    .wd     (error_enable_underflow_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.error_enable.underflow.q),
    .ds     (),
    
    .qs     (error_enable_underflow_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h1),
    .Mubi    (1'b0)
  ) u_error_enable_cmdinval (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (error_enable_we),
    .wd     (error_enable_cmdinval_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.error_enable.cmdinval.q),
    .ds     (),
    
    .qs     (error_enable_cmdinval_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h1),
    .Mubi    (1'b0)
  ) u_error_enable_csidinval (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (error_enable_we),
    .wd     (error_enable_csidinval_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.error_enable.csidinval.q),
    .ds     (),
    
    .qs     (error_enable_csidinval_qs)
  );
  
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_status_cmdbusy (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (error_status_we),
    .wd     (error_status_cmdbusy_wd),
    
    .de     (hw2reg.error_status.cmdbusy.de),
    .d      (hw2reg.error_status.cmdbusy.d),
    
    .qe     (),
    .q      (reg2hw.error_status.cmdbusy.q),
    .ds     (),
    
    .qs     (error_status_cmdbusy_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_status_overflow (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (error_status_we),
    .wd     (error_status_overflow_wd),
    
    .de     (hw2reg.error_status.overflow.de),
    .d      (hw2reg.error_status.overflow.d),
    
    .qe     (),
    .q      (reg2hw.error_status.overflow.q),
    .ds     (),
    
    .qs     (error_status_overflow_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_status_underflow (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (error_status_we),
    .wd     (error_status_underflow_wd),
    
    .de     (hw2reg.error_status.underflow.de),
    .d      (hw2reg.error_status.underflow.d),
    
    .qe     (),
    .q      (reg2hw.error_status.underflow.q),
    .ds     (),
    
    .qs     (error_status_underflow_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_status_cmdinval (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (error_status_we),
    .wd     (error_status_cmdinval_wd),
    
    .de     (hw2reg.error_status.cmdinval.de),
    .d      (hw2reg.error_status.cmdinval.d),
    
    .qe     (),
    .q      (reg2hw.error_status.cmdinval.q),
    .ds     (),
    
    .qs     (error_status_cmdinval_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_status_csidinval (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (error_status_we),
    .wd     (error_status_csidinval_wd),
    
    .de     (hw2reg.error_status.csidinval.de),
    .d      (hw2reg.error_status.csidinval.d),
    
    .qe     (),
    .q      (reg2hw.error_status.csidinval.q),
    .ds     (),
    
    .qs     (error_status_csidinval_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_status_accessinval (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (error_status_we),
    .wd     (error_status_accessinval_wd),
    
    .de     (hw2reg.error_status.accessinval.de),
    .d      (hw2reg.error_status.accessinval.d),
    
    .qe     (),
    .q      (reg2hw.error_status.accessinval.q),
    .ds     (),
    
    .qs     (error_status_accessinval_qs)
  );
  
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_event_enable_rxfull (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (event_enable_we),
    .wd     (event_enable_rxfull_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.event_enable.rxfull.q),
    .ds     (),
    
    .qs     (event_enable_rxfull_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_event_enable_txempty (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (event_enable_we),
    .wd     (event_enable_txempty_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.event_enable.txempty.q),
    .ds     (),
    
    .qs     (event_enable_txempty_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_event_enable_rxwm (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (event_enable_we),
    .wd     (event_enable_rxwm_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.event_enable.rxwm.q),
    .ds     (),
    
    .qs     (event_enable_rxwm_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_event_enable_txwm (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (event_enable_we),
    .wd     (event_enable_txwm_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.event_enable.txwm.q),
    .ds     (),
    
    .qs     (event_enable_txwm_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_event_enable_ready (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (event_enable_we),
    .wd     (event_enable_ready_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.event_enable.ready.q),
    .ds     (),
    
    .qs     (event_enable_ready_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_event_enable_idle (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (event_enable_we),
    .wd     (event_enable_idle_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.event_enable.idle.q),
    .ds     (),
    
    .qs     (event_enable_idle_qs)
  );
  logic [11:0] addr_hit;
  top_racl_pkg::racl_role_vec_t racl_role_vec;
  top_racl_pkg::racl_role_t racl_role;
  logic [11:0] racl_addr_hit_read;
  logic [11:0] racl_addr_hit_write;
  if (EnableRacl) begin : gen_racl_role_logic
    
    assign racl_role = top_racl_pkg::tlul_extract_racl_role_bits(tl_i.a_user.rsvd);
    prim_onehot_enc #(
      .OneHotWidth( $bits(top_racl_pkg::racl_role_vec_t) )
    ) u_racl_role_encode (
      .in_i ( racl_role     ),
      .en_i ( 1'b1          ),
      .out_o( racl_role_vec )
    );
  end else begin : gen_no_racl_role_logic
    assign racl_role     = '0;
    assign racl_role_vec = '0;
  end
  always_comb begin
    racl_addr_hit_read  = '0;
    racl_addr_hit_write = '0;
    addr_hit[ 0] = (reg_addr == SPI_HOST_INTR_STATE_OFFSET);
    addr_hit[ 1] = (reg_addr == SPI_HOST_INTR_ENABLE_OFFSET);
    addr_hit[ 2] = (reg_addr == SPI_HOST_INTR_TEST_OFFSET);
    addr_hit[ 3] = (reg_addr == SPI_HOST_ALERT_TEST_OFFSET);
    addr_hit[ 4] = (reg_addr == SPI_HOST_CONTROL_OFFSET);
    addr_hit[ 5] = (reg_addr == SPI_HOST_STATUS_OFFSET);
    addr_hit[ 6] = (reg_addr == SPI_HOST_CONFIGOPTS_OFFSET);
    addr_hit[ 7] = (reg_addr == SPI_HOST_CSID_OFFSET);
    addr_hit[ 8] = (reg_addr == SPI_HOST_COMMAND_OFFSET);
    addr_hit[ 9] = (reg_addr == SPI_HOST_ERROR_ENABLE_OFFSET);
    addr_hit[10] = (reg_addr == SPI_HOST_ERROR_STATUS_OFFSET);
    addr_hit[11] = (reg_addr == SPI_HOST_EVENT_ENABLE_OFFSET);
    if (EnableRacl) begin : gen_racl_hit
      for (int unsigned slice_idx = 0; slice_idx < 12; slice_idx++) begin
        racl_addr_hit_read[slice_idx] =
            addr_hit[slice_idx] & (|(racl_policies_i[RaclPolicySelVec[slice_idx]].read_perm
                                      & racl_role_vec));
        racl_addr_hit_write[slice_idx] =
            addr_hit[slice_idx] & (|(racl_policies_i[RaclPolicySelVec[slice_idx]].write_perm
                                      & racl_role_vec));
      end
    end else begin : gen_no_racl
      racl_addr_hit_read  = addr_hit;
      racl_addr_hit_write = addr_hit;
    end
  end
  assign addrmiss = (reg_re || reg_we) ? ~|addr_hit : 1'b0 ;
  
  assign racl_error_o.valid = |addr_hit & ((reg_re & ~|racl_addr_hit_read) |
                                           (reg_we & ~|racl_addr_hit_write));
  assign racl_error_o.request_address = top_pkg::TL_AW'(reg_addr);
  assign racl_error_o.racl_role       = racl_role;
  assign racl_error_o.overflow        = 1'b0;
  if (EnableRacl) begin : gen_racl_log
    assign racl_error_o.ctn_uid     = top_racl_pkg::tlul_extract_ctn_uid_bits(tl_i.a_user.rsvd);
    assign racl_error_o.read_access = tl_i.a_opcode == tlul_pkg::Get;
  end else begin : gen_no_racl_log
    assign racl_error_o.ctn_uid     = '0;
    assign racl_error_o.read_access = 1'b0;
  end
  
  always_comb begin
    wr_err = (reg_we &
              ((racl_addr_hit_write[ 0] & (|(SPI_HOST_PERMIT[ 0] & ~reg_be))) |
               (racl_addr_hit_write[ 1] & (|(SPI_HOST_PERMIT[ 1] & ~reg_be))) |
               (racl_addr_hit_write[ 2] & (|(SPI_HOST_PERMIT[ 2] & ~reg_be))) |
               (racl_addr_hit_write[ 3] & (|(SPI_HOST_PERMIT[ 3] & ~reg_be))) |
               (racl_addr_hit_write[ 4] & (|(SPI_HOST_PERMIT[ 4] & ~reg_be))) |
               (racl_addr_hit_write[ 5] & (|(SPI_HOST_PERMIT[ 5] & ~reg_be))) |
               (racl_addr_hit_write[ 6] & (|(SPI_HOST_PERMIT[ 6] & ~reg_be))) |
               (racl_addr_hit_write[ 7] & (|(SPI_HOST_PERMIT[ 7] & ~reg_be))) |
               (racl_addr_hit_write[ 8] & (|(SPI_HOST_PERMIT[ 8] & ~reg_be))) |
               (racl_addr_hit_write[ 9] & (|(SPI_HOST_PERMIT[ 9] & ~reg_be))) |
               (racl_addr_hit_write[10] & (|(SPI_HOST_PERMIT[10] & ~reg_be))) |
               (racl_addr_hit_write[11] & (|(SPI_HOST_PERMIT[11] & ~reg_be)))));
  end
  
  assign intr_state_we = racl_addr_hit_write[0] & reg_we & !reg_error;
  assign intr_state_error_wd = reg_wdata[0];
  assign intr_enable_we = racl_addr_hit_write[1] & reg_we & !reg_error;
  assign intr_enable_error_wd = reg_wdata[0];
  assign intr_enable_spi_event_wd = reg_wdata[1];
  assign intr_test_we = racl_addr_hit_write[2] & reg_we & !reg_error;
  assign intr_test_error_wd = reg_wdata[0];
  assign intr_test_spi_event_wd = reg_wdata[1];
  assign alert_test_we = racl_addr_hit_write[3] & reg_we & !reg_error;
  assign alert_test_wd = reg_wdata[0];
  assign control_we = racl_addr_hit_write[4] & reg_we & !reg_error;
  assign control_rx_watermark_wd = reg_wdata[7:0];
  assign control_tx_watermark_wd = reg_wdata[15:8];
  assign control_output_en_wd = reg_wdata[29];
  assign control_sw_rst_wd = reg_wdata[30];
  assign control_spien_wd = reg_wdata[31];
  assign configopts_we = racl_addr_hit_write[6] & reg_we & !reg_error;
  assign configopts_clkdiv_wd = reg_wdata[15:0];
  assign configopts_csnidle_wd = reg_wdata[19:16];
  assign configopts_csntrail_wd = reg_wdata[23:20];
  assign configopts_csnlead_wd = reg_wdata[27:24];
  assign configopts_fullcyc_wd = reg_wdata[29];
  assign configopts_cpha_wd = reg_wdata[30];
  assign configopts_cpol_wd = reg_wdata[31];
  assign csid_we = racl_addr_hit_write[7] & reg_we & !reg_error;
  assign csid_wd = reg_wdata[31:0];
  assign command_we = racl_addr_hit_write[8] & reg_we & !reg_error;
  assign command_csaat_wd = reg_wdata[0];
  assign command_speed_wd = reg_wdata[2:1];
  assign command_direction_wd = reg_wdata[4:3];
  assign command_len_wd = reg_wdata[24:5];
  assign error_enable_we = racl_addr_hit_write[9] & reg_we & !reg_error;
  assign error_enable_cmdbusy_wd = reg_wdata[0];
  assign error_enable_overflow_wd = reg_wdata[1];
  assign error_enable_underflow_wd = reg_wdata[2];
  assign error_enable_cmdinval_wd = reg_wdata[3];
  assign error_enable_csidinval_wd = reg_wdata[4];
  assign error_status_we = racl_addr_hit_write[10] & reg_we & !reg_error;
  assign error_status_cmdbusy_wd = reg_wdata[0];
  assign error_status_overflow_wd = reg_wdata[1];
  assign error_status_underflow_wd = reg_wdata[2];
  assign error_status_cmdinval_wd = reg_wdata[3];
  assign error_status_csidinval_wd = reg_wdata[4];
  assign error_status_accessinval_wd = reg_wdata[5];
  assign event_enable_we = racl_addr_hit_write[11] & reg_we & !reg_error;
  assign event_enable_rxfull_wd = reg_wdata[0];
  assign event_enable_txempty_wd = reg_wdata[1];
  assign event_enable_rxwm_wd = reg_wdata[2];
  assign event_enable_txwm_wd = reg_wdata[3];
  assign event_enable_ready_wd = reg_wdata[4];
  assign event_enable_idle_wd = reg_wdata[5];
  
  always_comb begin
    reg_we_check[0] = intr_state_we;
    reg_we_check[1] = intr_enable_we;
    reg_we_check[2] = intr_test_we;
    reg_we_check[3] = alert_test_we;
    reg_we_check[4] = control_we;
    reg_we_check[5] = 1'b0;
    reg_we_check[6] = configopts_we;
    reg_we_check[7] = csid_we;
    reg_we_check[8] = command_we;
    reg_we_check[9] = error_enable_we;
    reg_we_check[10] = error_status_we;
    reg_we_check[11] = event_enable_we;
  end
  
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      racl_addr_hit_read[0]: begin
        reg_rdata_next[0] = intr_state_error_qs;
        reg_rdata_next[1] = intr_state_spi_event_qs;
      end
      racl_addr_hit_read[1]: begin
        reg_rdata_next[0] = intr_enable_error_qs;
        reg_rdata_next[1] = intr_enable_spi_event_qs;
      end
      racl_addr_hit_read[2]: begin
        reg_rdata_next[0] = '0;
        reg_rdata_next[1] = '0;
      end
      racl_addr_hit_read[3]: begin
        reg_rdata_next[0] = '0;
      end
      racl_addr_hit_read[4]: begin
        reg_rdata_next[7:0] = control_rx_watermark_qs;
        reg_rdata_next[15:8] = control_tx_watermark_qs;
        reg_rdata_next[29] = control_output_en_qs;
        reg_rdata_next[30] = control_sw_rst_qs;
        reg_rdata_next[31] = control_spien_qs;
      end
      racl_addr_hit_read[5]: begin
        reg_rdata_next[7:0] = status_txqd_qs;
        reg_rdata_next[15:8] = status_rxqd_qs;
        reg_rdata_next[19:16] = status_cmdqd_qs;
        reg_rdata_next[20] = status_rxwm_qs;
        reg_rdata_next[22] = status_byteorder_qs;
        reg_rdata_next[23] = status_rxstall_qs;
        reg_rdata_next[24] = status_rxempty_qs;
        reg_rdata_next[25] = status_rxfull_qs;
        reg_rdata_next[26] = status_txwm_qs;
        reg_rdata_next[27] = status_txstall_qs;
        reg_rdata_next[28] = status_txempty_qs;
        reg_rdata_next[29] = status_txfull_qs;
        reg_rdata_next[30] = status_active_qs;
        reg_rdata_next[31] = status_ready_qs;
      end
      racl_addr_hit_read[6]: begin
        reg_rdata_next[15:0] = configopts_clkdiv_qs;
        reg_rdata_next[19:16] = configopts_csnidle_qs;
        reg_rdata_next[23:20] = configopts_csntrail_qs;
        reg_rdata_next[27:24] = configopts_csnlead_qs;
        reg_rdata_next[29] = configopts_fullcyc_qs;
        reg_rdata_next[30] = configopts_cpha_qs;
        reg_rdata_next[31] = configopts_cpol_qs;
      end
      racl_addr_hit_read[7]: begin
        reg_rdata_next[31:0] = csid_qs;
      end
      racl_addr_hit_read[8]: begin
        reg_rdata_next[0] = '0;
        reg_rdata_next[2:1] = '0;
        reg_rdata_next[4:3] = '0;
        reg_rdata_next[24:5] = '0;
      end
      racl_addr_hit_read[9]: begin
        reg_rdata_next[0] = error_enable_cmdbusy_qs;
        reg_rdata_next[1] = error_enable_overflow_qs;
        reg_rdata_next[2] = error_enable_underflow_qs;
        reg_rdata_next[3] = error_enable_cmdinval_qs;
        reg_rdata_next[4] = error_enable_csidinval_qs;
      end
      racl_addr_hit_read[10]: begin
        reg_rdata_next[0] = error_status_cmdbusy_qs;
        reg_rdata_next[1] = error_status_overflow_qs;
        reg_rdata_next[2] = error_status_underflow_qs;
        reg_rdata_next[3] = error_status_cmdinval_qs;
        reg_rdata_next[4] = error_status_csidinval_qs;
        reg_rdata_next[5] = error_status_accessinval_qs;
      end
      racl_addr_hit_read[11]: begin
        reg_rdata_next[0] = event_enable_rxfull_qs;
        reg_rdata_next[1] = event_enable_txempty_qs;
        reg_rdata_next[2] = event_enable_rxwm_qs;
        reg_rdata_next[3] = event_enable_txwm_qs;
        reg_rdata_next[4] = event_enable_ready_qs;
        reg_rdata_next[5] = event_enable_idle_qs;
      end
      default: begin
        reg_rdata_next = '1;
      end
    endcase
  end
  
  logic shadow_busy;
  assign shadow_busy = 1'b0;
  
  assign reg_busy = shadow_busy;
  
  
  
  logic unused_wdata;
  logic unused_be;
  assign unused_wdata = ^reg_wdata;
  assign unused_be = ^reg_be;
  logic unused_policy_sel;
  assign unused_policy_sel = ^racl_policies_i;
  
  `ASSERT_PULSE(wePulse, reg_we, clk_i, !rst_ni)
  `ASSERT_PULSE(rePulse, reg_re, clk_i, !rst_ni)
  `ASSERT(reAfterRv, $rose(reg_re || reg_we) |=> tl_o_pre.d_valid, clk_i, !rst_ni)
  `ASSERT(en2addrHit, (reg_we || reg_re) |-> $onehot0(addr_hit), clk_i, !rst_ni)
  
  
  
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
module spi_host_shift_register (
  input              clk_i,
  input              rst_ni,
  input              wr_en_i,
  output logic       wr_ready_o,
  input              rd_en_i,
  output logic       rd_ready_o,
  input        [1:0] speed_i,
  input              shift_en_i,
  input              sample_en_i,
  input              full_cyc_i,
  input              last_read_i,
  input              last_write_i,
  input        [7:0] tx_data_i,
  input              tx_valid_i,
  output             tx_ready_o,
  output             tx_flush_o,
  output logic [7:0] rx_data_o,
  output logic       rx_valid_o,
  input              rx_ready_i,
  output logic       rx_last_o,
  input        [3:0] sd_i,
  output logic [3:0] sd_o,
  input              sw_rst_i
);
  import spi_host_cmd_pkg::*;
  logic        [7:0] sr_q;
  logic        [7:0] sr_d;
  logic        [3:0] sd_i_q, sd_i_d;
  logic        [3:0] next_bits;
  logic        [7:0] sr_shifted;
  
  
  
  logic        [8:0] rx_buf_q;
  logic        [8:0] rx_buf_d;
  logic              rx_buf_valid_q;
  logic              rx_buf_valid_d;
  `ASSERT(SpeedValid, speed_i != RsvdSpd, clk_i, rst_ni)
  assign next_bits  = full_cyc_i ? sd_i : sd_i_q;
  assign sr_shifted = (speed_i == Standard) ? {sr_q[6:0], next_bits[1]} :
                      (speed_i == Dual)     ? {sr_q[5:0], next_bits[1:0]} :
                      (speed_i == Quad)     ? {sr_q[3:0], next_bits[3:0]} :
                      8'h00;
  assign sd_o       = (speed_i == Standard) ? {3'b000, sr_q[7]}   :
                      (speed_i == Dual)     ? {2'b00,  sr_q[7:6]} :
                      (speed_i == Quad)     ? {sr_q[7:4]} :
                      4'h0;
  
  
  assign rd_ready_o             = ~rx_buf_valid_q | (rx_valid_o & rx_ready_i);
  assign rx_valid_o             = rx_buf_valid_q;
  assign rx_buf_d               = sw_rst_i                ? 9'h0 :
                                  (rd_en_i && rd_ready_o) ? {last_read_i, sr_shifted} :
                                  rx_buf_q;
  assign rx_buf_valid_d         = sw_rst_i                  ? 1'b0 :
                                  (rd_en_i && rd_ready_o)   ? 1'b1 :
                                  (rx_valid_o & rx_ready_i) ? 1'b0 :
                                  rx_buf_valid_q;
  assign sd_i_d                 = sw_rst_i    ? 4'b0 :
                                  sample_en_i ? sd_i :
                                  sd_i_q;
  assign {rx_last_o, rx_data_o} = rx_buf_q;
  
  
  
  assign wr_ready_o         = tx_valid_i;
  assign tx_ready_o         = wr_en_i;
  assign tx_flush_o         = last_write_i;
  assign sr_d = sw_rst_i               ? 8'h0 :
                (wr_en_i & wr_ready_o) ? tx_data_i :
                shift_en_i             ? sr_shifted :
                sr_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      sd_i_q <= 4'h0;
      sr_q <= 8'h0;
      rx_buf_valid_q <= 1'b0;
      rx_buf_q <= 9'h0;
    end else begin
      sd_i_q <= sd_i_d;
      sr_q <= sr_d;
      rx_buf_valid_q <= rx_buf_valid_d;
      rx_buf_q <= rx_buf_d;
    end
  end
endmodule : spi_host_shift_register

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
module spi_host_window
#(
  parameter bit                             EnableRacl             = 1'b0,
  parameter bit                             RaclErrorRsp           = 1'b1,
  parameter top_racl_pkg::racl_policy_sel_t RaclPolicySelWinRXDATA = 0,
  parameter top_racl_pkg::racl_policy_sel_t RaclPolicySelWinTXDATA = 0
) (
  input  clk_i,
  input  rst_ni,
  input  tlul_pkg::tl_h2d_t rx_win_i,
  output tlul_pkg::tl_d2h_t rx_win_o,
  input  tlul_pkg::tl_h2d_t tx_win_i,
  output tlul_pkg::tl_d2h_t tx_win_o,
  output logic [31:0]       tx_data_o,
  output logic [3:0]        tx_be_o,
  output logic              tx_valid_o,
  input        [31:0]       rx_data_i,
  output logic              rx_ready_o,
  
  input  top_racl_pkg::racl_policy_vec_t racl_policies_i,
  output top_racl_pkg::racl_error_log_t  racl_error_tx_o,
  output top_racl_pkg::racl_error_log_t  racl_error_rx_o
);
  localparam int AW = spi_host_reg_pkg::BlockAw;
  localparam int DW = 32;
  localparam int ByteMaskW = DW / 8;
  localparam top_racl_pkg::racl_range_t [0:0] RaclPolicySelRangesTXDATA = '{
    '{
      base:  {top_pkg::TL_AW{1'b0}},
      limit: {top_pkg::TL_AW{1'b1}},
      policy_sel: top_racl_pkg::racl_policy_sel_t'(RaclPolicySelWinTXDATA),
      enable: 1'b1
    }
  };
  logic         rx_we;
  
  logic  rx_access_error;
  assign rx_access_error = rx_we;
  tlul_adapter_reg_racl #(
    .RegAw             ( AW                       ),
    .RegDw             ( DW                       ),
    .EnableDataIntgGen ( 0                        ),
    .EnableRacl        ( EnableRacl               ),
    .RaclErrorRsp      ( RaclErrorRsp             ),
    .RaclPolicySelVec  ( RaclPolicySelWinRXDATA   )
  ) u_adapter_rx (
    .clk_i,
    .rst_ni,
    .tl_i             ( rx_win_i                  ),
    .tl_o             ( rx_win_o                  ),
    .en_ifetch_i      ( prim_mubi_pkg::MuBi4False ),
    .intg_error_o     (                           ),
    .racl_policies_i  ( racl_policies_i           ),
    .racl_error_o     ( racl_error_rx_o           ),
    .we_o             ( rx_we                     ),
    .re_o             ( rx_ready_o                ),
    .addr_o           (                           ),
    .wdata_o          (                           ),
    .be_o             (                           ),
    .rdata_i          ( rx_data_i                 ),
    .error_i          ( rx_access_error           ),
    .busy_i           ( '0                        )
  );
  
  logic [DW-1:0] bit_mask;
  for (genvar i = 0; i < ByteMaskW; i++) begin : gen_byte_mask
     assign tx_be_o[i] = |bit_mask[i*8 +: 8];
    
    `ASSERT(BitMaskCheck_A, (|bit_mask[i*8 +: 8] == 1'b0) ||
                            (&bit_mask[i*8 +: 8] == 1'b1))
  end
  
  tlul_adapter_sram_racl #(
    .SramAw(AW),
    .SramDw(DW),
    .Outstanding(1),
    .ByteAccess(1),
    .ErrOnWrite(0),
    .ErrOnRead(1),
    .EnableRacl(EnableRacl),
    .RaclErrorRsp(RaclErrorRsp),
    .RaclPolicySelNumRanges(1)
  ) u_adapter_tx (
    .clk_i,
    .rst_ni,
    .tl_i(tx_win_i),
    .tl_o(tx_win_o),
    .en_ifetch_i(prim_mubi_pkg::MuBi4False),
    .req_o(tx_valid_o),
    .req_type_o(),
    .gnt_i(1'b1),
    .we_o(),
    .addr_o(),
    .wdata_o(tx_data_o),
    .wmask_o(bit_mask),
    .intg_error_o(),
    .user_rsvd_o(),
    .rdata_i('0),
    .rvalid_i('0),
    .rerror_i('0),
    .compound_txn_in_progress_o(),
    .readback_en_i(prim_mubi_pkg::MuBi4False),
    .readback_error_o (),
    .wr_collision_i(1'b0),
    .write_pending_i(1'b0),
    .racl_policies_i  (racl_policies_i),
    .racl_error_o     (racl_error_tx_o),
    .racl_policy_sel_ranges_i(RaclPolicySelRangesTXDATA)
  );
endmodule : spi_host_window
