`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:02:27 12/04/2015 
// Design Name: 
// Module Name:    Divisorfrecuencia 
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
module Divisorfrecuencia(
    input clk,
    output mclk
    );
	 
reg [2:0] contador= 0;
reg mclko=0;
assign mclk=mclko;

always @(posedge clk)
begin
    contador = contador + 1;
     if(contador == 5)
     begin
       mclko = ~mclko; //genera la señal de reloj
       contador = 0; 	//reset del contador
     end
end

endmodule
