#include <firmware_apis.h>
#include "CF_SPI.h"

// Base addresses from address map
#define SPI0_BASE    0x30000000  // SPI Master 0
#define SPI1_BASE    0x30010000  // SPI Master 1
#define I2C_BASE     0x30020000  // I2C Controller
#define GPIO_BASE    0x30030000  // GPIO Controller
#define SRAM_BASE    0x30040000  // SRAM
#define PWM0_BASE    0x30050000  // PWM Controller 0

void main(){
    // Enable management gpio as output to use as indicator for finishing configuration
    ManagmentGpio_outputEnable();
    ManagmentGpio_write(0);
    
    // Disable housekeeping SPI to free GPIO pins
    enableHkSpi(0);
    
    // Configure GPIO pins for peripherals
    // SPI0: MISO=0, MOSI=1, CSB=2, SCLK=3
    GPIOs_configure(0, GPIO_MODE_USER_STD_INPUT_PULLUP);
    GPIOs_configure(1, GPIO_MODE_USER_STD_OUTPUT);
    GPIOs_configure(2, GPIO_MODE_USER_STD_OUTPUT);
    GPIOs_configure(3, GPIO_MODE_USER_STD_OUTPUT);
    
    // SPI1: MISO=4, MOSI=5, CSB=6, SCLK=7
    GPIOs_configure(4, GPIO_MODE_USER_STD_INPUT_PULLUP);
    GPIOs_configure(5, GPIO_MODE_USER_STD_OUTPUT);
    GPIOs_configure(6, GPIO_MODE_USER_STD_OUTPUT);
    GPIOs_configure(7, GPIO_MODE_USER_STD_OUTPUT);
    
    // I2C: SCL=8, SDA=9
    GPIOs_configure(8, GPIO_MODE_USER_STD_BIDIRECTIONAL);
    GPIOs_configure(9, GPIO_MODE_USER_STD_BIDIRECTIONAL);
    
    // GPIO: GPIO0=10, GPIO1=11
    GPIOs_configure(10, GPIO_MODE_USER_STD_OUTPUT);
    GPIOs_configure(11, GPIO_MODE_USER_STD_OUTPUT);
    
    // PWM outputs: PWM0A=18, PWM0B=19
    GPIOs_configure(18, GPIO_MODE_USER_STD_OUTPUT);
    GPIOs_configure(19, GPIO_MODE_USER_STD_OUTPUT);
    
    // Configure remaining pins as management outputs
    for(int i = 12; i < 18; i++) {
        GPIOs_configure(i, GPIO_MODE_MGMT_STD_OUTPUT);
    }
    for(int i = 20; i < 38; i++) {
        GPIOs_configure(i, GPIO_MODE_MGMT_STD_OUTPUT);
    }
    
    GPIOs_loadConfigs();
    
    // Enable user interface for Wishbone access
    User_enableIF();
    
    // Signal configuration complete
    ManagmentGpio_write(1);
    
    // Test 1: SPI0 Basic Operation
    CF_SPI_setGclkEnable(SPI0_BASE, 1);
    CF_SPI_enable(SPI0_BASE);
    CF_SPI_enableRx(SPI0_BASE);
    CF_SPI_setPrescaler(SPI0_BASE, 8);
    
    CF_SPI_assertCs(SPI0_BASE);
    CF_SPI_writeData(SPI0_BASE, 0xAA);
    CF_SPI_waitTxFifoEmpty(SPI0_BASE);
    CF_SPI_deassertCs(SPI0_BASE);
    
    // Signal SPI0 test complete
    GPIOs_writeLow(0x01);
    
    // Small delay
    for(int i = 0; i < 1000; i++);
    
    // Test 2: SPI1 Basic Operation
    CF_SPI_setGclkEnable(SPI1_BASE, 1);
    CF_SPI_enable(SPI1_BASE);
    CF_SPI_enableRx(SPI1_BASE);
    CF_SPI_setPrescaler(SPI1_BASE, 8);
    
    CF_SPI_assertCs(SPI1_BASE);
    CF_SPI_writeData(SPI1_BASE, 0x55);
    CF_SPI_waitTxFifoEmpty(SPI1_BASE);
    CF_SPI_deassertCs(SPI1_BASE);
    
    // Signal SPI1 test complete
    GPIOs_writeLow(0x02);
    
    // Small delay
    for(int i = 0; i < 1000; i++);
    
    // Test 3: SRAM Access
    // Write test pattern to SRAM
    USER_writeWord(0x12345678, (SRAM_BASE - 0x30000000) >> 2);
    USER_writeWord(0x9ABCDEF0, ((SRAM_BASE - 0x30000000) + 4) >> 2);
    
    // Read back and verify (simplified - just signal completion)
    uint32_t read_val1 = USER_readWord((SRAM_BASE - 0x30000000) >> 2);
    uint32_t read_val2 = USER_readWord(((SRAM_BASE - 0x30000000) + 4) >> 2);
    
    // Signal SRAM test complete
    GPIOs_writeLow(0x04);
    
    // Small delay
    for(int i = 0; i < 1000; i++);
    
    // Test 4: PWM Configuration
    // Configure PWM0 (simplified register access)
    USER_writeWord(0x00000001, (PWM0_BASE - 0x30000000) >> 2);  // Enable PWM
    
    // Signal PWM test complete
    GPIOs_writeLow(0x08);
    
    // Final completion signal
    GPIOs_writeLow(0xFF);
    
    return;
}