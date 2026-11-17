`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.11.2026 15:22:51
// Design Name: 
// Module Name: debounce
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module debounce #(
    parameter integer CLK_HZ = 50000000,
    parameter integer DEBOUNCE_MS = 20
)(
    input wire clk,
    input wire reset,
    input wire button_in,
    output reg button_pulse
);

    localparam integer LIMIT =
        (CLK_HZ / 1000) * DEBOUNCE_MS;

    reg sync_1;
    reg sync_2;
    reg stable_state;
    reg [31:0] count;

    initial begin
        sync_1 = 0;
        sync_2 = 0;
        stable_state = 0;
        count = 0;
        button_pulse = 0;
    end

    always @(posedge clk) begin
        sync_1 <= button_in;
        sync_2 <= sync_1;

        if (reset) begin
            stable_state <= 0;
            count <= 0;
            button_pulse <= 0;
        end
        else begin
            button_pulse <= 0;

            if (sync_2 == stable_state) begin
                count <= 0;
            end
            else if (count >= LIMIT - 1) begin
                stable_state <= sync_2;
                count <= 0;

                if (sync_2)
                    button_pulse <= 1;
            end
            else begin
                count <= count + 1'b1;
            end
        end
    end

endmodule



