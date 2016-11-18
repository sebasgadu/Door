`timescale 1ns / 1ps

module ADC(
clk,
init,
reset,
clkadc    );

input wire clk;
input wire reset;
input wire init;
output wire clkadc;

reg pulsador = 1'd0;
reg pulse = 1'd0;
reg [16:0] cont = 17'd0;

always@(posedge clk)
begin
   if (init) pulsador = 1'd1;
   if (pulsador) cont = cont + 1'd1;
	else pulse = 1'b0;	
      if (cont == 17'd50000) pulse = 1'd1;
      if (cont == 17'd100000) begin
         pulse = 1'd0;
         cont = 17'd0;
      end
	if(reset) pulsador = 1'd0;	
end 

assign clkadc = pulse;

endmodule
