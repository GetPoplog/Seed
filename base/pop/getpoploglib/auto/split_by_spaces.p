compile_mode :pop11 +strict;

section;

;;;
;;; split_by_spaces( s, [maxsplit], [constructor] ) -> constructor( N )
;;;
define global procedure split_by_spaces() with_props 1;
    lvars s, maxsplit, constructor;

    false -> maxsplit;
    consvector -> constructor;

    if dup().isprocedure then
        () -> constructor
    endif;

    if dup().isinteger or dup() == false or dup() == _ do
        () -> maxsplit;
        if maxsplit == _ then
            false -> maxsplit
        endif
    endif;

    () -> s;
    unless s.isstring then
        mishap( 'Invalid argument for splitstring', [ ^s ] )
    endunless;
    if maxsplit == false or maxsplit == _ do
        ;;; Stop maxsplit ever being a limit by making it 'very big'.
        datalength(s) + 1 -> maxsplit;
    endif;

    constructor(#|
        lvars position = 1;
        lvars count = 0;
        repeat
            skipchar( ` `, position, s ) -> position;
            quitunless( position );

            if count >= maxsplit then
                substring( position, s.datalength - position + 1, s );
                quitloop
            endif;

            lvars n = locchar( ` `, position, s);
            if n then
                substring( position, n - position, s );
                count fi_+ 1 -> count;
                n -> position;
            else
                lvars len = s.datalength - position + 1;
                substring( position, len, s );
                quitloop
            endif
        endrepeat
    |#)
enddefine;

endsection;
