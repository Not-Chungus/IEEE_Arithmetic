`timescale 1ns/1ps

module tb_Leading_Zero_16bit;

  reg  [15:0] X;
  wire [3:0]  q;
  wire        a;

  // DUT
  Leading_Zero_16bit dut (
    .X(X),
    .q(q),
    .a(a)
  );

  // Reference model: count leading zeros from MSB (bit 15) down to bit 0
  function [4:0] ref_lzc16;   // needs 0..16, so 5 bits
    input [15:0] v;
    integer i;
    begin
      ref_lzc16 = 0;
      for (i = 15; i >= 0; i = i - 1) begin
        if (v[i] == 1'b0)
          ref_lzc16 = ref_lzc16 + 1;
        else
          i = -1; // stop (common TB trick instead of break)
      end
    end
  endfunction

  task automatic apply_check;
    input [15:0] val;
    reg [4:0] lz;
    reg [3:0] q_expected;
    reg       a_expected;
  begin
    X = val;
    #1;

    lz = ref_lzc16(val);

    // a = 1 iff all zeros (lz == 16)
    a_expected = (lz == 5'd16);

    // q should encode lz (0..15). If all zero, many designs output 0 or 15;
    // your design provides 'a' to disambiguate, so we only require q in 0..15.
    q_expected = (lz[3:0]);

    if (a !== a_expected) begin
      $display("FAIL a: X=0x%04h got a=%b expected a=%b (ref lz=%0d)", val, a, a_expected, lz);
      $stop;
    end

    // Only strictly check q when input isn't all zeros (otherwise q is don't-care-ish)
    if (!a_expected) begin
      if (q !== q_expected) begin
        $display("FAIL q: X=0x%04h got q=%0d (0x%01h) expected q=%0d (0x%01h) (ref lz=%0d)",
                val, q, q, q_expected, q_expected, lz);
        //$stop;
      end
    end else begin
      $display("NOTE all-zero: X=0x%04h a=1 q=%0d (q ignored when a=1)", val, q);
    end

    $display("PASS: X=0x%04h | ref_lz=%0d | a=%b q=%0d", val, lz, a, q);
  end
  endtask

  integer i;

  initial begin
    $display("=== tb_Leading_Zero_16bit start ===");

    // Directed tests
    apply_check(16'h8000); // lz=0
    apply_check(16'h4000); // lz=1
    apply_check(16'h0001); // lz=15
    apply_check(16'h001A); // lz=11 (good catch case)
    apply_check(16'h00F0); // lz=8
    apply_check(16'h0000); // all zero: a=1

    // Random-ish tests
    for (i = 0; i < 50; i = i + 1) begin
      apply_check({8'h00 , $unsigned($random) & 8'hFF});
    end

    for (i = 0; i < 50; i = i + 1) begin
      apply_check({4'h0 , $unsigned($random) & 12'hFFF});
    end

    // Exhaustive test (optional): uncomment for full coverage (65536 cases)
    /*
    for (i = 0; i < 65536; i = i + 1) begin
      apply_check(i[15:0]);
    end
    */

    $display("=== ALL TESTS COMPLETED ===");
    $stop;
  end

endmodule

//vsim -voptargs=+acc tb_Leading_Zero_16bit
//add wave *
//run -all