`timescale 1ns / 1ps

module LeftBarrelShifter #
(
    parameter TYPE = 0,
    parameter WIDTH = 32
)
(
    input  wire [$clog2(WIDTH) - 1 : 0] W,
    input  wire [WIDTH         - 1 : 0] A,
    output wire [WIDTH         - 1 : 0] Y
);

generate
    if(TYPE)
    begin
        LeftBarrelShifterB #(WIDTH) Unit (W, A, Y);
    end
    else
    begin
        LeftBarrelShifterA #(WIDTH) Unit (W, A, Y);
    end
endgenerate

endmodule