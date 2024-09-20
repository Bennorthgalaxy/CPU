module IF (
    input  wire        cpu_clk     ,
    input  wire        cpu_rst   ,

    input  wire [1:0]  npc_op  ,

    input  wire [31:0] sext_ext,
    input  wire [31:0] alu_c   ,

    output wire [31:0] pc      ,
    output wire [31:0] npc_pc4
);

wire [31:0] npc;

PC U_PC (
    // input
    .cpu_clk   (cpu_clk     ),
    .cpu_rst (cpu_rst   ),
    .din   (npc     ),
    // output
    .pc    (pc      )
);

NPC U_NPC (
    // input
    .op    (npc_op  ),
    .pc    (pc      ),
    .imm   (sext_ext),
    .alu_c (alu_c   ),
    // output
    .npc   (npc     ),
    .pc4   (npc_pc4 )
);

endmodule
