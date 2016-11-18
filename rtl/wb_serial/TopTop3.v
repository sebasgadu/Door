`timescale 1ns / 1ps

module TopTop3(clk, measure, reset, done, onewire, tem, temd, hum, humd, sum);

input wire clk; 
input wire measure;
input wire reset;
output wire done;
inout wire onewire;
output wire [7:0] tem;
output wire [7:0] temd;//inutil
output wire [7:0] hum;
output wire [7:0] humd;//inutil
output wire [7:0] sum;//inutil (Depende)
//output wire readed1;
//output wire readed0;

wire nodoclk, nodomeasure;

    SerialTop3 SerialTop3( 
        .clk(nodoclk),
		  .measure(nodomeasure),
		  .reset(reset),
		  .done(done),
		  .onewire(onewire),
		  .tem(tem),
		  .temd(temd),
		  .hum(hum),
		  .humd(humd),
		  .sum(sum)
		  //.readed1(readed1),
		  //.readed0(readed0)
	 );
	 
    DivisorSerial3 DivisorSerial3(
	     .clk(clk),
		  .clkg(nodoclk)
	 );
	 
	 alargapulse alargapulse(
	     .clk(clk),
		  //.clk1khz(nodoclk),
		  .measurein(measure),
		  .measureout(nodomeasure)
	 );
	 
endmodule

