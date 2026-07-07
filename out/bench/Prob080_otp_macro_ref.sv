
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

module prim_blanker #(
  parameter int Width = 1
) (
  input  logic [Width-1:0] in_i,
  input  logic             en_i,
  output logic [Width-1:0] out_o
);
  prim_and2 #(.Width(Width)) u_blank_and (
    .in0_i(in_i),
    .in1_i({Width{en_i}}),
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
module prim_lc_sync #(
  
  
  
  
  parameter int NumCopies = 1,
  
  
  
  parameter bit AsyncOn = 1,
  
  
  parameter bit ResetValueIsOn = 0
) (
  input                                       clk_i,
  input                                       rst_ni,
  input  lc_ctrl_pkg::lc_tx_t                 lc_en_i,
  output lc_ctrl_pkg::lc_tx_t [NumCopies-1:0] lc_en_o
);
  localparam lc_ctrl_pkg::lc_tx_t LcResetValue = (ResetValueIsOn) ? lc_ctrl_pkg::On :
                                                                  lc_ctrl_pkg::Off;
  `ASSERT_INIT(NumCopiesMustBeGreaterZero_A, NumCopies > 0)
  logic [lc_ctrl_pkg::TxWidth-1:0] lc_en;
  if (AsyncOn) begin : gen_flops
    prim_flop_2sync #(
      .Width(lc_ctrl_pkg::TxWidth),
      .ResetValue(lc_ctrl_pkg::TxWidth'(LcResetValue))
    ) u_prim_flop_2sync (
      .clk_i,
      .rst_ni,
      .d_i(lc_en_i),
      .q_o(lc_en)
    );
`ifdef INC_ASSERT
      lc_ctrl_pkg::lc_tx_t lc_en_in_sva_q;
      always_ff @(posedge clk_i) begin
        lc_en_in_sva_q <= lc_en_i;
      end
    `ASSERT(OutputDelay_A,
            rst_ni |-> ##3 lc_en_o == {NumCopies{$past(lc_en_in_sva_q, 2)}} ||
                           ($past(lc_en_in_sva_q, 2) != $past(lc_en_in_sva_q, 1)))
`endif
  end else begin : gen_no_flops
    
    
    
    
    
    
    lc_ctrl_pkg::lc_tx_t unused_logic;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
         unused_logic <= lc_ctrl_pkg::Off;
      end else begin
         unused_logic <= lc_en_i;
      end
    end
    
    
    assign lc_en = lc_en_i;
    `ASSERT(OutputDelay_A, lc_en_o == {NumCopies{lc_en_i}})
  end
  for (genvar j = 0; j < NumCopies; j++) begin : gen_buffs
    logic [lc_ctrl_pkg::TxWidth-1:0] lc_en_out;
    for (genvar k = 0; k < lc_ctrl_pkg::TxWidth; k++) begin : gen_bits
      prim_sec_anchor_buf u_prim_buf (
        .in_i(lc_en[k]),
        .out_o(lc_en_out[k])
      );
    end
    assign lc_en_o[j] = lc_ctrl_pkg::lc_tx_t'(lc_en_out);
  end
  
  
  
  
  `ASSERT_KNOWN(OutputsKnown_A, lc_en_o)
