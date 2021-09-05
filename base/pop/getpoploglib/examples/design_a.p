;;; Try the following code.

with
    sorted = false
define demo( x, y ) -> list;
    [%
        lvars i;
        for i in x do
            if member( i, y ) then i endif
        endfor
    %] -> list;
    if sorted then 
        list.sort -> list
    endif;
enddefine;


demo( [ 4 3 2 1 ], [3 6 4 8] ) =>

with 
    sorted = true
do
    demo( [ 4 3 2 1 ], [3 6 4 8] ) =>

