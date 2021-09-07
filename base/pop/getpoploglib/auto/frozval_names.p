section $-frozval_names => 
    frozval_names 
    frozval_stack_slot
    frozval_closure_slot;

constant procedure frozval_slot_table =
    newanyproperty( [], 8, 1, 8, false, false, "tmpval", false, false );

;;; Given a word and a 'bound' closure, returns the index of the word
;;; when addressed using subscr_stack.
define global constant procedure frozval_stack_slot( word, closure );
    lvars slots = frozval_slot_table( closure );
    if slots then
        lvars i, item;
        for item with_index i in_vector slots do
            returnif( word == item )( datalength( closure ) - i + 1 )
        endfor
    endif;
    mishap( 'Unrecognised slot name', [^word ^closure] )
enddefine;

;;; Given a word and a 'bound' closure, returns the index of the frozval.
define global constant procedure frozval_closure_slot( word, closure );
    lvars slots = frozval_slot_table( closure );
    if slots then
        lvars i, item;
        for item with_index i in_vector slots do
            returnif( word == item )( i )
        endfor
    endif;
    mishap( 'Unrecognised slot name', [^word ^closure] )
enddefine;


define frozval_names( closure );
    unless closure.isclosure do
        mishap( 'Expecting closure', [^closure] )
    endunless;
    lvars slots = frozval_slot_table( closure );
    if slots then
        destvector( slots )
    else
        0
    endif
enddefine;

define updaterof frozval_names( N, closure );
    unless closure.isclosure do
        mishap( 'Expecting closure', [^closure] )
    endunless;
    lvars slots = consvector( N );
    if datalength( slots ) /== datalength( closure ) then
        mishap( 'Mismatch in the number of names and the size of closure', [^N ^closure] )
    endif;
    slots -> frozval_slot_table( closure );
enddefine;

endsection;
