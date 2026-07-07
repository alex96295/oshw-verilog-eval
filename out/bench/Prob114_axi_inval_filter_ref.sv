
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

module TopModule #(
    
    parameter int  unsigned MaxTxns     = 32'd0,
    
    parameter int  unsigned AddrWidth   = 32'd0,
    parameter int  unsigned L1LineWidth = 32'd0,
    parameter type          aw_chan_t   = logic,
    parameter type          req_t       = logic,
    parameter type          resp_t      = logic
  ) (
    input logic clk_i,
    input logic rst_ni,
    input logic en_i,
    
    input  req_t  slv_req_i,
    output resp_t slv_resp_o,
    
    output req_t  mst_req_o,
    input  resp_t mst_resp_i,
    
    output logic [AddrWidth-1:0] inval_addr_o,
    output logic                 inval_valid_o,
    input  logic                 inval_ready_i
  );
  import cf_math_pkg::idx_width;
  
  
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
  
  logic     aw_fifo_full, aw_fifo_empty;
  logic     aw_fifo_push, aw_fifo_pop;
  aw_chan_t aw_fifo_data;
  assign aw_fifo_push = en_i & slv_req_i.aw_valid & slv_resp_o.aw_ready;
  
  logic [AddrWidth-1:0] inval_offset_d, inval_offset_q;
  assign inval_addr_o  = aw_fifo_data.addr + inval_offset_q;
  assign inval_valid_o = ~aw_fifo_empty;
  
  
  
  always_comb begin : axi
    
    mst_req_o  = slv_req_i;
    slv_resp_o = mst_resp_i;
    
    if (aw_fifo_full) begin
      slv_resp_o.aw_ready = 1'b0;
      mst_req_o.aw_valid  = 1'b0;
    end
  end
  
  
  
  enum logic { Idle, Invalidating } state_d, state_q;
  always_comb begin : inval_fsm
    
    state_d        = state_q;
    aw_fifo_pop    = 1'b0;
    inval_offset_d = inval_offset_q;
    unique case (state_q)
      
      Idle: begin
        
        if (!aw_fifo_empty) begin
          
          if (inval_ready_i) begin
            
            
            if ((L1LineWidth - aw_fifo_data.addr[idx_width(L1LineWidth)-1:0]) < ((aw_fifo_data.len + 1) << aw_fifo_data.size)) begin
              state_d        = Invalidating;
              inval_offset_d = L1LineWidth - aw_fifo_data.addr[idx_width(L1LineWidth)-1:0];
            end else begin
              aw_fifo_pop = 1'b1;
            end
          end
        end
      end
      
      Invalidating: begin
        
        if (inval_ready_i) begin
          inval_offset_d = inval_offset_q + L1LineWidth;
          
          if (inval_offset_d >= ((aw_fifo_data.len + 1) << aw_fifo_data.size)) begin
            state_d        = Idle;
            inval_offset_d = '0;
            aw_fifo_pop    = 1'b1;
          end
        end
      end
    endcase
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      state_q        <= Idle;
      inval_offset_q <= '0;
    end else begin
      state_q        <= state_d;
      inval_offset_q <= inval_offset_d;
    end
  end
  fifo_v3 #(
    .FALL_THROUGH ( 1'b1      ),
    .DEPTH        ( MaxTxns   ),
    .dtype        ( aw_chan_t )
  ) i_aw_fifo (
    .clk_i      ( clk_i         ),
    .rst_ni     ( rst_ni        ),
    .flush_i    ( 1'b0          ),
    .testmode_i ( 1'b0          ),
    .full_o     ( aw_fifo_full  ),
    .empty_o    ( aw_fifo_empty ),
    .usage_o    (               ),
    .data_i     ( slv_req_i.aw  ),
    .push_i     ( aw_fifo_push  ),
    .data_o     ( aw_fifo_data  ),
    .pop_i      ( aw_fifo_pop   )
  );
endmodule : TopModule
