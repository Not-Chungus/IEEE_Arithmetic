// Unpack two IEEE-754 single-precision (32-bit) floating-point words
// Outputs: sign bit, 8-bit exponent, 25-bit significand

module Unpack(
	input   [31:0] X, Y,

	output         signX,signY,   // sign: 1 bit
	output  [7:0]  expX,expY,     // exponent: 8 bits (biased)
	output  [27:0] S_X, S_Y       // significand: 28 bits (with implicit 1 | sign bit | G R S)
);

	// sign: MSB
	assign signX = X[31];
	assign signY = Y[31];

	// exponent: bits [30:23]
	assign expX  = X[30:23];
	assign expY  = Y[30:23];


	// significand (28 bits): sign bit , implicit leading bit, and fraction bits, G R S bits (intitialzed 0)
    // for normalized(exp != 0) the implicit leading bit is 1,
    // for denormals (exp == 0) leading bit is 0.
	assign S_X = (expX == 8'd0) ? {2'b00, X[22:0], 3'b000} : {2'b01, X[22:0], 3'b000};
	assign S_Y = (expY == 8'd0) ? {2'b00, Y[22:0], 3'b000} : {2'b01, Y[22:0], 3'b000};

endmodule


//To do:

//Add the sign bit [DONE]
//Add the three rounding bits (G R S) [DONE]


// Test for special cases: zero, infinity, NaN
// 1. If NAN : bypass the adder and output NAN directly
// 2. Address subnormals
// 3. Address 0 operands
