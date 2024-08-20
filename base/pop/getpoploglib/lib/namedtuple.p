compile_mode :pop11 +strict;

section $-namedtuple =>
    isnamedtuple namedtuple_length
    subscr_namedtuple appnamedtuple is_null_namedtuple;

#_IF not( isdefined( "namedtuple_key" ) )

vars ejection_threshold = 1024;

define constant procedure clear_half( prop );
    lvars clear_these = (
        [%
            fast_appproperty(
                prop,
                procedure( k, v );
                    if random(1.0) < 0.5 then k endif
                endprocedure
            )
        %]
    );
    lvars k;
    for k in clear_these do
        fast_kill_prop_entry( k, prop ) -> _;
    endfor;
enddefine;

;;; This table is used to ensure keysets are not usually duplicated.
constant procedure namedtuple_table =
    newanyproperty(
        [], 8, 1, 8,
        syshash, nonop =, "tmpval",
        false,
        procedure( key, prop );
            ;;; Have we grown too big?
            if datalength( prop ) > ejection_threshold then
                clear_half( prop )
            endif;
            key ->> prop( key );
        endprocedure
    );

global constant namedtuple_key = conskey( "namedtuple", [ full full ] );
global constant procedure isnamedtuple = namedtuple_key.class_recognise;

constant procedure destnamedtuple = namedtuple_key.class_dest;
constant procedure consnamedtuple = namedtuple_key.class_cons;

;;; Not exported but retained for autoloading.
constant procedure namedtuple_keys = class_access( 1, namedtuple_key );
"namedtuple_keys" -> namedtuple_keys.pdprops;

;;; Not exported but retained for autoloading.
constant procedure namedtuple_values = class_access( 2, namedtuple_key );
"namedtuple_values" -> namedtuple_values.pdprops;

define global constant procedure namedtuple_length( nmtuple );
    nmtuple.namedtuple_values.datalength
enddefine;

define lconstant find( w, nmtuple );
    lvars lo = 1;
    lvars hi = nmtuple.namedtuple_values.datalength;
    repeat
        if lo < hi then
            lvars mid = ( lo fi_+ hi ) fi_>> 1;
            lvars midkey = subscrv( mid, nmtuple.namedtuple_keys );
            lvars cmp = alphabefore( w, midkey );
            if cmp then
                if cmp == 1 then
                    return( mid )
                else
                    mid fi_- 1 -> hi;
                endif
            else
                mid fi_+ 1 -> lo;
            endif
        elseif lo == hi and w == subscrv( lo, nmtuple.namedtuple_keys ) then
            return( hi )
        else
            mishap( 'Trying to index nmtuple with invalid', [ ^w ] )
        endif
    endrepeat
enddefine;

define global constant procedure subscr_namedtuple( w, nmtuple );
    subscrv( find( w, nmtuple ), nmtuple.namedtuple_values )
enddefine;

define updaterof subscr_namedtuple( item, w, nmtuple );
    item -> subscrv( find( w, nmtuple ), nmtuple.namedtuple_values )
enddefine;

subscr_namedtuple -> class_apply( namedtuple_key );

define global constant procedure appnamedtuple( nmtuple, procedure p );
    lvars i, n = nmtuple.namedtuple_length;
    for i from 1 to n do
        p(
            fast_subscrv( i, nmtuple.namedtuple_keys ),
            fast_subscrv( i, nmtuple.namedtuple_values )
        )
    endfor;
enddefine;

define global constant procedure is_null_namedtuple( nmtuple );
    nmtuple.namedtuple_values.datalength == 0
enddefine;

define prnamedtuple( nmtuple );
    pr( '$(' );
    unless nmtuple.is_null_namedtuple do pr( ' ' ) endunless;
    dlvars first = true;
    appnamedtuple(
        nmtuple,
        procedure( k, v );
            unless first then
                pr( ', ' )
            endunless;
            pr( k );
            pr( '=' );
            pr( v );
            false -> first;
        endprocedure
    );
    unless nmtuple.is_null_namedtuple do pr( ' ' ) endunless;
    pr( ')' );
enddefine;

prnamedtuple -> class_print( namedtuple_key );


define lconstant procedure check_duplicates( key_index_list );
    lvars tail;
    for tail on key_index_list do
        if fast_back( tail ).ispair then
            if fast_front( fast_front( tail ) ) == fast_front( fast_front( fast_back( tail ) ) ) then
                mishap( 'Trying to construct named tuple with non-unique key', [% front(front(tail)) %] )
            endif
        endif
    endfor;
enddefine;

;;;
;;; This is a helper function for building named tuples. It takes a list
;;; of unsorted pairs (key, position) and a vector of values and
;;; _takes ownership of these_ i.e. no other references to these parameters
;;; are usable after this function has run. This allows the values vector to
;;; be sorted and the list of pairs to be returned to the heap.
;;;
;;; newnamedtuple_internal<T>: [ pair< word, int > ] * { T } -> namedtuple< T >
;;;
define constant newnamedtuple_internal( key_index_list, values_vector );
    nc_listsort(
        key_index_list,
        procedure( x, y ); alphabefore( x.front, y.front ) endprocedure
    ) -> key_index_list;
    check_duplicates( key_index_list );
    lvars sorted_keys_vector = {% applist( key_index_list, front ) %};
    lvars sorted_values_vector = fill(
        lblock
            lvars p;
            for p in key_index_list do
                subscrv( p.back, values_vector )
            endfor
        endlblock,
        values_vector      ;;; !! reusing this vector !!
    );
    ;;; Now we can free up the working store.
    while key_index_list.ispair do
        ( key_index_list.sys_grbg_destpair -> key_index_list ).sys_grbg_destpair -> _ -> _;
    endwhile;
    ;;; And deliver the result.
    consnamedtuple( sorted_keys_vector.namedtuple_table, sorted_values_vector )
enddefine;

;;; This is a non-exported helper function for writing syntax words.
define compile_newnamedtuple_to( closing_keyword ) -> actual_closer;
    dlocal pop_new_lvar_list;
    lvars keys = [];
    lvars n = 0;
    lvars tmpvars = {%
        until pop11_try_nextreaditem( closing_keyword ) ->> actual_closer do
            while pop11_try_nextreaditem( "," ) do endwhile;
            n + 1 -> n;
            lvars k = readitem();                    ;;; TODO: must be a word
            unless k.isword do
                mishap( 'Expected word as namedtuple key', [^k] )
            endunless;
            conspair( k, n ) :: keys -> keys;
            pop11_need_nextreaditem( "=" ) -> _;
            dlvars tmpvar = sysNEW_LVAR();
            pop11_comp_N( procedure(); pop11_comp_expr(); sysPOP(tmpvar) endprocedure, 0 );
            tmpvar
        enduntil;
    %};
    nc_listsort(
        keys,
        procedure( x, y ); alphabefore( x.front, y.front ) endprocedure
    ) -> keys;
    check_duplicates( keys );
    sysPUSHQ( {% applist( keys, front ) %} );
    lvars p;
    for p in keys do
        sysPUSH( subscrv( p.back, tmpvars ) )
    endfor;
    sysPUSHQ( tmpvars.datalength );
    sysCALL( "consvector" );
    sysCALLQ( consnamedtuple );
enddefine;

#_ENDIF

endsection;
