compile_mode :pop11 +strict;

uses dict

section $-dict => dict_concat;

define global constant procedure dict_concat( d1, d2 );
    lvars ( d1keys, d1values, d1length ) = d1.destdict.dup.datalength;
    lvars ( d2keys, d2values, d2length ) = d2.destdict.dup.datalength;
    lvars plist, d1i = 1, d2i = 1;
    [%
        repeat
            if d1i > d1length then
                ;;; Accept all of the remaining d2 items.
                lvars i;
                for i from d2i to d2length do
                    conspair( 
                        subscrv( i, d2keys ),
                        subscrv( i, d2values )
                    )
                endfor;
                quitloop
            elseif d2i > d2length then
                ;;; Accept all of the remaining d1 items. 
                lvars i;
                for i from d2i to d1length do
                    conspair(
                        subscrv( i, d1keys ),
                        subscrv( i, d1values )
                    )
                endfor;
                quitloop
            endif;
            lvars d1item = subscrv( d1i, d1keys );
            lvars d2item = subscrv( d2i, d2keys );
            lvars cmp = alphabefore( d1item, d2item );
            if cmp == true then
                conspair( d1item, subscrv( d1i, d1values ) );
                d1i fi_+ 1 -> d1i;
            elseif cmp == 1 then
                conspair( d2item, subscrv( d2i, d2values ) );
                d1i fi_+ 1 -> d1i;
                d2i fi_+ 1 -> d2i;
            else
                conspair( d2item, subscrv( d2i, d2values ) );
                d2i fi_+ 1 -> d2i;
            endif
        endrepeat
    %] -> plist;
    lvars keys = {% applist( plist, front ) %};
    lvars values = {% applist( plist, back ) %};
    while plist.ispair do
        sys_grbg_destpair( sys_grbg_destpair( plist ) -> plist ) -> (_, _); 
    endwhile;
    consdict( keys.dict_table, values );
enddefine;

endsection;