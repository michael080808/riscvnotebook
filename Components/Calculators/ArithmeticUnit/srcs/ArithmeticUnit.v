`timescale 1ns / 1ps

/*
 * 使用AdderBasic构建任意宽度算术单元
 * 支持计算加法、减法，将数据同时当作有符号数和无符号数，对溢出进行判断
 */

module ArithmeticUnit #
(
    parameter WIDTH = 32        // 算术单元位数
)
(
    input  OP,                  // 1位算术单元运算符输入，0为加法，1为减法
    input  [WIDTH - 1 : 0] A,   // (WIDTH)位加数/被减数A输入
    input  [WIDTH - 1 : 0] B,   // (WIDTH)位加数/  减数B输入
    output [WIDTH - 1 : 0] Y,   // (WIDTH)位结果Y输出
    output SF,                  // 1位结果Y符号位输出
    output CF,                  // 当数据作为无符号数据时，1位结果Y溢出输出，0未溢出，1为溢出
    output OF                   // 当数据作为有符号数据时，1位结果Y溢出输出，0未溢出，1为溢出
);

// 创建AdderBasic所需的进位输出线
wire [WIDTH - 1 : 0] C;

// 生成用于计算的AdderBasic单元
// 注意计算减法时相当于被减数与减数的补码相加
// 而减数的补码又等同于减数取反再加一
// 因此减法时(OP = 1)，B输入需要取反，而CI输入需要取1
AdderBasic #(.WIDTH(WIDTH))
Unit
(
    .CI(OP),
    .A(A),
    .B(OP ? ~B : B),
    .S(Y),
    .C(C)
);

// 符号位即输出结果的最高位
assign SF = Y[WIDTH - 1];
// 无符号数加法时，产生进位即溢出
// 无符号数减法时，产生退位即溢出(即转换成加法后不产生进位)
// 汇总可得符号位和最高位进位异或结果即为无符号数溢出状态
assign CF = OP ^ C[WIDTH - 1];
// Cs表示符号位的进位，Cp表示最高数值位进位，⊕表示异或
// 若Cs⊕Cp = 0无溢出，若Cs⊕Cp = 1有溢出
// 汇总可得最高位进位和次高位进位异或结果即为有符号数溢出状态，与符号位无关
assign OF = C[WIDTH - 1] ^ C[WIDTH - 2];

endmodule
