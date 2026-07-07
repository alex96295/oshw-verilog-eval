
module TopModule #(
  
  
  parameter bit AsyncOn = 0,
  parameter int unsigned CntWidth = 2
) (
  input                clk_i,
  input                rst_ni,
  input                enable_i,
  input                filter_i,
  input [CntWidth-1:0] thresh_i,
  output logic         filter_o
);
  logic [CntWidth-1:0] diff_ctr_q, diff_ctr_d;
  logic filter_q, stored_value_q, update_stored_value;
  logic filter_synced;
  if (AsyncOn) begin : gen_async
    
    
    prim_flop_2sync #(
      .Width(1)
    ) prim_flop_2sync (
      .clk_i,
      .rst_ni,
      .d_i(filter_i),
      .q_o(filter_synced)
    );
  end else begin : gen_sync
    assign filter_synced = filter_i;
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      filter_q <= 1'b0;
    end else begin
      filter_q <= filter_synced;
    end
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      stored_value_q <= 1'b0;
    end else if (update_stored_value) begin
      stored_value_q <= filter_synced;
    end
  end
  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      diff_ctr_q <= '0;
    end else begin
      diff_ctr_q <= diff_ctr_d;
    end
  end
  
  assign update_stored_value = (diff_ctr_d == thresh_i);
  assign diff_ctr_d = (filter_synced != filter_q) ? '0       :           
                      (diff_ctr_q >= thresh_i)    ? thresh_i :           
                                                    (diff_ctr_q + 1'b1); 
  assign filter_o = enable_i ? stored_value_q : filter_synced;
endmodule
