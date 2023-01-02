compile_mode :pop11 +strict;

section dict => dict_copy;

define global constant procedure dict_copy( dict );
    lvars ( keys_vector, values_vector ) = dict.destdict;
    consdict( keys_vector, values_vector.copy )
enddefine;

endsection;
