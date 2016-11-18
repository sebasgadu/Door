/**
 * 
 */

#include "soc-hw.h"

//MF522 Command word
#define PCD_IDLE              0x00               //NO action; Cancel the current command
#define PCD_AUTHENT           0x0E               //Authentication Key
#define PCD_RECEIVE           0x08               //Receive Data
#define PCD_TRANSMIT          0x04               //Transmit data
#define PCD_TRANSCEIVE        0x0C               //Transmit and receive data,
#define PCD_RESETPHASE        0x0F               //Reset
#define PCD_CALCCRC           0x03               //CRC Calculate

  // Page 0: Command and status
#define    CommandReg       0x01 << 1  // starts and stops command execution
#define    ComIEnReg        0x02 << 1  // enable and disable interrupt request control bits
#define    DivIEnReg        0x03 << 1  // enable and disable interrupt request control bits
#define    ComIrqReg        0x04 << 1  // interrupt request bits
#define    DivIrqReg        0x05 << 1  // interrupt request bits
#define    ErrorReg         0x06 << 1  // error bits showing the error status of the last command executed 
#define    Status1Reg         0x07 << 1  // communication status bits
#define    Status2Reg         0x08 << 1  // receiver and transmitter status bits
#define    FIFODataReg        0x09 << 1  // input and output of 64 byte FIFO buffer
#define    FIFOLevelReg       0x0A << 1  // number of bytes stored in the FIFO buffer
#define    WaterLevelReg      0x0B << 1  // level for FIFO underflow and overflow warning
#define    ControlReg         0x0C << 1  // miscellaneous control registers
#define    BitFramingReg      0x0D << 1  // adjustments for bit-oriented frames
#define    CollReg          0x0E << 1  // bit position of the first bit-collision detected on the RF interface
    //              0x0F      // reserved for future use
    
    // Page 1: Command
    //              0x10      // reserved for future use
#define    ModeReg          0x11 << 1  // defines general modes for transmitting and receiving 
#define    TxModeReg        0x12 << 1  // defines transmission data rate and framing
#define    RxModeReg        0x13 << 1  // defines reception data rate and framing
#define    TxControlReg     0x14 << 1  // controls the logical behavior of the antenna driver pins TX1 and TX2
#define    TxAutoReg         0x15 << 1  // controls the setting of the transmission modulation
#define    TxSelReg         0x16 << 1  // selects the internal sources for the antenna driver
#define    RxSelReg         0x17 << 1  // selects internal receiver settings
#define    RxThresholdReg   0x18 << 1  // selects thresholds for the bit decoder
#define    DemodReg         0x19 << 1  // defines demodulator settings
    //              0x1A      // reserved for future use
    //              0x1B      // reserved for future use
#define    MfTxReg          0x1C << 1  // controls some MIFARE communication transmit parameters
#define    MfRxReg          0x1D << 1  // controls some MIFARE communication receive parameters
    //              0x1E      // reserved for future use
#define    SerialSpeedReg   0x1F << 1  // selects the speed of the serial UART interface
    
    // Page 2: Configuration
    //              0x20      // reserved for future use
#define    CRCResultRegH    0x21 << 1  // shows the MSB and LSB values of the CRC calculation
#define    CRCResultRegL    0x22 << 1
    //              0x23      // reserved for future use
#define    ModWidthReg      0x24 << 1  // controls the ModWidth setting?
    //              0x25      // reserved for future use
#define    RFCfgReg         0x26 << 1  // configures the receiver gain
#define    GsNReg           0x27 << 1  // selects the conductance of the antenna driver pins TX1 and TX2 for modulation 
#define    CWGsPReg         0x28 << 1  // defines the conductance of the p-driver output during periods of no modulation
#define    ModGsPReg        0x29 << 1  // defines the conductance of the p-driver output during periods of modulation
#define    TModeReg         0x2A << 1  // defines settings for the internal timer
#define    TPrescalerReg    0x2B << 1  // the lower 8 bits of the TPrescaler value. The 4 high bits are in TModeReg.
#define    TReloadRegH      0x2C << 1  // defines the 16-bit timer reload value
#define    TReloadRegL      0x2D << 1
#define    TCounterValueRegH    0x2E << 1  // shows the 16-bit timer value
#define    TCounterValueRegL    0x2F << 1

