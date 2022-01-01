compile_mode :pop11 +strict;

section;

define global strpr( N );
    lvars L = conslist( N );
    dlocal cucharout = new_string_builder( false );
    applist( L, pr );
    cucharout( termin );
    sys_grbg_list( L );
enddefine;

endsection;