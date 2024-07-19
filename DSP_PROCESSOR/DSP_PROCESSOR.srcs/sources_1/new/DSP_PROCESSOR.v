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
    output wire tx_fifo_full,
    output wire tx_fifo_empty
    );
    
    wire rx_status; 
    wire[7:0] tx_data;
    wire tx_fifo_overrun,tx_fifo_underrun;
    wire [7:0] tx_fifo_data_out;
    wire [31:0] fir_filter_out;
    wire fir_filter_out_en;
    wire tx_fifo_read_en;
    //reg [3:0] filter_counter = 0;
    
//    // counter to make sure there are 14 clock cycles between each input value 
//    always@(posedge clk_100MHz)begin
//        if(rst)
//            filter_counter <= 0; 
//        else 
//            filter_counter <= filter_counter + 1'b1;
//    end 
//    // controller for data transfer between rx_fifo and filter modules
//    always@(posedge clk_100MHz)begin
//        if(rst)begin 
//            rx_fifo_read_en <= 1'b0;
//            fir_filter_en <= 1'b0;       
//        end 
//        else begin
//            if((!rx_fifo_empty) && (filter_counter == 4'hf))begin
//                rx_fifo_read_en <= 1'b1;
//                fir_filter_en <= 1'b1; 
//            end 
//            else begin 
//                rx_fifo_read_en <= 1'b0;
//                fir_filter_en <= 1'b0;
//            end 
//        end      
//    end 
    fifo tx1(.i_clk(clk_100MHz), 
        .i_rst(rst),
        .i_write_en(fir_filter_out_en),
        .i_write_data(fir_filter_out),
        .i_read_en(tx_fifo_read_en),
        .o_data_out(tx_fifo_data_out),
        .o_full(tx_fifo_full),
        .o_overrun(tx_fifo_overrun),
        .o_underrun(tx_fifo_underrun),
        .o_empty(tx_fifo_empty));
            
    fir_filter f1(.i_clk(clk_100MHz),
                  .i_rst(rst),
                  .i_ce(rx_status),
                  .i_sample(rx_data),
                  .o_ce(fir_filter_out_en),
                  .o_result(fir_filter_out));
    
    uart_rx u1(.clk(clk_100MHz),
               .rst(rst), 
               .rx_serial(rx_serial), 
               .rx_done(rx_status),
               .rx_data(rx_data)
               ); 
                 
endmodule
