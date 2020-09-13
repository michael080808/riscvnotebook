`timescale 1ns / 1ps

/*
 * ʹ��FDRE���������ȴ���ʱ��ʹ�ܵ�ͬ����λ�Ĵ���
 *      ʱ��ʹ�����ڼĴ�����д��ʹ�ܿ��ƺ�д�븴ѡ����
 *      ͬ����λ���ڼĴ�����ʼ�������Լ�������Ĵ�����������λ(�첽����������λ)
 */

module RegisterUnit #
(
    parameter WIDTH = 32        // �Ĵ���λ��
)
(
    input  RST,                 // ͬ����λ
    input  CLK,                 // ͬ��ʱ��
    input  ENA,                 // ʱ��ʹ��
    input  [WIDTH - 1 : 0] D,   // ��������
    output [WIDTH - 1 : 0] Q    // �������
);

// FDRE����ʵ����
// ����ʱ�ӡ�ͬ����λ��ʱ��ʹ��
// ����������������
genvar i;
generate
    for(i = 0; i < WIDTH; i = i + 1)
    begin
        FDRE #(.INIT(1'b0))
        FDRE_inst
        (
            .C(CLK),        // ͬ��ʱ��
            .R(RST),        // ͬ����λ
            .CE(ENA),       // ʱ��ʹ��
            .D(D[i]),       // ��������
            .Q(Q[i])        // �������
        );
    end
endgenerate

endmodule
