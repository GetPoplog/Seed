compile_mode :pop11 +strict;

section $-dict => newdict_from_twinlists;

uses dict

define global constant procedure newdict_from_twinlists( keys_list, values_list );
    lvars alist = [];
    until keys_list.null or values_list.null do
        lvars k = keys_list.fast_destpair -> keys_list;
        lvars v = values_list.fast_destpair -> values_list;
        conspair( [ ^k ^v ], alist ) -> alist;
    enduntil;
    newdict_from_assoclist( alist );
enddefine;

endsection;
