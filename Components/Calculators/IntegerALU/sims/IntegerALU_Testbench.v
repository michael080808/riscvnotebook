`timescale 1ns / 1ps

module IntegerALU_Testbench #(parameter WIDTH = 32)(); // 算术逻辑单元位数

reg  [3 : 0] OP =  4'h0;    // 算术逻辑单元操作码
reg  [WIDTH - 1 : 0] A;     // 算术逻辑单元输入A
reg  [WIDTH - 1 : 0] B;     // 算术逻辑单元输入B
wire [WIDTH - 1 : 0] Y;     // 算术逻辑单元输出Y
reg  [WIDTH - 1 : 0] Q;     // 算术逻辑单元输出结果验证Q

// 算术逻辑单元实例化
IntegerALU #(.WIDTH(WIDTH))
Unit
(
    .OP(OP),
    .A(A),
    .B(B),
    .Y(Y)
);

// 每5ns算术逻辑单元操作码循环以用于测试
always #5
begin
    OP = OP + 4'h1;
end

// 每当OP为4'h0时，算术逻辑单元操作码循环完成一次，更新输入数据
always @(OP)
begin
    if(OP == 4'h0)
    begin
        A <= $random();
        B <= $random();
    end      
end

// 计算用于验证结果Y的Q值
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

// 设定测试时间为1us
initial
begin
    #1000 $stop;
end

endmodule
