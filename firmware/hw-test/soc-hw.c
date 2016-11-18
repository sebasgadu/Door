#include "soc-hw.h"

i2c_t    *i2c0   = (i2c_t *)      0x10000000;
uart_t   *uart0  = (uart_t *)     0x20000000;
serial_t *serial0 = (serial_t *)  0x30000000;
gpio_t   *gpio0  = (gpio_t *)     0x40000000;
spi_t	 *spi0	 = (spi_t *)      0x50000000;
timer_t  *timer0 = (timer_t *)    0x60000000;


isr_ptr_t isr_table[32];


void tic_isr();
/***************************************************************************
 * IRQ handling
 */
void isr_null()
{
}

void irq_handler(uint32_t pending)
{
	int i;

	for(i=0; i<32; i++) {
		if (pending & 0x01) (*isr_table[i])();
		pending >>= 1;
	}
}

void isr_init()
{
	int i;
	for(i=0; i<32; i++)
		isr_table[i] = &isr_null;
}

void isr_register(int irq, isr_ptr_t isr)
{
	isr_table[irq] = isr;
}

void isr_unregister(int irq)
{
	isr_table[irq] = &isr_null;
}

/***************************************************************************
 * TIMER Functions
 */
void msleep(uint32_t msec)
{
	uint32_t tcr;

	// Use timer0.1
	timer0->compare1 = (FCPU/1000)*msec;
	timer0->counter1 = 0;
	timer0->tcr1 = TIMER_EN | TIMER_IRQEN;

	do {
		//halt();
 		tcr = timer0->tcr1;
 	} while ( ! (tcr & TIMER_TRIG) );
}


void nsleep(uint32_t nsec)
{
	uint32_t tcr;

	// Use timer0.1
	timer0->compare1 = (FCPU/1000000)*nsec;
	timer0->counter1 = 0;
	timer0->tcr1 = TIMER_EN | TIMER_IRQEN;

	do {
		//halt();
 		tcr = timer0->tcr1;
 	} while ( ! (tcr & TIMER_TRIG) );
}

uint32_t tic_msec;

void tic_isr()
{
	tic_msec++;
	timer0->tcr0     = TIMER_EN | TIMER_AR | TIMER_IRQEN;
}



void tic_init()
{
	tic_msec = 0;

	// Setup timer0.0
	timer0->compare0 = (FCPU/10000);
	timer0->counter0 = 0;
	timer0->tcr0     = TIMER_EN | TIMER_AR | TIMER_IRQEN;

	isr_register(1, &tic_isr);	
}

/***************************************************************************
 * WIFI ESP8266 Functions
 */

void init_wifi(){ //configurar el modulo como estación con puerto 80
        int c = 0;
        while(~c){
            uart_putstr("AT+RST\r\n");
            msleep(500);
            //c = ok();
            
            if(c==1){
                uart_putstr("AT+CIPMUX=1\r\n");
                c=ok();
                if(c==1){
                    uart_putstr("AT+CIPSERVER=1,80\r\n");
                    c = ok();
                    /*if(c==1){
                        uart_putstr("AT+ CWSAP=\"PRUEBA\",\"contrasena\",11,4\r\n");
                        c = ok();
                    }*/
                }
            }
        }
}

void wifi_putchar(char a){
	int c = 0; 	  
	while(c == 0){
		uart_putstr("AT+CIPSEND=0,1\r\n");
		uart_putchar(a);
		c = ok();
	}
}

char wifi_getchar(){
	char c='\n';
	int i=0;
	for(i=0;i<20;i++){
		c = uart_getchar();
		if (c ==':'){
			c = uart_getchar();
			return c;
			break;
		}
	}
	return '\n';

}

/*int ok(){
	int i=0;
	char a;
	for(i=0;i<30;i++){
		a=uart_getchar();
		if(a=='K'){
			return 1;
		}
	}
	return 0;

}*/

int ok()
{
	#define TAMBUFF 10
	//int TAMBUFF = 10;
        uint32_t buffer [TAMBUFF];	
	int cond = 1;
	while(cond)
	{
		
		char variable=uart_getchar();
		char ind=0;
		while(variable!=10  && ind < TAMBUFF){
			buffer[ind++]=variable;
			variable=uart_getchar();
		}		

		if(buffer[0]=="O"&& buffer[1]=="K"){
			return cond;
			break;
		}
		else if(buffer[0]=="E"&& buffer[1]=="R" && buffer[2]=="R"&& buffer[3]=="O" && buffer[4]=="R"){
			cond = 0;
			return cond;
			break;
		}
		/*else {
			buffer[]= 0;
		}*/
	}
}
/***************************************************************************
 * UART Functions
 */
void uart_init()
{
	//uart0->ier = 0x00;  // Interrupt Enable Register
	//uart0->lcr = 0x03;  // Line Control Register:    8N1
	//uart0->mcr = 0x00;  // Modem Control Register

	// Setup Divisor register (Fclk / Baud)
	//uart0->div = (FCPU/(57600*16));
}

