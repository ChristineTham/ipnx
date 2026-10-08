MAKE=/bin/make
MAKEFILE=devpost.mk

SYSTEM=V9
VERSION=3.3.1

GROUP=bin
OWNER=bin

FONTDIR=/usr/lib/font
FONTFILES=DESC ? ?? [A-Z]??* shell.lib u_Hb u_Hi u_Hx

all :

# ipnx: THE TWO RENAMES AT THE END OF install, and why these notes are up
# here.  u_Hb/u_Hi/u_Hx are casefix's names for Hb/Hi/Hx (their own "name"
# lines still say Hb/Hi/Hx) -- extracted that way because the real names
# collide case-insensitively with HB/HI/HX, already matched by the glob in
# FONTFILES.  Restored the same way troff/devaps restores u_Cw (build/mkfile,
# near its devaps install line).  Without it, dpost's mapfont() silently
# substitutes Times-Roman for all three Helvetica-Narrow weights.  The same
# rename for the charlib glyphs whose real names (LH, rH, lH, RC) collide with
# lh/rh/rc: \(LH (the AT&T logo, charlib/LH.example), \(lH and \(rH
# otherwise render as nothing at all.
#
# NOT AS COMMENTS INSIDE THE RECIPE, where they were.  This file is run by
# make, not mk, and v10's make execs a recipe line itself when it has no shell
# metacharacter: `# real names collide case-insensitively with HB/HI/HX,
# already' went to exec as a program named `#', and the 7 Oct rebuild stopped
# with `Make: Cannot load #.' -- postscript: FAILED, and no font installed.
install : all
	@rm -f $(FONTDIR)/devpost/*.out
	@if [ ! -d $(FONTDIR) ]; then \
	    mkdir $(FONTDIR); \
	    chmod 755 $(FONTDIR); \
	    : $(GROUP) $(FONTDIR); \
	    : $(OWNER) $(FONTDIR); \
	fi
	@if [ ! -d $(FONTDIR)/devpost ]; then \
	    mkdir $(FONTDIR)/devpost; \
	    chmod 755 $(FONTDIR)/devpost; \
	    : $(GROUP) $(FONTDIR)/devpost; \
	    : $(OWNER) $(FONTDIR)/devpost; \
	fi
	@if [ ! -d $(FONTDIR)/devpost/charlib ]; then \
	    mkdir $(FONTDIR)/devpost/charlib; \
	    chmod 755 $(FONTDIR)/devpost/charlib; \
	    : $(GROUP) $(FONTDIR)/devpost/charlib; \
	    : $(OWNER) $(FONTDIR)/devpost/charlib; \
	fi
	cp $(FONTFILES) $(FONTDIR)/devpost
	@for i in $(FONTFILES); do \
	    chmod 644 $(FONTDIR)/devpost/$$i; \
	    : $(GROUP) $(FONTDIR)/devpost/$$i; \
	    : $(OWNER) $(FONTDIR)/devpost/$$i; \
	done
	cd $(FONTDIR)/devpost; test -f u_Hb && mv u_Hb Hb || :; test -f u_Hi && mv u_Hi Hi || :; test -f u_Hx && mv u_Hx Hx || :
	cp charlib/* $(FONTDIR)/devpost/charlib
	@for i in charlib/*; do \
	    chmod 644 $(FONTDIR)/devpost/$$i; \
	    : $(GROUP) $(FONTDIR)/devpost/$$i; \
	    : $(OWNER) $(FONTDIR)/devpost/$$i; \
	done
	cd $(FONTDIR)/devpost/charlib; test -f u_LH && mv u_LH LH || :; test -f u_rH && mv u_rH rH || :; test -f u_u_lH && mv u_u_lH lH || :; test -f u_RC && mv u_RC RC || :

clean :

clobber : clean

changes :
	@trap "" 1 2 3 15; \
	sed \
	    -e "s'^SYSTEM=.*'SYSTEM=$(SYSTEM)'" \
	    -e "s'^VERSION=.*'VERSION=$(VERSION)'" \
	    -e "s'^GROUP=.*'GROUP=$(GROUP)'" \
	    -e "s'^OWNER=.*'OWNER=$(OWNER)'" \
	    -e "s'^FONTDIR=.*'FONTDIR=$(FONTDIR)'" \
	$(MAKEFILE) >XXX.mk; \
	mv XXX.mk $(MAKEFILE)

