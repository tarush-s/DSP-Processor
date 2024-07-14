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
    input wire clk,
    input wire a,
    input wire b,
    output reg rx_done
    );
    
    always@(posedge clk)begin
        rx_done <= a + b;
    end 
          
endmodule
