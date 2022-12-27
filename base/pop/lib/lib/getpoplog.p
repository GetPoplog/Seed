;;; This library adds the extns folder to the searchlists.
;;; N.B. This code is
;;;     - section independent
;;;     - safe against multiple reloads

extend_searchlist( '$usepop/pop/getpoploglib/auto', popautolist ) -> popautolist;
extend_searchlist( '$usepop/pop/getpoploglib/lib', popuseslist ) -> popuseslist;
extend_searchlist( '$usepop/pop/getpoploglib/help', vedhelplist ) -> vedhelplist;
