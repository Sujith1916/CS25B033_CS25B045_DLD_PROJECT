`timescale 1ns / 1ps

module tb_dual_auth_top;

    reg clk;
    reg enter_btn;
    reg reset_btn;
    reg [15:0] switches;

    wire lcd_rs;
    wire lcd_e;
    wire [7:0] lcd_data;

    dual_auth_top #(
        .DEBOUNCE_MS(1)
    ) dut (
        .clk(clk),
        .enter_btn(enter_btn),
        .reset_btn(reset_btn),
        .switches(switches),
        .lcd_rs(lcd_rs),
        .lcd_e(lcd_e),
        .lcd_data(lcd_data)
    );

    // 50 MHz clock: 20 ns period
    always #10 clk = ~clk;

    task press_enter;
        begin
            enter_btn = 1'b1;
            repeat (60000) @(posedge clk);

            enter_btn = 1'b0;
            repeat (60000) @(posedge clk);
        end
    endtask

    task press_reset;
        begin
            reset_btn = 1'b1;
            repeat (60000) @(posedge clk);

            reset_btn = 1'b0;
            repeat (60000) @(posedge clk);
        end
    endtask

    initial begin

        clk = 0;
        enter_btn = 0;
        reset_btn = 0;
        switches = 16'h0000;

        $display("--------------------------------");
        $display("DUAL AUTH TOP LEVEL TEST");
        $display("--------------------------------");

        // TEST 1: Reset
        press_reset();

        if (dut.attempts == 3 &&
            dut.auth_state == 2'b00)
            $display("PASS: Reset successful");
        else
            $display("FAIL: Reset test");

        // TEST 2: First four digits
        switches = 16'h1234;
        press_enter();

        if (dut.auth_state == 2'b01)
            $display("PASS: First code captured");
        else
            $display("FAIL: First code capture");

        // TEST 3: Second four digits
        switches = 16'h5678;
        press_enter();

        if (dut.access_granted &&
            dut.auth_state == 2'b11)
            $display("PASS: Access granted");
        else
            $display("FAIL: Access grant");

        // TEST 4: LCD outputs are not unknown
        if ((^lcd_data !== 1'bx) &&
            (lcd_rs !== 1'bx) &&
            (lcd_e !== 1'bx))
            $display("PASS: LCD outputs are defined");
        else
            $display("FAIL: LCD output contains unknown values");

        $display("--------------------------------");
        $display("TOP LEVEL TEST COMPLETED");
        $display("--------------------------------");

        #1000;
        $finish;
    end

    initial begin
        #100000000;
        $display("ERROR: Simulation timeout");
        $finish;
    end

endmodule