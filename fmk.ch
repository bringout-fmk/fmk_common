/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 * $Source: c:/cvsroot/cl/sigma/fmk/fmk.ch,v $
 * $Author: sasavranic $ 
 * $Revision: 1.38 $
 * $Log: fmk.ch,v $
 * Revision 1.38  2003/12/10 11:58:15  sasavranic
 * no message
 *
 * Revision 1.37  2003/11/10 09:50:04  sasavranic
 * no message
 *
 * Revision 1.36  2003/11/04 02:13:22  ernadhusremovic
 * Planika Kranj - Robno poslovanje
 *
 * Revision 1.35  2003/07/23 13:34:19  sasa
 * pos <-> pos
 *
 * Revision 1.34  2003/05/16 15:29:05  mirsad
 * VIRM-prilagodjavanje 1w sistemu
 *
 * Revision 1.33  2003/04/12 06:49:18  mirsad
 * napravljen sistem kontiranja LD->FIN
 *
 * Revision 1.32  2003/01/08 03:08:49  mirsad
 * dodani makroi za RNAL.DBF
 *
 * Revision 1.31  2003/01/04 11:34:02  ernad
 * duple stavke u FMK.CH-u
 *
 * Revision 1.30  2002/12/19 16:44:39  sasa
 * dodata tabela radsat
 *
 * Revision 1.29  2002/12/12 15:12:59  mirsad
 * os 0w->1w
 *
 * Revision 1.28  2002/12/11 13:13:15  mirsad
 * prebacivanje OS-a na 1w sistem
 *
 * Revision 1.27  2002/11/29 00:45:40  mirsad
 * ubacivanje baza za modul KAM
 *
 * Revision 1.26  2002/11/17 03:52:16  mirsad
 * korekcija
 *
 * Revision 1.25  2002/11/12 13:40:42  sasa
 * F_USERS, F_GROUPS, F_RULES, F_EVENTS, F_EVENTLOG
 *
 * Revision 1.24  2002/11/11 23:38:39  sasa
 * no message
 *
 * Revision 1.23  2002/08/19 10:04:24  ernad
 *
 *
 * podesenja CLIP
 *
 * Revision 1.22  2002/08/05 11:03:58  ernad
 *
 *
 * Fin/SQLLog funkcije, debug bug RJ/KUMPATH
 *
 * Revision 1.21  2002/07/30 17:40:59  ernad
 * SqlLog funkcije - Fin modul
 *
 * Revision 1.20  2002/07/25 11:02:46  sasa
 * dodat F_DOKSTXT na podrucju 173
 *
 * Revision 1.19  2002/07/15 06:55:16  ernad
 * F_RLABELE
 *
 * Revision 1.18  2002/07/14 06:40:41  ernad
 *
 *
 * ukloni ROBPR
 *
 * Revision 1.17  2002/07/10 08:44:19  ernad
 *
 *
 * barkod funkcije kalk, fakt -> fmk/roba/barkod.prg
 *
 * Revision 1.16  2002/07/08 23:03:54  ernad
 *
 *
 * trgomarket debug dok 80, 81, izvjestaj lager lista magacin po proizv. kriteriju
 *
 * Revision 1.15  2002/07/06 12:29:01  ernad
 *
 *
 * kalk, planika GenRekap1, GenRekap2
 *
 * Revision 1.14  2002/07/04 19:04:08  ernad
 *
 *
 * ciscenje sifrarnik fakt
 *
 * Revision 1.13  2002/07/03 23:55:19  ernad
 *
 *
 * ciscenja planika (tragao za nepostojecim bug-om u prelgedu finansijskog obrta)
 *
 * Revision 1.12  2002/07/01 17:49:28  ernad
 *
 *
 * formiranje finalnih build-ova (fin, kalk, fakt, pos) pred teren planika
 *
 * Revision 1.11  2002/06/29 17:32:01  ernad
 *
 *
 * planika - pregled prometa prodavnice
 *
 * Revision 1.10  2002/06/25 08:42:53  ernad
 * F_REKAP22
 *
 * Revision 1.9  2002/06/24 16:11:53  ernad
 *
 *
 * planika - uvodjenje izvjestaja 98-reklamacija, izvjestaj planika/promet po vrstama placanja, debug
 *
 * Revision 1.8  2002/06/20 16:52:05  ernad
 *
 *
 * ciscenje planika, uvedeno fmk/svi/specif.prg
 *
 * Revision 1.7  2002/06/17 09:47:01  ernad
 * header, podesenja
 *
 *
 */
 
