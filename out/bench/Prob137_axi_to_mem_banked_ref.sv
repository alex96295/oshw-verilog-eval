
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

module shift_reg #(
    parameter type dtype         = logic,
    parameter int unsigned Depth = 1
)(
    input  logic clk_i,    
    input  logic rst_ni,   
    input  dtype d_i,
    output dtype d_o
);
    shift_reg_gated #(
        .Depth(Depth),
        .dtype(dtype)
    ) i_shift_reg_gated (
        .clk_i  (clk_i),
        .rst_ni (rst_ni),
        .valid_i(1'b1),
        .data_i (d_i),
        .valid_o(),
        .data_o (d_o)
    );
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
module shift_reg_gated #(
  parameter int unsigned Depth = 32'd8,
  parameter type         dtype = logic
) (
  input  logic clk_i,    
  input  logic rst_ni,   
  input  logic valid_i,
  input  dtype data_i,
  output logic valid_o,
  output dtype data_o
);
  
  if (Depth == 0) begin : gen_pass_through
    assign valid_o = valid_i;
    assign data_o  = data_i;
  
  end else begin : gen_shift_reg
    logic [Depth-1 : 0] valid_d, valid_q;
    dtype [Depth-1 : 0] data_d, data_q;
    for (genvar i = 0; i < Depth; i++) begin : gen_regs
      
      if (i == 0) begin : gen_shift_in
        assign valid_d[i] = valid_i;
        assign data_d[i]  = data_i;
      end else begin : gen_shift
        assign valid_d[i] = valid_q[i-1];
        assign data_d[i]  = data_q[i-1];
      end
      
      `FF(valid_q[i], valid_d[i], '0, clk_i, rst_ni)
      
      
      `FFL(data_q[i], data_d[i], valid_d[i], dtype'('0), clk_i, rst_ni)
    end
    
    assign valid_o = valid_q[Depth-1];
    assign data_o  = data_q[Depth-1];
  end
endmodule

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

module stream_demux #(
  
  parameter int unsigned N_OUP     = 32'd1,
  
  parameter int unsigned LOG_N_OUP = (N_OUP > 32'd1) ? unsigned'($clog2(N_OUP)) : 1'b1
) (
  input  logic                 inp_valid_i,
  output logic                 inp_ready_o,
  input  logic [LOG_N_OUP-1:0] oup_sel_i,
  output logic [N_OUP-1:0]     oup_valid_o,
  input  logic [N_OUP-1:0]     oup_ready_i
);
  always_comb begin
    oup_valid_o = '0;
    oup_valid_o[oup_sel_i] = inp_valid_i;
  end
  assign inp_ready_o = oup_ready_i[oup_sel_i];
endmodule

module stream_fifo #(
    
    parameter bit          FALL_THROUGH = 1'b0,
    
    parameter int unsigned DATA_WIDTH   = 32,
    
    parameter int unsigned DEPTH        = 8,
    parameter type         T            = logic [DATA_WIDTH-1:0],
    
    parameter int unsigned ADDR_DEPTH  = (DEPTH > 1) ? $clog2(DEPTH) : 1
) (
    input  logic                  clk_i,      
    input  logic                  rst_ni,     
    input  logic                  flush_i,    
    input  logic                  testmode_i, 
    output logic [ADDR_DEPTH-1:0] usage_o,    
    
    input  T                      data_i,     
    input  logic                  valid_i,    
    output logic                  ready_o,    
    
    output T                      data_o,     
    output logic                  valid_o,    
    input  logic                  ready_i     
);
    logic push, pop;
    logic empty, full;
    assign push    = valid_i & ~full;
    assign pop     = ready_i & ~empty;
    assign ready_o = ~full;
    assign valid_o = ~empty;
    fifo_v3 #(
        .FALL_THROUGH   (FALL_THROUGH),
        .DATA_WIDTH     (DATA_WIDTH),
        .DEPTH          (DEPTH),
        .dtype(T)
    ) fifo_i (
        .clk_i,
        .rst_ni,
        .flush_i,
        .testmode_i,
        .full_o     (full),
        .empty_o    (empty),
        .usage_o,
        .data_i,
        .push_i     (push),
        .data_o,
        .pop_i      (pop)
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
module stream_fork #(
    parameter int unsigned N_OUP = 0    
) (
    input  logic                clk_i,
    input  logic                rst_ni,
    input  logic                valid_i,
    output logic                ready_o,
    output logic [N_OUP-1:0]    valid_o,
    input  logic [N_OUP-1:0]    ready_i
);
    typedef enum logic {READY, WAIT} state_t;
    logic [N_OUP-1:0]   oup_ready,
                        all_ones;
    state_t inp_state_d, inp_state_q;
    
    always_comb begin
        
        inp_state_d = inp_state_q;
        unique case (inp_state_q)
            READY: begin
                if (valid_i) begin
                    if (valid_o == all_ones && ready_i == all_ones) begin
                        
                        ready_o = 1'b1;
                    end else begin
                        ready_o = 1'b0;
                        
                        inp_state_d = WAIT;
                    end
                end else begin
                    ready_o = 1'b0;
                end
            end
            WAIT: begin
                if (valid_i && oup_ready == all_ones) begin
                    ready_o = 1'b1;
                    inp_state_d = READY;
                end else begin
                    ready_o = 1'b0;
                end
            end
            default: begin
                inp_state_d = READY;
                ready_o = 1'b0;
            end
        endcase
    end
    always_ff @(posedge clk_i, negedge rst_ni) begin
        if (!rst_ni) begin
            inp_state_q <= READY;
        end else begin
            inp_state_q <= inp_state_d;
        end
    end
    
    for (genvar i = 0; i < N_OUP; i++) begin: gen_oup_state
        state_t oup_state_d, oup_state_q;
        always_comb begin
            oup_ready[i]    = 1'b1;
            valid_o[i]      = 1'b0;
            oup_state_d     = oup_state_q;
            unique case (oup_state_q)
                READY: begin
                    if (valid_i) begin
                        valid_o[i] = 1'b1;
                        if (ready_i[i]) begin   
                            if (!ready_o) begin     
                                oup_state_d = WAIT;
                            end
                        end else begin          
                            oup_ready[i] = 1'b0;
                        end
                    end
                end
                WAIT: begin
                    if (valid_i && ready_o) begin   
                        oup_state_d = READY;
                    end
                end
                default: begin
                    oup_state_d = READY;
                end
            endcase
        end
        always_ff @(posedge clk_i, negedge rst_ni) begin
            if (!rst_ni) begin
                oup_state_q <= READY;
            end else begin
                oup_state_q <= oup_state_d;
            end
        end
    end
    assign all_ones = '1;   
                            
`ifndef COMMON_CELLS_ASSERTS_OFF
    `ASSERT_INIT(n_oup_0, N_OUP >= 1, "Number of outputs must be at least 1!")
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
module stream_fork_dynamic #(
  
  parameter int unsigned N_OUP = 32'd0 
) (
  
  input  logic             clk_i,
  
  input  logic             rst_ni,
  
  input  logic             valid_i,
  
  output logic             ready_o,
  
  input  logic [N_OUP-1:0] sel_i,
  
  input  logic             sel_valid_i,
  
  output logic             sel_ready_o,
  
  output logic [N_OUP-1:0] valid_o,
  
  input  logic [N_OUP-1:0] ready_i
);
  logic             int_inp_valid,  int_inp_ready;
  logic [N_OUP-1:0] int_oup_valid,  int_oup_ready;
  
  for (genvar i = 0; i < N_OUP; i++) begin : gen_oups
    always_comb begin
      valid_o[i]       = 1'b0;
      int_oup_ready[i] = 1'b0;
      if (sel_valid_i) begin
        if (sel_i[i]) begin
          valid_o[i]       = int_oup_valid[i];
          int_oup_ready[i] = ready_i[i];
        end else begin
          int_oup_ready[i] = 1'b1;
        end
      end
    end
  end
  
  always_comb begin
    int_inp_valid = 1'b0;
    ready_o       = 1'b0;
    sel_ready_o   = 1'b0;
    if (sel_valid_i) begin
      int_inp_valid = valid_i;
      ready_o       = int_inp_ready;
      sel_ready_o   = int_inp_ready;
    end
  end
  stream_fork #(
    .N_OUP  ( N_OUP )
  ) i_fork (
    .clk_i,
    .rst_ni,
    .valid_i ( int_inp_valid ),
    .ready_o ( int_inp_ready ),
    .valid_o ( int_oup_valid ),
    .ready_i ( int_oup_ready )
  );
`ifndef COMMON_CELLS_ASSERTS_OFF
  `ASSERT_INIT(n_oup_0, N_OUP >= 1, "N_OUP must be at least 1!")
