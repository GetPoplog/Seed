compile_mode :pop11 +strict;

section dict => newdict_from_twinlists;

uses dict

define global constant procedure newdict_from_twinlists( keys_list, values_list );
    newdict_from_stack(#|
        lvars i, j;
        for i, j in keys_list, values_list do
            i, j
        endfor
    |#)
enddefine;

endsection;
