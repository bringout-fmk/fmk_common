
dllname:="t:\sigma\ncom.dll"
funname:="MANAGER"
funres:=0
altd()
libhan = BLILIBLOD (dllname)            // Dynamically load the DLL

if libhan > 32                         // If it loaded successfully

//          ******************         // EITHER (most efficient and controlled)

   funhan = BLIFUNHAN (libhan,funname)  // Get the function handle
   if funhan <> 0                      // If the function was found

                                       // Call function with (multiple) params
      funres = BLIFUNCAL (funhan)
                                       // Note that function handle is LAST
   else
      ? "DLL file", dllnme, "does not contain function", funname
      ?
   endif

//          ******************         // OR (easiest but less efficient)

//    funres = &funnme (funpa1,funpa2) // Gives a runtime error if not found
                                       // But also works even if the function
                                       // Was not exported !!

//          ******************         // END

   //? "Function", funnme, "returned", funres // Display the results
   ?

   BLILIBFRE (libhan)                  // Free the library when finished

else
   ? "DLL file ", dllnme, "not found or failed to load"
   ?
endif
