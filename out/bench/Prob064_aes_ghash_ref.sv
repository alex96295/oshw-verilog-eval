
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
module prim_gf_mult #(
  parameter int Width = 32,
  parameter int StagesPerCycle = Width,
  
  
  
  
  parameter logic[Width-1:0] IPoly = Width'(1'b1) << 15 |
                                     Width'(1'b1) << 9  |
                                     Width'(1'b1) << 7  |
                                     Width'(1'b1) << 4  |
                                     Width'(1'b1) << 3  |
                                     Width'(1'b1) << 0,
  parameter bit OutputZeroUntilAck = 1'b0 
) (
  input clk_i,
  input rst_ni,
  input req_i,
  input [Width-1:0] operand_a_i,
  input [Width-1:0] operand_b_i,
  output logic ack_pre_o,
  output logic ack_o,
  output logic [Width-1:0] prod_o
);
  `ASSERT_INIT(IntegerLoops_A, (Width % StagesPerCycle) == 0)
  `ASSERT_INIT(StagePow2_A, $onehot(StagesPerCycle))
  localparam int Loops = Width / StagesPerCycle;
  localparam int CntWidth = (Loops == 1) ? 1 : $clog2(Loops);
  
  logic [Loops-1:0][StagesPerCycle-1:0] reformat_data;
  
  logic [StagesPerCycle-1:0] op_i_slice;
  
  logic [StagesPerCycle-1:0][Width-1:0] matrix;
  
  
  logic [Width-1:0] vector;
  
  logic [CntWidth-1:0] cnt;
  
  logic first;
  
  logic [Width-1:0] prod_q, prod_d;
  
  logic [Width-1:0] out_int;
  
  assign reformat_data = operand_b_i;
  assign op_i_slice = reformat_data[cnt];
  assign first = cnt == 0;
  if (StagesPerCycle == Width) begin : gen_all_combo
    assign ack_o = 1'b1;
    assign cnt = '0;
    assign prod_q = '0;
    assign vector = '0;
  end else begin : gen_decomposed
    
    assign ack_pre_o = int'(cnt) == (Loops - 2);
    
    assign ack_o = int'(cnt) == (Loops - 1);
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        cnt <= '0;
      end else if (req_i && ack_o) begin
        cnt <= '0;
      end else if (req_i && int'(cnt) < (Loops - 1)) begin
        cnt <= cnt + 1'b1;
      end
    end
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        prod_q <= '0;
        vector <= '0;
      end else if (ack_o) begin
        prod_q <= '0;
        vector <= '0;
      end else if (req_i) begin
        prod_q <= prod_d;
        vector <= matrix[StagesPerCycle-1];
      end
    end
  end
  assign matrix = first ? gen_matrix(operand_a_i, 1'b1) : gen_matrix(vector, 1'b0);
  assign prod_d = prod_q ^ gf_mult(matrix, op_i_slice);
  
  if (OutputZeroUntilAck) begin : gen_out_int_zero
    assign out_int = '0;
  end else begin : gen_out_int_op_a
    assign out_int = operand_a_i;
  end
  assign prod_o = ack_o ? prod_d : out_int;
  
  function automatic logic [Width-1:0] gf_mult2(
    logic [Width-1:0] operand
  );
    logic [Width-1:0] mult_out;
    mult_out = operand[Width-1] ? (operand << 1) ^ IPoly : (operand << 1);
    return mult_out;
  endfunction
  
  function automatic logic [StagesPerCycle-1:0][Width-1:0] gen_matrix(
    logic [Width-1:0] seed,
    logic init
  );
    logic [StagesPerCycle-1:0][Width-1:0] matrix_out;
    matrix_out[0] = init ? seed : gf_mult2(seed);
    matrix_out[StagesPerCycle-1:1] = '0;
    for (int i = 1; i < StagesPerCycle; i++) begin
      matrix_out[i] = gf_mult2(matrix_out[i-1]);
    end
    return matrix_out;
  endfunction
  
  function automatic logic [Width-1:0] gf_mult(
    logic [StagesPerCycle-1:0][Width-1:0] matrix_,
    logic [StagesPerCycle-1:0] operand
  );
    logic [Width-1:0] mult_out;
    logic [Width-1:0] add_vector;
    mult_out = '0;
    for (int i = 0; i < StagesPerCycle; i++) begin
      add_vector = operand[i] ? matrix_[i] : '0;
      mult_out = mult_out ^ add_vector;
    end
    return mult_out;
  endfunction 
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
module prim_onehot_mux #(
  parameter int Width  = 32,
  parameter int Inputs = 8
) (
  
  input clk_i,
  input rst_ni,
  input  logic [Width-1:0]  in_i [Inputs],
  input  logic [Inputs-1:0] sel_i, 
  output logic [Width-1:0]  out_o
);
  logic [Inputs-1:0] in_mux [Width];
  for (genvar b = 0; b < Width; ++b) begin : g_in_mux_outer
    logic [Inputs-1:0] out_mux_bits;
    for (genvar i = 0; i < Inputs; ++i) begin : g_in_mux_inner
      assign in_mux[b][i] = in_i[i][b];
    end
    prim_and2 #(.Width(Inputs)) u_mux_bit_and(
      .in0_i(in_mux[b]),
      .in1_i(sel_i),
      .out_o(out_mux_bits)
    );
    assign out_o[b] = |out_mux_bits;
  end
  logic unused_clk;
  logic unused_rst_n;
  
  assign unused_clk   = clk_i;
  assign unused_rst_n = rst_ni;
  `ASSERT(SelIsOnehot_A, $onehot0(sel_i))
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
module TopModule
  import aes_pkg::*;
  import aes_reg_pkg::*;
#(
  parameter bit          SecMasking   = 1,
  parameter int unsigned GFMultCycles = 32,
  localparam int         NumShares    = SecMasking ? 2 : 1 
) (
  input  logic                         clk_i,
  input  logic                         rst_ni,
  
  input  sp2v_e                        in_valid_i,
  output sp2v_e                        in_ready_o,
  
  output sp2v_e                        out_valid_o,
  input  sp2v_e                        out_ready_i,
  
  input  aes_op_e                      op_i,
  input  gcm_phase_e                   gcm_phase_i,
  input  logic [4:0]                   num_valid_bytes_i,
  input  sp2v_e                        load_hash_subkey_i,
  input  logic                         clear_i,
  output logic                         first_block_o,
  input  logic                         alert_fatal_i,
  output logic                         alert_o,
  
  input  logic         [GCMDegree-1:0] data_in_prev_i,                  
                                                                        
  input  logic [NumRegsData-1:0][31:0] data_out_i,                      
  input  logic         [3:0][3:0][7:0] cipher_state_done_i [NumShares], 
  output logic [NumRegsData-1:0][31:0] ghash_state_done_o
);
  
  localparam int GFMultStagesPerCycle = GCMDegree / GFMultCycles;
  
  logic [GCMDegree-1:0] s_d;
  logic [GCMDegree-1:0] s_q;
  sp2v_e                s_we;
  logic [GCMDegree-1:0] corr_d [2];
  logic [GCMDegree-1:0] corr_q [2];
  sp2v_e                corr_we;
  logic                 corr0_en_d;
  logic                 corr0_en_q;
  logic [15:0][7:0]     ghash_in;
  logic [15:0][7:0]     ghash_in_valid;
  ghash_in_sel_e        ghash_in_sel;
  ghash_add_in_sel_e    ghash_add_in_sel_d [2];
  ghash_add_in_sel_e    ghash_add_in_sel_q [2];
  logic [1:0]           ghash_add_in_sel_err;
  logic [GCMDegree-1:0] ghash_state_d [NumShares];
  logic [GCMDegree-1:0] ghash_state_q [NumShares];
  logic [GCMDegree-1:0] add_s_in;
  logic                 add_s_en_d;
  logic                 add_s_en_q;
  logic [GCMDegree-1:0] ghash_state_done;
  logic [GCMDegree-1:0] ghash_state_add [NumShares];
  sp2v_e                ghash_state_we [2];
  ghash_state_sel_e     ghash_state_sel;
  logic [GCMDegree-1:0] ghash_state_mult [NumShares];
  logic [GCMDegree-1:0] hash_subkey_d [NumShares];
  logic [GCMDegree-1:0] hash_subkey_q [NumShares];
  sp2v_e                hash_subkey_we;
  logic                 gf_mult0_en_d;
  logic                 gf_mult0_en_q;
  gf_mult_in_sel_e      gf_mult1_in_sel_d;
  gf_mult_in_sel_e      gf_mult1_in_sel_q;
  logic                 gf_mult1_in_sel_err;
  logic [1:0]           gf_mult_req;
  logic [1:0]           gf_mult_ack;
  logic [1:0]           gf_mult_ack_pre;
  aes_ghash_e           aes_ghash_ns, aes_ghash_cs;
  logic                 first_block_d;
  logic                 first_block_q;
  logic                 final_add_d;
  logic                 final_add_q;
  logic                 advance;
  
  
  
  
  logic [GCMDegree-1:0] cipher_state_done [NumShares];
  logic [GCMDegree-1:0] data_in_prev;
  logic [GCMDegree-1:0] data_out;
  always_comb begin : data_in_conversion
    for (int s = 0; s < NumShares; s++) begin
      cipher_state_done[s] = aes_state_to_ghash_vec(cipher_state_done_i[s]);
    end
    data_in_prev = aes_state_to_ghash_vec(aes_transpose(data_in_prev_i));
    data_out     = aes_state_to_ghash_vec(aes_transpose(data_out_i));
  end
  
  
  
  
  
  
  
  
  
  
  
  
  if (SecMasking) begin : gen_s1
    
    assign s_d = cipher_state_done[1];
  end else begin : gen_s0
    
    assign s_d = cipher_state_done[0];
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin : s_reg
    if (!rst_ni) begin
      s_q <= '0;
    end else if (s_we == SP2V_HIGH) begin
      s_q <= s_d;
    end
  end
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  if (SecMasking) begin : gen_corr_terms
    
    prim_flop #(
      .Width     (1),
      .ResetValue(1'b0)
    ) u_prim_flop_corr0_en (
      .clk_i (clk_i),
      .rst_ni(rst_ni),
      .d_i(corr0_en_d),
      .q_o(corr0_en_q)
    );
    
    
    
    logic [GCMDegree-1:0] ghash_state0_blanked;
    prim_blanker #(
      .Width(GCMDegree)
    ) u_prim_blanker_corr0 (
      .in_i (ghash_state_q[0]),
      .en_i (corr0_en_q),
      .out_o(ghash_state0_blanked)
    );
    assign corr_d[0] = ghash_state_mult[0] ^ ghash_state0_blanked;
    assign corr_d[1] = ghash_state_mult[1];
    always_ff @(posedge clk_i or negedge rst_ni) begin : corr_reg
      if (!rst_ni) begin
        corr_q <= '{default: '0};
      end else if (corr_we == SP2V_HIGH) begin
        corr_q <= corr_d;
      end
    end
  end
  
  
  
  
  always_comb begin : ghash_in_mux
    unique case (ghash_in_sel)
      GHASH_IN_DATA_IN_PREV: ghash_in = data_in_prev;
      GHASH_IN_DATA_OUT:     ghash_in = data_out;
      default:               ghash_in = data_out;
    endcase
  end
  
  
  always_comb begin
    for (int unsigned i = 0; i < 16; i++) begin
      ghash_in_valid[15-i] = num_valid_bytes_i > i[4:0] ? ghash_in[15-i] : 8'b0;
    end
  end
  
  
  
  
  if (SecMasking) begin : gen_masked_add
    logic [GCMDegree-1:0] add_in [NumShares];
    
    
    
    logic [GHashAddInSelWidth-1:0] ghash_add_in_sel_q_raw [NumShares];
    logic          [GCMDegree-1:0] ghash_add_in_mux_in [NumShares][GHashAddInSelWidth];
    
    
    assign ghash_add_in_mux_in[0][0] = ghash_in_valid;
    assign ghash_add_in_mux_in[0][1] = corr_q[0];
    assign ghash_add_in_mux_in[0][2] = ghash_state_q[1];
    assign ghash_add_in_mux_in[1][0] = ghash_in_valid;
    assign ghash_add_in_mux_in[1][1] = corr_q[1];
    assign ghash_add_in_mux_in[1][2] = ghash_state_mult[1];
    for (genvar s = 0; s < NumShares; s++) begin : gen_add_in_muxes
      
      prim_flop #(
        .Width     (GHashAddInSelWidth),
        .ResetValue({ADD_IN_GHASH_IN})
      ) u_prim_flop_add_in_sel (
        .clk_i (clk_i),
        .rst_ni(rst_ni),
        .d_i({ghash_add_in_sel_d[s]}),
        .q_o(ghash_add_in_sel_q_raw[s])
      );
      assign ghash_add_in_sel_q[s] = ghash_add_in_sel_e'(ghash_add_in_sel_q_raw[s]);
      
      
      prim_onehot_check #(
        .OneHotWidth(GHashAddInSelWidth),
        .AddrCheck  (1'b0),
        .StrictCheck(1'b0)
      ) u_prim_onehot_check_add_in_sel (
        .clk_i (clk_i),
        .rst_ni(rst_ni),
        .oh_i  ({ghash_add_in_sel_q[s]}),
        .addr_i('0),
        .en_i  (1'b1),
        .err_o (ghash_add_in_sel_err[s])
      );
      
      prim_onehot_mux #(
        .Width (GCMDegree),
        .Inputs(GHashAddInSelWidth)
      ) u_prim_onehot_mux_add_in (
        .clk_i (clk_i),
        .rst_ni(rst_ni),
        .in_i (ghash_add_in_mux_in[s]),
        .sel_i(ghash_add_in_sel_q[s]),
        .out_o(add_in[s])
      );
    end
    
    for (genvar s = 0; s < NumShares; s++) begin : gen_state_add
      assign ghash_state_add[s] = ghash_state_q[s] ^ add_in[s];
    end
  end else begin : gen_unmasked_add
    
    assign ghash_state_add[0] = ghash_state_q[0] ^ ghash_in_valid;
  end
  
  
  if (SecMasking) begin : gen_ghash_state_mux_masked
    
    
    
    
    
    
    always_comb begin : ghash_state0_mux
      unique case (ghash_state_sel)
        GHASH_STATE_INIT:    ghash_state_d[0] = cipher_state_done[0];
        GHASH_STATE_RESTORE: ghash_state_d[0] = data_in_prev;
        GHASH_STATE_ADD:     ghash_state_d[0] = ghash_state_add[0];
        GHASH_STATE_MULT:    ghash_state_d[0] = ghash_state_mult[0];
        
        default:             ghash_state_d[0] = ghash_state_add[0];
      endcase
    end
    always_comb begin : ghash_state1_mux
      unique case (ghash_state_sel)
        GHASH_STATE_INIT:    ghash_state_d[1] = cipher_state_done[1];
        GHASH_STATE_ADD:     ghash_state_d[1] = ghash_state_add[1];
        GHASH_STATE_MULT:    ghash_state_d[1] = ghash_state_mult[1];
        
        default:             ghash_state_d[1] = ghash_state_add[1];
      endcase
    end
  end else begin : gen_ghash_state_mux_unmasked
    
    
    
    
    
    
    
    
    
    always_comb begin : ghash_state_mux
      unique case (ghash_state_sel)
        GHASH_STATE_RESTORE: ghash_state_d[0] = ghash_state_add[0];
        GHASH_STATE_INIT:    ghash_state_d[0] = cipher_state_done[0];
        GHASH_STATE_ADD:     ghash_state_d[0] = ghash_state_add[0];
        GHASH_STATE_ADD_S:   ghash_state_d[0] = ghash_state_done;
        GHASH_STATE_MULT:    ghash_state_d[0] = ghash_state_mult[0];
        
        default:             ghash_state_d[0] = ghash_state_add[0];
      endcase
    end
  end
  
  
  for (genvar s = 0; s < NumShares; s++) begin : gen_ghash_state_reg_shares
    always_ff @(posedge clk_i or negedge rst_ni) begin : ghash_state_reg
      if (!rst_ni) begin
        ghash_state_q[s] <= '0;
      end else if (ghash_state_we[s] == SP2V_HIGH) begin
        ghash_state_q[s] <= ghash_state_d[s];
      end
    end
  end
  
  
  
  
  
  assign hash_subkey_d = cipher_state_done;
  always_ff @(posedge clk_i or negedge rst_ni) begin : hash_subkey_reg
    if (!rst_ni) begin
      hash_subkey_q <= '{default: '0};
    end else if (hash_subkey_we == SP2V_HIGH) begin
      hash_subkey_q <= hash_subkey_d;
    end
  end
  
  
  
  logic [GCMDegree-1:0] gf_mult_op_b[NumShares];
  logic [GCMDegree-1:0] gf_mult_op_b_rev[NumShares];
  logic [GCMDegree-1:0] gf_mult_prod[NumShares];
  
  
  if (SecMasking) begin : gen_gf_mult0_blanker
    
    prim_flop #(
      .Width     (1),
      .ResetValue(1'b0)
    ) u_prim_flop_gf_mult0_en (
      .clk_i (clk_i),
      .rst_ni(rst_ni),
      .d_i(gf_mult0_en_d),
      .q_o(gf_mult0_en_q)
    );
    
    prim_blanker #(
      .Width(GCMDegree)
    ) u_prim_blanker_gf_mult0 (
      .in_i (ghash_state_q[0]),
      .en_i (gf_mult0_en_q),
      .out_o(gf_mult_op_b[0])
    );
  end else begin : gen_no_gf_mult0_blanker
    assign gf_mult_op_b[0] = ghash_state_q[0];
  end
  
  assign gf_mult_op_b_rev[0] = aes_ghash_reverse_bit_order(gf_mult_op_b[0]);
  if (SecMasking) begin : gen_gf_mult1_mux
    
    
    
    logic [GFMultInSelWidth-1:0] gf_mult1_in_sel_q_raw;
    logic        [GCMDegree-1:0] gf_mult1_op_b_mux_in [GFMultInSelWidth];
    
    prim_flop #(
      .Width     (GFMultInSelWidth),
      .ResetValue({MULT_IN_ZERO})
    ) u_prim_flop_gf_mult1_in_sel (
      .clk_i (clk_i),
      .rst_ni(rst_ni),
      .d_i({gf_mult1_in_sel_d}),
      .q_o(gf_mult1_in_sel_q_raw)
    );
    assign gf_mult1_in_sel_q = gf_mult_in_sel_e'(gf_mult1_in_sel_q_raw);
    
    
    prim_onehot_check #(
      .OneHotWidth(GFMultInSelWidth),
      .AddrCheck  (1'b0),
      .StrictCheck(1'b0)
    ) u_prim_onehot_check_gf_mult1_in_sel (
      .clk_i (clk_i),
      .rst_ni(rst_ni),
      .oh_i  ({gf_mult1_in_sel_q}),
      .addr_i('0),
      .en_i  (1'b1),
      .err_o (gf_mult1_in_sel_err)
    );
    
    
    assign gf_mult1_op_b_mux_in[0] = ghash_state_q[0];
    assign gf_mult1_op_b_mux_in[1] = ghash_state_q[1];
    assign gf_mult1_op_b_mux_in[2] = s_q;
    prim_onehot_mux #(
      .Width (GCMDegree),
      .Inputs(GFMultInSelWidth)
    ) u_prim_onehot_mux_gf_mult1_op_b (
      .clk_i (clk_i),
      .rst_ni(rst_ni),
      .in_i (gf_mult1_op_b_mux_in),
      .sel_i(gf_mult1_in_sel_q),
      .out_o(gf_mult_op_b[1])
    );
    
    logic [GCMDegree-1:0] gf_mult1_op_b_rev;
    assign gf_mult1_op_b_rev = aes_ghash_reverse_bit_order(gf_mult_op_b[1]);
    
    
    
    
    
    
    
    
    
    logic [GFMultStagesPerCycle-1:0] gf_mult1_op_b_rev_slice_d;
    logic [GFMultStagesPerCycle-1:0] gf_mult1_op_b_rev_slice_q;
    assign gf_mult1_op_b_rev_slice_d = gf_mult1_op_b_rev[GCMDegree-1 -: GFMultStagesPerCycle];
    always_ff @(posedge clk_i or negedge rst_ni) begin : gf_mult1_op_b_slice_reg
      if (!rst_ni) begin
        gf_mult1_op_b_rev_slice_q <= '0;
      end else begin
        gf_mult1_op_b_rev_slice_q <= gf_mult1_op_b_rev_slice_d;
      end
    end
    assign gf_mult_op_b_rev[1] =
        {gf_mult1_op_b_rev_slice_q, gf_mult1_op_b_rev[GCMDegree-GFMultStagesPerCycle-1:0]};
  end
  for (genvar s = 0; s < NumShares; s++) begin : gen_gf_mult
    prim_gf_mult #(
      .Width             (GCMDegree),
      .StagesPerCycle    (GFMultStagesPerCycle),
      .IPoly             (GCMIPoly),
      .OutputZeroUntilAck(1'b1)
    ) u_gf_mult (
      .clk_i (clk_i),
      .rst_ni(rst_ni),
      .req_i(gf_mult_req[s]),
      .ack_o(gf_mult_ack[s]),
      .ack_pre_o(gf_mult_ack_pre[s]),
      .operand_a_i(aes_ghash_reverse_bit_order(hash_subkey_q[s])), 
      .operand_b_i(gf_mult_op_b_rev[s]),                           
      .prod_o(gf_mult_prod[s])
    );
    assign ghash_state_mult[s] = aes_ghash_reverse_bit_order(gf_mult_prod[s]);
  end
  if (!SecMasking) begin : gen_tie_offs
    
    logic [GCMDegree-1:0] unused_corr_q [2];
    sp2v_e                unused_corr_we;
    assign corr_d         = '{default: '0};
    assign corr_q         = corr_d;
    assign unused_corr_q  = corr_q;
    assign unused_corr_we = corr_we;
    logic unused_corr0_en_q;
    assign corr0_en_q        = corr0_en_d;
    assign unused_corr0_en_q = corr0_en_q;
    logic unused_ghash_add_in_sel_d;
    assign unused_ghash_add_in_sel_d = ^{{ghash_add_in_sel_d[0]}, {ghash_add_in_sel_d[1]}};
    assign ghash_add_in_sel_q        = '{default: ADD_IN_GHASH_IN};
    assign ghash_add_in_sel_err      = 2'b00;
    assign gf_mult1_in_sel_err       = 1'b0;
    sp2v_e unused_ghash_state_we;
    assign unused_ghash_state_we = ghash_state_we[1];
    logic unused_gf_mult_req;
    assign unused_gf_mult_req = gf_mult_req[1];
    assign gf_mult_ack[1]     = 1'b1;
    assign gf_mult_ack_pre[1] = 1'b1;
    logic unused_add_s_en_q;
    assign add_s_en_q        = add_s_en_d;
    assign unused_add_s_en_q = add_s_en_q;
  end
  
  
  
  always_comb begin : aes_ghash_fsm
    
    in_ready_o  = SP2V_LOW;
    out_valid_o = SP2V_LOW;
    
    s_we       = SP2V_LOW;
    corr_we    = SP2V_LOW;
    corr0_en_d = 1'b0;
    ghash_in_sel = GHASH_IN_DATA_OUT;
    ghash_add_in_sel_d = ghash_add_in_sel_q;
    ghash_state_sel   = GHASH_STATE_ADD;
    ghash_state_we[0] = SP2V_LOW;
    ghash_state_we[1] = SP2V_LOW;
    hash_subkey_we = SP2V_LOW;
    gf_mult_req       = '0;
    gf_mult0_en_d     = gf_mult0_en_q;
    gf_mult1_in_sel_d = gf_mult1_in_sel_q;
    add_s_en_d = 1'b0;
    
    aes_ghash_ns  = aes_ghash_cs;
    first_block_d = first_block_q;
    final_add_d   = final_add_q;
    advance       = 1'b0;
    
    alert_o = 1'b0;
    unique case (aes_ghash_cs)
      GHASH_IDLE: begin
        in_ready_o = SP2V_HIGH;
        if (in_valid_i == SP2V_HIGH) begin
          if (clear_i) begin
            
            
            s_we              = SP2V_HIGH;
            ghash_state_sel   = GHASH_STATE_ADD;
            ghash_state_we[0] = SP2V_HIGH;
            ghash_state_we[1] = SP2V_HIGH;
            hash_subkey_we    = SP2V_HIGH;
            first_block_d     = 1'b1;
            final_add_d       = 1'b0;
            
            
            if (SecMasking) begin
              gf_mult0_en_d     = 1'b1;
              gf_mult1_in_sel_d = MULT_IN_STATE1;
              aes_ghash_ns      = GHASH_MASKED_INIT;
            end
          end else if (gcm_phase_i == GCM_INIT) begin
            if (load_hash_subkey_i == SP2V_HIGH) begin
              
              hash_subkey_we  = SP2V_HIGH;
            end else begin
              
              s_we              = SP2V_HIGH;
              ghash_state_sel   = GHASH_STATE_INIT;
              ghash_state_we[0] = SP2V_HIGH;
              ghash_state_we[1] = SP2V_HIGH;
              first_block_d     = 1'b1;
              
              
              
              if (SecMasking) begin
                gf_mult0_en_d     = 1'b1;
                gf_mult1_in_sel_d = MULT_IN_STATE0;
                aes_ghash_ns      = GHASH_MASKED_INIT;
              end else begin
                aes_ghash_ns      = GHASH_ADD_S;
              end
            end
          end else if (gcm_phase_i == GCM_RESTORE) begin
            
            
            
            
            ghash_state_sel   = GHASH_STATE_RESTORE;
            ghash_state_we[0] = SP2V_HIGH;
            first_block_d     = 1'b0;
            
            
            
            ghash_in_sel = !SecMasking ? GHASH_IN_DATA_IN_PREV : GHASH_IN_DATA_OUT;
            aes_ghash_ns = !SecMasking ? GHASH_ADD_S           : GHASH_IDLE;
          end else if (gcm_phase_i == GCM_AAD ||
                       gcm_phase_i == GCM_TEXT ||
                       gcm_phase_i == GCM_TAG) begin
            
            ghash_in_sel    =
                (gcm_phase_i == GCM_AAD)                     ? GHASH_IN_DATA_IN_PREV :
                (gcm_phase_i == GCM_TEXT && op_i == AES_DEC) ? GHASH_IN_DATA_IN_PREV :
                (gcm_phase_i == GCM_TEXT && op_i == AES_ENC) ? GHASH_IN_DATA_OUT     :
                (gcm_phase_i == GCM_TAG)                     ? GHASH_IN_DATA_IN_PREV :
                                                               GHASH_IN_DATA_OUT;
            
            
            ghash_state_we[0] = SP2V_HIGH;
            ghash_state_we[1] = first_block_q ? SP2V_HIGH : SP2V_LOW;
            if (SecMasking && !first_block_q) begin
              
              
              ghash_add_in_sel_d[0] = ADD_IN_CORR_B;
              aes_ghash_ns          = GHASH_MASKED_ADD_STATE_SHARES;
            end else begin
              
              
              gf_mult0_en_d     = 1'b1;
              gf_mult1_in_sel_d = MULT_IN_STATE1;
              aes_ghash_ns      = GHASH_MULT;
            end
          end else if (gcm_phase_i == GCM_SAVE) begin
            
            
            
            final_add_d  = 1'b1;
            if (SecMasking) begin
              ghash_add_in_sel_d[0] = ADD_IN_CORR_B;
              aes_ghash_ns          = GHASH_MASKED_ADD_STATE_SHARES;
            end else begin
              add_s_en_d   = 1'b1;
              aes_ghash_ns = GHASH_OUT;
            end
          end else begin
            
            
            aes_ghash_ns = GHASH_ERROR;
          end
        end
      end
      GHASH_MASKED_INIT: begin
        
        
        
        
        
        
        
        
        
        gf_mult_req = 2'b11;
        if (gf_mult_ack_pre[0]) begin
          corr0_en_d = 1'b1;
        end
        if (gf_mult_ack_pre[1]) begin
          gf_mult1_in_sel_d = MULT_IN_ZERO;
        end
        if (&gf_mult_ack) begin
          gf_mult0_en_d     = 1'b0;
          gf_mult1_in_sel_d = MULT_IN_ZERO;
          corr_we           = SP2V_HIGH;
          aes_ghash_ns      = GHASH_IDLE;
        end
      end
      GHASH_MASKED_ADD_STATE_SHARES: begin
        
        ghash_state_sel     = GHASH_STATE_ADD;
        ghash_state_we[0]   = SP2V_HIGH;
        final_add_d         = 1'b0;
        
        ghash_add_in_sel_d[0] = ADD_IN_GHASH_IN;
        ghash_add_in_sel_d[1] = ADD_IN_GHASH_IN;
        if ((gcm_phase_i == GCM_SAVE) || ((gcm_phase_i == GCM_TAG) && final_add_q)) begin
          
          
          add_s_en_d   = 1'b1;
          aes_ghash_ns = GHASH_OUT;
        end else begin
          
          
          gf_mult0_en_d     = 1'b1;
          gf_mult1_in_sel_d = MULT_IN_STATE0;
          aes_ghash_ns      = GHASH_MULT;
        end
      end
      GHASH_MULT: begin
        
        gf_mult_req     = 2'b11;
        if (gf_mult_ack_pre[1]) begin
          gf_mult1_in_sel_d = MULT_IN_ZERO;
        end
        if (&gf_mult_ack) begin
          
          
          
          
          
          gf_mult0_en_d     = 1'b0;
          gf_mult1_in_sel_d = SecMasking && first_block_q ? MULT_IN_S1 : MULT_IN_ZERO;
          ghash_state_sel   = GHASH_STATE_MULT;
          ghash_state_we[0] = SP2V_HIGH;
          ghash_state_we[1] = SP2V_HIGH;
          if (SecMasking) begin
            ghash_add_in_sel_d[0] = ADD_IN_CORR_A;
            ghash_add_in_sel_d[1] = first_block_q ? ADD_IN_GHASH_IN : ADD_IN_CORR_A;
            aes_ghash_ns          = GHASH_MASKED_ADD_CORR;
          end else begin
            first_block_d = 1'b0;
            aes_ghash_ns  = (gcm_phase_i == GCM_TAG) ? GHASH_OUT : GHASH_IDLE;
          end
        end
      end
      GHASH_MASKED_ADD_CORR: begin
        
        if (first_block_q) begin
          
          
          
          
          
          gf_mult_req = 2'b10;
          if (gf_mult_ack_pre[1]) begin
            ghash_add_in_sel_d[1] = ADD_IN_CORR_B;
            gf_mult1_in_sel_d     = MULT_IN_ZERO;
          end
          if (gf_mult_ack[1]) begin
            gf_mult1_in_sel_d = MULT_IN_ZERO;
            ghash_state_we[0] = SP2V_HIGH;
            ghash_state_we[1] = SP2V_HIGH;
            first_block_d     = 1'b0;
            advance           = 1'b1;
          end
        end else begin
          
          advance = 1'b1;
          
          ghash_state_we[0] = SP2V_HIGH;
          ghash_state_we[1] = SP2V_HIGH;
        end
        if (advance) begin
          if (gcm_phase_i == GCM_TAG) begin
            
            
            
            
            
            
            
            aes_ghash_ns = GHASH_MASKED_SETTLE;
          end else begin
            ghash_add_in_sel_d[0] = ADD_IN_GHASH_IN;
            ghash_add_in_sel_d[1] = ADD_IN_GHASH_IN;
            aes_ghash_ns          = GHASH_IDLE;
          end
        end
      end
      GHASH_MASKED_SETTLE: begin
        
        
        
        final_add_d           = 1'b1;
        ghash_add_in_sel_d[0] = ADD_IN_CORR_B;
        ghash_add_in_sel_d[1] = ADD_IN_GHASH_IN;
        aes_ghash_ns          = GHASH_MASKED_ADD_STATE_SHARES;
      end
      GHASH_ADD_S: begin
        
        
        
        ghash_state_sel   = GHASH_STATE_ADD_S;
        ghash_state_we[0] = SP2V_HIGH;
        aes_ghash_ns      = GHASH_IDLE;
      end
      GHASH_OUT: begin
        
        
        add_s_en_d  = 1'b1;
        out_valid_o = SP2V_HIGH;
        if (out_ready_i == SP2V_HIGH) begin
          add_s_en_d        = 1'b0;
          s_we              = SP2V_HIGH;
          ghash_state_sel   = GHASH_STATE_ADD;
          ghash_state_we[0] = SP2V_HIGH;
          ghash_state_we[1] = SP2V_HIGH;
          hash_subkey_we    = SP2V_HIGH;
          
          
          if (SecMasking) begin
            gf_mult0_en_d     = 1'b1;
            gf_mult1_in_sel_d = MULT_IN_STATE1;
            aes_ghash_ns      = GHASH_MASKED_INIT;
          end else begin
            aes_ghash_ns      = GHASH_IDLE;
          end
        end
      end
      GHASH_ERROR: begin
        
        
        alert_o = 1'b1;
      end
      
      default: begin
        aes_ghash_ns = GHASH_ERROR;
        alert_o = 1'b1;
      end
    endcase
    
    
    if (|ghash_add_in_sel_err || gf_mult1_in_sel_err || alert_fatal_i) begin
      aes_ghash_ns = GHASH_ERROR;
    end
  end
  
  `PRIM_FLOP_SPARSE_FSM(u_state_regs, aes_ghash_ns,
      aes_ghash_cs, aes_ghash_e, GHASH_IDLE)
  always_ff @(posedge clk_i or negedge rst_ni) begin : fsm_reg
    if (!rst_ni) begin
      first_block_q <= 1'b0;
    end else begin
      first_block_q <= first_block_d;
    end
  end
  if (SecMasking) begin : gen_fsm_reg_masked
    always_ff @(posedge clk_i or negedge rst_ni) begin : fsm_reg_masked
      if (!rst_ni) begin
        final_add_q <= 1'b0;
      end else begin
        final_add_q <= final_add_d;
      end
    end
  end else begin : gen_no_fsm_reg
    
    logic unused_final_add_d;
    assign final_add_q = 1'b0;
    assign unused_final_add_d = final_add_d;
    logic unused_gf_mult0_en_d;
    assign gf_mult0_en_q = 1'b0;
    assign unused_gf_mult0_en_d = gf_mult0_en_d;
    gf_mult_in_sel_e unused_gf_mult1_in_sel_d;
    assign gf_mult1_in_sel_q = MULT_IN_ZERO;
    assign unused_gf_mult1_in_sel_d = gf_mult1_in_sel_d;
    logic unused_advance;
    assign unused_advance = advance;
  end
  
  
  
  
  assign first_block_o = first_block_q;
  
  
  
  
  
  
  if (SecMasking) begin : gen_add_s_in_masked
    
    prim_flop #(
      .Width     (1),
      .ResetValue(1'b0)
    ) u_prim_flop_add_s_en (
      .clk_i (clk_i),
      .rst_ni(rst_ni),
      .d_i(add_s_en_d),
      .q_o(add_s_en_q)
    );
    
    
    
    prim_blanker #(
      .Width(GCMDegree)
    ) u_prim_blanker_add_s_in (
      .in_i (ghash_state_q[0]),
      .en_i (add_s_en_q),
      .out_o(add_s_in)
    );
  end else begin : gen_add_s_in_unmasked
    
    assign add_s_in = ghash_state_q[0];
  end
  
  assign ghash_state_done = s_q ^ add_s_in;
  
  always_comb begin : data_out_conversion
    ghash_state_done_o = aes_transpose(aes_state_to_ghash_vec(ghash_state_done));
  end
  
  
  
