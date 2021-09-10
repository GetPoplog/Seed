compile_mode :pop11 +strict;

section;

uses dict

define global constant procedure newdict_from_assoclist( list );
    lvars keys = [];
    lvars values = {%
        lvars p, n = 0;
        for p in list do
            n fi_+ 1 -> n;
            lvars ( k, v ) = p.dest.hd;
            conspair( conspair( k, n ), keys ) -> keys;
            v ;;; put values in historical order into a vector.
        endfor
    %};
    newdict_internal( keys, values )
enddefine;

endsection;
