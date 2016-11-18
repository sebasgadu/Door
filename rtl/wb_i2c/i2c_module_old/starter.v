`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:29:29 12/04/2015 
// Design Name: 
// Module Name:    starter 
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
module starter(
    input mclk,
    output startM,
    input done,
    input start
);
//reg [5:0] contador= 0;
reg startm;
reg [1:0] counter=0;
reg [1:0] state =0;
reg flag;
assign startM=startm;


always @(posedge mclk) begin
case (state)
	0: if(start) state<=1;
	1: begin
		startm <= 1'b1;
		state <= 2;
		end
	2:begin
		startm <= 1'b0;
		if (done) begin
			counter<=counter+1;
			startm <= 1'b1;
		end
		if (counter==0) begin//numero de mediciones adicionales que hace el sensor
			state<=0;
			counter <= 0;
		end
	  end
endcase
end
endmodule
