`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/01/2024 11:26:54 AM
// Design Name: 
// Module Name: DSP_PROCESSOR
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


module DSP_PROCESSOR(
    input wire clk_100MHz, 
    input wire rx_serial,
    output reg uart_check
    );
    
    wire rx_status; 
    wire[7:0] rx_data;
    
    always@(*)begin
        if(rx_status == 1'b1 && rx_data == 8'h10)begin
            uart_check = 1'b1;
        end     
        else begin 
            uart_check = 1'b0;
        end 
    end 
    
    uart_rx u1(.clk(clk_100MHz), 
               .rx_serial(rx_serial), 
               .rx_done(rx_status),
               .rx_data(rx_data)
               ); 
                 
endmodule
