module RightBarrelShifterA #
(
    parameter WIDTH = 32
)
(
    input  wire OP,
    input  wire [$clog2(WIDTH) - 1 : 0] W,
    input  wire [WIDTH         - 1 : 0] A,
    output reg  [WIDTH         - 1 : 0] Y
);

always @(*)
begin
    Y <= OP ? ($signed(A) >>> W) : ($signed(A) >> W);
end

endmodule