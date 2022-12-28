section dollar => $;

;;; Initially tried with '$_' and hit a lot of problems with '$_{'.
lconstant autoload_prefix = 'dollar_';
lconstant autoload_class_suffix = '_key';

;;; This procedure provides an extension mechanism for the $ITEM syntax.
;;; It maps from 'items' from the Pop-11 itemizer (words, string, numbers)
;;; or keys (word_key, string_key, number keys) into code-planting
;;; procedures.

define lconstant lookup( item );
    if item.isword then
        lvars w = consword( autoload_prefix <> item.word_string );
        lvars wid = word_identifier( w, pop_section, true );
        if wid then
            wid.valof
        else
            if sys_autoload( w ) then
                word_identifier( w, pop_section, true ).valof
            else
                false
            endif
        endif
    else
        lvars w = consword( autoload_prefix <> item.datakey.class_name.word_string <> autoload_class_suffix );
        lvars wid = word_identifier( w, pop_section, true );
        [try to autoload ^w] =>
        if sys_autoload( w ) then
            [ succeeded] =>
            word_identifier( w, pop_section, true ).valof
        else
            false
        endif;
    endif
enddefine;

define lconstant is_viable_shell_variable( w );
    returnif( w.datalength <= 0 )( false );
    lvars w1 = subscrw( 1, w );
    returnunless( w1.isalphacode or w1 == `_` )( false );
    lvars i;
    for i from 2 to w.datalength do
        lvars ch = subscrw( i, w );
        returnunless( ch.isalphacode or ch.isnumbercode or ch == `_` )( false )
    endfor;
    return( true )
enddefine;

define global syntax $ ;
    lvars item = readitem();
    if item.isword and item.is_viable_shell_variable then
        sysPUSHQ( item.word_string );
        sysCALL -> pop_expr_inst;
        "systranslate" -> pop_expr_item;
    else
        lvars p = lookup( item );
        if p then
            p( item )
        else
            mishap( 'Unexpected item after $', [^item] )
        endif
    endif
enddefine;

endsection;
