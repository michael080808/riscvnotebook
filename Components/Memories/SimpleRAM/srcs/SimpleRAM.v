`timescale 1ns / 1ps

module SimpleRAM #
(
    parameter ADDRW = 14,                   // RAM��ַ���
    parameter DATAW = 2 ** 5,               // RAM���ݿ��
    parameter DEPTH = 2 ** 14,              // RAM�洢���
    parameter MEMORY_INIT_FILE = "none",    // RAM��ʼ���ļ�
    parameter SIM_ASSERT_CHK = 0            // �Ƿ������������Ϣ
)
(
    input  CLK,                             // ʱ������
    input  RST,                             // ��λ����
    input  WEN,                             // д��ʹ��
    input  CEN,                             // ʱ��ʹ��
    input  [ADDRW - 1 : 0] ADDR_F,          // �ڴ��ַ
    input  [DATAW - 1 : 0] DATA_I,          // ��������
    output [DATAW - 1 : 0] DATA_O           // �������
);

// xpm_memory_spram: ���˿�RAM
// Xilinx Parameterized Macro, 2020.1��
xpm_memory_spram #(
    // ��  �������õ��˿�RAM�ĵ�ַ�߿��(��Ӱ��ʵ�ʵĴ洢����)
    .ADDR_WIDTH_A(ADDRW),
    // ��  �����Զ�����ʱ��(�Զ�����ʹ��ʱ��Ч)
    .AUTO_SLEEP_TIME(0),
    // ��  ����д���ֽڿ��(д��ʱ���Դ�Ϊ��λд��)
    .BYTE_WRITE_WIDTH_A(DATAW),
    // ��  ����
    //  0 - û�м����߶�, ����Vivado�ۺ�������ѡ��
    // ��1 - Vivado�ۺ����ó�ָ�������߶�
    .CASCADE_HEIGHT(0),
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
    .MEMORY_INIT_FILE(MEMORY_INIT_FILE),
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
    // ��  �����洢���� = �洢λ�� �� �洢���
    .MEMORY_SIZE(DATAW * DEPTH),
    // ��  �����Ƿ����ö�̬��Ϣ����
    // 0 - ����
    // 1 - ����
    .MESSAGE_CONTROL(0),
    // ��  �������ݶ�ȡ��λ��
    .READ_DATA_WIDTH_A(DATAW),
    // ��  �������ݶ�ȡʱ���ӳ�
    // =0 ʱ��ʹ�÷ֲ�ʽ�洢
    // ��1 ʱ��ʹ��Block RAM(���ڴ洢)
    // ���У�
    //     =1 ʱֻʹ�ô洢�Դ�������
    //     =2 ʱʹ������Ĵ���
    //     >2 ʱ����洢�����Ĵ�����
    .READ_LATENCY_A(1),
    // �ַ������ڴ�����ʱ��������/����Ĵ������������
    // �������ݶ�ȡ��λ������ʮ������ֵ
    .READ_RESET_VALUE_A("0"),
    // �ַ������ڴ�����ģʽ
    //  "SYNC" - ͬ�����ã�����������ó�READ_RESET_VALUE_A���õ�ֵ
    // "ASYNC" - �첽���ã�����������ó���
    .RST_MODE_A("SYNC"),
    // ��  ����
    // 0 = ���÷�����Ϣ
    // 1 = ���÷�����Ϣ
    .SIM_ASSERT_CHK(SIM_ASSERT_CHK),
    // ��  �������������ڴ��ʼ����Ϣ(�����ڴ������ļ�����)
    .USE_MEM_INIT(1),
    // �ַ������ڴ涯̬�����趨
    // "disable_sleep" - ���ö�̬����
    // "use_sleep_pin" - ʹ��sleep���ſ��ƶ�̬����
    .WAKEUP_TIME("disable_sleep"),
    // ��  ��������д����λ��
    .WRITE_DATA_WIDTH_A(DATAW),
    // �ַ���������д��ʱ�������ģʽ
    // "read_first"  - ��ȡ���ȣ��ȴ��ڴ��ж�ȡԭ��ֵ��������/�Ĵ����������ڴ���д����ֵ
    // "WEN_first" - д�����ȣ������ڴ���д����ֵ���ٴ��ڴ��ж�ȡ�µ�ֵ��������/�Ĵ���
    // "no_change"   - �������ı䣺��д��ǰ������У����������/�Ĵ����ڵ�ֵ�������ı�
    .WRITE_MODE_A("WEN_first")
)
xpm_memory_spram_inst
(
    // ��������ź�
    .clka(CLK),                         // 1λ����:                     ʱ���ź�
    .rsta(RST),                         // 1λ����:                     ��������ź�
    .wea(WEN),                          // (WRITE_DATA_WIDTH_A / BYTE_WRITE_WIDTH_A)λ����: д��ʹ�ܣ�ע�������ֽ�д���ȿ�������ѡ��д�뵥Ԫ
    .ena(CEN),                          // 1λ����:                     ʱ��ʹ�ܣ����ƶ�ȡ��д���ʹ��
    .addra(ADDR_F),                     // (ADDR_WIDTH_A)λ����:        �ڴ��ַ
    .dina (DATA_I),                     // (WRITE_DATA_WIDTH_A)λ����:  ��������
    .douta(DATA_O),                     // (READ_DATA_WIDTH_A)λ����:   �������
    // �ڲ������ź�
    .sleep (1'b0),                      // 1λ����: ���ڶ�̬���߹��ܿ���
    .regcea(1'b1),                      // 1λ����: ʹ���������������/�Ĵ���ʱ���ź�
    // ECCУ������
    .injectdbiterra(1'b0),
    .injectsbiterra(1'b0),
    .dbiterra(),
    .sbiterra()
);

endmodule
