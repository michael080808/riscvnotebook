# 桶形移位器

用于整型数据的逻辑(算术)左移、逻辑右移、算术右移计算

## 设计细节

理论上使用Verilog HDL语法中的

桶形移位实现相应功能是没有问题的

但是在对比了不同的实现方式后

会发现不同的实现方法存在占用资源(主要为LUT)的差异

同时不同的实现方法潜在上存在不同的延迟差异

因此将独立实现的实现的左移、右移模块

以及组合后实现的移位器模块提供了类型选择功能

方便使用时进行选择和修改

如图所示是将逻辑(算术)左移、逻辑右移、算术右移融合后的16位桶形移位器

![16-bit Complex Barrel Shifter](./imgs/16-bit%20Complex%20Barrel%20Shifter.png)

本质上，桶形移位器是将移位2的N次幂的位移选择器依次进行级联

从而将位移次数从M次降低到log2(M)次，提高计算速度

该部分代码比较简单，易于理解，因此不在代码中添加注释