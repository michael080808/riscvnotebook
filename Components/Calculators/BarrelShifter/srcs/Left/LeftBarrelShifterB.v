module LeftBarrelShifterB #
(
    parameter width = 32
)
(
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
            if(j - 2 ** i >= 0)
            begin
                assign M[i + 1][j] = W[i] ? M[i][j - 2 ** i] : M[i][j];
            end
            else
            begin
                assign M[i + 1][j] = W[i] ? 1'b0 : M[i][j];
            end
        end
    end
endgenerate

assign M[0] = A;
assign Y = M[$clog2(width)];

endmodule