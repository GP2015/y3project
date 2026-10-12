`timescale 1 ns / 1 ps

`define FIRMWARE_FILE "../firmware.hex"

module top (
    input wire CLK100MHZ,
    output wire [15:0] LED
);
    reg  [3:0] reset_count = 4'b0000;
    wire       resetn = reset_count[3];
    always @(posedge CLK100MHZ) begin

        if (!reset_count[3]) reset_count <= reset_count + 1'b1;
    end

    wire        trap;
    wire        mem_valid;
    wire        mem_instr;
    wire        mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [ 3:0] mem_wstrb;
    reg  [31:0] mem_rdata;

    reg  [31:0] rom       [0:1023];

    initial begin
        $readmemh(`FIRMWARE_FILE, rom);
    end

    assign mem_ready = mem_valid;

    always @* begin
        mem_rdata = rom[mem_addr[11:2]];
    end

    always @(posedge CLK100MHZ) begin
        if (resetn && mem_valid && mem_ready && mem_addr == 32'h10000000 && |mem_wstrb) begin
            LED[0] <= mem_wdata[0];
        end
    end

    picorv32 #(
        .ENABLE_COUNTERS(1),
        .ENABLE_COUNTERS64(1),
        .ENABLE_REGS_16_31(1),
        .ENABLE_REGS_DUALPORT(1),

        .ENABLE_PCPI (0),
        .ENABLE_MUL  (0),
        .ENABLE_DIV  (0),
        .ENABLE_IRQ  (0),
        .ENABLE_TRACE(0),

        .PROGADDR_RESET(32'h0000_0000),
        .STACKADDR     (32'h0000_0FFC)
    ) cpu (
        .clk   (clk),
        .resetn(resetn),
        .trap  (trap),

        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr (mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );
endmodule

