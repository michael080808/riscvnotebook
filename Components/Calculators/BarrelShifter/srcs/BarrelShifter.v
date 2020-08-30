module BarrelShifter #
(
    parameter type = 0,
    parameter width = 32
)
(
    input  wire LR,
    input  wire LA,
    input  wire [$clog2(width) - 1 : 0] W,
    input  wire [width         - 1 : 0] A,
    output wire [width         - 1 : 0] Y
);

generate
    case(type)
    0: BarrelShifterA #(width) Unit (LR, LA, W, A, Y);
    1: BarrelShifterB #(width) Unit (LR, LA, W, A, Y);
    2: BarrelShifterC #(width) Unit (LR, LA, W, A, Y);
    endcase
endgenerate

endmodule