module sub_and_swap(

    input   [27:0] S_X, S_Y,
    input   [7:0]  expX, expY,
    input   Complement_Flag,

    output reg [27:0] S_1, S_2,
    output reg [7:0]  exp_out,
    output     [7:0]  exp_diff,
    output reg swapped_flag,
    output     N_Flag  // N_Flag = 1 if expX < expY
);

    
    reg [27:0] S_1_intermediate; 

    assign exp_diff = expX - expY; //SUBtractor
    assign N_Flag = (expX < expY) ;  //N Flag not from the SUBtractor, ran to issues with the MSB method, so we will directly compare expX and expY to get the N_Flag


    always @(*) begin           //SWAP logic=================================
        if (expX >= expY) begin  //NO SWAP, (S2 = SY) will be alligned
            swapped_flag = 1'b0;
            S_1_intermediate = S_X;
            S_2 = S_Y;
            
        end else begin          //SWAP, (S2 = SX) will be alligned
            swapped_flag = 1'b1;
            S_1_intermediate = S_Y;
            S_2 = S_X;
        end
    end

    always @(*) begin          //Selective complement=======================
        if (Complement_Flag)
            S_1 = ~S_1_intermediate; //Complement S_1
        else
            S_1 = S_1_intermediate;  //No change to S_1
    end

    //MUX for choosing the larger exponent==================================
    always @(*) begin
        if (N_Flag == 1'b0) //e1 is larger
            exp_out = expX;
        else                //e2 is larger
            exp_out = expY;
    end

endmodule


//To do:
// 1. add the sign bit [DONE] and the three rounding bits (G R S) [DONE]
// 2. maybe need to add a flag (o/p) [DONE]
// 3. maybe need to add (i/p) from CU [DONE]

// 4.Handle exterme exponential difference : 1 - 130 = -129 (129 shift ?!)