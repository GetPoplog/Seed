compile_mode :pop11 +strict;

/*  TODO: NOTE FOR FUTURE DEVELOPMENT

We want to add some syntax for merging in a dict object. e.g.

    f( 1, 2, 3 -&- ^^mydict )

*/

uses kwargs_lib

section $-kwargs =>
    -&-
    ;

define sort_keywords( keyword_list );
    syssort( keyword_list, true, alphabefore )
enddefine;

define check_only_one( n );
    lvars d = stacklength() fi_- n;
    unless d == 1 do
        if d < 1 then
            mishap( 0, 'Not enough values for optional argument' )
        else
            mishap( d, 'Too many values for optional argument' )
        endif
    endunless;
enddefine;

;;;
;;; Now we have to sort the pile of K1, V1, ... Kn, Vn
;;; into keyword order.  We do this by using sysSWAP to
;;; swap them into their correct positions.
;;;
;;; It is in this code that we check for duplicate
;;; keywords.
;;;
define permute( keyword_list );
    lvars keyword_vector = {% keyword_list.dl %};
    lvars n = keyword_vector.length;

    returnif( n <= 1 );     ;;; No need to permute if only 1 (or 0).

    lvars position = newproperty( [], 16, false, "perm" );
    lvars kw, n = 0;
    for kw in keyword_list do
        if position( kw ) then
            mishap( kw, 1, 'Repeated keyword for optional arguments' )
        endif;
        n + 1 ->> n -> position( kw )
    endfor;

    lvars kw, rank = 0;
    for kw in sort_keywords( keyword_list ) do
        rank + 1 -> rank;
        lvars posn = position( kw );
        unless rank == posn do
            ;;; Swap rank and posn over.
            lvars jw = keyword_vector( rank );

            ;;; K1, V1  K2, V2, ...., Kn-1, Vn-1, Kn, Vn
            ;;; 2*n     2*(n-1)       2*2         2*1
            lvars rank_stack_offset = 2 * ( n - rank + 1 );
            lvars posn_stack_offset = 2 * ( n - posn + 1 );
            sysSWAP( rank_stack_offset, posn_stack_offset );
            sysSWAP( rank_stack_offset - 1, posn_stack_offset - 1 );

            ;;; And now record that it has been done.
            ( keyword_vector( rank ), keyword_vector( posn ) ) -> ( keyword_vector( posn ), keyword_vector( rank ) );
            ( position( kw ), position( jw ) ) -> ( position( jw ), position( kw ) );
        endunless;
    endfor;
enddefine;

define check_terminator( keyword, check_plain );
    lvars idprops = keyword.identprops;
    returnif(
        idprops == "syntax" and
        keyword.valof == _ and
        keyword.length == 1 and
        not( isalphacode( keyword( 1 ) ) )
    )( true );
    if check_plain then
        unless idprops == 0 or idprops == undef do
            mishap( keyword, 1, 'Keyword is not an ordinary identifier' )
        endunless;
    endif;
    false
enddefine;

define is_terminator( keyword );
    check_terminator( keyword, false )
enddefine;

;;;
;;; This procedure knows a little bit about Pop-11 syntax so
;;; it can infer that some common expressions will deliver a
;;; single value.  It isn't very smart, unfortunately, but
;;; it is much better than nothing.
;;;
;;; It knows about these three cases
;;;     <nonword> ,                     e.g. integer, string
;;;     <ordinary identifier> ,         must not be active
;;;     " <item> " ,
;;;
define guarantee_single_value();
    dlocal proglist_state;              ;;; Leave input undisturbed.

    lvars it1 = readitem();
    returnif( it == termin )( false );

    lvars it2 = readitem();
    returnif( it2 == termin )( false );

    if it2.is_terminator then
        ;;; This looks promising.
        not( it1.isword ) or identprops( it1 ) == 0 and not( isactive( it1 ) )
    elseif it1 == """ then
        ;;; Still possible.
        lvars it3 = readitem();
        if it3 /== """ then
            false
        else
            readitem().is_terminator
        endif
    else
        false
    endif
enddefine;

;;;
;;; This should really be provided as part of the pop11_compile family.
;;; But it isn't.  So we have to code it up.
;;;
define compile_single_valued_expr( stack_count_tmpvar );
    ;;; Try to detect important common cases which are guaranteed to
    ;;; deliver single results.
    if guarantee_single_value() then
        pop11_comp_expr()
    else
        sysCALL( "stacklength" );
        sysPOP( stack_count_tmpvar );
        pop11_comp_expr();
        sysPUSH( stack_count_tmpvar );
        sysCALLQ( check_only_one );
    endif
enddefine;

define syntax 12 -&- ;
    dlocal pop_new_lvar_list;

    pop_expr_inst( pop_expr_item );

    ;;; Add the base of the kwargs-pile.
    sysPUSHQ( pop_kwargs_bottom_mark );

    lvars k = sysNEW_LVAR();
    lvars keywords = [];

    lvars count = 0;
    repeat
        lvars keyword = nextreaditem();
        quitif( check_terminator( keyword, false ) );
        readitem() -> _;

        count + 1 -> count;
        keyword :: keywords -> keywords;

        pop11_need_nextreaditem( KEY_VALUE_SEPARATOR ) -> _;
        sysPUSHQ( keyword );
        compile_single_valued_expr( k );
        quitunless( pop11_try_nextreaditem( "," ) );
    endrepeat;
    keywords.ncrev -> keywords;

    permute( keywords );

    ;;; Put the cap on the kwargs-pile.
    sysPUSHQ -> pop_expr_inst;
    pop_kwargs_top_mark -> pop_expr_item;
enddefine;


endsection;
