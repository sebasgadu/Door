`timescale 1ns / 1ps

//David Ovalle Taylor, National University of colombia.
//Serial One-Wire protocol for DHT11 Ver. 3.0.

module SerialTop3(clk, measure, reset, done, onewire, tem, temd, hum, humd, sum);

input wire clk; //clk must be at a frequency of 1us
input wire measure;
input wire reset;
output reg done = 1'd0;
inout onewire;
output reg [7:0] tem;
output reg [7:0] temd;//inutil
output reg [7:0] hum;
output reg [7:0] humd;//inutil
output reg [7:0] sum;//inutil (Depende)

//For tristate bus "onewire"
reg enable = 1'd1;
reg write = 1'd1;
reg read;

//separated data
/*reg [7:0] irh = 8'b00000000;
reg [7:0] drh = 8'b00000000;
reg [7:0] it  = 8'b00000000;
reg [7:0] dt  = 8'b00000000;
reg [7:0] sum = 8'b00000000;*/


//complete data
reg [39:1] complete = 39'd0;

//for write data
reg minit = 1'd0;
reg [14:0] cont = 15'd0;
reg stop = 1'd0;


//for read data
reg stop2 = 1'd0;
reg [6:0] cont2 = 7'd0;
reg dataread = 1'd0;

reg [5:0] contadata = 6'd0;
reg [7:0] conthigh = 8'd0;
reg readed1 = 1'd0;
reg readed0 = 1'd0;

//for reset
reg flagreset = 1'd0;
reg [1:0] contflag = 2'd00;
//reg flagstopreset = 1'd0;

//for new measurement
reg flagend = 1'd0;

assign onewire = (enable)? write : 1'bz;

always@(posedge clk)
begin

    //wire output
    if(measure == 1'd1) 
        minit = 1'd1;
		  //done = 1'd0;
		  //enable = 1'd1;
    if((minit == 1'd1) && (stop == 1'd0)) begin
	     cont = cont + 1'd1;
        if(cont < 15'd18000) write = 1'd0; 
	 end
    if(cont == 15'd18000)//18000us
	     write = 1'd1;
    if(cont == 15'd18012) begin //18044us (tal como lo envia arduino)	
	     //write = 1'b0;
        enable = 1'd0; // change onewire to high impedance
        cont = 1'd0;
        stop = 1'd1;
	end

    //wire input (preread)
    if((stop == 1'd1) && (stop2 == 1'd0)) begin
        cont2 = cont2 + 1'd1;
        if((cont2 >= 7'd100)/*54*/ && (read == 1'd0)) begin
            dataread = 1'd1;
            cont2 = 7'd0;
            stop2 = 1'd1;
        end
    end
    //wire input (read)
    if(dataread == 1'd1) begin
        conthigh = conthigh + 1'd1;
        if((conthigh >= 8'd75)/*56*/ && (conthigh <= 8'd100)/*82*/ && (read == 1'd0)) begin 
            conthigh = 8'd0;
            readed0 = 1'd1;
            contadata = contadata + 1'd1;
        end
        if ((conthigh > 8'd100)/*82*/&&(read == 1'd0)) begin
            conthigh = 8'd0;
            readed1 = 1'd1;
            contadata = contadata + 1'd1;         
        end 
    end
    //else conthigh = 8'd0;

    if((readed1 == 1'd1)&&(conthigh == 8'd4)) readed1 = 1'd0;
    if((readed0 == 1'd1)&&(conthigh == 8'd4)) readed0 = 1'd0;    
    if(readed1 == 1'd1) complete[contadata] = 1'd1; 
    if(readed0 == 1'd1) complete[contadata] = 1'd0; 
    
    if(contadata == 6'd39)/*40*/ begin /*si se deja en 40 aparece latch (obviamente)*/
     	  dataread = 1'd0;
        enable = 1'd1;
        done = 1'd1;
        contadata = 6'd0;
		  
		  //minit = 1'd0;
		  //readed1 = 1'd0;
		  //readed0 = 1'd0;
        //ver si se deja contador para bajar el pulso
        flagend = 1'd1;		  
    end
	 
	 if((flagend == 1'd1) && (measure == 1'd0))begin
	         minit = 1'd0;
            stop = 1'd0;
				stop2 = 1'd0;
            enable = 1'd1;
            write = 1'd1;
            dataread = 1'd0;
            cont = 15'd0;
            cont2 = 7'd0; 
            contadata = 6'd0;
            conthigh = 8'd0;
            //contflag = contflag + 1'd1;
				done = 1'd0;
				//complete = 40'd0;
				readed1 = 1'd0;
				readed0 = 1'd0;
	 end
 
    //reset
    if(reset == 1'd1) begin
        flagreset = 1'd1;
        if(flagreset == 1'd1) begin
            minit = 1'd0;
            stop = 1'd0;
				stop2 = 1'd0;
            enable = 1'd1;
            write = 1'd1;
            dataread = 1'd0;
            cont = 15'd0;
            cont2 = 7'd0; 
            contadata = 6'd0;
            conthigh = 8'd0;
            contflag = contflag + 1'd1;
				done = 1'd0;
				complete = 40'd0;
				readed1 = 1'd0;
				readed0 = 1'd0;
        end
    end
	 //else flagreset = 1'd0;
	 
    if((contflag >= 2'd2)) begin
        flagreset = 1'd0;
        contflag = 2'd0;
		  //flagend = 1'd0;
    end 
    
	 
	 //concatenated humidity
	 hum[7] = 1'd0; //chambonada hecha porque no se sabe porque no lee ese bit   
    hum[6] = complete[1];   
    hum[5] = complete[2];   
    hum[4] = complete[3];   
    hum[3] = complete[4];   
    hum[2] = complete[5];   
    hum[1] = complete[6];   
    hum[0] = complete[7];    
    
	 //puros ceros .-.
	 humd[7] = complete[8];
	 humd[6] = complete[9];
	 humd[5] = complete[10];
	 humd[4] = complete[11];
	 humd[3] = complete[12];
	 humd[2] = complete[13];
	 humd[1] = complete[14];
	 humd[0] = complete[15];
	 
	 //concatenated temperature
	 tem[7] = complete[16];
    tem[6] = complete[17];
    tem[5] = complete[18]; 
    tem[4] = complete[19];
    tem[3] = complete[20];  
    tem[2] = complete[21];
    tem[1] = complete[22];
    tem[0] = complete[23];
	 
	 //puros ceros .-.
	 temd[7] = complete[24];
	 temd[6] = complete[25];
	 temd[5] = complete[26];
	 temd[4] = complete[27];
	 temd[3] = complete[28];
	 temd[2] = complete[29];
	 temd[1] = complete[30];
	 temd[0] = complete[31];
	 
	 //talves sirva para algo 
	 sum[7] = complete[32];
	 sum[6] = complete[33];
	 sum[5] = complete[34];
	 sum[4] = complete[35];
	 sum[3] = complete[36];
	 sum[2] = complete[37];
	 sum[1] = complete[38];
	 sum[0] = complete[39];
	 
    read <= onewire;

end

//Assignations (no se si esta bien la sintaxis aca)
    
    /*assign hum[7] = complete[1];   
    assign hum[6] = complete[2];   
    assign hum[5] = complete[3];   
    assign hum[4] = complete[4];   
    assign hum[3] = complete[5];   
    assign hum[2] = complete[6];   
    assign hum[1] = complete[7];   
    assign hum[0] = complete[8];    
    
    assign tem[7] = complete[17];
    assign tem[6] = complete[18];
    assign tem[5] = complete[19]; 
    assign tem[4] = complete[20];
    assign tem[3] = complete[21];  
    assign tem[2] = complete[22];
    assign tem[1] = complete[23];
    assign tem[0] = complete[24];*/

endmodule

