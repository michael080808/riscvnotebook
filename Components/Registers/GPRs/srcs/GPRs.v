`timescale 1ns / 1ps

/*
 * 使用RegisterUnit构建任意宽度任意数量的通用寄存器组
 * 可通过ZERO选项配置首个寄存器是否为零寄存器
 */
module GPRs #
(
    parameter ZERO = 0,                     // 配置首个寄存器是否为零寄存器，常规寄存器为0，零寄存器为1
    parameter WIDTH = 32,                   // 单个寄存器位宽
    parameter UNITS = 32                    // 寄存器总数
)
(
    input  RST,                             // 同步复位
    input  CLK,                             // 同步时钟
    input  WEN,                             // 写入使能(时钟使能)
    input  [$clog2(UNITS) - 1 : 0] DSTs,    // 复选目标寄存器
    input  [$clog2(UNITS) - 1 : 0] RS1s,    // 复选源寄存器1
    input  [$clog2(UNITS) - 1 : 0] RS2s,    // 复选源寄存器2
    input  [WIDTH - 1 : 0] DSTi,            // 目标寄存器数据写入
    output [WIDTH - 1 : 0] RS1o,            // 源寄存器1数据输出
    output [WIDTH - 1 : 0] RS2o             // 源寄存器2数据输出
);

// 针对目标寄存器写入使能进行编码
// 用于映射到对应的寄存器上
integer index;
reg [WIDTH - 1 : 0] CLKs;
always @(*)
begin
    for(index = 0; index < WIDTH; index = index + 1)
    begin
        CLKs[index] <= (index == DSTs) ? 1'b1 : 1'b0;
    end
end

// 批量实例化寄存器RegisterUnit并进行对应连线
wire [WIDTH - 1 : 0] X [UNITS - 1 : 0];
genvar i;
generate
    for(i = 0; i < UNITS; i = i + 1)
    begin
        RegisterUnit #(.WIDTH(WIDTH))
        Unit
        (
            .RST((ZERO && !i) ? 1'b1 : RST), // 针对零寄存器进行特殊设置
            .CLK(CLK),                       // 同步时钟
            .ENA(WEN & CLKs[i]),             // 当写入使能且选定该寄存器时，D触发器写入使能
            .D(DSTi),                        // 目标寄存器数据写入
            .Q(X[i])                         // 寄存器数据全部输出
        );
    end
endgenerate

// 源寄存器数据输出复选器
// 根据源寄存器的编码进行输出数据的选择
reg [WIDTH - 1 : 0] RS1sG;
reg [WIDTH - 1 : 0] RS2sG;
always @(*)
begin
     RS1sG <= X[RS1s];
     RS2sG <= X[RS2s];
end
assign RS1o = RS1sG;
assign RS2o = RS2sG;

endmodule
