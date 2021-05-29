/*  --- University of Sussex POPLOG file -----------------------------------
 *  File:           $usepop/master/C.all/lib/data/vacmaze.p
 *  Purpose:        who knows!
 *  Author:         Unknown, ???
 *  Documentation:
 *  Related Files:
 */

erase(turtle);
newpicture(25,18);
jumpto(25,1); drawto(25,16);
jumpto(17,5); drawto(17,14);
jumpto(9,9); drawto(9,16);
jumpto(9,16); drawto(25,16);
jumpto(9,9); drawto(17,9);
jumpto(1,1); drawto(1,17);
jumpto(1,5); drawto(17,5);
jumpto(1,1);

vars database;
[[junc enddefine [1 17] [1 5]]
 [junc enddefine [17 14] [17 9]]
 [junc ell [25 16] [9 16] [25 1]]
 [junc ell [9 16] [9 9] [25 16]]
 [junc tee [1 5] [1 1] [17 5] [1 17]]
 [junc enddefine [1 1] [1 5]]
 [junc ell [9 9] [17 9] [9 16]]
 [junc tee [17 9] [17 14] [9 9] [17 5]]
 [junc ell [17 5] [17 9] [1 5]]
 [junc enddefine [25 1] [25 16]]
 [line vrt [25 1] [25 16]]
 [line vrt [17 5] [17 9]]
 [line vrt [17 9] [17 14]]
 [line vrt [9 9] [9 16]]
 [line vrt [1 1] [1 5]]
 [line vrt [1 5] [1 17]]
 [line hrz [9 16] [25 16]]
 [line hrz [9 9] [17 9]]
 [line hrz [1 5] [17 5]]]
    -> database;

define getchoices(point) -> result;
    ;;; given a point, return a list of points connected to it
    lookup([junc = ^point ??result])
enddefine;


;;; The following function finds a route from
;;; a given START position to a wanted GOAL position.
;;; It does this by pre-pending the START position to
;;; a route from some position immediately accessible
;;; from the START, this point is picked at random
;;; using ONEOF.
;;; This function tends to produce very bad routes.
define route(start,goal);
    if start = goal
    then    [^start]
    else
        [^start ^^(route(oneof(getchoices(start)), goal))]
    endif
enddefine;

pr('procedures route and getchoices now defined\n');
