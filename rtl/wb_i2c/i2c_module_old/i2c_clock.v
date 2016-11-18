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
module i2c_controlMachine(
         input       mclk,
	 output reg  StartR  = 0,
	 output reg  StartW  = 0,
	 output reg  sel     = 0,
	 output reg  reset   = 0,
	 output reg  done    = 0,
	 output reg  StartC  = 0,
	 output reg  exttrig = 1'b0,
	 input	     measure,
	 input	     doner,
	 input	     donew,
	 input	     timec,
	 input	     resetG
    );

reg [3:0] state =4'b000;
reg [3:0] counterflag=0;

parameter START  =	4'b0000;
parameter WRITE  =	4'b0001;
parameter WAIT   =	4'b0010;
parameter READ   =	4'b0011;
parameter DONE   =      4'b0100;
parameter RESET  =	4'b0101;
parameter WRITEB =	4'b0110;
parameter WAITB  =	4'b0111;
parameter READB  =	4'b1000;




always @(posedge mclk)
begin
	if(exttrig==1'b1)
	begin
	counterflag=counterflag+1;
	if (counterflag==4'b1111)
		begin
		counterflag=0;
		exttrig=0;
		end
	end
	if(resetG==1) state=RESET;
	case(state)

		START: begin
				StartW=0;
				StartR=0;
				done=0;
				reset=0;
				sel=0;
				StartC=0;
					if(measure==1) begin 
						state=WRITE;
					end
		       end

		WRITE: begin
				StartW=1;
				StartR=0;
				done=0;
				reset=0;
				sel=0;
				StartC=0;
				state=WRITEB;
			end

		WRITEB: begin
				StartW=0;
				StartR=0;
				done=0;
				reset=0;
				sel=0;
				StartC=0;
					if(donew==1) begin 
						state=WAIT;
					end	
		      end

		WAIT: begin
				StartW=0;
				StartR=0;
				done=0;
				reset=0;
				sel=0;
				StartC=1;
				state=WAITB;
		       end

	        WAITB: begin
				StartW=0;
				StartR=0;
				done=0;
				reset=0;
				sel=0;
				StartC=0;
					if(timec==1) begin 
						state=READ;
					end
		      end

		READ: begin
				StartW=0;
				StartR=1;
				done=0;
				reset=0;
				sel=1;
				StartC=0;
				state=READB;
				exttrig=1'b1;
		       end

		READB: begin
				StartW=0;
				StartR=0;
				done=0;
				reset=0;
				sel=1;
				StartC=0;
				
				   if(doner==1) begin 
						state=DONE;
						
					end
		      end

		DONE: begin
				StartW=0;
				StartR=0;
				done=1;
				reset=0;
				sel=0;
				StartC=0;
				state=RESET;
		       end

		RESET: begin
				StartW=0;
				StartR=0;
				done=0;
				reset=1;
				sel=0;
				StartC=0;
				state=START;
				
			end
	endcase
end

endmodule
