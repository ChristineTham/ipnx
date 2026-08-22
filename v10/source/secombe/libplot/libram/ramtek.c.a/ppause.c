#include <stdio.h>
#include "ram.h"
ppause()
{ 
	char	aa[4]; 
	fflush(stdout); 
	read(2, aa, 4);  
	erase(); 
}
