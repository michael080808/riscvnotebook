`timescale 1ns / 1ps

module RightBarrelShifter #
(
    parameter TYPE = 1,
    parameter WIDTH = 32
)
(
    input  wire OP,
    input  wire [$clog2(WIDTH) - 1 : 0] W,
    input  wire [WIDTH         - 1 : 0] A,
    output wire [WIDTH         - 1 : 0] Y
);

generate
    if(TYPE)
    begin
        RightBarrelShifterB #(WIDTH) Unit (OP, W, A, Y);
    end
    else
    begin
        RightBarrelShifterA #(WIDTH) Unit (OP, W, A, Y);
    end
endgenerate

endmodule