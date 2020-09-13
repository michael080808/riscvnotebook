module BarrelShifterC #
(
    parameter WIDTH = 32
)
(
    input  wire LR,
    input  wire LA,
    input  wire [$clog2(WIDTH) - 1 : 0] W,
    input  wire [WIDTH         - 1 : 0] A,
    output wire [WIDTH         - 1 : 0] Y
);

wire [WIDTH - 1 : 0] M [$clog2(WIDTH) : 0];

genvar i;
genvar j;
generate
    for(i = 0; i < $clog2(WIDTH); i = i + 1)
    begin
        for(j = 0; j < WIDTH; j = j + 1)
        begin
            reg [WIDTH - 1 : 0] S;

            always @(*)
            begin
                casex({W[i], LR, LA})
                3'b0xx: S <= M[i][j];
                3'b10x: S <= (j - 2 ** i >= 0)     ? M[i][j - 2 ** i] : 1'b0;
                3'b110: S <= (j + 2 ** i <  WIDTH) ? M[i][j + 2 ** i] : 1'b0;
                3'b111: S <= (j + 2 ** i <  WIDTH) ? M[i][j + 2 ** i] : M[0][WIDTH - 1];
                endcase
            end

            assign M[i + 1][j] = S;
        end
    end
endgenerate

assign M[0] = A;
assign Y = M[$clog2(WIDTH)];

endmodule