
module TopModule #(
  parameter int unsigned N = 8,
  localparam int IdxW      = prim_util_pkg::vbits(N)
) (
  input        [ N-1:0]    in_i,
  output logic [ N-1:0]    leading_one_o,
  output logic [ N-1:0]    ppc_out_o,
  output logic [IdxW-1:0]  idx_o
);
  logic [N-1:0] ppc_out;
  
  
  
  always_comb begin
    ppc_out[0] = in_i[0];
    for (int i = 1 ; i < N ; i++) begin
      ppc_out[i] = ppc_out[i-1] | in_i[i];
    end
  end
  
  assign leading_one_o = ppc_out ^ {ppc_out[N-2:0], 1'b0};
  assign ppc_out_o     = ppc_out;
  always_comb begin
    idx_o = '0;
    for (int unsigned i = 0 ; i < N ; i++) begin
      if (leading_one_o[i]) begin
        idx_o = i[IdxW-1:0];
      end
    end
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
