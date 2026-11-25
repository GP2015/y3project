`timescale 1 ns / 1 ps

module top (
    input wire CLK100MHZ,
    input wire CPU_RESETN,
    output wire [15:0] LED,
    input wire [15:0] SW,
    output reg M_CLK,
    input wire M_DATA,
    output wire M_LRSEL
);
    wire        trap;
    wire        mem_instr;

    wire        wbm_cyc;
    wire        wbm_stb;
    wire        wbm_we;
    wire [ 3:0] wbm_sel;
    wire [31:0] wbm_adr;
    wire [31:0] wbm_dat_o;
    wire [31:0] wbm_dat_i;
    wire        wbm_ack;

    wire        mem_valid;
    wire [ 3:0] mem_wstrb;

    assign mem_valid = wbm_cyc && wbm_stb;
    assign mem_wstrb = wbm_we ? wbm_sel : 4'b0000;

    mem u_mem (
        .clk(CLK100MHZ),
        .resetn(CPU_RESETN),

        .mem_valid(mem_valid),
        .mem_addr (wbm_adr),
        .mem_wdata(wbm_dat_o),
        .mem_wstrb(mem_wstrb),
        .mem_ready(wbm_ack),
        .mem_rdata(wbm_dat_i),

        .led(LED),
        .switches(SW),
        .M_CLK(M_CLK),
        .M_DATA(M_DATA),
        .M_LRSEL(M_LRSEL)
    );

    picorv32_wb #(
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
        .STACKADDR(32'h0003_FFFC)
    ) cpu (
        .trap(trap),

        .wb_rst_i(~CPU_RESETN),
        .wb_clk_i(CLK100MHZ),

        .wbm_adr_o(wbm_adr),
        .wbm_dat_o(wbm_dat_o),
        .wbm_dat_i(wbm_dat_i),
        .wbm_we_o (wbm_we),
        .wbm_sel_o(wbm_sel),
        .wbm_stb_o(wbm_stb),
        .wbm_ack_i(wbm_ack),
        .wbm_cyc_o(wbm_cyc),

        .pcpi_wr(1'b0),
        .pcpi_rd(32'b0),
        .pcpi_wait(1'b0),
        .pcpi_ready(1'b0),

        .irq(32'b0),

        .mem_instr(mem_instr)
    );
endmodule
