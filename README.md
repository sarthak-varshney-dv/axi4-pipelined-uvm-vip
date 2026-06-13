# axi4-pipelined-uvm-vip
SystemVerilog UVM-based AXI4 pipelined master agent with support for multiple outstanding transactions and scalable VIP architecture.


# AXI4 Master UVC (UVM)

A reusable AXI4 Master Universal Verification Component (UVC) developed using SystemVerilog and UVM.

This project focuses on building a protocol-aware AXI4 verification environment with support for pipelined transactions, multiple outstanding requests, ID-based response matching, and transaction-level abstraction.

The UVC is designed to model realistic AXI4 behavior including independent channel operation, burst transactions, out-of-order responses, and decoupled request/response handling.

---

## Key Features

- UVM-based AXI4 Master Agent
- AXI4 Read and Write Transaction Support
- Independent AXI Channels (AW, W, B, AR, R)
- Pipelined Driver Architecture
- Multiple Outstanding Transactions
- ID-Based Response Tracking
- Out-of-Order Response Handling
- Queue-Based Transaction Scheduling
- Active and Passive Agent Support


---