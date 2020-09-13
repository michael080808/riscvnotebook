`timescale 1ns / 1ps

module IntegerALU_Testbench #(parameter WIDTH = 32)(); // �����߼���Ԫλ��

reg  [3 : 0] OP =  4'h0;    // �����߼���Ԫ������
reg  [WIDTH - 1 : 0] A;     // �����߼���Ԫ����A
reg  [WIDTH - 1 : 0] B;     // �����߼���Ԫ����B
wire [WIDTH - 1 : 0] Y;     // �����߼���Ԫ���Y
reg  [WIDTH - 1 : 0] Q;     // �����߼���Ԫ��������֤Q

// �����߼���Ԫʵ����
IntegerALU #(.WIDTH(WIDTH))
Unit
(
    .OP(OP),
    .A(A),
    .B(B),
    .Y(Y)
);

// ÿ5ns�����߼���Ԫ������ѭ�������ڲ���
always #5
begin
    OP = OP + 4'h1;
end

// ÿ��OPΪ4'h0ʱ�������߼���Ԫ������ѭ�����һ�Σ�������������
always @(OP)
begin
    if(OP == 4'h0)
    begin
        A <= $random();
        B <= $random();
    end      
end

// ����������֤���Y��Qֵ
always @(*)
begin
    casex(OP)
    4'b0000: Q <= A + B;
    4'b0001: Q <= A - B;
    4'b001x: Q <= $signed(A) <<  B[$clog2(WIDTH) - 1 : 0];
    4'b010x: Q <= {{WIDTH - 1{1'b0}}, $signed(A)   < $signed(B)};
    4'b011x: Q <= {{WIDTH - 1{1'b0}}, $unsigned(A) < $unsigned(B)};
    4'b100x: Q <= A ^ B;
    4'b1010: Q <= $signed(A) >>  B[$clog2(WIDTH) - 1 : 0];
    4'b1011: Q <= $signed(A) >>> B[$clog2(WIDTH) - 1 : 0];
    4'b110x: Q <= A | B;
    4'b111x: Q <= A & B;
    endcase    
end

// �趨����ʱ��Ϊ1us
initial
begin
    #1000 $stop;
end

endmodule