void setBit(char reg, char mask)
{
	char tmp;
	tmp = spi_read(reg);
	spi_write(reg, tmp | mask);   
}
void clearBit(char reg, char mask)
{
	char tmp;
	tmp = spi_read(reg);
	spi_write(reg, tmp & (~mask));
}

void initRfidReader()
{
	//Make Soft Reset
	spi_write(CommandReg, PCD_RESETPHASE);
	while (spi_read(CommandReg) & (1<<4));
    //Wait until the PCD finish reseting
	

	spi_write(TModeReg, 0x8D );      //Tauto=1; f(Timer) = 6.78MHz/TPreScaler
	spi_write( TPrescalerReg, 0x3E );//TModeReg[3..0] + TPrescalerReg
	spi_write( TReloadRegL, 0x30 );           
	spi_write( TReloadRegH, 0x0 );   //WWWWWWWWWARNING: colocar ambo ceros o revisar que hace el registro
	spi_write( TxAutoReg, 0x40 );    //100%ASK
	spi_write( ModeReg, 0x3D );

	//AntennaON
	setBit( TxControlReg, 0x03 );
	
	//FINISH INIT 
}

uint32_t loop()
{
		char uno, dos, tres, cuatro, cinco, seis, siete, ocho, nueve, diez;
	//Begin Testing
	//uart_putstr("Iniciando prueba...."); Para prueba NFC
	//uart_putstr("\n\r");	Para prueba NFC
	//msleep(3000);		Para prueba NFC
	
	
	//IS_CARD
	//REQUEST

	spi_write( BitFramingReg, 0x07 );

	//TO_CARD
	char irqEn = 0x77;
	//Serial.println(irqEn, HEX);
	spi_write( ComIEnReg, irqEn | 0x80 );
	clearBit( ComIrqReg, 0x80 );
	setBit( FIFOLevelReg, 0x80 );
	spi_write( CommandReg, PCD_IDLE );
	spi_write( FIFODataReg, 0x26 );   //Escribiendo
	spi_write( CommandReg, PCD_TRANSCEIVE );
	setBit( BitFramingReg, 0x80 );

	//25ms revisando esto:
	char n;
	char waitIrq = 0x30;


	char flag = 1;
	while(flag)
	{
		//Serial.println("Entro a verificar");
		n =spi_read( ComIrqReg );
		if(n & waitIrq)
		{
			//Serial.println("ha cambiado algo");
			flag = 0;
		}
		if(n & 0x01)
		{
			//Serial.println("TIMEOUT, nada en 25ms");
			flag=0;
		}
		msleep(1);
		
	}
	
	flag=1;

	clearBit ( BitFramingReg, 0x80 );
	char lec;
	lec = spi_read( ErrorReg);
	
	/*if( !( lec & 0x1B) )
	{
		//Serial.println(lec, HEX);
		//Serial.println("status=MI_OK, todo va bien");
		if ( n & irqEn & 0x01 )     // WARNING: Parece ser otra lectura de un posible error, pero pues
			//Serial.println("status=NOTAGERR, NO todo va bien");
	}*/
	
	n = spi_read(FIFOLevelReg); //leer cantidad de datos
	
	/*uart_putstr("la cantidad de datos en el primer ciclo,n a leer es:  ");
	uart_putchar(n+48);
	uart_putstr("\n\r");								Para prueba NFC
	uart_putstr("-------");
	uart_putstr("\n\r");*/
	
	char i=0;
	
	while (i<n)
	{
		lec = spi_read(FIFODataReg);
		//uart_putstr(" Dato leido en el primer ciclo de FIFO: ");		Para prueba NFC
		char firstDigit  = lec & 0x0f;
		if (firstDigit <= 9) 
			firstDigit=firstDigit+48;
		else
			firstDigit=firstDigit+55;
		
		char secondDigit = (lec & 0xf0)>>4;
		if (secondDigit <= 9) 
			secondDigit=secondDigit+48;
		else
			secondDigit=secondDigit+55;

		/*uart_putchar(secondDigit);
		uart_putchar(firstDigit);                                                Para prueba NFC
		uart_putstr("\n\r");*/
		
		i=i+1;
	}
	
	/*
	uart_putstr("------- \n");
	char validBits;
	validBits = Rd(ControlReg) & 0x07; //Ver nro de bits validos
	Serial.print("Bits validos");Serial.print(validBits, BIN);
	Serial.println();
	*/
	
	//FIN TO_CARD
	//FIN REQUEST
	//FIN IS_CARD

	//READ_CARD_SERIAL

	//ANTICOLL
	spi_write( BitFramingReg, 0x00 );
	clearBit( Status2Reg, 0x08 );     //WARGNING: no presente en anterior ejemplo del cuaderno, tal vez puede ser omitido
	
	
	//TO_CARD

	spi_write( ComIEnReg, irqEn | 0x80 );
	clearBit( ComIrqReg, 0x80 );
	setBit( FIFOLevelReg, 0x80 );
	spi_write( CommandReg, PCD_IDLE );
	spi_write( FIFODataReg, 0x93 ); //EScribiendo PICC_ANTICOLL
	spi_write( FIFODataReg, 0x20 ); //EScribiendo NVB
	spi_write( CommandReg, PCD_TRANSCEIVE );
	setBit( BitFramingReg, 0x80 );
	
	while(flag)
	{
		//Serial.println("Entro a verificar");
		n =spi_read( ComIrqReg );
		if(n & waitIrq){
		//Serial.println("ha cambiado algo");
		flag = 0;
		}
		if(n & 0x01){
		//Serial.println("TIMEOUT, nada en 25ms");
		flag=0;
		}

		msleep(1);
	}
	
	flag = 1;

	clearBit( BitFramingReg, 0x80 );
	//char lec;
	/*lec = spi_read( ErrorReg);
	if( !( lec & 0x1B) ){
		Serial.println(lec, HEX);
		Serial.println("status=MI_OK, todo va bien");

		if ( n & irqEn & 0x01 )// WWWWWWWWARNING: Parece ser otra lectura de un posible error, pero pues
			Serial.println("status=NOTAGERR, NO todo va bien");
	}*/
	
	n = spi_read(FIFOLevelReg); //leer cantidad de datos
        if((n+48) == '0'){
            return 'x';
        }
	
	/*uart_putstr("la cantidad de datos n a leer es:  ");
	uart_putchar(n+48);
	uart_putstr("\n\r");                                               Para prueba NFC
	uart_putstr("-------");
	uart_putstr("\n\r");*/	

	i=0;
	
	while (i<n)
	{
		lec = spi_read(FIFODataReg);
		//uart_putstr(" Dato leido en el primer ciclo de FIFO: ");
		char firstDigit  = lec & 0x0f;
		if (firstDigit <= 9) 
			firstDigit=firstDigit+48;
		else
			firstDigit=firstDigit+55;
		
		char secondDigit = (lec & 0xf0)>>4;
		if (secondDigit <= 9) 
			secondDigit=secondDigit+48;
		else
			secondDigit=secondDigit+55;

		/*uart_putchar(secondDigit);
		uart_putchar(firstDigit);
		uart_putstr("\n\r");*/
		
		msleep(10);
		
		if(i==0){
		uno = secondDigit;
		dos = firstDigit;
		}
		if(i==1){
		tres = secondDigit;
		cuatro = firstDigit;
		}
		if(i==2){
		cinco = secondDigit;
		seis = firstDigit;
		}
		if(i==3){
		siete = secondDigit;
		ocho = firstDigit;
		}
		if(i==4){
		nueve = secondDigit;
		diez = firstDigit;
		}

		msleep(10);

		i=i+1;

		
	}
	
	if((uno == 'E') && (dos == 'B') &&(tres == 'D') &&(cuatro == 'F') &&(cinco == '3') &&(seis == 'B') &&(siete == '4') &&(ocho == '0') &&(nueve == '4') &&(diez == 'F')||(uno == '2') && (dos == 'B') &&(tres == 'A') &&(cuatro == 'D') &&(cinco == '3') &&(seis == '4') &&(siete == '4') &&(ocho == '0') &&(nueve == 'F') &&(diez == '2'))
	{
		return 'n';
	}
	else
	{
		return 'f';
	}

}



