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
    .WIDTH(WIDTH)        // 加法位数
)
Unit
(
    .CI(1'b0),           // 1位进位输入
    .A(A),               // (WIDTH)位加数A输入
    .B(B),               // (WIDTH)位加数B输入
    .S(Y),               // (WIDTH)位结果S输出
    .C(N)                // (WIDTH)位进位C输出
);

assign C = N[WIDTH - 1];

endmodule