## Problem Statement
Design a configurable FIFO buffer to handle streaming data from a high-speed sensor module to a slower processor interface. The FIFO must prevent data loss while ensuring efficient throughput.

The sensor sends 8-bit data at 50 MHz, while the processor reads data at 25 MHz, with occasional stalls (reads only 80% of the time). Your task is to:

- Calculate the minimum FIFO depth required to prevent overflow during processor stalls.
- Design controls and Synchronisation for the FIFO read/write interface.
- Include full/empty detection, programmable thresholds, and overflow/underflow flags.
- Verify the FIFO functionality using a testbench that models the sensor and processor behavior.

## Solution

### 1. FIFO Depth Calculation
- Sensor rate: 50 MHz (1 write every 20 ns)
- Processor reads at 25 MHz but only 80% of the time (1 read every 50 ns)
- Required depth = 5 → Rounded up to **8** for Gray code convenience
- `ADDR_WIDTH = 3` (for 2³ = 8 entries)

---

### 2. RTL Module Design

| Module | Description |
|--------|-------------|
| `fifo_pkg.sv` | Parameter definitions for `DATA_WIDTH`, `ADDR_WIDTH` |
| `fifo_mem.sv` | Dual-port memory with write/read clock separation |
| `fifo_write_ctrl.sv` | Write pointer increment, Gray code conversion, `full` flag |
| `fifo_read_ctrl.sv` | Read pointer increment, Gray code conversion, `empty` flag |
| `sync_gray.sv` | Gray code synchronizer across clock domains |
| `fifo_async.sv` | Top-level FIFO integrating all the above modules |

---

### 3. Pointer Synchronization
- Implemented **binary to Gray** conversion
- Used **`sync_gray.sv`** for cross-domain pointer transfer

---

### 4. Formal Verification Setup

| File | Purpose |
|------|---------|
| `fifo_formal.sv` | Formal wrapper with assumptions, assertions, and covers |
| `fifo.sby` | SymbiYosys script to run formal proof |
| Folder structure | `rtl/` for RTL, `formal/` for formal testbench, `common/` for shared pkg |

#### Formal Properties Checked
- No writes when FIFO is `full`
- No reads when FIFO is `empty`
- Data can flow through FIFO (basic `cover`)
