compile_mode :pop11 +strict;

section;

uses dict

define global constant procedure newdict_from_twinlists( keys_list, values_list );
    lvars keys = [];
    lvars values = {%
        lvars n = 0;
        until keys_list.null or values_list.null do
            n fi_+ 1 -> n;
            lvars k = keys_list.fast_destpair -> keys_list;
            lvars v = values_list.fast_destpair -> values_list;
            conspair( conspair( k, n ), keys ) -> keys;
            v ;;; put values in historical order into a vector.
        enduntil
    %};
    newdict_internal( keys, values );
enddefine;

endsection;
