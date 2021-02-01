`timescale 1ns / 1ps

module Testbench();

reg clock = 1'b0;
reg reset = 1'b1;
wire [31 : 0] instruction;

Top #
(
    .ILOAD("main.mem")
)
CPU
(
    .clock(clock),
    .reset(reset),
    .instruction(instruction)
);

always #5 clock <= ~clock;

initial 
begin
    #10 reset <= 1'b0;
end

endmodule
