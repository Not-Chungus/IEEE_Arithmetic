module Brent_Kung_64bit_Adder
    (
        input [63:0] A,B,
        input Cin,
        output [63:0] S,
        output Cout
    ); 

//1.G, P Generation Logic==================================================================================
    wire [63:0] g, p;
    assign g = A & B;
    assign p = A ^ B;
//=========================================================================================================

//2.Carry Network==========================================================================================
    wire [63:0] C;
    wire [63:0] gout, pout;
    i64_input_net top_net(g,p, gout,pout);

    assign C[0] = Cin;
    genvar i;
    generate
        for (i = 0; i < 63; i = i + 1) begin : carry_eval
            assign C[i+1] = gout[i] | (pout[i] & Cin);
        end
    endgenerate 

    assign Cout = gout[63] | (pout[63] & Cin);
    
//=========================================================================================================

//3.SUM Evaluation=========================================================================================
    assign S = C ^ p;  //this easy :)
//=========================================================================================================


endmodule


module i64_input_net (input [63:0] gin,pin , output [63:0] gout,pout);

    wire [31:0] g_odd,p_odd, g_odd_next, p_odd_next;
    wire [31:0] g_even,p_even, g_even_next, p_even_next;

    wire [31:0] g_out_odd, p_out_odd;
//0.Split Odds and evens===================================================================================
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : split_odd_even
            assign g_even[i] = gin[2*i];
            assign p_even[i] = pin[2*i];

            assign g_odd[i]  = gin[2*i + 1];
            assign p_odd[i]  = pin[2*i + 1];
        end
    endgenerate


//1. [Work on Odds]=========(C Operation)===(64/2 loops)====================================================

    generate
        for (i = 0; i < 32; i = i + 1) begin : odd_c_ops
            C_operation C_odd (
                g_odd[i],  p_odd[i],
                g_even[i], p_even[i],
                g_odd_next[i], p_odd_next[i]
            );
        end
    endgenerate


//2. [Pass Ready Odds to layer below]----->[now Odds are ready for Out]=====================================

    i32_input_net net_6(g_odd_next,p_odd_next,g_out_odd,p_out_odd);

//3. [Work on Evens]=========[C Operation]========(64/2 - 1 Loops)===========================================

    generate
        for (i = 1; i < 32; i = i + 1) begin : even_c_ops
            C_operation C_even (
                g_even[i],  p_even[i],
                g_out_odd[i-1], p_out_odd[i-1],
                g_even_next[i], p_even_next[i]
            );
        end
    endgenerate


//4. Reassemble everything==================================================================================
    assign g_even_next[0] = g_even[0];
    assign p_even_next[0] = p_even[0];

    generate
        for (i = 0; i < 32; i = i + 1) begin : reassemble
            assign gout[2*i]     = g_even_next[i];
            assign pout[2*i]     = p_even_next[i];

            assign gout[2*i + 1] = g_out_odd[i];
            assign pout[2*i + 1] = p_out_odd[i];
        end
    endgenerate
endmodule


module i32_input_net (input [31:0] gin,pin , output [31:0] gout,pout);

    wire [15:0] g_odd,p_odd, g_odd_next, p_odd_next;
    wire [15:0] g_even,p_even, g_even_next, p_even_next;

    wire [15:0] g_out_odd, p_out_odd;
//0.Split Odds and evens===================================================================================
    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : split_odd_even
            assign g_even[i] = gin[2*i];
            assign p_even[i] = pin[2*i];

            assign g_odd[i]  = gin[2*i + 1];
            assign p_odd[i]  = pin[2*i + 1];
        end
    endgenerate


//1. [Work on Odds]=========(C Operation)===(32/2 loops)====================================================

    generate
        for (i = 0; i < 16; i = i + 1) begin : odd_c_ops
            C_operation C_odd (
                g_odd[i],  p_odd[i],
                g_even[i], p_even[i],
                g_odd_next[i], p_odd_next[i]
            );
        end
    endgenerate


//2. [Pass Ready Odds to layer below]----->[now Odds are ready for Out]=====================================

    i16_input_net net_5(g_odd_next,p_odd_next,g_out_odd,p_out_odd);

//3. [Work on Evens]=========[C Operation]========(32/2 - 1 Loops)===========================================

    generate
        for (i = 1; i < 16; i = i + 1) begin : even_c_ops
            C_operation C_even (
                g_even[i],  p_even[i],
                g_out_odd[i-1], p_out_odd[i-1],
                g_even_next[i], p_even_next[i]
            );
        end
    endgenerate


//4. Reassemble everything==================================================================================
    assign g_even_next[0] = g_even[0];
    assign p_even_next[0] = p_even[0];

    generate
        for (i = 0; i < 16; i = i + 1) begin : reassemble
            assign gout[2*i]     = g_even_next[i];
            assign pout[2*i]     = p_even_next[i];

            assign gout[2*i + 1] = g_out_odd[i];
            assign pout[2*i + 1] = p_out_odd[i];
        end
    endgenerate
endmodule




module i16_input_net (input [15:0] gin,pin , output [15:0] gout,pout);

    wire [7:0] g_odd,p_odd, g_odd_next, p_odd_next;
    wire [7:0] g_even,p_even, g_even_next, p_even_next;

    wire [7:0] g_out_odd, p_out_odd;
//0.Split Odds and evens===================================================================================
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : split_odd_even
            assign g_even[i] = gin[2*i];
            assign p_even[i] = pin[2*i];

            assign g_odd[i]  = gin[2*i + 1];
            assign p_odd[i]  = pin[2*i + 1];
        end
    endgenerate


