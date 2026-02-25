module Carry_LookAhead_64bit(    //using 16 bit CLA(s)  || This is top Module
    input [63:0] A,B,
    input Cin,
    output [63:0] S,
    output Cout
    );

//1.G, P Generation Logic================================================================================================================
    wire [63:0] g, p;
    assign g = A & B;
    assign p = A ^ B;
//=======================================================================================================================================



//2.Carry Network========================================================================================================================
    wire [63:0] C;   //wont use C[0] , C[16] , C[32] .....   in first level
    wire G15_0 ,P15_0  ,G31_16 ,P31_16  ,G47_32 ,P47_32  ,G63_48 ,P63_48; 
    assign C[0] = Cin;

//Layer1==================================================================
    //0-15
    Carry_LookAhead_16bit CLA_16bit_0_15
    (
        .Cin(Cin),
        .g(g[15:0]), .p(p[15:0]),
        .C(C[15:0]),.Cout(), //won't use C16 / Cout we will predict it 
        .G15_0(G15_0), .P15_0(P15_0)
    );

    //16-31
    Carry_LookAhead_16bit CLA_16bit_16_31
    (
        .Cin(C[16]),
        .g(g[31:16]), .p(p[31:16]),
        .C(C[31:16]),.Cout(), //won't use C32 / Cout we will predict it 
        .G15_0(G31_16), .P15_0(P31_16)
    );

    //32-47
    Carry_LookAhead_16bit CLA_16bit_32_47
    (
        .Cin(C[32]),
        .g(g[47:32]), .p(p[47:32]),
        .C(C[47:32]),.Cout(), //won't use C48 / Cout we will predict it 
        .G15_0(G47_32), .P15_0(P47_32)
    );

    //48-63
    Carry_LookAhead_16bit CLA_16bit_48_63
    (
        .Cin(C[48]),
        .g(g[63:48]), .p(p[63:48]),
        .C(C[63:48]),.Cout(), //won't use C64 / Cout we will get it from next level
        .G15_0(G63_48), .P15_0(P63_48)
    );

//Layer2==================================================================
    Carry_LookAhead_4bit CLA_4bit_for_Carry_Prediction
    (
        .Cin(Cin),
        .g0(G15_0), .g1(G31_16), .g2(G47_32), .g3(G63_48),
        .p0(P15_0), .p1(P31_16), .p2(P47_32), .p3(P63_48),
                   .C1(C[16]), .C2(C[32]),  .C3(C[48]),  .Cout(Cout), //Get C64 / Cout from this level
        .G3_0(), .P3_0()   //no need for Group Signal, last level reached
    );

//=======================================================================================================================================

//3.SUM Evaluation========================================================================================================================
    assign S = C ^ p;  //this easy :)


endmodule