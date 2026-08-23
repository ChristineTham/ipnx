#!/bin/bash
# PreToolUse hook (Write|Edit): deny writes of historical binary artifacts
# anywhere in the repo except under work/ (gitignored build area).
# Reads the hook JSON on stdin; emits a permission decision on match.
#
# The committed disks live in image/ as .tar.bz2 -- allowed above, because
# the *.tar.bz2 pattern below would otherwise deny them.  They are tar
# because `tar -xSjf' restores holes and nothing else standard does.
# image/ipnx-v8-rp07.img.tar.bz2 is in
# git because it is the INPUT to the next build -- stage 8 lifts 1406 files
# off it that Bell Labs shipped without source (v8/mk/gen/carry.txt).  With
# it committed, the build's only external input is the tapes, which
# v8/MANIFEST already accounts for.  Write it with tar -cjf.
#
# Raw *.img is blocked precisely so that the packed form is the only way in.
f=$(jq -r '.tool_input.file_path // empty')
case "$f" in
  ""|*/work/*) exit 0 ;;
  */image/*.tar.bz2) exit 0 ;;
  *.disk|*.dsk|*.tap|*.tape|*.tar.gz|*.tar.bz2|*.tgz|*.cpio|*.iso|*.img)
    cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Historical binary artifacts (*.disk, *.tap, *.img, tarballs) must not be written into the repo - build them under work/ (gitignored). The committed disks are .tar.bz2 under image/, written with tar -cjf and restored with tar -xSjf. See CLAUDE.md conventions."}}
JSON
    ;;
esac
exit 0
