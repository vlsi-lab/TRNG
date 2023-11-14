module top_level_RO #(
        parameter int unsigned N_STAGES = 32,
        parameter int unsigned RO_LENGTH
        )
    (
        //`ifdef SIM
         input  int unsigned inv_delay[N_STAGES][RO_LENGTH],    
        //`endif
         input  logic     RO_en,
         input  logic     dff_en,	       	
         input  logic     clk,
         output logic     random_bit  
    );

    logic[N_STAGES - 1 : 0]  parallel_out, random_out;
    logic out_xor_tree;
    
    genvar i;
    generate
        for (i = 0; i < N_STAGES; i++) begin
            RO #(.RO_LENGTH(RO_LENGTH)) RO_i( 
                //`ifdef SIM
                .inv_delay(inv_delay[i]),    
                //`endif
                .RO_enable(RO_en), 
                .random_bit(parallel_out[i])
                ); /* synthesis keep */
        end
    endgenerate

    REG #(.NBITS(N_STAGES)) sampling_reg(
                .comb_in(parallel_out),
                .clk(clk),
                .dff_en(dff_en),
                .sample_out(random_out)
            );

    assign out_xor_tree = ^random_out;

    REG #(.NBITS(1)) out_xor_reg(
                .comb_in(out_xor_tree),
                .clk(clk),
                .dff_en(dff_en),
                .sample_out(random_bit)
            );


endmodule : top_level_RO

//TRY SAMPLING WITH ANOTHER RO wrt clk --> independence on deterministic jitter attacks