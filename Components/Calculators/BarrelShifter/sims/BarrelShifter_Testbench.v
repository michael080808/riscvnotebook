module BarrelShifter_Testbench #(parameter width = 32)();

reg  LR = 1'b0;
reg  LA = 1'b0;
reg  [$clog2(width) - 1 : 0] W = {$clog2(width){1'b0}};
reg  [width         - 1 : 0] A = {width{1'b0}};
wire [width         - 1 : 0] Ya;
wire [width         - 1 : 0] Yb;
wire [width         - 1 : 0] Yc;

BarrelShifter #(0, width) aUnit (LR, LA, W, A, Ya);
BarrelShifter #(1, width) bUnit (LR, LA, W, A, Yb);
BarrelShifter #(2, width) cUnit (LR, LA, W, A, Yc);

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