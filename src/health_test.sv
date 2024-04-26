module health_test #(
        parameter int unsigned NBITS = 28,
        parameter int unsigned CUTOFF = 589,
        parameter int unsigned FAIL_THRESH = 11
       )
    (
     input  logic                 rnd_bit,
     input  logic                 enable,
     input  logic                 rst_ni,
     input  logic                 clk,	       
     output logic                 error,
     output logic                 total_failure 	       
   );

    logic[NBITS - 1 : 0] rep_count_samples;
    logic stuck_at_0, stuck_at_1;
    logic error_adapt;
    logic tot_fail_s;
    (* keep = "true" *) int unsigned acc;
    int unsigned cnt;
    int unsigned consec_error_cnt;

    SHIFT_REG #(.NBITS(NBITS)) rep_count_shif_reg (
    .in_bit(rnd_bit),
    .clk(clk),
    .dff_en(enable),
    .rst_ni(rst_ni),
    .sample_out(rep_count_samples)
   );
    
    assign stuck_at_1 = &rep_count_samples;
    assign stuck_at_0 = &(~rep_count_samples);

    always_ff @(posedge clk) begin
        if(!rst_ni) begin
            acc <= 0;
            cnt <= 0;
            consec_error_cnt <= 0;
            error_adapt <= 0;
            tot_fail_s <= 0;
        end
        else if(rst_ni && enable) begin
            // window of 1024 samples
            if(cnt < 1023) begin
                // new value in shift register accumulated
                acc <= acc + rnd_bit;
                cnt <= cnt + 1;
            end else begin
                if(acc > CUTOFF || acc < (1024 - CUTOFF)) begin
                    error_adapt <= 1'b1;
                end else begin
                    error_adapt <= 1'b0;
                end 

                acc <= 0;
                cnt <= 0;   
            end 

            if(stuck_at_0 || stuck_at_1 || error_adapt) begin
                consec_error_cnt <= consec_error_cnt + 1;

                if(consec_error_cnt == FAIL_THRESH-1) begin
                   tot_fail_s <= 1'b1;
                end
            end else begin
                consec_error_cnt <= 0;
                tot_fail_s <= 1'b0;
            end
        end
    end

    assign total_failure = tot_fail_s;
    assign error = (stuck_at_0 | stuck_at_1 | error_adapt);

endmodule : health_test
