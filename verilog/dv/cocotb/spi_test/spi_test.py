from caravel_cocotb.caravel_interfaces import test_configure, report_test
import cocotb

@cocotb.test()
@report_test
async def spi_test(dut):
    """Test SPI0 peripheral functionality"""
    caravelEnv = await test_configure(dut, timeout_cycles=1000000)
    
    cocotb.log.info(f"[TEST] Start spi_test")
    
    # Release CSB and wait for firmware configuration to complete
    await caravelEnv.release_csb()
    await caravelEnv.wait_mgmt_gpio(1)
    
    cocotb.log.info(f"[TEST] Firmware configuration complete")
    
    # Wait for SPI operations to complete
    await cocotb.triggers.ClockCycles(caravelEnv.clk, 5000)
    
    # Check SPI pin states
    spi_mosi = caravelEnv.monitor_gpio(1, 1).integer  # MOSI pin
    spi_csb = caravelEnv.monitor_gpio(2, 2).integer   # CSB pin
    spi_sclk = caravelEnv.monitor_gpio(3, 3).integer  # SCLK pin
    
    cocotb.log.info(f"[TEST] SPI pins - MOSI: {spi_mosi}, CSB: {spi_csb}, SCLK: {spi_sclk}")
    
    # Check for test completion pattern on GPIO
    gpio_pattern = caravelEnv.monitor_gpio(7, 0).integer
    cocotb.log.info(f"[TEST] GPIO pattern: 0x{gpio_pattern:02X}")
    
    if gpio_pattern == 0xF0:
        cocotb.log.info(f"[TEST] PASS - SPI test completion pattern detected")
    else:
        cocotb.log.warning(f"[TEST] WARNING - Expected completion pattern 0xF0, got 0x{gpio_pattern:02X}")
    
    # Verify CSB is deasserted (high) after transaction
    if spi_csb == 1:
        cocotb.log.info(f"[TEST] PASS - CSB properly deasserted after transaction")
    else:
        cocotb.log.error(f"[TEST] FAIL - CSB should be high after transaction, got {spi_csb}")
    
    cocotb.log.info(f"[TEST] End spi_test")