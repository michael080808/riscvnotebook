`timescale 1ns / 1ps

/*
 * ʹ��AdderUnit����������
 * �����ȫ����λ״̬�ļӷ���
 * ȫ����λ״̬����������ж��з��������Ƿ����
 */

module AdderBasic #
(
    parameter width = 32        // �ӷ�λ��
) 
(
    input  CI,                  // 1λ��λ����
    input  [width - 1 : 0] A,   // (width)λ����A����
    input  [width - 1 : 0] B,   // (width)λ����B����
    output [width - 1 : 0] S,   // (width)λ���S���
    output [width - 1 : 0] C    // (width)λ��λC���
);

// ���ȼ���AdderUnit��Ҫ������
localparam integer units = $ceil(width / 4);

// ������������AdderUnit���������������
wire [units - 1 : 0] CIi;       // units���λ����
wire [4 * units - 1 : 0] Ai;    // 4 * unitsλ(units��)����A����
wire [4 * units - 1 : 0] Bi;    // 4 * unitsλ(units��)����B����
wire [4 * units - 1 : 0] So;    // 4 * unitsλ(units��)���S���
wire [4 * units - 1 : 0] Co;    // 4 * unitsλ(units��)��λC���

// ��������i������������
genvar i;

// ��������units��AdderUnit��Ԫ
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

// ��������AdderUnit��Ԫ��һ�����λ��λ����һ����λ���룬���һ����CI����������
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

// �������Ӽ���A�ͼ���B����λʹ��0��λ����֤�ӷ������ȷ
generate
    for(i = 0; i < 4 * units; i = i + 1)
    begin
        assign Ai[i] = (i < width) ? A[i] : 1'b0;
        assign Bi[i] = (i < width) ? B[i] : 1'b0;
    end
endgenerate

// ���ӽ��S�ͽ�λC
assign S = So[width - 1 : 0];
assign C = Co[width - 1 : 0];

endmodule