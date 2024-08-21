compile_mode :pop11 +strict;

section $-namedtuple => newnamedtuple_from_assoclist;

uses namedtuple

define global constant procedure newnamedtuple_from_assoclist( list );
    fast_make_namedtuple_from_unsorted(
        (#| applist( list, hd ) |#),
        (#| applist( list, procedure( p ); lvars p; p.fast_back.hd endprocedure ) |#)
    )
enddefine;

endsection;
