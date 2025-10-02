#include <firmware_apis.h>

void main(){
    // Enable management gpio as output to use as indicator for finishing configuration
    ManagmentGpio_outputEnable();
    ManagmentGpio_write(0);
    
    // Disable housekeeping SPI to free GPIO pins
    enableHkSpi(0);
    
    // Configure all GPIOs as management standard output
    GPIOs_configureAll(GPIO_MODE_MGMT_STD_OUTPUT);
    GPIOs_loadConfigs();
    
    // Enable user interface for Wishbone access
    User_enableIF();
    
    // Signal configuration complete
    ManagmentGpio_write(1);
    
    // Write a test pattern to verify basic connectivity
    GPIOs_writeLow(0xAA);  // Pattern: 10101010
    
    // Small delay
    for(int i = 0; i < 1000; i++) {
        // Simple delay loop
    }
    
    // Change pattern
    GPIOs_writeLow(0x55);  // Pattern: 01010101
    
    return;
}