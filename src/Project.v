//JK Flip Flop
module JK_FF (J, K, CLK, RST, Q);

    input J, K, CLK, RST;
    output Q;
    reg Q;

    always @(posedge CLK or posedge RST)
    begin
        if (RST)
            Q <= 1'b0;
        else
            case ({J,K})
                2'b00: Q <= Q;
                2'b01: Q <= 1'b0;
                2'b10: Q <= 1'b1;
                2'b11: Q <= ~Q;
            endcase
    end

endmodule	 

// Negative-edge JK flip-flop used to store the selected sequence
module JK_FF_NEG (J, K, CLK, RST, Q);

    input J, K, CLK, RST;
    output Q;
    reg Q;

    always @(negedge CLK or posedge RST)
    begin
        if (RST)
            Q <= 1'b0;
        else
            case ({J,K})
                2'b00: Q <= Q;
                2'b01: Q <= 1'b0;
                2'b10: Q <= 1'b1;
                2'b11: Q <= ~Q;
            endcase
    end

endmodule 
// JK excitation logic for the counter
module counter_logic (Q2, Q1, Q0, M, EN, J, K);

    input Q2, Q1, Q0, M, EN;
    output [2:0] J, K;

    assign J[2] = EN & (Q1 | Q0);
    assign K[2] = EN & Q0;

    assign J[1] = EN & ((M  & Q2)  |(M  & ~Q0) |(Q2 & ~Q0));

    assign K[1] = EN & ((Q0 & ~M) |(Q2 & ~Q0));

    assign J[0] = EN & (Q2 |(~M & ~Q1));

    assign K[0] = EN & (M |~Q2);

endmodule
// Sequence selection storage logic
module mode_logic (Q2, Q1, Q0, S, EN, JM, KM);

    input Q2, Q1, Q0, S, EN;
    output JM, KM;

    wire C;

    assign C = EN & ((Q2 & Q0) |(~Q2 & ~Q1 & ~Q0));

    assign JM = C & S;
    assign KM = C & ~S;

endmodule
// Top-level structural module of the special counter
module special_counter (CLK, RST, EN, S, Q);

    input CLK, RST, EN, S;
    output [2:0] Q;

    wire Q2, Q1, Q0;
    wire M;

    wire [2:0] J, K;
    wire JM, KM;

    counter_logic L1 (Q2, Q1, Q0,M, EN,J, K);

    mode_logic L2 (Q2, Q1, Q0,S, EN,JM, KM);

    JK_FF FF2 (J[2], K[2],CLK, RST,Q2);

    JK_FF FF1 (J[1], K[1],CLK, RST,Q1);

    JK_FF FF0 (J[0], K[0],CLK, RST,Q0);

    JK_FF_NEG FFM (JM, KM,CLK, RST,M);

    assign Q = {Q2, Q1, Q0};

endmodule
// Self-checking testbench for the special counter
module tb_special_counter;

    reg CLK, RST, EN, S;
    wire [2:0] Q;

    integer errors;

    special_counter DUT (CLK, RST, EN, S, Q);

    always #5 CLK = ~CLK;

    task check_Q;
        input [2:0] expected;
        begin
            @(posedge CLK);
            #1;

            if (Q !== expected)
            begin
                $display("ERROR at time %0t: expected Q = %b, actual Q = %b",$time, expected, Q);
                errors = errors + 1;
            end
            else
            begin
                $display("PASS at time %0t: Q = %b",$time, Q);
            end
        end
    endtask

    initial
    begin

        CLK    = 0;
        RST    = 1;
        EN     = 0;
        S      = 0;
        errors = 0;

        #2;

        if (Q !== 3'b000)
        begin
            $display("ERROR: Asynchronous reset failed");
            errors = errors + 1;
        end
        else
            $display("PASS: Reset -> Q = 000");

        @(posedge CLK);
        #1;

        RST = 0;
        EN  = 1;
        S   = 0;

        check_Q(3'b001);
        check_Q(3'b100);
        check_Q(3'b111);

        check_Q(3'b001);
        check_Q(3'b100);
        check_Q(3'b111);

        #1;
        EN = 0;

        check_Q(3'b111);
        check_Q(3'b111);

        #1;
        S = 1;

        check_Q(3'b111);

        #1;
        EN = 1;

        check_Q(3'b010);

        check_Q(3'b110);
        check_Q(3'b101);

        check_Q(3'b010);
        check_Q(3'b110);
        check_Q(3'b101);

        #1;
        S = 0;

        check_Q(3'b001);
        check_Q(3'b100);
        check_Q(3'b111);

        check_Q(3'b001);

        #1;
        S = 1;

        check_Q(3'b100);
        check_Q(3'b111);

        check_Q(3'b010);
        check_Q(3'b110);
        check_Q(3'b101);

        #2;
        RST = 1;

        #1;

        if (Q !== 3'b000)
        begin
            $display("ERROR: Asynchronous reset during operation failed");
            errors = errors + 1;
        end
        else
            $display("PASS: Asynchronous reset during operation -> Q = 000");

        #5;

        if (errors == 0)
        begin
            $display("====================================");
            $display("ALL TESTS PASSED");
            $display("====================================");
        end
        else
            $display("SIMULATION FINISHED WITH %0d ERROR(S)",errors);

        $finish;

    end

endmodule