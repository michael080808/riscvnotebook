`timescale 1ns / 1ps

// ZERO  : 首个寄存器是否为零寄存器
// WIDTH : 寄存器位宽
// UNITS : 寄存器数量
module GPRs_Testbench #(parameter ZERO = 0, parameter WIDTH = 32, parameter UNITS = 32)();

// 同步复位
reg RST = 1'b1;
// 同步时钟
reg CLK = 1'b0;
// 写入使能(时钟使能)
reg WEN = 1'b1;

// 复选目标寄存器
reg [$clog2(UNITS) - 1 : 0] DSTs;
// 复选源寄存器1
reg [$clog2(UNITS) - 1 : 0] RS1s;
// 复选源寄存器2
reg [$clog2(UNITS) - 1 : 0] RS2s;

// 目标寄存器输入数据
reg  [WIDTH - 1 : 0] DSTi;
// 源寄存器1输出数据
wire [WIDTH - 1 : 0] RS1o;
// 源寄存器2输出数据
wire [WIDTH - 1 : 0] RS2o;

// 实例化通用寄存器组
GPRs #(.ZERO(ZERO), .UNITS(UNITS), .WIDTH(WIDTH))
Unit
(
    .RST(RST),   // 同步复位
    .CLK(CLK),   // 同步时钟
    .WEN(WEN),   // 写入使能(时钟使能)
    .DSTs(DSTs), // 复选目标寄存器
    .RS1s(RS1s), // 复选源寄存器1
    .RS2s(RS2s), // 复选源寄存器2
    .DSTi(DSTi), // 目标寄存器数据写入
    .RS1o(RS1o), // 源寄存器1数据输出
    .RS2o(RS2o)  // 源寄存器2数据输出
);

// 初始化100MHz时钟
always  #5   CLK = ~CLK;
// 100ns之后复位结束，注意此处由于FPGA的初始化，因此复位时长要大于等于100ns
initial #100 RST = ~RST;

integer i, j;
initial
begin
    #100 ;                                  // 在100ns之后开始对通用寄存器操作
    for(i = 0; i < UNITS; i = i + 1)        // 对于每个寄存器进行一次赋值
    begin
        DSTs <= i;                          // 对目标寄存器进行复选
        DSTi <= $random();                  // 对目标寄存器输入随机数据
        for(j = 0; j < UNITS; j = j + 1)    // 赋值后检查每个寄存器内存储的内容
        begin
            RS1s <= j;                      // 源寄存器1正序输出数据
            RS2s <= UNITS - 1 - j;          // 源寄存器2倒序输出数据
            #10 ;                           // 每个输出为一个时钟周期
        end
    end
    
    // 对寄存器组清零复位，注意此处复位大于一个时钟周期(包含一个上升沿)即可
    #000 RST = ~RST;                        // 对寄存器组开始复位
    #100 RST = ~RST;                        // 对寄存器组结束复位

    // 针对零寄存器的情况，单独进行零寄存器的写入检查
    if(ZERO)
    begin
        DSTs <= 0;                          // 复选零寄存器
        DSTi <= $random();                  // 对零寄存器输入随机数据
        for(j = 0; j < UNITS; j = j + 1)
        begin
            RS1s <= j;                      // 源寄存器1正序输出数据
            RS2s <= UNITS - 1 - j;          // 源寄存器2倒序输出数据
            #10 ;                           // 每个输出为一个时钟周期
        end 
    end
    
    // 对写入使能(时钟使能)功能进行检查
    for(i = 0; i < UNITS; i = i + 1)
    begin
        DSTs <= i;                          // 对目标寄存器进行复选
        DSTi <= $random();                  // 对目标寄存器输入随机数据
        WEN <= ~WEN;                        // 改变当前写入使能(时钟使能)状态
        for(j = 0; j < UNITS; j = j + 1)
        begin
            RS1s <= j;                      // 源寄存器1正序输出数据
            RS2s <= UNITS - 1 - j;          // 源寄存器2倒序输出数据
            #10 ;                           // 每个输出为一个时钟周期
        end
    end

    // 完成检查，停止仿真
    $stop;
end

endmodule
