module RightBarrelShifterB #
(
    parameter WIDTH = 32
)
(
    input  wire OP,
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
            if(j + 2 ** i < WIDTH)
            begin
                assign M[i + 1][j] = W[i] ? M[i][j + 2 ** i] : M[i][j];
            end
            else
            begin
                assign M[i + 1][j] = W[i] ? (OP ? M[0][WIDTH - 1] : 1'b0) : M[i][j];
            end
        end
    end
endgenerate

assign M[0] = A;
assign Y = M[$clog2(WIDTH)];

endmodule