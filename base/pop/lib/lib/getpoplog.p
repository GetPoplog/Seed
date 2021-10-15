;;; This library adds the extns folder to the searchlists.
;;; N.B. This code is
;;;     - section independent
;;;     - safe against multiple reloads

extend_searchlist( '$usepop/pop/getpoploglibs/auto', popautolist ) -> popautolist;
extend_searchlist( '$usepop/pop/getpoploglibs/lib', popliblist ) -> popliblist;
extend_searchlist( '$usepop/pop/getpoploglibs/help', vedhelplist ) -> vedhelplist;
