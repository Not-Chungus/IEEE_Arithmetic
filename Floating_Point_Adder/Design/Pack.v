module Pack(

    input sign_out,

    input [8:0] exp_final, //Final
    input exp_overflowed, //for pack to handle
    input exp_underflowed, //for pack to handle

    input [23:0] Sum_last,
    

    output [31:0] Sum

);

    reg sign_out_to_pack;
    reg [7:0] exp_to_pack;
    reg [22:0] fract_to_pack;

    //Sign ===================================== "if zero clear the sign bit"
    always @(*) begin
        if (Sum_last[23:0] == 24'd0) sign_out_to_pack = 0;
        else sign_out_to_pack = sign_out;
    end

    //Exponent==============================================================
    always @(*) begin

        if(exp_overflowed) begin
            exp_to_pack = 8'hFF;  //Infinity
        end else if(exp_underflowed) begin
            exp_to_pack = 8'h00;  //underflow
        end else if (Sum_last[23:0] == 24'd0)begin //zero
            exp_to_pack = 8'h00;
        end else begin
            exp_to_pack = exp_final[7:0]; //normal number
        end

    end

    //Fraction====================================(Chop implicit one)=======
    //Rule: Infinity: make f = 0 forcibly | Subnormal: keep f as is
    always @(*) begin

        if(exp_overflowed) begin
            fract_to_pack = 23'd0;  //Infinity
        end else if(exp_underflowed) begin
            fract_to_pack = Sum_last[22:0];  //underflow, chop implicit 0
        end else begin
            fract_to_pack = Sum_last[22:0]; //normal number, chop implicit 1
        end

    end

    assign Sum = {sign_out_to_pack,exp_to_pack,fract_to_pack};





endmodule


//1.handle if exponential overflowed (>127) clamp to inf | under (<-126) clamp to -inf [DONE]
//2.take bypassed operands from unpack