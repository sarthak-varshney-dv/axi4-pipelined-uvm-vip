
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

# UVC Architecture

// ![AXI4 UVC Architecture](docs/images/axi4_uvc_architecture.png)

The AXI4 Master UVC follows a modular UVM architecture consisting of:

- Sequencer
- Driver
- Monitor
- AXI Interface
- DUT Connectivity

The design promotes reuse, scalability, and protocol abstraction while maintaining transaction-level visibility.

# Project Overview

The objective of this project is to develop a reusable AXI4 Master Verification IP capable of generating protocol-compliant traffic and validating DUT behavior under realistic operating conditions.

The implementation emphasizes:

- Transaction-level modeling
- Protocol abstraction
- Pipelined request handling
- Response-driven synchronization
- Support for concurrent transactions
- Reusable UVM architecture

The UVC can be integrated into larger subsystem and SoC verification environments.

# AXI4 Concepts Covered

## Independent Channels

The implementation models all five AXI4 channels independently:

| Channel | Description |
|----------|-------------|
| AW | Write Address |
| W | Write Data |
| B | Write Response |
| AR | Read Address |
| R | Read Data |

---

## Pipelining

The driver architecture supports transaction pipelining by decoupling:

- Request Acceptance
- Address Handling
- Data Handling
- Response Processing

This enables multiple transactions to remain active simultaneously.

---

## Outstanding Transactions

The UVC supports multiple outstanding requests by maintaining transaction state information indexed using transaction IDs.

---

## Out-of-Order Responses

Responses are matched using AXI transaction IDs, allowing completion in an order different from the original request sequence.

---

## Burst Transactions

Support for burst-based transfers with multi-beat data handling and response synchronization.


# Pipelined Driver Architecture

The AXI4 driver uses a multi-threaded architecture to model realistic protocol behavior.

### Driver Responsibilities

- Request Collection
- Channel Scheduling
- Outstanding Transaction Tracking
- Response Matching
- Sequence Synchronization

### Key Design Features

- Queue-Based Dispatching
- Independent Channel Threads
- ID-Based Tracking
- Semaphore-Controlled Outstanding Depth
- Response-Driven Completion

### Driver Flow

```text
Sequence
   |
   v
Dispatcher
   |
--------------------------------
|        |        |
AW      W       AR
|        |        |
DUT Interface
|        |
B        R
|
Response Matching
|
Sequence


---

# Step 7 — Add Outstanding Transaction Section

Recruiters love this section.

```markdown
# Outstanding Transaction Management

To support realistic AXI4 traffic patterns, the driver maintains an outstanding transaction table.

Transactions are stored using unique IDs and remain active until completion.

### Capabilities

- Multiple Outstanding Reads
- Multiple Outstanding Writes
- ID-Based Tracking
- Out-of-Order Completion Support
- Response Correlation

### Example

Request Order:

```text
ID1
ID2
ID3
ID4