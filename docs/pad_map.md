# Pad Mapping Documentation

## Overview

This document describes the default pad assignments for the multi-peripheral user project. The Caravel chip provides 38 user I/O pads (mprj_io[37:0]) for user project connectivity.

## Default Pad Assignments

### SPI Master 0 (Pads 5-8)
| Pad | Signal Name | Direction | Description |
|-----|-------------|-----------|-------------|
| 5   | spi0_sck    | Output    | SPI clock |
| 6   | spi0_mosi   | Output    | Master out, slave in |
| 7   | spi0_miso   | Input     | Master in, slave out |
| 8   | spi0_cs_n   | Output    | Chip select (active low) |

### SPI Master 1 (Pads 9-12)
| Pad | Signal Name | Direction | Description |
|-----|-------------|-----------|-------------|
| 9   | spi1_sck    | Output    | SPI clock |
| 10  | spi1_mosi   | Output    | Master out, slave in |
| 11  | spi1_miso   | Input     | Master in, slave out |
| 12  | spi1_cs_n   | Output    | Chip select (active low) |

### I2C Controller (Pads 13-14)
| Pad | Signal Name | Direction | Description |
|-----|-------------|-----------|-------------|
| 13  | i2c_scl     | Bidir     | I2C clock (open-drain) |
| 14  | i2c_sda     | Bidir     | I2C data (open-drain) |

### GPIO Controller (Pads 15-16)
| Pad | Signal Name | Direction | Description |
|-----|-------------|-----------|-------------|
| 15  | gpio0       | Bidir     | GPIO line 0 with interrupt |
| 16  | gpio1       | Bidir     | GPIO line 1 with interrupt |

### PWM Controller (Pads 17-32)
| Pad | Signal Name | Direction | Description |
|-----|-------------|-----------|-------------|
| 17  | pwm_ch0     | Output    | PWM channel 0 |
| 18  | pwm_ch1     | Output    | PWM channel 1 |
| 19  | pwm_ch2     | Output    | PWM channel 2 |
| 20  | pwm_ch3     | Output    | PWM channel 3 |
| 21  | pwm_ch4     | Output    | PWM channel 4 |
| 22  | pwm_ch5     | Output    | PWM channel 5 |
| 23  | pwm_ch6     | Output    | PWM channel 6 |
| 24  | pwm_ch7     | Output    | PWM channel 7 |
| 25  | pwm_ch8     | Output    | PWM channel 8 |
| 26  | pwm_ch9     | Output    | PWM channel 9 |
| 27  | pwm_ch10    | Output    | PWM channel 10 |
| 28  | pwm_ch11    | Output    | PWM channel 11 |
| 29  | pwm_ch12    | Output    | PWM channel 12 |
| 30  | pwm_ch13    | Output    | PWM channel 13 |
| 31  | pwm_ch14    | Output    | PWM channel 14 |
| 32  | pwm_ch15    | Output    | PWM channel 15 |

### Reserved/Unused Pads
| Pad Range | Status | Description |
|-----------|--------|-------------|
| 0-4       | Reserved | Caravel management interface |
| 33-37     | Unused | Available for future expansion |

## Pad Configuration

### Output Pads (Push-Pull)
- SPI clock and data signals
- PWM output channels
- Configuration: `io_oeb = 0`, drive `io_out`

### Input Pads
- SPI MISO signals
- Configuration: `io_oeb = 1`, read `io_in`

### Bidirectional Pads (Open-Drain)
- I2C SCL and SDA (require external pull-ups)
- GPIO lines
- Configuration: Drive 0 or release with `io_oeb = 1`

## Pin Order Configuration

The pin placement follows the standard Caravel pin ordering:

```
#BUS_SORT
#S
wb_.*
wbs_.*
la_.*
irq.*

#E
io_in\[5\] through io_in\[32\]
io_out\[5\] through io_out\[32\]
io_oeb\[5\] through io_oeb\[32\]
```

## Customization

To modify pad assignments:

1. Update the pad connections in `user_project_wrapper.v`
2. Modify the pin order configuration in `openlane/user_project_wrapper/pin_order.cfg`
3. Update this documentation
4. Regenerate the OpenLane configuration

## Electrical Characteristics

- **Supply Voltage**: 1.8V (vccd1/vssd1)
- **I/O Standard**: LVCMOS 1.8V
- **Drive Strength**: Configurable per pad
- **Pull-up/Pull-down**: External components required for I2C

## Notes

- Pads 0-4 are reserved for Caravel management interface
- I2C signals require external pull-up resistors (typically 4.7kΩ)
- All unused pads should be configured as inputs with pull-downs
- PWM channels can be individually enabled/disabled via software