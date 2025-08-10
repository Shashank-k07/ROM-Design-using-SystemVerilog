ROM Design using SystemVerilog
------------------------------
Overview
--------------
This project implements a synchronous Read-Only Memory (ROM) in SystemVerilog.

Width: 8 bits
Depth: 128 locations
Operation: Clocked with read and write enable controls
Applications: FPGA/ASIC designs, memory initialization, digital system simulation, and educational use in hardware design courses.

Signal Description
--------------------
| Signal   |   Width    |   Direction   | Description                                                 |
| -------- | ---------- | ------------- | ----------------------------------------------------------- |
| wr_data  | 8 bits     | Input         | Data to be written into memory                              |
| addr     | 7 bits     | Input         | Memory address for read/write operation                     |
| wr_en    | 1 bit      | Input         | Write enable — when high, writes wr_data into mem[addr]     |
| rd_en    | 1 bit      | Input         | Read enable — when high, outputs mem[addr] on rd_data       |
| clock    | 1 bit      | Input         | System clock — synchronizes all operations                  |
| rd_data  | 8 bits     | Output        | Data output after a read operation                          |
| mem      | 8×128 bits | Internal      | Memory array storing 128 bytes (ROM contents)               |

Memory Size Calculation
-------------------------
To design a memory of 1 Kibibit capacity:
1 Kibibit = 1024 bits
Memory width is 8 bits (1 byte per location)
Number of memory locations required: 1024 bits / 8bits = 128 location
To address 128 locations, we need: 2^7 address lines that is 7 bit address line

Conclusion:
-----------
Width = 8 bits
Depth = 128 locations
Address lines = 7 bits

Working flow
-------------
**On every positive edge of the clock** (posedge clock):
>>Write Operation
If **wr_en is high**, the data on wr_data is written into mem[addr].
>>Read Operation
If **rd_en is high**, the data stored in mem[addr] is placed on rd_data.
>>When **Both wr_en and rd_en are High**
Both operations are executed sequentially in the order they appear in the procedural block.
In this design, the write operation is checked first, followed by the read operation.
This means the read will return the newly written data if wr_en and rd_en are asserted in the same clock cycle.


