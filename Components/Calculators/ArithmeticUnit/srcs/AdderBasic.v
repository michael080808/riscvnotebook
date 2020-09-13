`timescale 1ns / 1ps

/*
 * ʹ��AdderUnit����������
 * �����ȫ����λ״̬�ļӷ���
 * ȫ����λ״̬����������ж��з��������Ƿ����
 */

module AdderBasic #
(
    parameter WIDTH = 32        // �ӷ�λ��
) 
(
    input  CI,                  // 1λ��λ����
    input  [WIDTH - 1 : 0] A,   // (WIDTH)λ����A����
    input  [WIDTH - 1 : 0] B,   // (WIDTH)λ����B����
    output [WIDTH - 1 : 0] S,   // (WIDTH)λ���S���
    output [WIDTH - 1 : 0] C    // (WIDTH)λ��λC���
);

// ���ȼ���AdderUnit��Ҫ������
localparam integer UNITS = $ceil(WIDTH / 4.0);

// ������������AdderUnit���������������
wire [UNITS - 1 : 0] CIi;       // UNITS���λ����
wire [4 * UNITS - 1 : 0] Ai;    // 4 * UNITSλ(UNITS��)����A����
wire [4 * UNITS - 1 : 0] Bi;    // 4 * UNITSλ(UNITS��)����B����
wire [4 * UNITS - 1 : 0] So;    // 4 * UNITSλ(UNITS��)���S���
wire [4 * UNITS - 1 : 0] Co;    // 4 * UNITSλ(UNITS��)��λC���

// ��������i������������
genvar i;

// ��������UNITS��AdderUnit��Ԫ
generate
    for(i = 0; i < UNITS; i = i + 1)
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

// ��������AdderUnit��Ԫ��һ�����λ��λ����һ����λ���룬���һ����CI����������
generate
    for(i = 0; i < UNITS; i = i + 1)
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

// �������Ӽ���A�ͼ���B����λʹ��0��λ����֤�ӷ������ȷ
generate
    for(i = 0; i < 4 * UNITS; i = i + 1)
    begin
        assign Ai[i] = (i < WIDTH) ? A[i] : 1'b0;
        assign Bi[i] = (i < WIDTH) ? B[i] : 1'b0;
    end
endgenerate

// ���ӽ��S�ͽ�λC
assign S = So[WIDTH - 1 : 0];
assign C = Co[WIDTH - 1 : 0];

endmodule