compile_mode :pop11 +strict;

section;

lconstant size = 1024;

define lconstant copy_across( idx_in, dump, result );
    if dump.ispair then
        lvars ( d, rest ) = dump.destpair;
        lvars ( idx_next, more_flag ) = copy_across( idx_in, rest, result );
        lvars n = datalength( d );
        move_bytes( 1, d, idx_next, result, n );
        ( idx_next + n, more_flag )
    else
        ( idx_in, dump )
    endif
enddefine;

define global constant procedure new_string_builder( more );

    lvars buffer = false;
    lvars index = 0;
    lvars dump = more and true;     ;;; bool terminated list of strings.
    lvars ndump = 0;                ;;; The number of characters in the dump.
                                    ;;; ... doubles up as dead flag.

    procedure( ch );
        lconstant dead_msg = 'Applying a dead accumulator';
        if ch == termin then
            unless ndump do
                mishap( ch, 1, dead_msg )
            endunless;
            lvars result = inits( ndump + index );
            lvars ( idx, more_flag ) = copy_across( 1, dump, result );
            if buffer then move_bytes( 1, buffer, idx, result, index ) endif;
            unless more_flag do
                false -> buffer;    ;;; free space AND avoid performance critical code
                false -> ndump;
                false -> dump;      ;;; free space
            endunless;
            return( result )
        elseif ch.isinteger then
            if buffer then
                ;;; Performance critical - must execute fast.
                if index == size then
                    size + ndump -> ndump;
                    conspair( buffer, dump ) -> dump;
                    inits( size ) -> buffer;
                    0 -> index;
                endif;
                index fi_+ 1 -> index;
                ch -> fast_subscrs( index, buffer );
            else
                unless ndump do
                    mishap( ch, 1, dead_msg )
                endunless;
                inits( size ) -> buffer;
                1 -> index;
                ch -> fast_subscrs( 1, buffer );
            endif
        elseif ch.isstring or ch.isword then
            appdata( ch, caller(0) )
        else
            mishap( 'Cannot add unexpected item to in-progress string', [^ch] )
        endif
    endprocedure
enddefine;

endsection;
