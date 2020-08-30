module BarrelShifterB #
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

wire [width - 1 : 0] Yl;
wire [width - 1 : 0] Yr;

LeftBarrelShifter  #(0, width) UnitL     (W, A, Yl);
RightBarrelShifter #(1, width) UnitR (LA, W, A, Yr);

assign Y = LR ? Yr : Yl;

endmodule