//1. [Work on Odds]=========(C Operation)===(16/2 loops)====================================================

    generate
        for (i = 0; i < 8; i = i + 1) begin : odd_c_ops
            C_operation C_odd (
                g_odd[i],  p_odd[i],
                g_even[i], p_even[i],
                g_odd_next[i], p_odd_next[i]
            );
        end
    endgenerate


//2. [Pass Ready Odds to layer below]----->[now Odds are ready for Out]=====================================

    i8_input_net net_4(g_odd_next,p_odd_next,g_out_odd,p_out_odd);

//3. [Work on Evens]=========[C Operation]========(16/2 - 1 Loops)===========================================

    generate
        for (i = 1; i < 8; i = i + 1) begin : even_c_ops
            C_operation C_even (
                g_even[i],  p_even[i],
                g_out_odd[i-1], p_out_odd[i-1],
                g_even_next[i], p_even_next[i]
            );
        end
    endgenerate


//4. Reassemble everything==================================================================================
    assign g_even_next[0] = g_even[0];
    assign p_even_next[0] = p_even[0];

    generate
        for (i = 0; i < 8; i = i + 1) begin : reassemble
            assign gout[2*i]     = g_even_next[i];
            assign pout[2*i]     = p_even_next[i];

            assign gout[2*i + 1] = g_out_odd[i];
            assign pout[2*i + 1] = p_out_odd[i];
        end
    endgenerate
endmodule






module i8_input_net (input [7:0] gin,pin , output [7:0] gout,pout);

    wire [3:0] g_odd,p_odd, g_odd_next, p_odd_next;
    wire [3:0] g_even,p_even, g_even_next, p_even_next;

    wire [3:0] g_out_odd, p_out_odd;
//0.Split Odds and evens===================================================================================
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : split_odd_even
            assign g_even[i] = gin[2*i];
            assign p_even[i] = pin[2*i];

            assign g_odd[i]  = gin[2*i + 1];
            assign p_odd[i]  = pin[2*i + 1];
        end
    endgenerate


//1. [Work on Odds]=========(C Operation)===(8/2 loops)====================================================

    generate
        for (i = 0; i < 4; i = i + 1) begin : odd_c_ops
            C_operation C_odd (
                g_odd[i],  p_odd[i],
                g_even[i], p_even[i],
                g_odd_next[i], p_odd_next[i]
            );
        end
    endgenerate


//2. [Pass Ready Odds to layer below]----->[now Odds are ready for Out]=====================================

    i4_input_net net_3(g_odd_next,p_odd_next,g_out_odd,p_out_odd);

//3. [Work on Evens]=========[C Operation]========(8/2 - 1 Loops)===========================================

    generate
        for (i = 1; i < 4; i = i + 1) begin : even_c_ops
            C_operation C_even (
                g_even[i],  p_even[i],
                g_out_odd[i-1], p_out_odd[i-1],
                g_even_next[i], p_even_next[i]
            );
        end
    endgenerate

//4. Reassemble everything==================================================================================
    assign g_even_next[0] = g_even[0];
    assign p_even_next[0] = p_even[0];

    generate
        for (i = 0; i < 4; i = i + 1) begin : reassemble
            assign gout[2*i]     = g_even_next[i];
            assign pout[2*i]     = p_even_next[i];

            assign gout[2*i + 1] = g_out_odd[i];
            assign pout[2*i + 1] = p_out_odd[i];
        end
    endgenerate
endmodule




module i4_input_net (input [3:0] gin,pin , output [3:0] gout,pout);

    wire [1:0] g_odd,p_odd, g_odd_next, p_odd_next;
    wire [1:0] g_even,p_even, g_even_next, p_even_next;

    wire [1:0] g_out_odd, p_out_odd;
//0.Split Odds and evens===================================================================================
    assign g_odd = {gin[3],gin[1]};
    assign p_odd = {pin[3],pin[1]};
    assign g_even = {gin[2],gin[0]};
    assign p_even = {pin[2],pin[0]};
//1. [Work on Odds]=========(C Operation)===(4/2 loops)====================================================

    C_operation C_1 (g_odd[0],p_odd[0], g_even[0],p_even[0],  g_odd_next[0],p_odd_next[0]);
    C_operation C_2 (g_odd[1],p_odd[1], g_even[1],p_even[1],  g_odd_next[1],p_odd_next[1]);

//2. [Pass Ready Odds to layer below]----->[now Odds are ready for Out]====================================

    i2_input_net net_2(g_odd_next,p_odd_next,g_out_odd,p_out_odd);

//3. [Work on Evens]=========[C Operation]========(4/2 - 1 Loops)===========================================

    C_operation C_3 (g_even[1],p_even[1], g_out_odd[0],p_out_odd[0],  g_even_next[1],p_even_next[1]);


    assign gout = {g_out_odd[1], g_even_next[1], g_out_odd[0], g_even[0]};
    assign pout = {p_out_odd[1], p_even_next[1], p_out_odd[0], p_even[0]};

endmodule




module i2_input_net (input [1:0] gin,pin, output [1:0] gout,pout);
    
    C_operation C_0 (gin[1],pin[1], gin[0],pin[0],  gout[1],pout[1]);

    assign gout[0] = gin[0];
    assign pout[0] = pin[0];
endmodule



module C_operation(input gli,pli, gri,pri, output gl,pl);
    assign gl = gli | (pli & gri);
    assign pl = (pli & pri);

endmodule