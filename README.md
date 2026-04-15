# Analog Magic — chipIgnite user_analog_project_wrapper

This directory contains the staged chipIgnite submission files for the Analog Magic mixed-signal inference wrapper.

## Design summary

The user project is an analog inference wrapper targeting the Caravel analog harness on SKY130A.

### External interface

- **analog_io[0:3]** — sensor inputs `ain0..ain3`
- **analog_io[4]** — external reference `vref`
- **analog_io[5]** — bias current input `ibias`
- **analog_io[6:7]** — analog monitor outputs `vmon0`, `vmon1`
- **io_in[8:10]** — SPI control inputs `spi_clk`, `spi_mosi`, `spi_cs_n`
- **io_out[11:16]** — digital outputs `dout[3:0]`, `valid`, `irq`

## Staged deliverables

- `gds/user_analog_project_wrapper.gds`
- `lef/user_project_wrapper.lef`
- `def/user_project_wrapper.def`
- `verilog/rtl/user_project_wrapper.v`
- `verilog/rtl/user_analog_project_wrapper.v`
- `verilog/rtl/user_defines.v`
- `verilog/gl/user_project_wrapper.v`
- `netgen/user_analog_project_wrapper.spice`
- `xschem/user_analog_project_wrapper.spice`

## Notes

- The staged GDS top cell is exported as `user_analog_project_wrapper` for mpw_precheck compatibility.
- The staged SPICE top `.subckt` is renamed to `user_analog_project_wrapper` for consistency and LVS.
- GPIO power-up modes are defined in `verilog/rtl/user_defines.v` using official Caravel 13-bit literals.
