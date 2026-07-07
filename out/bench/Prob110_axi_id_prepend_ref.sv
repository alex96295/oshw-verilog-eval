
module TopModule #(
  parameter int unsigned NoBus             = 1,     
  parameter int unsigned AxiIdWidthSlvPort = 4,     
  parameter int unsigned AxiIdWidthMstPort = 6,     
  parameter type         slv_aw_chan_t     = logic, 
  parameter type         slv_w_chan_t      = logic, 
  parameter type         slv_b_chan_t      = logic, 
  parameter type         slv_ar_chan_t     = logic, 
  parameter type         slv_r_chan_t      = logic, 
  parameter type         mst_aw_chan_t     = logic, 
  parameter type         mst_w_chan_t      = logic, 
  parameter type         mst_b_chan_t      = logic, 
  parameter type         mst_ar_chan_t     = logic, 
  parameter type         mst_r_chan_t      = logic, 
  
  parameter int unsigned PreIdWidth        = AxiIdWidthMstPort - AxiIdWidthSlvPort
) (
  input  logic [PreIdWidth-1:0] pre_id_i, 
  
  
  input  slv_aw_chan_t [NoBus-1:0] slv_aw_chans_i,
  input  logic         [NoBus-1:0] slv_aw_valids_i,
  output logic         [NoBus-1:0] slv_aw_readies_o,
  
  input  slv_w_chan_t  [NoBus-1:0] slv_w_chans_i,
  input  logic         [NoBus-1:0] slv_w_valids_i,
  output logic         [NoBus-1:0] slv_w_readies_o,
  
  output slv_b_chan_t  [NoBus-1:0] slv_b_chans_o,
  output logic         [NoBus-1:0] slv_b_valids_o,
  input  logic         [NoBus-1:0] slv_b_readies_i,
  
  input  slv_ar_chan_t [NoBus-1:0] slv_ar_chans_i,
  input  logic         [NoBus-1:0] slv_ar_valids_i,
  output logic         [NoBus-1:0] slv_ar_readies_o,
  
  output slv_r_chan_t  [NoBus-1:0] slv_r_chans_o,
  output logic         [NoBus-1:0] slv_r_valids_o,
  input  logic         [NoBus-1:0] slv_r_readies_i,
  
  
  output mst_aw_chan_t [NoBus-1:0] mst_aw_chans_o,
  output logic         [NoBus-1:0] mst_aw_valids_o,
  input  logic         [NoBus-1:0] mst_aw_readies_i,
  
  output mst_w_chan_t  [NoBus-1:0] mst_w_chans_o,
  output logic         [NoBus-1:0] mst_w_valids_o,
  input  logic         [NoBus-1:0] mst_w_readies_i,
  
  input  mst_b_chan_t  [NoBus-1:0] mst_b_chans_i,
  input  logic         [NoBus-1:0] mst_b_valids_i,
  output logic         [NoBus-1:0] mst_b_readies_o,
  
  output mst_ar_chan_t [NoBus-1:0] mst_ar_chans_o,
  output logic         [NoBus-1:0] mst_ar_valids_o,
  input  logic         [NoBus-1:0] mst_ar_readies_i,
  
  input  mst_r_chan_t  [NoBus-1:0] mst_r_chans_i,
  input  logic         [NoBus-1:0] mst_r_valids_i,
  output logic         [NoBus-1:0] mst_r_readies_o
);
  
  for (genvar i = 0; i < NoBus; i++) begin : gen_id_prepend
    if (PreIdWidth == 0) begin : gen_no_prepend
      assign mst_aw_chans_o[i] = slv_aw_chans_i[i];
      assign mst_ar_chans_o[i] = slv_ar_chans_i[i];
    end else begin : gen_prepend
      always_comb begin
        mst_aw_chans_o[i] = slv_aw_chans_i[i];
        mst_ar_chans_o[i] = slv_ar_chans_i[i];
        mst_aw_chans_o[i].id = {pre_id_i, slv_aw_chans_i[i].id[AxiIdWidthSlvPort-1:0]};
        mst_ar_chans_o[i].id = {pre_id_i, slv_ar_chans_i[i].id[AxiIdWidthSlvPort-1:0]};
      end
    end
    
    
    assign slv_b_chans_o[i] = mst_b_chans_i[i];
    assign slv_r_chans_o[i] = mst_r_chans_i[i];
  end
  
  assign mst_w_chans_o    = slv_w_chans_i;
  assign mst_aw_valids_o  = slv_aw_valids_i;
  assign slv_aw_readies_o = mst_aw_readies_i;
  assign mst_w_valids_o   = slv_w_valids_i;
  assign slv_w_readies_o  = mst_w_readies_i;
  assign slv_b_valids_o   = mst_b_valids_i;
  assign mst_b_readies_o  = slv_b_readies_i;
  assign mst_ar_valids_o  = slv_ar_valids_i;
  assign slv_ar_readies_o = mst_ar_readies_i;
  assign slv_r_valids_o   = mst_r_valids_i;
  assign mst_r_readies_o  = slv_r_readies_i;
