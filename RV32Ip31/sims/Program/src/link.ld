OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0x80000000;
  .text : { *(.text) }
  . = 0xC0000000;
  .data : { *(.data) }
  .bss : { *(.bss) }
}

