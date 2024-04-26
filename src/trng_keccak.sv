module trng_keccak #(
    parameter int unsigned N_STAGES = 32,
    parameter int unsigned RO_LENGTH = 13,
    parameter int unsigned NBITS_KEY = 32
  )
    (
     // Common in signals
     input  logic                     clk,
     input  logic                     rst_n, 
     input  logic[1 : 0]              op_mode,
     // op_mode[0] = 1 TRNG
     // op_mode[1] = 1 KECCAK
     input  logic                     conditioning,
     // TRNG in signal  
     input  logic                     ack_key_read,

     // Keccak in signal
     input  logic[1599 : 0]           keccak_in,

     // TRNG out signals
     output logic                     key_ready,
     output logic                     trng_intr,
     output logic[NBITS_KEY-1 : 0]    key_out,

     // Keccak out signals
     output logic                     status_d,
     output logic                     status_de,
     output logic                     keccak_intr,
     output logic[1599 : 0]           keccak_out
   );

    logic key_ready_s, trng_intr_s;
    logic[NBITS_KEY-1 : 0] key_keccak;  
    logic[999 : 0] out_key_s, keccak_out_s;
    logic status_d_s, keccak_intr_s;
    
  trng #(.N_STAGES(N_STAGES), .RO_LENGTH(RO_LENGTH), .N_BITS_KEY(1000), .WAIT_CONST(990)) i_trng (
        .enable(op_mode[0]),
        .clk(clk),
        .rst_n(rst_n),
        .ack_read(ack_key_read),
        .key_ready(key_ready_s),
        .out_key(out_key_s),
        .trng_intr(trng_intr_s)
    );

   `ifndef SYNTHESIS
    int unsigned inv_delay[N_STAGES][RO_LENGTH];  
    assign i_trng.inv_delay = inv_delay;
   `endif

    assign trng_intr = conditioning? keccak_intr_s : trng_intr_s;
    assign key_ready = conditioning? status_d_s : key_ready_s;
    assign key_out = conditioning? key_keccak : out_key_s;
    
   keccak i_keccak (
		.clk(clk),
		.rst_n(rst_n),
		.start(conditioning? key_ready_s : op_mode[1]), 
		.din(conditioning? out_key_s : keccak_in),
		.dout(keccak_out_s),
		.status_d(status_d_s),
		.status_de(status_de),
		.keccak_intr(keccak_intr_s)
	);

  assign keccak_intr = keccak_intr_s;
  assign status_d = status_d_s;
  assign keccak_out = keccak_out_s;

  assign key_keccak = keccak_out_s[815 + (NBITS_KEY-1) : 815];

endmodule : trng_keccak
