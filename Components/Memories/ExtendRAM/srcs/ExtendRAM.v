`timescale 1ns / 1ps

module ExtendRAM #
(
    parameter RTYPE = "ISPRAM",             // RAM内部实现类型
    parameter ADDRW = 14,                   // RAM地址宽度
    parameter UNITW = 8,                    // RAM每个单元宽度
    parameter GROUP = 4,                    // RAM每组单元数量
    parameter DEPTH = 2 ** 14               // RAM存储深度
)
(
    input  CLK,                             // 时钟输入
    input  RST,                             // 复位输入
    input  CEN,                             // 时钟使能
    input  [GROUP         - 1 : 0] WEN,     // 写入使能
    input  [ADDRW         - 1 : 0] ADDR_H,  // 地址高位(深度)
    input  [$clog2(GROUP) - 1 : 0] ADDR_L,  // 地址低位(组号)
    input  [UNITW * GROUP - 1 : 0] DATA_I,  // 数据输入
    output [UNITW * GROUP - 1 : 0] DATA_O,  // 数据输出
    output OVF                              // 地址溢出
);

generate
    case (RTYPE)
        "ISPRAM":
        begin
            ISPRAM #
            (
                .ADDRW(ADDRW),      // RAM地址宽度
                .UNITW(UNITW),      // RAM每个单元宽度
                .GROUP(GROUP),      // RAM每组单元数量
                .DEPTH(DEPTH)       // RAM存储深度
            )
            RAM
            (
                .CLK(CLK),          // 时钟输入
                .RST(RST),          // 复位输入
                .CEN(CEN),          // 时钟使能
                .WEN(WEN),          // 写入使能
                .ADDR_H(ADDR_H),    // 地址高位(深度)
                .ADDR_L(ADDR_L),    // 地址低位(组号)
                .DATA_I(DATA_I),    // 数据输入
                .DATA_O(DATA_O),    // 数据输出
                .OVF(OVF)           // 地址溢出
            );
        end
        "TDPRAM": 
        begin
            TDPRAM #
            (
                .ADDRW(ADDRW),      // RAM地址宽度
                .UNITW(UNITW),      // RAM每个单元宽度
                .GROUP(GROUP),      // RAM每组单元数量
                .DEPTH(DEPTH)       // RAM存储深度
            )
            RAM
            (
                .CLK(CLK),          // 时钟输入
                .RST(RST),          // 复位输入
                .CEN(CEN),          // 时钟使能
                .WEN(WEN),          // 写入使能
                .ADDR_H(ADDR_H),    // 地址高位(深度)
                .ADDR_L(ADDR_L),    // 地址低位(组号)
                .DATA_I(DATA_I),    // 数据输入
                .DATA_O(DATA_O),    // 数据输出
                .OVF(OVF)           // 地址溢出
            );
        end
    endcase
endgenerate
  
endmodule