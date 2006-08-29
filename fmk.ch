/*
 * ----------------------------------------------------------------
 *                                     Copyright Sigma-com software 
 * ----------------------------------------------------------------
 */
 
#define FMK_DEFINED

#ifndef SC_DEFINED
  #include "sc.ch"
#endif

#define FMK_VER  "02.57"

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
#define F_GEN_UG   53
#define F_G_UG_P   54
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
#define F_STRINGS  180

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
// vindija - auto import
#define F_TEMP	236
#define F_PRIPT	237
// tops integritet
#define F_DINTEG1 238
#define F_DINTEG2 239
#define F_INTEG1 240
#define F_INTEG2 241
#define F_ERRORS 242

#define F_KALKSEZ 243
#define F_ROBASEZ 248

// PDV stampa racuna
#define F_DRN 244
#define F_RN 245
#define F_DRNTEXT 246
#define F_DOKSPF 247
#define F_R_UIO 249
#define F_R_EXP 250

// pdv kumulativ - podaci za PDV prijavu
#define F_PDV 204
// kuf promet
#define F_KUF 205
// kif promet
#define F_KIF 206

// priprema kuf
#define F_P_KUF 248
// priprema kif
#define F_P_KIF 249

// KIF shema za generaciju 
// kif_s_gen
#define F_SG_KUF 240
// KUF shema za generaciju
#define F_SG_KIF 241

// reporti
#define F_R_KUF 171
#define F_R_KIF 172
#define F_R_PDV 173

#define F_LOKAL 242

// RNAL
#define F_P_RNAL 130
#define F_P_RNOP 131
#define F_T_RNST 132
#define F_T_RNOP 133
#define F_T_PARS 134
#define F_RNAL 135
#define F_RNOP 136
#define F_RNLOG 137
#define F_S_RNOP 138
#define F_S_RNKA 139
#define F_S_TIPOVI 140
#define F_RNST 141
#define F_P_RNST 142
#define F_LOGIT 143


#include "\dev\fmk\af\cl-AF\cdx\fmk.ch"

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

