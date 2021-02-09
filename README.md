# RISC-V 设计学习笔记

本项目用于记录作者在日常学习设计

基于RISC-V指令集的处理器时的源文件和文档

由于作者对Verilog HDL最为熟悉

因此项目均以Verilog HDL作为主要的开发语言

编程环境主要使用Xilinx Vivado Design Suite

可能会用到HDL Designer，X-HDL，Modelsim等常见开发工具

会在具体的设计文档中记录所使用的工具和使用方法

## 目录结构

更新于2020年8月29日

| 文件夹名称 |                           包含内容                            |
|:----------:|:-------------------------------------------------------------:|
| Components |              处理器设计过程中需要的通用设计部件               |
| Documents  |        RISC-V 非特权指令、特权指令、SIMD("V"扩展)文档         |
|  RV32Is31  |     使用RV32I指令集中31条指令集所构成的子集的单周期处理器     |
|  RV32Is37  |     使用RV32I指令集中37条指令集所构成的子集的单周期处理器     |
|  RV32Im31  |     使用RV32I指令集中31条指令集所构成的子集的多周期处理器     |
|  RV32Ip31  | 使用RV32I指令集中31条指令集所构成的子集的单发射五级流水处理器 |
