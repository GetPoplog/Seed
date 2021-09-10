compile_mode :pop11 +strict;

uses dict

section $-dict => destdict_keys;

define global constant procedure destdict_keys( dict );
    dict.dict_keys.destvector
enddefine;

endsection;
