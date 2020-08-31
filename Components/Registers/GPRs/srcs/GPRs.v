`timescale 1ns / 1ps

/*
 * ʹ��RegisterUnit��������������������ͨ�üĴ�����
 * ��ͨ��zeroѡ�������׸��Ĵ����Ƿ�Ϊ��Ĵ���
 */
module GPRs #
(
    parameter zero = 0,         // �����׸��Ĵ����Ƿ�Ϊ��Ĵ���������Ĵ���Ϊ0����Ĵ���Ϊ1
    parameter width = 32,       // �����Ĵ���λ��
    parameter registers = 32    // �Ĵ�������
)
(
    input  reset,                           // ͬ����λ
    input  clock,                           // ͬ��ʱ��
    input  write,                           // д��ʹ��(ʱ��ʹ��)
    input  [$clog2(registers) - 1 : 0] dst, // ��ѡĿ��Ĵ���
    input  [$clog2(registers) - 1 : 0] rs1, // ��ѡԴ�Ĵ���1
    input  [$clog2(registers) - 1 : 0] rs2, // ��ѡԴ�Ĵ���2
    input  [width - 1 : 0] dst_i,           // Ŀ��Ĵ�������д��
    output [width - 1 : 0] rs1_o,           // Դ�Ĵ���1�������
    output [width - 1 : 0] rs2_o            // Դ�Ĵ���2�������
);

// ���Ŀ��Ĵ���д��ʹ�ܽ��б���
// ����ӳ�䵽��Ӧ�ļĴ�����
integer index;
reg [width - 1 : 0] clock_select;
always @(*)
begin
    for(index = 0; index < width; index = index + 1)
    begin
        clock_select[index] <= (index == dst) ? 1'b1 : 1'b0;
    end
end

// ����ʵ�����Ĵ���RegisterUnit�����ж�Ӧ����
wire [width - 1 : 0] x[registers - 1 : 0];
genvar i;
generate
    for(i = 0; i < registers; i = i + 1)
    begin
        RegisterUnit #(.width(width))
        Unit
        (
            .reset((zero && !i) ? 1'b1 : reset), // �����Ĵ���������������
            .clock(clock),                       // ͬ��ʱ��
            .enable(write & clock_select[i]),    // ��д��ʹ����ѡ���üĴ���ʱ��D������д��ʹ��
            .D(dst_i),                           // Ŀ��Ĵ�������д��
            .Q(x[i])                             // �Ĵ�������ȫ�����
        );
    end
endgenerate

// Դ�Ĵ������������ѡ��
// ����Դ�Ĵ����ı������������ݵ�ѡ��
reg [width - 1 : 0] rs1_reg;
reg [width - 1 : 0] rs2_reg;
always @(*)
begin
     rs1_reg <= x[rs1];
     rs2_reg <= x[rs2];
end

assign rs1_o = rs1_reg;
assign rs2_o = rs2_reg;

endmodule
