# V10 full-tree read

Christine's instruction, verbatim across several messages:

  "You need to do a full scan" / "Not just every build file. Check for all build
  related files eg INSTALL" / "read every file and determine if it contributes to
  the build process" / "EVERY FILE" / "You are disallowed to scan by file name
  patterns. It must be *" / "You are disallowed from using pattern matching at
  all. Every file must be read and understood in it's entirety" / "because there
  may be a manual install command that you need to understand" / "you need to
  launch multiple subagents" / "don't assume you can do it in one session. in
  fact, you are not allowed to"

## The rule the findings serve

  "The rule should be use package mkfile unless it is wrong. If it is wrong fix
  it. Only create stuff if there isn't an existing rule"

## Why this exists

v10/usr/src/build/mkfile hand-writes an install step per package instead of
running the package's own documented install.  Measured before this scan:

  - 322 absolute install destinations are documented in the tree; the mkfile
    writes 99 and never writes 223.
  - Of 750 build files under /usr/src, 505 have an install rule.  234 of those
    are bypassed by an invented cp in our mkfile; 271 never run at all.
  - v10/usr/man/adm holds 74 files including tmac.s, whose own first line is
    `.so /usr/lib/tmac/tmac.s' -- it names its runtime home -- and the build
    installs none of them.

Those numbers came from pattern matching, which is exactly what is disallowed:
a prose instruction ("the file that belongs in /usr/jerq/bin") carries no verb
and no recipe syntax, so no regex finds it reliably.  Hence a full read.

## Scope

25,069 text files, 125.7 MB (1,326 binary/data files excluded -- they are
listed in chunks too, and an agent records them as binary rather than reading).
Partitioned into 361 chunks of <= 400 KB, directories kept together where they
fit, so each chunk is one agent-pass with room to read every byte.

125.7 MB is about 31M tokens of reading.  It does not fit in one session and is
not attempted in one.

## How to resume

STATUS has one line per chunk: number, files, KB, state (TODO/DONE).
chunks/NNN.lst is the file list.  findings/NNN.md is that chunk's report.
Do the lowest-numbered TODO chunks next; set a line to DONE only when
findings/NNN.md exists and covers every file in the list.
