#include <firmware_apis.h>
#include "CF_SPI.h"

// SPI0 base address (from address map)
#define SPI0_BASE 0x30000000

void main(){
    // Enable management gpio as output to use as indicator for finishing configuration
    ManagmentGpio_outputEnable();
    ManagmentGpio_write(0);
    
    // Disable housekeeping SPI to free GPIO pins
    enableHkSpi(0);
    
    // Configure SPI0 GPIO pins: MISO=0 (input), MOSI=1, CSB=2, SCLK=3 (outputs)
    GPIOs_configure(0, GPIO_MODE_USER_STD_INPUT_PULLUP);   // MISO
    GPIOs_configure(1, GPIO_MODE_USER_STD_OUTPUT);         // MOSI
    GPIOs_configure(2, GPIO_MODE_USER_STD_OUTPUT);         // CSB
    GPIOs_configure(3, GPIO_MODE_USER_STD_OUTPUT);         // SCLK
    
    // Configure remaining GPIOs as management outputs for monitoring
    for(int i = 4; i < 38; i++) {
        GPIOs_configure(i, GPIO_MODE_MGMT_STD_OUTPUT);
    }
    
    GPIOs_loadConfigs();
    
    // Enable user interface for Wishbone access
    User_enableIF();
    
    // Signal configuration complete
    ManagmentGpio_write(1);
    
    // Initialize SPI0
    CF_SPI_setGclkEnable(SPI0_BASE, 1);  // Enable clock
    CF_SPI_enable(SPI0_BASE);            // Enable SPI
    CF_SPI_enableRx(SPI0_BASE);          // Enable RX
    CF_SPI_setPrescaler(SPI0_BASE, 8);   // Set prescaler for reasonable speed
    
    // Test SPI communication
    CF_SPI_assertCs(SPI0_BASE);          // Assert chip select
    
    // Send test data
    CF_SPI_writeData(SPI0_BASE, 0xAA);   // Send 0xAA
    CF_SPI_waitTxFifoEmpty(SPI0_BASE);   // Wait for transmission
    
    CF_SPI_writeData(SPI0_BASE, 0x55);   // Send 0x55
    CF_SPI_waitTxFifoEmpty(SPI0_BASE);   // Wait for transmission
    
    CF_SPI_deassertCs(SPI0_BASE);        // Deassert chip select
    
    // Signal test pattern on GPIO for verification
    GPIOs_writeLow(0xF0);  // Pattern to indicate SPI test completion
    
    return;
}