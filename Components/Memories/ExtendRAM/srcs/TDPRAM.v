`timescale 1ns / 1ps

module TDPRAM #
(
    parameter ADDRW = 14,                   // RAM地址宽度
    parameter UNITW = 8,                    // RAM每个单元宽度
    parameter GROUP = 4,                    // RAM每组单元数量
    parameter DEPTH = 2 ** 14               // RAM存储深度
)
(
    input  CLK,                             // 时钟输入
    input  RST,                             // 复位输入
    input  CEN,                             // 时钟使能
    input  [GROUP         - 1 : 0] WEN,     // 写入使能
    input  [ADDRW         - 1 : 0] ADDR_H,  // 地址高位(深度)
    input  [$clog2(GROUP) - 1 : 0] ADDR_L,  // 地址低位(组号)
    input  [UNITW * GROUP - 1 : 0] DATA_I,  // 数据输入
    output [UNITW * GROUP - 1 : 0] DATA_O,  // 数据输出
    output OVF                              // 地址溢出
);

wire EXCEED;                                // RAM地址溢出
wire [ADDRW - 1 : 0] ADDR_P;                // RAM地址加一

Adder #(.WIDTH(ADDRW))
addone
(
    .A({{ADDRW - 1{1'b0}}, 1'b1}),          // RAM地址加一
    .B(ADDR_H),                             // RAM地址原值
    .Y(ADDR_P),                             // RAM地址加和
    .C(EXCEED)                              // RAM地址溢出
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

// xpm_memory_spram: 双端口输入输出RAM
// Xilinx Parameterized Macro, 2020.1版
xpm_memory_tdpram #(
    // 整  数：设置端口A的RAM的地址线宽度(不影响实际的存储容量)
    .ADDR_WIDTH_A(ADDRW),
    // 整  数：设置端口B的RAM的地址线宽度(不影响实际的存储容量)
    .ADDR_WIDTH_B(ADDRW),
    // 整  数：自动休眠时间(自动休眠使能时有效)
    .AUTO_SLEEP_TIME(0),
    // 整  数：端口A写入字节宽度(写入时可以此为单位写入)
    .BYTE_WRITE_WIDTH_A(UNITW),
    // 整  数：端口B写入字节宽度(写入时可以此为单位写入)
    .BYTE_WRITE_WIDTH_B(UNITW),
    // 整  数：
    //  0 - 没有级联高度, 允许Vivado综合是自行选择
    // ≥1 - Vivado综合设置成指定级联高度
    .CASCADE_HEIGHT(0),
    // 字符串：双端口时钟类型
    // "common_clock"           - 双端口共用时钟源CLKA
    // "independent_clock"      - 双端口独立时钟源CLKA和CLKB
    .CLOCKING_MODE("common_clock"),
    // 字符串：ECC校验纠错设置
    // "no_ecc"                 - 禁用ECC
    // "encode_only"            - 仅启用ECC编码器
    // "decode_only"            - 仅启用ECC解码器
    // "both_encode_and_decode" - 同时启用ECC编码器和解码器
    .ECC_MODE("no_ecc"),
    // 字符串：RAM初始化文件
    // 使用外部文件导入
    // 没有初始化内容时使用"none"
    // 格式参见UG953/UG974中有关Memory File(存储文件)章节
    .MEMORY_INIT_FILE("none"),
    // 字符串：RAM初始化参数
    // 十六进制输入，每字节间使用逗号","分割，可用于完整内存的初始化
    // 例如：parameter MEMORY_INIT_PARAM = "AB,CD,EF,1,2,34,56,78"
    // 使用"0"或者内容为空的字符串""表示没有初始化参数
    .MEMORY_INIT_PARAM("0"),
    // 字符串：是否优化RAM使用，使用"true", "false"进行选择
    .MEMORY_OPTIMIZATION("true"),
    // 字符串：指定要使用的内存原语(资源类型)
    // "auto"        - 允许Vivado综合自行选择
    // "distributed" - 分布式存储
    // "block"       - 块内存储
    // "ultra"       - UltraRAM存储(仅用于UltraScale+器件上)
    .MEMORY_PRIMITIVE("auto"),
    // 整  数：存储容量 = 存储位宽 × 存储深度 × 组数
    .MEMORY_SIZE(UNITW * DEPTH * GROUP),
    // 整  数：是否启用动态信息报告
    // 0 - 禁用
    // 1 - 启用
    .MESSAGE_CONTROL(0),
    // 整  数：端口A数据读取总位宽
    .READ_DATA_WIDTH_A(UNITW * GROUP),
    // 整  数：端口B数据读取总位宽
    .READ_DATA_WIDTH_B(UNITW * GROUP),
    // 整  数：端口A数据读取时钟延迟
    // =0 时，使用分布式存储
    // ≥1 时，使用Block RAM(块内存储)
    // 其中：
    //     =1 时只使用存储自带锁存器
    //     =2 时使用输出寄存器
    //     >2 时引入存储外额外的触发器
    .READ_LATENCY_A(1),
    // 整  数：端口B数据读取时钟延迟
    // =0 时，使用分布式存储
    // ≥1 时，使用Block RAM(块内存储)
    // 其中：
    //     =1 时只使用存储自带锁存器
    //     =2 时使用输出寄存器
    //     >2 时引入存储外额外的触发器
    .READ_LATENCY_B(1),
    // 字符串：端口A内存重置时，锁存器/输出寄存器的输出内容
    // 依据数据读取总位宽设置十六进制值
    .READ_RESET_VALUE_A("0"),
    // 字符串：端口B内存重置时，锁存器/输出寄存器的输出内容
    // 依据数据读取总位宽设置十六进制值
    .READ_RESET_VALUE_B("0"),
    // 字符串：端口A内存重置模式
    //  "SYNC" - 同步重置，数据输出重置成READ_RESET_VALUE_A设置的值
    // "ASYNC" - 异步重置，数据输出重置成零
    .RST_MODE_A("SYNC"),
    // 字符串：端口B内存重置模式
    //  "SYNC" - 同步重置，数据输出重置成READ_RESET_VALUE_B设置的值
    // "ASYNC" - 异步重置，数据输出重置成零
    .RST_MODE_B("SYNC"),
    // 整  数：
    // 0 = 禁用仿真信息
    // 1 = 启用仿真信息
    .SIM_ASSERT_CHK(0),
    // 整  数：指定1以启用分布式RAM的clka和clkb上的doutb_reg之间的set_false_path约束添加
    .USE_EMBEDDED_CONSTRAINT(0),
    // 整  数：用于生成内存初始化信息(包括内存内容文件加载)
    .USE_MEM_INIT(1),
    // 字符串：内存动态休眠设定
    // "disable_sleep" - 禁用动态休眠
    // "use_sleep_pin" - 使用sleep引脚控制动态休眠
    .WAKEUP_TIME("disable_sleep"),
    // 整  数：端口A数据写入总位宽
    .WRITE_DATA_WIDTH_A(UNITW * GROUP),
    // 整  数：端口B数据写入总位宽
    .WRITE_DATA_WIDTH_B(UNITW * GROUP),
    // 字符串：端口A数据写入时数据输出模式
    // "read_first"  - 读取优先：先从内存中读取原有值至锁存器/寄存器，再向内存中写入新值
    // "write_first" - 写入优先：先向内存中写入新值，再从内存中读取新的值至锁存器/寄存器
    // "no_change"   - 不发生改变：在写入前后过程中，输出锁存器/寄存器内的值不发生改变
    .WRITE_MODE_A("write_first"),
    // 字符串：端口B数据写入时数据输出模式
    // "read_first"  - 读取优先：先从内存中读取原有值至锁存器/寄存器，再向内存中写入新值
    // "write_first" - 写入优先：先向内存中写入新值，再从内存中读取新的值至锁存器/寄存器
    // "no_change"   - 不发生改变：在写入前后过程中，输出锁存器/寄存器内的值不发生改变
    .WRITE_MODE_B("write_first")
)
xpm_memory_tdpram_inst (
    // 对外控制信号
    .clka(CLK), // 1位输入: 端口A时钟信号
    .clkb(CLK), // 1位输入: 端口B时钟信号
    .rsta(RST), // 1位输入: 端口A输出重置信号
    .rstb(RST), // 1位输入: 端口B输出重置信号
    .wea(WER[    GROUP - 1 :     0]), // (WRITE_DATA_WIDTH_A / BYTE_WRITE_WIDTH_A)位输入: 端口A写入使能，注意依据字节写入宽度可以自行选择写入单元
    .web(WER[2 * GROUP - 1 : GROUP]), // (WRITE_DATA_WIDTH_B / BYTE_WRITE_WIDTH_B)位输入: 端口B写入使能，注意依据字节写入宽度可以自行选择写入单元
    .ena(CEN), // 1位输入: 端口A时钟使能，控制读取和写入的使能
    .enb(CEN), // 1位输入: 端口B时钟使能，控制读取和写入的使能
    .addra(ADDR_H), // (ADDR_WIDTH_A)位输入: 端口A内存地址
    .addrb(ADDR_P), // (ADDR_WIDTH_B)位输入: 端口B内存地址
    .dina (DATAwI[    UNITW * GROUP - 1 :             0]), // (WRITE_DATA_WIDTH_A)位输入: 端口A数据输入
    .dinb (DATAwI[2 * UNITW * GROUP - 1 : UNITW * GROUP]), // (WRITE_DATA_WIDTH_B)位输入: 端口B数据输入
    .douta(DATAwO[    UNITW * GROUP - 1 :             0]), // (READ_DATA_WIDTH_A)位输入: 端口A数据输出
    .doutb(DATAwO[2 * UNITW * GROUP - 1 : UNITW * GROUP]), // (READ_DATA_WIDTH_A)位输入: 端口B数据输出
    
    // 内部控制信号
    .sleep(1'b0),  // 1位输入: 用于动态休眠功能控制
    .regcea(1'b1), // 1位输入: 端口A使能数据输出锁存器/寄存器时钟信号
    .regceb(1'b1), // 1位输入: 端口B使能数据输出锁存器/寄存器时钟信号

    // ECC校验引脚
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