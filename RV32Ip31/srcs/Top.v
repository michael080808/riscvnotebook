`timescale 1ns / 1ps

module Top #
(
    parameter WIDTH = 32,
    parameter UNITS = 32,
    parameter IMEMW = 14,
    parameter DMEMW = 14,
    parameter ILOAD = "none",
    parameter DLOAD = "none",
    parameter CINIT = 32'h80000000
)
(
    input  wire                 clock,                      // 时钟输入
    input  wire                 reset                       // 复位输入: 高电平重置
);

/*
 * 流水通路
 */

// IF: Instruction Fetch
reg  [WIDTH          - 1 : 0] IP;                           // 程序计数器: 用于指令存储访问取指
wire [WIDTH          - 1 : 0] P4 = IP + 4;                  // 下一条指令地址计算
wire [31                 : 0] IO;                           // 指令输出

// IF/ID
reg  [WIDTH          - 1 : 0] PC;                           // 程序计数器
reg  [31                 : 0] IR;                           // 指令寄存器

// ID: Instruction Decode
wire [31                 : 0] IN;
wire [6                  : 0] OP     = IN[06 : 00];         // 指令操作码
wire [$clog2(UNITS)  - 1 : 0] RD0_No = IN[11 : 07];         // 目标寄存器编号
wire [$clog2(UNITS)  - 1 : 0] RS1_No = IN[19 : 15];         // 源一寄存器编号
wire [$clog2(UNITS)  - 1 : 0] RS2_No = IN[24 : 20];         // 源二寄存器编号
wire [WIDTH          - 1 : 0] RS1_Ro;
wire [WIDTH          - 1 : 0] RS2_Ro;
reg  [WIDTH          - 1 : 0] RS1_Rm;
reg  [WIDTH          - 1 : 0] RS2_Rm;
wire [2                  : 0] Funct3 = IN[14 : 12];         // 三位功能编码区
wire [6                  : 0] Funct7 = IN[31 : 25];         // 七位功能编码区
wire [WIDTH          - 1 : 0] IMM_Ix = {{WIDTH - 11{IN[31]}}, IN[30 : 20]};                             // Load, JALR, OP-IMM 
wire [WIDTH          - 1 : 0] IMM_Ux = {{WIDTH - 31{IN[31]}}, IN[30 : 12], 12'h0};                      // LUI, AUIPC
wire [WIDTH          - 1 : 0] IMM_Sx = {{WIDTH - 11{IN[31]}}, IN[30 : 25], IN[11 : 07]};                // Store
wire [WIDTH          - 1 : 0] IMM_Bx = {{WIDTH - 12{IN[31]}}, IN[07], IN[30 : 25], IN[11 : 08], 1'b0};  // Branch
wire [WIDTH          - 1 : 0] IMM_Jx = {{WIDTH - 31{IN[31]}}, IN[19 : 12], IN[20], IN[30 : 21], 1'b0};  // JAL

// ID/EX
reg  [3                  : 0] ALU_OP;
reg  [WIDTH          - 1 : 0] ALU_Ia;
reg  [WIDTH          - 1 : 0] ALU_Ib;
reg  [WIDTH          - 1 : 0] ADD_Ia;
reg  [WIDTH          - 1 : 0] ADD_Ib;
reg                           ResSrc;

reg                           JMP_En;
reg                           JMP_Tp;
reg                           BRC_Zf;

reg  [$clog2(UNITS)  - 1 : 0] RD0_N1;
reg                           MEM_A1;
reg                           MEM_W1;

// EX: Execution
wire [WIDTH          - 1 : 0] ADD_Ro;
wire [WIDTH          - 1 : 0] ALU_Ro;
wire                          ZFL_Ro;
wire                          BRC_Ro;

// EX/MM
reg  [WIDTH          - 1 : 0] MemA;
reg  [WIDTH          - 1 : 0] MemI;

reg  [$clog2(UNITS)  - 1 : 0] RD0_N2;
reg                           MEM_A2;
reg                           MEM_W2;

// MM: Access Memories
wire [WIDTH          - 1 : 0] MemO;

// MM/WB
reg  [WIDTH          - 1 : 0] MemD;
reg  [WIDTH          - 1 : 0] Data;

reg  [$clog2(UNITS)  - 1 : 0] RD0_N3;
reg                           RD0Src;

// WB: Write Back
wire [WIDTH          - 1 : 0] RD0Dst;

/*
 * 流水各阶段模块
 */

/* IF */

// 指令存储
SimpleRAM #
(
    .ADDRW(IMEMW),                              // RAM地址宽度
    .DATAW(32),                                 // RAM数据宽度
    .DEPTH(2 ** IMEMW),                         // RAM存储深度
    .MEMORY_INIT_FILE(ILOAD)                    // RAM初始化文件
)
IMEM
(
    .CLK(~clock),                               // 时钟输入
    .RST( reset),                               // 复位输入
    .WEN(1'b0),                                 // 写入使能
    .CEN(1'b1),                                 // 时钟使能
    .ADDR_F(IP[IMEMW + 1 : 2]),                 // 内存地址
    .DATA_I(),                                  // 数据输入
    .DATA_O(IO)                                 // 数据输出
);

always @(posedge clock) begin
    if(reset)
    begin
        IP <= CINIT;
        PC <= CINIT;
        IR <= 32'h00000013;
    end
    else
    begin
        PC <= IP;
        if(JMP_En & (JMP_Tp | BRC_Ro))
        begin
            if(JMP_Tp)
            begin
                IP <= ALU_Ro;
                IR <= 32'h00000013;
            end
            else
            begin
                IP <= ADD_Ro;
                IR <= 32'h00000013;
            end
        end
        else
        begin
            if(IR[06 : 00] == 7'b0000011) // Load
            begin
                case(IO[06 : 00])
                7'b1100111: // JALR
                begin
                    if(IO[19 : 15] == IR[11 : 07])
                    begin
                        IP <= IP;
                        IR <= 32'h00000013;
                    end
                    else
                    begin
                        IP <= P4;
                        IR <= IO;
                    end
                end
                7'b1100011: // Branch
                begin
                    if(IO[19 : 15] == IR[11 : 07] || IO[24 : 20] == IR[11 : 07])
                    begin
                        IP <= IP;
                        IR <= 32'h00000013;
                    end
                    else
                    begin
                        IP <= P4;
                        IR <= IO;
                    end
                end
                7'b0000011: // Load
                begin
                    if(IO[19 : 15] == IR[11 : 07])
                    begin
                        IP <= IP;
                        IR <= 32'h00000013;
                    end
                    else
                    begin
                        IP <= P4;
                        IR <= IO;
                    end
                end
                7'b0100011: // Store
                begin
                    if(IO[19 : 15] == IR[11 : 07] || IO[24 : 20] == IR[11 : 07])
                    begin
                        IP <= IP;
                        IR <= 32'h00000013;
                    end
                    else
                    begin
                        IP <= P4;
                        IR <= IO;
                    end
                end
                7'b0010011: // OP-IMM
                begin
                    if(IO[19 : 15] == IR[11 : 07])
                    begin
                        IP <= IP;
                        IR <= 32'h00000013;
                    end
                    else
                    begin
                        IP <= P4;
                        IR <= IO;
                    end
                end
                7'b0110011: // OP
                begin
                    if(IO[19 : 15] == IR[11 : 07] || IO[24 : 20] == IR[11 : 07])
                    begin
                        IP <= IP;
                        IR <= 32'h00000013;
                    end
                    else
                    begin
                        IP <= P4;
                        IR <= IO;
                    end
                end
                default:
                begin
                    IP <= P4;
                    IR <= IO;
                end
                endcase
            end 
            else
            begin
                IP <= P4;
                IR <= IO;
            end
        end
    end
end

/* ID */

// 整数通用寄存器组
GPRs #
(
    .ZERO(1),                                   // 配置首个寄存器是否为零寄存器，
                                                // 常规寄存器为0，零寄存器为1
    .WIDTH(WIDTH),                              // 单个寄存器位宽
    .UNITS(UNITS)                               // 寄存器总数
)
Integers
(
    .RST(reset),                                // 同步复位
    .CLK(clock),                                // 同步时钟
    .WEN(1'b1),                                 // 写入使能(时钟使能)
    .DSTs(RD0_N3),                              // 复选目标寄存器
    .RS1s(RS1_No),                              // 复选源寄存器1
    .RS2s(RS2_No),                              // 复选源寄存器2
    .DSTi(RD0Dst),                              // 目标寄存器数据写入
    .RS1o(RS1_Ro),                              // 源寄存器1数据输出
    .RS2o(RS2_Ro)                               // 源寄存器2数据输出
);

assign IN = (JMP_En & (JMP_Tp | BRC_Ro)) ? 32'h00000013 : IR;

always @(*) begin
    // RS1
    casez({|RS1_No, RS1_No == RD0_N1, RS1_No == RD0_N2, RS1_No == RD0_N3})
    4'b11zz: RS1_Rm <= ResSrc ? ADD_Ro : ALU_Ro;
    4'b101z: RS1_Rm <= MEM_A2 ? MemO : MemI;
    4'b1001: RS1_Rm <= RD0Src ? MemO : Data;
    default: RS1_Rm <= RS1_Ro;
    endcase

    // RS2
    casez({|RS2_No, RS2_No == RD0_N1, RS2_No == RD0_N2, RS2_No == RD0_N3})
    4'b11zz: RS2_Rm <= ResSrc ? ADD_Ro : ALU_Ro;
    4'b101z: RS2_Rm <= MEM_A2 ? MemO : MemI;
    4'b1001: RS2_Rm <= RD0Src ? MemO : Data;
    default: RS2_Rm <= RS2_Ro;
    endcase
end

always @(posedge clock) begin
    case (OP)
    7'b0110111: // LUI
    begin
        ALU_OP <= 4'b0000;
        ALU_Ia <= {WIDTH{1'b0}};
        ALU_Ib <= IMM_Ux;
        ADD_Ia <= {WIDTH{1'b0}};
        ADD_Ib <= {WIDTH{1'b0}};
        ResSrc <= 1'b0;

        JMP_En <= 1'b0;
        JMP_Tp <= 1'b0;
        BRC_Zf <= 1'b0;

        RD0_N1 <= RD0_No;
        MEM_A1 <= 1'b0;
        MEM_W1 <= 1'b0;
    end
    7'b0010111: // AUIPC
    begin
        ALU_OP <= 4'b0000;
        ALU_Ia <= PC;
        ALU_Ib <= IMM_Ux;
        ADD_Ia <= {WIDTH{1'b0}};
        ADD_Ib <= {WIDTH{1'b0}};
        ResSrc <= 1'b0;

        JMP_En <= 1'b0;
        JMP_Tp <= 1'b0;
        BRC_Zf <= 1'b0;

        RD0_N1 <= RD0_No;
        MEM_A1 <= 1'b0;
        MEM_W1 <= 1'b0;
    end
    7'b1101111: // JAL
    begin
        ALU_OP <= 4'b0000;
        ALU_Ia <= PC;
        ALU_Ib <= IMM_Jx;
        ADD_Ia <= PC;
        ADD_Ib <= 4;
        ResSrc <= 1'b1;

        JMP_En <= 1'b1;
        JMP_Tp <= 1'b1;
        BRC_Zf <= 1'b0;

        RD0_N1 <= RD0_No;
        MEM_A1 <= 1'b0;
        MEM_W1 <= 1'b0;
    end
    7'b1100111: // JALR
    begin
        ALU_OP <= 4'b0000;
        ALU_Ia <= RS1_Rm;
        ALU_Ib <= IMM_Ix;
        ADD_Ia <= PC;
        ADD_Ib <= 4;
        ResSrc <= 1'b1;

        JMP_En <= 1'b1;
        JMP_Tp <= 1'b1;
        BRC_Zf <= 1'b0;

        RD0_N1 <= RD0_No;
        MEM_A1 <= 1'b0;
        MEM_W1 <= 1'b0;
    end
    7'b1100011: // Branch
    begin
        casez (Funct3)
        3'b00z : ALU_OP <= 4'b0001;
        3'b10z : ALU_OP <= 4'b0100;
        3'b11z : ALU_OP <= 4'b0110;
        default: ALU_OP <= 4'b0000;
        endcase
        ALU_Ia <= RS1_Rm;
        ALU_Ib <= RS2_Rm;
        ADD_Ia <= PC;
        ADD_Ib <= IMM_Bx;
        ResSrc <= 1'b0;

        JMP_En <= 1'b1;
        JMP_Tp <= 1'b0;
        casez (Funct3)
        3'b000 : BRC_Zf <= 1'b1;
        3'b1z1 : BRC_Zf <= 1'b1;
        default: BRC_Zf <= 1'b0;
        endcase

        RD0_N1 <= {$clog2(UNITS){1'b0}};
        MEM_A1 <= 1'b0;
        MEM_W1 <= 1'b0;
    end
    7'b0000011: // Load
    begin
        ALU_OP <= 4'b0000;
        ALU_Ia <= RS1_Rm;
        ALU_Ib <= IMM_Ix;
        ADD_Ia <= {WIDTH{1'b0}};
        ADD_Ib <= {WIDTH{1'b0}};
        ResSrc <= 1'b0;

        JMP_En <= 1'b0;
        JMP_Tp <= 1'b0;
        BRC_Zf <= 1'b0;

        RD0_N1 <= RD0_No;
        MEM_A1 <= 1'b1;
        MEM_W1 <= 1'b0;
    end
    7'b0100011: // Store
    begin
        ALU_OP <= 4'b0000;
        ALU_Ia <= RS1_Rm;
        ALU_Ib <= IMM_Sx;
        ADD_Ia <= RS2_Rm;
        ADD_Ib <= {WIDTH{1'b0}};
        ResSrc <= 1'b1;

        JMP_En <= 1'b0;
        JMP_Tp <= 1'b0;
        BRC_Zf <= 1'b0;

        RD0_N1 <= {$clog2(UNITS){1'b0}};
        MEM_A1 <= 1'b1;
        MEM_W1 <= 1'b1;
    end
    7'b0010011: // OP-IMM
    begin
        casez(Funct3)
        3'bz01 : ALU_OP <= {Funct3, Funct7[5]};
        default: ALU_OP <= {Funct3, 1'b0};
        endcase
        ALU_Ia <= RS1_Rm;
        ALU_Ib <= IMM_Ix;
        ADD_Ia <= {WIDTH{1'b0}};
        ADD_Ib <= {WIDTH{1'b0}};
        ResSrc <= 1'b0;

        JMP_En <= 1'b0;
        JMP_Tp <= 1'b0;
        BRC_Zf <= 1'b0;

        RD0_N1 <= RD0_No;
        MEM_A1 <= 1'b0;
        MEM_W1 <= 1'b0;
    end
    7'b0110011: // OP
    begin
        ALU_OP <= {Funct3, Funct7[5]};
        ALU_Ia <= RS1_Rm;
        ALU_Ib <= RS2_Rm;
        ADD_Ia <= {WIDTH{1'b0}};
        ADD_Ib <= {WIDTH{1'b0}};
        ResSrc <= 1'b0;

        JMP_En <= 1'b0;
        JMP_Tp <= 1'b0;
        BRC_Zf <= 1'b0;

        RD0_N1 <= RD0_No;
        MEM_A1 <= 1'b0;
        MEM_W1 <= 1'b0;
    end
    default: 
    begin
        ALU_OP <= 4'b0000;
        ALU_Ia <= {WIDTH{1'b0}};
        ALU_Ib <= {WIDTH{1'b0}};
        ADD_Ia <= {WIDTH{1'b0}};
        ADD_Ib <= {WIDTH{1'b0}};
        ResSrc <= 1'b0;

        JMP_En <= 1'b0;
        JMP_Tp <= 1'b0;
        BRC_Zf <= 1'b0;

        RD0_N1 <= {$clog2(UNITS){1'b0}};
        MEM_A1 <= 1'b0;
        MEM_W1 <= 1'b0;
    end
    endcase
end

/* EX */

// 整数算数逻辑单元（不包含乘除法）
IntegerALU #
(
    .WIDTH(WIDTH)                               // 算术逻辑单元位数
)
IntegerALU
(
    .OP(ALU_OP),                                // 算术逻辑单元操作码
    .A (ALU_Ia),                                // 算术逻辑单元输入A
    .B (ALU_Ib),                                // 算术逻辑单元输入B
    .Y (ALU_Ro)                                 // 算术逻辑单元输出Y
);

// 额外加法计算单元
assign ADD_Ro = ADD_Ia + ADD_Ib;

// 条件跳转计算单元
assign ZFL_Ro =|ALU_Ro;
assign BRC_Ro = BRC_Zf ?~ZFL_Ro : ZFL_Ro;

always @(posedge clock) begin
    MemA <= ALU_Ro;
    MemI <= ResSrc ? ADD_Ro : ALU_Ro;
    RD0_N2 <= RD0_N1;
    MEM_A2 <= MEM_A1;
    MEM_W2 <= MEM_W1;
end

/* MM */

// 数据存储
SimpleRAM #
(
    .ADDRW(DMEMW),                              // RAM地址宽度
    .DATAW(WIDTH),                              // RAM数据宽度
    .DEPTH(2 ** DMEMW),                         // RAM存储深度
    .MEMORY_INIT_FILE(DLOAD)                    // RAM初始化文件
)
DMEM
(
    .CLK(~clock),                               // 时钟输入
    .RST( reset),                               // 复位输入
    .WEN(MEM_W2),                               // 写入使能
    .CEN(1'b1),                                 // 时钟使能
    .ADDR_F(MemA[DMEMW + 1 : 2]),               // 内存地址
    .DATA_I(MemI),                              // 数据输入
    .DATA_O(MemO)                               // 数据输出
);

always @(posedge clock) begin
    MemD <= MemO;
    Data <= MemI;
    RD0_N3 <= RD0_N2;
    RD0Src <= MEM_A2;
end

/* WB */
assign RD0Dst = RD0Src ? MemO : Data;

endmodule
