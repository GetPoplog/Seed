compile_mode :pop11 +strict;

section;

define global splitstring() with_props 3;
    lvars s, sep, procedure constructor;
    if dup().isprocedure then
        () -> ( s, sep, constructor );
    else
        consvector -> constructor;
        () -> ( s, sep )
    endif;
    lvars ( procedure finder, sep_n ) = (
        if sep.isstring then
            if sep.datalength == 0 then
                mishap( 'Invalid empty separator argument', [^sep] )
            endif;
            ( issubstring, datalength(sep) )
        elseif sep.isinteger then
            ( locchar, 1 )
        else
            mishap( 'Unexpected separator', [^sep] )
        endif
    );
    constructor(#|
        lvars position = 1;
        repeat
            lvars n = finder( sep, position, s);
            if n then
                substring( position, n - position, s );
                n + sep_n -> position;
            else
                substring( position, s.datalength - position + 1, s );
                quitloop
            endif
        endrepeat
    |#)
enddefine;

endsection;
