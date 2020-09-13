`timescale 1ns / 1ps

/*
 * 使用FDRE构建任意宽度带有时钟使能的同步复位寄存器
 *      时钟使能用于寄存器组写入使能控制和写入复选控制
 *      同步复位用于寄存器初始化重置以及整型零寄存器的连续置位(异步不能连续置位)
 */

module RegisterUnit #
(
    parameter WIDTH = 32        // 寄存器位数
)
(
    input  RST,                 // 同步复位
    input  CLK,                 // 同步时钟
    input  ENA,                 // 时钟使能
    input  [WIDTH - 1 : 0] D,   // 数据输入
    output [WIDTH - 1 : 0] Q    // 数据输出
);

// FDRE批量实例化
// 共用时钟、同步复位、时钟使能
// 数据输入和输出分离
genvar i;
generate
    for(i = 0; i < WIDTH; i = i + 1)
    begin
        FDRE #(.INIT(1'b0))
        FDRE_inst
        (
            .C(CLK),        // 同步时钟
            .R(RST),        // 同步复位
            .CE(ENA),       // 时钟使能
            .D(D[i]),       // 数据输入
            .Q(Q[i])        // 数据输出
        );
    end
endgenerate

endmodule
