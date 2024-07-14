`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2024 12:03:24 AM
// Design Name: Uart Transmitter
// Module Name: UART_TX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 8 - Data bits , N - No stop bit, 1 - Stop bit  
// No Hardware Flow Control 
// baudrate : 115200
// setting parametrs : 100 MHz clock 
// clks_per_bit = input clock / baudrate = 868.05 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module UART_TX 
#(parameter clk_cycles_per_bit = 868)
(
    input wire clock,
    input wire tx_enable,
    input [7:0] tx_data,
    output reg tx_busy,
    output reg tx_serial,
    output reg tx_done
);

    parameter IDLE = 3'b000;
    parameter START_BIT = 3'b001;
    parameter DATA_BITS = 3'b010;
    parameter STOP_BIT = 3'b011;
    parameter CLEANUP_STATE = 3'b100;

    reg [2:0] uart_tx_state = 0;  // keeps track of the state machine              // indicates a complete transfer 
    reg [7:0] tx_data_buffer = 0; // stores the data to be sent t prevent data contamination
    reg [2:0] bit_index = 0;      // stores the bit index to be sent   
    reg [9:0] clock_count = 0;    // keeps track of the clock cycles passed 

    always@(posedge clock) begin
        case(uart_tx_state)
        IDLE: begin
            tx_serial <= 1'b1; // drive the tx line high 
            tx_done <= 1'b0;
            clock_count <= 10'b0;
            bit_index <= 3'b0;
            tx_busy <= 1'b0;

            if(tx_enable == 1'b1) begin  // if tx enable is high begin transmission 
                tx_busy <= 1'b1; 
                tx_data_buffer <= tx_data;  // fill the temp data buffer 
                uart_tx_state <= START_BIT; 
             end
            else begin
                uart_tx_state <= IDLE;
            end   
        end

        // start bit is 0 
        START_BIT: begin 
            tx_serial <= 1'b0;

            if(clock_count < clk_cycles_per_bit-1)begin  // keep incrementing clock cycles untl you reach the define period 
                clock_count <= clock_count + 10'b1;
                uart_tx_state <= START_BIT; 
            end
            else begin
                clock_count <= 10'b0;
                uart_tx_state <= DATA_BITS; 
            end  
        end 

        // wait one clock period of 868 cycles fpr data bits to finish 
        DATA_BITS: begin
            tx_serial <= tx_data_buffer[bit_index]; // send out data to the serial port 

            if(clock_count < clk_cycles_per_bit-1)begin  // keep incrementing clock cycles untl you reach the define period 
                clock_count <= clock_count + 10'b1;
                uart_tx_state <= DATA_BITS; 
            end
            else begin
                clock_count <= 10'b0;
                if(bit_index < 7) begin // haven't sent out all the bits 
                    bit_index <= bit_index + 3'b1;
                    uart_tx_state <= DATA_BITS;
                end 
                else begin
                    bit_index <= 3'b0;
                    uart_tx_state <= STOP_BIT; 
                end 
            end 
        end 

        // stop bit is 1
        STOP_BIT: begin
            tx_serial <= 1'b1;

            if(bit_index < 7) begin // wait for one clock period  
                bit_index <= bit_index + 3'b1;
                uart_tx_state <= STOP_BIT;
            end 
            else begin
                bit_index <= 3'b0;
                tx_done <= 1'b1;
                uart_tx_state <= CLEANUP_STATE;
                tx_busy <= 1'b0; 
            end 
        end

        //cleanup state and stya here for one clock cycle 
        CLEANUP_STATE: begin
            tx_done <= 1'b1;
            uart_tx_state <= IDLE; 
        end 

        // default state 
        default : begin
            uart_tx_state <= IDLE;
        end 
        endcase  
    end 

endmodule 
