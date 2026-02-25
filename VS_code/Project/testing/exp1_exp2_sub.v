module sub_and_swap(

    input   [7:0]  expX, expY,

    output     [7:0]  exp_diff,
    output reg [7:0] exp_diff_abs,
    output     N_Flag  // N_Flag = 1 if expX < expY
);

    

    assign exp_diff = expX - expY; //SUBtractor
    assign N_Flag = (expX < expY);


    always @(*) begin  //GET absolute value of exp_diff
        exp_diff_abs = N_Flag ? (~exp_diff + 1'b1) : exp_diff; // Two's complement if negative
    end



endmodule

