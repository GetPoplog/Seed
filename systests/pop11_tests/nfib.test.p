define nfib( n ); lvars n;
    if n <= 1 then 
        1
    else
        nfib( n - 1) + nfib( n - 2 ) + 1
    endif
enddefine;

nfib( 15 ) =>