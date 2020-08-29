`timescale 1ns / 1ps

module ArithmeticUnit_Testbench #(parameter width = 32)(); // 算术单元位数

// 设置输入输出所使用的寄存器和线
reg  OP = 1'b0;             // 1位算术单元运算符输入，0为加法，1为减法
reg  [width - 1 : 0] A;     // (width)位加数/被减数A输入
reg  [width - 1 : 0] B;     // (width)位加数/  减数B输入
wire [width - 1 : 0] Y;     // (width)位结果Y输出
wire SF;                    // 1位结果Y符号位输出
wire CF;                    // 当数据作为无符号数据时，1位结果Y溢出输出，0未溢出，1为溢出
wire OF;                    // 当数据作为有符号数据时，1位结果Y溢出输出，0未溢出，1为溢出

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

// 每10ns生成一组测试数据, 分别对加法和减法结果进行人工检验
always
begin
    A <= $random();
    B <= $random();

    #5 OP <= 1'b1;
    #5 OP <= 1'b0;
end

// 设定测试时间为10ms
initial
begin
    #10000000 $stop;
end

endmodule
