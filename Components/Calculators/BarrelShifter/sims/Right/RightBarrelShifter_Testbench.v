module RightBarrelShifter_Testbench #(parameter WIDTH = 32)();

reg  OP = 1'b0;
reg  [$clog2(WIDTH) - 1 : 0] W = {$clog2(WIDTH){1'b0}};
reg  [WIDTH         - 1 : 0] A = {WIDTH{1'b0}};
wire [WIDTH         - 1 : 0] Ya;
wire [WIDTH         - 1 : 0] Yb;

RightBarrelShifter #(0, WIDTH) aUnit (OP, W, A, Ya);
RightBarrelShifter #(1, WIDTH) bUnit (OP, W, A, Yb);

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