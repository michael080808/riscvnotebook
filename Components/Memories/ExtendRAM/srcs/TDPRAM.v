`timescale 1ns / 1ps

module TDPRAM #
(
    parameter ADDRW = 14,                   // RAM��ַ���
    parameter UNITW = 8,                    // RAMÿ����Ԫ���
    parameter GROUP = 4,                    // RAMÿ�鵥Ԫ����
    parameter DEPTH = 2 ** 14               // RAM�洢���
)
(
    input  CLK,                             // ʱ������
    input  RST,                             // ��λ����
    input  CEN,                             // ʱ��ʹ��
    input  [GROUP         - 1 : 0] WEN,     // д��ʹ��
    input  [ADDRW         - 1 : 0] ADDR_H,  // ��ַ��λ(���)
    input  [$clog2(GROUP) - 1 : 0] ADDR_L,  // ��ַ��λ(���)
    input  [UNITW * GROUP - 1 : 0] DATA_I,  // ��������
    output [UNITW * GROUP - 1 : 0] DATA_O,  // �������
    output OVF                              // ��ַ���
);

wire EXCEED;                                // RAM��ַ���
wire [ADDRW - 1 : 0] ADDR_P;                // RAM��ַ��һ

Adder #(.WIDTH(ADDRW))
addone
(
    .A({{ADDRW - 1{1'b0}}, 1'b1}),          // RAM��ַ��һ
    .B(ADDR_H),                             // RAM��ַԭֵ
    .Y(ADDR_P),                             // RAM��ַ�Ӻ�
    .C(EXCEED)                              // RAM��ַ���
);

assign OVF = (EXCEED && !ADDR_L);

wire [2 * GROUP         - 1 : 0] WER;
wire [2 * UNITW * GROUP - 1 : 0] DATAwI;
wire [2 * UNITW * GROUP - 1 : 0] DATAwO;

reg [ADDRW - 1 : 0] ADDRLr;
always @(posedge CLK)
begin
    ADDRLr <= ADDR_L;
end

assign WER    = {{GROUP{1'b0}}, WEN} << ADDR_L;
assign DATAwI = {{UNITW * GROUP{1'b0}}, DATA_I} << (ADDR_L * UNITW);
assign DATA_O = DATAwO >> (ADDRLr * UNITW);

// xpm_memory_spram: ˫�˿��������RAM
// Xilinx Parameterized Macro, 2020.1��
xpm_memory_tdpram #(
    // ��  �������ö˿�A��RAM�ĵ�ַ�߿��(��Ӱ��ʵ�ʵĴ洢����)
    .ADDR_WIDTH_A(ADDRW),
    // ��  �������ö˿�B��RAM�ĵ�ַ�߿��(��Ӱ��ʵ�ʵĴ洢����)
    .ADDR_WIDTH_B(ADDRW),
    // ��  �����Զ�����ʱ��(�Զ�����ʹ��ʱ��Ч)
    .AUTO_SLEEP_TIME(0),
    // ��  �����˿�Aд���ֽڿ��(д��ʱ���Դ�Ϊ��λд��)
    .BYTE_WRITE_WIDTH_A(UNITW),
    // ��  �����˿�Bд���ֽڿ��(д��ʱ���Դ�Ϊ��λд��)
    .BYTE_WRITE_WIDTH_B(UNITW),
    // ��  ����
    //  0 - û�м����߶�, ����Vivado�ۺ�������ѡ��
    // ��1 - Vivado�ۺ����ó�ָ�������߶�
    .CASCADE_HEIGHT(0),
    // �ַ�����˫�˿�ʱ������
    // "common_clock"           - ˫�˿ڹ���ʱ��ԴCLKA
    // "independent_clock"      - ˫�˿ڶ���ʱ��ԴCLKA��CLKB
    .CLOCKING_MODE("common_clock"),
    // �ַ�����ECCУ���������
    // "no_ecc"                 - ����ECC
    // "encode_only"            - ������ECC������
    // "decode_only"            - ������ECC������
    // "both_encode_and_decode" - ͬʱ����ECC�������ͽ�����
    .ECC_MODE("no_ecc"),
    // �ַ�����RAM��ʼ���ļ�
    // ʹ���ⲿ�ļ�����
    // û�г�ʼ������ʱʹ��"none"
    // ��ʽ�μ�UG953/UG974���й�Memory File(�洢�ļ�)�½�
    .MEMORY_INIT_FILE("none"),
    // �ַ�����RAM��ʼ������
    // ʮ���������룬ÿ�ֽڼ�ʹ�ö���","�ָ�����������ڴ�ĳ�ʼ��
    // ���磺parameter MEMORY_INIT_PARAM = "AB,CD,EF,1,2,34,56,78"
    // ʹ��"0"��������Ϊ�յ��ַ���""��ʾû�г�ʼ������
    .MEMORY_INIT_PARAM("0"),
    // �ַ������Ƿ��Ż�RAMʹ�ã�ʹ��"true", "false"����ѡ��
    .MEMORY_OPTIMIZATION("true"),
    // �ַ�����ָ��Ҫʹ�õ��ڴ�ԭ��(��Դ����)
    // "auto"        - ����Vivado�ۺ�����ѡ��
    // "distributed" - �ֲ�ʽ�洢
    // "block"       - ���ڴ洢
    // "ultra"       - UltraRAM�洢(������UltraScale+������)
    .MEMORY_PRIMITIVE("auto"),
    // ��  �����洢���� = �洢λ�� �� �洢��� �� ����
    .MEMORY_SIZE(UNITW * DEPTH * GROUP),
    // ��  �����Ƿ����ö�̬��Ϣ����
    // 0 - ����
    // 1 - ����
    .MESSAGE_CONTROL(0),
    // ��  �����˿�A���ݶ�ȡ��λ��
    .READ_DATA_WIDTH_A(UNITW * GROUP),
    // ��  �����˿�B���ݶ�ȡ��λ��
    .READ_DATA_WIDTH_B(UNITW * GROUP),
    // ��  �����˿�A���ݶ�ȡʱ���ӳ�
    // =0 ʱ��ʹ�÷ֲ�ʽ�洢
    // ��1 ʱ��ʹ��Block RAM(���ڴ洢)
    // ���У�
    //     =1 ʱֻʹ�ô洢�Դ�������
    //     =2 ʱʹ������Ĵ���
    //     >2 ʱ����洢�����Ĵ�����
    .READ_LATENCY_A(1),
    // ��  �����˿�B���ݶ�ȡʱ���ӳ�
    // =0 ʱ��ʹ�÷ֲ�ʽ�洢
    // ��1 ʱ��ʹ��Block RAM(���ڴ洢)
    // ���У�
    //     =1 ʱֻʹ�ô洢�Դ�������
    //     =2 ʱʹ������Ĵ���
    //     >2 ʱ����洢�����Ĵ�����
    .READ_LATENCY_B(1),
    // �ַ������˿�A�ڴ�����ʱ��������/����Ĵ������������
    // �������ݶ�ȡ��λ������ʮ������ֵ
    .READ_RESET_VALUE_A("0"),
    // �ַ������˿�B�ڴ�����ʱ��������/����Ĵ������������
    // �������ݶ�ȡ��λ������ʮ������ֵ
    .READ_RESET_VALUE_B("0"),
    // �ַ������˿�A�ڴ�����ģʽ
    //  "SYNC" - ͬ�����ã�����������ó�READ_RESET_VALUE_A���õ�ֵ
    // "ASYNC" - �첽���ã�����������ó���
    .RST_MODE_A("SYNC"),
    // �ַ������˿�B�ڴ�����ģʽ
    //  "SYNC" - ͬ�����ã�����������ó�READ_RESET_VALUE_B���õ�ֵ
    // "ASYNC" - �첽���ã�����������ó���
    .RST_MODE_B("SYNC"),
    // ��  ����
    // 0 = ���÷�����Ϣ
    // 1 = ���÷�����Ϣ
    .SIM_ASSERT_CHK(0),
    // ��  ����ָ��1�����÷ֲ�ʽRAM��clka��clkb�ϵ�doutb_reg֮���set_false_pathԼ�����
    .USE_EMBEDDED_CONSTRAINT(0),
    // ��  �������������ڴ��ʼ����Ϣ(�����ڴ������ļ�����)
    .USE_MEM_INIT(1),
    // �ַ������ڴ涯̬�����趨
    // "disable_sleep" - ���ö�̬����
    // "use_sleep_pin" - ʹ��sleep���ſ��ƶ�̬����
    .WAKEUP_TIME("disable_sleep"),
    // ��  �����˿�A����д����λ��
    .WRITE_DATA_WIDTH_A(UNITW * GROUP),
    // ��  �����˿�B����д����λ��
    .WRITE_DATA_WIDTH_B(UNITW * GROUP),
    // �ַ������˿�A����д��ʱ�������ģʽ
    // "read_first"  - ��ȡ���ȣ��ȴ��ڴ��ж�ȡԭ��ֵ��������/�Ĵ����������ڴ���д����ֵ
    // "write_first" - д�����ȣ������ڴ���д����ֵ���ٴ��ڴ��ж�ȡ�µ�ֵ��������/�Ĵ���
    // "no_change"   - �������ı䣺��д��ǰ������У����������/�Ĵ����ڵ�ֵ�������ı�
    .WRITE_MODE_A("write_first"),
    // �ַ������˿�B����д��ʱ�������ģʽ
    // "read_first"  - ��ȡ���ȣ��ȴ��ڴ��ж�ȡԭ��ֵ��������/�Ĵ����������ڴ���д����ֵ
    // "write_first" - д�����ȣ������ڴ���д����ֵ���ٴ��ڴ��ж�ȡ�µ�ֵ��������/�Ĵ���
    // "no_change"   - �������ı䣺��д��ǰ������У����������/�Ĵ����ڵ�ֵ�������ı�
    .WRITE_MODE_B("write_first")
)
xpm_memory_tdpram_inst (
    // ��������ź�
    .clka(CLK), // 1λ����: �˿�Aʱ���ź�
    .clkb(CLK), // 1λ����: �˿�Bʱ���ź�
    .rsta(RST), // 1λ����: �˿�A��������ź�
    .rstb(RST), // 1λ����: �˿�B��������ź�
    .wea(WER[    GROUP - 1 :     0]), // (WRITE_DATA_WIDTH_A / BYTE_WRITE_WIDTH_A)λ����: �˿�Aд��ʹ�ܣ�ע�������ֽ�д���ȿ�������ѡ��д�뵥Ԫ
    .web(WER[2 * GROUP - 1 : GROUP]), // (WRITE_DATA_WIDTH_B / BYTE_WRITE_WIDTH_B)λ����: �˿�Bд��ʹ�ܣ�ע�������ֽ�д���ȿ�������ѡ��д�뵥Ԫ
    .ena(CEN), // 1λ����: �˿�Aʱ��ʹ�ܣ����ƶ�ȡ��д���ʹ��
    .enb(CEN), // 1λ����: �˿�Bʱ��ʹ�ܣ����ƶ�ȡ��д���ʹ��
    .addra(ADDR_H), // (ADDR_WIDTH_A)λ����: �˿�A�ڴ��ַ
    .addrb(ADDR_P), // (ADDR_WIDTH_B)λ����: �˿�B�ڴ��ַ
    .dina (DATAwI[    UNITW * GROUP - 1 :             0]), // (WRITE_DATA_WIDTH_A)λ����: �˿�A��������
    .dinb (DATAwI[2 * UNITW * GROUP - 1 : UNITW * GROUP]), // (WRITE_DATA_WIDTH_B)λ����: �˿�B��������
    .douta(DATAwO[    UNITW * GROUP - 1 :             0]), // (READ_DATA_WIDTH_A)λ����: �˿�A�������
    .doutb(DATAwO[2 * UNITW * GROUP - 1 : UNITW * GROUP]), // (READ_DATA_WIDTH_A)λ����: �˿�B�������
    
    // �ڲ������ź�
    .sleep(1'b0),  // 1λ����: ���ڶ�̬���߹��ܿ���
    .regcea(1'b1), // 1λ����: �˿�Aʹ���������������/�Ĵ���ʱ���ź�
    .regceb(1'b1), // 1λ����: �˿�Bʹ���������������/�Ĵ���ʱ���ź�

    // ECCУ������
    .injectdbiterra(1'b0),
    .injectdbiterrb(1'b0),
    .injectsbiterra(1'b0),
    .injectsbiterrb(1'b0),
    .dbiterra(),
    .dbiterrb(),
    .sbiterra(),
    .sbiterrb()
);
// End of xpm_memory_tdpram_inst instantiation

endmodule