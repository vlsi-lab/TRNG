module trng_top 
  import trng_data_reg_pkg::*;
  import trng_ctrl_reg_pkg::*;
  import reg_pkg::*;
  import obi_pkg::*;  
  #(
    parameter int unsigned N_STAGES = 33,
    parameter int unsigned RO_LENGTH = 13,
    parameter int unsigned N_BITS_KEY = 32
  )
(
	input logic clk_i,
	input logic rst_ni,
    
	// AHB Slave interface (data memory)
	input 	    obi_req_t slave_req_i,
	output 	    obi_resp_t slave_resp_o,
    // APB interface (ctrl mem)
	input 	    reg_req_t reg_req_i,
    output 	    reg_rsp_t reg_rsp_o,
  
    output      trng_intr_o
);

   reg_req_t periph_req_i;   
   reg_rsp_t periph_rsp_o;
   
   trng_data_reg2hw_t reg_file_to_ip_data;
   trng_data_hw2reg_t ip_to_reg_file_data;   
   trng_ctrl_reg2hw_t reg_file_to_ip_ctrl;
   trng_ctrl_hw2reg_t ip_to_reg_file_ctrl;

	
   periph_to_reg #(
      .req_t(reg_pkg::reg_req_t),
      .rsp_t(reg_pkg::reg_rsp_t),
      .IW(1)
   ) periph_to_reg_i (
      .clk_i,
      .rst_ni,
      .req_i(slave_req_i.req),
      .add_i(slave_req_i.addr),
      .wen_i(~slave_req_i.we),
      .wdata_i(slave_req_i.wdata),
      .be_i(slave_req_i.be),
      .id_i('0),
      .gnt_o(slave_resp_o.gnt),
      .r_rdata_o(slave_resp_o.rdata),
      .r_opc_o(),
      .r_id_o(),
      .r_valid_o(slave_resp_o.rvalid),
      .reg_req_o(periph_req_i),
      .reg_rsp_i(periph_rsp_o)
   );


   trng_data_reg_top #(
	.reg_req_t(reg_req_t),
	.reg_rsp_t(reg_rsp_t)
	) i_data_regfile (
		.clk_i,
		.rst_ni,
		.devmode_i(1'b1),
		// From the bus to regfile
		.reg_req_i(periph_req_i),
		.reg_rsp_o(periph_rsp_o),
		
		// Signals from regfile to IP
		.hw2reg(ip_to_reg_file_data) 
	);

   trng_ctrl_reg_top #(
	.reg_req_t(reg_req_t),
	.reg_rsp_t(reg_rsp_t)
	) i_ctrl_regfile (
		.clk_i,
		.rst_ni,
		.devmode_i(1'b1),
		// From the bus to regfile
		.reg_req_i(reg_req_i),
		.reg_rsp_o(reg_rsp_o),		
		// Signals from regfile to IP
		.reg2hw(reg_file_to_ip_ctrl),
		.hw2reg(ip_to_reg_file_ctrl) 
	);

   logic[31 : 0]   out_key; 
   logic key_ready_s;

  `ifndef SYNTHESIS
    int unsigned inv_delay[N_STAGES][RO_LENGTH];  
    assign i_trng.inv_delay = inv_delay;
   `endif	
   
	trng #(.N_STAGES(N_STAGES), .RO_LENGTH(RO_LENGTH), .N_BITS_KEY(N_BITS_KEY)) i_trng (
		.clk(clk_i),
		.rst_n(rst_ni),
        .enable(reg_file_to_ip_ctrl[2]),
        // when simulating check if ack_key_read and 
        // ip_to_reg_file_data.trng_dout.re have the same behaviour
        .ack_read(reg_file_to_ip_ctrl[0]),
        .key_ready(key_ready_s),
        .out_key(out_key),
        .trng_intr(trng_intr_o)
	); 

    assign ip_to_reg_file_ctrl.status.trng.de = key_ready_s;
    assign ip_to_reg_file_ctrl.status.trng.d = key_ready_s;
    assign ip_to_reg_file_data = out_key;

endmodule : trng_top
