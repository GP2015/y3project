module top (
    input wire CLK100MHZ,
    output wire [15:0] LED
);
    reg [24:0] r_count = 0;
    always @(posedge (CLK100MHZ)) r_count <= r_count + 1;
    assign LED[0] = r_count[24];
endmodule
