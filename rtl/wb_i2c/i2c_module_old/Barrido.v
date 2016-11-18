`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:36:55 12/04/2015 
// Design Name: 
// Module Name:    Barrido 
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
module Barrido(
    input start,
    output [15:0] data,
    output done,
    input resetG,
    input clk,
    inout SDA,
    inout SCL,
    output exttrigger
);

wire mclk;
wire startM;
	

I2C I2CMODULE(
.measure(startM), 
.mclk(mclk), 
.SDA(SDA), 
.SCL(SCL),
.done(done), 
.datao(data), 
.exttrigger(exttrigger), 
.resetG(resetG));

Divisorfrecuencia freq(
.clk(clk), 
.mclk(mclk)
);

starter starter(
.mclk(mclk), 
.startM(startM), 
.done(done), 
.start(start)
);

//interfaz interfaz(.measure(start), .measureP(startM), .clk(mclk));


endmodule
