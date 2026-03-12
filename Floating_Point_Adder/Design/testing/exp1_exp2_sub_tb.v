`timescale 1ns/1ps

module tb_sub_and_swap;

  reg  [7:0] expX, expY;
  wire [7:0] exp_diff;
  wire [7:0] exp_diff_abs;
  wire       N_Flag;

  // DUT
  sub_and_swap dut (
    .expX(expX),
    .expY(expY),
    .exp_diff(exp_diff),
    .exp_diff_abs(exp_diff_abs),
    .N_Flag(N_Flag)
  );

  task automatic apply_check;
    input [7:0] x;
    input [7:0] y;
    reg   expected_nf;
    reg  [7:0] expected_diff;
    reg  [7:0] expected_abs;
    integer signed_diff;
    integer abs_true;
  begin
    expX = x;
    expY = y;
    #1;

    expected_nf   = (x < y);
    expected_diff = (x - y); // wraps to 8-bit
    expected_abs  = expected_nf ? (~expected_diff + 8'd1) : expected_diff;

    // Check N_Flag
    if (N_Flag !== expected_nf) begin
      $display("FAIL N_Flag: expX=%0d expY=%0d got=%b expected=%b",
               x, y, N_Flag, expected_nf);
      $stop;
    end

    // Check exp_diff
    if (exp_diff !== expected_diff) begin
      $display("FAIL exp_diff: expX=%0d expY=%0d got=0x%02h expected=0x%02h",
               x, y, exp_diff, expected_diff);
      $stop;
    end

    // Check exp_diff_abs
    if (exp_diff_abs !== expected_abs) begin
      $display("FAIL exp_diff_abs: expX=%0d expY=%0d got=0x%02h expected=0x%02h (exp_diff=0x%02h N_Flag=%b)",
               x, y, exp_diff_abs, expected_abs, exp_diff, N_Flag);
      $stop;
    end

    // Informational: compare with true abs in integer math
    signed_diff = $signed({1'b0,x}) - $signed({1'b0,y}); // [-255..255]
    abs_true    = (signed_diff < 0) ? -signed_diff : signed_diff;

    if (abs_true > 127) begin
      $display("NOTE: true |expX-expY|=%0d (>127). DUT exp_diff_abs=0x%02h (8-bit wrap behavior).",
               abs_true, exp_diff_abs);
    end

    $display("PASS: expX=%0d expY=%0d | exp_diff=0x%02h N_Flag=%b exp_diff_abs=0x%02h",
             x, y, exp_diff, N_Flag, exp_diff_abs);
  end
  endtask

  integer i;

  initial begin
    $display("=== tb_sub_and_swap start ===");

    // Directed tests
    apply_check(8'd5,   8'd3);
    apply_check(8'd3,   8'd5);
    apply_check(8'd0,   8'd128);
    apply_check(8'd0,   8'd129); // NOTE: abs_true=129 (>127)
    apply_check(8'd1,   8'd130); // NOTE: abs_true=129 (>127)
    apply_check(8'd200, 8'd10);
    apply_check(8'd10,  8'd200); // large negative diff

    // Random tests
    for (i = 0; i < 50; i = i + 1) begin
      apply_check($random, $random);
    end

    $display("=== ALL TESTS COMPLETED ===");
    $finish;
  end

endmodule
//vsim -voptargs=+acc tb_sub_and_swap