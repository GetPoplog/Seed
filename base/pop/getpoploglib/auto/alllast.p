section;
compile_mode :pop11 +strict;

;;; get the first n elements from a list/vector
define global alllast( n, x ); lvars n, x;
    if x.isvectorclass then
        lvars K = x.datakey;
        lvars S = K.class_fast_subscr;
        lvars L = x.datalength;
        if L < fi_check( n, 0, false ) then
            mishap( 'Too few elements', [^n ^x] )
        endif;
        class_cons( x.datakey )(#|
            lvars i;
            fast_for i from L - n + 1 to L do
                S( i, x )
            endfor
        |#)
    elseif x.islist then
        lvars result;
        erasenum(#|
            if x.destlist >= n then
                conslist( n ) -> result;
            else
                mishap( 'Too few elements', [^n ^x] )
            endif
        |#);
        result;
    elseif x.isword then
        ;;; It is safe to call fast_word_string because alllast is
        ;;; an update-free procedure.
        alllast( n, x.fast_word_string ).consword
    else
        mishap( 'VECTORCLASS, LIST OR WORD NEEDED', [ ^x ] )
    endif
enddefine;

endsection;
