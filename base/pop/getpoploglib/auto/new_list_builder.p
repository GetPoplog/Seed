compile_mode :pop11 +strict;

section;

define lconstant list_builder( item, first_pair_ref, last_pair_ref );
    if item == termin then
        lvars first_pair = fast_cont( first_pair_ref );
        lvars result = fast_back( first_pair );
        nil -> fast_back( first_pair );
        first_pair -> fast_cont( last_pair_ref );
        result
    else
        lvars last_pair = fast_cont( last_pair_ref );
        conspair( item, nil ) ->> fast_back( last_pair ) -> fast_cont( last_pair_ref )
    endif
enddefine;

define global new_list_builder();
    lvars first_pair = conspair( _, nil );
    lvars last_pair = first_pair;
    list_builder(% consref( first_pair ), consref( last_pair ) %)
enddefine;

define global is_list_builder( p );
    p.isclosure and p.pdpart == list_builder
enddefine;

define global list_builder_copylist( p );
    if p.is_list_builder then
        copylist( frozval( 1, p ).cont.back )
    else
        mishap( 'List builder required', [^p] )
    endif
enddefine;

define global list_builder_push_front( item, p );
    if p.is_list_builder then
        lvars r = frozval( 1, p );
        lvars s = frozval( 2, p );
        lvars same = r.cont == s.cont;
        conspair( item, r.cont.back ) -> r.cont.back;
        if same then
            r.cont.back -> s.cont
        endif
    else
        mishap( 'List builder required', [^p] )
    endif
enddefine;

define global list_builder_push_back( item, p );
    if p.is_list_builder then
        p( item )
    else
        mishap( 'List builder required', [^p] )
    endif
enddefine;

define global list_builder_newlist( p );
    if p.is_list_builder then
        p( termin )
    else
        mishap( 'List builder required', [^p] )
    endif
enddefine;

endsection;
