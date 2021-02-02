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
    input clock,        // ͬ��ʱ���ź�
    input reset,        // ͬ����λ�ź�
    output reg [31 : 0] instruction  // �����ǰִ��ָ��
);

/*
 * �ڲ�ͨ·
 */

// ����ͨ�üĴ�����
reg  IntegersEnable = 1'b0;                                             // ����ͨ�üĴ�����д��ʹ��(ʱ��ʹ��)

wire [$clog2(UNITS) - 1 : 0] DstRegisterNumber = instruction[11 : 07];  // ����ͨ�üĴ����鸴ѡĿ��Ĵ���
wire [$clog2(UNITS) - 1 : 0] Rs1RegisterNumber = instruction[19 : 15];  // ����ͨ�üĴ����鸴ѡԴ�Ĵ���1
wire [$clog2(UNITS) - 1 : 0] Rs2RegisterNumber = instruction[24 : 20];  // ����ͨ�üĴ����鸴ѡԴ�Ĵ���2

reg  [WIDTH - 1 : 0] DstRegisterInsert = {WIDTH{1'b0}};                 // ����ͨ�üĴ�����Ŀ��Ĵ�������д��
wire [WIDTH - 1 : 0] Rs1RegisterOutput;                                 // ����ͨ�üĴ�����Դ�Ĵ���1�������
wire [WIDTH - 1 : 0] Rs2RegisterOutput;                                 // ����ͨ�üĴ�����Դ�Ĵ���2�������

// ���������߼���Ԫ���������˳�����
reg  [3 : 0] IntegerALUOp = 4'b0000;                                    // �����߼���Ԫ������
reg  [WIDTH - 1 : 0] IntegerALUInputA = {WIDTH{1'b0}};                  // �����߼���Ԫ����A
reg  [WIDTH - 1 : 0] IntegerALUInputB = {WIDTH{1'b0}};                  // �����߼���Ԫ����B
wire [WIDTH - 1 : 0] IntegerALUResult;                                  // �����߼���Ԫ���Y

// ָ�����
reg  [WIDTH - 1 : 0] PCNext;                    // ��һ��ַ

// ָ��洢
wire [31 : 0] CodeOutput;                       // ָ�����

// ���ݴ洢
reg  DataEnable = 1'b0;
reg  [WIDTH - 1 : 0] DataAddrIO;                // ���ݵ�ַ
reg  [WIDTH - 1 : 0] DataInsert;                // ��������
wire [WIDTH - 1 : 0] DataOutput;                // �������
/*
 * �ڲ����
 */
// ������ִ��״̬��¼�Ĵ�����ע����RISC-V�ڲ��Ŀ���״̬�Ĵ�������
reg  [2 : 0] status = 3'h0;
localparam IF = 3'h0;
localparam ID = 3'h1;
localparam EX = 3'h2;
localparam MM = 3'h3;
localparam WB = 3'h4;
// localparam E0 = 3'h5;
// localparam E1 = 3'h6;
// localparam E2 = 3'h7;

// PC�Ĵ�������¼��ǰִ��ָ���ַ
reg  [WIDTH - 1 : 0] PC;

// ����ͨ�üĴ�����
GPRs #
(
    .ZERO(1),                 // �����׸��Ĵ����Ƿ�Ϊ��Ĵ�����
                              // ����Ĵ���Ϊ0����Ĵ���Ϊ1
    .WIDTH(WIDTH),            // �����Ĵ���λ��
    .UNITS(UNITS)             // �Ĵ�������
)
Integers
(
    .RST(reset),              // ͬ����λ
    .CLK(clock),              // ͬ��ʱ��
    .WEN(IntegersEnable),     // д��ʹ��(ʱ��ʹ��)
    .DSTs(DstRegisterNumber), // ��ѡĿ��Ĵ���
    .RS1s(Rs1RegisterNumber), // ��ѡԴ�Ĵ���1
    .RS2s(Rs2RegisterNumber), // ��ѡԴ�Ĵ���2
    .DSTi(DstRegisterInsert), // Ŀ��Ĵ�������д��
    .RS1o(Rs1RegisterOutput), // Դ�Ĵ���1�������
    .RS2o(Rs2RegisterOutput)  // Դ�Ĵ���2�������
);

// ���������߼���Ԫ���������˳�����
IntegerALU #
(
    .WIDTH(WIDTH)             // �����߼���Ԫλ��
)
IntegerALU
(
    .OP(IntegerALUOp),        // �����߼���Ԫ������
    .A(IntegerALUInputA),     // �����߼���Ԫ����A
    .B(IntegerALUInputB),     // �����߼���Ԫ����B
    .Y(IntegerALUResult)      // �����߼���Ԫ���Y
);

// ָ��洢
SimpleRAM #
(
    .ADDRW(IMEMW),             // RAM��ַ���
    .DATAW(32),                // RAM���ݿ��
    .DEPTH(2 ** IMEMW),        // RAM�洢���
    .MEMORY_INIT_FILE(ILOAD)   // RAM��ʼ���ļ�
)
IMEM
(
    .CLK(clock),               // ʱ������
    .RST(reset),               // ��λ����
    .WEN(1'b0),                // д��ʹ��
    .CEN(1'b1),                // ʱ��ʹ��
    .ADDR_F(PC[IMEMW + 1 : 2]),// �ڴ��ַ
    .DATA_I(),                 // ��������
    .DATA_O(CodeOutput)        // �������
);

// ���ݴ洢
SimpleRAM #
(
    .ADDRW(DMEMW),             // RAM��ַ���
    .DATAW(WIDTH),             // RAM���ݿ��
    .DEPTH(2 ** DMEMW),        // RAM�洢���
    .MEMORY_INIT_FILE("none")  // RAM��ʼ���ļ�
)
DMEM
(
    .CLK(clock),               // ʱ������
    .RST(reset),               // ��λ����
    .WEN(DataEnable),          // д��ʹ��
    .CEN(1'b1),                // ʱ��ʹ��
    .ADDR_F(DataAddrIO[DMEMW + 1 : 2]), // �ڴ��ַ
    .DATA_I(DataInsert),       // ��������
    .DATA_O(DataOutput)        // �������
);

// ������ִ��״̬��¼�Ĵ���
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
