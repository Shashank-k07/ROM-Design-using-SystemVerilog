**Design of 1 Kibibit ROM using SystemVerilog**
-
Project Overview
--
This project implements a synchronous Read-Only Memory (ROM) module using SystemVerilog, along with a testbench environment for verification. The ROM features:
Memory Size: 128 locations of 8 bits each, addressed by a 7-bit address line.
Read Operation: Controlled by the rd_en signal. When high on the clock's rising edge, data from the specified address is output on the rd_data bus.
Write Operation: Controlled by the wr_en signal. When high on the clock's rising edge, data from the wr_data bus is written to the specified memory address.
Clock Signal: Synchronizes all read and write operations ensuring data stability and timing control.

The verification environment includes:

A SystemVerilog interface (rom_inf) to bundle the input/output signals and the clock.
A randomized testbench class (tb) that generates stimulus with controlled address constraints.
A generator class (gen) that produces randomized test vectors and sends them via a mailbox.
A bus functional model (BFM) class (bfm) that drives the interface signals using test vectors from the mailbox.
A top-level test module to instantiate the ROM, interface, generator, and BFM, running automated test cycles to validate memory functionality.  

This modular approach ensures reliable testing and validation of the ROM design, with clear separation of DUT and verification components.



Calculation:
-
1. To Design any memory element first list down the size and width of the memory.  
  In this project the size is 1 Kibi bits which equavalent to 1024 bits and width of memory per location is 8 bit.  
2. Next calculate the depth of memory .  
depth of memory = (No of bits)/(total width)  
i.e depth = 1024/8 = 128 locations required.  
3. Calculate address width.
For 128 different location we would need 7 bit address line.  

Signal Specification
-
In this project a total 6 signals are used and  the specification is as below
|Signal name|Direction|width|Description|
|-----------|---------|-----|-----------|
| rd_en | input | 1 bit | Control signal controls the read operation. Whenever this signal is high, the data stored at the memory location specified by the address is copied to the rd_data bus.|
| wr_en | input | 1 bit | Control signal controls the write operation. Whenever this signal is high, the data present on the wr_data bus is written to the memory location specified by the address addr.|
| wr_data| input| 8 bit| The input bus carries the data that is to be written into the memory.|
|clock| input | 1 bit | Synchronizes the timing of all memory operations, ensuring data is read from or written to the memory at the correct clock edges.|
| addr | input | 7 bit | Specifies the memory location from which data is to be read or to which data is to be written.|
|rd_data| output | 8 bit | Carries the data read from the memory location specified by the address during a read operation.|

Got it! Here's a detailed **program flow** overview followed by an in-depth explanation of every block in your SystemVerilog ROM testbench design, including the role of the `common` class with its virtual interface and mailbox.

---

# Program Flow Overview 

1. **Clock generation**: A clock signal is created to synchronize all operations.

2. **Test vector generation**: The `gen` class creates randomized input stimulus (`wr_data`, `rd_en`, `wr_en`, `addr`) packaged as an object `tb`. These test vectors conform to constraints (e.g., address fixed to 100).

3. **Inter-thread communication**: The generated test vectors are placed into a **mailbox** (a thread-safe FIFO queue) managed by the `common` class.

4. **Driving DUT signals**: The `bfm` (bus functional model) class retrieves test vectors from the mailbox and drives the DUT's interface signals (`wr_data`, `rd_en`, `wr_en`, `addr`) accordingly.

5. **ROM operations**: On every rising edge of the clock:

   * If `wr_en` is asserted, the ROM writes the `wr_data` value to the memory at location `addr`.
   * If `rd_en` is asserted, the ROM outputs the memory content at `addr` onto `rd_data`.

6. **Verification cycles**: Steps 2-5 repeat for multiple cycles (10 in your case) to test different random inputs.

7. **Simulation end**: After the defined number of test cycles, simulation finishes.

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

* **Purpose:** Acts as a shared repository for communication and signal connection.

* **Mailbox (`mb`):** A thread-safe queue used to transfer test vector objects (`tb`) safely between the generator (`gen`) and the bus functional model (`bfm`). This decouples stimulus generation from signal driving, allowing asynchronous behavior and cleaner testbench architecture.

* **Virtual Interface (`vif`):** Holds a reference to the `rom_inf` interface instance. Using a virtual interface allows classes (like `bfm`) to drive or monitor DUT signals abstractly, improving modularity and reuse. Instead of passing signals explicitly, classes use `common::vif` to access the interface signals.

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

* **Purpose:** Bundles all ROM input/output signals with the clock into a single interface construct.

* **Why use interfaces?** Interfaces simplify connecting the DUT to the testbench. Instead of connecting each signal individually, you pass the entire interface instance. This reduces wiring complexity and improves readability.

