.section .text
# Data Segment
.align 2
.data
mem:
    .word   00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00, 00
# Code Segment
.global _start
_start:
    li      ra,   1     # x1
    li      sp,   2     # x2
    li      gp,   3     # x3
    li      tp,   4     # x4
    li      t0,   5     # x5
    li      t1,   6     # x6
    li      t2,   7     # x7
    li      fp,   8     # x8
    li      s1,   9     # x9
    li      a0,   10    # x10
    li      a1,   11    # x11
    li      a2,   12    # x12
    li      a3,   13    # x13
    li      a4,   14    # x14
    li      a5,   15    # x15
    li      a6,   16    # x16
    li      a7,   17    # x17
    li      s2,   18    # x18
    li      s3,   19    # x19
    li      s4,   20    # x20
    li      s5,   21    # x21
    li      s6,   22    # x22
    li      s7,   23    # x23
    li      s8,   24    # x24
    li      s9,   25    # x25
    li      s10,  26    # x26
    li      s11,  27    # x27
    li      t3,   28    # x28
    li      t4,   29    # x29
    li      t5,   30    # x30
    li      t6,   31    # x31
    li      zero, 32    # x0

store:
    la      t0,   mem
    li      t1,   0
    li      t2,   128

store_loop:
    add     t3,   t0,   t1
    sw      t1,   0(t3)
    addi    t1,   t1,   4
    blt     t1,   t2,   store_loop

loads:
    la      t0,   mem
    li      t1,   0
    li      t2,   128

loads_loop:
    add     t3,   t0,   t1
    lw      t4,   0(t3)
    addi    t1,   t1,   4
    blt     t1,   t2,   loads_loop

calc:
    # OP-IMM
    # addi
    li      t0,   2020
    addi    t0,   t0,   1000 
    li      t1,   3020
    bne     t0,   t1,   calc_error
    # slti
    li      t0,   -1000
    slti    t0,   t0,   -2020
    li      t1,   0
    bne     t0,   t1,   calc_error
    # sltiu
    li      t0,   +1000
    sltiu   t0,   t0,   +2020
    li      t1,   1
    bne     t0,   t1,   calc_error
    # xori
    li      t0,   0b011111100100
    xori    t0,   t0,   0b001111101000
    li      t1,   0b010000001100
    bne     t0,   t1,   calc_error
    # ori
    li      t0,   0b011111100100
    ori     t0,   t0,   0b001111101000
    li      t1,   0b011111101100
    bne     t0,   t1,   calc_error
    # andi
    li      t0,   0b011111100100
    andi    t0,   t0,   0b001111101000
    li      t1,   0b001111100000
    bne     t0,   t1,   calc_error
    # slli
    li      t0,   0b00000000000000000000011111100100
    slli    t0,   t0,   4
    li      t1,   0b00000000000000000111111001000000
    bne     t0,   t1,   calc_error
    # srli
    li      t0,   0b11111111111111111111100000011100
    srli    t0,   t0,   4
    li      t1,   0b00001111111111111111111110000001
    bne     t0,   t1,   calc_error
    # srai
    li      t0,   0b11111111111111111111100000011100
    srai    t0,   t0,   4
    li      t1,   0b11111111111111111111111110000001
    bne     t0,   t1,   calc_error

    # OP
    # add
    li      t0,   2020
    li      t1,   1000
    add     t2,   t0,   t1
    li      t3,   3020
    bne     t2,   t3,   calc_error
    # sub
    li      t0,   2020
    li      t1,   1000
    sub     t2,   t0,   t1
    li      t3,   1020
    bne     t2,   t3,   calc_error
    # sll
    li      t0,   0b00000000000000000000011111100100
    li      t1,   4
    sll     t2,   t0,   t1
    li      t3,   0b00000000000000000111111001000000
    bne     t2,   t3,   calc_error
    # slt
    li      t0,   -1000
    li      t1,   -2020
    slt     t2,   t0,   t1
    li      t3,   0
    bne     t2,   t3,   calc_error
    # sltu
    li      t0,   +1000
    li      t1,   +2020
    sltu    t2,   t0,   t1
    li      t3,   1
    bne     t2,   t3,   calc_error
    # xor
    li      t0,   0b011111100100
    li      t1,   0b001111101000
    xor     t2,   t0,   t1   
    li      t3,   0b010000001100
    bne     t2,   t3,   calc_error
    # srl
    li      t0,   0b11111111111111111111100000011100
    li      t1,   4
    srl     t2,   t0,   t1
    li      t3,   0b00001111111111111111111110000001
    bne     t2,   t3,   calc_error
    # sra
    li      t0,   0b11111111111111111111100000011100
    li      t1,   4
    sra     t2,   t0,   t1
    li      t3,   0b11111111111111111111111110000001
    bne     t2,   t3,   calc_error
    # or
    li      t0,   0b011111100100
    li      t1,   0b001111101000
    or      t2,   t0,   t1
    li      t3,   0b011111101100
    bne     t2,   t3,   calc_error
    # and
    li      t0,   0b011111100100
    li      t1,   0b001111101000
    and     t2,   t0,   t1
    li      t3,   0b001111100000
    bne     t2,   t3,   calc_error
    
    # jump to branch
    j       branch_1

calc_error:
    j       calc_error

branch_1:
    # beq
    li      t0,   2020
    li      t1,   2020
    bne     t0,   t1,   branch_2
    beq     t0,   t1,   branch_3

branch_2:
    # bne
    li      t0,   2020
    li      t1,   2021
    beq     t0,   t1,   branch_3
    bne     t0,   t1,   branch_4

branch_3:
    # blt
    li      t0,   -2021
    li      t1,   -2020
    bge     t0,   t1,   branch_4
    blt     t0,   t1,   branch_5

branch_4:
    # bge
    li      t0,   -2020
    li      t1,   -2020
    blt     t0,   t1,   branch_5
    bge     t0,   t1,   branch_6

branch_5:
    # bltu
    li      t0,   2020
    li      t1,   2021
    bge     t0,   t1,   branch_6
    blt     t0,   t1,   branch_2

branch_6:
    # bgeu
    li      t0,   2020
    li      t1,   2020
    blt     t0,   t1,   branch_1
    bge     t0,   t1,   final

final:
    j       final
