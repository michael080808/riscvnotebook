`timescale 1ns / 1ps

/*
 * 将CARRY4和LUT进行组合形成4位加法器
 */

module AdderUnit
(
    input  CI,              // 1位进位输入
    input  [3 : 0] A,       // 4位加数A输入
    input  [3 : 0] B,       // 4位加数B输入
    output [3 : 0] S,       // 4位结果S输出
    output [3 : 0] C        // 4位进位C输出
);

CARRY4 CARRY4_inst 
(
    .CO(C),                 // 4位进位输出
    .O(S[3 : 0]),           // 4位结果输出
    .CI(CI),                // 1位进位输入
    .CYINIT(1'b0),          // 1位进位初始化，配置从CI输入数据
    .DI(A[3 : 0]),          // 4位进位-复选器数据输入，接数据A
    .S(A[3 : 0] ^ B[3 : 0]) // 4位进位-复选器选择输入，接数据A和B的异或
);
          
endmodule
