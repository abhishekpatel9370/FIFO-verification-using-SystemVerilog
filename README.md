# SystemVerilog FIFO Verification Project

## Overview
This project implements and verifies a **16×8 FIFO (First-In-First-Out) memory** in SystemVerilog using an **object-oriented, transaction-based testbench**.

The FIFO stores 8-bit data values and supports **read** and **write** operations with proper handling of `full` and `empty` conditions.

---



## How It Works

### 1. FIFO Design
- The FIFO has **16 locations**, each 8 bits wide.
- **Write Operation (`wr`)**: Stores `data_in` into memory if not full.
- **Read Operation (`rd`)**: Outputs `data_out` from memory if not empty.
- Uses:
  - **Write Pointer (wptr)** and **Read Pointer (rptr)** to track positions
  - **Count (cnt)** to determine `full` and `empty` flags

---

### 2. Testbench Structure
The verification environment is built with SystemVerilog classes:

- **Transaction** – Holds the data and control signals for each operation.
- **Generator** – Randomly decides whether to perform a read or write and creates transactions.
- **Driver** – Drives the DUT (FIFO) inputs according to the transactions.
- **Monitor** – Observes DUT signals and sends them to the scoreboard.
- **Scoreboard** – Checks if the FIFO output matches the expected data (self-checking).
- **Environment** – Connects and runs all components together.

---

### 3. Flow of Operation
1. **Generator** produces a random sequence of write/read commands.
2. **Driver** applies these commands to the FIFO via the interface.
3. **Monitor** captures both input and output activity.
4. **Scoreboard** maintains a reference model (queue) to compare expected vs actual outputs.
5. Any data mismatches are reported as errors.
6. Waveforms are dumped to a `.vcd` file for viewing in **EDAplayground**.

---

### 4. Simulation Output
The testbench logs:
- Each operation performed (write/read)
- FIFO status (`full`/`empty`)
- Data comparisons from the scoreboard
- Error count at the end of simulation

---

### 5. Key Learning Points
- FIFO design and pointer management
- Constrained random stimulus generation
- Using interfaces for DUT connections
- Self-checking testbenches with scoreboard
- Viewing simulation results in EDA playground
