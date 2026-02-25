module Carry_LookAhead_16bit(    //using 4 bit CLA(s)
    input [15:0] g,p,         //ready from top module later
    input Cin,
    output [15:0] C,
    output Cout,
    output G15_0, P15_0
    );


//Carry Network========================================================================================================================
    //wire [15:0] C;   //wont use C[0] , C[4] , C[8] .....   in first level
    wire G3_0 ,P3_0  ,G7_4 ,P7_4  ,G11_8 ,P11_8  ,G15_12 ,P15_12;
    //assign C[0] = Cin;

//Layer1==================================================================
    //0-3
    Carry_LookAhead_4bit CLA_4bit_0_3
    (
        .Cin(Cin),
        .g0(g[0]), .g1(g[1]), .g2(g[2]), .g3(g[3]),
        .p0(p[0]), .p1(p[1]), .p2(p[2]), .p3(p[3]),
                   .C1(C[1]), .C2(C[2]), .C3(C[3]),.Cout(), //no need to take C4 / Cout we will predict it 
        .G3_0(G3_0), .P3_0(P3_0) 
    );

    //4-7
    Carry_LookAhead_4bit CLA_4bit_4_7
    (
        .Cin(C[4]),
        .g0(g[4]), .g1(g[5]), .g2(g[6]), .g3(g[7]),
        .p0(p[4]), .p1(p[5]), .p2(p[6]), .p3(p[7]),
                   .C1(C[5]), .C2(C[6]), .C3(C[7]),.Cout(), //no need to take C8 / Cout we will predict it
        .G3_0(G7_4), .P3_0(P7_4) 
    );

    //8-11
    Carry_LookAhead_4bit CLA_4bit_8_11
    (
        .Cin(C[8]),
        .g0(g[8]), .g1(g[9]), .g2(g[10]), .g3(g[11]),
        .p0(p[8]), .p1(p[9]), .p2(p[10]), .p3(p[11]),
                   .C1(C[9]), .C2(C[10]), .C3(C[11]),.Cout(), //no need to take C12 / Cout we will predict it
        .G3_0(G11_8), .P3_0(P11_8) 
    );

    //12-15
    Carry_LookAhead_4bit CLA_4bit_12_15
    (
        .Cin(C[12]),
        .g0(g[12]), .g1(g[13]), .g2(g[14]), .g3(g[15]),
        .p0(p[12]), .p1(p[13]), .p2(p[14]), .p3(p[15]),
                   .C1(C[13]), .C2(C[14]), .C3(C[15]),.Cout(), //no need to take C16 / Cout we will get it from next level
        .G3_0(G15_12), .P3_0(P15_12) 
    );

//Layer2==================================================================
    Carry_LookAhead_4bit CLA_4bit_for_Carry_Prediction
     (
        .Cin(Cin),
        .g0(G3_0), .g1(G7_4), .g2(G11_8), .g3(G15_12),
        .p0(P3_0), .p1(P7_4), .p2(P11_8), .p3(P15_12),
                   .C1(C[4]), .C2(C[8]),  .C3(C[12]),  .Cout(Cout), //Get C16 / Cout from this level
        .G3_0(G15_0), .P3_0(P15_0) 
    );


endmodule