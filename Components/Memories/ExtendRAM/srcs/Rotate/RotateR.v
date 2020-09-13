`timescale 1ns / 1ps

module RotateR #
(
    parameter UNITW = 8,                    // RAM每个单元宽度
    parameter GROUP = 4                     // RAM每组单元数量
)
(
    input  [$clog2(GROUP) - 1 : 0] W,       // RAM内偏移量输入
    input  [UNITW * GROUP - 1 : 0] A,       // RAM内偏移内容输�?
    output [UNITW * GROUP - 1 : 0] Y        // RAM内偏移结果输�?
);

wire [UNITW * GROUP - 1 : 0] M [$clog2(GROUP) : 0];

genvar i, j;
generate
    for(i = 0; i < $clog2(GROUP); i = i + 1)
    begin
        for(j = 0; j < UNITW * GROUP; j = j + 1)
        begin
            if(j + (2 ** i) * UNITW < UNITW * GROUP)
            begin
                assign M[i + 1][j] = W[i] ? M[i][j +         (2 ** i) * UNITW] : M[i][j];
            end
            else
            begin
                assign M[i + 1][j] = W[i] ? M[i][j + (2 ** i - GROUP) * UNITW] : M[i][j];
            end
        end
    end
endgenerate

assign M[0] = A;
assign Y = M[$clog2(GROUP)];

endmodule