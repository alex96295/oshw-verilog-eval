
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
  
  parameter int unsigned    MemAddrWidth    = 32'd0,
  
  parameter int unsigned    AxiAddrWidth    = 32'd0,
  
  parameter int unsigned    DataWidth       = 32'd0,
  
  parameter int unsigned    MaxRequests     = 32'd0,
  
  parameter axi_pkg::prot_t AxiProt         = 3'b000,
  
  parameter type            axi_req_t       = logic,
  
  parameter type            axi_rsp_t       = logic
) (
  
  input  logic                    clk_i,
  
  input  logic                    rst_ni,
  
  input  logic                    mem_req_i,
  
  
  
  input  logic [MemAddrWidth-1:0] mem_addr_i,
  
  
  
  
  input  logic                    mem_we_i,
  
  input  logic [DataWidth-1:0]    mem_wdata_i,
  
  
  
  input  logic [DataWidth/8-1:0]  mem_be_i,
  
  output logic                    mem_gnt_o,
  
  
  output logic                    mem_rsp_valid_o,
  
  
  output logic [DataWidth-1:0]    mem_rsp_rdata_o,
  
  output logic                    mem_rsp_error_o,
  
  input  axi_pkg::cache_t         slv_aw_cache_i,
  
  input  axi_pkg::cache_t         slv_ar_cache_i,
  
  output axi_req_t                axi_req_o,
  
  input  axi_rsp_t                axi_rsp_i
);
  `AXI_LITE_TYPEDEF_ALL(axi_lite, logic [AxiAddrWidth-1:0], logic [DataWidth-1:0], logic [DataWidth/8-1:0])
  axi_lite_req_t axi_lite_req;
  axi_lite_resp_t axi_lite_rsp;
  axi_lite_from_mem #(
    .MemAddrWidth    ( MemAddrWidth    ),
    .AxiAddrWidth    ( AxiAddrWidth    ),
    .DataWidth       ( DataWidth       ),
    .MaxRequests     ( MaxRequests     ),
    .AxiProt         ( AxiProt         ),
    .axi_req_t       ( axi_lite_req_t  ),
    .axi_rsp_t       ( axi_lite_resp_t )
  ) i_axi_lite_from_mem (
    .clk_i,
    .rst_ni,
    .mem_req_i,
    .mem_addr_i,
    .mem_we_i,
    .mem_wdata_i,
    .mem_be_i,
    .mem_gnt_o,
    .mem_rsp_valid_o,
    .mem_rsp_rdata_o,
    .mem_rsp_error_o,
    .axi_req_o       ( axi_lite_req    ),
    .axi_rsp_i       ( axi_lite_rsp    )
  );
  axi_lite_to_axi #(
    .AxiDataWidth    ( DataWidth       ),
    .req_lite_t      ( axi_lite_req_t  ),
    .resp_lite_t     ( axi_lite_resp_t ),
    .axi_req_t       ( axi_req_t       ),
    .axi_resp_t      ( axi_rsp_t       )
  ) i_axi_lite_to_axi (
    .slv_req_lite_i  ( axi_lite_req    ),
    .slv_resp_lite_o ( axi_lite_rsp    ),
    .slv_aw_cache_i,
    .slv_ar_cache_i,
    .mst_req_o       ( axi_req_o       ),
    .mst_resp_i      ( axi_rsp_i       )
  );
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

module axi_lite_from_mem #(
  
  parameter int unsigned MemAddrWidth = 32'd0,
  
  parameter int unsigned AxiAddrWidth = 32'd0,
  
  parameter int unsigned DataWidth = 32'd0,
  
  parameter int unsigned MaxRequests = 32'd0,
  
  parameter axi_pkg::prot_t AxiProt = 3'b000,
  
  parameter type axi_req_t = logic,
  
  parameter type axi_rsp_t = logic,
  
  
  
  parameter type mem_addr_t = logic[MemAddrWidth-1:0],
  
  
  
  parameter type axi_addr_t = logic[AxiAddrWidth-1:0],
  
  
  
  
  parameter type data_t = logic[DataWidth-1:0],
  
  
  
  parameter type strb_t = logic[DataWidth/8-1:0]
) (
  
  input logic clk_i,
  
  input logic rst_ni,
  
  input logic mem_req_i,
  
  
  
  input mem_addr_t mem_addr_i,
  
  
  
  
  input logic mem_we_i,
  
  input data_t mem_wdata_i,
  
  
  
  input strb_t mem_be_i,
  
  output logic mem_gnt_o,
  
  
  output logic mem_rsp_valid_o,
  
  
  output data_t mem_rsp_rdata_o,
  
  output logic mem_rsp_error_o,
  
  output axi_req_t axi_req_o,
  
  input axi_rsp_t axi_rsp_i
);
  
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
  
  logic fifo_full, fifo_empty;
  
  logic aw_sent_q, aw_sent_d;
  logic w_sent_q,  w_sent_d;
  
  always_comb begin
    
    axi_req_o.aw       = '0;
    axi_req_o.aw.addr  = axi_addr_t'(mem_addr_i);
    axi_req_o.aw.prot  = AxiProt;
    axi_req_o.aw_valid = 1'b0;
    axi_req_o.w        = '0;
    axi_req_o.w.data   = mem_wdata_i;
    axi_req_o.w.strb   = mem_be_i;
    axi_req_o.w_valid  = 1'b0;
    axi_req_o.ar       = '0;
    axi_req_o.ar.addr  = axi_addr_t'(mem_addr_i);
    axi_req_o.ar.prot  = AxiProt;
    axi_req_o.ar_valid = 1'b0;
    
    mem_gnt_o          = 1'b0;
    
    aw_sent_d          = aw_sent_q;
    w_sent_d           = w_sent_q;
    
    if (mem_req_i && !fifo_full) begin
      if (!mem_we_i) begin
        
        axi_req_o.ar_valid = 1'b1;
        mem_gnt_o          = axi_rsp_i.ar_ready;
      end else begin
        
        unique case ({aw_sent_q, w_sent_q})
          2'b00 : begin
            
            axi_req_o.aw_valid = 1'b1;
            axi_req_o.w_valid  = 1'b1;
            unique case ({axi_rsp_i.aw_ready, axi_rsp_i.w_ready})
              2'b01 : begin 
                w_sent_d = 1'b1;
              end
              2'b10 : begin 
                aw_sent_d = 1'b1;
              end
              2'b11 : begin 
                mem_gnt_o = 1'b1;
              end
              default : ;
            endcase
          end
          2'b10 : begin
            
            axi_req_o.w_valid = 1'b1;
            if (axi_rsp_i.w_ready) begin
              aw_sent_d = 1'b0;
              mem_gnt_o = 1'b1;
            end
          end
          2'b01 : begin
            
            axi_req_o.aw_valid = 1'b1;
            if (axi_rsp_i.aw_ready) begin
              w_sent_d  = 1'b0;
              mem_gnt_o = 1'b1;
            end
          end
          default : begin
            
            aw_sent_d = 1'b0;
            w_sent_d  = 1'b0;
          end
        endcase
      end
    end
  end
  `FFARN(aw_sent_q, aw_sent_d, 1'b0, clk_i, rst_ni)
  `FFARN(w_sent_q, w_sent_d, 1'b0, clk_i, rst_ni)
  
  logic rsp_sel;
  fifo_v3 #(
    .FALL_THROUGH ( 1'b0        ), 
    .DEPTH        ( MaxRequests ),
    .dtype        ( logic       )
  ) i_fifo_rsp_mux (
    .clk_i,
    .rst_ni,
    .flush_i    ( 1'b0            ),
    .testmode_i ( 1'b0            ),
    .full_o     ( fifo_full       ),
    .empty_o    ( fifo_empty      ),
    .usage_o    (     ),
    .data_i     ( mem_we_i        ),
    .push_i     ( mem_gnt_o       ),
    .data_o     ( rsp_sel         ),
    .pop_i      ( mem_rsp_valid_o )
  );
  
  
  assign axi_req_o.b_ready = !fifo_empty &&  rsp_sel;
  assign axi_req_o.r_ready = !fifo_empty && !rsp_sel;
  
  assign mem_rsp_rdata_o = axi_rsp_i.r.data;
  
  assign mem_rsp_error_o = rsp_sel ?
      (axi_rsp_i.b.resp inside {axi_pkg::RESP_SLVERR, axi_pkg::RESP_DECERR}) :
      (axi_rsp_i.r.resp inside {axi_pkg::RESP_SLVERR, axi_pkg::RESP_DECERR});
  
  
  
  assign mem_rsp_valid_o = (axi_rsp_i.b_valid && axi_req_o.b_ready) ||
                           (axi_rsp_i.r_valid && axi_req_o.r_ready);
  
  `ifndef SYNTHESIS
  `ifndef VERILATOR
    initial begin : proc_assert
      assert (MemAddrWidth > 32'd0) else $fatal(1, "MemAddrWidth has to be greater than 0!");
      assert (AxiAddrWidth > 32'd0) else $fatal(1, "AxiAddrWidth has to be greater than 0!");
      
      
      
      
      
      assert (MaxRequests > 32'd0) else $fatal(1, "MaxRequests has to be greater than 0!");
      assert (AxiAddrWidth == $bits(axi_req_o.aw.addr)) else
          $fatal(1, "AxiAddrWidth has to match axi_req_o.aw.addr!");
      assert (AxiAddrWidth == $bits(axi_req_o.ar.addr)) else
          $fatal(1, "AxiAddrWidth has to match axi_req_o.ar.addr!");
      assert (DataWidth == $bits(axi_req_o.w.data)) else
          $fatal(1, "DataWidth has to match axi_req_o.w.data!");
      assert (DataWidth/8 == $bits(axi_req_o.w.strb)) else
          $fatal(1, "DataWidth / 8 has to match axi_req_o.w.strb!");
      assert (DataWidth == $bits(axi_rsp_i.r.data)) else
          $fatal(1, "DataWidth has to match axi_rsp_i.r.data!");
    end
    default disable iff (~rst_ni);
    assert property (@(posedge clk_i) (mem_req_i && !mem_gnt_o) |=> mem_req_i) else
        $fatal(1, "It is not allowed to deassert the request if it was not granted!");
    assert property (@(posedge clk_i) (mem_req_i && !mem_gnt_o) |=> $stable(mem_addr_i)) else
        $fatal(1, "mem_addr_i has to be stable if request is not granted!");
    assert property (@(posedge clk_i) (mem_req_i && !mem_gnt_o) |=> $stable(mem_we_i)) else
        $fatal(1, "mem_we_i has to be stable if request is not granted!");
    assert property (@(posedge clk_i) (mem_req_i && !mem_gnt_o) |=> $stable(mem_wdata_i)) else
        $fatal(1, "mem_wdata_i has to be stable if request is not granted!");
    assert property (@(posedge clk_i) (mem_req_i && !mem_gnt_o) |=> $stable(mem_be_i)) else
        $fatal(1, "mem_be_i has to be stable if request is not granted!");
  `endif
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
