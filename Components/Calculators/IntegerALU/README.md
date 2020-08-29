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
        <td>I</td>
        <td colspan="12">imm[11 : 0]</td>
        <td colspan="5">rs1</td>
        <td colspan="3">funct3</td>
        <td colspan="5">rd</td>
        <td colspan="7">opcode</td>
    </tr>
    <tr>
        <td>R</td>
        <td colspan="7">funct7</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td colspan="3">funct3</td>
        <td colspan="5">rd</td>
        <td colspan="7">opcode</td>
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
        <td>ADD</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SUB</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SLL</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SLT</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SLTU</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>XOR</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SRL</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SRA</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>OR</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>AND</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
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
        <td>ADDI</td>
        <td colspan="12">imm[11 : 0]</td>
        <td colspan="5">rs1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SLLI</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">shamt</td>
        <td colspan="5">rs1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SLTI</td>
        <td colspan="12">imm[11 : 0]</td>
        <td colspan="5">rs1</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SLTIU</td>
        <td colspan="12">imm[11 : 0]</td>
        <td colspan="5">rs1</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>XORI</td>
        <td colspan="12">imm[11 : 0]</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SRLI</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">shamt</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SRAI</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">shamt</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>ORI</td>
        <td colspan="12">imm[11 : 0]</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>ANDI</td>
        <td colspan="12">imm[11 : 0]</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
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
        <td>ADDW</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SUBW</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SLLW</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SRLW</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SRAW</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rs2</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
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
        <td>ADDIW</td>
        <td colspan="12">imm[11 : 0]</td>
        <td colspan="5">rs1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SLLIW</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">shamt</td>
        <td colspan="5">rs1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SRLIW</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">shamt</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SRAIW</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="5">shamt</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SLLI</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="6">shamt</td>
        <td colspan="5">rs1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SRLI</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="6">shamt</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
    </tr>
    <tr>
        <td>SRAI</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td colspan="6">shamt</td>
        <td colspan="5">rs1</td>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td colspan="5">rd</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td>1</td>
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
        <td>0</td>
        <td>0</td>
        <td>0</td>
        <td>ADD</td>
        <td>SUB</td>
    </tr>
    <tr>
        <td>0</td>
        <td>0</td>
        <td>1</td>
        <td colspan="2">SLL</td>
    </tr>
    <tr>
        <td>0</td>
        <td>1</td>
        <td>0</td>
        <td colspan="2">SLT</td>
    </tr>
    <tr>
        <td>0</td>
        <td>1</td>
        <td>1</td>
        <td colspan="2">SLTU</td>
    </tr>
    <tr>
        <td>1</td>
        <td>0</td>
        <td>0</td>        
        <td colspan="2">XOR</td>
    </tr>
    <tr>
        <td>1</td>
        <td>0</td>
        <td>1</td>
        <td>SRL</td>
        <td>SRA</td>
    </tr>
    <tr>
        <td>1</td>
        <td>1</td>
        <td>0</td>
        <td colspan="2">OR</td>
    </tr>
    <tr>
        <td>1</td>
        <td>1</td>
        <td>1</td>
        <td colspan="2">AND</td>
    </tr>
</table>

