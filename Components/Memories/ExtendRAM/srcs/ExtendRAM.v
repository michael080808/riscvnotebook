`timescale 1ns / 1ps

module ExtendRAM #
(
    parameter RTYPE = "ISPRAM",             // RAM�ڲ�ʵ������
    parameter ADDRW = 14,                   // RAM��ַ���
    parameter UNITW = 8,                    // RAMÿ����Ԫ���
    parameter GROUP = 4,                    // RAMÿ�鵥Ԫ����
    parameter DEPTH = 2 ** 14               // RAM�洢���
)
(
    input  CLK,                             // ʱ������
    input  RST,                             // ��λ����
    input  CEN,                             // ʱ��ʹ��
    input  [GROUP         - 1 : 0] WEN,     // д��ʹ��
    input  [ADDRW         - 1 : 0] ADDR_H,  // ��ַ��λ(���)
    input  [$clog2(GROUP) - 1 : 0] ADDR_L,  // ��ַ��λ(���)
    input  [UNITW * GROUP - 1 : 0] DATA_I,  // ��������
    output [UNITW * GROUP - 1 : 0] DATA_O,  // �������
    output OVF                              // ��ַ���
);

generate
    case (RTYPE)
        "ISPRAM":
        begin
            ISPRAM #
            (
                .ADDRW(ADDRW),      // RAM��ַ���
                .UNITW(UNITW),      // RAMÿ����Ԫ���
                .GROUP(GROUP),      // RAMÿ�鵥Ԫ����
                .DEPTH(DEPTH)       // RAM�洢���
            )
            RAM
            (
                .CLK(CLK),          // ʱ������
                .RST(RST),          // ��λ����
                .CEN(CEN),          // ʱ��ʹ��
                .WEN(WEN),          // д��ʹ��
                .ADDR_H(ADDR_H),    // ��ַ��λ(���)
                .ADDR_L(ADDR_L),    // ��ַ��λ(���)
                .DATA_I(DATA_I),    // ��������
                .DATA_O(DATA_O),    // �������
                .OVF(OVF)           // ��ַ���
            );
        end
        "TDPRAM": 
        begin
            TDPRAM #
            (
                .ADDRW(ADDRW),      // RAM��ַ���
                .UNITW(UNITW),      // RAMÿ����Ԫ���
                .GROUP(GROUP),      // RAMÿ�鵥Ԫ����
                .DEPTH(DEPTH)       // RAM�洢���
            )
            RAM
            (
                .CLK(CLK),          // ʱ������
                .RST(RST),          // ��λ����
                .CEN(CEN),          // ʱ��ʹ��
                .WEN(WEN),          // д��ʹ��
                .ADDR_H(ADDR_H),    // ��ַ��λ(���)
                .ADDR_L(ADDR_L),    // ��ַ��λ(���)
                .DATA_I(DATA_I),    // ��������
                .DATA_O(DATA_O),    // �������
                .OVF(OVF)           // ��ַ���
            );
        end
    endcase
endgenerate
  
endmodule