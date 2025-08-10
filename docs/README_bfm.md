Bus Functional Model (BFM)
----------------------------

Overview
----------
The Bus Functional Model (BFM) acts as the bridge between the generated transactions and the DUT (Device Under Test).
It receives randomized transactions from the Generator via a mailbox, extracts the transaction fields, and drives them into the DUT through a virtual interface.
The BFM abstracts low-level signal toggling, allowing the testbench to remain modular and readable.

Purpose
---------
Drives DUT input signals based on the received transactions.
Provides cycle-accurate stimulus application using the virtual interface.
Separates test stimulus generation from DUT signal-level driving.
```
class bfm;
    virtual mem_intf vif; // Virtual interface handle
    task drive;
        tb p;  
        common::mb.get(p);      // Retrieve the transaction from the mailbox
        // Apply the transaction values to the DUT interface
        vif.wr_data <= p.wr_data;
        vif.addr    <= p.addr;
        vif.wr_en   <= p.wr_en;
        vif.rd_en   <= p.rd_en;
        vif.reset   <= p.reset;
       @(posedge vif.clk);     // Synchronize with clock
    endtask
endclass
```

How It Works
---------------
**Receiving Transactions**
The BFM waits for transactions in the common::mb mailbox.
Once available, it retrieves the transaction object p.

**Driving the DUT**
Using the virtual interface, the BFM maps transaction fields directly to DUT input signals.
Synchronization with the DUT clock ensures correct timing of stimulus application.

**Abstraction Layer**
The BFM hides low-level signal operations from higher-level test logic.
This allows easy DUT replacement or interface changes without modifying the Generator or other blocks.

Key Points
-------------
Interface-Driven — Uses virtual interfaces for clean connectivity to DUT ports.
Modular — Can be reused across different testbenches with similar DUT signal structures.
Clock-Synchronized — Ensures DUT receives signals in sync with the system clock.

