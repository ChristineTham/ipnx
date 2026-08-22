#!/usr/bin/env bash
#
# Parse a guest harness without running one.
#
#	bash tools/v10-dryrun.sh tools/v10-build.exp
#
# WHY THIS EXISTS.  Tcl reports a syntax error only when it REACHES the
# command, so a typo in a harness's last block surfaces three hours into a run
# that has already done all its work.
#
# AND IT MUST STUB `spawn' BEFORE SOURCING, not after.  Checking this file by
# running `expect -c "source tools/v10-build.exp"' STARTED A SIMULATOR -- it
# reached the spawn and launched a VAX against whatever arguments were lying
# around.  A syntax check that boots a machine is not a syntax check.
set -uo pipefail
F="${1:?usage: v10-dryrun.sh <harness.exp>}"
exec expect -c "
proc spawn args { return 0 }
proc send args {}
proc expect args {}
proc interact args {}
proc close args {}
proc wait args { return {0 0 0 0} }
proc exec args { return {} }
set argv {A B 1 2 1}
set argc 5
source $F
" 2>&1
