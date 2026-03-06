//Both shifters should have the ability to shift by 0 bits
module Post_shifter(

    input [27:0] S_sum,
    input cout, // from the adder | this is for determining if we need to do a right shift (in case of overflow)
    input Complement_Flag,

    output reg [27:0] S_normalized,
    output reg [7:0] exp_adjustment // this is the amount we need to adjust the exponent by (can be negative)

);
//Counters (for left shifting)=================================================
    wire [4:0] count_zeros, count_ones; //5 bits
    wire [31:0] to_be_counted_zeros, to_be_counted_ones; //32 bits input for the LZC and LOC modules
    wire allzeros_flag, allones_flag;

    assign to_be_counted_zeros = {S_sum[26:0], 5'b11111}; //5 ones padding, dont count MSB                           
    assign to_be_counted_ones = {S_sum[26:0], 5'b00000}; //5 zeros padding, dont count MSB                           
    
    Leading_Zero_32bit LZC_32bit(
        .X(to_be_counted_zeros), //X is 32 bits
        .q(count_zeros),         //q is 5 bits
        .a(allzeros_flag) // we dont need the a output for this module
    );

    Leading_One_32bit LOC_32bit(
        .X(to_be_counted_ones), //X is 32 bits
        .q(count_ones),         //q is 5 bits
        .a(allones_flag) // we dont need the a output for this module
    );


    reg [27:0] S_normalized_intermediate;


    //Two seperate shifters
    //Right shifting============================[just zero extend]===========
    always @(*) begin


        if (!Complement_Flag) begin //condition for right shift generally [both +ve]

            if(cout != S_sum[27]) begin //condition for right shift with overflow [too big +ve] (can never be too big a -ve number)
                S_normalized_intermediate = S_sum >> 1; // right shift by 1, should zero extend auto
                S_normalized =  {S_normalized_intermediate[27:1],S_normalized_intermediate[0] | S_sum[0] }; // new sticky bit is OR of old sticky bit and new shifted bit
                exp_adjustment = 1; //increase the exponent

            end else begin //output already normalized, do nothing
                S_normalized_intermediate = S_sum;
                S_normalized = S_sum;
                exp_adjustment = 0;
            end
    //Left shifting========================================================
        end else begin //condition for left shift [generally] if negative S1 operand
            if((S_sum[27] == S_sum[26]) && (S_sum[27:0] != 28'd0)) begin //too small [11 (small -ve), 00 (small +ve)]
                
                if(S_sum[27] == 1'b0) begin //detect zeros :LZC
                S_normalized = S_sum << count_zeros;
                exp_adjustment = ~{3'b000,count_zeros} + 1; // decrease the exponent (-ve)

                end else begin //detect ones :LOC
                S_normalized = S_sum << count_ones;
                exp_adjustment = ~{3'b000,count_ones} + 1; // decrease the exponent (-ve)
                end

            end else begin //output already normalized, do nothing
                S_normalized = S_sum;
                exp_adjustment = 0;
            end

        end
    end


        


endmodule

//problems with boundry [-1]
//problem with 0 result? need for pack to handle later

