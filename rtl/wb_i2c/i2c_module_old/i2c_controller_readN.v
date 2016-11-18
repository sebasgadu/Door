`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:48:48 11/10/2015 
// Design Name: 
// Module Name:    i2c_controller_read 
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
// Modulo i2c diseñado paea leer la información de la SDA
//////////////////////////////////////////////////////////////////////////////////
module i2c_controller_readN(
    input  clk,
    inout  i2c_sclk,
    inout  i2c_sdat,
    input  start,
    output done,
    output reg [15:0] DATA=16'hFFFF,
    input reset
    );

//Dirección del SRF02 para escribir
parameter reg [7:0] address_1 = 8'hE0;
//register number para leer 
parameter reg [7:0] Range_High_Byte = 8'd2;///////cambiar a 2
//Dirección del SRF02 para leer
parameter reg [7:0] address_2 = 8'hE1;	
parameter reg [23:0] i2c_data = {address_1,Range_High_Byte ,address_2};
	 
	 
parameter reg [15:0] out_of_master = 16'b1111111111111111;
parameter reg [39:0] data = {i2c_data,out_of_master};

 

reg [6:0] stage=7'd0;
reg [6:0] sclk_divider;
reg clock_en = 1'b0;
reg resetflag=1'b0;
reg [3:0] waiting=4'd0;
reg enable=1'b1;


assign i2c_sclk = (((!clock_en) || sclk_divider[6])&& enable) ? 1'b1 : 1'b0;
wire midlow = (sclk_divider == 7'h1f);

reg sdat = 1'b1;

assign i2c_sdat = (sdat) ? 1'bz : 1'b0;

reg [4:0] acks;
reg start_repeated = 1'b0;
reg clkstretch=1'b0;

parameter LAST_STAGE = 16'd51;

assign ack = (acks == 3'b000);
assign done = (stage == LAST_STAGE)&&(!resetflag);

always @(posedge clk) begin

	 if (start_repeated) begin
        clock_en <= 1'b0;
		  start_repeated <= 1'b0;
    end else	 
	 
    if (start) begin
	     DATA <= 16'd0;
        sclk_divider <= 7'd0;
        stage <= 15'd0;
        clock_en <= 1'b0;
        sdat <= 1'b1;
        acks <= 5'b11111;
		  resetflag=1'b0;
    end else begin
					if (stage==7'd30 || stage==7'd31 || stage==7'd41 || stage==7'd42)
						begin
						enable=1'b0;
						end else enable=1'b1;
		  /*if (stage==7'd40 || stage==7'd30)
				begin
				if(sclk_divider==30 && !flag)
					begin
					sclk_divider<=7'd1;
					waiting<=waiting+1;
					if (waiting==6)
						begin
						flag<=1'b1;
						end
					end
				end	*/			
				if (sclk_divider == 7'd127) begin
            sclk_divider <= 7'd0;

            if (stage != LAST_STAGE && clkstretch == 1'b0)
                stage <= stage + 1'b1;
				    
            case (stage)
                // after start
                7'd0:  clock_en <= 1'b1;
                // receive acks
                7'd9:  acks[0] <= i2c_sdat;
                7'd18: acks[1] <= i2c_sdat;
                7'd29: acks[2] <= i2c_sdat;
					 7'd38: acks[3] <= i2c_sdat;
					 7'd47: acks[4] <= i2c_sdat;
				    // after repeated start
					 7'd20: clock_en <= 1'b1;
					 
				//almacenamiento de datos del sensor
					 //byte 4  Información que se lee
					 7'd32: DATA[15] <= i2c_sdat;
					 7'd33: DATA[14] <= i2c_sdat;
					 7'd34: DATA[13] <= i2c_sdat;
					 7'd35: DATA[12] <= i2c_sdat;
					 7'd36: DATA[11] <= i2c_sdat;
					 7'd37: DATA[10] <= i2c_sdat;
					 7'd38: DATA[9]  <= i2c_sdat;
					 7'd39: DATA[8]  <= i2c_sdat;
	
					 //byte 5  Información que se lee
					 7'd43: DATA[7] <= i2c_sdat;
					 7'd44: DATA[6] <= i2c_sdat;
					 7'd45: DATA[5] <= i2c_sdat;
					 7'd46: DATA[4] <= i2c_sdat;
					 7'd47: DATA[3] <= i2c_sdat;
					 7'd48: DATA[2] <= i2c_sdat;
					 7'd49: DATA[1] <= i2c_sdat;
					 7'd50: DATA[0] <= i2c_sdat;
					
                // before stop
                7'd52: clock_en <= 1'b0;
            endcase
        end else
            sclk_divider <= sclk_divider + 1'b1;

        if (midlow) begin
            case (stage)
                // start
                7'd0:  sdat <= 1'b0;
                // byte 1
					 //ADDRESS 1
                7'd1:  sdat <= data[39];
					 7'd2:  sdat <= data[38];
                7'd3:  sdat <= data[37];
                7'd4:  sdat <= data[36];
                7'd5:  sdat <= data[35];
                7'd6:  sdat <= data[34];
                7'd7:  sdat <= data[33];
					 //READ/~WRITE VALUE = 0
                7'd8:  sdat <= data[32];
                // ack 1
                7'd9:  sdat <= 1'b1;
                // byte 2
                7'd10: sdat <= data[31];
                7'd11: sdat <= data[30];
                7'd12: sdat <= data[29];
                7'd13: sdat <= data[28];
                7'd14: sdat <= data[27];
                7'd15: sdat <= data[26];
                7'd16: sdat <= data[25];
                7'd17: sdat <= data[24];
                // ack 2
                7'd18: sdat <= 1'b1;
                // repeated start
                7'd19: start_repeated <= 1'b1;
					 7'd19: sdat <= 1'b1;
					 7'd20: sdat <= 1'b0;
					 //byte 3
                7'd21: sdat <= data[23];
                7'd22: sdat <= data[22];
                7'd23: sdat <= data[21];
                7'd24: sdat <= data[20];
                7'd25: sdat <= data[19];
                7'd26: sdat <= data[18];
                7'd27: sdat <= data[17];
					 //READ/WRITE VALUE = 1
					 7'd28: sdat <= data[16];
                // ack 3
					 7'd29:	sdat <= 1'b1; 
					 7'd30: 	sdat <= 1'b1;
					 7'd31:  sdat <= 1'b1;
					 //byte 4  Información que se lee
					 7'd32: sdat <= data[15];
					 7'd33: sdat <= data[14];
					 7'd34: sdat <= data[13];
					 7'd35: sdat <= data[12];
					 7'd36: sdat <= data[11];
					 7'd37: sdat <= data[10];
					 7'd38: sdat <= data[9];
					 7'd39: sdat <= data[8];
					 // ack 4
					 7'd40: sdat <= 1'b0;
					 7'd41: sdat <= 1'b1;
					 7'd42: sdat <= 1'b1;
								
					 //byte 5 Información que se lee
					 7'd43: sdat <= data[7];
					 7'd44: sdat <= data[6];
					 7'd45: sdat <= data[5];
					 7'd46: sdat <= data[4];
					 7'd47: sdat <= data[3];
					 7'd48: sdat <= data[2];
					 7'd49: sdat <= data[1];
					 7'd50: sdat <= data[0];
					 //ack5
					 7'd51: sdat <= 1'b1;
                // stop
                7'd52: sdat <= 1'b0;
                7'd53:	sdat <= 1'b1;	
            endcase
        end
    end
	if (reset) begin
        sclk_divider <= 7'd0;
        stage <= LAST_STAGE;
        clock_en <= 1'b0;
        sdat <= 1'b1;
        resetflag=1'b1;
	end
end


endmodule
