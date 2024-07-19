`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2024 10:38:55 AM
// Design Name: 
// Module Name: fifo
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


module fifo#(
    parameter DATA_WIDTH = 8,
    parameter DEPTH      = 8
)
(
    input wire i_clk,                         // clock input for reading and writing
    input wire i_rst,                         // active high reset 
    input wire i_write_en,                    // write enable signal 
    input wire [DATA_WIDTH-1:0] i_write_data, // data written into fifo
    input wire i_read_en,                     // read enable signal 
    output reg [DATA_WIDTH-1:0] o_data_out,   // data output of signal 
    output wire o_full,                        // fifo full signal 
    output wire o_overrun,
    output wire o_underrun,
    output wire o_empty                        // fifo empty signal 
);
    localparam  PTR_WIDTH = $clog2(DEPTH);
    reg [PTR_WIDTH-1:0] w_ptr;
    reg [PTR_WIDTH-1:0] r_ptr;
    wire [PTR_WIDTH-1:0] nxt_adr;
    reg [DATA_WIDTH-1:0] fifo[0:DEPTH-1];
    reg overrun_flag;
    reg underrun_flag;

    initial begin
        w_ptr = 0;
        r_ptr = 0;
        overrun_flag = 0;
        underrun_flag = 0;
    end
    always @(posedge i_clk) begin 
        if(i_rst)begin
            w_ptr <= 0;
            overrun_flag <= 0;
        end
        else begin
            // wite data to fifo
            if(i_write_en && !o_full)begin
                fifo[w_ptr] <= i_write_data;
                w_ptr <= w_ptr + 1;
                overrun_flag <= 0;
                underrun_flag <= 0;
            end
            else if(i_write_en && o_full) begin
                overrun_flag <= 1;
            end
            else begin
            end
        end
    end

    always @(posedge i_clk) begin
        if(i_rst)begin
            r_ptr <= 0;
            underrun_flag <= 0;
        end 
        else begin 
            // read data from fifo 
            if(i_read_en && !o_empty)begin
                o_data_out <= fifo[r_ptr];
                r_ptr <= r_ptr + 1;
                underrun_flag <= 0; // need to reset the underrun flag 
            end
            else if(i_read_en && o_empty) begin
                underrun_flag <= 1;
            end
            else begin
            end 
        end 
    end

    assign o_overrun = overrun_flag;
    assign o_underrun = underrun_flag;
    assign nxt_adr = w_ptr + 1;
    assign o_full = (nxt_adr == r_ptr);
    assign o_empty = (w_ptr == r_ptr);
    
endmodule
