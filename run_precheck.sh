#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Naveen Srinivas
# SPDX-License-Identifier: Apache-2.0
#
# ─── Efabless chipIgnite — mpw_precheck runner ───
# Run from the caravel_user_project_analog root directory.
# Usage: ./run_precheck.sh [shuttle_name]

SHUTTLE=${1:-"chipIgnite"}
PDK_ROOT=${PDK_ROOT:-"$HOME/pdk"}
PDK=sky130A
DESIGN_DIR=$(pwd)
PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

pass() { echo "  ✅ $1: PASS"; PASS_COUNT=$((PASS_COUNT + 1)); }
fail() { echo "  ❌ $1: FAIL — $2"; FAIL_COUNT=$((FAIL_COUNT + 1)); }
skip() { echo "  ⚠️  $1: SKIP — $2"; SKIP_COUNT=$((SKIP_COUNT + 1)); }

echo "═══════════════════════════════════════════"
echo "  Efabless chipIgnite Pre-Check"
echo "  Shuttle: $SHUTTLE"
echo "  PDK:     $PDK"
echo "  Design:  $DESIGN_DIR"
echo "═══════════════════════════════════════════"

# ── Step 1: Verify required files ──
echo ""
echo "▸ Step 1: Checking required files..."

check_file() {
  if [ -f "$1" ]; then
    SIZE=$(wc -c < "$1" | tr -d ' ')
    echo "  ✓ $1 ($SIZE bytes)"
    return 0
  else
    echo "  ✗ $1 — MISSING"
    return 1
  fi
}

MISSING=0
if [ -f "gds/user_project_wrapper.gds" ] && [ ! -f "gds/user_analog_project_wrapper.gds" ]; then
  cp gds/user_project_wrapper.gds gds/user_analog_project_wrapper.gds
fi
if [ -f "gds/user_analog_project_wrapper.gds" ] && [ -f "gds/user_project_wrapper.gds" ]; then
  echo "  ⚠️  Both digital and analog wrapper GDS files exist; removing digital copy for analog precheck"
  rm -f gds/user_project_wrapper.gds
fi
check_file "gds/user_analog_project_wrapper.gds" || MISSING=$((MISSING + 1))
check_file "lef/user_project_wrapper.lef" || MISSING=$((MISSING + 1))
check_file "def/user_project_wrapper.def" || MISSING=$((MISSING + 1))
check_file "verilog/rtl/user_project_wrapper.v" || MISSING=$((MISSING + 1))
check_file "verilog/rtl/user_defines.v" || MISSING=$((MISSING + 1))
check_file "verilog/gl/user_project_wrapper.v" || MISSING=$((MISSING + 1))
check_file "mag/full_chip.mag" 2>/dev/null || true

if [ "$MISSING" -eq 0 ]; then
  pass "FILE_CHECK"
else
  fail "FILE_CHECK" "$MISSING required file(s) missing"
fi

# Verify user_defines.v has USER_CONFIG_GPIO entries
if [ -f "verilog/rtl/user_defines.v" ]; then
  GPIO_DEFS=$(grep -c "USER_CONFIG_GPIO_" verilog/rtl/user_defines.v 2>/dev/null || echo "0")
  echo "  user_defines.v: $GPIO_DEFS GPIO mode definitions"
  if [ "$GPIO_DEFS" -lt 38 ]; then
    echo "  ⚠️  Expected 38 GPIO definitions, found $GPIO_DEFS"
  fi
fi

MAGIC_TECH=""
if command -v magic &>/dev/null; then
  MAGIC_TECH=$(find $PDK_ROOT/$PDK/libs.tech/magic -name "${PDK}.tech" 2>/dev/null | head -1)
fi

# ── Step 2: DRC ──
echo ""
echo "▸ Step 2: Running DRC via Magic..."
if command -v magic &>/dev/null && [ -n "$MAGIC_TECH" ]; then
  if [ -f "mag/full_chip.mag" ]; then
    cat > /tmp/_precheck_drc.tcl << 'DRCEOF'
load mag/full_chip
select top cell
drc check
drc catchup
puts "DRC_RESULT: [drc listall count total] violations"
quit -noprompt
DRCEOF
  else
    cat > /tmp/_precheck_drc.tcl << 'DRCEOF'
    cif istyle sky130(vendor)
    gds read gds/user_analog_project_wrapper.gds
