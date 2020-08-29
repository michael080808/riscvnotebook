# 整型算术逻辑单元

用于RV32I/RV32E/RV64I/RV128I的可变宽度的整型算术逻辑单元

支持以下运算：

* 整型加法、整型减法

* 按位逻辑与、按位逻辑或、按位逻辑异或

* 逻辑/算术左移、逻辑右移、算术右移

* 无符号数小于比较、有符号数小于比较

## 设计细节

该类计算包含的指令种类有2种

<table style="text-align: center;">
    <tr>
        <th>类型</th>
        <th>31</th>
        <th>30</th>
        <th>29</th>
        <th>28</th>
        <th>27</th>
        <th>26</th>
        <th>25</th>
        <th>24</th>
        <th>23</th>
        <th>22</th>
        <th>21</th>
        <th>20</th>
        <th>19</th>
        <th>18</th>
        <th>17</th>
        <th>16</th>
        <th>15</th>
        <th>14</th>
        <th>13</th>
        <th>12</th>
        <th>11</th>
        <th>10</th>
        <th>09</th>
        <th>08</th>
        <th>07</th>
        <th>06</th>        
        <th>05</th>
        <th>04</th>        
        <th>03</th>
        <th>02</th>        
        <th>01</th>
        <th>00</th>
    </tr>
    <tr>
        <td align="center">TypeI</td>
        <td align="center" colspan="12">imm[11 : 0]</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center" colspan="3">funct3</td>
        <td align="center" colspan="5">rd</td>
        <td align="center" colspan="7">opcode</td>
    </tr>
    <tr>
        <td align="center">TypeR</td>
        <td align="center" colspan="7">funct7</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center" colspan="3">funct3</td>
        <td align="center" colspan="5">rd</td>
        <td align="center" colspan="7">opcode</td>
    </tr>
</table>

先以funct3为序，之后以funct7为序，对相关指令进行排序，得到下表

### RV32I寄存器寻址

<table style="text-align: center;">
    <tr>
        <th>指令</th>
        <th>31</th>
        <th>30</th>
        <th>29</th>
        <th>28</th>
        <th>27</th>
        <th>26</th>
        <th>25</th>
        <th>24</th>
        <th>23</th>
        <th>22</th>
        <th>21</th>
        <th>20</th>
        <th>19</th>
        <th>18</th>
        <th>17</th>
        <th>16</th>
        <th>15</th>
        <th>14</th>
        <th>13</th>
        <th>12</th>
        <th>11</th>
        <th>10</th>
        <th>09</th>
        <th>08</th>
        <th>07</th>
        <th>06</th>
        <th>05</th>
        <th>04</th>
        <th>03</th>
        <th>02</th>
        <th>01</th>
        <th>00</th>
    </tr>
    <tr>
        <td align="center">ADD</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SUB</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SLL</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SLT</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SLTU</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">XOR</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SRL</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SRA</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">OR</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">AND</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
</table>

### RV32I立即寻址

<table style="text-align: center;">
    <tr>
        <th>指令</th>
        <th>31</th>
        <th>30</th>
        <th>29</th>
        <th>28</th>
        <th>27</th>
        <th>26</th>
        <th>25</th>
        <th>24</th>
        <th>23</th>
        <th>22</th>
        <th>21</th>
        <th>20</th>
        <th>19</th>
        <th>18</th>
        <th>17</th>
        <th>16</th>
        <th>15</th>
        <th>14</th>
        <th>13</th>
        <th>12</th>
        <th>11</th>
        <th>10</th>
        <th>09</th>
        <th>08</th>
        <th>07</th>
        <th>06</th>
        <th>05</th>
        <th>04</th>
        <th>03</th>
        <th>02</th>
        <th>01</th>
        <th>00</th>
    </tr>
    <tr>
        <td align="center">ADDI</td>
        <td align="center" colspan="12">imm[11 : 0]</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SLLI</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">shamt</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SLTI</td>
        <td align="center" colspan="12">imm[11 : 0]</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SLTIU</td>
        <td align="center" colspan="12">imm[11 : 0]</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">XORI</td>
        <td align="center" colspan="12">imm[11 : 0]</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SRLI</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">shamt</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SRAI</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">shamt</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">ORI</td>
        <td align="center" colspan="12">imm[11 : 0]</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">ANDI</td>
        <td align="center" colspan="12">imm[11 : 0]</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
