module RO #(
        parameter int unsigned RO_LENGTH, 
        parameter int unsigned INV_DELAY
        )
   
   (
     input logic   RO_enable,
     output logic  random_bit 	       
   );
    
    logic[RO_LENGTH - 1 : 0] out_inv;
    
    genvar i;
    generate
        for (i = 0; i < RO_LENGTH; i++) begin
            INV #(INV_DELAY) inv_i( 
                .in((i == 0)? (out_inv[RO_LENGTH - 1] | RO_enable) : out_inv[i-1]),   
                .out(out_inv[i])
                );                    
        end
    endgenerate 

    assign random_bit = out_inv[RO_LENGTH - 1];


endmodule : RO