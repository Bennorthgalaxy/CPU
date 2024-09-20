module PC (
    input  wire        cpu_clk  ,
    input  wire        cpu_rst,
    input  wire [31:0] din  ,
    output reg  [31:0] pc
);

always @ (posedge cpu_clk or posedge cpu_rst) begin
    if (cpu_rst) pc <= -4; // 初始给 -4, 避免覆盖
        else pc <= din;
end

endmodule
