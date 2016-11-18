//---------------------------------------------------------------------------
// Wishbone UART 
//
// Register Description:
//
//    0x00 UCR      [ 0 | 0 | 0 | tx_busy | 0 | 0 | rx_error | rx_avail ]
//    0x04 DATA
//
//---------------------------------------------------------------------------

module wb_i2c (
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
	// i2c wires
	output             i2c_sclk,
	inout              i2c_sdat
);

//---------------------------------------------------------------------------
// Actual i2c engine
//---------------------------------------------------------------------------

reg startread;
reg startwrite;
reg rw;
reg [6:0] divisor;
wire done;
wire i2c_ack;
reg [15:0] i2c_data;
wire [7:0] i2c_data_out;
wire i2c_avail;
wire start_i2c_signal;
wire [4:0] stage;


i2c i2c0 (
	.clk(clk),
	.reset(reset),
         //
	.i2c_sclk(i2c_sclk),
        .i2c_sdat(i2c_sdat),
         //
	.startread(startread),
	.startwrite(startwrite),
        .rw(rw),
        .divisor(divisor),
        .i2c_data(i2c_data),
        .start_i2c_signal(start_i2c_signal),
        .stage(stage),
        //
        .done(done),
        .ack(i2c_ack),
        .i2c_data_out(i2c_data_out),
        .i2c_avail(i2c_avail)
);

//---------------------------------------------------------------------------
// 
//---------------------------------------------------------------------------
wire [7:0] ucr = { 3'b0, done, 1'b0 ,start_i2c_signal,  1'b0,  1'b0 };

wire wb_rd = wb_stb_i & wb_cyc_i & ~wb_we_i;
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i;

reg  ack;

assign wb_ack_o = wb_stb_i & wb_cyc_i & ack;

always @(posedge clk)
begin
	if (reset) begin
		wb_dat_o[31:8] <= 24'b0;
		divisor  <= 0;
		startread <= 0;
                startwrite <= 0;
                ack    <= 0;
	end else begin
//	        wb_dat_o[31:8] <= 24'b0;
		startread <= 0;
                startwrite <= 0;
                ack    <= 0;
		if (wb_rd & ~ack) begin
            
			ack <= 1;
			case (wb_adr_i[4:2])
			3'b000: begin
				wb_dat_o[7:0] <= ucr;
			end
			3'b001: begin
				wb_dat_o[7:0] <= i2c_data_out;

			end
		        default: wb_dat_o[7:0] <= 8'b0;
			endcase
		end else if (wb_wr & ~ack ) begin
			ack <= 1;
			 case (wb_adr_i[4:2])
			   3'b010:  divisor <= wb_dat_i[7:0];
			   3'b011: begin
                                   startread <= 1'b1;
                                   startwrite <= 1'b0;
                                   rw <= 1'b1;
                                   i2c_data <= wb_dat_i[15:0];
                           end
			   3'b100: begin
                                   startread <=1'b0;
                                   startwrite <=1'b1;
                                   rw <=1'b0;
                                   i2c_data <= wb_dat_i[15:0];
                           end
			   default: begin
                                   startread <=1'b0;
                                   startwrite<=1'b0;
                           end
			 endcase
		end
	end
end


endmodule
