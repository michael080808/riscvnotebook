`timescale 1ns / 1ps

module IntegerALU_Testbench #(parameter width = 32)(); // �����߼���Ԫλ��

reg  [3 : 0] OP =  4'h0;    // �����߼���Ԫ������
reg  [width - 1 : 0] A;     // �����߼���Ԫ����A
reg  [width - 1 : 0] B;     // �����߼���Ԫ����B
wire [width - 1 : 0] Y;     // �����߼���Ԫ���Y
reg  [width - 1 : 0] Q;     // �����߼���Ԫ��������֤Q

// �����߼���Ԫʵ����
IntegerALU #(.width(width))
Unit
(
    .opcode(OP),
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
    4'b001x: Q <= $signed(A) <<  B[$clog2(width) - 1 : 0];
    4'b010x: Q <= {{width - 1{1'b0}}, $signed(A)   < $signed(B)};
    4'b011x: Q <= {{width - 1{1'b0}}, $unsigned(A) < $unsigned(B)};
    4'b100x: Q <= A ^ B;
    4'b1010: Q <= $signed(A) >>  B[$clog2(width) - 1 : 0];
    4'b1011: Q <= $signed(A) >>> B[$clog2(width) - 1 : 0];
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