//---------------------------------------------------------------------------
// LCD Functions
//---------------------------------------------------------------------------

void writeCharlcd (char letter) 
{
  char highnib;
  char lownib;
  highnib = letter&0xF0;
  lownib = letter&0x0F;

     i2c_write(0x3F,highnib|0b00001001);
     i2c_write(0x3F,highnib|0b00001101);
     i2c_write(0x3F,highnib|0b00001001);  

     i2c_write(0x3F,(lownib<<4)|0b00001001);
     i2c_write(0x3F,(lownib<<4)|0b00001101);
     i2c_write(0x3F,(lownib<<4)|0b00001001);
}




void writeCommandlcd (char command) 
{
  char highnib;
  char lownib;
  highnib = command&0xF0;
  lownib = command&0x0F;

     i2c_write(0x3F,highnib|0b00001000);
     i2c_write(0x3F,highnib|0b00001100);
     i2c_write(0x3F,highnib|0b00001000);  

     i2c_write(0x3F,(lownib<<4)|0b00001000);
     i2c_write(0x3F,(lownib<<4)|0b00001100);
     i2c_write(0x3F,(lownib<<4)|0b00001000);
}




void writeStringlcd (char *str) {
	char *c = str;
	while(*c) {
		writeCharlcd(*c);
		c++;
	}
}







