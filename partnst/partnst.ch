#define F_STOSTAV	240
#define F_STPARAMS	241
#define F_STPARTN	242
#define F_F_OSTAV	243
#define F_F_KONCIJ	244
#define F_F_PARTN	245

#xcommand O_OSTAV => SELECT (F_STOSTAV); USE (KUMPATH+"OSTAV"); set order to tag "ID"
#xcommand O_PARAMS => SELECT (F_STPARAMS); USE (KUMPATH+"PARAMS"); set order to tag "ID"
#xcommand O_PARTN => SELECT (F_STPARTN); USE (KUMPATH+"PARTN"); set order to tag "ID"
#xcommand O_KONCIJ => SELECT (F_F_KONCIJ); USE (SIFPATH+"KONCIJ"); set order to tag "ID"

