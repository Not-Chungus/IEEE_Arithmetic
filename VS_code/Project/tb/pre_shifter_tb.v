`timescale 1ns/1ps

module tb_Pre_shifter;

  reg  [7:0]  exp_diff;
  reg  [23:0] S_1, S_2;
  wire [23:0] S_1_out, S_2_shifted;

  // DUT
  Pre_shifter dut (
    .exp_diff(exp_diff),
    .S_1(S_1),
    .S_2(S_2),
    .S_1_out(S_1_out),
    .S_2_shifted(S_2_shifted)
  );

  // task to apply and check one vector
  task automatic apply_check;
    input [7:0]  sh;
    input [23:0] a;
    input [23:0] b;
    reg   [23:0] exp_s1;
    reg   [23:0] exp_s2;
  begin
    exp_diff = sh;
    S_1      = a;
    S_2      = b;

    #1; // allow combinational settle

    exp_s1 = a;
    exp_s2 = (b >> sh);

    if (S_1_out !== exp_s1 || S_2_shifted !== exp_s2) begin
      $display("FAIL: sh=%0d S1=%h S2=%h | got S1_out=%h S2_shifted=%h | exp S1_out=%h exp S2_shifted=%h",
               sh, a, b, S_1_out, S_2_shifted, exp_s1, exp_s2);
      $stop;
    end else begin
      $display("PASS: sh=%0d S1=%h S2=%h | S1_out=%h S2_shifted=%h",
               sh, a, b, S_1_out, S_2_shifted);
    end
  end
  endtask

  initial begin
    $display("=== tb_Pre_shifter start ===");

    // Basic sanity
    apply_check(8'd0, 24'h123456, 24'hFEDCBA);  // shift 0
    apply_check(8'd1, 24'h000001, 24'h800000);  // shift 1
    apply_check(8'd4, 24'hABCDEF, 24'hF00000);  // shift 4
    apply_check(8'd8, 24'hFFFFFF, 24'h00FF00);  // shift 8

    // Edge shifts
    apply_check(8'd23, 24'h111111, 24'h800001); // keep only top bit -> LSB
    apply_check(8'd24, 24'h222222, 24'hFFFFFF); // shift >= width -> expected 0 in most simulators
    apply_check(8'd31, 24'h333333, 24'hABCDE0); // shift large

    // Random-ish
    apply_check(8'd7, 24'h0F0F0F, 24'h123456);
    apply_check(8'd13,24'h654321, 24'h89ABCD);

    $display("=== ALL TESTS PASSED ===");
    $stop;
  end

endmodule

//vsim -voptargs=+acc tb_Pre_shifter
//add wave *
//run -all