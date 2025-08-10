Generator Block
-----------------

Overview
--------
The Generator block is responsible for creating randomized test transactions and sending them to the Bus Functional Model (BFM) for driving into the DUT.
In this project, the Generator produces values for all input signals of the memory module (wr_data, addr, wr_en, rd_en, reset) using constrained randomization.
The generated transactions are passed to the BFM via a mailbox for synchronized communication between components.

Purpose
----------
Creates randomized input stimuli for the DUT.
Ensures constraints are respected (e.g., valid addresses, reset disabling read/write).
Decouples test vector creation from signal driving.

SystemVerilog code
-----------------
```
class gen;
    tb p; // Transaction object

    task t1;
        p = new();              // Create a new transaction
        p.randomize();          // Randomize all signals based on constraints
        common::mb.put(p);      // Send the transaction to the mailbox
    endtask
endclass
```

How It Works
--------------
**Transaction Creation**
A new object p of type tb (transaction class) is created.
This tb class contains all the DUT input signals as randc variables, along with constraints.

**Randomization**
p.randomize() generates random values for all transaction fields.
Constraints from the tb class ensure only valid combinations are generated (e.g., reset disables read/write).

**Sending to BFM**
Once generated, the transaction is sent to the common::mb mailbox.
The BFM retrieves the transaction from the mailbox and drives the DUT via the virtual interface.

Key Points
----------
Separation of Concerns — The Generator doesn’t directly drive the DUT; it only creates transactions.
Reusability — The Generator can be reused with different DUTs by modifying the transaction class.
Controlled Randomness — Constraints ensure that generated values are meaningful and avoid illegal operations.
