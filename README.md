# Special Sequence Counter (Verilog)

A structural Verilog implementation of a three-bit special counter using JK flip-flops, developed for an Advanced Digital Design course.

## Functionality

- **S = 0:** repeated sequence **1 → 4 → 7**.
- **S = 1:** repeated sequence **2 → 6 → 5**.
- **RST:** asynchronous active-high reset to `000`.
- **EN:** synchronous enable; when low, counting holds.
- The mode is stored in a negative-edge-triggered JK flip-flop and changes at a sequence boundary.

## Files

- `src/Project.v`: original Verilog design modules and `tb_special_counter` self-checking testbench in one file.
- `schematic/block.bde`: original Active-HDL block diagram file (requires compatible Active-HDL software).

## Design modules

`JK_FF`, `JK_FF_NEG`, `counter_logic`, `mode_logic`, and `special_counter`.

## Verification

The `tb_special_counter` testbench checks reset, both sequences, enable/hold behavior, and changing the sequence selection. The university project report includes Active-HDL simulation results. The uploaded HDL has not been rerun independently here because a Verilog simulator is not installed in the testing environment.

To run in Active-HDL, add `src/Project.v` to a design and select `tb_special_counter` as the simulation top module.

## Notes

This is a university-level teaching project. `Project.v` is the original source with the testbench included rather than separated into another file.
