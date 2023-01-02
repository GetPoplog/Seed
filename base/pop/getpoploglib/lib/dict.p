compile_mode :pop11 +strict;

section $-dict =>
    dict_key isdict dict_length
    subscr_dict appdict is_null_dict
    null_dict, newdict_from_stack;

#_IF not( isdefined( "dict_key" ) )

constant ejection_threshold = 1024;

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
constant procedure dict_table =
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

global constant dict_key = conskey( "dict", [ full full ] );
global constant procedure isdict = dict_key.class_recognise;
"isdict" -> isdict.pdprops;

constant procedure destdict = dict_key.class_dest;
constant procedure consdict = dict_key.class_cons;

global constant nulldict = consdict( {}.dup );

;;; Not exported but retained for autoloading.
constant procedure dict_keys = class_access( 1, dict_key );
"dict_keys" -> dict_keys.pdprops;

;;; Not exported but retained for autoloading.
constant procedure dict_values = class_access( 2, dict_key );
"dict_values" -> dict_values.pdprops;

define global constant procedure dict_length( dict );
    dict.dict_values.datalength
enddefine;

;;;
;;; Returns the position of the word -name- in the keys_vector of -dict-.
;;; When -name- does not appear in the keys vector the behvaiour is determined by
;;; the parameter count_preceding
;;;  - If count_preceding is true it returns the number of keys that 
;;;    precede -name- as ordered by -alphabefore-. 
;;;  - If count_preceding is -pop_undef- it returns -false-.
;;;
define constant procedure find( name, dict, count_preceding );
    lvars keys_vector = dict.dict_keys; ;;; Final.
    lvars N = keys_vector.datalength;   ;;; Final.
    lvars lo = 1;
    lvars hi = N;
    repeat
        if lo < hi then
            lvars mid = ( lo fi_+ hi ) fi_>> 1;
            lvars midkey = subscrv( mid, keys_vector );
            lvars cmp = alphabefore( name, midkey );
            if cmp then
                if cmp == 1 then
                    return( mid )
                else
                    mid fi_- 1 -> hi;
                endif
            else
                mid fi_+ 1 -> lo;
            endif
        elseif lo == hi and name == subscrv( lo, keys_vector ) then
            return( lo )
        elseif count_preceding == pop_undef then
            return( false )
        elseif count_preceding == true then
            ;;; Return the count of the keys before name.
            returnif( N == 0 )( 0 );
            ;;; There is at least 1 key (and name is different from that key)
            returnif( alphabefore( name, subscrv( 1, keys_vector ) ) )( 0 );
            returnif( alphabefore( subscrv( N, keys_vector ), name ) )( N );
            ;;; There are at least 2 keys and name is sandwiched between two keys.
            ;;; Also lo is either the element before name or the element after name.
            returnif( lo == 1 )( 1 );
            returnif( lo == N )( N - 1 );
            ;;; And we know that 2 <= lo <= N - 1 so keys_vector( lo +/- 1 ) is safe.
            lvars key_below = subscrv( lo fi_- 1, keys_vector );
            lvars key_at = subscrv( lo, keys_vector );
            lvars key_after = subscrv( lo fi_+ 1, keys_vector );
            returnif( alphabefore( key_below, name ) and alphabefore( name, key_at ) )( lo fi_- 1 );
            returnif( alphabefore( key_at, name ) and alphabefore( name, key_after ) )( lo );
            mishap( 0, 'INTERNAL ERROR IN dict$-find' )
        else
            mishap( 'Trying to index dict with invalid key', [ ^name ] )
        endif
    endrepeat
enddefine;

define global constant procedure subscr_dict( w, dict );
    subscrv( find( w, dict, false ), dict.dict_values )
enddefine;

define updaterof subscr_dict( item, w, dict );
    item -> subscrv( find( w, dict, false ), dict.dict_values )
enddefine;

subscr_dict -> class_apply( dict_key );

define global constant procedure appdict( dict, procedure p );
    lvars ( keys, values ) = dict.destdict;
    lvars i, n = datalength( keys );
    fast_for i from 1 to n do
        p(
            subscrv( i, keys ),
            subscrv( i, values )
        )
    endfast_for;
enddefine;

