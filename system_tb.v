//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------
`timescale 1 ns / 100 ps

module system_tb;

//----------------------------------------------------------------------------
// Parameter (may differ for physical synthesis)
//----------------------------------------------------------------------------
parameter tck              = 10;       // clock period in ns
parameter uart_baud_rate   = 1152000;  // uart baud rate for simulation 

parameter clk_freq = 1000000000 / tck; // Frequenzy in HZ
//----------------------------------------------------------------------------
//
//----------------------------------------------------------------------------
reg        clk;
reg        rst;
//wire       led;

//----------------------------------------------------------------------------
// UART STUFF (testbench uart, simulating a comm. partner)
//----------------------------------------------------------------------------
wire         uart_rxd;
wire         uart_txd;


wire	[5:0]  busgpioout;
wire	[17:6] busgpioin;

reg sdat;
assign i2c_sdat = (sdat) ? 1'bz : 1'b0;



//----------------------------------------------------------------------------
// Device Under Test 
//----------------------------------------------------------------------------
system #(
	.clk_freq(           clk_freq         ),
	.uart_baud_rate(     uart_baud_rate   )
) dut  (
	.clk(          clk    ),
	// Debug
	.rst(          rst    ),
	//.led(          led    ),
	// Uart
	.uart_rxd(  uart_rxd  ),
	.uart_txd(  uart_txd  ),

        //i2c
        .i2c_sclk(i2c_sclk),
        .i2c_sdat(i2c_sdat),
        
         //serial
	.onewire(onewire)
);

/* Clocking device */
initial         clk <= 0;
always #(tck/2) clk <= ~clk;

/* Simulation setup */
initial begin



	$dumpfile("system_tb.vcd");
	//$monitor("%b,%b,%b,%b",clk,rst,uart_txd,uart_rxd);
	$dumpvars(-1, dut,i2c_sdat);
	//$dumpvars(-1,clk,rst,uart_txd);
	// reset
	#0  rst <= 1;
        #10  rst <= 0;
	#30 rst <= 1;

        #176200 sdat<=1;
	#17595  sdat<=0;
	#17595  sdat<=1;
	#17595  sdat<=0;
	#17595  sdat<=1;
	#17595  sdat<=0;
	#17595  sdat<=1;
	#17595  sdat<=0;


	#(tck*605000) $finish;
end



//----------------------------------------------------------------------------
// i2c Simulation
//----------------------------------------------------------------------------

        //outputs
        wire i2c_sclk;
        //bidirs
        wire i2c_sdat;

//----------------------------------------------------------------------------
// serial Simulation
//----------------------------------------------------------------------------

	//inout
	wire onewire;




endmodule
