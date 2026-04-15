# SPDX-FileCopyrightText: 2026 Naveen Srinivas
# SPDX-License-Identifier: Apache-2.0
# _erase_wrapper.tcl — generate erased GDS for XOR check

load xor_target
box 0 0 10 10
paint comment
gds write precheck_results/outputs/user_analog_project_wrapper_erased.gds
gds write precheck_results/outputs/user_analog_project_wrapper_empty_erased.gds
puts "ERASE_DONE"
quit -noprompt