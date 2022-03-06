compile_mode :pop11 +strict;

uses pop11_named_arg_mark;
uses dict;

section $-gospl$-named_args =>
    named_arg_group
    is_named_arg_group
    new_named_arg_group
    named_arg_group_merge_dict
    named_arg_group_insert
    named_arg_group_pop
    named_arg_group_to_dict
    named_arg_group_erase
    named_arg_group_length
    ;

;;; Hack for -uses-.
vars named_arg_group = _;


/*
    is_named_arg_group() -> bool
    new_named_arg_group() -> ( 0, pop11_named_arg_mark )
    named_arg_group_merge_dict( ..., N, pop11_named_arg_mark, dict ) -> ( ..., N', pop11_named_arg_mark )
    named_arg_group_insert( ..., N, pop11_named_arg_mark, keyword, value ) -> ( ..., N', pop11_named_arg_mark )
    named_arg_group_pop( ..., N, pop11_named_arg_mark )
        -> ( ..., N-1, pop11_named_arg_mark, keyword, value ) OR
        -> ( ..., N, pop11_named_arg_mark, false, termin )
    named_arg_group_to_dict( ..., N, pop11_named_arg_mark ) -> dict
    named_arg_group_erase( ..., N, pop11_named_arg_mark ) -> ()
*/

define to_twinlists() -> ( keyword_list, value_list, count );
    lvars ( count, m ) = ();
    unless m == pop11_named_arg_mark do
        mishap( 'Invalid named-arg group, missing named-arg mark', [^m] )
    endunless;
    [] -> keyword_list;
    [] -> value_list;
    repeat count times
        conspair( keyword_list ) -> keyword_list;
        conspair( value_list ) -> value_list;
    endrepeat;
enddefine;

define named_arg_group_to_twinlists();
    ;;; Discard the count.
    to_twinlists() -> _
enddefine;

define named_arg_group_merge_dict( dict );
    dlvars ( keyword_list, value_list, count ) = to_twinlists();

    ;;; KEY ASSUMPTION: The order of iteration across a dictionary is the
    ;;; same order as that that comes from to_twinlists.
    lvars count = (#|
        appdict(
            dict,
            procedure( key, value );
                while keyword_list.ispair then
                    lvars ( k, tail ) = fast_destpair( keyword_list );
                    if k == key then
                        back( value_list ) -> value_list;
                        tail -> keyword_list;
                        quitloop;
                    elseif ascending( k, key ) then
                        destpair( value_list ) -> value_list;
                        k;
                        tail -> keyword_list;
                    else
                        quitloop
                    endif
                endwhile;
                value, key
            endprocedure
        );
        while keyword_list.ispair do
            value_list.destpair -> value_list;
            keyword_list.fast_destpair -> keyword_list;
        endwhile;
    |#);

    count >> 1, pop11_named_arg_mark
enddefine;

define is_named_arg_group();
    ;;; GUARD
    returnif( stacklength() == 0 )( false );

    ;;; BODY
    if dup() == pop11_named_arg_mark then
        if stacklength() fi_>= 2 then
            lvars count = (restack n, mark -> n, mark, n);
            returnif( count.isinteger and count fi_>= 0 )( true );
            mishap( 'Invalid named-arg group, non-negative integer required', [^count] )
        else
            mishap( 'Invalid named-arg group, no items under the named-arg-mark', [] )
        endif
    else
        false
    endif
enddefine;

define new_named_arg_group();
    ( 0, pop11_named_arg_mark )
enddefine;

define named_arg_group_erase();
    lvars ( count, mark ) = ();
    if mark == pop11_named_arg_mark and count >= 0 then
        erasenum( count << 1 )
    else
        mishap( 'Invalid named-arg group', [^count ^mark] )
    endif
enddefine;

define named_arg_group_to_dict();
    if is_named_arg_group() then
        lvars ( count, _ ) = ();
        lvars even_list = [];
        repeat count times
            lvars ( v, k ) = ();
            conspair( k, conspair( v, even_list ) ) -> even_list
        endrepeat;
        newdict_from_evenlist( even_list );
        sys_grbg_list( even_list );
    else
        mishap( 'Not a named-arg group, conversion to dict failed', [] )
    endif
enddefine;

define named_arg_group_pop();    ;;;  -> ( keyword, value );
    lvars ( count, mark ) = ();
    if mark == pop11_named_arg_mark then
        if count <= 0 then  ;;; defensive.
            count, mark, false, termin
        else
            lvars ( v, k ) = ();
            count - 1, pop11_named_arg_mark, k, v
        endif
    else
        count, mark, false, termin
    endif
enddefine;

;;;
;;; It isn't fast!  It could be improved by avoiding grabbing all
;;; the keyword/value ... instead we could slowly work down the stack
;;; until we come to one that is smaller and then re-insert.
;;;
define named_arg_group_insert( keyword, value );
    lvars ( keyword_list, value_list, count ) = to_twinlists();
    repeat
        unless keyword_list.ispair do
            value, keyword;
            quitloop
        endunless;
        lvars k = keyword_list.destpair -> keyword_list;
        lvars v = value_list.destpair -> value_list;
        if ascending( keyword, k ) then
            value, keyword, v, k;
            for k, v in keyword_list, value_list do
                v, k
            endfor;
            quitloop
        endif;
        v, k;
    endrepeat;
    count + 1, pop11_named_arg_mark
enddefine;

define named_arg_group_length() -> count;
    lvars ( count, mark ) = ( restack n, m -> n, m, n, m );
    unless mark == pop11_named_arg_mark do
        mishap( 'Missing named-arg mark', [ ^mark ] )
    endunless;
    unless count.isinteger do
        mishap( 'Invalid count under named-arg mark', [ ^count ] )
    endunless;
enddefine;

endsection;
