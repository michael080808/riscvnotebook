# RISC-V RV32I单发射五级流水31指令集CPU

包含指令包括：

* LUI
* AUIPC
* JAL
* JALR
* BRANCH:   BEQ, BNE, BLT, BGE, BLTU, BGEU
* LOAD:     LW
* STORE:    SW
* OP-IMM:   ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
* OP:       ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND

## 关于仿真目录

仿真目录下，Program用于生成仿真用程序内存文件

src文件夹存放汇编文件(*.s)，反汇编文件(*.dump)

dst文件夹存放反汇编转换成仿真所需内存文件(*.mem)

transform文件夹存放python脚本，用于将目录中全部的*.dump转换为*.mem，使用方法为python script.py <src_dir> <dst_dir>