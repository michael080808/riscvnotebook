`timescale 1ns / 1ps

/*
 * 使用AdderUnit构建任意宽度
 * 可输出全部进位状态的加法器
 * 全部进位状态输出有助于判断有符号整数是否溢出
 */

module AdderBasic #
(
    parameter width = 32        // 加法位数
) 
(
    input  CI,                  // 1位进位输入
    input  [width - 1 : 0] A,   // (width)位加数A输入
    input  [width - 1 : 0] B,   // (width)位加数B输入
    output [width - 1 : 0] S,   // (width)位结果S输出
    output [width - 1 : 0] C    // (width)位进位C输出
);

// 首先计算AdderUnit需要的数量
localparam integer units = $ceil(width / 4);

// 批量创建各个AdderUnit所需的输入和输出线
wire [units - 1 : 0] CIi;       // units组进位输入
wire [4 * units - 1 : 0] Ai;    // 4 * units位(units组)加数A输入
wire [4 * units - 1 : 0] Bi;    // 4 * units位(units组)加数B输入
wire [4 * units - 1 : 0] So;    // 4 * units位(units组)结果S输出
wire [4 * units - 1 : 0] Co;    // 4 * units位(units组)进位C输出

// 创建变量i用于批量生成
genvar i;

// 批量生成units组AdderUnit单元
generate
    for(i = 0; i < units; i = i + 1)
    begin
        AdderUnit Unit
        (
            .CI(CIi[i]),
            .A(Ai[i * 4 + 3 : i * 4]),
            .B(Bi[i * 4 + 3 : i * 4]),
            .S(So[i * 4 + 3 : i * 4]),
            .C(Co[i * 4 + 3 : i * 4])
        );
    end
endgenerate

// 批量级联AdderUnit单元上一级最高位进位和下一级进位输入，最低一级与CI输入相连接
generate
    for(i = 0; i < units; i = i + 1)
    begin
        if(i != 0) 
        begin
            assign CIi[i] = Co[4 * i - 1];
        end
        else
        begin
            assign CIi[i] = CI;
        end
    end
endgenerate

// 批量连接加数A和加数B，高位使用0补位，保证加法结果正确
generate
    for(i = 0; i < 4 * units; i = i + 1)
    begin
        assign Ai[i] = (i < width) ? A[i] : 1'b0;
        assign Bi[i] = (i < width) ? B[i] : 1'b0;
    end
endgenerate

// 连接结果S和进位C
assign S = So[width - 1 : 0];
assign C = Co[width - 1 : 0];

endmodule