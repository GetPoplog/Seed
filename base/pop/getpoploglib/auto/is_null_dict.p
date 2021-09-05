compile :pop11 +strict;

section $-dict => is_null_dict;

define global constant procedure is_null_dict( dict );
    dict.dict_values.datalength == 0
enddefine;

endsection;
