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
    output reg [31 : 0] instruction  // 输出当前执行指令
);

/*
 * 内部通路
 */

// 整数通用寄存器组
reg  IntegersEnable = 1'b0;                                             // 整数通用寄存器组写入使能(时钟使能)

wire [$clog2(UNITS) - 1 : 0] DstRegisterNumber = instruction[11 : 07];  // 整数通用寄存器组复选目标寄存器
wire [$clog2(UNITS) - 1 : 0] Rs1RegisterNumber = instruction[19 : 15];  // 整数通用寄存器组复选源寄存器1
wire [$clog2(UNITS) - 1 : 0] Rs2RegisterNumber = instruction[24 : 20];  // 整数通用寄存器组复选源寄存器2

reg  [WIDTH - 1 : 0] DstRegisterInsert = {WIDTH{1'b0}};                 // 整数通用寄存器组目标寄存器数据写入
wire [WIDTH - 1 : 0] Rs1RegisterOutput;                                 // 整数通用寄存器组源寄存器1数据输出
wire [WIDTH - 1 : 0] Rs2RegisterOutput;                                 // 整数通用寄存器组源寄存器2数据输出

// 整数算数逻辑单元（不包含乘除法）
reg  [3 : 0] IntegerALUOp = 4'b0000;                                    // 算术逻辑单元操作码
reg  [WIDTH - 1 : 0] IntegerALUInputA = {WIDTH{1'b0}};                  // 算术逻辑单元输入A
reg  [WIDTH - 1 : 0] IntegerALUInputB = {WIDTH{1'b0}};                  // 算术逻辑单元输入B
wire [WIDTH - 1 : 0] IntegerALUResult;                                  // 算术逻辑单元输出Y

// 指令计数
reg  [WIDTH - 1 : 0] PCNext;                    // 下一地址

// 指令存储
wire [31 : 0] CodeOutput;                       // 指令输出

// 数据存储
reg  DataEnable = 1'b0;
reg  [WIDTH - 1 : 0] DataAddrIO;                // 数据地址
reg  [WIDTH - 1 : 0] DataInsert;                // 数据输入
wire [WIDTH - 1 : 0] DataOutput;                // 数据输出
/*
 * 内部组件
 */
// 多周期执行状态记录寄存器，注意与RISC-V内部的控制状态寄存器区分
reg  [2 : 0] status = 3'h0;
localparam IF = 3'h0;
localparam ID = 3'h1;
localparam EX = 3'h2;
localparam MM = 3'h3;
localparam WB = 3'h4;
// localparam E0 = 3'h5;
// localparam E1 = 3'h6;
// localparam E2 = 3'h7;

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
    .CLK(clock),               // 时钟输入
    .RST(reset),               // 复位输入
    .WEN(1'b0),                // 写入使能
    .CEN(1'b1),                // 时钟使能
    .ADDR_F(PC[IMEMW + 1 : 2]),// 内存地址
    .DATA_I(),                 // 数据输入
    .DATA_O(CodeOutput)        // 数据输出
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
    .ADDR_F(DataAddrIO[DMEMW + 1 : 2]), // 内存地址
    .DATA_I(DataInsert),       // 数据输入
    .DATA_O(DataOutput)        // 数据输出
);

// 多周期执行状态记录寄存器
always @(posedge clock) begin
    if (reset)
    begin
        PC <= {1'b1, {WIDTH - 1{1'b0}}};
        status <= IF;
    end
    else
    begin
        case (status)
        IF:
        begin
            status <= ID;
            #1 instruction <= CodeOutput;
        end
        ID:
        begin
            case(instruction[6 : 0])
            7'b0110111: // LUI
            begin
                status <= EX;
            end
            7'b0010111: // AUIPC
            begin
                status <= EX;
            end
            7'b1101111: // JAL
            begin
                status <= EX;
            end
            7'b1100111: // JALR
            begin
                status <= EX;
            end
            7'b1100011: // Branch
            begin
                status <= EX;
                IntegerALUInputA <= Rs1RegisterOutput;
                IntegerALUInputB <= Rs2RegisterOutput;
                casez (instruction[14 : 12])
                    3'b00z:  IntegerALUOp <= 4'b0001; // BEQ  & BNE
                    3'b10z:  IntegerALUOp <= 4'b0100; // BLT  & BGE
                    3'b11z:  IntegerALUOp <= 4'b0110; // BLTU & BGEU
                    default: IntegerALUOp <= 4'b0000;
                endcase
            end
            7'b0000011: // Load
            begin
                status <= EX;
                IntegerALUInputA <= Rs1RegisterOutput;
                IntegerALUInputB <= {{21{instruction[31]}}, instruction[30 : 20]};
                IntegerALUOp <= 4'b0000;
            end
            7'b0100011: // Store
            begin
                status <= EX;
                IntegerALUInputA <= Rs1RegisterOutput;
                IntegerALUInputB <= {{21{instruction[31]}}, instruction[30 : 25], instruction[11 : 07]};
                IntegerALUOp <= 4'b0000;
            end
            7'b0010011: // OP-IMM
            begin
                status <= EX;
                IntegerALUInputA <= Rs1RegisterOutput;
                IntegerALUInputB <= {{21{instruction[31]}}, instruction[30 : 20]};
                case (instruction[14 : 12])
                    3'b101:  IntegerALUOp <= {instruction[14 : 12], instruction[30]}; // SRLI & SRAI
                    default: IntegerALUOp <= {instruction[14 : 12], 1'b0};            // Default
                endcase
            end
            7'b0110011: // OP
            begin
                status <= EX;
                IntegerALUInputA <= Rs1RegisterOutput;
                IntegerALUInputB <= Rs2RegisterOutput;
                IntegerALUOp <= {instruction[14 : 12], instruction[30]}; 
            end
            default: 
            begin
                status <= EX;
            end
            endcase
        end
        EX:
        begin
            case(instruction[6 : 0])
            7'b0110111: // LUI
            begin
                status <= WB;
                PCNext <= PC + 4;
                DstRegisterInsert <= {instruction[31 : 12], 12'h0};
                IntegersEnable <= 1'b1;
            end
            7'b0010111: // AUIPC
            begin
                status <= WB;
                PCNext <= PC + 4;
                DstRegisterInsert <= PC + {instruction[31 : 12], 12'h0};
                IntegersEnable <= 1'b1;
            end
            7'b1101111: // JAL
            begin
                status <= WB;
                PCNext <= PC + {{12{instruction[31]}}, instruction[19 : 12], instruction[20], instruction[30 : 21], 1'b0};
                DstRegisterInsert <= PC + 4;
                IntegersEnable <= 1'b1;
            end
            7'b1100111: // JALR
            begin
                status <= WB;
                PCNext <= Rs1RegisterOutput + {{21{instruction[31]}}, instruction[30 : 20]};
                DstRegisterInsert <= PC + 4;
                IntegersEnable <= 1'b1;
            end
            7'b1100011: // Branch
            begin
                status <= WB;
                case (instruction[14 : 12])
                    3'b000 : PCNext <= (~|IntegerALUResult) ? (PC + {{21{instruction[31]}}, instruction[07 : 07], instruction[30 : 25], instruction[11 : 08], 01'h0}) : (PC + 4);
                    3'b001 : PCNext <= ( |IntegerALUResult) ? (PC + {{21{instruction[31]}}, instruction[07 : 07], instruction[30 : 25], instruction[11 : 08], 01'h0}) : (PC + 4);
                    3'b100 : PCNext <= ( |IntegerALUResult) ? (PC + {{21{instruction[31]}}, instruction[07 : 07], instruction[30 : 25], instruction[11 : 08], 01'h0}) : (PC + 4);
                    3'b101 : PCNext <= (~|IntegerALUResult) ? (PC + {{21{instruction[31]}}, instruction[07 : 07], instruction[30 : 25], instruction[11 : 08], 01'h0}) : (PC + 4);
                    3'b110 : PCNext <= ( |IntegerALUResult) ? (PC + {{21{instruction[31]}}, instruction[07 : 07], instruction[30 : 25], instruction[11 : 08], 01'h0}) : (PC + 4);
                    3'b111 : PCNext <= (~|IntegerALUResult) ? (PC + {{21{instruction[31]}}, instruction[07 : 07], instruction[30 : 25], instruction[11 : 08], 01'h0}) : (PC + 4);
                    default: PCNext <= PC + 4;
                endcase
            end
            7'b0000011: // Load
            begin
                status <= MM;
                PCNext <= PC + 4;
                case (instruction[14 : 12])
                    3'b010:
                    begin
                        DataAddrIO <= IntegerALUResult;
                    end
                endcase
            end
            7'b0100011: // Store
            begin
                status <= WB;
                PCNext <= PC + 4;
                case (instruction[14 : 12])
                    3'b010:
                    begin
                        DataAddrIO <= IntegerALUResult;
                        DataInsert <= Rs2RegisterOutput;
                        DataEnable <= 1'b1;
                    end
                endcase
            end
            7'b0010011: // OP-IMM
            begin
                status <= WB;
                PCNext <= PC + 4;
                DstRegisterInsert <= IntegerALUResult;
                IntegersEnable <= 1'b1;
            end
            7'b0110011: // OP
            begin
                status <= WB;
                PCNext <= PC + 4;
                DstRegisterInsert <= IntegerALUResult;
                IntegersEnable <= 1'b1;
            end
            default: 
            begin
                status <= WB;
                PCNext <= PC + 4;
            end
            endcase
        end
        MM:
        begin
            case(instruction[6 : 0])
            7'b0000011: // Load
            begin
                status <= WB;
                case (instruction[14 : 12])
                    3'b010:
                    begin
                        #1 DstRegisterInsert <= DataOutput;
                        IntegersEnable <= 1'b1;
                    end 
                endcase
            end
            default: status <= WB;
            endcase
        end
        WB:
        begin
            status <= IF;
            IntegersEnable <= 1'b0;
            DataEnable <= 1'b0;
            PC <= PCNext;
        end
        default:
        begin
            
        end
        endcase
    end
end

endmodule
