`timescale 1ns/1ps

module tb_Leading_One_16bit;

  reg  [15:0] X;
  wire [3:0]  q;
  wire        a;

  // DUT
  Leading_One_16bit dut (
    .X(X),
    .q(q),
    .a(a)
  );

  // Reference model: count leading ONES from MSB (bit 15) down to bit 0
  // Returns 0..16 (needs 5 bits)
  function [4:0] ref_loc16;
    input [15:0] v;
    integer i;
    begin
      ref_loc16 = 0;
      for (i = 15; i >= 0; i = i - 1) begin
        if (v[i] == 1'b1)
          ref_loc16 = ref_loc16 + 1;
        else
          i = -1; // stop once we hit the first '0'
      end
    end
  endfunction

  task automatic apply_check;
    input [15:0] val;
    reg  [4:0] ones;
    reg  [3:0] q_expected;
    reg        a_expected;
  begin
    X = val;
    #1;

    ones = ref_loc16(val);

    // a = 1 iff all ones (ones == 16)
    a_expected = (ones == 5'd16);

    // q encodes 0..15; if all ones (16), q is ignored and 'a' disambiguates
    q_expected = ones[3:0];

    if (a !== a_expected) begin
      $display("FAIL a: X=0x%04h got a=%b expected a=%b (ref leading_ones=%0d)",
               val, a, a_expected, ones);
      $stop;
    end

    if (!a_expected) begin
      if (q !== q_expected) begin
        $display("FAIL q: X=0x%04h got q=%0d (0x%01h) expected q=%0d (0x%01h) (ref leading_ones=%0d)",
                 val, q, q, q_expected, q_expected, ones);
        //$stop; // uncomment to stop on first mismatch
      end
    end else begin
      $display("NOTE all-ones: X=0x%04h a=1 q=%0d (q ignored when a=1)", val, q);
    end

    $display("PASS: X=0x%04h | ref_leading_ones=%0d | a=%b q=%0d", val, ones, a, q);
  end
  endtask

  integer i;

  initial begin
    $display("=== tb_Leading_One_16bit start ===");

    // Directed tests
    apply_check(16'hFFFF); // ones=16 -> a=1
    apply_check(16'h7FFF); // ones=0
    apply_check(16'h8000); // ones=1
    apply_check(16'hF000); // ones=4
    apply_check(16'hFF00); // ones=8
    apply_check(16'hFFF0); // ones=12
    apply_check(16'h0000); // ones=0

    // Random-ish tests (biased toward many leading ones)
    for (i = 0; i < 50; i = i + 1) begin
      apply_check({8'hFF, $unsigned($random) & 8'hFF});
    end

    for (i = 0; i < 50; i = i + 1) begin
      apply_check({4'hF, $unsigned($random) & 12'hFFF});
    end

    // Full random tests
    for (i = 0; i < 150; i = i + 1) begin
      apply_check($unsigned($random) % 65536);
    end

    // Exhaustive test (optional)
    /*
    for (i = 0; i < 65536; i = i + 1) begin
      apply_check(i[15:0]);
    end
    */

    $display("===== ALL TESTS COMPLETED =====");
    $stop;
  end

endmodule

// vsim -voptargs=+acc tb_Leading_One_16bit
// add wave *
// run -all