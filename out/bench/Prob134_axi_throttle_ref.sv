
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
module stream_throttle #(
    
    parameter int unsigned MaxNumPending = 1,
    
    parameter int unsigned CntWidth = cf_math_pkg::idx_width(MaxNumPending),
    
    parameter type credit_t = logic [CntWidth-1:0]
) (
    
    input  logic clk_i,
    
    input  logic rst_ni,
    
    input  logic    req_valid_i,
    
    output logic    req_valid_o,
    
    input  logic    req_ready_i,
    
    output logic    req_ready_o,
    
    input  logic    rsp_valid_i,
    
    input  logic    rsp_ready_i,
    
    input  credit_t credit_i
);
    
    
    credit_t credit_d, credit_q;
    
    logic credit_available;
    
    
    
    always_comb begin : proc_credit_counter
        
        credit_d = credit_q;
        
        if (req_ready_o & req_valid_o) begin
            credit_d = credit_d + 'd1;
        end
        
        if (rsp_valid_i & rsp_ready_i) begin
            credit_d = credit_d - 'd1;
        end
    end
    
    assign credit_available = credit_q <= (credit_i - 'd1);
    
    assign req_valid_o = req_valid_i & credit_available;
    
    assign req_ready_o = req_ready_i & credit_available;
    
    `FF(credit_q, credit_d, '0, clk_i, rst_ni)
endmodule : stream_throttle

module TopModule #(
    
    parameter int unsigned MaxNumAwPending = 1,
    
    parameter int unsigned MaxNumArPending = 1,
    
    parameter type axi_req_t = logic,
    
    parameter type axi_rsp_t = logic,
    
    parameter int unsigned WCntWidth = cf_math_pkg::idx_width(MaxNumAwPending),
    
    parameter int unsigned RCntWidth = cf_math_pkg::idx_width(MaxNumArPending),
    
    parameter type w_credit_t = logic [WCntWidth-1:0],
    
    parameter type r_credit_t = logic [RCntWidth-1:0]
) (
    
    input  logic clk_i,
    
    input  logic rst_ni,
    
    input  axi_req_t req_i,
    
    output axi_rsp_t rsp_o,
    
    output axi_req_t req_o,
    
    input  axi_rsp_t rsp_i,
    
    input  w_credit_t w_credit_i,
    
    input  r_credit_t r_credit_i
);
    
    logic throttled_aw_valid;
    logic throttled_ar_valid;
    
    logic throttled_aw_ready;
    logic throttled_ar_ready;
    
    stream_throttle #(
        .MaxNumPending ( MaxNumAwPending  )
    ) i_stream_throttle_aw (
        .clk_i,
        .rst_ni,
        .req_valid_i ( req_i.aw_valid     ),
        .req_valid_o ( throttled_aw_valid ),
        .req_ready_i ( rsp_i.aw_ready     ),
        .req_ready_o ( throttled_aw_ready ),
        .rsp_valid_i ( rsp_i.b_valid      ),
        .rsp_ready_i ( req_i.b_ready      ),
        .credit_i    ( w_credit_i         )
    );
    
    stream_throttle #(
        .MaxNumPending ( MaxNumArPending  )
    ) i_stream_throttle_ar (
        .clk_i,
        .rst_ni,
        .req_valid_i ( req_i.ar_valid               ),
        .req_valid_o ( throttled_ar_valid           ),
        .req_ready_i ( rsp_i.ar_ready               ),
        .req_ready_o ( throttled_ar_ready           ),
        .rsp_valid_i ( rsp_i.r_valid & rsp_i.r.last ),
        .rsp_ready_i ( req_i.r_ready                ),
        .credit_i    ( r_credit_i                   )
    );
    
    always_comb begin : gen_throttled_req_conn
        req_o          = req_i;
        req_o.aw_valid = throttled_aw_valid;
        req_o.ar_valid = throttled_ar_valid;
    end
    
    always_comb begin : gen_throttled_rsp_conn
        rsp_o          = rsp_i;
        rsp_o.aw_ready = throttled_aw_ready;
        rsp_o.ar_ready = throttled_ar_ready;
    end
endmodule : TopModule
