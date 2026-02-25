module Carry_LookAhead_4bit(
    input Cin, g0, p0, g1, p1, g2, p2, g3, p3,
    output C1, C2, C3, Cout, G3_0, P3_0
);

    assign  C1 = g0 | (p0 & Cin);
    assign  C2 = g1 | (p1 & g0) | (p1 & p0 & Cin);
    assign  C3 = g2 | (p2 & g1) | (p2 & p1 & g0) | (p2 & p1 & p0 & Cin);
        //OPTION 1: More Area More Speed
    //assign  Cout = g3 | (p3 & g2) | (p3 & p2 & g1) | (p3 & p2 & p1 & g0) | (p3 & p2 & p1 & p0 & Cin);
        //OPTION 2: Less Area Less Speed    (As in slides)
    assign  Cout = g3 | (C3 & p3);



    assign G3_0 = g3 | (p3 & g2) | (p3 & p2 & g1) | (p3 & p2 & p1 & g0);
    assign P3_0 = p3 & p2 & p1 & p0;

endmodule