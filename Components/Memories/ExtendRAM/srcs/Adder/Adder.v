`timescale 1ns / 1ps

module Adder #
(
    parameter WIDTH = 32
)
(
    input  [WIDTH - 1 : 0] A,
    input  [WIDTH - 1 : 0] B,
    output [WIDTH - 1 : 0] Y,
    output C
);

wire [WIDTH - 1 : 0] N;

AdderBasic #
(
    .WIDTH(WIDTH)        // �ӷ�λ��
)
Unit
(
    .CI(1'b0),           // 1λ��λ����
    .A(A),               // (WIDTH)λ����A����
    .B(B),               // (WIDTH)λ����B����
    .S(Y),               // (WIDTH)λ���S���
    .C(N)                // (WIDTH)λ��λC���
);

assign C = N[WIDTH - 1];

endmodule