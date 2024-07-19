`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2024 08:48:52 PM
// Design Name: 
// Module Name: FIFO_TB
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


module FIFO_TB();
    parameter DATA_WIDTH = 8;
    parameter DEPTH = 8;
    reg i_clk;
    reg i_rst;
    reg i_write_en;
    reg [DATA_WIDTH-1:0] i_write_data;
    reg i_read_en;
    wire [DATA_WIDTH-1:0] o_data_out;
    wire o_full;
    wire o_empty;
    wire overrun;
    wire underrun; 


    FIFO dut(.i_clk(i_clk),
            .i_rst(i_rst),
            .i_write_en(i_write_en),
            .i_write_data(i_write_data),
            .i_read_en(i_read_en),
            .o_data_out(o_data_out),
            .o_full(o_full),
            .o_overrun(overrun),
            .o_underrun(underrun),
            .o_empty(o_empty));

    always #25 i_clk <= ~i_clk;
    integer i;
    initial begin
        i_clk = 0;
        i_rst = 1;
        i_write_en = 0;
        i_read_en = 0;
        i_write_data = 0;

        #75 
        i_rst = 0;
        
        @(posedge i_clk);
        //try reading an empty FIFO
        i_read_en = 1;
        @(posedge i_clk);
        i_read_en = 0;
        @(posedge i_clk);
        
        for(i=0; i<8; i=i+1)begin
            i_write_en = 1;
            i_write_data = $urandom;
            @(posedge i_clk);
        end 

        // still worte after fifo is full
        @(posedge i_clk);

        i_write_en = 1;
        i_write_data = 8'b1;
        @(posedge i_clk);
         // check full and overrun flag 
        i_write_en = 1'b0;

        // wait one clock cycle 
        @(posedge i_clk);
        // check if read works 
        for(i=0; i<8; i=i+1)begin
            i_read_en = 1;
            @(posedge i_clk);
        end
        //try writing after reading the FIFO
        @(posedge i_clk);
        i_write_en = 1;
        i_write_data = 8'b1;
        
        repeat(2) @(posedge i_clk);
        // finish the simulation and give control to OS
        $finish;
    end
endmodule 