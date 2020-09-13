`timescale 1ns / 1ps

module RotateR_Testbench #(parameter unitw = 8, parameter group = 4)();

reg  [$clog2(group) - 1 : 0] W = 0;   // RAM��ƫ��������
reg  [unitw * group - 1 : 0] A = 0;   // RAM��ƫ����������
wire [unitw * group - 1 : 0] Y;       // RAM��ƫ�ƽ�����

RotateR #
(
    unitw,   // RAMÿ����Ԫ���
    group    // RAMÿ�鵥Ԫ����
)
rotate_r
(
    W,       // RAM��ƫ��������
    A,       // RAM��ƫ����������
    Y        // RAM��ƫ�ƽ�����
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