`ifndef VERILATOR
  initial begin : p_assert
    assert(NoBus > 0)
      else $fatal(1, "Input must be at least one element wide.");
    assert(PreIdWidth == ($bits(mst_aw_chans_o[0].id) - $bits(slv_aw_chans_i[0].id)))
      else $fatal(1, "Prepend ID Width must be: $bits(mst_aw_chans_o.id)-$bits(slv_aw_chans_i.id)");
    assert ($bits(mst_aw_chans_o[0].id) > $bits(slv_aw_chans_i[0].id))
      else $fatal(1, "The master AXI port has to have a wider ID than the slave port.");
  end
  aw_id   : assert final(
      mst_aw_chans_o[0].id[$bits(slv_aw_chans_i[0].id)-1:0] === slv_aw_chans_i[0].id)
        else $fatal (1, "Something with the AW channel ID prepending went wrong.");
  aw_addr : assert final(mst_aw_chans_o[0].addr === slv_aw_chans_i[0].addr)
      else $fatal (1, "Something with the AW channel ID prepending went wrong.");
  aw_len  : assert final(mst_aw_chans_o[0].len === slv_aw_chans_i[0].len)
      else $fatal (1, "Something with the AW channel ID prepending went wrong.");
  aw_size : assert final(mst_aw_chans_o[0].size === slv_aw_chans_i[0].size)
      else $fatal (1, "Something with the AW channel ID prepending went wrong.");
  aw_qos  : assert final(mst_aw_chans_o[0].qos === slv_aw_chans_i[0].qos)
      else $fatal (1, "Something with the AW channel ID prepending went wrong.");
  b_id    : assert final(
      mst_b_chans_i[0].id[$bits(slv_b_chans_o[0].id)-1:0] === slv_b_chans_o[0].id)
        else $fatal (1, "Something with the B channel ID stripping went wrong.");
  b_resp  : assert final(mst_b_chans_i[0].resp === slv_b_chans_o[0].resp)
      else $fatal (1, "Something with the B channel ID stripping went wrong.");
  ar_id   : assert final(
      mst_ar_chans_o[0].id[$bits(slv_ar_chans_i[0].id)-1:0] === slv_ar_chans_i[0].id)
        else $fatal (1, "Something with the AR channel ID prepending went wrong.");
  ar_addr : assert final(mst_ar_chans_o[0].addr === slv_ar_chans_i[0].addr)
      else $fatal (1, "Something with the AR channel ID prepending went wrong.");
  ar_len  : assert final(mst_ar_chans_o[0].len === slv_ar_chans_i[0].len)
      else $fatal (1, "Something with the AR channel ID prepending went wrong.");
  ar_size : assert final(mst_ar_chans_o[0].size === slv_ar_chans_i[0].size)
      else $fatal (1, "Something with the AR channel ID prepending went wrong.");
  ar_qos  : assert final(mst_ar_chans_o[0].qos === slv_ar_chans_i[0].qos)
      else $fatal (1, "Something with the AR channel ID prepending went wrong.");
  r_id    : assert final(mst_r_chans_i[0].id[$bits(slv_r_chans_o[0].id)-1:0] === slv_r_chans_o[0].id)
      else $fatal (1, "Something with the R channel ID stripping went wrong.");
  r_data  : assert final(mst_r_chans_i[0].data === slv_r_chans_o[0].data)
      else $fatal (1, "Something with the R channel ID stripping went wrong.");
  r_resp  : assert final(mst_r_chans_i[0].resp === slv_r_chans_o[0].resp)
      else $fatal (1, "Something with the R channel ID stripping went wrong.");
`endif
endmodule
