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
    input wire rst,
    input wire rx_serial,
    output wire rx_fifo_full
    );
    
    wire rx_status; 
    wire[7:0] rx_data;
    wire rx_fifo_overrun,rx_fifo_empty,rx_fifo_underrun;
    wire rx_fifo_read_en;
    wire [7:0] rx_fifo_data_out;
    
    
    fifo rx1(.i_clk(clk_100MHz), 
            .i_rst(rst),
            .i_write_en(rx_status),
            .i_write_data(rx_data),
            .i_read_en(rx_fifo_read_en),
            .o_data_out(rx_fifo_data_out),
            .o_full(rx_fifo_full),
            .o_overrun(rx_fifo_overrun),
            .o_underrun(rx_fifo_underrun),
            .o_empty(rx_fifo_empty));
    
    uart_rx u1(.clk(clk_100MHz),
               .rst(rst), 
               .rx_serial(rx_serial), 
               .rx_done(rx_status),
               .rx_data(rx_data)
               ); 
                 
endmodule
