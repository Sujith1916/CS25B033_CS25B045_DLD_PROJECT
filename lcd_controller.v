`timescale 1ns / 1ps

module lcd_controller #(
    parameter integer CLK_HZ = 50000000
)(
    input wire clk,
    input wire reset,
    input wire [127:0] line1,
    input wire [127:0] line2,

    output reg lcd_rs,
    output reg lcd_e,
    output reg [7:0] lcd_data
);

    localparam integer INIT_WAIT_CYCLES = CLK_HZ / 50;
    localparam integer CLEAR_WAIT_CYCLES = CLK_HZ / 500;
    localparam integer REFRESH_CYCLES = CLK_HZ / 10;
    localparam integer BYTE_WAIT_CYCLES = CLK_HZ / 1000000;

    localparam WAIT_INIT    = 4'd0;
    localparam PREPARE      = 4'd1;
    localparam SETUP_WAIT   = 4'd2;
    localparam E_HIGH       = 4'd3;
    localparam E_LOW        = 4'd4;
    localparam BYTE_HOLD    = 4'd5;
    localparam CLEAR_WAIT   = 4'd6;
    localparam REFRESH_WAIT = 4'd7;

    reg [3:0] state;
    reg [31:0] count;

    reg [1:0] init_index;
    reg [5:0] phase;
    reg mode;

    reg [127:0] saved_line1;
    reg [127:0] saved_line2;

    reg [7:0] current_byte;
    reg current_rs;

    initial begin
        state = WAIT_INIT;
        count = 0;
        init_index = 0;
        phase = 0;
        mode = 0;
        saved_line1 = 0;
        saved_line2 = 0;
        current_byte = 0;
        current_rs = 0;
        lcd_rs = 0;
        lcd_e = 0;
        lcd_data = 0;
    end

    always @(posedge clk) begin

        if (reset) begin
            state <= WAIT_INIT;
            count <= 0;
            init_index <= 0;
            phase <= 0;
            mode <= 0;
            lcd_rs <= 0;
            lcd_e <= 0;
            lcd_data <= 0;
        end
        else begin

            case (state)

                WAIT_INIT: begin
                    if (count >= INIT_WAIT_CYCLES - 1) begin
                        count <= 0;
                        init_index <= 0;
                        mode <= 0;
                        current_byte <= 8'h38;
                        current_rs <= 0;
                        state <= PREPARE;
                    end
                    else
                        count <= count + 1'b1;
                end

                PREPARE: begin
                    lcd_data <= current_byte;
                    lcd_rs <= current_rs;
                    lcd_e <= 0;
                    count <= 0;
                    state <= SETUP_WAIT;
                end

                SETUP_WAIT: begin
                    if (count >= BYTE_WAIT_CYCLES - 1) begin
                        count <= 0;
                        lcd_e <= 1;
                        state <= E_HIGH;
                    end
                    else
                        count <= count + 1'b1;
                end

                E_HIGH: begin
                    if (count >= BYTE_WAIT_CYCLES - 1) begin
                        count <= 0;
                        lcd_e <= 0;
                        state <= E_LOW;
                    end
                    else
                        count <= count + 1'b1;
                end

                E_LOW: begin
                    if (count >= (BYTE_WAIT_CYCLES * 50) - 1) begin
                        count <= 0;
                        state <= BYTE_HOLD;
                    end
                    else
                        count <= count + 1'b1;
                end

                BYTE_HOLD: begin

                    if (!mode) begin

                        case (init_index)

                            2'd0: begin
                                current_byte <= 8'h0C;
                                current_rs <= 0;
                                init_index <= 1;
                                state <= PREPARE;
                            end

                            2'd1: begin
                                current_byte <= 8'h06;
                                current_rs <= 0;
                                init_index <= 2;
                                state <= PREPARE;
                            end

                            2'd2: begin
                                current_byte <= 8'h01;
                                current_rs <= 0;
                                init_index <= 3;
                                count <= 0;
                                state <= CLEAR_WAIT;
                            end

                            default: begin
                                mode <= 1;
                                phase <= 0;
                                saved_line1 <= line1;
                                saved_line2 <= line2;
                                current_byte <= 8'h80;
                                current_rs <= 0;
                                state <= PREPARE;
                            end

                        endcase
                    end
                    else begin

                        if (phase < 16) begin
                            current_byte <=
                                (saved_line1 >> ((15 - phase) * 8));
                            current_rs <= 1;
                            phase <= phase + 1'b1;
                            state <= PREPARE;
                        end

                        else if (phase == 16) begin
                            current_byte <= 8'hC0;
                            current_rs <= 0;
                            phase <= 17;
                            state <= PREPARE;
                        end

                        else if (phase < 33) begin
                            current_byte <=
                                (saved_line2 >> ((32 - phase) * 8));
                            current_rs <= 1;
                            phase <= phase + 1'b1;
                            state <= PREPARE;
                        end

                        else begin
                            count <= 0;
                            state <= REFRESH_WAIT;
                        end
                    end
                end

                CLEAR_WAIT: begin
                    if (count >= CLEAR_WAIT_CYCLES - 1) begin
                        count <= 0;
                        mode <= 1;
                        phase <= 0;
                        saved_line1 <= line1;
                        saved_line2 <= line2;
                        current_byte <= 8'h80;
                        current_rs <= 0;
                        state <= PREPARE;
                    end
                    else
                        count <= count + 1'b1;
                end

                REFRESH_WAIT: begin
                    if (count >= REFRESH_CYCLES - 1) begin
                        count <= 0;
                        phase <= 0;
                        saved_line1 <= line1;
                        saved_line2 <= line2;
                        current_byte <= 8'h80;
                        current_rs <= 0;
                        state <= PREPARE;
                    end
                    else
                        count <= count + 1'b1;
                end

                default: begin
                    state <= WAIT_INIT;
                    count <= 0;
                end

            endcase
        end
    end

endmodule