// LCD Commands------------------------------------------

// LCD_I2C CONFIG
// DB7 DB6 DB5 DB4 CTRST EN RW RS

void clearDisplay() 
{
   writeCommandlcd(0b00000001);
}

void returnHome()
{
   writeCommandlcd(0b00000010);
   msleep(2);
}

// I/D = 1, S=0
void entryModeSet2()
{  
  
   writeCommandlcd(0b00000110);
   msleep(1);
}

// I/D = 1, S=1
void entryModeSet()
{  
   writeCommandlcd(0b00000111);
   msleep(1);
}


// I/D = 0, S=0
void entryModeSet3()
{  
   writeCommandlcd(0b00000100);
   msleep(1);
}

// I/D = 0, S=1
void entryModeSet4()
{  
   writeCommandlcd(0b00000101);
   msleep(1);
}


void displayOff()
{  
   writeCommandlcd(0b00001000);
   msleep(1);
}

// D=1, C=1, B=1
void displayOn()
{  

   writeCommandlcd(0b00001111);
   msleep(1);
}


// S/C = 0, R/L = 1
void cursorShiftRight()
{  
   writeCommandlcd(0b00010100);
   msleep(1);
}



// S/C = 0, R/L = 0
void cursorShiftLeft()
{  
   writeCommandlcd(0b00010000);
   msleep(1);
}


// S/C = 1, R/L = 1
void displayShiftRight()
{   

   writeCommandlcd(0b00011100);
   msleep(1);
}


// S/C = 1, R/L = 0
void displayShiftLeft()
{  
   writeCommandlcd(0b00011000);
   msleep(1);
}



// D/L = 0, N = 1, F = 0
//4-Bit mode, 2 lines, 5x8 dots
void functionSet()
{  

   writeCommandlcd(0b00101000);
   msleep(1);
}




   void displayAddress(uint8_t col, uint8_t row){
	int row_offsets[] = { 0x00, 0x40, 0x14, 0x54 };
	if ( row > 2 ) {
		row = 2-1;    // we count rows starting w/0
	}
        writeCommandlcd (0x80|(col + row_offsets[row]));
}



