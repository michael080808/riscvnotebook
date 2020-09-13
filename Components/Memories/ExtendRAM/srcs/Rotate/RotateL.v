`timescale 1ns / 1ps

module RotateL #
(
    parameter UNITW = 8,                    // RAMÿ����Ԫ����
    parameter GROUP = 4                     // RAMÿ�鵥Ԫ����
)
(
    input  [$clog2(GROUP) - 1 : 0] W,       // RAM��ƫ��������
    input  [UNITW * GROUP - 1 : 0] A,       // RAM��ƫ����������
    output [UNITW * GROUP - 1 : 0] Y        // RAM��ƫ�ƽ�����
);

wire [UNITW * GROUP - 1 : 0] M [$clog2(GROUP) : 0];

genvar i, j;
generate
    for(i = 0; i < $clog2(GROUP); i = i + 1)
    begin
        for(j = 0; j < UNITW * GROUP; j = j + 1)
        begin
            if(j - (2 ** i) * UNITW >= 0)
            begin
                assign M[i + 1][j] = W[i] ? M[i][j -         (2 ** i) * UNITW] : M[i][j];
            end
            else
            begin
                assign M[i + 1][j] = W[i] ? M[i][j + (GROUP - 2 ** i) * UNITW] : M[i][j];
            end
        end
    end
endgenerate

assign M[0] = A;
assign Y = M[$clog2(GROUP)];

endmodule