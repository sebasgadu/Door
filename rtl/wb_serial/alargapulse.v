`timescale 1ns / 1ps

module alargapulse(clk, measurein, measureout);

input wire clk;
//input wire clk1khz;
input wire measurein;
output reg measureout = 1'd0;

//intern registers
reg flaginit = 1'd0;
reg [21:0] cont = 22'd0;

always @(posedge clk)begin
    if(measurein == 1'd1) flaginit = 1'd1;
	 if(flaginit == 1'd1) begin
	     cont = cont + 1'd1;
		  measureout = 1'd1;
	 end
	 if(cont == 22'd2550000) begin
	     cont = 22'd0;
        measureout = 1'd0;
        flaginit = 1'd0;		  
	 end
end

endmodule
