`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2024 11:29:52 AM
// Design Name: 
// Module Name: fir_filter
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


module fir_filter#(
        parameter LGNRES = 31,
        parameter LGNTAP = 15,
        parameter NTAPS = 15,
        parameter LGDATA = 15, 
        parameter LGSAMP = 7,
        parameter [4:0] TAP = 15 
    )
    (
        input wire i_clk,
        input wire i_rst, 
    
        input wire i_ce, 
        input wire [LGSAMP:0] i_sample,
        
        output reg o_ce, 
        output reg [LGNRES:0] o_result
    );
    
    // Local declaration 
    reg [LGNTAP:0] tapmem [0:NTAPS];    // tap memmory
    initial begin 
        $readmemh("Filter_Memory.mem",tapmem); 
    end
    reg signed [LGNTAP:0] tap;          // value read from tap memory
    
    reg [3:0] datawrite,dataread; // data write and read pointers
    reg [3:0] tapread;            // tap read pointer 
    
    reg [LGDATA:0] datamem [0:NTAPS];   // data memory     
    initial begin 
        $readmemh("Data_Memory.mem",datamem); 
    end
    reg signed [LGDATA:0] data;         // data read from memory 
    
    // Validation flags 
    reg d_ce, p_ce, m_ce;
    
    reg signed [LGNRES:0] product;
    reg signed [LGNRES:0] r_acc; 
    wire last_tap;
    reg [2:0] pre_acc_ce;
 
    initial datawrite = 0;
    //load new data value 
    always@(posedge i_clk)begin
        if(i_ce) begin
            datamem[datawrite] <= {8'b0,i_sample};
            datawrite <= datawrite + 1'b1;
        end    
    end 
    // check if we are on last tap and need to stop 
    assign last_tap = (TAP - tapread <= 1);
    //pre_acc_ce is used to check when the result of reading mem is valied later on 
    //pre_acc_ce[0] = tap index is valid 
    //pre_acc_ce[1] = tap value is vaid 
    //pre_acc_ce[2] = product is valid 
    initial pre_acc_ce = 3'b0;
    always@(posedge i_clk)begin
        if(i_rst)
            pre_acc_ce[0] <= 1'b0;
        else if(i_ce)
            pre_acc_ce[0] <= 1'b1; 
        else if((pre_acc_ce[0]) && (!last_tap))
            pre_acc_ce[0] <= 1'b1;
        else
            pre_acc_ce[0] <= 1'b0; 
    end 
    
    always@(posedge i_clk)begin 
        if(i_rst)
            pre_acc_ce[2:1] <= 2'b0;
        else
            pre_acc_ce[2:1] <= pre_acc_ce[1:0];
    end 
    //handle the write and read pointers
    initial dataread = 0;
    initial tapread = 0; 
    always@(posedge i_clk)begin
        if(i_ce)begin
            dataread <= datawrite;
            tapread <= 0; 
        end 
        else begin 
            dataread <= dataread - 1'b1;
            tapread <= tapread + 1'b1;
        end 
    end     
    //m_ce is high when the first index is valid 
    initial m_ce = 1'b0;
    always@(posedge i_clk)begin
        m_ce <= (i_ce) && (!i_rst);   
    end 
    //get tap and data values 
    initial tap = 0;
    initial data = 0;
    always@(posedge i_clk)begin
        tap <= tapmem[tapread];
        data <= datamem[dataread];   
    end 
    //d_ce is high when the data read from memory is valid
    initial d_ce = 1'b0;
    always@(posedge i_clk)begin
        d_ce <= (m_ce) && (!i_rst);   
    end 
    //calculate the product 
    //p_ce is high when the product is valid  
 
    initial p_ce = 1'b0;
    always@(posedge i_clk)begin
        p_ce = (d_ce) && (!i_rst);
    end 
    
    initial product = 0;
    always@(posedge i_clk)begin
        product <= tap * data;   
    end 
    
    // calculate the acc value based on pre_acc_ce or p_ce
    initial r_acc = 0;
    always@(posedge i_clk)begin
        if(p_ce)
            r_acc <= product;
        else if(pre_acc_ce[2])
            r_acc <= r_acc + product;
    end 
    
    initial o_ce = 1'b0;
    initial o_result = 0;
    always@(posedge i_clk)begin
        if(p_ce)begin
            o_result <= r_acc;  
            o_ce <= 1'b1; 
        end 
        else begin
            o_ce <= 1'b0;
        end 
    end 
endmodule
