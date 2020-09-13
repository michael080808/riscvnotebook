`timescale 1ns / 1ps

/*
 * 使用ArithmeticUnit构建任意宽度算术逻辑单元
 * RISC-V的整型ALU不支持异常，因此没有溢出等信号输出
 * 支持计算：
 *      整型加法、整型减法
 *      按位逻辑与、按位逻辑或、按位逻辑异或
 *      逻辑/算术左移、逻辑右移、算术右移
 *      无符号数小于比较、有符号数小于比较
 * 注意：
 *      由于ALU支持有符号数的计算，
 *      因此IntegerALU的最小位宽(WIDTH)为2
 */

module IntegerALU #
(
    parameter WIDTH = 32             // 算术逻辑单元位数
)
(
    input  wire [3 : 0] OP,          // 算术逻辑单元操作码
    input  wire [WIDTH - 1 : 0] A,   // 算术逻辑单元输入A
    input  wire [WIDTH - 1 : 0] B,   // 算术逻辑单元输入B
    output reg  [WIDTH - 1 : 0] Y    // 算术逻辑单元输出Y
);

// 用于连接算术单元的线
wire [WIDTH - 1 : 0] S; // 算术单元(WIDTH)位结果S输出
wire SF;                // 算术单元1位结果S符号位输出
wire CF;                // 算术单元当数据作为无符号数据时，1位结果S溢出输出，0未溢出，1为溢出
wire OF;                // 算术单元当数据作为有符号数据时，1位结果S溢出输出，0未溢出，1为溢出

// 算术单元实例化
// 注意到，只有当OP[3 : 1] = 3'b000时是加减法计算
// 而使用SLT/SLTU时，直接使用减法进行比较
// 为了简化设计，OP输入除OP[3 : 1] = 3'b000时均为减法
ArithmeticUnit #(.WIDTH(WIDTH))
Unit
(
    .OP(OP[3 : 1] ? 1'b1 : OP[0]),
    .A(A),
    .B(B),
    .Y(S),
    .SF(SF),
    .CF(CF),
    .OF(OF)
);

// 用于桶形移位器的线
wire [WIDTH - 1 : 0] H; // 算术单元(WIDTH)位结果S输出

// 桶形移位器实例化
BarrelShifter #(.WIDTH(WIDTH))
Shifter
(
    .LR(OP[3]),
    .LA(OP[0]),
    .W(B[$clog2(WIDTH) - 1 : 0]),
    .A(A),
    .Y(H)
);

// ALU计算复选单元
always @(*)
begin
    case(OP[3 : 1])
    // ADD(0) 和 SUB(1)
    3'b000: Y <= S;
    // SLL
    3'b001: Y <= H;
    // SLT
    3'b010: Y <= {{WIDTH - 1{1'b0}}, OF ^ SF};
    // SLTU
    3'b011: Y <= {{WIDTH - 1{1'b0}}, CF};
    // XOR
    3'b100: Y <= A ^ B;
    // SRL(0) 和 SRA(1)
    3'b101: Y <= H;
    // OR
    3'b110: Y <= A | B;
    // AND
    3'b111: Y <= A & B;
    endcase
end

endmodule
