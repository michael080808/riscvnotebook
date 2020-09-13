module LeftBarrelShifterA #
(
    parameter WIDTH = 32
)
(
    input  wire [$clog2(WIDTH) - 1 : 0] W,
    input  wire [WIDTH         - 1 : 0] A,
    output reg  [WIDTH         - 1 : 0] Y
);

always @(*)
begin
    Y <= $signed(A) << W;
end

endmodule