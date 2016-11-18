//---------------------------------------------------------------------------
// Wishbone SPI
//
// Register Description:
//
//    0x00 UCR      [ 0 | 0 | 0 | 0 | 0 | newData | busy | start]
//    0x04 DATA
//
//---------------------------------------------------------------------------

module wb_spi (

	input              clk,
	input              reset,
	// Wishbone interface
	input              wb_stb_i,
	input              wb_cyc_i,
	output             wb_ack_o,
	input              wb_we_i,
	input       [31:0] wb_adr_i,
	input        [3:0] wb_sel_i,
	input       [31:0] wb_dat_i,
	output reg  [31:0] wb_dat_o,
	// Serial Wires
	input 		   miso,
	output		   mosi,
	output 		   sck,
	output 	           ss
);


//---------------------------------------------------------------------------
// Actual I2C engine
//---------------------------------------------------------------------------
reg start;
reg  [15:0]data_in;
wire [15:0] data_out;
wire busy_spi;
wire newData_spi;
wire start_spi;
wire [15:0] data_in_spi;

assign start_spi=start;
assign data_in_spi=data_in;


spi_controller spi_controller (
    .clk(clk), 
    .rst(reset), 
    .miso(miso), 
    .mosi(mosi), 
    .sck(sck), 
    .ss(ss), 
    .start(start_spi), 
    .data_in(data_in_spi), 
    .data_out(data_out), 
    .busy(busy_spi), 
    .new_data(newData_spi)
    );





//---------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------
wire [7:0] ucr = { 5'b0, newData_spi , busy_spi, start_spi };

wire wb_rd = wb_stb_i & wb_cyc_i & ~wb_we_i;
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i;

reg  ack;

assign wb_ack_o = wb_stb_i & wb_cyc_i & ack;

always @(posedge clk)
begin
	if (reset) begin
		wb_dat_o       <= 32'b0;
 		start	     	     <= 1'b0;
		data_in              <= 16'b0;    
		//wishbone ack
		ack    		     <= 0;
	end else begin
		ack<=1'b0;
		if (wb_rd & ~ack) begin
			ack <= 1;

			case (wb_adr_i[3:2])
			2'b00: begin
				wb_dat_o[7:0] <= ucr;
			end
  			2'b10 : begin
				wb_dat_o[7:0] <= data_out[7:0];
			end
			default: begin
				wb_dat_o[7:0] <= 8'b0;
			end
			endcase

		end else if (wb_wr & ~ack ) begin
			ack <= 1;

			case (wb_adr_i[3:2])
			2'b00: begin
				start<=wb_dat_i[0];					
			end
			2'b01:begin
				data_in<=wb_dat_i[15:0]; 
			end	

			endcase
			
		end
	end
end


endmodule
