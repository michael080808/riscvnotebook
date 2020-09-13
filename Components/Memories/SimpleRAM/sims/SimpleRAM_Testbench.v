`timescale 1ns / 1ps

module SimpleRAM_Testbench #(parameter ADDRW = 32, parameter DATAW = 32, parameter DEPTH = 2 ** 14)();

reg  CLK = 1'b0;                // 时钟输入
reg  RST = 1'b1;                // 复位输入
reg  WEN = 1'b0;                // 写入使能
reg  CEN = 1'b1;                // 时钟使能
reg  [$clog2(DEPTH) - 1 : 0] ADDR = {$clog2(DEPTH){1'b0}}; // 内存地址
reg  [DATAW - 1 : 0] DATi = {DATAW{1'b0}}; // 数据输入
wire [DATAW - 1 : 0] DATo;                 // 数据输出

SimpleRAM #
(
    .ADDRW(ADDRW),              // RAM地址宽度
    .DATAW(DATAW),              // RAM数据宽度
    .DEPTH(DEPTH),              // RAM存储深度
    .MEMORY_INIT_FILE("none"),  // RAM初始化文件
    .SIM_ASSERT_CHK(1)          // 是否开启仿真调试信息
)
RAM
(
    .CLK(CLK),                  // 时钟输入
    .RST(RST),                  // 复位输入
    .WEN(WEN),                  // 写入使能
    .CEN(CEN),                  // 时钟使能
    .ADDR(ADDR),                // 内存地址
    .DATi(DATi),                // 数据输入
    .DATo(DATo)                 // 数据输出
);

// 生成100MHz的测试时钟
always  #5   CLK = ~CLK;
// 重置100ns
initial #100 RST = ~RST;

integer i;

initial
begin
    #100 ;
    // 对内存的每个存储单元进行读取和写入测试
    for(i = 0; i < DEPTH; i = i + 1)
    begin
        ADDR <= i;
        DATi  <= $random();
        #10 WEN = ~WEN;
        #10 WEN = ~WEN;
    end
    // 重置输入数据
    DATi = {$clog2(DEPTH){1'b0}};
    // 对内存的每个存储单元进行读取测试，确认前述数据写入
    for(i = 0; i < DEPTH; i = i + 1)
    begin
        ADDR <= i;
        #20 ;
    end
    // 禁用内存
    CEN <= 1'b0;
    // 测试禁用内存后的读取和写入
    for(i = 0; i < DEPTH; i = i + 1)
    begin
        ADDR <= i;
        DATi  <= $random();
        #10 WEN = ~WEN;
        #10 WEN = ~WEN;
    end
    // 启用内存
    CEN <= 1'b1;
    // 对内存的每个存储单元进行重新的读取和写入测试
    for(i = 0; i < DEPTH; i = i + 1)
    begin
        ADDR <= i;
        DATi  <= $random();
        #10 WEN = ~WEN;
        #10 WEN = ~WEN;
    end
    // 停止仿真
    $stop;
end

endmodule