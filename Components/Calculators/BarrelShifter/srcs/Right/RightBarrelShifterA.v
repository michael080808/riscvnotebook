module RightBarrelShifterA #
(
    parameter width = 32
)
(
    input  wire OP,
    input  wire [$clog2(width) - 1 : 0] W,
    input  wire [width         - 1 : 0] A,
    output reg  [width         - 1 : 0] Y
);

always @(*)
begin
    Y <= OP ? ($signed(A) >>> W) : ($signed(A) >> W);
end

endmodule