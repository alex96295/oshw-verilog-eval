
module addr_decode #(
  
  parameter int unsigned NoIndices = 32'd0,
  
  parameter int unsigned NoRules   = 32'd0,
  
  parameter type         addr_t    = logic,
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  parameter type         rule_t    = logic,
  
  parameter bit          Napot     = 0,
  
  
  
  parameter int unsigned IdxWidth  = cf_math_pkg::idx_width(NoIndices),
  parameter type         idx_t     = logic [IdxWidth-1:0]
) (
  
  input  addr_t               addr_i,
  
  input  rule_t [NoRules-1:0] addr_map_i,
  
  output idx_t                idx_o,
  
  output logic                dec_valid_o,
  
  output logic                dec_error_o,
  
  
  
  input  logic                en_default_idx_i,
  
  
  
  
  
  input  idx_t                default_idx_i
);
  
  addr_decode_dync #(
    .NoRules   ( NoRules   ),
    .addr_t    ( addr_t    ),
    .rule_t    ( rule_t    ),
    .Napot     ( Napot     ),
    .idx_t     ( idx_t     )
  ) i_addr_decode_dync (
    .addr_i,
    .addr_map_i,
    .idx_o,
    .dec_valid_o,
    .dec_error_o,
    .en_default_idx_i,
    .default_idx_i,
    .config_ongoing_i ( 1'b0 )
  );
endmodule

`ifndef COMMON_CELLS_ASSERTIONS_SVH
`define COMMON_CELLS_ASSERTIONS_SVH
`ifdef UVM
  
  package assert_rpt_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    function void assert_rpt(string msg);
      `uvm_error("ASSERT FAILED", msg)
    endfunction
  endpackage`endif
`ifndef ASSERTS_OFF
`ifndef SYNTHESIS
`ifndef XSIM
`define INC_ASSERT
`endif
`endif   
`endif
`ifdef ASSERTS_OVERRIDE_ON`ifndef INC_ASSERT
`define INC_ASSERT`endif`endif
`define ASSERT_STRINGIFY(__x) `"__x`"
`ifndef ASSERT_RPT
`define ASSERT_RPT(__name, __desc = "")                                                 \
`ifdef UVM                                                                              \
  assert_rpt_pkg::assert_rpt($sformatf("[%m] %s: %s (%s:%0d)",                          \
                             __name, __desc, `__FILE__, `__LINE__));                    \
`else                                                                                   \
  $error("[ASSERT FAILED] [%m] %s: %s (%s:%0d)", __name, __desc, `__FILE__, `__LINE__); \
`endif
`endif
`define ASSERT_DEFAULT_CLK clk_i
`define ASSERT_DEFAULT_RST !rst_ni
`define ASSERT_I(__name, __prop, __desc = "")        \
`ifdef INC_ASSERT                                    \
  __name: assert (__prop)                            \
    else begin                                       \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
    end                                              \
`endif
`define ASSERT_INIT(__name, __prop, __desc = "")       \
`ifdef INC_ASSERT                                      \
  initial begin                                        \
    __name: assert (__prop)                            \
      else begin                                       \
        `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
      end                                              \
  end                                                  \
`endif
`define ASSERT_FINAL(__name, __prop, __desc = "")                            \
`ifdef INC_ASSERT                                                            \
  final begin                                                                \
    __name: assert (__prop || $test$plusargs("disable_assert_final_checks")) \
      else begin                                                             \
        `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                       \
      end                                                                    \
  end                                                                        \
`endif
`define ASSERT(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                     \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop))                    \
    else begin                                                                                        \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                  \
    end                                                                                               \
`endif
`define ASSERT_NEVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                           \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) not (__prop))                      \
    else begin                                                                                              \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                        \
    end                                                                                                     \
`endif
`define ASSERT_KNOWN(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                          \
  `ASSERT(__name, !$isunknown(__sig), __clk, __rst, __desc)                                                \
`endif
`define COVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifdef INC_ASSERT                                                                       \
  __name: cover property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop));      \
`endif
`define ASSERT_PULSE(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                          \
  `ASSERT(__name, $rose(__sig) |=> !(__sig), __clk, __rst, __desc)                                         \
`endif
`define ASSERT_IF(__name, __prop, __enable, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                  \
  `ASSERT(__name, (__enable) |-> (__prop), __clk, __rst, __desc)                                                   \
`endif
`define ASSERT_KNOWN_IF(__name, __sig, __enable, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                       \
  `ASSERT_KNOWN(__name``KnownEnable, __enable, __clk, __rst, __desc)                                                    \
  `ASSERT_IF(__name, !$isunknown(__sig), __enable, __clk, __rst, __desc)                                                \
`endif
`define ASSERT_STABLE(__name, __valid, __ready, __data, __mask = '0, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                                           \
  `ASSERT(__name, (__valid) && !(__ready) |=> $stable((__data) & ~(__mask)), __clk, __rst, __desc)                                          \
`endif
`define ASSUME(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                     \
  __name: assume property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop))                    \
    else begin                                                                                        \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                  \
    end                                                                                               \
`endif
`define ASSUME_I(__name, __prop, __desc = "")        \
`ifdef INC_ASSERT                                    \
  __name: assume (__prop)                            \
    else begin                                       \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
    end                                              \
`endif
`define ASSUME_FPV(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef FPV_ON                                                                                             \
   `ASSUME(__name, __prop, __clk, __rst, __desc)                                                          \
`endif
`define ASSUME_I_FPV(__name, __prop, __desc = "") \
`ifdef FPV_ON                                     \
   `ASSUME_I(__name, __prop, __desc)              \
`endif
`define COVER_FPV(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifdef FPV_ON                                                                               \
   `COVER(__name, __prop, __clk, __rst)                                                     \
`endif
`endif 
module addr_decode_dync #(
  
  parameter int unsigned NoIndices = 32'd0,
  
  parameter int unsigned NoRules   = 32'd0,
  
  parameter type         addr_t    = logic,
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  parameter type         rule_t    = logic,
  
  parameter bit          Napot     = 0,
  
  
  
  parameter int unsigned IdxWidth  = cf_math_pkg::idx_width(NoIndices),
  parameter type         idx_t     = logic [IdxWidth-1:0]
) (
  
  input  addr_t               addr_i,
  
  input  rule_t [NoRules-1:0] addr_map_i,
  
  output idx_t                idx_o,
  
  output logic                dec_valid_o,
  
  output logic                dec_error_o,
  
  
  
  input  logic                en_default_idx_i,
  
  
  
  
  
  input  idx_t                default_idx_i,
  
  
  input  logic                config_ongoing_i
);
  logic [NoRules-1:0] matched_rules; 
  always_comb begin
    
    matched_rules = '0;
    dec_valid_o   = 1'b0;
    dec_error_o   = (en_default_idx_i) ? 1'b0 : 1'b1;
    idx_o         = (en_default_idx_i) ? default_idx_i : '0;
    
    for (int unsigned i = 0; i < NoRules; i++) begin
      if (
        !Napot && (addr_i >= addr_map_i[i].start_addr) &&
        ((addr_i < addr_map_i[i].end_addr) || (addr_map_i[i].end_addr == '0)) ||
        Napot && (addr_map_i[i].start_addr & addr_map_i[i].end_addr) ==
                 (addr_i & addr_map_i[i].end_addr)
      ) begin
        matched_rules[i] = ~config_ongoing_i;
        dec_valid_o      = ~config_ongoing_i;
        dec_error_o      = 1'b0;
        idx_o            = config_ongoing_i ? default_idx_i : idx_t'(addr_map_i[i].idx);
      end
    end
  end
  
  `ifndef COMMON_CELLS_ASSERTS_OFF
  initial begin : proc_check_parameters
    `ASSUME_I(addr_width_mismatch, $bits(addr_i) == $bits(addr_map_i[0].start_addr),
             $sformatf("Input address has %d bits and address map has %d bits.",
                       $bits(addr_i), $bits(addr_map_i[0].start_addr)))
    `ASSUME_I(norules_0, NoRules > 0, $sformatf("At least one rule needed"))
  end
  `ASSERT_FINAL(more_than_1_bit_set, $onehot0(matched_rules) || config_ongoing_i,
                "More than one bit set in the one-hot signal, matched_rules")
  
  
  
  
  
  
  
  
  `ifndef SYNTHESIS
  always_comb begin : proc_check_addr_map
    if (!$isunknown(addr_map_i) && ~config_ongoing_i) begin
      for (int unsigned i = 0; i < NoRules; i++) begin
        `ASSUME_I(check_start, Napot || addr_map_i[i].start_addr < addr_map_i[i].end_addr ||
          addr_map_i[i].end_addr == '0,
          $sformatf("This rule has a higher start than end address!!!\n\
              Violating rule %d.\n\
              Rule> IDX: %h START: %h END: %h\n\
              #####################################################",
              i ,addr_map_i[i].idx, addr_map_i[i].start_addr, addr_map_i[i].end_addr))
        for (int unsigned j = i + 1; j < NoRules; j++) begin
          
          `ASSUME_I(check_overlap, Napot ||
                                  !((addr_map_i[j].start_addr < addr_map_i[i].end_addr) &&
                                    (addr_map_i[j].end_addr > addr_map_i[i].start_addr)) ||
                                  !((addr_map_i[i].end_addr == '0) &&
                                    (addr_map_i[j].end_addr > addr_map_i[i].start_addr)) ||
                                  !((addr_map_i[j].start_addr < addr_map_i[i].end_addr) &&
                                    (addr_map_i[j].end_addr == '0)),
              $sformatf("Overlapping address region found!!!\n\
              Rule %d: IDX: %h START: %h END: %h\n\
              Rule %d: IDX: %h START: %h END: %h\n\
              #####################################################",
              i, addr_map_i[i].idx, addr_map_i[i].start_addr, addr_map_i[i].end_addr,
              j, addr_map_i[j].idx, addr_map_i[j].start_addr, addr_map_i[j].end_addr))
        end
      end
    end
  end
  `endif
  `endif
endmodule

package cf_math_pkg;
    
    
    
    function automatic integer ceil_div (input longint dividend, input longint divisor);
        automatic longint remainder;
        `ifndef SYNTHESIS
        `ifndef COMMON_CELLS_ASSERTS_OFF
        if (dividend < 0) begin
            $fatal(1, "Dividend %0d is not a natural number!", dividend);
        end
        if (divisor < 0) begin
            $fatal(1, "Divisor %0d is not a natural number!", divisor);
        end
        if (divisor == 0) begin
            $fatal(1, "Division by zero!");
        end
        `endif
        `endif
        remainder = dividend;
        for (ceil_div = 0; remainder > 0; ceil_div++) begin
            remainder = remainder - divisor;
        end
    endfunction
    
    
    
    
    
    
    
    
    
    function automatic integer unsigned idx_width (input integer unsigned num_idx);
        return (num_idx > 32'd1) ? unsigned'($clog2(num_idx)) : 32'd1;
    endfunction
    
    
    function automatic bit is_power_of_2 (input integer unsigned value);
        return (value != 0) && (value & (value - 1)) == 0;
    endfunction
endpackage

module counter #(
    parameter int unsigned WIDTH = 4,
    parameter bit STICKY_OVERFLOW = 1'b0
)(
    input  logic             clk_i,
    input  logic             rst_ni,
    input  logic             clear_i, 
    input  logic             en_i,    
    input  logic             load_i,  
    input  logic             down_i,  
    input  logic [WIDTH-1:0] d_i,
    output logic [WIDTH-1:0] q_o,
    output logic             overflow_o
);
    delta_counter #(
        .WIDTH          (WIDTH),
        .STICKY_OVERFLOW (STICKY_OVERFLOW)
    ) i_counter (
        .clk_i,
        .rst_ni,
        .clear_i,
        .en_i,
        .load_i,
        .down_i,
        .delta_i({{WIDTH-1{1'b0}}, 1'b1}),
        .d_i,
        .q_o,
        .overflow_o
    );
endmodule

module delta_counter #(
    parameter int unsigned WIDTH = 4,
    parameter bit STICKY_OVERFLOW = 1'b0
)(
    input  logic             clk_i,
    input  logic             rst_ni,
    input  logic             clear_i, 
    input  logic             en_i,    
    input  logic             load_i,  
    input  logic             down_i,  
    input  logic [WIDTH-1:0] delta_i,
    input  logic [WIDTH-1:0] d_i,
    output logic [WIDTH-1:0] q_o,
    output logic             overflow_o
);
    logic [WIDTH:0] counter_q, counter_d;
    if (STICKY_OVERFLOW) begin : gen_sticky_overflow
        logic overflow_d, overflow_q;
        always_ff @(posedge clk_i or negedge rst_ni)
        begin
            if(!rst_ni) begin
                overflow_q <= 1'b0;
            end else begin
                overflow_q <= overflow_d;
            end
        end
        always_comb begin
            overflow_d = overflow_q;
            if (clear_i || load_i) begin
                overflow_d = 1'b0;
            end else if (!overflow_q && en_i) begin
                if (down_i) begin
                    overflow_d = delta_i > counter_q[WIDTH-1:0];
                end else begin
                    overflow_d = counter_q[WIDTH-1:0] > ({WIDTH{1'b1}} - delta_i);
                end
            end
        end
        assign overflow_o = overflow_q;
    end else begin : gen_transient_overflow
        
        assign overflow_o = counter_q[WIDTH];
    end
    assign q_o = counter_q[WIDTH-1:0];
    always_comb begin
        counter_d = counter_q;
        if (clear_i) begin
            counter_d = '0;
        end else if (load_i) begin
            counter_d = {1'b0, d_i};
        end else if (en_i) begin
            if (down_i) begin
                counter_d = counter_q - delta_i;
            end else begin
                counter_d = counter_q + delta_i;
            end
        end
    end
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
           counter_q <= '0;
        end else begin
           counter_q <= counter_d;
        end
    end
endmodule

`ifndef COMMON_CELLS_ASSERTIONS_SVH
`define COMMON_CELLS_ASSERTIONS_SVH
`ifdef UVM
  
  package assert_rpt_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    function void assert_rpt(string msg);
      `uvm_error("ASSERT FAILED", msg)
    endfunction
  endpackage`endif
`ifndef ASSERTS_OFF
`ifndef SYNTHESIS
`ifndef XSIM
`define INC_ASSERT
`endif
`endif   
`endif
`ifdef ASSERTS_OVERRIDE_ON`ifndef INC_ASSERT
`define INC_ASSERT`endif`endif
`define ASSERT_STRINGIFY(__x) `"__x`"
`ifndef ASSERT_RPT
`define ASSERT_RPT(__name, __desc = "")                                                 \
`ifdef UVM                                                                              \
  assert_rpt_pkg::assert_rpt($sformatf("[%m] %s: %s (%s:%0d)",                          \
                             __name, __desc, `__FILE__, `__LINE__));                    \
`else                                                                                   \
  $error("[ASSERT FAILED] [%m] %s: %s (%s:%0d)", __name, __desc, `__FILE__, `__LINE__); \
`endif
`endif
`define ASSERT_DEFAULT_CLK clk_i
`define ASSERT_DEFAULT_RST !rst_ni
`define ASSERT_I(__name, __prop, __desc = "")        \
`ifdef INC_ASSERT                                    \
  __name: assert (__prop)                            \
    else begin                                       \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
    end                                              \
`endif
`define ASSERT_INIT(__name, __prop, __desc = "")       \
`ifdef INC_ASSERT                                      \
  initial begin                                        \
    __name: assert (__prop)                            \
      else begin                                       \
        `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
      end                                              \
  end                                                  \
`endif
`define ASSERT_FINAL(__name, __prop, __desc = "")                            \
`ifdef INC_ASSERT                                                            \
  final begin                                                                \
    __name: assert (__prop || $test$plusargs("disable_assert_final_checks")) \
      else begin                                                             \
        `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                       \
      end                                                                    \
  end                                                                        \
`endif
`define ASSERT(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                     \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop))                    \
    else begin                                                                                        \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                  \
    end                                                                                               \
`endif
`define ASSERT_NEVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                           \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) not (__prop))                      \
    else begin                                                                                              \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                        \
    end                                                                                                     \
`endif
`define ASSERT_KNOWN(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                          \
  `ASSERT(__name, !$isunknown(__sig), __clk, __rst, __desc)                                                \
`endif
`define COVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifdef INC_ASSERT                                                                       \
  __name: cover property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop));      \
`endif
`define ASSERT_PULSE(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                          \
  `ASSERT(__name, $rose(__sig) |=> !(__sig), __clk, __rst, __desc)                                         \
`endif
`define ASSERT_IF(__name, __prop, __enable, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                  \
  `ASSERT(__name, (__enable) |-> (__prop), __clk, __rst, __desc)                                                   \
`endif
`define ASSERT_KNOWN_IF(__name, __sig, __enable, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                       \
  `ASSERT_KNOWN(__name``KnownEnable, __enable, __clk, __rst, __desc)                                                    \
  `ASSERT_IF(__name, !$isunknown(__sig), __enable, __clk, __rst, __desc)                                                \
`endif
`define ASSERT_STABLE(__name, __valid, __ready, __data, __mask = '0, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                                           \
  `ASSERT(__name, (__valid) && !(__ready) |=> $stable((__data) & ~(__mask)), __clk, __rst, __desc)                                          \
`endif
`define ASSUME(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                     \
  __name: assume property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop))                    \
    else begin                                                                                        \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                  \
    end                                                                                               \
`endif
`define ASSUME_I(__name, __prop, __desc = "")        \
`ifdef INC_ASSERT                                    \
  __name: assume (__prop)                            \
    else begin                                       \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
    end                                              \
`endif
`define ASSUME_FPV(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef FPV_ON                                                                                             \
   `ASSUME(__name, __prop, __clk, __rst, __desc)                                                          \
`endif
`define ASSUME_I_FPV(__name, __prop, __desc = "") \
`ifdef FPV_ON                                     \
   `ASSUME_I(__name, __prop, __desc)              \
`endif
`define COVER_FPV(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifdef FPV_ON                                                                               \
   `COVER(__name, __prop, __clk, __rst)                                                     \
`endif
`endif 
module fifo_v3 #(
    parameter bit          FALL_THROUGH = 1'b0, 
    parameter int unsigned DATA_WIDTH   = 32,   
    parameter int unsigned DEPTH        = 8,    
    parameter type dtype                = logic [DATA_WIDTH-1:0],
    
    parameter int unsigned ADDR_DEPTH   = (DEPTH > 1) ? $clog2(DEPTH) : 1
)(
    input  logic  clk_i,            
    input  logic  rst_ni,           
    input  logic  flush_i,          
    input  logic  testmode_i,       
    
    output logic  full_o,           
    output logic  empty_o,          
    output logic  [ADDR_DEPTH-1:0] usage_o,  
    
    input  dtype  data_i,           
    input  logic  push_i,           
    
    output dtype  data_o,           
    input  logic  pop_i             
);
    
    
    localparam int unsigned FifoDepth = (DEPTH > 0) ? DEPTH : 1;
    
    logic gate_clock;
    
    logic [ADDR_DEPTH - 1:0] read_pointer_n, read_pointer_q, write_pointer_n, write_pointer_q;
    
    
    logic [ADDR_DEPTH:0] status_cnt_n, status_cnt_q;
    
    dtype [FifoDepth - 1:0] mem_n, mem_q;
    assign usage_o = status_cnt_q[ADDR_DEPTH-1:0];
    if (DEPTH == 0) begin : gen_pass_through
        assign empty_o     = ~push_i;
        assign full_o      = ~pop_i;
    end else begin : gen_fifo
        assign full_o       = (status_cnt_q == FifoDepth[ADDR_DEPTH:0]);
        assign empty_o      = (status_cnt_q == 0) & ~(FALL_THROUGH & push_i);
    end
    
    
    always_comb begin : read_write_comb
        
        read_pointer_n  = read_pointer_q;
        write_pointer_n = write_pointer_q;
        status_cnt_n    = status_cnt_q;
        data_o          = (DEPTH == 0) ? data_i : mem_q[read_pointer_q];
        mem_n           = mem_q;
        gate_clock      = 1'b1;
        
        if (push_i && ~full_o) begin
            
            mem_n[write_pointer_q] = data_i;
            
            gate_clock = 1'b0;
            
            
            if (write_pointer_q == FifoDepth[ADDR_DEPTH-1:0] - 1)
                write_pointer_n = '0;
            else
                write_pointer_n = write_pointer_q + 1;
            
            status_cnt_n    = status_cnt_q + 1;
        end
        if (pop_i && ~empty_o) begin
            
            
            
            if (read_pointer_n == FifoDepth[ADDR_DEPTH-1:0] - 1)
                read_pointer_n = '0;
            else
                read_pointer_n = read_pointer_q + 1;
            
            status_cnt_n   = status_cnt_q - 1;
        end
        
        if (push_i && pop_i &&  ~full_o && ~empty_o)
            status_cnt_n   = status_cnt_q;
        
        if (FALL_THROUGH && (status_cnt_q == 0) && push_i) begin
            data_o = data_i;
            if (pop_i) begin
                status_cnt_n = status_cnt_q;
                read_pointer_n = read_pointer_q;
                write_pointer_n = write_pointer_q;
            end
        end
    end
    
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            read_pointer_q  <= '0;
            write_pointer_q <= '0;
            status_cnt_q    <= '0;
        end else begin
            if (flush_i) begin
                read_pointer_q  <= '0;
                write_pointer_q <= '0;
                status_cnt_q    <= '0;
             end else begin
                read_pointer_q  <= read_pointer_n;
                write_pointer_q <= write_pointer_n;
                status_cnt_q    <= status_cnt_n;
            end
        end
    end
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) begin
            mem_q <= {FifoDepth{dtype'('0)}};
        end else if (!gate_clock) begin
            mem_q <= mem_n;
        end
    end
`ifndef COMMON_CELLS_ASSERTS_OFF
    `ASSERT_INIT(depth_0, DEPTH > 0, "DEPTH must be greater than 0.")
    `ASSERT(full_write, full_o |-> ~push_i, clk_i, !rst_ni,
            "Trying to push new data although the FIFO is full.")
    `ASSERT(empty_read, empty_o |-> ~pop_i, clk_i, !rst_ni,
            "Trying to pop data although the FIFO is empty.")
`endif
endmodule 

`ifndef COMMON_CELLS_ASSERTIONS_SVH
`define COMMON_CELLS_ASSERTIONS_SVH
`ifdef UVM
  
  package assert_rpt_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    function void assert_rpt(string msg);
      `uvm_error("ASSERT FAILED", msg)
    endfunction
  endpackage`endif
`ifndef ASSERTS_OFF
`ifndef SYNTHESIS
`ifndef XSIM
`define INC_ASSERT
`endif
`endif   
`endif
`ifdef ASSERTS_OVERRIDE_ON`ifndef INC_ASSERT
`define INC_ASSERT`endif`endif
`define ASSERT_STRINGIFY(__x) `"__x`"
`ifndef ASSERT_RPT
`define ASSERT_RPT(__name, __desc = "")                                                 \
`ifdef UVM                                                                              \
  assert_rpt_pkg::assert_rpt($sformatf("[%m] %s: %s (%s:%0d)",                          \
                             __name, __desc, `__FILE__, `__LINE__));                    \
`else                                                                                   \
  $error("[ASSERT FAILED] [%m] %s: %s (%s:%0d)", __name, __desc, `__FILE__, `__LINE__); \
`endif
`endif
`define ASSERT_DEFAULT_CLK clk_i
`define ASSERT_DEFAULT_RST !rst_ni
`define ASSERT_I(__name, __prop, __desc = "")        \
`ifdef INC_ASSERT                                    \
  __name: assert (__prop)                            \
    else begin                                       \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
    end                                              \
`endif
`define ASSERT_INIT(__name, __prop, __desc = "")       \
`ifdef INC_ASSERT                                      \
  initial begin                                        \
    __name: assert (__prop)                            \
      else begin                                       \
        `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
      end                                              \
  end                                                  \
`endif
`define ASSERT_FINAL(__name, __prop, __desc = "")                            \
`ifdef INC_ASSERT                                                            \
  final begin                                                                \
    __name: assert (__prop || $test$plusargs("disable_assert_final_checks")) \
      else begin                                                             \
        `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                       \
      end                                                                    \
  end                                                                        \
`endif
`define ASSERT(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                     \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop))                    \
    else begin                                                                                        \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                  \
    end                                                                                               \
`endif
`define ASSERT_NEVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                           \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) not (__prop))                      \
    else begin                                                                                              \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                        \
    end                                                                                                     \
`endif
`define ASSERT_KNOWN(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                          \
  `ASSERT(__name, !$isunknown(__sig), __clk, __rst, __desc)                                                \
`endif
`define COVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifdef INC_ASSERT                                                                       \
  __name: cover property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop));      \
`endif
`define ASSERT_PULSE(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                          \
  `ASSERT(__name, $rose(__sig) |=> !(__sig), __clk, __rst, __desc)                                         \
`endif
`define ASSERT_IF(__name, __prop, __enable, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                  \
  `ASSERT(__name, (__enable) |-> (__prop), __clk, __rst, __desc)                                                   \
`endif
`define ASSERT_KNOWN_IF(__name, __sig, __enable, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                       \
  `ASSERT_KNOWN(__name``KnownEnable, __enable, __clk, __rst, __desc)                                                    \
  `ASSERT_IF(__name, !$isunknown(__sig), __enable, __clk, __rst, __desc)                                                \
`endif
`define ASSERT_STABLE(__name, __valid, __ready, __data, __mask = '0, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                                           \
  `ASSERT(__name, (__valid) && !(__ready) |=> $stable((__data) & ~(__mask)), __clk, __rst, __desc)                                          \
`endif
`define ASSUME(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                     \
  __name: assume property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop))                    \
    else begin                                                                                        \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                  \
    end                                                                                               \
`endif
`define ASSUME_I(__name, __prop, __desc = "")        \
`ifdef INC_ASSERT                                    \
  __name: assume (__prop)                            \
    else begin                                       \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
    end                                              \
`endif
`define ASSUME_FPV(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef FPV_ON                                                                                             \
   `ASSUME(__name, __prop, __clk, __rst, __desc)                                                          \
`endif
`define ASSUME_I_FPV(__name, __prop, __desc = "") \
`ifdef FPV_ON                                     \
   `ASSUME_I(__name, __prop, __desc)              \
`endif
`define COVER_FPV(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifdef FPV_ON                                                                               \
   `COVER(__name, __prop, __clk, __rst)                                                     \
`endif
`endif 
module lzc #(
  
  parameter int unsigned WIDTH = 2,
  
  parameter bit          MODE  = 1'b0,
  
  
  
  parameter int unsigned CNT_WIDTH = cf_math_pkg::idx_width(WIDTH)
) (
  
  input  logic [WIDTH-1:0]     in_i,
  
  output logic [CNT_WIDTH-1:0] cnt_o,
  
  output logic                 empty_o
);
  `ifndef COMMON_CELLS_ASSERTS_OFF
    `ASSERT_INIT(width_0, WIDTH > 0, "input must be at least one bit wide")
  `endif
  if (WIDTH <= 1) begin : gen_degenerate_lzc
    assign cnt_o[0] = !in_i[0];
    assign empty_o = !in_i[0];
  end else begin : gen_lzc
    localparam int unsigned NumLevels = $clog2(WIDTH);
    logic [WIDTH-1:0][NumLevels-1:0] index_lut;
    logic [2**NumLevels-1:0] sel_nodes                  ;
    logic [2**NumLevels-1:0][NumLevels-1:0] index_nodes ;
    logic [WIDTH-1:0] in_tmp;
    if (MODE) begin : g_flip
      
      always_comb begin : flip_vector
        for (int unsigned i = 0; i < WIDTH; i++) begin
          in_tmp[i] = in_i[WIDTH-1-i];
        end
      end
    end else begin : g_no_flip
      
      assign in_tmp = in_i;
    end
    for (genvar j = 0; unsigned'(j) < WIDTH; j++) begin : g_index_lut
      assign index_lut[j] = (NumLevels)'(unsigned'(j));
    end
    for (genvar level = 0; unsigned'(level) < NumLevels; level++) begin : g_levels
      if (unsigned'(level) == NumLevels - 1) begin : g_last_level
        for (genvar k = 0; k < 2 ** level; k++) begin : g_level
          
          if (unsigned'(k) * 2 < WIDTH - 1) begin : g_reduce
            assign sel_nodes[2 ** level - 1 + k] = in_tmp[k * 2] | in_tmp[k * 2 + 1];
            assign index_nodes[2 ** level - 1 + k] = (in_tmp[k * 2] == 1'b1)
              ? index_lut[k * 2] :
                index_lut[k * 2 + 1];
          end
          
          if (unsigned'(k) * 2 == WIDTH - 1) begin : g_base
            assign sel_nodes[2 ** level - 1 + k] = in_tmp[k * 2];
            assign index_nodes[2 ** level - 1 + k] = index_lut[k * 2];
          end
          
          if (unsigned'(k) * 2 > WIDTH - 1) begin : g_out_of_range
            assign sel_nodes[2 ** level - 1 + k] = 1'b0;
            assign index_nodes[2 ** level - 1 + k] = '0;
          end
        end
      end else begin : g_not_last_level
        for (genvar l = 0; l < 2 ** level; l++) begin : g_level
          assign sel_nodes[2 ** level - 1 + l] =
              sel_nodes[2 ** (level + 1) - 1 + l * 2] | sel_nodes[2 ** (level + 1) - 1 + l * 2 + 1];
          assign index_nodes[2 ** level - 1 + l] = (sel_nodes[2 ** (level + 1) - 1 + l * 2] == 1'b1)
            ? index_nodes[2 ** (level + 1) - 1 + l * 2] :
              index_nodes[2 ** (level + 1) - 1 + l * 2 + 1];
        end
      end
    end
    assign cnt_o = NumLevels > unsigned'(0) ? index_nodes[0] : {($clog2(WIDTH)) {1'b0}};
    assign empty_o = NumLevels > unsigned'(0) ? ~sel_nodes[0] : ~(|in_i);
  end : gen_lzc
endmodule : lzc

`ifndef COMMON_CELLS_ASSERTIONS_SVH
`define COMMON_CELLS_ASSERTIONS_SVH
`ifdef UVM
  
  package assert_rpt_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    function void assert_rpt(string msg);
      `uvm_error("ASSERT FAILED", msg)
    endfunction
  endpackage`endif
`ifndef ASSERTS_OFF
`ifndef SYNTHESIS
`ifndef XSIM
`define INC_ASSERT
`endif
`endif   
`endif
`ifdef ASSERTS_OVERRIDE_ON`ifndef INC_ASSERT
`define INC_ASSERT`endif`endif
`define ASSERT_STRINGIFY(__x) `"__x`"
`ifndef ASSERT_RPT
`define ASSERT_RPT(__name, __desc = "")                                                 \
`ifdef UVM                                                                              \
  assert_rpt_pkg::assert_rpt($sformatf("[%m] %s: %s (%s:%0d)",                          \
                             __name, __desc, `__FILE__, `__LINE__));                    \
`else                                                                                   \
  $error("[ASSERT FAILED] [%m] %s: %s (%s:%0d)", __name, __desc, `__FILE__, `__LINE__); \
`endif
`endif
`define ASSERT_DEFAULT_CLK clk_i
`define ASSERT_DEFAULT_RST !rst_ni
`define ASSERT_I(__name, __prop, __desc = "")        \
`ifdef INC_ASSERT                                    \
  __name: assert (__prop)                            \
    else begin                                       \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
    end                                              \
`endif
`define ASSERT_INIT(__name, __prop, __desc = "")       \
`ifdef INC_ASSERT                                      \
  initial begin                                        \
    __name: assert (__prop)                            \
      else begin                                       \
        `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
      end                                              \
  end                                                  \
`endif
`define ASSERT_FINAL(__name, __prop, __desc = "")                            \
`ifdef INC_ASSERT                                                            \
  final begin                                                                \
    __name: assert (__prop || $test$plusargs("disable_assert_final_checks")) \
      else begin                                                             \
        `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                       \
      end                                                                    \
  end                                                                        \
`endif
`define ASSERT(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                     \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop))                    \
    else begin                                                                                        \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                  \
    end                                                                                               \
`endif
`define ASSERT_NEVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                           \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) not (__prop))                      \
    else begin                                                                                              \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                        \
    end                                                                                                     \
`endif
`define ASSERT_KNOWN(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                          \
  `ASSERT(__name, !$isunknown(__sig), __clk, __rst, __desc)                                                \
`endif
`define COVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifdef INC_ASSERT                                                                       \
  __name: cover property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop));      \
`endif
`define ASSERT_PULSE(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                          \
  `ASSERT(__name, $rose(__sig) |=> !(__sig), __clk, __rst, __desc)                                         \
`endif
`define ASSERT_IF(__name, __prop, __enable, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                  \
  `ASSERT(__name, (__enable) |-> (__prop), __clk, __rst, __desc)                                                   \
`endif
`define ASSERT_KNOWN_IF(__name, __sig, __enable, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                       \
  `ASSERT_KNOWN(__name``KnownEnable, __enable, __clk, __rst, __desc)                                                    \
  `ASSERT_IF(__name, !$isunknown(__sig), __enable, __clk, __rst, __desc)                                                \
`endif
`define ASSERT_STABLE(__name, __valid, __ready, __data, __mask = '0, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                                           \
  `ASSERT(__name, (__valid) && !(__ready) |=> $stable((__data) & ~(__mask)), __clk, __rst, __desc)                                          \
`endif
`define ASSUME(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                     \
  __name: assume property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop))                    \
    else begin                                                                                        \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                  \
    end                                                                                               \
`endif
`define ASSUME_I(__name, __prop, __desc = "")        \
`ifdef INC_ASSERT                                    \
  __name: assume (__prop)                            \
    else begin                                       \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
    end                                              \
`endif
`define ASSUME_FPV(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef FPV_ON                                                                                             \
   `ASSUME(__name, __prop, __clk, __rst, __desc)                                                          \
`endif
`define ASSUME_I_FPV(__name, __prop, __desc = "") \
`ifdef FPV_ON                                     \
   `ASSUME_I(__name, __prop, __desc)              \
`endif
`define COVER_FPV(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifdef FPV_ON                                                                               \
   `COVER(__name, __prop, __clk, __rst)                                                     \
`endif
`endif 
module rr_arb_tree #(
  
  parameter int unsigned NumIn      = 64,
  
  parameter int unsigned DataWidth  = 32,
  
  parameter type         DataType   = logic [DataWidth-1:0],
  
  
  
  
  
  
  parameter bit          ExtPrio    = 1'b0,
  
  
  
  
  
  
  parameter bit          AxiVldRdy  = 1'b0,
  
  
  
  
  
  
  parameter bit          LockIn     = 1'b0,
  
  
  
  parameter bit          FairArb    = 1'b1,
  
  
  parameter int unsigned IdxWidth   = (NumIn > 32'd1) ? unsigned'($clog2(NumIn)) : 32'd1,
  
  
  parameter type         idx_t      = logic [IdxWidth-1:0]
) (
  
  input  logic                clk_i,
  
  input  logic                rst_ni,
  
  input  logic                flush_i,
  
  input  idx_t                rr_i,
  
  input  logic    [NumIn-1:0] req_i,
  
  
  output logic    [NumIn-1:0] gnt_o,
  
  
  input  DataType [NumIn-1:0] data_i,
  
  output logic                req_o,
  
  input  logic                gnt_i,
  
  output DataType             data_o,
  
  output idx_t                idx_o
);
  
  if (NumIn == unsigned'(1)) begin : gen_pass_through
    assign req_o    = req_i[0];
    assign gnt_o[0] = gnt_i;
    assign data_o   = data_i[0];
    assign idx_o    = '0;
  
  end else begin : gen_arbiter
    localparam int unsigned NumLevels = unsigned'($clog2(NumIn));
      
    idx_t    [2**NumLevels-2:0] index_nodes ; 
    DataType [2**NumLevels-2:0] data_nodes  ; 
    logic    [2**NumLevels-2:0] gnt_nodes   ; 
    logic    [2**NumLevels-2:0] req_nodes   ; 
    
    
    idx_t                       rr_q;
    logic [NumIn-1:0]           req_d;
    
    assign req_o        = req_nodes[0];
    assign data_o       = data_nodes[0];
    assign idx_o        = index_nodes[0];
    if (ExtPrio) begin : gen_ext_rr
      assign rr_q       = rr_i;
      assign req_d      = req_i;
    end else begin : gen_int_rr
      idx_t rr_d;
      
      if (LockIn) begin : gen_lock
        logic  lock_d, lock_q;
        logic [NumIn-1:0] req_q;
        assign lock_d     = req_o & ~gnt_i;
        assign req_d      = (lock_q) ? req_q : req_i;
        always_ff @(posedge clk_i or negedge rst_ni) begin : p_lock_reg
          if (!rst_ni) begin
            lock_q <= '0;
          end else begin
            if (flush_i) begin
              lock_q <= '0;
            end else begin
              lock_q <= lock_d;
            end
          end
        end
        `ifndef COMMON_CELLS_ASSERTS_OFF
          `ASSERT(lock, req_o && (!gnt_i && !flush_i) |=> idx_o == $past(idx_o),
                  clk_i, !rst_ni || flush_i,
                  "Lock implies same arbiter decision in next cycle if output is not ready.")
          logic [NumIn-1:0] req_tmp;
          assign req_tmp = req_q & req_i;
          `ASSUME(lock_req, lock_d |=> req_tmp == req_q, clk_i, !rst_ni || flush_i,
                  "It is disallowed to deassert unserved request signals when LockIn is enabled.")
        `endif
        always_ff @(posedge clk_i or negedge rst_ni) begin : p_req_regs
          if (!rst_ni) begin
            req_q  <= '0;
          end else begin
            if (flush_i) begin
              req_q  <= '0;
            end else begin
              req_q  <= req_d;
            end
          end
        end
      end else begin : gen_no_lock
        assign req_d = req_i;
      end
      if (FairArb) begin : gen_fair_arb
        logic [NumIn-1:0] upper_mask,  lower_mask;
        idx_t             upper_idx,   lower_idx,   next_idx;
        logic             upper_empty, lower_empty;
        for (genvar i = 0; i < NumIn; i++) begin : gen_mask
          assign upper_mask[i] = (i >  rr_q) ? req_d[i] : 1'b0;
          assign lower_mask[i] = (i <= rr_q) ? req_d[i] : 1'b0;
        end
        lzc #(
          .WIDTH ( NumIn ),
          .MODE  ( 1'b0  )
        ) i_lzc_upper (
          .in_i    ( upper_mask  ),
          .cnt_o   ( upper_idx   ),
          .empty_o ( upper_empty )
        );
        lzc #(
          .WIDTH ( NumIn ),
          .MODE  ( 1'b0  )
        ) i_lzc_lower (
          .in_i    ( lower_mask  ),
          .cnt_o   ( lower_idx   ),
          .empty_o (   )
        );
        assign next_idx = upper_empty      ? lower_idx : upper_idx;
        assign rr_d     = (gnt_i && req_o) ? next_idx  : rr_q;
      end else begin : gen_unfair_arb
        assign rr_d = (gnt_i && req_o) ? ((rr_q == idx_t'(NumIn-1)) ? '0 : rr_q + 1'b1) : rr_q;
      end
      
      always_ff @(posedge clk_i or negedge rst_ni) begin : p_rr_regs
        if (!rst_ni) begin
          rr_q   <= '0;
        end else begin
          if (flush_i) begin
            rr_q   <= '0;
          end else begin
            rr_q   <= rr_d;
          end
        end
      end
    end
    assign gnt_nodes[0] = gnt_i;
    
    for (genvar level = 0; unsigned'(level) < NumLevels; level++) begin : gen_levels
      for (genvar l = 0; l < 2**level; l++) begin : gen_level
        
        logic sel;
        
        localparam int unsigned Idx0 = 2**level-1+l;
        localparam int unsigned Idx1 = 2**(level+1)-1+l*2;
        
        
        if (unsigned'(level) == NumLevels-1) begin : gen_first_level
          
          if (unsigned'(l) * 2 < NumIn-1) begin : gen_reduce
            assign req_nodes[Idx0]   = req_d[l*2] | req_d[l*2+1];
            
            assign sel =  ~req_d[l*2] | req_d[l*2+1] & rr_q[NumLevels-1-level];
            assign index_nodes[Idx0] = idx_t'(sel);
            assign data_nodes[Idx0]  = (sel) ? data_i[l*2+1] : data_i[l*2];
            assign gnt_o[l*2]        = gnt_nodes[Idx0] & (AxiVldRdy | req_d[l*2])   & ~sel;
            assign gnt_o[l*2+1]      = gnt_nodes[Idx0] & (AxiVldRdy | req_d[l*2+1]) & sel;
          end
          
          if (unsigned'(l) * 2 == NumIn-1) begin : gen_first
            assign req_nodes[Idx0]   = req_d[l*2];
            assign index_nodes[Idx0] = '0;
            assign data_nodes[Idx0]  = data_i[l*2];
            assign gnt_o[l*2]        = gnt_nodes[Idx0] & (AxiVldRdy | req_d[l*2]);
          end
          
          if (unsigned'(l) * 2 > NumIn-1) begin : gen_out_of_range
            assign req_nodes[Idx0]   = 1'b0;
            assign index_nodes[Idx0] = idx_t'('0);
            assign data_nodes[Idx0]  = DataType'('0);
          end
        
        
        end else begin : gen_other_levels
          assign req_nodes[Idx0]   = req_nodes[Idx1] | req_nodes[Idx1+1];
          
          assign sel =  ~req_nodes[Idx1] | req_nodes[Idx1+1] & rr_q[NumLevels-1-level];
          assign index_nodes[Idx0] = (sel) ?
            idx_t'({1'b1, index_nodes[Idx1+1][NumLevels-unsigned'(level)-2:0]}) :
            idx_t'({1'b0, index_nodes[Idx1][NumLevels-unsigned'(level)-2:0]});
          assign data_nodes[Idx0]  = (sel) ? data_nodes[Idx1+1] : data_nodes[Idx1];
          assign gnt_nodes[Idx1]   = gnt_nodes[Idx0] & ~sel;
          assign gnt_nodes[Idx1+1] = gnt_nodes[Idx0] & sel;
        end
        
      end
    end
    `ifndef COMMON_CELLS_ASSERTS_OFF
    `ASSERT_INIT(numin_0, NumIn, "Input must be at least one element wide.")
    `ASSERT_INIT(lockin_and_extprio, !(LockIn && ExtPrio),
                 "Cannot use LockIn feature together with external ExtPrio.")
    `ASSERT(hot_one, $onehot0(gnt_o), clk_i, !rst_ni || flush_i,
            "Grant signal must be hot1 or zero.")
    `ASSERT(gnt0, |gnt_o |-> gnt_i, clk_i, !rst_ni || flush_i, "Grant out implies grant in.")
    `ASSERT(gnt1, req_o |-> gnt_i |-> |gnt_o, clk_i, !rst_ni || flush_i,
            "Req out and grant in implies grant out.")
    `ASSERT(gnt_idx, req_o |->  gnt_i |-> gnt_o[idx_o], clk_i, !rst_ni || flush_i,
            "Idx_o / gnt_o do not match.")
    `ASSERT(req0, |req_i |-> req_o, clk_i, !rst_ni || flush_i, "Req in implies req out.")
    `ASSERT(req1, req_o |-> |req_i, clk_i, !rst_ni || flush_i, "Req out implies req in.")
    `endif
  end
endmodule : rr_arb_tree

module spill_register #(
  parameter type T      = logic,
  parameter bit  Bypass = 1'b0     
) (
  input  logic clk_i   ,
  input  logic rst_ni  ,
  input  logic valid_i ,
  output logic ready_o ,
  input  T     data_i  ,
  output logic valid_o ,
  input  logic ready_i ,
  output T     data_o
);
  spill_register_flushable #(
    .T(T),
    .Bypass(Bypass)
  ) spill_register_flushable_i (
    .clk_i,
    .rst_ni,
    .valid_i,
    .flush_i(1'b0),
    .ready_o,
    .data_i,
    .valid_o,
    .ready_i,
    .data_o
  );
endmodule

`ifndef COMMON_CELLS_ASSERTIONS_SVH
`define COMMON_CELLS_ASSERTIONS_SVH
`ifdef UVM
  
  package assert_rpt_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    function void assert_rpt(string msg);
      `uvm_error("ASSERT FAILED", msg)
    endfunction
  endpackage`endif
`ifndef ASSERTS_OFF
`ifndef SYNTHESIS
`ifndef XSIM
`define INC_ASSERT
`endif
`endif   
`endif
`ifdef ASSERTS_OVERRIDE_ON`ifndef INC_ASSERT
`define INC_ASSERT`endif`endif
`define ASSERT_STRINGIFY(__x) `"__x`"
`ifndef ASSERT_RPT
`define ASSERT_RPT(__name, __desc = "")                                                 \
`ifdef UVM                                                                              \
  assert_rpt_pkg::assert_rpt($sformatf("[%m] %s: %s (%s:%0d)",                          \
                             __name, __desc, `__FILE__, `__LINE__));                    \
`else                                                                                   \
  $error("[ASSERT FAILED] [%m] %s: %s (%s:%0d)", __name, __desc, `__FILE__, `__LINE__); \
`endif
`endif
`define ASSERT_DEFAULT_CLK clk_i
`define ASSERT_DEFAULT_RST !rst_ni
`define ASSERT_I(__name, __prop, __desc = "")        \
`ifdef INC_ASSERT                                    \
  __name: assert (__prop)                            \
    else begin                                       \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
    end                                              \
`endif
`define ASSERT_INIT(__name, __prop, __desc = "")       \
`ifdef INC_ASSERT                                      \
  initial begin                                        \
    __name: assert (__prop)                            \
      else begin                                       \
        `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
      end                                              \
  end                                                  \
`endif
`define ASSERT_FINAL(__name, __prop, __desc = "")                            \
`ifdef INC_ASSERT                                                            \
  final begin                                                                \
    __name: assert (__prop || $test$plusargs("disable_assert_final_checks")) \
      else begin                                                             \
        `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                       \
      end                                                                    \
  end                                                                        \
`endif
`define ASSERT(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                     \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop))                    \
    else begin                                                                                        \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                  \
    end                                                                                               \
`endif
`define ASSERT_NEVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                           \
  __name: assert property (@(posedge __clk) disable iff ((__rst) !== '0) not (__prop))                      \
    else begin                                                                                              \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                        \
    end                                                                                                     \
`endif
`define ASSERT_KNOWN(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                          \
  `ASSERT(__name, !$isunknown(__sig), __clk, __rst, __desc)                                                \
`endif
`define COVER(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifdef INC_ASSERT                                                                       \
  __name: cover property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop));      \
`endif
`define ASSERT_PULSE(__name, __sig, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                          \
  `ASSERT(__name, $rose(__sig) |=> !(__sig), __clk, __rst, __desc)                                         \
`endif
`define ASSERT_IF(__name, __prop, __enable, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                  \
  `ASSERT(__name, (__enable) |-> (__prop), __clk, __rst, __desc)                                                   \
`endif
`define ASSERT_KNOWN_IF(__name, __sig, __enable, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                       \
  `ASSERT_KNOWN(__name``KnownEnable, __enable, __clk, __rst, __desc)                                                    \
  `ASSERT_IF(__name, !$isunknown(__sig), __enable, __clk, __rst, __desc)                                                \
`endif
`define ASSERT_STABLE(__name, __valid, __ready, __data, __mask = '0, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                                                           \
  `ASSERT(__name, (__valid) && !(__ready) |=> $stable((__data) & ~(__mask)), __clk, __rst, __desc)                                          \
`endif
`define ASSUME(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef INC_ASSERT                                                                                     \
  __name: assume property (@(posedge __clk) disable iff ((__rst) !== '0) (__prop))                    \
    else begin                                                                                        \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc)                                                  \
    end                                                                                               \
`endif
`define ASSUME_I(__name, __prop, __desc = "")        \
`ifdef INC_ASSERT                                    \
  __name: assume (__prop)                            \
    else begin                                       \
      `ASSERT_RPT(`ASSERT_STRINGIFY(__name), __desc) \
    end                                              \
`endif
`define ASSUME_FPV(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST, __desc = "") \
`ifdef FPV_ON                                                                                             \
   `ASSUME(__name, __prop, __clk, __rst, __desc)                                                          \
`endif
`define ASSUME_I_FPV(__name, __prop, __desc = "") \
`ifdef FPV_ON                                     \
   `ASSUME_I(__name, __prop, __desc)              \
`endif
`define COVER_FPV(__name, __prop, __clk = `ASSERT_DEFAULT_CLK, __rst = `ASSERT_DEFAULT_RST) \
`ifdef FPV_ON                                                                               \
   `COVER(__name, __prop, __clk, __rst)                                                     \
`endif
`endif 
module spill_register_flushable #(
  parameter type T           = logic,
  parameter bit  Bypass      = 1'b0   
) (
  input  logic clk_i   ,
  input  logic rst_ni  ,
  input  logic valid_i ,
  input  logic flush_i ,
  output logic ready_o ,
  input  T     data_i  ,
  output logic valid_o ,
  input  logic ready_i ,
  output T     data_o
);
  if (Bypass) begin : gen_bypass
    assign valid_o = valid_i;
    assign ready_o = ready_i;
    assign data_o  = data_i;
  end else begin : gen_spill_reg
    
    T a_data_q;
    logic a_full_q;
    logic a_fill, a_drain;
    always_ff @(posedge clk_i or negedge rst_ni) begin : ps_a_data
      if (!rst_ni)
        a_data_q <= T'('0);
      else if (a_fill)
        a_data_q <= data_i;
    end
    always_ff @(posedge clk_i or negedge rst_ni) begin : ps_a_full
      if (!rst_ni)
        a_full_q <= 0;
      else if (a_fill || a_drain)
        a_full_q <= a_fill;
    end
    
    T b_data_q;
    logic b_full_q;
    logic b_fill, b_drain;
    always_ff @(posedge clk_i or negedge rst_ni) begin : ps_b_data
      if (!rst_ni)
        b_data_q <= T'('0);
      else if (b_fill)
        b_data_q <= a_data_q;
    end
    always_ff @(posedge clk_i or negedge rst_ni) begin : ps_b_full
      if (!rst_ni)
        b_full_q <= 0;
      else if (b_fill || b_drain)
        b_full_q <= b_fill;
    end
    
    
    assign a_fill = valid_i && ready_o && (!flush_i);
    assign a_drain = (a_full_q && !b_full_q) || flush_i;
    
    
    
    assign b_fill = a_drain && (!ready_i) && (!flush_i);
    assign b_drain = (b_full_q && ready_i) || flush_i;
    
    
    
    assign ready_o = !a_full_q || !b_full_q;
    
    assign valid_o = a_full_q | b_full_q;
    
    assign data_o = b_full_q ? b_data_q : a_data_q;
    `ifndef COMMON_CELLS_ASSERTS_OFF
    `ASSERT(flush_valid, flush_i |-> ~valid_i, clk_i, !rst_ni,
           "Trying to flush and feed the spill register simultaneously. You will lose data!")
   `endif
  end
endmodule

`ifndef COMMON_CELLS_REGISTERS_SVH_
`define COMMON_CELLS_REGISTERS_SVH_
`ifdef VERILATOR
`define NO_SYNOPSYS_FF 1`endif
`define REG_DFLT_CLK clk_i
`define REG_DFLT_RST rst_ni
`define FF(__q, __d, __reset_value, __clk = `REG_DFLT_CLK, __arst_n = `REG_DFLT_RST) \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin                           \
    if (!__arst_n) begin                                                             \
      __q <= (__reset_value);                                                        \
    end else begin                                                                   \
      __q <= (__d);                                                                  \
    end                                                                              \
  end
`define FFAR(__q, __d, __reset_value, __clk, __arst)     \
  always_ff @(posedge (__clk) or posedge (__arst)) begin \
    if (__arst) begin                                    \
      __q <= (__reset_value);                            \
    end else begin                                       \
      __q <= (__d);                                      \
    end                                                  \
  end
`define FFARN(__q, __d, __reset_value, __clk, __arst_n) \
  `FF(__q, __d, __reset_value, __clk, __arst_n)
`define FFSR(__q, __d, __reset_value, __clk, __reset_clk) \
  `ifndef NO_SYNOPSYS_FF                                  \
  /``* synopsys sync_set_reset `"__reset_clk`" *``/       \
  `endif                                                  \
  always_ff @(posedge (__clk)) begin                      \
    __q <= (__reset_clk) ? (__reset_value) : (__d);       \
  end
`define FFSRN(__q, __d, __reset_value, __clk, __reset_n_clk) \
  `ifndef NO_SYNOPSYS_FF                                     \
  /``* synopsys sync_set_reset `"__reset_n_clk`" *``/        \
  `endif                                                     \
  always_ff @(posedge (__clk)) begin                         \
    __q <= (!__reset_n_clk) ? (__reset_value) : (__d);       \
  end
`define FFNR(__q, __d, __clk)        \
  always_ff @(posedge (__clk)) begin \
    __q <= (__d);                    \
  end
`define FFL(__q, __d, __load, __reset_value, __clk = `REG_DFLT_CLK, __arst_n = `REG_DFLT_RST) \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin                                    \
    if (!__arst_n) begin                                                                      \
      __q <= (__reset_value);                                                                 \
    end else begin                                                                            \
      if (__load) begin                                                                       \
        __q <= (__d);                                                                         \
      end                                                                                     \
    end                                                                                       \
  end
`define FFLAR(__q, __d, __load, __reset_value, __clk, __arst) \
  always_ff @(posedge (__clk) or posedge (__arst)) begin      \
    if (__arst) begin                                         \
      __q <= (__reset_value);                                 \
    end else begin                                            \
      if (__load) begin                                       \
        __q <= (__d);                                         \
      end                                                     \
    end                                                       \
  end
`define FFLARN(__q, __d, __load, __reset_value, __clk, __arst_n) \
  `FFL(__q, __d, __load, __reset_value, __clk, __arst_n)
`define FFLSR(__q, __d, __load, __reset_value, __clk, __reset_clk) \
  `ifndef NO_SYNOPSYS_FF                                           \
  /``* synopsys sync_set_reset `"__reset_clk`" *``/                \
  `endif                                                           \
  always_ff @(posedge (__clk)) begin                               \
    if (__reset_clk) begin                                         \
      __q <= (__reset_value);                                      \
    end else if (__load) begin                                     \
      __q <= (__d);                                                \
    end                                                            \
  end
`define FFLSRN(__q, __d, __load, __reset_value, __clk, __reset_n_clk) \
  `ifndef NO_SYNOPSYS_FF                                              \
  /``* synopsys sync_set_reset `"__reset_n_clk`" *``/                 \
  `endif                                                              \
  always_ff @(posedge (__clk)) begin                                  \
    if (!__reset_n_clk) begin                                         \
      __q <= (__reset_value);                                         \
    end else if (__load) begin                                        \
      __q <= (__d);                                                   \
    end                                                               \
  end
`define FFLARNC(__q, __d, __load, __clear, __reset_value, __clk, __arst_n) \
    `ifndef NO_SYNOPSYS_FF                                                 \
  /``* synopsys sync_set_reset `"__clear`" *``/                            \
    `endif                                                                 \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin                 \
    if (!__arst_n) begin                                                   \
      __q <= (__reset_value);                                              \
    end else begin                                                         \
      if (__clear) begin                                                   \
        __q <= (__reset_value);                                            \
      end else if (__load) begin                                           \
        __q <= (__d);                                                      \
      end                                                                  \
    end                                                                    \
  end
`define FFARNC(__q, __d, __clear, __reset_value, __clk, __arst_n) \
    `ifndef NO_SYNOPSYS_FF                                        \
  /``* synopsys sync_set_reset `"__clear`" *``/                   \
    `endif                                                        \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin        \
    if (!__arst_n) begin                                          \
      __q <= (__reset_value);                                     \
    end else begin                                                \
      if (__clear) begin                                          \
        __q <= (__reset_value);                                   \
      end else begin                                              \
        __q <= (__d);                                             \
      end                                                         \
    end                                                           \
  end
`define FFLNR(__q, __d, __load, __clk) \
  always_ff @(posedge (__clk)) begin   \
    if (__load) begin                  \
      __q <= (__d);                    \
    end                                \
  end
`endif
module stream_register #(
    parameter type T = logic  
) (
    input  logic    clk_i,          
    input  logic    rst_ni,         
    input  logic    clr_i,          
    input  logic    testmode_i,     
    
    input  logic    valid_i,
    output logic    ready_o,
    input  T        data_i,
    
    output logic    valid_o,
    input  logic    ready_i,
    output T        data_o
);
    logic reg_ena;
    assign ready_o = ready_i | ~valid_o;
    assign reg_ena = valid_i & ready_o;
    
    `FFLARNC(valid_o, valid_i, ready_o, clr_i, 1'b0  , clk_i, rst_ni)
    `FFLARNC(data_o,   data_i, reg_ena, clr_i, T'('0), clk_i, rst_ni)
endmodule

module axi_atop_filter #(
  
  parameter int unsigned AxiIdWidth = 0,
  
  parameter int unsigned AxiMaxWriteTxns = 0,
  
  parameter type axi_req_t  = logic,
  
  parameter type axi_resp_t = logic
) (
  
  input  logic      clk_i,
  
  input  logic      rst_ni,
  
  input  axi_req_t  slv_req_i,
  
  output axi_resp_t slv_resp_o,
  
  output axi_req_t  mst_req_o,
  
  input  axi_resp_t mst_resp_i
);
  
  localparam int unsigned COUNTER_WIDTH = (AxiMaxWriteTxns == 1) ? 2 : $clog2(AxiMaxWriteTxns+1);
  typedef struct packed {
    logic                     underflow;
    logic [COUNTER_WIDTH-1:0] cnt;
  } cnt_t;
  cnt_t   w_cnt_d, w_cnt_q;
  typedef enum logic [2:0] {
    W_RESET, W_FEEDTHROUGH, BLOCK_AW, ABSORB_W, HOLD_B, INJECT_B, WAIT_R
  } w_state_e;
  w_state_e   w_state_d, w_state_q;
  typedef enum logic [1:0] { R_RESET, R_FEEDTHROUGH, INJECT_R, R_HOLD } r_state_e;
  r_state_e   r_state_d, r_state_q;
  typedef logic [AxiIdWidth-1:0] id_t;
  id_t  id_d, id_q;
  typedef logic [7:0] len_t;
  len_t   r_beats_d,  r_beats_q;
  typedef struct packed {
    len_t len;
  } r_resp_cmd_t;
  r_resp_cmd_t  r_resp_cmd_push, r_resp_cmd_pop;
  logic aw_without_complete_w_downstream,
        complete_w_without_aw_downstream,
        r_resp_cmd_push_valid,  r_resp_cmd_push_ready,
        r_resp_cmd_pop_valid,   r_resp_cmd_pop_ready;
  
  
  assign aw_without_complete_w_downstream = !w_cnt_q.underflow && (w_cnt_q.cnt > 0);
  
  assign complete_w_without_aw_downstream = w_cnt_q.underflow && &(w_cnt_q.cnt);
  
  always_comb begin
    
    
    mst_req_o.aw_valid  = 1'b0;
    slv_resp_o.aw_ready = 1'b0;
    mst_req_o.w_valid   = 1'b0;
    slv_resp_o.w_ready  = 1'b0;
    
    mst_req_o.b_ready   = slv_req_i.b_ready;
    slv_resp_o.b_valid  = mst_resp_i.b_valid;
    slv_resp_o.b        = mst_resp_i.b;
    
    id_d = id_q;
    
    r_resp_cmd_push_valid = 1'b0;
    
    w_state_d = w_state_q;
    unique case (w_state_q)
      W_RESET: w_state_d = W_FEEDTHROUGH;
      W_FEEDTHROUGH: begin
        
        if (complete_w_without_aw_downstream || (w_cnt_q.cnt < AxiMaxWriteTxns)) begin
          mst_req_o.aw_valid  = slv_req_i.aw_valid;
          slv_resp_o.aw_ready = mst_resp_i.aw_ready;
        end
        
        if (aw_without_complete_w_downstream 
            
            
            || ((slv_req_i.aw_valid && slv_req_i.aw.atop[5:4] == axi_pkg::ATOP_NONE)
                && !complete_w_without_aw_downstream)
        ) begin
          mst_req_o.w_valid  = slv_req_i.w_valid;
          slv_resp_o.w_ready = mst_resp_i.w_ready;
        end
        
        if (slv_req_i.aw_valid && slv_req_i.aw.atop[5:4] != axi_pkg::ATOP_NONE) begin
          mst_req_o.aw_valid  = 1'b0; 
          slv_resp_o.aw_ready = 1'b1; 
          id_d = slv_req_i.aw.id; 
          
          if (slv_req_i.aw.atop[axi_pkg::ATOP_R_RESP]) begin
            
            
            
            r_resp_cmd_push_valid = 1'b1;
          end
          
          if (aw_without_complete_w_downstream) begin
            w_state_d = BLOCK_AW;
          
          end else begin
            mst_req_o.w_valid  = 1'b0; 
            slv_resp_o.w_ready = 1'b1; 
            if (slv_req_i.w_valid && slv_req_i.w.last) begin
              
              
              
              if (slv_resp_o.b_valid && !slv_req_i.b_ready) begin
                w_state_d = HOLD_B;
              end else begin
                w_state_d = INJECT_B;
              end
            end else begin
              
              w_state_d = ABSORB_W;
            end
          end
        end
      end
      BLOCK_AW: begin
        
        if (aw_without_complete_w_downstream) begin
          mst_req_o.w_valid  = slv_req_i.w_valid;
          slv_resp_o.w_ready = mst_resp_i.w_ready;
        end else begin
          
          slv_resp_o.w_ready = 1'b1;
          if (slv_req_i.w_valid && slv_req_i.w.last) begin
            
            if (slv_resp_o.b_valid && !slv_req_i.b_ready) begin
              w_state_d = HOLD_B;
            end else begin
              w_state_d = INJECT_B;
            end
          end else begin
            
            w_state_d = ABSORB_W;
          end
        end
      end
      ABSORB_W: begin
        
        slv_resp_o.w_ready = 1'b1;
        if (slv_req_i.w_valid && slv_req_i.w.last) begin
          if (slv_resp_o.b_valid && !slv_req_i.b_ready) begin
            w_state_d = HOLD_B;
          end else begin
            w_state_d = INJECT_B;
          end
        end
      end
      HOLD_B: begin
        
        if (slv_resp_o.b_valid && slv_req_i.b_ready) begin
          w_state_d = INJECT_B;
        end
      end
      INJECT_B: begin
        
        mst_req_o.b_ready = 1'b0;
        
        
        
        slv_resp_o.b = '0;
        slv_resp_o.b.id = id_q;
        slv_resp_o.b.resp = axi_pkg::RESP_SLVERR;
        slv_resp_o.b_valid = 1'b1;
        if (slv_req_i.b_ready) begin
          
          
          if (r_resp_cmd_pop_valid && !r_resp_cmd_pop_ready) begin
            w_state_d = WAIT_R;
          end else begin
            w_state_d = W_FEEDTHROUGH;
          end
        end
      end
      WAIT_R: begin
        
        
        if (!r_resp_cmd_pop_valid) begin
          w_state_d = W_FEEDTHROUGH;
        end
      end
      default: w_state_d = W_RESET;
    endcase
  end
  
  
  
  always_comb begin
    
    mst_req_o.aw      = slv_req_i.aw;
    mst_req_o.aw.atop = '0;
  end
  assign mst_req_o.w = slv_req_i.w;
  
  always_comb begin
    
    
    slv_resp_o.r       = mst_resp_i.r;
    slv_resp_o.r_valid = mst_resp_i.r_valid;
    mst_req_o.r_ready  = slv_req_i.r_ready;
    
    r_resp_cmd_pop_ready = 1'b0;
    
    r_beats_d = r_beats_q;
    
    r_state_d = r_state_q;
    unique case (r_state_q)
      R_RESET: r_state_d = R_FEEDTHROUGH;
      R_FEEDTHROUGH: begin
        if (mst_resp_i.r_valid && !slv_req_i.r_ready) begin
          r_state_d = R_HOLD;
        end else if (r_resp_cmd_pop_valid) begin
          
          
          
          r_beats_d = r_resp_cmd_pop.len;
          r_state_d = INJECT_R;
        end
      end
      INJECT_R: begin
        mst_req_o.r_ready  = 1'b0;
        slv_resp_o.r       = '0;
        slv_resp_o.r.id    = id_q;
        slv_resp_o.r.resp  = axi_pkg::RESP_SLVERR;
        slv_resp_o.r.last  = (r_beats_q == '0);
        slv_resp_o.r_valid = 1'b1;
        if (slv_req_i.r_ready) begin
          if (slv_resp_o.r.last) begin
            r_resp_cmd_pop_ready = 1'b1;
            r_state_d = R_FEEDTHROUGH;
          end else begin
            r_beats_d -= 1;
          end
        end
      end
      R_HOLD: begin
        if (mst_resp_i.r_valid && slv_req_i.r_ready) begin
          r_state_d = R_FEEDTHROUGH;
        end
      end
      default: r_state_d = R_RESET;
    endcase
  end
  
  assign mst_req_o.ar        = slv_req_i.ar;
  assign mst_req_o.ar_valid  = slv_req_i.ar_valid;
  assign slv_resp_o.ar_ready = mst_resp_i.ar_ready;
  
  always_comb begin
    w_cnt_d = w_cnt_q;
    if (mst_req_o.aw_valid && mst_resp_i.aw_ready) begin
      w_cnt_d.cnt += 1;
    end
    if (mst_req_o.w_valid && mst_resp_i.w_ready && mst_req_o.w.last) begin
      w_cnt_d.cnt -= 1;
    end
    if (w_cnt_q.underflow && (w_cnt_d.cnt == '0)) begin
      w_cnt_d.underflow = 1'b0;
    end else if (w_cnt_q.cnt == '0 && &(w_cnt_d.cnt)) begin
      w_cnt_d.underflow = 1'b1;
    end
  end
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      id_q <= '0;
      r_beats_q <= '0;
      r_state_q <= R_RESET;
      w_cnt_q <= '{default: '0};
      w_state_q <= W_RESET;
    end else begin
      id_q <= id_d;
      r_beats_q <= r_beats_d;
      r_state_q <= r_state_d;
      w_cnt_q <= w_cnt_d;
      w_state_q <= w_state_d;
    end
  end
  stream_register #(
    .T(r_resp_cmd_t)
  ) r_resp_cmd (
    .clk_i      (clk_i),
    .rst_ni     (rst_ni),
    .clr_i      (1'b0),
    .testmode_i (1'b0),
    .valid_i    (r_resp_cmd_push_valid),
    .ready_o    (r_resp_cmd_push_ready),
    .data_i     (r_resp_cmd_push),
    .valid_o    (r_resp_cmd_pop_valid),
    .ready_i    (r_resp_cmd_pop_ready),
    .data_o     (r_resp_cmd_pop)
  );
  assign r_resp_cmd_push.len = slv_req_i.aw.len;
`ifndef VERILATOR
  initial begin: p_assertions
    assert (AxiIdWidth >= 1) else $fatal(1, "AXI ID width must be at least 1!");
    assert (AxiMaxWriteTxns >= 1)
      else $fatal(1, "Maximum number of outstanding write transactions must be at least 1!");
  end
`endif
endmodule
`ifndef AXI_ASSIGN_SVH_
`define AXI_ASSIGN_SVH_
`define __AXI_TO_AW(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)   \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``addr   = __rhs``__rhs_sep``addr;       \
  __opt_as __lhs``__lhs_sep``len    = __rhs``__rhs_sep``len;        \
  __opt_as __lhs``__lhs_sep``size   = __rhs``__rhs_sep``size;       \
  __opt_as __lhs``__lhs_sep``burst  = __rhs``__rhs_sep``burst;      \
  __opt_as __lhs``__lhs_sep``lock   = __rhs``__rhs_sep``lock;       \
  __opt_as __lhs``__lhs_sep``cache  = __rhs``__rhs_sep``cache;      \
  __opt_as __lhs``__lhs_sep``prot   = __rhs``__rhs_sep``prot;       \
  __opt_as __lhs``__lhs_sep``qos    = __rhs``__rhs_sep``qos;        \
  __opt_as __lhs``__lhs_sep``region = __rhs``__rhs_sep``region;     \
  __opt_as __lhs``__lhs_sep``atop   = __rhs``__rhs_sep``atop;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_W(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``data   = __rhs``__rhs_sep``data;       \
  __opt_as __lhs``__lhs_sep``strb   = __rhs``__rhs_sep``strb;       \
  __opt_as __lhs``__lhs_sep``last   = __rhs``__rhs_sep``last;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_B(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``resp   = __rhs``__rhs_sep``resp;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_AR(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)   \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``addr   = __rhs``__rhs_sep``addr;       \
  __opt_as __lhs``__lhs_sep``len    = __rhs``__rhs_sep``len;        \
  __opt_as __lhs``__lhs_sep``size   = __rhs``__rhs_sep``size;       \
  __opt_as __lhs``__lhs_sep``burst  = __rhs``__rhs_sep``burst;      \
  __opt_as __lhs``__lhs_sep``lock   = __rhs``__rhs_sep``lock;       \
  __opt_as __lhs``__lhs_sep``cache  = __rhs``__rhs_sep``cache;      \
  __opt_as __lhs``__lhs_sep``prot   = __rhs``__rhs_sep``prot;       \
  __opt_as __lhs``__lhs_sep``qos    = __rhs``__rhs_sep``qos;        \
  __opt_as __lhs``__lhs_sep``region = __rhs``__rhs_sep``region;     \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_R(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``data   = __rhs``__rhs_sep``data;       \
  __opt_as __lhs``__lhs_sep``resp   = __rhs``__rhs_sep``resp;       \
  __opt_as __lhs``__lhs_sep``last   = __rhs``__rhs_sep``last;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_REQ(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)  \
  `__AXI_TO_AW(__opt_as, __lhs.aw, __lhs_sep, __rhs.aw, __rhs_sep)  \
  __opt_as __lhs.aw_valid = __rhs.aw_valid;                         \
  `__AXI_TO_W(__opt_as, __lhs.w, __lhs_sep, __rhs.w, __rhs_sep)     \
  __opt_as __lhs.w_valid = __rhs.w_valid;                           \
  __opt_as __lhs.b_ready = __rhs.b_ready;                           \
  `__AXI_TO_AR(__opt_as, __lhs.ar, __lhs_sep, __rhs.ar, __rhs_sep)  \
  __opt_as __lhs.ar_valid = __rhs.ar_valid;                         \
  __opt_as __lhs.r_ready = __rhs.r_ready;
`define __AXI_TO_RESP(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs.aw_ready = __rhs.aw_ready;                         \
  __opt_as __lhs.ar_ready = __rhs.ar_ready;                         \
  __opt_as __lhs.w_ready = __rhs.w_ready;                           \
  __opt_as __lhs.b_valid = __rhs.b_valid;                           \
  `__AXI_TO_B(__opt_as, __lhs.b, __lhs_sep, __rhs.b, __rhs_sep)     \
  __opt_as __lhs.r_valid = __rhs.r_valid;                           \
  `__AXI_TO_R(__opt_as, __lhs.r, __lhs_sep, __rhs.r, __rhs_sep)
`define AXI_ASSIGN_AW(dst, src)               \
  `__AXI_TO_AW(assign, dst.aw, _, src.aw, _)  \
  assign dst.aw_valid = src.aw_valid;         \
  assign src.aw_ready = dst.aw_ready;
`define AXI_ASSIGN_W(dst, src)                \
  `__AXI_TO_W(assign, dst.w, _, src.w, _)     \
  assign dst.w_valid  = src.w_valid;          \
  assign src.w_ready  = dst.w_ready;
`define AXI_ASSIGN_B(dst, src)                \
  `__AXI_TO_B(assign, dst.b, _, src.b, _)     \
  assign dst.b_valid  = src.b_valid;          \
  assign src.b_ready  = dst.b_ready;
`define AXI_ASSIGN_AR(dst, src)               \
  `__AXI_TO_AR(assign, dst.ar, _, src.ar, _)  \
  assign dst.ar_valid = src.ar_valid;         \
  assign src.ar_ready = dst.ar_ready;
`define AXI_ASSIGN_R(dst, src)                \
  `__AXI_TO_R(assign, dst.r, _, src.r, _)     \
  assign dst.r_valid  = src.r_valid;          \
  assign src.r_ready  = dst.r_ready;
`define AXI_ASSIGN(slv, mst)  \
  `AXI_ASSIGN_AW(slv, mst)    \
  `AXI_ASSIGN_W(slv, mst)     \
  `AXI_ASSIGN_B(mst, slv)     \
  `AXI_ASSIGN_AR(slv, mst)    \
  `AXI_ASSIGN_R(mst, slv)
`define AXI_ASSIGN_MONITOR(mon_dv, axi_if)          \
  `__AXI_TO_AW(assign, mon_dv.aw, _, axi_if.aw, _)  \
  assign mon_dv.aw_valid  = axi_if.aw_valid;        \
  assign mon_dv.aw_ready  = axi_if.aw_ready;        \
  `__AXI_TO_W(assign, mon_dv.w, _, axi_if.w, _)     \
  assign mon_dv.w_valid   = axi_if.w_valid;         \
  assign mon_dv.w_ready   = axi_if.w_ready;         \
  `__AXI_TO_B(assign, mon_dv.b, _, axi_if.b, _)     \
  assign mon_dv.b_valid   = axi_if.b_valid;         \
  assign mon_dv.b_ready   = axi_if.b_ready;         \
  `__AXI_TO_AR(assign, mon_dv.ar, _, axi_if.ar, _)  \
  assign mon_dv.ar_valid  = axi_if.ar_valid;        \
  assign mon_dv.ar_ready  = axi_if.ar_ready;        \
  `__AXI_TO_R(assign, mon_dv.r, _, axi_if.r, _)     \
  assign mon_dv.r_valid   = axi_if.r_valid;         \
  assign mon_dv.r_ready   = axi_if.r_ready;
`define AXI_SET_FROM_AW(axi_if, aw_struct)      `__AXI_TO_AW(, axi_if.aw, _, aw_struct, .)
`define AXI_SET_FROM_W(axi_if, w_struct)        `__AXI_TO_W(, axi_if.w, _, w_struct, .)
`define AXI_SET_FROM_B(axi_if, b_struct)        `__AXI_TO_B(, axi_if.b, _, b_struct, .)
`define AXI_SET_FROM_AR(axi_if, ar_struct)      `__AXI_TO_AR(, axi_if.ar, _, ar_struct, .)
`define AXI_SET_FROM_R(axi_if, r_struct)        `__AXI_TO_R(, axi_if.r, _, r_struct, .)
`define AXI_SET_FROM_REQ(axi_if, req_struct)    `__AXI_TO_REQ(, axi_if, _, req_struct, .)
`define AXI_SET_FROM_RESP(axi_if, resp_struct)  `__AXI_TO_RESP(, axi_if, _, resp_struct, .)
`define AXI_ASSIGN_FROM_AW(axi_if, aw_struct)     `__AXI_TO_AW(assign, axi_if.aw, _, aw_struct, .)
`define AXI_ASSIGN_FROM_W(axi_if, w_struct)       `__AXI_TO_W(assign, axi_if.w, _, w_struct, .)
`define AXI_ASSIGN_FROM_B(axi_if, b_struct)       `__AXI_TO_B(assign, axi_if.b, _, b_struct, .)
`define AXI_ASSIGN_FROM_AR(axi_if, ar_struct)     `__AXI_TO_AR(assign, axi_if.ar, _, ar_struct, .)
`define AXI_ASSIGN_FROM_R(axi_if, r_struct)       `__AXI_TO_R(assign, axi_if.r, _, r_struct, .)
`define AXI_ASSIGN_FROM_REQ(axi_if, req_struct)   `__AXI_TO_REQ(assign, axi_if, _, req_struct, .)
`define AXI_ASSIGN_FROM_RESP(axi_if, resp_struct) `__AXI_TO_RESP(assign, axi_if, _, resp_struct, .)
`define AXI_SET_TO_AW(aw_struct, axi_if)     `__AXI_TO_AW(, aw_struct, ., axi_if.aw, _)
`define AXI_SET_TO_W(w_struct, axi_if)       `__AXI_TO_W(, w_struct, ., axi_if.w, _)
`define AXI_SET_TO_B(b_struct, axi_if)       `__AXI_TO_B(, b_struct, ., axi_if.b, _)
`define AXI_SET_TO_AR(ar_struct, axi_if)     `__AXI_TO_AR(, ar_struct, ., axi_if.ar, _)
`define AXI_SET_TO_R(r_struct, axi_if)       `__AXI_TO_R(, r_struct, ., axi_if.r, _)
`define AXI_SET_TO_REQ(req_struct, axi_if)   `__AXI_TO_REQ(, req_struct, ., axi_if, _)
`define AXI_SET_TO_RESP(resp_struct, axi_if) `__AXI_TO_RESP(, resp_struct, ., axi_if, _)
`define AXI_ASSIGN_TO_AW(aw_struct, axi_if)     `__AXI_TO_AW(assign, aw_struct, ., axi_if.aw, _)
`define AXI_ASSIGN_TO_W(w_struct, axi_if)       `__AXI_TO_W(assign, w_struct, ., axi_if.w, _)
`define AXI_ASSIGN_TO_B(b_struct, axi_if)       `__AXI_TO_B(assign, b_struct, ., axi_if.b, _)
`define AXI_ASSIGN_TO_AR(ar_struct, axi_if)     `__AXI_TO_AR(assign, ar_struct, ., axi_if.ar, _)
`define AXI_ASSIGN_TO_R(r_struct, axi_if)       `__AXI_TO_R(assign, r_struct, ., axi_if.r, _)
`define AXI_ASSIGN_TO_REQ(req_struct, axi_if)   `__AXI_TO_REQ(assign, req_struct, ., axi_if, _)
`define AXI_ASSIGN_TO_RESP(resp_struct, axi_if) `__AXI_TO_RESP(assign, resp_struct, ., axi_if, _)
`define AXI_SET_AW_STRUCT(lhs, rhs)     `__AXI_TO_AW(, lhs, ., rhs, .)
`define AXI_SET_W_STRUCT(lhs, rhs)       `__AXI_TO_W(, lhs, ., rhs, .)
`define AXI_SET_B_STRUCT(lhs, rhs)       `__AXI_TO_B(, lhs, ., rhs, .)
`define AXI_SET_AR_STRUCT(lhs, rhs)     `__AXI_TO_AR(, lhs, ., rhs, .)
`define AXI_SET_R_STRUCT(lhs, rhs)       `__AXI_TO_R(, lhs, ., rhs, .)
`define AXI_SET_REQ_STRUCT(lhs, rhs)   `__AXI_TO_REQ(, lhs, ., rhs, .)
`define AXI_SET_RESP_STRUCT(lhs, rhs) `__AXI_TO_RESP(, lhs, ., rhs, .)
`define AXI_ASSIGN_AW_STRUCT(lhs, rhs)     `__AXI_TO_AW(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_W_STRUCT(lhs, rhs)       `__AXI_TO_W(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_B_STRUCT(lhs, rhs)       `__AXI_TO_B(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_AR_STRUCT(lhs, rhs)     `__AXI_TO_AR(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_R_STRUCT(lhs, rhs)       `__AXI_TO_R(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_REQ_STRUCT(lhs, rhs)   `__AXI_TO_REQ(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_RESP_STRUCT(lhs, rhs) `__AXI_TO_RESP(assign, lhs, ., rhs, .)
`define __AXI_LITE_TO_AX(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)  \
  __opt_as __lhs``__lhs_sep``addr = __rhs``__rhs_sep``addr;             \
  __opt_as __lhs``__lhs_sep``prot = __rhs``__rhs_sep``prot;
`define __AXI_LITE_TO_W(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``data = __rhs``__rhs_sep``data;           \
  __opt_as __lhs``__lhs_sep``strb = __rhs``__rhs_sep``strb;
`define __AXI_LITE_TO_B(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``resp = __rhs``__rhs_sep``resp;
`define __AXI_LITE_TO_R(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``data = __rhs``__rhs_sep``data;           \
  __opt_as __lhs``__lhs_sep``resp = __rhs``__rhs_sep``resp;
`define __AXI_LITE_TO_REQ(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  `__AXI_LITE_TO_AX(__opt_as, __lhs.aw, __lhs_sep, __rhs.aw, __rhs_sep) \
  __opt_as __lhs.aw_valid = __rhs.aw_valid;                             \
  `__AXI_LITE_TO_W(__opt_as, __lhs.w, __lhs_sep, __rhs.w, __rhs_sep)    \
  __opt_as __lhs.w_valid = __rhs.w_valid;                               \
  __opt_as __lhs.b_ready = __rhs.b_ready;                               \
  `__AXI_LITE_TO_AX(__opt_as, __lhs.ar, __lhs_sep, __rhs.ar, __rhs_sep) \
  __opt_as __lhs.ar_valid = __rhs.ar_valid;                             \
  __opt_as __lhs.r_ready = __rhs.r_ready;
`define __AXI_LITE_TO_RESP(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)  \
  __opt_as __lhs.aw_ready = __rhs.aw_ready;                               \
  __opt_as __lhs.ar_ready = __rhs.ar_ready;                               \
  __opt_as __lhs.w_ready = __rhs.w_ready;                                 \
  __opt_as __lhs.b_valid = __rhs.b_valid;                                 \
  `__AXI_LITE_TO_B(__opt_as, __lhs.b, __lhs_sep, __rhs.b, __rhs_sep)      \
  __opt_as __lhs.r_valid = __rhs.r_valid;                                 \
  `__AXI_LITE_TO_R(__opt_as, __lhs.r, __lhs_sep, __rhs.r, __rhs_sep)
`define AXI_LITE_ASSIGN_AW(dst, src)              \
  `__AXI_LITE_TO_AX(assign, dst.aw, _, src.aw, _) \
  assign dst.aw_valid = src.aw_valid;             \
  assign src.aw_ready = dst.aw_ready;
`define AXI_LITE_ASSIGN_W(dst, src)             \
  `__AXI_LITE_TO_W(assign, dst.w, _, src.w, _)  \
  assign dst.w_valid  = src.w_valid;            \
  assign src.w_ready  = dst.w_ready;
`define AXI_LITE_ASSIGN_B(dst, src)             \
  `__AXI_LITE_TO_B(assign, dst.b, _, src.b, _)  \
  assign dst.b_valid  = src.b_valid;            \
  assign src.b_ready  = dst.b_ready;
`define AXI_LITE_ASSIGN_AR(dst, src)              \
  `__AXI_LITE_TO_AX(assign, dst.ar, _, src.ar, _) \
  assign dst.ar_valid = src.ar_valid;             \
  assign src.ar_ready = dst.ar_ready;
`define AXI_LITE_ASSIGN_R(dst, src)             \
  `__AXI_LITE_TO_R(assign, dst.r, _, src.r, _)  \
  assign dst.r_valid  = src.r_valid;            \
  assign src.r_ready  = dst.r_ready;
`define AXI_LITE_ASSIGN(slv, mst) \
  `AXI_LITE_ASSIGN_AW(slv, mst)   \
  `AXI_LITE_ASSIGN_W(slv, mst)    \
  `AXI_LITE_ASSIGN_B(mst, slv)    \
  `AXI_LITE_ASSIGN_AR(slv, mst)   \
  `AXI_LITE_ASSIGN_R(mst, slv)
`define AXI_LITE_SET_FROM_AW(axi_if, aw_struct)      `__AXI_LITE_TO_AX(, axi_if.aw, _, aw_struct, .)
`define AXI_LITE_SET_FROM_W(axi_if, w_struct)        `__AXI_LITE_TO_W(, axi_if.w, _, w_struct, .)
`define AXI_LITE_SET_FROM_B(axi_if, b_struct)        `__AXI_LITE_TO_B(, axi_if.b, _, b_struct, .)
`define AXI_LITE_SET_FROM_AR(axi_if, ar_struct)      `__AXI_LITE_TO_AX(, axi_if.ar, _, ar_struct, .)
`define AXI_LITE_SET_FROM_R(axi_if, r_struct)        `__AXI_LITE_TO_R(, axi_if.r, _, r_struct, .)
`define AXI_LITE_SET_FROM_REQ(axi_if, req_struct)    `__AXI_LITE_TO_REQ(, axi_if, _, req_struct, .)
`define AXI_LITE_SET_FROM_RESP(axi_if, resp_struct)  `__AXI_LITE_TO_RESP(, axi_if, _, resp_struct, .)
`define AXI_LITE_ASSIGN_FROM_AW(axi_if, aw_struct)     `__AXI_LITE_TO_AX(assign, axi_if.aw, _, aw_struct, .)
`define AXI_LITE_ASSIGN_FROM_W(axi_if, w_struct)       `__AXI_LITE_TO_W(assign, axi_if.w, _, w_struct, .)
`define AXI_LITE_ASSIGN_FROM_B(axi_if, b_struct)       `__AXI_LITE_TO_B(assign, axi_if.b, _, b_struct, .)
`define AXI_LITE_ASSIGN_FROM_AR(axi_if, ar_struct)     `__AXI_LITE_TO_AX(assign, axi_if.ar, _, ar_struct, .)
`define AXI_LITE_ASSIGN_FROM_R(axi_if, r_struct)       `__AXI_LITE_TO_R(assign, axi_if.r, _, r_struct, .)
`define AXI_LITE_ASSIGN_FROM_REQ(axi_if, req_struct)   `__AXI_LITE_TO_REQ(assign, axi_if, _, req_struct, .)
`define AXI_LITE_ASSIGN_FROM_RESP(axi_if, resp_struct) `__AXI_LITE_TO_RESP(assign, axi_if, _, resp_struct, .)
`define AXI_LITE_SET_TO_AW(aw_struct, axi_if)     `__AXI_LITE_TO_AX(, aw_struct, ., axi_if.aw, _)
`define AXI_LITE_SET_TO_W(w_struct, axi_if)       `__AXI_LITE_TO_W(, w_struct, ., axi_if.w, _)
`define AXI_LITE_SET_TO_B(b_struct, axi_if)       `__AXI_LITE_TO_B(, b_struct, ., axi_if.b, _)
`define AXI_LITE_SET_TO_AR(ar_struct, axi_if)     `__AXI_LITE_TO_AX(, ar_struct, ., axi_if.ar, _)
`define AXI_LITE_SET_TO_R(r_struct, axi_if)       `__AXI_LITE_TO_R(, r_struct, ., axi_if.r, _)
`define AXI_LITE_SET_TO_REQ(req_struct, axi_if)   `__AXI_LITE_TO_REQ(, req_struct, ., axi_if, _)
`define AXI_LITE_SET_TO_RESP(resp_struct, axi_if) `__AXI_LITE_TO_RESP(, resp_struct, ., axi_if, _)
`define AXI_LITE_ASSIGN_TO_AW(aw_struct, axi_if)     `__AXI_LITE_TO_AX(assign, aw_struct, ., axi_if.aw, _)
`define AXI_LITE_ASSIGN_TO_W(w_struct, axi_if)       `__AXI_LITE_TO_W(assign, w_struct, ., axi_if.w, _)
`define AXI_LITE_ASSIGN_TO_B(b_struct, axi_if)       `__AXI_LITE_TO_B(assign, b_struct, ., axi_if.b, _)
`define AXI_LITE_ASSIGN_TO_AR(ar_struct, axi_if)     `__AXI_LITE_TO_AX(assign, ar_struct, ., axi_if.ar, _)
`define AXI_LITE_ASSIGN_TO_R(r_struct, axi_if)       `__AXI_LITE_TO_R(assign, r_struct, ., axi_if.r, _)
`define AXI_LITE_ASSIGN_TO_REQ(req_struct, axi_if)   `__AXI_LITE_TO_REQ(assign, req_struct, ., axi_if, _)
`define AXI_LITE_ASSIGN_TO_RESP(resp_struct, axi_if) `__AXI_LITE_TO_RESP(assign, resp_struct, ., axi_if, _)
`define AXI_LITE_SET_AW_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(, lhs, ., rhs, .)
`define AXI_LITE_SET_W_STRUCT(lhs, rhs)       `__AXI_LITE_TO_W(, lhs, ., rhs, .)
`define AXI_LITE_SET_B_STRUCT(lhs, rhs)       `__AXI_LITE_TO_B(, lhs, ., rhs, .)
`define AXI_LITE_SET_AR_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(, lhs, ., rhs, .)
`define AXI_LITE_SET_R_STRUCT(lhs, rhs)       `__AXI_LITE_TO_R(, lhs, ., rhs, .)
`define AXI_LITE_SET_REQ_STRUCT(lhs, rhs)   `__AXI_LITE_TO_REQ(, lhs, ., rhs, .)
`define AXI_LITE_SET_RESP_STRUCT(lhs, rhs) `__AXI_LITE_TO_RESP(, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_AW_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_W_STRUCT(lhs, rhs)       `__AXI_LITE_TO_W(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_B_STRUCT(lhs, rhs)       `__AXI_LITE_TO_B(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_AR_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_R_STRUCT(lhs, rhs)       `__AXI_LITE_TO_R(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_REQ_STRUCT(lhs, rhs)   `__AXI_LITE_TO_REQ(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_RESP_STRUCT(lhs, rhs) `__AXI_LITE_TO_RESP(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_MASTER_TO_FLAT(pat, req, rsp) \
  assign m_axi_``pat``_awvalid  = req.aw_valid;  \
  assign m_axi_``pat``_awid     = req.aw.id;     \
  assign m_axi_``pat``_awaddr   = req.aw.addr;   \
  assign m_axi_``pat``_awlen    = req.aw.len;    \
  assign m_axi_``pat``_awsize   = req.aw.size;   \
  assign m_axi_``pat``_awburst  = req.aw.burst;  \
  assign m_axi_``pat``_awlock   = req.aw.lock;   \
  assign m_axi_``pat``_awcache  = req.aw.cache;  \
  assign m_axi_``pat``_awprot   = req.aw.prot;   \
  assign m_axi_``pat``_awqos    = req.aw.qos;    \
  assign m_axi_``pat``_awregion = req.aw.region; \
  assign m_axi_``pat``_awuser   = req.aw.user;   \
                                                 \
  assign m_axi_``pat``_wvalid   = req.w_valid;   \
  assign m_axi_``pat``_wdata    = req.w.data;    \
  assign m_axi_``pat``_wstrb    = req.w.strb;    \
  assign m_axi_``pat``_wlast    = req.w.last;    \
  assign m_axi_``pat``_wuser    = req.w.user;    \
                                                 \
  assign m_axi_``pat``_bready   = req.b_ready;   \
                                                 \
  assign m_axi_``pat``_arvalid  = req.ar_valid;  \
  assign m_axi_``pat``_arid     = req.ar.id;     \
  assign m_axi_``pat``_araddr   = req.ar.addr;   \
  assign m_axi_``pat``_arlen    = req.ar.len;    \
  assign m_axi_``pat``_arsize   = req.ar.size;   \
  assign m_axi_``pat``_arburst  = req.ar.burst;  \
  assign m_axi_``pat``_arlock   = req.ar.lock;   \
  assign m_axi_``pat``_arcache  = req.ar.cache;  \
  assign m_axi_``pat``_arprot   = req.ar.prot;   \
  assign m_axi_``pat``_arqos    = req.ar.qos;    \
  assign m_axi_``pat``_arregion = req.ar.region; \
  assign m_axi_``pat``_aruser   = req.ar.user;   \
                                                 \
  assign m_axi_``pat``_rready   = req.r_ready;   \
                                                 \
  assign rsp.aw_ready = m_axi_``pat``_awready;   \
  assign rsp.ar_ready = m_axi_``pat``_arready;   \
  assign rsp.w_ready  = m_axi_``pat``_wready;    \
                                                 \
  assign rsp.b_valid  = m_axi_``pat``_bvalid;    \
  assign rsp.b.id     = m_axi_``pat``_bid;       \
  assign rsp.b.resp   = m_axi_``pat``_bresp;     \
  assign rsp.b.user   = m_axi_``pat``_buser;     \
                                                 \
  assign rsp.r_valid  = m_axi_``pat``_rvalid;    \
  assign rsp.r.id     = m_axi_``pat``_rid;       \
  assign rsp.r.data   = m_axi_``pat``_rdata;     \
  assign rsp.r.resp   = m_axi_``pat``_rresp;     \
  assign rsp.r.last   = m_axi_``pat``_rlast;     \
  assign rsp.r.user   = m_axi_``pat``_ruser;
`define AXI_ASSIGN_SLAVE_TO_FLAT(pat, req, rsp)  \
  assign req.aw_valid  = s_axi_``pat``_awvalid;  \
  assign req.aw.id     = s_axi_``pat``_awid;     \
  assign req.aw.addr   = s_axi_``pat``_awaddr;   \
  assign req.aw.len    = s_axi_``pat``_awlen;    \
  assign req.aw.size   = s_axi_``pat``_awsize;   \
  assign req.aw.burst  = s_axi_``pat``_awburst;  \
  assign req.aw.lock   = s_axi_``pat``_awlock;   \
  assign req.aw.cache  = s_axi_``pat``_awcache;  \
  assign req.aw.prot   = s_axi_``pat``_awprot;   \
  assign req.aw.qos    = s_axi_``pat``_awqos;    \
  assign req.aw.region = s_axi_``pat``_awregion; \
  assign req.aw.user   = s_axi_``pat``_awuser;   \
                                                 \
  assign req.w_valid   = s_axi_``pat``_wvalid;   \
  assign req.w.data    = s_axi_``pat``_wdata;    \
  assign req.w.strb    = s_axi_``pat``_wstrb;    \
  assign req.w.last    = s_axi_``pat``_wlast;    \
  assign req.w.user    = s_axi_``pat``_wuser;    \
                                                 \
  assign req.b_ready   = s_axi_``pat``_bready;   \
                                                 \
  assign req.ar_valid  = s_axi_``pat``_arvalid;  \
  assign req.ar.id     = s_axi_``pat``_arid;     \
  assign req.ar.addr   = s_axi_``pat``_araddr;   \
  assign req.ar.len    = s_axi_``pat``_arlen;    \
  assign req.ar.size   = s_axi_``pat``_arsize;   \
  assign req.ar.burst  = s_axi_``pat``_arburst;  \
  assign req.ar.lock   = s_axi_``pat``_arlock;   \
  assign req.ar.cache  = s_axi_``pat``_arcache;  \
  assign req.ar.prot   = s_axi_``pat``_arprot;   \
  assign req.ar.qos    = s_axi_``pat``_arqos;    \
  assign req.ar.region = s_axi_``pat``_arregion; \
  assign req.ar.user   = s_axi_``pat``_aruser;   \
                                                 \
  assign req.r_ready   = s_axi_``pat``_rready;   \
                                                 \
  assign s_axi_``pat``_awready = rsp.aw_ready;   \
  assign s_axi_``pat``_arready = rsp.ar_ready;   \
  assign s_axi_``pat``_wready  = rsp.w_ready;    \
                                                 \
  assign s_axi_``pat``_bvalid  = rsp.b_valid;    \
  assign s_axi_``pat``_bid     = rsp.b.id;       \
  assign s_axi_``pat``_bresp   = rsp.b.resp;     \
  assign s_axi_``pat``_buser   = rsp.b.user;     \
                                                 \
  assign s_axi_``pat``_rvalid  = rsp.r_valid;    \
  assign s_axi_``pat``_rid     = rsp.r.id;       \
  assign s_axi_``pat``_rdata   = rsp.r.data;     \
  assign s_axi_``pat``_rresp   = rsp.r.resp;     \
  assign s_axi_``pat``_rlast   = rsp.r.last;     \
  assign s_axi_``pat``_ruser   = rsp.r.user;
`define AXI_ASSIGN_TO_FLAT_PORT(pat, req, rsp)  \
  .``pat``_awvalid  ( req.aw_valid  ), \
  .``pat``_awid     ( req.aw.id     ), \
  .``pat``_awaddr   ( req.aw.addr   ), \
  .``pat``_awlen    ( req.aw.len    ), \
  .``pat``_awsize   ( req.aw.size   ), \
  .``pat``_awburst  ( req.aw.burst  ), \
  .``pat``_awlock   ( req.aw.lock   ), \
  .``pat``_awcache  ( req.aw.cache  ), \
  .``pat``_awprot   ( req.aw.prot   ), \
  .``pat``_awqos    ( req.aw.qos    ), \
  .``pat``_awregion ( req.aw.region ), \
  .``pat``_awuser   ( req.aw.user   ), \
                                       \
  .``pat``_wvalid   ( req.w_valid   ), \
  .``pat``_wdata    ( req.w.data    ), \
  .``pat``_wstrb    ( req.w.strb    ), \
  .``pat``_wlast    ( req.w.last    ), \
  .``pat``_wuser    ( req.w.user    ), \
                                       \
  .``pat``_bready   ( req.b_ready   ), \
                                       \
  .``pat``_arvalid  ( req.ar_valid  ), \
  .``pat``_arid     ( req.ar.id     ), \
  .``pat``_araddr   ( req.ar.addr   ), \
  .``pat``_arlen    ( req.ar.len    ), \
  .``pat``_arsize   ( req.ar.size   ), \
  .``pat``_arburst  ( req.ar.burst  ), \
  .``pat``_arlock   ( req.ar.lock   ), \
  .``pat``_arcache  ( req.ar.cache  ), \
  .``pat``_arprot   ( req.ar.prot   ), \
  .``pat``_arqos    ( req.ar.qos    ), \
  .``pat``_arregion ( req.ar.region ), \
  .``pat``_aruser   ( req.ar.user   ), \
                                       \
  .``pat``_rready   ( req.r_ready   ), \
                                       \
  .``pat``_awready  ( rsp.aw_ready  ), \
  .``pat``_arready  ( rsp.ar_ready  ), \
  .``pat``_wready   ( rsp.w_ready   ), \
                                       \
  .``pat``_bvalid   ( rsp.b_valid   ), \
  .``pat``_bid      ( rsp.b.id      ), \
  .``pat``_bresp    ( rsp.b.resp    ), \
  .``pat``_buser    ( rsp.b.user    ), \
                                       \
  .``pat``_rvalid   ( rsp.r_valid   ), \
  .``pat``_rid      ( rsp.r.id      ), \
  .``pat``_rdata    ( rsp.r.data    ), \
  .``pat``_rresp    ( rsp.r.resp    ), \
  .``pat``_rlast    ( rsp.r.last    ), \
  .``pat``_ruser    ( rsp.r.user    )
`define AXI_ASSIGN_MASTER_TO_FLAT_PORT(name, req, rsp) \
  `AXI_ASSIGN_TO_FLAT_PORT(m_axi_``name``, req, rsp)
`define AXI_ASSIGN_SLAVE_TO_FLAT_PORT(name, req, rsp) \
  `AXI_ASSIGN_TO_FLAT_PORT(s_axi_``name``, req, rsp)
`define AXI_HIGHLIGHT(__name, __aw_t, __w_t, __b_t, __ar_t, __r_t, __req, __resp) \
  signal_highlighter #(                                                           \
    .T ( __aw_t )                                                                 \
  ) i_signal_highlighter_``__name``_aw (                                          \
    .ready_i ( __resp.aw_ready ),                                                 \
    .valid_i ( __req.aw_valid  ),                                                 \
    .data_i  ( __req.aw        )                                                  \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __w_t )                                                                  \
  ) i_signal_highlighter_``__name``_w (                                           \
    .ready_i ( __resp.w_ready ),                                                  \
    .valid_i ( __req.w_valid  ),                                                  \
    .data_i  ( __req.w        )                                                   \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __b_t )                                                                  \
  ) i_signal_highlighter_``__name``_b (                                           \
    .ready_i ( __req.b_ready  ),                                                  \
    .valid_i ( __resp.b_valid ),                                                  \
    .data_i  ( __resp.b       )                                                   \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __ar_t )                                                                 \
  ) i_signal_highlighter_``__name``_ar (                                          \
    .ready_i ( __resp.ar_ready ),                                                 \
    .valid_i ( __req.ar_valid  ),                                                 \
    .data_i  ( __req.ar        )                                                  \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __r_t )                                                                  \
  ) i_signal_highlighter_``__name``_r (                                           \
    .ready_i ( __req.r_ready  ),                                                  \
    .valid_i ( __resp.r_valid ),                                                  \
    .data_i  ( __resp.r       )                                                   \
  );
`endif
`ifndef AXI_TYPEDEF_SVH_
`define AXI_TYPEDEF_SVH_
`define AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)  \
  typedef struct packed {                                       \
    id_t              id;                                       \
    addr_t            addr;                                     \
    axi_pkg::len_t    len;                                      \
    axi_pkg::size_t   size;                                     \
    axi_pkg::burst_t  burst;                                    \
    logic             lock;                                     \
    axi_pkg::cache_t  cache;                                    \
    axi_pkg::prot_t   prot;                                     \
    axi_pkg::qos_t    qos;                                      \
    axi_pkg::region_t region;                                   \
    axi_pkg::atop_t   atop;                                     \
    user_t            user;                                     \
  } aw_chan_t;
`define AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)  \
  typedef struct packed {                                       \
    data_t data;                                                \
    strb_t strb;                                                \
    logic  last;                                                \
    user_t user;                                                \
  } w_chan_t;
`define AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)  \
  typedef struct packed {                             \
    id_t            id;                               \
    axi_pkg::resp_t resp;                             \
    user_t          user;                             \
  } b_chan_t;
`define AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)  \
  typedef struct packed {                                       \
    id_t              id;                                       \
    addr_t            addr;                                     \
    axi_pkg::len_t    len;                                      \
    axi_pkg::size_t   size;                                     \
    axi_pkg::burst_t  burst;                                    \
    logic             lock;                                     \
    axi_pkg::cache_t  cache;                                    \
    axi_pkg::prot_t   prot;                                     \
    axi_pkg::qos_t    qos;                                      \
    axi_pkg::region_t region;                                   \
    user_t            user;                                     \
  } ar_chan_t;
`define AXI_TYPEDEF_R_CHAN_T(r_chan_t, data_t, id_t, user_t)  \
  typedef struct packed {                                     \
    id_t            id;                                       \
    data_t          data;                                     \
    axi_pkg::resp_t resp;                                     \
    logic           last;                                     \
    user_t          user;                                     \
  } r_chan_t;
`define AXI_TYPEDEF_REQ_T(req_t, aw_chan_t, w_chan_t, ar_chan_t)  \
  typedef struct packed {                                         \
    aw_chan_t aw;                                                 \
    logic     aw_valid;                                           \
    w_chan_t  w;                                                  \
    logic     w_valid;                                            \
    logic     b_ready;                                            \
    ar_chan_t ar;                                                 \
    logic     ar_valid;                                           \
    logic     r_ready;                                            \
  } req_t;
`define AXI_TYPEDEF_RESP_T(resp_t, b_chan_t, r_chan_t)  \
  typedef struct packed {                               \
    logic     aw_ready;                                 \
    logic     ar_ready;                                 \
    logic     w_ready;                                  \
    logic     b_valid;                                  \
    b_chan_t  b;                                        \
    logic     r_valid;                                  \
    r_chan_t  r;                                        \
  } resp_t;
`define AXI_TYPEDEF_ALL_CT(__name, __req, __rsp, __addr_t, __id_t, __data_t, __strb_t, __user_t) \
  `AXI_TYPEDEF_AW_CHAN_T(__name``_aw_chan_t, __addr_t, __id_t, __user_t)                         \
  `AXI_TYPEDEF_W_CHAN_T(__name``_w_chan_t, __data_t, __strb_t, __user_t)                         \
  `AXI_TYPEDEF_B_CHAN_T(__name``_b_chan_t, __id_t, __user_t)                                     \
  `AXI_TYPEDEF_AR_CHAN_T(__name``_ar_chan_t, __addr_t, __id_t, __user_t)                         \
  `AXI_TYPEDEF_R_CHAN_T(__name``_r_chan_t, __data_t, __id_t, __user_t)                           \
  `AXI_TYPEDEF_REQ_T(__req, __name``_aw_chan_t, __name``_w_chan_t, __name``_ar_chan_t)           \
  `AXI_TYPEDEF_RESP_T(__rsp, __name``_b_chan_t, __name``_r_chan_t)
`define AXI_TYPEDEF_ALL(__name, __addr_t, __id_t, __data_t, __strb_t, __user_t)                                \
  `AXI_TYPEDEF_ALL_CT(__name, __name``_req_t, __name``_resp_t, __addr_t, __id_t, __data_t, __strb_t, __user_t)
`define AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_lite_t, addr_t)  \
  typedef struct packed {                                   \
    addr_t          addr;                                   \
    axi_pkg::prot_t prot;                                   \
  } aw_chan_lite_t;
`define AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_lite_t, data_t, strb_t)  \
  typedef struct packed {                                         \
    data_t   data;                                                \
    strb_t   strb;                                                \
  } w_chan_lite_t;
`define AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_lite_t)  \
  typedef struct packed {                         \
    axi_pkg::resp_t resp;                         \
  } b_chan_lite_t;
`define AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_lite_t, addr_t)  \
  typedef struct packed {                                   \
    addr_t          addr;                                   \
    axi_pkg::prot_t prot;                                   \
  } ar_chan_lite_t;
`define AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_lite_t, data_t)  \
  typedef struct packed {                                 \
    data_t          data;                                 \
    axi_pkg::resp_t resp;                                 \
  } r_chan_lite_t;
`define AXI_LITE_TYPEDEF_REQ_T(req_lite_t, aw_chan_lite_t, w_chan_lite_t, ar_chan_lite_t)  \
  typedef struct packed {                                                                  \
    aw_chan_lite_t aw;                                                                     \
    logic          aw_valid;                                                               \
    w_chan_lite_t  w;                                                                      \
    logic          w_valid;                                                                \
    logic          b_ready;                                                                \
    ar_chan_lite_t ar;                                                                     \
    logic          ar_valid;                                                               \
    logic          r_ready;                                                                \
  } req_lite_t;
`define AXI_LITE_TYPEDEF_RESP_T(resp_lite_t, b_chan_lite_t, r_chan_lite_t)  \
  typedef struct packed {                                                   \
    logic          aw_ready;                                                \
    logic          w_ready;                                                 \
    b_chan_lite_t  b;                                                       \
    logic          b_valid;                                                 \
    logic          ar_ready;                                                \
    r_chan_lite_t  r;                                                       \
    logic          r_valid;                                                 \
  } resp_lite_t;
`define AXI_LITE_TYPEDEF_ALL_CT(__name, __req, __rsp, __addr_t, __data_t, __strb_t)         \
  `AXI_LITE_TYPEDEF_AW_CHAN_T(__name``_aw_chan_t, __addr_t)                                 \
  `AXI_LITE_TYPEDEF_W_CHAN_T(__name``_w_chan_t, __data_t, __strb_t)                         \
  `AXI_LITE_TYPEDEF_B_CHAN_T(__name``_b_chan_t)                                             \
  `AXI_LITE_TYPEDEF_AR_CHAN_T(__name``_ar_chan_t, __addr_t)                                 \
  `AXI_LITE_TYPEDEF_R_CHAN_T(__name``_r_chan_t, __data_t)                                   \
  `AXI_LITE_TYPEDEF_REQ_T(__req, __name``_aw_chan_t, __name``_w_chan_t, __name``_ar_chan_t) \
  `AXI_LITE_TYPEDEF_RESP_T(__rsp, __name``_b_chan_t, __name``_r_chan_t)
`define AXI_LITE_TYPEDEF_ALL(__name, __addr_t, __data_t, __strb_t)                                \
  `AXI_LITE_TYPEDEF_ALL_CT(__name, __name``_req_t, __name``_resp_t, __addr_t, __data_t, __strb_t)
`endif
module axi_atop_filter_intf #(
  
  parameter int unsigned AXI_ID_WIDTH   = 0,
  
  parameter int unsigned AXI_ADDR_WIDTH = 0,
  
  parameter int unsigned AXI_DATA_WIDTH = 0,
  
  parameter int unsigned AXI_USER_WIDTH = 0,
  
  parameter int unsigned AXI_MAX_WRITE_TXNS = 0
) (
  
  input  logic    clk_i,
  
  input  logic    rst_ni,
  
  AXI_BUS.Slave   slv,
  
  AXI_BUS.Master  mst
);
  typedef logic [AXI_ID_WIDTH-1:0]     id_t;
  typedef logic [AXI_ADDR_WIDTH-1:0]   addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0]   data_t;
  typedef logic [AXI_DATA_WIDTH/8-1:0] strb_t;
  typedef logic [AXI_USER_WIDTH-1:0]   user_t;
  `AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)
  `AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)
  `AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_R_CHAN_T(r_chan_t, data_t, id_t, user_t)
  `AXI_TYPEDEF_REQ_T(axi_req_t, aw_chan_t, w_chan_t, ar_chan_t)
  `AXI_TYPEDEF_RESP_T(axi_resp_t, b_chan_t, r_chan_t)
  axi_req_t  slv_req,  mst_req;
  axi_resp_t slv_resp, mst_resp;
  `AXI_ASSIGN_TO_REQ(slv_req, slv)
  `AXI_ASSIGN_FROM_RESP(slv, slv_resp)
  `AXI_ASSIGN_FROM_REQ(mst, mst_req)
  `AXI_ASSIGN_TO_RESP(mst_resp, mst)
  axi_atop_filter #(
    .AxiIdWidth      ( AXI_ID_WIDTH       ),
  
    .AxiMaxWriteTxns ( AXI_MAX_WRITE_TXNS ),
  
    .axi_req_t       ( axi_req_t          ),
    .axi_resp_t      ( axi_resp_t         )
  ) i_axi_atop_filter (
    .clk_i,
    .rst_ni,
    .slv_req_i  ( slv_req  ),
    .slv_resp_o ( slv_resp ),
    .mst_req_o  ( mst_req  ),
    .mst_resp_i ( mst_resp )
  );
`ifndef VERILATOR
  initial begin: p_assertions
    assert (AXI_ADDR_WIDTH >= 1) else $fatal(1, "AXI ADDR width must be at least 1!");
    assert (AXI_DATA_WIDTH >= 1) else $fatal(1, "AXI DATA width must be at least 1!");
    assert (AXI_USER_WIDTH >= 1) else $fatal(1, "AXI USER width must be at least 1!");
  end
`endif
endmodule

module axi_err_slv #(
  parameter int unsigned          AxiIdWidth  = 0,                    
  parameter type                  axi_req_t   = logic,                
  parameter type                  axi_resp_t  = logic,                
  parameter axi_pkg::resp_t       Resp        = axi_pkg::RESP_DECERR, 
  parameter int unsigned          RespWidth   = 32'd64,               
  parameter logic [RespWidth-1:0] RespData    = 64'hCA11AB1EBADCAB1E, 
  parameter bit                   ATOPs       = 1'b1,                 
  parameter int unsigned          MaxTrans    = 1                     
) (
  input  logic      clk_i,   
  input  logic      rst_ni,  
  input  logic      test_i,  
  
  input  axi_req_t  slv_req_i,
  output axi_resp_t slv_resp_o
);
  typedef logic [AxiIdWidth-1:0] id_t;
  typedef struct packed {
    id_t           id;
    axi_pkg::len_t len;
  } r_data_t;
  axi_req_t   err_req;
  axi_resp_t  err_resp;
  if (ATOPs) begin
    axi_atop_filter #(
      .AxiIdWidth       ( AxiIdWidth  ),
      .AxiMaxWriteTxns  ( MaxTrans    ),
      .axi_req_t        ( axi_req_t   ),
      .axi_resp_t       ( axi_resp_t  )
    ) i_atop_filter (
      .clk_i,
      .rst_ni,
      .slv_req_i  ( slv_req_i   ),
      .slv_resp_o ( slv_resp_o  ),
      .mst_req_o  ( err_req     ),
      .mst_resp_i ( err_resp    )
    );
  end else begin
    assign err_req    = slv_req_i;
    assign slv_resp_o = err_resp;
  end
  
  logic    w_fifo_full, w_fifo_empty;
  logic    w_fifo_push, w_fifo_pop;
  id_t     w_fifo_data;
  
  logic    b_fifo_full, b_fifo_empty;
  logic    b_fifo_push, b_fifo_pop;
  id_t     b_fifo_data;
  
  r_data_t r_fifo_inp;
  logic    r_fifo_full, r_fifo_empty;
  logic    r_fifo_push, r_fifo_pop;
  r_data_t r_fifo_data;
  
  logic    r_cnt_clear, r_cnt_en, r_cnt_load;
  axi_pkg::len_t r_current_beat;
  
  logic    r_busy_d, r_busy_q, r_busy_load;
  
  
  
  
  assign w_fifo_push        = err_req.aw_valid & ~w_fifo_full;
  assign err_resp.aw_ready  = ~w_fifo_full;
  fifo_v3 #(
    .FALL_THROUGH ( 1'b1      ),
    .DEPTH        ( MaxTrans  ),
    .dtype        ( id_t      )
  ) i_w_fifo (
    .clk_i      ( clk_i             ),
    .rst_ni     ( rst_ni            ),
    .flush_i    ( 1'b0              ),
    .testmode_i ( test_i            ),
    .full_o     ( w_fifo_full       ),
    .empty_o    ( w_fifo_empty      ),
    .usage_o    (                   ),
    .data_i     ( err_req.aw.id     ),
    .push_i     ( w_fifo_push       ),
    .data_o     ( w_fifo_data       ),
    .pop_i      ( w_fifo_pop        )
  );
  always_comb begin : proc_w_channel
    err_resp.w_ready  = 1'b0;
    w_fifo_pop        = 1'b0;
    b_fifo_push       = 1'b0;
    if (!w_fifo_empty && !b_fifo_full) begin
      
      err_resp.w_ready = 1'b1;
      
      if (err_req.w_valid && err_req.w.last) begin
        w_fifo_pop    = 1'b1;
        b_fifo_push   = 1'b1;
      end
    end
  end
  fifo_v3 #(
    .FALL_THROUGH ( 1'b0         ),
    .DEPTH        ( unsigned'(2) ), 
    .dtype        ( id_t         )
  ) i_b_fifo (
    .clk_i      ( clk_i        ),
    .rst_ni     ( rst_ni       ),
    .flush_i    ( 1'b0         ),
    .testmode_i ( test_i       ),
    .full_o     ( b_fifo_full  ),
    .empty_o    ( b_fifo_empty ),
    .usage_o    (              ),
    .data_i     ( w_fifo_data  ),
    .push_i     ( b_fifo_push  ),
    .data_o     ( b_fifo_data  ),
    .pop_i      ( b_fifo_pop   )
  );
  always_comb begin : proc_b_channel
    b_fifo_pop        = 1'b0;
    err_resp.b        = '0;
    err_resp.b.id     = b_fifo_data;
    err_resp.b.resp   = Resp;
    err_resp.b_valid  = 1'b0;
    if (!b_fifo_empty) begin
      err_resp.b_valid = 1'b1;
      
      b_fifo_pop = err_req.b_ready;
    end
  end
  
  
  
  
  assign r_fifo_push        = err_req.ar_valid & ~r_fifo_full;
  assign err_resp.ar_ready  = ~r_fifo_full;
  
  assign r_fifo_inp.id  = err_req.ar.id;
  assign r_fifo_inp.len = err_req.ar.len;
  fifo_v3 #(
    .FALL_THROUGH ( 1'b0      ),
    .DEPTH        ( MaxTrans  ),
    .dtype        ( r_data_t  )
  ) i_r_fifo (
    .clk_i     ( clk_i        ),
    .rst_ni    ( rst_ni       ),
    .flush_i   ( 1'b0         ),
    .testmode_i( test_i       ),
    .full_o    ( r_fifo_full  ),
    .empty_o   ( r_fifo_empty ),
    .usage_o   (              ),
    .data_i    ( r_fifo_inp   ),
    .push_i    ( r_fifo_push  ),
    .data_o    ( r_fifo_data  ),
    .pop_i     ( r_fifo_pop   )
  );
  always_comb begin : proc_r_channel
    
    r_busy_d    = r_busy_q;
    r_busy_load = 1'b0;
    
    r_fifo_pop  = 1'b0;
    
    r_cnt_clear = 1'b0;
    r_cnt_en    = 1'b0;
    r_cnt_load  = 1'b0;
    
    err_resp.r        = '0;
    err_resp.r.id     = r_fifo_data.id;
    err_resp.r.data   = RespData;
    err_resp.r.resp   = Resp;
    err_resp.r_valid  = 1'b0;
    
    if (r_busy_q) begin
      err_resp.r_valid = 1'b1;
      err_resp.r.last = (r_current_beat == '0);
      
      if (err_req.r_ready) begin
        r_cnt_en = 1'b1;
        if (r_current_beat == '0) begin
          r_busy_d    = 1'b0;
          r_busy_load = 1'b1;
          r_cnt_clear = 1'b1;
          r_fifo_pop  = 1'b1;
        end
      end
    end else begin
      
      if (!r_fifo_empty) begin
        r_busy_d    = 1'b1;
        r_busy_load = 1'b1;
        r_cnt_load  = 1'b1;
      end
    end
  end
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if (!rst_ni) begin
      r_busy_q <= '0;
    end else if (r_busy_load) begin
      r_busy_q <= r_busy_d;
    end
  end
  counter #(
    .WIDTH     ($bits(axi_pkg::len_t))
  ) i_r_counter (
    .clk_i     ( clk_i           ),
    .rst_ni    ( rst_ni          ),
    .clear_i   ( r_cnt_clear     ),
    .en_i      ( r_cnt_en        ),
    .load_i    ( r_cnt_load      ),
    .down_i    ( 1'b1            ),
    .d_i       ( r_fifo_data.len ),
    .q_o       ( r_current_beat  ),
    .overflow_o(                 )
  );
  
  `ifndef VERILATOR
  `ifndef XSIM
  initial begin
    assert (Resp == axi_pkg::RESP_DECERR || Resp == axi_pkg::RESP_SLVERR) else
      $fatal(1, "This module may only generate RESP_DECERR or RESP_SLVERR responses!");
  end
  default disable iff (!rst_ni);
  if (!ATOPs) begin : gen_assert_atops_unsupported
    assume property( @(posedge clk_i) (slv_req_i.aw_valid |-> slv_req_i.aw.atop == '0)) else
     $fatal(1, "Got ATOP but not configured to support ATOPs!");
  end
  `endif
  `endif
  
endmodule

interface AXI_BUS #(
  parameter int unsigned AXI_ADDR_WIDTH = 0,
  parameter int unsigned AXI_DATA_WIDTH = 0,
  parameter int unsigned AXI_ID_WIDTH   = 0,
  parameter int unsigned AXI_USER_WIDTH = 0
);
  localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;
  typedef logic [AXI_ID_WIDTH-1:0]   id_t;
  typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0] data_t;
  typedef logic [AXI_STRB_WIDTH-1:0] strb_t;
  typedef logic [AXI_USER_WIDTH-1:0] user_t;
  id_t              aw_id;
  addr_t            aw_addr;
  axi_pkg::len_t    aw_len;
  axi_pkg::size_t   aw_size;
  axi_pkg::burst_t  aw_burst;
  logic             aw_lock;
  axi_pkg::cache_t  aw_cache;
  axi_pkg::prot_t   aw_prot;
  axi_pkg::qos_t    aw_qos;
  axi_pkg::region_t aw_region;
  axi_pkg::atop_t   aw_atop;
  user_t            aw_user;
  logic             aw_valid;
  logic             aw_ready;
  data_t            w_data;
  strb_t            w_strb;
  logic             w_last;
  user_t            w_user;
  logic             w_valid;
  logic             w_ready;
  id_t              b_id;
  axi_pkg::resp_t   b_resp;
  user_t            b_user;
  logic             b_valid;
  logic             b_ready;
  id_t              ar_id;
  addr_t            ar_addr;
  axi_pkg::len_t    ar_len;
  axi_pkg::size_t   ar_size;
  axi_pkg::burst_t  ar_burst;
  logic             ar_lock;
  axi_pkg::cache_t  ar_cache;
  axi_pkg::prot_t   ar_prot;
  axi_pkg::qos_t    ar_qos;
  axi_pkg::region_t ar_region;
  user_t            ar_user;
  logic             ar_valid;
  logic             ar_ready;
  id_t              r_id;
  data_t            r_data;
  axi_pkg::resp_t   r_resp;
  logic             r_last;
  user_t            r_user;
  logic             r_valid;
  logic             r_ready;
  modport Master (
    output aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_atop, aw_user, aw_valid, input aw_ready,
    output w_data, w_strb, w_last, w_user, w_valid, input w_ready,
    input b_id, b_resp, b_user, b_valid, output b_ready,
    output ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_valid, input ar_ready,
    input r_id, r_data, r_resp, r_last, r_user, r_valid, output r_ready
  );
  modport Slave (
    input aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_atop, aw_user, aw_valid, output aw_ready,
    input w_data, w_strb, w_last, w_user, w_valid, output w_ready,
    output b_id, b_resp, b_user, b_valid, input b_ready,
    input ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_valid, output ar_ready,
    output r_id, r_data, r_resp, r_last, r_user, r_valid, input r_ready
  );
  modport Monitor (
    input aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_atop, aw_user, aw_valid, aw_ready,
          w_data, w_strb, w_last, w_user, w_valid, w_ready,
          b_id, b_resp, b_user, b_valid, b_ready,
          ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_valid, ar_ready,
          r_id, r_data, r_resp, r_last, r_user, r_valid, r_ready
  );
endinterface
interface AXI_BUS_DV #(
  parameter int unsigned AXI_ADDR_WIDTH = 0,
  parameter int unsigned AXI_DATA_WIDTH = 0,
  parameter int unsigned AXI_ID_WIDTH   = 0,
  parameter int unsigned AXI_USER_WIDTH = 0
)(
  input logic clk_i
);
  localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;
  typedef logic [AXI_ID_WIDTH-1:0]   id_t;
  typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0] data_t;
  typedef logic [AXI_STRB_WIDTH-1:0] strb_t;
  typedef logic [AXI_USER_WIDTH-1:0] user_t;
  id_t              aw_id;
  addr_t            aw_addr;
  axi_pkg::len_t    aw_len;
  axi_pkg::size_t   aw_size;
  axi_pkg::burst_t  aw_burst;
  logic             aw_lock;
  axi_pkg::cache_t  aw_cache;
  axi_pkg::prot_t   aw_prot;
  axi_pkg::qos_t    aw_qos;
  axi_pkg::region_t aw_region;
  axi_pkg::atop_t   aw_atop;
  user_t            aw_user;
  logic             aw_valid;
  logic             aw_ready;
  data_t            w_data;
  strb_t            w_strb;
  logic             w_last;
  user_t            w_user;
  logic             w_valid;
  logic             w_ready;
  id_t              b_id;
  axi_pkg::resp_t   b_resp;
  user_t            b_user;
  logic             b_valid;
  logic             b_ready;
  id_t              ar_id;
  addr_t            ar_addr;
  axi_pkg::len_t    ar_len;
  axi_pkg::size_t   ar_size;
  axi_pkg::burst_t  ar_burst;
  logic             ar_lock;
  axi_pkg::cache_t  ar_cache;
  axi_pkg::prot_t   ar_prot;
  axi_pkg::qos_t    ar_qos;
  axi_pkg::region_t ar_region;
  user_t            ar_user;
  logic             ar_valid;
  logic             ar_ready;
  id_t              r_id;
  data_t            r_data;
  axi_pkg::resp_t   r_resp;
  logic             r_last;
  user_t            r_user;
  logic             r_valid;
  logic             r_ready;
  modport Master (
    output aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_atop, aw_user, aw_valid, input aw_ready,
    output w_data, w_strb, w_last, w_user, w_valid, input w_ready,
    input b_id, b_resp, b_user, b_valid, output b_ready,
    output ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_valid, input ar_ready,
    input r_id, r_data, r_resp, r_last, r_user, r_valid, output r_ready
  );
  modport Slave (
    input aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_atop, aw_user, aw_valid, output aw_ready,
    input w_data, w_strb, w_last, w_user, w_valid, output w_ready,
    output b_id, b_resp, b_user, b_valid, input b_ready,
    input ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_valid, output ar_ready,
    output r_id, r_data, r_resp, r_last, r_user, r_valid, input r_ready
  );
  modport Monitor (
    input aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_atop, aw_user, aw_valid, aw_ready,
          w_data, w_strb, w_last, w_user, w_valid, w_ready,
          b_id, b_resp, b_user, b_valid, b_ready,
          ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_valid, ar_ready,
          r_id, r_data, r_resp, r_last, r_user, r_valid, r_ready
  );
  
  `ifndef VERILATOR
  
  
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_id)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_addr)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_len)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_size)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_burst)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_lock)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_cache)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_prot)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_qos)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_region)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_atop)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> $stable(aw_user)));
  assert property (@(posedge clk_i) (aw_valid && !aw_ready |=> aw_valid));
  
  assert property (@(posedge clk_i) ( w_valid && ! w_ready |=> $stable(w_data)));
  assert property (@(posedge clk_i) ( w_valid && ! w_ready |=> $stable(w_strb)));
  assert property (@(posedge clk_i) ( w_valid && ! w_ready |=> $stable(w_last)));
  assert property (@(posedge clk_i) ( w_valid && ! w_ready |=> $stable(w_user)));
  assert property (@(posedge clk_i) ( w_valid && ! w_ready |=> w_valid));
  
  assert property (@(posedge clk_i) ( b_valid && ! b_ready |=> $stable(b_id)));
  assert property (@(posedge clk_i) ( b_valid && ! b_ready |=> $stable(b_resp)));
  assert property (@(posedge clk_i) ( b_valid && ! b_ready |=> $stable(b_user)));
  assert property (@(posedge clk_i) ( b_valid && ! b_ready |=> b_valid));
  
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_id)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_addr)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_len)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_size)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_burst)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_lock)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_cache)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_prot)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_qos)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_region)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> $stable(ar_user)));
  assert property (@(posedge clk_i) (ar_valid && !ar_ready |=> ar_valid));
  
  assert property (@(posedge clk_i) ( r_valid && ! r_ready |=> $stable(r_id)));
  assert property (@(posedge clk_i) ( r_valid && ! r_ready |=> $stable(r_data)));
  assert property (@(posedge clk_i) ( r_valid && ! r_ready |=> $stable(r_resp)));
  assert property (@(posedge clk_i) ( r_valid && ! r_ready |=> $stable(r_last)));
  assert property (@(posedge clk_i) ( r_valid && ! r_ready |=> $stable(r_user)));
  assert property (@(posedge clk_i) ( r_valid && ! r_ready |=> r_valid));
  
  
  assert property (@(posedge clk_i) aw_valid |-> (aw_burst != axi_pkg::BURST_INCR) || (
    axi_pkg::beat_addr(aw_addr, aw_size, aw_len, aw_burst, 0) >> 12 ==    
    axi_pkg::beat_addr(aw_addr, aw_size, aw_len, aw_burst, aw_len) >> 12  
  )) else $error("AW burst crossing 4 KiB page boundary detected, which is illegal!");
  assert property (@(posedge clk_i) ar_valid |-> (aw_burst != axi_pkg::BURST_INCR) || (
    axi_pkg::beat_addr(ar_addr, ar_size, ar_len, ar_burst, 0) >> 12 ==    
    axi_pkg::beat_addr(ar_addr, ar_size, ar_len, ar_burst, ar_len) >> 12  
  )) else $error("AR burst crossing 4 KiB page boundary detected, which is illegal!");
  `endif
  
endinterface
interface AXI_BUS_ASYNC
#(
  parameter int unsigned AXI_ADDR_WIDTH = 0,
  parameter int unsigned AXI_DATA_WIDTH = 0,
  parameter int unsigned AXI_ID_WIDTH   = 0,
  parameter int unsigned AXI_USER_WIDTH = 0,
  parameter int unsigned BUFFER_WIDTH   = 0
);
  localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;
  typedef logic [AXI_ID_WIDTH-1:0]   id_t;
  typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0] data_t;
  typedef logic [AXI_STRB_WIDTH-1:0] strb_t;
  typedef logic [AXI_USER_WIDTH-1:0] user_t;
  typedef logic [BUFFER_WIDTH-1:0]   buffer_t;
  id_t              aw_id;
  addr_t            aw_addr;
  axi_pkg::len_t    aw_len;
  axi_pkg::size_t   aw_size;
  axi_pkg::burst_t  aw_burst;
  logic             aw_lock;
  axi_pkg::cache_t  aw_cache;
  axi_pkg::prot_t   aw_prot;
  axi_pkg::qos_t    aw_qos;
  axi_pkg::region_t aw_region;
  axi_pkg::atop_t   aw_atop;
  user_t            aw_user;
  buffer_t          aw_writetoken;
  buffer_t          aw_readpointer;
  data_t            w_data;
  strb_t            w_strb;
  logic             w_last;
  user_t            w_user;
  buffer_t          w_writetoken;
  buffer_t          w_readpointer;
  id_t              b_id;
  axi_pkg::resp_t   b_resp;
  user_t            b_user;
  buffer_t          b_writetoken;
  buffer_t          b_readpointer;
  id_t              ar_id;
  addr_t            ar_addr;
  axi_pkg::len_t    ar_len;
  axi_pkg::size_t   ar_size;
  axi_pkg::burst_t  ar_burst;
  logic             ar_lock;
  axi_pkg::cache_t  ar_cache;
  axi_pkg::prot_t   ar_prot;
  axi_pkg::qos_t    ar_qos;
  axi_pkg::region_t ar_region;
  user_t            ar_user;
  buffer_t          ar_writetoken;
  buffer_t          ar_readpointer;
  id_t              r_id;
  data_t            r_data;
  axi_pkg::resp_t   r_resp;
  logic             r_last;
  user_t            r_user;
  buffer_t          r_writetoken;
  buffer_t          r_readpointer;
  modport Master (
    output aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_atop, aw_user, aw_writetoken, input aw_readpointer,
    output w_data, w_strb, w_last, w_user, w_writetoken, input w_readpointer,
    input b_id, b_resp, b_user, b_writetoken, output b_readpointer,
    output ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_writetoken, input ar_readpointer,
    input r_id, r_data, r_resp, r_last, r_user, r_writetoken, output r_readpointer
  );
  modport Slave (
    input aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_atop, aw_user, aw_writetoken, output aw_readpointer,
    input w_data, w_strb, w_last, w_user, w_writetoken, output w_readpointer,
    output b_id, b_resp, b_user, b_writetoken, input b_readpointer,
    input ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_writetoken, output ar_readpointer,
    output r_id, r_data, r_resp, r_last, r_user, r_writetoken, input r_readpointer
  );
endinterface
`ifndef AXI_TYPEDEF_SVH_
`define AXI_TYPEDEF_SVH_
`define AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)  \
  typedef struct packed {                                       \
    id_t              id;                                       \
    addr_t            addr;                                     \
    axi_pkg::len_t    len;                                      \
    axi_pkg::size_t   size;                                     \
    axi_pkg::burst_t  burst;                                    \
    logic             lock;                                     \
    axi_pkg::cache_t  cache;                                    \
    axi_pkg::prot_t   prot;                                     \
    axi_pkg::qos_t    qos;                                      \
    axi_pkg::region_t region;                                   \
    axi_pkg::atop_t   atop;                                     \
    user_t            user;                                     \
  } aw_chan_t;
`define AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)  \
  typedef struct packed {                                       \
    data_t data;                                                \
    strb_t strb;                                                \
    logic  last;                                                \
    user_t user;                                                \
  } w_chan_t;
`define AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)  \
  typedef struct packed {                             \
    id_t            id;                               \
    axi_pkg::resp_t resp;                             \
    user_t          user;                             \
  } b_chan_t;
`define AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)  \
  typedef struct packed {                                       \
    id_t              id;                                       \
    addr_t            addr;                                     \
    axi_pkg::len_t    len;                                      \
    axi_pkg::size_t   size;                                     \
    axi_pkg::burst_t  burst;                                    \
    logic             lock;                                     \
    axi_pkg::cache_t  cache;                                    \
    axi_pkg::prot_t   prot;                                     \
    axi_pkg::qos_t    qos;                                      \
    axi_pkg::region_t region;                                   \
    user_t            user;                                     \
  } ar_chan_t;
`define AXI_TYPEDEF_R_CHAN_T(r_chan_t, data_t, id_t, user_t)  \
  typedef struct packed {                                     \
    id_t            id;                                       \
    data_t          data;                                     \
    axi_pkg::resp_t resp;                                     \
    logic           last;                                     \
    user_t          user;                                     \
  } r_chan_t;
`define AXI_TYPEDEF_REQ_T(req_t, aw_chan_t, w_chan_t, ar_chan_t)  \
  typedef struct packed {                                         \
    aw_chan_t aw;                                                 \
    logic     aw_valid;                                           \
    w_chan_t  w;                                                  \
    logic     w_valid;                                            \
    logic     b_ready;                                            \
    ar_chan_t ar;                                                 \
    logic     ar_valid;                                           \
    logic     r_ready;                                            \
  } req_t;
`define AXI_TYPEDEF_RESP_T(resp_t, b_chan_t, r_chan_t)  \
  typedef struct packed {                               \
    logic     aw_ready;                                 \
    logic     ar_ready;                                 \
    logic     w_ready;                                  \
    logic     b_valid;                                  \
    b_chan_t  b;                                        \
    logic     r_valid;                                  \
    r_chan_t  r;                                        \
  } resp_t;
`define AXI_TYPEDEF_ALL_CT(__name, __req, __rsp, __addr_t, __id_t, __data_t, __strb_t, __user_t) \
  `AXI_TYPEDEF_AW_CHAN_T(__name``_aw_chan_t, __addr_t, __id_t, __user_t)                         \
  `AXI_TYPEDEF_W_CHAN_T(__name``_w_chan_t, __data_t, __strb_t, __user_t)                         \
  `AXI_TYPEDEF_B_CHAN_T(__name``_b_chan_t, __id_t, __user_t)                                     \
  `AXI_TYPEDEF_AR_CHAN_T(__name``_ar_chan_t, __addr_t, __id_t, __user_t)                         \
  `AXI_TYPEDEF_R_CHAN_T(__name``_r_chan_t, __data_t, __id_t, __user_t)                           \
  `AXI_TYPEDEF_REQ_T(__req, __name``_aw_chan_t, __name``_w_chan_t, __name``_ar_chan_t)           \
  `AXI_TYPEDEF_RESP_T(__rsp, __name``_b_chan_t, __name``_r_chan_t)
`define AXI_TYPEDEF_ALL(__name, __addr_t, __id_t, __data_t, __strb_t, __user_t)                                \
  `AXI_TYPEDEF_ALL_CT(__name, __name``_req_t, __name``_resp_t, __addr_t, __id_t, __data_t, __strb_t, __user_t)
`define AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_lite_t, addr_t)  \
  typedef struct packed {                                   \
    addr_t          addr;                                   \
    axi_pkg::prot_t prot;                                   \
  } aw_chan_lite_t;
`define AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_lite_t, data_t, strb_t)  \
  typedef struct packed {                                         \
    data_t   data;                                                \
    strb_t   strb;                                                \
  } w_chan_lite_t;
`define AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_lite_t)  \
  typedef struct packed {                         \
    axi_pkg::resp_t resp;                         \
  } b_chan_lite_t;
`define AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_lite_t, addr_t)  \
  typedef struct packed {                                   \
    addr_t          addr;                                   \
    axi_pkg::prot_t prot;                                   \
  } ar_chan_lite_t;
`define AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_lite_t, data_t)  \
  typedef struct packed {                                 \
    data_t          data;                                 \
    axi_pkg::resp_t resp;                                 \
  } r_chan_lite_t;
`define AXI_LITE_TYPEDEF_REQ_T(req_lite_t, aw_chan_lite_t, w_chan_lite_t, ar_chan_lite_t)  \
  typedef struct packed {                                                                  \
    aw_chan_lite_t aw;                                                                     \
    logic          aw_valid;                                                               \
    w_chan_lite_t  w;                                                                      \
    logic          w_valid;                                                                \
    logic          b_ready;                                                                \
    ar_chan_lite_t ar;                                                                     \
    logic          ar_valid;                                                               \
    logic          r_ready;                                                                \
  } req_lite_t;
`define AXI_LITE_TYPEDEF_RESP_T(resp_lite_t, b_chan_lite_t, r_chan_lite_t)  \
  typedef struct packed {                                                   \
    logic          aw_ready;                                                \
    logic          w_ready;                                                 \
    b_chan_lite_t  b;                                                       \
    logic          b_valid;                                                 \
    logic          ar_ready;                                                \
    r_chan_lite_t  r;                                                       \
    logic          r_valid;                                                 \
  } resp_lite_t;
`define AXI_LITE_TYPEDEF_ALL_CT(__name, __req, __rsp, __addr_t, __data_t, __strb_t)         \
  `AXI_LITE_TYPEDEF_AW_CHAN_T(__name``_aw_chan_t, __addr_t)                                 \
  `AXI_LITE_TYPEDEF_W_CHAN_T(__name``_w_chan_t, __data_t, __strb_t)                         \
  `AXI_LITE_TYPEDEF_B_CHAN_T(__name``_b_chan_t)                                             \
  `AXI_LITE_TYPEDEF_AR_CHAN_T(__name``_ar_chan_t, __addr_t)                                 \
  `AXI_LITE_TYPEDEF_R_CHAN_T(__name``_r_chan_t, __data_t)                                   \
  `AXI_LITE_TYPEDEF_REQ_T(__req, __name``_aw_chan_t, __name``_w_chan_t, __name``_ar_chan_t) \
  `AXI_LITE_TYPEDEF_RESP_T(__rsp, __name``_b_chan_t, __name``_r_chan_t)
`define AXI_LITE_TYPEDEF_ALL(__name, __addr_t, __data_t, __strb_t)                                \
  `AXI_LITE_TYPEDEF_ALL_CT(__name, __name``_req_t, __name``_resp_t, __addr_t, __data_t, __strb_t)
`endif
interface AXI_BUS_ASYNC_GRAY #(
  parameter int unsigned AXI_ADDR_WIDTH = 0,
  parameter int unsigned AXI_DATA_WIDTH = 0,
  parameter int unsigned AXI_ID_WIDTH = 0,
  parameter int unsigned AXI_USER_WIDTH = 0,
  parameter int unsigned LOG_DEPTH = 0
);
  localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;
  typedef logic [AXI_ID_WIDTH-1:0]   id_t;
  typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0] data_t;
  typedef logic [AXI_STRB_WIDTH-1:0] strb_t;
  typedef logic [AXI_USER_WIDTH-1:0] user_t;
  `AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)
  `AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)
  `AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_R_CHAN_T(r_chan_t, data_t, id_t, user_t)
  aw_chan_t  [2**LOG_DEPTH-1:0] aw_data;
  w_chan_t   [2**LOG_DEPTH-1:0] w_data;
  b_chan_t   [2**LOG_DEPTH-1:0] b_data;
  ar_chan_t  [2**LOG_DEPTH-1:0] ar_data;
  r_chan_t   [2**LOG_DEPTH-1:0] r_data;
  logic           [LOG_DEPTH:0] aw_wptr,  aw_rptr,
                                w_wptr,   w_rptr,
                                b_wptr,   b_rptr,
                                ar_wptr,  ar_rptr,
                                r_wptr,   r_rptr;
  modport Master (
    output aw_data, aw_wptr, input aw_rptr,
    output w_data, w_wptr, input w_rptr,
    input b_data, b_wptr, output b_rptr,
    output ar_data, ar_wptr, input ar_rptr,
    input r_data, r_wptr, output r_rptr);
  modport Slave (
    input aw_data, aw_wptr, output aw_rptr,
    input w_data, w_wptr, output w_rptr,
    output b_data, b_wptr, input b_rptr,
    input ar_data, ar_wptr, output ar_rptr,
    output r_data, r_wptr, input r_rptr);
endinterface
interface AXI_LITE #(
  parameter int unsigned AXI_ADDR_WIDTH = 0,
  parameter int unsigned AXI_DATA_WIDTH = 0
);
  localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;
  typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0] data_t;
  typedef logic [AXI_STRB_WIDTH-1:0] strb_t;
  
  addr_t          aw_addr;
  axi_pkg::prot_t aw_prot;
  logic           aw_valid;
  logic           aw_ready;
  data_t          w_data;
  strb_t          w_strb;
  logic           w_valid;
  logic           w_ready;
  axi_pkg::resp_t b_resp;
  logic           b_valid;
  logic           b_ready;
  addr_t          ar_addr;
  axi_pkg::prot_t ar_prot;
  logic           ar_valid;
  logic           ar_ready;
  data_t          r_data;
  axi_pkg::resp_t r_resp;
  logic           r_valid;
  logic           r_ready;
  modport Master (
    output aw_addr, aw_prot, aw_valid, input aw_ready,
    output w_data, w_strb, w_valid, input w_ready,
    input b_resp, b_valid, output b_ready,
    output ar_addr, ar_prot, ar_valid, input ar_ready,
    input r_data, r_resp, r_valid, output r_ready
  );
  modport Slave (
    input aw_addr, aw_prot, aw_valid, output aw_ready,
    input w_data, w_strb, w_valid, output w_ready,
    output b_resp, b_valid, input b_ready,
    input ar_addr, ar_prot, ar_valid, output ar_ready,
    output r_data, r_resp, r_valid, input r_ready
  );
  modport Monitor (
    input aw_addr, aw_prot, aw_valid, aw_ready,
          w_data, w_strb, w_valid, w_ready,
          b_resp, b_valid, b_ready,
          ar_addr, ar_prot, ar_valid, ar_ready,
          r_data, r_resp, r_valid, r_ready
  );
endinterface
interface AXI_LITE_DV #(
  parameter int unsigned AXI_ADDR_WIDTH = 0,
  parameter int unsigned AXI_DATA_WIDTH = 0
)(
  input logic clk_i
);
  localparam AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;
  typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0] data_t;
  typedef logic [AXI_STRB_WIDTH-1:0] strb_t;
  
  addr_t          aw_addr;
  axi_pkg::prot_t aw_prot;
  logic           aw_valid;
  logic           aw_ready;
  data_t          w_data;
  strb_t          w_strb;
  logic           w_valid;
  logic           w_ready;
  axi_pkg::resp_t b_resp;
  logic           b_valid;
  logic           b_ready;
  addr_t          ar_addr;
  axi_pkg::prot_t ar_prot;
  logic           ar_valid;
  logic           ar_ready;
  data_t          r_data;
  axi_pkg::resp_t r_resp;
  logic           r_valid;
  logic           r_ready;
  modport Master (
    output aw_addr, aw_prot, aw_valid, input aw_ready,
    output w_data, w_strb, w_valid, input w_ready,
    input b_resp, b_valid, output b_ready,
    output ar_addr, ar_prot, ar_valid, input ar_ready,
    input r_data, r_resp, r_valid, output r_ready
  );
  modport Slave (
    input aw_addr, aw_prot, aw_valid, output aw_ready,
    input w_data, w_strb, w_valid, output w_ready,
    output b_resp, b_valid, input b_ready,
    input ar_addr, ar_prot, ar_valid, output ar_ready,
    output r_data, r_resp, r_valid, input r_ready
  );
  modport Monitor (
    input aw_addr, aw_prot, aw_valid, aw_ready,
          w_data, w_strb, w_valid, w_ready,
          b_resp, b_valid, b_ready,
          ar_addr, ar_prot, ar_valid, ar_ready,
          r_data, r_resp, r_valid, r_ready
  );
endinterface
interface AXI_LITE_ASYNC_GRAY #(
  parameter int unsigned AXI_ADDR_WIDTH = 0,
  parameter int unsigned AXI_DATA_WIDTH = 0,
  parameter int unsigned LOG_DEPTH = 0
);
  localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;
  typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
  typedef logic [AXI_DATA_WIDTH-1:0] data_t;
  typedef logic [AXI_STRB_WIDTH-1:0] strb_t;
  `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t)
  `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t)
  `AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_t)
  `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t)
  `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_t, data_t)
  aw_chan_t  [2**LOG_DEPTH-1:0] aw_data;
  w_chan_t   [2**LOG_DEPTH-1:0] w_data;
  b_chan_t   [2**LOG_DEPTH-1:0] b_data;
  ar_chan_t  [2**LOG_DEPTH-1:0] ar_data;
  r_chan_t   [2**LOG_DEPTH-1:0] r_data;
  logic           [LOG_DEPTH:0] aw_wptr,  aw_rptr,
                                w_wptr,   w_rptr,
                                b_wptr,   b_rptr,
                                ar_wptr,  ar_rptr,
                                r_wptr,   r_rptr;
  modport Master (
    output aw_data, aw_wptr, input aw_rptr,
    output w_data, w_wptr, input w_rptr,
    input b_data, b_wptr, output b_rptr,
    output ar_data, ar_wptr, input ar_rptr,
    input r_data, r_wptr, output r_rptr);
  modport Slave (
    input aw_data, aw_wptr, output aw_rptr,
    input w_data, w_wptr, output w_rptr,
    output b_data, b_wptr, input b_rptr,
    input ar_data, ar_wptr, output ar_rptr,
    output r_data, r_wptr, input r_rptr);
endinterface

`ifndef COMMON_CELLS_REGISTERS_SVH_
`define COMMON_CELLS_REGISTERS_SVH_
`ifdef VERILATOR
`define NO_SYNOPSYS_FF 1`endif
`define REG_DFLT_CLK clk_i
`define REG_DFLT_RST rst_ni
`define FF(__q, __d, __reset_value, __clk = `REG_DFLT_CLK, __arst_n = `REG_DFLT_RST) \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin                           \
    if (!__arst_n) begin                                                             \
      __q <= (__reset_value);                                                        \
    end else begin                                                                   \
      __q <= (__d);                                                                  \
    end                                                                              \
  end
`define FFAR(__q, __d, __reset_value, __clk, __arst)     \
  always_ff @(posedge (__clk) or posedge (__arst)) begin \
    if (__arst) begin                                    \
      __q <= (__reset_value);                            \
    end else begin                                       \
      __q <= (__d);                                      \
    end                                                  \
  end
`define FFARN(__q, __d, __reset_value, __clk, __arst_n) \
  `FF(__q, __d, __reset_value, __clk, __arst_n)
`define FFSR(__q, __d, __reset_value, __clk, __reset_clk) \
  `ifndef NO_SYNOPSYS_FF                                  \
  /``* synopsys sync_set_reset `"__reset_clk`" *``/       \
  `endif                                                  \
  always_ff @(posedge (__clk)) begin                      \
    __q <= (__reset_clk) ? (__reset_value) : (__d);       \
  end
`define FFSRN(__q, __d, __reset_value, __clk, __reset_n_clk) \
  `ifndef NO_SYNOPSYS_FF                                     \
  /``* synopsys sync_set_reset `"__reset_n_clk`" *``/        \
  `endif                                                     \
  always_ff @(posedge (__clk)) begin                         \
    __q <= (!__reset_n_clk) ? (__reset_value) : (__d);       \
  end
`define FFNR(__q, __d, __clk)        \
  always_ff @(posedge (__clk)) begin \
    __q <= (__d);                    \
  end
`define FFL(__q, __d, __load, __reset_value, __clk = `REG_DFLT_CLK, __arst_n = `REG_DFLT_RST) \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin                                    \
    if (!__arst_n) begin                                                                      \
      __q <= (__reset_value);                                                                 \
    end else begin                                                                            \
      if (__load) begin                                                                       \
        __q <= (__d);                                                                         \
      end                                                                                     \
    end                                                                                       \
  end
`define FFLAR(__q, __d, __load, __reset_value, __clk, __arst) \
  always_ff @(posedge (__clk) or posedge (__arst)) begin      \
    if (__arst) begin                                         \
      __q <= (__reset_value);                                 \
    end else begin                                            \
      if (__load) begin                                       \
        __q <= (__d);                                         \
      end                                                     \
    end                                                       \
  end
`define FFLARN(__q, __d, __load, __reset_value, __clk, __arst_n) \
  `FFL(__q, __d, __load, __reset_value, __clk, __arst_n)
`define FFLSR(__q, __d, __load, __reset_value, __clk, __reset_clk) \
  `ifndef NO_SYNOPSYS_FF                                           \
  /``* synopsys sync_set_reset `"__reset_clk`" *``/                \
  `endif                                                           \
  always_ff @(posedge (__clk)) begin                               \
    if (__reset_clk) begin                                         \
      __q <= (__reset_value);                                      \
    end else if (__load) begin                                     \
      __q <= (__d);                                                \
    end                                                            \
  end
`define FFLSRN(__q, __d, __load, __reset_value, __clk, __reset_n_clk) \
  `ifndef NO_SYNOPSYS_FF                                              \
  /``* synopsys sync_set_reset `"__reset_n_clk`" *``/                 \
  `endif                                                              \
  always_ff @(posedge (__clk)) begin                                  \
    if (!__reset_n_clk) begin                                         \
      __q <= (__reset_value);                                         \
    end else if (__load) begin                                        \
      __q <= (__d);                                                   \
    end                                                               \
  end
`define FFLARNC(__q, __d, __load, __clear, __reset_value, __clk, __arst_n) \
    `ifndef NO_SYNOPSYS_FF                                                 \
  /``* synopsys sync_set_reset `"__clear`" *``/                            \
    `endif                                                                 \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin                 \
    if (!__arst_n) begin                                                   \
      __q <= (__reset_value);                                              \
    end else begin                                                         \
      if (__clear) begin                                                   \
        __q <= (__reset_value);                                            \
      end else if (__load) begin                                           \
        __q <= (__d);                                                      \
      end                                                                  \
    end                                                                    \
  end
`define FFARNC(__q, __d, __clear, __reset_value, __clk, __arst_n) \
    `ifndef NO_SYNOPSYS_FF                                        \
  /``* synopsys sync_set_reset `"__clear`" *``/                   \
    `endif                                                        \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin        \
    if (!__arst_n) begin                                          \
      __q <= (__reset_value);                                     \
    end else begin                                                \
      if (__clear) begin                                          \
        __q <= (__reset_value);                                   \
      end else begin                                              \
        __q <= (__d);                                             \
      end                                                         \
    end                                                           \
  end
`define FFLNR(__q, __d, __load, __clk) \
  always_ff @(posedge (__clk)) begin   \
    if (__load) begin                  \
      __q <= (__d);                    \
    end                                \
  end
`endif
`ifdef QUESTA
`define TARGET_VSIM`endif
module axi_lite_demux #(
  parameter type         aw_chan_t      = logic, 
  parameter type         w_chan_t       = logic, 
  parameter type         b_chan_t       = logic, 
  parameter type         ar_chan_t      = logic, 
  parameter type         r_chan_t       = logic, 
  parameter type         axi_req_t      = logic, 
  parameter type         axi_resp_t     = logic, 
  parameter int unsigned NoMstPorts     = 32'd0, 
  parameter int unsigned MaxTrans       = 32'd0, 
  parameter bit          FallThrough    = 1'b0,  
  parameter bit          SpillAw        = 1'b1,  
  parameter bit          SpillW         = 1'b0,  
  parameter bit          SpillB         = 1'b0,  
  parameter bit          SpillAr        = 1'b1,  
  parameter bit          SpillR         = 1'b0,  
  
  parameter type         select_t       = logic [$clog2(NoMstPorts)-1:0]
) (
  input  logic                        clk_i,
  input  logic                        rst_ni,
  input  logic                        test_i,
  
  input  axi_req_t                    slv_req_i,
  input  select_t                     slv_aw_select_i,
  input  select_t                     slv_ar_select_i,
  output axi_resp_t                   slv_resp_o,
  
  output axi_req_t  [NoMstPorts-1:0]  mst_reqs_o,
  input  axi_resp_t [NoMstPorts-1:0]  mst_resps_i
);
  
  
  
  typedef struct packed {
    aw_chan_t aw;
    select_t  select;
  } aw_chan_select_t;
  typedef struct packed {
    ar_chan_t ar;
    select_t  select;
  } ar_chan_select_t;
  if (NoMstPorts == 32'd1) begin : gen_no_demux
    
    spill_register #(
      .T       ( aw_chan_t  ),
      .Bypass  ( ~SpillAw   )
    ) i_aw_spill_reg (
      .clk_i   ( clk_i                    ),
      .rst_ni  ( rst_ni                   ),
      .valid_i ( slv_req_i.aw_valid       ),
      .ready_o ( slv_resp_o.aw_ready      ),
      .data_i  ( slv_req_i.aw             ),
      .valid_o ( mst_reqs_o[0].aw_valid   ),
      .ready_i ( mst_resps_i[0].aw_ready  ),
      .data_o  ( mst_reqs_o[0].aw         )
    );
    spill_register #(
      .T       ( w_chan_t  ),
      .Bypass  ( ~SpillW   )
    ) i_w_spill_reg (
      .clk_i   ( clk_i                   ),
      .rst_ni  ( rst_ni                  ),
      .valid_i ( slv_req_i.w_valid       ),
      .ready_o ( slv_resp_o.w_ready      ),
      .data_i  ( slv_req_i.w             ),
      .valid_o ( mst_reqs_o[0].w_valid   ),
      .ready_i ( mst_resps_i[0].w_ready  ),
      .data_o  ( mst_reqs_o[0].w         )
    );
    spill_register #(
      .T       ( b_chan_t ),
      .Bypass  ( ~SpillB      )
    ) i_b_spill_reg (
      .clk_i   ( clk_i                  ),
      .rst_ni  ( rst_ni                 ),
      .valid_i ( mst_resps_i[0].b_valid ),
      .ready_o ( mst_reqs_o[0].b_ready  ),
      .data_i  ( mst_resps_i[0].b       ),
      .valid_o ( slv_resp_o.b_valid     ),
      .ready_i ( slv_req_i.b_ready      ),
      .data_o  ( slv_resp_o.b           )
    );
    spill_register #(
      .T       ( ar_chan_t  ),
      .Bypass  ( ~SpillAr   )
    ) i_ar_spill_reg (
      .clk_i   ( clk_i                    ),
      .rst_ni  ( rst_ni                   ),
      .valid_i ( slv_req_i.ar_valid       ),
      .ready_o ( slv_resp_o.ar_ready      ),
      .data_i  ( slv_req_i.ar             ),
      .valid_o ( mst_reqs_o[0].ar_valid   ),
      .ready_i ( mst_resps_i[0].ar_ready  ),
      .data_o  ( mst_reqs_o[0].ar         )
    );
    spill_register #(
      .T       ( r_chan_t ),
      .Bypass  ( ~SpillR      )
    ) i_r_spill_reg (
      .clk_i   ( clk_i                  ),
      .rst_ni  ( rst_ni                 ),
      .valid_i ( mst_resps_i[0].r_valid ),
      .ready_o ( mst_reqs_o[0].r_ready  ),
      .data_i  ( mst_resps_i[0].r       ),
      .valid_o ( slv_resp_o.r_valid     ),
      .ready_i ( slv_req_i.r_ready      ),
      .data_o  ( slv_resp_o.r           )
    );
  end else begin : gen_demux
    
    
    
    
    
    
    
    
    
    aw_chan_select_t       slv_aw_chan;
    logic                  slv_aw_valid,    slv_aw_ready;
    logic [NoMstPorts-1:0] mst_aw_valids, mst_aw_readies;
    logic                  lock_aw_valid_d, lock_aw_valid_q, load_aw_lock;
    logic                  w_fifo_push,     w_fifo_pop;
    logic                  w_fifo_full,     w_fifo_empty;
    w_chan_t               slv_w_chan;
    select_t               w_select;
    logic                  slv_w_valid,     slv_w_ready;
    logic                          b_fifo_pop;
    logic                  b_fifo_full,     b_fifo_empty;
    b_chan_t               slv_b_chan;
    select_t               b_select;
    logic                  slv_b_valid,     slv_b_ready;
    
    
    
    ar_chan_select_t slv_ar_chan;
    logic            slv_ar_valid,    slv_ar_ready;
    logic            r_fifo_push,     r_fifo_pop;
    logic            r_fifo_full,     r_fifo_empty;
    r_chan_t         slv_r_chan;
    select_t         r_select;
    logic            slv_r_valid,     slv_r_ready;
    
    
    
    
    
    
    
    
    `ifdef TARGET_VSIM
    
    
    typedef logic [$bits(aw_chan_select_t)-1:0] aw_chan_select_flat_t;`else
    
    
    typedef aw_chan_select_t aw_chan_select_flat_t;
    `endif
    aw_chan_select_flat_t slv_aw_chan_select_in_flat,
                          slv_aw_chan_select_out_flat;
    assign slv_aw_chan_select_in_flat = {slv_req_i.aw, slv_aw_select_i};
    spill_register #(
      .T      ( aw_chan_select_flat_t         ),
      .Bypass ( ~SpillAw                      )
    ) i_aw_spill_reg (
      .clk_i   ( clk_i                        ),
      .rst_ni  ( rst_ni                       ),
      .valid_i ( slv_req_i.aw_valid           ),
      .ready_o ( slv_resp_o.aw_ready          ),
      .data_i  ( slv_aw_chan_select_in_flat   ),
      .valid_o ( slv_aw_valid                 ),
      .ready_i ( slv_aw_ready                 ),
      .data_o  ( slv_aw_chan_select_out_flat  )
    );
    assign slv_aw_chan = slv_aw_chan_select_out_flat;
    
    for (genvar i = 0; i < NoMstPorts; i++) begin : gen_mst_aw
      assign mst_reqs_o[i].aw       = slv_aw_chan.aw;
      assign mst_reqs_o[i].aw_valid = mst_aw_valids[i];
      assign mst_aw_readies[i]      = mst_resps_i[i].aw_ready;
    end
    
    always_comb begin
      
      lock_aw_valid_d = lock_aw_valid_q;
      load_aw_lock    = 1'b0;
      
      slv_aw_ready    = 1'b0;
      mst_aw_valids   = '0;
      
      w_fifo_push     = 1'b0;
      
      if (lock_aw_valid_q) begin
        
        mst_aw_valids[slv_aw_chan.select] = 1'b1;
        if (mst_aw_readies[slv_aw_chan.select]) begin
          
          slv_aw_ready    = 1'b1;
          lock_aw_valid_d = 1'b0;
          load_aw_lock    = 1'b1;
        end
      end else begin
        if (!w_fifo_full && slv_aw_valid) begin
          
          w_fifo_push                       = 1'b1;
          mst_aw_valids[slv_aw_chan.select] = 1'b1; 
          if (mst_aw_readies[slv_aw_chan.select]) begin
            
            slv_aw_ready = 1'b1;
          end else begin
            
            lock_aw_valid_d = 1'b1;
            load_aw_lock    = 1'b1;
          end
        end
      end
    end
    
    
    `FFLARN(lock_aw_valid_q, lock_aw_valid_d, load_aw_lock, '0, clk_i, rst_ni)
    fifo_v3 #(
      .FALL_THROUGH( FallThrough ),
      .DEPTH       ( MaxTrans    ),
      .dtype       ( select_t    )
    ) i_w_fifo (
      .clk_i      ( clk_i              ),
      .rst_ni     ( rst_ni             ),
      .flush_i    ( 1'b0               ), 
      .testmode_i ( test_i             ),
      .full_o     ( w_fifo_full        ),
      .empty_o    ( w_fifo_empty       ),
      .usage_o    (        ),
      .data_i     ( slv_aw_chan.select ),
      .push_i     ( w_fifo_push        ),
      .data_o     ( w_select           ),
      .pop_i      ( w_fifo_pop         )
    );
    
    
    
    spill_register #(
      .T      ( w_chan_t ),
      .Bypass ( ~SpillW  )
    ) i_w_spill_reg (
      .clk_i   ( clk_i              ),
      .rst_ni  ( rst_ni             ),
      .valid_i ( slv_req_i.w_valid  ),
      .ready_o ( slv_resp_o.w_ready ),
      .data_i  ( slv_req_i.w        ),
      .valid_o ( slv_w_valid        ),
      .ready_i ( slv_w_ready        ),
      .data_o  ( slv_w_chan         )
    );
    
    for (genvar i = 0; i < NoMstPorts; i++) begin : gen_mst_w
      assign mst_reqs_o[i].w       = slv_w_chan;
      assign mst_reqs_o[i].w_valid = ~w_fifo_empty & ~b_fifo_full &
                                       slv_w_valid & (w_select == select_t'(i));
    end
    assign slv_w_ready = ~w_fifo_empty & ~b_fifo_full & mst_resps_i[w_select].w_ready;
    assign w_fifo_pop  = slv_w_valid & slv_w_ready;
    fifo_v3 #(
      .FALL_THROUGH( FallThrough ),
      .DEPTH       ( MaxTrans    ),
      .dtype       ( select_t    )
    ) i_b_fifo (
      .clk_i      ( clk_i        ),
      .rst_ni     ( rst_ni       ),
      .flush_i    ( 1'b0         ), 
      .testmode_i ( test_i       ),
      .full_o     ( b_fifo_full  ),
      .empty_o    ( b_fifo_empty ),
      .usage_o    (  ),
      .data_i     ( w_select     ),
      .push_i     ( w_fifo_pop   ), 
      .data_o     ( b_select     ),
      .pop_i      ( b_fifo_pop   )
    );
    
    
    
    spill_register #(
      .T      ( b_chan_t ),
      .Bypass ( ~SpillB  )
    ) i_b_spill_reg (
      .clk_i   ( clk_i              ),
      .rst_ni  ( rst_ni             ),
      .valid_i ( slv_b_valid        ),
      .ready_o ( slv_b_ready        ),
      .data_i  ( slv_b_chan         ),
      .valid_o ( slv_resp_o.b_valid ),
      .ready_i ( slv_req_i.b_ready  ),
      .data_o  ( slv_resp_o.b       )
    );
    
    assign slv_b_chan      = (!b_fifo_empty) ? mst_resps_i[b_select].b : '0;
    assign slv_b_valid     =  ~b_fifo_empty  & mst_resps_i[b_select].b_valid;
    for (genvar i = 0; i < NoMstPorts; i++) begin : gen_mst_b
      assign mst_reqs_o[i].b_ready = ~b_fifo_empty & slv_b_ready & (b_select == select_t'(i));
    end
    assign b_fifo_pop = slv_b_valid & slv_b_ready;
    
    
    
    
    `ifdef TARGET_VSIM
    typedef logic [$bits(ar_chan_select_t)-1:0] ar_chan_select_flat_t;`else
    typedef ar_chan_select_t ar_chan_select_flat_t;
    `endif
    ar_chan_select_flat_t slv_ar_chan_select_in_flat,
                          slv_ar_chan_select_out_flat;
    assign slv_ar_chan_select_in_flat = {slv_req_i.ar, slv_ar_select_i};
    spill_register #(
      .T      ( ar_chan_select_flat_t         ),
      .Bypass ( ~SpillAr                      )
    ) i_ar_spill_reg (
      .clk_i   ( clk_i                        ),
      .rst_ni  ( rst_ni                       ),
      .valid_i ( slv_req_i.ar_valid           ),
      .ready_o ( slv_resp_o.ar_ready          ),
      .data_i  ( slv_ar_chan_select_in_flat   ),
      .valid_o ( slv_ar_valid                 ),
      .ready_i ( slv_ar_ready                 ),
      .data_o  ( slv_ar_chan_select_out_flat  )
    );
    assign slv_ar_chan = slv_ar_chan_select_out_flat;
    
    for (genvar i = 0; i < NoMstPorts; i++) begin : gen_mst_ar
      assign mst_reqs_o[i].ar       = slv_ar_chan.ar;
      assign mst_reqs_o[i].ar_valid = ~r_fifo_full & slv_ar_valid &
                                       (slv_ar_chan.select == select_t'(i));
    end
    assign slv_ar_ready = ~r_fifo_full & mst_resps_i[slv_ar_chan.select].ar_ready;
    assign r_fifo_push  = slv_ar_valid & slv_ar_ready;
    fifo_v3 #(
      .FALL_THROUGH( FallThrough ),
      .DEPTH       ( MaxTrans    ),
      .dtype       ( select_t    )
    ) i_r_fifo (
      .clk_i      ( clk_i              ),
      .rst_ni     ( rst_ni             ),
      .flush_i    ( 1'b0               ), 
      .testmode_i ( test_i             ),
      .full_o     ( r_fifo_full        ),
      .empty_o    ( r_fifo_empty       ),
      .usage_o    (        ),
      .data_i     ( slv_ar_chan.select ),
      .push_i     ( r_fifo_push        ),
      .data_o     ( r_select           ),
      .pop_i      ( r_fifo_pop         )
    );
    
    
    
    spill_register #(
      .T      ( r_chan_t ),
      .Bypass ( ~SpillR  )
    ) i_r_spill_reg (
      .clk_i   ( clk_i              ),
      .rst_ni  ( rst_ni             ),
      .valid_i ( slv_r_valid        ),
      .ready_o ( slv_r_ready        ),
      .data_i  ( slv_r_chan         ),
      .valid_o ( slv_resp_o.r_valid ),
      .ready_i ( slv_req_i.r_ready  ),
      .data_o  ( slv_resp_o.r       )
    );
    
    always_comb begin
       slv_r_chan  = '0;
       slv_r_valid = '0;
       if (!r_fifo_empty) begin
          slv_r_chan  = mst_resps_i[r_select].r;
          slv_r_valid = mst_resps_i[r_select].r_valid;
       end
    end
    for (genvar i = 0; i < NoMstPorts; i++) begin : gen_mst_r
      assign mst_reqs_o[i].r_ready = ~r_fifo_empty & slv_r_ready & (r_select == select_t'(i));
    end
    assign r_fifo_pop      = slv_r_valid & slv_r_ready;
    
    `ifndef VERILATOR
    default disable iff (!rst_ni);
    aw_select: assume property( @(posedge clk_i) (slv_req_i.aw_valid |->
                                                 (slv_aw_select_i < NoMstPorts))) else
      $fatal(1, "slv_aw_select_i is %d: AW has selected a slave that is not defined.\
                 NoMstPorts: %d", slv_aw_select_i, NoMstPorts);
    ar_select: assume property( @(posedge clk_i) (slv_req_i.ar_valid |->
                                                 (slv_ar_select_i < NoMstPorts))) else
      $fatal(1, "slv_ar_select_i is %d: AR has selected a slave that is not defined.\
                 NoMstPorts: %d", slv_ar_select_i, NoMstPorts);
    aw_valid_stable: assert property( @(posedge clk_i) (slv_aw_valid && !slv_aw_ready)
                                                       |=> slv_aw_valid) else
      $fatal(1, "aw_valid was deasserted, when aw_ready = 0 in last cycle.");
    ar_valid_stable: assert property( @(posedge clk_i) (slv_ar_valid && !slv_ar_ready)
                                                       |=> slv_ar_valid) else
      $fatal(1, "ar_valid was deasserted, when ar_ready = 0 in last cycle.");
    aw_stable: assert property( @(posedge clk_i) (slv_aw_valid && !slv_aw_ready)
                               |=> $stable(slv_aw_chan)) else
      $fatal(1, "slv_aw_chan_select unstable with valid set.");
    ar_stable: assert property( @(posedge clk_i) (slv_ar_valid && !slv_ar_ready)
                               |=> $stable(slv_ar_chan)) else
      $fatal(1, "slv_aw_chan_select unstable with valid set.");
    `endif
    
  end
  
  `ifndef VERILATOR
    initial begin: p_assertions
      NoPorts:  assert (NoMstPorts > 0) else $fatal("Number of master ports must be at least 1!");
      MaxTnx:   assert (MaxTrans   > 0) else $fatal("Number of transactions must be at least 1!");
    end
  `endif
  
endmodule
`ifndef AXI_ASSIGN_SVH_
`define AXI_ASSIGN_SVH_
`define __AXI_TO_AW(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)   \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``addr   = __rhs``__rhs_sep``addr;       \
  __opt_as __lhs``__lhs_sep``len    = __rhs``__rhs_sep``len;        \
  __opt_as __lhs``__lhs_sep``size   = __rhs``__rhs_sep``size;       \
  __opt_as __lhs``__lhs_sep``burst  = __rhs``__rhs_sep``burst;      \
  __opt_as __lhs``__lhs_sep``lock   = __rhs``__rhs_sep``lock;       \
  __opt_as __lhs``__lhs_sep``cache  = __rhs``__rhs_sep``cache;      \
  __opt_as __lhs``__lhs_sep``prot   = __rhs``__rhs_sep``prot;       \
  __opt_as __lhs``__lhs_sep``qos    = __rhs``__rhs_sep``qos;        \
  __opt_as __lhs``__lhs_sep``region = __rhs``__rhs_sep``region;     \
  __opt_as __lhs``__lhs_sep``atop   = __rhs``__rhs_sep``atop;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_W(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``data   = __rhs``__rhs_sep``data;       \
  __opt_as __lhs``__lhs_sep``strb   = __rhs``__rhs_sep``strb;       \
  __opt_as __lhs``__lhs_sep``last   = __rhs``__rhs_sep``last;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_B(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``resp   = __rhs``__rhs_sep``resp;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_AR(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)   \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``addr   = __rhs``__rhs_sep``addr;       \
  __opt_as __lhs``__lhs_sep``len    = __rhs``__rhs_sep``len;        \
  __opt_as __lhs``__lhs_sep``size   = __rhs``__rhs_sep``size;       \
  __opt_as __lhs``__lhs_sep``burst  = __rhs``__rhs_sep``burst;      \
  __opt_as __lhs``__lhs_sep``lock   = __rhs``__rhs_sep``lock;       \
  __opt_as __lhs``__lhs_sep``cache  = __rhs``__rhs_sep``cache;      \
  __opt_as __lhs``__lhs_sep``prot   = __rhs``__rhs_sep``prot;       \
  __opt_as __lhs``__lhs_sep``qos    = __rhs``__rhs_sep``qos;        \
  __opt_as __lhs``__lhs_sep``region = __rhs``__rhs_sep``region;     \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_R(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``data   = __rhs``__rhs_sep``data;       \
  __opt_as __lhs``__lhs_sep``resp   = __rhs``__rhs_sep``resp;       \
  __opt_as __lhs``__lhs_sep``last   = __rhs``__rhs_sep``last;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_REQ(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)  \
  `__AXI_TO_AW(__opt_as, __lhs.aw, __lhs_sep, __rhs.aw, __rhs_sep)  \
  __opt_as __lhs.aw_valid = __rhs.aw_valid;                         \
  `__AXI_TO_W(__opt_as, __lhs.w, __lhs_sep, __rhs.w, __rhs_sep)     \
  __opt_as __lhs.w_valid = __rhs.w_valid;                           \
  __opt_as __lhs.b_ready = __rhs.b_ready;                           \
  `__AXI_TO_AR(__opt_as, __lhs.ar, __lhs_sep, __rhs.ar, __rhs_sep)  \
  __opt_as __lhs.ar_valid = __rhs.ar_valid;                         \
  __opt_as __lhs.r_ready = __rhs.r_ready;
`define __AXI_TO_RESP(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs.aw_ready = __rhs.aw_ready;                         \
  __opt_as __lhs.ar_ready = __rhs.ar_ready;                         \
  __opt_as __lhs.w_ready = __rhs.w_ready;                           \
  __opt_as __lhs.b_valid = __rhs.b_valid;                           \
  `__AXI_TO_B(__opt_as, __lhs.b, __lhs_sep, __rhs.b, __rhs_sep)     \
  __opt_as __lhs.r_valid = __rhs.r_valid;                           \
  `__AXI_TO_R(__opt_as, __lhs.r, __lhs_sep, __rhs.r, __rhs_sep)
`define AXI_ASSIGN_AW(dst, src)               \
  `__AXI_TO_AW(assign, dst.aw, _, src.aw, _)  \
  assign dst.aw_valid = src.aw_valid;         \
  assign src.aw_ready = dst.aw_ready;
`define AXI_ASSIGN_W(dst, src)                \
  `__AXI_TO_W(assign, dst.w, _, src.w, _)     \
  assign dst.w_valid  = src.w_valid;          \
  assign src.w_ready  = dst.w_ready;
`define AXI_ASSIGN_B(dst, src)                \
  `__AXI_TO_B(assign, dst.b, _, src.b, _)     \
  assign dst.b_valid  = src.b_valid;          \
  assign src.b_ready  = dst.b_ready;
`define AXI_ASSIGN_AR(dst, src)               \
  `__AXI_TO_AR(assign, dst.ar, _, src.ar, _)  \
  assign dst.ar_valid = src.ar_valid;         \
  assign src.ar_ready = dst.ar_ready;
`define AXI_ASSIGN_R(dst, src)                \
  `__AXI_TO_R(assign, dst.r, _, src.r, _)     \
  assign dst.r_valid  = src.r_valid;          \
  assign src.r_ready  = dst.r_ready;
`define AXI_ASSIGN(slv, mst)  \
  `AXI_ASSIGN_AW(slv, mst)    \
  `AXI_ASSIGN_W(slv, mst)     \
  `AXI_ASSIGN_B(mst, slv)     \
  `AXI_ASSIGN_AR(slv, mst)    \
  `AXI_ASSIGN_R(mst, slv)
`define AXI_ASSIGN_MONITOR(mon_dv, axi_if)          \
  `__AXI_TO_AW(assign, mon_dv.aw, _, axi_if.aw, _)  \
  assign mon_dv.aw_valid  = axi_if.aw_valid;        \
  assign mon_dv.aw_ready  = axi_if.aw_ready;        \
  `__AXI_TO_W(assign, mon_dv.w, _, axi_if.w, _)     \
  assign mon_dv.w_valid   = axi_if.w_valid;         \
  assign mon_dv.w_ready   = axi_if.w_ready;         \
  `__AXI_TO_B(assign, mon_dv.b, _, axi_if.b, _)     \
  assign mon_dv.b_valid   = axi_if.b_valid;         \
  assign mon_dv.b_ready   = axi_if.b_ready;         \
  `__AXI_TO_AR(assign, mon_dv.ar, _, axi_if.ar, _)  \
  assign mon_dv.ar_valid  = axi_if.ar_valid;        \
  assign mon_dv.ar_ready  = axi_if.ar_ready;        \
  `__AXI_TO_R(assign, mon_dv.r, _, axi_if.r, _)     \
  assign mon_dv.r_valid   = axi_if.r_valid;         \
  assign mon_dv.r_ready   = axi_if.r_ready;
`define AXI_SET_FROM_AW(axi_if, aw_struct)      `__AXI_TO_AW(, axi_if.aw, _, aw_struct, .)
`define AXI_SET_FROM_W(axi_if, w_struct)        `__AXI_TO_W(, axi_if.w, _, w_struct, .)
`define AXI_SET_FROM_B(axi_if, b_struct)        `__AXI_TO_B(, axi_if.b, _, b_struct, .)
`define AXI_SET_FROM_AR(axi_if, ar_struct)      `__AXI_TO_AR(, axi_if.ar, _, ar_struct, .)
`define AXI_SET_FROM_R(axi_if, r_struct)        `__AXI_TO_R(, axi_if.r, _, r_struct, .)
`define AXI_SET_FROM_REQ(axi_if, req_struct)    `__AXI_TO_REQ(, axi_if, _, req_struct, .)
`define AXI_SET_FROM_RESP(axi_if, resp_struct)  `__AXI_TO_RESP(, axi_if, _, resp_struct, .)
`define AXI_ASSIGN_FROM_AW(axi_if, aw_struct)     `__AXI_TO_AW(assign, axi_if.aw, _, aw_struct, .)
`define AXI_ASSIGN_FROM_W(axi_if, w_struct)       `__AXI_TO_W(assign, axi_if.w, _, w_struct, .)
`define AXI_ASSIGN_FROM_B(axi_if, b_struct)       `__AXI_TO_B(assign, axi_if.b, _, b_struct, .)
`define AXI_ASSIGN_FROM_AR(axi_if, ar_struct)     `__AXI_TO_AR(assign, axi_if.ar, _, ar_struct, .)
`define AXI_ASSIGN_FROM_R(axi_if, r_struct)       `__AXI_TO_R(assign, axi_if.r, _, r_struct, .)
`define AXI_ASSIGN_FROM_REQ(axi_if, req_struct)   `__AXI_TO_REQ(assign, axi_if, _, req_struct, .)
`define AXI_ASSIGN_FROM_RESP(axi_if, resp_struct) `__AXI_TO_RESP(assign, axi_if, _, resp_struct, .)
`define AXI_SET_TO_AW(aw_struct, axi_if)     `__AXI_TO_AW(, aw_struct, ., axi_if.aw, _)
`define AXI_SET_TO_W(w_struct, axi_if)       `__AXI_TO_W(, w_struct, ., axi_if.w, _)
`define AXI_SET_TO_B(b_struct, axi_if)       `__AXI_TO_B(, b_struct, ., axi_if.b, _)
`define AXI_SET_TO_AR(ar_struct, axi_if)     `__AXI_TO_AR(, ar_struct, ., axi_if.ar, _)
`define AXI_SET_TO_R(r_struct, axi_if)       `__AXI_TO_R(, r_struct, ., axi_if.r, _)
`define AXI_SET_TO_REQ(req_struct, axi_if)   `__AXI_TO_REQ(, req_struct, ., axi_if, _)
`define AXI_SET_TO_RESP(resp_struct, axi_if) `__AXI_TO_RESP(, resp_struct, ., axi_if, _)
`define AXI_ASSIGN_TO_AW(aw_struct, axi_if)     `__AXI_TO_AW(assign, aw_struct, ., axi_if.aw, _)
`define AXI_ASSIGN_TO_W(w_struct, axi_if)       `__AXI_TO_W(assign, w_struct, ., axi_if.w, _)
`define AXI_ASSIGN_TO_B(b_struct, axi_if)       `__AXI_TO_B(assign, b_struct, ., axi_if.b, _)
`define AXI_ASSIGN_TO_AR(ar_struct, axi_if)     `__AXI_TO_AR(assign, ar_struct, ., axi_if.ar, _)
`define AXI_ASSIGN_TO_R(r_struct, axi_if)       `__AXI_TO_R(assign, r_struct, ., axi_if.r, _)
`define AXI_ASSIGN_TO_REQ(req_struct, axi_if)   `__AXI_TO_REQ(assign, req_struct, ., axi_if, _)
`define AXI_ASSIGN_TO_RESP(resp_struct, axi_if) `__AXI_TO_RESP(assign, resp_struct, ., axi_if, _)
`define AXI_SET_AW_STRUCT(lhs, rhs)     `__AXI_TO_AW(, lhs, ., rhs, .)
`define AXI_SET_W_STRUCT(lhs, rhs)       `__AXI_TO_W(, lhs, ., rhs, .)
`define AXI_SET_B_STRUCT(lhs, rhs)       `__AXI_TO_B(, lhs, ., rhs, .)
`define AXI_SET_AR_STRUCT(lhs, rhs)     `__AXI_TO_AR(, lhs, ., rhs, .)
`define AXI_SET_R_STRUCT(lhs, rhs)       `__AXI_TO_R(, lhs, ., rhs, .)
`define AXI_SET_REQ_STRUCT(lhs, rhs)   `__AXI_TO_REQ(, lhs, ., rhs, .)
`define AXI_SET_RESP_STRUCT(lhs, rhs) `__AXI_TO_RESP(, lhs, ., rhs, .)
`define AXI_ASSIGN_AW_STRUCT(lhs, rhs)     `__AXI_TO_AW(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_W_STRUCT(lhs, rhs)       `__AXI_TO_W(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_B_STRUCT(lhs, rhs)       `__AXI_TO_B(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_AR_STRUCT(lhs, rhs)     `__AXI_TO_AR(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_R_STRUCT(lhs, rhs)       `__AXI_TO_R(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_REQ_STRUCT(lhs, rhs)   `__AXI_TO_REQ(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_RESP_STRUCT(lhs, rhs) `__AXI_TO_RESP(assign, lhs, ., rhs, .)
`define __AXI_LITE_TO_AX(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)  \
  __opt_as __lhs``__lhs_sep``addr = __rhs``__rhs_sep``addr;             \
  __opt_as __lhs``__lhs_sep``prot = __rhs``__rhs_sep``prot;
`define __AXI_LITE_TO_W(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``data = __rhs``__rhs_sep``data;           \
  __opt_as __lhs``__lhs_sep``strb = __rhs``__rhs_sep``strb;
`define __AXI_LITE_TO_B(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``resp = __rhs``__rhs_sep``resp;
`define __AXI_LITE_TO_R(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``data = __rhs``__rhs_sep``data;           \
  __opt_as __lhs``__lhs_sep``resp = __rhs``__rhs_sep``resp;
`define __AXI_LITE_TO_REQ(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  `__AXI_LITE_TO_AX(__opt_as, __lhs.aw, __lhs_sep, __rhs.aw, __rhs_sep) \
  __opt_as __lhs.aw_valid = __rhs.aw_valid;                             \
  `__AXI_LITE_TO_W(__opt_as, __lhs.w, __lhs_sep, __rhs.w, __rhs_sep)    \
  __opt_as __lhs.w_valid = __rhs.w_valid;                               \
  __opt_as __lhs.b_ready = __rhs.b_ready;                               \
  `__AXI_LITE_TO_AX(__opt_as, __lhs.ar, __lhs_sep, __rhs.ar, __rhs_sep) \
  __opt_as __lhs.ar_valid = __rhs.ar_valid;                             \
  __opt_as __lhs.r_ready = __rhs.r_ready;
`define __AXI_LITE_TO_RESP(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)  \
  __opt_as __lhs.aw_ready = __rhs.aw_ready;                               \
  __opt_as __lhs.ar_ready = __rhs.ar_ready;                               \
  __opt_as __lhs.w_ready = __rhs.w_ready;                                 \
  __opt_as __lhs.b_valid = __rhs.b_valid;                                 \
  `__AXI_LITE_TO_B(__opt_as, __lhs.b, __lhs_sep, __rhs.b, __rhs_sep)      \
  __opt_as __lhs.r_valid = __rhs.r_valid;                                 \
  `__AXI_LITE_TO_R(__opt_as, __lhs.r, __lhs_sep, __rhs.r, __rhs_sep)
`define AXI_LITE_ASSIGN_AW(dst, src)              \
  `__AXI_LITE_TO_AX(assign, dst.aw, _, src.aw, _) \
  assign dst.aw_valid = src.aw_valid;             \
  assign src.aw_ready = dst.aw_ready;
`define AXI_LITE_ASSIGN_W(dst, src)             \
  `__AXI_LITE_TO_W(assign, dst.w, _, src.w, _)  \
  assign dst.w_valid  = src.w_valid;            \
  assign src.w_ready  = dst.w_ready;
`define AXI_LITE_ASSIGN_B(dst, src)             \
  `__AXI_LITE_TO_B(assign, dst.b, _, src.b, _)  \
  assign dst.b_valid  = src.b_valid;            \
  assign src.b_ready  = dst.b_ready;
`define AXI_LITE_ASSIGN_AR(dst, src)              \
  `__AXI_LITE_TO_AX(assign, dst.ar, _, src.ar, _) \
  assign dst.ar_valid = src.ar_valid;             \
  assign src.ar_ready = dst.ar_ready;
`define AXI_LITE_ASSIGN_R(dst, src)             \
  `__AXI_LITE_TO_R(assign, dst.r, _, src.r, _)  \
  assign dst.r_valid  = src.r_valid;            \
  assign src.r_ready  = dst.r_ready;
`define AXI_LITE_ASSIGN(slv, mst) \
  `AXI_LITE_ASSIGN_AW(slv, mst)   \
  `AXI_LITE_ASSIGN_W(slv, mst)    \
  `AXI_LITE_ASSIGN_B(mst, slv)    \
  `AXI_LITE_ASSIGN_AR(slv, mst)   \
  `AXI_LITE_ASSIGN_R(mst, slv)
`define AXI_LITE_SET_FROM_AW(axi_if, aw_struct)      `__AXI_LITE_TO_AX(, axi_if.aw, _, aw_struct, .)
`define AXI_LITE_SET_FROM_W(axi_if, w_struct)        `__AXI_LITE_TO_W(, axi_if.w, _, w_struct, .)
`define AXI_LITE_SET_FROM_B(axi_if, b_struct)        `__AXI_LITE_TO_B(, axi_if.b, _, b_struct, .)
`define AXI_LITE_SET_FROM_AR(axi_if, ar_struct)      `__AXI_LITE_TO_AX(, axi_if.ar, _, ar_struct, .)
`define AXI_LITE_SET_FROM_R(axi_if, r_struct)        `__AXI_LITE_TO_R(, axi_if.r, _, r_struct, .)
`define AXI_LITE_SET_FROM_REQ(axi_if, req_struct)    `__AXI_LITE_TO_REQ(, axi_if, _, req_struct, .)
`define AXI_LITE_SET_FROM_RESP(axi_if, resp_struct)  `__AXI_LITE_TO_RESP(, axi_if, _, resp_struct, .)
`define AXI_LITE_ASSIGN_FROM_AW(axi_if, aw_struct)     `__AXI_LITE_TO_AX(assign, axi_if.aw, _, aw_struct, .)
`define AXI_LITE_ASSIGN_FROM_W(axi_if, w_struct)       `__AXI_LITE_TO_W(assign, axi_if.w, _, w_struct, .)
`define AXI_LITE_ASSIGN_FROM_B(axi_if, b_struct)       `__AXI_LITE_TO_B(assign, axi_if.b, _, b_struct, .)
`define AXI_LITE_ASSIGN_FROM_AR(axi_if, ar_struct)     `__AXI_LITE_TO_AX(assign, axi_if.ar, _, ar_struct, .)
`define AXI_LITE_ASSIGN_FROM_R(axi_if, r_struct)       `__AXI_LITE_TO_R(assign, axi_if.r, _, r_struct, .)
`define AXI_LITE_ASSIGN_FROM_REQ(axi_if, req_struct)   `__AXI_LITE_TO_REQ(assign, axi_if, _, req_struct, .)
`define AXI_LITE_ASSIGN_FROM_RESP(axi_if, resp_struct) `__AXI_LITE_TO_RESP(assign, axi_if, _, resp_struct, .)
`define AXI_LITE_SET_TO_AW(aw_struct, axi_if)     `__AXI_LITE_TO_AX(, aw_struct, ., axi_if.aw, _)
`define AXI_LITE_SET_TO_W(w_struct, axi_if)       `__AXI_LITE_TO_W(, w_struct, ., axi_if.w, _)
`define AXI_LITE_SET_TO_B(b_struct, axi_if)       `__AXI_LITE_TO_B(, b_struct, ., axi_if.b, _)
`define AXI_LITE_SET_TO_AR(ar_struct, axi_if)     `__AXI_LITE_TO_AX(, ar_struct, ., axi_if.ar, _)
`define AXI_LITE_SET_TO_R(r_struct, axi_if)       `__AXI_LITE_TO_R(, r_struct, ., axi_if.r, _)
`define AXI_LITE_SET_TO_REQ(req_struct, axi_if)   `__AXI_LITE_TO_REQ(, req_struct, ., axi_if, _)
`define AXI_LITE_SET_TO_RESP(resp_struct, axi_if) `__AXI_LITE_TO_RESP(, resp_struct, ., axi_if, _)
`define AXI_LITE_ASSIGN_TO_AW(aw_struct, axi_if)     `__AXI_LITE_TO_AX(assign, aw_struct, ., axi_if.aw, _)
`define AXI_LITE_ASSIGN_TO_W(w_struct, axi_if)       `__AXI_LITE_TO_W(assign, w_struct, ., axi_if.w, _)
`define AXI_LITE_ASSIGN_TO_B(b_struct, axi_if)       `__AXI_LITE_TO_B(assign, b_struct, ., axi_if.b, _)
`define AXI_LITE_ASSIGN_TO_AR(ar_struct, axi_if)     `__AXI_LITE_TO_AX(assign, ar_struct, ., axi_if.ar, _)
`define AXI_LITE_ASSIGN_TO_R(r_struct, axi_if)       `__AXI_LITE_TO_R(assign, r_struct, ., axi_if.r, _)
`define AXI_LITE_ASSIGN_TO_REQ(req_struct, axi_if)   `__AXI_LITE_TO_REQ(assign, req_struct, ., axi_if, _)
`define AXI_LITE_ASSIGN_TO_RESP(resp_struct, axi_if) `__AXI_LITE_TO_RESP(assign, resp_struct, ., axi_if, _)
`define AXI_LITE_SET_AW_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(, lhs, ., rhs, .)
`define AXI_LITE_SET_W_STRUCT(lhs, rhs)       `__AXI_LITE_TO_W(, lhs, ., rhs, .)
`define AXI_LITE_SET_B_STRUCT(lhs, rhs)       `__AXI_LITE_TO_B(, lhs, ., rhs, .)
`define AXI_LITE_SET_AR_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(, lhs, ., rhs, .)
`define AXI_LITE_SET_R_STRUCT(lhs, rhs)       `__AXI_LITE_TO_R(, lhs, ., rhs, .)
`define AXI_LITE_SET_REQ_STRUCT(lhs, rhs)   `__AXI_LITE_TO_REQ(, lhs, ., rhs, .)
`define AXI_LITE_SET_RESP_STRUCT(lhs, rhs) `__AXI_LITE_TO_RESP(, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_AW_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_W_STRUCT(lhs, rhs)       `__AXI_LITE_TO_W(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_B_STRUCT(lhs, rhs)       `__AXI_LITE_TO_B(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_AR_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_R_STRUCT(lhs, rhs)       `__AXI_LITE_TO_R(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_REQ_STRUCT(lhs, rhs)   `__AXI_LITE_TO_REQ(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_RESP_STRUCT(lhs, rhs) `__AXI_LITE_TO_RESP(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_MASTER_TO_FLAT(pat, req, rsp) \
  assign m_axi_``pat``_awvalid  = req.aw_valid;  \
  assign m_axi_``pat``_awid     = req.aw.id;     \
  assign m_axi_``pat``_awaddr   = req.aw.addr;   \
  assign m_axi_``pat``_awlen    = req.aw.len;    \
  assign m_axi_``pat``_awsize   = req.aw.size;   \
  assign m_axi_``pat``_awburst  = req.aw.burst;  \
  assign m_axi_``pat``_awlock   = req.aw.lock;   \
  assign m_axi_``pat``_awcache  = req.aw.cache;  \
  assign m_axi_``pat``_awprot   = req.aw.prot;   \
  assign m_axi_``pat``_awqos    = req.aw.qos;    \
  assign m_axi_``pat``_awregion = req.aw.region; \
  assign m_axi_``pat``_awuser   = req.aw.user;   \
                                                 \
  assign m_axi_``pat``_wvalid   = req.w_valid;   \
  assign m_axi_``pat``_wdata    = req.w.data;    \
  assign m_axi_``pat``_wstrb    = req.w.strb;    \
  assign m_axi_``pat``_wlast    = req.w.last;    \
  assign m_axi_``pat``_wuser    = req.w.user;    \
                                                 \
  assign m_axi_``pat``_bready   = req.b_ready;   \
                                                 \
  assign m_axi_``pat``_arvalid  = req.ar_valid;  \
  assign m_axi_``pat``_arid     = req.ar.id;     \
  assign m_axi_``pat``_araddr   = req.ar.addr;   \
  assign m_axi_``pat``_arlen    = req.ar.len;    \
  assign m_axi_``pat``_arsize   = req.ar.size;   \
  assign m_axi_``pat``_arburst  = req.ar.burst;  \
  assign m_axi_``pat``_arlock   = req.ar.lock;   \
  assign m_axi_``pat``_arcache  = req.ar.cache;  \
  assign m_axi_``pat``_arprot   = req.ar.prot;   \
  assign m_axi_``pat``_arqos    = req.ar.qos;    \
  assign m_axi_``pat``_arregion = req.ar.region; \
  assign m_axi_``pat``_aruser   = req.ar.user;   \
                                                 \
  assign m_axi_``pat``_rready   = req.r_ready;   \
                                                 \
  assign rsp.aw_ready = m_axi_``pat``_awready;   \
  assign rsp.ar_ready = m_axi_``pat``_arready;   \
  assign rsp.w_ready  = m_axi_``pat``_wready;    \
                                                 \
  assign rsp.b_valid  = m_axi_``pat``_bvalid;    \
  assign rsp.b.id     = m_axi_``pat``_bid;       \
  assign rsp.b.resp   = m_axi_``pat``_bresp;     \
  assign rsp.b.user   = m_axi_``pat``_buser;     \
                                                 \
  assign rsp.r_valid  = m_axi_``pat``_rvalid;    \
  assign rsp.r.id     = m_axi_``pat``_rid;       \
  assign rsp.r.data   = m_axi_``pat``_rdata;     \
  assign rsp.r.resp   = m_axi_``pat``_rresp;     \
  assign rsp.r.last   = m_axi_``pat``_rlast;     \
  assign rsp.r.user   = m_axi_``pat``_ruser;
`define AXI_ASSIGN_SLAVE_TO_FLAT(pat, req, rsp)  \
  assign req.aw_valid  = s_axi_``pat``_awvalid;  \
  assign req.aw.id     = s_axi_``pat``_awid;     \
  assign req.aw.addr   = s_axi_``pat``_awaddr;   \
  assign req.aw.len    = s_axi_``pat``_awlen;    \
  assign req.aw.size   = s_axi_``pat``_awsize;   \
  assign req.aw.burst  = s_axi_``pat``_awburst;  \
  assign req.aw.lock   = s_axi_``pat``_awlock;   \
  assign req.aw.cache  = s_axi_``pat``_awcache;  \
  assign req.aw.prot   = s_axi_``pat``_awprot;   \
  assign req.aw.qos    = s_axi_``pat``_awqos;    \
  assign req.aw.region = s_axi_``pat``_awregion; \
  assign req.aw.user   = s_axi_``pat``_awuser;   \
                                                 \
  assign req.w_valid   = s_axi_``pat``_wvalid;   \
  assign req.w.data    = s_axi_``pat``_wdata;    \
  assign req.w.strb    = s_axi_``pat``_wstrb;    \
  assign req.w.last    = s_axi_``pat``_wlast;    \
  assign req.w.user    = s_axi_``pat``_wuser;    \
                                                 \
  assign req.b_ready   = s_axi_``pat``_bready;   \
                                                 \
  assign req.ar_valid  = s_axi_``pat``_arvalid;  \
  assign req.ar.id     = s_axi_``pat``_arid;     \
  assign req.ar.addr   = s_axi_``pat``_araddr;   \
  assign req.ar.len    = s_axi_``pat``_arlen;    \
  assign req.ar.size   = s_axi_``pat``_arsize;   \
  assign req.ar.burst  = s_axi_``pat``_arburst;  \
  assign req.ar.lock   = s_axi_``pat``_arlock;   \
  assign req.ar.cache  = s_axi_``pat``_arcache;  \
  assign req.ar.prot   = s_axi_``pat``_arprot;   \
  assign req.ar.qos    = s_axi_``pat``_arqos;    \
  assign req.ar.region = s_axi_``pat``_arregion; \
  assign req.ar.user   = s_axi_``pat``_aruser;   \
                                                 \
  assign req.r_ready   = s_axi_``pat``_rready;   \
                                                 \
  assign s_axi_``pat``_awready = rsp.aw_ready;   \
  assign s_axi_``pat``_arready = rsp.ar_ready;   \
  assign s_axi_``pat``_wready  = rsp.w_ready;    \
                                                 \
  assign s_axi_``pat``_bvalid  = rsp.b_valid;    \
  assign s_axi_``pat``_bid     = rsp.b.id;       \
  assign s_axi_``pat``_bresp   = rsp.b.resp;     \
  assign s_axi_``pat``_buser   = rsp.b.user;     \
                                                 \
  assign s_axi_``pat``_rvalid  = rsp.r_valid;    \
  assign s_axi_``pat``_rid     = rsp.r.id;       \
  assign s_axi_``pat``_rdata   = rsp.r.data;     \
  assign s_axi_``pat``_rresp   = rsp.r.resp;     \
  assign s_axi_``pat``_rlast   = rsp.r.last;     \
  assign s_axi_``pat``_ruser   = rsp.r.user;
`define AXI_ASSIGN_TO_FLAT_PORT(pat, req, rsp)  \
  .``pat``_awvalid  ( req.aw_valid  ), \
  .``pat``_awid     ( req.aw.id     ), \
  .``pat``_awaddr   ( req.aw.addr   ), \
  .``pat``_awlen    ( req.aw.len    ), \
  .``pat``_awsize   ( req.aw.size   ), \
  .``pat``_awburst  ( req.aw.burst  ), \
  .``pat``_awlock   ( req.aw.lock   ), \
  .``pat``_awcache  ( req.aw.cache  ), \
  .``pat``_awprot   ( req.aw.prot   ), \
  .``pat``_awqos    ( req.aw.qos    ), \
  .``pat``_awregion ( req.aw.region ), \
  .``pat``_awuser   ( req.aw.user   ), \
                                       \
  .``pat``_wvalid   ( req.w_valid   ), \
  .``pat``_wdata    ( req.w.data    ), \
  .``pat``_wstrb    ( req.w.strb    ), \
  .``pat``_wlast    ( req.w.last    ), \
  .``pat``_wuser    ( req.w.user    ), \
                                       \
  .``pat``_bready   ( req.b_ready   ), \
                                       \
  .``pat``_arvalid  ( req.ar_valid  ), \
  .``pat``_arid     ( req.ar.id     ), \
  .``pat``_araddr   ( req.ar.addr   ), \
  .``pat``_arlen    ( req.ar.len    ), \
  .``pat``_arsize   ( req.ar.size   ), \
  .``pat``_arburst  ( req.ar.burst  ), \
  .``pat``_arlock   ( req.ar.lock   ), \
  .``pat``_arcache  ( req.ar.cache  ), \
  .``pat``_arprot   ( req.ar.prot   ), \
  .``pat``_arqos    ( req.ar.qos    ), \
  .``pat``_arregion ( req.ar.region ), \
  .``pat``_aruser   ( req.ar.user   ), \
                                       \
  .``pat``_rready   ( req.r_ready   ), \
                                       \
  .``pat``_awready  ( rsp.aw_ready  ), \
  .``pat``_arready  ( rsp.ar_ready  ), \
  .``pat``_wready   ( rsp.w_ready   ), \
                                       \
  .``pat``_bvalid   ( rsp.b_valid   ), \
  .``pat``_bid      ( rsp.b.id      ), \
  .``pat``_bresp    ( rsp.b.resp    ), \
  .``pat``_buser    ( rsp.b.user    ), \
                                       \
  .``pat``_rvalid   ( rsp.r_valid   ), \
  .``pat``_rid      ( rsp.r.id      ), \
  .``pat``_rdata    ( rsp.r.data    ), \
  .``pat``_rresp    ( rsp.r.resp    ), \
  .``pat``_rlast    ( rsp.r.last    ), \
  .``pat``_ruser    ( rsp.r.user    )
`define AXI_ASSIGN_MASTER_TO_FLAT_PORT(name, req, rsp) \
  `AXI_ASSIGN_TO_FLAT_PORT(m_axi_``name``, req, rsp)
`define AXI_ASSIGN_SLAVE_TO_FLAT_PORT(name, req, rsp) \
  `AXI_ASSIGN_TO_FLAT_PORT(s_axi_``name``, req, rsp)
`define AXI_HIGHLIGHT(__name, __aw_t, __w_t, __b_t, __ar_t, __r_t, __req, __resp) \
  signal_highlighter #(                                                           \
    .T ( __aw_t )                                                                 \
  ) i_signal_highlighter_``__name``_aw (                                          \
    .ready_i ( __resp.aw_ready ),                                                 \
    .valid_i ( __req.aw_valid  ),                                                 \
    .data_i  ( __req.aw        )                                                  \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __w_t )                                                                  \
  ) i_signal_highlighter_``__name``_w (                                           \
    .ready_i ( __resp.w_ready ),                                                  \
    .valid_i ( __req.w_valid  ),                                                  \
    .data_i  ( __req.w        )                                                   \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __b_t )                                                                  \
  ) i_signal_highlighter_``__name``_b (                                           \
    .ready_i ( __req.b_ready  ),                                                  \
    .valid_i ( __resp.b_valid ),                                                  \
    .data_i  ( __resp.b       )                                                   \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __ar_t )                                                                 \
  ) i_signal_highlighter_``__name``_ar (                                          \
    .ready_i ( __resp.ar_ready ),                                                 \
    .valid_i ( __req.ar_valid  ),                                                 \
    .data_i  ( __req.ar        )                                                  \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __r_t )                                                                  \
  ) i_signal_highlighter_``__name``_r (                                           \
    .ready_i ( __req.r_ready  ),                                                  \
    .valid_i ( __resp.r_valid ),                                                  \
    .data_i  ( __resp.r       )                                                   \
  );
`endif
`ifndef AXI_TYPEDEF_SVH_
`define AXI_TYPEDEF_SVH_
`define AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)  \
  typedef struct packed {                                       \
    id_t              id;                                       \
    addr_t            addr;                                     \
    axi_pkg::len_t    len;                                      \
    axi_pkg::size_t   size;                                     \
    axi_pkg::burst_t  burst;                                    \
    logic             lock;                                     \
    axi_pkg::cache_t  cache;                                    \
    axi_pkg::prot_t   prot;                                     \
    axi_pkg::qos_t    qos;                                      \
    axi_pkg::region_t region;                                   \
    axi_pkg::atop_t   atop;                                     \
    user_t            user;                                     \
  } aw_chan_t;
`define AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)  \
  typedef struct packed {                                       \
    data_t data;                                                \
    strb_t strb;                                                \
    logic  last;                                                \
    user_t user;                                                \
  } w_chan_t;
`define AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)  \
  typedef struct packed {                             \
    id_t            id;                               \
    axi_pkg::resp_t resp;                             \
    user_t          user;                             \
  } b_chan_t;
`define AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)  \
  typedef struct packed {                                       \
    id_t              id;                                       \
    addr_t            addr;                                     \
    axi_pkg::len_t    len;                                      \
    axi_pkg::size_t   size;                                     \
    axi_pkg::burst_t  burst;                                    \
    logic             lock;                                     \
    axi_pkg::cache_t  cache;                                    \
    axi_pkg::prot_t   prot;                                     \
    axi_pkg::qos_t    qos;                                      \
    axi_pkg::region_t region;                                   \
    user_t            user;                                     \
  } ar_chan_t;
`define AXI_TYPEDEF_R_CHAN_T(r_chan_t, data_t, id_t, user_t)  \
  typedef struct packed {                                     \
    id_t            id;                                       \
    data_t          data;                                     \
    axi_pkg::resp_t resp;                                     \
    logic           last;                                     \
    user_t          user;                                     \
  } r_chan_t;
`define AXI_TYPEDEF_REQ_T(req_t, aw_chan_t, w_chan_t, ar_chan_t)  \
  typedef struct packed {                                         \
    aw_chan_t aw;                                                 \
    logic     aw_valid;                                           \
    w_chan_t  w;                                                  \
    logic     w_valid;                                            \
    logic     b_ready;                                            \
    ar_chan_t ar;                                                 \
    logic     ar_valid;                                           \
    logic     r_ready;                                            \
  } req_t;
`define AXI_TYPEDEF_RESP_T(resp_t, b_chan_t, r_chan_t)  \
  typedef struct packed {                               \
    logic     aw_ready;                                 \
    logic     ar_ready;                                 \
    logic     w_ready;                                  \
    logic     b_valid;                                  \
    b_chan_t  b;                                        \
    logic     r_valid;                                  \
    r_chan_t  r;                                        \
  } resp_t;
`define AXI_TYPEDEF_ALL_CT(__name, __req, __rsp, __addr_t, __id_t, __data_t, __strb_t, __user_t) \
  `AXI_TYPEDEF_AW_CHAN_T(__name``_aw_chan_t, __addr_t, __id_t, __user_t)                         \
  `AXI_TYPEDEF_W_CHAN_T(__name``_w_chan_t, __data_t, __strb_t, __user_t)                         \
  `AXI_TYPEDEF_B_CHAN_T(__name``_b_chan_t, __id_t, __user_t)                                     \
  `AXI_TYPEDEF_AR_CHAN_T(__name``_ar_chan_t, __addr_t, __id_t, __user_t)                         \
  `AXI_TYPEDEF_R_CHAN_T(__name``_r_chan_t, __data_t, __id_t, __user_t)                           \
  `AXI_TYPEDEF_REQ_T(__req, __name``_aw_chan_t, __name``_w_chan_t, __name``_ar_chan_t)           \
  `AXI_TYPEDEF_RESP_T(__rsp, __name``_b_chan_t, __name``_r_chan_t)
`define AXI_TYPEDEF_ALL(__name, __addr_t, __id_t, __data_t, __strb_t, __user_t)                                \
  `AXI_TYPEDEF_ALL_CT(__name, __name``_req_t, __name``_resp_t, __addr_t, __id_t, __data_t, __strb_t, __user_t)
`define AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_lite_t, addr_t)  \
  typedef struct packed {                                   \
    addr_t          addr;                                   \
    axi_pkg::prot_t prot;                                   \
  } aw_chan_lite_t;
`define AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_lite_t, data_t, strb_t)  \
  typedef struct packed {                                         \
    data_t   data;                                                \
    strb_t   strb;                                                \
  } w_chan_lite_t;
`define AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_lite_t)  \
  typedef struct packed {                         \
    axi_pkg::resp_t resp;                         \
  } b_chan_lite_t;
`define AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_lite_t, addr_t)  \
  typedef struct packed {                                   \
    addr_t          addr;                                   \
    axi_pkg::prot_t prot;                                   \
  } ar_chan_lite_t;
`define AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_lite_t, data_t)  \
  typedef struct packed {                                 \
    data_t          data;                                 \
    axi_pkg::resp_t resp;                                 \
  } r_chan_lite_t;
`define AXI_LITE_TYPEDEF_REQ_T(req_lite_t, aw_chan_lite_t, w_chan_lite_t, ar_chan_lite_t)  \
  typedef struct packed {                                                                  \
    aw_chan_lite_t aw;                                                                     \
    logic          aw_valid;                                                               \
    w_chan_lite_t  w;                                                                      \
    logic          w_valid;                                                                \
    logic          b_ready;                                                                \
    ar_chan_lite_t ar;                                                                     \
    logic          ar_valid;                                                               \
    logic          r_ready;                                                                \
  } req_lite_t;
`define AXI_LITE_TYPEDEF_RESP_T(resp_lite_t, b_chan_lite_t, r_chan_lite_t)  \
  typedef struct packed {                                                   \
    logic          aw_ready;                                                \
    logic          w_ready;                                                 \
    b_chan_lite_t  b;                                                       \
    logic          b_valid;                                                 \
    logic          ar_ready;                                                \
    r_chan_lite_t  r;                                                       \
    logic          r_valid;                                                 \
  } resp_lite_t;
`define AXI_LITE_TYPEDEF_ALL_CT(__name, __req, __rsp, __addr_t, __data_t, __strb_t)         \
  `AXI_LITE_TYPEDEF_AW_CHAN_T(__name``_aw_chan_t, __addr_t)                                 \
  `AXI_LITE_TYPEDEF_W_CHAN_T(__name``_w_chan_t, __data_t, __strb_t)                         \
  `AXI_LITE_TYPEDEF_B_CHAN_T(__name``_b_chan_t)                                             \
  `AXI_LITE_TYPEDEF_AR_CHAN_T(__name``_ar_chan_t, __addr_t)                                 \
  `AXI_LITE_TYPEDEF_R_CHAN_T(__name``_r_chan_t, __data_t)                                   \
  `AXI_LITE_TYPEDEF_REQ_T(__req, __name``_aw_chan_t, __name``_w_chan_t, __name``_ar_chan_t) \
  `AXI_LITE_TYPEDEF_RESP_T(__rsp, __name``_b_chan_t, __name``_r_chan_t)
`define AXI_LITE_TYPEDEF_ALL(__name, __addr_t, __data_t, __strb_t)                                \
  `AXI_LITE_TYPEDEF_ALL_CT(__name, __name``_req_t, __name``_resp_t, __addr_t, __data_t, __strb_t)
`endif
module axi_lite_demux_intf #(
  parameter int unsigned AxiAddrWidth = 32'd0,
  parameter int unsigned AxiDataWidth = 32'd0,
  parameter int unsigned NoMstPorts   = 32'd0,
  parameter int unsigned MaxTrans     = 32'd0,
  parameter bit          FallThrough  = 1'b0,
  parameter bit          SpillAw      = 1'b1,
  parameter bit          SpillW       = 1'b0,
  parameter bit          SpillB       = 1'b0,
  parameter bit          SpillAr      = 1'b1,
  parameter bit          SpillR       = 1'b0,
  
  parameter type         select_t     = logic [$clog2(NoMstPorts)-1:0]
) (
  input  logic     clk_i,               
  input  logic     rst_ni,              
  input  logic     test_i,              
  input  select_t  slv_aw_select_i,     
  input  select_t  slv_ar_select_i,     
  AXI_LITE.Slave   slv,                 
  AXI_LITE.Master  mst [NoMstPorts-1:0] 
);
  typedef logic [AxiAddrWidth-1:0]   addr_t;
  typedef logic [AxiDataWidth-1:0]   data_t;
  typedef logic [AxiDataWidth/8-1:0] strb_t;
  `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t)
  `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t)
  `AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_t)
  `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t)
  `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_t, data_t)
  `AXI_LITE_TYPEDEF_REQ_T(axi_req_t, aw_chan_t, w_chan_t, ar_chan_t)
  `AXI_LITE_TYPEDEF_RESP_T(axi_resp_t, b_chan_t, r_chan_t)
  axi_req_t                   slv_req;
  axi_resp_t                  slv_resp;
  axi_req_t  [NoMstPorts-1:0] mst_reqs;
  axi_resp_t [NoMstPorts-1:0] mst_resps;
  `AXI_LITE_ASSIGN_TO_REQ(slv_req, slv)
  `AXI_LITE_ASSIGN_FROM_RESP(slv, slv_resp)
  for (genvar i = 0; i < NoMstPorts; i++) begin : gen_assign_mst_ports
    `AXI_LITE_ASSIGN_FROM_REQ(mst[i], mst_reqs[i])
    `AXI_LITE_ASSIGN_TO_RESP(mst_resps[i], mst[i])
  end
  axi_lite_demux #(
    .aw_chan_t   (  aw_chan_t  ),
    .w_chan_t    (   w_chan_t  ),
    .b_chan_t    (   b_chan_t  ),
    .ar_chan_t   (  ar_chan_t  ),
    .r_chan_t    (   r_chan_t  ),
    .axi_req_t   (  axi_req_t  ),
    .axi_resp_t  ( axi_resp_t  ),
    .NoMstPorts  ( NoMstPorts  ),
    .MaxTrans    ( MaxTrans    ),
    .FallThrough ( FallThrough ),
    .SpillAw     ( SpillAw     ),
    .SpillW      ( SpillW      ),
    .SpillB      ( SpillB      ),
    .SpillAr     ( SpillAr     ),
    .SpillR      ( SpillR      )
  ) i_axi_demux (
    .clk_i,
    .rst_ni,
    .test_i,
    
    .slv_req_i       ( slv_req         ),
    .slv_aw_select_i ( slv_aw_select_i ), 
    .slv_ar_select_i ( slv_ar_select_i ), 
    .slv_resp_o      ( slv_resp        ),
    
    .mst_reqs_o      ( mst_reqs        ),
    .mst_resps_i     ( mst_resps       )
  );
  
  `ifndef VERILATOR
    initial begin: p_assertions
      AddrWidth: assert (AxiAddrWidth > 0) else $fatal("Axi Parmeter has to be > 0!");
      DataWidth: assert (AxiDataWidth > 0) else $fatal("Axi Parmeter has to be > 0!");
    end
  `endif
  
endmodule

`ifndef COMMON_CELLS_REGISTERS_SVH_
`define COMMON_CELLS_REGISTERS_SVH_
`ifdef VERILATOR
`define NO_SYNOPSYS_FF 1`endif
`define REG_DFLT_CLK clk_i
`define REG_DFLT_RST rst_ni
`define FF(__q, __d, __reset_value, __clk = `REG_DFLT_CLK, __arst_n = `REG_DFLT_RST) \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin                           \
    if (!__arst_n) begin                                                             \
      __q <= (__reset_value);                                                        \
    end else begin                                                                   \
      __q <= (__d);                                                                  \
    end                                                                              \
  end
`define FFAR(__q, __d, __reset_value, __clk, __arst)     \
  always_ff @(posedge (__clk) or posedge (__arst)) begin \
    if (__arst) begin                                    \
      __q <= (__reset_value);                            \
    end else begin                                       \
      __q <= (__d);                                      \
    end                                                  \
  end
`define FFARN(__q, __d, __reset_value, __clk, __arst_n) \
  `FF(__q, __d, __reset_value, __clk, __arst_n)
`define FFSR(__q, __d, __reset_value, __clk, __reset_clk) \
  `ifndef NO_SYNOPSYS_FF                                  \
  /``* synopsys sync_set_reset `"__reset_clk`" *``/       \
  `endif                                                  \
  always_ff @(posedge (__clk)) begin                      \
    __q <= (__reset_clk) ? (__reset_value) : (__d);       \
  end
`define FFSRN(__q, __d, __reset_value, __clk, __reset_n_clk) \
  `ifndef NO_SYNOPSYS_FF                                     \
  /``* synopsys sync_set_reset `"__reset_n_clk`" *``/        \
  `endif                                                     \
  always_ff @(posedge (__clk)) begin                         \
    __q <= (!__reset_n_clk) ? (__reset_value) : (__d);       \
  end
`define FFNR(__q, __d, __clk)        \
  always_ff @(posedge (__clk)) begin \
    __q <= (__d);                    \
  end
`define FFL(__q, __d, __load, __reset_value, __clk = `REG_DFLT_CLK, __arst_n = `REG_DFLT_RST) \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin                                    \
    if (!__arst_n) begin                                                                      \
      __q <= (__reset_value);                                                                 \
    end else begin                                                                            \
      if (__load) begin                                                                       \
        __q <= (__d);                                                                         \
      end                                                                                     \
    end                                                                                       \
  end
`define FFLAR(__q, __d, __load, __reset_value, __clk, __arst) \
  always_ff @(posedge (__clk) or posedge (__arst)) begin      \
    if (__arst) begin                                         \
      __q <= (__reset_value);                                 \
    end else begin                                            \
      if (__load) begin                                       \
        __q <= (__d);                                         \
      end                                                     \
    end                                                       \
  end
`define FFLARN(__q, __d, __load, __reset_value, __clk, __arst_n) \
  `FFL(__q, __d, __load, __reset_value, __clk, __arst_n)
`define FFLSR(__q, __d, __load, __reset_value, __clk, __reset_clk) \
  `ifndef NO_SYNOPSYS_FF                                           \
  /``* synopsys sync_set_reset `"__reset_clk`" *``/                \
  `endif                                                           \
  always_ff @(posedge (__clk)) begin                               \
    if (__reset_clk) begin                                         \
      __q <= (__reset_value);                                      \
    end else if (__load) begin                                     \
      __q <= (__d);                                                \
    end                                                            \
  end
`define FFLSRN(__q, __d, __load, __reset_value, __clk, __reset_n_clk) \
  `ifndef NO_SYNOPSYS_FF                                              \
  /``* synopsys sync_set_reset `"__reset_n_clk`" *``/                 \
  `endif                                                              \
  always_ff @(posedge (__clk)) begin                                  \
    if (!__reset_n_clk) begin                                         \
      __q <= (__reset_value);                                         \
    end else if (__load) begin                                        \
      __q <= (__d);                                                   \
    end                                                               \
  end
`define FFLARNC(__q, __d, __load, __clear, __reset_value, __clk, __arst_n) \
    `ifndef NO_SYNOPSYS_FF                                                 \
  /``* synopsys sync_set_reset `"__clear`" *``/                            \
    `endif                                                                 \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin                 \
    if (!__arst_n) begin                                                   \
      __q <= (__reset_value);                                              \
    end else begin                                                         \
      if (__clear) begin                                                   \
        __q <= (__reset_value);                                            \
      end else if (__load) begin                                           \
        __q <= (__d);                                                      \
      end                                                                  \
    end                                                                    \
  end
`define FFARNC(__q, __d, __clear, __reset_value, __clk, __arst_n) \
    `ifndef NO_SYNOPSYS_FF                                        \
  /``* synopsys sync_set_reset `"__clear`" *``/                   \
    `endif                                                        \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin        \
    if (!__arst_n) begin                                          \
      __q <= (__reset_value);                                     \
    end else begin                                                \
      if (__clear) begin                                          \
        __q <= (__reset_value);                                   \
      end else begin                                              \
        __q <= (__d);                                             \
      end                                                         \
    end                                                           \
  end
`define FFLNR(__q, __d, __load, __clk) \
  always_ff @(posedge (__clk)) begin   \
    if (__load) begin                  \
      __q <= (__d);                    \
    end                                \
  end
`endif
module axi_lite_mux #(
  
  parameter type          aw_chan_t  = logic, 
  parameter type           w_chan_t  = logic, 
  parameter type           b_chan_t  = logic, 
  parameter type          ar_chan_t  = logic, 
  parameter type           r_chan_t  = logic, 
  parameter type          axi_req_t  = logic, 
  parameter type         axi_resp_t  = logic, 
  parameter int unsigned NoSlvPorts  = 32'd0, 
  
  parameter int unsigned MaxTrans    = 32'd0,
  
  parameter bit          FallThrough = 1'b0,
  
  parameter bit          SpillAw     = 1'b1,
  parameter bit          SpillW      = 1'b0,
  parameter bit          SpillB      = 1'b0,
  
  parameter bit          SpillAr     = 1'b1,
  parameter bit          SpillR      = 1'b0
) (
  input  logic                       clk_i,    
  input  logic                       rst_ni,   
  input  logic                       test_i,   
  
  input  axi_req_t  [NoSlvPorts-1:0] slv_reqs_i,
  output axi_resp_t [NoSlvPorts-1:0] slv_resps_o,
  
  output axi_req_t                   mst_req_o,
  input  axi_resp_t                  mst_resp_i
);
  
  if (NoSlvPorts == 32'h1) begin : gen_no_mux
    spill_register #(
      .T       ( aw_chan_t  ),
      .Bypass  ( ~SpillAw   )
    ) i_aw_spill_reg (
      .clk_i   ( clk_i                    ),
      .rst_ni  ( rst_ni                   ),
      .valid_i ( slv_reqs_i[0].aw_valid   ),
      .ready_o ( slv_resps_o[0].aw_ready  ),
      .data_i  ( slv_reqs_i[0].aw         ),
      .valid_o ( mst_req_o.aw_valid       ),
      .ready_i ( mst_resp_i.aw_ready      ),
      .data_o  ( mst_req_o.aw             )
    );
    spill_register #(
      .T       ( w_chan_t ),
      .Bypass  ( ~SpillW  )
    ) i_w_spill_reg (
      .clk_i   ( clk_i                   ),
      .rst_ni  ( rst_ni                  ),
      .valid_i ( slv_reqs_i[0].w_valid   ),
      .ready_o ( slv_resps_o[0].w_ready  ),
      .data_i  ( slv_reqs_i[0].w         ),
      .valid_o ( mst_req_o.w_valid       ),
      .ready_i ( mst_resp_i.w_ready      ),
      .data_o  ( mst_req_o.w             )
    );
    spill_register #(
      .T       ( b_chan_t ),
      .Bypass  ( ~SpillB  )
    ) i_b_spill_reg (
      .clk_i   ( clk_i                  ),
      .rst_ni  ( rst_ni                 ),
      .valid_i ( mst_resp_i.b_valid     ),
      .ready_o ( mst_req_o.b_ready      ),
      .data_i  ( mst_resp_i.b           ),
      .valid_o ( slv_resps_o[0].b_valid ),
      .ready_i ( slv_reqs_i[0].b_ready  ),
      .data_o  ( slv_resps_o[0].b       )
    );
    spill_register #(
      .T       ( ar_chan_t ),
      .Bypass  ( ~SpillAr  )
    ) i_ar_spill_reg (
      .clk_i   ( clk_i                    ),
      .rst_ni  ( rst_ni                   ),
      .valid_i ( slv_reqs_i[0].ar_valid   ),
      .ready_o ( slv_resps_o[0].ar_ready  ),
      .data_i  ( slv_reqs_i[0].ar         ),
      .valid_o ( mst_req_o.ar_valid       ),
      .ready_i ( mst_resp_i.ar_ready      ),
      .data_o  ( mst_req_o.ar             )
    );
    spill_register #(
      .T       ( r_chan_t ),
      .Bypass  ( ~SpillR  )
    ) i_r_spill_reg (
      .clk_i   ( clk_i                  ),
      .rst_ni  ( rst_ni                 ),
      .valid_i ( mst_resp_i.r_valid     ),
      .ready_o ( mst_req_o.r_ready      ),
      .data_i  ( mst_resp_i.r           ),
      .valid_o ( slv_resps_o[0].r_valid ),
      .ready_i ( slv_reqs_i[0].r_ready  ),
      .data_o  ( slv_resps_o[0].r       )
    );
  
  end else begin : gen_mux
    
    
    localparam int unsigned CLog2NoSlvPorts = $clog2(NoSlvPorts);
    typedef logic [CLog2NoSlvPorts-1:0] select_t;
    
    aw_chan_t [NoSlvPorts-1:0] slv_aw_chans;
    logic     [NoSlvPorts-1:0] slv_aw_valids, slv_aw_readies;
    
    select_t  aw_select;
    aw_chan_t mst_aw_chan;
    logic     mst_aw_valid, mst_aw_ready;
    
    logic     aw_valid,     aw_ready;
    
    
    
    logic     lock_aw_valid_d, lock_aw_valid_q;
    logic     load_aw_lock;
    
    logic     w_fifo_full,  w_fifo_empty;
    logic     w_fifo_push,  w_fifo_pop;
    
    select_t  w_select;
    w_chan_t  mst_w_chan;
    logic     mst_w_valid,  mst_w_ready;
    
    select_t  b_select;
    
    logic     b_fifo_full,  b_fifo_empty;
    logic     b_fifo_pop;
    
    b_chan_t  mst_b_chan;
    logic     mst_b_valid,  mst_b_ready;
    
    ar_chan_t [NoSlvPorts-1:0] slv_ar_chans;
    logic     [NoSlvPorts-1:0] slv_ar_valids, slv_ar_readies;
    
    select_t  ar_select;
    ar_chan_t mst_ar_chan;
    logic     mst_ar_valid, mst_ar_ready;
    
    logic     ar_valid,     ar_ready;
    
    select_t  r_select;
    
    logic     r_fifo_full,  r_fifo_empty;
    logic     r_fifo_push,  r_fifo_pop;
    
    r_chan_t  mst_r_chan;
    logic     mst_r_valid,  mst_r_ready;
    
    
    
    
    for (genvar i = 0; i < NoSlvPorts; i++) begin : gen_aw_arb_input
      assign slv_aw_chans[i]         = slv_reqs_i[i].aw;
      assign slv_aw_valids[i]        = slv_reqs_i[i].aw_valid;
      assign slv_resps_o[i].aw_ready = slv_aw_readies[i];
    end
    rr_arb_tree #(
      .NumIn    ( NoSlvPorts ),
      .DataType ( aw_chan_t  ),
      .AxiVldRdy( 1'b1       ),
      .LockIn   ( 1'b1       )
    ) i_aw_arbiter (
      .clk_i  ( clk_i          ),
      .rst_ni ( rst_ni         ),
      .flush_i( 1'b0           ),
      .rr_i   ( '0             ),
      .req_i  ( slv_aw_valids  ),
      .gnt_o  ( slv_aw_readies ),
      .data_i ( slv_aw_chans   ),
      .gnt_i  ( aw_ready       ),
      .req_o  ( aw_valid       ),
      .data_o ( mst_aw_chan    ),
      .idx_o  ( aw_select      )
    );
    
    always_comb begin
      
      lock_aw_valid_d = lock_aw_valid_q;
      load_aw_lock    = 1'b0;
      w_fifo_push     = 1'b0;
      mst_aw_valid    = 1'b0;
      aw_ready        = 1'b0;
      
      if (lock_aw_valid_q) begin
        mst_aw_valid = 1'b1;
        
        if (mst_aw_ready) begin
          aw_ready        = 1'b1;
          lock_aw_valid_d = 1'b0;
          load_aw_lock    = 1'b1;
        end
      end else begin
        if (!w_fifo_full && aw_valid) begin
          mst_aw_valid = 1'b1;
          w_fifo_push = 1'b1;
          if (mst_aw_ready) begin
            aw_ready = 1'b1;
          end else begin
            
            lock_aw_valid_d = 1'b1;
            load_aw_lock    = 1'b1;
          end
        end
      end
    end
    `FFLARN(lock_aw_valid_q, lock_aw_valid_d, load_aw_lock, '0, clk_i, rst_ni)
    fifo_v3 #(
      .FALL_THROUGH ( FallThrough ),
      .DEPTH        ( MaxTrans    ),
      .dtype        ( select_t    )
    ) i_w_fifo (
      .clk_i     ( clk_i        ),
      .rst_ni    ( rst_ni       ),
      .flush_i   ( 1'b0         ),
      .testmode_i( test_i       ),
      .full_o    ( w_fifo_full  ),
      .empty_o   ( w_fifo_empty ),
      .usage_o   (              ),
      .data_i    ( aw_select    ),
      .push_i    ( w_fifo_push  ),
      .data_o    ( w_select     ),
      .pop_i     ( w_fifo_pop   )
    );
    spill_register #(
      .T       ( aw_chan_t  ),
      .Bypass  ( ~SpillAw   ) 
    ) i_aw_spill_reg (
      .clk_i   ( clk_i               ),
      .rst_ni  ( rst_ni              ),
      .valid_i ( mst_aw_valid        ),
      .ready_o ( mst_aw_ready        ),
      .data_i  ( mst_aw_chan         ),
      .valid_o ( mst_req_o.aw_valid  ),
      .ready_i ( mst_resp_i.aw_ready ),
      .data_o  ( mst_req_o.aw        )
    );
    
    
    
    
    assign mst_w_chan      = slv_reqs_i[w_select].w;
    assign mst_w_valid     = (!w_fifo_empty && !b_fifo_full) ? slv_reqs_i[w_select].w_valid  : 1'b0;
    for (genvar i = 0; i < NoSlvPorts; i++) begin : gen_slv_w_ready
      assign slv_resps_o[i].w_ready =  mst_w_ready & ~w_fifo_empty &
                                      ~b_fifo_full & (w_select == select_t'(i));
    end
    assign w_fifo_pop      = mst_w_valid & mst_w_ready;
    fifo_v3 #(
      .FALL_THROUGH ( FallThrough ),
      .DEPTH        ( MaxTrans    ),
      .dtype        ( select_t    )
    ) i_b_fifo (
      .clk_i     ( clk_i        ),
      .rst_ni    ( rst_ni       ),
      .flush_i   ( 1'b0         ),
      .testmode_i( test_i       ),
      .full_o    ( b_fifo_full  ),
      .empty_o   ( b_fifo_empty ),
      .usage_o   (              ),
      .data_i    ( w_select     ),
      .push_i    ( w_fifo_pop   ), 
      .data_o    ( b_select     ),
      .pop_i     ( b_fifo_pop   )
    );
    spill_register #(
      .T       ( w_chan_t ),
      .Bypass  ( ~SpillW  )
    ) i_w_spill_reg (
      .clk_i   ( clk_i              ),
      .rst_ni  ( rst_ni             ),
      .valid_i ( mst_w_valid        ),
      .ready_o ( mst_w_ready        ),
      .data_i  ( mst_w_chan         ),
      .valid_o ( mst_req_o.w_valid  ),
      .ready_i ( mst_resp_i.w_ready ),
      .data_o  ( mst_req_o.w        )
    );
    
    
    
    
    for (genvar i = 0; i < NoSlvPorts; i++) begin : gen_slv_resps_b
      assign slv_resps_o[i].b       = mst_b_chan;
      assign slv_resps_o[i].b_valid = mst_b_valid & ~b_fifo_empty & (b_select == select_t'(i));
    end
    assign mst_b_ready    = ~b_fifo_empty & slv_reqs_i[b_select].b_ready;
    assign b_fifo_pop     = mst_b_valid & mst_b_ready;
    spill_register #(
      .T       ( b_chan_t ),
      .Bypass  ( ~SpillB  )
    ) i_b_spill_reg (
      .clk_i   ( clk_i              ),
      .rst_ni  ( rst_ni             ),
      .valid_i ( mst_resp_i.b_valid ),
      .ready_o ( mst_req_o.b_ready  ),
      .data_i  ( mst_resp_i.b       ),
      .valid_o ( mst_b_valid        ),
      .ready_i ( mst_b_ready        ),
      .data_o  ( mst_b_chan         )
    );
    
    
    
    
    for (genvar i = 0; i < NoSlvPorts; i++) begin : gen_ar_arb_input
      assign slv_ar_chans[i]         = slv_reqs_i[i].ar;
      assign slv_ar_valids[i]        = slv_reqs_i[i].ar_valid;
      assign slv_resps_o[i].ar_ready = slv_ar_readies[i];
    end
    rr_arb_tree #(
      .NumIn    ( NoSlvPorts ),
      .DataType ( ar_chan_t  ),
      .AxiVldRdy( 1'b1       ),
      .LockIn   ( 1'b1       )
    ) i_ar_arbiter (
      .clk_i  ( clk_i          ),
      .rst_ni ( rst_ni         ),
      .flush_i( 1'b0           ),
      .rr_i   ( '0             ),
      .req_i  ( slv_ar_valids  ),
      .gnt_o  ( slv_ar_readies ),
      .data_i ( slv_ar_chans   ),
      .gnt_i  ( ar_ready       ),
      .req_o  ( ar_valid       ),
      .data_o ( mst_ar_chan    ),
      .idx_o  ( ar_select      )
    );
    
    
    assign mst_ar_valid = (!r_fifo_full) ? ar_valid     : 1'b0;
    assign ar_ready     = (!r_fifo_full) ? mst_ar_ready : 1'b0;
    assign r_fifo_push  = mst_ar_valid & mst_ar_ready;
    fifo_v3 #(
      .FALL_THROUGH ( FallThrough ),
      .DEPTH        ( MaxTrans    ),
      .dtype        ( select_t    )
    ) i_r_fifo (
      .clk_i     ( clk_i        ),
      .rst_ni    ( rst_ni       ),
      .flush_i   ( 1'b0         ),
      .testmode_i( test_i       ),
      .full_o    ( r_fifo_full  ),
      .empty_o   ( r_fifo_empty ),
      .usage_o   (              ),
      .data_i    ( ar_select    ),
      .push_i    ( r_fifo_push  ), 
      .data_o    ( r_select     ),
      .pop_i     ( r_fifo_pop   )
    );
    spill_register #(
      .T       ( ar_chan_t ),
      .Bypass  ( ~SpillAr  )
    ) i_ar_spill_reg (
      .clk_i   ( clk_i               ),
      .rst_ni  ( rst_ni              ),
      .valid_i ( mst_ar_valid        ),
      .ready_o ( mst_ar_ready        ),
      .data_i  ( mst_ar_chan         ),
      .valid_o ( mst_req_o.ar_valid  ),
      .ready_i ( mst_resp_i.ar_ready ),
      .data_o  ( mst_req_o.ar        )
    );
    
    
    
    
    for (genvar i = 0; i < NoSlvPorts; i++) begin : gen_slv_resps_r
      assign slv_resps_o[i].r       = mst_r_chan;
      assign slv_resps_o[i].r_valid = mst_r_valid & ~r_fifo_empty & (r_select == select_t'(i));
    end
    assign mst_r_ready    = ~r_fifo_empty & slv_reqs_i[r_select].r_ready;
    assign r_fifo_pop     = mst_r_valid & mst_r_ready;
    spill_register #(
      .T       ( r_chan_t ),
      .Bypass  ( ~SpillR  )
    ) i_r_spill_reg (
      .clk_i   ( clk_i              ),
      .rst_ni  ( rst_ni             ),
      .valid_i ( mst_resp_i.r_valid ),
      .ready_o ( mst_req_o.r_ready  ),
      .data_i  ( mst_resp_i.r       ),
      .valid_o ( mst_r_valid        ),
      .ready_i ( mst_r_ready        ),
      .data_o  ( mst_r_chan         )
    );
  end
  
  `ifndef VERILATOR
    initial begin: p_assertions
      NoPorts:  assert (NoSlvPorts > 0) else $fatal("Number of slave ports must be at least 1!");
      MaxTnx:   assert (MaxTrans   > 0) else $fatal("Number of transactions must be at least 1!");
    end
  `endif
  
endmodule
`ifndef AXI_ASSIGN_SVH_
`define AXI_ASSIGN_SVH_
`define __AXI_TO_AW(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)   \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``addr   = __rhs``__rhs_sep``addr;       \
  __opt_as __lhs``__lhs_sep``len    = __rhs``__rhs_sep``len;        \
  __opt_as __lhs``__lhs_sep``size   = __rhs``__rhs_sep``size;       \
  __opt_as __lhs``__lhs_sep``burst  = __rhs``__rhs_sep``burst;      \
  __opt_as __lhs``__lhs_sep``lock   = __rhs``__rhs_sep``lock;       \
  __opt_as __lhs``__lhs_sep``cache  = __rhs``__rhs_sep``cache;      \
  __opt_as __lhs``__lhs_sep``prot   = __rhs``__rhs_sep``prot;       \
  __opt_as __lhs``__lhs_sep``qos    = __rhs``__rhs_sep``qos;        \
  __opt_as __lhs``__lhs_sep``region = __rhs``__rhs_sep``region;     \
  __opt_as __lhs``__lhs_sep``atop   = __rhs``__rhs_sep``atop;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_W(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``data   = __rhs``__rhs_sep``data;       \
  __opt_as __lhs``__lhs_sep``strb   = __rhs``__rhs_sep``strb;       \
  __opt_as __lhs``__lhs_sep``last   = __rhs``__rhs_sep``last;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_B(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``resp   = __rhs``__rhs_sep``resp;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_AR(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)   \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``addr   = __rhs``__rhs_sep``addr;       \
  __opt_as __lhs``__lhs_sep``len    = __rhs``__rhs_sep``len;        \
  __opt_as __lhs``__lhs_sep``size   = __rhs``__rhs_sep``size;       \
  __opt_as __lhs``__lhs_sep``burst  = __rhs``__rhs_sep``burst;      \
  __opt_as __lhs``__lhs_sep``lock   = __rhs``__rhs_sep``lock;       \
  __opt_as __lhs``__lhs_sep``cache  = __rhs``__rhs_sep``cache;      \
  __opt_as __lhs``__lhs_sep``prot   = __rhs``__rhs_sep``prot;       \
  __opt_as __lhs``__lhs_sep``qos    = __rhs``__rhs_sep``qos;        \
  __opt_as __lhs``__lhs_sep``region = __rhs``__rhs_sep``region;     \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_R(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``data   = __rhs``__rhs_sep``data;       \
  __opt_as __lhs``__lhs_sep``resp   = __rhs``__rhs_sep``resp;       \
  __opt_as __lhs``__lhs_sep``last   = __rhs``__rhs_sep``last;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_REQ(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)  \
  `__AXI_TO_AW(__opt_as, __lhs.aw, __lhs_sep, __rhs.aw, __rhs_sep)  \
  __opt_as __lhs.aw_valid = __rhs.aw_valid;                         \
  `__AXI_TO_W(__opt_as, __lhs.w, __lhs_sep, __rhs.w, __rhs_sep)     \
  __opt_as __lhs.w_valid = __rhs.w_valid;                           \
  __opt_as __lhs.b_ready = __rhs.b_ready;                           \
  `__AXI_TO_AR(__opt_as, __lhs.ar, __lhs_sep, __rhs.ar, __rhs_sep)  \
  __opt_as __lhs.ar_valid = __rhs.ar_valid;                         \
  __opt_as __lhs.r_ready = __rhs.r_ready;
`define __AXI_TO_RESP(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs.aw_ready = __rhs.aw_ready;                         \
  __opt_as __lhs.ar_ready = __rhs.ar_ready;                         \
  __opt_as __lhs.w_ready = __rhs.w_ready;                           \
  __opt_as __lhs.b_valid = __rhs.b_valid;                           \
  `__AXI_TO_B(__opt_as, __lhs.b, __lhs_sep, __rhs.b, __rhs_sep)     \
  __opt_as __lhs.r_valid = __rhs.r_valid;                           \
  `__AXI_TO_R(__opt_as, __lhs.r, __lhs_sep, __rhs.r, __rhs_sep)
`define AXI_ASSIGN_AW(dst, src)               \
  `__AXI_TO_AW(assign, dst.aw, _, src.aw, _)  \
  assign dst.aw_valid = src.aw_valid;         \
  assign src.aw_ready = dst.aw_ready;
`define AXI_ASSIGN_W(dst, src)                \
  `__AXI_TO_W(assign, dst.w, _, src.w, _)     \
  assign dst.w_valid  = src.w_valid;          \
  assign src.w_ready  = dst.w_ready;
`define AXI_ASSIGN_B(dst, src)                \
  `__AXI_TO_B(assign, dst.b, _, src.b, _)     \
  assign dst.b_valid  = src.b_valid;          \
  assign src.b_ready  = dst.b_ready;
`define AXI_ASSIGN_AR(dst, src)               \
  `__AXI_TO_AR(assign, dst.ar, _, src.ar, _)  \
  assign dst.ar_valid = src.ar_valid;         \
  assign src.ar_ready = dst.ar_ready;
`define AXI_ASSIGN_R(dst, src)                \
  `__AXI_TO_R(assign, dst.r, _, src.r, _)     \
  assign dst.r_valid  = src.r_valid;          \
  assign src.r_ready  = dst.r_ready;
`define AXI_ASSIGN(slv, mst)  \
  `AXI_ASSIGN_AW(slv, mst)    \
  `AXI_ASSIGN_W(slv, mst)     \
  `AXI_ASSIGN_B(mst, slv)     \
  `AXI_ASSIGN_AR(slv, mst)    \
  `AXI_ASSIGN_R(mst, slv)
`define AXI_ASSIGN_MONITOR(mon_dv, axi_if)          \
  `__AXI_TO_AW(assign, mon_dv.aw, _, axi_if.aw, _)  \
  assign mon_dv.aw_valid  = axi_if.aw_valid;        \
  assign mon_dv.aw_ready  = axi_if.aw_ready;        \
  `__AXI_TO_W(assign, mon_dv.w, _, axi_if.w, _)     \
  assign mon_dv.w_valid   = axi_if.w_valid;         \
  assign mon_dv.w_ready   = axi_if.w_ready;         \
  `__AXI_TO_B(assign, mon_dv.b, _, axi_if.b, _)     \
  assign mon_dv.b_valid   = axi_if.b_valid;         \
  assign mon_dv.b_ready   = axi_if.b_ready;         \
  `__AXI_TO_AR(assign, mon_dv.ar, _, axi_if.ar, _)  \
  assign mon_dv.ar_valid  = axi_if.ar_valid;        \
  assign mon_dv.ar_ready  = axi_if.ar_ready;        \
  `__AXI_TO_R(assign, mon_dv.r, _, axi_if.r, _)     \
  assign mon_dv.r_valid   = axi_if.r_valid;         \
  assign mon_dv.r_ready   = axi_if.r_ready;
`define AXI_SET_FROM_AW(axi_if, aw_struct)      `__AXI_TO_AW(, axi_if.aw, _, aw_struct, .)
`define AXI_SET_FROM_W(axi_if, w_struct)        `__AXI_TO_W(, axi_if.w, _, w_struct, .)
`define AXI_SET_FROM_B(axi_if, b_struct)        `__AXI_TO_B(, axi_if.b, _, b_struct, .)
`define AXI_SET_FROM_AR(axi_if, ar_struct)      `__AXI_TO_AR(, axi_if.ar, _, ar_struct, .)
`define AXI_SET_FROM_R(axi_if, r_struct)        `__AXI_TO_R(, axi_if.r, _, r_struct, .)
`define AXI_SET_FROM_REQ(axi_if, req_struct)    `__AXI_TO_REQ(, axi_if, _, req_struct, .)
`define AXI_SET_FROM_RESP(axi_if, resp_struct)  `__AXI_TO_RESP(, axi_if, _, resp_struct, .)
`define AXI_ASSIGN_FROM_AW(axi_if, aw_struct)     `__AXI_TO_AW(assign, axi_if.aw, _, aw_struct, .)
`define AXI_ASSIGN_FROM_W(axi_if, w_struct)       `__AXI_TO_W(assign, axi_if.w, _, w_struct, .)
`define AXI_ASSIGN_FROM_B(axi_if, b_struct)       `__AXI_TO_B(assign, axi_if.b, _, b_struct, .)
`define AXI_ASSIGN_FROM_AR(axi_if, ar_struct)     `__AXI_TO_AR(assign, axi_if.ar, _, ar_struct, .)
`define AXI_ASSIGN_FROM_R(axi_if, r_struct)       `__AXI_TO_R(assign, axi_if.r, _, r_struct, .)
`define AXI_ASSIGN_FROM_REQ(axi_if, req_struct)   `__AXI_TO_REQ(assign, axi_if, _, req_struct, .)
`define AXI_ASSIGN_FROM_RESP(axi_if, resp_struct) `__AXI_TO_RESP(assign, axi_if, _, resp_struct, .)
`define AXI_SET_TO_AW(aw_struct, axi_if)     `__AXI_TO_AW(, aw_struct, ., axi_if.aw, _)
`define AXI_SET_TO_W(w_struct, axi_if)       `__AXI_TO_W(, w_struct, ., axi_if.w, _)
`define AXI_SET_TO_B(b_struct, axi_if)       `__AXI_TO_B(, b_struct, ., axi_if.b, _)
`define AXI_SET_TO_AR(ar_struct, axi_if)     `__AXI_TO_AR(, ar_struct, ., axi_if.ar, _)
`define AXI_SET_TO_R(r_struct, axi_if)       `__AXI_TO_R(, r_struct, ., axi_if.r, _)
`define AXI_SET_TO_REQ(req_struct, axi_if)   `__AXI_TO_REQ(, req_struct, ., axi_if, _)
`define AXI_SET_TO_RESP(resp_struct, axi_if) `__AXI_TO_RESP(, resp_struct, ., axi_if, _)
`define AXI_ASSIGN_TO_AW(aw_struct, axi_if)     `__AXI_TO_AW(assign, aw_struct, ., axi_if.aw, _)
`define AXI_ASSIGN_TO_W(w_struct, axi_if)       `__AXI_TO_W(assign, w_struct, ., axi_if.w, _)
`define AXI_ASSIGN_TO_B(b_struct, axi_if)       `__AXI_TO_B(assign, b_struct, ., axi_if.b, _)
`define AXI_ASSIGN_TO_AR(ar_struct, axi_if)     `__AXI_TO_AR(assign, ar_struct, ., axi_if.ar, _)
`define AXI_ASSIGN_TO_R(r_struct, axi_if)       `__AXI_TO_R(assign, r_struct, ., axi_if.r, _)
`define AXI_ASSIGN_TO_REQ(req_struct, axi_if)   `__AXI_TO_REQ(assign, req_struct, ., axi_if, _)
`define AXI_ASSIGN_TO_RESP(resp_struct, axi_if) `__AXI_TO_RESP(assign, resp_struct, ., axi_if, _)
`define AXI_SET_AW_STRUCT(lhs, rhs)     `__AXI_TO_AW(, lhs, ., rhs, .)
`define AXI_SET_W_STRUCT(lhs, rhs)       `__AXI_TO_W(, lhs, ., rhs, .)
`define AXI_SET_B_STRUCT(lhs, rhs)       `__AXI_TO_B(, lhs, ., rhs, .)
`define AXI_SET_AR_STRUCT(lhs, rhs)     `__AXI_TO_AR(, lhs, ., rhs, .)
`define AXI_SET_R_STRUCT(lhs, rhs)       `__AXI_TO_R(, lhs, ., rhs, .)
`define AXI_SET_REQ_STRUCT(lhs, rhs)   `__AXI_TO_REQ(, lhs, ., rhs, .)
`define AXI_SET_RESP_STRUCT(lhs, rhs) `__AXI_TO_RESP(, lhs, ., rhs, .)
`define AXI_ASSIGN_AW_STRUCT(lhs, rhs)     `__AXI_TO_AW(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_W_STRUCT(lhs, rhs)       `__AXI_TO_W(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_B_STRUCT(lhs, rhs)       `__AXI_TO_B(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_AR_STRUCT(lhs, rhs)     `__AXI_TO_AR(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_R_STRUCT(lhs, rhs)       `__AXI_TO_R(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_REQ_STRUCT(lhs, rhs)   `__AXI_TO_REQ(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_RESP_STRUCT(lhs, rhs) `__AXI_TO_RESP(assign, lhs, ., rhs, .)
`define __AXI_LITE_TO_AX(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)  \
  __opt_as __lhs``__lhs_sep``addr = __rhs``__rhs_sep``addr;             \
  __opt_as __lhs``__lhs_sep``prot = __rhs``__rhs_sep``prot;
`define __AXI_LITE_TO_W(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``data = __rhs``__rhs_sep``data;           \
  __opt_as __lhs``__lhs_sep``strb = __rhs``__rhs_sep``strb;
`define __AXI_LITE_TO_B(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``resp = __rhs``__rhs_sep``resp;
`define __AXI_LITE_TO_R(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``data = __rhs``__rhs_sep``data;           \
  __opt_as __lhs``__lhs_sep``resp = __rhs``__rhs_sep``resp;
`define __AXI_LITE_TO_REQ(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  `__AXI_LITE_TO_AX(__opt_as, __lhs.aw, __lhs_sep, __rhs.aw, __rhs_sep) \
  __opt_as __lhs.aw_valid = __rhs.aw_valid;                             \
  `__AXI_LITE_TO_W(__opt_as, __lhs.w, __lhs_sep, __rhs.w, __rhs_sep)    \
  __opt_as __lhs.w_valid = __rhs.w_valid;                               \
  __opt_as __lhs.b_ready = __rhs.b_ready;                               \
  `__AXI_LITE_TO_AX(__opt_as, __lhs.ar, __lhs_sep, __rhs.ar, __rhs_sep) \
  __opt_as __lhs.ar_valid = __rhs.ar_valid;                             \
  __opt_as __lhs.r_ready = __rhs.r_ready;
`define __AXI_LITE_TO_RESP(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)  \
  __opt_as __lhs.aw_ready = __rhs.aw_ready;                               \
  __opt_as __lhs.ar_ready = __rhs.ar_ready;                               \
  __opt_as __lhs.w_ready = __rhs.w_ready;                                 \
  __opt_as __lhs.b_valid = __rhs.b_valid;                                 \
  `__AXI_LITE_TO_B(__opt_as, __lhs.b, __lhs_sep, __rhs.b, __rhs_sep)      \
  __opt_as __lhs.r_valid = __rhs.r_valid;                                 \
  `__AXI_LITE_TO_R(__opt_as, __lhs.r, __lhs_sep, __rhs.r, __rhs_sep)
`define AXI_LITE_ASSIGN_AW(dst, src)              \
  `__AXI_LITE_TO_AX(assign, dst.aw, _, src.aw, _) \
  assign dst.aw_valid = src.aw_valid;             \
  assign src.aw_ready = dst.aw_ready;
`define AXI_LITE_ASSIGN_W(dst, src)             \
  `__AXI_LITE_TO_W(assign, dst.w, _, src.w, _)  \
  assign dst.w_valid  = src.w_valid;            \
  assign src.w_ready  = dst.w_ready;
`define AXI_LITE_ASSIGN_B(dst, src)             \
  `__AXI_LITE_TO_B(assign, dst.b, _, src.b, _)  \
  assign dst.b_valid  = src.b_valid;            \
  assign src.b_ready  = dst.b_ready;
`define AXI_LITE_ASSIGN_AR(dst, src)              \
  `__AXI_LITE_TO_AX(assign, dst.ar, _, src.ar, _) \
  assign dst.ar_valid = src.ar_valid;             \
  assign src.ar_ready = dst.ar_ready;
`define AXI_LITE_ASSIGN_R(dst, src)             \
  `__AXI_LITE_TO_R(assign, dst.r, _, src.r, _)  \
  assign dst.r_valid  = src.r_valid;            \
  assign src.r_ready  = dst.r_ready;
`define AXI_LITE_ASSIGN(slv, mst) \
  `AXI_LITE_ASSIGN_AW(slv, mst)   \
  `AXI_LITE_ASSIGN_W(slv, mst)    \
  `AXI_LITE_ASSIGN_B(mst, slv)    \
  `AXI_LITE_ASSIGN_AR(slv, mst)   \
  `AXI_LITE_ASSIGN_R(mst, slv)
`define AXI_LITE_SET_FROM_AW(axi_if, aw_struct)      `__AXI_LITE_TO_AX(, axi_if.aw, _, aw_struct, .)
`define AXI_LITE_SET_FROM_W(axi_if, w_struct)        `__AXI_LITE_TO_W(, axi_if.w, _, w_struct, .)
`define AXI_LITE_SET_FROM_B(axi_if, b_struct)        `__AXI_LITE_TO_B(, axi_if.b, _, b_struct, .)
`define AXI_LITE_SET_FROM_AR(axi_if, ar_struct)      `__AXI_LITE_TO_AX(, axi_if.ar, _, ar_struct, .)
`define AXI_LITE_SET_FROM_R(axi_if, r_struct)        `__AXI_LITE_TO_R(, axi_if.r, _, r_struct, .)
`define AXI_LITE_SET_FROM_REQ(axi_if, req_struct)    `__AXI_LITE_TO_REQ(, axi_if, _, req_struct, .)
`define AXI_LITE_SET_FROM_RESP(axi_if, resp_struct)  `__AXI_LITE_TO_RESP(, axi_if, _, resp_struct, .)
`define AXI_LITE_ASSIGN_FROM_AW(axi_if, aw_struct)     `__AXI_LITE_TO_AX(assign, axi_if.aw, _, aw_struct, .)
`define AXI_LITE_ASSIGN_FROM_W(axi_if, w_struct)       `__AXI_LITE_TO_W(assign, axi_if.w, _, w_struct, .)
`define AXI_LITE_ASSIGN_FROM_B(axi_if, b_struct)       `__AXI_LITE_TO_B(assign, axi_if.b, _, b_struct, .)
`define AXI_LITE_ASSIGN_FROM_AR(axi_if, ar_struct)     `__AXI_LITE_TO_AX(assign, axi_if.ar, _, ar_struct, .)
`define AXI_LITE_ASSIGN_FROM_R(axi_if, r_struct)       `__AXI_LITE_TO_R(assign, axi_if.r, _, r_struct, .)
`define AXI_LITE_ASSIGN_FROM_REQ(axi_if, req_struct)   `__AXI_LITE_TO_REQ(assign, axi_if, _, req_struct, .)
`define AXI_LITE_ASSIGN_FROM_RESP(axi_if, resp_struct) `__AXI_LITE_TO_RESP(assign, axi_if, _, resp_struct, .)
`define AXI_LITE_SET_TO_AW(aw_struct, axi_if)     `__AXI_LITE_TO_AX(, aw_struct, ., axi_if.aw, _)
`define AXI_LITE_SET_TO_W(w_struct, axi_if)       `__AXI_LITE_TO_W(, w_struct, ., axi_if.w, _)
`define AXI_LITE_SET_TO_B(b_struct, axi_if)       `__AXI_LITE_TO_B(, b_struct, ., axi_if.b, _)
`define AXI_LITE_SET_TO_AR(ar_struct, axi_if)     `__AXI_LITE_TO_AX(, ar_struct, ., axi_if.ar, _)
`define AXI_LITE_SET_TO_R(r_struct, axi_if)       `__AXI_LITE_TO_R(, r_struct, ., axi_if.r, _)
`define AXI_LITE_SET_TO_REQ(req_struct, axi_if)   `__AXI_LITE_TO_REQ(, req_struct, ., axi_if, _)
`define AXI_LITE_SET_TO_RESP(resp_struct, axi_if) `__AXI_LITE_TO_RESP(, resp_struct, ., axi_if, _)
`define AXI_LITE_ASSIGN_TO_AW(aw_struct, axi_if)     `__AXI_LITE_TO_AX(assign, aw_struct, ., axi_if.aw, _)
`define AXI_LITE_ASSIGN_TO_W(w_struct, axi_if)       `__AXI_LITE_TO_W(assign, w_struct, ., axi_if.w, _)
`define AXI_LITE_ASSIGN_TO_B(b_struct, axi_if)       `__AXI_LITE_TO_B(assign, b_struct, ., axi_if.b, _)
`define AXI_LITE_ASSIGN_TO_AR(ar_struct, axi_if)     `__AXI_LITE_TO_AX(assign, ar_struct, ., axi_if.ar, _)
`define AXI_LITE_ASSIGN_TO_R(r_struct, axi_if)       `__AXI_LITE_TO_R(assign, r_struct, ., axi_if.r, _)
`define AXI_LITE_ASSIGN_TO_REQ(req_struct, axi_if)   `__AXI_LITE_TO_REQ(assign, req_struct, ., axi_if, _)
`define AXI_LITE_ASSIGN_TO_RESP(resp_struct, axi_if) `__AXI_LITE_TO_RESP(assign, resp_struct, ., axi_if, _)
`define AXI_LITE_SET_AW_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(, lhs, ., rhs, .)
`define AXI_LITE_SET_W_STRUCT(lhs, rhs)       `__AXI_LITE_TO_W(, lhs, ., rhs, .)
`define AXI_LITE_SET_B_STRUCT(lhs, rhs)       `__AXI_LITE_TO_B(, lhs, ., rhs, .)
`define AXI_LITE_SET_AR_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(, lhs, ., rhs, .)
`define AXI_LITE_SET_R_STRUCT(lhs, rhs)       `__AXI_LITE_TO_R(, lhs, ., rhs, .)
`define AXI_LITE_SET_REQ_STRUCT(lhs, rhs)   `__AXI_LITE_TO_REQ(, lhs, ., rhs, .)
`define AXI_LITE_SET_RESP_STRUCT(lhs, rhs) `__AXI_LITE_TO_RESP(, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_AW_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_W_STRUCT(lhs, rhs)       `__AXI_LITE_TO_W(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_B_STRUCT(lhs, rhs)       `__AXI_LITE_TO_B(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_AR_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_R_STRUCT(lhs, rhs)       `__AXI_LITE_TO_R(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_REQ_STRUCT(lhs, rhs)   `__AXI_LITE_TO_REQ(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_RESP_STRUCT(lhs, rhs) `__AXI_LITE_TO_RESP(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_MASTER_TO_FLAT(pat, req, rsp) \
  assign m_axi_``pat``_awvalid  = req.aw_valid;  \
  assign m_axi_``pat``_awid     = req.aw.id;     \
  assign m_axi_``pat``_awaddr   = req.aw.addr;   \
  assign m_axi_``pat``_awlen    = req.aw.len;    \
  assign m_axi_``pat``_awsize   = req.aw.size;   \
  assign m_axi_``pat``_awburst  = req.aw.burst;  \
  assign m_axi_``pat``_awlock   = req.aw.lock;   \
  assign m_axi_``pat``_awcache  = req.aw.cache;  \
  assign m_axi_``pat``_awprot   = req.aw.prot;   \
  assign m_axi_``pat``_awqos    = req.aw.qos;    \
  assign m_axi_``pat``_awregion = req.aw.region; \
  assign m_axi_``pat``_awuser   = req.aw.user;   \
                                                 \
  assign m_axi_``pat``_wvalid   = req.w_valid;   \
  assign m_axi_``pat``_wdata    = req.w.data;    \
  assign m_axi_``pat``_wstrb    = req.w.strb;    \
  assign m_axi_``pat``_wlast    = req.w.last;    \
  assign m_axi_``pat``_wuser    = req.w.user;    \
                                                 \
  assign m_axi_``pat``_bready   = req.b_ready;   \
                                                 \
  assign m_axi_``pat``_arvalid  = req.ar_valid;  \
  assign m_axi_``pat``_arid     = req.ar.id;     \
  assign m_axi_``pat``_araddr   = req.ar.addr;   \
  assign m_axi_``pat``_arlen    = req.ar.len;    \
  assign m_axi_``pat``_arsize   = req.ar.size;   \
  assign m_axi_``pat``_arburst  = req.ar.burst;  \
  assign m_axi_``pat``_arlock   = req.ar.lock;   \
  assign m_axi_``pat``_arcache  = req.ar.cache;  \
  assign m_axi_``pat``_arprot   = req.ar.prot;   \
  assign m_axi_``pat``_arqos    = req.ar.qos;    \
  assign m_axi_``pat``_arregion = req.ar.region; \
  assign m_axi_``pat``_aruser   = req.ar.user;   \
                                                 \
  assign m_axi_``pat``_rready   = req.r_ready;   \
                                                 \
  assign rsp.aw_ready = m_axi_``pat``_awready;   \
  assign rsp.ar_ready = m_axi_``pat``_arready;   \
  assign rsp.w_ready  = m_axi_``pat``_wready;    \
                                                 \
  assign rsp.b_valid  = m_axi_``pat``_bvalid;    \
  assign rsp.b.id     = m_axi_``pat``_bid;       \
  assign rsp.b.resp   = m_axi_``pat``_bresp;     \
  assign rsp.b.user   = m_axi_``pat``_buser;     \
                                                 \
  assign rsp.r_valid  = m_axi_``pat``_rvalid;    \
  assign rsp.r.id     = m_axi_``pat``_rid;       \
  assign rsp.r.data   = m_axi_``pat``_rdata;     \
  assign rsp.r.resp   = m_axi_``pat``_rresp;     \
  assign rsp.r.last   = m_axi_``pat``_rlast;     \
  assign rsp.r.user   = m_axi_``pat``_ruser;
`define AXI_ASSIGN_SLAVE_TO_FLAT(pat, req, rsp)  \
  assign req.aw_valid  = s_axi_``pat``_awvalid;  \
  assign req.aw.id     = s_axi_``pat``_awid;     \
  assign req.aw.addr   = s_axi_``pat``_awaddr;   \
  assign req.aw.len    = s_axi_``pat``_awlen;    \
  assign req.aw.size   = s_axi_``pat``_awsize;   \
  assign req.aw.burst  = s_axi_``pat``_awburst;  \
  assign req.aw.lock   = s_axi_``pat``_awlock;   \
  assign req.aw.cache  = s_axi_``pat``_awcache;  \
  assign req.aw.prot   = s_axi_``pat``_awprot;   \
  assign req.aw.qos    = s_axi_``pat``_awqos;    \
  assign req.aw.region = s_axi_``pat``_awregion; \
  assign req.aw.user   = s_axi_``pat``_awuser;   \
                                                 \
  assign req.w_valid   = s_axi_``pat``_wvalid;   \
  assign req.w.data    = s_axi_``pat``_wdata;    \
  assign req.w.strb    = s_axi_``pat``_wstrb;    \
  assign req.w.last    = s_axi_``pat``_wlast;    \
  assign req.w.user    = s_axi_``pat``_wuser;    \
                                                 \
  assign req.b_ready   = s_axi_``pat``_bready;   \
                                                 \
  assign req.ar_valid  = s_axi_``pat``_arvalid;  \
  assign req.ar.id     = s_axi_``pat``_arid;     \
  assign req.ar.addr   = s_axi_``pat``_araddr;   \
  assign req.ar.len    = s_axi_``pat``_arlen;    \
  assign req.ar.size   = s_axi_``pat``_arsize;   \
  assign req.ar.burst  = s_axi_``pat``_arburst;  \
  assign req.ar.lock   = s_axi_``pat``_arlock;   \
  assign req.ar.cache  = s_axi_``pat``_arcache;  \
  assign req.ar.prot   = s_axi_``pat``_arprot;   \
  assign req.ar.qos    = s_axi_``pat``_arqos;    \
  assign req.ar.region = s_axi_``pat``_arregion; \
  assign req.ar.user   = s_axi_``pat``_aruser;   \
                                                 \
  assign req.r_ready   = s_axi_``pat``_rready;   \
                                                 \
  assign s_axi_``pat``_awready = rsp.aw_ready;   \
  assign s_axi_``pat``_arready = rsp.ar_ready;   \
  assign s_axi_``pat``_wready  = rsp.w_ready;    \
                                                 \
  assign s_axi_``pat``_bvalid  = rsp.b_valid;    \
  assign s_axi_``pat``_bid     = rsp.b.id;       \
  assign s_axi_``pat``_bresp   = rsp.b.resp;     \
  assign s_axi_``pat``_buser   = rsp.b.user;     \
                                                 \
  assign s_axi_``pat``_rvalid  = rsp.r_valid;    \
  assign s_axi_``pat``_rid     = rsp.r.id;       \
  assign s_axi_``pat``_rdata   = rsp.r.data;     \
  assign s_axi_``pat``_rresp   = rsp.r.resp;     \
  assign s_axi_``pat``_rlast   = rsp.r.last;     \
  assign s_axi_``pat``_ruser   = rsp.r.user;
`define AXI_ASSIGN_TO_FLAT_PORT(pat, req, rsp)  \
  .``pat``_awvalid  ( req.aw_valid  ), \
  .``pat``_awid     ( req.aw.id     ), \
  .``pat``_awaddr   ( req.aw.addr   ), \
  .``pat``_awlen    ( req.aw.len    ), \
  .``pat``_awsize   ( req.aw.size   ), \
  .``pat``_awburst  ( req.aw.burst  ), \
  .``pat``_awlock   ( req.aw.lock   ), \
  .``pat``_awcache  ( req.aw.cache  ), \
  .``pat``_awprot   ( req.aw.prot   ), \
  .``pat``_awqos    ( req.aw.qos    ), \
  .``pat``_awregion ( req.aw.region ), \
  .``pat``_awuser   ( req.aw.user   ), \
                                       \
  .``pat``_wvalid   ( req.w_valid   ), \
  .``pat``_wdata    ( req.w.data    ), \
  .``pat``_wstrb    ( req.w.strb    ), \
  .``pat``_wlast    ( req.w.last    ), \
  .``pat``_wuser    ( req.w.user    ), \
                                       \
  .``pat``_bready   ( req.b_ready   ), \
                                       \
  .``pat``_arvalid  ( req.ar_valid  ), \
  .``pat``_arid     ( req.ar.id     ), \
  .``pat``_araddr   ( req.ar.addr   ), \
  .``pat``_arlen    ( req.ar.len    ), \
  .``pat``_arsize   ( req.ar.size   ), \
  .``pat``_arburst  ( req.ar.burst  ), \
  .``pat``_arlock   ( req.ar.lock   ), \
  .``pat``_arcache  ( req.ar.cache  ), \
  .``pat``_arprot   ( req.ar.prot   ), \
  .``pat``_arqos    ( req.ar.qos    ), \
  .``pat``_arregion ( req.ar.region ), \
  .``pat``_aruser   ( req.ar.user   ), \
                                       \
  .``pat``_rready   ( req.r_ready   ), \
                                       \
  .``pat``_awready  ( rsp.aw_ready  ), \
  .``pat``_arready  ( rsp.ar_ready  ), \
  .``pat``_wready   ( rsp.w_ready   ), \
                                       \
  .``pat``_bvalid   ( rsp.b_valid   ), \
  .``pat``_bid      ( rsp.b.id      ), \
  .``pat``_bresp    ( rsp.b.resp    ), \
  .``pat``_buser    ( rsp.b.user    ), \
                                       \
  .``pat``_rvalid   ( rsp.r_valid   ), \
  .``pat``_rid      ( rsp.r.id      ), \
  .``pat``_rdata    ( rsp.r.data    ), \
  .``pat``_rresp    ( rsp.r.resp    ), \
  .``pat``_rlast    ( rsp.r.last    ), \
  .``pat``_ruser    ( rsp.r.user    )
`define AXI_ASSIGN_MASTER_TO_FLAT_PORT(name, req, rsp) \
  `AXI_ASSIGN_TO_FLAT_PORT(m_axi_``name``, req, rsp)
`define AXI_ASSIGN_SLAVE_TO_FLAT_PORT(name, req, rsp) \
  `AXI_ASSIGN_TO_FLAT_PORT(s_axi_``name``, req, rsp)
`define AXI_HIGHLIGHT(__name, __aw_t, __w_t, __b_t, __ar_t, __r_t, __req, __resp) \
  signal_highlighter #(                                                           \
    .T ( __aw_t )                                                                 \
  ) i_signal_highlighter_``__name``_aw (                                          \
    .ready_i ( __resp.aw_ready ),                                                 \
    .valid_i ( __req.aw_valid  ),                                                 \
    .data_i  ( __req.aw        )                                                  \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __w_t )                                                                  \
  ) i_signal_highlighter_``__name``_w (                                           \
    .ready_i ( __resp.w_ready ),                                                  \
    .valid_i ( __req.w_valid  ),                                                  \
    .data_i  ( __req.w        )                                                   \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __b_t )                                                                  \
  ) i_signal_highlighter_``__name``_b (                                           \
    .ready_i ( __req.b_ready  ),                                                  \
    .valid_i ( __resp.b_valid ),                                                  \
    .data_i  ( __resp.b       )                                                   \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __ar_t )                                                                 \
  ) i_signal_highlighter_``__name``_ar (                                          \
    .ready_i ( __resp.ar_ready ),                                                 \
    .valid_i ( __req.ar_valid  ),                                                 \
    .data_i  ( __req.ar        )                                                  \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __r_t )                                                                  \
  ) i_signal_highlighter_``__name``_r (                                           \
    .ready_i ( __req.r_ready  ),                                                  \
    .valid_i ( __resp.r_valid ),                                                  \
    .data_i  ( __resp.r       )                                                   \
  );
`endif
`ifndef AXI_TYPEDEF_SVH_
`define AXI_TYPEDEF_SVH_
`define AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)  \
  typedef struct packed {                                       \
    id_t              id;                                       \
    addr_t            addr;                                     \
    axi_pkg::len_t    len;                                      \
    axi_pkg::size_t   size;                                     \
    axi_pkg::burst_t  burst;                                    \
    logic             lock;                                     \
    axi_pkg::cache_t  cache;                                    \
    axi_pkg::prot_t   prot;                                     \
    axi_pkg::qos_t    qos;                                      \
    axi_pkg::region_t region;                                   \
    axi_pkg::atop_t   atop;                                     \
    user_t            user;                                     \
  } aw_chan_t;
`define AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)  \
  typedef struct packed {                                       \
    data_t data;                                                \
    strb_t strb;                                                \
    logic  last;                                                \
    user_t user;                                                \
  } w_chan_t;
`define AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)  \
  typedef struct packed {                             \
    id_t            id;                               \
    axi_pkg::resp_t resp;                             \
    user_t          user;                             \
  } b_chan_t;
`define AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)  \
  typedef struct packed {                                       \
    id_t              id;                                       \
    addr_t            addr;                                     \
    axi_pkg::len_t    len;                                      \
    axi_pkg::size_t   size;                                     \
    axi_pkg::burst_t  burst;                                    \
    logic             lock;                                     \
    axi_pkg::cache_t  cache;                                    \
    axi_pkg::prot_t   prot;                                     \
    axi_pkg::qos_t    qos;                                      \
    axi_pkg::region_t region;                                   \
    user_t            user;                                     \
  } ar_chan_t;
`define AXI_TYPEDEF_R_CHAN_T(r_chan_t, data_t, id_t, user_t)  \
  typedef struct packed {                                     \
    id_t            id;                                       \
    data_t          data;                                     \
    axi_pkg::resp_t resp;                                     \
    logic           last;                                     \
    user_t          user;                                     \
  } r_chan_t;
`define AXI_TYPEDEF_REQ_T(req_t, aw_chan_t, w_chan_t, ar_chan_t)  \
  typedef struct packed {                                         \
    aw_chan_t aw;                                                 \
    logic     aw_valid;                                           \
    w_chan_t  w;                                                  \
    logic     w_valid;                                            \
    logic     b_ready;                                            \
    ar_chan_t ar;                                                 \
    logic     ar_valid;                                           \
    logic     r_ready;                                            \
  } req_t;
`define AXI_TYPEDEF_RESP_T(resp_t, b_chan_t, r_chan_t)  \
  typedef struct packed {                               \
    logic     aw_ready;                                 \
    logic     ar_ready;                                 \
    logic     w_ready;                                  \
    logic     b_valid;                                  \
    b_chan_t  b;                                        \
    logic     r_valid;                                  \
    r_chan_t  r;                                        \
  } resp_t;
`define AXI_TYPEDEF_ALL_CT(__name, __req, __rsp, __addr_t, __id_t, __data_t, __strb_t, __user_t) \
  `AXI_TYPEDEF_AW_CHAN_T(__name``_aw_chan_t, __addr_t, __id_t, __user_t)                         \
  `AXI_TYPEDEF_W_CHAN_T(__name``_w_chan_t, __data_t, __strb_t, __user_t)                         \
  `AXI_TYPEDEF_B_CHAN_T(__name``_b_chan_t, __id_t, __user_t)                                     \
  `AXI_TYPEDEF_AR_CHAN_T(__name``_ar_chan_t, __addr_t, __id_t, __user_t)                         \
  `AXI_TYPEDEF_R_CHAN_T(__name``_r_chan_t, __data_t, __id_t, __user_t)                           \
  `AXI_TYPEDEF_REQ_T(__req, __name``_aw_chan_t, __name``_w_chan_t, __name``_ar_chan_t)           \
  `AXI_TYPEDEF_RESP_T(__rsp, __name``_b_chan_t, __name``_r_chan_t)
`define AXI_TYPEDEF_ALL(__name, __addr_t, __id_t, __data_t, __strb_t, __user_t)                                \
  `AXI_TYPEDEF_ALL_CT(__name, __name``_req_t, __name``_resp_t, __addr_t, __id_t, __data_t, __strb_t, __user_t)
`define AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_lite_t, addr_t)  \
  typedef struct packed {                                   \
    addr_t          addr;                                   \
    axi_pkg::prot_t prot;                                   \
  } aw_chan_lite_t;
`define AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_lite_t, data_t, strb_t)  \
  typedef struct packed {                                         \
    data_t   data;                                                \
    strb_t   strb;                                                \
  } w_chan_lite_t;
`define AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_lite_t)  \
  typedef struct packed {                         \
    axi_pkg::resp_t resp;                         \
  } b_chan_lite_t;
`define AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_lite_t, addr_t)  \
  typedef struct packed {                                   \
    addr_t          addr;                                   \
    axi_pkg::prot_t prot;                                   \
  } ar_chan_lite_t;
`define AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_lite_t, data_t)  \
  typedef struct packed {                                 \
    data_t          data;                                 \
    axi_pkg::resp_t resp;                                 \
  } r_chan_lite_t;
`define AXI_LITE_TYPEDEF_REQ_T(req_lite_t, aw_chan_lite_t, w_chan_lite_t, ar_chan_lite_t)  \
  typedef struct packed {                                                                  \
    aw_chan_lite_t aw;                                                                     \
    logic          aw_valid;                                                               \
    w_chan_lite_t  w;                                                                      \
    logic          w_valid;                                                                \
    logic          b_ready;                                                                \
    ar_chan_lite_t ar;                                                                     \
    logic          ar_valid;                                                               \
    logic          r_ready;                                                                \
  } req_lite_t;
`define AXI_LITE_TYPEDEF_RESP_T(resp_lite_t, b_chan_lite_t, r_chan_lite_t)  \
  typedef struct packed {                                                   \
    logic          aw_ready;                                                \
    logic          w_ready;                                                 \
    b_chan_lite_t  b;                                                       \
    logic          b_valid;                                                 \
    logic          ar_ready;                                                \
    r_chan_lite_t  r;                                                       \
    logic          r_valid;                                                 \
  } resp_lite_t;
`define AXI_LITE_TYPEDEF_ALL_CT(__name, __req, __rsp, __addr_t, __data_t, __strb_t)         \
  `AXI_LITE_TYPEDEF_AW_CHAN_T(__name``_aw_chan_t, __addr_t)                                 \
  `AXI_LITE_TYPEDEF_W_CHAN_T(__name``_w_chan_t, __data_t, __strb_t)                         \
  `AXI_LITE_TYPEDEF_B_CHAN_T(__name``_b_chan_t)                                             \
  `AXI_LITE_TYPEDEF_AR_CHAN_T(__name``_ar_chan_t, __addr_t)                                 \
  `AXI_LITE_TYPEDEF_R_CHAN_T(__name``_r_chan_t, __data_t)                                   \
  `AXI_LITE_TYPEDEF_REQ_T(__req, __name``_aw_chan_t, __name``_w_chan_t, __name``_ar_chan_t) \
  `AXI_LITE_TYPEDEF_RESP_T(__rsp, __name``_b_chan_t, __name``_r_chan_t)
`define AXI_LITE_TYPEDEF_ALL(__name, __addr_t, __data_t, __strb_t)                                \
  `AXI_LITE_TYPEDEF_ALL_CT(__name, __name``_req_t, __name``_resp_t, __addr_t, __data_t, __strb_t)
`endif
module axi_lite_mux_intf #(
  parameter int unsigned AxiAddrWidth  = 32'd0,
  parameter int unsigned AxiDataWidth  = 32'd0,
  parameter int unsigned NoSlvPorts    = 32'd0, 
  
  parameter int unsigned MaxTrans      = 32'd0,
  
  parameter bit          FallThrough   = 1'b0,
  
  parameter bit          SpillAw       = 1'b1,
  parameter bit          SpillW        = 1'b0,
  parameter bit          SpillB        = 1'b0,
  
  parameter bit          SpillAr       = 1'b1,
  parameter bit          SpillR        = 1'b0
) (
  input  logic    clk_i,                
  input  logic    rst_ni,               
  input  logic    test_i,               
  AXI_LITE.Slave  slv [NoSlvPorts-1:0], 
  AXI_LITE.Master mst                   
);
  typedef logic [AxiAddrWidth-1:0]   addr_t;
  typedef logic [AxiDataWidth-1:0]   data_t;
  typedef logic [AxiDataWidth/8-1:0] strb_t;
  
  `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t)
  `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t)
  `AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_t)
  `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t)
  `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_t, data_t)
  `AXI_LITE_TYPEDEF_REQ_T(axi_req_t, aw_chan_t, w_chan_t, ar_chan_t)
  `AXI_LITE_TYPEDEF_RESP_T(axi_resp_t, b_chan_t, r_chan_t)
  axi_req_t     [NoSlvPorts-1:0] slv_reqs;
  axi_resp_t    [NoSlvPorts-1:0] slv_resps;
  axi_req_t                      mst_req;
  axi_resp_t                     mst_resp;
  for (genvar i = 0; i < NoSlvPorts; i++) begin : gen_assign_slv_ports
    `AXI_LITE_ASSIGN_TO_REQ(slv_reqs[i], slv[i])
    `AXI_LITE_ASSIGN_FROM_RESP(slv[i], slv_resps[i])
  end
  `AXI_LITE_ASSIGN_FROM_REQ(mst, mst_req)
  `AXI_LITE_ASSIGN_TO_RESP(mst_resp, mst)
  axi_lite_mux #(
    .aw_chan_t     ( aw_chan_t     ), 
    .w_chan_t      (  w_chan_t     ), 
    .b_chan_t      (  b_chan_t     ), 
    .ar_chan_t     ( ar_chan_t     ), 
    .r_chan_t      (  r_chan_t     ), 
    .axi_req_t     ( axi_req_t     ),
    .axi_resp_t    ( axi_resp_t    ),
    .NoSlvPorts    ( NoSlvPorts    ), 
    .MaxTrans      ( MaxTrans      ),
    .FallThrough   ( FallThrough   ),
    .SpillAw       ( SpillAw       ),
    .SpillW        ( SpillW        ),
    .SpillB        ( SpillB        ),
    .SpillAr       ( SpillAr       ),
    .SpillR        ( SpillR        )
  ) i_axi_mux (
    .clk_i,  
    .rst_ni, 
    .test_i, 
    .slv_reqs_i  ( slv_reqs  ),
    .slv_resps_o ( slv_resps ),
    .mst_req_o   ( mst_req   ),
    .mst_resp_i  ( mst_resp  )
  );
  
  `ifndef VERILATOR
    initial begin: p_assertions
      AddrWidth: assert (AxiAddrWidth > 0) else $fatal("Axi Parameter has to be > 0!");
      DataWidth: assert (AxiDataWidth > 0) else $fatal("Axi Parameter has to be > 0!");
    end
  `endif
  
endmodule

module axi_lite_to_axi #(
  parameter int unsigned AxiDataWidth = 32'd0,
  
  parameter type  req_lite_t = logic,
  parameter type resp_lite_t = logic,
  
  parameter type   axi_req_t = logic,
  parameter type  axi_resp_t = logic
) (
  
  input  req_lite_t       slv_req_lite_i,
  output resp_lite_t      slv_resp_lite_o,
  input  axi_pkg::cache_t slv_aw_cache_i,
  input  axi_pkg::cache_t slv_ar_cache_i,
  
  output axi_req_t        mst_req_o,
  input  axi_resp_t       mst_resp_i
);
  localparam int unsigned AxiSize = axi_pkg::size_t'($unsigned($clog2(AxiDataWidth/8)));
  
  assign mst_req_o = '{
    aw: '{
      addr:  slv_req_lite_i.aw.addr,
      prot:  slv_req_lite_i.aw.prot,
      size:  AxiSize,
      burst: axi_pkg::BURST_FIXED,
      cache: slv_aw_cache_i,
      default: '0
    },
    aw_valid: slv_req_lite_i.aw_valid,
    w: '{
      data: slv_req_lite_i.w.data,
      strb: slv_req_lite_i.w.strb,
      last: 1'b1,
      default: '0
    },
    w_valid: slv_req_lite_i.w_valid,
    b_ready: slv_req_lite_i.b_ready,
    ar: '{
      addr:  slv_req_lite_i.ar.addr,
      prot:  slv_req_lite_i.ar.prot,
      size:  AxiSize,
      burst: axi_pkg::BURST_FIXED,
      cache: slv_ar_cache_i,
      default: '0
    },
    ar_valid: slv_req_lite_i.ar_valid,
    r_ready:  slv_req_lite_i.r_ready,
    default:   '0
  };
  
  assign slv_resp_lite_o = '{
    aw_ready: mst_resp_i.aw_ready,
    w_ready:  mst_resp_i.w_ready,
    b: '{
      resp: mst_resp_i.b.resp,
      default: '0
    },
    b_valid:  mst_resp_i.b_valid,
    ar_ready: mst_resp_i.ar_ready,
    r: '{
      data: mst_resp_i.r.data,
      resp: mst_resp_i.r.resp,
      default: '0
    },
    r_valid: mst_resp_i.r_valid,
    default: '0
  };
  
  `ifndef VERILATOR
  initial begin
    assert (AxiDataWidth > 0) else $fatal(1, "Data width must be non-zero!");
  end
  `endif
  
endmodule
module axi_lite_to_axi_intf #(
  parameter int unsigned AXI_DATA_WIDTH = 32'd0
) (
  AXI_LITE.Slave  in,
  input axi_pkg::cache_t slv_aw_cache_i,
  input axi_pkg::cache_t slv_ar_cache_i,
  AXI_BUS.Master  out
);
  localparam int unsigned AxiSize = axi_pkg::size_t'($unsigned($clog2(AXI_DATA_WIDTH/8)));
  initial begin
    assert(in.AXI_ADDR_WIDTH == out.AXI_ADDR_WIDTH);
    assert(in.AXI_DATA_WIDTH == out.AXI_DATA_WIDTH);
    assert(AXI_DATA_WIDTH    == out.AXI_DATA_WIDTH);
  end
  assign out.aw_id     = '0;
  assign out.aw_addr   = in.aw_addr;
  assign out.aw_len    = '0;
  assign out.aw_size   = axi_pkg::size_t'(AxiSize);
  assign out.aw_burst  = axi_pkg::BURST_FIXED;
  assign out.aw_lock   = '0;
  assign out.aw_cache  = slv_aw_cache_i;
  assign out.aw_prot   = '0;
  assign out.aw_qos    = '0;
  assign out.aw_region = '0;
  assign out.aw_atop   = '0;
  assign out.aw_user   = '0;
  assign out.aw_valid  = in.aw_valid;
  assign in.aw_ready   = out.aw_ready;
  assign out.w_data    = in.w_data;
  assign out.w_strb    = in.w_strb;
  assign out.w_last    = '1;
  assign out.w_user    = '0;
  assign out.w_valid   = in.w_valid;
  assign in.w_ready    = out.w_ready;
  assign in.b_resp     = out.b_resp;
  assign in.b_valid    = out.b_valid;
  assign out.b_ready   = in.b_ready;
  assign out.ar_id     = '0;
  assign out.ar_addr   = in.ar_addr;
  assign out.ar_len    = '0;
  assign out.ar_size   = axi_pkg::size_t'(AxiSize);
  assign out.ar_burst  = axi_pkg::BURST_FIXED;
  assign out.ar_lock   = '0;
  assign out.ar_cache  = slv_ar_cache_i;
  assign out.ar_prot   = '0;
  assign out.ar_qos    = '0;
  assign out.ar_region = '0;
  assign out.ar_user   = '0;
  assign out.ar_valid  = in.ar_valid;
  assign in.ar_ready   = out.ar_ready;
  assign in.r_data     = out.r_data;
  assign in.r_resp     = out.r_resp;
  assign in.r_valid    = out.r_valid;
  assign out.r_ready   = in.r_ready;
endmodule

`ifndef AXI_TYPEDEF_SVH_
`define AXI_TYPEDEF_SVH_
`define AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)  \
  typedef struct packed {                                       \
    id_t              id;                                       \
    addr_t            addr;                                     \
    axi_pkg::len_t    len;                                      \
    axi_pkg::size_t   size;                                     \
    axi_pkg::burst_t  burst;                                    \
    logic             lock;                                     \
    axi_pkg::cache_t  cache;                                    \
    axi_pkg::prot_t   prot;                                     \
    axi_pkg::qos_t    qos;                                      \
    axi_pkg::region_t region;                                   \
    axi_pkg::atop_t   atop;                                     \
    user_t            user;                                     \
  } aw_chan_t;
`define AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)  \
  typedef struct packed {                                       \
    data_t data;                                                \
    strb_t strb;                                                \
    logic  last;                                                \
    user_t user;                                                \
  } w_chan_t;
`define AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)  \
  typedef struct packed {                             \
    id_t            id;                               \
    axi_pkg::resp_t resp;                             \
    user_t          user;                             \
  } b_chan_t;
`define AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)  \
  typedef struct packed {                                       \
    id_t              id;                                       \
    addr_t            addr;                                     \
    axi_pkg::len_t    len;                                      \
    axi_pkg::size_t   size;                                     \
    axi_pkg::burst_t  burst;                                    \
    logic             lock;                                     \
    axi_pkg::cache_t  cache;                                    \
    axi_pkg::prot_t   prot;                                     \
    axi_pkg::qos_t    qos;                                      \
    axi_pkg::region_t region;                                   \
    user_t            user;                                     \
  } ar_chan_t;
`define AXI_TYPEDEF_R_CHAN_T(r_chan_t, data_t, id_t, user_t)  \
  typedef struct packed {                                     \
    id_t            id;                                       \
    data_t          data;                                     \
    axi_pkg::resp_t resp;                                     \
    logic           last;                                     \
    user_t          user;                                     \
  } r_chan_t;
`define AXI_TYPEDEF_REQ_T(req_t, aw_chan_t, w_chan_t, ar_chan_t)  \
  typedef struct packed {                                         \
    aw_chan_t aw;                                                 \
    logic     aw_valid;                                           \
    w_chan_t  w;                                                  \
    logic     w_valid;                                            \
    logic     b_ready;                                            \
    ar_chan_t ar;                                                 \
    logic     ar_valid;                                           \
    logic     r_ready;                                            \
  } req_t;
`define AXI_TYPEDEF_RESP_T(resp_t, b_chan_t, r_chan_t)  \
  typedef struct packed {                               \
    logic     aw_ready;                                 \
    logic     ar_ready;                                 \
    logic     w_ready;                                  \
    logic     b_valid;                                  \
    b_chan_t  b;                                        \
    logic     r_valid;                                  \
    r_chan_t  r;                                        \
  } resp_t;
`define AXI_TYPEDEF_ALL_CT(__name, __req, __rsp, __addr_t, __id_t, __data_t, __strb_t, __user_t) \
  `AXI_TYPEDEF_AW_CHAN_T(__name``_aw_chan_t, __addr_t, __id_t, __user_t)                         \
  `AXI_TYPEDEF_W_CHAN_T(__name``_w_chan_t, __data_t, __strb_t, __user_t)                         \
  `AXI_TYPEDEF_B_CHAN_T(__name``_b_chan_t, __id_t, __user_t)                                     \
  `AXI_TYPEDEF_AR_CHAN_T(__name``_ar_chan_t, __addr_t, __id_t, __user_t)                         \
  `AXI_TYPEDEF_R_CHAN_T(__name``_r_chan_t, __data_t, __id_t, __user_t)                           \
  `AXI_TYPEDEF_REQ_T(__req, __name``_aw_chan_t, __name``_w_chan_t, __name``_ar_chan_t)           \
  `AXI_TYPEDEF_RESP_T(__rsp, __name``_b_chan_t, __name``_r_chan_t)
`define AXI_TYPEDEF_ALL(__name, __addr_t, __id_t, __data_t, __strb_t, __user_t)                                \
  `AXI_TYPEDEF_ALL_CT(__name, __name``_req_t, __name``_resp_t, __addr_t, __id_t, __data_t, __strb_t, __user_t)
`define AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_lite_t, addr_t)  \
  typedef struct packed {                                   \
    addr_t          addr;                                   \
    axi_pkg::prot_t prot;                                   \
  } aw_chan_lite_t;
`define AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_lite_t, data_t, strb_t)  \
  typedef struct packed {                                         \
    data_t   data;                                                \
    strb_t   strb;                                                \
  } w_chan_lite_t;
`define AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_lite_t)  \
  typedef struct packed {                         \
    axi_pkg::resp_t resp;                         \
  } b_chan_lite_t;
`define AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_lite_t, addr_t)  \
  typedef struct packed {                                   \
    addr_t          addr;                                   \
    axi_pkg::prot_t prot;                                   \
  } ar_chan_lite_t;
`define AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_lite_t, data_t)  \
  typedef struct packed {                                 \
    data_t          data;                                 \
    axi_pkg::resp_t resp;                                 \
  } r_chan_lite_t;
`define AXI_LITE_TYPEDEF_REQ_T(req_lite_t, aw_chan_lite_t, w_chan_lite_t, ar_chan_lite_t)  \
  typedef struct packed {                                                                  \
    aw_chan_lite_t aw;                                                                     \
    logic          aw_valid;                                                               \
    w_chan_lite_t  w;                                                                      \
    logic          w_valid;                                                                \
    logic          b_ready;                                                                \
    ar_chan_lite_t ar;                                                                     \
    logic          ar_valid;                                                               \
    logic          r_ready;                                                                \
  } req_lite_t;
`define AXI_LITE_TYPEDEF_RESP_T(resp_lite_t, b_chan_lite_t, r_chan_lite_t)  \
  typedef struct packed {                                                   \
    logic          aw_ready;                                                \
    logic          w_ready;                                                 \
    b_chan_lite_t  b;                                                       \
    logic          b_valid;                                                 \
    logic          ar_ready;                                                \
    r_chan_lite_t  r;                                                       \
    logic          r_valid;                                                 \
  } resp_lite_t;
`define AXI_LITE_TYPEDEF_ALL_CT(__name, __req, __rsp, __addr_t, __data_t, __strb_t)         \
  `AXI_LITE_TYPEDEF_AW_CHAN_T(__name``_aw_chan_t, __addr_t)                                 \
  `AXI_LITE_TYPEDEF_W_CHAN_T(__name``_w_chan_t, __data_t, __strb_t)                         \
  `AXI_LITE_TYPEDEF_B_CHAN_T(__name``_b_chan_t)                                             \
  `AXI_LITE_TYPEDEF_AR_CHAN_T(__name``_ar_chan_t, __addr_t)                                 \
  `AXI_LITE_TYPEDEF_R_CHAN_T(__name``_r_chan_t, __data_t)                                   \
  `AXI_LITE_TYPEDEF_REQ_T(__req, __name``_aw_chan_t, __name``_w_chan_t, __name``_ar_chan_t) \
  `AXI_LITE_TYPEDEF_RESP_T(__rsp, __name``_b_chan_t, __name``_r_chan_t)
`define AXI_LITE_TYPEDEF_ALL(__name, __addr_t, __data_t, __strb_t)                                \
  `AXI_LITE_TYPEDEF_ALL_CT(__name, __name``_req_t, __name``_resp_t, __addr_t, __data_t, __strb_t)
`endif
module TopModule #(
  parameter axi_pkg::xbar_cfg_t Cfg = '0,
  parameter type  aw_chan_t         = logic,
  parameter type   w_chan_t         = logic,
  parameter type   b_chan_t         = logic,
  parameter type  ar_chan_t         = logic,
  parameter type   r_chan_t         = logic,
  parameter type  axi_req_t         = logic,
  parameter type axi_resp_t         = logic,
  parameter type     rule_t         = axi_pkg::xbar_rule_64_t,
  
  parameter int unsigned MstIdxWidth = (Cfg.NoMstPorts > 32'd1) ? $clog2(Cfg.NoMstPorts) : 32'd1
) (
  input  logic                                        clk_i,
  input  logic                                        rst_ni,
  input  logic                                        test_i,
  input  axi_req_t  [Cfg.NoSlvPorts-1:0]              slv_ports_req_i,
  output axi_resp_t [Cfg.NoSlvPorts-1:0]              slv_ports_resp_o,
  output axi_req_t  [Cfg.NoMstPorts-1:0]              mst_ports_req_o,
  input  axi_resp_t [Cfg.NoMstPorts-1:0]              mst_ports_resp_i,
  input  rule_t [Cfg.NoAddrRules-1:0]                 addr_map_i,
  input  logic  [Cfg.NoSlvPorts-1:0]                  en_default_mst_port_i,
  input  logic  [Cfg.NoSlvPorts-1:0][MstIdxWidth-1:0] default_mst_port_i
);
  typedef logic [Cfg.AxiAddrWidth-1:0]   addr_t;
  typedef logic [Cfg.AxiDataWidth-1:0]   data_t;
  typedef logic [Cfg.AxiDataWidth/8-1:0] strb_t;
  
  typedef logic [$clog2(Cfg.NoMstPorts + 1)-1:0] mst_port_idx_t;
  
  
  `AXI_TYPEDEF_AW_CHAN_T(full_aw_chan_t, addr_t, logic, logic)
  `AXI_TYPEDEF_W_CHAN_T(full_w_chan_t, data_t, strb_t, logic)
  `AXI_TYPEDEF_B_CHAN_T(full_b_chan_t, logic, logic)
  `AXI_TYPEDEF_AR_CHAN_T(full_ar_chan_t, addr_t, logic, logic)
  `AXI_TYPEDEF_R_CHAN_T(full_r_chan_t, data_t, logic, logic)
  `AXI_TYPEDEF_REQ_T(full_req_t, full_aw_chan_t, full_w_chan_t, full_ar_chan_t)
  `AXI_TYPEDEF_RESP_T(full_resp_t, full_b_chan_t, full_r_chan_t)
  
  axi_req_t  [Cfg.NoSlvPorts-1:0][Cfg.NoMstPorts:0] slv_reqs;
  axi_resp_t [Cfg.NoSlvPorts-1:0][Cfg.NoMstPorts:0] slv_resps;
  
  axi_req_t  [Cfg.NoMstPorts-1:0][Cfg.NoSlvPorts-1:0] mst_reqs;
  axi_resp_t [Cfg.NoMstPorts-1:0][Cfg.NoSlvPorts-1:0] mst_resps;
  for (genvar i = 0; i < Cfg.NoSlvPorts; i++) begin : gen_slv_port_demux
    logic [MstIdxWidth-1:0] dec_aw,        dec_ar;
    mst_port_idx_t          slv_aw_select, slv_ar_select;
    logic                   dec_aw_error;
    logic                   dec_ar_error;
    full_req_t  decerr_req;
    full_resp_t decerr_resp;
    addr_decode #(
      .NoIndices  ( Cfg.NoMstPorts  ),
      .NoRules    ( Cfg.NoAddrRules ),
      .addr_t     ( addr_t          ),
      .rule_t     ( rule_t          )
    ) i_axi_aw_decode (
      .addr_i           ( slv_ports_req_i[i].aw.addr ),
      .addr_map_i       ( addr_map_i                 ),
      .idx_o            ( dec_aw                     ),
      .dec_valid_o      (                ),
      .dec_error_o      ( dec_aw_error               ),
      .en_default_idx_i ( en_default_mst_port_i[i]   ),
      .default_idx_i    ( default_mst_port_i[i]      )
    );
    addr_decode #(
      .NoIndices  ( Cfg.NoMstPorts  ),
      .addr_t     ( addr_t          ),
      .NoRules    ( Cfg.NoAddrRules ),
      .rule_t     ( rule_t          )
    ) i_axi_ar_decode (
      .addr_i           ( slv_ports_req_i[i].ar.addr ),
      .addr_map_i       ( addr_map_i                 ),
      .idx_o            ( dec_ar                     ),
      .dec_valid_o      (                ),
      .dec_error_o      ( dec_ar_error               ),
      .en_default_idx_i ( en_default_mst_port_i[i]   ),
      .default_idx_i    ( default_mst_port_i[i]      )
    );
    assign slv_aw_select = (dec_aw_error) ?
        mst_port_idx_t'(Cfg.NoMstPorts) : mst_port_idx_t'(dec_aw);
    assign slv_ar_select = (dec_ar_error) ?
        mst_port_idx_t'(Cfg.NoMstPorts) : mst_port_idx_t'(dec_ar);
    
    
    `ifndef VERILATOR
    default disable iff (~rst_ni);
    default_aw_mst_port_en: assert property(
      @(posedge clk_i) (slv_ports_req_i[i].aw_valid && !slv_ports_resp_o[i].aw_ready)
          |=> $stable(en_default_mst_port_i[i]))
        else $fatal (1, $sformatf("It is not allowed to change the default mst port\
                                   enable, when there is an unserved Aw beat. Slave Port: %0d", i));
    default_aw_mst_port: assert property(
      @(posedge clk_i) (slv_ports_req_i[i].aw_valid && !slv_ports_resp_o[i].aw_ready)
          |=> $stable(default_mst_port_i[i]))
        else $fatal (1, $sformatf("It is not allowed to change the default mst port\
                                   when there is an unserved Aw beat. Slave Port: %0d", i));
    default_ar_mst_port_en: assert property(
      @(posedge clk_i) (slv_ports_req_i[i].ar_valid && !slv_ports_resp_o[i].ar_ready)
          |=> $stable(en_default_mst_port_i[i]))
        else $fatal (1, $sformatf("It is not allowed to change the enable, when\
                                   there is an unserved Ar beat. Slave Port: %0d", i));
    default_ar_mst_port: assert property(
      @(posedge clk_i) (slv_ports_req_i[i].ar_valid && !slv_ports_resp_o[i].ar_ready)
          |=> $stable(default_mst_port_i[i]))
        else $fatal (1, $sformatf("It is not allowed to change the default mst port\
                                   when there is an unserved Ar beat. Slave Port: %0d", i));
    `endif
    
    axi_lite_demux #(
      .aw_chan_t      ( aw_chan_t          ),  
      .w_chan_t       (  w_chan_t          ),  
      .b_chan_t       (  b_chan_t          ),  
      .ar_chan_t      ( ar_chan_t          ),  
      .r_chan_t       (  r_chan_t          ),  
      .axi_req_t      ( axi_req_t          ),
      .axi_resp_t     ( axi_resp_t         ),
      .NoMstPorts     ( Cfg.NoMstPorts + 1 ),
      .MaxTrans       ( Cfg.MaxMstTrans    ),
      .FallThrough    ( Cfg.FallThrough    ),
      .SpillAw        ( Cfg.LatencyMode[9] ),
      .SpillW         ( Cfg.LatencyMode[8] ),
      .SpillB         ( Cfg.LatencyMode[7] ),
      .SpillAr        ( Cfg.LatencyMode[6] ),
      .SpillR         ( Cfg.LatencyMode[5] )
    ) i_axi_lite_demux (
      .clk_i,   
      .rst_ni,  
      .test_i,  
      .slv_req_i       ( slv_ports_req_i[i]  ),
      .slv_aw_select_i ( slv_aw_select       ),
      .slv_ar_select_i ( slv_ar_select       ),
      .slv_resp_o      ( slv_ports_resp_o[i] ),
      .mst_reqs_o      ( slv_reqs[i]         ),
      .mst_resps_i     ( slv_resps[i]        )
    );
    
    
    axi_lite_to_axi #(
      .AxiDataWidth ( Cfg.AxiDataWidth  ),
      .req_lite_t   ( axi_req_t         ),
      .resp_lite_t  ( axi_resp_t        ),
      .axi_req_t    ( full_req_t        ),
      .axi_resp_t   ( full_resp_t       )
    ) i_dec_err_conv (
      .slv_req_lite_i  ( slv_reqs[i][Cfg.NoMstPorts]  ),
      .slv_resp_lite_o ( slv_resps[i][Cfg.NoMstPorts] ),
      .slv_aw_cache_i  ( 4'd0                         ),
      .slv_ar_cache_i  ( 4'd0                         ),
      .mst_req_o       ( decerr_req                   ),
      .mst_resp_i      ( decerr_resp                  )
    );
    axi_err_slv #(
      .AxiIdWidth  ( 32'd1                ), 
      .axi_req_t   ( full_req_t           ), 
      .axi_resp_t  ( full_resp_t          ), 
      .Resp        ( axi_pkg::RESP_DECERR ),
      .ATOPs       ( 1'b0                 ), 
      .MaxTrans    ( 1                    )  
                                             
    ) i_axi_err_slv (
      .clk_i      ( clk_i       ),  
      .rst_ni     ( rst_ni      ),  
      .test_i     ( test_i      ),  
      
      .slv_req_i  ( decerr_req  ),
      .slv_resp_o ( decerr_resp )
    );
  end
  
  for (genvar i = 0; i < Cfg.NoSlvPorts; i++) begin : gen_xbar_slv_cross
    for (genvar j = 0; j < Cfg.NoMstPorts; j++) begin : gen_xbar_mst_cross
      assign mst_reqs[j][i]  = slv_reqs[i][j];
      assign slv_resps[i][j] = mst_resps[j][i];
    end
  end
  for (genvar i = 0; i < Cfg.NoMstPorts; i++) begin : gen_mst_port_mux
    axi_lite_mux #(
      .aw_chan_t   ( aw_chan_t          ), 
      .w_chan_t    (  w_chan_t          ), 
      .b_chan_t    (  b_chan_t          ), 
      .ar_chan_t   ( ar_chan_t          ), 
      .r_chan_t    (  r_chan_t          ), 
      .axi_req_t   ( axi_req_t          ),
      .axi_resp_t  ( axi_resp_t         ),
      .NoSlvPorts  ( Cfg.NoSlvPorts     ), 
      .MaxTrans    ( Cfg.MaxSlvTrans    ),
      .FallThrough ( Cfg.FallThrough    ),
      .SpillAw     ( Cfg.LatencyMode[4] ),
      .SpillW      ( Cfg.LatencyMode[3] ),
      .SpillB      ( Cfg.LatencyMode[2] ),
      .SpillAr     ( Cfg.LatencyMode[1] ),
      .SpillR      ( Cfg.LatencyMode[0] )
    ) i_axi_lite_mux (
      .clk_i,  
      .rst_ni, 
      .test_i, 
      .slv_reqs_i  ( mst_reqs[i]         ),
      .slv_resps_o ( mst_resps[i]        ),
      .mst_req_o   ( mst_ports_req_o[i]  ),
      .mst_resp_i  ( mst_ports_resp_i[i] )
    );
  end
endmodule
`ifndef AXI_ASSIGN_SVH_
`define AXI_ASSIGN_SVH_
`define __AXI_TO_AW(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)   \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``addr   = __rhs``__rhs_sep``addr;       \
  __opt_as __lhs``__lhs_sep``len    = __rhs``__rhs_sep``len;        \
  __opt_as __lhs``__lhs_sep``size   = __rhs``__rhs_sep``size;       \
  __opt_as __lhs``__lhs_sep``burst  = __rhs``__rhs_sep``burst;      \
  __opt_as __lhs``__lhs_sep``lock   = __rhs``__rhs_sep``lock;       \
  __opt_as __lhs``__lhs_sep``cache  = __rhs``__rhs_sep``cache;      \
  __opt_as __lhs``__lhs_sep``prot   = __rhs``__rhs_sep``prot;       \
  __opt_as __lhs``__lhs_sep``qos    = __rhs``__rhs_sep``qos;        \
  __opt_as __lhs``__lhs_sep``region = __rhs``__rhs_sep``region;     \
  __opt_as __lhs``__lhs_sep``atop   = __rhs``__rhs_sep``atop;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_W(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``data   = __rhs``__rhs_sep``data;       \
  __opt_as __lhs``__lhs_sep``strb   = __rhs``__rhs_sep``strb;       \
  __opt_as __lhs``__lhs_sep``last   = __rhs``__rhs_sep``last;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_B(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``resp   = __rhs``__rhs_sep``resp;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_AR(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)   \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``addr   = __rhs``__rhs_sep``addr;       \
  __opt_as __lhs``__lhs_sep``len    = __rhs``__rhs_sep``len;        \
  __opt_as __lhs``__lhs_sep``size   = __rhs``__rhs_sep``size;       \
  __opt_as __lhs``__lhs_sep``burst  = __rhs``__rhs_sep``burst;      \
  __opt_as __lhs``__lhs_sep``lock   = __rhs``__rhs_sep``lock;       \
  __opt_as __lhs``__lhs_sep``cache  = __rhs``__rhs_sep``cache;      \
  __opt_as __lhs``__lhs_sep``prot   = __rhs``__rhs_sep``prot;       \
  __opt_as __lhs``__lhs_sep``qos    = __rhs``__rhs_sep``qos;        \
  __opt_as __lhs``__lhs_sep``region = __rhs``__rhs_sep``region;     \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_R(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``data   = __rhs``__rhs_sep``data;       \
  __opt_as __lhs``__lhs_sep``resp   = __rhs``__rhs_sep``resp;       \
  __opt_as __lhs``__lhs_sep``last   = __rhs``__rhs_sep``last;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_REQ(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)  \
  `__AXI_TO_AW(__opt_as, __lhs.aw, __lhs_sep, __rhs.aw, __rhs_sep)  \
  __opt_as __lhs.aw_valid = __rhs.aw_valid;                         \
  `__AXI_TO_W(__opt_as, __lhs.w, __lhs_sep, __rhs.w, __rhs_sep)     \
  __opt_as __lhs.w_valid = __rhs.w_valid;                           \
  __opt_as __lhs.b_ready = __rhs.b_ready;                           \
  `__AXI_TO_AR(__opt_as, __lhs.ar, __lhs_sep, __rhs.ar, __rhs_sep)  \
  __opt_as __lhs.ar_valid = __rhs.ar_valid;                         \
  __opt_as __lhs.r_ready = __rhs.r_ready;
`define __AXI_TO_RESP(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs.aw_ready = __rhs.aw_ready;                         \
  __opt_as __lhs.ar_ready = __rhs.ar_ready;                         \
  __opt_as __lhs.w_ready = __rhs.w_ready;                           \
  __opt_as __lhs.b_valid = __rhs.b_valid;                           \
  `__AXI_TO_B(__opt_as, __lhs.b, __lhs_sep, __rhs.b, __rhs_sep)     \
  __opt_as __lhs.r_valid = __rhs.r_valid;                           \
  `__AXI_TO_R(__opt_as, __lhs.r, __lhs_sep, __rhs.r, __rhs_sep)
`define AXI_ASSIGN_AW(dst, src)               \
  `__AXI_TO_AW(assign, dst.aw, _, src.aw, _)  \
  assign dst.aw_valid = src.aw_valid;         \
  assign src.aw_ready = dst.aw_ready;
`define AXI_ASSIGN_W(dst, src)                \
  `__AXI_TO_W(assign, dst.w, _, src.w, _)     \
  assign dst.w_valid  = src.w_valid;          \
  assign src.w_ready  = dst.w_ready;
`define AXI_ASSIGN_B(dst, src)                \
  `__AXI_TO_B(assign, dst.b, _, src.b, _)     \
  assign dst.b_valid  = src.b_valid;          \
  assign src.b_ready  = dst.b_ready;
`define AXI_ASSIGN_AR(dst, src)               \
  `__AXI_TO_AR(assign, dst.ar, _, src.ar, _)  \
  assign dst.ar_valid = src.ar_valid;         \
  assign src.ar_ready = dst.ar_ready;
`define AXI_ASSIGN_R(dst, src)                \
  `__AXI_TO_R(assign, dst.r, _, src.r, _)     \
  assign dst.r_valid  = src.r_valid;          \
  assign src.r_ready  = dst.r_ready;
`define AXI_ASSIGN(slv, mst)  \
  `AXI_ASSIGN_AW(slv, mst)    \
  `AXI_ASSIGN_W(slv, mst)     \
  `AXI_ASSIGN_B(mst, slv)     \
  `AXI_ASSIGN_AR(slv, mst)    \
  `AXI_ASSIGN_R(mst, slv)
`define AXI_ASSIGN_MONITOR(mon_dv, axi_if)          \
  `__AXI_TO_AW(assign, mon_dv.aw, _, axi_if.aw, _)  \
  assign mon_dv.aw_valid  = axi_if.aw_valid;        \
  assign mon_dv.aw_ready  = axi_if.aw_ready;        \
  `__AXI_TO_W(assign, mon_dv.w, _, axi_if.w, _)     \
  assign mon_dv.w_valid   = axi_if.w_valid;         \
  assign mon_dv.w_ready   = axi_if.w_ready;         \
  `__AXI_TO_B(assign, mon_dv.b, _, axi_if.b, _)     \
  assign mon_dv.b_valid   = axi_if.b_valid;         \
  assign mon_dv.b_ready   = axi_if.b_ready;         \
  `__AXI_TO_AR(assign, mon_dv.ar, _, axi_if.ar, _)  \
  assign mon_dv.ar_valid  = axi_if.ar_valid;        \
  assign mon_dv.ar_ready  = axi_if.ar_ready;        \
  `__AXI_TO_R(assign, mon_dv.r, _, axi_if.r, _)     \
  assign mon_dv.r_valid   = axi_if.r_valid;         \
  assign mon_dv.r_ready   = axi_if.r_ready;
`define AXI_SET_FROM_AW(axi_if, aw_struct)      `__AXI_TO_AW(, axi_if.aw, _, aw_struct, .)
`define AXI_SET_FROM_W(axi_if, w_struct)        `__AXI_TO_W(, axi_if.w, _, w_struct, .)
`define AXI_SET_FROM_B(axi_if, b_struct)        `__AXI_TO_B(, axi_if.b, _, b_struct, .)
`define AXI_SET_FROM_AR(axi_if, ar_struct)      `__AXI_TO_AR(, axi_if.ar, _, ar_struct, .)
`define AXI_SET_FROM_R(axi_if, r_struct)        `__AXI_TO_R(, axi_if.r, _, r_struct, .)
`define AXI_SET_FROM_REQ(axi_if, req_struct)    `__AXI_TO_REQ(, axi_if, _, req_struct, .)
`define AXI_SET_FROM_RESP(axi_if, resp_struct)  `__AXI_TO_RESP(, axi_if, _, resp_struct, .)
`define AXI_ASSIGN_FROM_AW(axi_if, aw_struct)     `__AXI_TO_AW(assign, axi_if.aw, _, aw_struct, .)
`define AXI_ASSIGN_FROM_W(axi_if, w_struct)       `__AXI_TO_W(assign, axi_if.w, _, w_struct, .)
`define AXI_ASSIGN_FROM_B(axi_if, b_struct)       `__AXI_TO_B(assign, axi_if.b, _, b_struct, .)
`define AXI_ASSIGN_FROM_AR(axi_if, ar_struct)     `__AXI_TO_AR(assign, axi_if.ar, _, ar_struct, .)
`define AXI_ASSIGN_FROM_R(axi_if, r_struct)       `__AXI_TO_R(assign, axi_if.r, _, r_struct, .)
`define AXI_ASSIGN_FROM_REQ(axi_if, req_struct)   `__AXI_TO_REQ(assign, axi_if, _, req_struct, .)
`define AXI_ASSIGN_FROM_RESP(axi_if, resp_struct) `__AXI_TO_RESP(assign, axi_if, _, resp_struct, .)
`define AXI_SET_TO_AW(aw_struct, axi_if)     `__AXI_TO_AW(, aw_struct, ., axi_if.aw, _)
`define AXI_SET_TO_W(w_struct, axi_if)       `__AXI_TO_W(, w_struct, ., axi_if.w, _)
`define AXI_SET_TO_B(b_struct, axi_if)       `__AXI_TO_B(, b_struct, ., axi_if.b, _)
`define AXI_SET_TO_AR(ar_struct, axi_if)     `__AXI_TO_AR(, ar_struct, ., axi_if.ar, _)
`define AXI_SET_TO_R(r_struct, axi_if)       `__AXI_TO_R(, r_struct, ., axi_if.r, _)
`define AXI_SET_TO_REQ(req_struct, axi_if)   `__AXI_TO_REQ(, req_struct, ., axi_if, _)
`define AXI_SET_TO_RESP(resp_struct, axi_if) `__AXI_TO_RESP(, resp_struct, ., axi_if, _)
`define AXI_ASSIGN_TO_AW(aw_struct, axi_if)     `__AXI_TO_AW(assign, aw_struct, ., axi_if.aw, _)
`define AXI_ASSIGN_TO_W(w_struct, axi_if)       `__AXI_TO_W(assign, w_struct, ., axi_if.w, _)
`define AXI_ASSIGN_TO_B(b_struct, axi_if)       `__AXI_TO_B(assign, b_struct, ., axi_if.b, _)
`define AXI_ASSIGN_TO_AR(ar_struct, axi_if)     `__AXI_TO_AR(assign, ar_struct, ., axi_if.ar, _)
`define AXI_ASSIGN_TO_R(r_struct, axi_if)       `__AXI_TO_R(assign, r_struct, ., axi_if.r, _)
`define AXI_ASSIGN_TO_REQ(req_struct, axi_if)   `__AXI_TO_REQ(assign, req_struct, ., axi_if, _)
`define AXI_ASSIGN_TO_RESP(resp_struct, axi_if) `__AXI_TO_RESP(assign, resp_struct, ., axi_if, _)
`define AXI_SET_AW_STRUCT(lhs, rhs)     `__AXI_TO_AW(, lhs, ., rhs, .)
`define AXI_SET_W_STRUCT(lhs, rhs)       `__AXI_TO_W(, lhs, ., rhs, .)
`define AXI_SET_B_STRUCT(lhs, rhs)       `__AXI_TO_B(, lhs, ., rhs, .)
`define AXI_SET_AR_STRUCT(lhs, rhs)     `__AXI_TO_AR(, lhs, ., rhs, .)
`define AXI_SET_R_STRUCT(lhs, rhs)       `__AXI_TO_R(, lhs, ., rhs, .)
`define AXI_SET_REQ_STRUCT(lhs, rhs)   `__AXI_TO_REQ(, lhs, ., rhs, .)
`define AXI_SET_RESP_STRUCT(lhs, rhs) `__AXI_TO_RESP(, lhs, ., rhs, .)
`define AXI_ASSIGN_AW_STRUCT(lhs, rhs)     `__AXI_TO_AW(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_W_STRUCT(lhs, rhs)       `__AXI_TO_W(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_B_STRUCT(lhs, rhs)       `__AXI_TO_B(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_AR_STRUCT(lhs, rhs)     `__AXI_TO_AR(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_R_STRUCT(lhs, rhs)       `__AXI_TO_R(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_REQ_STRUCT(lhs, rhs)   `__AXI_TO_REQ(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_RESP_STRUCT(lhs, rhs) `__AXI_TO_RESP(assign, lhs, ., rhs, .)
`define __AXI_LITE_TO_AX(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)  \
  __opt_as __lhs``__lhs_sep``addr = __rhs``__rhs_sep``addr;             \
  __opt_as __lhs``__lhs_sep``prot = __rhs``__rhs_sep``prot;
`define __AXI_LITE_TO_W(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``data = __rhs``__rhs_sep``data;           \
  __opt_as __lhs``__lhs_sep``strb = __rhs``__rhs_sep``strb;
`define __AXI_LITE_TO_B(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``resp = __rhs``__rhs_sep``resp;
`define __AXI_LITE_TO_R(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  __opt_as __lhs``__lhs_sep``data = __rhs``__rhs_sep``data;           \
  __opt_as __lhs``__lhs_sep``resp = __rhs``__rhs_sep``resp;
`define __AXI_LITE_TO_REQ(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep) \
  `__AXI_LITE_TO_AX(__opt_as, __lhs.aw, __lhs_sep, __rhs.aw, __rhs_sep) \
  __opt_as __lhs.aw_valid = __rhs.aw_valid;                             \
  `__AXI_LITE_TO_W(__opt_as, __lhs.w, __lhs_sep, __rhs.w, __rhs_sep)    \
  __opt_as __lhs.w_valid = __rhs.w_valid;                               \
  __opt_as __lhs.b_ready = __rhs.b_ready;                               \
  `__AXI_LITE_TO_AX(__opt_as, __lhs.ar, __lhs_sep, __rhs.ar, __rhs_sep) \
  __opt_as __lhs.ar_valid = __rhs.ar_valid;                             \
  __opt_as __lhs.r_ready = __rhs.r_ready;
`define __AXI_LITE_TO_RESP(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)  \
  __opt_as __lhs.aw_ready = __rhs.aw_ready;                               \
  __opt_as __lhs.ar_ready = __rhs.ar_ready;                               \
  __opt_as __lhs.w_ready = __rhs.w_ready;                                 \
  __opt_as __lhs.b_valid = __rhs.b_valid;                                 \
  `__AXI_LITE_TO_B(__opt_as, __lhs.b, __lhs_sep, __rhs.b, __rhs_sep)      \
  __opt_as __lhs.r_valid = __rhs.r_valid;                                 \
  `__AXI_LITE_TO_R(__opt_as, __lhs.r, __lhs_sep, __rhs.r, __rhs_sep)
`define AXI_LITE_ASSIGN_AW(dst, src)              \
  `__AXI_LITE_TO_AX(assign, dst.aw, _, src.aw, _) \
  assign dst.aw_valid = src.aw_valid;             \
  assign src.aw_ready = dst.aw_ready;
`define AXI_LITE_ASSIGN_W(dst, src)             \
  `__AXI_LITE_TO_W(assign, dst.w, _, src.w, _)  \
  assign dst.w_valid  = src.w_valid;            \
  assign src.w_ready  = dst.w_ready;
`define AXI_LITE_ASSIGN_B(dst, src)             \
  `__AXI_LITE_TO_B(assign, dst.b, _, src.b, _)  \
  assign dst.b_valid  = src.b_valid;            \
  assign src.b_ready  = dst.b_ready;
`define AXI_LITE_ASSIGN_AR(dst, src)              \
  `__AXI_LITE_TO_AX(assign, dst.ar, _, src.ar, _) \
  assign dst.ar_valid = src.ar_valid;             \
  assign src.ar_ready = dst.ar_ready;
`define AXI_LITE_ASSIGN_R(dst, src)             \
  `__AXI_LITE_TO_R(assign, dst.r, _, src.r, _)  \
  assign dst.r_valid  = src.r_valid;            \
  assign src.r_ready  = dst.r_ready;
`define AXI_LITE_ASSIGN(slv, mst) \
  `AXI_LITE_ASSIGN_AW(slv, mst)   \
  `AXI_LITE_ASSIGN_W(slv, mst)    \
  `AXI_LITE_ASSIGN_B(mst, slv)    \
  `AXI_LITE_ASSIGN_AR(slv, mst)   \
  `AXI_LITE_ASSIGN_R(mst, slv)
`define AXI_LITE_SET_FROM_AW(axi_if, aw_struct)      `__AXI_LITE_TO_AX(, axi_if.aw, _, aw_struct, .)
`define AXI_LITE_SET_FROM_W(axi_if, w_struct)        `__AXI_LITE_TO_W(, axi_if.w, _, w_struct, .)
`define AXI_LITE_SET_FROM_B(axi_if, b_struct)        `__AXI_LITE_TO_B(, axi_if.b, _, b_struct, .)
`define AXI_LITE_SET_FROM_AR(axi_if, ar_struct)      `__AXI_LITE_TO_AX(, axi_if.ar, _, ar_struct, .)
`define AXI_LITE_SET_FROM_R(axi_if, r_struct)        `__AXI_LITE_TO_R(, axi_if.r, _, r_struct, .)
`define AXI_LITE_SET_FROM_REQ(axi_if, req_struct)    `__AXI_LITE_TO_REQ(, axi_if, _, req_struct, .)
`define AXI_LITE_SET_FROM_RESP(axi_if, resp_struct)  `__AXI_LITE_TO_RESP(, axi_if, _, resp_struct, .)
`define AXI_LITE_ASSIGN_FROM_AW(axi_if, aw_struct)     `__AXI_LITE_TO_AX(assign, axi_if.aw, _, aw_struct, .)
`define AXI_LITE_ASSIGN_FROM_W(axi_if, w_struct)       `__AXI_LITE_TO_W(assign, axi_if.w, _, w_struct, .)
`define AXI_LITE_ASSIGN_FROM_B(axi_if, b_struct)       `__AXI_LITE_TO_B(assign, axi_if.b, _, b_struct, .)
`define AXI_LITE_ASSIGN_FROM_AR(axi_if, ar_struct)     `__AXI_LITE_TO_AX(assign, axi_if.ar, _, ar_struct, .)
`define AXI_LITE_ASSIGN_FROM_R(axi_if, r_struct)       `__AXI_LITE_TO_R(assign, axi_if.r, _, r_struct, .)
`define AXI_LITE_ASSIGN_FROM_REQ(axi_if, req_struct)   `__AXI_LITE_TO_REQ(assign, axi_if, _, req_struct, .)
`define AXI_LITE_ASSIGN_FROM_RESP(axi_if, resp_struct) `__AXI_LITE_TO_RESP(assign, axi_if, _, resp_struct, .)
`define AXI_LITE_SET_TO_AW(aw_struct, axi_if)     `__AXI_LITE_TO_AX(, aw_struct, ., axi_if.aw, _)
`define AXI_LITE_SET_TO_W(w_struct, axi_if)       `__AXI_LITE_TO_W(, w_struct, ., axi_if.w, _)
`define AXI_LITE_SET_TO_B(b_struct, axi_if)       `__AXI_LITE_TO_B(, b_struct, ., axi_if.b, _)
`define AXI_LITE_SET_TO_AR(ar_struct, axi_if)     `__AXI_LITE_TO_AX(, ar_struct, ., axi_if.ar, _)
`define AXI_LITE_SET_TO_R(r_struct, axi_if)       `__AXI_LITE_TO_R(, r_struct, ., axi_if.r, _)
`define AXI_LITE_SET_TO_REQ(req_struct, axi_if)   `__AXI_LITE_TO_REQ(, req_struct, ., axi_if, _)
`define AXI_LITE_SET_TO_RESP(resp_struct, axi_if) `__AXI_LITE_TO_RESP(, resp_struct, ., axi_if, _)
`define AXI_LITE_ASSIGN_TO_AW(aw_struct, axi_if)     `__AXI_LITE_TO_AX(assign, aw_struct, ., axi_if.aw, _)
`define AXI_LITE_ASSIGN_TO_W(w_struct, axi_if)       `__AXI_LITE_TO_W(assign, w_struct, ., axi_if.w, _)
`define AXI_LITE_ASSIGN_TO_B(b_struct, axi_if)       `__AXI_LITE_TO_B(assign, b_struct, ., axi_if.b, _)
`define AXI_LITE_ASSIGN_TO_AR(ar_struct, axi_if)     `__AXI_LITE_TO_AX(assign, ar_struct, ., axi_if.ar, _)
`define AXI_LITE_ASSIGN_TO_R(r_struct, axi_if)       `__AXI_LITE_TO_R(assign, r_struct, ., axi_if.r, _)
`define AXI_LITE_ASSIGN_TO_REQ(req_struct, axi_if)   `__AXI_LITE_TO_REQ(assign, req_struct, ., axi_if, _)
`define AXI_LITE_ASSIGN_TO_RESP(resp_struct, axi_if) `__AXI_LITE_TO_RESP(assign, resp_struct, ., axi_if, _)
`define AXI_LITE_SET_AW_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(, lhs, ., rhs, .)
`define AXI_LITE_SET_W_STRUCT(lhs, rhs)       `__AXI_LITE_TO_W(, lhs, ., rhs, .)
`define AXI_LITE_SET_B_STRUCT(lhs, rhs)       `__AXI_LITE_TO_B(, lhs, ., rhs, .)
`define AXI_LITE_SET_AR_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(, lhs, ., rhs, .)
`define AXI_LITE_SET_R_STRUCT(lhs, rhs)       `__AXI_LITE_TO_R(, lhs, ., rhs, .)
`define AXI_LITE_SET_REQ_STRUCT(lhs, rhs)   `__AXI_LITE_TO_REQ(, lhs, ., rhs, .)
`define AXI_LITE_SET_RESP_STRUCT(lhs, rhs) `__AXI_LITE_TO_RESP(, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_AW_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_W_STRUCT(lhs, rhs)       `__AXI_LITE_TO_W(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_B_STRUCT(lhs, rhs)       `__AXI_LITE_TO_B(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_AR_STRUCT(lhs, rhs)     `__AXI_LITE_TO_AX(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_R_STRUCT(lhs, rhs)       `__AXI_LITE_TO_R(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_REQ_STRUCT(lhs, rhs)   `__AXI_LITE_TO_REQ(assign, lhs, ., rhs, .)
`define AXI_LITE_ASSIGN_RESP_STRUCT(lhs, rhs) `__AXI_LITE_TO_RESP(assign, lhs, ., rhs, .)
`define AXI_ASSIGN_MASTER_TO_FLAT(pat, req, rsp) \
  assign m_axi_``pat``_awvalid  = req.aw_valid;  \
  assign m_axi_``pat``_awid     = req.aw.id;     \
  assign m_axi_``pat``_awaddr   = req.aw.addr;   \
  assign m_axi_``pat``_awlen    = req.aw.len;    \
  assign m_axi_``pat``_awsize   = req.aw.size;   \
  assign m_axi_``pat``_awburst  = req.aw.burst;  \
  assign m_axi_``pat``_awlock   = req.aw.lock;   \
  assign m_axi_``pat``_awcache  = req.aw.cache;  \
  assign m_axi_``pat``_awprot   = req.aw.prot;   \
  assign m_axi_``pat``_awqos    = req.aw.qos;    \
  assign m_axi_``pat``_awregion = req.aw.region; \
  assign m_axi_``pat``_awuser   = req.aw.user;   \
                                                 \
  assign m_axi_``pat``_wvalid   = req.w_valid;   \
  assign m_axi_``pat``_wdata    = req.w.data;    \
  assign m_axi_``pat``_wstrb    = req.w.strb;    \
  assign m_axi_``pat``_wlast    = req.w.last;    \
  assign m_axi_``pat``_wuser    = req.w.user;    \
                                                 \
  assign m_axi_``pat``_bready   = req.b_ready;   \
                                                 \
  assign m_axi_``pat``_arvalid  = req.ar_valid;  \
  assign m_axi_``pat``_arid     = req.ar.id;     \
  assign m_axi_``pat``_araddr   = req.ar.addr;   \
  assign m_axi_``pat``_arlen    = req.ar.len;    \
  assign m_axi_``pat``_arsize   = req.ar.size;   \
  assign m_axi_``pat``_arburst  = req.ar.burst;  \
  assign m_axi_``pat``_arlock   = req.ar.lock;   \
  assign m_axi_``pat``_arcache  = req.ar.cache;  \
  assign m_axi_``pat``_arprot   = req.ar.prot;   \
  assign m_axi_``pat``_arqos    = req.ar.qos;    \
  assign m_axi_``pat``_arregion = req.ar.region; \
  assign m_axi_``pat``_aruser   = req.ar.user;   \
                                                 \
  assign m_axi_``pat``_rready   = req.r_ready;   \
                                                 \
  assign rsp.aw_ready = m_axi_``pat``_awready;   \
  assign rsp.ar_ready = m_axi_``pat``_arready;   \
  assign rsp.w_ready  = m_axi_``pat``_wready;    \
                                                 \
  assign rsp.b_valid  = m_axi_``pat``_bvalid;    \
  assign rsp.b.id     = m_axi_``pat``_bid;       \
  assign rsp.b.resp   = m_axi_``pat``_bresp;     \
  assign rsp.b.user   = m_axi_``pat``_buser;     \
                                                 \
  assign rsp.r_valid  = m_axi_``pat``_rvalid;    \
  assign rsp.r.id     = m_axi_``pat``_rid;       \
  assign rsp.r.data   = m_axi_``pat``_rdata;     \
  assign rsp.r.resp   = m_axi_``pat``_rresp;     \
  assign rsp.r.last   = m_axi_``pat``_rlast;     \
  assign rsp.r.user   = m_axi_``pat``_ruser;
`define AXI_ASSIGN_SLAVE_TO_FLAT(pat, req, rsp)  \
  assign req.aw_valid  = s_axi_``pat``_awvalid;  \
  assign req.aw.id     = s_axi_``pat``_awid;     \
  assign req.aw.addr   = s_axi_``pat``_awaddr;   \
  assign req.aw.len    = s_axi_``pat``_awlen;    \
  assign req.aw.size   = s_axi_``pat``_awsize;   \
  assign req.aw.burst  = s_axi_``pat``_awburst;  \
  assign req.aw.lock   = s_axi_``pat``_awlock;   \
  assign req.aw.cache  = s_axi_``pat``_awcache;  \
  assign req.aw.prot   = s_axi_``pat``_awprot;   \
  assign req.aw.qos    = s_axi_``pat``_awqos;    \
  assign req.aw.region = s_axi_``pat``_awregion; \
  assign req.aw.user   = s_axi_``pat``_awuser;   \
                                                 \
  assign req.w_valid   = s_axi_``pat``_wvalid;   \
  assign req.w.data    = s_axi_``pat``_wdata;    \
  assign req.w.strb    = s_axi_``pat``_wstrb;    \
  assign req.w.last    = s_axi_``pat``_wlast;    \
  assign req.w.user    = s_axi_``pat``_wuser;    \
                                                 \
  assign req.b_ready   = s_axi_``pat``_bready;   \
                                                 \
  assign req.ar_valid  = s_axi_``pat``_arvalid;  \
  assign req.ar.id     = s_axi_``pat``_arid;     \
  assign req.ar.addr   = s_axi_``pat``_araddr;   \
  assign req.ar.len    = s_axi_``pat``_arlen;    \
  assign req.ar.size   = s_axi_``pat``_arsize;   \
  assign req.ar.burst  = s_axi_``pat``_arburst;  \
  assign req.ar.lock   = s_axi_``pat``_arlock;   \
  assign req.ar.cache  = s_axi_``pat``_arcache;  \
  assign req.ar.prot   = s_axi_``pat``_arprot;   \
  assign req.ar.qos    = s_axi_``pat``_arqos;    \
  assign req.ar.region = s_axi_``pat``_arregion; \
  assign req.ar.user   = s_axi_``pat``_aruser;   \
                                                 \
  assign req.r_ready   = s_axi_``pat``_rready;   \
                                                 \
  assign s_axi_``pat``_awready = rsp.aw_ready;   \
  assign s_axi_``pat``_arready = rsp.ar_ready;   \
  assign s_axi_``pat``_wready  = rsp.w_ready;    \
                                                 \
  assign s_axi_``pat``_bvalid  = rsp.b_valid;    \
  assign s_axi_``pat``_bid     = rsp.b.id;       \
  assign s_axi_``pat``_bresp   = rsp.b.resp;     \
  assign s_axi_``pat``_buser   = rsp.b.user;     \
                                                 \
  assign s_axi_``pat``_rvalid  = rsp.r_valid;    \
  assign s_axi_``pat``_rid     = rsp.r.id;       \
  assign s_axi_``pat``_rdata   = rsp.r.data;     \
  assign s_axi_``pat``_rresp   = rsp.r.resp;     \
  assign s_axi_``pat``_rlast   = rsp.r.last;     \
  assign s_axi_``pat``_ruser   = rsp.r.user;
`define AXI_ASSIGN_TO_FLAT_PORT(pat, req, rsp)  \
  .``pat``_awvalid  ( req.aw_valid  ), \
  .``pat``_awid     ( req.aw.id     ), \
  .``pat``_awaddr   ( req.aw.addr   ), \
  .``pat``_awlen    ( req.aw.len    ), \
  .``pat``_awsize   ( req.aw.size   ), \
  .``pat``_awburst  ( req.aw.burst  ), \
  .``pat``_awlock   ( req.aw.lock   ), \
  .``pat``_awcache  ( req.aw.cache  ), \
  .``pat``_awprot   ( req.aw.prot   ), \
  .``pat``_awqos    ( req.aw.qos    ), \
  .``pat``_awregion ( req.aw.region ), \
  .``pat``_awuser   ( req.aw.user   ), \
                                       \
  .``pat``_wvalid   ( req.w_valid   ), \
  .``pat``_wdata    ( req.w.data    ), \
  .``pat``_wstrb    ( req.w.strb    ), \
  .``pat``_wlast    ( req.w.last    ), \
  .``pat``_wuser    ( req.w.user    ), \
                                       \
  .``pat``_bready   ( req.b_ready   ), \
                                       \
  .``pat``_arvalid  ( req.ar_valid  ), \
  .``pat``_arid     ( req.ar.id     ), \
  .``pat``_araddr   ( req.ar.addr   ), \
  .``pat``_arlen    ( req.ar.len    ), \
  .``pat``_arsize   ( req.ar.size   ), \
  .``pat``_arburst  ( req.ar.burst  ), \
  .``pat``_arlock   ( req.ar.lock   ), \
  .``pat``_arcache  ( req.ar.cache  ), \
  .``pat``_arprot   ( req.ar.prot   ), \
  .``pat``_arqos    ( req.ar.qos    ), \
  .``pat``_arregion ( req.ar.region ), \
  .``pat``_aruser   ( req.ar.user   ), \
                                       \
  .``pat``_rready   ( req.r_ready   ), \
                                       \
  .``pat``_awready  ( rsp.aw_ready  ), \
  .``pat``_arready  ( rsp.ar_ready  ), \
  .``pat``_wready   ( rsp.w_ready   ), \
                                       \
  .``pat``_bvalid   ( rsp.b_valid   ), \
  .``pat``_bid      ( rsp.b.id      ), \
  .``pat``_bresp    ( rsp.b.resp    ), \
  .``pat``_buser    ( rsp.b.user    ), \
                                       \
  .``pat``_rvalid   ( rsp.r_valid   ), \
  .``pat``_rid      ( rsp.r.id      ), \
  .``pat``_rdata    ( rsp.r.data    ), \
  .``pat``_rresp    ( rsp.r.resp    ), \
  .``pat``_rlast    ( rsp.r.last    ), \
  .``pat``_ruser    ( rsp.r.user    )
`define AXI_ASSIGN_MASTER_TO_FLAT_PORT(name, req, rsp) \
  `AXI_ASSIGN_TO_FLAT_PORT(m_axi_``name``, req, rsp)
`define AXI_ASSIGN_SLAVE_TO_FLAT_PORT(name, req, rsp) \
  `AXI_ASSIGN_TO_FLAT_PORT(s_axi_``name``, req, rsp)
`define AXI_HIGHLIGHT(__name, __aw_t, __w_t, __b_t, __ar_t, __r_t, __req, __resp) \
  signal_highlighter #(                                                           \
    .T ( __aw_t )                                                                 \
  ) i_signal_highlighter_``__name``_aw (                                          \
    .ready_i ( __resp.aw_ready ),                                                 \
    .valid_i ( __req.aw_valid  ),                                                 \
    .data_i  ( __req.aw        )                                                  \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __w_t )                                                                  \
  ) i_signal_highlighter_``__name``_w (                                           \
    .ready_i ( __resp.w_ready ),                                                  \
    .valid_i ( __req.w_valid  ),                                                  \
    .data_i  ( __req.w        )                                                   \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __b_t )                                                                  \
  ) i_signal_highlighter_``__name``_b (                                           \
    .ready_i ( __req.b_ready  ),                                                  \
    .valid_i ( __resp.b_valid ),                                                  \
    .data_i  ( __resp.b       )                                                   \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __ar_t )                                                                 \
  ) i_signal_highlighter_``__name``_ar (                                          \
    .ready_i ( __resp.ar_ready ),                                                 \
    .valid_i ( __req.ar_valid  ),                                                 \
    .data_i  ( __req.ar        )                                                  \
  );                                                                              \
  signal_highlighter #(                                                           \
    .T ( __r_t )                                                                  \
  ) i_signal_highlighter_``__name``_r (                                           \
    .ready_i ( __req.r_ready  ),                                                  \
    .valid_i ( __resp.r_valid ),                                                  \
    .data_i  ( __resp.r       )                                                   \
  );
`endif
module axi_lite_xbar_intf #(
  parameter axi_pkg::xbar_cfg_t Cfg = '0,
  parameter type rule_t             = axi_pkg::xbar_rule_64_t
) (
  input  logic                                                    clk_i,
  input  logic                                                    rst_ni,
  input  logic                                                    test_i,
  AXI_LITE.Slave                                                  slv_ports [Cfg.NoSlvPorts-1:0],
  AXI_LITE.Master                                                 mst_ports [Cfg.NoMstPorts-1:0],
  input  rule_t [Cfg.NoAddrRules-1:0]                             addr_map_i,
  input  logic  [Cfg.NoSlvPorts-1:0]                              en_default_mst_port_i,
  input  logic  [Cfg.NoSlvPorts-1:0][$clog2(Cfg.NoMstPorts)-1:0]  default_mst_port_i
);
  typedef logic [Cfg.AxiAddrWidth       -1:0] addr_t;
  typedef logic [Cfg.AxiDataWidth       -1:0] data_t;
  typedef logic [Cfg.AxiDataWidth/8     -1:0] strb_t;
  `AXI_LITE_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t)
  `AXI_LITE_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t)
  `AXI_LITE_TYPEDEF_B_CHAN_T(b_chan_t)
  `AXI_LITE_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t)
  `AXI_LITE_TYPEDEF_R_CHAN_T(r_chan_t, data_t)
  `AXI_LITE_TYPEDEF_REQ_T(axi_req_t, aw_chan_t, w_chan_t, ar_chan_t)
  `AXI_LITE_TYPEDEF_RESP_T(axi_resp_t, b_chan_t, r_chan_t)
  axi_req_t   [Cfg.NoMstPorts-1:0]  mst_reqs;
  axi_resp_t  [Cfg.NoMstPorts-1:0]  mst_resps;
  axi_req_t   [Cfg.NoSlvPorts-1:0]  slv_reqs;
  axi_resp_t  [Cfg.NoSlvPorts-1:0]  slv_resps;
  for (genvar i = 0; i < Cfg.NoMstPorts; i++) begin : gen_assign_mst
    `AXI_LITE_ASSIGN_FROM_REQ(mst_ports[i], mst_reqs[i])
    `AXI_LITE_ASSIGN_TO_RESP(mst_resps[i], mst_ports[i])
  end
  for (genvar i = 0; i < Cfg.NoSlvPorts; i++) begin : gen_assign_slv
    `AXI_LITE_ASSIGN_TO_REQ(slv_reqs[i], slv_ports[i])
    `AXI_LITE_ASSIGN_FROM_RESP(slv_ports[i], slv_resps[i])
  end
  TopModule #(
    .Cfg  (Cfg),
    .aw_chan_t  ( aw_chan_t  ),
    .w_chan_t   ( w_chan_t   ),
    .b_chan_t   ( b_chan_t   ),
    .ar_chan_t  ( ar_chan_t  ),
    .r_chan_t   ( r_chan_t   ),
    .axi_req_t  ( axi_req_t  ),
    .axi_resp_t ( axi_resp_t ),
    .rule_t     ( rule_t     )
  ) i_xbar (
    .clk_i,
    .rst_ni,
    .test_i,
    .slv_ports_req_i  (slv_reqs ),
    .slv_ports_resp_o (slv_resps),
    .mst_ports_req_o  (mst_reqs ),
    .mst_ports_resp_i (mst_resps),
    .addr_map_i,
    .en_default_mst_port_i,
    .default_mst_port_i
  );
endmodule

package axi_pkg;
    
  parameter int unsigned BurstWidth  = 32'd2;
  
  parameter int unsigned RespWidth   = 32'd2;
  
  parameter int unsigned CacheWidth  = 32'd4;
  
  parameter int unsigned ProtWidth   = 32'd3;
  
  parameter int unsigned QosWidth    = 32'd4;
  
  parameter int unsigned RegionWidth = 32'd4;
  
  parameter int unsigned LenWidth    = 32'd8;
  
  parameter int unsigned SizeWidth   = 32'd3;
  
  parameter int unsigned LockWidth   = 32'd1;
  
  parameter int unsigned AtopWidth   = 32'd6;
  
  parameter int unsigned NsaidWidth  = 32'd4;
  
  typedef logic [1:0]  burst_t;
  
  typedef logic [1:0]   resp_t;
  
  typedef logic [3:0]  cache_t;
  
  typedef logic [2:0]   prot_t;
  
  typedef logic [3:0]    qos_t;
  
  typedef logic [3:0] region_t;
  
  typedef logic [7:0]    len_t;
  
  typedef logic [2:0]   size_t;
  
  typedef logic [5:0]   atop_t; 
  
  typedef logic [3:0]  nsaid_t;
  
  
  
  
  
  
  
  localparam BURST_FIXED = 2'b00;
  
  
  
  
  
  localparam BURST_INCR  = 2'b01;
  
  
  
  
  
  localparam BURST_WRAP  = 2'b10;
  
  
  localparam RESP_OKAY   = 2'b00;
  
  
  localparam RESP_EXOKAY = 2'b01;
  
  
  localparam RESP_SLVERR = 2'b10;
  
  
  localparam RESP_DECERR = 2'b11;
  
  
  localparam CACHE_BUFFERABLE = 4'b0001;
  
  
  localparam CACHE_MODIFIABLE = 4'b0010;
  
  
  localparam CACHE_RD_ALLOC   = 4'b0100;
  
  
  localparam CACHE_WR_ALLOC   = 4'b1000;
  
  function automatic shortint unsigned num_bytes(size_t size);
    return shortint'(1 << size);
  endfunction
  
  
  
  typedef logic [127:0] largest_addr_t;
  
  function automatic largest_addr_t aligned_addr(largest_addr_t addr, size_t size);
    return (addr >> size) << size;
  endfunction
  
  
  
  
  function automatic largest_addr_t wrap_boundary (largest_addr_t addr, size_t size, len_t len);
    largest_addr_t wrap_addr;
    
    `ifndef VERILATOR
      assume (len == len_t'(4'b1) || len == len_t'(4'b11) || len == len_t'(4'b111) ||
          len == len_t'(4'b1111)) else
        $error("AXI BURST_WRAP with not allowed len of: %0h", len);
    `endif
    
    
    
    
    
    
    
    
    
    
    
    unique case (len)
      len_t'(4'b1   ) : wrap_addr = (addr >> (unsigned'(size) + 1)) << (unsigned'(size) + 1); 
      len_t'(4'b11  ) : wrap_addr = (addr >> (unsigned'(size) + 2)) << (unsigned'(size) + 2); 
      len_t'(4'b111 ) : wrap_addr = (addr >> (unsigned'(size) + 3)) << (unsigned'(size) + 3); 
      len_t'(4'b1111) : wrap_addr = (addr >> (unsigned'(size) + 4)) << (unsigned'(size) + 4); 
      default : wrap_addr = '0;
    endcase
    return wrap_addr;
  endfunction
  
  function automatic largest_addr_t
  beat_addr(largest_addr_t addr, size_t size, len_t len, burst_t burst, shortint unsigned i_beat);
    largest_addr_t ret_addr = addr;
    largest_addr_t wrp_bond = '0;
    if (burst == BURST_WRAP) begin
      
      wrp_bond = wrap_boundary(addr, size, len);
    end
    if (i_beat != 0 && burst != BURST_FIXED) begin
      
      
      
      
      ret_addr = aligned_addr(addr, size) + i_beat * num_bytes(size);
      
      
      
      
      
      
      
      
      
      
      
      if (burst == BURST_WRAP && ret_addr >= wrp_bond + (num_bytes(size) * (largest_addr_t'(len) + 1))) begin
        ret_addr = ret_addr - (num_bytes(size) * (largest_addr_t'(len) + 1));
      end
    end
    return ret_addr;
  endfunction
  
  function automatic shortint unsigned
  beat_lower_byte(largest_addr_t addr, size_t size, len_t len, burst_t burst,
      shortint unsigned strobe_width, shortint unsigned i_beat);
    largest_addr_t _addr = beat_addr(addr, size, len, burst, i_beat);
    return shortint'(($bits(_addr)  + $bits(strobe_width))'(_addr) - (_addr / largest_addr_t'(strobe_width)) * strobe_width);
  endfunction
  
  function automatic shortint unsigned
  beat_upper_byte(largest_addr_t addr, size_t size, len_t len, burst_t burst,
      shortint unsigned strobe_width, shortint unsigned i_beat);
      typedef shortint unsigned SU;
    if (i_beat == 0) begin
      return SU'(aligned_addr(addr, size) + (largest_addr_t'(num_bytes(size)) - 1) - (addr / largest_addr_t'(strobe_width)) * strobe_width);
    end else begin
      return beat_lower_byte(addr, size, len, burst, strobe_width, i_beat) + num_bytes(size) - 1;
    end
  endfunction
  
  function automatic logic bufferable(cache_t cache);
    return |(cache & CACHE_BUFFERABLE);
  endfunction
  
  function automatic logic modifiable(cache_t cache);
    return |(cache & CACHE_MODIFIABLE);
  endfunction
  
  typedef enum logic [3:0] {
    DEVICE_NONBUFFERABLE,
    DEVICE_BUFFERABLE,
    NORMAL_NONCACHEABLE_NONBUFFERABLE,
    NORMAL_NONCACHEABLE_BUFFERABLE,
    WTHRU_NOALLOCATE,
    WTHRU_RALLOCATE,
    WTHRU_WALLOCATE,
    WTHRU_RWALLOCATE,
    WBACK_NOALLOCATE,
    WBACK_RALLOCATE,
    WBACK_WALLOCATE,
    WBACK_RWALLOCATE
  } mem_type_t;
  
  function automatic logic [3:0] get_arcache(mem_type_t mtype);
    unique case (mtype)
      DEVICE_NONBUFFERABLE              : return 4'b0000;
      DEVICE_BUFFERABLE                 : return 4'b0001;
      NORMAL_NONCACHEABLE_NONBUFFERABLE : return 4'b0010;
      NORMAL_NONCACHEABLE_BUFFERABLE    : return 4'b0011;
      WTHRU_NOALLOCATE                  : return 4'b1010;
      WTHRU_RALLOCATE                   : return 4'b1110;
      WTHRU_WALLOCATE                   : return 4'b1010;
      WTHRU_RWALLOCATE                  : return 4'b1110;
      WBACK_NOALLOCATE                  : return 4'b1011;
      WBACK_RALLOCATE                   : return 4'b1111;
      WBACK_WALLOCATE                   : return 4'b1011;
      WBACK_RWALLOCATE                  : return 4'b1111;
      default                           : return 4'bxxxx;
    endcase 
  endfunction
  
  function automatic logic [3:0] get_awcache(mem_type_t mtype);
    unique case (mtype)
      DEVICE_NONBUFFERABLE              : return 4'b0000;
      DEVICE_BUFFERABLE                 : return 4'b0001;
      NORMAL_NONCACHEABLE_NONBUFFERABLE : return 4'b0010;
      NORMAL_NONCACHEABLE_BUFFERABLE    : return 4'b0011;
      WTHRU_NOALLOCATE                  : return 4'b0110;
      WTHRU_RALLOCATE                   : return 4'b0110;
      WTHRU_WALLOCATE                   : return 4'b1110;
      WTHRU_RWALLOCATE                  : return 4'b1110;
      WBACK_NOALLOCATE                  : return 4'b0111;
      WBACK_RALLOCATE                   : return 4'b0111;
      WBACK_WALLOCATE                   : return 4'b1111;
      WBACK_RWALLOCATE                  : return 4'b1111;
      default                           : return 4'bxxxx;
    endcase 
  endfunction
  
  
  
  
  
  
  
  
  
  
  function automatic resp_t resp_precedence(resp_t resp_a, resp_t resp_b);
    unique case (resp_a)
      RESP_OKAY: begin
        
        if (resp_b == RESP_EXOKAY) begin
          return resp_a;
        end else begin
          return resp_b;
        end
      end
      RESP_EXOKAY: begin
        
        return resp_b;
      end
      RESP_SLVERR: begin
        
        if (resp_b == RESP_DECERR) begin
          return resp_b;
        end else begin
          return resp_a;
        end
      end
      RESP_DECERR: begin
        
        return resp_a;
      end
    endcase
  endfunction
  
  function automatic int unsigned aw_width(int unsigned addr_width, int unsigned id_width,
                                           int unsigned user_width );
    
    return (id_width + addr_width + LenWidth + SizeWidth + BurstWidth + LockWidth + CacheWidth +
            ProtWidth + QosWidth + RegionWidth + AtopWidth + user_width );
  endfunction
  
  function automatic int unsigned w_width(int unsigned data_width, int unsigned user_width );
    
    return (data_width + data_width / 32'd8 + 32'd1 + user_width);
    
  endfunction
  
  function automatic int unsigned b_width(int unsigned id_width, int unsigned user_width );
    
    return (id_width + RespWidth + user_width);
  endfunction
  
  function automatic int unsigned ar_width(int unsigned addr_width, int unsigned id_width,
                                           int unsigned user_width );
    
    return (id_width + addr_width + LenWidth + SizeWidth + BurstWidth + LockWidth + CacheWidth +
            ProtWidth + QosWidth + RegionWidth + user_width );
  endfunction
  
  function automatic int unsigned r_width(int unsigned data_width, int unsigned id_width,
                                          int unsigned user_width );
    
    return (id_width + data_width + RespWidth + 32'd1 + user_width);
    
  endfunction
  
  function automatic int unsigned req_width(int unsigned addr_width,    int unsigned data_width,
                                            int unsigned id_width,      int unsigned aw_user_width,
                                            int unsigned ar_user_width, int unsigned w_user_width   );
    
    
    return (aw_width(addr_width, id_width, aw_user_width) + 32'd1 +
            w_width(data_width, w_user_width)             + 32'd1 +
            ar_width(addr_width, id_width, ar_user_width) + 32'd1 + 32'd1 + 32'd1 );
    
  endfunction
  
  function automatic int unsigned rsp_width(int unsigned data_width,   int unsigned id_width,
                                            int unsigned r_user_width, int unsigned b_user_width );
    
    
    return (r_width(data_width, id_width, r_user_width) + 32'd1 +
            b_width(id_width, b_user_width)             + 32'd1 + 32'd1 + 32'd1 + 32'd1);
    
  endfunction
  
  
  
  
  
  
  
  localparam ATOP_ATOMICSWAP  = 6'b110000;
  
  
  
  
  
  
  
  
  
  localparam ATOP_ATOMICCMP   = 6'b110001;
  
  
  localparam ATOP_NONE        = 2'b00;
  
  
  
  
  
  
  localparam ATOP_ATOMICSTORE = 2'b01;
  
  
  
  
  
  
  
  localparam ATOP_ATOMICLOAD  = 2'b10;
  
  
  
  
  
  localparam ATOP_LITTLE_END  = 1'b0;
  
  localparam ATOP_BIG_END     = 1'b1;
  
  
  localparam ATOP_ADD   = 3'b000;
  
  localparam ATOP_CLR   = 3'b001;
  
  localparam ATOP_EOR   = 3'b010;
  
  localparam ATOP_SET   = 3'b011;
  
  
  localparam ATOP_SMAX  = 3'b100;
  
  
  localparam ATOP_SMIN  = 3'b101;
  
  
  localparam ATOP_UMAX  = 3'b110;
  
  
  localparam ATOP_UMIN  = 3'b111;
  
  
  localparam ATOP_R_RESP = 32'd5;
  
  
  localparam bit [9:0] DemuxAw = (1 << 9);
  
  localparam bit [9:0] DemuxW  = (1 << 8);
  
  localparam bit [9:0] DemuxB  = (1 << 7);
  
  localparam bit [9:0] DemuxAr = (1 << 6);
  
  localparam bit [9:0] DemuxR  = (1 << 5);
  
  localparam bit [9:0] MuxAw   = (1 << 4);
  
  localparam bit [9:0] MuxW    = (1 << 3);
  
  localparam bit [9:0] MuxB    = (1 << 2);
  
  localparam bit [9:0] MuxAr   = (1 << 1);
  
  localparam bit [9:0] MuxR    = (1 << 0);
  
  typedef enum bit [9:0] {
    NO_LATENCY    = 10'b000_00_000_00,
    CUT_SLV_AX    = DemuxAw | DemuxAr,
    CUT_MST_AX    = MuxAw | MuxAr,
    CUT_ALL_AX    = DemuxAw | DemuxAr | MuxAw | MuxAr,
    CUT_SLV_PORTS = DemuxAw | DemuxW | DemuxB | DemuxAr | DemuxR,
    CUT_MST_PORTS = MuxAw | MuxW | MuxB | MuxAr | MuxR,
    CUT_ALL_PORTS = 10'b111_11_111_11
  } xbar_latency_e;
  
  typedef struct packed {
    
    
    int unsigned   NoSlvPorts;
    
    
    int unsigned   NoMstPorts;
    
    
    int unsigned   MaxMstTrans;
    
    
    int unsigned   MaxSlvTrans;
    
    
    
    bit            FallThrough;
    
    
    
    bit [9:0]      LatencyMode;
    
    
    int unsigned   PipelineStages;
    
    
    int unsigned   AxiIdWidthSlvPorts;
    
    
    int unsigned   AxiIdUsedSlvPorts;
    
    bit            UniqueIds;
    
    int unsigned   AxiAddrWidth;
    
    int unsigned   AxiDataWidth;
    
    
    
    int unsigned   NoAddrRules;
  } xbar_cfg_t;
  
  typedef struct packed {
    int unsigned idx;
    logic [63:0] start_addr;
    logic [63:0] end_addr;
  } xbar_rule_64_t;
  
  typedef struct packed {
    int unsigned idx;
    logic [31:0] start_addr;
    logic [31:0] end_addr;
  } xbar_rule_32_t;
  
  function automatic integer unsigned iomsb (input integer unsigned width);
      return (width != 32'd0) ? unsigned'(width-1) : 32'd0;
  endfunction
endpackage
