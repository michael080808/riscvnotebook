module BarrelShifter_Testbench #(parameter WIDTH = 32)();

reg  LR = 1'b0;
reg  LA = 1'b0;
reg  [$clog2(WIDTH) - 1 : 0] W = {$clog2(WIDTH){1'b0}};
reg  [WIDTH         - 1 : 0] A = {WIDTH{1'b0}};
wire [WIDTH         - 1 : 0] Ya;
wire [WIDTH         - 1 : 0] Yb;
wire [WIDTH         - 1 : 0] Yc;

BarrelShifter #(0, WIDTH) aUnit (LR, LA, W, A, Ya);
BarrelShifter #(1, WIDTH) bUnit (LR, LA, W, A, Yb);
BarrelShifter #(2, WIDTH) cUnit (LR, LA, W, A, Yc);

always
begin
    W <= $random();
    A <= $random();
    #5 {LR, LA} = 2'b00;
    #5 {LR, LA} = 2'b01;
    #5 {LR, LA} = 2'b10;
    #5 {LR, LA} = 2'b11;
end

endmodule