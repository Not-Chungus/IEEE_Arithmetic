//complement or round first??? I will  complement first to avoid deciding wether to: (add or sub) ulp

module Round_sel_complement(

    input [27:0] Sum_normalized,
    
    output reg [24:0] Sum_Rounded,
    output reg Complement_Flag_2 // 1 if we need to complement

);

    reg [27:0] Sum_normalized_intermediate; // Sign | 1 | 23 fract

    wire G, R, S;
    assign G = Sum_normalized_intermediate[2]; // Guard bit
    assign R = Sum_normalized_intermediate[1]; // Round bit 
    assign S = Sum_normalized_intermediate[0]; // Sticky bit
    wire LSB;
    assign LSB = Sum_normalized_intermediate[3];

    always @(*) begin


        //Complement logic: if the sum is negative, we need to complement
        if (Sum_normalized[27] == 1'b1) begin // Check the sign bit of the normalized sum
            Complement_Flag_2 = 1'b1; 
            Sum_normalized_intermediate = ~Sum_normalized + 28'b1;
        end else begin
            Complement_Flag_2 = 1'b0;
            Sum_normalized_intermediate = Sum_normalized; 
        end
        
        //Rounding logic: Round to nearest even  [logic from reference]
        if (G == 1'b0 || (LSB == 1'b0 && R == 1'b0 && S == 1'b0)) begin  

            Sum_Rounded = Sum_normalized_intermediate[27:3];     //Chop (Round down)
            
        end else begin

            Sum_Rounded = Sum_normalized_intermediate[27:3] + 25'b1; //Round up, check if -ve : -1 ??

        end

        

    end



endmodule

//other way around:
/*
//Rounding logic: Round to nearest even  [logic from reference]
        if (G == 1'b0 || (LSB == 1'b0 && R == 1'b0 && S == 1'b0)) begin  

            Sum_normalized_intermediate = Sum_normalized[27:3];     //Chop (Round down)
            
        end else begin

            Sum_normalized_intermediate = Sum_normalized[27:3] + 25'b1; //Round up, check if -ve : -1 ??

        end

        //Complement logic: if the sum is negative, we need to complement
        if (Sum_normalized_intermediate[24] == 1'b1) begin // Check the sign bit of the normalized sum
            Complement_Flag_2 = 1'b1; 
            Sum_Rounded = ~Sum_normalized_intermediate + 25'b1;
        end else begin
            Complement_Flag_2 = 1'b0;
            Sum_Rounded = Sum_normalized_intermediate; 
        end
        
*/