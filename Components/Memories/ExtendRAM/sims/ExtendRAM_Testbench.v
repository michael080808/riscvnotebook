`timescale 1ns / 1ps

module ExtendRAM_Testbench #(parameter ADDRW = 14, parameter UNITW = 8, parameter GROUP = 4, parameter DEPTH = 2 ** 14)();

reg  CLK = 1'b0;                                // ʱ������
reg  RST = 1'b1;                                // ��λ����
reg  CEN = 1'b1;                                // ʱ��ʹ��
reg  [GROUP                 - 1 : 0] WEN;       // д��ʹ��
reg  [ADDRW + $clog2(GROUP) - 1 : 0] ADDR_F;    // ��ַ
reg  [UNITW * GROUP - 1 : 0] DATA_I;            // ��������
wire [UNITW * GROUP - 1 : 0] DATA1O;            // �������
wire OVF1;                                      // ��ַ���
wire [UNITW * GROUP - 1 : 0] DATA2O;            // �������
wire OVF2;                                      // ��ַ���

ExtendRAM #
(
    .RTYPE("ISPRAM"),                           // RAM�ڲ�ʵ������
    .ADDRW(ADDRW),                              // RAM��ַ���
    .UNITW(UNITW),                              // RAMÿ����Ԫ���
    .GROUP(GROUP),                              // RAMÿ�鵥Ԫ����
    .DEPTH(DEPTH)                               // RAM�洢���
)
RAM1
(
    .CLK(CLK),                                  // ʱ������
    .RST(RST),                                  // ��λ����
    .CEN(CEN),                                  // ʱ��ʹ��
    .WEN(WEN),                                  // д��ʹ��
    .ADDR_H(ADDR_F[ADDRW + $clog2(GROUP) - 1 : $clog2(GROUP)]),   // ��ַ��λ(���)
    .ADDR_L(ADDR_F[        $clog2(GROUP) - 1 :             0]),   // ��ַ��λ(���)
    .DATA_I(DATA_I),                            // ��������
    .DATA_O(DATA1O),                            // �������
    .OVF(OVF1)                                  // ��ַ���
);


ExtendRAM #
(
    .RTYPE("TDPRAM"),                           // RAM�ڲ�ʵ������
    .ADDRW(ADDRW),                              // RAM��ַ���
    .UNITW(UNITW),                              // RAMÿ����Ԫ���
    .GROUP(GROUP),                              // RAMÿ�鵥Ԫ����
    .DEPTH(DEPTH)                               // RAM�洢���
)
RAM2
(
    .CLK(CLK),                                  // ʱ������
    .RST(RST),                                  // ��λ����
    .CEN(CEN),                                  // ʱ��ʹ��
    .WEN(WEN),                                  // д��ʹ��
    .ADDR_H(ADDR_F[ADDRW + $clog2(GROUP) - 1 : $clog2(GROUP)]),   // ��ַ��λ(���)
    .ADDR_L(ADDR_F[        $clog2(GROUP) - 1 :             0]),   // ��ַ��λ(���)
    .DATA_I(DATA_I),                            // ��������
    .DATA_O(DATA2O),                            // �������
    .OVF(OVF2)                                  // ��ַ���
);


always  #5   CLK = ~CLK;
initial #100 RST = ~RST;

integer index;
initial
begin
    // ϵͳ����
    #100 ;

    // ����д�룬�Ƕ����ȡ

    // д������
    WEN <= 4'b1111;
    // ��һ��
    ADDR_F <= 16'h0000;
    DATA_I <= 32'h04030201;
    #10 ;
    // �ڶ���
    ADDR_F <= 16'h0004;
    DATA_I <= 32'h08070605;
    #10 ;

    // ��ȡ����
    WEN <= 4'b0000;
    // �����������
    DATA_I <= 32'h00000000;
    // ����ѭ����ʼ��ַ
    ADDR_F <= 16'h0000;
    for(index = 0; index < 4'h0009; index = index + 1)
    begin
        #10 ADDR_F = ADDR_F + 1;
    end

    // �Ƕ���д�룬�����ȡ

    // д������
    // ��һ��
    WEN    <= 4'b1111;
    ADDR_F <= 16'h0009;
    DATA_I <= 32'h0C0B0A09;
    #10 ;
    // �ڶ���
    WEN    <= 4'b0011;
    ADDR_F <= 16'h000E;
    DATA_I <= 32'h100F0E0D;
    #10 ;

    // ��ȡ����
    WEN <= 4'b0000;
    // �����������
    DATA_I <= 32'h00000000;
    // ��һ��
    ADDR_F <= 16'h0008;
    #10 ;
    // �ڶ���
    ADDR_F <= 16'h000C;
    #10 ;

    $stop;
end

endmodule