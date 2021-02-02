`timescale 1ns / 1ps

module Top #
(
    parameter WIDTH = 32,
    parameter UNITS = 32,
    parameter IMEMW = 14,
    parameter DMEMW = 14,
    parameter ILOAD = "none"
)
(
    input clock,        // 同步时钟信号
    input reset,        // 同步复位信号
    output [31 : 0] instruction  // 输出当前执行指令
);

/*
 * 内部通路
 */
reg  IntegersEnable;                                                    // 整数通用寄存器组写入使能(时钟使能)
wire [$clog2(UNITS) - 1 : 0] DstRegisterNumber = instruction[11 : 07];  // 整数通用寄存器组复选目标寄存器
wire [$clog2(UNITS) - 1 : 0] Rs1RegisterNumber = instruction[19 : 15];  // 整数通用寄存器组复选源寄存器1
wire [$clog2(UNITS) - 1 : 0] Rs2RegisterNumber = instruction[24 : 20];  // 整数通用寄存器组复选源寄存器2
reg  [WIDTH - 1 : 0] DstRegisterInsert;                                 // 整数通用寄存器组目标寄存器数据写入
wire [WIDTH - 1 : 0] Rs1RegisterOutput;                                 // 整数通用寄存器组源寄存器1数据输出
wire [WIDTH - 1 : 0] Rs2RegisterOutput;                                 // 整数通用寄存器组源寄存器2数据输出

reg  [3 : 0] IntegerALUOp;                                              // 整数算数逻辑单元操作码
wire [WIDTH - 1 : 0] IntegerALUInputA = Rs1RegisterOutput;              // 整数算术逻辑单元输入A
reg  [WIDTH - 1 : 0] IntegerALUInputB;                                  // 整数算术逻辑单元输入B
wire [WIDTH - 1 : 0] IntegerALUResult;                                  // 整数算术逻辑单元输出Y

reg  DataEnable;                                                        // DMEM写入使能
wire [WIDTH - 1 : 0] DataInsert = Rs2RegisterOutput;                    // DMEM数据输入
wire [WIDTH - 1 : 0] DataOutput;                                        // DMEM数据输出

/*
 * 内部组件
 */
// PC寄存器：记录当前执行指令地址
reg  [WIDTH - 1 : 0] PC;

// 整数通用寄存器组
GPRs #
(
    .ZERO(1),                 // 配置首个寄存器是否为零寄存器，
                              // 常规寄存器为0，零寄存器为1
    .WIDTH(WIDTH),            // 单个寄存器位宽
    .UNITS(UNITS)             // 寄存器总数
)
Integers
(
    .RST(reset),              // 同步复位
    .CLK(clock),              // 同步时钟
    .WEN(IntegersEnable),     // 写入使能(时钟使能)
    .DSTs(DstRegisterNumber), // 复选目标寄存器
    .RS1s(Rs1RegisterNumber), // 复选源寄存器1
    .RS2s(Rs2RegisterNumber), // 复选源寄存器2
    .DSTi(DstRegisterInsert), // 目标寄存器数据写入
    .RS1o(Rs1RegisterOutput), // 源寄存器1数据输出
    .RS2o(Rs2RegisterOutput)  // 源寄存器2数据输出
);

// 整数算数逻辑单元（不包含乘除法）
IntegerALU #
(
    .WIDTH(WIDTH)             // 算术逻辑单元位数
)
IntegerALU
(
    .OP(IntegerALUOp),        // 算术逻辑单元操作码
    .A(IntegerALUInputA),     // 算术逻辑单元输入A
    .B(IntegerALUInputB),     // 算术逻辑单元输入B
    .Y(IntegerALUResult)      // 算术逻辑单元输出Y
);

// 指令存储
SimpleRAM #
(
    .ADDRW(IMEMW),             // RAM地址宽度
    .DATAW(32),                // RAM数据宽度
    .DEPTH(2 ** IMEMW),        // RAM存储深度
    .MEMORY_INIT_FILE(ILOAD)   // RAM初始化文件
)
IMEM
(
    .CLK(~clock),              // 时钟输入
    .RST(reset),               // 复位输入
    .WEN(1'b0),                // 写入使能
    .CEN(1'b1),                // 时钟使能
    .ADDR_F(PC[IMEMW + 1 : 2]),// 内存地址
    .DATA_I(),                 // 数据输入
    .DATA_O(instruction)       // 数据输出
);

// 数据存储
SimpleRAM #
(
    .ADDRW(DMEMW),             // RAM地址宽度
    .DATAW(WIDTH),             // RAM数据宽度
    .DEPTH(2 ** DMEMW),        // RAM存储深度
    .MEMORY_INIT_FILE("none")  // RAM初始化文件
)
DMEM
(
    .CLK(clock),               // 时钟输入
    .RST(reset),               // 复位输入
    .WEN(DataEnable),          // 写入使能
    .CEN(1'b1),                // 时钟使能
    .ADDR_F(IntegerALUResult[DMEMW + 1 : 2]), // 内存地址
    .DATA_I(DataInsert),       // 数据输入
    .DATA_O(DataOutput)        // 数据输出
);

// PC寄存器
always @(posedge clock) begin
    if (reset)
    begin
        PC <= {1'b1, {WIDTH-1{1'b0}}};
    end
    else
    begin
        case (instruction[6 : 0])
        7'b1101111: PC <= PC + {{12{instruction[31]}}, instruction[19 : 12], instruction[20 : 20], instruction[30 : 21], 01'h0}; // JAL
        7'b1100111: PC <= Rs1RegisterOutput + {{21{instruction[31]}}, instruction[30 : 20]};                                     // JALR
        7'b1100011: // BRANCH
        begin
            case(instruction[14 : 12])
            3'b000 : PC <= (~|IntegerALUResult) ? (PC + {{21{instruction[31]}}, instruction[07 : 07], instruction[30 : 25], instruction[11 : 08], 01'h0}) : (PC + 4);
            3'b001 : PC <= ( |IntegerALUResult) ? (PC + {{21{instruction[31]}}, instruction[07 : 07], instruction[30 : 25], instruction[11 : 08], 01'h0}) : (PC + 4);
            3'b100 : PC <= ( |IntegerALUResult) ? (PC + {{21{instruction[31]}}, instruction[07 : 07], instruction[30 : 25], instruction[11 : 08], 01'h0}) : (PC + 4);
            3'b101 : PC <= (~|IntegerALUResult) ? (PC + {{21{instruction[31]}}, instruction[07 : 07], instruction[30 : 25], instruction[11 : 08], 01'h0}) : (PC + 4);
            3'b110 : PC <= ( |IntegerALUResult) ? (PC + {{21{instruction[31]}}, instruction[07 : 07], instruction[30 : 25], instruction[11 : 08], 01'h0}) : (PC + 4);
            3'b111 : PC <= (~|IntegerALUResult) ? (PC + {{21{instruction[31]}}, instruction[07 : 07], instruction[30 : 25], instruction[11 : 08], 01'h0}) : (PC + 4);
            default: PC <= PC + 4;
            endcase
        end
        default: PC <= PC + 4;
        endcase
    end
end

// GPRs的DST目标寄存器
always @(*) begin
    casez (instruction[6 : 0])
    7'b0110111: // LUI
    begin
        IntegersEnable <= 1'b1;
        DstRegisterInsert <= {instruction[31 : 12], 12'h0};
    end
    7'b0010111: // AUIPC
    begin
        IntegersEnable <= 1'b1;
        DstRegisterInsert <= PC + {instruction[31 : 12], 12'h0};
    end
    7'b110z111: // JAL & JALR
    begin
        IntegersEnable <= 1'b1;
        DstRegisterInsert <= PC + 4;
    end
    7'b0000011: // LOAD
    begin
        DstRegisterInsert <= {DataOutput};
        case (instruction[14 : 12])
        3'b010 : IntegersEnable <= 1'b1;
        default: IntegersEnable <= 1'b0;
        endcase
    end
    7'b0z10011: // OP & OP-IMM
    begin
        IntegersEnable <= 1'b1;
        DstRegisterInsert <= IntegerALUResult;
    end
    default: 
    begin
        IntegersEnable <= 1'b0;
        DstRegisterInsert <= IntegerALUResult;
    end
    endcase
end

// DMEM写入使能控制
always @(*) begin
    case (instruction[6 : 0])
    7'b0100011: DataEnable <= 1'b1; // STORE
    default:    DataEnable <= 1'b0;
    endcase
end

// 算数逻辑单元输入B
always @(*) begin
    casez (instruction[6 : 0])
    7'b00z0011: IntegerALUInputB <= {{21{instruction[31]}}, instruction[30 : 20]};                       // LOAD & OP-IMM
    7'b0100011: IntegerALUInputB <= {{21{instruction[31]}}, instruction[30 : 25], instruction[11 : 07]}; // STORE
    default:    IntegerALUInputB <= Rs2RegisterOutput;
    endcase
end

// 算数逻辑单元操作码
always @(*) begin
    case (instruction[6 : 0])
    7'b1100011: // BRANCH
    begin
        casez(instruction[14 : 12])
        3'b00z : IntegerALUOp <= 4'b0001;
        3'b10z : IntegerALUOp <= 4'b0100;
        3'b11z : IntegerALUOp <= 4'b0110;
        default: IntegerALUOp <= 4'b0000;
        endcase
    end
    7'b0010011: // OP-IMM
    begin
        casez(instruction[14 : 12])
        3'bz01 : IntegerALUOp <= {instruction[14 : 12], instruction[30]}; // SLLI, SRLI, SRAI
        default: IntegerALUOp <= {instruction[14 : 12], 1'b0};            // OTHERS
        endcase
    end
    7'b0110011: IntegerALUOp <= {instruction[14 : 12], instruction[30]}; // OP
    default: IntegerALUOp <= 4'b0000;
    endcase
end

endmodule
