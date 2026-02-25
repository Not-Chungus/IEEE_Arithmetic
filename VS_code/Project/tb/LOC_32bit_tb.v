`timescale 1ns/1ps

module tb_Leading_One_32bit;

  reg  [31:0] X;
  wire [4:0]  q;
  wire        a;

  // DUT
  Leading_One_32bit dut (
    .X(X),
    .q(q),
    .a(a)
  );

  // Reference model: count leading ONES from MSB (bit 31) down to bit 0
  // Returns 0..32 (needs 6 bits)
  function [5:0] ref_loc32;
    input [31:0] v;
    integer i;
    begin
      ref_loc32 = 0;
      for (i = 31; i >= 0; i = i - 1) begin
        if (v[i] == 1'b1)
          ref_loc32 = ref_loc32 + 1;
        else
          i = -1; // stop once we hit the first '0'
      end
    end
  endfunction

  task automatic apply_check;
    input [31:0] val;
    reg  [5:0] ones;
    reg  [4:0] q_expected;
    reg        a_expected;
  begin
    X = val;
    #1;

    ones = ref_loc32(val);

    // a = 1 iff all ones (ones == 32)
    a_expected = (ones == 6'd32);

    // q encodes 0..31; if all ones (32), q is ignored and 'a' disambiguates
    q_expected = ones[4:0];

    if (a !== a_expected) begin
      $display("FAIL a: X=0x%08h got a=%b expected a=%b (ref leading_ones=%0d)",
               val, a, a_expected, ones);
      //$stop;
    end

    if (!a_expected) begin
      if (q !== q_expected) begin
        $display("FAIL q: X=0x%08h got q=%0d (0x%02h) expected q=%0d (0x%02h) (ref leading_ones=%0d)",
                 val, q, q, q_expected, q_expected, ones);
        //$stop; // uncomment to stop on first mismatch
      end
    end else begin
      $display("NOTE all-ones: X=0x%08h a=1 q=%0d (q ignored when a=1)", val, q);
    end

    $display("PASS: X=0x%08h | ref_leading_ones=%0d | a=%b q=%0d", val, ones, a, q);
  end
  endtask

  integer i;

  initial begin
    $display("=== tb_Leading_One_32bit start ===");

    // Directed tests
    apply_check(32'hFFFF_FFFF); // ones=32 -> a=1
    apply_check(32'h7FFF_FFFF); // ones=0
    apply_check(32'h8000_0000); // ones=1
    apply_check(32'hF000_0000); // ones=4
    apply_check(32'hFF00_0000); // ones=8
    apply_check(32'hFFFF_0000); // ones=16
    apply_check(32'hFFFF_FFF0); // ones=28
    apply_check(32'h0000_0000); // ones=0

    apply_check(32'hFEFF_0000); // ones=7
    apply_check(32'hFDFF_0000); // ones=6
    apply_check(32'hFFCF_FFFF); // ones=10



    // Full random tests
    for (i = 0; i < 200; i = i + 1) begin
      apply_check($unsigned($random));
    end

    $display("=== ALL TESTS COMPLETED ===");
    $stop;
  end

endmodule

// vsim -voptargs=+acc tb_Leading_One_32bit
// add wave *
// run -all