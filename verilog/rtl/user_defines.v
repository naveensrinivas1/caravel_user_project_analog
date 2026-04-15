// SPDX-FileCopyrightText: 2026 Naveen Srinivas
// SPDX-License-Identifier: Apache-2.0
//
// user_defines.v — generated for Analog Magic chipIgnite staging
// Generated: 2026-04-15T17:55:23.492Z

`default_nettype none

`ifndef __USER_DEFINES_H
// User GPIO initial configuration parameters
`define __USER_DEFINES_H

`define GPIO_MODE_INVALID 13'hXXXX

`define GPIO_MODE_MGMT_STD_INPUT_NOPULL   13'h0403
`define GPIO_MODE_MGMT_STD_INPUT_PULLDOWN 13'h0c01
`define GPIO_MODE_MGMT_STD_INPUT_PULLUP   13'h0801
`define GPIO_MODE_MGMT_STD_OUTPUT         13'h1809
`define GPIO_MODE_MGMT_STD_BIDIRECTIONAL  13'h1801
`define GPIO_MODE_MGMT_STD_ANALOG         13'h000b

`define GPIO_MODE_USER_STD_INPUT_NOPULL   13'h0402
`define GPIO_MODE_USER_STD_INPUT_PULLDOWN 13'h0c00
`define GPIO_MODE_USER_STD_INPUT_PULLUP   13'h0800
`define GPIO_MODE_USER_STD_OUTPUT         13'h1808
`define GPIO_MODE_USER_STD_BIDIRECTIONAL  13'h1800
`define GPIO_MODE_USER_STD_OUT_MONITORED  13'h1802
`define GPIO_MODE_USER_STD_ANALOG         13'h000a

// GPIO 0:4 are fixed by Caravel and intentionally omitted.
`define USER_CONFIG_GPIO_5_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_6_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_7_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_8_INIT 13'h0402 // SPI_CLK
`define USER_CONFIG_GPIO_9_INIT 13'h0402 // SPI_MOSI
`define USER_CONFIG_GPIO_10_INIT 13'h000a // SPI_CS_N (analog connectivity — OEB high)
`define USER_CONFIG_GPIO_11_INIT 13'h1808 // DOUT[0]
`define USER_CONFIG_GPIO_12_INIT 13'h1808 // DOUT[1]
`define USER_CONFIG_GPIO_13_INIT 13'h1808 // DOUT[2]
`define USER_CONFIG_GPIO_14_INIT 13'h000a // DOUT[3] (analog connectivity — OEB high)
`define USER_CONFIG_GPIO_15_INIT 13'h1808 // VALID
`define USER_CONFIG_GPIO_16_INIT 13'h1808 // IRQ
`define USER_CONFIG_GPIO_17_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_18_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_19_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_20_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_21_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_22_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_23_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_24_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_25_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_26_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_27_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_28_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_29_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_30_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_31_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_32_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_33_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_34_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_35_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_36_INIT 13'h0403 // unused / management input
`define USER_CONFIG_GPIO_37_INIT 13'h0403 // unused / management input

`endif // __USER_DEFINES_H
