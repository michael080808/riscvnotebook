`timescale 1ns / 1ps

// zero      : �׸��Ĵ����Ƿ�Ϊ��Ĵ���
// width     : �Ĵ���λ��
// registers : �Ĵ�������
module GPRs_Testbench #(parameter zero = 0, parameter width = 32, parameter registers = 32)();

// ͬ����λ
reg reset = 1'b1;
// ͬ��ʱ��
reg clock = 1'b0;
// д��ʹ��(ʱ��ʹ��)
reg write = 1'b1;

// ��ѡĿ��Ĵ���
reg [$clog2(registers) - 1 : 0] dst;
// ��ѡԴ�Ĵ���1
reg [$clog2(registers) - 1 : 0] rs1;
// ��ѡԴ�Ĵ���2
reg [$clog2(registers) - 1 : 0] rs2;

// Ŀ��Ĵ�����������
reg  [width - 1 : 0] dst_i;
// Դ�Ĵ���1�������
wire [width - 1 : 0] rs1_o;
// Դ�Ĵ���2�������
wire [width - 1 : 0] rs2_o;

// ʵ����ͨ�üĴ�����
GPRs #(.zero(zero), .registers(registers), .width(width))
Unit
(
    .reset(reset), // ͬ����λ
    .clock(clock), // ͬ��ʱ��
    .write(write), // д��ʹ��(ʱ��ʹ��)
    .dst(dst),     // ��ѡĿ��Ĵ���
    .rs1(rs1),     // ��ѡԴ�Ĵ���1
    .rs2(rs2),     // ��ѡԴ�Ĵ���2
    .dst_i(dst_i), // Ŀ��Ĵ�������д��
    .rs1_o(rs1_o), // Դ�Ĵ���1�������
    .rs2_o(rs2_o)  // Դ�Ĵ���2�������
);

// ��ʼ��100MHzʱ��
always  #5   clock = ~clock;
// 100ns֮��λ������ע��˴�����FPGA�ĳ�ʼ������˸�λʱ��Ҫ���ڵ���100ns
initial #100 reset = ~reset;

integer i, j;
initial
begin
    #100 ;                                      // ��100ns֮��ʼ��ͨ�üĴ�������
    for(i = 0; i < registers; i = i + 1)        // ����ÿ���Ĵ�������һ�θ�ֵ
    begin
        dst <= i;                               // ��Ŀ��Ĵ������и�ѡ
        dst_i <= $random();                     // ��Ŀ��Ĵ��������������
        for(j = 0; j < registers; j = j + 1)    // ��ֵ����ÿ���Ĵ����ڴ洢������
        begin
            rs1 <= j;                           // Դ�Ĵ���1�����������
            rs2 <= registers - 1 - j;           // Դ�Ĵ���2�����������
            #10 ;                               // ÿ�����Ϊһ��ʱ������
        end
    end
    
    // �ԼĴ��������㸴λ��ע��˴���λ����һ��ʱ������(����һ��������)����
    #000 reset = ~reset;                        // �ԼĴ����鿪ʼ��λ
    #100 reset = ~reset;                        // �ԼĴ����������λ

    // �����Ĵ��������������������Ĵ�����д����
    if(zero)
    begin
        dst <= 0;                               // ��ѡ��Ĵ���
        dst_i <= $random();                     // ����Ĵ��������������
        for(j = 0; j < registers; j = j + 1)
        begin
            rs1 <= j;                           // Դ�Ĵ���1�����������
            rs2 <= registers - 1 - j;           // Դ�Ĵ���2�����������
            #10 ;                               // ÿ�����Ϊһ��ʱ������
        end 
    end
    
    // ��д��ʹ��(ʱ��ʹ��)���ܽ��м��
    for(i = 0; i < registers; i = i + 1)
    begin
        dst <= i;                               // ��Ŀ��Ĵ������и�ѡ
        dst_i <= $random();                     // ��Ŀ��Ĵ��������������
        write <= ~write;                        // �ı䵱ǰд��ʹ��(ʱ��ʹ��)״̬
        for(j = 0; j < registers; j = j + 1)
        begin
            rs1 <= j;                           // Դ�Ĵ���1�����������
            rs2 <= registers - 1 - j;           // Դ�Ĵ���2�����������
            #10 ;                               // ÿ�����Ϊһ��ʱ������
        end
    end

    // ��ɼ�飬ֹͣ����
    $stop;
end

endmodule
