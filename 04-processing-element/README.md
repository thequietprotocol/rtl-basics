# pe — weight-stationary processing element

Basys 3 (Artix-7 XC7A35T) · SystemVerilog · Vivado/XSIM
Part of `rtl-basics`. Builds on `pipeFixedMac`.

## Status
- RTL: done
- Verification: done

## Spec
- Operands: Q1.7 (8-bit signed)
- Partial sum: Q6.14 (20-bit signed), saturating on overflow
- Weight: stationary - loaded once via `weight_load`, held across many streaming cycles
- Latency: fixed 3 cycles, input to output
- Reset: synchronous, active-high

## What it computes
Every cycle: `psum_out = psum_in + (a_in × weight)`, plus `a_out = a_in` delayed to
stay in lockstep with `psum_out` - the activation pass-through that feeds the next
PE east in a systolic array. No local accumulator: accumulation happens spatially,
across a chain of PEs, not inside this module.

## Interface

```systemverilog
module pe #(
    parameter int DATA_WIDTH = 8,   // Q1.7
    parameter int ACC_WIDTH  = 20   // Q6.14
)(
    input  logic clk, rst,

    input  logic                          weight_load,
    input  logic signed [DATA_WIDTH-1:0]  weight_in,

    input  logic                          valid_in,
    input  logic signed [DATA_WIDTH-1:0]  a_in,
    input  logic signed [ACC_WIDTH-1:0]   psum_in,

    output logic                          valid_out,
    output logic signed [DATA_WIDTH-1:0]  a_out,
    output logic signed [ACC_WIDTH-1:0]   psum_out
);
```

## Tests (`tb_pe.sv`)
- `single_step` - one MAC, sanity check on `psum_out`/`a_out` alignment
- `bubble` - a bubble between two unrelated transactions doesn't corrupt either
- `overflow_positive` / `overflow_negative` - saturation on `psum_in + product`, both directions