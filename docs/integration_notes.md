# Integration Notes

## Overview

This document provides technical details for integrating the multi-peripheral user project with the Caravel SoC, including timing constraints, simulation setup, and verification procedures.

## Clock and Reset Architecture

### Clock Domain
- **Primary Clock**: `wb_clk_i` (Wishbone clock from Caravel)
- **Frequency**: Target 25 MHz (40ns period)
- **Distribution**: Single clock domain for all peripherals
- **Clock Gating**: Not used - clock enables preferred for power management

### Reset Strategy
- **Reset Signal**: `wb_rst_i` (synchronous, active-high)
- **Reset Synchronizer**: Implemented at user project level
- **Reset Assertion**: All registers reset to known states
- **Reset Deassertion**: Synchronized to clock edge

## Bus Architecture

### Wishbone B4 Classic Protocol
- **Data Width**: 32 bits
- **Address Width**: 32 bits
- **Byte Enable**: 4 bits (`wbs_sel_i`)
- **Handshake**: `wbs_cyc_i`, `wbs_stb_i`, `wbs_ack_o`

### Address Decoding
```verilog
// Address decode for 6 peripherals using bits [19:16]
wire [2:0] peripheral_sel = wbs_adr_i[19:16];
wire [5:0] peripheral_stb;

assign peripheral_stb[0] = (peripheral_sel == 3'd0) & wbs_stb_i; // SPI0
assign peripheral_stb[1] = (peripheral_sel == 3'd1) & wbs_stb_i; // SPI1
assign peripheral_stb[2] = (peripheral_sel == 3'd2) & wbs_stb_i; // I2C
assign peripheral_stb[3] = (peripheral_sel == 3'd3) & wbs_stb_i; // GPIO
assign peripheral_stb[4] = (peripheral_sel == 3'd4) & wbs_stb_i; // SRAM
assign peripheral_stb[5] = (peripheral_sel == 3'd5) & wbs_stb_i; // PWM
```

### Bus Timing
- **Setup Time**: 2ns minimum
- **Hold Time**: 1ns minimum
- **Clock-to-Output**: 10ns maximum
- **Acknowledge Latency**: 1 clock cycle

## Power Architecture

### Power Domains
- **Core Power**: vccd1 (1.8V digital core)
- **Ground**: vssd1 (digital ground)
- **I/O Power**: vccd2 (3.3V I/O, if needed)

### Power Connections
```verilog
`ifdef USE_POWER_PINS
    .VPWR(vccd1),
    .VGND(vssd1),
`endif
```

## Interrupt Architecture

### Interrupt Sources
- **GPIO0 Edge Detect** → `user_irq[0]`
- **GPIO1 Edge Detect** → `user_irq[1]`
- **Combined Status** → `user_irq[2]`

### Interrupt Handling
- Level-triggered interrupts (active high)
- Software clearable via W1C registers
- Maskable at peripheral level

## Timing Constraints

### Clock Constraints
```tcl
create_clock -name wb_clk -period 40.0 [get_ports wb_clk_i]
set_clock_uncertainty 2.0 [get_clocks wb_clk]
```

### I/O Constraints
```tcl
set_input_delay -clock wb_clk 5.0 [get_ports wbs_*]
set_output_delay -clock wb_clk 5.0 [get_ports wbs_*]
```

### False Paths
```tcl
set_false_path -from [get_ports wb_rst_i]
```

## Simulation Setup

### RTL Simulation
```bash
# Setup Caravel-Cocotb environment
python verilog/dv/setup-cocotb.py /workspace/nativechips-demo

# Run individual tests
cd verilog/dv/cocotb
caravel_cocotb -t spi_test -tag rtl_sim

# Run test suite
caravel_cocotb -tl test_list.yaml
```

### Gate-Level Simulation
```bash
# Run with gate-level netlist
caravel_cocotb -t spi_test -tag gl_sim -sim GL
```

### Waveform Analysis
- **Format**: VCD
- **Location**: `sim/<tag>/<test>/waves.vcd`
- **Viewer**: GTKWave

## Verification Strategy

### Test Coverage
1. **Individual Peripheral Tests**
   - SPI master functionality
   - I2C master/slave operations
   - GPIO input/output and interrupts
   - SRAM read/write operations
   - PWM channel control

2. **Integration Tests**
   - Bus arbitration
   - Address decoding
   - Interrupt handling
   - Power-on reset sequence

3. **System Tests**
   - Multi-peripheral concurrent operation
   - Stress testing
   - Corner case scenarios

### Test Methodology
- **Framework**: Cocotb with PyUVM
- **Synchronization**: Management GPIO handshake
- **Self-Checking**: Automated pass/fail detection
- **Coverage**: Functional and code coverage metrics

## Synthesis Considerations

### Area Optimization
- **Target Utilization**: 70-80%
- **Die Area**: Minimum 400×400 µm²
- **Macro Placement**: Optimized for timing and congestion

### Timing Optimization
- **Setup Margin**: 10% minimum
- **Hold Margin**: 5% minimum
- **Clock Skew**: <5% of clock period

### Power Optimization
- **Clock Gating**: Peripheral-level enables
- **Operand Isolation**: Unused arithmetic units
- **Voltage Islands**: Single domain (vccd1/vssd1)

## Physical Design Notes

### Floorplanning
- **Aspect Ratio**: 1:1 preferred
- **Core Utilization**: 70-80%
- **Macro Placement**: Manual placement for critical paths

### Routing
- **Metal Layers**: M1-M5 available
- **Via Rules**: Standard via insertion
- **Antenna Rules**: Diode insertion as needed

### DRC/LVS
- **Technology**: SKY130A
- **Standard Cells**: sky130_fd_sc_hd
- **Design Rules**: SKY130 PDK v1.0.0+

## Debug and Bring-up

### Debug Signals
- **Logic Analyzer**: 128 bits available via `la_*` ports
- **UART Debug**: Management SoC UART for debug output
- **GPIO Status**: LED indicators for system status

### Bring-up Sequence
1. Power-on reset verification
2. Clock distribution check
3. Bus connectivity test
4. Individual peripheral bring-up
5. System integration test

## Known Issues and Workarounds

### Issue 1: I2C Open-Drain Implementation
- **Problem**: Standard cells don't support true open-drain
- **Workaround**: Use tri-state buffers with external pull-ups

### Issue 2: Clock Domain Crossing
- **Problem**: Single clock domain may limit performance
- **Workaround**: Use clock enables instead of multiple domains

## References

- [Caravel Documentation](https://caravel-harness.readthedocs.io/)
- [Wishbone B4 Specification](https://opencores.org/howto/wishbone)
- [SKY130 PDK Documentation](https://skywater-pdk.readthedocs.io/)
- [OpenLane Documentation](https://openlane.readthedocs.io/)