* The interface contains **write data bus**, **read data bus**, **read enable**, **write enable**, and **address bus** signals, all required for ROM operation.

---

### 3. ROM Module (`rom`)

```systemverilog
module rom(...);
  ...
  reg [7:0] mem[127:0];  // Memory array
  
  always @(posedge clock) begin
    if (wr_en) begin
      mem[addr] = wr_data;  // Write operation
    end
    if (rd_en) begin
      rd_data = mem[addr];  // Read operation
    end
  end
endmodule
```

* **Purpose:** Implements the core Read-Only Memory functionality.

* **Synchronous memory:** Reads and writes happen on the rising clock edge for stable and predictable timing.

* **Write Enable (`wr_en`):** When high, copies data from `wr_data` bus into the memory at the specified address.

* **Read Enable (`rd_en`):** When high, outputs the data stored at the specified address onto the `rd_data` bus.

* **Memory Size:** 128 entries (addressed by 7 bits), each 8 bits wide.

* This module represents the **Device Under Test (DUT)** in the verification environment.

---

### 4. Testbench Class `tb`

```systemverilog
class tb;
  randc bit [7:0] wr_data; 
  randc bit rd_en; 
  randc bit wr_en;
  randc bit [6:0] addr;

  constraint c1 {
    addr == 100;  // Restrict address for focused testing
  }
endclass
```

* **Purpose:** Defines the test vector structure and its randomization constraints.

* **Randomized fields:** Inputs (`wr_data`, `rd_en`, `wr_en`, and `addr`) are marked `randc` for constrained random cyclic generation, ensuring unique random values each time.

* **Constraint:** Restricts the address to 100 for targeted tests, useful for focused debugging or specific test coverage.

* This class encapsulates **stimulus data**.

---

### 5. Generator Class `gen`

```systemverilog
class gen;
  tb p;

  task t1;
    p = new();
    p.randomize();          // Generate a random test vector
    common::mb.put(p);      // Send it to mailbox for consumption
  endtask
endclass
```

* **Purpose:** Generates new randomized test vectors each cycle.

* **Operation:**

  * Creates a new `tb` object.
  * Randomizes its fields.
  * Places the randomized object into the mailbox for the BFM to consume.

* This **decouples stimulus creation** from driving signals, supporting better testbench modularity.

---

### 6. Bus Functional Model (BFM) Class `bfm`

```systemverilog
class bfm;
  tb p;

  task t2;
    p = new();
    common::mb.get(p);           // Retrieve a test vector from mailbox
    common::vif.wr_data = p.wr_data;  // Drive DUT signals through interface
    common::vif.wr_en = p.wr_en;
    common::vif.rd_en = p.rd_en;
    common::vif.addr = p.addr;
  endtask
endclass
```

* **Purpose:** Drives the DUT interface signals using test vectors received from the mailbox.

* **Operation:**

  * Gets a test vector `tb` from the mailbox.
  * Assigns the fields to the corresponding interface signals (`wr_data`, `wr_en`, `rd_en`, `addr`).

* Acts as the **signal driver** in the testbench.

---

### 7. Top-Level Test Module `test`

```systemverilog
module test;
  bit clock;

  initial begin
    clock = 0;
    forever #5 clock = ~clock;  // 10 time unit clock period
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
    common::vif = pvif;        // Connect interface instance to common class
    repeat (10) begin          // Run 10 test cycles
      a.t1;                   // Generate test vector
      b.t2;                   // Drive test vector to DUT
      @(posedge clock);       // Wait for next clock edge
    end
    $finish;                  // End simulation
  end
endmodule
```

* **Purpose:** Ties together DUT, interface, stimulus generator, and BFM.

* **Clock Generation:** Produces a stable clock to drive synchronous operations.

* **Instantiation:**

  * Creates interface instance `pvif` connected to clock.
  * Instantiates the DUT (`rom`).
  * Instantiates generator (`gen`) and BFM (`bfm`).

* **Test Sequence:**

  * Assigns interface to `common::vif`.
  * Runs a loop for 10 cycles generating and applying random test vectors.
  * Waits for a clock edge each cycle to synchronize stimulus application.
  * Ends simulation after tests.

---

# Summary

* The **`common` class** provides the glue with its mailbox (for safe communication between generator and BFM) and virtual interface (for modular access to DUT signals).
* The **interface** groups signals for clean connection.
* The **ROM module** is the DUT that synchronously reads/writes data.
* The **`tb` class** defines random test vectors.
* The **`gen` class** creates stimulus vectors.
* The **`bfm` class** applies stimulus to the DUT signals.
* The **`test` module** coordinates clock, DUT, interface, and verification flow.

---

If you want, I can also help with:

* Adding assertions for checking correctness.
* Generating waveform viewing scripts.
* Expanding the testbench with coverage.
* Explaining how to run the simulation.

Just say the word!

