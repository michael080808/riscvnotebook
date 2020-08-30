module LeftBarrelShifter_Testbench #(parameter width = 32)();

reg  [$clog2(width) - 1 : 0] W = {$clog2(width){1'b0}};
reg  [width         - 1 : 0] A = {width{1'b0}};
wire [width         - 1 : 0] Ya;
wire [width         - 1 : 0] Yb;

LeftBarrelShifter #(0, width) aUnit (W, A, Ya);
LeftBarrelShifter #(1, width) bUnit (W, A, Yb);

always
begin
    #5
    begin
        W <= $random();
        A <= $random();
    end
end

endmodule