module BarrelShifter #
(
    parameter TYPE = 0,
    parameter WIDTH = 32
)
(
    input  wire LR,
    input  wire LA,
    input  wire [$clog2(WIDTH) - 1 : 0] W,
    input  wire [WIDTH         - 1 : 0] A,
    output wire [WIDTH         - 1 : 0] Y
);

generate
    case(TYPE)
    0: BarrelShifterA #(WIDTH) Unit (LR, LA, W, A, Y);
    1: BarrelShifterB #(WIDTH) Unit (LR, LA, W, A, Y);
    2: BarrelShifterC #(WIDTH) Unit (LR, LA, W, A, Y);
    endcase
endgenerate

endmodule