module Pre_shifter(
    input [7:0] exp_diff,  // from sub_and_swap | this is the shamt
    input [27:0] S_1, S_2, //only shift S_2
    input N_Flag, // from sub_and_swap (not in original design) | for getting the absolute value of the exp_diff
    output reg [27:0] S_1_out ,S_2_shifted

);

    reg [7:0] exp_diff_abs; // actually will need just five bits to represent the max shift of 24, but we will use 8 for simplicity
    reg [27:0] S_2_shifted_intermediate;

    wire [27:0] ones_mask;
    assign ones_mask = ~({28{1'b1}} >> exp_diff_abs); // 28 bits of 1's for sign extension : 111....11100000

    wire S_2_sign_bit;
    assign S_2_sign_bit = S_2[27]; //MSB is the sign bit


    always @(*) begin  //GET absolute value of exp_diff
        exp_diff_abs = N_Flag ? (~exp_diff + 1'b1) : exp_diff; // Two's complement if negative
    end

    always @(*) begin
        S_1_out = S_1;
        S_2_shifted_intermediate = S_2 >> exp_diff_abs;
        if(S_2_sign_bit == 1'b1)  //sign extend using the mask 
            S_2_shifted = ones_mask | S_2_shifted_intermediate; 
        else
            S_2_shifted = S_2_shifted_intermediate; 
        
    end


endmodule

//do we need to get the absolute value of the exp_diff [DONE]
//sign extend s2 because it could have been complemented in sub_and_swap module [DONE]
//Add the sign bit and the three rounding bits (G R S) [DONE]
//implement Sticky logic



//didnt implement the O(log k) | maybe in the future