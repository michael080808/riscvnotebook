`timescale 1ns / 1ps

// ZERO  : �׸��Ĵ����Ƿ�Ϊ��Ĵ���
// WIDTH : �Ĵ���λ��
// UNITS : �Ĵ�������
module GPRs_Testbench #(parameter ZERO = 0, parameter WIDTH = 32, parameter UNITS = 32)();

// ͬ����λ
reg RST = 1'b1;
// ͬ��ʱ��
reg CLK = 1'b0;
// д��ʹ��(ʱ��ʹ��)
reg WEN = 1'b1;

// ��ѡĿ��Ĵ���
reg [$clog2(UNITS) - 1 : 0] DSTs;
// ��ѡԴ�Ĵ���1
reg [$clog2(UNITS) - 1 : 0] RS1s;
// ��ѡԴ�Ĵ���2
reg [$clog2(UNITS) - 1 : 0] RS2s;

// Ŀ��Ĵ�����������
reg  [WIDTH - 1 : 0] DSTi;
// Դ�Ĵ���1�������
wire [WIDTH - 1 : 0] RS1o;
// Դ�Ĵ���2�������
wire [WIDTH - 1 : 0] RS2o;

// ʵ����ͨ�üĴ�����
GPRs #(.ZERO(ZERO), .UNITS(UNITS), .WIDTH(WIDTH))
Unit
(
    .RST(RST),   // ͬ����λ
    .CLK(CLK),   // ͬ��ʱ��
    .WEN(WEN),   // д��ʹ��(ʱ��ʹ��)
    .DSTs(DSTs), // ��ѡĿ��Ĵ���
    .RS1s(RS1s), // ��ѡԴ�Ĵ���1
    .RS2s(RS2s), // ��ѡԴ�Ĵ���2
    .DSTi(DSTi), // Ŀ��Ĵ�������д��
    .RS1o(RS1o), // Դ�Ĵ���1�������
    .RS2o(RS2o)  // Դ�Ĵ���2�������
);

// ��ʼ��100MHzʱ��
always  #5   CLK = ~CLK;
// 100ns֮��λ������ע��˴�����FPGA�ĳ�ʼ������˸�λʱ��Ҫ���ڵ���100ns
initial #100 RST = ~RST;

integer i, j;
initial
begin
    #100 ;                                  // ��100ns֮��ʼ��ͨ�üĴ�������
    for(i = 0; i < UNITS; i = i + 1)        // ����ÿ���Ĵ�������һ�θ�ֵ
    begin
        DSTs <= i;                          // ��Ŀ��Ĵ������и�ѡ
        DSTi <= $random();                  // ��Ŀ��Ĵ��������������
        for(j = 0; j < UNITS; j = j + 1)    // ��ֵ����ÿ���Ĵ����ڴ洢������
        begin
            RS1s <= j;                      // Դ�Ĵ���1�����������
            RS2s <= UNITS - 1 - j;          // Դ�Ĵ���2�����������
            #10 ;                           // ÿ�����Ϊһ��ʱ������
        end
    end
    
    // �ԼĴ��������㸴λ��ע��˴���λ����һ��ʱ������(����һ��������)����
    #000 RST = ~RST;                        // �ԼĴ����鿪ʼ��λ
    #100 RST = ~RST;                        // �ԼĴ����������λ

    // �����Ĵ��������������������Ĵ�����д����
    if(ZERO)
    begin
        DSTs <= 0;                          // ��ѡ��Ĵ���
        DSTi <= $random();                  // ����Ĵ��������������
        for(j = 0; j < UNITS; j = j + 1)
        begin
            RS1s <= j;                      // Դ�Ĵ���1�����������
            RS2s <= UNITS - 1 - j;          // Դ�Ĵ���2�����������
            #10 ;                           // ÿ�����Ϊһ��ʱ������
        end 
    end
    
    // ��д��ʹ��(ʱ��ʹ��)���ܽ��м��
    for(i = 0; i < UNITS; i = i + 1)
    begin
        DSTs <= i;                          // ��Ŀ��Ĵ������и�ѡ
        DSTi <= $random();                  // ��Ŀ��Ĵ��������������
        WEN <= ~WEN;                        // �ı䵱ǰд��ʹ��(ʱ��ʹ��)״̬
        for(j = 0; j < UNITS; j = j + 1)
        begin
            RS1s <= j;                      // Դ�Ĵ���1�����������
            RS2s <= UNITS - 1 - j;          // Դ�Ĵ���2�����������
            #10 ;                           // ÿ�����Ϊһ��ʱ������
        end
    end

    // ��ɼ�飬ֹͣ����
    $stop;
end

endmodule
