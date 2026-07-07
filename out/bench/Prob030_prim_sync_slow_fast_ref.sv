
module TopModule #(
  parameter int unsigned Width = 32
) (
  input  logic             clk_slow_i,
  input  logic             clk_fast_i,
  input  logic             rst_fast_ni,
  input  logic [Width-1:0] wdata_i,    
  output logic [Width-1:0] rdata_o     
);
  logic             sync_clk_slow, sync_clk_slow_q;
  logic             wdata_en;
  logic [Width-1:0] wdata_q;
  
  prim_flop_2sync #(.Width(1)) sync_slow_clk (
    .clk_i    (clk_fast_i),
    .rst_ni   (rst_fast_ni),
    .d_i      (clk_slow_i),
    .q_o      (sync_clk_slow));
  
  always_ff @(posedge clk_fast_i or negedge rst_fast_ni) begin
    if (!rst_fast_ni) begin
      sync_clk_slow_q <= 1'b0;
    end else begin
      sync_clk_slow_q <= sync_clk_slow;
    end
  end
  
  assign wdata_en = sync_clk_slow_q & !sync_clk_slow;
  
  always_ff @(posedge clk_fast_i or negedge rst_fast_ni) begin
    if (!rst_fast_ni) begin
      wdata_q <= '0;
    end else if (wdata_en) begin
      wdata_q <= wdata_i;
    end
  end
  assign rdata_o = wdata_q;
endmodule
