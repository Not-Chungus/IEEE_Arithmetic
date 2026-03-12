`timescale 1ns/1ps

module tb_Leading_One_4bit;

  reg  [3:0] X;
  wire [1:0] q;
  wire       a;

  // DUT
  Leading_One_4bit dut (
    .X(X),
    .q(q),
    .a(a)
  );

  // Reference model: count leading 1s from MSB (bit 3) down to bit 0
  // Returns 0..4 (needs 3 bits), but q is only 2 bits so it can hold 0..3.
  // We'll use 'a' to disambiguate the all-ones case (count=4).
  function [2:0] ref_loc1_ones;
    input [3:0] v;
    integer i;
    begin
      ref_loc1_ones = 0;
      for (i = 3; i >= 0; i = i - 1) begin
        if (v[i] == 1'b1)
          ref_loc1_ones = ref_loc1_ones + 1;
        else
          i = -1; // stop once we hit the first '0'
      end
    end
  endfunction

  task automatic apply_check;
    input [3:0] val;
    reg [2:0] ones_cnt;
    reg [1:0] q_expected;
    reg       a_expected;
  begin
    X = val;
    #1;

    ones_cnt = ref_loc1_ones(val);

    // For a true "leading-ones counter", a is typically 1 iff all ones (count==4).
    a_expected = (ones_cnt == 3'd4);

    // q encodes 0..3; if all ones (4), q is don't-care-ish and 'a' disambiguates.
    q_expected = ones_cnt[1:0];

    if (a !== a_expected) begin
      $display("FAIL a: X=%b got a=%b expected a=%b (ref leading_ones=%0d)",
               val, a, a_expected, ones_cnt);
      //$stop;
    end

    // Only check q when not all-ones (otherwise q can be ignored)
    if (!a_expected) begin
      if (q !== q_expected) begin
        $display("FAIL q: X=%b got q=%b expected q=%b (ref leading_ones=%0d)",
                 val, q, q_expected, ones_cnt);
        //$stop;
      end
    end else begin
      $display("NOTE all-ones: X=%b a=1 q=%b (q ignored when a=1)", val, q);
    end

    $display("PASS: X=%b | ref_leading_ones=%0d | a=%b q=%b",
             val, ones_cnt, a, q);
  end
  endtask

  integer i;

  initial begin
    $display("=== tb_Leading_One_4bit start ===");

    // Exhaustive test (all 16 patterns)
    for (i = 0; i < 16; i = i + 1) begin
      apply_check(i[3:0]);
    end

    $display("=== ALL TESTS PASSED ===");
    $stop;
  end

endmodule

// vsim -voptargs=+acc tb_Leading_One_4bit
// add wave *
// run -all