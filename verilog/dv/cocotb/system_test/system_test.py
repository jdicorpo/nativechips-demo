from caravel_cocotb.caravel_interfaces import test_configure, report_test
import cocotb

@cocotb.test()
@report_test
async def system_test(dut):
    """Comprehensive system integration test"""
    caravelEnv = await test_configure(dut, timeout_cycles=2000000)
    
    cocotb.log.info(f"[TEST] Start system_test")
    
    # Release CSB and wait for firmware configuration to complete
    await caravelEnv.release_csb()
    await caravelEnv.wait_mgmt_gpio(1)
    
    cocotb.log.info(f"[TEST] Firmware configuration complete")
    
    # Test sequence tracking
    test_phases = ["SPI0", "SPI1", "SRAM", "PWM", "Complete"]
    expected_patterns = [0x01, 0x02, 0x04, 0x08, 0xFF]
    
    for i, (phase, expected) in enumerate(zip(test_phases, expected_patterns)):
        # Wait for test phase to complete
        await cocotb.triggers.ClockCycles(caravelEnv.clk, 2000)
        
        # Check GPIO pattern
        gpio_pattern = caravelEnv.monitor_gpio(7, 0).integer
        cocotb.log.info(f"[TEST] {phase} phase - GPIO pattern: 0x{gpio_pattern:02X}")
        
        if gpio_pattern == expected:
            cocotb.log.info(f"[TEST] PASS - {phase} test completed successfully")
        else:
            cocotb.log.warning(f"[TEST] WARNING - {phase} test pattern mismatch. Expected 0x{expected:02X}, got 0x{gpio_pattern:02X}")
    
    # Check individual peripheral pin states
    await cocotb.triggers.ClockCycles(caravelEnv.clk, 1000)
    
    # SPI0 pins
    spi0_csb = caravelEnv.monitor_gpio(2, 2).integer
    spi0_sclk = caravelEnv.monitor_gpio(3, 3).integer
    
    # SPI1 pins  
    spi1_csb = caravelEnv.monitor_gpio(6, 6).integer
    spi1_sclk = caravelEnv.monitor_gpio(7, 7).integer
    
    # PWM pins
    pwm0a = caravelEnv.monitor_gpio(18, 18).integer
    pwm0b = caravelEnv.monitor_gpio(19, 19).integer
    
    cocotb.log.info(f"[TEST] Final pin states:")
    cocotb.log.info(f"[TEST]   SPI0 - CSB: {spi0_csb}, SCLK: {spi0_sclk}")
    cocotb.log.info(f"[TEST]   SPI1 - CSB: {spi1_csb}, SCLK: {spi1_sclk}")
    cocotb.log.info(f"[TEST]   PWM0 - A: {pwm0a}, B: {pwm0b}")
    
    # Verify CSB pins are deasserted (high) after transactions
    if spi0_csb == 1 and spi1_csb == 1:
        cocotb.log.info(f"[TEST] PASS - Both SPI CSB pins properly deasserted")
    else:
        cocotb.log.error(f"[TEST] FAIL - SPI CSB pins not properly deasserted")
    
    # Final verification
    final_pattern = caravelEnv.monitor_gpio(7, 0).integer
    if final_pattern == 0xFF:
        cocotb.log.info(f"[TEST] PASS - System integration test completed successfully")
    else:
        cocotb.log.error(f"[TEST] FAIL - Final completion pattern not detected. Got 0x{final_pattern:02X}")
    
    cocotb.log.info(f"[TEST] End system_test")