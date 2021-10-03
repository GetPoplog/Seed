compile_mode :pop11 +strict;

section;

;;;
;;;     splitstring( string, separator ) -> vector
;;;     splitstring( string, separator, maxsplit: int_or_false, constructor: procedure ) -> constructor( N )
;;;
define global splitstring() with_props 2;
    lvars s, sep, maxsplit, procedure constructor;

    ;;; Set default values for optionals.
    consvector -> constructor;
    false -> maxsplit;

    ;;; Decode optional arguments directly from the stack.
    if not(dup().isregexp) and dup().isprocedure then
        () -> ( maxsplit, constructor );
    endif;

    () -> ( s, sep );

    if sep.isstring then
        if sep.datalength == 1 then
            ;;; Take advantage of locchar.
            subscrs( 1, sep ) -> sep
        endif
    elseunless sep.isinteger or sep.isregexp then
        mishap( 'Invalid separator for split', [ ^sep ] )
    endif;

    unless s.isstring then
        mishap( 'Invalid argument for splitstring', [ ^s ] )
    endunless;

    if maxsplit == false or maxsplit == _ do
        ;;; Stop maxsplit ever being a limit by making it 'big enough'.
        datalength(s) + 1 -> maxsplit;
    endif;

    ;;; Deal separately with regular expressions and string/integer separators.
    if sep.isregexp then
        constructor(#|
            lvars position = 1;
            lvars count = 0;
            lvars s_len = datalength( s );
            repeat
                if position > s_len then
                    '';
                    quitloop
                endif;
                lvars ( n, sep_n ) = if maxsplit > count then sep( position, s, false, false ) else false, false endif;
                if n then
                    substring( position, n - position, s );
                    count fi_+ 1 -> count;
                    n + sep_n -> position;
                else
                    lvars len = s_len fi_- position fi_+ 1;
                    substring( position, s.datalength - position + 1, s );
                    quitloop
                endif
            endrepeat
        |#)
    else
        lvars ( procedure finder, sep_n ) = (
            if sep.isstring then
                lvars d = sep.datalength;
                if d == 0 then
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
            lvars count = 0;
            repeat
                lvars n = (maxsplit > count) and finder( sep, position, s );
                if n then
                    substring( position, n - position, s );
                    count fi_+ 1 -> count;
                    n + sep_n -> position;
                else
                    lvars len = s.datalength - position + 1;
                    substring( position, len, s );
                    quitloop
                endif
            endrepeat
        |#)
    endif
enddefine;

endsection;