void lcdInit ()
{  //1
   // LCD_I2C CONFIG
   // DB7 DB6 DB5 DB4 CTRST EN RW RS
   msleep(50);
   i2c_write(0x3F,0b00111000);
   i2c_write(0x3F,0b00111100);
   i2c_write(0x3F,0b00111000);
   msleep(5);
   
   //2
   i2c_write(0x3F,0b00111000);
   i2c_write(0x3F,0b00111100);
   i2c_write(0x3F,0b00111000);
   msleep(5);
   //3
   i2c_write(0x3F,0b00111000);
   i2c_write(0x3F,0b00111100);
   i2c_write(0x3F,0b00111000);
   msleep(1);
   //5
   i2c_write(0x3F,0b00101000);
   i2c_write(0x3F,0b00101100);
   i2c_write(0x3F,0b00101000);
   msleep(1);
   //6
   i2c_write(0x3F,0b00101000);
   i2c_write(0x3F,0b00101100);
   i2c_write(0x3F,0b00101000);
   msleep(1);
   //7
   i2c_write(0x3F,0b10001000);
   i2c_write(0x3F,0b10001100);
   i2c_write(0x3F,0b10001000);
   msleep(1);
   //8
   i2c_write(0x3F,0b00001000);
   i2c_write(0x3F,0b00001100);
   i2c_write(0x3F,0b00001000);
   msleep(1);
   //9
   i2c_write(0x3F,0b10001000);
   i2c_write(0x3F,0b10001100);
   i2c_write(0x3F,0b10001000);
   msleep(1);
   //10
   i2c_write(0x3F,0b00001000);
   i2c_write(0x3F,0b00001100);
   i2c_write(0x3F,0b00001000);
   msleep(2);
   //11
   i2c_write(0x3F,0b11111000);
   i2c_write(0x3F,0b11111100);
   i2c_write(0x3F,0b11111000);
   msleep(1);
   //12
   i2c_write(0x3F,0b00001000);
   i2c_write(0x3F,0b00001100);
   i2c_write(0x3F,0b00001000);
   msleep(1);
   //13
   i2c_write(0x3F,0b01101000);
   i2c_write(0x3F,0b01101100);
   i2c_write(0x3F,0b01101000);
   msleep(2);

}


//---------------------------------------------------------------------------
// RTC Functions
//---------------------------------------------------------------------------


//Función para obtener los segundos del RTC
char getSecondRTC ()
{  
        i2c_write(0x68,0);
        return i2c_read(0x68);
}

//Función para obtener los minutos del RTC
char getMinuteRTC ()
{
     i2c_write(0x68,1);
     return i2c_read(0x68);

}


//Función para obtener la hora del RTC
char getHourRTC ()
{
     i2c_write(0x68,2);
     return i2c_read(0x68);  

}

//---------------------------------------------------------------------------




//---------------------------------------------------------------------------
// ASCII converter 
//---------------------------------------------------------------------------

char asciiConv (char number)
{
     return number+48;

}


//Funcion que devuelve el numero de potencias de 10 en el numero
char powerCount (char number, char tenpower)
{ 

    if (number == 0)
        return tenpower;
    else
        return powerCount (number/10,tenpower+1);
}


char returnHundreds (char number)
{
  char power = powerCount(number,0);
    if (power == 3){
       return (number/100);
    } 
    else return 0;
}


char returnTenths (char number)
{
    number = number%100;
    char power = powerCount(number,0);
    if (power >=2) {
       return (number/10);
    }
   else return 0;
}


char returnUnits (char number)
{
     number = number%100;
     return (number%10);
}




// LCD Functions print ------------------------------------------------------

void printnumberlcd (char number)
{
      char hundred;
      char tenth;
      char unit;

      char hundredascii;
      char tenthascii;
      char unitascii;
    
      hundred = returnHundreds(number);
      tenth = returnTenths(number);
      unit = returnUnits(number);
     
      hundredascii = asciiConv(hundred);
      tenthascii = asciiConv(tenth);
      unitascii = asciiConv(unit);
    
      writeCharlcd(hundredascii);
      writeCharlcd(tenthascii);
      writeCharlcd(unitascii);
} 

// Imprime segundo o minuto
void printnumberRTC (char number)
{
  char highnib;
  char lownib;
  highnib = number&0xF0;
  lownib = number&0x0F;
  
  writeCharlcd(asciiConv(highnib>>4));
  writeCharlcd(asciiConv(lownib));
} 

// Imprime hora
void printHourRTC (char number)
{
  char highnib;
  char lownib;
  highnib = number&0x10;
  lownib = number&0x0F;
  
  writeCharlcd(asciiConv(highnib>>4));
  writeCharlcd(asciiConv(lownib));
} 



