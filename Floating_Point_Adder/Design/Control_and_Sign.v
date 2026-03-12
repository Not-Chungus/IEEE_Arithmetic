module Control_and_Sign(

    input signX, signY,
    input Addb_sub,
    
    input swapped_flag,         //from sub and swap
    input Complement_Flag_2,    //from round and selective complement for sign logic

    input [7:0] exp_adjustment, //from post shifter  
    input [7:0] exp_out,         //from sub and swap mux [already biased with 127]
    input Rounding_has_overflowed, //inc exp


    output reg cin,     //if S1 was complemented
    output reg Complement_Flag, //to sub and swap
    output sign_out,        //Final
    output [7:0] exp_final, //Final
    output reg exp_overflowed, //for pack to handle
    output reg exp_underflowed //for pack to handle
);

    reg flip_bit;

    wire [3:0] variable = {signX,Addb_sub,signY,swapped_flag};

//COMPLEMENT FLAG=======================================================
//SIGN BIT==============================================================
    always @(*) begin
        casex (variable) //can be optimized with kmap
                4'b000x: begin
                    Complement_Flag = 1'b0;
                    flip_bit = 1'b0;
            end 4'b0010: begin
                    Complement_Flag = 1'b1;
                    flip_bit = 1'b1;
            end 4'b0011: begin
                    Complement_Flag = 1'b1;
                    flip_bit = 1'b0;
            end 4'b1000: begin
                    Complement_Flag = 1'b1;
                    flip_bit = 1'b0;
            end 4'b1001: begin
                    Complement_Flag = 1'b1;
                    flip_bit = 1'b1;
            end 4'b101x: begin
                    Complement_Flag = 1'b0;
                    flip_bit = 1'b1;

            end 4'b0100: begin
                    Complement_Flag = 1'b1;
                    flip_bit = 1'b1;
            end 4'b0101: begin
                    Complement_Flag = 1'b1;
                    flip_bit = 1'b0;
            end 4'b011x: begin
                    Complement_Flag = 1'b0;
                    flip_bit = 1'b0;
            end 4'b110x: begin
                    Complement_Flag = 1'b0;
                    flip_bit = 1'b1;
            end 4'b1110: begin
                    Complement_Flag = 1'b1;
                    flip_bit = 1'b0;
            end 4'b1111: begin
                    Complement_Flag = 1'b1;
                    flip_bit = 1'b1;
            end

        endcase
    end

    assign sign_out = flip_bit ^ Complement_Flag_2;  // -ve * -ve = +ve  (11) > 0

//CIN FOR ADDER=========================================================
    always @(*) begin
        if(Complement_Flag) begin
            cin = 1'b1;
        end else begin
            cin = 1'b0;
        end
    end      

//Exponential Handeling==============================================================

        wire signed [9:0] exp_calc; // 10 bits to prevent overflow during intermediate math

        // We cast exp_out to 10 bits and add a leading 0 to ensure it's treated as positive 0-255
        assign exp_calc = $signed({2'b0, exp_out}) + 
                  $signed({exp_adjustment[7], exp_adjustment[7], exp_adjustment}) + 
                  $signed({9'b0, Rounding_has_overflowed});


        assign exp_final = exp_calc[7:0]; 



    always @(*) begin

        if(exp_calc >= 10'sd255) begin
        exp_overflowed = 1'b1;
        exp_underflowed = 1'b0;

        end else if(exp_calc <= 10'sd0) begin
        exp_overflowed = 1'b0;
        exp_underflowed = 1'b1;

        end else begin
        exp_overflowed = 1'b0;
        exp_underflowed = 1'b0;
        end

    end


endmodule



//TO DO:
//1. implement sign logic [sign_out] [DONE]
//2. take all exp adjustments and output final exp to add [DONE]
