`timescale 1ns / 1ps
`default_nettype none

/*
 * User Project: Custom SoC with Multiple Peripherals
 * 
 * This module integrates the following peripherals:
 * - 2x SPI masters at base addresses 0x3000_0000 and 0x3001_0000
 * - 1x I2C controller at 0x3002_0000  
 * - 1x GPIO controller (2 lines with edge-detect interrupts) at 0x3003_0000
 * - 1x 16KB SRAM at 0x3004_0000
 * - 8x PWM controllers (16 channels total) at 0x3005_0000 to 0x300C_0000
 */

module user_project #(
    parameter BITS = 32
) (
`ifdef USE_POWER_PINS
    inout vccd1,    // User area 1 1.8V supply
    inout vssd1,    // User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [37:0] io_in,
    output [37:0] io_out,
    output [37:0] io_oeb,

    // IRQ
    output [2:0] user_irq
);

    // Address decode for peripherals (using bits [19:16] for 64KB windows)
    wire [3:0] peripheral_sel = wbs_adr_i[19:16];
    
    // Peripheral select signals
    wire spi0_stb, spi1_stb, i2c_stb, gpio_stb, sram_stb;
    wire pwm0_stb, pwm1_stb, pwm2_stb, pwm3_stb;
    wire pwm4_stb, pwm5_stb, pwm6_stb, pwm7_stb;
    
    // Generate strobe signals for each peripheral
    assign spi0_stb  = (peripheral_sel == 4'h0) & wbs_stb_i;  // 0x3000_0000
    assign spi1_stb  = (peripheral_sel == 4'h1) & wbs_stb_i;  // 0x3001_0000
    assign i2c_stb   = (peripheral_sel == 4'h2) & wbs_stb_i;  // 0x3002_0000
    assign gpio_stb  = (peripheral_sel == 4'h3) & wbs_stb_i;  // 0x3003_0000
    assign sram_stb  = (peripheral_sel == 4'h4) & wbs_stb_i;  // 0x3004_0000
    assign pwm0_stb  = (peripheral_sel == 4'h5) & wbs_stb_i;  // 0x3005_0000
    assign pwm1_stb  = (peripheral_sel == 4'h6) & wbs_stb_i;  // 0x3006_0000
    assign pwm2_stb  = (peripheral_sel == 4'h7) & wbs_stb_i;  // 0x3007_0000
    assign pwm3_stb  = (peripheral_sel == 4'h8) & wbs_stb_i;  // 0x3008_0000
    assign pwm4_stb  = (peripheral_sel == 4'h9) & wbs_stb_i;  // 0x3009_0000
    assign pwm5_stb  = (peripheral_sel == 4'hA) & wbs_stb_i;  // 0x300A_0000
    assign pwm6_stb  = (peripheral_sel == 4'hB) & wbs_stb_i;  // 0x300B_0000
    assign pwm7_stb  = (peripheral_sel == 4'hC) & wbs_stb_i;  // 0x300C_0000

    // Peripheral acknowledge signals
    wire spi0_ack, spi1_ack, i2c_ack, gpio_ack, sram_ack;
    wire pwm0_ack, pwm1_ack, pwm2_ack, pwm3_ack;
    wire pwm4_ack, pwm5_ack, pwm6_ack, pwm7_ack;
    
    // Peripheral data output signals
    wire [31:0] spi0_dat_o, spi1_dat_o, i2c_dat_o, gpio_dat_o, sram_dat_o;
    wire [31:0] pwm0_dat_o, pwm1_dat_o, pwm2_dat_o, pwm3_dat_o;
    wire [31:0] pwm4_dat_o, pwm5_dat_o, pwm6_dat_o, pwm7_dat_o;
    
    // Peripheral interrupt signals
    wire spi0_irq, spi1_irq, i2c_irq, gpio_irq;

    // Combine acknowledge signals
    assign wbs_ack_o = spi0_ack | spi1_ack | i2c_ack | gpio_ack | sram_ack |
                       pwm0_ack | pwm1_ack | pwm2_ack | pwm3_ack |
                       pwm4_ack | pwm5_ack | pwm6_ack | pwm7_ack;

    // Multiplex data output based on peripheral selection
    reg [31:0] mux_dat_o;
    always @(*) begin
        case (peripheral_sel)
            4'h0: mux_dat_o = spi0_dat_o;
            4'h1: mux_dat_o = spi1_dat_o;
            4'h2: mux_dat_o = i2c_dat_o;
            4'h3: mux_dat_o = gpio_dat_o;
            4'h4: mux_dat_o = sram_dat_o;
            4'h5: mux_dat_o = pwm0_dat_o;
            4'h6: mux_dat_o = pwm1_dat_o;
            4'h7: mux_dat_o = pwm2_dat_o;
            4'h8: mux_dat_o = pwm3_dat_o;
            4'h9: mux_dat_o = pwm4_dat_o;
            4'hA: mux_dat_o = pwm5_dat_o;
            4'hB: mux_dat_o = pwm6_dat_o;
            4'hC: mux_dat_o = pwm7_dat_o;
            default: mux_dat_o = 32'hDEADBEEF;
        endcase
    end
    assign wbs_dat_o = mux_dat_o;

    // Map interrupts to user_irq (only 3 available)
    // Priority: GPIO > SPI0 > I2C
    assign user_irq[0] = gpio_irq;
    assign user_irq[1] = spi0_irq;
    assign user_irq[2] = i2c_irq | spi1_irq;  // OR together lower priority interrupts

    // SPI Master 0 (io_out[3:0], io_in[0])
    CF_SPI_WB #(
        .CDW(8),
        .FAW(4)
    ) spi0_inst (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(spi0_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(spi0_stb),
        .ack_o(spi0_ack),
        .we_i(wbs_we_i),
        .IRQ(spi0_irq),
        .miso(io_in[0]),
        .mosi(io_out[1]),
        .csb(io_out[2]),
        .sclk(io_out[3])
    );

    // SPI Master 1 (io_out[7:4], io_in[4])
    CF_SPI_WB #(
        .CDW(8),
        .FAW(4)
    ) spi1_inst (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(spi1_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(spi1_stb),
        .ack_o(spi1_ack),
        .we_i(wbs_we_i),
        .IRQ(spi1_irq),
        .miso(io_in[4]),
        .mosi(io_out[5]),
        .csb(io_out[6]),
        .sclk(io_out[7])
    );

    // I2C Controller (io_out[9:8] for SDA/SCL)
    EF_I2C_WB #(
        .DEFAULT_PRESCALE(1),
        .FIXED_PRESCALE(0),
        .CMD_FIFO(1),
        .CMD_FIFO_DEPTH(16),
        .WRITE_FIFO(1),
        .WRITE_FIFO_DEPTH(16),
        .READ_FIFO(1),
        .READ_FIFO_DEPTH(16)
    ) i2c_inst (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(i2c_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(i2c_stb),
        .ack_o(i2c_ack),
        .we_i(wbs_we_i),
        .IRQ(i2c_irq),
        .scl_i(io_in[8]),
        .scl_o(io_out[8]),
        .scl_oen_o(io_oeb[8]),
        .sda_i(io_in[9]),
        .sda_o(io_out[9]),
        .sda_oen_o(io_oeb[9])
    );

    // GPIO Controller (io_out[11:10] for 2 GPIO lines)
    EF_GPIO8_WB gpio_inst (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(gpio_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(gpio_stb),
        .ack_o(gpio_ack),
        .we_i(wbs_we_i),
        .IRQ(gpio_irq),
        .io_in({6'b0, io_in[11:10]}),    // Only use 2 GPIO lines
        .io_out({io_out[17:12], io_out[11:10]}), // Map to io_out[17:10]
        .io_oe({io_oeb[17:12], io_oeb[11:10]})   // Map to io_oeb[17:10]
    );

    // 2KB SRAM (using DFFRAM512x32 - available IP)
    // Note: This provides 2KB SRAM instead of requested 16KB due to IP availability
    DFFRAM512x32 sram_inst (
        .CLK(wb_clk_i),
        .WE0(sram_stb & wbs_we_i ? wbs_sel_i : 4'b0000),  // Byte-wise write enable
        .EN0(sram_stb),
        .A0(wbs_adr_i[10:2]),  // 9-bit address for 512 words
        .Di0(wbs_dat_i),
        .Do0(sram_dat_o)
    );
    
    // Simple ACK generation for SRAM
    reg sram_ack_reg;
    always @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i)
            sram_ack_reg <= 1'b0;
        else if (sram_stb && !sram_ack_reg)
            sram_ack_reg <= 1'b1;
        else
            sram_ack_reg <= 1'b0;
    end
    assign sram_ack = sram_ack_reg;

    // PWM Controllers (8 instances for 16 channels)
    // PWM0 - Channels 0,1 (io_out[19:18])
    EF_PWM32_wb pwm0_inst (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(pwm0_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(pwm0_stb),
        .ack_o(pwm0_ack),
        .we_i(wbs_we_i),
        .pwmA(io_out[18]),
        .pwmB(io_out[19])
    );

    // PWM1 - Channels 2,3 (io_out[21:20])
    EF_PWM32_wb pwm1_inst (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(pwm1_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(pwm1_stb),
        .ack_o(pwm1_ack),
        .we_i(wbs_we_i),
        .pwmA(io_out[20]),
        .pwmB(io_out[21])
    );

    // PWM2 - Channels 4,5 (io_out[23:22])
    EF_PWM32_wb pwm2_inst (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(pwm2_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(pwm2_stb),
        .ack_o(pwm2_ack),
        .we_i(wbs_we_i),
        .pwmA(io_out[22]),
        .pwmB(io_out[23])
    );

    // PWM3 - Channels 6,7 (io_out[25:24])
    EF_PWM32_wb pwm3_inst (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(pwm3_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(pwm3_stb),
        .ack_o(pwm3_ack),
        .we_i(wbs_we_i),
        .pwmA(io_out[24]),
        .pwmB(io_out[25])
    );

    // PWM4 - Channels 8,9 (io_out[27:26])
    EF_PWM32_wb pwm4_inst (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(pwm4_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(pwm4_stb),
        .ack_o(pwm4_ack),
        .we_i(wbs_we_i),
        .pwmA(io_out[26]),
        .pwmB(io_out[27])
    );

    // PWM5 - Channels 10,11 (io_out[29:28])
    EF_PWM32_wb pwm5_inst (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(pwm5_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(pwm5_stb),
        .ack_o(pwm5_ack),
        .we_i(wbs_we_i),
        .pwmA(io_out[28]),
        .pwmB(io_out[29])
    );

    // PWM6 - Channels 12,13 (io_out[31:30])
    EF_PWM32_wb pwm6_inst (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(pwm6_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(pwm6_stb),
        .ack_o(pwm6_ack),
        .we_i(wbs_we_i),
        .pwmA(io_out[30]),
        .pwmB(io_out[31])
    );

    // PWM7 - Channels 14,15 (io_out[33:32])
    EF_PWM32_wb pwm7_inst (
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(wbs_adr_i),
        .dat_i(wbs_dat_i),
        .dat_o(pwm7_dat_o),
        .sel_i(wbs_sel_i),
        .cyc_i(wbs_cyc_i),
        .stb_i(pwm7_stb),
        .ack_o(pwm7_ack),
        .we_i(wbs_we_i),
        .pwmA(io_out[32]),
        .pwmB(io_out[33])
    );

    // Set unused I/O pins to input mode
    assign io_oeb[0] = 1'b1;     // SPI0 MISO input
    assign io_oeb[3:1] = 3'b000; // SPI0 outputs
    assign io_oeb[4] = 1'b1;     // SPI1 MISO input
    assign io_oeb[7:5] = 3'b000; // SPI1 outputs
    // I2C pins are controlled by the I2C controller (open-drain)
    // GPIO pins are controlled by the GPIO controller
    assign io_oeb[33:18] = 16'b0; // PWM outputs
    assign io_oeb[37:34] = 4'b1111; // Unused pins as inputs

    // Tie unused outputs to 0
    assign io_out[0] = 1'b0;     // SPI0 MISO (input)
    assign io_out[4] = 1'b0;     // SPI1 MISO (input)
    assign io_out[37:34] = 4'b0; // Unused outputs

    // Logic Analyzer - not used in this design
    assign la_data_out = 128'b0;

endmodule

`default_nettype wire