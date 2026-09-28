module main (input wire clk, output wire led);
    reg [31:0] x [31:0];
    reg [31:0] pc;

    always @(posedge clk) begin
       // Ensure that x[0] is always 0.
    end
endmodule

// x1 holds return address
// x5 is alternate link register
// x2 holds the stack pointer

// behaviour for decoding a reserved instruction is unspecified

// Sign bit is always held in bit 31 of immediate

// -- Base instruction formats --
// R: register-to-register ops
// I: immediate ops & loads
// S: store ops
// U: upper immediate ops

// -- Extra immediate formats
// B: branch ops
// J: unconditional jump ops
