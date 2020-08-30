module LeftBarrelShifterA #
(
    parameter width = 32
)
(
    input  wire [$clog2(width) - 1 : 0] W,
    input  wire [width         - 1 : 0] A,
    output reg  [width         - 1 : 0] Y
);

always @(*)
begin
    Y <= $signed(A) << W;
end

endmodule