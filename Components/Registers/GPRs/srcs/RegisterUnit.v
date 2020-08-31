`timescale 1ns / 1ps

/*
 * ʹ��FDRE���������ȴ���ʱ��ʹ�ܵ�ͬ����λ�Ĵ���
 *      ʱ��ʹ�����ڼĴ�����д��ʹ�ܿ��ƺ�д�븴ѡ����
 *      ͬ����λ���ڼĴ�����ʼ�������Լ�������Ĵ�����������λ(�첽����������λ)
 */

module RegisterUnit #
(
    parameter width = 32        // �Ĵ���λ��
)
(
    input  reset,               // ͬ����λ
    input  clock,               // ͬ��ʱ��
    input  enable,              // ʱ��ʹ��
    input  [width - 1 : 0] D,   // ��������
    output [width - 1 : 0] Q    // �������
);

// FDRE����ʵ����
// ����ʱ�ӡ�ͬ����λ��ʱ��ʹ��
// ����������������
genvar i;
generate
    for(i = 0; i < width; i = i + 1)
    begin
        FDRE #(.INIT(1'b0))
        FDRE_inst
        (
            .C(clock),      // ͬ��ʱ��
            .R(reset),      // ͬ����λ
            .CE(enable),    // ʱ��ʹ��
            .D(D[i]),       // ��������
            .Q(Q[i])        // �������
        );
    end
endgenerate

endmodule
