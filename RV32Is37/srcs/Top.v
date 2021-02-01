`timescale 1ns / 1ps

module Top #
(
    parameter WIDTH = 32,
    parameter UNITS = 32,
    parameter IMEMW = 14,
    parameter DMEMW = 12,
    parameter DMEMU = 08,
    parameter DMEMG = 04,
    parameter ILOAD = "none"
)
(
    input clock,        // ͬ��ʱ���ź�
    input reset,        // ͬ����λ�ź�
    output [31 : 0] instruction  // �����ǰִ��ָ��
);

/*
 * �ڲ�ͨ·
 */
reg  IntegersEnable;                                                    // ����ͨ�üĴ�����д��ʹ��(ʱ��ʹ��)
wire [$clog2(UNITS) - 1 : 0] DstRegisterNumber = instruction[11 : 07];  // ����ͨ�üĴ����鸴ѡĿ��Ĵ���
wire [$clog2(UNITS) - 1 : 0] Rs1RegisterNumber = instruction[19 : 15];  // ����ͨ�üĴ����鸴ѡԴ�Ĵ���1
wire [$clog2(UNITS) - 1 : 0] Rs2RegisterNumber = instruction[24 : 20];  // ����ͨ�üĴ����鸴ѡԴ�Ĵ���2
reg  [WIDTH - 1 : 0] DstRegisterInsert;                                 // ����ͨ�üĴ�����Ŀ��Ĵ�������д��
wire [WIDTH - 1 : 0] Rs1RegisterOutput;                                 // ����ͨ�üĴ�����Դ�Ĵ���1�������
wire [WIDTH - 1 : 0] Rs2RegisterOutput;                                 // ����ͨ�üĴ�����Դ�Ĵ���2�������

reg  [3 : 0] IntegerALUOp;                                              // ���������߼���Ԫ������
wire [WIDTH - 1 : 0] IntegerALUInputA = Rs1RegisterOutput;              // ���������߼���Ԫ����A
reg  [WIDTH - 1 : 0] IntegerALUInputB;                                  // ���������߼���Ԫ����B
wire [WIDTH - 1 : 0] IntegerALUResult;                                  // ���������߼���Ԫ���Y

reg  [DMEMG - 1 : 0] DataEnable;                                        // DMEMд��ʹ��
wire [WIDTH - 1 : 0] DataInsert = Rs2RegisterOutput;                    // DMEM��������
wire [WIDTH - 1 : 0] DataOutput;                                        // DMEM�������

/*
 * �ڲ����
 */
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
    .CLK(~clock),              // ʱ������
    .RST(reset),               // ��λ����
    .WEN(1'b0),                // д��ʹ��
    .CEN(1'b1),                // ʱ��ʹ��
    .ADDR_F(PC[IMEMW + 1 : 2]),// �ڴ��ַ
    .DATA_I(),                 // ��������
    .DATA_O(instruction)       // �������
);

// ���ݴ洢
ExtendRAM #
(
    .ADDRW(DMEMW),             // RAM��ַ���
    .UNITW(DMEMU),             // RAMÿ����Ԫ���
    .GROUP(DMEMG),             // RAMÿ�鵥Ԫ����
    .DEPTH(2 ** DMEMW)         // RAM�洢���
)
DMEM
(
    .CLK(clock),               // ʱ������
    .RST(reset),               // ��λ����
    .CEN(1'b1),                // ʱ��ʹ��
    .WEN(DataEnable),          // д��ʹ��
    .ADDR_H(IntegerALUResult[DMEMW + $clog2(DMEMG) - 1 : $clog2(DMEMG)]), // ��ַ��λ(���)
    .ADDR_L(IntegerALUResult[$clog2(DMEMG) - 1 : 0]), // ��ַ��λ(���)
    .DATA_I(DataInsert),       // ��������
    .DATA_O(DataOutput),       // �������
    .OVF()                     // ��ַ���
);

// PC�Ĵ���
always @(posedge clock) begin
    if (reset)
    begin
        PC <= {1'b1, {WIDTH - 1{1'b0}}};
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

// GPRs��DSTĿ��Ĵ���
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
        case (instruction[14 : 12])
        3'b000 : // LB
        begin
            IntegersEnable <= 1'b1;
            DstRegisterInsert <= {{24{DataOutput[07]}}, DataOutput[07 : 00]};
        end
        3'b001 : // LH
        begin
            IntegersEnable <= 1'b1;
            DstRegisterInsert <= {{16{DataOutput[15]}}, DataOutput[15 : 00]};
        end
        3'b010 : // LW
        begin
            IntegersEnable <= 1'b1;
            DstRegisterInsert <= {DataOutput};
        end
        3'b100 : // LBU
        begin
            IntegersEnable <= 1'b1;
            DstRegisterInsert <= {24'h0, DataOutput[07 : 00]};
        end
        3'b101 : // LHU
        begin
            IntegersEnable <= 1'b1;
            DstRegisterInsert <= {16'h0, DataOutput[15 : 00]};
        end
        default: 
        begin
            IntegersEnable <= 1'b0;
            DstRegisterInsert <= {DataOutput};
        end
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

// DMEMд��ʹ�ܿ���
always @(*) begin
    case (instruction[6 : 0])
    7'b0100011: // STORE
    begin
        case (instruction[14 : 12])
        3'b000 : DataEnable <= 4'b0001;
        3'b001 : DataEnable <= 4'b0011;
        3'b010 : DataEnable <= 4'b1111;
        default: DataEnable <= 4'b0000;
        endcase
    end
    default:    DataEnable <= 4'b0000;
    endcase
end

// �����߼���Ԫ����B
always @(*) begin
    casez (instruction[6 : 0])
    7'b00z0011: IntegerALUInputB <= {{21{instruction[31]}}, instruction[30 : 20]};                       // LOAD & OP-IMM
    7'b0100011: IntegerALUInputB <= {{21{instruction[31]}}, instruction[30 : 25], instruction[11 : 07]}; // STORE
    default:    IntegerALUInputB <= Rs2RegisterOutput;
    endcase
end

// �����߼���Ԫ������
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
