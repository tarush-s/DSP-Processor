// Uart Description : 
// 8 - Data bits , N - No stop bit, 1 - Stop bit  
// No Hardware Flow Control 
// baudrate : 115200
// setting parametrs : 100 MHz clock 
// clks_per_bit = input clock / baudrate = 868.05 

module uart_rx
#(parameter clk_cycles_per_bit = 868)
(
    input wire clk,
    input wire rx_serial,
    output wire rx_done,
    output wire[7:0] rx_data
);

    parameter IDLE = 3'b000;
    parameter START_BIT = 3'b001;
    parameter DATA_BITS = 3'b010;
    parameter STOP_BIT = 3'b011;
    parameter CLEAN = 3'b100;

    reg [2:0] uart_rx_state = 0;  // keeps track of the 
    reg rx_done_flag = 0;         // indicates a complete transfer 
    reg [7:0] rx_data_buffer = 0; // stores the data to be sent to prevent data contamination
    reg [2:0] bit_index = 0;
    reg [9:0] clock_count = 0;

    always@(posedge clk)begin 
        case(uart_rx_state)
            IDLE: begin 
                rx_done_flag <= 0;
                clock_count <= 0;
                bit_index <= 0;

                if(rx_serial <= 1'b0)begin // detected start bit 
                    uart_rx_state <= START_BIT; 
                end 
                else begin 
                    uart_rx_state <= IDLE;
                end 
            end 
            // check the middle of the start bit to make sure it is still low 
            START_BIT: begin 
                if(clock_count == (clk_cycles_per_bit-1)/2)begin 
                    if(rx_serial == 1'b0)begin 
                        clock_count <= 0;
                        uart_rx_state <= DATA_BITS; // go to dat bit stage if still low 
                    end 
                    else begin 
                        uart_rx_state <= IDLE;      // else false low signal 
                    end 
                end
                else begin
                    clock_count <= clock_count + 10'b1;
                    uart_rx_state <= START_BIT; 
                end  
            end 
            // wait for one clock cycle and then start sampling 
            DATA_BITS: begin 
                if(clock_count < clk_cycles_per_bit-1)begin
                    clock_count <= clock_count + 10'b1;
                    uart_rx_state <= DATA_BITS; 
                end 
                else begin 
                    clock_count <= 0;
                    rx_data_buffer[bit_index] = rx_serial;

                    // check if we have aall the 8 bits of data 
                    if(bit_index < 7)begin
                        bit_index <= bit_index + 3'b1;
                        uart_rx_state <= DATA_BITS; 
                    end 
                    else begin 
                        bit_index <= 3'b0;
                        uart_rx_state <= STOP_BIT;
                    end 
                end 
            end 
            // wait for one clock cycle for the stop bit to finish
            STOP_BIT: begin 
                if(clock_count < clk_cycles_per_bit-1)begin
                    clock_count <= clock_count + 10'b1;
                    uart_rx_state <= STOP_BIT; 
                end 
                else begin 
                    rx_done_flag <= 1'b1;
                    clock_count <= 0;
                    //changed here for debugging 
                    uart_rx_state <= CLEAN;
                end 
            end 
            // stay here for one clock cycle 
            CLEAN: begin 
                uart_rx_state <= IDLE;
                rx_done_flag <= 0;
            end 
            default:begin 
                uart_rx_state <= IDLE;
            end 
        endcase
    end 

    assign rx_done = rx_done_flag;
    assign rx_data = rx_data_buffer;
    
endmodule