define global constant procedure is_null_dict( dict );
    dict.dict_values.datalength == 0
enddefine;

define prdict( dict );
    pr( '${' );
    unless dict.is_null_dict do pr( ' ' ) endunless;
    dlvars first = true;
    appdict(
        dict,
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
    unless dict.is_null_dict do pr( ' ' ) endunless;
    pr( '}' );
enddefine;

prdict -> class_print( dict_key );


define lconstant procedure check_duplicates( key_index_list );
    lvars tail;
    for tail on key_index_list do
        if fast_back( tail ).ispair then
            if fast_front( fast_front( tail ) ) == fast_front( fast_front( fast_back( tail ) ) ) then
                mishap( 'Trying to construct dict with non-unique key', [% front(front(tail)) %] )
            endif
        endif
    endfor;
enddefine;

define lconstant gather_triples( N ) -> ( triples_list );
    lvars i, triples_list = [];
    fast_for i from 1 to (N >> 1) do
        lvars ( k, v ) = ();
        unless k.isword do
            mishap( k, 1, 'Word needed' )
        endunless;
        lvars t = conspair( conspair( k, i ), v );
        conspair( t, triples_list ) -> triples_list;
    endfast_for;
enddefine;

define lconstant sort_triples_list( triples_list );
    nc_listsort(
        triples_list,
        procedure( t1, t2 );
            lvars ( k1, i1 ) = fast_destpair( fast_front( t1 ) );
            lvars ( k2, i2 ) = fast_destpair( fast_front( t2 ) );
            if k1 == k2 then
                i2 > i1
            else
                alphabefore( k1, k2 )
            endif
        endprocedure
    )
enddefine;

define constant newdict_internal( keys_vector, values_vector );
    consdict( keys_vector.dict_table, values_vector )
enddefine;

define constant newdict_from_stack( N );
    lvars triples_list = gather_triples( N ).sort_triples_list;
    
    ;;; Iterate over the triples in sorted order, skipping duplicate keys,
    ;;; and dump the values on the stack in order to form a vector. At the 
    ;;; same time create a matching list of keys in reverse order. We delete the
    ;;; triples and list spine as we go.
    lvars rev_keys_list = [];
    lvars values_vector = {%
        lvars prev_k = false;            ;;; Any non-word could do here.
        while triples_list.ispair do
            lvars triple = sys_grbg_destpair( triples_list ) -> triples_list;
            lvars ( ki, v ) = sys_grbg_destpair( triple );
            lvars k = sys_grbg_destpair( ki ) -> _;
            if k /== prev_k then
                conspair( k, rev_keys_list ) -> rev_keys_list;
                v
            endif;
            k -> prev_k
        endwhile
    %};

    ;;; Now populate a keys vector in reverse order, deleting the reversed list
    ;;; as we go.
    lvars n2 = datalength( values_vector );
    lvars keys_vector = initv( n2 );
    while rev_keys_list.ispair do
        quitif( n2 == 0 );
        sys_grbg_destpair( rev_keys_list ) -> rev_keys_list -> fast_subscrv( n2, keys_vector );
        n2 fi_- 1 -> n2;
    endwhile; 

    newdict_internal( keys_vector.dict_table, values_vector )
enddefine;

;;; This is a non-exported helper function for writing syntax words.
define compile_newdict_to( closing_keyword ) -> actual_closer;
    dlocal pop_new_lvar_list;
    lvars keys = [];
    lvars n = 0;
    lvars tmpvars = {%
        until pop11_try_nextreaditem( closing_keyword ) ->> actual_closer do
            while pop11_try_nextreaditem( "," ) do endwhile;
            n + 1 -> n;
            lvars k = readitem();                    ;;; TODO: must be a word
            unless k.isword do
                mishap( 'Expected word as dict key', [^k] )
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
    if keys.null then
        sysPUSH( "nulldict" ); 
    else
        check_duplicates( keys );
        sysPUSHQ( {% applist( keys, front ) %} );
        lvars p;
        for p in keys do
            sysPUSH( subscrv( p.back, tmpvars ) )
        endfor;
        sysPUSHQ( tmpvars.datalength );
        sysCALL( "consvector" );
        sysCALLQ( consdict );
    endif
enddefine;

#_ENDIF

endsection;
