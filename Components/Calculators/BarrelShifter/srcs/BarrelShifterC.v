module BarrelShifterC #
(
    parameter width = 32
)
(
    input  wire LR,
    input  wire LA,
    input  wire [$clog2(width) - 1 : 0] W,
    input  wire [width         - 1 : 0] A,
    output wire [width         - 1 : 0] Y
);

wire [width - 1 : 0] M [$clog2(width) : 0];

genvar i;
genvar j;
generate
    for(i = 0; i < $clog2(width); i = i + 1)
    begin
        for(j = 0; j < width; j = j + 1)
        begin
            reg [width - 1 : 0] S;

            always @(*)
            begin
                casex({W[i], LR, LA})
                3'b0xx: S <= M[i][j];
                3'b10x: S <= (j - 2 ** i >= 0)     ? M[i][j - 2 ** i] : 1'b0;
                3'b110: S <= (j + 2 ** i <  width) ? M[i][j + 2 ** i] : 1'b0;
                3'b111: S <= (j + 2 ** i <  width) ? M[i][j + 2 ** i] : M[0][width - 1];
                endcase
            end

            assign M[i + 1][j] = S;
        end
    end
endgenerate

assign M[0] = A;
assign Y = M[$clog2(width)];

endmodule