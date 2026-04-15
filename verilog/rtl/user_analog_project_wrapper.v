// SPDX-FileCopyrightText: 2026 Naveen Srinivas
// SPDX-License-Identifier: Apache-2.0
//
// user_analog_project_wrapper.v - Caravel analog wrapper for 7-stage inference ASIC
// Target: Efabless chipIgnite / SKY130A
// Generated: 2026-04-15T17:55:23.492Z
//
// Pin mapping:
//   analog_io[0:3]  - Sensor inputs (ain0-3)
//   analog_io[4]    - Voltage reference (0.9V)
//   analog_io[5]    - Bias current input
//   analog_io[6:7]  - Analog monitor outputs
//   io_in[8:10]     - SPI bus (CLK, MOSI, CS*)
//   io_out[11:14]   - Classification output DOUT[3:0]
//   io_out[15]      - Valid strobe
//   io_out[16]      - IRQ
//
module user_analog_project_wrapper (
    // Power pins (active for Caravel)
    inout vccd1,
    inout vccd2,
    inout vssd1,
    inout vssd2,
    inout vdda1,
    inout vdda2,
    inout vssa1,
    inout vssa2,

    // Wishbone Slave ports
    input   wb_clk_i,
    input   wb_rst_i,
    input   wbs_stb_i,
    input   wbs_cyc_i,
    input   wbs_we_i,
    input   [3:0] wbs_sel_i,
    input   [31:0] wbs_dat_i,
    input   [31:0] wbs_adr_i,
    output  wbs_ack_o,
    output  [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs - 38 pads
    input  [37:0] io_in,
    output [37:0] io_out,
    output [37:0] io_oeb,

    // Analog - 29 pads
    inout [28:0] analog_io,

    // Independent clock
    input   user_clock2,

    // User maskable interrupt signals
    output [2:0] user_irq
);

    // --- Internal Wires ---
    wire [3:0] ain;
    wire       vref_ext;
    wire       ibias_ext;
    wire       vmon_norm;
    wire       vmon_wta;

    wire       spi_clk_int;
    wire       spi_mosi_int;
    wire       spi_cs_n_int;

    wire [3:0] dout;
    wire       valid_out;
    wire       irq_out;

    // --- Analog Pin Assignments ---
    assign ain[0]    = analog_io[0];
    assign ain[1]    = analog_io[1];
    assign ain[2]    = analog_io[2];
    assign ain[3]    = analog_io[3];
    assign vref_ext  = analog_io[4];
    assign ibias_ext = analog_io[5];
    assign analog_io[6] = vmon_norm;
    assign analog_io[7] = vmon_wta;

    // --- Digital Input Pin Assignments ---
    assign spi_clk_int  = io_in[8];
    assign spi_mosi_int = io_in[9];
    assign spi_cs_n_int = io_in[10];

    // --- Digital Output Pin Assignments ---
    assign io_out[11] = dout[0];
    assign io_out[12] = dout[1];
    assign io_out[13] = dout[2];
    assign io_out[14] = dout[3];
    assign io_out[15] = valid_out;
    assign io_out[16] = irq_out;

    // --- Output Enable (active low: 0 = output, 1 = tri-state/input) ---
    // GPIO  0-7:  unused → tri-state (oeb=1)
    // GPIO  8-10: digital inputs (SPI) → tri-state (oeb=1)
    //   Note: GPIO 10 has analog connectivity in layout → oeb must be 1
    // GPIO 11-13: digital outputs (DOUT[0:2]) → drive (oeb=0)
    // GPIO 14:    has analog connectivity in layout → oeb=1 (disable digital driver)
    // GPIO 15-16: digital outputs (VALID, IRQ) → drive (oeb=0)
    // GPIO 17-37: unused → tri-state (oeb=1)
    assign io_oeb[7:0]   = 8'hFF;           // unused: tri-state
    assign io_oeb[10:8]  = 3'b111;          // SPI inputs + GPIO10 analog: tri-state
    assign io_oeb[13:11] = 3'b000;          // DOUT[0:2]: drive
    assign io_oeb[14]    = 1'b1;            // GPIO14 analog: tri-state (OEB high)
    assign io_oeb[16:15] = 2'b00;           // VALID, IRQ: drive
    assign io_oeb[37:17] = {21{1'b1}};      // unused: tri-state

    // --- Tie-off unused outputs ---
    assign io_out[7:0]   = 8'h00;
    assign io_out[10:8]  = 3'b000;
    assign io_out[37:17] = {21{1'b0}};

    // --- Wishbone (unused — active tie-off to avoid HI-Z) ---
    assign wbs_ack_o  = 1'b0;
    assign wbs_dat_o  = 32'h0;

    // --- Logic Analyzer (unused — active tie-off) ---
    assign la_data_out = 128'h0;

    // --- IRQ ---
    assign user_irq = {1'b0, 1'b0, irq_out};

    // --- Placeholder: tie outputs for precheck ---
    assign dout      = 4'b0000;
    assign valid_out = 1'b0;
    assign irq_out   = 1'b0;
    assign vmon_norm = 1'b0;
    assign vmon_wta  = 1'b0;

endmodule
