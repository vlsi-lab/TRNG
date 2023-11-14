timeunit 1ps;
timeprecision 1ps;

module top_level_RO_tb();

parameter N_STAGES = 32;
parameter RO_LENGTH = 3;
logic RO_enable_tb;
logic rnd_nojit_tb;
logic clk_tb;
logic dff_en_tb;
int unsigned inv_delay_tb[N_STAGES][RO_LENGTH];

logic[27:0] rnd_test_wnd1_nojit, prev_wnd;
logic[1023:0] rnd_test_wnd2_nojit;

int count_samples = 0;
int n_fails_adaptive = 0;
int n_fails_repetition1 = 0;
int n_fails_repetition2 = 0;
int n_fails_1, n_fails_2, n_fails;
int count_outfile = 0;
int fd_nojit;

top_level_RO 
#(.N_STAGES(N_STAGES), .RO_LENGTH(RO_LENGTH))
UUT_nojitter (
    //`ifdef SIM
     .inv_delay(inv_delay_tb),
    //`endif
    .RO_en(RO_enable_tb),
    .dff_en(dff_en_tb),
    .clk(clk_tb),
    .random_bit(rnd_nojit_tb)
);


SHIFT_REG #(.NBITS(28)) UUT_BUFFER1 (
    .in_bit(rnd_nojit_tb),
    .clk(clk_tb),
    .dff_en(dff_en_tb),
    .sample_out(rnd_test_wnd1_nojit)
);

SHIFT_REG #(.NBITS(1024)) UUT_BUFFER2 (
    .in_bit(rnd_nojit_tb),
    .clk(clk_tb),
    .dff_en(dff_en_tb),
    .sample_out(rnd_test_wnd2_nojit)
);


always #1.1ns clk_tb = ~clk_tb;

initial begin
    fd_nojit = $fopen ("./results/rnd_out_3INV_32RO_0sigma.txt", "w");

    assign_delays(inv_delay_tb);
    RO_enable_tb = 0;
    clk_tb = 1;
    clk_jitter_tb = 1;
    dff_en_tb = 0;
	#200ps RO_enable_tb = 1;
    dff_en_tb = 1;
    #16ns RO_enable_tb = 0;  // RO period = 2*Delay_INV*N_INV

    #1000ms $fclose(fd_nojit);
end 

`ifdef NO_JITTER_SIM  

always_ff @(posedge clk_tb) begin

    if((rnd_nojit_tb == 1'b1 || rnd_nojit_tb == 1'b0) && count_outfile < 1000000000) begin
        $fwrite(fd_nojit, "%b", rnd_nojit_tb);
        count_outfile++;

        if(count_outfile % 128 == 0) begin
            $fwrite(fd_nojit, "\n");
        end
    end

end


always_ff @(posedge clk_tb && (((^rnd_test_wnd1_nojit) == 1'b1) || ((^rnd_test_wnd1_nojit) == 1'b0))) begin

    if((count_samples != 0) && (count_samples % 28 == 0)) begin
        repetition_count_test(rnd_test_wnd1_nojit, n_fails_1, n_fails_2);

        if(n_fails_1 != 0) begin
            n_fails_repetition1 += n_fails_1;
            $monitor("Time: %t ps Number of fails for repetition count test for alpha = 0.01: %0d", $time, n_fails_repetition1);
        end

        if(n_fails_2 != 0) begin
            n_fails_repetition2 += n_fails_2;
            $monitor("Time: %t ps Number of fails for repetition count test for alpha = 0.001: %0d", $time, n_fails_repetition2); 
        end

    end

    if(count_samples == 1023) begin
        adaptive_proportion_test(rnd_test_wnd2_nojit, n_fails);

        if(n_fails != 0) begin
            n_fails_adaptive += n_fails;
            $monitor("Time: %t ps Number of fails for adaptive proportion test (C = 589): %0d", $time, n_fails_adaptive);
        end
        count_samples = 0;
    end

    count_samples++;
end
`endif



task repetition_count_test;
    input logic[27:0] rnd_window;
    output int n_fails_rctest_1;
    output int n_fails_rctest_2;

    /////////////////////////////* Repetition count test: *////////////////////////////////
    //                                                                                   //
    // n = 1 + up(-log2(alpha)/H) --> number of consecutive repetitions to trigger alarm //
    // alpha1 = 0.001 --> log2(alpha) = -9.9658                                          //
    // alpha2 = 0.01  --> log2(alpha) = -6.6438                                          //
    // H_Shannon > 0.997 (AIS-31)                                                        //
    // H_min = 0.999 (NIST SP 800-90B) (when post processing used)                       //
    //                                                                                   //
    // n_alpha1_HShan = 11              n_alpha1_Hmin = 11                               // 
    // n_alpha2_HShan = 8               n_alpha2_Hmin = 8                                // 
    //                                                                                   //   
    ///////////////////////////////////////////////////////////////////////////////////////

    static int thresh_alpha1 = 11;
    static int thresh_alpha2 = 8;
    automatic int count = 0;
    automatic int fail2 = 0;
    automatic int n_fails_1_var = 0;
    automatic int n_fails_2_var = 0;

    for(int i = 1; i < 28; i++) begin
        if(rnd_window[i] == rnd_window[i-1]) begin

            count++;     

            if(count > thresh_alpha2) begin

                if(fail2 == 0) begin
                    //$display("Repetition count test failed for alpha = 0.01");
                    n_fails_2_var++;
                end

                fail2 = 1;
            end
    
            if(count > thresh_alpha1) begin
                //$display("Repetition count test failed for alpha = 0.001");
                n_fails_1_var++;
                break;
            end

        end else begin
            count = 0;
        end
    end 

    n_fails_rctest_1 = n_fails_1_var;
    n_fails_rctest_2 = n_fails_2_var;

endtask

task adaptive_proportion_test;
    input logic[1024:0] rnd_window;
    output int n_fails_aptest;

    ///////////////////////////* Adaptive proportion test: *//////////////////////
    //                                                                          //
    //  C = 589 --> cutoff value to trigger alarm, value from NIST document.    // 
    //              It corresponds to entropy = 1 (binary source) (1024/2)      //
    //                                                                          //
    //////////////////////////////////////////////////////////////////////////////

    automatic int count = 0;
    static int C = 589;
    automatic int n_fails = 0;

    for(int i = 0; i < 1024; i++) begin
        if(rnd_window[i] == 1)
            count++;    
            
    end

    if(count > C || count < (1024-C)) begin
        //$display("Adaptive proportion test failed for cutoff value C = 589. Number of ones in 1024 stream equal to %0d", count);
        n_fails++;
    end;

    n_fails_aptest = n_fails;

endtask

task assign_delays;
    output int unsigned delays_vec[N_STAGES][RO_LENGTH];

    string line;
    static string fixed_chars = "RO #xxxx";
    int fID_delays, n, m;

    fID_delays = $fopen ("./model_files/model_3INV_32RO_0sigma.txt", "r");
    $fgets(line, fID_delays);

    for(int j = 0; j < N_STAGES; j++) begin
        $fscanf(fID_delays, "%s %s ", line, line);
        for(int i = 0; i < RO_LENGTH; i++) begin
            $fscanf(fID_delays, "%d ", delays_vec[j][i]);
        end
    end

    $fclose(fID_delays);

endtask

endmodule : top_level_RO_tb