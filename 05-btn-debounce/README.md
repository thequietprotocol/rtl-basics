# Debounce Circuits
Basys 3 (Artix-7 XC7A35T) · SystemVerilog · Vivado/XSIM

# Delayed Debounce

## Status
- RTL: done
- Verification: in-progress
- Hardware Validation: not yet

## Spec
- Input: single-bit button signal, `btn`
- Output: single-bit debounced signal, synchronous to `SYS_CLK`
- Polling interval: `btn` sampled every `TICK_TIME` ns (default 10 ms)
- Debounce window: 2-3x polling interval (20 to 30 ms), confirmed stable on both press and release transitions
- Reset: synchronous, active-high

## Interfaces
```systemverilog
module delay_debounce #(
    parameter TICK_TIME = 10_000_000, // (in ns)
    parameter SYS_CLK = 10 // (in ns)
)(
    input clk,
    input rst,
    input btn, 
    output db
);
```
