compile_mode :pop11 +strict;

section dict => is_key_in_dict;

define global constant procedure is_key_in_dict( name, dict );
    find( name, dict, pop_undef ) and true
enddefine;

endsection;
