`timescale 1ns/1ps

module tb_FPA_Top;

  reg  [31:0] X;
  reg  [31:0] Y;
  reg         Addb_sub;
  wire [31:0] S;

  // DUT
  FPA_Top dut (
    .X(X),
    .Y(Y),
    .Addb_sub(Addb_sub),
    .S(S)
  );

  // --------------------------------------------------------------------------
  // IEEE-754 binary32 decode to real (for readable printing)
  // --------------------------------------------------------------------------
  function real fp32_to_real;
    input [31:0] b;
    reg sign;
    integer exp;
    integer frac;
    real mant;
    integer e;
    real pow2;
    integer i;
    begin
      sign = b[31];
      exp  = b[30:23];
      frac = b[22:0];

      // Specials
      if (exp == 255) begin
        if (frac == 0) fp32_to_real = (sign ? -1.0 : 1.0) / 0.0; // +/-inf
        else           fp32_to_real = 0.0 / 0.0;                 // NaN
      end
      else if (exp == 0) begin
        if (frac == 0) begin
          fp32_to_real = sign ? -0.0 : 0.0;
        end else begin
          // subnormal: (-1)^sign * (frac / 2^23) * 2^-126
          mant = frac / 8388608.0; // 2^23
          e = -126;
          pow2 = 1.0;
          if (e >= 0) for (i=0; i<e; i=i+1) pow2 = pow2 * 2.0;
          else        for (i=0; i<-e; i=i+1) pow2 = pow2 / 2.0;
          fp32_to_real = (sign ? -1.0 : 1.0) * mant * pow2;
        end
      end
      else begin
        // normal: (-1)^sign * (1 + frac/2^23) * 2^(exp-127)
        mant = 1.0 + (frac / 8388608.0);
        e = exp - 127;
        pow2 = 1.0;
        if (e >= 0) for (i=0; i<e; i=i+1) pow2 = pow2 * 2.0;
        else        for (i=0; i<-e; i=i+1) pow2 = pow2 / 2.0;
        fp32_to_real = (sign ? -1.0 : 1.0) * mant * pow2;
      end
    end
  endfunction

  // --------------------------------------------------------------------------
  // Failure printer (Questa console)
  // --------------------------------------------------------------------------
  task automatic show_failure;
    input integer case_idx;
    input reg op;
    input reg [31:0] a_bits;
    input reg [31:0] b_bits;
    input reg [31:0] exp_sum;
    input reg [31:0] got_bits;
    real a_r, b_r, exp_r, got_r;
  begin
    a_r   = fp32_to_real(a_bits);
    b_r   = fp32_to_real(b_bits);
    exp_r = fp32_to_real(exp_sum);
    got_r = fp32_to_real(got_bits);

    $display("======================================================================");
    $display("**FAIL** case %0d  op(Add=0/Sub=1)=%0d", case_idx, op);
    $display("A=0x%08h (%e)   B=0x%08h (%e)", a_bits, a_r, b_bits, b_r);
    $display("EXP=0x%08h (%e) GOT=0x%08h (%e)", exp_sum, exp_r, got_bits, got_r);
    $display("");

    $display("-- Unpack --");
    $display("signX=%b signY=%b", dut.signX, dut.signY);
    $display("expX_unpacked=%0d expY_unpacked=%0d", dut.expX_unpacked, dut.expY_unpacked);
    $display("S_X_unpacked=0x%07h S_Y_unpacked=0x%07h", dut.S_X_unpacked, dut.S_Y_unpacked);
    $display("");

    $display("-- Control_and_Sign --");
    $display("cin=%b Complement_S1_Flag=%b sign_out=%b", dut.cin_from_control, dut.Complement_S1_Flag, dut.sign_out);
    $display("exp_semi_final=0x%03h exp_overflowed=%b exp_underflowed=%b",
             dut.exp_semi_final, dut.exp_overflowed, dut.exp_underflowed);
    $display("");

    $display("-- sub_and_swap --");
    $display("swapped_flag=%b N_Flag=%b exp_from_mux=0x%02h exp_diff=0x%02h",
             dut.swapped_flag, dut.N_Flag, dut.exp_from_mux, dut.exp_diff);
    $display("S_1=0x%07h S_2=0x%07h", dut.S_1, dut.S_2);
    $display("");

    $display("-- Pre_shifter --");
    $display("S_1_out=0x%07h S_2_shifted=0x%07h", dut.S_1_out, dut.S_2_shifted);
    $display("");

    $display("-- Adder --");
    $display("cout=%b S_sum=0x%07h", dut.cout, dut.S_sum);
    $display("");

    $display("-- Post_shifter --");
    $display("S_normalized=0x%07h exp_post_adjustment=0x%02h", dut.S_normalized, dut.exp_post_adjustment);
    $display("");

    $display("-- Round_sel_complement --");
    $display("Complement_Flag_at_rounding=%b Sum_Rounded=0x%07h",
             dut.Complement_Flag_at_rounding, dut.Sum_Rounded);
    $display("");

    $display("-- last_normalize --");
    $display("Sum_last=0x%06h Rounding_has_overflowed=%b", dut.Sum_last, dut.Rounding_has_overflowed);
    $display("");
  end
  endtask

  // --------------------------------------------------------------------------
  // Test runner: reads cases from cases_fp32.txt
  // Format per line:  <op> <A_hex> <B_hex> <Expected_hex>
  // Example:          0 3f800000 3f800000 40000000
  // --------------------------------------------------------------------------
  integer fd;
  integer rc;
  integer case_idx;
  reg [31:0] exp_sum;

  // dummy line buffer for fgets when skipping bad lines
  reg [1023:0] dummy_line;

  // Set to 1 if you want to stop immediately on first failure
  localparam STOP_ON_FIRST_FAIL = 0;

  initial begin
    fd = $fopen("../VS_code/Project/Project_tb/cases_fp32.txt", "r");
    if (fd == 0) begin
      $display("ERROR: could not open cases_fp32.txt");
      $stop;
    end

    $display("=== tb_FPA_Top start ===");
    case_idx = 0;

    while (!$feof(fd)) begin
      rc = $fscanf(fd, "%d %h %h %h\n", Addb_sub, X, Y, exp_sum);
      if (rc != 4) begin
        // skip malformed/blank lines
        rc = $fgets(dummy_line, fd);
      end else begin
        case_idx = case_idx + 1;
        #1; // combinational settle

        // Pretty print in scientific notation
        $display("Case %0d  op=%0d | A=%e (0x%08h)  B=%e (0x%08h)  =>  GOT=%e (0x%08h)  EXP=%e (0x%08h)",
                 case_idx, Addb_sub,
                 fp32_to_real(X), X,
                 fp32_to_real(Y), Y,
                 fp32_to_real(S), S,
                 fp32_to_real(exp_sum), exp_sum);

        // Compare
        if (S !== exp_sum) begin
          show_failure(case_idx, Addb_sub, X, Y, exp_sum, S);
          if (STOP_ON_FIRST_FAIL) begin
            $display("Stopping on first failure (STOP_ON_FIRST_FAIL=1).");
            $stop;
          end
        end
      end
    end

    $fclose(fd);
    $display("=== tb_FPA_Top done ===");
    $stop;
  end

endmodule

// vsim -voptargs=+acc tb_FPA_Top
// add wave *
// run -all
