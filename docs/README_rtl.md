RTL Design Block
----------------

Overview
-----------
The RTL Design block represents the actual hardware implementation of the Design Under Test (DUT).
In this project, the DUT is a memory module that supports read and write operations with addressable locations.
It receives control signals (wr_en, rd_en), data inputs (wr_data), and address inputs (addr) and outputs the corresponding read data (rd_data).

Purpose
----------
Implements the required functional behavior of the memory system in synthesizable SystemVerilog.
Acts as the core logic that verification components (Generator, BFM) interact with.
Serves as the target for functional verification and validation.
```
module rom(rd_data, wr_data, addr, rd_en, wr_en, clock);
    input [7:0] wr_data;
    input [6:0] addr;
    input wr_en, rd_en, clock;
    output reg [7:0] rd_data;
    reg [7:0] mem[127:0];

    always @(posedge clock) begin
        if (wr_en == 1) begin
            mem[addr] = wr_data;
        end
        if (rd_en == 1) begin
            rd_data = mem[addr];
        end
    end
endmodule
```
How It Works
--------------
**Write Operation**
When wr_en is asserted, the value on wr_data is stored in the memory at the location specified by addr.

**Read Operation**
When rd_en is asserted, the value from the memory location specified by addr is driven onto rd_data.

Key Points
-----------
Synthesizable — Fully compliant with synthesis tools for FPGA/ASIC implementation.
Edge-Triggered — Operations occur on the rising edge of clock.
Deterministic Behavior — Output is entirely dependent on input signals and stored memory state.
Scalable — Address and data widths can be easily parameterized for different use cases.