`endif
endmodule

module stream_join #(
  
  parameter int unsigned N_INP = 32'd0 
) (
  
  input  logic  [N_INP-1:0] inp_valid_i,
  
  output logic  [N_INP-1:0] inp_ready_o,
  
  output logic              oup_valid_o,
  
  input  logic              oup_ready_i
);
  stream_join_dynamic #(
    .N_INP(N_INP)
  ) i_stream_join_dynamic (
    .inp_valid_i(inp_valid_i),
    .inp_ready_o(inp_ready_o),
    .sel_i      ({N_INP{1'b1}}),
    .oup_valid_o(oup_valid_o),
    .oup_ready_i(oup_ready_i)
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
module stream_join_dynamic #(
  
  parameter int unsigned N_INP = 32'd0 
) (
  
  input  logic [N_INP-1:0] inp_valid_i,
  
  output logic [N_INP-1:0] inp_ready_o,
  
  input  logic [N_INP-1:0] sel_i,
  
  output logic             oup_valid_o,
  
  input  logic             oup_ready_i
);
  
  assign oup_valid_o = &(inp_valid_i | ~sel_i) && |sel_i;
  for (genvar i = 0; i < N_INP; i++) begin : gen_inp_ready
    assign inp_ready_o[i] = oup_valid_o & oup_ready_i & sel_i[i];
  end
`ifndef COMMON_CELLS_ASSERTS_OFF
  `ASSERT_INIT(n_inp_0, N_INP >= 1, "N_INP must be at least 1!")
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
module stream_mux #(
  parameter type DATA_T = logic,  
  parameter integer N_INP = 0,    
  
  parameter integer SEL_WIDTH = cf_math_pkg::idx_width(N_INP)
) (
  input  DATA_T [N_INP-1:0]     inp_data_i,
  input  logic  [N_INP-1:0]     inp_valid_i,
  output logic  [N_INP-1:0]     inp_ready_o,
  input  logic  [SEL_WIDTH-1:0] inp_sel_i,
  output DATA_T                 oup_data_o,
  output logic                  oup_valid_o,
  input  logic                  oup_ready_i
);
  always_comb begin
    inp_ready_o = '0;
    inp_ready_o[inp_sel_i] = oup_ready_i;
  end
  assign oup_data_o   = inp_data_i[inp_sel_i];
  assign oup_valid_o  = inp_valid_i[inp_sel_i];
`ifndef COMMON_CELLS_ASSERTS_OFF
  `ASSERT_INIT(n_inp_0, N_INP >= 1, "The number of inputs must be at least 1!")
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
module stream_xbar #(
  
  parameter int unsigned NumInp      = 32'd0,
  
  parameter int unsigned NumOut      = 32'd0,
  
  parameter int unsigned DataWidth   = 32'd1,
  
  parameter type         payload_t   = logic [DataWidth-1:0],
  
  parameter bit          OutSpillReg = 1'b0,
  
  parameter int unsigned ExtPrio     = 1'b0,
  
  
  parameter int unsigned AxiVldRdy   = 1'b1,
  
  
  
  parameter int unsigned LockIn      = 1'b1,
  
  
  
  parameter payload_t    AxiVldMask  = '1,
  
  
  
  parameter int unsigned SelWidth = (NumOut > 32'd1) ? unsigned'($clog2(NumOut)) : 32'd1,
  
  
  
  parameter type sel_oup_t = logic[SelWidth-1:0],
  
  
  
  parameter int unsigned IdxWidth = (NumInp > 32'd1) ? unsigned'($clog2(NumInp)) : 32'd1,
  
  
  
  parameter type idx_inp_t = logic[IdxWidth-1:0]
) (
  
  input  logic                  clk_i,
  
  input  logic                  rst_ni,
  
  
  
  
  input  logic                  flush_i,
  
  
  input  idx_inp_t [NumOut-1:0] rr_i,
  
  
  input  payload_t [NumInp-1:0] data_i,
  
  
  input  sel_oup_t [NumInp-1:0] sel_i,
  
  input  logic     [NumInp-1:0] valid_i,
  
  output logic     [NumInp-1:0] ready_o,
  
  output payload_t [NumOut-1:0] data_o,
  
  output idx_inp_t [NumOut-1:0] idx_o,
  
  output logic     [NumOut-1:0] valid_o,
  
  input  logic     [NumOut-1:0] ready_i
);
  typedef struct packed {
    payload_t data;
    idx_inp_t idx;
  } spill_data_t;
  logic     [NumInp-1:0][NumOut-1:0] inp_valid;
  logic     [NumInp-1:0][NumOut-1:0] inp_ready;
  payload_t [NumOut-1:0][NumInp-1:0] out_data;
  logic     [NumOut-1:0][NumInp-1:0] out_valid;
  logic     [NumOut-1:0][NumInp-1:0] out_ready;
  
  for (genvar i = 0; unsigned'(i) < NumInp; i++) begin : gen_inps
    stream_demux #(
      .N_OUP ( NumOut )
    ) i_stream_demux (
      .inp_valid_i ( valid_i[i]   ),
      .inp_ready_o ( ready_o[i]   ),
      .oup_sel_i   ( sel_i[i]     ),
      .oup_valid_o ( inp_valid[i] ),
      .oup_ready_i ( inp_ready[i] )
    );
    
    for (genvar j = 0; unsigned'(j) < NumOut; j++) begin : gen_cross
      
      assign out_data[j][i]  = data_i[i];
      
      assign out_valid[j][i] = inp_valid[i][j];
      assign inp_ready[i][j] = out_ready[j][i];
    end
  end
  
  for (genvar j = 0; unsigned'(j) < NumOut; j++) begin : gen_outs
    spill_data_t arb;
    logic        arb_valid, arb_ready;
    rr_arb_tree #(
      .NumIn     ( NumInp    ),
      .DataType  ( payload_t ),
      .ExtPrio   ( ExtPrio   ),
      .AxiVldRdy ( AxiVldRdy ),
      .LockIn    ( LockIn    )
    ) i_rr_arb_tree (
      .clk_i,
      .rst_ni,
      .flush_i,
      .rr_i    ( rr_i[j]      ),
      .req_i   ( out_valid[j] ),
      .gnt_o   ( out_ready[j] ),
      .data_i  ( out_data[j]  ),
      .req_o   ( arb_valid    ),
      .gnt_i   ( arb_ready    ),
      .data_o  ( arb.data     ),
      .idx_o   ( arb.idx      )
    );
    spill_data_t spill;
    spill_register #(
      .T      ( spill_data_t ),
      .Bypass ( !OutSpillReg )
    ) i_spill_register (
      .clk_i,
      .rst_ni,
      .valid_i ( arb_valid  ),
      .ready_o ( arb_ready  ),
      .data_i  ( arb        ),
      .valid_o ( valid_o[j] ),
      .ready_i ( ready_i[j] ),
      .data_o  ( spill      )
    );
    
    always_comb begin
      data_o[j] = spill.data;
      idx_o[j]  = spill.idx;
    end
  end
  
  
  `ifndef COMMON_CELLS_ASSERTS_OFF
  for (genvar i = 0; unsigned'(i) < NumInp; i++) begin : gen_sel_assertions
    `ASSERT(non_existing_output, valid_i[i] |-> sel_i[i] < NumOut, clk_i, !rst_ni,
            "Non-existing output is selected!")
  end
  if (AxiVldRdy) begin : gen_handshake_assertions
    for (genvar i = 0; unsigned'(i) < NumInp; i++) begin : gen_inp_assertions
      `ASSERT(input_data_unstable, valid_i[i] && !ready_o[i] |=> $stable(data_i[i] & AxiVldMask),
              clk_i, !rst_ni, $sformatf("data_i is unstable at input: %0d", i))
      `ASSERT(input_sel_unstable, valid_i[i] && !ready_o[i] |=> $stable(sel_i[i]), clk_i, !rst_ni,
              $sformatf("sel_i is unstable at input: %0d", i))
      `ASSERT(input_valid_taken, valid_i[i] && !ready_o[i] |=> valid_i[i], clk_i, !rst_ni,
              $sformatf("valid_i at input %0d has been taken away without a ready.", i))
    end
    for (genvar i = 0; unsigned'(i) < NumOut; i++) begin : gen_out_assertions
      `ASSERT(output_data_unstable, valid_o[i] && !ready_i[i] |=> $stable(data_o[i] & AxiVldMask),
              clk_i, !rst_ni,
              $sformatf("data_o is unstable at output: %0d Check that parameter LockIn is set.", i))
      `ASSERT(output_idx_unstable, valid_o[i] && !ready_i[i] |=> $stable(idx_o[i]), clk_i, !rst_ni,
              $sformatf("idx_o is unstable at output: %0d Check that parameter LockIn is set.", i))
      `ASSERT(output_valid_taken, valid_o[i] && !ready_i[i] |=> valid_o[i], clk_i, !rst_ni,
              $sformatf("valid_o at output %0d has been taken away without a ready.", i))
    end
  end
  `ASSERT_INIT(numinp_0, NumInp > 32'd0, "NumInp has to be > 0!")
  `ASSERT_INIT(numout_0, NumOut > 32'd0, "NumOut has to be > 0!")
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
module axi_demux #(
  parameter int unsigned AxiIdWidth     = 32'd0,
  parameter bit          AtopSupport    = 1'b1,
  parameter type         aw_chan_t      = logic,
  parameter type         w_chan_t       = logic,
  parameter type         b_chan_t       = logic,
  parameter type         ar_chan_t      = logic,
  parameter type         r_chan_t       = logic,
  parameter type         axi_req_t      = logic,
  parameter type         axi_resp_t     = logic,
  parameter int unsigned NoMstPorts     = 32'd0,
  parameter int unsigned MaxTrans       = 32'd8,
  parameter int unsigned AxiLookBits    = 32'd3,
  parameter bit          UniqueIds      = 1'b0,
  parameter bit          SpillAw        = 1'b1,
  parameter bit          SpillW         = 1'b0,
  parameter bit          SpillB         = 1'b0,
  parameter bit          SpillAr        = 1'b1,
  parameter bit          SpillR         = 1'b0,
  
  parameter int unsigned SelectWidth    = (NoMstPorts > 32'd1) ? $clog2(NoMstPorts) : 32'd1,
  parameter type         select_t       = logic [SelectWidth-1:0]
) (
  input  logic                          clk_i,
  input  logic                          rst_ni,
  input  logic                          test_i,
  
  input  axi_req_t                      slv_req_i,
  input  select_t                       slv_aw_select_i,
  input  select_t                       slv_ar_select_i,
  output axi_resp_t                     slv_resp_o,
  
  output axi_req_t    [NoMstPorts-1:0]  mst_reqs_o,
  input  axi_resp_t   [NoMstPorts-1:0]  mst_resps_i
);
  axi_req_t slv_req_cut;
  axi_resp_t slv_resp_cut;
  logic slv_aw_ready_chan, slv_aw_ready_sel;
  logic slv_aw_valid_chan, slv_aw_valid_sel;
  logic slv_ar_ready_chan, slv_ar_ready_sel;
  logic slv_ar_valid_chan, slv_ar_valid_sel;
  select_t slv_aw_select, slv_ar_select;
  spill_register #(
    .T       ( aw_chan_t  ),
    .Bypass  ( ~SpillAw   )
  ) i_aw_spill_reg (
    .clk_i,
    .rst_ni,
    .valid_i ( slv_req_i.aw_valid    ),
    .ready_o ( slv_aw_ready_chan     ),
    .data_i  ( slv_req_i.aw          ),
    .valid_o ( slv_aw_valid_chan     ),
    .ready_i ( slv_resp_cut.aw_ready ),
    .data_o  ( slv_req_cut.aw        )
  );
  spill_register #(
    .T       ( select_t ),
    .Bypass  ( ~SpillAw )
  ) i_aw_select_spill_reg (
    .clk_i,
    .rst_ni,
    .valid_i ( slv_req_i.aw_valid    ),
    .ready_o ( slv_aw_ready_sel      ),
    .data_i  ( slv_aw_select_i       ),
    .valid_o ( slv_aw_valid_sel      ),
    .ready_i ( slv_resp_cut.aw_ready ),
    .data_o  ( slv_aw_select         )
  );
  assign slv_resp_o.aw_ready  = slv_aw_ready_chan & slv_aw_ready_sel;
  assign slv_req_cut.aw_valid = slv_aw_valid_chan & slv_aw_valid_sel;
  spill_register #(
    .T       ( w_chan_t  ),
    .Bypass  ( ~SpillW   )
  ) i_w_spill_reg (
    .clk_i,
    .rst_ni,
    .valid_i ( slv_req_i.w_valid    ),
    .ready_o ( slv_resp_o.w_ready   ),
    .data_i  ( slv_req_i.w          ),
    .valid_o ( slv_req_cut.w_valid  ),
    .ready_i ( slv_resp_cut.w_ready ),
    .data_o  ( slv_req_cut.w        )
  );
  spill_register #(
    .T       ( ar_chan_t  ),
    .Bypass  ( ~SpillAr   )
  ) i_ar_spill_reg (
    .clk_i,
    .rst_ni,
    .valid_i ( slv_req_i.ar_valid    ),
    .ready_o ( slv_ar_ready_chan     ),
    .data_i  ( slv_req_i.ar          ),
    .valid_o ( slv_ar_valid_chan     ),
    .ready_i ( slv_resp_cut.ar_ready ),
    .data_o  ( slv_req_cut.ar        )
  );
  spill_register #(
    .T       ( select_t ),
    .Bypass  ( ~SpillAr )
  ) i_ar_sel_spill_reg (
    .clk_i,
    .rst_ni,
    .valid_i ( slv_req_i.ar_valid    ),
    .ready_o ( slv_ar_ready_sel      ),
    .data_i  ( slv_ar_select_i       ),
    .valid_o ( slv_ar_valid_sel      ),
    .ready_i ( slv_resp_cut.ar_ready ),
    .data_o  ( slv_ar_select         )
  );
  assign slv_resp_o.ar_ready  = slv_ar_ready_chan & slv_ar_ready_sel;
  assign slv_req_cut.ar_valid = slv_ar_valid_chan & slv_ar_valid_sel;
  spill_register #(
    .T       ( b_chan_t ),
    .Bypass  ( ~SpillB  )
  ) i_b_spill_reg (
    .clk_i,
    .rst_ni,
    .valid_i ( slv_resp_cut.b_valid ),
    .ready_o ( slv_req_cut.b_ready  ),
    .data_i  ( slv_resp_cut.b       ),
    .valid_o ( slv_resp_o.b_valid   ),
    .ready_i ( slv_req_i.b_ready    ),
    .data_o  ( slv_resp_o.b         )
  );
  spill_register #(
    .T       ( r_chan_t ),
    .Bypass  ( ~SpillR  )
  ) i_r_spill_reg (
    .clk_i,
    .rst_ni,
    .valid_i ( slv_resp_cut.r_valid ),
    .ready_o ( slv_req_cut.r_ready  ),
    .data_i  ( slv_resp_cut.r       ),
    .valid_o ( slv_resp_o.r_valid   ),
    .ready_i ( slv_req_i.r_ready    ),
    .data_o  ( slv_resp_o.r         )
  );
  axi_demux_simple #(
    .AxiIdWidth ( AxiIdWidth  ),
    .AtopSupport( AtopSupport ),
    .axi_req_t  ( axi_req_t   ),
    .axi_resp_t ( axi_resp_t  ),
    .NoMstPorts ( NoMstPorts  ),
    .MaxTrans   ( MaxTrans    ),
    .AxiLookBits( AxiLookBits ),
    .UniqueIds  ( UniqueIds   )
  ) i_demux_simple (
    .clk_i,
    .rst_ni,
    .test_i,
    .slv_req_i       ( slv_req_cut   ),
    .slv_aw_select_i ( slv_aw_select ),
    .slv_ar_select_i ( slv_ar_select ),
    .slv_resp_o      ( slv_resp_cut  ),
    .mst_reqs_o      ( mst_reqs_o    ),
    .mst_resps_i     ( mst_resps_i   )
  );
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
module axi_demux_intf #(
  parameter int unsigned AXI_ID_WIDTH     = 32'd0, 
  parameter bit          ATOP_SUPPORT     = 1'b1,
  parameter int unsigned AXI_ADDR_WIDTH   = 32'd0,
  parameter int unsigned AXI_DATA_WIDTH   = 32'd0,
  parameter int unsigned AXI_USER_WIDTH   = 32'd0,
  parameter int unsigned NO_MST_PORTS     = 32'd3,
  parameter int unsigned MAX_TRANS        = 32'd8,
  parameter int unsigned AXI_LOOK_BITS    = 32'd3,
  parameter bit          UNIQUE_IDS       = 1'b0,
  parameter bit          SPILL_AW         = 1'b1,
  parameter bit          SPILL_W          = 1'b0,
  parameter bit          SPILL_B          = 1'b0,
  parameter bit          SPILL_AR         = 1'b1,
  parameter bit          SPILL_R          = 1'b0,
  
  parameter int unsigned SELECT_WIDTH   = (NO_MST_PORTS > 32'd1) ? $clog2(NO_MST_PORTS) : 32'd1,
  parameter type         select_t       = logic [SELECT_WIDTH-1:0] 
) (
  input  logic    clk_i,                 
  input  logic    rst_ni,                
  input  logic    test_i,                
  input  select_t slv_aw_select_i,       
  input  select_t slv_ar_select_i,       
  AXI_BUS.Slave   slv,                   
  AXI_BUS.Master  mst [NO_MST_PORTS-1:0] 
);
  typedef logic [AXI_ID_WIDTH-1:0]       id_t;
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
  axi_req_t                     slv_req;
  axi_resp_t                    slv_resp;
  axi_req_t  [NO_MST_PORTS-1:0] mst_req;
  axi_resp_t [NO_MST_PORTS-1:0] mst_resp;
  `AXI_ASSIGN_TO_REQ(slv_req, slv)
  `AXI_ASSIGN_FROM_RESP(slv, slv_resp)
  for (genvar i = 0; i < NO_MST_PORTS; i++) begin : gen_assign_mst_ports
    `AXI_ASSIGN_FROM_REQ(mst[i], mst_req[i])
    `AXI_ASSIGN_TO_RESP(mst_resp[i], mst[i])
  end
  axi_demux #(
    .AxiIdWidth     ( AXI_ID_WIDTH  ), 
    .AtopSupport    ( ATOP_SUPPORT  ),
    .aw_chan_t      (  aw_chan_t    ), 
    .w_chan_t       (   w_chan_t    ), 
    .b_chan_t       (   b_chan_t    ), 
    .ar_chan_t      (  ar_chan_t    ), 
    .r_chan_t       (   r_chan_t    ), 
    .axi_req_t      (  axi_req_t    ),
    .axi_resp_t     ( axi_resp_t    ),
    .NoMstPorts     ( NO_MST_PORTS  ),
    .MaxTrans       ( MAX_TRANS     ),
    .AxiLookBits    ( AXI_LOOK_BITS ),
    .UniqueIds      ( UNIQUE_IDS    ),
    .SpillAw        ( SPILL_AW      ),
    .SpillW         ( SPILL_W       ),
    .SpillB         ( SPILL_B       ),
    .SpillAr        ( SPILL_AR      ),
    .SpillR         ( SPILL_R       )
  ) i_axi_demux (
    .clk_i,   
    .rst_ni,  
    .test_i,  
    
    .slv_req_i       ( slv_req         ),
    .slv_aw_select_i ( slv_aw_select_i ),
    .slv_ar_select_i ( slv_ar_select_i ),
    .slv_resp_o      ( slv_resp        ),
    
    .mst_reqs_o      ( mst_req         ),
    .mst_resps_i     ( mst_resp        )
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
`ifdef QUESTA
`define TARGET_VSIM`endif
module axi_demux_simple #(
  parameter int unsigned AxiIdWidth     = 32'd0,
  parameter bit          AtopSupport    = 1'b1,
  parameter type         axi_req_t      = logic,
  parameter type         axi_resp_t     = logic,
  parameter int unsigned NoMstPorts     = 32'd0,
  parameter int unsigned MaxTrans       = 32'd8,
  parameter int unsigned AxiLookBits    = 32'd3,
  parameter bit          UniqueIds      = 1'b0,
  
  parameter int unsigned SelectWidth    = (NoMstPorts > 32'd1) ? $clog2(NoMstPorts) : 32'd1,
  parameter type         select_t       = logic [SelectWidth-1:0]
) (
  input  logic                          clk_i,
  input  logic                          rst_ni,
  input  logic                          test_i,
  
  input  axi_req_t                      slv_req_i,
  input  select_t                       slv_aw_select_i,
  input  select_t                       slv_ar_select_i,
  output axi_resp_t                     slv_resp_o,
  
  output axi_req_t    [NoMstPorts-1:0]  mst_reqs_o,
  input  axi_resp_t   [NoMstPorts-1:0]  mst_resps_i
);
  localparam int unsigned IdCounterWidth = cf_math_pkg::idx_width(MaxTrans);
  typedef logic [IdCounterWidth-1:0] id_cnt_t;
  
  if (NoMstPorts == 32'h1) begin : gen_no_demux
    `AXI_ASSIGN_REQ_STRUCT(mst_reqs_o[0], slv_req_i)
    `AXI_ASSIGN_RESP_STRUCT(slv_resp_o, mst_resps_i[0])
  end else begin
    
    
    
    
    
    
    
    
    
    logic                     lock_aw_valid_d,    lock_aw_valid_q, load_aw_lock;
    logic                     aw_valid,           aw_ready;
    
    select_t                  lookup_aw_select;
    logic                     aw_select_occupied, aw_id_cnt_full;
    
    logic                     atop_inject;
    
    select_t                  w_select,           w_select_q;
    logic                     w_select_valid;
    id_cnt_t                  w_open;
    logic                     w_cnt_up,           w_cnt_down;
    
    logic    [NoMstPorts-1:0] mst_b_valids,       mst_b_readies;
    
    
    
    
    select_t                  lookup_ar_select;
    logic                     ar_select_occupied, ar_id_cnt_full;
    logic                     ar_push;
    
    logic                     lock_ar_valid_d,    lock_ar_valid_q, load_ar_lock;
    logic                     ar_valid,           ar_ready;
    logic    [NoMstPorts-1:0] mst_r_valids, mst_r_readies;
    
    
    
    
    
    
    
    
    always_comb begin
      
      slv_resp_o.aw_ready = 1'b0;
      aw_valid     = 1'b0;
      
      
      
      
      
      lock_aw_valid_d = lock_aw_valid_q;
      load_aw_lock    = 1'b0;
      
      w_cnt_up        = 1'b0;
      
      atop_inject     = 1'b0;
      
      if (lock_aw_valid_q) begin
        aw_valid = 1'b1;
        
        if (aw_ready) begin
          slv_resp_o.aw_ready    = 1'b1;
          lock_aw_valid_d = 1'b0;
          load_aw_lock    = 1'b1;
          
          atop_inject     = slv_req_i.aw.atop[axi_pkg::ATOP_R_RESP] & AtopSupport;
        end
      end else begin
        
        
        
        if (!aw_id_cnt_full && (w_open != {IdCounterWidth{1'b1}}) &&
            (!(ar_id_cnt_full && slv_req_i.aw.atop[axi_pkg::ATOP_R_RESP]) ||
             !AtopSupport)) begin
          
          
          
          
          if (slv_req_i.aw_valid &&
                ((w_open == '0) || (w_select == slv_aw_select_i)) &&
                (!aw_select_occupied || (slv_aw_select_i == lookup_aw_select))) begin
            
            aw_valid     = 1'b1;
            
            w_cnt_up     = 1'b1;
            
            if (aw_ready) begin
              slv_resp_o.aw_ready = 1'b1;
              atop_inject  = slv_req_i.aw.atop[axi_pkg::ATOP_R_RESP] & AtopSupport;
            
            end else begin
              lock_aw_valid_d = 1'b1;
              load_aw_lock    = 1'b1;
            end
          end
        end
      end
    end
    
    
    `FFLARN(lock_aw_valid_q, lock_aw_valid_d, load_aw_lock, '0, clk_i, rst_ni)
    if (UniqueIds) begin : gen_unique_ids_aw
      
      
      
      
      
      assign lookup_aw_select = slv_aw_select_i;
      assign aw_select_occupied = 1'b0;
      assign aw_id_cnt_full = 1'b0;
    end else begin : gen_aw_id_counter
      axi_demux_id_counters #(
        .AxiIdBits         ( AxiLookBits    ),
        .CounterWidth      ( IdCounterWidth ),
        .mst_port_select_t ( select_t       )
      ) i_aw_id_counter (
        .clk_i                        ( clk_i                          ),
        .rst_ni                       ( rst_ni                         ),
        .lookup_axi_id_i              ( slv_req_i.aw.id[0+:AxiLookBits] ),
        .lookup_mst_select_o          ( lookup_aw_select               ),
        .lookup_mst_select_occupied_o ( aw_select_occupied             ),
        .full_o                       ( aw_id_cnt_full                 ),
        .inject_axi_id_i              ( '0                             ),
        .inject_i                     ( 1'b0                           ),
        .push_axi_id_i                ( slv_req_i.aw.id[0+:AxiLookBits] ),
        .push_mst_select_i            ( slv_aw_select_i                ),
        .push_i                       ( w_cnt_up                       ),
        .pop_axi_id_i                 ( slv_resp_o.b.id[0+:AxiLookBits]  ),
        .pop_i                        ( slv_resp_o.b_valid & slv_req_i.b_ready      )
      );
      
    end
    
    
    
    
    counter #(
      .WIDTH           ( IdCounterWidth ),
      .STICKY_OVERFLOW ( 1'b0           )
    ) i_counter_open_w (
      .clk_i,
      .rst_ni,
      .clear_i    ( 1'b0                  ),
      .en_i       ( w_cnt_up ^ w_cnt_down ),
      .load_i     ( 1'b0                  ),
      .down_i     ( w_cnt_down            ),
      .d_i        ( '0                    ),
      .q_o        ( w_open                ),
      .overflow_o (           )
    );
    `FFLARN(w_select_q, slv_aw_select_i, w_cnt_up, select_t'(0), clk_i, rst_ni)
    assign w_select       = (|w_open) ? w_select_q : slv_aw_select_i;
    assign w_select_valid = w_cnt_up | (|w_open);
    
    
    
    
    
    
    logic [cf_math_pkg::idx_width(NoMstPorts)-1:0] b_idx;
    
    rr_arb_tree #(
      .NumIn    ( NoMstPorts ),
      .DataType ( logic   ),
      .AxiVldRdy( 1'b1       ),
      .LockIn   ( 1'b1       )
    ) i_b_mux (
      .clk_i  ( clk_i         ),
      .rst_ni ( rst_ni        ),
      .flush_i( 1'b0          ),
      .rr_i   ( '0            ),
      .req_i  ( mst_b_valids  ),
      .gnt_o  ( mst_b_readies ),
      .data_i ( '0   ),
      .gnt_i  ( slv_req_i.b_ready  ),
      .req_o  ( slv_resp_o.b_valid ),
      .data_o (        ),
      .idx_o  ( b_idx              )
    );
    always_comb begin
      if (slv_resp_o.b_valid) begin
        `AXI_SET_B_STRUCT(slv_resp_o.b, mst_resps_i[b_idx].b)
      end else begin
        slv_resp_o.b = '0;
      end
    end
    
    
    
    
    always_comb begin
      
      slv_resp_o.ar_ready    = 1'b0;
      ar_valid        = 1'b0;
      
      
      
      
      lock_ar_valid_d = lock_ar_valid_q;
      load_ar_lock    = 1'b0;
      
      ar_push         = 1'b0;
      
      
      if (lock_ar_valid_q) begin
        ar_valid = 1'b1;
        
        if (ar_ready) begin
          slv_resp_o.ar_ready    = 1'b1;
          ar_push         = 1'b1;
          lock_ar_valid_d = 1'b0;
          load_ar_lock    = 1'b1;
        end
      end else begin
        
        if (!ar_id_cnt_full) begin
          
          if (slv_req_i.ar_valid && (!ar_select_occupied ||
             (slv_ar_select_i == lookup_ar_select))) begin
            
            ar_valid     = 1'b1;
            
            if (ar_ready) begin
              slv_resp_o.ar_ready = 1'b1;
              ar_push      = 1'b1;
            
            end else begin
              lock_ar_valid_d = 1'b1;
              load_ar_lock    = 1'b1;
            end
          end
        end
      end
    end
    
    `FFLARN(lock_ar_valid_q, lock_ar_valid_d, load_ar_lock, '0, clk_i, rst_ni)
    if (UniqueIds) begin : gen_unique_ids_ar
      
      
      
      
      
      assign lookup_ar_select = slv_ar_select_i;
      assign ar_select_occupied = 1'b0;
      assign ar_id_cnt_full = 1'b0;
    end else begin : gen_ar_id_counter
      axi_demux_id_counters #(
        .AxiIdBits         ( AxiLookBits    ),
        .CounterWidth      ( IdCounterWidth ),
        .mst_port_select_t ( select_t       )
      ) i_ar_id_counter (
        .clk_i                        ( clk_i                                       ),
        .rst_ni                       ( rst_ni                                      ),
        .lookup_axi_id_i              ( slv_req_i.ar.id[0+:AxiLookBits]             ),
        .lookup_mst_select_o          ( lookup_ar_select                            ),
        .lookup_mst_select_occupied_o ( ar_select_occupied                          ),
        .full_o                       ( ar_id_cnt_full                              ),
        .inject_axi_id_i              ( slv_req_i.aw.id[0+:AxiLookBits]             ),
        .inject_i                     ( atop_inject                                 ),
        .push_axi_id_i                ( slv_req_i.ar.id[0+:AxiLookBits]             ),
        .push_mst_select_i            ( slv_ar_select_i                             ),
        .push_i                       ( ar_push                                     ),
        .pop_axi_id_i                 ( slv_resp_o.r.id[0+:AxiLookBits]               ),
        .pop_i                        ( slv_resp_o.r_valid & slv_req_i.r_ready & slv_resp_o.r.last )
      );
    end
    
    
    
    logic [cf_math_pkg::idx_width(NoMstPorts)-1:0] r_idx;
    
    rr_arb_tree #(
      .NumIn    ( NoMstPorts ),
      .DataType ( logic   ),
      .AxiVldRdy( 1'b1       ),
      .LockIn   ( 1'b1       )
    ) i_r_mux (
      .clk_i  ( clk_i         ),
      .rst_ni ( rst_ni        ),
      .flush_i( 1'b0          ),
      .rr_i   ( '0            ),
      .req_i  ( mst_r_valids  ),
      .gnt_o  ( mst_r_readies ),
      .data_i ( '0            ),
      .gnt_i  ( slv_req_i.r_ready   ),
      .req_o  ( slv_resp_o.r_valid   ),
      .data_o (),
      .idx_o  ( r_idx              )
    );
    always_comb begin
      if (slv_resp_o.r_valid) begin
        `AXI_SET_R_STRUCT(slv_resp_o.r, mst_resps_i[r_idx].r)
      end else begin
        slv_resp_o.r = '0;
      end
    end
    assign ar_ready = ar_valid & mst_resps_i[slv_ar_select_i].ar_ready;
    assign aw_ready = aw_valid & mst_resps_i[slv_aw_select_i].aw_ready;
    
    
    always_comb begin
      
      mst_reqs_o  = '0;
      slv_resp_o.w_ready = 1'b0;
      w_cnt_down  = 1'b0;
      for (int unsigned i = 0; i < NoMstPorts; i++) begin
        
        mst_reqs_o[i].aw       = slv_req_i.aw;
        mst_reqs_o[i].aw_valid = 1'b0;
        if (aw_valid && (slv_aw_select_i == i)) begin
          mst_reqs_o[i].aw_valid = 1'b1;
        end
        
        mst_reqs_o[i].w       = slv_req_i.w;
        mst_reqs_o[i].w_valid = 1'b0;
        if (w_select_valid && (w_select == i)) begin
          mst_reqs_o[i].w_valid = slv_req_i.w_valid;
          slv_resp_o.w_ready           = mst_resps_i[i].w_ready;
          w_cnt_down            = slv_req_i.w_valid & mst_resps_i[i].w_ready & slv_req_i.w.last;
        end
        
        mst_reqs_o[i].b_ready = mst_b_readies[i];
        
        mst_reqs_o[i].ar       = slv_req_i.ar;
        mst_reqs_o[i].ar_valid = 1'b0;
        if (ar_valid && (slv_ar_select_i == i)) begin
          mst_reqs_o[i].ar_valid = 1'b1;
        end
        
        mst_reqs_o[i].r_ready = mst_r_readies[i];
      end
    end
    
    for (genvar i = 0; i < NoMstPorts; i++) begin : gen_b_channels
      
      assign mst_b_valids[i]       = mst_resps_i[i].b_valid;
      
      assign mst_r_valids[i]       = mst_resps_i[i].r_valid;
    end
`ifndef VERILATOR
`ifndef XSIM
    initial begin: validate_params
      no_mst_ports: assume (NoMstPorts > 0) else
        $fatal(1, "The Number of slaves (NoMstPorts) has to be at least 1");
      AXI_ID_BITS:  assume (AxiIdWidth >= AxiLookBits) else
        $fatal(1, "AxiIdBits has to be equal or smaller than AxiIdWidth.");
    end
    default disable iff (!rst_ni);
    aw_select: assume property( @(posedge clk_i) (slv_req_i.aw_valid |->
                                                 (slv_aw_select_i < NoMstPorts))) else
      $fatal(1, "slv_aw_select_i is %d: AW has selected a slave that is not defined.\
                 NoMstPorts: %d", slv_aw_select_i, NoMstPorts);
    ar_select: assume property( @(posedge clk_i) (slv_req_i.ar_valid |->
                                                 (slv_ar_select_i < NoMstPorts))) else
      $fatal(1, "slv_ar_select_i is %d: AR has selected a slave that is not defined.\
                 NoMstPorts: %d", slv_ar_select_i, NoMstPorts);
    aw_valid_stable: assert property( @(posedge clk_i) (aw_valid && !aw_ready) |=> aw_valid) else
      $fatal(1, "aw_valid was deasserted, when aw_ready = 0 in last cycle.");
    ar_valid_stable: assert property( @(posedge clk_i)
                               (ar_valid && !ar_ready) |=> ar_valid) else
      $fatal(1, "ar_valid was deasserted, when ar_ready = 0 in last cycle.");
    slv_aw_chan_stable: assert property( @(posedge clk_i) (aw_valid && !aw_ready)
                               |=> $stable(slv_req_i.aw)) else
      $fatal(1, "slv_aw_chan unstable with valid set.");
    slv_aw_select_stable: assert property( @(posedge clk_i) (aw_valid && !aw_ready)
                               |=> $stable(slv_aw_select_i)) else
      $fatal(1, "slv_aw_select_i unstable with valid set.");
    slv_ar_chan_stable: assert property( @(posedge clk_i) (ar_valid && !ar_ready)
                               |=> $stable(slv_req_i.ar)) else
      $fatal(1, "slv_ar_chan unstable with valid set.");
    slv_ar_select_stable: assert property( @(posedge clk_i) (ar_valid && !ar_ready)
                               |=> $stable(slv_ar_select_i)) else
      $fatal(1, "slv_ar_select_i unstable with valid set.");
    internal_ar_select: assert property( @(posedge clk_i)
        (ar_valid |-> slv_ar_select_i < NoMstPorts))
      else $fatal(1, "slv_ar_select_i illegal while ar_valid.");
    internal_aw_select: assert property( @(posedge clk_i)
        (aw_valid |-> slv_aw_select_i < NoMstPorts))
      else $fatal(1, "slv_aw_select_i illegal while aw_valid.");
    w_underflow: assert property( @(posedge clk_i)
        ((w_open == '0) && (w_cnt_up ^ w_cnt_down) |-> !w_cnt_down)) else
        $fatal(1, "W counter underflowed!");
    `ASSUME(NoAtopAllowed, !AtopSupport && slv_req_i.aw_valid |-> slv_req_i.aw.atop == '0)
`endif
`endif
  end
endmodule
module axi_demux_id_counters #(
  
  parameter int unsigned AxiIdBits         = 2,
  parameter int unsigned CounterWidth      = 4,
  parameter type         mst_port_select_t = logic
) (
  input  logic                 clk_i,   
  input  logic                 rst_ni,  
  
  input  logic [AxiIdBits-1:0] lookup_axi_id_i,
  output mst_port_select_t     lookup_mst_select_o,
  output logic                 lookup_mst_select_occupied_o,
  
  output logic                 full_o,
  input  logic [AxiIdBits-1:0] push_axi_id_i,
  input  mst_port_select_t     push_mst_select_i,
  input  logic                 push_i,
  
  input  logic [AxiIdBits-1:0] inject_axi_id_i,
  input  logic                 inject_i,
  
  input  logic [AxiIdBits-1:0] pop_axi_id_i,
  input  logic                 pop_i
);
  localparam int unsigned NoCounters = 2**AxiIdBits;
  typedef logic [CounterWidth-1:0] cnt_t;
  
  mst_port_select_t [NoCounters-1:0] mst_select_q;
  
  logic [NoCounters-1:0] push_en, inject_en, pop_en, occupied, cnt_full;
  
  
  
  assign lookup_mst_select_o          = mst_select_q[lookup_axi_id_i];
  assign lookup_mst_select_occupied_o = occupied[lookup_axi_id_i];
  
  
  
  assign push_en   = (push_i)   ? (1 << push_axi_id_i)   : '0;
  assign inject_en = (inject_i) ? (1 << inject_axi_id_i) : '0;
  assign pop_en    = (pop_i)    ? (1 << pop_axi_id_i)    : '0;
  assign full_o    = |cnt_full;
  
  for (genvar i = 0; i < NoCounters; i++) begin : gen_counters
    logic cnt_en, cnt_down, overflow;
    cnt_t cnt_delta, in_flight;
    always_comb begin
      unique case ({push_en[i], inject_en[i], pop_en[i]})
        3'b001  : begin 
          cnt_en    = 1'b1;
          cnt_down  = 1'b1;
          cnt_delta = cnt_t'(1);
        end
        3'b010  : begin 
          cnt_en    = 1'b1;
          cnt_down  = 1'b0;
          cnt_delta = cnt_t'(1);
        end
     
        3'b100  : begin 
          cnt_en    = 1'b1;
          cnt_down  = 1'b0;
          cnt_delta = cnt_t'(1);
        end
     
        3'b110  : begin 
          cnt_en    = 1'b1;
          cnt_down  = 1'b0;
          cnt_delta = cnt_t'(2);
        end
        3'b111  : begin 
          cnt_en    = 1'b1;
          cnt_down  = 1'b0;
          cnt_delta = cnt_t'(1);
        end
        default : begin 
          cnt_en    = 1'b0;
          cnt_down  = 1'b0;
          cnt_delta = cnt_t'(0);
        end
      endcase
    end
    delta_counter #(
      .WIDTH           ( CounterWidth ),
      .STICKY_OVERFLOW ( 1'b0         )
    ) i_in_flight_cnt (
      .clk_i      ( clk_i     ),
      .rst_ni     ( rst_ni    ),
      .clear_i    ( 1'b0      ),
      .en_i       ( cnt_en    ),
      .load_i     ( 1'b0      ),
      .down_i     ( cnt_down  ),
      .delta_i    ( cnt_delta ),
      .d_i        ( '0        ),
      .q_o        ( in_flight ),
      .overflow_o ( overflow  )
    );
    assign occupied[i] = |in_flight;
    assign cnt_full[i] = overflow | (&in_flight);
    
    `FFLARN(mst_select_q[i], push_mst_select_i, push_en[i], '0, clk_i, rst_ni)
`ifndef VERILATOR
`ifndef XSIM
    
    cnt_underflow: assert property(
      @(posedge clk_i) disable iff (~rst_ni) (pop_en[i] |=> !overflow)) else
        $fatal(1, "axi_demux_id_counters > Counter: %0d underflowed.\
                   The reason is probably a faulty AXI response.", i);
`endif
`endif
  end
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
module axi_to_detailed_mem #(
  
  parameter type         axi_req_t  = logic,
  
  parameter type         axi_resp_t = logic,
  
  
  
  parameter int unsigned AddrWidth  = 1,
  
  parameter int unsigned DataWidth  = 1,
  
  parameter int unsigned IdWidth    = 1,
  
  parameter int unsigned UserWidth  = 1,
  
  parameter int unsigned NumBanks   = 1,
  
  parameter int unsigned BufDepth   = 1,
  
  parameter bit          HideStrb   = 1'b0,
  
  parameter int unsigned OutFifoDepth = 1,
  
  localparam type addr_t     = logic [AddrWidth-1:0],
  
  localparam type mem_data_t = logic [DataWidth/NumBanks-1:0],
  
  localparam type mem_strb_t = logic [DataWidth/NumBanks/8-1:0],
  
  localparam type mem_id_t   = logic [IdWidth-1:0],
  
  localparam type mem_user_t = logic [UserWidth-1:0]
) (
  
  input  logic                             clk_i,
  
  input  logic                             rst_ni,
  
  output logic                             busy_o,
  
  input  axi_req_t                         axi_req_i,
  
  output axi_resp_t                        axi_resp_o,
  
  output logic             [NumBanks-1:0]  mem_req_o,
  
  input  logic             [NumBanks-1:0]  mem_gnt_i,
  
  output addr_t            [NumBanks-1:0]  mem_addr_o,
  
  output mem_data_t        [NumBanks-1:0]  mem_wdata_o,
  
  output mem_strb_t        [NumBanks-1:0]  mem_strb_o,
  
  output axi_pkg::atop_t   [NumBanks-1:0]  mem_atop_o,
  
  output logic             [NumBanks-1:0]  mem_lock_o,
  
  output logic             [NumBanks-1:0]  mem_we_o,
  
  output mem_id_t          [NumBanks-1:0]  mem_id_o,
  
  output mem_user_t        [NumBanks-1:0]  mem_user_o,
  
  output axi_pkg::cache_t  [NumBanks-1:0]  mem_cache_o,
  
  output axi_pkg::prot_t   [NumBanks-1:0]  mem_prot_o,
  
  output axi_pkg::qos_t    [NumBanks-1:0]  mem_qos_o,
  
  output axi_pkg::region_t [NumBanks-1:0]  mem_region_o,
  
  
  input  logic             [NumBanks-1:0]  mem_rvalid_i,
  
  input  mem_data_t        [NumBanks-1:0]  mem_rdata_i,
  
  input  logic             [NumBanks-1:0]  mem_err_i,
  
  input  logic             [NumBanks-1:0]  mem_exokay_i
);
  typedef logic [DataWidth-1:0]   axi_data_t;
  typedef logic [DataWidth/8-1:0] axi_strb_t;
  typedef logic [IdWidth-1:0]     axi_id_t;
  typedef struct packed {
    addr_t            addr;
    axi_pkg::atop_t   atop;
    logic             lock;
    axi_strb_t        strb;
    axi_data_t        wdata;
    logic             we;
    mem_id_t          id;
    mem_user_t        user;
    axi_pkg::cache_t  cache;
    axi_pkg::prot_t   prot;
    axi_pkg::qos_t    qos;
    axi_pkg::region_t region;
  } mem_req_t;
  typedef struct packed {
    addr_t            addr;
    axi_pkg::atop_t   atop;
    logic             lock;
    axi_strb_t        strb;
    axi_id_t          id;
    logic             last;
    axi_pkg::qos_t    qos;
    axi_pkg::size_t   size;
    logic             write;
    mem_user_t        user;
    axi_pkg::cache_t  cache;
    axi_pkg::prot_t   prot;
    axi_pkg::region_t region;
  } meta_t;
  typedef struct packed {
    axi_data_t           data;
    logic [NumBanks-1:0] err;
    logic [NumBanks-1:0] exokay;
  } mem_rsp_t;
  mem_rsp_t       m2s_resp;
  axi_pkg::len_t  r_cnt_d,        r_cnt_q,
                  w_cnt_d,        w_cnt_q;
  logic           arb_valid,      arb_ready,
                  rd_valid,       rd_ready,
                  wr_valid,       wr_ready,
                  sel_b,          sel_buf_b,
                  sel_r,          sel_buf_r,
                  sel_valid,      sel_ready,
                  sel_buf_valid,  sel_buf_ready,
                  sel_lock_d,     sel_lock_q,
                  meta_valid,     meta_ready,
                  meta_buf_valid, meta_buf_ready,
                  meta_sel_d,     meta_sel_q,
                  m2s_req_valid,  m2s_req_ready,
                  m2s_resp_valid, m2s_resp_ready;
  mem_req_t       m2s_req;
  meta_t          rd_meta,
                  rd_meta_d,      rd_meta_q,
                  wr_meta,
                  wr_meta_d,      wr_meta_q,
                  meta,           meta_buf;
  assign busy_o = axi_req_i.aw_valid | axi_req_i.ar_valid | axi_req_i.w_valid |
                    axi_resp_o.b_valid | axi_resp_o.r_valid |
                    (r_cnt_q > 0) | (w_cnt_q > 0);
  
  always_comb begin
    
    axi_resp_o.ar_ready = 1'b0;
    rd_meta_d           = rd_meta_q;
    rd_meta             = meta_t'{default: '0};
    rd_valid            = 1'b0;
    r_cnt_d             = r_cnt_q;
    
    if (r_cnt_q > '0) begin
      rd_meta_d.last = (r_cnt_q == 8'd1);
      rd_meta        = rd_meta_d;
      rd_meta.addr   = rd_meta_q.addr + axi_pkg::num_bytes(rd_meta_q.size);
      rd_valid       = 1'b1;
      if (rd_ready) begin
        r_cnt_d--;
        rd_meta_d.addr = rd_meta.addr;
      end
    
    end else if (axi_req_i.ar_valid) begin
      rd_meta_d = '{
        addr:   addr_t'(axi_pkg::aligned_addr(axi_pkg::largest_addr_t'(axi_req_i.ar.addr), axi_req_i.ar.size)),
        atop:   '0,
        lock:   axi_req_i.ar.lock,
        strb:   '0,
        id:     axi_req_i.ar.id,
        last:   (axi_req_i.ar.len == '0),
        qos:    axi_req_i.ar.qos,
        size:   axi_req_i.ar.size,
        write:  1'b0,
        user:   axi_req_i.ar.user,
        cache:  axi_req_i.ar.cache,
        prot:   axi_req_i.ar.prot,
        region: axi_req_i.ar.region
      };
      rd_meta      = rd_meta_d;
      rd_meta.addr = addr_t'(axi_req_i.ar.addr);
      rd_valid     = 1'b1;
      if (rd_ready) begin
        r_cnt_d             = axi_req_i.ar.len;
        axi_resp_o.ar_ready = 1'b1;
      end
    end
  end
  
  always_comb begin
    
    axi_resp_o.aw_ready = 1'b0;
    axi_resp_o.w_ready  = 1'b0;
    wr_meta_d           = wr_meta_q;
    wr_meta             = meta_t'{default: '0};
    wr_valid            = 1'b0;
    w_cnt_d             = w_cnt_q;
    
    if (w_cnt_q > '0) begin
      wr_meta_d.last = (w_cnt_q == 8'd1);
      wr_meta        = wr_meta_d;
      wr_meta.addr   = wr_meta_q.addr + axi_pkg::num_bytes(wr_meta_q.size);
      if (axi_req_i.w_valid) begin
        wr_valid = 1'b1;
        wr_meta.strb = axi_req_i.w.strb;
        if (wr_ready) begin
          axi_resp_o.w_ready = 1'b1;
          w_cnt_d--;
          wr_meta_d.addr = wr_meta.addr;
        end
      end
    
    end else if (axi_req_i.aw_valid && axi_req_i.w_valid) begin
      wr_meta_d = '{
        addr:   addr_t'(axi_pkg::aligned_addr(axi_pkg::largest_addr_t'(axi_req_i.aw.addr), axi_req_i.aw.size)),
        atop:   axi_req_i.aw.atop,
        lock:   axi_req_i.aw.lock,
        strb:   axi_req_i.w.strb,
        id:     axi_req_i.aw.id,
        last:   (axi_req_i.aw.len == '0),
        qos:    axi_req_i.aw.qos,
        size:   axi_req_i.aw.size,
        write:  1'b1,
        user:   axi_req_i.aw.user,
        cache:  axi_req_i.aw.cache,
        prot:   axi_req_i.aw.prot,
        region: axi_req_i.aw.region
      };
      wr_meta = wr_meta_d;
      wr_meta.addr = addr_t'(axi_req_i.aw.addr);
      wr_valid = 1'b1;
      if (wr_ready) begin
        w_cnt_d = axi_req_i.aw.len;
        axi_resp_o.aw_ready = 1'b1;
        axi_resp_o.w_ready = 1'b1;
      end
    end
  end
  
  stream_mux #(
    .DATA_T ( meta_t ),
    .N_INP  ( 32'd2  )
  ) i_ax_mux (
    .inp_data_i   ({wr_meta,  rd_meta }),
    .inp_valid_i  ({wr_valid, rd_valid}),
    .inp_ready_o  ({wr_ready, rd_ready}),
    .inp_sel_i    ( meta_sel_d         ),
    .oup_data_o   ( meta               ),
    .oup_valid_o  ( arb_valid          ),
    .oup_ready_i  ( arb_ready          )
  );
  always_comb begin
    meta_sel_d = meta_sel_q;
    sel_lock_d = sel_lock_q;
    if (sel_lock_q) begin
      meta_sel_d = meta_sel_q;
      if (arb_valid && arb_ready) begin
        sel_lock_d = 1'b0;
      end
    end else begin
      if (wr_valid ^ rd_valid) begin
        
        meta_sel_d = wr_valid;
      end else if (wr_valid && rd_valid) begin
        
        
        if (wr_meta.qos > rd_meta.qos) begin
          meta_sel_d = 1'b1;
        end else if (rd_meta.qos > wr_meta.qos) begin
          meta_sel_d = 1'b0;
        
        end else if (wr_meta.qos == rd_meta.qos) begin
          
          
          if (wr_meta.last && !rd_meta.last) begin
            meta_sel_d = 1'b1;
          
          
          end else if (w_cnt_q > '0) begin
            meta_sel_d = 1'b1;
          end else if (r_cnt_q > '0) begin
            meta_sel_d = 1'b0;
          
          end else begin
            meta_sel_d = ~meta_sel_q;
          end
        end
      end
      
      if (arb_valid && !arb_ready) begin
        sel_lock_d = 1'b1;
      end
    end
  end
  
  stream_fork #(
    .N_OUP ( 32'd3 )
  ) i_fork (
    .clk_i,
    .rst_ni,
    .valid_i ( arb_valid                            ),
    .ready_o ( arb_ready                            ),
    .valid_o ({sel_valid, meta_valid, m2s_req_valid}),
    .ready_i ({sel_ready, meta_ready, m2s_req_ready})
  );
  assign sel_b = meta.write & meta.last;
  assign sel_r = ~meta.write | meta.atop[5];
  stream_fifo #(
    .FALL_THROUGH ( 1'b1             ),
    .DEPTH        ( 32'd1 + BufDepth ),
    .T            ( logic[1:0]       )
  ) i_sel_buf (
    .clk_i,
    .rst_ni,
    .flush_i    ( 1'b0                    ),
    .testmode_i ( 1'b0                    ),
    .data_i     ({sel_b,        sel_r    }),
    .valid_i    ( sel_valid               ),
    .ready_o    ( sel_ready               ),
    .data_o     ({sel_buf_b,    sel_buf_r}),
    .valid_o    ( sel_buf_valid           ),
    .ready_i    ( sel_buf_ready           ),
    .usage_o    (             )
  );
  stream_fifo #(
    .FALL_THROUGH ( 1'b1             ),
    .DEPTH        ( 32'd1 + BufDepth ),
    .T            ( meta_t           )
  ) i_meta_buf (
    .clk_i,
    .rst_ni,
    .flush_i    ( 1'b0           ),
    .testmode_i ( 1'b0           ),
    .data_i     ( meta           ),
    .valid_i    ( meta_valid     ),
    .ready_o    ( meta_ready     ),
    .data_o     ( meta_buf       ),
    .valid_o    ( meta_buf_valid ),
    .ready_i    ( meta_buf_ready ),
    .usage_o    (    )
  );
  
  assign m2s_req = mem_req_t'{
    addr:   meta.addr,
    atop:   meta.atop,
    lock:   meta.lock,
    strb:   axi_req_i.w.strb,
    wdata:  axi_req_i.w.data,
    we:     meta.write,
    id:     meta.id,
    user:   meta.user,
    cache:  meta.cache,
    prot:   meta.prot,
    qos:    meta.qos,
    region: meta.region
  };
  typedef struct packed {
    axi_pkg::atop_t   atop;
    logic             lock;
    mem_id_t          id;
    mem_user_t        user;
    axi_pkg::cache_t  cache;
    axi_pkg::prot_t   prot;
    axi_pkg::qos_t    qos;
    axi_pkg::region_t region;
  } tmp_atop_t;
  tmp_atop_t mem_req_atop;
  tmp_atop_t [NumBanks-1:0] banked_req_atop;
  assign mem_req_atop = '{
    atop:   m2s_req.atop,
    lock:   m2s_req.lock,
    id:     m2s_req.id,
    user:   m2s_req.user,
    cache:  m2s_req.cache,
    prot:   m2s_req.prot,
    qos:    m2s_req.qos,
    region: m2s_req.region
  };
  for (genvar i = 0; i < NumBanks; i++) begin
    assign mem_atop_o  [i] = banked_req_atop[i].atop;
    assign mem_lock_o  [i] = banked_req_atop[i].lock;
    assign mem_id_o    [i] = banked_req_atop[i].id;
    assign mem_user_o  [i] = banked_req_atop[i].user;
    assign mem_cache_o [i] = banked_req_atop[i].cache;
    assign mem_prot_o  [i] = banked_req_atop[i].prot;
    assign mem_qos_o   [i] = banked_req_atop[i].qos;
    assign mem_region_o[i] = banked_req_atop[i].region;
  end
  logic [NumBanks-1:0][1:0] tmp_ersp;
  logic [NumBanks-1:0][1:0] bank_ersp;
  for (genvar i = 0; i < NumBanks; i++) begin
    assign m2s_resp.err[i]    = tmp_ersp[i][0];
    assign m2s_resp.exokay[i] = tmp_ersp[i][1];
    assign bank_ersp[i][0] = mem_err_i[i];
    assign bank_ersp[i][1] = mem_exokay_i[i];
  end
  
  mem_stream_to_banks_detailed #(
    .AddrWidth   ( AddrWidth         ),
    .DataWidth   ( DataWidth         ),
    .RUserWidth  ( 2                 ),
    .NumBanks    ( NumBanks          ),
    .HideStrb    ( HideStrb          ),
    .MaxTrans    ( BufDepth          ),
    .OutFifoDepth( OutFifoDepth      ),
    .WUserWidth  ( $bits(tmp_atop_t) )
  ) i_mem_to_banks (
    .clk_i,
    .rst_ni,
    .req_i         ( m2s_req_valid ),
    .gnt_o         ( m2s_req_ready ),
    .addr_i        ( m2s_req.addr  ),
    .wdata_i       ( m2s_req.wdata ),
    .strb_i        ( m2s_req.strb  ),
    .wuser_i       ( mem_req_atop  ),
    .we_i          ( m2s_req.we    ),
    .rvalid_o      ( m2s_resp_valid ),
    .rready_i      ( m2s_resp_ready ),
    .rdata_o       ( m2s_resp.data ),
    .ruser_o       ( tmp_ersp      ),
    .bank_req_o    ( mem_req_o     ),
    .bank_gnt_i    ( mem_gnt_i     ),
    .bank_addr_o   ( mem_addr_o    ),
    .bank_wdata_o  ( mem_wdata_o   ),
    .bank_strb_o   ( mem_strb_o    ),
    .bank_wuser_o  ( banked_req_atop ),
    .bank_we_o     ( mem_we_o      ),
    .bank_rvalid_i ( mem_rvalid_i  ),
    .bank_rdata_i  ( mem_rdata_i   ),
    .bank_ruser_i  ( bank_ersp     )
  );
  
  logic mem_join_valid, mem_join_ready;
  stream_join #(
    .N_INP ( 32'd2 )
  ) i_join (
    .inp_valid_i  ({m2s_resp_valid, meta_buf_valid}),
    .inp_ready_o  ({m2s_resp_ready, meta_buf_ready}),
    .oup_valid_o  ( mem_join_valid                 ),
    .oup_ready_i  ( mem_join_ready                 )
  );
  
  stream_fork_dynamic #(
    .N_OUP ( 32'd2 )
  ) i_fork_dynamic (
    .clk_i,
    .rst_ni,
    .valid_i      ( mem_join_valid                         ),
    .ready_o      ( mem_join_ready                         ),
    .sel_i        ({sel_buf_b,          sel_buf_r         }),
    .sel_valid_i  ( sel_buf_valid                          ),
    .sel_ready_o  ( sel_buf_ready                          ),
    .valid_o      ({axi_resp_o.b_valid, axi_resp_o.r_valid}),
    .ready_i      ({axi_req_i.b_ready,  axi_req_i.r_ready })
  );
  localparam NumBytesPerBank = DataWidth/NumBanks/8;
  logic [NumBanks-1:0] meta_buf_bank_strb, meta_buf_size_enable;
  logic resp_b_err, resp_b_exokay, resp_r_err, resp_r_exokay;
  
  
  for (genvar i = 0; i < NumBanks; i++) begin
    
    assign meta_buf_bank_strb[i] = |meta_buf.strb[i*NumBytesPerBank +: NumBytesPerBank];
    
    assign meta_buf_size_enable[i] = ((i*NumBytesPerBank + NumBytesPerBank) > (meta_buf.addr % DataWidth/8)) &&
                                     ((i*NumBytesPerBank) < ((meta_buf.addr % DataWidth/8) + 1<<meta_buf.size));
  end
  assign resp_b_err    = |(m2s_resp.err    &  meta_buf_bank_strb);   
  assign resp_b_exokay = &(m2s_resp.exokay | ~meta_buf_bank_strb) & meta_buf.lock;   
  assign resp_r_err    = |(m2s_resp.err    &  meta_buf_size_enable); 
  assign resp_r_exokay = &(m2s_resp.exokay | ~meta_buf_size_enable) & meta_buf.lock; 
  logic collect_b_err_d, collect_b_err_q;
  logic collect_b_exokay_d, collect_b_exokay_q;
  logic next_collect_b_err, next_collect_b_exokay;
  
  
  assign next_collect_b_err = collect_b_err_q | resp_b_err;
  assign next_collect_b_exokay = collect_b_exokay_q & resp_b_exokay;
  always_comb begin
    
    collect_b_err_d = collect_b_err_q;
    collect_b_exokay_d = collect_b_exokay_q;
    
    if (sel_buf_valid && sel_buf_ready) begin
      if (meta_buf.write && meta_buf.last) begin
        collect_b_err_d = 1'b0;
        collect_b_exokay_d = 1'b1;
      end else if (meta_buf.write) begin
        collect_b_err_d = next_collect_b_err;
        collect_b_exokay_d = next_collect_b_exokay;
      end
    end
  end
  
  assign axi_resp_o.b = '{
    id:   meta_buf.id,
    resp: next_collect_b_err ? axi_pkg::RESP_SLVERR : next_collect_b_exokay ? axi_pkg::RESP_EXOKAY : axi_pkg::RESP_OKAY,
    user: '0
  };
  
  assign axi_resp_o.r = '{
    data: m2s_resp.data,
    id:   meta_buf.id,
    last: meta_buf.last,
    resp: resp_r_err ? axi_pkg::RESP_SLVERR : resp_r_exokay ? axi_pkg::RESP_EXOKAY : axi_pkg::RESP_OKAY,
    user: '0
  };
  
  `FFARN(meta_sel_q, meta_sel_d, 1'b0, clk_i, rst_ni)
  `FFARN(sel_lock_q, sel_lock_d, 1'b0, clk_i, rst_ni)
  `FFARN(rd_meta_q, rd_meta_d, meta_t'{default: '0}, clk_i, rst_ni)
  `FFARN(wr_meta_q, wr_meta_d, meta_t'{default: '0}, clk_i, rst_ni)
  `FFARN(r_cnt_q, r_cnt_d, '0, clk_i, rst_ni)
  `FFARN(w_cnt_q, w_cnt_d, '0, clk_i, rst_ni)
  `FFARN(collect_b_err_q, collect_b_err_d, '0, clk_i, rst_ni)
  `FFARN(collect_b_exokay_q, collect_b_exokay_d, 1'b1, clk_i, rst_ni)
  
  
  `ifndef VERILATOR
  default disable iff (!rst_ni);
  assume property (@(posedge clk_i)
      axi_req_i.ar_valid && !axi_resp_o.ar_ready |=> $stable(axi_req_i.ar))
    else $error("AR must remain stable until handshake has happened!");
  assert property (@(posedge clk_i)
      axi_resp_o.r_valid && !axi_req_i.r_ready |=> $stable(axi_resp_o.r))
    else $error("R must remain stable until handshake has happened!");
  assume property (@(posedge clk_i)
      axi_req_i.aw_valid && !axi_resp_o.aw_ready |=> $stable(axi_req_i.aw))
    else $error("AW must remain stable until handshake has happened!");
  assume property (@(posedge clk_i)
      axi_req_i.w_valid && !axi_resp_o.w_ready |=> $stable(axi_req_i.w))
    else $error("W must remain stable until handshake has happened!");
  assert property (@(posedge clk_i)
      axi_resp_o.b_valid && !axi_req_i.b_ready |=> $stable(axi_resp_o.b))
    else $error("B must remain stable until handshake has happened!");
  assert property (@(posedge clk_i) axi_req_i.ar_valid && axi_req_i.ar.len > 0 |->
      axi_req_i.ar.burst == axi_pkg::BURST_INCR)
    else $error("Non-incrementing bursts are not supported!");
  assert property (@(posedge clk_i) axi_req_i.aw_valid && axi_req_i.aw.len > 0 |->
      axi_req_i.aw.burst == axi_pkg::BURST_INCR)
    else $error("Non-incrementing bursts are not supported!");
  assert property (@(posedge clk_i) meta_valid && meta.atop != '0 |-> meta.write)
    else $warning("Unexpected atomic operation on read.");
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
module axi_to_detailed_mem_intf #(
  
  parameter int unsigned ADDR_WIDTH     = 32'd0,
  
  parameter int unsigned DATA_WIDTH     = 32'd0,
  
  parameter int unsigned ID_WIDTH       = 32'd0,
  
  parameter int unsigned USER_WIDTH     = 32'd0,
  
  parameter int unsigned NUM_BANKS      = 32'd0,
  
  parameter int unsigned BUF_DEPTH      = 32'd1,
  
  parameter bit          HIDE_STRB      = 1'b0,
  
  parameter int unsigned OUT_FIFO_DEPTH = 32'd1,
  
  localparam type addr_t     = logic [ADDR_WIDTH-1:0],
  
  localparam type mem_data_t = logic [DATA_WIDTH/NUM_BANKS-1:0],
  
  localparam type mem_strb_t = logic [DATA_WIDTH/NUM_BANKS/8-1:0]
) (
  
  input  logic                              clk_i,
  
  input  logic                              rst_ni,
  
  output logic                              busy_o,
  
  AXI_BUS.Slave                             slv,
  
  output logic             [NUM_BANKS-1:0]  mem_req_o,
  
  input  logic             [NUM_BANKS-1:0]  mem_gnt_i,
  
  output addr_t            [NUM_BANKS-1:0]  mem_addr_o,
  
  output mem_data_t        [NUM_BANKS-1:0]  mem_wdata_o,
  
  output mem_strb_t        [NUM_BANKS-1:0]  mem_strb_o,
  
  output axi_pkg::atop_t   [NUM_BANKS-1:0]  mem_atop_o,
  
  output logic             [NUM_BANKS-1:0]  mem_lock_o,
  
  output logic             [NUM_BANKS-1:0]  mem_we_o,
  
  output logic             [NUM_BANKS-1:0]  mem_id_o,
  
  output logic             [NUM_BANKS-1:0]  mem_user_o,
  
  output axi_pkg::cache_t  [NUM_BANKS-1:0]  mem_cache_o,
  
  output axi_pkg::prot_t   [NUM_BANKS-1:0]  mem_prot_o,
  
  output axi_pkg::qos_t    [NUM_BANKS-1:0]  mem_qos_o,
  
  output axi_pkg::region_t [NUM_BANKS-1:0]  mem_region_o,
  
  input  logic             [NUM_BANKS-1:0]  mem_rvalid_i,
  
  input  mem_data_t        [NUM_BANKS-1:0]  mem_rdata_i,
  
  input  logic             [NUM_BANKS-1:0]  mem_err_i,
  
  input  logic             [NUM_BANKS-1:0]  mem_exokay_i
);
  typedef logic [ID_WIDTH-1:0]     id_t;
  typedef logic [DATA_WIDTH-1:0]   data_t;
  typedef logic [DATA_WIDTH/8-1:0] strb_t;
  typedef logic [USER_WIDTH-1:0]   user_t;
  `AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)
  `AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)
  `AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_R_CHAN_T(r_chan_t, data_t, id_t, user_t)
  `AXI_TYPEDEF_REQ_T(req_t, aw_chan_t, w_chan_t, ar_chan_t)
  `AXI_TYPEDEF_RESP_T(resp_t, b_chan_t, r_chan_t)
  req_t   req;
  resp_t  resp;
  `AXI_ASSIGN_TO_REQ(req, slv)
  `AXI_ASSIGN_FROM_RESP(slv, resp)
  axi_to_detailed_mem #(
    .axi_req_t    ( req_t          ),
    .axi_resp_t   ( resp_t         ),
    .AddrWidth    ( ADDR_WIDTH     ),
    .DataWidth    ( DATA_WIDTH     ),
    .IdWidth      ( ID_WIDTH       ),
    .UserWidth    ( USER_WIDTH     ),
    .NumBanks     ( NUM_BANKS      ),
    .BufDepth     ( BUF_DEPTH      ),
    .HideStrb     ( HIDE_STRB      ),
    .OutFifoDepth ( OUT_FIFO_DEPTH )
  ) i_axi_to_detailed_mem (
    .clk_i,
    .rst_ni,
    .busy_o,
    .axi_req_i  ( req  ),
    .axi_resp_o ( resp ),
    .mem_req_o,
    .mem_gnt_i,
    .mem_addr_o,
    .mem_wdata_o,
    .mem_strb_o,
    .mem_atop_o,
    .mem_lock_o,
    .mem_we_o,
    .mem_id_o,
    .mem_user_o,
    .mem_cache_o,
    .mem_prot_o,
    .mem_qos_o,
    .mem_region_o,
    .mem_rvalid_i,
    .mem_rdata_i,
    .mem_err_i,
    .mem_exokay_i
  );
endmodule
module mem_stream_to_banks_detailed #(
  
  parameter int unsigned AddrWidth = 32'd0,
  
  parameter int unsigned DataWidth = 32'd0,
  
  parameter int unsigned WUserWidth = 32'd0,
  
  parameter int unsigned RUserWidth = 32'd0,
  
  parameter int unsigned NumBanks  = 32'd1,
  
  parameter bit          HideStrb  = 1'b0,
  
  parameter int unsigned MaxTrans  = 32'd1,
  
  parameter int unsigned OutFifoDepth  = 32'd1,
  
  parameter  type wuser_t     = logic [WUserWidth-1:0],
  
  localparam type addr_t      = logic [AddrWidth-1:0],
  
  localparam type inp_data_t  = logic [DataWidth-1:0],
  
  localparam type inp_strb_t  = logic [DataWidth/8-1:0],
  
  localparam type inp_ruser_t = logic [NumBanks-1:0][RUserWidth-1:0],
  
  localparam type oup_data_t  = logic [DataWidth/NumBanks-1:0],
  
  localparam type oup_strb_t  = logic [DataWidth/NumBanks/8-1:0],
  
  localparam type oup_ruser_t = logic [RUserWidth-1:0]
) (
  
  input  logic                       clk_i,
  
  input  logic                       rst_ni,
  
  input  logic                       req_i,
  
  output logic                       gnt_o,
  
  input  addr_t                      addr_i,
  
  input  inp_data_t                  wdata_i,
  
  input  inp_strb_t                  strb_i,
  
  input  wuser_t                     wuser_i,
  
  input  logic                       we_i,
  
  output logic                       rvalid_o,
  
  input  logic                       rready_i,
  
  output inp_data_t                  rdata_o,
  
  output inp_ruser_t                 ruser_o,
  
  output logic       [NumBanks-1:0]  bank_req_o,
  
  input  logic       [NumBanks-1:0]  bank_gnt_i,
  
  output addr_t      [NumBanks-1:0]  bank_addr_o,
  
  output oup_data_t  [NumBanks-1:0]  bank_wdata_o,
  
  output oup_strb_t  [NumBanks-1:0]  bank_strb_o,
  
  output wuser_t     [NumBanks-1:0]  bank_wuser_o,
  
  output logic       [NumBanks-1:0]  bank_we_o,
  
  input  logic       [NumBanks-1:0]  bank_rvalid_i,
  
  input  oup_data_t  [NumBanks-1:0]  bank_rdata_i,
  
  input  oup_ruser_t [NumBanks-1:0]  bank_ruser_i
);
  localparam int unsigned DataBytes    = $bits(inp_strb_t);
  localparam int unsigned BitsPerBank  = $bits(oup_data_t);
  localparam int unsigned BytesPerBank = $bits(oup_strb_t);
  typedef struct packed {
    addr_t     addr;
    oup_data_t wdata;
    oup_strb_t strb;
    wuser_t    wuser;
    logic      we;
  } req_t;
  logic                 req_valid;
  logic [NumBanks-1:0]              req_ready,
                        resp_valid, resp_ready;
  req_t [NumBanks-1:0]  bank_req,
                        bank_oup;
  logic [NumBanks-1:0]  bank_req_internal, bank_gnt_internal, zero_strobe, dead_response;
  logic                 dead_write_fifo_full;
  function automatic addr_t align_addr(input addr_t addr);
    return (addr >> $clog2(DataBytes)) << $clog2(DataBytes);
  endfunction
  logic mem_req_valid, mem_req_ready;
  
  typedef logic [$clog2(MaxTrans+1):0] cnt_t;
  cnt_t cnt_d, cnt_q;
  logic cnt_req_ready;
  if (MaxTrans > 0) begin : gen_buf
    
    always_comb begin
      cnt_d = cnt_q;
      if (req_i && gnt_o) begin
        cnt_d++;
      end
      if (rvalid_o && rready_i) begin
        cnt_d--;
      end
    end
    
    
    assign cnt_req_ready = (cnt_q < MaxTrans) | (rvalid_o & rready_i);
    
    assign gnt_o = mem_req_ready & cnt_req_ready;
    assign mem_req_valid = req_i & cnt_req_ready;
    
    `FFARN(cnt_q, cnt_d, '0, clk_i, rst_ni)
  end
  
  assign req_valid = mem_req_valid & mem_req_ready;
  for (genvar i = 0; unsigned'(i) < NumBanks; i++) begin : gen_reqs
    assign bank_req[i].addr  = align_addr(addr_i) + 7'(i * BytesPerBank);
    assign bank_req[i].wdata = wdata_i[i*BitsPerBank+:BitsPerBank];
    assign bank_req[i].strb  = strb_i[i*BytesPerBank+:BytesPerBank];
    assign bank_req[i].wuser = wuser_i;
    assign bank_req[i].we    = we_i;
    stream_fifo #(
      .FALL_THROUGH ( 1'b1         ),
      .DATA_WIDTH   ( $bits(req_t) ),
      .DEPTH        ( OutFifoDepth ),
      .T            ( req_t        )
    ) i_ft_reg (
      .clk_i,
      .rst_ni,
      .flush_i    ( 1'b0          ),
      .testmode_i ( 1'b0          ),
      .usage_o    (),
      .data_i     ( bank_req[i]   ),
      .valid_i    ( req_valid     ),
      .ready_o    ( req_ready[i]  ),
      .data_o     ( bank_oup[i]   ),
      .valid_o    ( bank_req_internal[i] ),
      .ready_i    ( bank_gnt_internal[i] )
    );
    assign bank_addr_o[i]  = bank_oup[i].addr;
    assign bank_wdata_o[i] = bank_oup[i].wdata;
    assign bank_strb_o[i]  = bank_oup[i].strb;
    assign bank_wuser_o[i] = bank_oup[i].wuser;
    assign bank_we_o[i]    = bank_oup[i].we;
    assign zero_strobe[i] = (bank_oup[i].strb == '0);
    if (HideStrb) begin : gen_hide_strb
      assign bank_req_o[i] = (bank_oup[i].we && zero_strobe[i]) ? 1'b0 : bank_req_internal[i];
      assign bank_gnt_internal[i] = (bank_oup[i].we && zero_strobe[i]) ? 1'b1 : bank_gnt_i[i];
    end else begin : gen_legacy_strb
      assign bank_req_o[i] = bank_req_internal[i];
      assign bank_gnt_internal[i] = bank_gnt_i[i];
    end
  end
  
  assign mem_req_ready = (&req_ready) & (&resp_ready) & !dead_write_fifo_full;
  if (HideStrb) begin : gen_dead_write_fifo
    logic                dead_write_fifo_empty;
    logic [NumBanks-1:0] dead_write_fifo_out_data;
    logic [NumBanks-1:0] zero_strobe_on_input;
    for (genvar i = 0; unsigned'(i) < NumBanks; i++) begin
      assign zero_strobe_on_input[i] = (strb_i[i*BytesPerBank+:BytesPerBank] == '0);
    end
    fifo_v3 #(
      .FALL_THROUGH ( 1'b0     ),
      .DEPTH        ( MaxTrans+1 ),
      .DATA_WIDTH   ( NumBanks )
    ) i_dead_write_fifo (
      .clk_i,
      .rst_ni,
      .flush_i    ( 1'b0                             ),
      .testmode_i ( 1'b0                             ),
      .full_o     ( dead_write_fifo_full             ),
      .empty_o    ( dead_write_fifo_empty            ),
      .usage_o    (                                  ),
      .data_i     ( we_i ? zero_strobe_on_input : '0 ),
      .push_i     ( mem_req_valid & mem_req_ready    ),
      .data_o     ( dead_write_fifo_out_data         ),
      .pop_i      ( rvalid_o & rready_i              )
    );
    
    
    assign dead_response = dead_write_fifo_empty ? '0 : dead_write_fifo_out_data;
  end else begin : gen_no_dead_write_fifo
    assign dead_response = '0;
    assign dead_write_fifo_full = 1'b0;
  end
  
  for (genvar i = 0; unsigned'(i) < NumBanks; i++) begin : gen_resp_regs
    stream_fifo #(
      .FALL_THROUGH ( 1'b1              ),
      .DATA_WIDTH   ( $bits(oup_data_t) + $bits(oup_ruser_t) ),
      .DEPTH        ( MaxTrans         )
    ) i_ft_reg (
      .clk_i,
      .rst_ni,
      .flush_i    ( 1'b0                                              ),
      .testmode_i ( 1'b0                                              ),
      .usage_o    (),
      .data_i     ( {bank_rdata_i[i], bank_ruser_i[i]}                ),
      .valid_i    ( bank_rvalid_i[i]                                  ),
      .ready_o    ( resp_ready[i]                                     ),
      .data_o     ( {rdata_o[i*BitsPerBank+:BitsPerBank], ruser_o[i]} ),
      .valid_o    ( resp_valid[i]                                     ),
      .ready_i    ( rvalid_o & !dead_response[i] & rready_i           )
    );
  end
  assign rvalid_o = &(resp_valid | dead_response);
  
  `ifndef SYNTHESIS
  `ifndef COMMON_CELLS_ASSERTS_OFF
  `ifndef SYNTHESIS
    initial begin
      assume (DataWidth != 0 && (DataWidth & (DataWidth - 1)) == 0)
        else $fatal(1, "Data width must be a power of two!");
      assume (DataWidth % NumBanks == 0)
        else $fatal(1, "Data width must be evenly divisible over banks!");
      assume ((DataWidth / NumBanks) % 8 == 0)
        else $fatal(1, "Data width of each bank must be divisible into 8-bit bytes!");
    end
  `endif
  `endif
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
module axi_to_mem #(
  
  parameter type         axi_req_t  = logic,
  
  parameter type         axi_resp_t = logic,
  
  
  
  parameter int unsigned AddrWidth  = 0,
  
  parameter int unsigned DataWidth  = 0,
  
  parameter int unsigned IdWidth    = 0,
  
  parameter int unsigned NumBanks   = 0,
  
  parameter int unsigned BufDepth   = 1,
  
  parameter bit          HideStrb   = 1'b0,
  
  parameter int unsigned OutFifoDepth = 1,
  
  localparam type addr_t     = logic [AddrWidth-1:0],
  
  localparam type mem_data_t = logic [DataWidth/NumBanks-1:0],
  
  localparam type mem_strb_t = logic [DataWidth/NumBanks/8-1:0]
) (
  
  input  logic                           clk_i,
  
  input  logic                           rst_ni,
  
  output logic                           busy_o,
  
  input  axi_req_t                       axi_req_i,
  
  output axi_resp_t                      axi_resp_o,
  
  output logic           [NumBanks-1:0]  mem_req_o,
  
  input  logic           [NumBanks-1:0]  mem_gnt_i,
  
  output addr_t          [NumBanks-1:0]  mem_addr_o,
  
  output mem_data_t      [NumBanks-1:0]  mem_wdata_o,
  
  output mem_strb_t      [NumBanks-1:0]  mem_strb_o,
  
  output axi_pkg::atop_t [NumBanks-1:0]  mem_atop_o,
  
  output logic           [NumBanks-1:0]  mem_we_o,
  
  
  input  logic           [NumBanks-1:0]  mem_rvalid_i,
  
  input  mem_data_t      [NumBanks-1:0]  mem_rdata_i
);
  axi_to_detailed_mem #(
    .axi_req_t    ( axi_req_t    ),
    .axi_resp_t   ( axi_resp_t   ),
    .AddrWidth    ( AddrWidth    ),
    .DataWidth    ( DataWidth    ),
    .IdWidth      ( IdWidth      ),
    .UserWidth    ( 1            ),
    .NumBanks     ( NumBanks     ),
    .BufDepth     ( BufDepth     ),
    .HideStrb     ( HideStrb     ),
    .OutFifoDepth ( OutFifoDepth )
  ) i_axi_to_detailed_mem (
    .clk_i,
    .rst_ni,
    .busy_o,
    .axi_req_i    ( axi_req_i     ),
    .axi_resp_o   ( axi_resp_o    ),
    .mem_req_o    ( mem_req_o     ),
    .mem_gnt_i    ( mem_gnt_i     ),
    .mem_addr_o   ( mem_addr_o    ),
    .mem_wdata_o  ( mem_wdata_o   ),
    .mem_strb_o   ( mem_strb_o    ),
    .mem_atop_o   ( mem_atop_o    ),
    .mem_lock_o   (),
    .mem_we_o     ( mem_we_o      ),
    .mem_id_o     (),
    .mem_user_o   (),
    .mem_cache_o  (),
    .mem_prot_o   (),
    .mem_qos_o    (),
    .mem_region_o (),
    .mem_rvalid_i ( mem_rvalid_i ),
    .mem_rdata_i  ( mem_rdata_i   ),
    .mem_err_i    ('0),
    .mem_exokay_i ('0)
  );
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
module axi_to_mem_intf #(
  
  parameter int unsigned ADDR_WIDTH     = 32'd0,
  
  parameter int unsigned DATA_WIDTH     = 32'd0,
  
  parameter int unsigned ID_WIDTH       = 32'd0,
  
  parameter int unsigned USER_WIDTH     = 32'd0,
  
  parameter int unsigned NUM_BANKS      = 32'd0,
  
  parameter int unsigned BUF_DEPTH      = 32'd1,
  
  parameter bit          HIDE_STRB      = 1'b0,
  
  parameter int unsigned OUT_FIFO_DEPTH = 32'd1,
  
  localparam type addr_t     = logic [ADDR_WIDTH-1:0],
  
  localparam type mem_data_t = logic [DATA_WIDTH/NUM_BANKS-1:0],
  
  localparam type mem_strb_t = logic [DATA_WIDTH/NUM_BANKS/8-1:0]
) (
  
  input  logic                            clk_i,
  
  input  logic                            rst_ni,
  
  output logic                            busy_o,
  
  AXI_BUS.Slave                           slv,
  
  output logic           [NUM_BANKS-1:0]  mem_req_o,
  
  input  logic           [NUM_BANKS-1:0]  mem_gnt_i,
  
  output addr_t          [NUM_BANKS-1:0]  mem_addr_o,
  
  output mem_data_t      [NUM_BANKS-1:0]  mem_wdata_o,
  
  output mem_strb_t      [NUM_BANKS-1:0]  mem_strb_o,
  
  output axi_pkg::atop_t [NUM_BANKS-1:0]  mem_atop_o,
  
  output logic           [NUM_BANKS-1:0]  mem_we_o,
  
  input  logic           [NUM_BANKS-1:0]  mem_rvalid_i,
  
  input  mem_data_t      [NUM_BANKS-1:0]  mem_rdata_i
);
  typedef logic [ID_WIDTH-1:0]     id_t;
  typedef logic [DATA_WIDTH-1:0]   data_t;
  typedef logic [DATA_WIDTH/8-1:0] strb_t;
  typedef logic [USER_WIDTH-1:0]   user_t;
  `AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)
  `AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)
  `AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)
  `AXI_TYPEDEF_R_CHAN_T(r_chan_t, data_t, id_t, user_t)
  `AXI_TYPEDEF_REQ_T(req_t, aw_chan_t, w_chan_t, ar_chan_t)
  `AXI_TYPEDEF_RESP_T(resp_t, b_chan_t, r_chan_t)
  req_t   req;
  resp_t  resp;
  `AXI_ASSIGN_TO_REQ(req, slv)
  `AXI_ASSIGN_FROM_RESP(slv, resp)
  axi_to_mem #(
    .axi_req_t    ( req_t          ),
    .axi_resp_t   ( resp_t         ),
    .AddrWidth    ( ADDR_WIDTH     ),
    .DataWidth    ( DATA_WIDTH     ),
    .IdWidth      ( ID_WIDTH       ),
    .NumBanks     ( NUM_BANKS      ),
    .BufDepth     ( BUF_DEPTH      ),
    .HideStrb     ( HIDE_STRB      ),
    .OutFifoDepth ( OUT_FIFO_DEPTH )
  ) i_axi_to_mem (
    .clk_i,
    .rst_ni,
    .busy_o,
    .axi_req_i  ( req  ),
    .axi_resp_o ( resp ),
    .mem_req_o,
    .mem_gnt_i,
    .mem_addr_o,
    .mem_wdata_o,
    .mem_strb_o,
    .mem_atop_o,
    .mem_we_o,
    .mem_rvalid_i,
    .mem_rdata_i
  );
endmodule

module TopModule #(
  
  parameter int unsigned                  AxiIdWidth    = 32'd0,
  
  parameter int unsigned                  AxiAddrWidth  = 32'd0,
  
  parameter int unsigned                  AxiDataWidth  = 32'd0,
  
  parameter type                          axi_aw_chan_t = logic,
  
  parameter type                          axi_w_chan_t  = logic,
  
  parameter type                          axi_b_chan_t  = logic,
  
  parameter type                          axi_ar_chan_t = logic,
  
  parameter type                          axi_r_chan_t  = logic,
  
  parameter type                          axi_req_t     = logic,
  
  parameter type                          axi_resp_t    = logic,
  
  
  
  
  parameter int unsigned                  MemNumBanks   = 32'd4,
  
  parameter int unsigned                  MemAddrWidth  = 32'd11,
  
  
  
  parameter int unsigned                  MemDataWidth  = 32'd32,
  
  parameter int unsigned                  MemLatency    = 32'd1,
  
  parameter bit                           HideStrb      = 1'b0,
  
  parameter int unsigned                  OutFifoDepth = 1,
  
  parameter type mem_addr_t = logic [MemAddrWidth-1:0],
  
  parameter type mem_atop_t = axi_pkg::atop_t,
  
  parameter type mem_data_t = logic [MemDataWidth-1:0],
  
  parameter type mem_strb_t = logic [MemDataWidth/8-1:0]
) (
  
  input  logic                        clk_i,
  
  input  logic                        rst_ni,
  
  input  logic                        test_i,
  
  input  axi_req_t                    axi_req_i,
  
  output axi_resp_t                   axi_resp_o,
  
  output logic      [MemNumBanks-1:0] mem_req_o,
  
  input  logic      [MemNumBanks-1:0] mem_gnt_i,
  
  output mem_addr_t [MemNumBanks-1:0] mem_add_o,
  
  output logic      [MemNumBanks-1:0] mem_we_o,
  
  output mem_data_t [MemNumBanks-1:0] mem_wdata_o,
  
  output mem_strb_t [MemNumBanks-1:0] mem_be_o,
  
  output mem_atop_t [MemNumBanks-1:0] mem_atop_o,
  
  input  mem_data_t [MemNumBanks-1:0] mem_rdata_i,
  
  output logic      [1:0]             axi_to_mem_busy_o
);
  
  
  localparam int unsigned BanksPerAxiChannel = AxiDataWidth / MemDataWidth;
  
  
  localparam int unsigned BankSelOffset = $clog2(MemDataWidth / 32'd8);
  
  
  localparam int unsigned BankSelWidth  = cf_math_pkg::idx_width(MemNumBanks);
  typedef logic [BankSelWidth-1:0] xbar_sel_t;
  
  typedef enum logic {
    ReadAccess  = 1'b0,
    WriteAccess = 1'b1
  } access_type_e;
  typedef logic [AxiAddrWidth-1:0] axi_addr_t;
  
  typedef struct packed {
    
    mem_addr_t addr;
    
    logic      we;
    
    mem_data_t wdata;
    
    mem_strb_t wstrb;
    
    mem_atop_t atop;
  } xbar_payload_t;
  
  typedef struct packed {
    
    xbar_sel_t sel;
    
    logic      valid;
  } read_sel_t;
  axi_req_t  [1:0] mem_axi_reqs;
  axi_resp_t [1:0] mem_axi_resps;
  
  axi_demux #(
    .AxiIdWidth  ( AxiIdWidth    ),
    .AtopSupport ( 1'b1          ),
    .aw_chan_t   ( axi_aw_chan_t ),
    .w_chan_t    ( axi_w_chan_t  ),
    .b_chan_t    ( axi_b_chan_t  ),
    .ar_chan_t   ( axi_ar_chan_t ),
    .r_chan_t    ( axi_r_chan_t  ),
    .axi_req_t   ( axi_req_t     ),
    .axi_resp_t  ( axi_resp_t    ),
    .NoMstPorts  ( 32'd2         ),
    .MaxTrans    ( MemLatency+2  ), 
    .AxiLookBits ( 32'd1         ), 
    .UniqueIds   ( 1'b1          ), 
    .SpillAw     ( 1'b1          ),
    .SpillW      ( 1'b1          ),
    .SpillB      ( 1'b1          ),
    .SpillAr     ( 1'b1          ),
    .SpillR      ( 1'b1          )
  ) i_axi_demux (
    .clk_i,
    .rst_ni,
    .test_i,
    .slv_req_i       ( axi_req_i     ),
    .slv_aw_select_i ( WriteAccess   ),
    .slv_ar_select_i ( ReadAccess    ),
    .slv_resp_o      ( axi_resp_o    ),
    .mst_reqs_o      ( mem_axi_reqs  ),
    .mst_resps_i     ( mem_axi_resps )
  );
  xbar_payload_t [1:0][BanksPerAxiChannel-1:0] inter_payload;
  xbar_sel_t     [1:0][BanksPerAxiChannel-1:0] inter_sel;
  logic          [1:0][BanksPerAxiChannel-1:0] inter_valid,   inter_ready;
  
  for (genvar i = 0; i < 2; i++) begin : gen_axi_to_mem
    axi_addr_t [BanksPerAxiChannel-1:0] req_addr;  
    mem_data_t [BanksPerAxiChannel-1:0] req_wdata, res_rdata;
    mem_strb_t [BanksPerAxiChannel-1:0] req_wstrb;
    mem_atop_t [BanksPerAxiChannel-1:0] req_atop;
    logic      [BanksPerAxiChannel-1:0] req_we,    res_valid;
    
    
    axi_to_mem #(
      .axi_req_t    ( axi_req_t          ),
      .axi_resp_t   ( axi_resp_t         ),
      .AddrWidth    ( AxiAddrWidth       ),
      .DataWidth    ( AxiDataWidth       ),
      .IdWidth      ( AxiIdWidth         ),
      .NumBanks     ( BanksPerAxiChannel ),
      .BufDepth     ( MemLatency         ),
      .HideStrb     ( HideStrb           ),
      .OutFifoDepth ( OutFifoDepth       )
    ) i_axi_to_mem (
      .clk_i,
      .rst_ni,
      .busy_o       ( axi_to_mem_busy_o[i]            ),
      .axi_req_i    ( mem_axi_reqs[i]                 ),
      .axi_resp_o   ( mem_axi_resps[i]                ),
      .mem_req_o    ( inter_valid[i]                  ),
      .mem_gnt_i    ( inter_ready[i] & inter_valid[i] ), 
      .mem_addr_o   ( req_addr                        ),
      .mem_wdata_o  ( req_wdata                       ),
      .mem_strb_o   ( req_wstrb                       ),
      .mem_atop_o   ( req_atop                        ),
      .mem_we_o     ( req_we                          ),
      .mem_rvalid_i ( res_valid                       ),
      .mem_rdata_i  ( res_rdata                       )
    );
    
    for (genvar j = 0; unsigned'(j) < BanksPerAxiChannel; j++) begin : gen_response_mux
      
      assign inter_sel[i][j] = req_addr[j][BankSelOffset+:BankSelWidth];
      
      assign inter_payload[i][j] = xbar_payload_t'{
        
        addr:    req_addr[j][(BankSelOffset+BankSelWidth)+:MemAddrWidth],
        we:      req_we[j],
        wdata:   req_wdata[j],
        wstrb:   req_wstrb[j],
        atop:    req_atop[j],
        default: '0
      };
      
      read_sel_t r_shift_inp, r_shift_oup;
      
      assign r_shift_inp = read_sel_t'{
        sel:     inter_sel[i][j],                       
        valid:   inter_valid[i][j] & inter_ready[i][j], 
        default: '0
      };
      
      
      assign res_valid[j] = r_shift_oup.valid;
      assign res_rdata[j] = mem_rdata_i[r_shift_oup.sel];
      
      shift_reg #(
        .dtype ( read_sel_t ),
        .Depth ( MemLatency )
      ) i_shift_reg_rdata_mux (
        .clk_i,
        .rst_ni,
        .d_i    ( r_shift_inp ),
        .d_o    ( r_shift_oup )
      );
    end
  end
  
  xbar_payload_t [MemNumBanks-1:0] mem_payload;
  stream_xbar #(
    .NumInp      ( 32'd2 * BanksPerAxiChannel ),
    .NumOut      ( MemNumBanks                ),
    .payload_t   ( xbar_payload_t             ),
    .OutSpillReg ( 1'b0                       ),
    .ExtPrio     ( 1'b0                       ),
    .AxiVldRdy   ( 1'b1                       ),
    .LockIn      ( 1'b1                       )
  ) i_stream_xbar (
    .clk_i,
    .rst_ni,
    .flush_i ( 1'b0          ),
    .rr_i    ( '0            ),
    .data_i  ( inter_payload ),
    .sel_i   ( inter_sel     ),
    .valid_i ( inter_valid   ),
    .ready_o ( inter_ready   ),
    .data_o  ( mem_payload   ),
    .idx_o   (   ),
    .valid_o ( mem_req_o     ),
    .ready_i ( mem_gnt_i     )
  );
  
  for (genvar i = 0; unsigned'(i) < MemNumBanks; i++) begin : gen_mem_outp
    assign mem_add_o[i]   = mem_payload[i].addr;
    assign mem_we_o[i]    = mem_payload[i].we;
    assign mem_wdata_o[i] = mem_payload[i].wdata;
    assign mem_be_o[i]    = mem_payload[i].wstrb;
    assign mem_atop_o[i]  = mem_payload[i].atop;
  end
`ifndef VERILATOR
  initial begin: p_assertions
    assert (AxiIdWidth   >= 32'd1) else $fatal(1, "AxiIdWidth must be at least 1!");
    assert (AxiAddrWidth >= 32'd1) else $fatal(1, "AxiAddrWidth must be at least 1!");
    assert (AxiDataWidth >= 32'd1) else $fatal(1, "AxiDataWidth must be at least 1!");
    assert (MemNumBanks  >= 32'd2 * AxiDataWidth / MemDataWidth) else
        $fatal(1, "MemNumBanks has to be >= 2 * AxiDataWidth / MemDataWidth");
    assert (MemLatency   >= 32'd1) else $fatal(1, "MemLatency has to be at least 1!");
    assert ($onehot(MemNumBanks))  else $fatal(1, "MemNumBanks has to be a power of 2.");
    assert (MemAddrWidth >= 32'd1) else $fatal(1, "MemAddrWidth must be at least 1!");
    assert (MemDataWidth >= 32'd1) else $fatal(1, "MemDataWidth must be at least 1!");
    assert (AxiDataWidth % MemDataWidth == 0) else
        $fatal(1, "MemDataWidth has to be a divisor of AxiDataWidth.");
  end
`endif
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
module axi_to_mem_banked_intf #(
  
  parameter int unsigned                  AXI_ID_WIDTH   = 32'd0,
  
  parameter int unsigned                  AXI_ADDR_WIDTH = 32'd0,
  
  parameter int unsigned                  AXI_DATA_WIDTH = 32'd0,
  
  parameter int unsigned                  AXI_USER_WIDTH = 32'd0,
  
  
  
  
  parameter int unsigned                  MEM_NUM_BANKS  = 32'd4,
  
  parameter int unsigned                  MEM_ADDR_WIDTH = 32'd11,
  
  
  
  parameter int unsigned                  MEM_DATA_WIDTH = 32'd32,
  
  parameter int unsigned                  MEM_LATENCY    = 32'd1,
  
  parameter bit                           HIDE_STRB      = 1'b0,
  
  parameter int unsigned                  OUT_FIFO_DEPTH = 32'd1,
  
  parameter type mem_addr_t = logic [MEM_ADDR_WIDTH-1:0],
  parameter type mem_atop_t = logic [5:0],
  parameter type mem_data_t = logic [MEM_DATA_WIDTH-1:0],
  parameter type mem_strb_t = logic [MEM_DATA_WIDTH/8-1:0]
) (
  
  input  logic                          clk_i,
  
  input  logic                          rst_ni,
  
  input  logic                          test_i,
  
  AXI_BUS.Slave                         slv,
  
  output logic      [MEM_NUM_BANKS-1:0] mem_req_o,
  
  input  logic      [MEM_NUM_BANKS-1:0] mem_gnt_i,
  
  output mem_addr_t [MEM_NUM_BANKS-1:0] mem_add_o,
  
  output logic      [MEM_NUM_BANKS-1:0] mem_we_o,
  
  output mem_data_t [MEM_NUM_BANKS-1:0] mem_wdata_o,
  
  output mem_strb_t [MEM_NUM_BANKS-1:0] mem_be_o,
  
  output mem_atop_t [MEM_NUM_BANKS-1:0] mem_atop_o,
  
  input  mem_data_t [MEM_NUM_BANKS-1:0] mem_rdata_i,
  
  output logic      [1:0]               axi_to_mem_busy_o
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
  axi_req_t  mem_axi_req;
  axi_resp_t mem_axi_resp;
  `AXI_ASSIGN_TO_REQ(mem_axi_req, slv)
  `AXI_ASSIGN_FROM_RESP(slv, mem_axi_resp)
  TopModule #(
    .AxiIdWidth    ( AXI_ID_WIDTH               ),
    .AxiAddrWidth  ( AXI_ADDR_WIDTH             ),
    .AxiDataWidth  ( AXI_DATA_WIDTH             ),
    .axi_aw_chan_t ( aw_chan_t                  ),
    .axi_w_chan_t  (  w_chan_t                  ),
    .axi_b_chan_t  (  b_chan_t                  ),
    .axi_ar_chan_t ( ar_chan_t                  ),
    .axi_r_chan_t  (  r_chan_t                  ),
    .axi_req_t     ( axi_req_t                  ),
    .axi_resp_t    ( axi_resp_t                 ),
    .MemNumBanks   ( MEM_NUM_BANKS              ),
    .MemAddrWidth  ( MEM_ADDR_WIDTH             ),
    .MemDataWidth  ( MEM_DATA_WIDTH             ),
    .MemLatency    ( MEM_LATENCY                ),
    .HideStrb      ( HIDE_STRB                  ),
    .OutFifoDepth  ( OUT_FIFO_DEPTH             )
  ) i_axi_to_mem_banked (
    .clk_i,
    .rst_ni,
    .test_i,
    .axi_to_mem_busy_o,
    .axi_req_i      ( mem_axi_req  ),
    .axi_resp_o     ( mem_axi_resp ),
    .mem_req_o,
    .mem_gnt_i,
    .mem_add_o,
    .mem_wdata_o,
    .mem_be_o,
    .mem_atop_o,
    .mem_we_o,
    .mem_rdata_i
  );
`ifndef VERILATOR
  initial begin: p_assertions
    assert (AXI_ADDR_WIDTH  >= 1) else $fatal(1, "AXI address width must be at least 1!");
    assert (AXI_DATA_WIDTH  >= 1) else $fatal(1, "AXI data width must be at least 1!");
    assert (AXI_ID_WIDTH    >= 1) else $fatal(1, "AXI ID   width must be at least 1!");
    assert (AXI_USER_WIDTH  >= 1) else $fatal(1, "AXI user width must be at least 1!");
  end
`endif
endmodule
