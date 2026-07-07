
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
module TopModule #(
  parameter  int unsigned Width  = 16,
  parameter  int unsigned Depth  = 4,
  parameter  bit OutputZeroIfEmpty = 1'b0, 
  parameter  bit OutputZeroIfInvalid = 1'b0, 
  localparam int unsigned DepthW = $clog2(Depth+1) 
) (
  
  input  logic              clk_wr_i,
  input  logic              rst_wr_ni,
  input  logic              wvalid_i,
  output logic              wready_o,
  input  logic [Width-1:0]  wdata_i,
  output logic [DepthW-1:0] wdepth_o,
  
  input  logic              clk_rd_i,
  input  logic              rst_rd_ni,
  output logic              rvalid_o,
  input  logic              rready_i,
  output logic [Width-1:0]  rdata_o,
  output logic [DepthW-1:0] rdepth_o
);
  
  `ASSERT_INIT(ParamCheckDepth_A, (Depth == 2**$clog2(Depth)))
  localparam int unsigned PTRV_W    = (Depth == 1) ? 1 : $clog2(Depth);
  localparam int unsigned PTR_WIDTH = (Depth == 1) ? 1 : PTRV_W+1;
  logic [PTR_WIDTH-1:0] fifo_wptr_q, fifo_wptr_d;
  logic [PTR_WIDTH-1:0] fifo_rptr_q, fifo_rptr_d;
  logic [PTR_WIDTH-1:0] fifo_wptr_sync_combi, fifo_rptr_sync_combi;
  logic [PTR_WIDTH-1:0] fifo_wptr_gray_sync, fifo_rptr_gray_sync, fifo_rptr_sync_q;
  logic [PTR_WIDTH-1:0] fifo_wptr_gray_q, fifo_wptr_gray_d;
  logic [PTR_WIDTH-1:0] fifo_rptr_gray_q, fifo_rptr_gray_d;
  logic                 fifo_incr_wptr, fifo_incr_rptr;
  logic                 full_wclk, full_rclk, empty_rclk;
  logic [Width-1:0]     storage [Depth];
  
  
  
  assign fifo_incr_wptr = wvalid_i & wready_o;
  
  assign fifo_wptr_d = fifo_wptr_q + PTR_WIDTH'(1'b1);
  always_ff @(posedge clk_wr_i or negedge rst_wr_ni) begin
    if (!rst_wr_ni) begin
      fifo_wptr_q <= '0;
    end else if (fifo_incr_wptr) begin
      fifo_wptr_q <= fifo_wptr_d;
    end
  end
  
  always_ff @(posedge clk_wr_i or negedge rst_wr_ni) begin
    if (!rst_wr_ni) begin
      fifo_wptr_gray_q <= '0;
    end else if (fifo_incr_wptr) begin
      fifo_wptr_gray_q <= fifo_wptr_gray_d;
    end
  end
  
  prim_flop_2sync #(.Width(PTR_WIDTH)) sync_wptr (
    .clk_i    (clk_rd_i),
    .rst_ni   (rst_rd_ni),
    .d_i      (fifo_wptr_gray_q),
    .q_o      (fifo_wptr_gray_sync));
  
  
  
  assign fifo_incr_rptr = rvalid_o & rready_i;
  
  assign fifo_rptr_d = fifo_rptr_q + PTR_WIDTH'(1'b1);
  always_ff @(posedge clk_rd_i or negedge rst_rd_ni) begin
    if (!rst_rd_ni) begin
      fifo_rptr_q <= '0;
    end else if (fifo_incr_rptr) begin
      fifo_rptr_q <= fifo_rptr_d;
    end
  end
  
  always_ff @(posedge clk_rd_i or negedge rst_rd_ni) begin
    if (!rst_rd_ni) begin
      fifo_rptr_gray_q <= '0;
    end else if (fifo_incr_rptr) begin
      fifo_rptr_gray_q <= fifo_rptr_gray_d;
    end
  end
  
  prim_flop_2sync #(.Width(PTR_WIDTH)) sync_rptr (
    .clk_i    (clk_wr_i),
    .rst_ni   (rst_wr_ni),
    .d_i      (fifo_rptr_gray_q),
    .q_o      (fifo_rptr_gray_sync));
  
  always_ff @(posedge clk_wr_i or negedge rst_wr_ni) begin
    if (!rst_wr_ni) begin
      fifo_rptr_sync_q <= '0;
    end else begin
      fifo_rptr_sync_q <= fifo_rptr_sync_combi;
    end
  end
  
  
  
  logic [PTR_WIDTH-1:0] xor_mask;
  assign xor_mask   =  PTR_WIDTH'(1'b1) << (PTR_WIDTH-1);
  assign full_wclk  = (fifo_wptr_q == (fifo_rptr_sync_q ^ xor_mask));
  assign full_rclk  = (fifo_wptr_sync_combi == (fifo_rptr_q ^ xor_mask));
  assign empty_rclk = (fifo_wptr_sync_combi ==  fifo_rptr_q);
  if (Depth > 1) begin : g_depth_calc
    
    logic               wptr_msb;
    logic               rptr_sync_msb;
    logic  [PTRV_W-1:0] wptr_value;
    logic  [PTRV_W-1:0] rptr_sync_value;
    assign wptr_msb        = fifo_wptr_q[PTR_WIDTH-1];
    assign rptr_sync_msb   = fifo_rptr_sync_q[PTR_WIDTH-1];
    assign wptr_value      = fifo_wptr_q[0+:PTRV_W];
    assign rptr_sync_value = fifo_rptr_sync_q[0+:PTRV_W];
    assign wdepth_o = (full_wclk) ? DepthW'(Depth) :
                      (wptr_msb == rptr_sync_msb) ? DepthW'(wptr_value) - DepthW'(rptr_sync_value) :
                      (DepthW'(Depth) - DepthW'(rptr_sync_value) + DepthW'(wptr_value)) ;
    
    logic               rptr_msb;
    logic               wptr_sync_msb;
    logic  [PTRV_W-1:0] rptr_value;
    logic  [PTRV_W-1:0] wptr_sync_value;
    assign wptr_sync_msb   = fifo_wptr_sync_combi[PTR_WIDTH-1];
    assign rptr_msb        = fifo_rptr_q[PTR_WIDTH-1];
    assign wptr_sync_value = fifo_wptr_sync_combi[0+:PTRV_W];
    assign rptr_value      = fifo_rptr_q[0+:PTRV_W];
    assign rdepth_o = (full_rclk) ? DepthW'(Depth) :
                      (wptr_sync_msb == rptr_msb) ? DepthW'(wptr_sync_value) - DepthW'(rptr_value) :
                      (DepthW'(Depth) - DepthW'(rptr_value) + DepthW'(wptr_sync_value)) ;
  end else begin : g_no_depth_calc
    assign rdepth_o = full_rclk;
    assign wdepth_o = full_wclk;
  end
  assign wready_o = ~full_wclk;
  assign rvalid_o = ~empty_rclk;
  
  
  
  logic [Width-1:0] rdata_int;
  if (Depth > 1) begin : g_storage_mux
    always_ff @(posedge clk_wr_i) begin
      if (fifo_incr_wptr) begin
        storage[fifo_wptr_q[PTRV_W-1:0]] <= wdata_i;
      end
    end
    assign rdata_int = storage[fifo_rptr_q[PTRV_W-1:0]];
  end else begin : g_storage_simple
    always_ff @(posedge clk_wr_i) begin
      if (fifo_incr_wptr) begin
        storage[0] <= wdata_i;
      end
    end
    assign rdata_int = storage[0];
  end
  
  if (OutputZeroIfEmpty == 1'b1) begin : gen_output_zero
    if (OutputZeroIfInvalid  == 1'b1) begin : gen_invalid_zero
      assign rdata_o = empty_rclk ? '0 : (rvalid_o ? rdata_int : '0);
    end
    else begin : gen_invalid_non_zero
      assign rdata_o = empty_rclk ? '0 : rdata_int;
    end
  end else begin : gen_no_output_zero
    if (OutputZeroIfInvalid  == 1'b1) begin : gen_invalid_zero
        assign rdata_o = rvalid_o ? rdata_int : '0;
    end
    else begin : gen_invalid_non_zero
        assign rdata_o = rdata_int;
    end
  end
  
  
  
  
  if (Depth > 2) begin : g_full_gray_conversion
    function automatic [PTR_WIDTH-1:0] dec2gray(input logic [PTR_WIDTH-1:0] decval);
      logic [PTR_WIDTH-1:0] decval_sub;
      logic [PTR_WIDTH-1:0] decval_in;
      logic                 unused_decval_msb;
      decval_sub = (PTR_WIDTH)'(Depth) - {1'b0, decval[PTR_WIDTH-2:0]} - 1'b1;
      decval_in = decval[PTR_WIDTH-1] ? decval_sub : decval;
      
      unused_decval_msb = decval_in[PTR_WIDTH-1];
      decval_in[PTR_WIDTH-1] = 1'b0;
      
      dec2gray = decval_in;
      dec2gray ^= (decval_in >> 1);
      
      dec2gray[PTR_WIDTH-1] = decval[PTR_WIDTH-1];
    endfunction
    
    function automatic [PTR_WIDTH-1:0] gray2dec(input logic [PTR_WIDTH-1:0] grayval);
      logic [PTR_WIDTH-1:0] dec_tmp, dec_tmp_sub;
      logic                 unused_decsub_msb;
      dec_tmp = '0;
      for (int unsigned i = PTR_WIDTH-1; i > 0; i--) begin
        dec_tmp[i-1] = dec_tmp[i] ^ grayval[i-1];
      end
      dec_tmp_sub = (PTR_WIDTH)'(Depth) - dec_tmp - 1'b1;
      if (grayval[PTR_WIDTH-1]) begin
        gray2dec = dec_tmp_sub;
        
        gray2dec[PTR_WIDTH-1] = 1'b1;
        unused_decsub_msb = dec_tmp_sub[PTR_WIDTH-1];
      end else begin
        gray2dec = dec_tmp;
      end
    endfunction
    
    assign fifo_rptr_sync_combi = gray2dec(fifo_rptr_gray_sync);
    
    assign fifo_wptr_sync_combi = gray2dec(fifo_wptr_gray_sync);
    assign fifo_rptr_gray_d = dec2gray(fifo_rptr_d);
    assign fifo_wptr_gray_d = dec2gray(fifo_wptr_d);
  end else if (Depth == 2) begin : g_simple_gray_conversion
    assign fifo_rptr_sync_combi = {fifo_rptr_gray_sync[PTR_WIDTH-1], ^fifo_rptr_gray_sync};
    assign fifo_wptr_sync_combi = {fifo_wptr_gray_sync[PTR_WIDTH-1], ^fifo_wptr_gray_sync};
    assign fifo_rptr_gray_d = {fifo_rptr_d[PTR_WIDTH-1], ^fifo_rptr_d};
    assign fifo_wptr_gray_d = {fifo_wptr_d[PTR_WIDTH-1], ^fifo_wptr_d};
  end else begin : g_no_gray_conversion
    assign fifo_rptr_sync_combi = fifo_rptr_gray_sync;
    assign fifo_wptr_sync_combi = fifo_wptr_gray_sync;
    assign fifo_rptr_gray_d = fifo_rptr_d;
    assign fifo_wptr_gray_d = fifo_wptr_d;
  end
  
  `ASSERT(GrayWptr_A, ##1 $countones(fifo_wptr_gray_q ^ $past(fifo_wptr_gray_q)) <= 1,
          clk_wr_i, !rst_wr_ni)
  `ASSERT(GrayRptr_A, ##1 $countones(fifo_rptr_gray_q ^ $past(fifo_rptr_gray_q)) <= 1,
          clk_rd_i, !rst_rd_ni)
endmodule
