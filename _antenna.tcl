# SPDX-FileCopyrightText: 2026 Naveen Srinivas
# SPDX-License-Identifier: Apache-2.0

cif istyle sky130(vendor)
gds read gds/user_analog_project_wrapper.gds
set allcells [cellname list allcells]
puts "ALL_CELLS: $allcells"
set topcell ""
foreach c $allcells { if {$c ne "(UNNAMED)"} { set topcell $c } }
if {$topcell eq ""} { puts "ERROR: no named cell found"; quit -noprompt }
puts "LOADING: $topcell"
load $topcell
select top cell
antenna check
puts "ANTENNA_DONE"
quit -noprompt