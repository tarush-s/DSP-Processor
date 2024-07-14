`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2024 10:51:49 PM
// Design Name: 
// Module Name: FIR_Filter_TB
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


module FIR_Filter_TB();
        parameter LGNRES = 31;
        parameter LGNTAP = 15;
        parameter NTAPS = 15;
        parameter LGDATA = 15; 
        parameter LGSAMP = 7;
        parameter [4:0] TAP = 15;
        reg i_clk;
        reg i_rst; 
        reg i_ce; 
        reg [LGSAMP:0] i_sample;
        wire o_ce;
        wire o_ready;
        wire [LGNRES:0] o_result;
         
        FIR_FILTER dut( .i_clk(i_clk), 
                        .i_rst(i_rst),
                        .i_ce(i_ce), 
                        .i_sample(i_sample), 
                        .o_ce(o_ce), 
                        .o_ready(o_ready), 
                        .o_result(o_result));
                        
        always #50 i_clk <= ~i_clk;
        integer i;
        reg [7:0] counter = 1;
        initial begin
            i_clk = 0;
            i_rst = 0; 
            i_sample = 0;
            i_ce = 0; 
            
            repeat(4) @(posedge i_clk);
            
            for(i=0; i<30 ;i=i+1) begin
                i_ce = 1; 
                i_sample = counter;
                counter = counter + 8'b1;
                @(posedge i_clk);
                i_ce = 0;
                repeat(15) @(posedge i_clk); 
            end 
                         
            $finish;        
        end  
endmodule
