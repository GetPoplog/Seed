compile_mode :pop11 +strict;

section $-namedtuple =>
    isnamedtuple namedtuple_length nullnamedtuple
    subscr_namedtuple appnamedtuple is_null_namedtuple;

#_IF not( isdefined( "namedtupleN_key" ) )

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
constant procedure intern_table =
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


defclass namedtupleN {
    namedtupleN_keyset,
    namedtupleN_values
};

global constant nullnamedtuple = consnamedtupleN( {}.dup );

constant
    LOW_RECORD_SIZE = 2,
    LOW_RECORD_SIZE_1 = LOW_RECORD_SIZE - 1,
    HIGH_RECORD_SIZE = 5;

constant namedtuple_record_keys = [% ;;; ^namedtuple2_key ^namedtuple3_key ^namedtuple4_key ];
    lblock
        lvars i;
        for i from LOW_RECORD_SIZE to HIGH_RECORD_SIZE do
            conskey( ( 'namedtuple' >< i ).consword, [% dupnum( "full", i+1) %] )
        endfor
    endlblock
%];
constant namedtuple_record_keys_vector = namedtuple_record_keys.destlist.consvector;

define isnamedtuple_recordclass( t );
    lvars k;
    ( t.isrecordclass ->> k ) and fast_lmember( k, namedtuple_record_keys ) and k
enddefine;

define global constant procedure namedtuple_length( t );
    lvars rec_key;
    if t.isnamedtupleN then
        t.namedtupleN_values.datalength
    elseif t.isnamedtuple_recordclass ->> rec_key then
        class_datasize( rec_key )
    else
        mishap( t, 1, 'Named-tuple required' )
    endif
enddefine;


define lconstant find( w, keyset, t );
    lvars lo = 1;
    lvars hi = keyset.datalength;
    repeat
       if lo < hi then
            lvars mid = ( lo fi_+ hi ) fi_>> 1;
            lvars midkey = subscrv( mid, keyset );
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
        elseif lo == hi and w == subscrv( lo, keyset ) then
            return( hi )
        else
            mishap( 'Trying to index named tuple with invalid index', [ ^t ^w ] )
        endif
    endrepeat
enddefine;

define constant procedure subscr_namedtupleN( w, t );
    lvars N = find( w, t.namedtupleN_keyset, t );
    subscrv( N, t.namedtupleN_values )
enddefine;

define updaterof subscr_namedtupleN( item, w, t );
    lvars N = find( w, t.namedtupleN_keyset, t );
    item -> subscrv( N, t.namedtupleN_values )
enddefine;

define constant procedure subscr_namedtuple_recordclass( w, t );
    lvars rec_key = t.datakey;
    lvars keyset = class_access( 1, rec_key )( t );
    lvars N = find( w, keyset, t );
    class_access( N, rec_key )( t )
enddefine;

define updaterof subscr_namedtuple_recordclass( item, w, t );
    lvars rec_key = t.datakey;
    lvars keyset = class_access( 1, rec_key )( t );
    lvars N = find( w, keyset, t );
    item -> class_access( N, rec_key )( t )
enddefine;

lblock
    lvars rec_key;
    for rec_key in namedtuple_record_keys do
        subscr_namedtuple_recordclass -> class_apply( rec_key );
    endfor
endlblock;
subscr_namedtupleN -> class_apply( namedtupleN_key );


define global constant procedure appnamedtuple( t, procedure p );
    lvars rec_key;
    if t.isnamedtupleN then
        lvars keyset = t.namedtupleN_keyset;
        lvars values = t.namedtupleN_values;
        lvars i, n = keyset.datalength;
        for i from 1 to n do
            p(
                fast_subscrv( i, keyset ),
                fast_subscrv( i, values )
            )
        endfor;
    elseif t.isnamedtuple_recordclass ->> rec_key then
        ;;; Will work for all small namedtuple record-types.
        lvars i, n = t.datalength;
        lvars keyset = class_access( 1, rec_key )( t );
        fast_for i from 1 to keyset.datalength do
            p(
                fast_subscrv( i, keyset ),
                fast_subscrv( i,  t )        ;;; ABSTRACTION BREAKER.
            )
        endfor
    else
        mishap( t, 1, 'Named-tuple required' )
    endif
enddefine;

define global constant procedure is_null_namedtuple( t );
    ;;; Zero-length named tuples are rare, so no dedicated record-type.
    t.isnamedtupleN and t.namedtupleN_values.datalength == 0
