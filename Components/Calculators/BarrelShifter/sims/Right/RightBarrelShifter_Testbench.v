module RightBarrelShifter_Testbench #(parameter width = 32)();

reg  OP = 1'b0;
reg  [$clog2(width) - 1 : 0] W = {$clog2(width){1'b0}};
reg  [width         - 1 : 0] A = {width{1'b0}};
wire [width         - 1 : 0] Ya;
wire [width         - 1 : 0] Yb;

RightBarrelShifter #(0, width) aUnit (OP, W, A, Ya);
RightBarrelShifter #(1, width) bUnit (OP, W, A, Yb);

always
begin
    #5 OP = ~OP;
    #5
    begin
        OP <= ~OP;
        W <= $random();
        A <= $random();
    end
end

endmodule