#define F_MSGNEW 234

#xcommand O_MESSAGE   => select(F_MESSAGE); use (KUMPATH+"MESSAGE"); set order to tag "1"
#xcommand O_AMESSAGE   => select(F_AMESSAGE); use (EXEPATH+"AMESSAGE"); set order to tag "1"
#xcommand O_TMPMSG  => select(F_TMPMSG); use (EXEPATH+"TMPMSG"); set order to tag "1"
