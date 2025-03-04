compile_mode :pop11 +strict;

uses kwargs_lib;

section $-kwargs =>
    kwargs_pile,
    kwargs_pile_to_twinlists
    new_kwargs_pile
    kwargs_pile_to_dict
    dict_to_kwargs_pile
    kwargs_pile_erase
    kwargs_pile_length
    kwargs_pile_normalise
    kwargs_pile_add
    kwargs_pile_extend
    ;

;;; Hack for -uses-.
vars kwarg_pile  = _;

define constant verify_kwargs_pile();
    lvars m = ();
    unless m == pop_kwargs_top_mark do
        mishap( m, 1, 'Invalid kwargs-pile, missing top mark' )
    endunless;
enddefine;

define kwargs_pile_normalise() with_nargs 1;
    verify_kwargs_pile();
    lvars pairs = [];
    repeat
        lvars arg = ();
        quitif( arg == pop_kwargs_bottom_mark );
        lvars kw = ();
        conspair( conspair( kw, arg ), pairs ) -> pairs
    endrepeat;
    nc_listsort(
        pairs,
        procedure( a, b );
            alphabefore( a.front, b.front )
        endprocedure
    ) -> pairs;
    pop_kwargs_bottom_mark;
    lvars prev_k = false;
    while pairs.ispair do
        lvars p = pairs.sys_grbg_destpair -> pairs;
        lvars k = p.front;
        if k == prev_k then
            () -> _;
            sys_grbg_destpair( p ) -> p -> _;
            p
        else
            sys_grbg_destpair( p )
        endif;
        k -> prev_k
    endwhile;
    pop_kwargs_top_mark
enddefine;

define kwargs_pile_add( key, value ) with_nargs 3;
    verify_kwargs_pile();
    key, value, pop_kwargs_top_mark
enddefine;

define kwargs_pile_extend( maplike ) with_nargs 2;
    verify_kwargs_pile();
    if maplike.isdict then
        appdict( maplike, identfn )
    elseif maplike.isproperty then
        fast_appproperty(
            maplike,
            procedure( k, v );
                if k.isword then
                    k, v
                else
                    mishap( k, 1, 'Trying to use a non-word as a keyword' )
                endif
            endprocedure
        )
    else
        mishap( maplike, 1, 'Not a map-like object (or unrecognised)' )
    endif;
    pop_kwargs_top_mark
enddefine;

define kwargs_pile_to_twinlists() -> ( keyword_list, value_list ) with_nargs 1;
    verify_kwargs_pile();
    [] -> keyword_list;
    [] -> value_list;
    repeat
        lvars arg = ();
        quitif( arg == pop_kwargs_bottom_mark );
        conspair( (), keyword_list ) -> keyword_list;
        conspair( arg, value_list ) -> value_list;
    endrepeat;
enddefine;

define new_kwargs_pile();
    ( pop_kwargs_bottom_mark, pop_kwargs_top_mark )
enddefine;

define kwargs_pile_erase() with_nargs 1;
    verify_kwargs_pile();
    until () == pop_kwargs_bottom_mark do
    enduntil;
enddefine;

define kwargs_pile_to_dict() -> d with_nargs 1;
    lvars ( K, V ) = kwargs_pile_to_twinlists();
    newdict_from_twinlists( K, V ) -> d;
    sys_grbg_list( K );
    sys_grbg_list( V );
enddefine;

define dict_to_kwargs_pile( dict );
    pop_kwargs_bottom_mark;
    appdict( dict, identfn );
    pop_kwargs_top_mark
enddefine;

define kwargs_pile_length() -> count with_nargs 1;
    verify_kwargs_pile();
    lvars n = 1;
    until subscr_stack( n ) == pop_kwargs_bottom_mark do
        n fi_+ 1 -> n
    enduntil;
    n fi_>> 1 -> count;
    pop_kwargs_top_mark
enddefine;

endsection;
