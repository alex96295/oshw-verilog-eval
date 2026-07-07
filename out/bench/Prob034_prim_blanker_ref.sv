
module TopModule #(
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
