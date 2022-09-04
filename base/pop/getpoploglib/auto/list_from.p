compile_mode :pop11 +strict;

section;

;;; list_from( n: num ) -> [ n, n+1, ... ]
;;; list_from( item, p: item -> item ) -> [ item, p(item), p(p(item)), ... ]
define global list_from() with_nargs 1;
    repeater_from( /* take args from stack */ ).pdtolist
enddefine;

endsection;
