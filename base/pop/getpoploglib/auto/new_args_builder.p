compile_mode :pop11 +strict;

section;

;;; Start off small but quickly shift to a bigger buffer size.
lconstant initial_size = 64, bigger_size = 256;
lvars size = initial_size;

define lconstant boom( dump ) -> flag;
    if dump.ispair then
        lvars ( d, rest ) = dump.destpair;
        boom( rest ) -> flag;
        explode( d )
    else
        dump -> flag
    endif
enddefine;

define new_args_builder( constructor );
    lvars reusable = false;
    if constructor.isboolean then
        constructor -> reusable;
        () -> constructor;
    endif;
    unless constructor.isprocedure do
        mishap( constructor, 1, 'Procedure needed' )
    endunless;

    lvars buffer = false;
    lvars index = 0;
    lvars dump = [];        ;;; A list of filled string buffers.
    lvars ndump = 0;        ;;; The number of characters in the dump.

    procedure( ch );
        lconstant dead_msg = 'Applying a dead accumulator';
        if ch == termin then
            unless ndump do
                mishap( ch, 1, dead_msg )
            endunless;
            lvars more_flag = boom( dump );
            lvars i;
            fast_for i from 1 to index do
                fast_subscrv( i, buffer )
            endfor;
            unless more_flag do
                false -> buffer;    ;;; free space AND avoid performance critical code
                false -> ndump;
                false -> dump;      ;;; free space
            endunless;
            return( constructor( ndump + index ) );
        elseif buffer then
            if index == size then
                size + ndump -> ndump;
                conspair( buffer, dump ) -> dump;
                bigger_size -> size;
                initv( size ) -> buffer;
                0 -> index;
            endif;
            index fi_+ 1 -> index;
            ch -> fast_subscrv( index, buffer );
        else
            unless ndump do
                mishap( ch, 1, dead_msg )
            endunless;
            initv( size ) -> buffer;
            1 -> index;
            ch -> fast_subscrv( 1, buffer );
        endif
    endprocedure
enddefine;

endsection;
