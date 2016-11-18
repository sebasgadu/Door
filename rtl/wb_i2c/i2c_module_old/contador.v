`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:27:00 10/09/2015 
// Design Name: 
// Module Name:    contador 
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
module msCounter(
    input clk,
    input StartC,
    input reset,
    output TimeC
);

reg timec=1'b0;	 
reg CountE=1'b0;
reg endcount=1'b0;
reg [23:0] 	contador= 0;
assign TimeC=timec;
always @(posedge clk)
begin
	if(StartC==1)
	begin
	CountE<=1'b1;
	endcount<=1'b0;
	end
	
	if(reset==1)
	begin
	contador<=1'b0;
	CountE<=1'b0;
	end	
	
	if(CountE==1'b1)
	begin
		contador <= contador + 1;
		if(contador == 800000)
		begin
			timec <= 1'b1; 
			contador <= 1'b0; 	//reset del contador 
			CountE<=1'b0;
			endcount<=1'b1;
		end
	end
	if (endcount==1'b1) timec <= 1'b0;
end
  

endmodule
