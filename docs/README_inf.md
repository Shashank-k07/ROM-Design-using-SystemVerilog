Interface Block
----------------
Overview
---------------
The interface block (rom_inf) serves as a container for all the DUT I/O signals and provides a single connection point between the DUT and the testbench components. By grouping related signals into one interface, it simplifies connectivity and allows for easy signal access in different testbench classes via a virtual interface.
In this project, rom_inf holds all the ROM’s primary inputs and outputs, including address, read/write data, control signals, and the clock.

Purpose
------------
Encapsulates all DUT I/O signals in a single entity.
Simplifies wiring between the DUT and testbench components.
Supports easy access through a virtual interface for driving/monitoring signals in classes.
Reduces port-list complexity when connecting DUT to multiple components.
```
interface rom_inf(input bit clock);
    bit [7:0] wr_data, rd_data; // Write and read data
    bit rd_en;                  // Read enable
    bit wr_en;                  // Write enable
    bit [6:0] addr;             // Address bus
endinterface
```
How It Works
-------------
**Signal Grouping**

All related DUT pins are defined within the interface, making it easy to pass them around as one object.

**Clock Handling**

The interface takes the clock as an input port, allowing synchronous logic inside or making it available to connected components.

**Virtual Interface Usage**

Testbench classes (e.g., BFM, Monitor) can declare a virtual rom_inf variable.
This enables direct access to these signals without multiple port connections.

Connection to DUT
------------

In the testbench top module, the interface instance is connected directly to the DUT ports.

Key Points
-----
Reusability — The same interface can be reused across different projects with similar signal sets.
Maintainability — Adding/removing signals in one place updates them for all connected components.
Virtual Interface Friendly — Allows OOP-based testbench components to access hardware-like ports.
