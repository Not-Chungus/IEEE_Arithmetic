module Pre_shifter(
    input [7:0] exp_diff,  // from sub_and_swap | this is the shamt
    input [27:0] S_1, S_2, //only shift S_2
    input N_Flag, // from sub_and_swap (not in original design) | for getting the absolute value of the exp_diff
    output reg [27:0] S_1_out ,S_2_shifted

);

    wire S_2_sign_bit;
    assign S_2_sign_bit = S_2[27]; //MSB is the sign bit

    //GET absolute value of exp_diff
    wire [7:0] exp_diff_abs; // actually will need just five bits to represent the max shift of 24, but we will use 8 for simplicity
    assign exp_diff_abs = N_Flag ? (~exp_diff + 1'b1) : exp_diff; // Two's complement if negative

    reg [27:0] S_2_shifted_intermediate;

    wire [27:0] ones_mask;
    assign ones_mask = ~({28{1'b1}} >> exp_diff_abs); // 28 bits of 1's for sign extension : 111....11100000

    // Mask to catch bits that will be shifted out
    wire [27:0] lost_any_mask;
    assign lost_any_mask = ~({28{1'b1}} << exp_diff_abs);// Ex: If shift is 3, mask is 000...0111
    reg lost_any;
    reg sticky_bit;

   

    always @(*) begin
 
        //pass S1 as is
        S_1_out = S_1;
        //preform the shift on S2
        S_2_shifted_intermediate = S_2 >> exp_diff_abs; //may need clamp for large values
        
        //STICKY BIT LOGIC
        // If the shift is greater than the total width (28), the sticky bit must be 1.

        if (exp_diff_abs >= 8'd28) begin //exclude sign bit
            lost_any = |(S_2[26:0]); // Reduction OR: 1 if any bit in S_2[26:0] is 1
        end else begin
            // Bitwise AND S_2 with the mask of "bits to be lost"
            lost_any = |(S_2[26:0] & lost_any_mask[26:0]); 
        end

        sticky_bit = lost_any | S_2_shifted_intermediate[0]; // OR with the old sticky

        // Apply Sign Extension AND the Sticky Bit in one concatenation [No need?]
        if(S_2_sign_bit == 1'b1)  //sign extend using the mask 
            S_2_shifted = {(ones_mask | S_2_shifted_intermediate[27:1]),sticky_bit}; // OR with ones_mask to ensure sign extension
        else                      //zero extended by default, just sticky bit
            S_2_shifted = {S_2_shifted_intermediate[27:1],sticky_bit}; 
        
    end


endmodule

//do we need to get the absolute value of the exp_diff [DONE]
//sign extend s2 because it could have been complemented in sub_and_swap module [DONE]
//Add the sign bit and the three rounding bits (G R S) [DONE]
//Implement Sticky logic [Done]  Don't OR in the sign (MSB) bit? [Implemented]

//looks like i dont  need to sign extend S2 as it will never be complemented here lets leave it as is anyway
//may need to clamp the shift amount for large values
//does sticky bit get added like other bits?


//didnt implement the O(log k) variable shifter | maybe in the future



//significand: Sign | 1 | 23 bits of fraction | G | R | S