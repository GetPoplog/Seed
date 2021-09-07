compile_mode :pop11 +strict;

section $-queue => 
    push_back_queue pop_back_queue
    push_front_queue pop_front_queue
    is_null_queue 
    newqueue isqueue destqueue appqueue
    explode_queue 
    queue_to_list queue_to_vector
    subscr_queue print_queue clear_queue
    queue_key queue_length queue_first queue_last;

defclass constant queue {
    queue_origin
};

syscancel( "destqueue" );

define newlink( left, item, right );
    conspair( conspair( item, left ), right )
enddefine;

define grbg_link( link );
    lvars ( p, right ) = sys_grbg_destpair( link );
    lvars ( item, left ) = sys_grbg_destpair( p );
    ( left, item, right )
enddefine;

define linkleft( link );
    link.front.back
enddefine;

define updaterof linkleft( x, link );
    x -> link.front.back
enddefine;

define linkright( link );
    link.back
enddefine;

define updaterof linkright( x, link );
    x -> link.back
enddefine;

define linkitem( link );
    link.front.front
enddefine;

define updaterof linkitem( item, link );
    item -> link.front.front
enddefine;

define is_null_queue( q );
    lvars origin = q.queue_origin;
    origin.linkleft == origin
enddefine;

define appqueue( q, procedure p );
    lvars origin = q.queue_origin;
    lvars x = origin.linkright;
    while x /== origin do
        p( x.linkitem );
        x.back -> x;
    endwhile;
enddefine;

define queue_length( q ) -> n;
    lvars origin = q.queue_origin;
    lvars x = origin.linkright;
    0 -> n;
    while x /== origin do
        n fi_+ 1 -> n;
        x.back -> x;
    endwhile;
enddefine;

define queue_first( q );
    lvars origin = q.queue_origin;
    lvars x = origin.linkright;
    if x == origin then
        mishap( 'Trying to take the front of an empty queue', [] );
    endif;
    x.linkitem    
enddefine;

define queue_last( q );
    lvars origin = q.queue_origin;
    lvars x = origin.linkleft;
    if x == origin then
        mishap( 'Trying to take the last item of an empty queue', [] );
    endif;
    x.linkitem
enddefine;

define print_queue( q );
    pr( '<queue' );
    appqueue( q, procedure(x); cucharout( ` ` ); pr(x) endprocedure );
    cucharout( `>` )
enddefine;

print_queue -> class_print( queue_key );

define find_link( n, q );
    unless n.isinteger and n >= 1 do
        mishap( 'Invalid subscript for queue', [^n] )
    endunless;
    lvars origin = q.queue_origin;
    lvars p = origin.linkright;
    while p /== origin do
        returnif( n == 1 )( p );
        n - 1 -> n;
        p.linkright -> p;
    endwhile;
    mishap( 'Subscript out of range', [^n ^q] );
enddefine;

define subscr_queue( n, q );
    find_link( n, q ).linkitem
enddefine;

define updaterof subscr_queue( v, n, q );
    v -> find_link( n, q ).linkitem
enddefine;

subscr_queue -> class_apply( queue_key );

define push_back_queue( item, q );
    lvars origin = q.queue_origin;
    lvars oldleft = origin.linkleft;
    lvars new = newlink( oldleft, item, origin );
    new -> oldleft.linkright;
    new -> origin.linkleft;
enddefine;

define push_front_queue( item, q );
    lvars origin = q.queue_origin;
    lvars oldright = origin.linkright;
    lvars new = newlink( origin, item, oldright );
    new -> oldright.linkleft;
    new -> origin.linkright;
enddefine;

define pop_front_queue( q ) -> x;
    lvars origin = q.queue_origin;
    lvars oldright = origin.linkright;
    lvars right = oldright.linkright;
    oldright.linkitem -> x;
    unless origin /== oldright do    
        mishap( 'Trying to pop from the front of an empty queue', [] )
    endunless;
    origin -> right.linkleft;
    right -> origin.linkright;
    grbg_link( oldright ) -> ( _, _, _ );
enddefine;

define pop_back_queue( q ) -> x;
    lvars origin = q.queue_origin;
    lvars oldleft = origin.linkleft;
    lvars left = oldleft.linkleft;
    oldleft.linkitem -> x;
    unless origin /== oldleft do    
        mishap( 'Trying to pop from the back of an empty queue', [] )
    endunless;
    origin -> left.linkright;
    left -> origin.linkleft;
    grbg_link( oldleft ) -> ( _, _, _ );
enddefine;

define clear_queue( q );
    lvars origin = q.queue_origin;
    lvars oldright = origin.linkright;
    returnif( origin == oldright )();

    origin -> origin.linkleft;
    origin -> origin.linkright;

    while oldright /== origin do
        grbg_link( oldright ) -> ( _, _, oldright );
    endwhile;
enddefine;

define newqueue( L ) -> q;
    lvars origin = newlink(_, _, _);
    origin -> linkleft( origin );
    origin -> linkright( origin );
    consqueue( origin ) -> q;
    lvars i;
    for i in L do
        push_back_queue( i, q )
    endfor;
enddefine;

define constant explode_queue( q );
    lvars origin = q.queue_origin;
    lvars x = origin.linkright;
    while x /== origin do
        x.linkitem;
        x.back -> x;
    endwhile;
enddefine;

define constant destqueue( q );
    (#| explode_queue( q ) |#)
enddefine;

define constant queue_to_list( q );
    [% explode_queue( q ) %]
enddefine;

define constant queue_to_vector( q );
    consvector( destqueue( q ) )
enddefine;

endsection;
