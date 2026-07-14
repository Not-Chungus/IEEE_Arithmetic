# Computer Arithmetic Workshop

## Overview

This workshop explored how arithmetic operations are represented and implemented in digital hardware, with an emphasis on **speed, area, scalability, and critical-path optimization**.

The material progressed from basic number representation and binary addition to high-performance adder architectures, multioperand arithmetic, multiplication, and IEEE 754 floating-point hardware.

---

## Topics Covered and Concepts Learned

### 1. Number Representation

The workshop introduced the foundations required for implementing arithmetic circuits, including:

- Unsigned and signed binary number representations.
- Signed-magnitude and two's-complement formats.
- Dot notation as a visual method for understanding arithmetic operations.
- Addition flags, carry, signed overflow, and representable numeric ranges.
- The effect of number format on hardware complexity and arithmetic behavior.

### 2. Binary Adders

The adder sessions began with the construction of half adders, full adders, and Ripple-Carry Adders, followed by analysis of their delay and critical paths.

A major concept was the classification of each bit position using:

- **Generate:** the bit position produces a carry independently of the input carry.
- **Propagate:** the bit position passes an incoming carry to the next stage.
- **Kill:** the bit position prevents an incoming carry from propagating.

These signals were extended from individual bits to groups of bits, forming the basis of faster carry-generation networks.

The explored adder architectures included:

- Ripple-Carry Adder.
- Carry-Lookahead Adder and hierarchical CLA construction.
- Ling Adder and alternative carry formulations.
- Parallel-prefix adders.
- Brent-Kung, Kogge-Stone, and Sklansky prefix networks.
- Carry-Skip Adders, including variable-size and multilevel structures.
- Carry-Select Adders.
- Conditional-Sum Adders.
- Hybrid adder architectures.

The different architectures were compared in terms of:

- Logic depth and critical-path delay.
- Fanout.
- Wiring complexity.
- Gate count and hardware cost.
- Scalability to wide operands.

### 3. Multioperand Addition

The workshop also covered the problem of adding more than two operands efficiently.

The explored concepts included:

- Serial accumulation.
- Trees of conventional two-operand adders.
- Carry-Save Adders.
- 3:2 counters and compressors.
- Carry-save reduction trees.
- Wallace Trees.
- Dadda Trees.
- Larger parallel counters and compressor structures.

These techniques showed how several operands can be reduced to only two rows before using a final carry-propagating adder.

### 4. Multiplication

Multiplication was studied as a combination of partial-product generation and multioperand addition.

The covered concepts included:

- Binary partial products.
- Shift-and-add multiplication.
- Sequential multiplier architectures.
- Basic hardware multiplier datapaths.
- Signed multiplication.
- Reduction of partial products using carry-save structures, Wallace Trees, and Dadda Trees.

### 5. IEEE 754 and Real Arithmetic

The final part of the workshop explored floating-point representation and arithmetic based on the **IEEE 754 standard**.

The covered concepts included:

- Sign, biased exponent, and significand fields.
- Hidden leading bit.
- Normalized and special floating-point values.
- Rounding methods and rounding bias.
- Guard, round, and sticky bits.
- Floating-point exceptions and special values such as zero, infinity, and NaN.
- Floating-point addition and subtraction.
- Floating-point multiplication and division.
- Fused Multiply-Add.
- Logarithmic arithmetic units.

The floating-point adder/subtractor datapath was studied as a sequence of stages:

1. Unpack and classify the operands.
2. Compare and subtract the exponents.
3. Select or swap the operands when required.
4. Align the smaller significand.
5. Add or subtract the significands.
6. Detect the leading one or leading zero.
7. Normalize the result.
8. Round the result.
9. Perform post-rounding normalization.
10. Pack the sign, exponent, and significand into the final result.

---

## Assigned Tasks

### Task 1 - 64-bit Hierarchical Carry-Lookahead Adder

The first task was to design a **64-bit hierarchical Carry-Lookahead Adder** using a 4-bit CLA block as the basic building unit.

The work included:

