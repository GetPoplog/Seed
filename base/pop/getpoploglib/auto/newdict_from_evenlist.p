compile_mode :pop11 +strict;

section $-dict =>
    newdict_from_evenlist
    ;

uses dict;

define global constant procedure newdict_from_evenlist( list );
    lvars keys = [];
    lvars values = {%
        lvars n = 0;
        until null( list ) do
            lvars ( v, k ) = dest( fast_destpair( list ) ) -> list;
            n fi_+ 1 -> n;
            conspair( conspair( k, n ), keys ) -> keys;
            v ;;; put values in historical order into a vector.
        enduntil
    %};
    newdict_internal( keys, values )
enddefine;

endsection;