//----------------------------------------------------------------------------
inline void writeint(uint32_t val)
{
	uint32_t i, digit;

	for (i=0; i<8; i++) {
		digit = (val & 0xf0000000) >> 28;
		if (digit >= 0xA) 
			uart_putchar('A'+digit-10);
		else
			uart_putchar('0'+digit);
		val <<= 4;
	}
}

void test2() {
    uart_putchar('b');   
}

void test() {
    uart_putchar('a');
    test2();
    uart_putchar('c');
} 

char glob[] = "Global";

volatile uint32_t *p;
volatile uint8_t *p2;

extern uint32_t tic_msec;


//---------------------------------------------------------------------------
// Keyboard functions
//---------------------------------------------------------------------------

uint32_t key_read_num(int val){

	int case1 = 1;
	int case2 = 1;
	uint32_t dato = 0;
	uint32_t clave = 0;

	int bandera1 = 0;
	int bandera2 = 0;
	int bandera3 = 0;
	int bandera4 = 0;

	int cont = 0;
	int temp1 = 0;
	int temp2 = 0;
	int temp3 = 0;
	int temp4 = 0;
	int temp5 = 0;
	int temp6 = 0;
	int temp7 = 0;
	int temp8 = 0;

	uint32_t i;
        uint32_t data1 = 0;
	uint32_t data2 = 0;

	for(i = 2 ; i>1; i++){
//==========================================================================================//
//=============================== key matricial ============================================//

		msleep(1);

		temp1 = bandera1;
		temp2 = bandera2;
		temp3 = bandera3;
		temp4 = bandera4;
		
		switch (case1){
    			case 1:	write_fila(1);
				msleep(1);
				case2 = read_columna();
				switch (case2){
	   				case 1:	dato = 1;
						bandera1 = 1;
						break;
		    			case 2: dato = 4;
						bandera1 = 1;
						break;
			    		case 4:	dato = 7;
						bandera1 = 1;
						break;
		    			case 8: dato = 10;
						bandera1 = 1;
						break;
					default:	dato = dato;
							bandera1 = 0;
							break;
				}
				break;
    			case 2: write_fila(2);
				msleep(1);
				case2 = read_columna();
				switch (case2){
	    				case 1:	dato = 2;
						bandera2 = 1;
						break;
			    		case 2: dato = 5;
						bandera2 = 1;
						break;
		    			case 4:	dato = 8;
						bandera2 = 1;
						break;
			    		case 8: dato = 0;
						bandera2 = 1;
						break;
					default:	dato = dato;
							bandera2 = 0;
							break;
				}
				break;
	    		case 3:	write_fila(4);
				msleep(1);
				case2 = read_columna();
				switch (case2){
	    				case 1:	dato = 3;
						bandera3 = 1;
						break;
		    			case 2: dato = 6;
						bandera3 = 1;
						break;
			    		case 4:	dato = 9;
						bandera3 = 1;
						break;
		    			case 8: dato = 11;
						bandera3 = 1;
						break;
					default:	dato = dato;
							bandera3 = 0;
							break;
				}
				break;
    			case 4:	write_fila(8);
				msleep(1);
				case2 = read_columna();
				switch (case2){
	    				case 1:	dato = 12;
						bandera4 = 1;
						break;
			    		case 2: dato = 13;
						bandera4 = 1;
						break;
		    			case 4:	dato = 14;
						bandera4 = 1;
						break;
			    		case 8: dato = 15;
						bandera4 = 1;
						break;
					default:	dato = dato;
							bandera4 = 0;
							break;
				}
				break;
			default:	write_fila(0);
					break;
		}

		temp5 = bandera1;
		temp6 = bandera2;
		temp7 = bandera3;
		temp8 = bandera4;

		if (val == 0){

			if ((temp1 == 0 && temp5 == 0)||(temp1 == 1 && temp5 == 1)||(temp2 == 0 && temp6 == 0)||(temp2 == 1 && temp6 == 1)||(temp3 == 0 && temp7 == 0)||(temp3 == 1 && temp7 == 1)||(temp4 == 0 && temp8 == 0)||(temp4 == 1 && temp8 == 1)){

			}
			if((temp1 == 0 && temp5 == 1)||(temp2 == 0 && temp6 == 1)||(temp3 == 0 && temp7 == 1)||(temp4 == 0 && temp8 == 1)){
				clave = dato;
				i = 0;
			}
			
			
		}

		
		if (val == 1) {

			if ((temp1 == 0 && temp5 == 0)||(temp1 == 1 && temp5 == 1)||(temp2 == 0 && temp6 == 0)||(temp2 == 1 && temp6 == 1)||(temp3 == 0 && temp7 == 0)||(temp3 == 1 && temp7 == 1)||(temp4 == 0 && temp8 == 0)||(temp4 == 1 && temp8 == 1)){

			}
			if((temp1 == 0 && temp5 == 1)||(temp2 == 0 && temp6 == 1)||(temp3 == 0 && temp7 == 1)||(temp4 == 0 && temp8 == 1)){

				if((dato == 14)||(dato == 15)||(dato == 10)||(dato == 11)){
				
				}
				else{
					if(dato == 12){
						clave = data2;
						clearDisplay();	
						msleep(10);
						i = 0;
						cont = 3;
						
					}
					if(dato == 13){
						
						data1 = 0;
						data2 = 0;						
						displayAddress(6,1);
						printnumberlcd(000);
						msleep(500);
						cont = -1;
										
					}
	
					cont = cont + 1;

					if (cont == 1){
						data1 = dato;
						displayAddress(6,1);
						printnumberlcd(data1);
						msleep(500);
					}
					if (cont == 2){
						data2 = dato + 10*data1;
						displayAddress(6,1);
						printnumberlcd(data2);
						//i = 0;
						msleep(500);
					}

				}
			}	

		}
		
		if (case1 == 4){
			case1 = 0;
		}

		case1 = case1 + 1;
	}
	return clave;
}
/*****************************************************************************************
VALIDAR TARJETA
++++++++++++++++++++++++++++++++++*/
void validar(){
	
}



