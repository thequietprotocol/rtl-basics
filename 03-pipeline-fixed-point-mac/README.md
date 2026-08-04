# Pipelined Fixed-Point MAC

Basys 3 (Artix-7 XC7A35T) · SystemVerilog · Vivado/XSIM

## Status
- RTL: done
- Verification: in progress

## Spec
- Operands: Q1.7 (8-bit signed)
- Accumulator: Q6.14 (20-bit signed), saturating on overflow
- Latency: fixed 3 cycles, input to output
- Pipeline stages matched to DSP48E1 internal registers (AREG/BREG → MREG → PREG)
- Reset: synchronous, active-high

## Interface

```systemverilog
module pipeFixedMac #(
    parameter DATA_WIDTH = 8,   // Q1.7
    parameter ACC_WIDTH  = 20   // Q6.14
)(
    input  logic clk, rst,
    input  logic valid_in,
    input  logic clear_acc,       // this pair starts a fresh accumulation
    input  logic signed [DATA_WIDTH-1:0] a_in, b_in,

    output logic valid_out,
    output logic signed [ACC_WIDTH-1:0] acc_out
);
```