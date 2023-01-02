section;
compile_mode :pop11 +strict;

;;; get the first n elemenst from a list/vector
define global allfirst( n, x ); lvars n, x;
    if x.isvectorclass then
        class_cons( x.datakey )(#|
            lvars i, count;
            for i with_index count in_vectorclass x do
                quitif( count fi_> n );
                i
            endfor
        |#)
    elseif x.islist then
        [% applynum( x, dest, n ).erase %]
    elseif x.isword then
        ;;; It is safe to call fast_word_string because allfirst
        ;;; is update-free.
        allfirst( n, x.fast_word_string ).consword
    else
        mishap( 'VECTORCLASS, LIST OR WORD NEEDED', [ ^x ] )
    endif
enddefine;

endsection;
