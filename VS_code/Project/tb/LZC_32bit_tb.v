`timescale 1ns/1ps

module tb_Leading_Zero_32bit;

  reg  [31:0] X;
  wire [4:0]  q;
  wire        a;

  // DUT
  Leading_Zero_32bit dut (
    .X(X),
    .q(q),
    .a(a)
  );

  // Reference model: count leading zeros from MSB (bit 31) down to bit 0
  function [5:0] ref_lzc32;   // needs 0..32, so 6 bits
    input [31:0] v;
    integer i;
    begin
      ref_lzc32 = 0;
      for (i = 31; i >= 0; i = i - 1) begin
        if (v[i] == 1'b0)
          ref_lzc32 = ref_lzc32 + 1;
        else
          i = -1; // stop (TB trick instead of break)
      end
    end
  endfunction

  task automatic apply_check;
    input [31:0] val;
    reg [5:0] lz;
    reg [4:0] q_expected;
    reg       a_expected;
  begin
    X = val;
    #1;

    lz = ref_lzc32(val);

    // a = 1 iff all zeros (lz == 32)
    a_expected = (lz == 6'd32);

    // q should encode lz (0..31). If all zero, q is don't-care-ish; 'a' disambiguates.
    q_expected = lz[4:0];

    if (a !== a_expected) begin
      $display("FAIL a: X=0x%08h got a=%b expected a=%b (ref lz=%0d)", val, a, a_expected, lz);
      //$stop;
    end

    // Only strictly check q when input isn't all zeros (otherwise q can be ignored)
    if (!a_expected) begin
      if (q !== q_expected) begin
        $display("FAIL q: X=0x%08h got q=%0d (0x%02h) expected q=%0d (0x%02h) (ref lz=%0d)",
                 val, q, q, q_expected, q_expected, lz);
        //$stop; // uncomment to stop on first mismatch
      end
    end else begin
      $display("NOTE all-zero: X=0x%08h a=1 q=%0d (q ignored when a=1)", val, q);
    end

    $display("PASS: X=0x%08h | ref_lz=%0d | a=%b q=%0d", val, lz, a, q);
  end
  endtask

  integer i;

  initial begin
    $display("=== tb_Leading_Zero_32bit start ===");

    // Directed tests
    apply_check(32'h8000_0000); // lz=0
    apply_check(32'h4000_0000); // lz=1
    apply_check(32'h0000_0001); // lz=31
    apply_check(32'h0000_001A); // lz=27
    apply_check(32'h00F0_0000); // lz=8
    apply_check(32'h0000_0000); // all zero: a=1

    // Random-ish tests (biased toward many leading zeros)
    for (i = 0; i < 50; i = i + 1) begin
      apply_check({16'h0000, $unsigned($random) & 16'hFFFF});
    end

    for (i = 0; i < 50; i = i + 1) begin
      apply_check({8'h00, $unsigned($random) & 24'hFFFFFF});
    end

    for (i = 0; i < 50; i = i + 1) begin
      apply_check({4'h0, $unsigned($random) & 28'hFFFFFFF});
    end

    // Random full-range tests
    for (i = 0; i < 50; i = i + 1) begin
      apply_check($unsigned($random));
    end

    // Exhaustive test (optional): 2^32 too large, but you can exhaust 16-bit subset:
    /*
    for (i = 0; i < 65536; i = i + 1) begin
      apply_check({i[15:0], 16'h0000});
      apply_check({16'h0000, i[15:0]});
    end
    */

    $display("=== ALL TESTS COMPLETED ===");
    $stop;
  end

endmodule

// vsim -voptargs=+acc tb_Leading_Zero_32bit
// add wave *
// run -all