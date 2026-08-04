# Synchronous FIFO Buffer

sync_fifo — parked, incomplete

## Status
WIP, paused. Picking this back up once the current focus wraps up.

fifo.sv — synchronous FIFO, parameterized DATA_WIDTH/DEPTH. Pointer-based read/write, count register driving full/empty.

## What's missing
No testbench — completely unverified.
No review pass yet — hasn't been checked line-by-line.
Before resuming

Sanity-check first: the simultaneous read+write branch in the count update, and pointer wraparound behavior at DEPTH-1.