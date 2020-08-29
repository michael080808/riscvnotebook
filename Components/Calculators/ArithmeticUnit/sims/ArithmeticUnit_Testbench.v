`timescale 1ns / 1ps

module ArithmeticUnit_Testbench #(parameter width = 32)(); // ������Ԫλ��

// �������������ʹ�õļĴ�������
reg  OP = 1'b0;             // 1λ������Ԫ��������룬0Ϊ�ӷ���1Ϊ����
reg  [width - 1 : 0] A;     // (width)λ����/������A����
reg  [width - 1 : 0] B;     // (width)λ����/  ����B����
wire [width - 1 : 0] Y;     // (width)λ���Y���
wire SF;                    // 1λ���Y����λ���
wire CF;                    // ��������Ϊ�޷�������ʱ��1λ���Y��������0δ�����1Ϊ���
wire OF;                    // ��������Ϊ�з�������ʱ��1λ���Y��������0δ�����1Ϊ���

ArithmeticUnit #(.width(width))
Unit
(
    .OP(OP),
    .A(A),
    .B(B),
    .Y(Y),
    .SF(SF),
    .CF(CF),
    .OF(OF)
);

// ÿ10ns����һ���������, �ֱ�Լӷ��ͼ�����������˹�����
always
begin
    A <= $random();
    B <= $random();

    #5 OP <= 1'b1;
    #5 OP <= 1'b0;
end

// �趨����ʱ��Ϊ10ms
initial
begin
    #10000000 $stop;
end

endmodule
