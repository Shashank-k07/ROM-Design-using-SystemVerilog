Testbench Class (tb)
------------------
This SystemVerilog tb class is designed to generate randomized test data for the ROM module during simulation. It leverages randc variables for constrained-random stimulus generation and includes a constraint to control specific signal values.

Code 
-----------
```
class tb;
    randc bit[7:0] wr_data;    // Random cyclic 8-bit data to be written to the ROM
    randc bit rd_en;           // Random cyclic read enable signal
    randc bit wr_en;           // Random cyclic write enable signal
    randc bit[6:0] addr;       // Random cyclic 7-bit ROM address

    // Constraint: Forces the ROM address to always be 100
    constraint c1 {
        addr == 100;
    }
endclass
```
Key Points
------------
randc (Random Cyclic Variables)
Generates values in a random order without repetition until all possible values are exhausted.
Useful for exhaustive verification of all possible values before repeating.

Test Signals
-------------
wr_data → Data to be written into the ROM (8-bit).
rd_en → Controls read operations.
wr_en → Controls write operations.
addr → Memory address in ROM (7-bit, supports 128 locations).

Constraint
------------
The constraint addr == 100 fixes the address to a constant value during all test iterations.
This is useful for scenarios where you want to repeatedly test read/write operations at a specific address.

