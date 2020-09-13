module BarrelShifterA #
(
    parameter WIDTH = 32
)
(
    input  wire LR,
    input  wire LA,
    input  wire [$clog2(WIDTH) - 1 : 0] W,
    input  wire [WIDTH         - 1 : 0] A,
    output wire [WIDTH         - 1 : 0] Y
);

wire [WIDTH - 1 : 0] Ai;
wire [WIDTH - 1 : 0] Mn;
wire [WIDTH - 1 : 0] Mi;

genvar i;

generate
    for(i = 0; i < WIDTH; i = i + 1)
    begin
        assign Ai[i] = A[WIDTH - 1 - i];
    end
endgenerate

RightBarrelShifter #(1, WIDTH) Unit (LR & LA, W, LR ? A : Ai, Mn);

generate
    for(i = 0; i < WIDTH; i = i + 1)
    begin
        assign Mi[i] = Mn[WIDTH - 1 - i];
    end
endgenerate

assign Y = LR ? Mn : Mi;

endmodule