int main()
{
	i2c_clockfreq(7);
	lcdInit();
	//displayAddress(0,0);
	//writeStringlcd("Validar tarjeta");
	msleep(50);
	//clearDisplay();                  

	initRfidReader();
	
        //init_wifi();
        uart_putstr("AT+RST\r\n");
        msleep(500);
        uart_putstr("AT+CIPMUX=1\r\n");
        msleep(500);
        uart_putstr("AT+CIPSERVER=1,80\r\n");
        msleep(500);
        uart_putstr("AT+CWSAP=\"PUERTA_RAPIDA\",\"987654321\",11,4\r\n");
        msleep(500);
        //msleep(1000);
        
        char n, user;
        
        while(1)
	{
		displayAddress(0,0);
                writeStringlcd("Validar tarjeta");
                msleep(50);
                user=loop();

		//n=wifi_getchar();
		if(user !='x')
		{
			/*uart_putstr("Valid Command, begin loop");
			uart_putstr("\n\r");
			user=loop();
			uart_putchar(user);
			*/
			clearDisplay();
                        msleep(50);
			displayAddress(0,0);
			writeStringlcd("Validando");
			
//			user=loop();
			if (user=='n'){
					clearDisplay();
                                        msleep(50);
					displayAddress(0,0);
					writeStringlcd("Permitido");
					msleep(3000);
                                        clearDisplay();
                                        msleep(50);
					}
	
			else
				{
				//uart_putstr("Invalid command");
				//uart_putstr("\n\r");
				clearDisplay();
                                msleep(50);
				displayAddress(0,0);
				writeStringlcd("Denegado");
				msleep(3000);
                                clearDisplay();
                                msleep(50);
				}
		}
		/*else
			{
			clearDisplay();
                        msleep(50);
			displayAddress(0,0);
			writeStringlcd("Oprima s");
			msleep(3000);
                        clearDisplay();
                        msleep(50);
                }	*/
		/*if(n!='s')
		{
			displayAddress(0,0);
				writeStringlcd("Digite s");
				msleep(6000);
				clearDisplay();
		}*/
		
	}
	
}

