//Reference: Advanced Digital System Design A Practical Guide to Verilog, chapter 12
//Leading One counter hierarchy================================================================
//4 bit LOC (base case)=====================================================
module Leading_One_4bit(
    input [3:0] X,
    output [1:0] q,
    output a
);
    assign a = (X == 4'b1111) ? 1'b1 : 1'b0; // if all bits are one, then a = 0, else a = 1

    assign q[0] = X[3] & (~X[2] | (X[1] & ~X[0]));  //expressions come from optimization of logic (K-map) 
    assign q[1] = X[3] & X[2] & (~X[1] | ~X[0]);
   
endmodule


//16 bit LOC (2nd level)=====================================================
module Leading_One_16bit(
    input [15:0] X,
    output reg [3:0] q,
    output a
);

    wire [1:0] option_3 , option_2, option_1, option_0;
    wire a0, a1, a2, a3;

    //Stage 1: Count leading ones in each 4-bit segment
    Leading_One_4bit Nibble_0_3(
        .X(X[3:0]),
        .q(option_3),
        .a(a3)
    );
    Leading_One_4bit Nibble_4_7(
        .X(X[7:4]),
        .q(option_2),
        .a(a2)
    );
    Leading_One_4bit Nibble_8_11(
        .X(X[11:8]),
        .q(option_1),
        .a(a1)
    );
    Leading_One_4bit Nibble_12_15(
        .X(X[15:12]),
        .q(option_0),
        .a(a0)
    );
    //Stage 2:
    //we cant quite use the same logic as the 4 bit LOCC for this stage | different logic


    always @(*) begin

        q[2] = a0 & (~a1 | (a2 & ~a3) ); 
        q[3] = a0 & a1 & (~a2 | ~a3); 

        case (q[3:2])
            2'b00: q[1:0] = option_0;
            2'b01: q[1:0] = option_1; 
            2'b10: q[1:0] = option_2; 
            2'b11: q[1:0] = option_3;
        endcase
    end

    //now for next (32) stage we need a
    //or assign a = (X == 16'hFFFF) ? 1'b1 : 1'b0; // if all bits are one, then a = 1, else a = 0
    assign a = a0 & a1 & a2 & a3;


endmodule


//32 bit LOC (3rd level)=====================================================
module Leading_One_32bit(
    input [31:0] X,
    output reg [4:0] q,
    output a //optional, for later stages if needed
);

    wire [3:0] option_1, option_0;
    wire a0, a1;

    //Stage 2: Count leading ones in each 16-bit segment
    Leading_One_16bit Nibble_0_15(
        .X(X[15:0]),
        .q(option_1),
        .a(a1)
    );
    Leading_One_16bit Nibble_16_31(
        .X(X[31:16]),
        .q(option_0),
        .a(a0)
    );
    //Stage 3: Determine which 4-bit segment has the leading zeros and calculate the total count
    //we cant quite use the same logic as the 4 bit LZC for this stage | different logic


    always @(*) begin

        q[4] = a0 & (~ a1);

        case (q[4])
            1'b0: q[3:0] = option_0;
            1'b1: q[3:0] = option_1;
        endcase
    end

    //now for next (32) stage we need a
    //or assign a = (X == 32'hFFFFFFFF) ? 1'b1 : 1'b0; // if all bits are one, then a = 1, else a = 0
    assign a = a0 & a1;


endmodule

