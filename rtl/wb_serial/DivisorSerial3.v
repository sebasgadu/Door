`timescale 1ns / 1ps

module DivisorSerial3(

//divisor de 100MHz A 1MHz
 input wire clk,
 output wire clkg
 
 );

reg pulse = 1'b0;
reg [6:0] cont = 7'b0000000;
assign clkg = pulse;

always@(posedge clk)
begin
   cont = cont + 1'b1;
   if (cont == 7'b0110010) 
	   pulse = 1'b1;
   if (cont == 7'b1100100) begin
      pulse = 1'b0;
      cont = 7'b0000000;
   end
end

endmodule

