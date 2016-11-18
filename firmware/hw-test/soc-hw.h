#ifndef SPIKEHW_H
#define SPIKEHW_H

#define PROMSTART 0x00000000
#define RAMSTART  0x00000800
#define RAMSIZE   0x400
#define frvRAMEND    (RAMSTART + RAMSIZE)

#define RAM_START 0x40000000
#define RAM_SIZE  0x04000000

#define FCPU      100000000

#define UART_RXBUFSIZE 32

/****************************************************************************
 * Types
 */
typedef unsigned int  uint32_t;    // 32 Bit
typedef signed   int   int32_t;    // 32 Bit

typedef unsigned char  uint8_t;    // 8 Bit
typedef signed   char   int8_t;    // 8 Bit

/****************************************************************************
 * Interrupt handling
 */
typedef void(*isr_ptr_t)(void);

void     irq_enable();
void     irq_disable();
void     irq_set_mask(uint32_t mask);
uint32_t irq_get_mak();

void     isr_init();
void     isr_register(int irq, isr_ptr_t isr);
void     isr_unregister(int irq);

/****************************************************************************
 * General Stuff
 */
void     halt();
void     jump(uint32_t addr);


/****************************************************************************
 * Timer
 */
#define TIMER_EN     0x08    // Enable Timer
#define TIMER_AR     0x04    // Auto-Reload
#define TIMER_IRQEN  0x02    // IRQ Enable
#define TIMER_TRIG   0x01    // Triggered (reset when writing to TCR)

typedef struct {
	volatile uint32_t tcr0;
	volatile uint32_t compare0;
	volatile uint32_t counter0;
	volatile uint32_t tcr1;
	volatile uint32_t compare1;
	volatile uint32_t counter1;
} timer_t;

void msleep(uint32_t msec);
void nsleep(uint32_t nsec);

void tic_init();


/***************************************************************************
 * GPIO0
 */
typedef struct {
	//volatile uint32_t ctrl;
	//volatile uint32_t dummy1;
	//volatile uint32_t dummy2;
	//volatile uint32_t dummy3;
	volatile uint32_t in;
	//volatile uint32_t humsoil;
	//volatile uint32_t keyin;
	volatile uint32_t last;
	volatile uint32_t out;
	volatile uint32_t oe;
	volatile uint32_t initadc;
} gpio_t;

void initdir(int first, int direction);
int read_last();
void write_fila(int code);
char read_hums();
char read_columna(); 
void initled();
void offled();
void initvalve();
void offvalve();
void initclkadc();


/***************************************************************************
 * UART0
 */
#define UART_DR   0x01                    // RX Data Ready
#define UART_ERR  0x02                    // RX Error
#define UART_BUSY 0x10                    // TX Busy

typedef struct {
   volatile uint32_t ucr;
   volatile uint32_t rxtx;
} uart_t;

void uart_init();
void uart_putchar(char c);
void uart_putstr(char *str);
char uart_getchar();





/***************************************************************************
 *  i2c0
 */


#define I2C_AVAIL 0x00000001                    // RX Data Ready
#define I2C_ACK   0x00000002                    // RX Error
#define I2C_DONE  0x00000010                    // i2c_avail
#define I2C_START 0x00000004                    //start_i2c_signal


typedef struct {
   volatile uint32_t ucr;   
   volatile uint32_t i2c_data_out;
   volatile uint32_t divisor;
   volatile uint32_t read;
   volatile uint32_t write;
}i2c_t;

void i2c_write (unsigned char dir, unsigned char data);
char i2c_read (char dir);
void i2c_clockfreq(char div);

/***************************************************************************
 * SPI0
 */

#define SPI_START  0x01                    // spi Start
#define SPI_BUSY   0x02                    // spi busy
#define SPI_NEWDATA  0x04                    // spi newData

typedef struct{
	volatile uint32_t ucr;
	volatile uint32_t data_in;
	volatile uint32_t data_out; 
} spi_t;

void spi_start();
unsigned char spi_read(char reg);
void spi_write(char reg, char value);

/***************************************************************************
 * serial0
 */
typedef struct {
	volatile uint32_t humidity;
	volatile uint32_t temperature;
	volatile uint32_t sum;
	volatile uint32_t measure;
} serial_t;

void serial_init();
char read_humidity();
char read_temperature();
char read_sum();
char good();

/***************************************************************************
 * Pointer to actual components
 */
extern timer_t  *timer0;
extern uart_t   *uart0; 
extern gpio_t   *gpio0; 
extern i2c_t    *i2c0;
extern spi_t    *spi0; 
extern serial_t *serial0;
extern uint32_t *sram0; 

#endif // SPIKEHW_H
