# Synchronous FIFO
Basys 3 (Artix-7 XC7A35T) · SystemVerilog · Vivado/XSIM

## Status
- RTL: done
- Verification: done

## Spec
- Data width: parameterized, `DATA_WIDTH` (default 8 bits)
- Depth: parameterized, `DEPTH` (default 16 words), arbitrary depth supported (not restricted to powers of 2)
- Pointer width: `$clog2(DEPTH)`, wraparound handled explicitly (not via bit-width truncation)
- Flags: `full`, `empty`, tracked via dedicated status registers, disambiguated using precomputed pointer successors
- Simultaneous read+write: both pointers advance; matches standard flag/pointer FIFO semantics
- Reset: synchronous, active-high

## Interface
```systemverilog
module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 16
)(
    input  logic clk, reset,
    input  logic read_en, write_en,
    input  logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out,
    output logic full,
    output logic empty
);
```