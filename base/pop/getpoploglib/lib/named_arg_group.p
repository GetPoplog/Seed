compile_mode :pop11 +strict;

uses pop11_named_arg_mark;

section $-gospl$-named_args =>
    is_named_arg_group
    new_named_arg_group
    named_arg_group_merge_dict
    named_arg_group_insert_named_arg
    named_arg_group_pop
    named_arg_group_to_dict
    named_arg_group_erase
    ;


/*
    is_named_arg_group() -> bool
    new_named_arg_group() -> ( 0, pop11_named_arg_mark )
    named_arg_group_merge_dict( ..., N, pop11_named_arg_mark, dict ) -> ( ..., N', pop11_named_arg_mark )
    named_arg_group_insert_named_arg( ..., N, pop11_named_arg_mark, keyword, value ) -> ( ..., N', pop11_named_arg_mark )
    named_arg_group_pop( ..., N, pop11_named_arg_mark )
        -> ( ..., N-1, pop11_named_arg_mark, keyword, value ) OR
        -> ( ..., N, pop11_named_arg_mark, false, termin )
    named_arg_group_to_dict( ..., N, pop11_named_arg_mark ) -> dict
    named_arg_group_erase( ..., N, pop11_named_arg_mark ) -> ()
*/

define named_arg_group_merge_dict( count, mark, dict );
    ;;; TODO
enddefine;

define is_named_arg_group();
    ;;; GUARD
    returnif( stacklength() == 0 )( false );

    ;;; BODY
    if dup() == pop11_named_arg_mark then
        if stacklength() fi_>= 2 then
            lvars count = (restack n, mark -> n, mark, n);
            returnif( count.isinteger and count >= 0 );
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
        lvars even_list = conslist( count << 1 );
        newdict_from_evenlist( even_list );
        sys_grbg_list( even_list );
    else
        mishap( 'Not a named-arg group, conversion to dict failed', [] )
    endif
enddefine;

define named_arg_group_pop();    ;;;  -> ( keyword, value );
    lvars count, mark = ();
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
define named_arg_group_insert_named_arg( keyword, value );
    lvars ( n, m ) = ();
    unless m == pop11_named_arg_mark do
        mishap( 'Invalid named-arg group, missing named-arg mark', [^m] )
    endunless;
    lvars keyword_list = [];
    lvars value_list = [];
    repeat n times
        conspair( keyword_list ) -> keyword_list;
        conspair( value_list ) -> value_list;
    endrepeat;
    repeat
        unless keyword_list.ispair do
            value, keyword;
            quitloop
        endunless;
        lvars k = keyword_list.destpair -> keyword_list;
        lvars v = value_list.destpair -> value_list;
        if keyword.order_of_appearance < k.order_of_appearance then
            value, keyword, v, k;
            for k, v in keyword_list, value_list do
                v, k
            endfor;
            quitloop
        endif;
        v, k;
    endrepeat;
    n + 1, pop11_named_arg_mark
enddefine;

endsection;
