compile_mode :pop11 +strict;

uses dict

section $-dict => destdict_values;

define global constant procedure destdict_values( dict );
    dict.dict_values.destvector
enddefine;

endsection;
