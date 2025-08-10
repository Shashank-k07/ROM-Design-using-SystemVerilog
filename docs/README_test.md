Testbench Module – test
------------------------------
This SystemVerilog testbench orchestrates the ROM verification process by generating a clock, creating instances of generator and bus functional model (BFM) classes, instantiating the DUT (ROM), and coordinating data flow between testbench components using a virtual interface.

Key Components
-------------
**Clock Generation**
```
bit clock;
initial begin
    clock = 0;
    forever #5 clock = ~clock;
end
```
Generates a periodic clock with a 10 time unit period (5 high + 5 low).
This clock drives both the testbench and DUT for synchronous operation.

**Object Creation**

```
gen a = new();
bfm b = new();
rom_inf pvif(clock);
```
gen a → Instance of the generator class (produces test stimulus).
bfm b → Instance of the bus functional model (drives signals to DUT).
rom_inf pvif(clock) → Instantiation of the ROM interface with the generated clock.

**DUT Instantiation**
```
rom dut(
    .clock(pvif.clock),
    .rd_data(pvif.rd_data),
    .wr_data(pvif.wr_data),
    .wr_en(pvif.wr_en),
    .rd_en(pvif.rd_en),
    .addr(pvif.addr)
);
```
The ROM module is connected directly to the interface signals (pvif), ensuring synchronized data exchange.

**Virtual Interface Binding**
```
common::vif = pvif;
```
The pvif handle is assigned to common::vif (a static virtual interface).
This allows all classes (generator, BFM, scoreboard, etc.) to access DUT signals without tight coupling.

**Test Sequence Execution**

```
repeat(10) begin
    a.t1;
    b.t2;
    @(posedge clock);
end
```
Repeats 10 cycles of:
a.t1 → Generator method producing random or constrained stimulus.
b.t2 → BFM method driving signals to the DUT.
Synchronization at positive clock edge.

**Simulation Termination**
```
$finish;
```
Ends simulation after 10 test cycles.

Overall Function
--
The test module serves as the top-level testbench controller:
Generates the clock.
Connects all verification components.
Binds the virtual interface for signal access.
Executes a controlled number of test cycles.
It ensures the ROM DUT is tested in a structured and reusable verification environment.
