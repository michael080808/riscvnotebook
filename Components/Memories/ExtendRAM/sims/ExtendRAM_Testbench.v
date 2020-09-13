`timescale 1ns / 1ps

module ExtendRAM_Testbench #(parameter ADDRW = 14, parameter UNITW = 8, parameter GROUP = 4, parameter DEPTH = 2 ** 14)();

reg  CLK = 1'b0;                                // 时钟输入
reg  RST = 1'b1;                                // 复位输入
reg  CEN = 1'b1;                                // 时钟使能
reg  [GROUP                 - 1 : 0] WEN;       // 写入使能
reg  [ADDRW + $clog2(GROUP) - 1 : 0] ADDR_F;    // 地址
reg  [UNITW * GROUP - 1 : 0] DATA_I;            // 数据输入
wire [UNITW * GROUP - 1 : 0] DATA1O;            // 数据输出
wire OVF1;                                      // 地址溢出
wire [UNITW * GROUP - 1 : 0] DATA2O;            // 数据输出
wire OVF2;                                      // 地址溢出

ExtendRAM #
(
    .RTYPE("ISPRAM"),                           // RAM内部实现类型
    .ADDRW(ADDRW),                              // RAM地址宽度
    .UNITW(UNITW),                              // RAM每个单元宽度
    .GROUP(GROUP),                              // RAM每组单元数量
    .DEPTH(DEPTH)                               // RAM存储深度
)
RAM1
(
    .CLK(CLK),                                  // 时钟输入
    .RST(RST),                                  // 复位输入
    .CEN(CEN),                                  // 时钟使能
    .WEN(WEN),                                  // 写入使能
    .ADDR_H(ADDR_F[ADDRW + $clog2(GROUP) - 1 : $clog2(GROUP)]),   // 地址高位(深度)
    .ADDR_L(ADDR_F[        $clog2(GROUP) - 1 :             0]),   // 地址低位(组号)
    .DATA_I(DATA_I),                            // 数据输入
    .DATA_O(DATA1O),                            // 数据输出
    .OVF(OVF1)                                  // 地址溢出
);


ExtendRAM #
(
    .RTYPE("TDPRAM"),                           // RAM内部实现类型
    .ADDRW(ADDRW),                              // RAM地址宽度
    .UNITW(UNITW),                              // RAM每个单元宽度
    .GROUP(GROUP),                              // RAM每组单元数量
    .DEPTH(DEPTH)                               // RAM存储深度
)
RAM2
(
    .CLK(CLK),                                  // 时钟输入
    .RST(RST),                                  // 复位输入
    .CEN(CEN),                                  // 时钟使能
    .WEN(WEN),                                  // 写入使能
    .ADDR_H(ADDR_F[ADDRW + $clog2(GROUP) - 1 : $clog2(GROUP)]),   // 地址高位(深度)
    .ADDR_L(ADDR_F[        $clog2(GROUP) - 1 :             0]),   // 地址低位(组号)
    .DATA_I(DATA_I),                            // 数据输入
    .DATA_O(DATA2O),                            // 数据输出
    .OVF(OVF2)                                  // 地址溢出
);


always  #5   CLK = ~CLK;
initial #100 RST = ~RST;

integer index;
initial
begin
    // 系统重置
    #100 ;

    // 对齐写入，非对齐读取

    // 写入数据
    WEN <= 4'b1111;
    // 第一组
    ADDR_F <= 16'h0000;
    DATA_I <= 32'h04030201;
    #10 ;
    // 第二组
    ADDR_F <= 16'h0004;
    DATA_I <= 32'h08070605;
    #10 ;

    // 读取数据
    WEN <= 4'b0000;
    // 数据输入清空
    DATA_I <= 32'h00000000;
    // 设置循环起始地址
    ADDR_F <= 16'h0000;
    for(index = 0; index < 4'h0009; index = index + 1)
    begin
        #10 ADDR_F = ADDR_F + 1;
    end

    // 非对齐写入，对齐读取

    // 写入数据
    // 第一组
    WEN    <= 4'b1111;
    ADDR_F <= 16'h0009;
    DATA_I <= 32'h0C0B0A09;
    #10 ;
    // 第二组
    WEN    <= 4'b0011;
    ADDR_F <= 16'h000E;
    DATA_I <= 32'h100F0E0D;
    #10 ;

    // 读取数据
    WEN <= 4'b0000;
    // 数据输入清空
    DATA_I <= 32'h00000000;
    // 第一组
    ADDR_F <= 16'h0008;
    #10 ;
    // 第二组
    ADDR_F <= 16'h000C;
    #10 ;

    $stop;
end

endmodule