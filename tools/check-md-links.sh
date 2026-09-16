#!/bin/bash
# Verify that relative markdown links resolve to files that exist.
#
#	tools/check-md-links.sh README.md docs/roadmap.md
#	tools/check-md-links.sh                 # every tracked .md that is ours
#
# THIS WAS A PostToolUse HOOK AND CARRIED THE HOOK PROTOCOL WITH IT: it printed
# a JSON `block' object and exited 0 whatever it found, because a hook reports
# through stdout and its exit status meant nothing.  Nothing installs it now,
# so it is a command -- and a command that finds a broken link must FAIL.
# Exiting 0 with the complaint on stdout is how a checker ends up in a `&&'
# chain and quietly stops being one.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

check_one() {
	# `local' OR THE ACCUMULATOR IS CLOBBERED.  Without it this function's own
	# rc=0 is the caller's rc, so each file reset the sweep's verdict and a run
	# that printed broken links still exited 0 -- the exact failure this script
	# was rewritten to stop having.
	local f dir link t rc
	f="$1"
	case "$f" in *.md) ;; *) return 0 ;; esac
	[ -f "$f" ] || { echo "check-md-links: no $f" >&2; return 1; }
	dir=$(cd "$(dirname "$f")" && pwd) || return 1
	rc=0
	while IFS= read -r link; do
		case "$link" in http*|mailto:*|"#"*|"") continue ;; esac
		t="${link%%#*}"
		# `file.md:123' -- a line reference, which the terminal makes
		# clickable and which is not part of the path.
		case "$t" in *:[0-9]*) t="${t%%:*}" ;; esac
		[ -z "$t" ] && continue
		[ -e "$dir/$t" ] || { echo "$f: broken link: $link"; rc=1; }
	done < <(grep -oE '\]\([^)]*\)' "$f" 2>/dev/null | sed -E 's/^\]\(//; s/\)$//')
	return $rc
}

rc=0
if [ "$#" -gt 0 ]; then
	for f in "$@"; do check_one "$f" || rc=1; done
else
	# OURS ONLY.  Four of the tracked `.md' files are not markdown at all:
	# v10/usr/src/cmd/gcc/vax.md and its three siblings are GCC MACHINE
	# DESCRIPTIONS -- and nothing under the tape trees was written as a link
	# into this repository.
	cd "$ROOT" || exit 1
	while IFS= read -r f; do
		case "$f" in v10/*|v8/usr/*) continue ;; esac
		check_one "$f" || rc=1
	done < <(git ls-files '*.md')
fi
exit $rc
