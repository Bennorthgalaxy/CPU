`timescale 1ns / 1ps

`include "defines.vh"

module miniRV_SoC (
    input  wire         fpga_rst,   // High active
    input  wire         fpga_clk,

    input  wire [23:0]  switch1,
    input  wire [ 4:0]  button,
    output wire [ 7:0]  dig_en,
    output wire         DN_A,
    output wire         DN_B,
    output wire         DN_C,
    output wire         DN_D,
    output wire         DN_E,
    output wire         DN_F,
    output wire         DN_G,
    output wire         DN_DP,
    output wire [23:0]  led

`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst, // 当前时钟周期是否有指令写回 (对单周期CPU，可在复位后恒置1)
    output wire [31:0]  debug_wb_pc,        // 当前写回的指令的PC (若wb_have_inst=0，此项可为任意值)
    output              debug_wb_ena,       // 指令写回时，寄存器堆的写使能 (若wb_have_inst=0，此项可为任意值)
    output wire [ 4:0]  debug_wb_reg,       // 指令写回时，写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
    output wire [31:0]  debug_wb_value      // 指令写回时，写入寄存器的值 (若wb_ena或wb_have_inst=0，此项可为任意值)
`endif
);

    wire        pll_lock;
    wire        pll_clk;
    wire        cpu_clk;

    // Interface between CPU and IROM
`ifdef RUN_TRACE
    wire [15:0] inst_addr;
`else
    wire [13:0] inst_addr;
`endif
    wire [31:0] inst;

    // Interface between CPU and Bridge
    wire [31:0] Bus_rdata;
    wire [31:0] Bus_addr;
    wire        Bus_wen;
    wire [31:0] Bus_wdata;
    
 
wire [31:0] pc_pc    ;    
wire        dram_we  ;
wire        rf_we    ;
wire [31:0] dram_rd  ;
wire [31:0] alu_c    ;
wire [31:0] rf_rd2   ;
wire [31:0] rf_wd    ;

    
`ifdef RUN_TRACE
    // Trace调试时，直接使用外部输入时钟
    assign cpu_clk = fpga_clk;
`else
    // 下板时，使用PLL分频后的时钟
    assign cpu_clk = pll_clk & pll_lock;
    cpuclk Clkgen (
        // .resetn     (!fpga_rst),
        .clk_in1    (fpga_clk),
        .clk_out1   (pll_clk),
        .locked     (pll_lock)
    );
`endif
    
    myCPU Core_cpu (
        .cpu_rst            (fpga_rst),
        .cpu_clk            (cpu_clk),

        .dram_rd            (dram_rd),
        .pc_pc              (pc_pc), // output

        // Interface to IROM
        .inst_addr          (inst_addr),
        .inst               (inst),

        // Interface to Bridge
        .Bus_addr           (Bus_addr),
        .Bus_rdata          (Bus_rdata),
        .Bus_wen            (Bus_wen),
        .Bus_wdata          (Bus_wdata),

        .rf_we     (rf_we      ), // output
        .rf_wd     (rf_wd      ), // output
        .dram_we   (dram_we    ), // output
        .alu_c     (alu_c      ), // output
        .rf_rd2    (rf_rd2     ) // output

    );
    
    IROM Mem_IROM (
        .a          (inst_addr),
        .spo        (inst)
    );
    

    DRAM Mem_DRAM (
        .clk        (cpu_clk),
        .a          (alu_c[15:2]),
        .spo        (dram_rd ),
        .we         (dram_we),
        .d          (rf_rd2)
    );

`ifdef RUN_TRACE
    // Debug Interface
    assign debug_wb_have_inst = 1/* TODO */;
    assign debug_wb_pc        = pc_pc/* TODO */;
    assign debug_wb_ena       = rf_we/* TODO */;
    assign debug_wb_reg       = inst[11:7]/* TODO */;
    assign debug_wb_value     = rf_wd/* TODO */;
`endif

endmodule
