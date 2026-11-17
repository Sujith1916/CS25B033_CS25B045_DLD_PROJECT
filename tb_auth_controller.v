`timescale 1ns / 1ps

module tb_auth_controller;

    reg clk;
    reg reset;
    reg enter_pulse;
    reg [15:0] switches;

    wire [1:0] auth_state;
    wire [1:0] attempts;
    wire access_granted;
    wire invalid_input;

    auth_controller #(
        .CLK_HZ(100),
        .ERROR_SECONDS(1),
        .PASSCODE(32'h12345678)
    ) dut (
        .clk(clk),
        .reset(reset),
        .enter_pulse(enter_pulse),
        .switches(switches),
        .auth_state(auth_state),
        .attempts(attempts),
        .access_granted(access_granted),
        .invalid_input(invalid_input)
    );

    always #5 clk = ~clk;

    task press_enter;
        begin
            @(negedge clk);
            enter_pulse = 1'b1;
            @(negedge clk);
            enter_pulse = 1'b0;
        end
    endtask

    task reset_system;
        begin
            @(negedge clk);
            reset = 1'b1;
            @(negedge clk);
            reset = 1'b0;
        end
    endtask

    initial begin

        clk = 0;
        reset = 0;
        enter_pulse = 0;
        switches = 0;

        $display("--------------------------------");
        $display("AUTHENTICATION CONTROLLER TEST");
        $display("--------------------------------");

        reset_system();

        // TEST 1: Invalid BCD
        switches = 16'h12A4;
        press_enter();

        if (invalid_input && attempts == 3 &&
            auth_state == 2'b00)
            $display("PASS: Invalid BCD rejected");
        else
            $display("FAIL: Invalid BCD test");

        // TEST 2: Valid first half
        switches = 16'h1234;
        press_enter();

        if (auth_state == 2'b01 && !invalid_input)
            $display("PASS: First half accepted");
        else
            $display("FAIL: First half test");

        // TEST 3: Correct second half
        switches = 16'h5678;
        press_enter();

        if (access_granted && auth_state == 2'b11)
            $display("PASS: Correct password accepted");
        else
            $display("FAIL: Correct password test");

        // TEST 4: Reset after successful authentication
        reset_system();

        // TEST 5: First incorrect complete password
        switches = 16'h1111;
        press_enter();

        switches = 16'h2222;
        press_enter();

        if (attempts == 2 && auth_state == 2'b10)
            $display("PASS: First wrong attempt counted");
        else
            $display("FAIL: First wrong attempt");

        wait (auth_state == 2'b00);

        // TEST 6: Second incorrect complete password
        switches = 16'h1111;
        press_enter();

        switches = 16'h2222;
        press_enter();

        if (attempts == 1 && auth_state == 2'b10)
            $display("PASS: Second wrong attempt counted");
        else
            $display("FAIL: Second wrong attempt");

        wait (auth_state == 2'b00);

        // TEST 7: Third incorrect complete password
        switches = 16'h1111;
        press_enter();

        switches = 16'h2222;
        press_enter();

        if (auth_state == 2'b11 &&
            attempts == 0 &&
            !access_granted)
            $display("PASS: Locked after third failure");
        else
            $display("FAIL: Lockout test");

        $display("--------------------------------");
        $display("AUTHENTICATION TEST COMPLETED");
        $display("--------------------------------");

        #20;
        $finish;
    end

endmodule