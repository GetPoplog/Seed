compile_mode :pop11 +strict;

section;

define json_println( x );
    json_print( x );
    nl( 1 );
enddefine;

endsection;
