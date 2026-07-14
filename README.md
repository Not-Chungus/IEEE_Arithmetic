README_Computer_Arithmetic_Compact.md


# Computer Arithmetic Workshop

## Overview

This workshop explored the representation and implementation of arithmetic operations in digital hardware, with emphasis on **speed, area, scalability, and critical-path optimization**.

The material progressed from number representation and binary addition to advanced adder architectures, multioperand arithmetic, multiplication, and IEEE 754 floating-point hardware.

---

## Topics Covered

### 1. Number Representation

- Unsigned, signed-magnitude, and two's-complement representations.
- Dot notation for visualizing arithmetic operations.
- Carry, overflow, addition flags, and representable ranges.
- The effect of number format on hardware complexity and arithmetic behavior.

### 2. Binary Adders

The workshop began with half adders, full adders, and Ripple-Carry Adders, then introduced the carry-classification concepts used in faster architectures:

- **Generate:** produces a carry independently of the input carry.
- **Propagate:** passes an incoming carry to the next stage.
- **Kill:** prevents an incoming carry from propagating.

These signals were extended from individual bits to groups of bits and used to study:

- Carry-Lookahead and hierarchical CLA architectures.
- Ling adders.
- Parallel-prefix adders.
- Brent-Kung, Kogge-Stone, and Sklansky networks.
- Carry-Skip, Carry-Select, Conditional-Sum, and hybrid adders.

The architectures were compared in terms of logic depth, critical-path delay, fanout, wiring complexity, hardware cost, and scalability.

### 3. Multioperand Addition and Multiplication

The workshop explored efficient methods for handling more than two operands, including:

- Serial accumulation and adder trees.
- Carry-Save Adders.
- 3:2 counters, compressors, and reduction trees.
- Wallace and Dadda Trees.
- Binary partial-product generation.
- Shift-and-add and sequential multipliers.
- Signed multiplication.
- Partial-product reduction using carry-save structures.

### 4. IEEE 754 and Real Arithmetic

The real-arithmetic sessions covered:

- Floating-point sign, biased exponent, significand, and hidden bit.
- Normal, subnormal, zero, infinity, and NaN values.
- Guard, round, and sticky bits.
- Rounding modes, exceptions, overflow, and underflow.
- Floating-point addition, subtraction, multiplication, and division.
- Fused Multiply-Add and logarithmic arithmetic units.

A floating-point adder/subtractor was studied through the following stages:

1. Unpack and classify the operands.
2. Compare the exponents.
3. Swap operands when required.
4. Align the smaller significand.
5. Add or subtract the significands.
6. Detect the leading one or leading zero.
7. Normalize and round the result.
8. Perform post-rounding normalization.
9. Pack the final IEEE 754 result.

---

## Assigned Tasks

### Task 1 - 64-bit Hierarchical Carry-Lookahead Adder

Design a **64-bit hierarchical Carry-Lookahead Adder** using a 4-bit CLA block as the main building unit.

The task included:

- Designing bit-level and group-level generate/propagate logic.
- Building the 64-bit hierarchical carry network.
- Writing commented RTL.
- Creating a simulation testbench and capturing waveforms.
- Running FPGA synthesis and implementation using Vivado.
- Reporting resource utilization and critical-path delay.
- Discussing design limitations.
- Optionally creating a parameterized N-bit version.

### Task 2 - 64-bit Brent-Kung Parallel-Prefix Adder

Design a **64-bit Brent-Kung parallel-prefix adder**.

The task included:

- Understanding the recursive Brent-Kung structure.
- Mapping prefix operations to generate/propagate carry operators.
- Constructing the 64-bit carry tree.
- Computing carry signals and the final sum.
- Writing and simulating the RTL.
- Reporting synthesis utilization and timing.
- Evaluating scalability and implementation limitations.
- Optionally producing a parameterized N-bit implementation.

---

## Highlighted Project - IEEE 754 Floating-Point Adder/Subtractor

The main project was an RTL implementation of a floating-point adder/subtractor based on the **IEEE 754 standard**.

Unlike a basic integer adder, the design required several arithmetic and control stages to operate together correctly, including exponent comparison, significand alignment, effective addition or subtraction, normalization, rounding, exception handling, and final result packing.

<p align="center">
  <img width="700" alt="IEEE 754 Floating-Point Adder/Subtractor Architecture" src="https://github.com/user-attachments/assets/35342b87-ae75-401c-91e1-2f177086ccc8" />
</p>

<p align="center">
  <em>High-level architecture of the IEEE 754 floating-point adder/subtractor.</em>
</p>

### Project Highlights

- Implements the main datapath stages required for IEEE 754 floating-point addition and subtraction.
- Separates the design into clear functional blocks for easier understanding, verification, and optimization.
- Unpacks operands into sign, exponent, and significand fields.
- Compares exponents and aligns the smaller significand before arithmetic.
- Determines the effective operation from the operand signs and requested add/subtract function.
- Supports normalization before and after rounding when required.
- Uses guard, round, and sticky information for accurate rounding.
- Handles special floating-point values and exceptional conditions.
- Reassembles the final sign, exponent, and significand into IEEE 754 format.
- Demonstrates how a complete arithmetic algorithm can be translated into synthesizable RTL.

### Performance-Oriented Supporting Blocks

A special part of the project was the exploration and implementation of optimized supporting blocks such as:

- **LOC - Leading-One Counter**
- **LZC - Leading-Zero Counter**

These blocks determine the number of positions by which the arithmetic result must be shifted during normalization.

An optimized counter or tree-based implementation performs this operation more efficiently than checking the result sequentially one bit at a time. This reduces the normalization delay, which can form a significant part of the floating-point adder's critical path.

The project therefore provided experience not only with IEEE 754 arithmetic, but also with designing reusable low-level blocks that improve the performance of a larger datapath.

### Project Flow

The implemented datapath follows this overall sequence:

1. **Unpack:** extract and classify the sign, exponent, and significand.
2. **Compare:** determine the exponent difference and operand ordering.
3. **Align:** right-shift the smaller significand while preserving rounding information.
4. **Operate:** perform the effective significand addition or subtraction.
5. **Normalize:** use LOC/LZC logic to determine the required shift.
6. **Round:** apply the selected rounding behavior using guard, round, and sticky bits.
7. **Renormalize:** correct the result if rounding changes its magnitude.
8. **Pack:** generate the final IEEE 754 output and exception status.

---

## Skills Gained

- Translating arithmetic algorithms into RTL.
- Designing hierarchical and parameterized hardware.
- Comparing area, delay, fanout, and wiring tradeoffs.
- Identifying and optimizing critical paths.
- Writing testbenches and analyzing waveforms.
- Running FPGA synthesis and implementation.
- Reading utilization and timing reports.
- Structuring complex datapaths as reusable modules.

---

## Possible Future Improvement

The floating-point project would benefit from a more comprehensive and automated verification environment.

A stronger testbench should cover:

- Positive and negative zero.
- Normal and subnormal operands.
- Equal operands and complete cancellation.
- Large exponent differences.
- Overflow and underflow.
- Infinity and NaN combinations.
- Different sign combinations.
- Exact, inexact, and halfway rounding cases.
- Cases requiring normalization before or after rounding.

Future verification could also include a software reference model, constrained-random stimulus, assertions, functional coverage, and regression testing to provide greater confidence in IEEE 754 compliance.
