compile_mode :pop11 +strict;

section;

;;; repeater_from( n: num )
;;; repeater_from( item, p: item -> item )
define global repeater_from( n );
    if n.isnumber then
        procedure();
            n;
            n + 1 -> n;
        endprocedure
    elseif n.isprocedure then
        lvars p = n;
        lvars n = ();
        procedure();
            n;
            p( n ) -> n
        endprocedure
    else
        mishap( 'Unexpected argument', [^n] )
    endif
enddefine;

endsection;
