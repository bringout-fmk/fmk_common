
#ifdef CAX
 INIT PROCEDURE Rddinit()

 Request LIKE
 REQUEST DBFCDXAX
 REQUEST AOFINIT
 REQUEST COMIX
 rddsetdefault("DBFCDXAX")
#else
#endif


#ifdef XBASE
PROCEDURE DBESYS()

      IF ! DbeLoad( "FOXDBE", .T.) 
         Alert( "FOXDBE not loaded", {"OK"} ) 
      ENDIF 
    
      IF ! DbeLoad( "CDXDBE", .T.) 
         Alert( "CDXDBE not loaded", {"OK"} ) 
      ENDIF 
 
      IF ! DbeBuild( "FOXCDX", "FOXDBE", "CDXDBE" ) 
         Alert( "Unable to build;" + ; 
                "FOXCDX DatabaseEngine" , {"OK"} ) 

      ENDIF 
 
      DbeSetDefault( "FOXCDX" ) 

RETURN


#ENDIF



