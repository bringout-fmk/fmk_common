#define F_STOSTAV	220
#define F_STPARAMS	221
#define F_F_OSTAV	222

#xcommand O_OSTAV => SELECT (F_STOSTAV); USE (KUMPATH+"OSTAV"); set order to tag "ID"
#xcommand O_PARAMS => SELECT (F_STPARAMS); USE (KUMPATH+"PARAMS"); set order to tag "ID"

