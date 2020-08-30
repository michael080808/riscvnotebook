`timescale 1ns / 1ps

/*
 * ʹ��ArithmeticUnit���������������߼���Ԫ
 * RISC-V������ALU��֧���쳣�����û��������ź����
 * ֧�ּ��㣺
 *      ���ͼӷ������ͼ���
 *      ��λ�߼��롢��λ�߼��򡢰�λ�߼����
 *      �߼�/�������ơ��߼����ơ���������
 *      �޷�����С�ڱȽϡ��з�����С�ڱȽ�
 * ע�⣺
 *      ����ALU֧���з������ļ��㣬
 *      ���IntegerALU����Сλ��(width)Ϊ2
 */

module IntegerALU #
(
    parameter width = 32             // �����߼���Ԫλ��
)
(
    input  wire [3 : 0] opcode,      // �����߼���Ԫ������
    input  wire [width - 1 : 0] A,   // �����߼���Ԫ����A
    input  wire [width - 1 : 0] B,   // �����߼���Ԫ����B
    output reg  [width - 1 : 0] Y    // �����߼���Ԫ���Y
);

// ��������������Ԫ����
wire [width - 1 : 0] S; // ������Ԫ(width)λ���S���
wire SF;                // ������Ԫ1λ���S����λ���
wire CF;                // ������Ԫ��������Ϊ�޷�������ʱ��1λ���S��������0δ�����1Ϊ���
wire OF;                // ������Ԫ��������Ϊ�з�������ʱ��1λ���S��������0δ�����1Ϊ���

// ������Ԫʵ����
// ע�⵽��ֻ�е�opcode[3 : 1] = 3'b000ʱ�ǼӼ�������
// ��ʹ��SLT/SLTUʱ��ֱ��ʹ�ü������бȽ�
// Ϊ�˼���ƣ�OP�����opcode[3 : 1] = 3'b000ʱ��Ϊ����
ArithmeticUnit #(.width(width))
Unit
(
    .OP(opcode[3 : 1] ? 1'b1 : opcode[0]),
    .A(A),
    .B(B),
    .Y(S),
    .SF(SF),
    .CF(CF),
    .OF(OF)
);

// ����Ͱ����λ������
wire [width - 1 : 0] H; // ������Ԫ(width)λ���S���

// Ͱ����λ��ʵ����
BarrelShifter #(.width(width))
Shifter
(
    .LR(opcode[3]),
    .LA(opcode[0]),
    .W(B[$clog2(width) - 1 : 0]),
    .A(A),
    .Y(H)
);

// ALU���㸴ѡ��Ԫ
always @(*)
begin
    case(opcode[3 : 1])
    // ADD(0) �� SUB(1)
    3'b000: Y <= S;
    // SLL
    3'b001: Y <= H;
    // SLT
    3'b010: Y <= {{width - 1{1'b0}}, OF ^ SF};
    // SLTU
    3'b011: Y <= {{width - 1{1'b0}}, CF};
    // XOR
    3'b100: Y <= A ^ B;
    // SRL(0) �� SRA(1)
    3'b101: Y <= H;
    // OR
    3'b110: Y <= A | B;
    // AND
    3'b111: Y <= A & B;
    endcase
end

endmodule
