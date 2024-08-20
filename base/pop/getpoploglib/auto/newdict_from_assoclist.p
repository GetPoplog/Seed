compile_mode :pop11 +strict;

section $-dict => newdict_from_assoclist;

uses dict

define global constant procedure newdict_from_assoclist( list );
    newanyproperty(
        list,
        max( 8, list.length ),
        1,
        false,
        false,
        false,
        "perm",
        false,
        false
    )
enddefine;

endsection;
