#include	<stdio.h>
#include	"../scsi.h"
#include	"../scsish.h"
#include	"fns.h"

static Function fns[] = {
	{ "diag", "diag", "", wr_diag },
	{ "extinq", "extinq", "", wr_extinq },
	{ "modesense", "modesense", "", wr_modesense },
	{ "modeselect", "modeselect er-param er-retries read-recon write-recon cache-enable", "IIIII", wr_modeselect },
	{ 0 }
};
Device wrendev = {
	"wren", "Wren VI",
	gen_extsense,
	fns
};