</table>

### RV64I寄存器寻址

<table style="text-align: center;">
    <tr>
        <th>指令</th>
        <th>31</th>
        <th>30</th>
        <th>29</th>
        <th>28</th>
        <th>27</th>
        <th>26</th>
        <th>25</th>
        <th>24</th>
        <th>23</th>
        <th>22</th>
        <th>21</th>
        <th>20</th>
        <th>19</th>
        <th>18</th>
        <th>17</th>
        <th>16</th>
        <th>15</th>
        <th>14</th>
        <th>13</th>
        <th>12</th>
        <th>11</th>
        <th>10</th>
        <th>09</th>
        <th>08</th>
        <th>07</th>
        <th>06</th>
        <th>05</th>
        <th>04</th>
        <th>03</th>
        <th>02</th>
        <th>01</th>
        <th>00</th>
    </tr>
    <tr>
        <td align="center">ADDW</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SUBW</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SLLW</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SRLW</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SRAW</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rs2</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
</table>

### RV64I立即寻址

<table style="text-align: center;">
    <tr>
        <th>指令</th>
        <th>31</th>
        <th>30</th>
        <th>29</th>
        <th>28</th>
        <th>27</th>
        <th>26</th>
        <th>25</th>
        <th>24</th>
        <th>23</th>
        <th>22</th>
        <th>21</th>
        <th>20</th>
        <th>19</th>
        <th>18</th>
        <th>17</th>
        <th>16</th>
        <th>15</th>
        <th>14</th>
        <th>13</th>
        <th>12</th>
        <th>11</th>
        <th>10</th>
        <th>09</th>
        <th>08</th>
        <th>07</th>
        <th>06</th>
        <th>05</th>
        <th>04</th>
        <th>03</th>
        <th>02</th>
        <th>01</th>
        <th>00</th>
    </tr>
    <tr>
        <td align="center">ADDIW</td>
        <td align="center" colspan="12">imm[11 : 0]</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SLLIW</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">shamt</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SRLIW</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">shamt</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SRAIW</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="5">shamt</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SLLI</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="6">shamt</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SRLI</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="6">shamt</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
    <tr>
        <td align="center">SRAI</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center" colspan="6">shamt</td>
        <td align="center" colspan="5">rs1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="5">rd</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
    </tr>
</table>

通过上述表格可以总结出：

使用funct3和funct7的第5位(指令的第30位)

可以共同确定ALU的编码所对应的运算，如下表所示

<table style="text-align: center;">
    <tr>
        <th>op[3]</th>
        <th>op[2]</th>
        <th>op[1]</th>
        <th>op[0] = 0</th>
        <th>op[0] = 1</th>
    </tr>
    <tr>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">ADD</td>
        <td align="center">SUB</td>
    </tr>
    <tr>
        <td align="center">0</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center" colspan="2">SLL</td>
    </tr>
    <tr>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center" colspan="2">SLT</td>
    </tr>
    <tr>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center" colspan="2">SLTU</td>
    </tr>
    <tr>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">0</td>        
        <td align="center" colspan="2">XOR</td>
    </tr>
    <tr>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center">1</td>
        <td align="center">SRL</td>
        <td align="center">SRA</td>
    </tr>
    <tr>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">0</td>
        <td align="center" colspan="2">OR</td>
    </tr>
    <tr>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center">1</td>
        <td align="center" colspan="2">AND</td>
    </tr>
</table>

