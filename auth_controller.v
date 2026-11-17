`timescale 1ns / 1ps

module auth_controller #(
    parameter integer CLK_HZ = 50000000,
    parameter integer ERROR_SECONDS = 3,
    parameter [31:0] PASSCODE = 32'h12345678
)(
    input wire clk,
    input wire reset,
    input wire enter_pulse,
    input wire [15:0] switches,

    output reg [1:0] auth_state,
    output reg [1:0] attempts,
    output reg access_granted,
    output reg invalid_input
);

    localparam FIRST_INPUT  = 2'b00;
    localparam SECOND_INPUT = 2'b01;
    localparam ERROR_WAIT   = 2'b10;
    localparam TERMINAL     = 2'b11;

    localparam integer ERROR_LIMIT =
        CLK_HZ * ERROR_SECONDS;

    reg [15:0] first_code;
    reg [31:0] error_count;

    integer i;
    reg bcd_valid;

    initial begin
        auth_state = FIRST_INPUT;
        attempts = 3;
        access_granted = 0;
        invalid_input = 0;
        first_code = 0;
        error_count = 0;
    end

    always @(*) begin
        bcd_valid = 1'b1;

        for (i = 0; i < 4; i = i + 1) begin
            if (switches[i*4 +: 4] > 4'd9)
                bcd_valid = 1'b0;
        end
    end

    always @(posedge clk) begin

        if (reset) begin
            auth_state <= FIRST_INPUT;
            attempts <= 3;
            access_granted <= 0;
            invalid_input <= 0;
            first_code <= 0;
            error_count <= 0;
        end
        else begin

            case (auth_state)

                FIRST_INPUT: begin
                    if (enter_pulse) begin
                        if (!bcd_valid) begin
                            invalid_input <= 1;
                        end
                        else begin
                            first_code <= switches;
                            invalid_input <= 0;
                            auth_state <= SECOND_INPUT;
                        end
                    end
                end

                SECOND_INPUT: begin
                    if (enter_pulse) begin
                        if (!bcd_valid) begin
                            invalid_input <= 1;
                        end
                        else begin
                            invalid_input <= 0;

                            if ({first_code, switches} == PASSCODE) begin
                                access_granted <= 1;
                                auth_state <= TERMINAL;
                            end
                            else begin
                                error_count <= 0;

                                if (attempts > 0)
                                    attempts <= attempts - 1'b1;

                                if (attempts == 1) begin
                                    attempts <= 0;
                                    access_granted <= 0;
                                    auth_state <= TERMINAL;
                                end
                                else begin
                                    auth_state <= ERROR_WAIT;
                                end
                            end
                        end
                    end
                end

                ERROR_WAIT: begin
                    if (error_count >= ERROR_LIMIT - 1) begin
                        error_count <= 0;
                        first_code <= 0;
                        invalid_input <= 0;
                        auth_state <= FIRST_INPUT;
                    end
                    else begin
                        error_count <= error_count + 1'b1;
                    end
                end

                TERMINAL: begin
                    // Wait for reset.
                end

                default: begin
                    auth_state <= FIRST_INPUT;
                end

            endcase
        end
    end

endmodule