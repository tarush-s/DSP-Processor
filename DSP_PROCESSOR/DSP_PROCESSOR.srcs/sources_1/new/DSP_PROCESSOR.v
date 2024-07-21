`timescale 1ns / 1ps

module DSP_PROCESSOR(
    input wire clk_100MHz,
    input wire rst,
    input wire rx_serial,
    output wire tx_serial,
    output wire tx_fifo_full,
    output wire tx_fifo_empty
    );
    
    wire rx_status; 
    wire tx_status;
    wire[7:0] tx_data;
    wire tx_fifo_overrun,tx_fifo_underrun;
    wire [7:0] tx_fifo_data_out;
    wire [31:0] fir_filter_out;
    wire fir_filter_out_en;
    wire tx_fifo_read_en;
    
    reg tx_enable = 0;

    always@(posedge clk_100MHz) begin 
        if(!tx_fifo_empty)
            tx_enable <= 1'b1;
        else 
            tx_enable <= 1'b0;            
    end
    
    uart_tx u2(.clk(clk_100MHz),
               .rst(rst),
               .tx_enable(tx_enable),
               .tx_data(tx_fifo_data_out[7:0]),
               .tx_serial(tx_serial),
               .tx_done(tx_status));

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
