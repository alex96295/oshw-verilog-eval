
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
module TopModule
  import prim_alert_pkg::*;
#(
  parameter int OutWidth = 32,
  
  parameter bit RepCheck = 0,
  
  parameter bit EnRstChks = 0,
  
  
  
  
  
  
  
  
  parameter int unsigned MaxLatency = 0
) (
  
  input                       clk_i,
  input                       rst_ni,
  input                       req_chk_i, 
                                         
  input                       req_i,
  output logic                ack_o,
  output logic [OutWidth-1:0] data_o,
  output logic                fips_o,
  output logic                err_o,  
  
  input                       clk_edn_i,
  input                       rst_edn_ni,
  output edn_pkg::edn_req_t   edn_o,
  input  edn_pkg::edn_rsp_t   edn_i
);
  
  logic word_req, word_ack;
  assign word_req = req_i & ~ack_o;
  logic [edn_pkg::ENDPOINT_BUS_WIDTH-1:0] word_data;
  logic word_fips;
  localparam int SyncWidth = $bits({edn_i.edn_fips, edn_i.edn_bus});
  prim_sync_reqack_data #(
    .Width(SyncWidth),
    .EnRstChks(EnRstChks),
    .DataSrc2Dst(1'b0),
    .DataReg(1'b0)
  ) u_prim_sync_reqack_data (
    .clk_src_i  ( clk_i                           ),
    .rst_src_ni ( rst_ni                          ),
    .clk_dst_i  ( clk_edn_i                       ),
    .rst_dst_ni ( rst_edn_ni                      ),
    .req_chk_i  ( req_chk_i                       ),
    .src_req_i  ( word_req                        ),
    .src_ack_o  ( word_ack                        ),
    .dst_req_o  ( edn_o.edn_req                   ),
    .dst_ack_i  ( edn_i.edn_ack                   ),
    .data_i     ( {edn_i.edn_fips, edn_i.edn_bus} ),
    .data_o     ( {word_fips,      word_data}     )
  );
  if (RepCheck) begin : gen_rep_chk
    logic [edn_pkg::ENDPOINT_BUS_WIDTH-1:0] word_data_q;
    always_ff @(posedge clk_i) begin
      if (word_ack) begin
        word_data_q <= word_data;
      end
    end
    
    logic chk_rep;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        chk_rep <= '0;
      end else if (word_ack) begin
        chk_rep <= 1'b1;
      end
    end
    
    
    logic err_d, err_q;
    assign err_d = (req_i && ack_o)                                  ? 1'b0 : 
                   (chk_rep && word_ack && word_data == word_data_q) ? 1'b1 : 
                                                                       err_q; 
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        err_q <= 1'b0;
      end else begin
        err_q <= err_d;
      end
    end
    assign err_o = err_q;
  end else begin : gen_no_rep_chk 
    assign err_o = '0;
  end
  prim_packer_fifo #(
    .InW(edn_pkg::ENDPOINT_BUS_WIDTH),
    .OutW(OutWidth),
    .ClearOnRead(1'b0)
  ) u_prim_packer_fifo (
    .clk_i,
    .rst_ni,
    .clr_i    ( 1'b0          ), 
    .wvalid_i ( word_ack      ),
    .wdata_i  ( word_data     ),
    
    
    .wready_o (               ),
    .rvalid_o ( ack_o         ),
    .rdata_o  ( data_o        ),
    
    
    .rready_i ( 1'b1          ),
    .depth_o  (               )
  );
  
  
  logic fips_d, fips_q;
  assign fips_d = (req_i && ack_o) ? 1'b1               : 
                  (word_ack)       ? fips_q & word_fips : 
                                     fips_q;              
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      fips_q <= 1'b1;
    end else begin
      fips_q <= fips_d;
    end
  end
  assign fips_o = fips_q;
  
  
  
  
`ifdef INC_ASSERT
  
  
  logic [OutWidth-1:0] data_prev, data_curr;
  always_ff @(posedge ack_o or negedge rst_ni) begin
    if (!rst_ni) begin
      data_prev <= '0;
      data_curr <= '0;
    end else if (ack_o) begin
      data_curr <= data_o;
      data_prev <= data_curr;
    end
  end
  
  
  `ASSERT(DataOutputValid_A, ack_o |-> (data_o != 0) && (data_o != '1))
  `ASSERT(DataOutputDiffFromPrev_A, data_prev != 0 |-> data_prev != data_o)
`endif
  
`ifndef SYNTHESIS
  if (MaxLatency != 0) begin: g_maxlatency_assertion
    
    
    localparam int unsigned LatencyW = $clog2(MaxLatency+1);
    logic [LatencyW-1:0] latency_counter;
    logic reset_counter;
    logic enable_counter;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) latency_counter <= '0;
      else if (reset_counter) latency_counter <= '0;
      else if (enable_counter) latency_counter <= latency_counter + 1'b1;
    end
    assign reset_counter  = ack_o;
    assign enable_counter = req_i;
    
    
    `ASSERT(MaxLatency_A, latency_counter <= MaxLatency)
    
    
    
    
    
    
    
  end 
`else 
  logic unused_param_maxlatency;
  assign unused_param_maxlatency = ^MaxLatency;`endif 
endmodule : TopModule

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
