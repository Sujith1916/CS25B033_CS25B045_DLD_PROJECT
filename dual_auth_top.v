`timescale 1ns / 1ps

module dual_auth_top #(
    parameter integer DEBOUNCE_MS = 20
)(
    input wire clk,
    input wire enter_btn,
    input wire reset_btn,
    input wire [15:0] switches,

    output wire lcd_rs,
    output wire lcd_e,
    output wire [7:0] lcd_data
);

    wire enter_pulse;
    wire reset_pulse;

    wire [1:0] auth_state;
    wire [1:0] attempts;

    wire access_granted;
    wire invalid_input;

    reg [127:0] message1;
    reg [127:0] message2;

    // ENTER button debounce
    debounce #(
        .CLK_HZ(50000000),
        .DEBOUNCE_MS(DEBOUNCE_MS)
    ) enter_debounce (
        .clk(clk),
        .reset(1'b0),
        .button_in(enter_btn),
        .button_pulse(enter_pulse)
    );

    // RESET button debounce
    debounce #(
        .CLK_HZ(50000000),
        .DEBOUNCE_MS(DEBOUNCE_MS)
    ) reset_debounce (
        .clk(clk),
        .reset(1'b0),
        .button_in(reset_btn),
        .button_pulse(reset_pulse)
    );

    // Authentication controller
    auth_controller #(
        .CLK_HZ(50000000),
        .ERROR_SECONDS(3),
        .PASSCODE(32'h12345678)
    ) auth_unit (
        .clk(clk),
        .reset(reset_pulse),
        .enter_pulse(enter_pulse),
        .switches(switches),
        .auth_state(auth_state),
        .attempts(attempts),
        .access_granted(access_granted),
        .invalid_input(invalid_input)
    );

    // LCD message selection
    always @(*) begin

        message1 = "                ";
        message2 = "                ";

        case (auth_state)

            2'b00: begin
                if (invalid_input) begin
                    message1 = "INVALID BCD     ";
                    message2 = "ENTER 0 TO 9    ";
                end
                else begin
                    message1 = "ENTER CODE 1    ";
                    message2 = "SET 4 DIGITS    ";
                end
            end

            2'b01: begin
                if (invalid_input) begin
                    message1 = "INVALID BCD     ";
                    message2 = "ENTER 0 TO 9    ";
                end
                else begin
                    message1 = "ENTER CODE 2    ";
                    message2 = "SET 4 DIGITS    ";
                end
            end

            2'b10: begin
                message1 = "WRONG CODE!     ";

                case (attempts)
                    2'd3: message2 = "TRIES LEFT: 3   ";
                    2'd2: message2 = "TRIES LEFT: 2   ";
                    2'd1: message2 = "TRIES LEFT: 1   ";
                    default: message2 = "TRIES LEFT: 0   ";
                endcase
            end

            2'b11: begin
                if (access_granted) begin
                    message1 = "ACCESS GRANTED  ";
                    message2 = "WELCOME!        ";
                end
                else begin
                    message1 = "SYSTEM LOCKED   ";
                    message2 = "RESET REQUIRED  ";
                end
            end

            default: begin
                message1 = "                ";
                message2 = "                ";
            end

        endcase
    end

    // LCD controller
    lcd_controller #(
        .CLK_HZ(50000000)
    ) lcd_unit (
        .clk(clk),
        .reset(reset_pulse),
        .line1(message1),
        .line2(message2),
        .lcd_rs(lcd_rs),
        .lcd_e(lcd_e),
        .lcd_data(lcd_data)
    );

endmodule