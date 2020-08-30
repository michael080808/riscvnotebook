`timescale 1ns / 1ps

module LeftBarrelShifter #
(
    parameter type = 0,
    parameter width = 32
)
(
    input  wire [$clog2(width) - 1 : 0] W,
    input  wire [width         - 1 : 0] A,
    output wire [width         - 1 : 0] Y
);

generate
    if(type)
    begin
        LeftBarrelShifterB #(width) Unit (W, A, Y);
    end
    else
    begin
        LeftBarrelShifterA #(width) Unit (W, A, Y);
    end
endgenerate

endmodule