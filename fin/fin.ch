#ifndef SC_DEFINED
	#include "sc.ch"
#endif

#define D_FI_VERZIJA "1.w.0.6.62"
#define D_FI_PERIOD '11.94-27.05.04'
#ifndef FMK_DEFINED
	#include "\cl\sigma\fmk\fmk.ch"
#endif


#ifdef CDX
	#include "\cl\sigma\fmk\fin\cdx\fin.ch"
#else
	#include "\cl\sigma\fmk\fin\ax\fin.ch"
#endif
