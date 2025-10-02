# Register Map Documentation

## Overview

This document describes the register maps for all peripherals integrated into the Caravel user project. Each peripheral occupies a 64KB address window starting from base address 0x3000_0000.

## Address Decoding

- **Base Address**: 0x3000_0000
- **Window Size**: 64KB (0x10000) per peripheral
- **Decode Bits**: Address bits [19:16] for peripheral selection

## Peripheral Register Maps

### SPI Master 0 (Base: 0x3000_0000)

| Offset | Register Name | Access | Reset Value | Description |
|--------|---------------|--------|-------------|-------------|
| 0x00   | CTRL          | RW     | 0x00000000  | Control register |
| 0x04   | STATUS        | RO     | 0x00000001  | Status register |
| 0x08   | DATA          | RW     | 0x00000000  | Data register |
| 0x0C   | PRESCALER     | RW     | 0x00000002  | Clock prescaler |

### SPI Master 1 (Base: 0x3001_0000)

| Offset | Register Name | Access | Reset Value | Description |
|--------|---------------|--------|-------------|-------------|
| 0x00   | CTRL          | RW     | 0x00000000  | Control register |
| 0x04   | STATUS        | RO     | 0x00000001  | Status register |
| 0x08   | DATA          | RW     | 0x00000000  | Data register |
| 0x0C   | PRESCALER     | RW     | 0x00000002  | Clock prescaler |

### I2C Controller (Base: 0x3002_0000)

| Offset | Register Name | Access | Reset Value | Description |
|--------|---------------|--------|-------------|-------------|
| 0x00   | CTRL          | RW     | 0x00000000  | Control register |
| 0x04   | STATUS        | RO     | 0x00000000  | Status register |
| 0x08   | DATA          | RW     | 0x00000000  | Data register |
| 0x0C   | ADDR          | RW     | 0x00000000  | Address register |

### GPIO Controller (Base: 0x3003_0000)

| Offset | Register Name | Access | Reset Value | Description |
|--------|---------------|--------|-------------|-------------|
| 0x00   | DATA          | RW     | 0x00000000  | GPIO data register |
| 0x04   | DIR           | RW     | 0x00000000  | Direction register |
| 0x08   | IRQ_EN        | RW     | 0x00000000  | Interrupt enable |
| 0x0C   | IRQ_STATUS    | W1C    | 0x00000000  | Interrupt status |

### 16K SRAM (Base: 0x3004_0000)

| Address Range | Access | Description |
|---------------|--------|-------------|
| 0x3004_0000 - 0x3007_FFFF | RW | 16KB SRAM data space |

### PWM Controller (Base: 0x3005_0000)

| Offset | Register Name | Access | Reset Value | Description |
|--------|---------------|--------|-------------|-------------|
| 0x00   | CTRL          | RW     | 0x00000000  | Global control |
| 0x04   | PRESCALER     | RW     | 0x00000001  | Clock prescaler |
| 0x10-0x4C | CH0-15_DUTY | RW     | 0x00000000  | Channel duty cycles |

## Register Field Descriptions

### SPI Control Register (CTRL)
- Bit [0]: Enable (1=enabled, 0=disabled)
- Bit [1]: CPOL (clock polarity)
- Bit [2]: CPHA (clock phase)
- Bit [7:4]: Reserved
- Bit [15:8]: Transfer length
- Bit [31:16]: Reserved

### I2C Control Register (CTRL)
- Bit [0]: Enable (1=enabled, 0=disabled)
- Bit [1]: Master mode (1=master, 0=slave)
- Bit [2]: Start condition
- Bit [3]: Stop condition
- Bit [7:4]: Reserved
- Bit [31:8]: Reserved

### GPIO Direction Register (DIR)
- Bit [0]: GPIO0 direction (1=output, 0=input)
- Bit [1]: GPIO1 direction (1=output, 0=input)
- Bit [31:2]: Reserved

### PWM Channel Duty Cycle (CHx_DUTY)
- Bit [15:0]: Duty cycle value
- Bit [31:16]: Reserved

## Interrupt Sources

### GPIO Interrupts
- GPIO0 edge detect → user_irq[0]
- GPIO1 edge detect → user_irq[1]
- Combined GPIO status → user_irq[2]

## Notes

- All registers are 32-bit aligned
- Unused register bits read as 0
- Write-one-to-clear (W1C) registers clear the bit when 1 is written
- Reserved bits should not be written and will read as 0