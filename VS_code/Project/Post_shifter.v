//Find the number of bits eqivalent to S_sum[24] starting with S_sum[23]

module Post_shifter(

    input [24:0] S_sum,
    input cout, // from the adder | this is for determining if we need to do a right shift (in case of overflow)

    output reg [24:0] S_normalized,
    output reg [7:0] exp_adjustment, // this is the amount we need to adjust the exponent by (can be negative)

);

//Two seperate shifters
    //Right shifting========================================================
    //condition for right shift: cout != S_SUM[MSB]
    always @(*) begin
        if (cout != S_sum[24]) begin
            S_normalized = S_sum >> 1; // right shift by 1 
            exp_adjustment = -1; //decrease the exponent (-1 =  8'hFF)
        end else begin
    //Left shifting=========================================================               //race condition with left shift!
            if(S_sum[24] == 1'b0) begin //detect zeros :LZC

                S_normalized = S_sum << count_zeros;
                exp_adjustment = {3'b000,count_zeros}; // increase the exponent 

            end else begin //detect ones :LOC

                S_normalized = S_sum << count_ones;
                exp_adjustment = -count_ones; // decrease the exponent
            end
        end
    end


//Counters (for left shifting)=================================================
    reg [4:0] count_zeros, count_ones; //5 bits
    //reg [7:0] final_Count_zeros, final_Count_ones; //convert the 5 bit count to an 8 bit value for the exponent adjustment
    reg [32:0] to_be_counted;
    reg allzeros_flag, allones_flag;

    always @(*) begin
        to_be_counted = {S_sum[23:0], 8'hFF}; //8 ones padding, dont count MSB
    end                              
    
    Leading_Zero_32bit LZC_32bit(
        .X(to_be_counted), //X is 32 bits
        .q(count_zeros),         //q is 5 bits
        .a(allzeros_flag) // we dont need the a output for this module
    );

    Leading_One_32bit LOC_32bit(
        .X(to_be_counted), //X is 32 bits
        .q(count_ones),         //q is 5 bits
        .a(allones_flag) // we dont need the a output for this module
    );

   


endmodule