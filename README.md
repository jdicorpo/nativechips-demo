# Caravel User Project - Multi-Peripheral SoC Integration

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/chipfoundry/caravel_user_project/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/chipfoundry/caravel_user_project/actions/workflows/user_project_ci.yml)

## Project Overview

This project integrates a custom user project into the Caravel SoC with multiple peripherals connected via Wishbone B4 (classic) bus protocol.

## Initial User Requirements

**Original User Prompt:**
> Integrate a custom user project into the Caravel SoC with the following peripherals: (1) 2× SPI masters at base 0x3000_0000. (2) 1× I2C controller at 0x3000_1000. (3) 2× GPIO lines with edge-detect interrupts at 0x3000_2000 and 16k sram and 16 channel pwm.

## Peripheral Specifications

### Address Map
- **Base Address**: 0x3000_0000 (User project address space)
- **Window Size**: 64 KB (0x10000) per peripheral

| Peripheral | Base Address | Address Range | Description |
|------------|--------------|---------------|-------------|
| SPI Master 0 | 0x3000_0000 | 0x3000_0000 - 0x3000_FFFF | First SPI master controller |
| SPI Master 1 | 0x3001_0000 | 0x3001_0000 - 0x3001_FFFF | Second SPI master controller |
| I2C Controller | 0x3002_0000 | 0x3002_0000 - 0x3002_FFFF | I2C master/slave controller |
| GPIO Controller | 0x3003_0000 | 0x3003_0000 - 0x3003_FFFF | 2× GPIO with edge-detect interrupts |
| 16K SRAM | 0x3004_0000 | 0x3004_0000 - 0x3004_FFFF | 16KB SRAM with Wishbone interface |
| PWM Controller | 0x3005_0000 | 0x3005_0000 - 0x3005_FFFF | 16-channel PWM controller |

### Peripheral Requirements
1. **2× SPI Masters**: Full-duplex SPI master controllers with configurable clock dividers
2. **1× I2C Controller**: I2C master/slave with standard and fast mode support
3. **2× GPIO Lines**: GPIO controller with edge-detect interrupt capability
4. **16K SRAM**: Memory block with Wishbone interface for data storage
5. **16-Channel PWM**: Multi-channel PWM generator with independent duty cycle control

### Interrupt Mapping
- GPIO edge-detect interrupts mapped to `user_irq[2:0]`
- Additional interrupt sources will be OR'ed appropriately

## Design Approach

### Architecture
- **Bus Protocol**: Wishbone B4 (classic) 32-bit slave interface
- **Clock Domain**: Single clock domain (wb_clk_i)
- **Reset Strategy**: Synchronous active-high reset (wb_rst_i)
- **Address Decoding**: 64KB windows using address bits [19:16]

### IP Core Integration
- Utilize existing verified IP cores from `/workspace/ip/` directory
- Integrate Wishbone wrappers for each peripheral
- Implement centralized address decoding and bus multiplexing

### Power Strategy
- Connect to vccd1/vssd1 power rails
- Proper power pin mapping for Caravel integration

## Project Structure

```
/workspace/nativechips-demo/
├── rtl/                          # RTL source files
│   ├── user_project.v           # Main user project with bus decoding
│   └── user_project_wrapper.v   # Caravel wrapper module
├── verilog/
│   ├── rtl/                     # Verilog RTL files
│   ├── dv/cocotb/              # Cocotb verification tests
│   └── includes/               # Include files for simulation
├── docs/                        # Project documentation
│   ├── register_map.md         # Register maps for all peripherals
│   ├── pad_map.md             # Pad assignment documentation
│   └── integration_notes.md    # Integration and timing notes
├── openlane/                   # OpenLane configuration
│   ├── user_project/          # User project macro config
│   └── user_project_wrapper/  # Wrapper hardening config
└── ip/                        # Linked IP cores
```

## Development Milestones

- [x] Project setup and documentation initialization
- [x] IP core integration and Wishbone wrapper development
- [x] User project RTL implementation with address decoding
- [x] User project wrapper creation
- [ ] Cocotb verification test development
- [ ] RTL verification and validation
- [ ] OpenLane synthesis and place & route
- [ ] Final integration and sign-off

## Current Status

✅ **RTL Development Complete**
- Successfully integrated all required peripherals using pre-verified IP cores
- Created user_project.v with proper Wishbone bus decoding
- Implemented user_project_wrapper.v for Caravel integration
- Address map implemented as specified with 64KB windows per peripheral

## Next Steps

1. Set up Caravel-cocotb verification environment
2. Create individual peripheral tests using provided firmware APIs
3. Develop system integration test
4. Run verification tests and ensure all pass
5. Proceed to OpenLane synthesis and PnR

---

*This document will be updated as the project progresses through each milestone.*
