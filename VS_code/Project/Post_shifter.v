//The reference says both shifters should have the ability to shift by 0 bits
//But i dont see this case, i see we ALWAYS need to shift??
//never the result = [1,2)  ??  Both operands are [1,2)
module Post_shifter(

    input [24:0] S_sum,
    input cout, // from the adder | this is for determining if we need to do a right shift (in case of overflow)
    input Complement_Flag,

    output reg [24:0] S_normalized,
    output reg [7:0] exp_adjustment // this is the amount we need to adjust the exponent by (can be negative)

);
//Counters (for left shifting)=================================================
    reg [4:0] count_zeros, count_ones; //5 bits
    //reg [7:0] final_Count_zeros, final_Count_ones; //convert the 5 bit count to an 8 bit value for the exponent adjustment
    wire [31:0] to_be_counted_zeros, to_be_counted_ones; //32 bits input for the LZC and LOC modules
    wire allzeros_flag, allones_flag;

    assign to_be_counted_zeros = {S_sum[23:0], 8'hFF}; //8 ones padding, dont count MSB                           
    assign to_be_counted_ones = {S_sum[23:0], 8'h00}; //8 zeros padding, dont count MSB                           
    
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






//Right shifting: 

//Two seperate shifters
//First check if s1 was complemeneted (-ve) because if so we would never need to right shift
//because the result of -ve + +ve can never be "too big" to normalize
    //Right shifting============================[just zero extend]===========
    //need ability to shift right by no bits?
    always @(*) begin
        if (!Complement_Flag) begin //condition for right shift: both operands positive | half sure of this condition
            S_normalized =  S_sum >> 1; // right shift by 1, should zero extend auto
            exp_adjustment = 1; //increase the exponent 
        end else begin
    //Left shifting========================================================= 
            if(S_sum[24] == 1'b0) begin //detect zeros :LZC

                S_normalized = S_sum << count_zeros;
                exp_adjustment = ~{3'b000,count_zeros}; // decrease the exponent 

            end else begin //detect ones :LOC

                S_normalized = S_sum << count_ones;
                exp_adjustment = ~{3'b000,count_ones}; // decrease the exponent
            end
        end
    end




   


endmodule