#define FMK_DEFINED

#ifndef SC_DEFINED
  #include "\sclib\sc.ch"
#endif

#define FMK_VER  "1.w.0.8.3"

#define F_GPARAMS   1
#define F_GPARAMSP  2
#define F_PARAMS    3
#define F_KORISN    4
#define F_MPARAMS   5
#define F_KPARAMS   6
#define F_SECUR     7
#define F_ADRES     8
#define F_SIFK      9
#define F_SIFV     10
#define F_TMP      11
#define F_SQLPAR   12

// proizvoljni izvjestaji
#define F_KONIZ    13
#define F_IZVJE    14
#define F_ZAGLI    15
#define F_KOLIZ    16
#define D_S_TABELE 


//OVA ZAGLAVLJA NAPUSTITI!
#define F_PRIPR     17
#define F_DOKS      18
#define F_DOKS2     19


// FMK FIN
#define F_FIPRIPR  20
#define F_SUBAN    21
#define F_ANAL     22
#define F_SINT     23
#define F_BBKLAS   24
#define F_IOS      25
#define F_NALOG    26
#define F_PNALOG   27
#define F_PSUBAN   28
#define F_PANAL    29
#define F_PSINT    30
#define F_PKONTO   31
#define F_PRIPRRP  32

// FMK FIN/BUDZET
#define F_FUNK     33
#define F_BUDZET   34
#define F_PAREK    36
#define F_FOND     37

#define F_OSTAV    38
#define F_OSUBAN   39
#define F_BUIZ     40

#define F__KONTO   41
#define F__PARTN   42
#define F_POM2     43
#define F_VKSG     44
#define F_ULIMIT   45
#define F_FIDOKS   46
#define F_FIDOKS2  47

#define F_UGOV     50
#define F_RUGOV    51
#define F_KUF      53
#define F_KIF      54
#define F_VPRIH    55


//FMK ROBA
#define F_TARIFA    60 
#define F_PARTN     61
#define F_TNAL      62
#define F_TDOK      63
#define F_ROBA      64 
#define F_KONTO     65
#define F_TRFP      66
#define F_TRMP      67
#define F_VALUTE    68
#define F_KONCIJ    69 
#define F_SAST      70
#define F_BARKOD    71
#define F__VALUTE   72
#define F_RJ        73
#define F_OPS       74
#define F_RNAL      75


//KALK
#define F_KPRIPR    85 
#define F_FINMAT    86
#define F_KALK      87
#define F_PORMP     88
#define F_PRIPR2    89
#define F_PRIPR9    90
#define F__KALK     91
#define F_KDOKS     92
#define F_KPRIPRRP  93
#define F_LOGK      95
#define F_LOGKD     96
#define F_KALKS     97
#define F_KDOKS2    98
#define F_POM       99

//FAKT
#define F_FAPRIPR   100
#define F_FAKT      101
#define F_FTXT      102
#define F_FADOKS    103
#define F__FAKT     104
#define F_FAPRIPRRP 105
#define F_UPL       106 
#define F_DEST      107
#define F_LABELU    108
#define F_FADOKS2   109
#define F_VRSTEP    110
#define F_RELAC     112
#define F_VOZILA    113
#define F_KALPOS    114
#define F_CROBA     115
#define F_POR       116

