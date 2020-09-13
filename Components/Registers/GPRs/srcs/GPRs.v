`timescale 1ns / 1ps

/*
 * ʹ��RegisterUnit��������������������ͨ�üĴ�����
 * ��ͨ��ZEROѡ�������׸��Ĵ����Ƿ�Ϊ��Ĵ���
 */
module GPRs #
(
    parameter ZERO = 0,                     // �����׸��Ĵ����Ƿ�Ϊ��Ĵ���������Ĵ���Ϊ0����Ĵ���Ϊ1
    parameter WIDTH = 32,                   // �����Ĵ���λ��
    parameter UNITS = 32                    // �Ĵ�������
)
(
    input  RST,                             // ͬ����λ
    input  CLK,                             // ͬ��ʱ��
    input  WEN,                             // д��ʹ��(ʱ��ʹ��)
    input  [$clog2(UNITS) - 1 : 0] DSTs,    // ��ѡĿ��Ĵ���
    input  [$clog2(UNITS) - 1 : 0] RS1s,    // ��ѡԴ�Ĵ���1
    input  [$clog2(UNITS) - 1 : 0] RS2s,    // ��ѡԴ�Ĵ���2
    input  [WIDTH - 1 : 0] DSTi,            // Ŀ��Ĵ�������д��
    output [WIDTH - 1 : 0] RS1o,            // Դ�Ĵ���1�������
    output [WIDTH - 1 : 0] RS2o             // Դ�Ĵ���2�������
);

// ���Ŀ��Ĵ���д��ʹ�ܽ��б���
// ����ӳ�䵽��Ӧ�ļĴ�����
integer index;
reg [WIDTH - 1 : 0] CLKs;
always @(*)
begin
    for(index = 0; index < WIDTH; index = index + 1)
    begin
        CLKs[index] <= (index == DSTs) ? 1'b1 : 1'b0;
    end
end

// ����ʵ�����Ĵ���RegisterUnit�����ж�Ӧ����
wire [WIDTH - 1 : 0] X [UNITS - 1 : 0];
genvar i;
generate
    for(i = 0; i < UNITS; i = i + 1)
    begin
        RegisterUnit #(.WIDTH(WIDTH))
        Unit
        (
            .RST((ZERO && !i) ? 1'b1 : RST), // �����Ĵ���������������
            .CLK(CLK),                       // ͬ��ʱ��
            .ENA(WEN & CLKs[i]),             // ��д��ʹ����ѡ���üĴ���ʱ��D������д��ʹ��
            .D(DSTi),                        // Ŀ��Ĵ�������д��
            .Q(X[i])                         // �Ĵ�������ȫ�����
        );
    end
endgenerate

// Դ�Ĵ������������ѡ��
// ����Դ�Ĵ����ı������������ݵ�ѡ��
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
