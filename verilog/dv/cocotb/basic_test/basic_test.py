from caravel_cocotb.caravel_interfaces import test_configure, report_test
import cocotb

@cocotb.test()
@report_test
async def basic_test(dut):
    """Basic connectivity test to verify system is working"""
    caravelEnv = await test_configure(dut, timeout_cycles=1000000)
    
    cocotb.log.info(f"[TEST] Start basic_test")
    
    # Release CSB and wait for firmware configuration to complete
    await caravelEnv.release_csb()
    await caravelEnv.wait_mgmt_gpio(1)
    
    cocotb.log.info(f"[TEST] Firmware configuration complete")
    
    # Wait a bit for the first pattern to be set
    await cocotb.triggers.ClockCycles(caravelEnv.clk, 100)
    
    # Read GPIO values and check for expected pattern
    gpio_value = caravelEnv.monitor_gpio(7, 0).integer
    cocotb.log.info(f"[TEST] GPIO[7:0] value: 0x{gpio_value:02X}")
    
    # We expect either 0xAA or 0x55 depending on timing
    if gpio_value == 0xAA or gpio_value == 0x55:
        cocotb.log.info(f"[TEST] PASS - GPIO pattern detected: 0x{gpio_value:02X}")
    else:
        cocotb.log.error(f"[TEST] FAIL - Unexpected GPIO pattern: 0x{gpio_value:02X}, expected 0xAA or 0x55")
    
    # Wait for pattern change
    await cocotb.triggers.ClockCycles(caravelEnv.clk, 2000)
    
    # Read GPIO values again
    gpio_value2 = caravelEnv.monitor_gpio(7, 0).integer
    cocotb.log.info(f"[TEST] GPIO[7:0] second value: 0x{gpio_value2:02X}")
    
    # Verify pattern changed
    if gpio_value2 != gpio_value:
        cocotb.log.info(f"[TEST] PASS - GPIO pattern changed from 0x{gpio_value:02X} to 0x{gpio_value2:02X}")
    else:
        cocotb.log.warning(f"[TEST] WARNING - GPIO pattern did not change")
    
    cocotb.log.info(f"[TEST] End basic_test")