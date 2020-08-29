`timescale 1ns / 1ps

/*
 * ��CARRY4��LUT��������γ�4λ�ӷ���
 */

module AdderUnit
(
    input  CI,              // 1λ��λ����
    input  [3 : 0] A,       // 4λ����A����
    input  [3 : 0] B,       // 4λ����B����
    output [3 : 0] S,       // 4λ���S���
    output [3 : 0] C        // 4λ��λC���
);

CARRY4 CARRY4_inst 
(
    .CO(C),                 // 4λ��λ���
    .O(S[3 : 0]),           // 4λ������
    .CI(CI),                // 1λ��λ����
    .CYINIT(1'b0),          // 1λ��λ��ʼ�������ô�CI��������
    .DI(A[3 : 0]),          // 4λ��λ-��ѡ���������룬������A
    .S(A[3 : 0] ^ B[3 : 0]) // 4λ��λ-��ѡ��ѡ�����룬������A��B�����
);
          
endmodule
