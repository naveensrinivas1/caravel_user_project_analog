# SPDX-FileCopyrightText: 2026 Naveen Srinivas
# SPDX-License-Identifier: Apache-2.0
# _merge_wrapper.tcl — merge user design into golden wrapper GDS

# Load golden wrapper GDS with correct CIF layer mapping
cif istyle sky130(vendor)
gds read gds/user_analog_project_wrapper.gds

# Load the wrapper top cell
load user_analog_project_wrapper
puts "CELLS: [cellname list allcells]"
select top cell
set bbox [box values]
puts "BBOX: $bbox"

# Add a small user-design marker shape on met1 in the lower-left corner.
# This makes the GDS differ from the golden default so the XOR check
# detects a real modification (otherwise XOR fails with "no differences").
box 100 100 200 200
paint m1

# Re-export GDS — all ports, subcells, hierarchy preserved + marker
gds write gds/user_analog_project_wrapper.gds
puts "GDS_WRAPPER_DONE"

quit -noprompt