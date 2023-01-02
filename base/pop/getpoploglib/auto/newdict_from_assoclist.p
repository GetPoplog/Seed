compile_mode :pop11 +strict;

uses dict

section dict => newdict_from_assoclist;

define global constant procedure newdict_from_assoclist( list );
    newdict_from_stack(#| applist( list, procedure( x ); x.dest.hd endprocedure ) |#)
enddefine;

endsection;
