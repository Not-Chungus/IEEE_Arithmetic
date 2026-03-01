module last_normalize(

    input [24:0] Sum_Rounded,

    output reg [23:0] Sum_last,
    output reg Rounding_has_overflowed //to control to add 1 to exponent 

);

    always @(*) begin   //CHOP SIGN BIT
      
        if (Sum_Rounded[24] == 1'b1) begin// overflow detected

            Sum_last = 24'b0000_0000_0000_0000_0000_0000; //an only case no need for shift
            Rounding_has_overflowed = 1'b1;

        end else begin

            Sum_last = Sum_Rounded[23:0]; //an only case no need for shift
            Rounding_has_overflowed = 1'b0;

        end

    end


endmodule