char uart_getchar()
{   
	while (! (uart0->ucr & UART_DR)) ;
	return uart0->rxtx;
}

void uart_putchar(char c)
{
	while (uart0->ucr & UART_BUSY) ;
	uart0->rxtx = c;
}

void uart_putstr(char *str)
{
	char *c = str;
	while(*c) {
		uart_putchar(*c);
		c++;
	}
}

/***************************************************************************
 * SPI Functions
 */
//These are the specific funtions for the rc522 rfid reader card
void spi_start()
{
	spi0->ucr=0x1;
	spi0->ucr=0x0;
}
unsigned char spi_read (char reg)
{
	//reg= reg<<1;
	uint32_t regAddress = (0x80 | (reg & 0x7E));
	regAddress = regAddress << 8;
	while(spi0->ucr & SPI_BUSY);
	spi0->data_in= regAddress;
	spi_start();
	while(spi0->ucr & SPI_BUSY);
	
	return spi0->data_out;	
}
void spi_write (char reg, char value)
{
	//reg=reg<<1;
	uint32_t regAddress=(reg & 0x7E);
	regAddress = regAddress << 8;
	uint32_t data0 = regAddress | value;
	while(spi0->ucr & SPI_BUSY);
	spi0->data_in=data0;
	spi_start();
}


/*****************************************************************************
* GPIO Functions
*/

/*
int read_columna(){
	gpio0->ctrl = 0x10;
	return gpio0->in;
}

void write_fila(int code){
	gpio0->ctrl = 0x14;
	gpio0->out = code;
}

void write_buzzer(int signal){
	gpio0->ctrl = 0x18;
	gpio0->oe = signal;
}
*/
void initdir(int first, int direction){
	gpio0->oe = direction;
	gpio0->out = first; //inicializar gpio
	
}


int read_last(){
	int ultimo;
	ultimo = gpio0->last;
	return ultimo;
}

void write_fila(int code){
	
	char flag0;
	char flag1;
	char flag2;
	char flag3;
	char flag4;

	switch (code){
			
		case 1: 
			flag1 = 7 & (4 | read_last());	
			gpio0->out = flag1;
			break;
		case 2: 
			flag2 = 11 & (8 | read_last());	
			gpio0->out = flag2;
			break;
		case 4: 
			flag3 = 19 & (16 | read_last());	
			gpio0->out = flag3;
			break;
		case 8: 
			flag4 = 35 & (32 | read_last());	
			gpio0->out = flag4;
			break;
		default: 
			flag0 = 3 & read_last();
			gpio0->out = flag0;
			break;			
	
	}
}

char read_hums(){

	uint32_t inputh;
	uint32_t dataouth;
	uint32_t out;	
	
	inputh = 16320 & gpio0->in;
	dataouth = inputh>>6;
 	
	out = 100-(100*(dataouth-90))/165; 
		
	return out;
}


char read_columna(){
	
	uint32_t inputc;
	uint32_t dataoutc;
	inputc = 245760 & gpio0->in;
	dataoutc = inputc>>14;
	
	return dataoutc;		
}



void initled(){
	int doutled1 = 2 | read_last();
	gpio0->out = doutled1;	
}

void offled(){
	int doutled2 = 61 & read_last();
	gpio0->out = doutled2; 	
}

void initvalve(){
	int doutvalve1 = 1 | read_last();	
	gpio0->out = doutvalve1; 
}

void offvalve(){
	int doutvalve2 = 62 & read_last();
	gpio0->out = doutvalve2;
} 

void initclkadc(){
	gpio0->initadc = 1;
}


/******************************************************************************
* i2c Functons
*/


void i2c_write (unsigned char dir, unsigned char data)
{ 
   while(!((i2c0->ucr & I2C_DONE)));
   i2c0->write =  dir<<9|data;
}


char i2c_read ( char dir)
{

    while(!((i2c0->ucr & I2C_DONE)));
    i2c0->read=dir;
    nsleep(15); 
    while(!((i2c0->ucr & I2C_DONE)));
    return i2c0->i2c_data_out;

    
}


void i2c_clockfreq(char div)
{
      while(!((i2c0->ucr & I2C_DONE)));
      i2c0->divisor=div;

}

/******************************************************************************
* Serial Functons
*/

void serial_init()
{
     serial0->measure = 1;
     msleep(80);
}

char read_humidity()
{   
    serial_init(); 
    return serial0->humidity;
}

char read_temperature()
{
    serial_init();
    return serial0->temperature;
}

char read_sum()
{
    serial_init();
    return serial0->sum;
}

char good()
{    
     int ind = 0;
     int plus = serial0->temperature + serial0->humidity;
     if(plus == serial0->sum) ind = 1;
     else ind = 0;
     
     return ind;   
}