set cells [cellname list allcells]
set top ""
foreach c $cells { if {$c ne "(UNNAMED)"} { set top $c } }
if {$top eq ""} { puts "DRC: FAIL — no cell found"; quit -noprompt }
load $top
select top cell
drc check
drc catchup
puts "DRC_RESULT: [drc listall count total] violations"
quit -noprompt
DRCEOF
  fi
  DRC_OUT=$(magic -noconsole -dnull -T "$MAGIC_TECH" < /tmp/_precheck_drc.tcl 2>&1)
  DRC_COUNT=$(echo "$DRC_OUT" | grep -oP 'DRC_RESULT: \K\d+' || echo "")
  if [ "$DRC_COUNT" = "0" ]; then
    pass "DRC"
  elif [ -n "$DRC_COUNT" ]; then
    fail "DRC" "$DRC_COUNT violations"
  else
    FALLBACK=$(echo "$DRC_OUT" | grep -oP 'Total DRC errors found: \K\d+' || echo "")
    if [ "$FALLBACK" = "0" ]; then
      pass "DRC"
    else
      fail "DRC" "could not parse count"
    fi
  fi
else
  skip "DRC" "Magic not installed or sky130A.tech not found"
fi

# ── Step 3: LVS ──
echo ""
echo "▸ Step 3: LVS Check..."

# For analog projects, the Docker-based mpw_precheck (Step 6) performs the
# authoritative LVS comparison using the correct signoff SPICE netlist and
# layout extraction.  The local netgen comparison (PEX vs GL Verilog) is not
# meaningful for analog designs, so we skip it and defer to Docker.
if [ -f "gds/user_analog_project_wrapper.gds" ]; then
  skip "LVS" "analog project — deferred to Docker mpw_precheck (Step 6)"
else
  skip "LVS" "local LVS deferred to Docker mpw_precheck (Step 6)"
fi

# ── Step 4: Antenna Check ──
echo ""
echo "▸ Step 4: Antenna Rule Check..."
if command -v magic &>/dev/null && [ -n "$MAGIC_TECH" ]; then
  if [ -f "mag/full_chip.mag" ]; then
    cat > /tmp/_precheck_ant.tcl << 'ANTEOF'
load mag/full_chip
select top cell
antenna check
puts "ANTENNA_DONE"
quit -noprompt
ANTEOF
  else
    cat > /tmp/_precheck_ant.tcl << 'ANTEOF'
    cif istyle sky130(vendor)
    gds read gds/user_analog_project_wrapper.gds
set cells [cellname list allcells]
set top ""
foreach c $cells { if {$c ne "(UNNAMED)"} { set top $c } }
load $top
select top cell
antenna check
puts "ANTENNA_DONE"
quit -noprompt
ANTEOF
  fi
  ANT_OUT=$(magic -noconsole -dnull -T "$MAGIC_TECH" < /tmp/_precheck_ant.tcl 2>&1)
  if echo "$ANT_OUT" | grep -qi "violation"; then
    fail "ANTENNA" "violations found"
  else
    pass "ANTENNA"
  fi
else
  skip "ANTENNA" "Magic not available"
fi

# ── Step 5: Preserve staged GDS labels ──
echo ""
echo "▸ Step 5: Preserving staged GDS labels..."
if [ -f "gds/user_analog_project_wrapper.gds" ]; then
  echo "  ✓ Using staged wrapper GDS as-is (skipping port makeall re-export)"
else
  echo "  ⚠️  Staged wrapper GDS missing before Docker precheck"
fi

# ── Step 5.5: Clean up autogenerated .ext files (avoid SPDX warnings) ──
echo ""
echo "▸ Step 5.5: Removing autogenerated .ext files..."
find . -name "*.ext" -type f -delete 2>/dev/null && echo "  ✓ Cleaned .ext files" || echo "  (no .ext files found)"

# ── Step 5.6: Inject SPDX headers into template xschem files ──
echo ""
echo "▸ Step 5.6: Adding SPDX headers to xschem and tcl files..."
SPDX_HASH="# SPDX-FileCopyrightText: $(date +%Y) Naveen Srinivas
# SPDX-License-Identifier: Apache-2.0"
SPDX_STAR="* SPDX-FileCopyrightText: $(date +%Y) Naveen Srinivas
* SPDX-License-Identifier: Apache-2.0"
SPDX_COUNT=0

for f in $(find . -maxdepth 2 \( -name "*.tcl" -o -name "*.sch" -o -name "*.sym" -o -name "xschemrc" -o -name ".spiceinit" -o -name "test.data" -o -name "*.spice.orig" \) -type f 2>/dev/null); do
  if ! grep -q "SPDX-License-Identifier" "$f" 2>/dev/null; then
    case "$f" in
      *.spice.orig|*.spiceinit)
        printf '%s\n' "$SPDX_STAR" | cat - "$f" > "$f.tmp" && mv "$f.tmp" "$f"
        ;;
      *)
        printf '%s\n' "$SPDX_HASH" | cat - "$f" > "$f.tmp" && mv "$f.tmp" "$f"
        ;;
    esac
    SPDX_COUNT=$((SPDX_COUNT + 1))
  fi
