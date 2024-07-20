`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/21/2024 10:39:12 PM
// Design Name: 
// Module Name: Uart_Test
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


module Uart_Test(
    input wire clk_100MHz,
    output wire tx_serial,
    output wire tx_done,
    output wire tx_status
    );
    
    reg [7:0] tx_data = 8'h10;
    wire tx_en; 
    reg tx_state = 0;
    reg [15:0] counter = 0;
    
    always@(posedge clk_100MHz)begin 
        if(counter == 16'hFFFF)begin 
            tx_state <= ~tx_state;
            counter <= 0;
        end 
        else begin
            counter <= counter + 1'b1;
        end 
    end
    assign tx_en = tx_state; 
    
    uarttx t1(.clk(clk_100MHz),
              .tx_enable(tx_en),
              .tx_data(tx_data),
              .tx_busy(tx_status),
              .tx_serial(tx_serial),
              .tx_done(tx_done));      
endmodule
