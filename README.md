# Design of 1 Kibibit ROM using SystemVerilog

---

## Project Overview

This project implements a synchronous **Read-Only Memory (ROM)** module using SystemVerilog, along with a testbench environment for verification. The ROM features:

* **Memory Size:** 128 locations of 8 bits each, addressed by a 7-bit address line.
* **Read Operation:** Controlled by the `rd_en` signal. When high on the clock's rising edge, data from the specified address is output on the `rd_data` bus.
* **Write Operation:** Controlled by the `wr_en` signal. When high on the clock's rising edge, data from the `wr_data` bus is written to the specified memory address.
* **Clock Signal:** Synchronizes all read and write operations ensuring data stability and timing control.

The verification environment includes:

* A SystemVerilog interface (`rom_inf`) to bundle the input/output signals and the clock.
* A randomized testbench class (`tb`) that generates stimulus with controlled address constraints.
* A generator class (`gen`) that produces randomized test vectors and sends them via a mailbox.
* A bus functional model (BFM) class (`bfm`) that drives the interface signals using test vectors from the mailbox.
* A top-level test module to instantiate the ROM, interface, generator, and BFM, running automated test cycles to validate memory functionality.

This modular approach ensures reliable testing and validation of the ROM design, with clear separation of DUT and verification components.

---

## Calculation

1. **Memory size:** The target size is 1 Kibibit, which equals 1024 bits.
2. **Memory depth:** The depth is 1024/width of memory(8 bit) = 128 locations.  
3. **Address width:** To address 128 locations, we need a 7-bit address bus (since $2^7 = 128$).

---

## Signal Specification

| Signal Name | Direction | Width | Description                                                                                                                     |
| ----------- | --------- | ----- | ------------------------------------------------------------------------------------------------------------------------------- |
| `rd_en`     | Input     | 1 bit | Control signal for read operation. When high, data stored at the memory location specified by `addr` is output on `rd_data`.    |
| `wr_en`     | Input     | 1 bit | Control signal for write operation. When high, data present on `wr_data` is written to the memory location specified by `addr`. |
| `wr_data`   | Input     | 8 bit | Input bus carrying the data to be written into the memory.                                                                      |
| `clock`     | Input     | 1 bit | Synchronizes timing of all memory operations, ensuring correct timing on read and write.                                        |
| `addr`      | Input     | 7 bit | Specifies the memory location for read or write operation.                                                                      |
| `rd_data`   | Output    | 8 bit | Carries data read from the specified memory location during a read operation.                                                   |

---

# Program Flow Overview

1. **Clock generation:** A clock signal is created to synchronize all operations.

2. **Test vector generation:** The `gen` class creates randomized input stimulus (`wr_data`, `rd_en`, `wr_en`, `addr`) packaged as an object `tb`. These test vectors conform to constraints (e.g., address fixed to 100).

3. **Inter-thread communication:** Generated test vectors are placed into a **mailbox** (thread-safe FIFO queue) managed by the `common` class.

4. **Driving DUT signals:** The bus functional model (`bfm`) class retrieves test vectors from the mailbox and drives the DUT's interface signals (`wr_data`, `rd_en`, `wr_en`, `addr`).

5. **ROM operations:** On every rising clock edge:

   * If `wr_en` is asserted, ROM writes `wr_data` to memory at `addr`.
   * If `rd_en` is asserted, ROM outputs memory content at `addr` on `rd_data`.

6. **Verification cycles:** Steps 2–5 repeat for multiple cycles (10 in this project) to test varied random inputs.

7. **Simulation end:** After all test cycles, simulation finishes.

---

# Detailed Explanation of Each Block

---

### 1. `common` Class

```systemverilog
class common;
  static mailbox mb = new();
  static virtual rom_inf vif;
endclass
```

* **Purpose:** Acts as shared storage for communication and signal access between testbench components.
* **Mailbox (`mb`):** Thread-safe FIFO queue transferring test vectors (`tb` objects) between generator and BFM, decoupling stimulus creation and signal driving.
* **Virtual Interface (`vif`):** Reference to the `rom_inf` interface instance, enabling modular, abstract access to DUT signals inside testbench classes.

---

### 2. Interface `rom_inf`

```systemverilog
interface rom_inf(input bit clock);
  bit [7:0] wr_data, rd_data;
  bit rd_en;
  bit wr_en;
  bit [6:0] addr;
endinterface
```

* **Purpose:** Bundles all input/output signals and clock for the ROM module.
* **Benefit:** Simplifies connections between DUT and testbench, reducing wiring complexity.

---

### 3. ROM Module (`rom`)

```systemverilog
module rom(
  output reg [7:0] rd_data,
  input [7:0] wr_data,
  input [6:0] addr,
  input rd_en,
  input wr_en,
  input clock
);
  reg [7:0] mem[127:0];

  always @(posedge clock) begin
    if (wr_en)
      mem[addr] = wr_data;
    if (rd_en)
      rd_data = mem[addr];
  end
endmodule
```

* **Functionality:** Implements synchronous ROM with write and read operations occurring on the clock's rising edge.
* **Memory:** 128 words, 8 bits each, accessed via 7-bit address.

---

### 4. Testbench Class `tb`

```systemverilog
class tb;
  randc bit [7:0] wr_data;
  randc bit rd_en;
  randc bit wr_en;
  randc bit [6:0] addr;

  constraint c1 {
    addr == 100;
  }
endclass
```

* **Purpose:** Defines stimulus structure with constrained random fields.
* **Constraint:** Fixes address to 100 for focused testing.

---

### 5. Generator Class `gen`

```systemverilog
class gen;
  tb p;

  task t1;
    p = new();
    p.randomize();
    common::mb.put(p);
  endtask
endclass
```

* **Purpose:** Creates randomized test vectors and puts them in the mailbox.
* **Decouples** generation from driving signals.

---

### 6. Bus Functional Model (BFM) Class `bfm`

```systemverilog
class bfm;
  tb p;

  task t2;
    p = new();
    common::mb.get(p);
    common::vif.wr_data = p.wr_data;
    common::vif.wr_en = p.wr_en;
    common::vif.rd_en = p.rd_en;
    common::vif.addr = p.addr;
  endtask
endclass
```

* **Purpose:** Receives test vectors from mailbox and drives DUT signals via interface.

---

### 7. Top-Level Test Module `test`

```systemverilog
module test;
  bit clock;

  initial begin
    clock = 0;
    forever #5 clock = ~clock;
  end

  gen a = new();
  bfm b = new();
  rom_inf pvif(clock);
  rom dut(
    .clock(pvif.clock),
    .rd_data(pvif.rd_data),
    .wr_data(pvif.wr_data),
    .wr_en(pvif.wr_en),
    .rd_en(pvif.rd_en),
    .addr(pvif.addr)
  );

  initial begin
    common::vif = pvif;
    repeat (10) begin
      a.t1;
      b.t2;
      @(posedge clock);
    end
    $finish;
  end
endmodule
```

* **Role:** Instantiates clock, DUT, interface, generator, and BFM.
* **Runs** 10 test cycles applying randomized stimulus synchronized to clock edges.
* **Ends** simulation after tests.

---