`ifdef INC_ASSERT
  
  
  if (SecMasking) begin : gen_sec_cm_key_masking_svas
    
    
    logic hsk_vld_after_rst_d, hsk_vld_after_rst_q;
    logic s_vld_after_rst_d, s_vld_after_rst_q;
    logic in_hs;
    assign in_hs = (in_valid_i == SP2V_HIGH) & (in_ready_o == SP2V_HIGH);
    assign hsk_vld_after_rst_d = (in_hs & ~clear_i &  load_hash_subkey_i) | hsk_vld_after_rst_q;
    assign s_vld_after_rst_d   = (in_hs & ~clear_i & ~load_hash_subkey_i) | s_vld_after_rst_q;
    always_ff @(posedge clk_i or negedge rst_ni) begin : sva_reg
      if (!rst_ni) begin
        hsk_vld_after_rst_q <= 1'b0;
        s_vld_after_rst_q   <= 1'b0;
      end else begin
        hsk_vld_after_rst_q <= hsk_vld_after_rst_d;
        s_vld_after_rst_q   <= s_vld_after_rst_d;
      end
    end
    for (genvar s = 0; s < NumShares; s++) begin : gen_sec_cm_key_masking_share_svas
      
      `ASSERT(AesSecCmKeyMaskingGhashHskNonZero,
          hsk_vld_after_rst_q && gf_mult_req[s] |-> |hash_subkey_q[s])
      
      `ASSERT(AesSecCmKeyMaskingGhashInitialStateNonZero,
          s_vld_after_rst_q && (aes_ghash_cs == GHASH_MASKED_INIT) |-> |ghash_state_q[s])
      
      `ASSERT(AesSecCmKeyMaskingGhashCorrNonZero,
          aes_ghash_cs == GHASH_MASKED_ADD_CORR |-> |corr_q[s])
    end
    
    
    `ASSERT(AesSecCmKeyMaskingGhashS1NonZero,
        (aes_ghash_cs == GHASH_MASKED_ADD_CORR && first_block_q) ||
        (aes_ghash_cs == GHASH_OUT) |-> |s_q)
  end
  
  
`endif
endmodule

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
