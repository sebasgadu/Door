`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:10:48 11/12/2015 
// Design Name: 
// Module Name:    I2C 
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
module I2C(
    input measure,
    input mclk,
    inout SDA,
    inout SCL,
    output done,
    output [15:0] datao,
    output exttrigger,
    input resetG
    );
	 

  wire SCLW;
  wire SCLR;
//wire SDAW;
//wire SDAR;
  wire StartR;
  wire StartW;
  wire StartC;
  wire DoneR;
  wire DoneW;
  wire TimeC;
  wire sel;
  wire reset;
	
	 

	 
	 
	 
mux multiplexor(
  .clk(mclk), 
  .sel(sel), 
/*.SDAR(SDAR), 
  .SDAW(SDAW),*/ 
  .SCLW(SCLW), 
  .SCLR(SCLR), 
  .SCL(SCL)/*, 
  .SDA(SDA)*/
);
	 
i2c_controlMachine i2c_ccontrol(
  .mclk(mclk), 
  .StartR(StartR), 
  .StartW(StartW), 
  .sel(sel), 
  .reset(reset), 
  .done(done), 
  .StartC(StartC), 
  .measure(measure), 
  .doner(DoneR), 
  .donew(DoneW), 
  .timec(TimeC), 
  .resetG(resetG), 
  .exttrig(exttrigger)
);


i2c_controllerN write(
  .clk(mclk), 
  .i2c_sclk(SCLW), 
  .i2c_sdat(SDA), 
  .start(StartW),
  .reset(reset), 
  .done(DoneW)
);


i2c_controller_readN read(
  .clk(mclk), 
  .i2c_sclk(SCLR), 
  .i2c_sdat(SDA),
  .start(StartR), 
  .done(DoneR), 
  .DATA(datao), 
  .reset(reset)
);


msCounter contador(
  .clk(mclk), 
  .StartC(StartC), 
  .reset(reset), 
  .TimeC(TimeC)
);


endmodule