- Designing the 4-bit carry-lookahead network.
- Generating bit-level and group-level generate and propagate signals.
- Building wider hierarchical carry networks from the 4-bit blocks.
- Extending the hierarchy to produce a complete 64-bit adder.
- Writing commented RTL code.
- Developing and running a simulation testbench.
- Capturing waveform and transcript results.
- Synthesizing and implementing the design using Vivado.
- Reporting FPGA utilization and critical-path delay.
- Discussing design limitations.
- Optionally creating a parameterized N-bit implementation.

### Task 2 - 64-bit Brent-Kung Parallel-Prefix Adder

The second task was to design a **64-bit parallel-prefix adder using the Brent-Kung carry network**.

The work included:

- Understanding the recursive Brent-Kung prefix structure.
- Mapping the prefix operation to generate and propagate carry operators.
- Constructing the prefix tree for 64-bit operands.
- Computing the carry signals and final sum.
- Writing and commenting the RTL implementation.
- Creating a simulation testbench and capturing its results.
- Running synthesis and implementation.
- Reporting resource utilization and critical-path timing.
- Evaluating the design's limitations and scalability.
- Optionally producing a parameterized N-bit version.

---

## Highlighted Project - IEEE 754 Floating-Point Adder/Subtractor

The main project was an RTL implementation of a floating-point adder/subtractor based on the **IEEE 754 standard**.

Unlike a basic integer adder, the project required the coordination of several arithmetic and control stages, including exponent comparison, significand alignment, effective addition or subtraction, normalization, rounding, exception handling, and final result packing.
<img width="811" height="1062" alt="image" src="https://github.com/user-attachments/assets/35342b87-ae75-401c-91e1-2f177086ccc8" />


### Project Highlights

- Implements the major datapath stages required for IEEE 754 floating-point addition and subtraction.
- Separates the design into clear functional blocks, making the architecture easier to understand, verify, and optimize.
- Handles the relationship between operand signs and the effective add/subtract operation.
- Aligns significands according to the exponent difference before arithmetic is performed.
- Uses guard, round, and sticky information to support accurate rounding.
- Includes normalization before and after rounding when required.
- Reassembles the final sign, exponent, and significand into IEEE 754 format.
- Demonstrates how theoretical arithmetic algorithms are converted into synthesizable RTL hardware.

### Performance-Oriented Supporting Blocks

A special part of the project was the implementation and exploration of supporting blocks such as:

- **LOC - Leading-One Counter**
- **LZC - Leading-Zero Counter**

These blocks determine the amount of normalization shift required after significand addition or subtraction.

Using an optimized counter or tree-based structure provides better performance than checking the result one bit at a time. This reduces the delay of the normalization path, which can be one of the most important critical paths in a floating-point adder.

The project therefore provided experience not only with IEEE 754 arithmetic, but also with designing reusable low-level arithmetic blocks for improved timing performance.

---

## Skills Gained

Through the sessions, tasks, and project, the workshop developed practical experience in:

- Translating arithmetic algorithms into RTL.
- Designing hierarchical and parameterized hardware.
- Analyzing propagation delay and critical paths.
- Comparing area, timing, fanout, and wiring tradeoffs.
- Writing simulation testbenches.
- Reading simulation waveforms and transcript results.
- Synthesizing and implementing designs on FPGA tools.
- Reviewing utilization and timing reports.
- Structuring a complex datapath as smaller reusable modules.
- Connecting mathematical correctness with hardware implementation details.

---

## Possible Future Improvement

The floating-point project would benefit from a more comprehensive and automated testbench.

A stronger verification environment should systematically cover IEEE 754 corner cases, including:

- Positive and negative zero.
- Normal and subnormal operands.
- Equal operands and complete cancellation.
- Very large exponent differences.
- Overflow and underflow.
- Infinity and NaN combinations.
- Different operand-sign combinations.
- Exact and inexact results.
- Rounding boundaries and halfway cases.
- Cases that require normalization before or after rounding.

The testbench could also use a software reference model, constrained-random stimulus, assertions, functional coverage, and regression testing to provide greater confidence in full IEEE 754 compliance.
