module BarrelShifterB #
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

wire [WIDTH - 1 : 0] Yl;
wire [WIDTH - 1 : 0] Yr;

LeftBarrelShifter  #(0, WIDTH) UnitL     (W, A, Yl);
RightBarrelShifter #(1, WIDTH) UnitR (LA, W, A, Yr);

assign Y = LR ? Yr : Yl;

endmodule