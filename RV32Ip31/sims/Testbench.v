`timescale 1ns / 1ps

module Testbench();

reg            clock = 1'b0;
reg            reset = 1'b1;

Top #
(
    .ILOAD("main.mem")
)
CPU
(
    .clock(clock),
    .reset(reset)
);

always  #5    clock <= ~clock;
initial #100  reset <= 1'b0;
initial #6000 $stop;
endmodule
