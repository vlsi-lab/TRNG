timeunit 1ps;
timeprecision 1ps;

module INV #(
        //parameter int unsigned min_INV_DELAY,
        parameter int unsigned typ_INV_DELAY
        //parameter int unsigned max_INV_DELAY
        )
    (
     input logic   in,	       
     output logic  out   	       
   );

   always_comb begin
    out <= #typ_INV_DELAY !in;
   end

endmodule : INV