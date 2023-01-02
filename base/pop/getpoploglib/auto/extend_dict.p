compile_mode :pop11 +strict;

uses dict

section dict => extend_dict;

uses dict

define global constant procedure extend_dict( name, value, dict );
    lvars (keys_vector, values_vector) = destdict( dict );
    lvars count = datalength( values_vector );
    lvars n = find( name, dict, true );
    if subscrv( n, keys_vector ) == name then
        values_vector.copy -> values_vector;
        value -> subscrv( n, values_vector );
        consdict( keys_vector, values_vector )
    elseif n == 0 then
        newdict_internal( {^name ^^keys_vector}, {^value ^^values_vector} )
    else
        ;;; -n- is the numbers of keys that precedes -name-.
        lvars new_keys_vector = {%
            lvars i;
            fast_for i from 1 to count do
                subscrv( i, keys_vector );
                if i == n then
                    name
                endif
            endfast_for
        %};
        lvars new_values_vector = {%
            lvars i;
            fast_for i from 1 to count do
                subscrv( i, values_vector );
                if i == n then
                    value
                endif
            endfast_for
        %};
        newdict_internal( new_keys_vector, new_values_vector )
    endif
enddefine;

endsection;
