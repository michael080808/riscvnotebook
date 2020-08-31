`timescale 1ns / 1ps

// zero      : 首个寄存器是否为零寄存器
// width     : 寄存器位宽
// registers : 寄存器数量
module GPRs_Testbench #(parameter zero = 0, parameter width = 32, parameter registers = 32)();

// 同步复位
reg reset = 1'b1;
// 同步时钟
reg clock = 1'b0;
// 写入使能(时钟使能)
reg write = 1'b1;

// 复选目标寄存器
reg [$clog2(registers) - 1 : 0] dst;
// 复选源寄存器1
reg [$clog2(registers) - 1 : 0] rs1;
// 复选源寄存器2
reg [$clog2(registers) - 1 : 0] rs2;

// 目标寄存器输入数据
reg  [width - 1 : 0] dst_i;
// 源寄存器1输出数据
wire [width - 1 : 0] rs1_o;
// 源寄存器2输出数据
wire [width - 1 : 0] rs2_o;

// 实例化通用寄存器组
GPRs #(.zero(zero), .registers(registers), .width(width))
Unit
(
    .reset(reset), // 同步复位
    .clock(clock), // 同步时钟
    .write(write), // 写入使能(时钟使能)
    .dst(dst),     // 复选目标寄存器
    .rs1(rs1),     // 复选源寄存器1
    .rs2(rs2),     // 复选源寄存器2
    .dst_i(dst_i), // 目标寄存器数据写入
    .rs1_o(rs1_o), // 源寄存器1数据输出
    .rs2_o(rs2_o)  // 源寄存器2数据输出
);

// 初始化100MHz时钟
always  #5   clock = ~clock;
// 100ns之后复位结束，注意此处由于FPGA的初始化，因此复位时长要大于等于100ns
initial #100 reset = ~reset;

integer i, j;
initial
begin
    #100 ;                                      // 在100ns之后开始对通用寄存器操作
    for(i = 0; i < registers; i = i + 1)        // 对于每个寄存器进行一次赋值
    begin
        dst <= i;                               // 对目标寄存器进行复选
        dst_i <= $random();                     // 对目标寄存器输入随机数据
        for(j = 0; j < registers; j = j + 1)    // 赋值后检查每个寄存器内存储的内容
        begin
            rs1 <= j;                           // 源寄存器1正序输出数据
            rs2 <= registers - 1 - j;           // 源寄存器2倒序输出数据
            #10 ;                               // 每个输出为一个时钟周期
        end
    end
    
    // 对寄存器组清零复位，注意此处复位大于一个时钟周期(包含一个上升沿)即可
    #000 reset = ~reset;                        // 对寄存器组开始复位
    #100 reset = ~reset;                        // 对寄存器组结束复位

    // 针对零寄存器的情况，单独进行零寄存器的写入检查
    if(zero)
    begin
        dst <= 0;                               // 复选零寄存器
        dst_i <= $random();                     // 对零寄存器输入随机数据
        for(j = 0; j < registers; j = j + 1)
        begin
            rs1 <= j;                           // 源寄存器1正序输出数据
            rs2 <= registers - 1 - j;           // 源寄存器2倒序输出数据
            #10 ;                               // 每个输出为一个时钟周期
        end 
    end
    
    // 对写入使能(时钟使能)功能进行检查
    for(i = 0; i < registers; i = i + 1)
    begin
        dst <= i;                               // 对目标寄存器进行复选
        dst_i <= $random();                     // 对目标寄存器输入随机数据
        write <= ~write;                        // 改变当前写入使能(时钟使能)状态
        for(j = 0; j < registers; j = j + 1)
        begin
            rs1 <= j;                           // 源寄存器1正序输出数据
            rs2 <= registers - 1 - j;           // 源寄存器2倒序输出数据
            #10 ;                               // 每个输出为一个时钟周期
        end
    end

    // 完成检查，停止仿真
    $stop;
end

endmodule
