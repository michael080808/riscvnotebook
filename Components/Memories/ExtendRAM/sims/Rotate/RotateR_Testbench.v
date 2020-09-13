`timescale 1ns / 1ps

module RotateR_Testbench #(parameter unitw = 8, parameter group = 4)();

reg  [$clog2(group) - 1 : 0] W = 0;   // RAM内偏移量输入
reg  [unitw * group - 1 : 0] A = 0;   // RAM内偏移内容输入
wire [unitw * group - 1 : 0] Y;       // RAM内偏移结果输出

RotateR #
(
    unitw,   // RAM每个单元宽度
    group    // RAM每组单元数量
)
rotate_r
(
    W,       // RAM内偏移量输入
    A,       // RAM内偏移内容输入
    Y        // RAM内偏移结果输出
);

always @(*)
begin
    if(W == 0)
    begin
        A <= $random();
    end
end

always #10 W = W + 1;

initial #1000 $stop;

endmodule