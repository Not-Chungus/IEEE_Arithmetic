module CLA_64bit_tb;

    reg [63:0] A,B;  //Inputs are regs
    reg cin;

    wire [63:0] sum; //Outputs are wires
    wire cout;

    //Instentiate
    Carry_LookAhead_64bit CLAtester (A, B, cin,sum, cout);

    //Task: validation of output
    task validate_output;
        if({cout,sum} !== A + B + cin) $display("Error: Adding A + B + cin, time: %0t", $time);
    endtask


    initial
    begin
        A=0; B=0;  //initial state
        cin =0;
        #10

        repeat(100) //100 randomized tests
        begin
            A = {$random, $random}; //$random gives 32 bit only
            B = {$random, $random};
            cin = $random % 2;   // ensure 0/1

            #5; //wait for output

            validate_output();
        end

        $display("Test case 1:");      //Test 1
        A = 64'd7; B = 64'd4; cin = 0;

        #10 //wait for out and monitor
        if(sum == 64'd11 && (!cout) ) $display("Test 1 pass, time: %0t",$time);
        else $display("Test 1 fail");


        #10
        $stop;
    end

    initial //monitor i/o
    begin   // this event is in the postponed event region
        $monitor("Time=%0t | A=%b | B=%b | cin =%b | Sum=%b | Cout=%b",
        $time,A,B,cin,sum,cout);
    end

endmodule

//vsim -voptargs=+acc CLA_64bit_tb
//add wave *
//run -all