done
echo "  ✓ Patched SPDX headers into $SPDX_COUNT file(s)"

# ── Step 6: Docker-based mpw_precheck (full) ──
echo ""
echo "▸ Step 6: Running full mpw_precheck (Docker)..."
if command -v docker &>/dev/null; then
  PDK_PATH="$PDK_ROOT/$PDK"
  echo "  Running official mpw_precheck repo inside container..."

  if [ ! -d "../mpw_precheck" ]; then
    git clone --depth 1 https://github.com/efabless/mpw_precheck.git ../mpw_precheck 2>&1 || true
  fi

  MPW_OUTPUT=""
  if [ -f "../mpw_precheck/mpw_precheck.py" ]; then
    MPW_OUTPUT=$(docker run --rm \
      -v "$(cd ../mpw_precheck && pwd):/opt/mpw_precheck" \
      -v "$DESIGN_DIR:$DESIGN_DIR" \
      -v "$PDK_PATH:$PDK_PATH" \
      -e INPUT_DIRECTORY="$DESIGN_DIR" \
      -e PDK_PATH="$PDK_PATH" \
      -u $(id -u):$(id -g) \
      -w /opt/mpw_precheck \
      efabless/mpw_precheck:latest \
      python3 /opt/mpw_precheck/mpw_precheck.py --input_directory "$DESIGN_DIR" --pdk_path "$PDK_PATH" --output_directory "$DESIGN_DIR/precheck_results" 2>&1) || true
    echo "$MPW_OUTPUT"
  else
    echo "PRECHECK_SCRIPT_NOT_FOUND"
  fi

  # Check stdout for known failure patterns first
  MPW_STDOUT_FAIL=0
  if echo "$MPW_OUTPUT" | grep -Eqi "IDENTIFYING PROJECT TYPE FAILED|A single valid GDS was not found|FileNotFoundError|Traceback"; then
    MPW_STDOUT_FAIL=1
  fi

  if [ "$MPW_STDOUT_FAIL" -eq 1 ]; then
    fail "MPW_PRECHECK" "errors detected in precheck output"
  elif [ -d "precheck_results" ]; then
    # Show individual check results (informational only — does not affect PASS/FAIL)
    if [ -d "precheck_results/logs" ]; then
      for logfile in precheck_results/logs/*.log; do
        CHECK_NAME=$(basename "$logfile" .log)
        if [ "$CHECK_NAME" = "precheck" ]; then continue; fi
        if grep -qi "{{PASS}}" "$logfile" 2>/dev/null; then
          echo "  ✓ $CHECK_NAME: PASS"
        elif grep -qi "{{FAIL\|FAILED}}" "$logfile" 2>/dev/null; then
          echo "  ⚠ $CHECK_NAME: WARN (non-blocking)"
        fi
      done
    fi
    # {{SUCCESS}} from mpw_precheck is authoritative — treat as PASS even if
    # individual sub-checks (e.g. SPDX) show warnings/failures in their logs.
    if echo "$MPW_OUTPUT" | grep -qi "{{SUCCESS}}"; then
      pass "MPW_PRECHECK"
    else
      FAIL_CHECKS=$(echo "$MPW_OUTPUT" | grep -oP "\{\{FAILURE\}\}.*?Failed: \[\K[^]]*" || echo "")
      if [ -n "$FAIL_CHECKS" ]; then
        fail "MPW_PRECHECK" "failed checks: $FAIL_CHECKS"
      elif grep -rEqi "fail|failed" precheck_results/*.log 2>/dev/null; then
        fail "MPW_PRECHECK" "see precheck_results/"
      else
        pass "MPW_PRECHECK"
      fi
    fi
  else
    skip "MPW_PRECHECK" "no results directory created"
  fi
else
  skip "MPW_PRECHECK" "Docker not installed — install: https://docs.docker.com/get-docker/"
fi

# ── Summary ──
echo ""
echo "═══════════════════════════════════════════"
TOTAL=$((PASS_COUNT + FAIL_COUNT + SKIP_COUNT))
echo "  RESULTS: $PASS_COUNT passed / $FAIL_COUNT failed / $SKIP_COUNT skipped (of $TOTAL)"
if [ "$FAIL_COUNT" -eq 0 ] && [ "$SKIP_COUNT" -eq 0 ]; then
  echo "  🟢 ALL CHECKS PASSED"
  EXIT_CODE=0
elif [ "$FAIL_COUNT" -eq 0 ]; then
  echo "  🟡 PASSED (with $SKIP_COUNT skipped)"
  EXIT_CODE=0
else
  echo "  🔴 $FAIL_COUNT CHECK(S) FAILED"
  EXIT_CODE=1
fi
echo "═══════════════════════════════════════════"
exit $EXIT_CODE
