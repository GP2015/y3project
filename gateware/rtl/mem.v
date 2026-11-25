`define FIRMWARE_FILE "../../build/pitch.hex"

module mem (
    input wire clk,
    input wire resetn,

    input wire mem_valid,
    input wire [31:0] mem_addr,
    input wire [31:0] mem_wdata,
    input wire [3:0] mem_wstrb,
    output wire mem_ready,
    output reg [31:0] mem_rdata,

    output wire [15:0] led,
    input  wire [15:0] switches,

    output reg  M_CLK,
    input  wire M_DATA,
    output wire M_LRSEL
);
    wire rom_select = (mem_addr <= 32'h0001_FFFF);
    wire ram_select = (mem_addr >= 32'h0002_0000 && mem_addr <= 32'h0003_FFFF);
    wire led_select = (mem_addr == 32'h1000_0000);
    wire switches_select = (mem_addr == 32'h1000_0004);
    wire mic_select = (mem_addr >= 32'h1000_0008 && mem_addr <= 32'h1000_000C);

    wire rom_enable = mem_valid && rom_select;
    wire ram_enable = mem_valid && ram_select;
    wire led_enable = mem_valid && led_select;
    wire switches_enable = mem_valid && switches_select;
    wire mic_enable = mem_valid && mic_select;

    wire [31:0] rom_rdata;
    wire [31:0] ram_rdata;
    wire [31:0] led_rdata;
    wire [31:0] switch_rdata;
    wire [31:0] mic_rdata;

    rom u_rom (
        .enable(rom_enable),
        .addr  (mem_addr[16:2]),
        .rdata (rom_rdata)
    );

    ram u_ram (
        .clk(clk),
        .enable(ram_enable),
        .addr(mem_addr[16:2]),
        .wdata(mem_wdata),
        .wstrb(mem_wstrb),
        .rdata(ram_rdata)
    );

    leds u_leds (
        .clk(clk),
        .resetn(resetn),
        .enable(led_enable),
        .wdata(mem_wdata[15:0]),
        .wstrb(mem_wstrb[1:0]),
        .rdata(led_rdata),
        .led_out(led)
    );

    switches u_switches (
        .enable(switches_enable),
        .rdata(switch_rdata),
        .switch_in(switches)
    );

    mic u_mic (
        .clk(clk),
        .resetn(resetn),
        .enable(mic_enable),
        .rdata(mic_rdata),
        .check_ready(mem_addr[2]),
        .M_CLK(M_CLK),
        .M_DATA(M_DATA),
        .M_LRSEL(M_LRSEL)
    );

    assign mem_ready = mem_valid;

    always @* begin
        if (rom_select) mem_rdata = rom_rdata;
        else if (ram_select) mem_rdata = ram_rdata;
        else if (led_select) mem_rdata = led_rdata;
        else if (switches_select) mem_rdata = switch_rdata;
        else if (mic_select) mem_rdata = mic_rdata;
        else mem_rdata = 32'b0;
    end
endmodule


module rom (
    input wire enable,
    input wire [14:0] addr,
    output wire [31:0] rdata
);
    reg [31:0] mem[32767:0];

    initial begin
        $readmemh(`FIRMWARE_FILE, mem);
    end

    assign rdata = enable ? mem[addr] : 32'b0;
endmodule


module ram (
    input wire clk,
    input wire enable,
    input wire [14:0] addr,
    input wire [31:0] wdata,
    input wire [3:0] wstrb,
    output wire [31:0] rdata
);
    reg [31:0] mem[32767:0];

    always @(posedge clk) begin
        if (enable) begin
            if (wstrb[0]) mem[addr][7:0] <= wdata[7:0];
            if (wstrb[1]) mem[addr][15:8] <= wdata[15:8];
            if (wstrb[2]) mem[addr][23:16] <= wdata[23:16];
            if (wstrb[3]) mem[addr][31:24] <= wdata[31:24];
        end
    end

    assign rdata = enable ? mem[addr] : 32'b0;
endmodule


module leds (
    input wire clk,
    input wire resetn,
    input wire enable,
    input wire [15:0] wdata,
    input wire [1:0] wstrb,
    output wire [31:0] rdata,
    output wire [15:0] led_out
);
    reg [15:0] led_reg;

    always @(posedge clk) begin
        if (!resetn) begin
            led_reg <= 16'b0;
        end else if (enable) begin
            if (wstrb[0]) led_reg[7:0] <= wdata[7:0];
            if (wstrb[1]) led_reg[15:8] <= wdata[15:8];
        end
    end

    assign rdata   = enable ? {16'b0, led_reg} : 32'b0;
    assign led_out = led_reg;
endmodule


module switches (
    input wire enable,
    output wire [31:0] rdata,
    input wire [15:0] switch_in
);
    assign rdata = enable ? {16'b0, switch_in} : 32'b0;
endmodule


module mic (
    input wire clk,
    input wire resetn,
    input wire enable,
    input wire check_ready,
    output wire [31:0] rdata,
    output reg M_CLK,
    input wire M_DATA,
    output wire M_LRSEL
);
    reg [4:0] clk_counter;
    reg [7:0] sample_count;
    reg [8:0] high_count;
    reg [9:0] level;
    reg ready;

    assign M_LRSEL = 0;

    always @(posedge clk) begin
        if (!resetn) begin
            clk_counter <= 0;
            M_CLK <= 0;
            sample_count <= 0;
            high_count <= 0;
            level <= 0;
            ready <= 0;
        end else begin
            clk_counter <= clk_counter + 1'b1;
            M_CLK <= clk_counter[4];

            if (clk_counter == 5'b11111) begin
                if (sample_count == 8'd255) begin
                    level <= {1'b0, high_count} + M_DATA;
                    high_count <= 0;
                    sample_count <= 0;
                    ready <= 1;
                end else begin
                    high_count   <= high_count + M_DATA;
                    sample_count <= sample_count + 1'b1;
                end
            end

            if (enable && ~check_ready) begin
                ready <= 0;
            end
        end
    end

    assign rdata = enable ? (check_ready ? {31'b0, ready} : {22'b0, level}) : 32'b0;

endmodule
