# SPDX-FileCopyrightText: 2026 Naveen Srinivas
# SPDX-License-Identifier: Apache-2.0
# _extract_lvs.tcl — extract SPICE netlist from GDS for LVS

cif istyle sky130(vendor)
gds read gds/user_analog_project_wrapper.gds
set allcells [cellname list allcells]
puts "CELLS: $allcells"
set topcell ""
foreach c $allcells { if {$c ne "(UNNAMED)"} { set topcell $c } }
if {$topcell eq ""} { puts "NO_CELL"; quit -noprompt }
load $topcell
select top cell
extract all
ext2spice lvs
ext2spice -o netgen/user_analog_project_wrapper.spice
ext2spice -o xschem/user_analog_project_wrapper.spice
puts "PEX_DONE"
quit -noprompt