//POS
#define F_PDOKS     130
#define F_POS       131
#define F_RNGPLA    132
#define F__POS      133
#define F__PRIPR    134
#define F_PRIPRZ    135
#define F_PRIPRG    136
#define F_K2C       137
#define F_MJTRUR    138
#define F_ROBAIZ    139
#define F_RAZDR     140
#define F_SIROV     141
#define F_STRAD     142
#define F_OSOB      143
#define F_KASE      144
#define F_ODJ       145
#define F_UREDJ     146
#define F_RNGOST    147
#define F_DIO       148
#define F_MARS      149
#define F_PROMVP    150
#define F_DOKS_S    151 
#define F_POS_S     152
#define F_DOKS_K    153
#define F_POS_K     154
#define F_DOKS_SEZ  155
#define F_POS_SEZ   156


#define F_TRFP2     160
#define F_TRFP3     215
#define F__ROBA     161

#define F_OBJEKTI   162
#define F_REKAP1    163
#define F_REKAP2    164
#define F_REKA22    165

// pos
#define F_ZAKSM     166

// kalk

// kalk
#define F_PPPROD    167

//kalk, planika
#define F_K1        168
#define F_POBJEKTI  170
#define F_RPT_TMP   171

#define F_RLABELE   172
#define F_DOKSTXT   173

//kalk, kontrolna tabela lagera
#define F_KONTROLA  174

//events
#define F_EVENTS  175
#define F_EVENTLOG  176

//security
#define F_USERS  177
#define F_GROUPS  178
#define F_RULES  179

//ld
#define F_RADN     180
#define F_PAROBR   181
#define F_TIPPR    182
#define F_LD       183
#define F_DOPR     185
#define F_STRSPR   186
#define F_VPOSLA   187
#define F_KBENEF   188
#define F_TIPPR2   189
#define F_KRED     190
#define F_RADKR    191
#define F_LDSM     192
#define F__RADN    193
#define F__LD      194
#define F_REKLD    195
#define F__RADKR   196
#define F__KRED    197
#define F_OPSLD    198
#define F_NORSIHT  199
#define F_TPRSIHT  200
#define F_RADSIHT  201
#define F_BANKE    202
#define F_OBRACUNI 203
#define F_RADSAT   213
#define F_REKLDP   214

//kam
#define F_KAMPRIPR 204
#define F_KAMAT    205
#define F_KS       206
#define F_KS2      207

//os
#define F_OS       208
#define F_AMORT    209
#define F_REVAL    210
#define F_PROMJ    211
#define F_INVENT   212

//virm
#define F_VIPRIPR 216
#define F_KUMUL   217
#define F_VRPRIM  218
#define F_STAMP   219
#define F_VIPRIP2 220
#define F_VRPRIM2 221
#define F_STAMP2  222
#define F_LDVIRM  223
#define F_KALVIR  224
#define F_IZLAZ   225
#define F_JPRIH   226
#define F_KUMUL2  227

// pos
#define F__POSP  228
#define F__DOKSP  229

// KALK
#define F_PRODNC 230
#define F_RVRSTA 231
// POS
#define F_MESSAGE 232
#define F_AMESSAGE 233
#define F_TMPMSG 234
// FAKT
#define F_POMGN 235

#ifdef CLIP
   #include "\dev\fmk\af\cl-AF\cdx\fmk.ch"
#else
	#ifdef CDX
	   #include "\dev\fmk\af\cl-AF\cdx\fmk.ch"
	#else
	   #include "\dev\fmk\af\cl-AF\ax\fmk.ch"
	#endif
#endif

#define POR_PPP		1 
#define POR_PPU		2
#define POR_PP		3
#define POR_PRUC	4
#define POR_PRUCMP	5
#define POR_DLRUC	6

#define POR_I_PRUC	1
#define POR_I_MPC2	2
#define POR_I_PP	3
#define POR_I_MPC3	4
#define POR_I_PPP	5
#define POR_I_MPC4	6

