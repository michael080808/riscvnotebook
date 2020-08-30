`timescale 1ns / 1ps

module RightBarrelShifter #
(
    parameter type = 1,
    parameter width = 32
)
(
    input  wire OP,
    input  wire [$clog2(width) - 1 : 0] W,
    input  wire [width         - 1 : 0] A,
    output wire [width         - 1 : 0] Y
);

generate
    if(type)
    begin
        RightBarrelShifterB #(width) Unit (OP, W, A, Y);
    end
    else
    begin
        RightBarrelShifterA #(width) Unit (OP, W, A, Y);
    end
endgenerate

endmodule