#  8 bit Asynchronous FIFO Design and Verification

##  Problem Statement: Bridging Asynchronous Worlds

Imagine a high-speed sensor transmitting valuable data at 50 MHz — far faster than the processor meant to consume it. The processor, operating at 25 MHz and prone to occasional stalls (only active 80% of the time), risks falling behind. Without an intelligent buffer, this mismatch leads to data overflow and system instability.

To solve this, we need a **synchronized, reliable, and configurable FIFO buffer** that can:
- Handle continuous high-speed input without losing data
- Adapt to slower or intermittent read speeds
- Safely transfer data between **asynchronous clock domains**
- Detect and prevent overflow/underflow conditions
- Be easily integrated into any new SoC, SPI, or UART design

---

## Solution Overview

### 1. FIFO Depth Calculation

| Parameter | Value |
|----------|-------|
| Sensor Write Rate | 50 MHz (1 write every 20 ns) |
| Processor Effective Read Rate | 25 MHz × 80% = 1 read every 50 ns |
| Required FIFO Depth | 5 → rounded up to **8** (for Gray code ease) |
| Address Width | `ADDR_WIDTH = 3` (since 2³ = 8 entries) |

---

### 2. RTL Module Design

| Module | Description |
|--------|-------------|
| `fifo_pkg.sv` | Common parameter definitions (`DATA_WIDTH`, `ADDR_WIDTH`) |
| `fifo_mem.sv` | Dual-port memory with independent read/write clocks |
| `fifo_write_ctrl.sv` | Write pointer logic + full detection |
| `fifo_read_ctrl.sv` | Read pointer logic + empty detection |
| `sync_gray.sv` | Gray code synchronizer for pointer crossing |
| `fifo_async.sv` | Top-level FIFO wrapper integrating all components |

---

### 3. Pointer Synchronization

- Binary → Gray code conversion
- Used `sync_gray.sv` for 2-flop pointer synchronization
- Avoided CDC issues through verified dual-clock handling

---

### 4. Formal Verification Setup

| File | Purpose |
|------|---------|
| `fifo_formal.sv` | Contains formal assertions and coverage conditions |
| `fifo.sby` | SymbiYosys script to run formal verification |
| Folder Layout | `rtl/`, `memory/`, `common/`, `formal/` for separation of concerns |

#### Formal Properties Checked:
- No writes when FIFO is `full`
- No reads when FIFO is `empty`
- Covers prove FIFO is usable in live systems

---

#### To Add this repository to your project:

```bash
git submodule add https://github.com/JananiPSrinivasan/AynchronousFIFO.git ip/async-fifo
