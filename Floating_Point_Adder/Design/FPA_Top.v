module FPA_Top (
    input  [31:0] X,           // 32-bit input A
    input  [31:0] Y,           // 32-bit input B
    input  Addb_sub,           // 0 for Add, 1 for Subtract
    output [31:0] S            // 32-bit output result
);

    //==========================================================================
    // Internal signals
    //==========================================================================

    // Unpack outputs
    wire        signX, signY;
    wire [7:0]  expX_unpacked, expY_unpacked;
    wire [27:0] S_X_unpacked, S_Y_unpacked;  //has implicit one if normal

    // Control & sign logic
    wire        cin_from_control;
    wire        Complement_S1_Flag;
    wire        sign_out;
    wire [8:0]  exp_semi_final;  //weill still pass to pack first
    wire        exp_overflowed, exp_underflowed;

    // sub_and_swap outputs
    wire [27:0] S_1, S_2;
    wire [7:0]  exp_from_mux;
    wire [7:0]  exp_diff;
    wire        swapped_flag;
    wire        N_Flag;

    // Pre_shifter outputs
    wire [27:0] S_1_out, S_2_shifted;

    // Adder outputs (implemented in top)
    wire [27:0] S_sum;
    wire        cout;

    // Post_shifter outputs
    wire [27:0] S_normalized;
    wire [7:0]  exp_post_adjustment;

    // Round & selective complement outputs
    wire [24:0] Sum_Rounded;
    wire        Complement_Flag_at_rounding;

    // Last normalize outputs
    wire [23:0] Sum_last;
    wire        Rounding_has_overflowed;

    // Pack output
    //wire [31:0] Sum_packed;

    //==========================================================================
    // Module instantiations (SKELETON ONLY — fill in wiring inside ())
    //==========================================================================

    Unpack u_unpack (
        .X(X),
        .Y(Y),

        .signX(signX),
        .signY(signY),
        .expX(expX_unpacked),
        .expY(expY_unpacked),
        .S_X(S_X_unpacked),
        .S_Y(S_Y_unpacked)
    );

    Control_and_Sign u_control_and_sign (
        .signX(signX), //from unpack
        .signY(signY),
        .Addb_sub(Addb_sub), //from user
        .swapped_flag(swapped_flag),  //from sub and swap
        .Complement_Flag_2(Complement_Flag_at_rounding), //from round_select_complement
        .exp_adjustment(exp_post_adjustment),  //from post shifter
        .exp_out(exp_from_mux),   //"The bigger"
        .Rounding_has_overflowed(Rounding_has_overflowed),

        .cin(cin_from_control), //to adder 
        .Complement_Flag(Complement_S1_Flag),
        .sign_out(sign_out),
        .exp_final(exp_semi_final),
        .exp_overflowed(exp_overflowed),
        .exp_underflowed(exp_underflowed)
    );

    sub_and_swap u_sub_and_swap (
        .S_X(S_X_unpacked),
        .S_Y(S_Y_unpacked),
        .expX(expX_unpacked),
        .expY(expY_unpacked),
        .Complement_Flag(Complement_S1_Flag),

        .S_1(S_1),
        .S_2(S_2),
        .exp_out(exp_from_mux),
        .exp_diff(exp_diff),
        .swapped_flag(swapped_flag),
        .N_Flag(N_Flag)
    );

    Pre_shifter u_pre_shifter (
        .exp_diff(exp_diff),
        .S_1(S_1),
        .S_2(S_2),
        .N_Flag(N_Flag),

        .S_1_out(S_1_out),
        .S_2_shifted(S_2_shifted)
    );

    //---------------ADDER------------------------------------------------------
    // TODO (top-level): implement the adder here
    //   - Use S_1_out, S_2_shifted, and cin_from_control
    //   - Produce S_sum and cout
    //   Example (placeholder):
    assign {cout, S_sum} = S_1_out + S_2_shifted + cin_from_control;
    //--------------------------------------------------------------------------

    Post_shifter u_post_shifter (
        .S_sum(S_sum),
        .cout(cout),
        .Complement_Flag(Complement_S1_Flag),

        .S_normalized(S_normalized),
        .exp_adjustment(exp_post_adjustment)
    );

    Round_sel_complement u_round_sel_complement (
        .Sum_normalized(S_normalized),

        .Sum_Rounded(Sum_Rounded),
        .Complement_Flag_2(Complement_Flag_at_rounding)
    );

    last_normalize u_last_normalize (
        .Sum_Rounded(Sum_Rounded),

        .Sum_last(Sum_last),
        .Rounding_has_overflowed(Rounding_has_overflowed)
    );

    Pack u_pack (
        .sign_out(sign_out),
        .exp_final(exp_semi_final),
        .exp_overflowed(exp_overflowed),
        .exp_underflowed(exp_underflowed),
        .Sum_last(Sum_last),

        .Sum(S)  //<---FINAL!
    );

    

endmodule