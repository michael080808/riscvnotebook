module LeftBarrelShifter_Testbench #(parameter WIDTH = 32)();

reg  [$clog2(WIDTH) - 1 : 0] W = {$clog2(WIDTH){1'b0}};
reg  [WIDTH         - 1 : 0] A = {WIDTH{1'b0}};
wire [WIDTH         - 1 : 0] Ya;
wire [WIDTH         - 1 : 0] Yb;

LeftBarrelShifter #(0, WIDTH) aUnit (W, A, Ya);
LeftBarrelShifter #(1, WIDTH) bUnit (W, A, Yb);

always
begin
    #5
    begin
        W <= $random();
        A <= $random();
    end
end

endmodule