endmodule : prim_lc_sync

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
module prim_ram_1p_adv import prim_ram_1p_pkg::*; #(
  parameter  int Depth                = 512,
  
  
  parameter  int InstDepth            = Depth,
  parameter  int Width                = 32,
  parameter  int DataBitsPerMask      = 1,  
  parameter      MemInitFile          = "", 
  
  parameter  bit EnableECC            = 0, 
  parameter  bit EnableParity         = 0, 
  parameter  bit EnableInputPipeline  = 0, 
  parameter  bit EnableOutputPipeline = 0, 
  
  
  
  parameter bit HammingECC            = 0,
  localparam int Aw                   = prim_util_pkg::vbits(Depth),
  
  localparam int NumRamInst           = prim_util_pkg::ceil_div(Depth, InstDepth),
  localparam int InstAw               = prim_util_pkg::vbits(InstDepth)
) (
  input clk_i,
  input rst_ni,
  input                               req_i,
  input                               write_i,
  input        [Aw-1:0]               addr_i,
  input        [Width-1:0]            wdata_i,
  input        [Width-1:0]            wmask_i,
  output logic [Width-1:0]            rdata_o,
  output logic                        rvalid_o, 
  output logic [1:0]                  rerror_o, 
  
  input  ram_1p_cfg_t     [NumRamInst-1:0] cfg_i,
  output ram_1p_cfg_rsp_t [NumRamInst-1:0] cfg_rsp_o,
  
  output logic                             alert_o
);
  import prim_mubi_pkg::mubi4_t;
  import prim_mubi_pkg::mubi4_and_hi;
  import prim_mubi_pkg::mubi4_bool_to_mubi;
  import prim_mubi_pkg::mubi4_test_invalid;
  import prim_mubi_pkg::mubi4_test_true_loose;
  import prim_mubi_pkg::mubi4_test_true_strict;
  import prim_mubi_pkg::MuBi4True;
  import prim_mubi_pkg::MuBi4False;
  import prim_mubi_pkg::MuBi4Width;
  `ASSERT_INIT(CannotHaveEccAndParity_A, !(EnableParity && EnableECC))
  
  localparam int ParWidth  = (EnableParity) ? Width/8 :
                             (!EnableECC)   ? 0 :
                             (Width <=   4) ? 4 :
                             (Width <=  11) ? 5 :
                             (Width <=  26) ? 6 :
                             (Width <=  57) ? 7 :
                             (Width <= 120) ? 8 : 8 ;
  localparam int TotalWidth = Width + ParWidth;
  
  
  
  localparam int LocalDataBitsPerMask = (EnableParity) ? 9          :
                                        (EnableECC)    ? TotalWidth :
                                                         DataBitsPerMask;
  
  
  
  mubi4_t                  req_q,     req_d,    req_buf_d ;
  logic [MuBi4Width-1:0]   req_buf_b_d;
  logic                    req_q_b ;
  mubi4_t                  write_q,   write_d,  write_buf_d ;
  logic [MuBi4Width-1:0]   write_buf_b_d;
  logic                    write_q_b ;
  logic [Aw-1:0]           addr_q,    addr_d ;
  logic [TotalWidth-1:0]   wdata_q,   wdata_d ;
  logic [TotalWidth-1:0]   wmask_q,   wmask_d ;
  mubi4_t                  rvalid_q,  rvalid_d, rvalid_sram_q, rvalid_sram_d ;
  logic [Width-1:0]        rdata_q,   rdata_d ;
  logic [TotalWidth-1:0]   rdata_sram ;
  logic [1:0]              rerror_q,  rerror_d ;
  assign req_q_b = mubi4_test_true_loose(req_q);
  assign write_q_b = mubi4_test_true_loose(write_q);
  logic [NumRamInst-1:0] inst_req_d, inst_req_q, rvalid_inst;
  logic [InstAw-1:0] inst_addr;
  logic [NumRamInst-1:0] [Width-1:0] inst_rdata;
  
  assign inst_addr = addr_q[InstAw-1:0];
  
  
  
  if (NumRamInst == 1) begin : gen_single_inst_req
    assign inst_req_d[0] = req_q_b;
  end else begin : gen_multi_inst_req
    always_comb begin
      inst_req_d = '0;
      for (int i = 0; i < NumRamInst; i++) begin
        if (req_q_b && (i == addr_q[Aw-1:InstAw])) begin
          inst_req_d[i] = 1'b1;
        end
      end
    end
  end
  
  
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      inst_req_q <= '0;
    end else begin
      inst_req_q <= inst_req_d;
    end
  end
  
  `ASSERT(OneHotInstReq_A, $onehot0(inst_req_d))
  for (genvar i = 0; i < NumRamInst; i++) begin : gen_ram_inst
    prim_ram_1p #(
      .MemInitFile     (MemInitFile),
      .Width           (TotalWidth),
      .Depth           (InstDepth),
      .DataBitsPerMask (LocalDataBitsPerMask)
    ) u_mem (
      .clk_i,
      .rst_ni,
      .req_i     (inst_req_d[i]),
      .write_i   (write_q_b),
      .addr_i    (inst_addr),
      .wdata_i   (wdata_q),
      .wmask_i   (wmask_q),
      .rdata_o   (inst_rdata[i]),
      .cfg_i     (cfg_i[i]),
      .cfg_rsp_o (cfg_rsp_o[i])
    );
  end
  
  always_comb begin
    rdata_sram = '0;
    for (int i = 0; i < NumRamInst; i++) begin
      
      
      rvalid_inst[i] = mubi4_test_true_strict(
        mubi4_and_hi(mubi4_bool_to_mubi(inst_req_q[i]), rvalid_sram_q));
      if(rvalid_inst[i]) begin
        rdata_sram = inst_rdata[i];
      end
    end
  end
  assign rvalid_sram_d = mubi4_and_hi(req_q, mubi4_t'(~write_q));
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rvalid_sram_q <= MuBi4False;
    end else begin
      rvalid_sram_q <= rvalid_sram_d;
    end
  end
  assign req_d              = mubi4_bool_to_mubi(req_i);
  assign write_d            = mubi4_bool_to_mubi(write_i);
  assign addr_d             = addr_i;
  assign rvalid_o           = mubi4_test_true_loose(rvalid_q);
  assign rdata_o            = rdata_q;
  assign rerror_o           = rerror_q;
  prim_buf #(
    .Width(MuBi4Width)
  ) u_req_d_buf (
    .in_i (req_d),
    .out_o(req_buf_b_d)
  );
  assign req_buf_d = mubi4_t'(req_buf_b_d);
  prim_buf #(
    .Width(MuBi4Width)
  ) u_write_d_buf (
    .in_i (write_d),
    .out_o(write_buf_b_d)
  );
  assign write_buf_d = mubi4_t'(write_buf_b_d);
  
  
  
  if (EnableParity == 0 && EnableECC) begin : gen_secded
    logic unused_wmask;
    assign unused_wmask = ^wmask_i;
    
    `ASSERT_INIT(SecDecWidth_A, Width inside {16, 32})
    
    `ASSERT(OnlyWordWritePossibleWithEccPortA_A, req_i |->
          wmask_i == {Width{1'b1}})
    assign wmask_d = {TotalWidth{1'b1}};
    if (Width == 16) begin : gen_secded_22_16
      if (HammingECC) begin : gen_hamming
        prim_secded_inv_hamming_22_16_enc u_enc (
          .data_i(wdata_i),
          .data_o(wdata_d)
        );
        prim_secded_inv_hamming_22_16_dec u_dec (
          .data_i     (rdata_sram),
          .data_o     (rdata_d[0+:Width]),
          .syndrome_o ( ),
          .err_o      (rerror_d)
        );
      end else begin : gen_hsiao
        prim_secded_inv_22_16_enc u_enc (
          .data_i(wdata_i),
          .data_o(wdata_d)
        );
        prim_secded_inv_22_16_dec u_dec (
          .data_i     (rdata_sram),
          .data_o     (rdata_d[0+:Width]),
          .syndrome_o ( ),
          .err_o      (rerror_d)
        );
      end
    end else if (Width == 32) begin : gen_secded_39_32
      if (HammingECC) begin : gen_hamming
        prim_secded_inv_hamming_39_32_enc u_enc (
          .data_i(wdata_i),
          .data_o(wdata_d)
        );
        prim_secded_inv_hamming_39_32_dec u_dec (
          .data_i     (rdata_sram),
          .data_o     (rdata_d[0+:Width]),
          .syndrome_o ( ),
          .err_o      (rerror_d)
        );
      end else begin : gen_hsiao
        prim_secded_inv_39_32_enc u_enc (
          .data_i(wdata_i),
          .data_o(wdata_d)
        );
        prim_secded_inv_39_32_dec u_dec (
          .data_i     (rdata_sram),
          .data_o     (rdata_d[0+:Width]),
          .syndrome_o ( ),
          .err_o      (rerror_d)
        );
      end
    end
  end else if (EnableParity) begin : gen_byte_parity
    `ASSERT_INIT(WidthNeedsToBeByteAligned_A, Width % 8 == 0)
    `ASSERT_INIT(ParityNeedsByteWriteMask_A, DataBitsPerMask == 8)
    always_comb begin : p_parity
      rerror_d = '0;
      for (int i = 0; i < Width/8; i ++) begin
        
        
        
        wmask_d[i*9 +: 8] = wmask_i[i*8 +: 8];
        wdata_d[i*9 +: 8] = wdata_i[i*8 +: 8];
        rdata_d[i*8 +: 8] = rdata_sram[i*9 +: 8];
        
        wdata_d[i*9 + 8] = ~(^wdata_i[i*8 +: 8]);
        wmask_d[i*9 + 8] = &wmask_i[i*8 +: 8];
        
        rerror_d[1] |= ~(^{rdata_sram[i*9 +: 8], rdata_sram[i*9 + 8]});
      end
    end
  end else begin : gen_nosecded_noparity
    assign wmask_d = wmask_i;
    assign wdata_d = wdata_i;
    assign rdata_d  = rdata_sram[0+:Width];
    assign rerror_d = '0;
  end
  assign rvalid_d = rvalid_sram_q;
  
  
  
  if (EnableInputPipeline) begin : gen_regslice_input
    
    
    
    if (EnableECC || EnableParity) begin : gen_prim_flop
      prim_flop #(
        .Width(MuBi4Width),
        .ResetValue(MuBi4Width'(MuBi4False))
      ) u_write_flop (
        .clk_i,
        .rst_ni,
        .d_i(MuBi4Width'(write_buf_d)),
        .q_o({write_q})
      );
      prim_flop #(
        .Width(MuBi4Width),
        .ResetValue(MuBi4Width'(MuBi4False))
      ) u_req_flop (
        .clk_i,
        .rst_ni,
        .d_i(MuBi4Width'(req_buf_d)),
        .q_o({req_q})
      );
    end else begin: gen_no_prim_flop
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          write_q <= MuBi4False;
          req_q   <= MuBi4False;
        end else begin
          write_q <= write_buf_d;
          req_q   <= req_buf_d;
        end
      end
    end
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        addr_q  <= '0;
        wdata_q <= '0;
        wmask_q <= '0;
      end else begin
        addr_q  <= addr_d;
        wdata_q <= wdata_d;
        wmask_q <= wmask_d;
      end
    end
  end else begin : gen_dirconnect_input
    assign req_q   = req_buf_d;
    assign write_q = write_buf_d;
    assign addr_q  = addr_d;
    assign wdata_q = wdata_d;
    assign wmask_q = wmask_d;
  end
  if (EnableOutputPipeline) begin : gen_regslice_output
    
    
    
    if (EnableECC || EnableParity) begin : gen_prim_rvalid_flop
      prim_flop #(
        .Width(MuBi4Width),
        .ResetValue(MuBi4Width'(MuBi4False))
      ) u_rvalid_flop (
        .clk_i,
        .rst_ni,
        .d_i(MuBi4Width'(rvalid_d)),
        .q_o({rvalid_q})
      );
    end else begin: gen_no_prim_rvalid_flop
      always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
          rvalid_q <= MuBi4False;
        end else begin
          rvalid_q <= rvalid_d;
        end
      end
    end
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        rdata_q  <= '0;
        rerror_q <= '0;
      end else begin
        rdata_q  <= rdata_d;
        
        rerror_q <= rerror_d & {2{mubi4_test_true_loose(rvalid_d)}};
      end
    end
  end else begin : gen_dirconnect_output
    assign rvalid_q = rvalid_d;
    assign rdata_q  = rdata_d;
    
    assign rerror_q = rerror_d & {2{mubi4_test_true_loose(rvalid_d)}};
  end
  assign alert_o = mubi4_test_invalid(req_q) | mubi4_test_invalid(write_q) |
                   mubi4_test_invalid(rvalid_q) | mubi4_test_invalid(rvalid_sram_q);
endmodule : prim_ram_1p_adv

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

module prim_secded_22_16_dec (
  input        [21:0] data_i,
  output logic [15:0] data_o,
  output logic [5:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_22_16_dec

module prim_secded_22_16_enc (
  input        [15:0] data_i,
  output logic [21:0] data_o
);
  always_comb begin : p_encode
    data_o = 22'(data_i);
    data_o[16] = ^(data_o & 22'h00496E);
    data_o[17] = ^(data_o & 22'h00F20B);
    data_o[18] = ^(data_o & 22'h008ED8);
    data_o[19] = ^(data_o & 22'h007714);
    data_o[20] = ^(data_o & 22'h00ACA5);
    data_o[21] = ^(data_o & 22'h0011F3);
  end
endmodule : prim_secded_22_16_enc

module prim_secded_28_22_dec (
  input        [27:0] data_i,
  output logic [21:0] data_o,
  output logic [5:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_28_22_dec

module prim_secded_28_22_enc (
  input        [21:0] data_i,
  output logic [27:0] data_o
);
  always_comb begin : p_encode
    data_o = 28'(data_i);
    data_o[22] = ^(data_o & 28'h03003FF);
    data_o[23] = ^(data_o & 28'h010FC0F);
    data_o[24] = ^(data_o & 28'h0271C71);
    data_o[25] = ^(data_o & 28'h03B6592);
    data_o[26] = ^(data_o & 28'h03DAAA4);
    data_o[27] = ^(data_o & 28'h03ED348);
  end
endmodule : prim_secded_28_22_enc

module prim_secded_39_32_dec (
  input        [38:0] data_i,
  output logic [31:0] data_o,
  output logic [6:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_39_32_dec

module prim_secded_39_32_enc (
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
  end
endmodule : prim_secded_39_32_enc

module prim_secded_64_57_dec (
  input        [63:0] data_i,
  output logic [56:0] data_o,
  output logic [6:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_64_57_dec

module prim_secded_64_57_enc (
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
  end
endmodule : prim_secded_64_57_enc

module prim_secded_72_64_dec (
  input        [71:0] data_i,
  output logic [63:0] data_o,
  output logic [7:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_72_64_dec

module prim_secded_72_64_enc (
  input        [63:0] data_i,
  output logic [71:0] data_o
);
  always_comb begin : p_encode
    data_o = 72'(data_i);
    data_o[64] = ^(data_o & 72'h00B9000000001FFFFF);
    data_o[65] = ^(data_o & 72'h005E00000FFFE0003F);
    data_o[66] = ^(data_o & 72'h0067003FF003E007C1);
    data_o[67] = ^(data_o & 72'h00CD0FC0F03C207842);
    data_o[68] = ^(data_o & 72'h00B671C711C4438884);
    data_o[69] = ^(data_o & 72'h00B5B65926488C9108);
    data_o[70] = ^(data_o & 72'h00CBDAAA4A91152210);
    data_o[71] = ^(data_o & 72'h007AED348D221A4420);
  end
endmodule : prim_secded_72_64_enc

module prim_secded_hamming_22_16_dec (
  input        [21:0] data_i,
  output logic [15:0] data_o,
  output logic [5:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_hamming_22_16_dec

module prim_secded_hamming_22_16_enc (
  input        [15:0] data_i,
  output logic [21:0] data_o
);
  always_comb begin : p_encode
    data_o = 22'(data_i);
    data_o[16] = ^(data_o & 22'h00AD5B);
    data_o[17] = ^(data_o & 22'h00366D);
    data_o[18] = ^(data_o & 22'h00C78E);
    data_o[19] = ^(data_o & 22'h0007F0);
    data_o[20] = ^(data_o & 22'h00F800);
    data_o[21] = ^(data_o & 22'h1FFFFF);
  end
endmodule : prim_secded_hamming_22_16_enc

module prim_secded_hamming_39_32_dec (
  input        [38:0] data_i,
  output logic [31:0] data_o,
  output logic [6:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_hamming_39_32_dec

module prim_secded_hamming_39_32_enc (
  input        [31:0] data_i,
  output logic [38:0] data_o
);
  always_comb begin : p_encode
    data_o = 39'(data_i);
    data_o[32] = ^(data_o & 39'h0056AAAD5B);
    data_o[33] = ^(data_o & 39'h009B33366D);
    data_o[34] = ^(data_o & 39'h00E3C3C78E);
    data_o[35] = ^(data_o & 39'h0003FC07F0);
    data_o[36] = ^(data_o & 39'h0003FFF800);
    data_o[37] = ^(data_o & 39'h00FC000000);
    data_o[38] = ^(data_o & 39'h3FFFFFFFFF);
  end
endmodule : prim_secded_hamming_39_32_enc

module prim_secded_hamming_72_64_dec (
  input        [71:0] data_i,
  output logic [63:0] data_o,
  output logic [7:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_hamming_72_64_dec

module prim_secded_hamming_72_64_enc (
  input        [63:0] data_i,
  output logic [71:0] data_o
);
  always_comb begin : p_encode
    data_o = 72'(data_i);
    data_o[64] = ^(data_o & 72'h00AB55555556AAAD5B);
    data_o[65] = ^(data_o & 72'h00CD9999999B33366D);
    data_o[66] = ^(data_o & 72'h00F1E1E1E1E3C3C78E);
    data_o[67] = ^(data_o & 72'h0001FE01FE03FC07F0);
    data_o[68] = ^(data_o & 72'h0001FFFE0003FFF800);
    data_o[69] = ^(data_o & 72'h0001FFFFFFFC000000);
    data_o[70] = ^(data_o & 72'h00FE00000000000000);
    data_o[71] = ^(data_o & 72'h7FFFFFFFFFFFFFFFFF);
  end
endmodule : prim_secded_hamming_72_64_enc

module prim_secded_hamming_76_68_dec (
  input        [75:0] data_i,
  output logic [67:0] data_o,
  output logic [7:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_hamming_76_68_dec

module prim_secded_hamming_76_68_enc (
  input        [67:0] data_i,
  output logic [75:0] data_o
);
  always_comb begin : p_encode
    data_o = 76'(data_i);
    data_o[68] = ^(data_o & 76'h00AAB55555556AAAD5B);
    data_o[69] = ^(data_o & 76'h00CCD9999999B33366D);
    data_o[70] = ^(data_o & 76'h000F1E1E1E1E3C3C78E);
    data_o[71] = ^(data_o & 76'h00F01FE01FE03FC07F0);
    data_o[72] = ^(data_o & 76'h00001FFFE0003FFF800);
    data_o[73] = ^(data_o & 76'h00001FFFFFFFC000000);
    data_o[74] = ^(data_o & 76'h00FFE00000000000000);
    data_o[75] = ^(data_o & 76'h7FFFFFFFFFFFFFFFFFF);
  end
endmodule : prim_secded_hamming_76_68_enc

module prim_secded_inv_22_16_dec (
  input        [21:0] data_i,
  output logic [15:0] data_o,
  output logic [5:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_inv_22_16_dec

module prim_secded_inv_22_16_enc (
  input        [15:0] data_i,
  output logic [21:0] data_o
);
  always_comb begin : p_encode
    data_o = 22'(data_i);
    data_o[16] = ^(data_o & 22'h00496E);
    data_o[17] = ^(data_o & 22'h00F20B);
    data_o[18] = ^(data_o & 22'h008ED8);
    data_o[19] = ^(data_o & 22'h007714);
    data_o[20] = ^(data_o & 22'h00ACA5);
    data_o[21] = ^(data_o & 22'h0011F3);
    data_o ^= 22'h2A0000;
  end
endmodule : prim_secded_inv_22_16_enc

module prim_secded_inv_28_22_dec (
  input        [27:0] data_i,
  output logic [21:0] data_o,
  output logic [5:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_inv_28_22_dec

module prim_secded_inv_28_22_enc (
  input        [21:0] data_i,
  output logic [27:0] data_o
);
  always_comb begin : p_encode
    data_o = 28'(data_i);
    data_o[22] = ^(data_o & 28'h03003FF);
    data_o[23] = ^(data_o & 28'h010FC0F);
    data_o[24] = ^(data_o & 28'h0271C71);
    data_o[25] = ^(data_o & 28'h03B6592);
    data_o[26] = ^(data_o & 28'h03DAAA4);
    data_o[27] = ^(data_o & 28'h03ED348);
    data_o ^= 28'hA800000;
  end
endmodule : prim_secded_inv_28_22_enc

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

module prim_secded_inv_72_64_dec (
  input        [71:0] data_i,
  output logic [63:0] data_o,
  output logic [7:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_inv_72_64_dec

module prim_secded_inv_72_64_enc (
  input        [63:0] data_i,
  output logic [71:0] data_o
);
  always_comb begin : p_encode
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
  end
endmodule : prim_secded_inv_72_64_enc

module prim_secded_inv_hamming_22_16_dec (
  input        [21:0] data_i,
  output logic [15:0] data_o,
  output logic [5:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_inv_hamming_22_16_dec

module prim_secded_inv_hamming_22_16_enc (
  input        [15:0] data_i,
  output logic [21:0] data_o
);
  always_comb begin : p_encode
    data_o = 22'(data_i);
    data_o[16] = ^(data_o & 22'h00AD5B);
    data_o[17] = ^(data_o & 22'h00366D);
    data_o[18] = ^(data_o & 22'h00C78E);
    data_o[19] = ^(data_o & 22'h0007F0);
    data_o[20] = ^(data_o & 22'h00F800);
    data_o[21] = ^(data_o & 22'h1FFFFF);
    data_o ^= 22'h2A0000;
  end
endmodule : prim_secded_inv_hamming_22_16_enc

module prim_secded_inv_hamming_39_32_dec (
  input        [38:0] data_i,
  output logic [31:0] data_o,
  output logic [6:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_inv_hamming_39_32_dec

module prim_secded_inv_hamming_39_32_enc (
  input        [31:0] data_i,
  output logic [38:0] data_o
);
  always_comb begin : p_encode
    data_o = 39'(data_i);
    data_o[32] = ^(data_o & 39'h0056AAAD5B);
    data_o[33] = ^(data_o & 39'h009B33366D);
    data_o[34] = ^(data_o & 39'h00E3C3C78E);
    data_o[35] = ^(data_o & 39'h0003FC07F0);
    data_o[36] = ^(data_o & 39'h0003FFF800);
    data_o[37] = ^(data_o & 39'h00FC000000);
    data_o[38] = ^(data_o & 39'h3FFFFFFFFF);
    data_o ^= 39'h2A00000000;
  end
endmodule : prim_secded_inv_hamming_39_32_enc

module prim_secded_inv_hamming_72_64_dec (
  input        [71:0] data_i,
  output logic [63:0] data_o,
  output logic [7:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_inv_hamming_72_64_dec

module prim_secded_inv_hamming_72_64_enc (
  input        [63:0] data_i,
  output logic [71:0] data_o
);
  always_comb begin : p_encode
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
  end
endmodule : prim_secded_inv_hamming_72_64_enc

module prim_secded_inv_hamming_76_68_dec (
  input        [75:0] data_i,
  output logic [67:0] data_o,
  output logic [7:0] syndrome_o,
  output logic [1:0] err_o
);
  always_comb begin : p_encode
    
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
  end
endmodule : prim_secded_inv_hamming_76_68_dec

module prim_secded_inv_hamming_76_68_enc (
  input        [67:0] data_i,
  output logic [75:0] data_o
);
  always_comb begin : p_encode
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
  end
endmodule : prim_secded_inv_hamming_76_68_enc

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
module tlul_lc_gate
  import tlul_pkg::*;
  import lc_ctrl_pkg::*;
#(
  
  
  
  parameter int NumGatesPerDirection = 2,
  
  
  
  parameter bit ReturnBlankResp = 0,
  
  parameter int unsigned Outstanding = 3
) (
  input clk_i,
  input rst_ni,
  
  input  tl_h2d_t tl_h2d_i,
  output tl_d2h_t tl_d2h_o,
  
  output tl_h2d_t tl_h2d_o,
  input  tl_d2h_t tl_d2h_i,
  
  input flush_req_i,
  output logic flush_ack_o,
  
  output logic resp_pending_o,
  
  input  lc_tx_t  lc_en_i,
  output logic err_o
);
  
  
  
  lc_tx_t err_en;
  lc_tx_t [NumGatesPerDirection-1:0] err_en_buf;
  prim_lc_sync #(
    .NumCopies(NumGatesPerDirection),
    .AsyncOn(0)
  ) u_err_en_sync (
    .clk_i,
    .rst_ni,
    .lc_en_i(err_en),
    .lc_en_o(err_en_buf)
  );
  tl_h2d_t tl_h2d_int [NumGatesPerDirection+1];
  tl_d2h_t tl_d2h_int [NumGatesPerDirection+1];
  for (genvar k = 0; k < NumGatesPerDirection; k++) begin : gen_lc_gating_muxes
    
    prim_blanker #(
      .Width($bits(tl_h2d_t))
    ) u_prim_blanker_h2d (
      .in_i(tl_h2d_int[k]),
      .en_i(lc_tx_test_false_strict(err_en_buf[k])),
      .out_o(tl_h2d_int[k+1])
    );
    
    prim_blanker #(
      .Width($bits(tl_d2h_t))
    ) u_prim_blanker_d2h (
      .in_i(tl_d2h_int[k+1]),
      .en_i(lc_tx_test_false_strict(err_en_buf[k])),
      .out_o(tl_d2h_int[k])
    );
  end
  
  assign tl_h2d_o = tl_h2d_int[NumGatesPerDirection];
  assign tl_d2h_int[NumGatesPerDirection] = tl_d2h_i;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  localparam int StateWidth = 9;
  typedef enum logic [StateWidth-1:0] {
    StActive = 9'b100100001,
    StOutstanding = 9'b011100111,
    StFlush = 9'b001001100,
    StError = 9'b010111010,
    StErrorOutstanding = 9'b100010110
  } state_e;
  state_e state_d, state_q;
  `PRIM_FLOP_SPARSE_FSM(u_state_regs, state_d, state_q, state_e, StError)
  logic [prim_util_pkg::vbits(Outstanding+1)-1:0] outstanding_txn;
  logic a_ack;
  logic d_ack;
  assign a_ack = tl_h2d_i.a_valid & tl_d2h_o.a_ready;
  assign d_ack = tl_h2d_i.d_ready & tl_d2h_o.d_valid;
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      outstanding_txn <= '0;
    end else if (a_ack && !d_ack) begin
      outstanding_txn <= outstanding_txn + 1'b1;
    end else if (d_ack && !a_ack) begin
      outstanding_txn <= outstanding_txn - 1'b1;
    end
  end
  logic block_cmd;
  always_comb begin
    block_cmd = '0;
    state_d = state_q;
    err_en = Off;
    err_o = '0;
    flush_ack_o = '0;
    resp_pending_o = 1'b0;
    unique case (state_q)
      StActive: begin
        if (lc_tx_test_false_loose(lc_en_i) || flush_req_i) begin
          state_d = StOutstanding;
        end
        if (outstanding_txn != '0) begin
          resp_pending_o = 1'b1;
        end
      end
      StOutstanding: begin
        block_cmd = 1'b1;
        if (outstanding_txn == '0) begin
          state_d = lc_tx_test_false_loose(lc_en_i) ? StError : StFlush;
        end else begin
          resp_pending_o = 1'b1;
        end
      end
      StFlush: begin
        block_cmd = 1'b1;
        flush_ack_o = 1'b1;
        if (lc_tx_test_false_loose(lc_en_i)) begin
          state_d = StError;
        end else if (!flush_req_i) begin
          state_d = StActive;
        end
      end
      StError: begin
        err_en = On;
        if (lc_tx_test_true_strict(lc_en_i)) begin
          state_d = StErrorOutstanding;
        end
      end
      StErrorOutstanding: begin
        err_en = On;
        block_cmd = 1'b1;
        if (outstanding_txn == '0) begin
          state_d = StActive;
        end
      end
      default: begin
        err_o = 1'b1;
        err_en = On;
      end
    endcase 
  end
  
  
  
  tl_h2d_t tl_h2d_error;
  tl_d2h_t tl_d2h_error;
  always_comb begin
    tl_h2d_int[0] = tl_h2d_i;
    tl_d2h_o      = tl_d2h_int[0];
    tl_h2d_error  = '0;
    if (lc_tx_test_true_loose(err_en)) begin
      tl_h2d_error  = tl_h2d_i;
      tl_d2h_o      = tl_d2h_error;
    end
    if (block_cmd) begin
      tl_d2h_o.a_ready = 1'b0;
      tl_h2d_int[0].a_valid = 1'b0;
      tl_h2d_error.a_valid = 1'b0;
    end
  end
  tlul_err_resp #(
    .ReturnBlankResp(ReturnBlankResp)
  ) u_tlul_err_resp (
    .clk_i,
    .rst_ni,
    .tl_h_i(tl_h2d_error),
    .tl_h_o(tl_d2h_error)
  );
  
  `ASSERT(OutStandingOvfl_A, (outstanding_txn == Outstanding) |-> ~a_ack)
  `ASSERT(SizeOutstandingTxn_A, (2 ** $bits(outstanding_txn)) - 1 >= Outstanding)
endmodule : tlul_lc_gate

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
  import otp_ctrl_macro_pkg::*;
  import otp_macro_reg_pkg::*;
  import otp_macro_pkg::*;
#(
  
  parameter  int    Width            = 16,
  parameter  int    Depth            = 1024,
  
  
  parameter  int    SizeWidth        = 2,
  
  parameter         MemInitFile   = "",
  
  parameter  int    VendorTestOffset = 0,
  parameter  int    VendorTestSize   = 0,
  
  parameter bit  EnableRacl       = 1'b0,
  parameter bit  RaclErrorRsp     = 1'b1,
  parameter top_racl_pkg::racl_policy_sel_t RaclPolicySelVec[otp_macro_reg_pkg::NumRegsPrim] =
    '{otp_macro_reg_pkg::NumRegsPrim{0}}
) (
  input                          clk_i,
  input                          rst_ni,
  
  input                          tlul_pkg::tl_h2d_t prim_tl_i,
  output                         tlul_pkg::tl_d2h_t prim_tl_o,
  
  
  input                          lc_ctrl_pkg::lc_tx_t lc_dft_en_i,
  input                          ast_pkg::ast_obs_ctrl_t obs_ctrl_i,
  output logic [7:0]             otp_obs_o,
  
  output pwr_seq_t               pwr_seq_o,
  input  pwr_seq_t               pwr_seq_h_i,
  
  inout wire                     ext_voltage_h_io,
  
  input                          otp_test_req_t test_i,
  output                         otp_test_rsp_t test_o,
  output                         otp_test_vect_t cio_test_o,
  output                         otp_test_vect_t cio_test_en_o,
  
  input                          prim_mubi_pkg::mubi4_t scanmode_i,
  input                          scan_en_i,
  input                          scan_rst_ni,
  
  input                          otp_ctrl_macro_req_t otp_i,
  output                         otp_ctrl_macro_rsp_t otp_o,
  
  input  top_racl_pkg::racl_policy_vec_t  racl_policies_i,
  output top_racl_pkg::racl_error_log_t   racl_error_o,
  
  input                          otp_cfg_t cfg_i,
  output                         otp_cfg_rsp_t cfg_rsp_o
);
  
  
  import prim_mubi_pkg::MuBi4False;
  
  
  if (!prim_secded_pkg::is_width_valid(prim_secded_pkg::SecdedHamming, Width))
    $error("Width %0d is not supported for SecdedHamming", Width);
  
  localparam int EccWidth = prim_secded_pkg::get_synd_width(prim_secded_pkg::SecdedHamming, Width);
  
  pwr_seq_t unused_pwr_seq_h;
  assign unused_pwr_seq_h = pwr_seq_h_i;
  assign pwr_seq_o = '0;
  logic unused_obs;
  assign unused_obs = |obs_ctrl_i;
  assign otp_obs_o = '0;
  wire unused_ext_voltage;
  assign unused_ext_voltage = ext_voltage_h_io;
  logic unused_test_ctrl_i;
  assign unused_test_ctrl_i = ^test_i.ctrl;
  logic unused_scan;
  assign unused_scan = ^{scanmode_i, scan_en_i, scan_rst_ni};
  logic lc_fsm_err, intg_err, fsm_err;
  assign otp_o.fatal_lc_fsm_err = lc_fsm_err;
  assign otp_o.fatal_alert = intg_err || fsm_err;
  assign otp_o.recov_alert = 1'b0;
  otp_test_vect_t test_vect;
  assign test_vect = '0;
  assign test_o.status = '0;
  logic unused_cfg;
  assign unused_cfg = ^cfg_i;
  assign cfg_rsp_o  = '0;
  
  
  
  lc_ctrl_pkg::lc_tx_t [2:0] lc_dft_en;
  prim_lc_sync #(
    .NumCopies(3)
  ) u_prim_lc_sync_dft_en (
    .clk_i,
    .rst_ni,
    .lc_en_i(lc_dft_en_i),
    .lc_en_o(lc_dft_en)
  );
  
  
  assign cio_test_o    = (lc_ctrl_pkg::lc_tx_test_true_strict(lc_dft_en[1])) ?
                         test_vect            : '0;
  assign cio_test_en_o = (lc_ctrl_pkg::lc_tx_test_true_strict(lc_dft_en[2])) ?
                         {OtpTestVectWidth{1'b1}} : '0;
  
  
  
  tlul_pkg::tl_h2d_t           tl_h2d_gated;
  tlul_pkg::tl_d2h_t           tl_d2h_gated;
  
  
  
  tlul_lc_gate #(
    .NumGatesPerDirection(2)
  ) u_tlul_lc_gate (
    .clk_i,
    .rst_ni,
    .tl_h2d_i(prim_tl_i),
    .tl_d2h_o(prim_tl_o),
    .tl_h2d_o(tl_h2d_gated),
    .tl_d2h_i(tl_d2h_gated),
    .lc_en_i (lc_dft_en[0]),
    .flush_req_i('0),
    .flush_ack_o(),
    .resp_pending_o(),
    .err_o   (lc_fsm_err)
  );
  otp_macro_reg_pkg::otp_macro_prim_reg2hw_t reg2hw;
  otp_macro_reg_pkg::otp_macro_prim_hw2reg_t hw2reg;
  otp_macro_prim_reg_top #(
    .EnableRacl       ( EnableRacl       ),
    .RaclErrorRsp     ( RaclErrorRsp     ),
    .RaclPolicySelVec ( RaclPolicySelVec )
  ) u_reg_top (
    .clk_i,
    .rst_ni,
    .tl_i      (tl_h2d_gated ),
    .tl_o      (tl_d2h_gated ),
    .reg2hw    (reg2hw    ),
    .hw2reg    (hw2reg    ),
    .intg_err_o(intg_err  ),
    .racl_policies_i,
    .racl_error_o
  );
  logic unused_reg_sig;
  assign unused_reg_sig = ^reg2hw;
  assign hw2reg = '0;
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  localparam int StateWidth = 11;
  typedef enum logic [StateWidth-1:0] {
    ResetSt       = 11'b10000100011,
    InitSt        = 11'b11101011000,
    IdleSt        = 11'b10110111001,
    ReadSt        = 11'b01000101110,
    ReadWaitSt    = 11'b10111000101,
    WriteCheckSt  = 11'b11011000010,
    WriteWaitSt   = 11'b00110010110,
    WriteSt       = 11'b01010010001,
    ZerWriteSt    = 11'b00101100000,
    ZerReadSt     = 11'b00001111101,
    ZerReadWaitSt = 11'b01111101011,
    ErrorSt       = 11'b11101110111
  } state_e;
  state_e state_d, state_q;
  err_e err_d, err_q;
  logic valid_d, valid_q;
  logic integrity_en_d, integrity_en_q;
  logic req, wren, rvalid;
  logic [1:0] rerror;
  otp_macro_addr_t addr_q;
  logic [SizeWidth-1:0] size_q;
  logic [SizeWidth-1:0] cnt_d, cnt_q;
  logic cnt_clr, cnt_en;
  logic read_ecc_on, write_ecc_on;
  logic wdata_inconsistent;
  logic zer_en;
  
  assign otp_o.rvalid = valid_q;
  assign otp_o.err   = err_q;
  assign cnt_d = (cnt_clr) ? '0           :
                 (cnt_en)  ? cnt_q + 1'b1 : cnt_q;
  always_comb begin : p_fsm
    
    state_d        = state_q;
    otp_o.ready    = 1'b0;
    valid_d        = 1'b0;
    err_d          = err_q;
    req            = 1'b0;
    wren           = 1'b0;
    cnt_clr        = 1'b0;
    cnt_en         = 1'b0;
    read_ecc_on    = 1'b1;
    write_ecc_on   = 1'b1;
    fsm_err        = 1'b0;
    integrity_en_d = integrity_en_q;
    zer_en = 1'b0;
    unique case (state_q)
      
      ResetSt: begin
        err_d = NoError;
        otp_o.ready = 1'b1;
        if (otp_i.valid) begin
          if (otp_i.cmd == Init) begin
            state_d = InitSt;
          end
        end
      end
      
      InitSt: begin
        state_d = IdleSt;
        valid_d = 1'b1;
        err_d = NoError;
      end
      
      IdleSt: begin
        otp_o.ready = 1'b1;
        err_d = NoError;
        if (otp_i.valid) begin
          cnt_clr = 1'b1;
          err_d = NoError;
          unique case (otp_i.cmd)
            Read:  begin
              state_d = ReadSt;
              integrity_en_d = 1'b1;
            end
            Write: begin
              state_d = WriteCheckSt;
              integrity_en_d = 1'b1;
            end
            ReadRaw:  begin
              state_d = ReadSt;
              integrity_en_d = 1'b0;
            end
            WriteRaw: begin
              state_d = WriteCheckSt;
              integrity_en_d = 1'b0;
            end
            Zeroize: begin
              state_d = ZerWriteSt;
              integrity_en_d = 1'b0;
            end
            default: ;
          endcase 
        end
      end
      
      ReadSt: begin
        state_d = ReadWaitSt;
        req     = 1'b1;
        
        read_ecc_on = integrity_en_q;
      end
      
      ReadWaitSt: begin
        
        read_ecc_on = integrity_en_q;
        if (rvalid) begin
          cnt_en = 1'b1;
          
          if (rerror[1] && integrity_en_q) begin
            state_d = IdleSt;
            valid_d = 1'b1;
            err_d = MacroEccUncorrError;
          end else begin
            if (cnt_q == size_q) begin
              state_d = IdleSt;
              valid_d = 1'b1;
            end else begin
              state_d = ReadSt;
            end
            
            if (rerror[0] && integrity_en_q) begin
              err_d = MacroEccCorrError;
            end
          end
        end
      end
      
      
      WriteCheckSt: begin
        state_d = WriteWaitSt;
        req     = 1'b1;
        
        
        read_ecc_on = 1'b0;
      end
      
      WriteWaitSt: begin
        
        
        read_ecc_on = 1'b0;
        if (rvalid) begin
          cnt_en = 1'b1;
          if (cnt_q == size_q) begin
            cnt_clr = 1'b1;
            state_d = WriteSt;
          end else begin
            state_d = WriteCheckSt;
          end
        end
      end
      
      
      WriteSt: begin
        req = 1'b1;
        wren = 1'b1;
        cnt_en = 1'b1;
        
        write_ecc_on = integrity_en_q;
        if (wdata_inconsistent) begin
          err_d = MacroWriteBlankError;
        end
        if (cnt_q == size_q) begin
          valid_d = 1'b1;
          state_d = IdleSt;
        end
      end
      
      ZerWriteSt: begin
        req = 1'b1;
        wren = 1'b1;
        cnt_en = 1'b1;
        zer_en = 1'b1;
        if (cnt_q == size_q) begin
          state_d = ZerReadSt;
          cnt_clr = 1'b1;
        end
      end
      
      ZerReadSt: begin
        state_d = ZerReadWaitSt;
        req     = 1'b1;
        read_ecc_on = 1'b0;
      end
      
      ZerReadWaitSt: begin
        read_ecc_on = 1'b0;
        if (rvalid) begin
          cnt_en = 1'b1;
          if (cnt_q == size_q) begin
            state_d = IdleSt;
            valid_d = 1'b1;
          end else begin
            state_d = ZerReadSt;
          end
        end
      end
      
      ErrorSt: begin
        fsm_err = 1'b1;
      end
      default: begin
        state_d = ErrorSt;
        fsm_err = 1'b1;
      end
    endcase 
  end
  
  
  
  otp_macro_addr_t addr;
  assign addr = addr_q + otp_macro_addr_t'(cnt_q);
  logic [Width-1:0] rdata_corr;
  logic [Width+EccWidth-1:0] rdata_d, wdata_ecc, rdata_ecc, wdata_rmw;
  logic [2**SizeWidth-1:0][Width-1:0] wdata_q, rdata_reshaped;
  logic [2**SizeWidth-1:0][Width+EccWidth-1:0] rdata_q;
  
`define SECDED_INST_DEC(_TYPE, _WIDTH, _INST, _ENC_DATA, _DATA, _SYND, _ERR) \
  case (_TYPE)                                                               \
    prim_secded_pkg::SecdedHsiao: begin : gen_dec_hsiao                      \
      case (_WIDTH)                                                          \
        16: begin : gen_dec_hsiao_16                                         \
          prim_secded_22_16_dec _INST(                                       \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        22: begin : gen_dec_hsiao_22                                         \
          prim_secded_28_22_dec _INST(                                       \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        32: begin : gen_dec_hsiao_32                                         \
          prim_secded_39_32_dec _INST(                                       \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        57: begin : gen_dec_hsiao_57                                         \
          prim_secded_64_57_dec _INST(                                       \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        64: begin : gen_dec_hsiao_64                                         \
          prim_secded_72_64_dec _INST(                                       \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        default: begin : gen_dec_hsiao_default                               \
        end                                                                  \
      endcase                                                                \
    end                                                                      \
    prim_secded_pkg::SecdedHamming: begin : gen_dec_hamming                  \
      case (_WIDTH)                                                          \
        16: begin : gen_dec_hamming_16                                       \
          prim_secded_hamming_22_16_dec _INST(                               \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        32: begin : gen_dec_hamming_32                                       \
          prim_secded_hamming_39_32_dec _INST(                               \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        64: begin : gen_dec_hamming_64                                       \
          prim_secded_hamming_72_64_dec _INST(                               \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        68: begin : gen_dec_hamming_68                                       \
          prim_secded_hamming_76_68_dec _INST(                               \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        default: begin : gen_dec_hamming_default                             \
        end                                                                  \
      endcase                                                                \
    end                                                                      \
    prim_secded_pkg::SecdedInvHsiao: begin : gen_dec_inv_hsiao               \
      case (_WIDTH)                                                          \
        16: begin : gen_dec_inv_hsiao_16                                     \
          prim_secded_inv_22_16_dec _INST(                                   \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        22: begin : gen_dec_inv_hsiao_22                                     \
          prim_secded_inv_28_22_dec _INST(                                   \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        32: begin : gen_dec_inv_hsiao_32                                     \
          prim_secded_inv_39_32_dec _INST(                                   \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        57: begin : gen_dec_inv_hsiao_57                                     \
          prim_secded_inv_64_57_dec _INST(                                   \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        64: begin : gen_dec_inv_hsiao_64                                     \
          prim_secded_inv_72_64_dec _INST(                                   \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        default: begin : gen_dec_inv_hsiao_default                           \
        end                                                                  \
      endcase                                                                \
    end                                                                      \
    prim_secded_pkg::SecdedInvHamming: begin : gen_dec_inv_hamming           \
      case (_WIDTH)                                                          \
        16: begin : gen_dec_inv_hamming_16                                   \
          prim_secded_inv_hamming_22_16_dec _INST(                           \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        32: begin : gen_dec_inv_hamming_32                                   \
          prim_secded_inv_hamming_39_32_dec _INST(                           \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        64: begin : gen_dec_inv_hamming_64                                   \
          prim_secded_inv_hamming_72_64_dec _INST(                           \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        68: begin : gen_dec_inv_hamming_68                                   \
          prim_secded_inv_hamming_76_68_dec _INST(                           \
            .data_i(_ENC_DATA),                                              \
            .data_o(_DATA),                                                  \
            .syndrome_o(_SYND),                                              \
            .err_o(_ERR));                                                   \
        end                                                                  \
        default: begin : gen_dec_inv_hamming_default                         \
        end                                                                  \
      endcase                                                                \
    end                                                                      \
  endcase
`define SECDED_INST_ENC(_TYPE, _WIDTH, _INST, _DATA, _ENC_DATA) \
  case (_TYPE)                                                  \
    prim_secded_pkg::SecdedHsiao: begin : gen_enc_hsiao         \
      case (_WIDTH)                                             \
        16: begin : gen_enc_hsiao_16                            \
          prim_secded_22_16_enc _INST(                          \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        22: begin : gen_enc_hsiao_22                            \
          prim_secded_28_22_enc _INST(                          \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        32: begin : gen_enc_hsiao_32                            \
          prim_secded_39_32_enc _INST(                          \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        57: begin : gen_enc_hsiao_57                            \
          prim_secded_64_57_enc _INST(                          \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        64: begin : gen_enc_hsiao_64                            \
          prim_secded_72_64_enc _INST(                          \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        default: begin : gen_enc_hsiao_default                  \
        end                                                     \
      endcase                                                   \
    end                                                         \
    prim_secded_pkg::SecdedHamming: begin : gen_enc_hamming     \
      case (_WIDTH)                                             \
        16: begin : gen_enc_hamming_16                          \
          prim_secded_hamming_22_16_enc _INST(                  \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        32: begin : gen_enc_hamming_32                          \
          prim_secded_hamming_39_32_enc _INST(                  \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        64: begin : gen_enc_hamming_64                          \
          prim_secded_hamming_72_64_enc _INST(                  \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        68: begin : gen_enc_hamming_68                          \
          prim_secded_hamming_76_68_enc _INST(                  \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        default: begin : gen_enc_hamming_default                \
        end                                                     \
      endcase                                                   \
    end                                                         \
    prim_secded_pkg::SecdedInvHsiao: begin : gen_enc_inv_hsiao  \
      case (_WIDTH)                                             \
        16: begin : gen_enc_inv_hsiao_16                        \
          prim_secded_inv_22_16_enc _INST(                      \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        22: begin : gen_enc_inv_hsiao_22                        \
          prim_secded_inv_28_22_enc _INST(                      \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        32: begin : gen_enc_inv_hsiao_32                        \
          prim_secded_inv_39_32_enc _INST(                      \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        57: begin : gen_enc_inv_hsiao_57                        \
          prim_secded_inv_64_57_enc _INST(                      \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        64: begin : gen_enc_inv_hsiao_64                        \
          prim_secded_inv_72_64_enc _INST(                      \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        default: begin : gen_enc_inv_hsiao_default              \
        end                                                     \
      endcase                                                   \
    end                                                         \
    prim_secded_pkg::SecdedInvHamming: begin : gen_enc_inv_hamming \
      case (_WIDTH)                                             \
        16: begin : gen_enc_inv_hamming_16                      \
          prim_secded_inv_hamming_22_16_enc _INST(              \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        32: begin : gen_enc_inv_hamming_32                      \
          prim_secded_inv_hamming_39_32_enc _INST(              \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        64: begin : gen_enc_inv_hamming_64                      \
          prim_secded_inv_hamming_72_64_enc _INST(              \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        68: begin : gen_enc_inv_hamming_68                      \
          prim_secded_inv_hamming_76_68_enc _INST(              \
            .data_i(_DATA),                                     \
            .data_o(_ENC_DATA));                                \
        end                                                     \
        default: begin : gen_enc_inv_hamming_default            \
        end                                                     \
      endcase                                                   \
    end                                                         \
  endcase
`SECDED_INST_ENC(prim_secded_pkg::SecdedHamming, Width, u_enc, wdata_q[cnt_q], wdata_ecc)
`SECDED_INST_DEC(prim_secded_pkg::SecdedHamming, Width, u_dec, rdata_ecc, rdata_corr, , rerror)
`undef SECDED_INST_DEC
`undef SECDED_INST_ENC
  assign rdata_d = (read_ecc_on) ? {{EccWidth{1'b0}}, rdata_corr}
                                 : rdata_ecc;
  
  
  assign wdata_rmw = zer_en       ? '1 :
                     write_ecc_on ? wdata_ecc | rdata_q[cnt_q] :
                     {{EccWidth{1'b0}}, wdata_q[cnt_q]} | rdata_q[cnt_q];
  
  
  assign wdata_inconsistent = (rdata_q[cnt_q] & wdata_ecc) != rdata_q[cnt_q];
  
  always_comb begin : p_output_map
    for (int k = 0; k < 2**SizeWidth; k++) begin
      rdata_reshaped[k] = rdata_q[k][Width-1:0];
    end
    otp_o.rdata = rdata_reshaped;
  end
  prim_ram_1p_adv #(
    .Depth                (Depth),
    .Width                (Width + EccWidth),
    .MemInitFile          (MemInitFile),
    .EnableInputPipeline  (1),
    .EnableOutputPipeline (1)
  ) u_prim_ram_1p_adv (
    .clk_i,
    .rst_ni,
    .req_i    ( req                    ),
    .write_i  ( wren                   ),
    .addr_i   ( addr                   ),
    .wdata_i  ( wdata_rmw              ),
    .wmask_i  ( {Width+EccWidth{1'b1}} ),
    .rdata_o  ( rdata_ecc              ),
    .rvalid_o ( rvalid                 ),
    .rerror_o (                        ),
    .cfg_i    ( '0                     ),
    .cfg_rsp_o(                        ),
    .alert_o  (                        )
  );
  
  `ASSERT(NoWrapArounds_A, req |-> (addr >= addr_q))
  
  
  
 `PRIM_FLOP_SPARSE_FSM(u_state_regs, state_d, state_q, state_e, ResetSt)
  always_ff @(posedge clk_i or negedge rst_ni) begin : p_regs
    if (!rst_ni) begin
      valid_q <= '0;
      err_q   <= NoError;
      addr_q  <= '0;
      wdata_q <= '0;
      rdata_q <= '0;
      cnt_q   <= '0;
      size_q  <= '0;
      integrity_en_q <= 1'b0;
    end else begin
      valid_q <= valid_d;
      err_q   <= err_d;
      cnt_q   <= cnt_d;
      integrity_en_q <= integrity_en_d;
      if (otp_o.ready && otp_i.valid) begin
        addr_q  <= otp_i.addr;
        wdata_q <= otp_i.wdata;
        size_q  <= otp_i.size;
      end
      if (rvalid) begin
        rdata_q[cnt_q] <= rdata_d;
      end
    end
  end
  
  
  
  
  `ASSERT(CheckCommands0_A, state_q == ResetSt && otp_i.valid && otp_o.ready |-> otp_i.cmd == Init)
  `ASSERT(CheckCommands1_A, state_q != ResetSt && otp_i.valid && otp_o.ready
      |-> otp_i.cmd inside {Read, ReadRaw, Write, WriteRaw, Zeroize})
  
  `ASSERT_INIT(WidthMatches_A, Width == otp_ctrl_macro_pkg::OtpWidth)
  `ASSERT_INIT(DepthMatches_A, Depth == otp_ctrl_macro_pkg::OtpDepth)
  `ASSERT_INIT(SizeWidthMatches_A, SizeWidth == otp_ctrl_macro_pkg::OtpSizeWidth)
  `ASSERT_INIT(VendorTestOffsetMatches_A, VendorTestOffset == otp_ctrl_reg_pkg::VendorTestOffset)
  `ASSERT_INIT(VendorTestSizeMatches_A, VendorTestSize == otp_ctrl_reg_pkg::VendorTestSize)
  `ASSERT_KNOWN(OtpAstPwrSeqKnown_A, pwr_seq_o)
  `ASSERT_KNOWN(OtpMacroTlOutKnown_A, prim_tl_o)
  
  
  
  
  `ASSERT_ERROR_TRIGGER_ERR(PrimFsmCheck_A, u_state_regs, otp_o.fatal_alert, 0,
      `_SEC_CM_ALERT_MAX_CYC, unused_err_o, `ASSERT_DEFAULT_CLK, `ASSERT_DEFAULT_RST)
  `ASSUME_FPV(PrimFsmCheck_ATriggerAfterAlertInit_S,
              $stable(rst_ni) == 0 |-> u_state_regs.unused_err_o == 0 [*10])
  `ASSERT_ERROR_TRIGGER_ERR(TlLcGateFsm_A, u_tlul_lc_gate.u_state_regs, otp_o.fatal_lc_fsm_err, 0,
      `_SEC_CM_ALERT_MAX_CYC, unused_err_o, `ASSERT_DEFAULT_CLK, `ASSERT_DEFAULT_RST)
  `ASSUME_FPV(TlLcGateFsm_ATriggerAfterAlertInit_S,
              $stable(rst_ni) == 0 |-> u_tlul_lc_gate.u_state_regs.unused_err_o == 0 [*10])
  `ASSERT_ERROR_TRIGGER_ERR(PrimRegWeOnehotCheck_A,
      u_reg_top.u_prim_reg_we_check.u_prim_onehot_check, otp_o.fatal_alert, 0,
      `_SEC_CM_ALERT_MAX_CYC, err_o, `ASSERT_DEFAULT_CLK, `ASSERT_DEFAULT_RST)
  `ASSUME_FPV(PrimRegWeOneHotCheck_ATriggerAfterAlertInit_S,
              $stable(rst_ni) == 0 |-> u_state_regs.err_o == 0 [*10])
endmodule : TopModule

package otp_macro_pkg;
  parameter int OtpPwrSeqWidth     = 2;
  parameter int OtpTestCtrlWidth   = 32;
  parameter int OtpTestStatusWidth = 32;
  parameter int OtpTestVectWidth   = 8;
  
  typedef logic [OtpPwrSeqWidth-1:0] pwr_seq_t;
  typedef struct packed {
    pwr_seq_t pwr_seq;
  } otp_ast_req_t;
  typedef struct packed {
    pwr_seq_t pwr_seq_h;
  } otp_ast_rsp_t;
  
  typedef logic [OtpTestCtrlWidth-1:0] otp_test_ctrl_t;
  typedef struct packed {
    otp_test_ctrl_t ctrl;
  } otp_test_req_t;
  typedef logic [OtpTestStatusWidth-1:0] otp_test_status_t;
  typedef struct packed {
    otp_test_status_t status;
  } otp_test_rsp_t;
  typedef logic [OtpTestVectWidth-1:0] otp_test_vect_t;
  parameter otp_test_req_t OTP_TEST_DEFAULT = '0;
  
  typedef struct packed {
    logic test;
  } otp_cfg_t;
  typedef struct packed {
    logic done;
  } otp_cfg_rsp_t;
  parameter otp_cfg_t OTP_CFG_DEFAULT = '0;
endpackage : otp_macro_pkg

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
module otp_macro_prim_reg_top
  # (
    parameter bit          EnableRacl           = 1'b0,
    parameter bit          RaclErrorRsp         = 1'b1,
    parameter top_racl_pkg::racl_policy_sel_t RaclPolicySelVec[otp_macro_reg_pkg::NumRegsPrim] =
      '{otp_macro_reg_pkg::NumRegsPrim{0}}
  ) (
  input clk_i,
  input rst_ni,
  input  tlul_pkg::tl_h2d_t tl_i,
  output tlul_pkg::tl_d2h_t tl_o,
  
  output otp_macro_reg_pkg::otp_macro_prim_reg2hw_t reg2hw, 
  input  otp_macro_reg_pkg::otp_macro_prim_hw2reg_t hw2reg, 
  
  input  top_racl_pkg::racl_policy_vec_t racl_policies_i,
  output top_racl_pkg::racl_error_log_t  racl_error_o,
  
  output logic intg_err_o
);
  import otp_macro_reg_pkg::* ;
  localparam int AW = 5;
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
  logic [7:0] reg_we_check;
  prim_reg_we_check #(
    .OneHotWidth(8)
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
  
  
  
  logic csr0_we;
  logic csr0_field0_qs;
  logic csr0_field0_wd;
  logic csr0_field1_qs;
  logic csr0_field1_wd;
  logic csr0_field2_qs;
  logic csr0_field2_wd;
  logic [9:0] csr0_field3_qs;
  logic [9:0] csr0_field3_wd;
  logic [10:0] csr0_field4_qs;
  logic [10:0] csr0_field4_wd;
  logic csr1_we;
  logic [6:0] csr1_field0_qs;
  logic [6:0] csr1_field0_wd;
  logic csr1_field1_qs;
  logic csr1_field1_wd;
  logic [6:0] csr1_field2_qs;
  logic [6:0] csr1_field2_wd;
  logic csr1_field3_qs;
  logic csr1_field3_wd;
  logic [15:0] csr1_field4_qs;
  logic [15:0] csr1_field4_wd;
  logic csr2_we;
  logic csr2_qs;
  logic csr2_wd;
  logic csr3_we;
  logic [2:0] csr3_field0_qs;
  logic [2:0] csr3_field0_wd;
  logic [9:0] csr3_field1_qs;
  logic [9:0] csr3_field1_wd;
  logic csr3_field2_qs;
  logic csr3_field2_wd;
  logic csr3_field3_qs;
  logic csr3_field4_qs;
  logic csr3_field5_qs;
  logic csr3_field6_qs;
  logic csr3_field7_qs;
  logic csr3_field8_qs;
  logic csr4_we;
  logic [9:0] csr4_field0_qs;
  logic [9:0] csr4_field0_wd;
  logic csr4_field1_qs;
  logic csr4_field1_wd;
  logic csr4_field2_qs;
  logic csr4_field2_wd;
  logic csr4_field3_qs;
  logic csr4_field3_wd;
  logic csr5_we;
  logic [5:0] csr5_field0_qs;
  logic [5:0] csr5_field0_wd;
  logic [1:0] csr5_field1_qs;
  logic [1:0] csr5_field1_wd;
  logic csr5_field2_qs;
  logic [2:0] csr5_field3_qs;
  logic csr5_field4_qs;
  logic csr5_field5_qs;
  logic [15:0] csr5_field6_qs;
  logic [15:0] csr5_field6_wd;
  logic csr6_we;
  logic [9:0] csr6_field0_qs;
  logic [9:0] csr6_field0_wd;
  logic csr6_field1_qs;
  logic csr6_field1_wd;
  logic csr6_field2_qs;
  logic csr6_field2_wd;
  logic [15:0] csr6_field3_qs;
  logic [15:0] csr6_field3_wd;
  logic [5:0] csr7_field0_qs;
  logic [2:0] csr7_field1_qs;
  logic csr7_field2_qs;
  logic csr7_field3_qs;
  
  
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr0_field0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr0_we),
    .wd     (csr0_field0_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr0.field0.q),
    .ds     (),
    
    .qs     (csr0_field0_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr0_field1 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr0_we),
    .wd     (csr0_field1_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr0.field1.q),
    .ds     (),
    
    .qs     (csr0_field1_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr0_field2 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr0_we),
    .wd     (csr0_field2_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr0.field2.q),
    .ds     (),
    
    .qs     (csr0_field2_qs)
  );
  
  prim_subreg #(
    .DW      (10),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (10'h0),
    .Mubi    (1'b0)
  ) u_csr0_field3 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr0_we),
    .wd     (csr0_field3_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr0.field3.q),
    .ds     (),
    
    .qs     (csr0_field3_qs)
  );
  
  prim_subreg #(
    .DW      (11),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (11'h0),
    .Mubi    (1'b0)
  ) u_csr0_field4 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr0_we),
    .wd     (csr0_field4_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr0.field4.q),
    .ds     (),
    
    .qs     (csr0_field4_qs)
  );
  
  
  prim_subreg #(
    .DW      (7),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (7'h0),
    .Mubi    (1'b0)
  ) u_csr1_field0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr1_we),
    .wd     (csr1_field0_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr1.field0.q),
    .ds     (),
    
    .qs     (csr1_field0_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr1_field1 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr1_we),
    .wd     (csr1_field1_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr1.field1.q),
    .ds     (),
    
    .qs     (csr1_field1_qs)
  );
  
  prim_subreg #(
    .DW      (7),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (7'h0),
    .Mubi    (1'b0)
  ) u_csr1_field2 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr1_we),
    .wd     (csr1_field2_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr1.field2.q),
    .ds     (),
    
    .qs     (csr1_field2_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr1_field3 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr1_we),
    .wd     (csr1_field3_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr1.field3.q),
    .ds     (),
    
    .qs     (csr1_field3_qs)
  );
  
  prim_subreg #(
    .DW      (16),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (16'h0),
    .Mubi    (1'b0)
  ) u_csr1_field4 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr1_we),
    .wd     (csr1_field4_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr1.field4.q),
    .ds     (),
    
    .qs     (csr1_field4_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr2 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr2_we),
    .wd     (csr2_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr2.q),
    .ds     (),
    
    .qs     (csr2_qs)
  );
  
  
  prim_subreg #(
    .DW      (3),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (3'h0),
    .Mubi    (1'b0)
  ) u_csr3_field0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr3_we),
    .wd     (csr3_field0_wd),
    
    .de     (hw2reg.csr3.field0.de),
    .d      (hw2reg.csr3.field0.d),
    
    .qe     (),
    .q      (reg2hw.csr3.field0.q),
    .ds     (),
    
    .qs     (csr3_field0_qs)
  );
  
  prim_subreg #(
    .DW      (10),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (10'h0),
    .Mubi    (1'b0)
  ) u_csr3_field1 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr3_we),
    .wd     (csr3_field1_wd),
    
    .de     (hw2reg.csr3.field1.de),
    .d      (hw2reg.csr3.field1.d),
    
    .qe     (),
    .q      (reg2hw.csr3.field1.q),
    .ds     (),
    
    .qs     (csr3_field1_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessW1C),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr3_field2 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr3_we),
    .wd     (csr3_field2_wd),
    
    .de     (hw2reg.csr3.field2.de),
    .d      (hw2reg.csr3.field2.d),
    
    .qe     (),
    .q      (reg2hw.csr3.field2.q),
    .ds     (),
    
    .qs     (csr3_field2_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr3_field3 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.csr3.field3.de),
    .d      (hw2reg.csr3.field3.d),
    
    .qe     (),
    .q      (reg2hw.csr3.field3.q),
    .ds     (),
    
    .qs     (csr3_field3_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr3_field4 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.csr3.field4.de),
    .d      (hw2reg.csr3.field4.d),
    
    .qe     (),
    .q      (reg2hw.csr3.field4.q),
    .ds     (),
    
    .qs     (csr3_field4_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr3_field5 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.csr3.field5.de),
    .d      (hw2reg.csr3.field5.d),
    
    .qe     (),
    .q      (reg2hw.csr3.field5.q),
    .ds     (),
    
    .qs     (csr3_field5_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr3_field6 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.csr3.field6.de),
    .d      (hw2reg.csr3.field6.d),
    
    .qe     (),
    .q      (reg2hw.csr3.field6.q),
    .ds     (),
    
    .qs     (csr3_field6_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr3_field7 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.csr3.field7.de),
    .d      (hw2reg.csr3.field7.d),
    
    .qe     (),
    .q      (reg2hw.csr3.field7.q),
    .ds     (),
    
    .qs     (csr3_field7_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr3_field8 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.csr3.field8.de),
    .d      (hw2reg.csr3.field8.d),
    
    .qe     (),
    .q      (reg2hw.csr3.field8.q),
    .ds     (),
    
    .qs     (csr3_field8_qs)
  );
  
  
  prim_subreg #(
    .DW      (10),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (10'h0),
    .Mubi    (1'b0)
  ) u_csr4_field0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr4_we),
    .wd     (csr4_field0_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr4.field0.q),
    .ds     (),
    
    .qs     (csr4_field0_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr4_field1 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr4_we),
    .wd     (csr4_field1_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr4.field1.q),
    .ds     (),
    
    .qs     (csr4_field1_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr4_field2 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr4_we),
    .wd     (csr4_field2_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr4.field2.q),
    .ds     (),
    
    .qs     (csr4_field2_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr4_field3 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr4_we),
    .wd     (csr4_field3_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr4.field3.q),
    .ds     (),
    
    .qs     (csr4_field3_qs)
  );
  
  
  prim_subreg #(
    .DW      (6),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (6'h0),
    .Mubi    (1'b0)
  ) u_csr5_field0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr5_we),
    .wd     (csr5_field0_wd),
    
    .de     (hw2reg.csr5.field0.de),
    .d      (hw2reg.csr5.field0.d),
    
    .qe     (),
    .q      (reg2hw.csr5.field0.q),
    .ds     (),
    
    .qs     (csr5_field0_qs)
  );
  
  prim_subreg #(
    .DW      (2),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (2'h0),
    .Mubi    (1'b0)
  ) u_csr5_field1 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr5_we),
    .wd     (csr5_field1_wd),
    
    .de     (hw2reg.csr5.field1.de),
    .d      (hw2reg.csr5.field1.d),
    
    .qe     (),
    .q      (reg2hw.csr5.field1.q),
    .ds     (),
    
    .qs     (csr5_field1_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr5_field2 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.csr5.field2.de),
    .d      (hw2reg.csr5.field2.d),
    
    .qe     (),
    .q      (reg2hw.csr5.field2.q),
    .ds     (),
    
    .qs     (csr5_field2_qs)
  );
  
  prim_subreg #(
    .DW      (3),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (3'h0),
    .Mubi    (1'b0)
  ) u_csr5_field3 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.csr5.field3.de),
    .d      (hw2reg.csr5.field3.d),
    
    .qe     (),
    .q      (reg2hw.csr5.field3.q),
    .ds     (),
    
    .qs     (csr5_field3_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr5_field4 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.csr5.field4.de),
    .d      (hw2reg.csr5.field4.d),
    
    .qe     (),
    .q      (reg2hw.csr5.field4.q),
    .ds     (),
    
    .qs     (csr5_field4_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr5_field5 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.csr5.field5.de),
    .d      (hw2reg.csr5.field5.d),
    
    .qe     (),
    .q      (reg2hw.csr5.field5.q),
    .ds     (),
    
    .qs     (csr5_field5_qs)
  );
  
  prim_subreg #(
    .DW      (16),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (16'h0),
    .Mubi    (1'b0)
  ) u_csr5_field6 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr5_we),
    .wd     (csr5_field6_wd),
    
    .de     (hw2reg.csr5.field6.de),
    .d      (hw2reg.csr5.field6.d),
    
    .qe     (),
    .q      (reg2hw.csr5.field6.q),
    .ds     (),
    
    .qs     (csr5_field6_qs)
  );
  
  
  prim_subreg #(
    .DW      (10),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (10'h0),
    .Mubi    (1'b0)
  ) u_csr6_field0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr6_we),
    .wd     (csr6_field0_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr6.field0.q),
    .ds     (),
    
    .qs     (csr6_field0_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr6_field1 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr6_we),
    .wd     (csr6_field1_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr6.field1.q),
    .ds     (),
    
    .qs     (csr6_field1_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr6_field2 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr6_we),
    .wd     (csr6_field2_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr6.field2.q),
    .ds     (),
    
    .qs     (csr6_field2_qs)
  );
  
  prim_subreg #(
    .DW      (16),
    .SwAccess(prim_subreg_pkg::SwAccessRW),
    .RESVAL  (16'h0),
    .Mubi    (1'b0)
  ) u_csr6_field3 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (csr6_we),
    .wd     (csr6_field3_wd),
    
    .de     (1'b0),
    .d      ('0),
    
    .qe     (),
    .q      (reg2hw.csr6.field3.q),
    .ds     (),
    
    .qs     (csr6_field3_qs)
  );
  
  
  prim_subreg #(
    .DW      (6),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (6'h0),
    .Mubi    (1'b0)
  ) u_csr7_field0 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.csr7.field0.de),
    .d      (hw2reg.csr7.field0.d),
    
    .qe     (),
    .q      (reg2hw.csr7.field0.q),
    .ds     (),
    
    .qs     (csr7_field0_qs)
  );
  
  prim_subreg #(
    .DW      (3),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (3'h0),
    .Mubi    (1'b0)
  ) u_csr7_field1 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.csr7.field1.de),
    .d      (hw2reg.csr7.field1.d),
    
    .qe     (),
    .q      (reg2hw.csr7.field1.q),
    .ds     (),
    
    .qs     (csr7_field1_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr7_field2 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.csr7.field2.de),
    .d      (hw2reg.csr7.field2.d),
    
    .qe     (),
    .q      (reg2hw.csr7.field2.q),
    .ds     (),
    
    .qs     (csr7_field2_qs)
  );
  
  prim_subreg #(
    .DW      (1),
    .SwAccess(prim_subreg_pkg::SwAccessRO),
    .RESVAL  (1'h0),
    .Mubi    (1'b0)
  ) u_csr7_field3 (
    .clk_i   (clk_i),
    .rst_ni  (rst_ni),
    
    .we     (1'b0),
    .wd     ('0),
    
    .de     (hw2reg.csr7.field3.de),
    .d      (hw2reg.csr7.field3.d),
    
    .qe     (),
    .q      (reg2hw.csr7.field3.q),
    .ds     (),
    
    .qs     (csr7_field3_qs)
  );
  logic [7:0] addr_hit;
  top_racl_pkg::racl_role_vec_t racl_role_vec;
  top_racl_pkg::racl_role_t racl_role;
  logic [7:0] racl_addr_hit_read;
  logic [7:0] racl_addr_hit_write;
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
    addr_hit[0] = (reg_addr == OTP_MACRO_CSR0_OFFSET);
    addr_hit[1] = (reg_addr == OTP_MACRO_CSR1_OFFSET);
    addr_hit[2] = (reg_addr == OTP_MACRO_CSR2_OFFSET);
    addr_hit[3] = (reg_addr == OTP_MACRO_CSR3_OFFSET);
    addr_hit[4] = (reg_addr == OTP_MACRO_CSR4_OFFSET);
    addr_hit[5] = (reg_addr == OTP_MACRO_CSR5_OFFSET);
    addr_hit[6] = (reg_addr == OTP_MACRO_CSR6_OFFSET);
    addr_hit[7] = (reg_addr == OTP_MACRO_CSR7_OFFSET);
    if (EnableRacl) begin : gen_racl_hit
      for (int unsigned slice_idx = 0; slice_idx < 8; slice_idx++) begin
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
              ((racl_addr_hit_write[0] & (|(OTP_MACRO_PRIM_PERMIT[0] & ~reg_be))) |
               (racl_addr_hit_write[1] & (|(OTP_MACRO_PRIM_PERMIT[1] & ~reg_be))) |
               (racl_addr_hit_write[2] & (|(OTP_MACRO_PRIM_PERMIT[2] & ~reg_be))) |
               (racl_addr_hit_write[3] & (|(OTP_MACRO_PRIM_PERMIT[3] & ~reg_be))) |
               (racl_addr_hit_write[4] & (|(OTP_MACRO_PRIM_PERMIT[4] & ~reg_be))) |
               (racl_addr_hit_write[5] & (|(OTP_MACRO_PRIM_PERMIT[5] & ~reg_be))) |
               (racl_addr_hit_write[6] & (|(OTP_MACRO_PRIM_PERMIT[6] & ~reg_be))) |
               (racl_addr_hit_write[7] & (|(OTP_MACRO_PRIM_PERMIT[7] & ~reg_be)))));
  end
  
  assign csr0_we = racl_addr_hit_write[0] & reg_we & !reg_error;
  assign csr0_field0_wd = reg_wdata[0];
  assign csr0_field1_wd = reg_wdata[1];
  assign csr0_field2_wd = reg_wdata[2];
  assign csr0_field3_wd = reg_wdata[13:4];
  assign csr0_field4_wd = reg_wdata[26:16];
  assign csr1_we = racl_addr_hit_write[1] & reg_we & !reg_error;
  assign csr1_field0_wd = reg_wdata[6:0];
  assign csr1_field1_wd = reg_wdata[7];
  assign csr1_field2_wd = reg_wdata[14:8];
  assign csr1_field3_wd = reg_wdata[15];
  assign csr1_field4_wd = reg_wdata[31:16];
  assign csr2_we = racl_addr_hit_write[2] & reg_we & !reg_error;
  assign csr2_wd = reg_wdata[0];
  assign csr3_we = racl_addr_hit_write[3] & reg_we & !reg_error;
  assign csr3_field0_wd = reg_wdata[2:0];
  assign csr3_field1_wd = reg_wdata[13:4];
  assign csr3_field2_wd = reg_wdata[16];
  assign csr4_we = racl_addr_hit_write[4] & reg_we & !reg_error;
  assign csr4_field0_wd = reg_wdata[9:0];
  assign csr4_field1_wd = reg_wdata[12];
  assign csr4_field2_wd = reg_wdata[13];
  assign csr4_field3_wd = reg_wdata[14];
  assign csr5_we = racl_addr_hit_write[5] & reg_we & !reg_error;
  assign csr5_field0_wd = reg_wdata[5:0];
  assign csr5_field1_wd = reg_wdata[7:6];
  assign csr5_field6_wd = reg_wdata[31:16];
  assign csr6_we = racl_addr_hit_write[6] & reg_we & !reg_error;
  assign csr6_field0_wd = reg_wdata[9:0];
  assign csr6_field1_wd = reg_wdata[11];
  assign csr6_field2_wd = reg_wdata[12];
  assign csr6_field3_wd = reg_wdata[31:16];
  
  always_comb begin
    reg_we_check[0] = csr0_we;
    reg_we_check[1] = csr1_we;
    reg_we_check[2] = csr2_we;
    reg_we_check[3] = csr3_we;
    reg_we_check[4] = csr4_we;
    reg_we_check[5] = csr5_we;
    reg_we_check[6] = csr6_we;
    reg_we_check[7] = 1'b0;
  end
  
  always_comb begin
    reg_rdata_next = '0;
    unique case (1'b1)
      racl_addr_hit_read[0]: begin
        reg_rdata_next[0] = csr0_field0_qs;
        reg_rdata_next[1] = csr0_field1_qs;
        reg_rdata_next[2] = csr0_field2_qs;
        reg_rdata_next[13:4] = csr0_field3_qs;
        reg_rdata_next[26:16] = csr0_field4_qs;
      end
      racl_addr_hit_read[1]: begin
        reg_rdata_next[6:0] = csr1_field0_qs;
        reg_rdata_next[7] = csr1_field1_qs;
        reg_rdata_next[14:8] = csr1_field2_qs;
        reg_rdata_next[15] = csr1_field3_qs;
        reg_rdata_next[31:16] = csr1_field4_qs;
      end
      racl_addr_hit_read[2]: begin
        reg_rdata_next[0] = csr2_qs;
      end
      racl_addr_hit_read[3]: begin
        reg_rdata_next[2:0] = csr3_field0_qs;
        reg_rdata_next[13:4] = csr3_field1_qs;
        reg_rdata_next[16] = csr3_field2_qs;
        reg_rdata_next[17] = csr3_field3_qs;
        reg_rdata_next[18] = csr3_field4_qs;
        reg_rdata_next[19] = csr3_field5_qs;
        reg_rdata_next[20] = csr3_field6_qs;
        reg_rdata_next[21] = csr3_field7_qs;
        reg_rdata_next[22] = csr3_field8_qs;
      end
      racl_addr_hit_read[4]: begin
        reg_rdata_next[9:0] = csr4_field0_qs;
        reg_rdata_next[12] = csr4_field1_qs;
        reg_rdata_next[13] = csr4_field2_qs;
        reg_rdata_next[14] = csr4_field3_qs;
      end
      racl_addr_hit_read[5]: begin
        reg_rdata_next[5:0] = csr5_field0_qs;
        reg_rdata_next[7:6] = csr5_field1_qs;
        reg_rdata_next[8] = csr5_field2_qs;
        reg_rdata_next[11:9] = csr5_field3_qs;
        reg_rdata_next[12] = csr5_field4_qs;
        reg_rdata_next[13] = csr5_field5_qs;
        reg_rdata_next[31:16] = csr5_field6_qs;
      end
      racl_addr_hit_read[6]: begin
        reg_rdata_next[9:0] = csr6_field0_qs;
        reg_rdata_next[11] = csr6_field1_qs;
        reg_rdata_next[12] = csr6_field2_qs;
        reg_rdata_next[31:16] = csr6_field3_qs;
      end
      racl_addr_hit_read[7]: begin
        reg_rdata_next[5:0] = csr7_field0_qs;
        reg_rdata_next[10:8] = csr7_field1_qs;
        reg_rdata_next[14] = csr7_field2_qs;
        reg_rdata_next[15] = csr7_field3_qs;
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

package otp_macro_reg_pkg;
  
  parameter int PrimAw = 5;
  
  parameter int NumRegsPrim = 8;
  
  
  
  typedef struct packed {
    struct packed {
      logic [10:0] q;
    } field4;
    struct packed {
      logic [9:0] q;
    } field3;
    struct packed {
      logic        q;
    } field2;
    struct packed {
      logic        q;
    } field1;
    struct packed {
      logic        q;
    } field0;
  } otp_macro_reg2hw_csr0_reg_t;
  typedef struct packed {
    struct packed {
      logic [15:0] q;
    } field4;
    struct packed {
      logic        q;
    } field3;
    struct packed {
      logic [6:0]  q;
    } field2;
    struct packed {
      logic        q;
    } field1;
    struct packed {
      logic [6:0]  q;
    } field0;
  } otp_macro_reg2hw_csr1_reg_t;
  typedef struct packed {
    logic        q;
  } otp_macro_reg2hw_csr2_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } field8;
    struct packed {
      logic        q;
    } field7;
    struct packed {
      logic        q;
    } field6;
    struct packed {
      logic        q;
    } field5;
    struct packed {
      logic        q;
    } field4;
    struct packed {
      logic        q;
    } field3;
    struct packed {
      logic        q;
    } field2;
    struct packed {
      logic [9:0] q;
    } field1;
    struct packed {
      logic [2:0]  q;
    } field0;
  } otp_macro_reg2hw_csr3_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } field3;
    struct packed {
      logic        q;
    } field2;
    struct packed {
      logic        q;
    } field1;
    struct packed {
      logic [9:0] q;
    } field0;
  } otp_macro_reg2hw_csr4_reg_t;
  typedef struct packed {
    struct packed {
      logic [15:0] q;
    } field6;
    struct packed {
      logic        q;
    } field5;
    struct packed {
      logic        q;
    } field4;
    struct packed {
      logic [2:0]  q;
    } field3;
    struct packed {
      logic        q;
    } field2;
    struct packed {
      logic [1:0]  q;
    } field1;
    struct packed {
      logic [5:0]  q;
    } field0;
  } otp_macro_reg2hw_csr5_reg_t;
  typedef struct packed {
    struct packed {
      logic [15:0] q;
    } field3;
    struct packed {
      logic        q;
    } field2;
    struct packed {
      logic        q;
    } field1;
    struct packed {
      logic [9:0] q;
    } field0;
  } otp_macro_reg2hw_csr6_reg_t;
  typedef struct packed {
    struct packed {
      logic        q;
    } field3;
    struct packed {
      logic        q;
    } field2;
    struct packed {
      logic [2:0]  q;
    } field1;
    struct packed {
      logic [5:0]  q;
    } field0;
  } otp_macro_reg2hw_csr7_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } field8;
    struct packed {
      logic        d;
      logic        de;
    } field7;
    struct packed {
      logic        d;
      logic        de;
    } field6;
    struct packed {
      logic        d;
      logic        de;
    } field5;
    struct packed {
      logic        d;
      logic        de;
    } field4;
    struct packed {
      logic        d;
      logic        de;
    } field3;
    struct packed {
      logic        d;
      logic        de;
    } field2;
    struct packed {
      logic [9:0] d;
      logic        de;
    } field1;
    struct packed {
      logic [2:0]  d;
      logic        de;
    } field0;
  } otp_macro_hw2reg_csr3_reg_t;
  typedef struct packed {
    struct packed {
      logic [15:0] d;
      logic        de;
    } field6;
    struct packed {
      logic        d;
      logic        de;
    } field5;
    struct packed {
      logic        d;
      logic        de;
    } field4;
    struct packed {
      logic [2:0]  d;
      logic        de;
    } field3;
    struct packed {
      logic        d;
      logic        de;
    } field2;
    struct packed {
      logic [1:0]  d;
      logic        de;
    } field1;
    struct packed {
      logic [5:0]  d;
      logic        de;
    } field0;
  } otp_macro_hw2reg_csr5_reg_t;
  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } field3;
    struct packed {
      logic        d;
      logic        de;
    } field2;
    struct packed {
      logic [2:0]  d;
      logic        de;
    } field1;
    struct packed {
      logic [5:0]  d;
      logic        de;
    } field0;
  } otp_macro_hw2reg_csr7_reg_t;
  
  typedef struct packed {
    otp_macro_reg2hw_csr0_reg_t csr0; 
    otp_macro_reg2hw_csr1_reg_t csr1; 
    otp_macro_reg2hw_csr2_reg_t csr2; 
    otp_macro_reg2hw_csr3_reg_t csr3; 
    otp_macro_reg2hw_csr4_reg_t csr4; 
    otp_macro_reg2hw_csr5_reg_t csr5; 
    otp_macro_reg2hw_csr6_reg_t csr6; 
    otp_macro_reg2hw_csr7_reg_t csr7; 
  } otp_macro_prim_reg2hw_t;
  
  typedef struct packed {
    otp_macro_hw2reg_csr3_reg_t csr3; 
    otp_macro_hw2reg_csr5_reg_t csr5; 
    otp_macro_hw2reg_csr7_reg_t csr7; 
  } otp_macro_prim_hw2reg_t;
  
  parameter logic [PrimAw-1:0] OTP_MACRO_CSR0_OFFSET = 5'h 0;
  parameter logic [PrimAw-1:0] OTP_MACRO_CSR1_OFFSET = 5'h 4;
  parameter logic [PrimAw-1:0] OTP_MACRO_CSR2_OFFSET = 5'h 8;
  parameter logic [PrimAw-1:0] OTP_MACRO_CSR3_OFFSET = 5'h c;
  parameter logic [PrimAw-1:0] OTP_MACRO_CSR4_OFFSET = 5'h 10;
  parameter logic [PrimAw-1:0] OTP_MACRO_CSR5_OFFSET = 5'h 14;
  parameter logic [PrimAw-1:0] OTP_MACRO_CSR6_OFFSET = 5'h 18;
  parameter logic [PrimAw-1:0] OTP_MACRO_CSR7_OFFSET = 5'h 1c;
  
  typedef enum int {
    OTP_MACRO_CSR0,
    OTP_MACRO_CSR1,
    OTP_MACRO_CSR2,
    OTP_MACRO_CSR3,
    OTP_MACRO_CSR4,
    OTP_MACRO_CSR5,
    OTP_MACRO_CSR6,
    OTP_MACRO_CSR7
  } otp_macro_prim_id_e;
  
  parameter logic [3:0] OTP_MACRO_PRIM_PERMIT [8] = '{
    4'b 1111, 
    4'b 1111, 
    4'b 0001, 
    4'b 0111, 
    4'b 0011, 
    4'b 1111, 
    4'b 1111, 
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
