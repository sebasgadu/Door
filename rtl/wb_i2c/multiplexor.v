`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:02:45 04/21/2016 
// Design Name: 
// Module Name:    multiplexor 
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
module multiplexor(
   input clk,
	
	input rw,
	
	input i2c_sclk_write,
	input i2c_sdat_write,

	
	input i2c_sclk_read,
	input i2c_sdat_read,

	
	output i2c_sclk,
	output i2c_sdat
	

);


reg sclk;
reg sdat;



assign i2c_sclk = sclk;
assign i2c_sdat = sdat;




always @(posedge clk) begin
   case (rw) //Read es 1, write es 0
	     1'b0: begin // Write
		      sclk <= i2c_sclk_write;
				sdat <= i2c_sdat_write;
		  end
		  
		  1'b1: begin  //Read
		     sclk <= i2c_sclk_read;
			  sdat <= i2c_sdat_read;
		  end
		  
		  default: begin
				 sclk <= 1'b1;
             sdat <= 1'b1;
		  end
	
	endcase

end
endmodule
