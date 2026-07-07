
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
module prim_sha2 import prim_sha2_pkg::*;
#(
  parameter bit MultimodeEn = 0, 
  localparam int unsigned RndWidth256 = $clog2(NumRound256),
  localparam int unsigned RndWidth512 = $clog2(NumRound512),
  localparam sha_word64_t ZeroWord      = '0
 ) (
  input clk_i,
  input rst_ni,
  input               wipe_secret_i,
  input sha_word32_t  wipe_v_i,
  
  input               fifo_rvalid_i, 
                                     
  input  sha_fifo64_t fifo_rdata_i,
  output logic        fifo_rready_o, 
                                     
  
  input               sha_en_i,   
  input               hash_start_i, 
                                    
  input               hash_stop_i, 
                                   
  input               hash_continue_i, 
                                       
  input digest_mode_e digest_mode_i,
  input               hash_process_i,
  output logic        hash_done_o,
  input  [63:0]             message_length_i, 
  input  sha_word64_t [7:0] digest_i,
  input  logic [7:0]        digest_we_i,
  output sha_word64_t [7:0] digest_o, 
  output logic digest_on_blk_o, 
  output fifoctl_state_e fifo_st_o,
  output logic hash_running_o, 
                               
  output logic idle_o
);
  logic        msg_feed_complete;
  logic        shaf_rready;
  logic        shaf_rvalid;
  
  logic update_w_from_fifo, calculate_next_w;
  logic init_hash, run_hash, one_chunk_done;
  logic update_digest, clear_digest;
  logic hash_done_next; 
  logic hash_go;
  
  logic [RndWidth512-1:0] round_d, round_q;
  logic [3:0]             w_index_d, w_index_q;
  digest_mode_e           digest_mode_flag_d, digest_mode_flag_q;
  sha_word64_t            shaf_rdata;
  
  if (!MultimodeEn) begin : gen_tie_unused
    logic [7:0] unused_digest_upper;
    for (genvar i = 0; i < 8; i++) begin : gen_unused_digest_upper
      assign unused_digest_upper[i] = ^digest_i[i][63:32];
    end
    logic unused_signals;
    assign unused_signals = ^{shaf_rdata[63:32], unused_digest_upper};
  end
  
  
  assign hash_go = hash_start_i | hash_continue_i;
  assign digest_mode_flag_d = hash_go     ? digest_mode_i   :    
                              hash_done_o ? SHA2_None       :    
                                            digest_mode_flag_q;  
  if (MultimodeEn) begin : gen_multimode
    
    sha_word64_t [7:0]  hash_d, hash_q; 
    sha_word64_t [15:0] w_d, w_q;
    sha_word64_t [7:0]  digest_d, digest_q;
    
    always_comb begin : compute_w_multimode
      w_d = w_q;
      if (wipe_secret_i) begin
        w_d = {32{wipe_v_i}};
      end else if (!sha_en_i || hash_go) begin
        w_d = '0;
      end else if (!run_hash && update_w_from_fifo) begin
        
        
        w_d = {shaf_rdata, w_q[15:1]};
      end else if (calculate_next_w) begin 
        if (digest_mode_flag_q == SHA2_256) begin
          
          w_d = {{32'b0, calc_w_256(w_q[0][31:0], w_q[1][31:0], w_q[9][31:0],
                w_q[14][31:0])}, w_q[15:1]};
        end else if ((digest_mode_flag_q == SHA2_384) || (digest_mode_flag_q == SHA2_512)) begin
          w_d = {calc_w_512(w_q[0], w_q[1], w_q[9], w_q[14]), w_q[15:1]};
        end
      end else if (run_hash) begin
        
        w_d = {ZeroWord, w_q[15:1]};
      end
    end : compute_w_multimode
    
    always_ff @(posedge clk_i or negedge rst_ni) begin : update_w_multimode
      if (!rst_ni)            w_q <= '0;
      else if (MultimodeEn)   w_q <= w_d;
    end : update_w_multimode
    
    always_comb begin : compression_multimode
      hash_d = hash_q;
      if (wipe_secret_i) begin
        hash_d = {16{wipe_v_i}};
      end else if (init_hash) begin
        hash_d = digest_q;
      end else if (run_hash) begin
        if (digest_mode_flag_q == SHA2_256) begin
          hash_d = compress_multi_256(w_q[0][31:0],
                   CubicRootPrime256[round_q[RndWidth256-1:0]], hash_q);
        end else begin 
          hash_d = compress_512(w_q[0], CubicRootPrime512[round_q], hash_q);
        end
      end
    end : compression_multimode
    
    always_ff @(posedge clk_i or negedge rst_ni) begin : update_hash_multimode
      if (!rst_ni)  hash_q <= '0;
      else          hash_q <= hash_d;
    end : update_hash_multimode
    
    always_comb begin : compute_digest_multimode
      digest_d = digest_q;
      if (wipe_secret_i) begin
        digest_d = {16{wipe_v_i}};
      end else if (hash_start_i) begin
        for (int i = 0 ; i < 8 ; i++) begin
          if (digest_mode_i == SHA2_256) begin
            digest_d[i] = {32'b0, InitHash_256[i]};
          end else if (digest_mode_i == SHA2_384) begin
            digest_d[i] = InitHash_384[i];
          end else if (digest_mode_i == SHA2_512) begin
            digest_d[i] = InitHash_512[i];
          end
        end
      end else if (clear_digest) begin
        digest_d = '0;
      end else if (!sha_en_i) begin
        for (int i = 0; i < 8; i++) begin
          digest_d[i] = digest_we_i[i] ? digest_i[i] : digest_q[i];
        end
      end else if (update_digest) begin
        for (int i = 0 ; i < 8 ; i++) begin
          digest_d[i] = digest_q[i] + hash_q[i];
        end
      end
    end : compute_digest_multimode
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni)  digest_q <= '0;
      else          digest_q <= digest_d;
    end
    
    assign digest_o = digest_q;
    
    
    `ASSERT(WipeHashAssert,
            wipe_secret_i |=> (hash_q == {($bits(hash_q)/$bits(wipe_v_i)){$past(wipe_v_i)}}))
    `ASSERT(WipeMsgSchArrAssert,
            wipe_secret_i |=> (w_q == {($bits(w_q)/$bits(wipe_v_i)){$past(wipe_v_i)}}))
    `ASSERT(WipeDigestAssert,
            wipe_secret_i |=> (digest_q == {($bits(digest_q)/$bits(wipe_v_i)){$past(wipe_v_i)}}))
  end else begin : gen_256 
    
    sha_word32_t        shaf_rdata256;
    sha_word32_t [7:0]  hash256_d, hash256_q; 
    sha_word32_t [15:0] w256_d, w256_q;
    sha_word32_t [7:0]  digest256_d, digest256_q;
    assign shaf_rdata256 = shaf_rdata[31:0];
    always_comb begin : compute_w_256
      
      w256_d = w256_q;
      if (wipe_secret_i) begin
        w256_d = {16{wipe_v_i}};
      end else if (!sha_en_i || hash_go) begin
        w256_d = '0;
      end else if (!run_hash && update_w_from_fifo) begin
        
        
        w256_d = {shaf_rdata256, w256_q[15:1]};
      end else if (calculate_next_w) begin 
        w256_d = {calc_w_256(w256_q[0][31:0], w256_q[1][31:0], w256_q[9][31:0],
                 w256_q[14][31:0]), w256_q[15:1]};
      end else if (run_hash) begin
        
        w256_d = {ZeroWord[31:0], w256_q[15:1]};
      end
    end : compute_w_256
    
    always_ff @(posedge clk_i or negedge rst_ni) begin : update_w_256
      if (!rst_ni)            w256_q <= '0;
      else if (!MultimodeEn)  w256_q <= w256_d;
    end : update_w_256
    
    always_comb begin : compression_256
      hash256_d = hash256_q;
      if (wipe_secret_i) begin
        hash256_d = {8{wipe_v_i}};
      end else if (init_hash) begin
        hash256_d = digest256_q;
      end else if (run_hash) begin
        hash256_d = compress_256(w256_q[0], CubicRootPrime256[round_q[RndWidth256-1:0]], hash256_q);
      end
    end : compression_256
    
    always_ff @(posedge clk_i or negedge rst_ni) begin : update_hash256
      if (!rst_ni) hash256_q <= '0;
      else         hash256_q <= hash256_d;
    end : update_hash256
    
    always_comb begin : compute_digest_256
      digest256_d = digest256_q;
      if (wipe_secret_i) begin
        digest256_d = {8{wipe_v_i}};
      end else if (hash_start_i) begin
        for (int i = 0 ; i < 8 ; i++) begin
            digest256_d[i] = InitHash_256[i];
        end
      end else if (clear_digest) begin
        digest256_d = '0;
      end else if (!sha_en_i) begin
        for (int i = 0; i < 8; i++) begin
          digest256_d[i] = digest_we_i[i] ? digest_i[i][31:0] : digest256_q[i];
        end
      end else if (update_digest) begin
        for (int i = 0 ; i < 8 ; i++) begin
          digest256_d[i] = digest256_q[i] + hash256_q[i];
        end
      end
    end : compute_digest_256
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni)  digest256_q <= '0;
      else          digest256_q <= digest256_d;
    end
    
    for (genvar i = 0; i < 8; i++) begin  : gen_assign_digest_256
      assign digest_o[i][31:0]  = digest256_q[i];
      assign digest_o[i][63:32] = 32'b0;
    end
    
    
    `ASSERT(WipeHashAssert,
      wipe_secret_i |=> (hash256_q == {($bits(hash256_q)/$bits(wipe_v_i)){$past(wipe_v_i)}}))
    `ASSERT(WipeMsgSchArrAssert,
      wipe_secret_i |=> (w256_q == {($bits(w256_q)/$bits(wipe_v_i)){$past(wipe_v_i)}}))
    `ASSERT(WipeDigestAssert,
      wipe_secret_i |=> (digest256_q == {($bits(digest256_q)/$bits(wipe_v_i)){$past(wipe_v_i)}}))
  end
  
  always_comb begin : round_counter
    round_d = round_q;
    if (!sha_en_i || hash_go) begin
      round_d = '0;
    end else if (run_hash) begin
      if (((round_q[RndWidth256-1:0] == RndWidth256'(unsigned'(NumRound256-1))) &&
         (digest_mode_flag_q == SHA2_256 || !MultimodeEn)) ||
         ((round_q == RndWidth512'(unsigned'(NumRound512-1))) &&
         ((digest_mode_flag_q == SHA2_384) || (digest_mode_flag_q == SHA2_512)))) begin
        round_d = '0;
      end else begin
        round_d = round_q + 1;
      end
    end
  end
  
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) round_q <= '0;
    else         round_q <= round_d;
  end
  
  assign w_index_d = (~sha_en_i || hash_go) ? '0            :  
                     update_w_from_fifo     ? w_index_q + 1 :  
                                              w_index_q;       
  
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) w_index_q <= '0;
    else         w_index_q <= w_index_d;
  end
  
  assign shaf_rready = update_w_from_fifo;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) hash_done_o <= 1'b0;
    else         hash_done_o <= hash_done_next;
  end
  fifoctl_state_e fifo_st_q, fifo_st_d;
  assign fifo_st_o = fifo_st_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) fifo_st_q <= FifoIdle;
    else         fifo_st_q <= fifo_st_d;
  end
  always_comb begin
    fifo_st_d          = fifo_st_q;
    update_w_from_fifo = 1'b0;
    hash_done_next     = 1'b0;
    unique case (fifo_st_q)
      FifoIdle: begin
        if (hash_go) fifo_st_d = FifoLoadFromFifo;
        else         fifo_st_d = FifoIdle;
      end
      FifoLoadFromFifo: begin
        if (!shaf_rvalid) begin
          
          fifo_st_d          = FifoLoadFromFifo;
          update_w_from_fifo = 1'b0;
          if (msg_feed_complete) begin
            fifo_st_d       = FifoIdle;
            hash_done_next  = 1'b1;
          end
        end else if (w_index_q == 4'd 15) begin
          fifo_st_d = FifoWait;
          
          update_w_from_fifo = 1'b1;
        end else begin
          fifo_st_d          = FifoLoadFromFifo;
          update_w_from_fifo = 1'b1;
        end
      end
      FifoWait: begin
        if (msg_feed_complete && one_chunk_done) begin
          fifo_st_d      = FifoIdle;
          
          hash_done_next = 1'b1;
        end else if (one_chunk_done) begin
          fifo_st_d      = FifoLoadFromFifo;
        end else begin
          fifo_st_d      = FifoWait;
        end
      end
      default: begin
        fifo_st_d = FifoIdle;
      end
    endcase
    if (!sha_en_i)  begin
      fifo_st_d          = FifoIdle;
      update_w_from_fifo = 1'b0;
    end else if (hash_go) begin
      fifo_st_d          = FifoLoadFromFifo;
    end
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) digest_mode_flag_q <= SHA2_None;
    else         digest_mode_flag_q <= digest_mode_flag_d;
  end
  
  typedef enum logic [1:0] {
    ShaIdle,
    ShaCompress,
    ShaUpdateDigest
  } sha_st_t;
  sha_st_t sha_st_q, sha_st_d;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) sha_st_q <= ShaIdle;
    else         sha_st_q <= sha_st_d;
  end
  logic sha_en_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) sha_en_q <= 1'b0;
    else         sha_en_q <= sha_en_i;
  end
  assign clear_digest = hash_start_i | (~sha_en_i & sha_en_q);
  always_comb begin
    update_digest    = 1'b0;
    calculate_next_w = 1'b0;
    init_hash        = 1'b0;
    run_hash         = 1'b0;
    sha_st_d         = sha_st_q;
    unique case (sha_st_q)
      ShaIdle: begin
        if (fifo_st_q == FifoWait) begin
          init_hash = 1'b1;
          sha_st_d  = ShaCompress;
        end else begin
          sha_st_d  = ShaIdle;
        end
      end
      ShaCompress: begin
        run_hash = 1'b1;
        if (((digest_mode_flag_q == SHA2_256 || ~MultimodeEn) && round_q < 48) ||
           (((digest_mode_flag_q == SHA2_384) ||
           (digest_mode_flag_q == SHA2_512)) && round_q < 64)) begin
          calculate_next_w = 1'b1;
        end else if (one_chunk_done) begin
          sha_st_d = ShaUpdateDigest;
        end else begin
          sha_st_d = ShaCompress;
        end
      end
      ShaUpdateDigest: begin
        update_digest = 1'b1;
        if (fifo_st_q == FifoWait) begin
          init_hash = 1'b1;
          sha_st_d  = ShaCompress;
        end else begin
          sha_st_d  = ShaIdle;
        end
      end
      default: begin
        sha_st_d = ShaIdle;
      end
    endcase
    if (!sha_en_i || hash_go) sha_st_d  = ShaIdle;
  end
  logic update_digest_q, update_digest_d;
  
  
  
  assign digest_on_blk_o = (update_digest || update_digest_q) && (fifo_st_q == FifoIdle) && (
      (digest_mode_flag_q == SHA2_256                 && message_length_i[8:0] == '0) ||
      (digest_mode_flag_q inside {SHA2_384, SHA2_512} && message_length_i[9:0] == '0));
  assign update_digest_d = digest_on_blk_o ? 1'b0 :
                           update_digest   ? 1'b1 : update_digest_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      update_digest_q <= 1'b0;
    end else begin
      update_digest_q <= update_digest_d;
    end
  end
  assign one_chunk_done = ((digest_mode_flag_q == SHA2_256 || ~MultimodeEn)
                          && (round_q == 7'd63)) ? 1'b1 :
                          (((digest_mode_flag_q == SHA2_384) || (digest_mode_flag_q == SHA2_512))
                          && (round_q == 7'd79)) ? 1'b1 : 1'b0;
  prim_sha2_pad #(
      .MultimodeEn(MultimodeEn)
    ) u_pad (
    .clk_i,
    .rst_ni,
    .fifo_rvalid_i,
    .fifo_rdata_i,
    .fifo_rready_o,
    .shaf_rvalid_o (shaf_rvalid), 
    .shaf_rdata_o  (shaf_rdata),
    .shaf_rready_i (shaf_rready), 
    .sha_en_i,
    .hash_start_i,
    .hash_stop_i,
    .hash_continue_i,
    .digest_mode_i,
    .hash_process_i,
    .hash_done_i (hash_done_o),
    .message_length_i ({64'b0, message_length_i}), 
    .msg_feed_complete_o (msg_feed_complete)
  );
  assign hash_running_o = init_hash | run_hash | update_digest;
  
  assign idle_o = (fifo_st_q == FifoIdle) && (sha_st_q == ShaIdle) && !hash_go;
  
  
  
  `ASSERT(ValidDigestModeFlag_A, run_hash |->
    digest_mode_flag_q inside {SHA2_256, SHA2_384, SHA2_512})
endmodule : prim_sha2

module prim_sha2_32 import prim_sha2_pkg::*;
#(
  parameter bit MultimodeEn = 0 
 ) (
  input clk_i,
  input rst_ni,
  input              wipe_secret_i,
  input sha_word32_t wipe_v_i,
  
  input               fifo_rvalid_i,      
                                          
  input  sha_fifo32_t fifo_rdata_i,
  output logic        fifo_rready_o,      
                                          
  
  input                     sha_en_i, 
  input                     hash_start_i,
  input                     hash_stop_i,
  input                     hash_continue_i,
  input digest_mode_e       digest_mode_i,
  input                     hash_process_i,
  output logic              hash_done_o,
  input [63:0]              message_length_i,
  input  sha_word64_t [7:0] digest_i,
  input  logic [7:0]        digest_we_i,
  output sha_word64_t [7:0] digest_o,         
  output logic              digest_on_blk_o,
  output logic              hash_running_o,
  output logic              idle_o
);
  
  sha_fifo64_t  full_word;
  logic sha_ready, hash_go;
  
  
  assign hash_go = hash_start_i | hash_continue_i;
  fifoctl_state_e fifo_st;
  
  if (!MultimodeEn) begin : gen_tie_unused
    logic unused_signals;
    assign unused_signals = ^{digest_mode_i, hash_go};
  end
  
  if (MultimodeEn) begin : gen_multimode_logic
    
    sha_fifo64_t  word_buffer_d, word_buffer_q;
    logic [1:0]   word_part_count_d, word_part_count_q;
    logic         sha_process, process_flag_d, process_flag_q;
    logic         word_valid;
    logic         word_part_inc, word_part_reset;
    digest_mode_e digest_mode_flag_d, digest_mode_flag_q;
    always_comb begin : multimode_combinational
      word_part_inc    = 1'b0;
      word_part_reset  = 1'b0;
      full_word.mask   = 8'hFF; 
      full_word.data   = 64'h0;
      sha_process      = 1'b0;
      word_valid       = 1'b0;
      fifo_rready_o    = 1'b0;
      
      if (!sha_en_i || hash_go) word_buffer_d = 0;
      else                      word_buffer_d = word_buffer_q;
      if (sha_en_i && fifo_rvalid_i) begin 
        if (word_part_count_q == 2'b00) begin
          if (digest_mode_flag_q != SHA2_256) begin
            
            word_buffer_d.data[63:32] = fifo_rdata_i.data;
            word_buffer_d.mask[7:4]   = fifo_rdata_i.mask;
            if (fifo_st == FifoLoadFromFifo) begin
              fifo_rready_o = 1'b1; 
              word_part_inc = 1'b1;
            end else begin
              fifo_rready_o = 1'b0; 
              word_part_inc = 1'b0;
            end
          end else begin   
            word_valid = 1'b1;
            
            word_buffer_d.data = {32'b0, fifo_rdata_i.data};
            word_buffer_d.mask = {4'hF, fifo_rdata_i.mask}; 
            
            full_word.data =  {32'b0, fifo_rdata_i.data};
            full_word.mask =  {4'hF, fifo_rdata_i.mask};
            if (hash_process_i || process_flag_q) begin
                sha_process = 1'b1;
            end
            if (sha_ready == 1'b1) begin
              
              fifo_rready_o = 1'b1; 
            end else begin
              fifo_rready_o = 1'b0;
            end
          end
        end else if (word_part_count_q == 2'b01) begin
          
          word_buffer_d.data [31:0] = fifo_rdata_i.data;
          word_buffer_d.mask [3:0]  = fifo_rdata_i.mask;
          
          word_valid              = 1'b1;
          full_word.data [63:32]  = word_buffer_q.data[63:32];
          full_word.mask [7:4]    = word_buffer_q.mask[7:4];
          full_word.data [31:0]   = fifo_rdata_i.data;
          full_word.mask  [3:0]   = fifo_rdata_i.mask;
          if (hash_process_i || process_flag_q) begin
              sha_process = 1'b1;
          end
          if (sha_ready == 1'b1) begin
            
            fifo_rready_o     = 1'b1; 
            word_part_reset   = 1'b1;
            word_part_inc     = 1'b0;
          end else begin
            fifo_rready_o     = 1'b0;
            word_part_inc     = 1'b0;
          end
        end else if (word_part_count_q == 2'b10) begin 
          
          fifo_rready_o     = 1'b0;
          word_valid        = 1'b1; 
          full_word         = word_buffer_q;
          if (hash_process_i || process_flag_q) begin
              sha_process   = 1'b1;
          end
          if (sha_ready == 1'b1) begin 
            
            word_part_reset = 1'b1;
          end
        end
      end else if (sha_en_i) begin 
        
        full_word = word_buffer_q;
        if (word_part_count_q == 2'b00 && (hash_process_i || process_flag_q)) begin
          sha_process = 1'b1; 
        end else if (word_part_count_q == 2'b01 && (hash_process_i || process_flag_q)) begin
          
          full_word.data [31:0] = 32'b0;
          full_word.mask [3:0]  = 4'h0;
          word_valid            = 1'b1;
          sha_process           = 1'b1;
          if (sha_ready == 1'b1) begin 
            word_part_reset = 1'b1; 
          end
        end else if (word_part_count_q == 2'b01) begin 
          word_valid = 1'b0;
        end else if (word_part_count_q == 2'b10 && (hash_process_i || process_flag_q)) begin
          
          word_valid  = 1'b1;
          sha_process = 1'b1;
          if (sha_ready == 1'b1) begin 
            word_part_reset = 1'b1; 
          end
        end else if (word_part_count_q == 2'b10) begin 
          word_valid = 1'b0;
        end
      end
      
      if ((word_part_reset || hash_go || !sha_en_i)) begin
        word_part_count_d = '0;
      end else if (word_part_inc) begin
        word_part_count_d = word_part_count_q + 1'b1;
      end else begin
        word_part_count_d = word_part_count_q;
      end
      
      if (hash_go)          digest_mode_flag_d = digest_mode_i;      
      else if (hash_done_o) digest_mode_flag_d = SHA2_None;          
      else                  digest_mode_flag_d = digest_mode_flag_q; 
      
      if (!sha_en_i || hash_go) process_flag_d = 1'b0;
      else if (hash_process_i)  process_flag_d = 1'b1;
      else                      process_flag_d = process_flag_q;
    end : multimode_combinational
    prim_sha2 #(
      .MultimodeEn(1)
    ) u_prim_sha2_multimode (
      .clk_i (clk_i),
      .rst_ni (rst_ni),
      .wipe_secret_i      (wipe_secret_i),
      .wipe_v_i           (wipe_v_i),
      .fifo_rvalid_i      (word_valid),
      .fifo_rdata_i       (full_word),
      .fifo_rready_o      (sha_ready),
      .sha_en_i           (sha_en_i),
      .hash_start_i       (hash_start_i),
      .hash_stop_i        (hash_stop_i),
      .hash_continue_i    (hash_continue_i),
      .digest_mode_i      (digest_mode_i),
      .hash_process_i     (sha_process),
      .hash_done_o        (hash_done_o),
      .message_length_i   (message_length_i),
      .digest_i           (digest_i),
      .digest_we_i        (digest_we_i),
      .digest_o           (digest_o),
      .digest_on_blk_o    (digest_on_blk_o),
      .fifo_st_o          (fifo_st),
      .hash_running_o     (hash_running_o),
      .idle_o             (idle_o)
    );
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni)  word_part_count_q <= '0;
      else          word_part_count_q <= word_part_count_d;
    end
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni)  word_buffer_q <= 0;
      else          word_buffer_q <= word_buffer_d;
    end
    always_ff @(posedge clk_i or negedge rst_ni) begin
     if (!rst_ni)          process_flag_q <= '0;
      else  process_flag_q <= process_flag_d;
    end
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) digest_mode_flag_q <= SHA2_None;
      else         digest_mode_flag_q <= digest_mode_flag_d;
    end
  
  end else begin : gen_sha256_logic  
    always_comb begin : sha256_combinational
      full_word.data   = {32'b0, fifo_rdata_i.data};
      full_word.mask   = {4'hF,  fifo_rdata_i.mask};
      fifo_rready_o    = sha_ready;
    end : sha256_combinational
    prim_sha2 #(
      .MultimodeEn(0)
    ) u_prim_sha2_256 (
      .clk_i (clk_i),
      .rst_ni (rst_ni),
      .wipe_secret_i      (wipe_secret_i),
      .wipe_v_i           (wipe_v_i),
      .fifo_rvalid_i      (fifo_rvalid_i), 
      .fifo_rdata_i       (full_word),
      .fifo_rready_o      (sha_ready),
      .sha_en_i           (sha_en_i),
      .hash_start_i       (hash_start_i),
      .hash_stop_i        (hash_stop_i),
      .hash_continue_i    (hash_continue_i),
      .digest_mode_i      (SHA2_None),      
      .hash_process_i     (hash_process_i), 
      .hash_done_o        (hash_done_o),
      .message_length_i   (message_length_i),
      .digest_i           (digest_i),
      .digest_we_i        (digest_we_i),
      .digest_o           (digest_o),
      .digest_on_blk_o    (digest_on_blk_o),
      .fifo_st_o          (fifo_st),
      .hash_running_o     (hash_running_o),
      .idle_o             (idle_o)
    );
  end
endmodule : prim_sha2_32

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
module prim_sha2_pad import prim_sha2_pkg::*;
#(
  parameter bit MultimodeEn = 1
 ) (
  input clk_i,
  input rst_ni,
  
  input                 fifo_rvalid_i,
  input  sha_fifo64_t   fifo_rdata_i,
  output logic          fifo_rready_o,
  
  output logic          shaf_rvalid_o,
  output sha_word64_t   shaf_rdata_o,
  input                 shaf_rready_i,
  input                 sha_en_i,
  input                 hash_start_i,
  input                 hash_stop_i,
  input                 hash_continue_i,
  input digest_mode_e   digest_mode_i,
  input                 hash_process_i,
  input                 hash_done_i,
  input        [127:0]  message_length_i,   
  output logic          msg_feed_complete_o 
);
  logic [127:0] tx_count_d, tx_count;    
  logic         inc_txcount;
  logic         fifo_partial;
  logic         txcnt_eq_1a0;
  logic         txcnt_eq_msg_len;
  logic         hash_go;
  logic         hash_stop_flag_d, hash_stop_flag_q;
  logic         hash_process_flag_d, hash_process_flag_q;
  digest_mode_e digest_mode_flag_d,  digest_mode_flag_q;
  
  
  assign hash_go = hash_start_i | hash_continue_i;
  
  if (!MultimodeEn) begin : gen_tie_unused
    logic unused_signals;
    assign unused_signals = ^{message_length_i[127:64]};
  end
  assign fifo_partial = MultimodeEn ? ~&fifo_rdata_i.mask :
                                      ~&fifo_rdata_i.mask[3:0];
  
  assign txcnt_eq_1a0 = (digest_mode_flag_q == SHA2_256   || ~MultimodeEn)               ?
                                                                        (tx_count[8:0] == 9'h1a0)  :
                        ((digest_mode_flag_q == SHA2_384) || (digest_mode_flag_q == SHA2_512)) ?
                                                                        (tx_count[9:0] == 10'h340) :
                                                                        '0;
  if (MultimodeEn) begin : gen_txcnt_comp_multimode
    assign txcnt_eq_msg_len = (tx_count == message_length_i);
  end else begin : gen_txcnt_comp_no_multimode
    assign txcnt_eq_msg_len = (tx_count[63:0] == message_length_i[63:0]);
  end
  assign hash_stop_flag_d = (~sha_en_i || hash_go || hash_done_i) ? 1'b0 :
                            hash_stop_i                           ? 1'b1 :
                                                                    hash_stop_flag_q;
  assign hash_process_flag_d = (~sha_en_i || hash_go || hash_done_i) ? 1'b0 :
                               hash_process_i                        ? 1'b1 :
                                                                       hash_process_flag_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      hash_stop_flag_q    <= 1'b0;
      hash_process_flag_q <= 1'b0;
    end else begin
      hash_stop_flag_q    <= hash_stop_flag_d;
      hash_process_flag_q <= hash_process_flag_d;
    end
  end
  
  typedef enum logic [2:0] {
    FifoIn,         
    Pad80,          
    Pad00,          
    LenHi,          
    LenLo           
  } sel_data_e;
  sel_data_e sel_data;
  always_comb begin
    unique case (sel_data)
      FifoIn: begin
        shaf_rdata_o = fifo_rdata_i.data;
      end
      Pad80: begin
        
        
        
        
        
        if ((digest_mode_flag_q == SHA2_256) || ~MultimodeEn) begin
          unique case (message_length_i[4:3])
            2'b 00:  shaf_rdata_o = 64'h 0000_0000_8000_0000;
            2'b 01:  shaf_rdata_o = {32'h 0000_0000, fifo_rdata_i.data[31:24], 24'h 8000_00};
            2'b 10:  shaf_rdata_o = {32'h 0000_0000, fifo_rdata_i.data[31:16], 16'h 8000};
            default: shaf_rdata_o = {32'h 0000_0000, fifo_rdata_i.data[31: 8],  8'h 80}; 
          endcase
        end else begin 
          unique case (message_length_i[5:3])
            3'b 000: shaf_rdata_o = 64'h 8000_0000_0000_0000;
            3'b 001: shaf_rdata_o = {fifo_rdata_i.data[63:56], 56'h 8000_0000_0000_00};
            3'b 010: shaf_rdata_o = {fifo_rdata_i.data[63:48], 48'h 8000_0000_0000};
            3'b 011: shaf_rdata_o = {fifo_rdata_i.data[63:40], 40'h 8000_0000_00};
            3'b 100: shaf_rdata_o = {fifo_rdata_i.data[63:32], 32'h 8000_0000};
            3'b 101: shaf_rdata_o = {fifo_rdata_i.data[63:24], 24'h 8000_00};
            3'b 110: shaf_rdata_o = {fifo_rdata_i.data[63:16], 16'h 8000};
            default: shaf_rdata_o = {fifo_rdata_i.data[63:8],  8'h 80}; 
          endcase
        end
      end
      Pad00: begin
        shaf_rdata_o = '0;
      end
      LenHi: begin
        shaf_rdata_o = ((digest_mode_flag_q == SHA2_256) || ~MultimodeEn) ?
                       {32'b0, message_length_i[63:32]} :
                       message_length_i[127:64]; 
      end
      LenLo: begin
        shaf_rdata_o = ((digest_mode_flag_q == SHA2_256) || ~MultimodeEn) ?
                       {32'b0, message_length_i[31:0]} :
                       message_length_i[63:0]; 
      end
      default: begin
        shaf_rdata_o = '0;
      end
    endcase
    if (!MultimodeEn) shaf_rdata_o [63:32] = 32'b0; 
  end
  
  
  
  
  
  
  
  
  
  
  
  
  
  typedef enum logic [2:0] {
    StIdle,        
    StFifoReceive, 
    StPad80,       
    StPad00,
    StLenHi,
    StLenLo
  } pad_st_e;
  pad_st_e st_q, st_d;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) st_q <= StIdle;
    else         st_q <= st_d;
  end
  
  always_comb begin
    shaf_rvalid_o = 1'b0;
    inc_txcount   = 1'b0;
    sel_data      = FifoIn;
    fifo_rready_o = 1'b0;
    st_d          = StIdle;
    unique case (st_q)
      StIdle: begin
        sel_data      = FifoIn;
        shaf_rvalid_o = 1'b0;
        if (sha_en_i && hash_go) begin
          inc_txcount = 1'b0;
          st_d        = StFifoReceive;
        end else begin
          st_d        = StIdle;
        end
      end
      StFifoReceive: begin
        sel_data = FifoIn;
        if (fifo_partial && fifo_rvalid_i) begin
          
          shaf_rvalid_o = 1'b0; 
          inc_txcount   = 1'b0;
          fifo_rready_o = 1'b0;
          st_d = StPad80;
        end else if (!hash_process_flag_q) begin
          fifo_rready_o = shaf_rready_i;
          shaf_rvalid_o = fifo_rvalid_i;
          inc_txcount   = shaf_rready_i;
          st_d = StFifoReceive;
        end else if (txcnt_eq_msg_len) begin
          
          shaf_rvalid_o = 1'b0;
          inc_txcount   = 1'b0;
          fifo_rready_o = 1'b0;
          st_d = StPad80;
        end else begin
          shaf_rvalid_o = fifo_rvalid_i;
          fifo_rready_o = shaf_rready_i; 
          inc_txcount   = shaf_rready_i; 
          st_d = StFifoReceive;
        end
        if (txcnt_eq_msg_len && hash_stop_flag_q) begin
          shaf_rvalid_o = 1'b0;
          inc_txcount   = 1'b0;
          fifo_rready_o = 1'b0;
          st_d = StIdle;
        end
      end
      StPad80: begin
        sel_data      = Pad80;
        shaf_rvalid_o = 1'b1;
        fifo_rready_o = (digest_mode_flag_q == SHA2_256 || ~MultimodeEn) ?
                        shaf_rready_i && |message_length_i[4:3] :
                        
                        shaf_rready_i && |message_length_i[5:3];
        
        if (shaf_rready_i && txcnt_eq_1a0) begin
          st_d        = StLenHi;
          inc_txcount = 1'b1;
        
        
        
        end else if (shaf_rready_i && !txcnt_eq_1a0) begin
          st_d        = StPad00;
          inc_txcount = 1'b1;
        end else begin
          st_d        = StPad80;
          inc_txcount = 1'b0;
        end
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
      end
      StPad00: begin
        sel_data      = Pad00;
        shaf_rvalid_o = 1'b1;
        if (shaf_rready_i) begin
          inc_txcount = 1'b1;
          if (txcnt_eq_1a0) st_d = StLenHi;
          else              st_d = StPad00;
        end else begin
          st_d = StPad00;
        end
      end
      StLenHi: begin
        sel_data      = LenHi;
        shaf_rvalid_o = 1'b1;
        st_d = StLenHi;
        inc_txcount = 1'b0;
        if (shaf_rready_i) begin
          st_d = StLenLo;
          inc_txcount = 1'b1;
        end
      end
      StLenLo: begin
        sel_data        = LenLo;
        shaf_rvalid_o   = 1'b1;
        st_d        = StLenLo;
        inc_txcount = 1'b0;
        if (shaf_rready_i) begin
          st_d        = StIdle;
          inc_txcount = 1'b1;
        end
      end
      default: begin
        st_d = StIdle;
      end
    endcase
    if (!sha_en_i) begin
      st_d = StIdle;
    
    
    end else if (hash_go && (st_q inside {StIdle, StFifoReceive})) begin
      st_d = StFifoReceive;
    end
  end
  
  always_comb begin
    tx_count_d = tx_count;
    if (hash_start_i) begin
      
      tx_count_d = '0;
    end else if (hash_continue_i) begin
      
      tx_count_d = message_length_i;
    end else if (inc_txcount) begin
      if ((digest_mode_flag_q == SHA2_256) || !MultimodeEn) begin
        tx_count_d[127:5] = tx_count[127:5] + 1'b1;
      end else begin 
        tx_count_d[127:6] = tx_count[127:6] + 1'b1;
      end
    end
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) tx_count <= '0;
    else         tx_count <= tx_count_d;
  end
  assign digest_mode_flag_d = (hash_start_i || hash_continue_i) ? digest_mode_i  :    
                              hash_done_i                       ? SHA2_None      :    
                                                                  digest_mode_flag_q; 
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni)  digest_mode_flag_q <= SHA2_None;
    else          digest_mode_flag_q <= digest_mode_flag_d;
  end
  
  assign msg_feed_complete_o = (hash_process_flag_q || hash_stop_flag_q) && (st_q == StIdle);
  
  
  
  `ASSERT(ValidDigestModeFlag_A, sel_data inside {Pad80, LenHi, LenLo} || inc_txcount |->
      digest_mode_flag_q inside {SHA2_256, SHA2_384, SHA2_512})
endmodule

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
module tlul_adapter_host
  import tlul_pkg::*;
  import prim_mubi_pkg::mubi4_t;
#(
  parameter int unsigned MAX_REQS = 2,
  parameter bit EnableDataIntgGen = 0,
  parameter bit EnableRspDataIntgCheck = 0
) (
  input clk_i,
  input rst_ni,
  input                              req_i,
  output logic                       gnt_o,
  input  logic [top_pkg::TL_AW-1:0]  addr_i,
  input  logic                       we_i,
  input  logic [top_pkg::TL_DW-1:0]  wdata_i,
  input  logic [DataIntgWidth-1:0]   wdata_intg_i,
  input  logic [top_pkg::TL_DBW-1:0] be_i,
  input  mubi4_t                     instr_type_i,
  input  logic [RsvdWidth-1:0]       user_rsvd_i,
  output logic                       valid_o,
  output logic [top_pkg::TL_DW-1:0]  rdata_o,
  output logic [DataIntgWidth-1:0]   rdata_intg_o,
  output logic                       err_o,
  output logic                       intg_err_o,
  output tl_h2d_t                    tl_o,
  input  tl_d2h_t                    tl_i
);
  localparam int unsigned WordSize = $clog2(top_pkg::TL_DBW);
  logic [top_pkg::TL_AIW-1:0] tl_source;
  logic [top_pkg::TL_DBW-1:0] tl_be;
  tl_h2d_t                    tl_out;
  if (MAX_REQS == 1) begin : g_single_req
    assign tl_source = '0;
  end else begin : g_multiple_reqs
    localparam int ReqNumW  = $clog2(MAX_REQS);
    localparam int unsigned MaxSource = MAX_REQS - 1;
    localparam logic [ReqNumW-1:0] ReqNumOne = ReqNumW'(1'b1);
    logic [ReqNumW-1:0] source_d;
    logic [ReqNumW-1:0] source_q;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        source_q <= '0;
      end else begin
        source_q <= source_d;
      end
    end
    always_comb begin
      source_d = source_q;
      if (req_i && gnt_o) begin
        if (source_q == MaxSource[ReqNumW-1:0]) begin
          source_d = '0;
        end else  begin
          source_d = source_q + ReqNumOne;
        end
      end
    end
    assign tl_source = top_pkg::TL_AIW'(source_q);
  end
  
  
  assign tl_be = ~we_i ? {top_pkg::TL_DBW{1'b1}} : be_i;
  assign tl_out = '{
    a_valid:   req_i,
    a_opcode:  (~we_i) ? Get           :
               (&be_i) ? PutFullData   :
                         PutPartialData,
    a_param:   3'h0,
    a_size:    top_pkg::TL_SZW'(WordSize),
    a_mask:    tl_be,
    a_source:  tl_source,
    a_address: {addr_i[31:WordSize], {WordSize{1'b0}}},
    a_data:    wdata_i,
    a_user:    '{default: '0, data_intg: wdata_intg_i, instr_type: instr_type_i, rsvd: user_rsvd_i},
    d_ready:   1'b1
  };
  tlul_cmd_intg_gen #(.EnableDataIntgGen (EnableDataIntgGen)) u_cmd_intg_gen (
    .tl_i(tl_out),
    .tl_o(tl_o)
  );
  assign gnt_o        = tl_i.a_ready;
  assign valid_o      = tl_i.d_valid;
  assign rdata_o      = tl_i.d_data;
  assign rdata_intg_o = tl_i.d_user.data_intg;
  logic intg_err;
  tlul_rsp_intg_chk #(
    .EnableRspDataIntgCheck(EnableRspDataIntgCheck)
  ) u_rsp_chk (
    .tl_i,
    .err_o(intg_err)
  );
  logic intg_err_q;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      intg_err_q <= '0;
    end else if (intg_err) begin
      intg_err_q <= 1'b1;
    end
  end
  
  
  assign err_o   = tl_i.d_error | intg_err;
  
  
  assign intg_err_o = intg_err_q | intg_err;
  
  logic unused_addr_bottom_bits;
  assign unused_addr_bottom_bits = ^addr_i[WordSize-1:0];
  
  logic unused_tl_i_fields;
  assign unused_tl_i_fields = ^{tl_i.d_opcode, tl_i.d_param,
                                tl_i.d_size, tl_i.d_source, tl_i.d_sink,
                                tl_i.d_user};
`ifdef INC_ASSERT
  
  
  localparam int OutstandingReqCntW =
    (MAX_REQS == 2 ** $clog2(MAX_REQS)) ? $clog2(MAX_REQS) + 1 : $clog2(MAX_REQS);
  localparam logic [OutstandingReqCntW-1:0] OutstandingReqCntOne = OutstandingReqCntW'(1'b1);
  logic [OutstandingReqCntW-1:0] outstanding_reqs_q;
  logic [OutstandingReqCntW-1:0] outstanding_reqs_d;
  always_comb begin
    outstanding_reqs_d = outstanding_reqs_q;
    if ((req_i && gnt_o) && !valid_o) begin
      outstanding_reqs_d = outstanding_reqs_q + OutstandingReqCntOne;
    end else if (!(req_i && gnt_o) && valid_o) begin
      outstanding_reqs_d = outstanding_reqs_q - OutstandingReqCntOne;
    end
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      outstanding_reqs_q <= '0;
    end else begin
      outstanding_reqs_q <= outstanding_reqs_d;
    end
  end
  
  
  `ASSERT(DontExceeedMaxReqs, req_i |-> outstanding_reqs_d <= MAX_REQS)
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
module tlul_cmd_intg_gen import tlul_pkg::*; #(
  parameter bit EnableDataIntgGen = 1'b1
) (
  
  input  tl_h2d_t tl_i,
  output tl_h2d_t tl_o
);
  tl_h2d_cmd_intg_t cmd;
  assign cmd = extract_h2d_cmd_intg(tl_i);
  logic [H2DCmdMaxWidth-1:0] unused_cmd_payload;
  logic [H2DCmdIntgWidth-1:0] cmd_intg;
  prim_secded_inv_64_57_enc u_cmd_gen (
    .data_i(H2DCmdMaxWidth'(cmd)),
    .data_o({cmd_intg, unused_cmd_payload})
  );
  logic [top_pkg::TL_DW-1:0] data_final;
  logic [DataIntgWidth-1:0] data_intg;
  if (EnableDataIntgGen) begin : gen_data_intg
    assign data_final = tl_i.a_data;
    logic [DataMaxWidth-1:0] unused_data;
    prim_secded_inv_39_32_enc u_data_gen (
      .data_i(DataMaxWidth'(data_final)),
      .data_o({data_intg, unused_data})
    );
  end else begin : gen_passthrough_data_intg
    assign data_final = tl_i.a_data;
    assign data_intg = tl_i.a_user.data_intg;
  end
  always_comb begin
    tl_o = tl_i;
    tl_o.a_data = data_final;
    tl_o.a_user.cmd_intg = cmd_intg;
    tl_o.a_user.data_intg = data_intg;
  end
  logic unused_tl;
  assign unused_tl = ^tl_i;
  `ASSERT_INIT(PayMaxWidthCheck_A, $bits(tl_h2d_cmd_intg_t) <= H2DCmdMaxWidth)
endmodule : tlul_cmd_intg_gen

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
module tlul_rsp_intg_chk import tlul_pkg::*; #(
  parameter bit EnableRspDataIntgCheck = 0
) (
  
  input  tl_d2h_t tl_i,
  
  output logic err_o
);
  logic [1:0] rsp_err;
  tl_d2h_rsp_intg_t rsp;
  assign rsp = extract_d2h_rsp_intg(tl_i);
  prim_secded_inv_64_57_dec u_chk (
    .data_i({tl_i.d_user.rsp_intg, D2HRspMaxWidth'(rsp)}),
    .data_o(),
    .syndrome_o(),
    .err_o(rsp_err)
  );
  logic rsp_data_err;
  if (EnableRspDataIntgCheck) begin : gen_rsp_data_intg_check
    tlul_data_integ_dec u_tlul_data_integ_dec (
      .data_intg_i({tl_i.d_user.data_intg, DataMaxWidth'(tl_i.d_data)}),
      .data_err_o(rsp_data_err)
    );
  end else begin : gen_no_rsp_data_intg_check
    assign rsp_data_err = 1'b0;
  end
  
  
  
  
  
  assign err_o = tl_i.d_valid & (|rsp_err | rsp_data_err);
  logic unused_tl;
  assign unused_tl = |tl_i;
  `ASSERT_INIT(PayLoadWidthCheck, $bits(tl_d2h_rsp_intg_t) <= D2HRspMaxWidth)
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
module TopModule
  import tlul_pkg::*;
  import dma_pkg::*;
  import dma_reg_pkg::*;
#(
  parameter logic [NumAlerts-1:0]           AlertAsyncOn              = {NumAlerts{1'b1}},
  
  parameter int unsigned                    AlertSkewCycles           = 1,
  parameter bit                             EnableDataIntgGen         = 1'b1,
  parameter bit                             EnableRspDataIntgCheck    = 1'b1,
  parameter logic [RsvdWidth-1:0]           TlUserRsvd                = '0,
  parameter top_racl_pkg::racl_role_t       SysRaclRole               = '0,
  parameter int unsigned                    OtAgentId                 = 0,
  parameter bit                             EnableRacl                = 1'b0,
  parameter bit                             RaclErrorRsp              = EnableRacl,
  parameter top_racl_pkg::racl_policy_sel_t RaclPolicySelVec[NumRegs] = '{NumRegs{0}}
) (
  input logic                                       clk_i,
  input logic                                       rst_ni,
  input prim_mubi_pkg::mubi4_t                      scanmode_i,
  
  output  logic                                     intr_dma_done_o,
  output  logic                                     intr_dma_chunk_done_o,
  output  logic                                     intr_dma_error_o,
  input   lsio_trigger_t                            lsio_trigger_i,
  
  input  prim_alert_pkg::alert_rx_t [NumAlerts-1:0] alert_rx_i,
  output prim_alert_pkg::alert_tx_t [NumAlerts-1:0] alert_tx_o,
  
  input  top_racl_pkg::racl_policy_vec_t            racl_policies_i,
  output top_racl_pkg::racl_error_log_t             racl_error_o,
  
  input   tlul_pkg::tl_h2d_t                        tl_d_i,
  output  tlul_pkg::tl_d2h_t                        tl_d_o,
  
  input   tlul_pkg::tl_d2h_t                        ctn_tl_d2h_i,
  output  tlul_pkg::tl_h2d_t                        ctn_tl_h2d_o,
  
  input   tlul_pkg::tl_d2h_t                        host_tl_h_i,
  output  tlul_pkg::tl_h2d_t                        host_tl_h_o,
  
  input  dma_pkg::sys_rsp_t                         sys_i,
  output dma_pkg::sys_req_t                         sys_o
);
  import prim_mubi_pkg::*;
  import prim_sha2_pkg::*;
  dma_reg2hw_t reg2hw;
  dma_hw2reg_t hw2reg;
  localparam int unsigned TRANSFER_BYTES_WIDTH    = $bits(reg2hw.total_data_size.q);
  localparam int unsigned INTR_CLEAR_SOURCES_WIDTH = $clog2(NumIntClearSources);
  localparam int unsigned NR_SHA_DIGEST_ELEMENTS  = 16;
  
  dma_pkg::sys_req_t sys_req_d;
  dma_pkg::sys_rsp_t sys_resp_q;
  
  logic                       dma_host_tlul_req_valid,    dma_ctn_tlul_req_valid;
  logic [top_pkg::TL_AW-1:0]  dma_host_tlul_req_addr,     dma_ctn_tlul_req_addr;
  logic                       dma_host_tlul_req_we,       dma_ctn_tlul_req_we;
  logic [top_pkg::TL_DW-1:0]  dma_host_tlul_req_wdata,    dma_ctn_tlul_req_wdata;
  logic [top_pkg::TL_DBW-1:0] dma_host_tlul_req_be,       dma_ctn_tlul_req_be;
  logic                       dma_host_tlul_gnt,          dma_ctn_tlul_gnt;
  logic                       dma_host_tlul_rsp_valid,    dma_ctn_tlul_rsp_valid;
  logic [top_pkg::TL_DW-1:0]  dma_host_tlul_rsp_data,     dma_ctn_tlul_rsp_data;
  logic                       dma_host_tlul_rsp_err,      dma_ctn_tlul_rsp_err;
  logic                       dma_host_tlul_rsp_intg_err, dma_ctn_tlul_rsp_intg_err;
  logic                       dma_host_write, dma_host_read, dma_host_clear_intr;
  logic                       dma_ctn_write,  dma_ctn_read,  dma_ctn_clear_intr;
  logic                       dma_sys_write,  dma_sys_read;
  logic                       capture_return_data;
  logic [top_pkg::TL_DW-1:0]  read_return_data_q, read_return_data_d, dma_rsp_data;
  logic [SYS_ADDR_WIDTH-1:0]  new_src_addr, new_dst_addr;
  logic dma_state_error;
  
  dma_ctrl_state_e ctrl_state_q, ctrl_state_d;
  logic set_error_code, clear_go, clear_status, clear_sha_status, chunk_done;
  logic [INTR_CLEAR_SOURCES_WIDTH-1:0] clear_index_d, clear_index_q;
  logic                                clear_index_en, intr_clear_tlul_rsp_valid;
  logic                                intr_clear_tlul_gnt, intr_clear_tlul_rsp_error;
  logic [DmaErrLast-1:0] next_error;
  
  logic read_gnt;
  
  logic read_rsp_valid;
  
  
  logic read_rsp_error;
  
  logic write_gnt;
  
  logic write_rsp_valid;
  
  
  logic write_rsp_error;
  logic cfg_abort_en;
  assign cfg_abort_en = reg2hw.control.abort.q;
  logic cfg_handshake_en;
  logic [SYS_METADATA_WIDTH-1:0] src_metadata;
  assign src_metadata = SYS_METADATA_WIDTH'(1'b1) << OtAgentId;
  
  logic scanmode;
  assign scanmode = mubi4_test_true_strict(scanmode_i);
  logic sw_reg_wr, sw_reg_wr1, sw_reg_wr2;
  assign sw_reg_wr = reg2hw.control.go.qe;
  prim_flop #(
    .Width(1)
  ) aff_reg_wr1 (
    .clk_i ( clk_i      ),
    .rst_ni( rst_ni     ),
    .d_i   ( sw_reg_wr  ),
    .q_o   ( sw_reg_wr1 )
  );
  prim_flop #(
    .Width(1)
  ) aff_reg_wr2 (
    .clk_i ( clk_i      ),
    .rst_ni( rst_ni     ),
    .d_i   ( sw_reg_wr1 ),
    .q_o   ( sw_reg_wr2 )
  );
  
  logic sw_reg_wr_extended;
  assign sw_reg_wr_extended = sw_reg_wr || sw_reg_wr1 || sw_reg_wr2;
  logic gated_clk_en, gated_clk;
  assign gated_clk_en = reg2hw.control.go.q       ||
                        (ctrl_state_q != DmaIdle) ||
                        sw_reg_wr_extended;
  prim_clock_gating #(
    .FpgaBufGlobal(1'b0) 
  ) dma_clk_gate (
    .clk_i    ( clk_i        ),
    .en_i     ( gated_clk_en ),
    .test_en_i( scanmode     ),     
    .clk_o    ( gated_clk    )
  );
  logic reg_intg_error;
  
  
  dma_reg_top #(
    .EnableRacl       ( EnableRacl       ),
    .RaclErrorRsp     ( RaclErrorRsp     ),
    .RaclPolicySelVec ( RaclPolicySelVec )
  ) u_dma_reg (
    .clk_i     ( clk_i          ),
    .rst_ni    ( rst_ni         ),
    .tl_i      ( tl_d_i         ),
    .tl_o      ( tl_d_o         ),
    .reg2hw,
    .hw2reg,
    .racl_policies_i,
    .racl_error_o,
    .intg_err_o( reg_intg_error )
  );
  
  logic [NumAlerts-1:0] alert_test, alerts;
  assign alert_test = {reg2hw.alert_test.q & reg2hw.alert_test.qe};
  assign alerts[0]  = reg_intg_error              ||
                      dma_host_tlul_rsp_intg_err  ||
                      dma_ctn_tlul_rsp_intg_err   ||
                      dma_state_error;
  for (genvar i = 0; i < NumAlerts; i++) begin : gen_alert_tx
    prim_alert_sender #(
      .AsyncOn(AlertAsyncOn[i]),
      .SkewCycles(AlertSkewCycles),
      .IsFatal(1'b1)
    ) u_prim_alert_sender (
      .clk_i,
      .rst_ni,
      .alert_test_i (alert_test[i]),
      .alert_req_i  (alerts[i]),
      .alert_ack_o  (),
      .alert_state_o(),
      .alert_rx_i   (alert_rx_i[i]),
      .alert_tx_o   (alert_tx_o[i])
    );
  end
  
  tlul_adapter_host #(
    .MAX_REQS(NUM_MAX_OUTSTANDING_REQS),
    .EnableDataIntgGen(EnableDataIntgGen),
    .EnableRspDataIntgCheck(EnableRspDataIntgCheck)
  ) u_dma_host_tlul_host (
    .clk_i          ( gated_clk                        ),
    .rst_ni         ( rst_ni                           ),
    
    .req_i          ( dma_host_tlul_req_valid          ),
    .gnt_o          ( dma_host_tlul_gnt                ),
    .addr_i         ( dma_host_tlul_req_addr           ),
    .we_i           ( dma_host_tlul_req_we             ),
    .wdata_i        ( dma_host_tlul_req_wdata          ),
    .wdata_intg_i   ( TL_A_USER_DEFAULT.data_intg      ),
    .be_i           ( dma_host_tlul_req_be             ),
    .instr_type_i   ( MuBi4False                       ),
    .user_rsvd_i    ( TlUserRsvd                       ),
    .valid_o        ( dma_host_tlul_rsp_valid          ),
    .rdata_o        ( dma_host_tlul_rsp_data           ),
    .rdata_intg_o   (                                  ),
    .err_o          ( dma_host_tlul_rsp_err            ),
    .intg_err_o     ( dma_host_tlul_rsp_intg_err       ),
    .tl_o           ( host_tl_h_o                      ),
    .tl_i           ( host_tl_h_i                      )
  );
  
  tlul_adapter_host #(
    .MAX_REQS(NUM_MAX_OUTSTANDING_REQS),
    .EnableDataIntgGen(EnableDataIntgGen),
    .EnableRspDataIntgCheck(EnableRspDataIntgCheck)
  ) u_dma_ctn_tlul_host (
    .clk_i          ( gated_clk                        ),
    .rst_ni         ( rst_ni                           ),
    
    .req_i          ( dma_ctn_tlul_req_valid           ),
    .gnt_o          ( dma_ctn_tlul_gnt                 ),
    .addr_i         ( dma_ctn_tlul_req_addr            ),
    .we_i           ( dma_ctn_tlul_req_we              ),
    .wdata_i        ( dma_ctn_tlul_req_wdata           ),
    .wdata_intg_i   ( TL_A_USER_DEFAULT.data_intg      ),
    .be_i           ( dma_ctn_tlul_req_be              ),
    .instr_type_i   ( MuBi4False                       ),
    .user_rsvd_i    ( TlUserRsvd                       ),
    .valid_o        ( dma_ctn_tlul_rsp_valid           ),
    .rdata_o        ( dma_ctn_tlul_rsp_data            ),
    .rdata_intg_o   (                                  ),
    .err_o          ( dma_ctn_tlul_rsp_err             ),
    .intg_err_o     ( dma_ctn_tlul_rsp_intg_err        ),
    .tl_o           ( ctn_tl_h2d_o                     ),
    .tl_i           ( ctn_tl_d2h_i                     )
  );
  
  lsio_trigger_t lsio_trigger;
  always_comb begin
    lsio_trigger = '0;
    for (int i = 0; i < NumIntClearSources; i++) begin
      lsio_trigger[i] = lsio_trigger_i[i] && reg2hw.handshake_intr_enable.q[i];
    end
  end
  
  
  
  
  
  
  control_state_t control_d, control_q;
  logic           capture_state;
  
  always_comb begin
    control_d.opcode                     = opcode_e'(reg2hw.control.opcode.q);
    control_d.cfg_handshake_en           = reg2hw.control.hardware_handshake_enable.q;
    control_d.cfg_digest_swap            = reg2hw.control.digest_swap.q;
    control_d.range_valid                = reg2hw.range_valid.q;
    control_d.enabled_memory_range_base  = reg2hw.enabled_memory_range_base.q;
    control_d.enabled_memory_range_limit = reg2hw.enabled_memory_range_limit.q;
  end
  prim_flop_en #(
    .Width($bits(control_state_t))
  ) u_opcode (
    .clk_i  ( gated_clk     ),
    .rst_ni ( rst_ni        ),
    .en_i   ( capture_state ),
    .d_i    ( control_d     ),
    .q_o    ( control_q     )
  );
  `PRIM_FLOP_SPARSE_FSM(aff_ctrl_state_q, ctrl_state_d, ctrl_state_q, dma_ctrl_state_e, DmaIdle,
                        gated_clk, rst_ni)
  logic [TRANSFER_BYTES_WIDTH-1:0] transfer_byte_q, transfer_byte_d;
  logic [TRANSFER_BYTES_WIDTH-1:0] transfer_remaining_bytes;
  logic [TRANSFER_BYTES_WIDTH-1:0] chunk_remaining_bytes;
  logic [TRANSFER_BYTES_WIDTH-1:0] remaining_bytes;
  logic                            capture_transfer_byte;
  prim_flop_en #(
    .Width(TRANSFER_BYTES_WIDTH)
  ) aff_transfer_byte (
    .clk_i  ( gated_clk             ),
    .rst_ni ( rst_ni                ),
    .en_i   ( capture_transfer_byte ),
    .d_i    ( transfer_byte_d       ),
    .q_o    ( transfer_byte_q       )
  );
  logic [TRANSFER_BYTES_WIDTH-1:0] chunk_byte_q, chunk_byte_d;
  logic                            capture_chunk_byte;
  prim_flop_en #(
    .Width(TRANSFER_BYTES_WIDTH)
  ) aff_chunk_byte (
    .clk_i  ( gated_clk          ),
    .rst_ni ( rst_ni             ),
    .en_i   ( capture_chunk_byte ),
    .d_i    ( chunk_byte_d       ),
    .q_o    ( chunk_byte_q       )
  );
  logic       capture_transfer_width;
  logic [2:0] transfer_width_q, transfer_width_d;
  prim_flop_en #(
    .Width(3)
  ) aff_transfer_width (
    .clk_i ( gated_clk              ),
    .rst_ni( rst_ni                 ),
    .en_i  ( capture_transfer_width ),
    .d_i   ( transfer_width_d       ),
    .q_o   ( transfer_width_q       )
  );
  logic                      capture_addr;
  logic [SYS_ADDR_WIDTH-1:0] src_addr_q, src_addr_d;
  logic [SYS_ADDR_WIDTH-1:0] dst_addr_q, dst_addr_d;
  prim_flop_en #(
    .Width(SYS_ADDR_WIDTH)
  ) aff_src_addr (
    .clk_i ( gated_clk    ),
    .rst_ni( rst_ni       ),
    .en_i  ( capture_addr ),
    .d_i   ( src_addr_d   ),
    .q_o   ( src_addr_q   )
  );
  prim_flop_en #(
    .Width(SYS_ADDR_WIDTH)
  ) aff_dst_addr (
    .clk_i ( gated_clk    ),
    .rst_ni( rst_ni       ),
    .en_i  ( capture_addr ),
    .d_i   ( dst_addr_d   ),
    .q_o   ( dst_addr_q   )
  );
  logic                       capture_be;
  logic [top_pkg::TL_DBW-1:0] req_src_be_q, req_src_be_d;
  logic [top_pkg::TL_DBW-1:0] req_dst_be_q, req_dst_be_d;
  prim_flop_en #(
    .Width(top_pkg::TL_DBW)
  ) aff_req_src_be (
    .clk_i ( gated_clk    ),
    .rst_ni( rst_ni       ),
    .en_i  ( capture_be   ),
    .d_i   ( req_src_be_d ),
    .q_o   ( req_src_be_q )
  );
  prim_flop_en #(
    .Width(top_pkg::TL_DBW)
  ) aff_req_dst_be (
    .clk_i ( gated_clk    ),
    .rst_ni( rst_ni       ),
    .en_i  ( capture_be   ),
    .d_i   ( req_dst_be_d ),
    .q_o   ( req_dst_be_q )
  );
  prim_flop_en #(
    .Width(INTR_CLEAR_SOURCES_WIDTH)
  ) u_clear_index (
    .clk_i ( gated_clk      ),
    .rst_ni( rst_ni         ),
    .en_i  ( clear_index_en ),
    .d_i   ( clear_index_d  ),
    .q_o   ( clear_index_q  )
  );
  logic use_inline_hashing;
  logic sha2_hash_start, sha2_hash_process;
  logic sha2_valid, sha2_ready, sha2_digest_set;
  sha_fifo32_t sha2_data;
  digest_mode_e sha2_mode;
  sha_word64_t [7:0] sha2_digest;
  assign use_inline_hashing = control_q.opcode inside {OpcSha256,  OpcSha384, OpcSha512};
  
  assign sha2_hash_process = (ctrl_state_q == DmaShaFinalize);
  logic sha2_consumed_d, sha2_consumed_q;
  prim_flop #(
    .Width(1)
  ) u_sha2_consumed (
    .clk_i ( gated_clk       ),
    .rst_ni( rst_ni          ),
    .d_i   ( sha2_consumed_d ),
    .q_o   ( sha2_consumed_q )
  );
  logic sha2_hash_done;
  logic sha2_hash_done_d, sha2_hash_done_q;
  prim_flop #(
    .Width(1)
  ) u_sha2_hash_done (
    .clk_i ( gated_clk        ),
    .rst_ni( rst_ni           ),
    .d_i   ( sha2_hash_done_d ),
    .q_o   ( sha2_hash_done_q )
  );
  
  logic [63:0] sha2_message_len_bits;
  assign sha2_message_len_bits = reg2hw.total_data_size.q << 3;
  
  always_comb begin
    unique case (control_q.opcode)
      OpcSha256: sha2_mode = SHA2_256;
      OpcSha384: sha2_mode = SHA2_384;
      OpcSha512: sha2_mode = SHA2_512;
      default:   sha2_mode = SHA2_None;
    endcase
  end
  
  prim_sha2_32 #(.MultimodeEn(1)) u_sha2 (
    .clk_i              ( clk_i                 ),
    .rst_ni             ( rst_ni                ),
    .wipe_secret_i      ( 1'b0                  ),
    .wipe_v_i           ( 32'b0                 ),
    .fifo_rvalid_i      ( sha2_valid            ),
    .fifo_rdata_i       ( sha2_data             ),
    .fifo_rready_o      ( sha2_ready            ),
    .sha_en_i           ( 1'b1                  ),
    .hash_start_i       ( sha2_hash_start       ),
    .hash_stop_i        ( 1'b0                  ),
    .hash_continue_i    ( 1'b0                  ),
    .digest_mode_i      ( sha2_mode             ),
    .hash_process_i     ( sha2_hash_process     ),
    .hash_done_o        ( sha2_hash_done        ),
    .message_length_i   ( sha2_message_len_bits ),
    .digest_i           ( '0                    ),
    .digest_we_i        ( '0                    ),
    .digest_o           ( sha2_digest           ),
    .digest_on_blk_o    (                       ),
    .hash_running_o     (                       ),
    .idle_o             (                       )
  );
  
  logic [ASID_WIDTH-1:0] src_asid, dst_asid;
  assign src_asid = reg2hw.addr_space_id.src_asid.q;
  assign dst_asid = reg2hw.addr_space_id.dst_asid.q;
  
  
  
  always_comb begin
    dma_host_write = (ctrl_state_q == DmaSendWrite) & (dst_asid == OtInternalAddr);
    dma_host_read  = (ctrl_state_q == DmaSendRead)  & (src_asid == OtInternalAddr);
    dma_host_tlul_req_valid = dma_host_write | dma_host_read | dma_host_clear_intr;
    
    dma_host_tlul_req_addr  = dma_host_write ? {dst_addr_q[top_pkg::TL_AW-1:2], 2'b0} :
                             (dma_host_read  ? {src_addr_q[top_pkg::TL_AW-1:2], 2'b0} :
                        (dma_host_clear_intr ? reg2hw.intr_src_addr[clear_index_q].q : 'b0));
    dma_host_tlul_req_we    = dma_host_write | dma_host_clear_intr;
    dma_host_tlul_req_wdata = dma_host_write ? read_return_data_q :
                        (dma_host_clear_intr ? reg2hw.intr_src_wr_val[clear_index_q].q : 'b0);
    dma_host_tlul_req_be    = dma_host_write ? req_dst_be_q :
                             (dma_host_read  ? req_src_be_q
                                             : {top_pkg::TL_DBW{dma_host_clear_intr}});
  end
  
  always_comb begin
    dma_ctn_write = (ctrl_state_q == DmaSendWrite) & (dst_asid == SocControlAddr);
    dma_ctn_read  = (ctrl_state_q == DmaSendRead)  & (src_asid == SocControlAddr);
    dma_ctn_tlul_req_valid = dma_ctn_write | dma_ctn_read | dma_ctn_clear_intr;
    
    dma_ctn_tlul_req_addr  = dma_ctn_write ? {dst_addr_q[top_pkg::TL_AW-1:2], 2'b0} :
                            (dma_ctn_read  ? {src_addr_q[top_pkg::TL_AW-1:2], 2'b0} :
                       (dma_ctn_clear_intr ? reg2hw.intr_src_addr[clear_index_q].q : 'b0));
    dma_ctn_tlul_req_we    = dma_ctn_write | dma_ctn_clear_intr;
    dma_ctn_tlul_req_wdata = dma_ctn_write ? read_return_data_q :
                       (dma_ctn_clear_intr ? reg2hw.intr_src_wr_val[clear_index_q].q : 'b0);
    dma_ctn_tlul_req_be    = dma_ctn_write ? req_dst_be_q :
                            (dma_ctn_read  ? req_src_be_q : {top_pkg::TL_DBW{dma_ctn_clear_intr}});
  end
  
  always_comb begin
    dma_sys_write = (ctrl_state_q == DmaSendWrite) & (dst_asid == SocSystemAddr);
    dma_sys_read  = (ctrl_state_q == DmaSendRead)  & (src_asid  == SocSystemAddr);
    sys_req_d.vld_vec     [SysCmdWrite] = dma_sys_write;
    sys_req_d.metadata_vec[SysCmdWrite] = src_metadata;
    sys_req_d.opcode_vec  [SysCmdWrite] = SysOpcWrite;
    sys_req_d.iova_vec    [SysCmdWrite] = dma_sys_write ?
                                         {dst_addr_q[(SYS_ADDR_WIDTH-1):2], 2'b0} : 'b0;
    sys_req_d.racl_vec    [SysCmdWrite] = SysRaclRole;
    sys_req_d.write_data = {SYS_DATA_WIDTH{dma_sys_write}} & read_return_data_q;
    sys_req_d.write_be   = {SYS_DATA_BYTEWIDTH{dma_sys_write}} & req_dst_be_q;
    sys_req_d.vld_vec     [SysCmdRead] = dma_sys_read;
    sys_req_d.metadata_vec[SysCmdRead] = src_metadata;
    sys_req_d.opcode_vec  [SysCmdRead] = SysOpcRead;
    sys_req_d.iova_vec    [SysCmdRead] = dma_sys_read ?
                                         {src_addr_q[(SYS_ADDR_WIDTH-1):2], 2'b0} : 'b0;
    sys_req_d.racl_vec    [SysCmdRead] = SysRaclRole;
    sys_req_d.read_be                  = req_src_be_q;
  end
  
  always_comb begin
    unique case (dst_asid)
      OtInternalAddr: begin
        
        write_gnt       = dma_host_tlul_gnt;
        
        write_rsp_valid = dma_host_tlul_rsp_valid;
        
        write_rsp_error = dma_host_tlul_rsp_err;
      end
      SocSystemAddr: begin
        write_gnt       = 1'b1;  
        write_rsp_valid = sys_resp_q.grant_vec[SysCmdWrite] | sys_resp_q.error_vld;
        write_rsp_error = sys_resp_q.error_vld;
      end
      
      
      default: begin
        write_gnt       = dma_ctn_tlul_gnt;
        write_rsp_valid = dma_ctn_tlul_rsp_valid;
        write_rsp_error = dma_ctn_tlul_rsp_err;
      end
    endcase
  end
  
  always_comb begin
    unique case (src_asid)
      OtInternalAddr: begin
        
        read_gnt       = dma_host_tlul_gnt;
        
        read_rsp_valid = dma_host_tlul_rsp_valid;
        
        read_rsp_error = dma_host_tlul_rsp_err;
      end
      SocSystemAddr: begin
        read_gnt       = 1'b1;  
        read_rsp_valid = sys_resp_q.read_data_vld;
        read_rsp_error = sys_resp_q.error_vld;
      end
      
      
      default: begin
        read_gnt       = dma_ctn_tlul_gnt;
        read_rsp_valid = dma_ctn_tlul_rsp_valid;
        read_rsp_error = dma_ctn_tlul_rsp_err;
      end
    endcase
  end
  always_comb begin
    ctrl_state_d = ctrl_state_q;
    capture_transfer_byte  = 1'b0;
    transfer_byte_d        = transfer_byte_q;
    capture_chunk_byte     = 1'b0;
    chunk_byte_d           = chunk_byte_q;
    capture_transfer_width = 1'b0;
    transfer_width_d       = '0;
    capture_return_data    = 1'b0;
    capture_state          = 1'b0;
    next_error   = '0;
    capture_addr = 1'b0;
    src_addr_d   = '0;
    dst_addr_d   = '0;
    capture_be   = '0;
    req_src_be_d = '0;
    req_dst_be_d = '0;
    dma_host_clear_intr = 1'b0;
    dma_ctn_clear_intr = 1'b0;
    clear_index_d  = '0;
    clear_index_en = '0;
    clear_go       = 1'b0;
    chunk_done     = 1'b0;
    
    intr_clear_tlul_gnt       = reg2hw.clear_intr_bus.q[clear_index_q] ? dma_host_tlul_gnt :
                                                                         dma_ctn_tlul_gnt;
    intr_clear_tlul_rsp_valid = reg2hw.clear_intr_bus.q[clear_index_q] ? dma_host_tlul_rsp_valid :
                                                                         dma_ctn_tlul_rsp_valid;
    intr_clear_tlul_rsp_error = reg2hw.clear_intr_bus.q[clear_index_q] ? dma_host_tlul_rsp_err :
                                                                         dma_ctn_tlul_rsp_err;
    dma_state_error = 1'b0;
    sha2_hash_start      = 1'b0;
    sha2_valid           = 1'b0;
    sha2_digest_set      = 1'b0;
    sha2_consumed_d      = sha2_consumed_q;
    
    if (ctrl_state_q == DmaIdle) begin
      sha2_hash_done_d = 1'b0;
    end else begin
      sha2_hash_done_d = sha2_hash_done_q | sha2_hash_done;
    end
    
    cfg_handshake_en = control_q.cfg_handshake_en;
    
    
    
    
    if (cfg_abort_en) begin
      ctrl_state_d = DmaIdle;
      clear_go     = 1'b1;
    end else begin
      unique case (ctrl_state_q)
        DmaIdle: begin
          chunk_byte_d       = '0;
          capture_chunk_byte = 1'b1;
          
          
          
          if (!reg2hw.status.busy.q) begin
            
            cfg_handshake_en = reg2hw.control.hardware_handshake_enable.q;
          end
          
          
          if (reg2hw.control.go.q || reg2hw.status.busy.q) begin
            
            if (reg2hw.control.initial_transfer.q && !reg2hw.status.busy.q) begin
              transfer_byte_d       = '0;
              capture_transfer_byte = 1'b1;
              
              capture_state = 1'b1;
            end
            
            if (!cfg_handshake_en) begin
              ctrl_state_d = DmaAddrSetup;
            end else if (cfg_handshake_en && |lsio_trigger) begin
              
              if (|reg2hw.clear_intr_src.q) begin
                clear_index_en = 1'b1;
                clear_index_d  = '0;
                ctrl_state_d   = DmaClearIntrSrc;
              end else begin
                ctrl_state_d = DmaAddrSetup;
              end
            end
          end
        end
        DmaClearIntrSrc: begin
          
          if (reg2hw.clear_intr_src.q[clear_index_q]) begin
            
            dma_host_clear_intr = reg2hw.clear_intr_bus.q[clear_index_q];
            dma_ctn_clear_intr = !reg2hw.clear_intr_bus.q[clear_index_q];
            if (intr_clear_tlul_gnt) begin
              ctrl_state_d = DmaWaitIntrSrcResponse;
            end
            
            
            
            if (intr_clear_tlul_rsp_valid) begin
              if (intr_clear_tlul_rsp_error) begin
                next_error[DmaBusErr] = 1'b1;
                ctrl_state_d = DmaError;
              end else if (32'(clear_index_q) >= (NumIntClearSources - 1)) begin
                ctrl_state_d = DmaAddrSetup;  
              end else begin
                clear_index_en = 1'b1;
                clear_index_d  = clear_index_q + INTR_CLEAR_SOURCES_WIDTH'(1'b1);
                ctrl_state_d   = DmaClearIntrSrc;  
              end
            end
          end else begin
            
            clear_index_en = 1'b1;
            clear_index_d  = clear_index_q + INTR_CLEAR_SOURCES_WIDTH'(1'b1);
            if (32'(clear_index_q) >= (NumIntClearSources - 1)) begin
              ctrl_state_d = DmaAddrSetup;
            end
          end
        end
        DmaWaitIntrSrcResponse: begin
          
          
          if (intr_clear_tlul_rsp_valid) begin
            if (intr_clear_tlul_rsp_error) begin
              next_error[DmaBusErr] = 1'b1;
              ctrl_state_d = DmaError;
            end else if (32'(clear_index_q) < (NumIntClearSources - 1)) begin
              clear_index_en = 1'b1;
              clear_index_d  = clear_index_q + INTR_CLEAR_SOURCES_WIDTH'(1'b1);
              ctrl_state_d   = DmaClearIntrSrc;
            end else begin
              ctrl_state_d = DmaAddrSetup;
            end
          end
        end
        DmaAddrSetup: begin
          capture_transfer_width = 1'b1;
          capture_addr           = 1'b1;
          capture_be             = 1'b1;
          sha2_consumed_d        = 1'b0;
          
          unique case (reg2hw.transfer_width.q)
            DmaXfer1BperTxn: transfer_width_d = 3'b001; 
            DmaXfer2BperTxn: transfer_width_d = 3'b010; 
            DmaXfer4BperTxn: transfer_width_d = 3'b100; 
            
            default: next_error[DmaSizeErr] = 1'b1;  
          endcase
          
          if ((transfer_byte_q == '0) ||
              
              reg2hw.src_config.increment.q == AddrNoIncrement ||
              
              (chunk_byte_q == '0 && reg2hw.src_config.wrap.q == AddrWrapChunk)) begin
            src_addr_d = {reg2hw.src_addr_hi.q, reg2hw.src_addr_lo.q};
          end else begin
            
            src_addr_d = src_addr_q + SYS_ADDR_WIDTH'(transfer_width_d);
          end
          
          if ((transfer_byte_q == '0) ||
              
              reg2hw.dst_config.increment.q == AddrNoIncrement ||
              
              (chunk_byte_q == '0 && reg2hw.dst_config.wrap.q == AddrWrapChunk)) begin
            dst_addr_d = {reg2hw.dst_addr_hi.q, reg2hw.dst_addr_lo.q};
          end else begin
            
            dst_addr_d = dst_addr_q + SYS_ADDR_WIDTH'(transfer_width_d);
          end
          unique case (transfer_width_d)
            3'b001: begin
              req_dst_be_d = top_pkg::TL_DBW'('b0001) << dst_addr_d[1:0];
              req_src_be_d = top_pkg::TL_DBW'('b0001) << src_addr_d[1:0];
            end
            3'b010: begin
              if (remaining_bytes >= TRANSFER_BYTES_WIDTH'(transfer_width_d)) begin
                req_dst_be_d = top_pkg::TL_DBW'('b0011) << dst_addr_d[1:0];
                req_src_be_d = top_pkg::TL_DBW'('b0011) << src_addr_d[1:0];
              end else begin
                req_dst_be_d = top_pkg::TL_DBW'('b0001) << dst_addr_d[1:0];
                req_src_be_d = top_pkg::TL_DBW'('b0001) << src_addr_d[1:0];
              end
            end
            3'b100: begin
              if (remaining_bytes >= TRANSFER_BYTES_WIDTH'(transfer_width_d)) begin
                req_dst_be_d = {top_pkg::TL_DBW{1'b1}};
              end else begin
                unique case (remaining_bytes)
                  TRANSFER_BYTES_WIDTH'('h1): req_dst_be_d = top_pkg::TL_DBW'('b0001);
                  TRANSFER_BYTES_WIDTH'('h2): req_dst_be_d = top_pkg::TL_DBW'('b0011);
                  TRANSFER_BYTES_WIDTH'('h3): req_dst_be_d = top_pkg::TL_DBW'('b0111);
                  default:                    req_dst_be_d = top_pkg::TL_DBW'('b1111);
                endcase
              end
              req_src_be_d = req_dst_be_d;  
            end
            default: begin
              req_dst_be_d = top_pkg::TL_DBW'('b0000);
              req_src_be_d = top_pkg::TL_DBW'('b0000);
            end
          endcase
          
          
          if ((reg2hw.chunk_data_size.q == '0) ||         
              (reg2hw.total_data_size.q == '0)) begin     
            next_error[DmaSizeErr] = 1'b1;
          end
          if (!(control_q.opcode inside {OpcCopy, OpcSha256, OpcSha384, OpcSha512})) begin
            next_error[DmaOpcodeErr] = 1'b1;
          end
          
          if (use_inline_hashing) begin
            if (reg2hw.transfer_width.q != DmaXfer4BperTxn) begin
              next_error[DmaSizeErr] = 1'b1;
            end
          end
          
          
          if (!(src_asid inside {OtInternalAddr, SocControlAddr, SocSystemAddr})) begin
            next_error[DmaAsidErr] = 1'b1;
          end
          if (!(dst_asid inside {OtInternalAddr, SocControlAddr, SocSystemAddr})) begin
            next_error[DmaAsidErr] = 1'b1;
          end
          
          
          if (control_q.enabled_memory_range_limit < control_q.enabled_memory_range_base) begin
            next_error[DmaBaseLimitErr] = 1'b1;
          end
          
          if (reg2hw.transfer_width.q == DmaXfer4BperTxn && |reg2hw.src_addr_lo.q[1:0]) begin
            next_error[DmaSrcAddrErr] = 1'b1;
          end
          if (reg2hw.transfer_width.q == DmaXfer4BperTxn && |reg2hw.dst_addr_lo.q[1:0]) begin
            next_error[DmaDstAddrErr] = 1'b1;
          end
          
          if (reg2hw.transfer_width.q == DmaXfer2BperTxn && reg2hw.src_addr_lo.q[0]) begin
            next_error[DmaSrcAddrErr] = 1'b1;
          end
          if (reg2hw.transfer_width.q == DmaXfer2BperTxn &&
              reg2hw.dst_addr_lo.q[0]) begin
            next_error[DmaDstAddrErr] = 1'b1;
          end
          
          
          
          if ((src_asid inside {SocControlAddr, SocSystemAddr}) && (dst_asid == OtInternalAddr) &&
              
              ((reg2hw.dst_addr_lo.q > control_q.enabled_memory_range_limit) ||
                (reg2hw.dst_addr_lo.q < control_q.enabled_memory_range_base) ||
                ((SYS_ADDR_WIDTH'(reg2hw.dst_addr_lo.q) +
                  SYS_ADDR_WIDTH'(reg2hw.chunk_data_size.q)) >
                  SYS_ADDR_WIDTH'(control_q.enabled_memory_range_limit)))) begin
            next_error[DmaDstAddrErr] = 1'b1;
          end
          
          
          
          if ((dst_asid inside {SocControlAddr, SocSystemAddr}) && (src_asid == OtInternalAddr) &&
                
                ((reg2hw.src_addr_lo.q > control_q.enabled_memory_range_limit) ||
                (reg2hw.src_addr_lo.q < control_q.enabled_memory_range_base)   ||
                ((SYS_ADDR_WIDTH'(reg2hw.src_addr_lo.q) +
                  SYS_ADDR_WIDTH'(reg2hw.chunk_data_size.q)) >
                  SYS_ADDR_WIDTH'(control_q.enabled_memory_range_limit)))) begin
            next_error[DmaSrcAddrErr] = 1'b1;
          end
          
          
          if ((src_asid inside {SocControlAddr, OtInternalAddr}) &&
              (|reg2hw.src_addr_hi.q)) begin
            next_error[DmaSrcAddrErr] = 1'b1;
          end
          
          
          
          if ((dst_asid inside {SocControlAddr, OtInternalAddr}) &&
              (|reg2hw.dst_addr_hi.q)) begin
            next_error[DmaDstAddrErr] = 1'b1;
          end
          if (!control_q.range_valid) begin
            next_error[DmaRangeValidErr] = 1'b1;
          end
          
          if (|next_error) begin
            ctrl_state_d = DmaError;
          end else begin
            
            
            if (transfer_byte_q == '0) begin
              if (use_inline_hashing) begin
                sha2_hash_start = 1'b1;
              end
            end
            ctrl_state_d = DmaSendRead;
          end
        end
        DmaSendRead,
        DmaWaitReadResponse: begin
          if (read_rsp_valid) begin
            if (read_rsp_error) begin
              next_error[DmaBusErr] = 1'b1;
              ctrl_state_d          = DmaError;
            end else begin
              capture_return_data = 1'b1;
              
              if (use_inline_hashing) begin
                sha2_valid      = 1'b1;
                sha2_consumed_d = sha2_ready;
              end
              ctrl_state_d = DmaSendWrite;
            end
          end else if (read_gnt) begin
            
            ctrl_state_d = DmaWaitReadResponse;
          end
        end
        DmaSendWrite,
        DmaWaitWriteResponse: begin
          
          if (use_inline_hashing && !sha2_consumed_q) begin
            sha2_valid = 1'b1;
            sha2_consumed_d = sha2_ready;
          end
          if (write_rsp_valid) begin
            if (write_rsp_error) begin
              next_error[DmaBusErr] = 1'b1;
              ctrl_state_d          = DmaError;
            end else begin
              
              transfer_byte_d       = transfer_byte_q + TRANSFER_BYTES_WIDTH'(transfer_width_q);
              chunk_byte_d          = chunk_byte_q + TRANSFER_BYTES_WIDTH'(transfer_width_q);
              capture_transfer_byte = 1'b1;
              capture_chunk_byte    = 1'b1;
              
              
              if (use_inline_hashing && !(sha2_ready || sha2_consumed_q)) begin
                ctrl_state_d = DmaShaWait;
              end else begin
                
                if (transfer_byte_d >= reg2hw.total_data_size.q) begin
                  if (use_inline_hashing) begin
                    ctrl_state_d = DmaShaFinalize;
                  end else begin
                    clear_go     = 1'b1;
                    ctrl_state_d = DmaIdle;
                  end
                end else if (chunk_byte_d >= reg2hw.chunk_data_size.q) begin
                  
                  
                  
                  
                  
                  clear_go     = !control_q.cfg_handshake_en;
                  chunk_done   = !control_q.cfg_handshake_en;
                  ctrl_state_d = DmaIdle;
                end else begin
                  ctrl_state_d = DmaAddrSetup;
                end
              end
            end
          end else if (write_gnt) begin
            
            ctrl_state_d = DmaWaitWriteResponse;
          end
        end
        DmaShaWait: begin
          
          sha2_valid = 1'b1;
          if (sha2_ready) begin
            
            if (transfer_byte_q >= reg2hw.total_data_size.q) begin
              ctrl_state_d = DmaShaFinalize;
            end else if (chunk_byte_q >= reg2hw.chunk_data_size.q) begin
              
              
              
              clear_go     = !control_q.cfg_handshake_en;
              chunk_done   = !control_q.cfg_handshake_en;
              ctrl_state_d = DmaIdle;
            end else begin
              ctrl_state_d = DmaAddrSetup;
            end
          end
        end
        DmaShaFinalize: begin
          if (sha2_hash_done_q) begin
            
            sha2_digest_set = 1'b1;
            ctrl_state_d   = DmaIdle;
            clear_go       = 1'b1;
          end
        end
        
        DmaError: begin
          if (!reg2hw.status.error.q) begin
            ctrl_state_d = DmaIdle;
            clear_go     = 1'b1;
          end
        end
        default: begin
          
          dma_state_error = 1'b1;
        end
      endcase
    end
  end
  
  always_comb begin
    unique case (src_asid)
      OtInternalAddr: dma_rsp_data = dma_host_tlul_rsp_data;
      SocControlAddr: dma_rsp_data = dma_ctn_tlul_rsp_data;
      default:        dma_rsp_data = sys_resp_q.read_data;
    endcase
  end
  
  
  always_comb begin
    unique case (transfer_width_q)
      
      3'b001:
        unique casez (req_src_be_q)
          4'b1???: read_return_data_d = {4{dma_rsp_data[31:24]}};
          4'b01??: read_return_data_d = {4{dma_rsp_data[23:16]}};
          4'b001?: read_return_data_d = {4{dma_rsp_data[15:8]}};
          default: read_return_data_d = {4{dma_rsp_data[7:0]}};
        endcase
      
      
      3'b010:  read_return_data_d = {2{|req_src_be_q[1:0] ? dma_rsp_data[15:0]
                                                          : dma_rsp_data[31:16]}};
      default: read_return_data_d = dma_rsp_data;
    endcase
  end
  prim_flop_en #(
    .Width(top_pkg::TL_DW)
  ) aff_read_return_data (
    .clk_i ( gated_clk             ),
    .rst_ni( rst_ni                ),
    .en_i  ( capture_return_data   ),
    .d_i   ( read_return_data_d    ),
    .q_o   ( read_return_data_q    )
  );
  
  
  
  
  assign sha2_data.data = {<<8{capture_return_data ? read_return_data_d :
                                                     read_return_data_q}};
  assign sha2_data.mask = {<<1{req_dst_be_q}};
  
  prim_intr_hw #(
    .IntrT ( "Status" )
  ) u_intr_dma_done (
    .clk_i                  ( clk_i                         ),
    .rst_ni                 ( rst_ni                        ),
    .event_intr_i           ( reg2hw.status.done.q          ),
    .reg2hw_intr_enable_q_i ( reg2hw.intr_enable.dma_done.q ),
    .reg2hw_intr_test_q_i   ( reg2hw.intr_test.dma_done.q   ),
    .reg2hw_intr_test_qe_i  ( reg2hw.intr_test.dma_done.qe  ),
    .reg2hw_intr_state_q_i  ( reg2hw.intr_state.dma_done.q  ),
    .hw2reg_intr_state_de_o ( hw2reg.intr_state.dma_done.de ),
    .hw2reg_intr_state_d_o  ( hw2reg.intr_state.dma_done.d  ),
    .intr_o                 ( intr_dma_done_o               )
  );
  prim_intr_hw #(
    .IntrT ( "Status" )
  ) u_intr_chunk_dma_done (
    .clk_i                  ( clk_i                               ),
    .rst_ni                 ( rst_ni                              ),
    .event_intr_i           ( reg2hw.status.chunk_done.q          ),
    .reg2hw_intr_enable_q_i ( reg2hw.intr_enable.dma_chunk_done.q ),
    .reg2hw_intr_test_q_i   ( reg2hw.intr_test.dma_chunk_done.q   ),
    .reg2hw_intr_test_qe_i  ( reg2hw.intr_test.dma_chunk_done.qe  ),
    .reg2hw_intr_state_q_i  ( reg2hw.intr_state.dma_chunk_done.q  ),
    .hw2reg_intr_state_de_o ( hw2reg.intr_state.dma_chunk_done.de ),
    .hw2reg_intr_state_d_o  ( hw2reg.intr_state.dma_chunk_done.d  ),
    .intr_o                 ( intr_dma_chunk_done_o               )
  );
  prim_intr_hw #(
    .IntrT ( "Status" )
  ) u_intr_error (
    .clk_i                  ( clk_i                          ),
    .rst_ni                 ( rst_ni                         ),
    .event_intr_i           ( reg2hw.status.error.q          ),
    .reg2hw_intr_enable_q_i ( reg2hw.intr_enable.dma_error.q ),
    .reg2hw_intr_test_q_i   ( reg2hw.intr_test.dma_error.q   ),
    .reg2hw_intr_test_qe_i  ( reg2hw.intr_test.dma_error.qe  ),
    .reg2hw_intr_state_q_i  ( reg2hw.intr_state.dma_error.q  ),
    .hw2reg_intr_state_de_o ( hw2reg.intr_state.dma_error.de ),
    .hw2reg_intr_state_d_o  ( hw2reg.intr_state.dma_error.d  ),
    .intr_o                 ( intr_dma_error_o               )
  );
  logic data_move_state;
  logic update_dst_addr_reg, update_src_addr_reg;
  assign data_move_state = (ctrl_state_q == DmaSendWrite)         ||
                           (ctrl_state_q == DmaWaitWriteResponse) ||
                           (ctrl_state_q == DmaShaWait)           ||
                           (ctrl_state_q == DmaShaFinalize);
  
  
  
  
  assign transfer_remaining_bytes = reg2hw.total_data_size.q - transfer_byte_q;
  assign chunk_remaining_bytes = reg2hw.chunk_data_size.q - chunk_byte_q;
  assign remaining_bytes = (transfer_remaining_bytes < chunk_remaining_bytes) ?
                            transfer_remaining_bytes : chunk_remaining_bytes;
  always_comb begin
    
    
    
    
    
    
    hw2reg.control.go.de = clear_go || cfg_abort_en;
    hw2reg.control.go.d  = 1'b0;
    
    
    hw2reg.cfg_regwen.d = prim_mubi_pkg::mubi4_bool_to_mubi(~reg2hw.status.busy.q);
    
    
    new_dst_addr = {reg2hw.dst_addr_hi.q, reg2hw.dst_addr_lo.q} +
                    SYS_ADDR_WIDTH'(reg2hw.chunk_data_size.q);
    new_src_addr = {reg2hw.src_addr_hi.q, reg2hw.src_addr_lo.q} +
                    SYS_ADDR_WIDTH'(reg2hw.chunk_data_size.q);
    
    
    
    update_dst_addr_reg = 1'b0;
    update_src_addr_reg = 1'b0;
    if (data_move_state && (ctrl_state_d == DmaIdle)) begin
      if (reg2hw.src_config.increment.q == AddrNoIncrement &&
          reg2hw.src_config.wrap.q == AddrNoWrapChunk) begin
        update_src_addr_reg = 1'b1;
      end
      if (reg2hw.dst_config.increment.q == AddrNoIncrement &&
          reg2hw.dst_config.wrap.q == AddrNoWrapChunk) begin
        update_dst_addr_reg = 1'b1;
      end
    end
    hw2reg.dst_addr_hi.de = update_dst_addr_reg;
    hw2reg.dst_addr_hi.d  = new_dst_addr[63:32];
    hw2reg.dst_addr_lo.de = update_dst_addr_reg;
    hw2reg.dst_addr_lo.d  = new_dst_addr[31:0];
    hw2reg.src_addr_hi.de = update_src_addr_reg;
    hw2reg.src_addr_hi.d  = new_src_addr[63:32];
    hw2reg.src_addr_lo.de = update_src_addr_reg;
    hw2reg.src_addr_lo.d  = new_src_addr[31:0];
    hw2reg.control.initial_transfer.de = 1'b0;
    hw2reg.control.initial_transfer.d  = 1'b0;
    
    if ((ctrl_state_q == DmaIdle) && (ctrl_state_d != DmaIdle) &&
        reg2hw.control.initial_transfer.q) begin
      hw2reg.control.initial_transfer.de = 1'b1;
    end
    
    
    
    
    hw2reg.status.busy.de = ((ctrl_state_q == DmaIdle) && (ctrl_state_d != DmaIdle)) ||
                            clear_go                                                 ||
                            cfg_abort_en;
    
    hw2reg.status.busy.d  = ((ctrl_state_q == DmaIdle) && (ctrl_state_d != DmaIdle)) ? 1'b1 : 1'b0;
    
    clear_status = (ctrl_state_q == DmaIdle) && (ctrl_state_d != DmaIdle) && !reg2hw.status.busy.q;
    
    
    clear_sha_status = (ctrl_state_q == DmaIdle) && (ctrl_state_d != DmaIdle) &&
                       reg2hw.control.initial_transfer.q;
    
    
    hw2reg.status.done.de = ((!cfg_abort_en) && data_move_state && clear_go && ~chunk_done) |
                            clear_status;
    hw2reg.status.done.d  = clear_status? 1'b0 : 1'b1;
    hw2reg.status.error.de = (ctrl_state_d == DmaError) | clear_status;
    hw2reg.status.error.d  = clear_status? 1'b0 : 1'b1;
    hw2reg.status.aborted.de = cfg_abort_en | clear_status;
    hw2reg.status.aborted.d  = clear_status? 1'b0 : 1'b1;
    hw2reg.status.sha2_digest_valid.de = sha2_digest_set | clear_sha_status;
    hw2reg.status.sha2_digest_valid.d  = sha2_digest_set;
    hw2reg.status.chunk_done.de = ((!cfg_abort_en) && chunk_done) | clear_status;
    hw2reg.status.chunk_done.d  = clear_status? 1'b0 : 1'b1;
    
    
    
    
    
    
    for (int i = 0; i < NR_SHA_DIGEST_ELEMENTS; i++) begin
      hw2reg.sha2_digest[i].de = sha2_digest_set | clear_sha_status;
      hw2reg.sha2_digest[i].d  = '0;
    end
    
    
    
    
    if (sha2_digest_set) begin
      for (int unsigned i = 0; i < NR_SHA_DIGEST_ELEMENTS / 2; i++) begin
        unique case (control_q.opcode)
          OpcSha256: begin
            hw2reg.sha2_digest[i].d = conv_endian32(sha2_digest[i][0 +: 32],
                                                    control_q.cfg_digest_swap);
          end
          OpcSha384: begin
            if (i < 6) begin
              hw2reg.sha2_digest[i*2].d     = conv_endian32(sha2_digest[i][32 +: 32],
                                                            control_q.cfg_digest_swap);
              hw2reg.sha2_digest[(i*2)+1].d = conv_endian32(sha2_digest[i][0  +: 32],
                                                            control_q.cfg_digest_swap);
            end
          end
          default: begin 
            hw2reg.sha2_digest[i*2].d     = conv_endian32(sha2_digest[i][32 +: 32],
                                                          control_q.cfg_digest_swap);
            hw2reg.sha2_digest[(i*2)+1].d = conv_endian32(sha2_digest[i][0  +: 32],
                                                          control_q.cfg_digest_swap);
          end
        endcase
      end
    end
    
    set_error_code = (ctrl_state_q != DmaError) && (ctrl_state_d == DmaError);
    
    hw2reg.error_code.src_addr_error.de    = set_error_code | clear_status;
    hw2reg.error_code.dst_addr_error.de    = set_error_code | clear_status;
    hw2reg.error_code.opcode_error.de      = set_error_code | clear_status;
    hw2reg.error_code.size_error.de        = set_error_code | clear_status;
    hw2reg.error_code.bus_error.de         = set_error_code | clear_status;
    hw2reg.error_code.base_limit_error.de  = set_error_code | clear_status;
    hw2reg.error_code.range_valid_error.de = set_error_code | clear_status;
    hw2reg.error_code.asid_error.de        = set_error_code | clear_status;
    hw2reg.error_code.src_addr_error.d     = clear_status? '0 : next_error[DmaSrcAddrErr];
    hw2reg.error_code.dst_addr_error.d     = clear_status? '0 : next_error[DmaDstAddrErr];
    hw2reg.error_code.opcode_error.d       = clear_status? '0 : next_error[DmaOpcodeErr];
    hw2reg.error_code.size_error.d         = clear_status? '0 : next_error[DmaSizeErr];
    hw2reg.error_code.bus_error.d          = clear_status? '0 : next_error[DmaBusErr];
    hw2reg.error_code.base_limit_error.d   = clear_status? '0 : next_error[DmaBaseLimitErr];
    hw2reg.error_code.range_valid_error.d  = clear_status? '0 : next_error[DmaRangeValidErr];
    hw2reg.error_code.asid_error.d         = clear_status? '0 : next_error[DmaAsidErr];
    
    hw2reg.control.abort.de = hw2reg.status.aborted.de;
    hw2reg.control.abort.d  = 1'b0;
    
    if (reg2hw.status.sha2_digest_valid.qe & reg2hw.status.sha2_digest_valid.q) begin
      for (int i = 0; i < NR_SHA_DIGEST_ELEMENTS; i++) begin
        hw2reg.sha2_digest[i].de = 1'b0;
        hw2reg.sha2_digest[i].d  = '0;
      end
    end
    
    if (reg2hw.status.error.qe & reg2hw.status.error.q) begin
      
      hw2reg.error_code.src_addr_error.de = 1'b1;
      hw2reg.error_code.dst_addr_error.de = 1'b1;
      hw2reg.error_code.opcode_error.de      = 1'b1;
      hw2reg.error_code.size_error.de        = 1'b1;
      hw2reg.error_code.bus_error.de         = 1'b1;
      hw2reg.error_code.base_limit_error.de  = 1'b1;
      hw2reg.error_code.range_valid_error.de = 1'b1;
      hw2reg.error_code.asid_error.de        = 1'b1;
      hw2reg.error_code.src_addr_error.d  = 1'b0;
      hw2reg.error_code.dst_addr_error.d  = 1'b0;
      hw2reg.error_code.opcode_error.d       = 1'b0;
      hw2reg.error_code.size_error.d         = 1'b0;
      hw2reg.error_code.bus_error.d          = 1'b0;
      hw2reg.error_code.base_limit_error.d   = 1'b0;
      hw2reg.error_code.range_valid_error.d  = 1'b0;
      hw2reg.error_code.asid_error.d         = 1'b0;
    end
  end
  
  
  
  prim_flop #(
    .Width(SYS_NUM_REQ_CH)
  ) u_sys_vld_vec (
    .clk_i ( gated_clk         ),
    .rst_ni( rst_ni            ),
    .d_i   ( sys_req_d.vld_vec ),
    .q_o   ( sys_o.vld_vec     )
  );
  prim_flop_en #(
    .Width(SYS_METADATA_WIDTH)
  ) u_sys_metadata_write_vec (
    .clk_i ( gated_clk                           ),
    .rst_ni( rst_ni                              ),
    .en_i  ( sys_req_d.vld_vec[SysCmdWrite]      ),
    .d_i   ( sys_req_d.metadata_vec[SysCmdWrite] ),
    .q_o   ( sys_o.metadata_vec[SysCmdWrite]     )
  );
  prim_flop_en #(
    .Width($bits(sys_opc_e))
  ) u_sys_opcode_write_vec (
    .clk_i ( gated_clk                         ),
    .rst_ni( rst_ni                            ),
    .en_i  ( sys_req_d.vld_vec[SysCmdWrite]    ),
    .d_i   ( sys_req_d.opcode_vec[SysCmdWrite] ),
    .q_o   ( {sys_o.opcode_vec[SysCmdWrite]}   )
  );
  prim_flop_en #(
    .Width(SYS_ADDR_WIDTH)
  ) u_sys_iova_write_vec (
    .clk_i ( gated_clk                       ),
    .rst_ni( rst_ni                          ),
    .en_i  ( sys_req_d.vld_vec[SysCmdWrite]  ),
    .d_i   ( sys_req_d.iova_vec[SysCmdWrite] ),
    .q_o   ( sys_o.iova_vec[SysCmdWrite]     )
  );
  prim_flop_en #(
    .Width($bits(top_racl_pkg::racl_role_t))
  ) u_sys_racl_write_vec (
    .clk_i ( gated_clk                       ),
    .rst_ni( rst_ni                          ),
    .en_i  ( sys_req_d.vld_vec[SysCmdWrite]  ),
    .d_i   ( sys_req_d.racl_vec[SysCmdWrite] ),
    .q_o   ( sys_o.racl_vec[SysCmdWrite]     )
  );
  prim_flop_en #(
    .Width(SYS_METADATA_WIDTH)
  ) u_sys_metadata_read_vec (
    .clk_i ( gated_clk                          ),
    .rst_ni( rst_ni                             ),
    .en_i  ( sys_req_d.vld_vec[SysCmdRead]      ),
    .d_i   ( sys_req_d.metadata_vec[SysCmdRead] ),
    .q_o   ( sys_o.metadata_vec[SysCmdRead]     )
  );
  prim_flop_en #(
    .Width($bits(sys_opc_e))
  ) u_sys_opcode_read_vec (
    .clk_i ( gated_clk                        ),
    .rst_ni( rst_ni                           ),
    .en_i  ( sys_req_d.vld_vec[SysCmdRead]    ),
    .d_i   ( sys_req_d.opcode_vec[SysCmdRead] ),
    .q_o   ( {sys_o.opcode_vec[SysCmdRead]}   )
  );
  prim_flop_en #(
    .Width(SYS_ADDR_WIDTH)
  ) u_sys_iova_read_vec (
    .clk_i ( gated_clk                      ),
    .rst_ni( rst_ni                         ),
    .en_i  ( sys_req_d.vld_vec[SysCmdRead]  ),
    .d_i   ( sys_req_d.iova_vec[SysCmdRead] ),
    .q_o   ( sys_o.iova_vec[SysCmdRead]     )
  );
  prim_flop_en #(
    .Width($bits(top_racl_pkg::racl_role_t))
  ) u_sys_racl_read_vec (
    .clk_i ( gated_clk                      ),
    .rst_ni( rst_ni                         ),
    .en_i  ( sys_req_d.vld_vec[SysCmdRead]  ),
    .d_i   ( sys_req_d.racl_vec[SysCmdRead] ),
    .q_o   ( sys_o.racl_vec[SysCmdRead]     )
  );
  prim_flop_en #(
    .Width(SYS_DATA_WIDTH)
  ) u_sys_write_data (
    .clk_i ( gated_clk                      ),
    .rst_ni( rst_ni                         ),
    .en_i  ( sys_req_d.vld_vec[SysCmdWrite] ),
    .d_i   ( sys_req_d.write_data           ),
    .q_o   ( sys_o.write_data               )
  );
  prim_flop_en #(
    .Width(SYS_DATA_BYTEWIDTH)
  ) u_sys_write_be (
    .clk_i ( gated_clk                      ),
    .rst_ni( rst_ni                         ),
    .en_i  ( sys_req_d.vld_vec[SysCmdWrite] ),
    .d_i   ( sys_req_d.write_be             ),
    .q_o   ( sys_o.write_be                 )
  );
  prim_flop_en #(
    .Width(SYS_DATA_BYTEWIDTH)
  ) u_sys_read_be (
    .clk_i ( gated_clk                      ),
    .rst_ni( rst_ni                         ),
    .en_i  ( sys_req_d.vld_vec[SysCmdRead ] ),
    .d_i   ( sys_req_d.read_be              ),
    .q_o   ( sys_o.read_be                  )
  );
  prim_flop #(
    .Width(SYS_NUM_REQ_CH)
  ) u_sys_gnt_vec (
    .clk_i ( gated_clk            ),
    .rst_ni( rst_ni               ),
    .d_i   ( sys_i.grant_vec      ),
    .q_o   ( sys_resp_q.grant_vec )
  );
  prim_flop #(
    .Width(1)
  ) u_sys_read_data_valid (
    .clk_i ( gated_clk                ),
    .rst_ni( rst_ni                   ),
    .d_i   ( sys_i.read_data_vld      ),
    .q_o   ( sys_resp_q.read_data_vld )
  );
  prim_flop #(
    .Width(SYS_DATA_WIDTH)
  ) u_sys_read_data (
    .clk_i ( gated_clk            ),
    .rst_ni( rst_ni               ),
    .d_i   ( sys_i.read_data      ),
    .q_o   ( sys_resp_q.read_data )
  );
  prim_flop #(
    .Width(SYS_METADATA_WIDTH)
  ) u_sys_read_metadata (
    .clk_i ( gated_clk                ),
    .rst_ni( rst_ni                   ),
    .d_i   ( sys_i.read_metadata      ),
    .q_o   ( sys_resp_q.read_metadata )
  );
  prim_flop #(
    .Width(1)
  ) u_sys_read_error_valid (
    .clk_i ( gated_clk            ),
    .rst_ni( rst_ni               ),
    .d_i   ( sys_i.error_vld      ),
    .q_o   ( sys_resp_q.error_vld )
  );
  prim_flop #(
    .Width(SYS_NUM_ERROR_TYPES)
  ) u_sys_read_error (
    .clk_i ( gated_clk            ),
    .rst_ni( rst_ni               ),
    .d_i   ( sys_i.error_vec      ),
    .q_o   ( sys_resp_q.error_vec )
  );
  
  
  
  logic unused_signals;
  assign unused_signals = ^{reg2hw.enabled_memory_range_base.qe,
                            reg2hw.enabled_memory_range_limit.qe,
                            reg2hw.range_regwen.q,
                            sys_resp_q.error_vec,
                            sys_resp_q.read_metadata,
                            sys_resp_q.grant_vec[SysCmdRead]};
  
  
  
  
  `ASSERT_KNOWN(AlertsKnown_A, alert_tx_o)
  `ASSERT_KNOWN_IF(RaclErrorOKnown_A, racl_error_o, racl_error_o.valid)
  `ASSERT_KNOWN(IntrDmaDoneKnown_A, intr_dma_done_o)
  `ASSERT_KNOWN(IntrDmaChunkDoneKnown_A, intr_dma_chunk_done_o)
  `ASSERT_KNOWN(IntrDmaErrorKnown_A, intr_dma_error_o)
  `ASSERT_KNOWN(TlDValidKnownO_A, tl_d_o.d_valid)
  `ASSERT_KNOWN(TlAReadyKnownO_A, tl_d_o.a_ready)
  `ASSERT_KNOWN(CtnTlAValidKnownO_A, ctn_tl_h2d_o.a_valid)
  `ASSERT_KNOWN(CtnTlDReadyKnownO_A, ctn_tl_h2d_o.d_ready)
  `ASSERT_KNOWN(HostTlAValidKnownO_A, host_tl_h_o.a_valid)
  `ASSERT_KNOWN(HostTlDReadyKnownO_A, host_tl_h_o.d_ready)
  `ASSERT_KNOWN(SysValidKnownO_A, sys_o.vld_vec)
  
  `ASSERT_PRIM_REG_WE_ONEHOT_ERROR_TRIGGER_ALERT(RegWeOnehotCheck_A, u_dma_reg, alert_tx_o[0])
  
  
  `ASSERT_NEVER(LimitHandshakeTriggerWires_A, NumIntClearSources > 32)
  
  `ASSERT_NEVER(BeLengthMustBe4_A, top_pkg::TL_DBW != 4)
  
  `ASSERT_NEVER(NoDmaEnabledMemoryChangeAfterLock_A,
                prim_mubi_pkg::mubi4_test_false_loose(
                  prim_mubi_pkg::mubi4_t'(reg2hw.range_regwen.q)) &&
                  (reg2hw.enabled_memory_range_base.qe ||
                   reg2hw.enabled_memory_range_limit.qe))
  
  `ASSERT_PRIM_FSM_ERROR_TRIGGER_ALERT(CtrlStateFsmCheck_A, aff_ctrl_state_q, alert_tx_o[0])
endmodule

package dma_pkg;
  
  
  typedef logic [dma_reg_pkg::NumIntClearSources-1:0] lsio_trigger_t;
  
  typedef enum logic [4:0] {
    DmaSrcAddrErr,
    DmaDstAddrErr,
    DmaOpcodeErr,
    DmaSizeErr,
    DmaBusErr,
    DmaBaseLimitErr,
    DmaRangeValidErr,
    DmaAsidErr,
    DmaErrLast
  } dma_error_e;
  
  typedef enum logic [1:0] {
    DmaXfer1BperTxn = 2'h0,
    DmaXfer2BperTxn = 2'h1,
    DmaXfer4BperTxn = 2'h2
  } dma_transfer_width_e;
  
  parameter int unsigned ASID_WIDTH = 4;
  typedef enum logic [ASID_WIDTH-1:0] {
    OtInternalAddr = 4'h7,
    SocControlAddr = 4'ha,
    SocSystemAddr  = 4'h9
  } asid_encoding_e;
  
  typedef enum logic [3:0] {
    OpcCopy   = 4'h0,
    OpcSha256 = 4'h1,
    OpcSha384 = 4'h2,
    OpcSha512 = 4'h3
  } opcode_e;
  
  parameter bit AddrIncrement   = 1'b1;
  parameter bit AddrNoIncrement = 1'b0;
  parameter bit AddrWrapChunk   = 1'b1;
  parameter bit AddrNoWrapChunk = 1'b0;
  
  typedef struct packed {
    
    opcode_e    opcode;
    logic       cfg_handshake_en;
    logic       cfg_digest_swap;
    logic       range_valid;
    
    logic [31:0] enabled_memory_range_base;
    
    logic [31:0] enabled_memory_range_limit;
  } control_state_t;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  typedef enum logic [7:0] {
    DmaIdle                 = 8'b11110111,
    DmaClearIntrSrc         = 8'b10101100,
    DmaWaitIntrSrcResponse  = 8'b00101011,
    DmaAddrSetup            = 8'b11110000,
    DmaSendRead             = 8'b01000011,
    DmaWaitReadResponse     = 8'b00011111,
    DmaSendWrite            = 8'b10010100,
    DmaWaitWriteResponse    = 8'b11011001,
    DmaError                = 8'b01010110,
    DmaShaFinalize          = 8'b00110001,
    DmaShaWait              = 8'b01111010
  } dma_ctrl_state_e;
  
  parameter int unsigned NUM_MAX_OUTSTANDING_REQS = 1;
  
  
  
  parameter int unsigned SYS_NUM_REQ_CH      = 2;
  parameter int unsigned SYS_ADDR_WIDTH      = 64;
  parameter int unsigned SYS_METADATA_WIDTH  = 3;
  parameter int unsigned SYS_DATA_BYTEWIDTH  = 4;
  parameter int unsigned SYS_DATA_WIDTH      = SYS_DATA_BYTEWIDTH * 8;
  parameter int unsigned SYS_NUM_ERROR_TYPES = 1;
  
  typedef enum logic [2:0] {
    SysOpcRead            = 3'd0,
    SysOpcCmoClean        = 3'd1,
    SysOpcAtomicNoDataRsp = 3'd2,
    SysOpcAtomicDataRsp   = 3'd3,
    SysOpcWrite           = 3'd4,
    SysOpcWriteOrdered    = 3'd5,
    SysOpcMsgIntrReq      = 3'd6,
    SysOpcMsgP2P          = 3'd7
  } sys_opc_e;
  
  typedef enum logic {
    SysCmdRead  = 1'd0,
    SysCmdWrite = 1'd1
  } sys_cmd_type_e;
  
  typedef struct packed {
    logic                     [SYS_NUM_REQ_CH-1:0]                         vld_vec;
    logic                     [SYS_NUM_REQ_CH-1:0][SYS_METADATA_WIDTH-1:0] metadata_vec;
    sys_opc_e                 [SYS_NUM_REQ_CH-1:0]                         opcode_vec;
    logic                     [SYS_NUM_REQ_CH-1:0][SYS_ADDR_WIDTH-1:0]     iova_vec;
    top_racl_pkg::racl_role_t [SYS_NUM_REQ_CH-1:0]                         racl_vec;
    logic                     [SYS_DATA_WIDTH-1:0]                         write_data;
    logic                     [SYS_DATA_BYTEWIDTH-1:0]                     write_be;
    logic                     [SYS_DATA_BYTEWIDTH-1:0]                     read_be;
  } sys_req_t;
  
  typedef struct packed {
    logic [SYS_NUM_REQ_CH-1:0]         grant_vec;
    logic                              read_data_vld;
    logic [SYS_DATA_WIDTH-1:0]         read_data;
    logic [SYS_METADATA_WIDTH-1:0]     read_metadata;
    logic                              error_vld;
    logic [SYS_NUM_ERROR_TYPES-1:0]    error_vec;
  } sys_rsp_t;
  parameter sys_rsp_t SYS_RSP_DEFAULT = '0;
endpackage

package dma_reg_pkg;
  
  parameter int NumIntClearSources = 11;
  parameter int NumAlerts = 1;
  
  parameter int BlockAw = 9;
  
  parameter int NumRegs = 63;
  
  typedef enum int {
    AlertFatalFaultIdx = 0
  } dma_alert_idx_t;
  
  
  
  typedef struct packed {
    struct packed {
      logic        q;
    } dma_error;
    struct packed {
      logic        q;
    } dma_chunk_done;
    struct packed {
      logic        q;
    } dma_done;
  } dma_reg2hw_intr_state_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } dma_error;
    struct packed {
      logic        q;
    } dma_chunk_done;
    struct packed {
      logic        q;
    } dma_done;
  } dma_reg2hw_intr_enable_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } dma_error;
    struct packed {
      logic        q;
      logic        qe;
    } dma_chunk_done;
    struct packed {
      logic        q;
      logic        qe;
    } dma_done;
  } dma_reg2hw_intr_test_reg_t;
  typedef struct packed {
    logic        q;
    logic        qe;
  } dma_reg2hw_alert_test_reg_t;
  typedef struct packed {
    logic [31:0] q;
  } dma_reg2hw_src_addr_lo_reg_t;
  typedef struct packed {
    logic [31:0] q;
  } dma_reg2hw_src_addr_hi_reg_t;
  typedef struct packed {
    logic [31:0] q;
  } dma_reg2hw_dst_addr_lo_reg_t;
  typedef struct packed {
    logic [31:0] q;
  } dma_reg2hw_dst_addr_hi_reg_t;
  typedef struct packed {
    struct packed {
      logic [3:0]  q;
    } dst_asid;
    struct packed {
      logic [3:0]  q;
    } src_asid;
  } dma_reg2hw_addr_space_id_reg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } dma_reg2hw_enabled_memory_range_base_reg_t;
  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } dma_reg2hw_enabled_memory_range_limit_reg_t;
  typedef struct packed {
    logic        q;
  } dma_reg2hw_range_valid_reg_t;
  typedef struct packed {
    logic [3:0]  q;
  } dma_reg2hw_range_regwen_reg_t;
  typedef struct packed {
    logic [31:0] q;
  } dma_reg2hw_total_data_size_reg_t;
  typedef struct packed {
    logic [31:0] q;
  } dma_reg2hw_chunk_data_size_reg_t;
  typedef struct packed {
    logic [1:0]  q;
  } dma_reg2hw_transfer_width_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } go;
    struct packed {
      logic        q;
    } abort;
    struct packed {
      logic        q;
    } initial_transfer;
    struct packed {
      logic        q;
    } digest_swap;
    struct packed {
      logic        q;
    } hardware_handshake_enable;
    struct packed {
      logic [3:0]  q;
    } opcode;
  } dma_reg2hw_control_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } wrap;
    struct packed {
      logic        q;
    } increment;
  } dma_reg2hw_src_config_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } wrap;
    struct packed {
      logic        q;
    } increment;
  } dma_reg2hw_dst_config_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } chunk_done;
    struct packed {
      logic        q;
      logic        qe;
    } sha2_digest_valid;
    struct packed {
      logic        q;
      logic        qe;
    } error;
    struct packed {
      logic        q;
    } done;
    struct packed {
      logic        q;
    } busy;
  } dma_reg2hw_status_reg_t;
  typedef struct packed {
    logic [10:0] q;
  } dma_reg2hw_handshake_intr_enable_reg_t;
  typedef struct packed {
    logic [10:0] q;
  } dma_reg2hw_clear_intr_src_reg_t;
  typedef struct packed {
    logic [10:0] q;
  } dma_reg2hw_clear_intr_bus_reg_t;
  typedef struct packed {
    logic [31:0] q;
  } dma_reg2hw_intr_src_addr_mreg_t;
  typedef struct packed {
    logic [31:0] q;
  } dma_reg2hw_intr_src_wr_val_mreg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } dma_error;
    struct packed {
      logic        d;
      logic        de;
    } dma_chunk_done;
    struct packed {
      logic        d;
      logic        de;
    } dma_done;
  } dma_hw2reg_intr_state_reg_t;
  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } dma_hw2reg_src_addr_lo_reg_t;
  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } dma_hw2reg_src_addr_hi_reg_t;
  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } dma_hw2reg_dst_addr_lo_reg_t;
  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } dma_hw2reg_dst_addr_hi_reg_t;
  typedef struct packed {
    logic [3:0]  d;
  } dma_hw2reg_cfg_regwen_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } go;
    struct packed {
      logic        d;
      logic        de;
    } abort;
    struct packed {
      logic        d;
      logic        de;
    } initial_transfer;
  } dma_hw2reg_control_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } chunk_done;
    struct packed {
      logic        d;
      logic        de;
    } sha2_digest_valid;
    struct packed {
      logic        d;
      logic        de;
    } error;
    struct packed {
      logic        d;
      logic        de;
    } aborted;
    struct packed {
      logic        d;
      logic        de;
    } done;
    struct packed {
      logic        d;
      logic        de;
    } busy;
  } dma_hw2reg_status_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } asid_error;
    struct packed {
      logic        d;
      logic        de;
    } range_valid_error;
    struct packed {
      logic        d;
      logic        de;
    } base_limit_error;
    struct packed {
      logic        d;
      logic        de;
    } bus_error;
    struct packed {
      logic        d;
      logic        de;
    } size_error;
    struct packed {
      logic        d;
      logic        de;
    } opcode_error;
    struct packed {
      logic        d;
      logic        de;
    } dst_addr_error;
    struct packed {
      logic        d;
      logic        de;
    } src_addr_error;
  } dma_hw2reg_error_code_reg_t;
  typedef struct packed {
    logic [31:0] d;
    logic        de;
  } dma_hw2reg_sha2_digest_mreg_t;
  
  typedef struct packed {
    dma_reg2hw_intr_state_reg_t intr_state; 
    dma_reg2hw_intr_enable_reg_t intr_enable; 
    dma_reg2hw_intr_test_reg_t intr_test; 
    dma_reg2hw_alert_test_reg_t alert_test; 
    dma_reg2hw_src_addr_lo_reg_t src_addr_lo; 
    dma_reg2hw_src_addr_hi_reg_t src_addr_hi; 
    dma_reg2hw_dst_addr_lo_reg_t dst_addr_lo; 
    dma_reg2hw_dst_addr_hi_reg_t dst_addr_hi; 
    dma_reg2hw_addr_space_id_reg_t addr_space_id; 
    dma_reg2hw_enabled_memory_range_base_reg_t enabled_memory_range_base; 
    dma_reg2hw_enabled_memory_range_limit_reg_t enabled_memory_range_limit; 
    dma_reg2hw_range_valid_reg_t range_valid; 
    dma_reg2hw_range_regwen_reg_t range_regwen; 
    dma_reg2hw_total_data_size_reg_t total_data_size; 
    dma_reg2hw_chunk_data_size_reg_t chunk_data_size; 
    dma_reg2hw_transfer_width_reg_t transfer_width; 
    dma_reg2hw_control_reg_t control; 
    dma_reg2hw_src_config_reg_t src_config; 
    dma_reg2hw_dst_config_reg_t dst_config; 
    dma_reg2hw_status_reg_t status; 
    dma_reg2hw_handshake_intr_enable_reg_t handshake_intr_enable; 
    dma_reg2hw_clear_intr_src_reg_t clear_intr_src; 
    dma_reg2hw_clear_intr_bus_reg_t clear_intr_bus; 
    dma_reg2hw_intr_src_addr_mreg_t [10:0] intr_src_addr; 
    dma_reg2hw_intr_src_wr_val_mreg_t [10:0] intr_src_wr_val; 
  } dma_reg2hw_t;
  
  typedef struct packed {
    dma_hw2reg_intr_state_reg_t intr_state; 
    dma_hw2reg_src_addr_lo_reg_t src_addr_lo; 
    dma_hw2reg_src_addr_hi_reg_t src_addr_hi; 
    dma_hw2reg_dst_addr_lo_reg_t dst_addr_lo; 
    dma_hw2reg_dst_addr_hi_reg_t dst_addr_hi; 
    dma_hw2reg_cfg_regwen_reg_t cfg_regwen; 
    dma_hw2reg_control_reg_t control; 
    dma_hw2reg_status_reg_t status; 
    dma_hw2reg_error_code_reg_t error_code; 
    dma_hw2reg_sha2_digest_mreg_t [15:0] sha2_digest; 
  } dma_hw2reg_t;
  
  parameter logic [BlockAw-1:0] DMA_INTR_STATE_OFFSET = 9'h 0;
  parameter logic [BlockAw-1:0] DMA_INTR_ENABLE_OFFSET = 9'h 4;
  parameter logic [BlockAw-1:0] DMA_INTR_TEST_OFFSET = 9'h 8;
  parameter logic [BlockAw-1:0] DMA_ALERT_TEST_OFFSET = 9'h c;
  parameter logic [BlockAw-1:0] DMA_SRC_ADDR_LO_OFFSET = 9'h 10;
  parameter logic [BlockAw-1:0] DMA_SRC_ADDR_HI_OFFSET = 9'h 14;
  parameter logic [BlockAw-1:0] DMA_DST_ADDR_LO_OFFSET = 9'h 18;
  parameter logic [BlockAw-1:0] DMA_DST_ADDR_HI_OFFSET = 9'h 1c;
  parameter logic [BlockAw-1:0] DMA_ADDR_SPACE_ID_OFFSET = 9'h 20;
  parameter logic [BlockAw-1:0] DMA_ENABLED_MEMORY_RANGE_BASE_OFFSET = 9'h 24;
  parameter logic [BlockAw-1:0] DMA_ENABLED_MEMORY_RANGE_LIMIT_OFFSET = 9'h 28;
  parameter logic [BlockAw-1:0] DMA_RANGE_VALID_OFFSET = 9'h 2c;
  parameter logic [BlockAw-1:0] DMA_RANGE_REGWEN_OFFSET = 9'h 30;
  parameter logic [BlockAw-1:0] DMA_CFG_REGWEN_OFFSET = 9'h 34;
  parameter logic [BlockAw-1:0] DMA_TOTAL_DATA_SIZE_OFFSET = 9'h 38;
  parameter logic [BlockAw-1:0] DMA_CHUNK_DATA_SIZE_OFFSET = 9'h 3c;
  parameter logic [BlockAw-1:0] DMA_TRANSFER_WIDTH_OFFSET = 9'h 40;
  parameter logic [BlockAw-1:0] DMA_CONTROL_OFFSET = 9'h 44;
  parameter logic [BlockAw-1:0] DMA_SRC_CONFIG_OFFSET = 9'h 48;
  parameter logic [BlockAw-1:0] DMA_DST_CONFIG_OFFSET = 9'h 4c;
  parameter logic [BlockAw-1:0] DMA_STATUS_OFFSET = 9'h 50;
  parameter logic [BlockAw-1:0] DMA_ERROR_CODE_OFFSET = 9'h 54;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_0_OFFSET = 9'h 58;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_1_OFFSET = 9'h 5c;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_2_OFFSET = 9'h 60;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_3_OFFSET = 9'h 64;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_4_OFFSET = 9'h 68;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_5_OFFSET = 9'h 6c;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_6_OFFSET = 9'h 70;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_7_OFFSET = 9'h 74;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_8_OFFSET = 9'h 78;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_9_OFFSET = 9'h 7c;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_10_OFFSET = 9'h 80;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_11_OFFSET = 9'h 84;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_12_OFFSET = 9'h 88;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_13_OFFSET = 9'h 8c;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_14_OFFSET = 9'h 90;
  parameter logic [BlockAw-1:0] DMA_SHA2_DIGEST_15_OFFSET = 9'h 94;
  parameter logic [BlockAw-1:0] DMA_HANDSHAKE_INTR_ENABLE_OFFSET = 9'h 98;
  parameter logic [BlockAw-1:0] DMA_CLEAR_INTR_SRC_OFFSET = 9'h 9c;
  parameter logic [BlockAw-1:0] DMA_CLEAR_INTR_BUS_OFFSET = 9'h a0;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_ADDR_0_OFFSET = 9'h a4;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_ADDR_1_OFFSET = 9'h a8;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_ADDR_2_OFFSET = 9'h ac;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_ADDR_3_OFFSET = 9'h b0;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_ADDR_4_OFFSET = 9'h b4;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_ADDR_5_OFFSET = 9'h b8;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_ADDR_6_OFFSET = 9'h bc;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_ADDR_7_OFFSET = 9'h c0;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_ADDR_8_OFFSET = 9'h c4;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_ADDR_9_OFFSET = 9'h c8;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_ADDR_10_OFFSET = 9'h cc;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_WR_VAL_0_OFFSET = 9'h 124;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_WR_VAL_1_OFFSET = 9'h 128;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_WR_VAL_2_OFFSET = 9'h 12c;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_WR_VAL_3_OFFSET = 9'h 130;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_WR_VAL_4_OFFSET = 9'h 134;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_WR_VAL_5_OFFSET = 9'h 138;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_WR_VAL_6_OFFSET = 9'h 13c;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_WR_VAL_7_OFFSET = 9'h 140;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_WR_VAL_8_OFFSET = 9'h 144;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_WR_VAL_9_OFFSET = 9'h 148;
  parameter logic [BlockAw-1:0] DMA_INTR_SRC_WR_VAL_10_OFFSET = 9'h 14c;
  
  parameter logic [2:0] DMA_INTR_TEST_RESVAL = 3'h 0;
  parameter logic [0:0] DMA_INTR_TEST_DMA_DONE_RESVAL = 1'h 0;
  parameter logic [0:0] DMA_INTR_TEST_DMA_CHUNK_DONE_RESVAL = 1'h 0;
  parameter logic [0:0] DMA_INTR_TEST_DMA_ERROR_RESVAL = 1'h 0;
  parameter logic [0:0] DMA_ALERT_TEST_RESVAL = 1'h 0;
  parameter logic [0:0] DMA_ALERT_TEST_FATAL_FAULT_RESVAL = 1'h 0;
  parameter logic [3:0] DMA_CFG_REGWEN_RESVAL = 4'h 6;
  parameter logic [3:0] DMA_CFG_REGWEN_REGWEN_RESVAL = 4'h 6;
  
  typedef enum int {
    DMA_INTR_STATE,
    DMA_INTR_ENABLE,
    DMA_INTR_TEST,
    DMA_ALERT_TEST,
    DMA_SRC_ADDR_LO,
    DMA_SRC_ADDR_HI,
    DMA_DST_ADDR_LO,
    DMA_DST_ADDR_HI,
    DMA_ADDR_SPACE_ID,
    DMA_ENABLED_MEMORY_RANGE_BASE,
    DMA_ENABLED_MEMORY_RANGE_LIMIT,
    DMA_RANGE_VALID,
    DMA_RANGE_REGWEN,
    DMA_CFG_REGWEN,
    DMA_TOTAL_DATA_SIZE,
    DMA_CHUNK_DATA_SIZE,
    DMA_TRANSFER_WIDTH,
    DMA_CONTROL,
    DMA_SRC_CONFIG,
    DMA_DST_CONFIG,
    DMA_STATUS,
    DMA_ERROR_CODE,
    DMA_SHA2_DIGEST_0,
    DMA_SHA2_DIGEST_1,
    DMA_SHA2_DIGEST_2,
    DMA_SHA2_DIGEST_3,
    DMA_SHA2_DIGEST_4,
    DMA_SHA2_DIGEST_5,
    DMA_SHA2_DIGEST_6,
    DMA_SHA2_DIGEST_7,
    DMA_SHA2_DIGEST_8,
    DMA_SHA2_DIGEST_9,
    DMA_SHA2_DIGEST_10,
    DMA_SHA2_DIGEST_11,
    DMA_SHA2_DIGEST_12,
    DMA_SHA2_DIGEST_13,
    DMA_SHA2_DIGEST_14,
    DMA_SHA2_DIGEST_15,
    DMA_HANDSHAKE_INTR_ENABLE,
    DMA_CLEAR_INTR_SRC,
    DMA_CLEAR_INTR_BUS,
    DMA_INTR_SRC_ADDR_0,
    DMA_INTR_SRC_ADDR_1,
    DMA_INTR_SRC_ADDR_2,
    DMA_INTR_SRC_ADDR_3,
    DMA_INTR_SRC_ADDR_4,
    DMA_INTR_SRC_ADDR_5,
    DMA_INTR_SRC_ADDR_6,
    DMA_INTR_SRC_ADDR_7,
    DMA_INTR_SRC_ADDR_8,
    DMA_INTR_SRC_ADDR_9,
    DMA_INTR_SRC_ADDR_10,
    DMA_INTR_SRC_WR_VAL_0,
    DMA_INTR_SRC_WR_VAL_1,
    DMA_INTR_SRC_WR_VAL_2,
    DMA_INTR_SRC_WR_VAL_3,
    DMA_INTR_SRC_WR_VAL_4,
    DMA_INTR_SRC_WR_VAL_5,
    DMA_INTR_SRC_WR_VAL_6,
    DMA_INTR_SRC_WR_VAL_7,
    DMA_INTR_SRC_WR_VAL_8,
    DMA_INTR_SRC_WR_VAL_9,
    DMA_INTR_SRC_WR_VAL_10
  } dma_id_e;
  
  parameter logic [3:0] DMA_PERMIT [63] = '{
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 0001, 
    4'b 1111, 
    4'b 1111, 
    4'b 0001, 
    4'b 0001, 
    4'b 0001, 
    4'b 1111, 
    4'b 1111, 
    4'b 0001, 
    4'b 1111, 
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
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 1111, 
    4'b 0011, 
    4'b 0011, 
    4'b 0011, 
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
    4'b 1111  
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
module dma_reg_top
  # (
    parameter bit          EnableRacl           = 1'b0,
    parameter bit          RaclErrorRsp         = 1'b1,
    parameter top_racl_pkg::racl_policy_sel_t RaclPolicySelVec[dma_reg_pkg::NumRegs] =
      '{dma_reg_pkg::NumRegs{0}}
  ) (
  input clk_i,
  input rst_ni,
  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,
  
  output dma_reg_pkg::dma_reg2hw_t reg2hw, 
  input  dma_reg_pkg::dma_hw2reg_t hw2reg, 
  
  input  top_racl_pkg::racl_policy_vec_t racl_policies_i,
  output top_racl_pkg::racl_error_log_t  racl_error_o,
  
  output logic intg_err_o
);
  import dma_reg_pkg::* ;
  localparam int AW = 9;
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
  logic [62:0] reg_we_check;
  prim_reg_we_check #(
    .OneHotWidth(63)
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
    
    .error_i (reg_error | (RaclErrorRsp & racl_error_o.valid))
  );
  
  assign reg_rdata = reg_rdata_next ;
  assign reg_error = addrmiss | wr_err | intg_err;
  
  
  
  logic intr_state_dma_done_qs;
  logic intr_state_dma_chunk_done_qs;
  logic intr_state_dma_error_qs;
  logic intr_enable_we;
  logic intr_enable_dma_done_qs;
  logic intr_enable_dma_done_wd;
  logic intr_enable_dma_chunk_done_qs;
  logic intr_enable_dma_chunk_done_wd;
  logic intr_enable_dma_error_qs;
  logic intr_enable_dma_error_wd;
  logic intr_test_we;
  logic intr_test_dma_done_wd;
  logic intr_test_dma_chunk_done_wd;
  logic intr_test_dma_error_wd;
  logic alert_test_we;
  logic alert_test_wd;
  logic src_addr_lo_we;
  logic [31:0] src_addr_lo_qs;
  logic [31:0] src_addr_lo_wd;
  logic src_addr_hi_we;
  logic [31:0] src_addr_hi_qs;
  logic [31:0] src_addr_hi_wd;
  logic dst_addr_lo_we;
  logic [31:0] dst_addr_lo_qs;
  logic [31:0] dst_addr_lo_wd;
  logic dst_addr_hi_we;
  logic [31:0] dst_addr_hi_qs;
  logic [31:0] dst_addr_hi_wd;
  logic addr_space_id_we;
  logic [3:0] addr_space_id_src_asid_qs;
  logic [3:0] addr_space_id_src_asid_wd;
  logic [3:0] addr_space_id_dst_asid_qs;
  logic [3:0] addr_space_id_dst_asid_wd;
  logic enabled_memory_range_base_we;
  logic [31:0] enabled_memory_range_base_qs;
  logic [31:0] enabled_memory_range_base_wd;
  logic enabled_memory_range_limit_we;
  logic [31:0] enabled_memory_range_limit_qs;
  logic [31:0] enabled_memory_range_limit_wd;
  logic range_valid_we;
  logic range_valid_qs;
  logic range_valid_wd;
  logic range_regwen_we;
  logic [3:0] range_regwen_qs;
  logic [3:0] range_regwen_wd;
  logic cfg_regwen_re;
  logic [3:0] cfg_regwen_qs;
  logic total_data_size_we;
  logic [31:0] total_data_size_qs;
  logic [31:0] total_data_size_wd;
  logic chunk_data_size_we;
  logic [31:0] chunk_data_size_qs;
  logic [31:0] chunk_data_size_wd;
  logic transfer_width_we;
  logic [1:0] transfer_width_qs;
  logic [1:0] transfer_width_wd;
  logic control_we;
  logic [3:0] control_opcode_qs;
  logic [3:0] control_opcode_wd;
  logic control_hardware_handshake_enable_qs;
  logic control_hardware_handshake_enable_wd;
  logic control_digest_swap_qs;
  logic control_digest_swap_wd;
  logic control_initial_transfer_qs;
  logic control_initial_transfer_wd;
  logic control_abort_wd;
  logic control_go_qs;
  logic control_go_wd;
  logic src_config_we;
  logic src_config_increment_qs;
  logic src_config_increment_wd;
  logic src_config_wrap_qs;
  logic src_config_wrap_wd;
  logic dst_config_we;
  logic dst_config_increment_qs;
  logic dst_config_increment_wd;
  logic dst_config_wrap_qs;
  logic dst_config_wrap_wd;
  logic status_we;
  logic status_busy_qs;
  logic status_done_qs;
  logic status_done_wd;
  logic status_aborted_qs;
  logic status_aborted_wd;
  logic status_error_qs;
  logic status_error_wd;
  logic status_sha2_digest_valid_qs;
  logic status_chunk_done_qs;
  logic status_chunk_done_wd;
  logic error_code_src_addr_error_qs;
  logic error_code_dst_addr_error_qs;
  logic error_code_opcode_error_qs;
  logic error_code_size_error_qs;
  logic error_code_bus_error_qs;
  logic error_code_base_limit_error_qs;
  logic error_code_range_valid_error_qs;
  logic error_code_asid_error_qs;
  logic [31:0] sha2_digest_0_qs;
  logic [31:0] sha2_digest_1_qs;
  logic [31:0] sha2_digest_2_qs;
  logic [31:0] sha2_digest_3_qs;
  logic [31:0] sha2_digest_4_qs;
  logic [31:0] sha2_digest_5_qs;
  logic [31:0] sha2_digest_6_qs;
  logic [31:0] sha2_digest_7_qs;
  logic [31:0] sha2_digest_8_qs;
  logic [31:0] sha2_digest_9_qs;
  logic [31:0] sha2_digest_10_qs;
  logic [31:0] sha2_digest_11_qs;
  logic [31:0] sha2_digest_12_qs;
  logic [31:0] sha2_digest_13_qs;
  logic [31:0] sha2_digest_14_qs;
  logic [31:0] sha2_digest_15_qs;
  logic handshake_intr_enable_we;
  logic [10:0] handshake_intr_enable_qs;
  logic [10:0] handshake_intr_enable_wd;
  logic clear_intr_src_we;
  logic [10:0] clear_intr_src_qs;
  logic [10:0] clear_intr_src_wd;
  logic clear_intr_bus_we;
  logic [10:0] clear_intr_bus_qs;
  logic [10:0] clear_intr_bus_wd;
  logic intr_src_addr_0_we;
  logic [31:0] intr_src_addr_0_qs;
  logic [31:0] intr_src_addr_0_wd;
  logic intr_src_addr_1_we;
  logic [31:0] intr_src_addr_1_qs;
  logic [31:0] intr_src_addr_1_wd;
  logic intr_src_addr_2_we;
  logic [31:0] intr_src_addr_2_qs;
  logic [31:0] intr_src_addr_2_wd;
  logic intr_src_addr_3_we;
  logic [31:0] intr_src_addr_3_qs;
  logic [31:0] intr_src_addr_3_wd;
  logic intr_src_addr_4_we;
  logic [31:0] intr_src_addr_4_qs;
  logic [31:0] intr_src_addr_4_wd;
  logic intr_src_addr_5_we;
  logic [31:0] intr_src_addr_5_qs;
  logic [31:0] intr_src_addr_5_wd;
  logic intr_src_addr_6_we;
  logic [31:0] intr_src_addr_6_qs;
  logic [31:0] intr_src_addr_6_wd;
  logic intr_src_addr_7_we;
  logic [31:0] intr_src_addr_7_qs;
  logic [31:0] intr_src_addr_7_wd;
  logic intr_src_addr_8_we;
  logic [31:0] intr_src_addr_8_qs;
  logic [31:0] intr_src_addr_8_wd;
  logic intr_src_addr_9_we;
  logic [31:0] intr_src_addr_9_qs;
  logic [31:0] intr_src_addr_9_wd;
  logic intr_src_addr_10_we;
  logic [31:0] intr_src_addr_10_qs;
  logic [31:0] intr_src_addr_10_wd;
  logic intr_src_wr_val_0_we;
  logic [31:0] intr_src_wr_val_0_qs;
  logic [31:0] intr_src_wr_val_0_wd;
  logic intr_src_wr_val_1_we;
  logic [31:0] intr_src_wr_val_1_qs;
  logic [31:0] intr_src_wr_val_1_wd;
  logic intr_src_wr_val_2_we;
  logic [31:0] intr_src_wr_val_2_qs;
  logic [31:0] intr_src_wr_val_2_wd;
  logic intr_src_wr_val_3_we;
  logic [31:0] intr_src_wr_val_3_qs;
  logic [31:0] intr_src_wr_val_3_wd;
  logic intr_src_wr_val_4_we;
  logic [31:0] intr_src_wr_val_4_qs;
  logic [31:0] intr_src_wr_val_4_wd;
  logic intr_src_wr_val_5_we;
  logic [31:0] intr_src_wr_val_5_qs;
  logic [31:0] intr_src_wr_val_5_wd;
  logic intr_src_wr_val_6_we;
  logic [31:0] intr_src_wr_val_6_qs;
  logic [31:0] intr_src_wr_val_6_wd;
  logic intr_src_wr_val_7_we;
  logic [31:0] intr_src_wr_val_7_qs;
  logic [31:0] intr_src_wr_val_7_wd;
  logic intr_src_wr_val_8_we;
  logic [31:0] intr_src_wr_val_8_qs;
  logic [31:0] intr_src_wr_val_8_wd;
  logic intr_src_wr_val_9_we;
  logic [31:0] intr_src_wr_val_9_qs;
  logic [31:0] intr_src_wr_val_9_wd;
  logic intr_src_wr_val_10_we;
  logic [31:0] intr_src_wr_val_10_qs;
  logic [31:0] intr_src_wr_val_10_wd;
  
  
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_state_dma_done (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.intr_state.dma_done.de),
    .d      (hw2reg.intr_state.dma_done.d),
    
    .qe     (),
    .q      (reg2hw.intr_state.dma_done.q),
    .ds     (),
    
    .qs     (intr_state_dma_done_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_state_dma_chunk_done (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.intr_state.dma_chunk_done.de),
    .d      (hw2reg.intr_state.dma_chunk_done.d),
    
    .qe     (),
    .q      (reg2hw.intr_state.dma_chunk_done.q),
    .ds     (),
    
    .qs     (intr_state_dma_chunk_done_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_state_dma_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.intr_state.dma_error.de),
    .d      (hw2reg.intr_state.dma_error.d),
    
    .qe     (),
    .q      (reg2hw.intr_state.dma_error.q),
    .ds     (),
    
    .qs     (intr_state_dma_error_qs)
  );
  
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_enable_dma_done (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_enable_we),
    .wd     (intr_enable_dma_done_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_enable.dma_done.q),
    .ds     (),
    
    .qs     (intr_enable_dma_done_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_enable_dma_chunk_done (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_enable_we),
    .wd     (intr_enable_dma_chunk_done_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_enable.dma_chunk_done.q),
    .ds     (),
    
    .qs     (intr_enable_dma_chunk_done_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_intr_enable_dma_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_enable_we),
    .wd     (intr_enable_dma_error_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_enable.dma_error.q),
    .ds     (),
    
    .qs     (intr_enable_dma_error_qs)
  );
  
  logic intr_test_qe;
  logic [2:0] intr_test_flds_we;
  assign intr_test_qe = &intr_test_flds_we;
  
  prim_subreg_ext #(
    .DW    (1)
  ) u_intr_test_dma_done (
    .re     (1'b0),
    .we     (intr_test_we),
    .wd     (intr_test_dma_done_wd),
    .d      ('0),
    .qre    (),
    .qe     (intr_test_flds_we[0]),
    .q      (reg2hw.intr_test.dma_done.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.intr_test.dma_done.qe = intr_test_qe;
  
  prim_subreg_ext #(
    .DW    (1)
  ) u_intr_test_dma_chunk_done (
    .re     (1'b0),
    .we     (intr_test_we),
    .wd     (intr_test_dma_chunk_done_wd),
    .d      ('0),
    .qre    (),
    .qe     (intr_test_flds_we[1]),
    .q      (reg2hw.intr_test.dma_chunk_done.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.intr_test.dma_chunk_done.qe = intr_test_qe;
  
  prim_subreg_ext #(
    .DW    (1)
  ) u_intr_test_dma_error (
    .re     (1'b0),
    .we     (intr_test_we),
    .wd     (intr_test_dma_error_wd),
    .d      ('0),
    .qre    (),
    .qe     (intr_test_flds_we[2]),
    .q      (reg2hw.intr_test.dma_error.q),
    .ds     (),
    .qs     ()
  );
  assign reg2hw.intr_test.dma_error.qe = intr_test_qe;
  
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
  
  
  logic src_addr_lo_gated_we;
  assign src_addr_lo_gated_we =
    src_addr_lo_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_src_addr_lo (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (src_addr_lo_gated_we),
    .wd     (src_addr_lo_wd),
    
    .de     (hw2reg.src_addr_lo.de),
    .d      (hw2reg.src_addr_lo.d),
    
    .qe     (),
    .q      (reg2hw.src_addr_lo.q),
    .ds     (),
    
    .qs     (src_addr_lo_qs)
  );
  
  
  logic src_addr_hi_gated_we;
  assign src_addr_hi_gated_we =
    src_addr_hi_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_src_addr_hi (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (src_addr_hi_gated_we),
    .wd     (src_addr_hi_wd),
    
    .de     (hw2reg.src_addr_hi.de),
    .d      (hw2reg.src_addr_hi.d),
    
    .qe     (),
    .q      (reg2hw.src_addr_hi.q),
    .ds     (),
    
    .qs     (src_addr_hi_qs)
  );
  
  
  logic dst_addr_lo_gated_we;
  assign dst_addr_lo_gated_we =
    dst_addr_lo_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_dst_addr_lo (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (dst_addr_lo_gated_we),
    .wd     (dst_addr_lo_wd),
    
    .de     (hw2reg.dst_addr_lo.de),
    .d      (hw2reg.dst_addr_lo.d),
    
    .qe     (),
    .q      (reg2hw.dst_addr_lo.q),
    .ds     (),
    
    .qs     (dst_addr_lo_qs)
  );
  
  
  logic dst_addr_hi_gated_we;
  assign dst_addr_hi_gated_we =
    dst_addr_hi_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_dst_addr_hi (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (dst_addr_hi_gated_we),
    .wd     (dst_addr_hi_wd),
    
    .de     (hw2reg.dst_addr_hi.de),
    .d      (hw2reg.dst_addr_hi.d),
    
    .qe     (),
    .q      (reg2hw.dst_addr_hi.q),
    .ds     (),
    
    .qs     (dst_addr_hi_qs)
  );
  
  
  logic addr_space_id_gated_we;
  assign addr_space_id_gated_we =
    addr_space_id_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  
  prim_subreg #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (4'h7),
    .Mubi    (1'b0)
  ) u_addr_space_id_src_asid (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (addr_space_id_gated_we),
    .wd     (addr_space_id_src_asid_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.addr_space_id.src_asid.q),
    .ds     (),
    
    .qs     (addr_space_id_src_asid_qs)
  );
  
  prim_subreg #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (4'h7),
    .Mubi    (1'b0)
  ) u_addr_space_id_dst_asid (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (addr_space_id_gated_we),
    .wd     (addr_space_id_dst_asid_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.addr_space_id.dst_asid.q),
    .ds     (),
    
    .qs     (addr_space_id_dst_asid_qs)
  );
  
  logic enabled_memory_range_base_qe;
  logic [0:0] enabled_memory_range_base_flds_we;
  prim_flop #(
    .Width(1),
    .ResetValue(0)
  ) u_enabled_memory_range_base0_qe (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .d_i(&enabled_memory_range_base_flds_we),
    .q_o(enabled_memory_range_base_qe)
  );
  
  logic enabled_memory_range_base_gated_we;
  assign enabled_memory_range_base_gated_we =
    enabled_memory_range_base_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(range_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_enabled_memory_range_base (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (enabled_memory_range_base_gated_we),
    .wd     (enabled_memory_range_base_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (enabled_memory_range_base_flds_we[0]),
    .q      (reg2hw.enabled_memory_range_base.q),
    .ds     (),
    
    .qs     (enabled_memory_range_base_qs)
  );
  assign reg2hw.enabled_memory_range_base.qe = enabled_memory_range_base_qe;
  
  logic enabled_memory_range_limit_qe;
  logic [0:0] enabled_memory_range_limit_flds_we;
  prim_flop #(
    .Width(1),
    .ResetValue(0)
  ) u_enabled_memory_range_limit0_qe (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .d_i(&enabled_memory_range_limit_flds_we),
    .q_o(enabled_memory_range_limit_qe)
  );
  
  logic enabled_memory_range_limit_gated_we;
  assign enabled_memory_range_limit_gated_we =
    enabled_memory_range_limit_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(range_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_enabled_memory_range_limit (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (enabled_memory_range_limit_gated_we),
    .wd     (enabled_memory_range_limit_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (enabled_memory_range_limit_flds_we[0]),
    .q      (reg2hw.enabled_memory_range_limit.q),
    .ds     (),
    
    .qs     (enabled_memory_range_limit_qs)
  );
  assign reg2hw.enabled_memory_range_limit.qe = enabled_memory_range_limit_qe;
  
  
  logic range_valid_gated_we;
  assign range_valid_gated_we =
    range_valid_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(range_regwen_qs));
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_range_valid (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (range_valid_gated_we),
    .wd     (range_valid_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.range_valid.q),
    .ds     (),
    
    .qs     (range_valid_qs)
  );
  
  prim_subreg #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessW0C),
    .RESVAL  (4'h6),
    .Mubi    (1'b1)
  ) u_range_regwen (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (range_regwen_we),
    .wd     (range_regwen_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.range_regwen.q),
    .ds     (),
    
    .qs     (range_regwen_qs)
  );
  
  prim_subreg_ext #(
    .DW    (4)
  ) u_cfg_regwen (
    .re     (cfg_regwen_re),
    .we     (1'b0),
    .wd     ('0),
    .d      (hw2reg.cfg_regwen.d),
    .qre    (),
    .qe     (),
    .q      (),
    .ds     (),
    .qs     (cfg_regwen_qs)
  );
  
  
  logic total_data_size_gated_we;
  assign total_data_size_gated_we =
    total_data_size_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_total_data_size (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (total_data_size_gated_we),
    .wd     (total_data_size_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.total_data_size.q),
    .ds     (),
    
    .qs     (total_data_size_qs)
  );
  
  
  logic chunk_data_size_gated_we;
  assign chunk_data_size_gated_we =
    chunk_data_size_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_chunk_data_size (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (chunk_data_size_gated_we),
    .wd     (chunk_data_size_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.chunk_data_size.q),
    .ds     (),
    
    .qs     (chunk_data_size_qs)
  );
  
  
  logic transfer_width_gated_we;
  assign transfer_width_gated_we =
    transfer_width_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (2),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (2'h2),
    .Mubi    (1'b0)
  ) u_transfer_width (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (transfer_width_gated_we),
    .wd     (transfer_width_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.transfer_width.q),
    .ds     (),
    
    .qs     (transfer_width_qs)
  );
  
  logic control_qe;
  logic [5:0] control_flds_we;
  prim_flop #(
    .Width(1),
    .ResetValue(0)
  ) u_control0_qe (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .d_i(&control_flds_we),
    .q_o(control_qe)
  );
  
  prim_subreg #(
    .DW      (4),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (4'h0),
    .Mubi    (1'b0)
  ) u_control_opcode (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (control_we),
    .wd     (control_opcode_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (control_flds_we[0]),
    .q      (reg2hw.control.opcode.q),
    .ds     (),
    
    .qs     (control_opcode_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_control_hardware_handshake_enable (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (control_we),
    .wd     (control_hardware_handshake_enable_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (control_flds_we[1]),
    .q      (reg2hw.control.hardware_handshake_enable.q),
    .ds     (),
    
    .qs     (control_hardware_handshake_enable_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_control_digest_swap (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (control_we),
    .wd     (control_digest_swap_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (control_flds_we[2]),
    .q      (reg2hw.control.digest_swap.q),
    .ds     (),
    
    .qs     (control_digest_swap_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_control_initial_transfer (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (control_we),
    .wd     (control_initial_transfer_wd),
    
    .de     (hw2reg.control.initial_transfer.de),
    .d      (hw2reg.control.initial_transfer.d),
    
    .qe     (control_flds_we[3]),
    .q      (reg2hw.control.initial_transfer.q),
    .ds     (),
    
    .qs     (control_initial_transfer_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessWO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_control_abort (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (control_we),
    .wd     (control_abort_wd),
    
    .de     (hw2reg.control.abort.de),
    .d      (hw2reg.control.abort.d),
    
    .qe     (control_flds_we[4]),
    .q      (reg2hw.control.abort.q),
    .ds     (),
    
    .qs     ()
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_control_go (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (control_we),
    .wd     (control_go_wd),
    
    .de     (hw2reg.control.go.de),
    .d      (hw2reg.control.go.d),
    
    .qe     (control_flds_we[5]),
    .q      (reg2hw.control.go.q),
    .ds     (),
    
    .qs     (control_go_qs)
  );
  assign reg2hw.control.go.qe = control_qe;
  
  
  logic src_config_gated_we;
  assign src_config_gated_we =
    src_config_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_src_config_increment (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (src_config_gated_we),
    .wd     (src_config_increment_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.src_config.increment.q),
    .ds     (),
    
    .qs     (src_config_increment_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_src_config_wrap (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (src_config_gated_we),
    .wd     (src_config_wrap_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.src_config.wrap.q),
    .ds     (),
    
    .qs     (src_config_wrap_qs)
  );
  
  
  logic dst_config_gated_we;
  assign dst_config_gated_we =
    dst_config_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_dst_config_increment (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (dst_config_gated_we),
    .wd     (dst_config_increment_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.dst_config.increment.q),
    .ds     (),
    
    .qs     (dst_config_increment_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_dst_config_wrap (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (dst_config_gated_we),
    .wd     (dst_config_wrap_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.dst_config.wrap.q),
    .ds     (),
    
    .qs     (dst_config_wrap_qs)
  );
  
  logic status_qe;
  logic [5:0] status_flds_we;
  prim_flop #(
    .Width(1),
    .ResetValue(0)
  ) u_status0_qe (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .d_i(&(status_flds_we | 6'h11)),
    .q_o(status_qe)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_busy (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.busy.de),
    .d      (hw2reg.status.busy.d),
    
    .qe     (status_flds_we[0]),
    .q      (reg2hw.status.busy.q),
    .ds     (),
    
    .qs     (status_busy_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_done (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (status_we),
    .wd     (status_done_wd),
    
    .de     (hw2reg.status.done.de),
    .d      (hw2reg.status.done.d),
    
    .qe     (status_flds_we[1]),
    .q      (reg2hw.status.done.q),
    .ds     (),
    
    .qs     (status_done_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_aborted (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (status_we),
    .wd     (status_aborted_wd),
    
    .de     (hw2reg.status.aborted.de),
    .d      (hw2reg.status.aborted.d),
    
    .qe     (status_flds_we[2]),
    .q      (),
    .ds     (),
    
    .qs     (status_aborted_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (status_we),
    .wd     (status_error_wd),
    
    .de     (hw2reg.status.error.de),
    .d      (hw2reg.status.error.d),
    
    .qe     (status_flds_we[3]),
    .q      (reg2hw.status.error.q),
    .ds     (),
    
    .qs     (status_error_qs)
  );
  assign reg2hw.status.error.qe = status_qe;
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_sha2_digest_valid (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.status.sha2_digest_valid.de),
    .d      (hw2reg.status.sha2_digest_valid.d),
    
    .qe     (status_flds_we[4]),
    .q      (reg2hw.status.sha2_digest_valid.q),
    .ds     (),
    
    .qs     (status_sha2_digest_valid_qs)
  );
  assign reg2hw.status.sha2_digest_valid.qe = status_qe;
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_status_chunk_done (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (status_we),
    .wd     (status_chunk_done_wd),
    
    .de     (hw2reg.status.chunk_done.de),
    .d      (hw2reg.status.chunk_done.d),
    
    .qe     (status_flds_we[5]),
    .q      (reg2hw.status.chunk_done.q),
    .ds     (),
    
    .qs     (status_chunk_done_qs)
  );
  
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_code_src_addr_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.error_code.src_addr_error.de),
    .d      (hw2reg.error_code.src_addr_error.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (error_code_src_addr_error_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_code_dst_addr_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.error_code.dst_addr_error.de),
    .d      (hw2reg.error_code.dst_addr_error.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (error_code_dst_addr_error_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_code_opcode_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.error_code.opcode_error.de),
    .d      (hw2reg.error_code.opcode_error.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (error_code_opcode_error_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_code_size_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.error_code.size_error.de),
    .d      (hw2reg.error_code.size_error.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (error_code_size_error_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_code_bus_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.error_code.bus_error.de),
    .d      (hw2reg.error_code.bus_error.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (error_code_bus_error_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_code_base_limit_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.error_code.base_limit_error.de),
    .d      (hw2reg.error_code.base_limit_error.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (error_code_base_limit_error_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_code_range_valid_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.error_code.range_valid_error.de),
    .d      (hw2reg.error_code.range_valid_error.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (error_code_range_valid_error_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_error_code_asid_error (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.error_code.asid_error.de),
    .d      (hw2reg.error_code.asid_error.d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (error_code_asid_error_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[0].de),
    .d      (hw2reg.sha2_digest[0].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_0_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_1 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[1].de),
    .d      (hw2reg.sha2_digest[1].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_1_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_2 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[2].de),
    .d      (hw2reg.sha2_digest[2].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_2_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_3 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[3].de),
    .d      (hw2reg.sha2_digest[3].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_3_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_4 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[4].de),
    .d      (hw2reg.sha2_digest[4].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_4_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_5 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[5].de),
    .d      (hw2reg.sha2_digest[5].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_5_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_6 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[6].de),
    .d      (hw2reg.sha2_digest[6].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_6_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_7 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[7].de),
    .d      (hw2reg.sha2_digest[7].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_7_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_8 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[8].de),
    .d      (hw2reg.sha2_digest[8].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_8_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_9 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[9].de),
    .d      (hw2reg.sha2_digest[9].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_9_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_10 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[10].de),
    .d      (hw2reg.sha2_digest[10].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_10_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_11 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[11].de),
    .d      (hw2reg.sha2_digest[11].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_11_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_12 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[12].de),
    .d      (hw2reg.sha2_digest[12].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_12_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_13 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[13].de),
    .d      (hw2reg.sha2_digest[13].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_13_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_14 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[14].de),
    .d      (hw2reg.sha2_digest[14].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_14_qs)
  );
  
  
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_sha2_digest_15 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.sha2_digest[15].de),
    .d      (hw2reg.sha2_digest[15].d),
    
    .qe     (),
    .q      (),
    .ds     (),
    
    .qs     (sha2_digest_15_qs)
  );
  
  
  logic handshake_intr_enable_gated_we;
  assign handshake_intr_enable_gated_we =
    handshake_intr_enable_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (11),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (11'h7ff),
    .Mubi    (1'b0)
  ) u_handshake_intr_enable (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (handshake_intr_enable_gated_we),
    .wd     (handshake_intr_enable_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.handshake_intr_enable.q),
    .ds     (),
    
    .qs     (handshake_intr_enable_qs)
  );
  
  
  logic clear_intr_src_gated_we;
  assign clear_intr_src_gated_we =
    clear_intr_src_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (11),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (11'h0),
    .Mubi    (1'b0)
  ) u_clear_intr_src (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (clear_intr_src_gated_we),
    .wd     (clear_intr_src_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.clear_intr_src.q),
    .ds     (),
    
    .qs     (clear_intr_src_qs)
  );
  
  
  logic clear_intr_bus_gated_we;
  assign clear_intr_bus_gated_we =
    clear_intr_bus_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (11),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (11'h0),
    .Mubi    (1'b0)
  ) u_clear_intr_bus (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (clear_intr_bus_gated_we),
    .wd     (clear_intr_bus_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.clear_intr_bus.q),
    .ds     (),
    
    .qs     (clear_intr_bus_qs)
  );
  
  
  
  logic intr_src_addr_0_gated_we;
  assign intr_src_addr_0_gated_we =
    intr_src_addr_0_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_addr_0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_addr_0_gated_we),
    .wd     (intr_src_addr_0_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_addr[0].q),
    .ds     (),
    
    .qs     (intr_src_addr_0_qs)
  );
  
  
  
  logic intr_src_addr_1_gated_we;
  assign intr_src_addr_1_gated_we =
    intr_src_addr_1_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_addr_1 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_addr_1_gated_we),
    .wd     (intr_src_addr_1_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_addr[1].q),
    .ds     (),
    
    .qs     (intr_src_addr_1_qs)
  );
  
  
  
  logic intr_src_addr_2_gated_we;
  assign intr_src_addr_2_gated_we =
    intr_src_addr_2_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_addr_2 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_addr_2_gated_we),
    .wd     (intr_src_addr_2_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_addr[2].q),
    .ds     (),
    
    .qs     (intr_src_addr_2_qs)
  );
  
  
  
  logic intr_src_addr_3_gated_we;
  assign intr_src_addr_3_gated_we =
    intr_src_addr_3_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_addr_3 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_addr_3_gated_we),
    .wd     (intr_src_addr_3_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_addr[3].q),
    .ds     (),
    
    .qs     (intr_src_addr_3_qs)
  );
  
  
  
  logic intr_src_addr_4_gated_we;
  assign intr_src_addr_4_gated_we =
    intr_src_addr_4_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_addr_4 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_addr_4_gated_we),
    .wd     (intr_src_addr_4_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_addr[4].q),
    .ds     (),
    
    .qs     (intr_src_addr_4_qs)
  );
  
  
  
  logic intr_src_addr_5_gated_we;
  assign intr_src_addr_5_gated_we =
    intr_src_addr_5_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_addr_5 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_addr_5_gated_we),
    .wd     (intr_src_addr_5_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_addr[5].q),
    .ds     (),
    
    .qs     (intr_src_addr_5_qs)
  );
  
  
  
  logic intr_src_addr_6_gated_we;
  assign intr_src_addr_6_gated_we =
    intr_src_addr_6_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_addr_6 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_addr_6_gated_we),
    .wd     (intr_src_addr_6_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_addr[6].q),
    .ds     (),
    
    .qs     (intr_src_addr_6_qs)
  );
  
  
  
  logic intr_src_addr_7_gated_we;
  assign intr_src_addr_7_gated_we =
    intr_src_addr_7_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_addr_7 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_addr_7_gated_we),
    .wd     (intr_src_addr_7_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_addr[7].q),
    .ds     (),
    
    .qs     (intr_src_addr_7_qs)
  );
  
  
  
  logic intr_src_addr_8_gated_we;
  assign intr_src_addr_8_gated_we =
    intr_src_addr_8_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_addr_8 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_addr_8_gated_we),
    .wd     (intr_src_addr_8_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_addr[8].q),
    .ds     (),
    
    .qs     (intr_src_addr_8_qs)
  );
  
  
  
  logic intr_src_addr_9_gated_we;
  assign intr_src_addr_9_gated_we =
    intr_src_addr_9_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_addr_9 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_addr_9_gated_we),
    .wd     (intr_src_addr_9_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_addr[9].q),
    .ds     (),
    
    .qs     (intr_src_addr_9_qs)
  );
  
  
  
  logic intr_src_addr_10_gated_we;
  assign intr_src_addr_10_gated_we =
    intr_src_addr_10_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_addr_10 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_addr_10_gated_we),
    .wd     (intr_src_addr_10_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_addr[10].q),
    .ds     (),
    
    .qs     (intr_src_addr_10_qs)
  );
  
  
  
  logic intr_src_wr_val_0_gated_we;
  assign intr_src_wr_val_0_gated_we =
    intr_src_wr_val_0_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_wr_val_0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_wr_val_0_gated_we),
    .wd     (intr_src_wr_val_0_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_wr_val[0].q),
    .ds     (),
    
    .qs     (intr_src_wr_val_0_qs)
  );
  
  
  
  logic intr_src_wr_val_1_gated_we;
  assign intr_src_wr_val_1_gated_we =
    intr_src_wr_val_1_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_wr_val_1 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_wr_val_1_gated_we),
    .wd     (intr_src_wr_val_1_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_wr_val[1].q),
    .ds     (),
    
    .qs     (intr_src_wr_val_1_qs)
  );
  
  
  
  logic intr_src_wr_val_2_gated_we;
  assign intr_src_wr_val_2_gated_we =
    intr_src_wr_val_2_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_wr_val_2 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_wr_val_2_gated_we),
    .wd     (intr_src_wr_val_2_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_wr_val[2].q),
    .ds     (),
    
    .qs     (intr_src_wr_val_2_qs)
  );
  
  
  
  logic intr_src_wr_val_3_gated_we;
  assign intr_src_wr_val_3_gated_we =
    intr_src_wr_val_3_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_wr_val_3 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_wr_val_3_gated_we),
    .wd     (intr_src_wr_val_3_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_wr_val[3].q),
    .ds     (),
    
    .qs     (intr_src_wr_val_3_qs)
  );
  
  
  
  logic intr_src_wr_val_4_gated_we;
  assign intr_src_wr_val_4_gated_we =
    intr_src_wr_val_4_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_wr_val_4 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_wr_val_4_gated_we),
    .wd     (intr_src_wr_val_4_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_wr_val[4].q),
    .ds     (),
    
    .qs     (intr_src_wr_val_4_qs)
  );
  
  
  
  logic intr_src_wr_val_5_gated_we;
  assign intr_src_wr_val_5_gated_we =
    intr_src_wr_val_5_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_wr_val_5 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_wr_val_5_gated_we),
    .wd     (intr_src_wr_val_5_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_wr_val[5].q),
    .ds     (),
    
    .qs     (intr_src_wr_val_5_qs)
  );
  
  
  
  logic intr_src_wr_val_6_gated_we;
  assign intr_src_wr_val_6_gated_we =
    intr_src_wr_val_6_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_wr_val_6 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_wr_val_6_gated_we),
    .wd     (intr_src_wr_val_6_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_wr_val[6].q),
    .ds     (),
    
    .qs     (intr_src_wr_val_6_qs)
  );
  
  
  
  logic intr_src_wr_val_7_gated_we;
  assign intr_src_wr_val_7_gated_we =
    intr_src_wr_val_7_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_wr_val_7 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_wr_val_7_gated_we),
    .wd     (intr_src_wr_val_7_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_wr_val[7].q),
    .ds     (),
    
    .qs     (intr_src_wr_val_7_qs)
  );
  
  
  
  logic intr_src_wr_val_8_gated_we;
  assign intr_src_wr_val_8_gated_we =
    intr_src_wr_val_8_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_wr_val_8 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_wr_val_8_gated_we),
    .wd     (intr_src_wr_val_8_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_wr_val[8].q),
    .ds     (),
    
    .qs     (intr_src_wr_val_8_qs)
  );
  
  
  
  logic intr_src_wr_val_9_gated_we;
  assign intr_src_wr_val_9_gated_we =
    intr_src_wr_val_9_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_wr_val_9 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_wr_val_9_gated_we),
    .wd     (intr_src_wr_val_9_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_wr_val[9].q),
    .ds     (),
    
    .qs     (intr_src_wr_val_9_qs)
  );
  
  
  
  logic intr_src_wr_val_10_gated_we;
  assign intr_src_wr_val_10_gated_we =
    intr_src_wr_val_10_we &
          prim_mubi_pkg::mubi4_test_true_strict(prim_mubi_pkg::mubi4_t'(cfg_regwen_qs));
  prim_subreg #(
    .DW      (32),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (32'h0),
    .Mubi    (1'b0)
  ) u_intr_src_wr_val_10 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (intr_src_wr_val_10_gated_we),
    .wd     (intr_src_wr_val_10_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.intr_src_wr_val[10].q),
    .ds     (),
    
    .qs     (intr_src_wr_val_10_qs)
  );
  logic [62:0] addr_hit;
  top_racl_pkg::racl_role_vec_t racl_role_vec;
  top_racl_pkg::racl_role_t racl_role;
  logic [62:0] racl_addr_hit_read;
  logic [62:0] racl_addr_hit_write;
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
    addr_hit[ 0] = (reg_addr == DMA_INTR_STATE_OFFSET);
    addr_hit[ 1] = (reg_addr == DMA_INTR_ENABLE_OFFSET);
    addr_hit[ 2] = (reg_addr == DMA_INTR_TEST_OFFSET);
    addr_hit[ 3] = (reg_addr == DMA_ALERT_TEST_OFFSET);
    addr_hit[ 4] = (reg_addr == DMA_SRC_ADDR_LO_OFFSET);
    addr_hit[ 5] = (reg_addr == DMA_SRC_ADDR_HI_OFFSET);
    addr_hit[ 6] = (reg_addr == DMA_DST_ADDR_LO_OFFSET);
    addr_hit[ 7] = (reg_addr == DMA_DST_ADDR_HI_OFFSET);
    addr_hit[ 8] = (reg_addr == DMA_ADDR_SPACE_ID_OFFSET);
    addr_hit[ 9] = (reg_addr == DMA_ENABLED_MEMORY_RANGE_BASE_OFFSET);
    addr_hit[10] = (reg_addr == DMA_ENABLED_MEMORY_RANGE_LIMIT_OFFSET);
    addr_hit[11] = (reg_addr == DMA_RANGE_VALID_OFFSET);
    addr_hit[12] = (reg_addr == DMA_RANGE_REGWEN_OFFSET);
    addr_hit[13] = (reg_addr == DMA_CFG_REGWEN_OFFSET);
    addr_hit[14] = (reg_addr == DMA_TOTAL_DATA_SIZE_OFFSET);
    addr_hit[15] = (reg_addr == DMA_CHUNK_DATA_SIZE_OFFSET);
    addr_hit[16] = (reg_addr == DMA_TRANSFER_WIDTH_OFFSET);
    addr_hit[17] = (reg_addr == DMA_CONTROL_OFFSET);
    addr_hit[18] = (reg_addr == DMA_SRC_CONFIG_OFFSET);
    addr_hit[19] = (reg_addr == DMA_DST_CONFIG_OFFSET);
    addr_hit[20] = (reg_addr == DMA_STATUS_OFFSET);
    addr_hit[21] = (reg_addr == DMA_ERROR_CODE_OFFSET);
    addr_hit[22] = (reg_addr == DMA_SHA2_DIGEST_0_OFFSET);
    addr_hit[23] = (reg_addr == DMA_SHA2_DIGEST_1_OFFSET);
    addr_hit[24] = (reg_addr == DMA_SHA2_DIGEST_2_OFFSET);
    addr_hit[25] = (reg_addr == DMA_SHA2_DIGEST_3_OFFSET);
    addr_hit[26] = (reg_addr == DMA_SHA2_DIGEST_4_OFFSET);
    addr_hit[27] = (reg_addr == DMA_SHA2_DIGEST_5_OFFSET);
    addr_hit[28] = (reg_addr == DMA_SHA2_DIGEST_6_OFFSET);
    addr_hit[29] = (reg_addr == DMA_SHA2_DIGEST_7_OFFSET);
    addr_hit[30] = (reg_addr == DMA_SHA2_DIGEST_8_OFFSET);
    addr_hit[31] = (reg_addr == DMA_SHA2_DIGEST_9_OFFSET);
    addr_hit[32] = (reg_addr == DMA_SHA2_DIGEST_10_OFFSET);
    addr_hit[33] = (reg_addr == DMA_SHA2_DIGEST_11_OFFSET);
    addr_hit[34] = (reg_addr == DMA_SHA2_DIGEST_12_OFFSET);
    addr_hit[35] = (reg_addr == DMA_SHA2_DIGEST_13_OFFSET);
    addr_hit[36] = (reg_addr == DMA_SHA2_DIGEST_14_OFFSET);
    addr_hit[37] = (reg_addr == DMA_SHA2_DIGEST_15_OFFSET);
    addr_hit[38] = (reg_addr == DMA_HANDSHAKE_INTR_ENABLE_OFFSET);
    addr_hit[39] = (reg_addr == DMA_CLEAR_INTR_SRC_OFFSET);
    addr_hit[40] = (reg_addr == DMA_CLEAR_INTR_BUS_OFFSET);
    addr_hit[41] = (reg_addr == DMA_INTR_SRC_ADDR_0_OFFSET);
    addr_hit[42] = (reg_addr == DMA_INTR_SRC_ADDR_1_OFFSET);
    addr_hit[43] = (reg_addr == DMA_INTR_SRC_ADDR_2_OFFSET);
    addr_hit[44] = (reg_addr == DMA_INTR_SRC_ADDR_3_OFFSET);
    addr_hit[45] = (reg_addr == DMA_INTR_SRC_ADDR_4_OFFSET);
    addr_hit[46] = (reg_addr == DMA_INTR_SRC_ADDR_5_OFFSET);
    addr_hit[47] = (reg_addr == DMA_INTR_SRC_ADDR_6_OFFSET);
    addr_hit[48] = (reg_addr == DMA_INTR_SRC_ADDR_7_OFFSET);
    addr_hit[49] = (reg_addr == DMA_INTR_SRC_ADDR_8_OFFSET);
    addr_hit[50] = (reg_addr == DMA_INTR_SRC_ADDR_9_OFFSET);
    addr_hit[51] = (reg_addr == DMA_INTR_SRC_ADDR_10_OFFSET);
    addr_hit[52] = (reg_addr == DMA_INTR_SRC_WR_VAL_0_OFFSET);
    addr_hit[53] = (reg_addr == DMA_INTR_SRC_WR_VAL_1_OFFSET);
    addr_hit[54] = (reg_addr == DMA_INTR_SRC_WR_VAL_2_OFFSET);
    addr_hit[55] = (reg_addr == DMA_INTR_SRC_WR_VAL_3_OFFSET);
    addr_hit[56] = (reg_addr == DMA_INTR_SRC_WR_VAL_4_OFFSET);
    addr_hit[57] = (reg_addr == DMA_INTR_SRC_WR_VAL_5_OFFSET);
    addr_hit[58] = (reg_addr == DMA_INTR_SRC_WR_VAL_6_OFFSET);
    addr_hit[59] = (reg_addr == DMA_INTR_SRC_WR_VAL_7_OFFSET);
    addr_hit[60] = (reg_addr == DMA_INTR_SRC_WR_VAL_8_OFFSET);
    addr_hit[61] = (reg_addr == DMA_INTR_SRC_WR_VAL_9_OFFSET);
    addr_hit[62] = (reg_addr == DMA_INTR_SRC_WR_VAL_10_OFFSET);
    if (EnableRacl) begin : gen_racl_hit
      for (int unsigned slice_idx = 0; slice_idx < 63; slice_idx++) begin
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
              ((racl_addr_hit_write[ 0] & (|(DMA_PERMIT[ 0] & ~reg_be))) |
               (racl_addr_hit_write[ 1] & (|(DMA_PERMIT[ 1] & ~reg_be))) |
               (racl_addr_hit_write[ 2] & (|(DMA_PERMIT[ 2] & ~reg_be))) |
               (racl_addr_hit_write[ 3] & (|(DMA_PERMIT[ 3] & ~reg_be))) |
               (racl_addr_hit_write[ 4] & (|(DMA_PERMIT[ 4] & ~reg_be))) |
               (racl_addr_hit_write[ 5] & (|(DMA_PERMIT[ 5] & ~reg_be))) |
               (racl_addr_hit_write[ 6] & (|(DMA_PERMIT[ 6] & ~reg_be))) |
               (racl_addr_hit_write[ 7] & (|(DMA_PERMIT[ 7] & ~reg_be))) |
               (racl_addr_hit_write[ 8] & (|(DMA_PERMIT[ 8] & ~reg_be))) |
               (racl_addr_hit_write[ 9] & (|(DMA_PERMIT[ 9] & ~reg_be))) |
               (racl_addr_hit_write[10] & (|(DMA_PERMIT[10] & ~reg_be))) |
               (racl_addr_hit_write[11] & (|(DMA_PERMIT[11] & ~reg_be))) |
               (racl_addr_hit_write[12] & (|(DMA_PERMIT[12] & ~reg_be))) |
               (racl_addr_hit_write[13] & (|(DMA_PERMIT[13] & ~reg_be))) |
               (racl_addr_hit_write[14] & (|(DMA_PERMIT[14] & ~reg_be))) |
               (racl_addr_hit_write[15] & (|(DMA_PERMIT[15] & ~reg_be))) |
               (racl_addr_hit_write[16] & (|(DMA_PERMIT[16] & ~reg_be))) |
               (racl_addr_hit_write[17] & (|(DMA_PERMIT[17] & ~reg_be))) |
               (racl_addr_hit_write[18] & (|(DMA_PERMIT[18] & ~reg_be))) |
               (racl_addr_hit_write[19] & (|(DMA_PERMIT[19] & ~reg_be))) |
               (racl_addr_hit_write[20] & (|(DMA_PERMIT[20] & ~reg_be))) |
               (racl_addr_hit_write[21] & (|(DMA_PERMIT[21] & ~reg_be))) |
               (racl_addr_hit_write[22] & (|(DMA_PERMIT[22] & ~reg_be))) |
               (racl_addr_hit_write[23] & (|(DMA_PERMIT[23] & ~reg_be))) |
               (racl_addr_hit_write[24] & (|(DMA_PERMIT[24] & ~reg_be))) |
               (racl_addr_hit_write[25] & (|(DMA_PERMIT[25] & ~reg_be))) |
               (racl_addr_hit_write[26] & (|(DMA_PERMIT[26] & ~reg_be))) |
               (racl_addr_hit_write[27] & (|(DMA_PERMIT[27] & ~reg_be))) |
               (racl_addr_hit_write[28] & (|(DMA_PERMIT[28] & ~reg_be))) |
               (racl_addr_hit_write[29] & (|(DMA_PERMIT[29] & ~reg_be))) |
               (racl_addr_hit_write[30] & (|(DMA_PERMIT[30] & ~reg_be))) |
               (racl_addr_hit_write[31] & (|(DMA_PERMIT[31] & ~reg_be))) |
               (racl_addr_hit_write[32] & (|(DMA_PERMIT[32] & ~reg_be))) |
               (racl_addr_hit_write[33] & (|(DMA_PERMIT[33] & ~reg_be))) |
               (racl_addr_hit_write[34] & (|(DMA_PERMIT[34] & ~reg_be))) |
               (racl_addr_hit_write[35] & (|(DMA_PERMIT[35] & ~reg_be))) |
               (racl_addr_hit_write[36] & (|(DMA_PERMIT[36] & ~reg_be))) |
               (racl_addr_hit_write[37] & (|(DMA_PERMIT[37] & ~reg_be))) |
               (racl_addr_hit_write[38] & (|(DMA_PERMIT[38] & ~reg_be))) |
               (racl_addr_hit_write[39] & (|(DMA_PERMIT[39] & ~reg_be))) |
               (racl_addr_hit_write[40] & (|(DMA_PERMIT[40] & ~reg_be))) |
               (racl_addr_hit_write[41] & (|(DMA_PERMIT[41] & ~reg_be))) |
               (racl_addr_hit_write[42] & (|(DMA_PERMIT[42] & ~reg_be))) |
               (racl_addr_hit_write[43] & (|(DMA_PERMIT[43] & ~reg_be))) |
               (racl_addr_hit_write[44] & (|(DMA_PERMIT[44] & ~reg_be))) |
               (racl_addr_hit_write[45] & (|(DMA_PERMIT[45] & ~reg_be))) |
               (racl_addr_hit_write[46] & (|(DMA_PERMIT[46] & ~reg_be))) |
               (racl_addr_hit_write[47] & (|(DMA_PERMIT[47] & ~reg_be))) |
               (racl_addr_hit_write[48] & (|(DMA_PERMIT[48] & ~reg_be))) |
               (racl_addr_hit_write[49] & (|(DMA_PERMIT[49] & ~reg_be))) |
               (racl_addr_hit_write[50] & (|(DMA_PERMIT[50] & ~reg_be))) |
               (racl_addr_hit_write[51] & (|(DMA_PERMIT[51] & ~reg_be))) |
               (racl_addr_hit_write[52] & (|(DMA_PERMIT[52] & ~reg_be))) |
               (racl_addr_hit_write[53] & (|(DMA_PERMIT[53] & ~reg_be))) |
               (racl_addr_hit_write[54] & (|(DMA_PERMIT[54] & ~reg_be))) |
               (racl_addr_hit_write[55] & (|(DMA_PERMIT[55] & ~reg_be))) |
               (racl_addr_hit_write[56] & (|(DMA_PERMIT[56] & ~reg_be))) |
               (racl_addr_hit_write[57] & (|(DMA_PERMIT[57] & ~reg_be))) |
               (racl_addr_hit_write[58] & (|(DMA_PERMIT[58] & ~reg_be))) |
               (racl_addr_hit_write[59] & (|(DMA_PERMIT[59] & ~reg_be))) |
               (racl_addr_hit_write[60] & (|(DMA_PERMIT[60] & ~reg_be))) |
               (racl_addr_hit_write[61] & (|(DMA_PERMIT[61] & ~reg_be))) |
               (racl_addr_hit_write[62] & (|(DMA_PERMIT[62] & ~reg_be)))));
  end
  
  assign intr_enable_we = racl_addr_hit_write[1] & reg_we & !reg_error;
  assign intr_enable_dma_done_wd = reg_wdata[0];
  assign intr_enable_dma_chunk_done_wd = reg_wdata[1];
  assign intr_enable_dma_error_wd = reg_wdata[2];
  assign intr_test_we = racl_addr_hit_write[2] & reg_we & !reg_error;
  assign intr_test_dma_done_wd = reg_wdata[0];
  assign intr_test_dma_chunk_done_wd = reg_wdata[1];
  assign intr_test_dma_error_wd = reg_wdata[2];
  assign alert_test_we = racl_addr_hit_write[3] & reg_we & !reg_error;
  assign alert_test_wd = reg_wdata[0];
  assign src_addr_lo_we = racl_addr_hit_write[4] & reg_we & !reg_error;
  assign src_addr_lo_wd = reg_wdata[31:0];
  assign src_addr_hi_we = racl_addr_hit_write[5] & reg_we & !reg_error;
  assign src_addr_hi_wd = reg_wdata[31:0];
  assign dst_addr_lo_we = racl_addr_hit_write[6] & reg_we & !reg_error;
  assign dst_addr_lo_wd = reg_wdata[31:0];
  assign dst_addr_hi_we = racl_addr_hit_write[7] & reg_we & !reg_error;
  assign dst_addr_hi_wd = reg_wdata[31:0];
  assign addr_space_id_we = racl_addr_hit_write[8] & reg_we & !reg_error;
  assign addr_space_id_src_asid_wd = reg_wdata[3:0];
  assign addr_space_id_dst_asid_wd = reg_wdata[7:4];
  assign enabled_memory_range_base_we = racl_addr_hit_write[9] & reg_we & !reg_error;
  assign enabled_memory_range_base_wd = reg_wdata[31:0];
  assign enabled_memory_range_limit_we = racl_addr_hit_write[10] & reg_we & !reg_error;
  assign enabled_memory_range_limit_wd = reg_wdata[31:0];
  assign range_valid_we = racl_addr_hit_write[11] & reg_we & !reg_error;
  assign range_valid_wd = reg_wdata[0];
  assign range_regwen_we = racl_addr_hit_write[12] & reg_we & !reg_error;
  assign range_regwen_wd = reg_wdata[3:0];
  assign cfg_regwen_re = racl_addr_hit_read[13] & reg_re & !reg_error;
  assign total_data_size_we = racl_addr_hit_write[14] & reg_we & !reg_error;
  assign total_data_size_wd = reg_wdata[31:0];
  assign chunk_data_size_we = racl_addr_hit_write[15] & reg_we & !reg_error;
  assign chunk_data_size_wd = reg_wdata[31:0];
  assign transfer_width_we = racl_addr_hit_write[16] & reg_we & !reg_error;
  assign transfer_width_wd = reg_wdata[1:0];
  assign control_we = racl_addr_hit_write[17] & reg_we & !reg_error;
  assign control_opcode_wd = reg_wdata[3:0];
  assign control_hardware_handshake_enable_wd = reg_wdata[4];
  assign control_digest_swap_wd = reg_wdata[5];
  assign control_initial_transfer_wd = reg_wdata[8];
  assign control_abort_wd = reg_wdata[27];
  assign control_go_wd = reg_wdata[31];
  assign src_config_we = racl_addr_hit_write[18] & reg_we & !reg_error;
  assign src_config_increment_wd = reg_wdata[0];
  assign src_config_wrap_wd = reg_wdata[1];
  assign dst_config_we = racl_addr_hit_write[19] & reg_we & !reg_error;
  assign dst_config_increment_wd = reg_wdata[0];
  assign dst_config_wrap_wd = reg_wdata[1];
  assign status_we = racl_addr_hit_write[20] & reg_we & !reg_error;
  assign status_done_wd = reg_wdata[1];
  assign status_aborted_wd = reg_wdata[2];
  assign status_error_wd = reg_wdata[3];
  assign status_chunk_done_wd = reg_wdata[5];
  assign handshake_intr_enable_we = racl_addr_hit_write[38] & reg_we & !reg_error;
  assign handshake_intr_enable_wd = reg_wdata[10:0];
  assign clear_intr_src_we = racl_addr_hit_write[39] & reg_we & !reg_error;
  assign clear_intr_src_wd = reg_wdata[10:0];
  assign clear_intr_bus_we = racl_addr_hit_write[40] & reg_we & !reg_error;
  assign clear_intr_bus_wd = reg_wdata[10:0];
  assign intr_src_addr_0_we = racl_addr_hit_write[41] & reg_we & !reg_error;
  assign intr_src_addr_0_wd = reg_wdata[31:0];
  assign intr_src_addr_1_we = racl_addr_hit_write[42] & reg_we & !reg_error;
  assign intr_src_addr_1_wd = reg_wdata[31:0];
  assign intr_src_addr_2_we = racl_addr_hit_write[43] & reg_we & !reg_error;
  assign intr_src_addr_2_wd = reg_wdata[31:0];
  assign intr_src_addr_3_we = racl_addr_hit_write[44] & reg_we & !reg_error;
  assign intr_src_addr_3_wd = reg_wdata[31:0];
  assign intr_src_addr_4_we = racl_addr_hit_write[45] & reg_we & !reg_error;
  assign intr_src_addr_4_wd = reg_wdata[31:0];
  assign intr_src_addr_5_we = racl_addr_hit_write[46] & reg_we & !reg_error;
  assign intr_src_addr_5_wd = reg_wdata[31:0];
  assign intr_src_addr_6_we = racl_addr_hit_write[47] & reg_we & !reg_error;
  assign intr_src_addr_6_wd = reg_wdata[31:0];
  assign intr_src_addr_7_we = racl_addr_hit_write[48] & reg_we & !reg_error;
  assign intr_src_addr_7_wd = reg_wdata[31:0];
  assign intr_src_addr_8_we = racl_addr_hit_write[49] & reg_we & !reg_error;
  assign intr_src_addr_8_wd = reg_wdata[31:0];
  assign intr_src_addr_9_we = racl_addr_hit_write[50] & reg_we & !reg_error;
  assign intr_src_addr_9_wd = reg_wdata[31:0];
  assign intr_src_addr_10_we = racl_addr_hit_write[51] & reg_we & !reg_error;
  assign intr_src_addr_10_wd = reg_wdata[31:0];
  assign intr_src_wr_val_0_we = racl_addr_hit_write[52] & reg_we & !reg_error;
  assign intr_src_wr_val_0_wd = reg_wdata[31:0];
  assign intr_src_wr_val_1_we = racl_addr_hit_write[53] & reg_we & !reg_error;
  assign intr_src_wr_val_1_wd = reg_wdata[31:0];
  assign intr_src_wr_val_2_we = racl_addr_hit_write[54] & reg_we & !reg_error;
  assign intr_src_wr_val_2_wd = reg_wdata[31:0];
  assign intr_src_wr_val_3_we = racl_addr_hit_write[55] & reg_we & !reg_error;
  assign intr_src_wr_val_3_wd = reg_wdata[31:0];
  assign intr_src_wr_val_4_we = racl_addr_hit_write[56] & reg_we & !reg_error;
  assign intr_src_wr_val_4_wd = reg_wdata[31:0];
  assign intr_src_wr_val_5_we = racl_addr_hit_write[57] & reg_we & !reg_error;
  assign intr_src_wr_val_5_wd = reg_wdata[31:0];
  assign intr_src_wr_val_6_we = racl_addr_hit_write[58] & reg_we & !reg_error;
  assign intr_src_wr_val_6_wd = reg_wdata[31:0];
  assign intr_src_wr_val_7_we = racl_addr_hit_write[59] & reg_we & !reg_error;
  assign intr_src_wr_val_7_wd = reg_wdata[31:0];
  assign intr_src_wr_val_8_we = racl_addr_hit_write[60] & reg_we & !reg_error;
  assign intr_src_wr_val_8_wd = reg_wdata[31:0];
  assign intr_src_wr_val_9_we = racl_addr_hit_write[61] & reg_we & !reg_error;
  assign intr_src_wr_val_9_wd = reg_wdata[31:0];
  assign intr_src_wr_val_10_we = racl_addr_hit_write[62] & reg_we & !reg_error;
  assign intr_src_wr_val_10_wd = reg_wdata[31:0];
  
  always_comb begin
    reg_we_check[0] = 1'b0;
    reg_we_check[1] = intr_enable_we;
    reg_we_check[2] = intr_test_we;
    reg_we_check[3] = alert_test_we;
    reg_we_check[4] = src_addr_lo_gated_we;
    reg_we_check[5] = src_addr_hi_gated_we;
    reg_we_check[6] = dst_addr_lo_gated_we;
    reg_we_check[7] = dst_addr_hi_gated_we;
    reg_we_check[8] = addr_space_id_gated_we;
    reg_we_check[9] = enabled_memory_range_base_gated_we;
    reg_we_check[10] = enabled_memory_range_limit_gated_we;
    reg_we_check[11] = range_valid_gated_we;
    reg_we_check[12] = range_regwen_we;
    reg_we_check[13] = 1'b0;
    reg_we_check[14] = total_data_size_gated_we;
    reg_we_check[15] = chunk_data_size_gated_we;
    reg_we_check[16] = transfer_width_gated_we;
    reg_we_check[17] = control_we;
    reg_we_check[18] = src_config_gated_we;
    reg_we_check[19] = dst_config_gated_we;
    reg_we_check[20] = status_we;
    reg_we_check[21] = 1'b0;
    reg_we_check[22] = 1'b0;
    reg_we_check[23] = 1'b0;
    reg_we_check[24] = 1'b0;
    reg_we_check[25] = 1'b0;
    reg_we_check[26] = 1'b0;
    reg_we_check[27] = 1'b0;
    reg_we_check[28] = 1'b0;
    reg_we_check[29] = 1'b0;
    reg_we_check[30] = 1'b0;
    reg_we_check[31] = 1'b0;
    reg_we_check[32] = 1'b0;
    reg_we_check[33] = 1'b0;
    reg_we_check[34] = 1'b0;
    reg_we_check[35] = 1'b0;
    reg_we_check[36] = 1'b0;
    reg_we_check[37] = 1'b0;
    reg_we_check[38] = handshake_intr_enable_gated_we;
    reg_we_check[39] = clear_intr_src_gated_we;
    reg_we_check[40] = clear_intr_bus_gated_we;
    reg_we_check[41] = intr_src_addr_0_gated_we;
    reg_we_check[42] = intr_src_addr_1_gated_we;
    reg_we_check[43] = intr_src_addr_2_gated_we;
    reg_we_check[44] = intr_src_addr_3_gated_we;
    reg_we_check[45] = intr_src_addr_4_gated_we;
    reg_we_check[46] = intr_src_addr_5_gated_we;
    reg_we_check[47] = intr_src_addr_6_gated_we;
    reg_we_check[48] = intr_src_addr_7_gated_we;
    reg_we_check[49] = intr_src_addr_8_gated_we;
    reg_we_check[50] = intr_src_addr_9_gated_we;
    reg_we_check[51] = intr_src_addr_10_gated_we;
    reg_we_check[52] = intr_src_wr_val_0_gated_we;
    reg_we_check[53] = intr_src_wr_val_1_gated_we;
    reg_we_check[54] = intr_src_wr_val_2_gated_we;
    reg_we_check[55] = intr_src_wr_val_3_gated_we;
    reg_we_check[56] = intr_src_wr_val_4_gated_we;
    reg_we_check[57] = intr_src_wr_val_5_gated_we;
    reg_we_check[58] = intr_src_wr_val_6_gated_we;
    reg_we_check[59] = intr_src_wr_val_7_gated_we;
    reg_we_check[60] = intr_src_wr_val_8_gated_we;
    reg_we_check[61] = intr_src_wr_val_9_gated_we;
    reg_we_check[62] = intr_src_wr_val_10_gated_we;
  end
  
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      racl_addr_hit_read[0]: begin
        reg_rdata_next[0] = intr_state_dma_done_qs;
        reg_rdata_next[1] = intr_state_dma_chunk_done_qs;
        reg_rdata_next[2] = intr_state_dma_error_qs;
      end
      racl_addr_hit_read[1]: begin
        reg_rdata_next[0] = intr_enable_dma_done_qs;
        reg_rdata_next[1] = intr_enable_dma_chunk_done_qs;
        reg_rdata_next[2] = intr_enable_dma_error_qs;
      end
      racl_addr_hit_read[2]: begin
        reg_rdata_next[0] = '0;
        reg_rdata_next[1] = '0;
        reg_rdata_next[2] = '0;
      end
      racl_addr_hit_read[3]: begin
        reg_rdata_next[0] = '0;
      end
      racl_addr_hit_read[4]: begin
        reg_rdata_next[31:0] = src_addr_lo_qs;
      end
      racl_addr_hit_read[5]: begin
        reg_rdata_next[31:0] = src_addr_hi_qs;
      end
      racl_addr_hit_read[6]: begin
        reg_rdata_next[31:0] = dst_addr_lo_qs;
      end
      racl_addr_hit_read[7]: begin
        reg_rdata_next[31:0] = dst_addr_hi_qs;
      end
      racl_addr_hit_read[8]: begin
        reg_rdata_next[3:0] = addr_space_id_src_asid_qs;
        reg_rdata_next[7:4] = addr_space_id_dst_asid_qs;
      end
      racl_addr_hit_read[9]: begin
        reg_rdata_next[31:0] = enabled_memory_range_base_qs;
      end
      racl_addr_hit_read[10]: begin
        reg_rdata_next[31:0] = enabled_memory_range_limit_qs;
      end
      racl_addr_hit_read[11]: begin
        reg_rdata_next[0] = range_valid_qs;
      end
      racl_addr_hit_read[12]: begin
        reg_rdata_next[3:0] = range_regwen_qs;
      end
      racl_addr_hit_read[13]: begin
        reg_rdata_next[3:0] = cfg_regwen_qs;
      end
      racl_addr_hit_read[14]: begin
        reg_rdata_next[31:0] = total_data_size_qs;
      end
      racl_addr_hit_read[15]: begin
        reg_rdata_next[31:0] = chunk_data_size_qs;
      end
      racl_addr_hit_read[16]: begin
        reg_rdata_next[1:0] = transfer_width_qs;
      end
      racl_addr_hit_read[17]: begin
        reg_rdata_next[3:0] = control_opcode_qs;
        reg_rdata_next[4] = control_hardware_handshake_enable_qs;
        reg_rdata_next[5] = control_digest_swap_qs;
        reg_rdata_next[8] = control_initial_transfer_qs;
        reg_rdata_next[27] = '0;
        reg_rdata_next[31] = control_go_qs;
      end
      racl_addr_hit_read[18]: begin
        reg_rdata_next[0] = src_config_increment_qs;
        reg_rdata_next[1] = src_config_wrap_qs;
      end
      racl_addr_hit_read[19]: begin
        reg_rdata_next[0] = dst_config_increment_qs;
        reg_rdata_next[1] = dst_config_wrap_qs;
      end
      racl_addr_hit_read[20]: begin
        reg_rdata_next[0] = status_busy_qs;
        reg_rdata_next[1] = status_done_qs;
        reg_rdata_next[2] = status_aborted_qs;
        reg_rdata_next[3] = status_error_qs;
        reg_rdata_next[4] = status_sha2_digest_valid_qs;
        reg_rdata_next[5] = status_chunk_done_qs;
      end
      racl_addr_hit_read[21]: begin
        reg_rdata_next[0] = error_code_src_addr_error_qs;
        reg_rdata_next[1] = error_code_dst_addr_error_qs;
        reg_rdata_next[2] = error_code_opcode_error_qs;
        reg_rdata_next[3] = error_code_size_error_qs;
        reg_rdata_next[4] = error_code_bus_error_qs;
        reg_rdata_next[5] = error_code_base_limit_error_qs;
        reg_rdata_next[6] = error_code_range_valid_error_qs;
        reg_rdata_next[7] = error_code_asid_error_qs;
      end
      racl_addr_hit_read[22]: begin
        reg_rdata_next[31:0] = sha2_digest_0_qs;
      end
      racl_addr_hit_read[23]: begin
        reg_rdata_next[31:0] = sha2_digest_1_qs;
      end
      racl_addr_hit_read[24]: begin
        reg_rdata_next[31:0] = sha2_digest_2_qs;
      end
      racl_addr_hit_read[25]: begin
        reg_rdata_next[31:0] = sha2_digest_3_qs;
      end
      racl_addr_hit_read[26]: begin
        reg_rdata_next[31:0] = sha2_digest_4_qs;
      end
      racl_addr_hit_read[27]: begin
        reg_rdata_next[31:0] = sha2_digest_5_qs;
      end
      racl_addr_hit_read[28]: begin
        reg_rdata_next[31:0] = sha2_digest_6_qs;
      end
      racl_addr_hit_read[29]: begin
        reg_rdata_next[31:0] = sha2_digest_7_qs;
      end
      racl_addr_hit_read[30]: begin
        reg_rdata_next[31:0] = sha2_digest_8_qs;
      end
      racl_addr_hit_read[31]: begin
        reg_rdata_next[31:0] = sha2_digest_9_qs;
      end
      racl_addr_hit_read[32]: begin
        reg_rdata_next[31:0] = sha2_digest_10_qs;
      end
      racl_addr_hit_read[33]: begin
        reg_rdata_next[31:0] = sha2_digest_11_qs;
      end
      racl_addr_hit_read[34]: begin
        reg_rdata_next[31:0] = sha2_digest_12_qs;
      end
      racl_addr_hit_read[35]: begin
        reg_rdata_next[31:0] = sha2_digest_13_qs;
      end
      racl_addr_hit_read[36]: begin
        reg_rdata_next[31:0] = sha2_digest_14_qs;
      end
      racl_addr_hit_read[37]: begin
        reg_rdata_next[31:0] = sha2_digest_15_qs;
      end
      racl_addr_hit_read[38]: begin
        reg_rdata_next[10:0] = handshake_intr_enable_qs;
      end
      racl_addr_hit_read[39]: begin
        reg_rdata_next[10:0] = clear_intr_src_qs;
      end
      racl_addr_hit_read[40]: begin
        reg_rdata_next[10:0] = clear_intr_bus_qs;
      end
      racl_addr_hit_read[41]: begin
        reg_rdata_next[31:0] = intr_src_addr_0_qs;
      end
      racl_addr_hit_read[42]: begin
        reg_rdata_next[31:0] = intr_src_addr_1_qs;
      end
      racl_addr_hit_read[43]: begin
        reg_rdata_next[31:0] = intr_src_addr_2_qs;
      end
      racl_addr_hit_read[44]: begin
        reg_rdata_next[31:0] = intr_src_addr_3_qs;
      end
      racl_addr_hit_read[45]: begin
        reg_rdata_next[31:0] = intr_src_addr_4_qs;
      end
      racl_addr_hit_read[46]: begin
        reg_rdata_next[31:0] = intr_src_addr_5_qs;
      end
      racl_addr_hit_read[47]: begin
        reg_rdata_next[31:0] = intr_src_addr_6_qs;
      end
      racl_addr_hit_read[48]: begin
        reg_rdata_next[31:0] = intr_src_addr_7_qs;
      end
      racl_addr_hit_read[49]: begin
        reg_rdata_next[31:0] = intr_src_addr_8_qs;
      end
      racl_addr_hit_read[50]: begin
        reg_rdata_next[31:0] = intr_src_addr_9_qs;
      end
      racl_addr_hit_read[51]: begin
        reg_rdata_next[31:0] = intr_src_addr_10_qs;
      end
      racl_addr_hit_read[52]: begin
        reg_rdata_next[31:0] = intr_src_wr_val_0_qs;
      end
      racl_addr_hit_read[53]: begin
        reg_rdata_next[31:0] = intr_src_wr_val_1_qs;
      end
      racl_addr_hit_read[54]: begin
        reg_rdata_next[31:0] = intr_src_wr_val_2_qs;
      end
      racl_addr_hit_read[55]: begin
        reg_rdata_next[31:0] = intr_src_wr_val_3_qs;
      end
      racl_addr_hit_read[56]: begin
        reg_rdata_next[31:0] = intr_src_wr_val_4_qs;
      end
      racl_addr_hit_read[57]: begin
        reg_rdata_next[31:0] = intr_src_wr_val_5_qs;
      end
      racl_addr_hit_read[58]: begin
        reg_rdata_next[31:0] = intr_src_wr_val_6_qs;
      end
      racl_addr_hit_read[59]: begin
        reg_rdata_next[31:0] = intr_src_wr_val_7_qs;
      end
      racl_addr_hit_read[60]: begin
        reg_rdata_next[31:0] = intr_src_wr_val_8_qs;
      end
      racl_addr_hit_read[61]: begin
        reg_rdata_next[31:0] = intr_src_wr_val_9_qs;
      end
      racl_addr_hit_read[62]: begin
        reg_rdata_next[31:0] = intr_src_wr_val_10_qs;
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
