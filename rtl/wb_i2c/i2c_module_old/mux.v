`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:54:28 11/13/2015 
// Design Name: 
// Module Name:    mux 
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
module mux(
      clk,
      sel,
      SCLW, 
      SCLR,
      SCL/*, 
      SDAR, 
      SDAW,
      SDA*/
);


input clk;
input  sel;
input  SCLW, SCLR;
//input  SDAW, SDAR;
output SCL /*, SDA*/;
reg SCLo=1;
//reg SDAo=1;
assign SCL = (SCLo) ? 1'bz : 1'b0;
//assign SDA = (SDAo) ? 1'bz : 1'b0;


always @(posedge clk)

  begin
    case (sel)
      1'b0: begin
				SCLo = SCLW;
				//SDAo = SDAW;
	    end

      1'b1: begin
				SCLo = SCLR;
				//SDAo = SDAR;
	    end
  endcase

end

endmodule 
