`timescale 1ns / 1ps

module ISPRAM #
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

genvar i;                                   // 模块生成变量

wire [GROUP - 1 : 0] WER;                   // 写入使能旋转右移后结果
RotateL #
(
    .UNITW(1),                              // 每个单元宽度
    .GROUP(GROUP)                           // 每组单元数量
)
rotate_w
(
    .W(ADDR_L),                             // 偏移量输入
    .A(WEN),                                // 偏移内容输入
    .Y(WER)                                 // 偏移结果输出
);

wire [UNITW * GROUP - 1 : 0] DATA_A;        // 数据输入旋转右移后结果
RotateL #
(
    .UNITW(UNITW),                          // RAM每个单元宽度
    .GROUP(GROUP)                           // RAM每组单元数量
)
rotate_i
(
    .W(ADDR_L),                             // RAM内偏移量输入
    .A(DATA_I),                             // RAM内偏移内容输入
    .Y(DATA_A)                              // RAM内偏移结果输出
);

reg [ADDRW - 1 : 0] ADDRLr;

always @(posedge CLK)
begin
    ADDRLr <= ADDR_L;
end

wire [UNITW * GROUP - 1 : 0] DATA_B;        // 数据输出旋转左移前结果
RotateR #
(
    .UNITW(UNITW),                          // RAM每个单元宽度
    .GROUP(GROUP)                           // RAM每组单元数量
)
rotate_o
(
    .W(ADDRLr),                             // RAM内偏移量输入
    .A(DATA_B),                             // RAM内偏移内容输入
    .Y(DATA_O)                              // RAM内偏移结果输出
);

assign OVF = (EXCEED && !ADDRLr);

generate
    for(i = 0; i < GROUP; i = i + 1)
    begin
        // xpm_memory_spram: 单端口RAM
        // Xilinx Parameterized Macro, 2020.1版
        xpm_memory_spram #(
            // 整  数：设置单端口RAM的地址线宽度(不影响实际的存储容量)
            .ADDR_WIDTH_A(ADDRW),
            // 整  数：自动休眠时间(自动休眠使能时有效)
            .AUTO_SLEEP_TIME(0),
            // 整  数：写入字节宽度(写入时可以此为单位写入)
            .BYTE_WRITE_WIDTH_A(UNITW),
            // 整  数：
            //  0 - 没有级联高度, 允许Vivado综合是自行选择
            // ≥1 - Vivado综合设置成指定级联高度
            .CASCADE_HEIGHT(0),
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
            // 整  数：存储容量 = 存储位宽 × 存储深度
            .MEMORY_SIZE(UNITW * DEPTH),
            // 整  数：是否启用动态信息报告
            // 0 - 禁用
            // 1 - 启用
            .MESSAGE_CONTROL(0),
            // 整  数：数据读取总位宽
            .READ_DATA_WIDTH_A(UNITW),
            // 整  数：数据读取时钟延迟
            // =0 时，使用分布式存储
            // ≥1 时，使用Block RAM(块内存储)
            // 其中：
            //     =1 时只使用存储自带锁存器
            //     =2 时使用输出寄存器
            //     >2 时引入存储外额外的触发器
            .READ_LATENCY_A(1),
            // 字符串：内存重置时，锁存器/输出寄存器的输出内容
            // 依据数据读取总位宽设置十六进制值
            .READ_RESET_VALUE_A("0"),
            // 字符串：内存重置模式
            //  "SYNC" - 同步重置，数据输出重置成READ_RESET_VALUE_A设置的值
            // "ASYNC" - 异步重置，数据输出重置成零
            .RST_MODE_A("SYNC"),
            // 整  数：
            // 0 = 禁用仿真信息
            // 1 = 启用仿真信息
            .SIM_ASSERT_CHK(0),
            // 整  数：用于生成内存初始化信息(包括内存内容文件加载)
            .USE_MEM_INIT(1),
            // 字符串：内存动态休眠设定
            // "disable_sleep" - 禁用动态休眠
            // "use_sleep_pin" - 使用sleep引脚控制动态休眠
            .WAKEUP_TIME("disable_sleep"),
            // 整  数：数据写入总位宽
            .WRITE_DATA_WIDTH_A(UNITW),
            // 字符串：数据写入时数据输出模式
            // "read_first"  - 读取优先：先从内存中读取原有值至锁存器/寄存器，再向内存中写入新值
            // "write_first" - 写入优先：先向内存中写入新值，再从内存中读取新的值至锁存器/寄存器
            // "no_change"   - 不发生改变：在写入前后过程中，输出锁存器/寄存器内的值不发生改变
            .WRITE_MODE_A("write_first")
        )
        xpm_memory_spram_inst
        (
            // 对外控制信号
            .clka(CLK),         // 1位输入:              时钟信号
            .rsta(RST),         // 1位输入:              输出重置信号
            .wea(WER[i]),       // (WRITE_DATA_WIDTH_A / BYTE_WRITE_WIDTH_A)位输入: 写入使能，注意依据字节写入宽度可以自行选择写入单元
            .ena(CEN),          // 1位输入:              时钟使能，控制读取和写入的使能
            .addra((i < ADDR_L) ? ADDR_P : ADDR_H),          // (ADDR_WIDTH_A)位输入: 内存地址
            .dina (DATA_A[(i + 1) * UNITW - 1 : i * UNITW]), // (WRITE_DATA_WIDTH_A)位输入: 数据输入
            .douta(DATA_B[(i + 1) * UNITW - 1 : i * UNITW]), // (READ_DATA_WIDTH_A)位输入:  数据输出
            // 内部控制信号
            .sleep (1'b0),      // 1位输入: 用于动态休眠功能控制
            .regcea(1'b1),      // 1位输入: 使能数据输出锁存器/寄存器时钟信号
            // ECC校验引脚
            .injectdbiterra(1'b0),
            .injectsbiterra(1'b0),
            .dbiterra(),
            .sbiterra()
        );
    end
endgenerate

endmodule