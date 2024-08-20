compile_mode :pop11 +strict;

section $-namedtuple => newnamedtuple_from_twinlists;

uses namedtuple

define global constant procedure newnamedtuple_from_twinlists( keys_list, values_list );
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
    newnamedtuple_internal( keys, values );
enddefine;

endsection;
