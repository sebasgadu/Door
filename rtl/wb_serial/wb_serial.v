//Serial Master

module wb_serial(        
        input               clk,
	input               reset,
	// Wishbone bus
	input      [31:0]   wb_adr_i,
	input      [31:0]   wb_dat_i,
	output reg [31:0]   wb_dat_o,
	input      [ 3:0]   wb_sel_i,
	input               wb_cyc_i,
	input               wb_stb_i,
	output              wb_ack_o,
	input               wb_we_i,
        // Serial
        inout               onewire
);

//instanciacion topmodule

reg measure;
wire done;
wire [7:0] tem;
wire [7:0] temd;
wire [7:0] hum;
wire [7:0] humd;
wire [7:0] sum;

TopTop3 serial0 (
    .clk(clk),
    .reset(reset),
    .onewire(onewire),
    .measure(measure),
    .done(done),
    .tem(tem),
    .temd(temd),
    .hum(hum),
    .humd(humd),
    .sum(sum)
);

reg ack;

wire wb_rd = wb_stb_i & wb_cyc_i & ~wb_we_i;
wire wb_wr = wb_stb_i & wb_cyc_i &  wb_we_i;

assign wb_ack_o = wb_stb_i & wb_cyc_i & ack;

always@(posedge clk) begin

    if(reset)begin
        ack <= 0;
        measure <= 0;
    end
    else begin
        ack <= 0;
        measure <= 0; 
        if (wb_rd & ~ack) begin             
            ack <= 1;
            //measure <= 0; 
            case(wb_adr_i[4:2]) 
                3'b000: begin
                    wb_dat_o[7:0] <= hum;
                    wb_dat_o[31:8] <= 0;      
                end
                3'b001: begin
                     wb_dat_o[7:0] <=tem;
                     wb_dat_o[31:8] <= 0;      
                end
                3'b010: begin
                    wb_dat_o[7:0] <= sum;
                    wb_dat_o[31:8] <= 0;      
                end
            default: wb_dat_o <= 32'b0;     
            endcase
        end
        else if (wb_wr & ~ack ) begin  
                ack <= 1;
                if(wb_adr_i[4:2] ==3'b011) begin
                    measure <= 1'd1;  
                end 
             end
        end                    
end

endmodule


