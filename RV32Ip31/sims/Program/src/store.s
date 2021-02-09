# Data Segment
.align 2
.data
var:
    .word   0x00000000
.text
.global _start
_start:
    la      t0,     var
    li      t1,     0x12345678
    sw      t1,     0(t0)
    li      t1,     0x87654321
    lw      t2,     0(t0)
    add     t2,     t2,     t1
