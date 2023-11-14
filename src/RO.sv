module RO #(parameter int unsigned RO_LENGTH)
   (
    //`ifdef SIM
     input  int unsigned inv_delay[RO_LENGTH],    
    //`endif
     input  logic        RO_enable,
     output logic        random_bit 	       
   );
    
    logic[RO_LENGTH - 1 : 0] out_inv;
        
    genvar i;
    generate
        for (i = 0; i < RO_LENGTH; i++) begin
            INV inv_i( 
                //`ifdef SIM
                .delay(inv_delay[i]),    
                //`endif
                .in((i == 0)? (out_inv[RO_LENGTH - 1] | RO_enable) : out_inv[i-1]),   
                .out(out_inv[i])
                ); /* synthesis keep */                
        end
    endgenerate 

    assign random_bit = out_inv[RO_LENGTH - 1];


endmodule : RO