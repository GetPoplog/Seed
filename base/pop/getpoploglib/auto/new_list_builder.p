compile_mode :pop11 +strict;

section;

define new_list_builder();
    lvars first_pair = conspair( _, nil );
    lvars last_pair = first_pair;
    procedure( item ) with_props list_builder;
        if item == termin then
            lvars result = fast_back( first_pair );
            nil -> fast_back( first_pair );
            first_pair -> last_pair;
            result
        else
            conspair( item, nil ) ->> fast_back( last_pair ) -> last_pair
        endif
    endprocedure 
enddefine;

endsection;