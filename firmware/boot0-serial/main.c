/**
 * Primitive first stage bootloader 
 *
 *
 */
#include "soc-hw.h"

/* prototypes */
uint32_t read_uint32()
{
	uint32_t val = 0, i;

    for (i = 0; i < 4; i++) {
        val <<= 8;
        val += (uint8_t)uart_getchar();
    }

    return val;
}

int main(int argc, char **argv)
{
	int8_t  *p;
	uint8_t  c;

	// Initialize UART
	uart_init();

	c = '*'; // print msg on first iteration
	for(;;) {
		uint32_t start, size; 
		c = uart_putchar('b');
	}
}

