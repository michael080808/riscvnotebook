module BarrelShifterA #
(
    parameter width = 32
)
(
    input  wire LR,
    input  wire LA,
    input  wire [$clog2(width) - 1 : 0] W,
    input  wire [width         - 1 : 0] A,
    output wire [width         - 1 : 0] Y
);

wire [width - 1 : 0] Ai;
wire [width - 1 : 0] Mn;
wire [width - 1 : 0] Mi;

genvar i;

generate
    for(i = 0; i < width; i = i + 1)
    begin
        assign Ai[i] = A[width - 1 - i];
    end
endgenerate

RightBarrelShifter #(1, width) Unit (LR & LA, W, LR ? A : Ai, Mn);

generate
    for(i = 0; i < width; i = i + 1)
    begin
        assign Mi[i] = Mn[width - 1 - i];
    end
endgenerate

assign Y = LR ? Mn : Mi;

endmodule