enddefine;

define prnamedtuple( t );
    pr( '$(' );
    unless t.is_null_namedtuple do pr( ' ' ) endunless;
    dlvars first = true;
    appnamedtuple(
        t,
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
    unless t.is_null_namedtuple do pr( ' ' ) endunless;
    pr( ')' );
enddefine;

lblock
    lvars rec_key;
    for rec_key in namedtuple_record_keys do
        prnamedtuple -> rec_key.class_print;
    endfor
endlblock;
prnamedtuple -> namedtupleN_key.class_print;


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

define lconstant procedure check_dups( keyset );
    lvars tail;
    for tail on keyset do
        if tail.ispair then
            if fast_front( tail ) == fast_front( fast_back( tail ) ) then
                mishap( 'Trying to construct named tuple with non-unique key', [% front(tail) %] )
            endif
        endif
    endfor;
enddefine;

;;; Arguments
;;;    0. interned keyset (sorted vector of unique words)
;;;    1. value1
;;;    ...
;;;    N. valueN
;;;
define constant procedure fast_make_namedtuple_from_interned(N);
    if fi_check( N, LOW_RECORD_SIZE, HIGH_RECORD_SIZE) then
        lvars k = fast_subscrv( N fi_- LOW_RECORD_SIZE_1, namedtuple_record_keys_vector );
        class_cons(k)()
    else
        consvector(N).consnamedtupleN
    endif
enddefine;

;;;
;;; This is a helper function for building named tuples. It takes a list
;;; of unsorted pairs (key, position) and a vector of values and
;;; _takes ownership of these_ i.e. no other references to these parameters
;;; are usable after this function has run. This allows the values vector to
;;; be sorted and the list of pairs to be returned to the heap.
;;;
;;; fast_make_namedtuple_internal<T>( [ pair< word, int > ], { T } ) -> namedtuple< T >
;;;
define constant procedure fast_make_namedtuple_internal( key_index_list, values_vector );
    nc_listsort(
        key_index_list,
        procedure( x, y ); alphabefore( x.front, y.front ) endprocedure
    ) -> key_index_list;
    check_duplicates( key_index_list );
    lvars interned_sorted_keys_vector = {% applist( key_index_list, front ) %}.intern_table;

    lvars N = interned_sorted_keys_vector.datalength;

    interned_sorted_keys_vector;
    lblock
        lvars p;
        for p in key_index_list do
            subscrv( p.back, values_vector )
        endfor
    endlblock;


    if fi_check( N, LOW_RECORD_SIZE, HIGH_RECORD_SIZE ) then
        lvars k = fast_subscrv( N fi_- LOW_RECORD_SIZE_1, namedtuple_record_keys_vector );
        class_cons( k )()
    else
        fill( values_vector );  ;;; !! reusing this vector !!
        consnamedtupleN()
    endif;

    ;;; Now we can free up the working store.
    while key_index_list.ispair do
        ( key_index_list.sys_grbg_destpair -> key_index_list ).sys_grbg_destpair -> _ -> _;
    endwhile;
enddefine;

;;; Arguments
;;;   1. A counted pile of key-words.
;;;   2. A counted pile of values.
define constant procedure fast_make_namedtuple_from_unsorted(N);
    lvars values = consvector( N );
    lvars M = ();
    if M /== N do
        mishap( 'Mismatched keys and values while constructing namedtuple', [^M ^N] )
    endif;
    lvars key_index_list = [];
    lvars i;
    fast_for i from M by -1 to 1 do
        lvars p = conspair( /*key*/, i );
        conspair( p, key_index_list ) -> key_index_list;
    endfor;
    fast_make_namedtuple_internal( key_index_list, values )
enddefine;

include '$usepop/pop/lib/include/pop11_flags.ph';

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
    lvars keyset = {% applist( keys, front ) %}.intern_table;
    if keyset.datalength == 0 and ( POP11_CONSTRUCTOR_CONSTS && pop_pop11_flags /== 0 ) then
        sysPUSHQ( nullnamedtuple )
    else
        sysPUSHQ( keyset );
        lvars p;
        for p in keys do
            sysPUSH( subscrv( p.back, tmpvars ) )
        endfor;
        sysPUSHQ( n );
        sysCALLQ( fast_make_namedtuple_from_interned );
    endif
enddefine;

#_ENDIF

endsection;
