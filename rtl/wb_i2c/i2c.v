`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    08:26:44 04/21/2016 
// Design Name: 
// Module Name:    i2c 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module i2c(
    input clk,
	 input reset,
	 
    input [6:0] divisor,
	 
	 output i2c_sclk,
    inout  i2c_sdat,
	 
	 input rw,
	 
	 input startread,
	 input startwrite,
    output done,
    output ack,
	 output i2c_avail,
   output start_i2c_signal,
  output [4:0] stage,
	 
	 input [15:0] i2c_data,
	 output [7:0] i2c_data_out
    );
	 

wire mclk;

wire i2c_sclk_write;
wire i2c_sdat_write;
	
wire i2c_sclk_read;
wire i2c_sdat_read;


wire startslowwrite;
wire startslowread;
	

wire done_write;
wire ack_write;
wire done_read;
wire ack_read;


 
assign i2c_avail=(i2c_avail_write && i2c_avail_read);
assign done = (done_read && done_write);
assign ack = (ack_read && ack_write);
assign start_i2c_signal = (startslowwrite || startslowread);



i2c_controller_read i2c_read (

    .clk(clk),
    .reset(reset),
	 
    .mclk(mclk),


    .i2c_sclk(i2c_sclk_read),
    .i2c_sdat(i2c_sdat),
    
    .divisor(divisor),
    .start(startread),
    .done(done_read),
    .ack(ack_read),
    .i2c_avail(i2c_avail_read),
    .startslow(startslowread),
    .stage(stage),
	 

    .i2c_data(i2c_data),
    .i2c_data_out(i2c_data_out)
);


i2c_controller_write i2c_write (
    .clk(clk),
    .reset(reset),

    .i2c_sclk(i2c_sclk_write),
    .i2c_sdat(i2c_sdat),
    
    .divisor(divisor),
    .start(startwrite),
    .done(done_write),
    .ack(ack_write),
    .i2c_avail(i2c_avail_write),
    .startslow(startslowwrite),

    .i2c_data(i2c_data)
);




multiplexor mux (
   .clk(mclk),
	
	.rw(rw),
	
	.i2c_sclk_write(i2c_sclk_write),
//	.i2c_sdat_write(i2c_sdat_write),

	.i2c_sclk_read(i2c_sclk_read),
//	.i2c_sdat_read(i2c_sdat_read),

	
	.i2c_sclk(i2c_sclk)
//	.i2c_sdat(i2c_sdat)
);



endmodule
