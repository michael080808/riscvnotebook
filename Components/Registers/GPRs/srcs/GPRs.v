`timescale 1ns / 1ps

/*
 * 使用RegisterUnit构建任意宽度任意数量的通用寄存器组
 * 可通过zero选项配置首个寄存器是否为零寄存器
 */
module GPRs #
(
    parameter zero = 0,         // 配置首个寄存器是否为零寄存器，常规寄存器为0，零寄存器为1
    parameter width = 32,       // 单个寄存器位宽
    parameter registers = 32    // 寄存器总数
)
(
    input  reset,                           // 同步复位
    input  clock,                           // 同步时钟
    input  write,                           // 写入使能(时钟使能)
    input  [$clog2(registers) - 1 : 0] dst, // 复选目标寄存器
    input  [$clog2(registers) - 1 : 0] rs1, // 复选源寄存器1
    input  [$clog2(registers) - 1 : 0] rs2, // 复选源寄存器2
    input  [width - 1 : 0] dst_i,           // 目标寄存器数据写入
    output [width - 1 : 0] rs1_o,           // 源寄存器1数据输出
    output [width - 1 : 0] rs2_o            // 源寄存器2数据输出
);

// 针对目标寄存器写入使能进行编码
// 用于映射到对应的寄存器上
integer index;
reg [width - 1 : 0] clock_select;
always @(*)
begin
    for(index = 0; index < width; index = index + 1)
    begin
        clock_select[index] <= (index == dst) ? 1'b1 : 1'b0;
    end
end

// 批量实例化寄存器RegisterUnit并进行对应连线
wire [width - 1 : 0] x[registers - 1 : 0];
genvar i;
generate
    for(i = 0; i < registers; i = i + 1)
    begin
        RegisterUnit #(.width(width))
        Unit
        (
            .reset((zero && !i) ? 1'b1 : reset), // 针对零寄存器进行特殊设置
            .clock(clock),                       // 同步时钟
            .enable(write & clock_select[i]),    // 当写入使能且选定该寄存器时，D触发器写入使能
            .D(dst_i),                           // 目标寄存器数据写入
            .Q(x[i])                             // 寄存器数据全部输出
        );
    end
endgenerate

// 源寄存器数据输出复选器
// 根据源寄存器的编码进行输出数据的选择
reg [width - 1 : 0] rs1_reg;
reg [width - 1 : 0] rs2_reg;
always @(*)
begin
     rs1_reg <= x[rs1];
     rs2_reg <= x[rs2];
end

assign rs1_o = rs1_reg;
assign rs2_o = rs2_reg;

endmodule
