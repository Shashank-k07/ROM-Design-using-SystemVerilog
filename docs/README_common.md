Common Source Class
------------
Overview
----------
The Common class acts as a shared resource holder for all verification components in the testbench. It contains two primary elements:
1. Mailbox — Used for synchronized communication between components (e.g., Generator and BFM).
2. Virtual Interface — Provides a shared handle to the DUT’s physical interface, allowing multiple components to access and drive signals.
This class ensures that global objects are accessible without requiring direct references between components, improving modularity and reusability.

Purpose
--------------
**Centralized Communication** — Allows different verification blocks to exchange transactions using the same mailbox.
**Shared DUT Access** — Stores the virtual interface so that components can interact with the DUT without hardcoding connections.
**Simplified Connectivity** — Avoids complex hierarchical references by placing shared handles in one common location.
```
class common;
    static mailbox mb = new();        // Shared mailbox for transaction passing
    static virtual rom_inf vif;       // Shared virtual interface for DUT access
endclass
```
How It Works
--------------
**1. Mailbox (mb)**

A static mailbox object mb is created.
Being static means there is only one mailbox instance, shared across all objects and classes in the testbench.
Used to pass transaction objects between the Generator and BFM.

Example:
Generator: common::mb.put(transaction) → sends transaction.

BFM: common::mb.get(transaction) → retrieves transaction.

Ensures synchronized, thread-safe communication between producer and consumer.

**2. Virtual Interface (vif)**

A static virtual interface vif is declared to connect testbench components to the DUT interface (rom_inf).
The interface is assigned once in the testbench top-level and then accessible anywhere via common::vif.
Allows BFMs and monitors to read/write DUT signals without directly instantiating the interface.

Key Points
------------
Global Access — Both mb and vif are static, making them universally accessible without passing references explicitly.
Testbench Modularity — Components don’t need to know about each other’s structure; they just use the shared resources.
Ease of Integration — Works well in large verification environments where multiple blocks need the same interface and mailbox.

Synchronization Guarantee — Mailbox ensures orderly and safe data transfer between parallel processes.
