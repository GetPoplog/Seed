compile_mode :pop11 +strict;

uses named_arg_group;

section;

/*
    is_named_arg_group() -> bool
    new_named_arg_group() -> ( 0, pop11_named_arg_mark )
    named_arg_group_merge_dict( ..., N, pop11_named_arg_mark, dict ) -> ( ..., N', pop11_named_arg_mark )
    named_arg_group_insert( ..., N, pop11_named_arg_mark, keyword, value ) -> ( ..., N', pop11_named_arg_mark )
    named_arg_group_pop( ..., N, pop11_named_arg_mark )
        -> ( ..., N-1, pop11_named_arg_mark, keyword, value ) OR
        -> ( ..., N, pop11_named_arg_mark, false, termin )
    named_arg_group_to_dict( ..., N, pop11_named_arg_mark ) -> dict
    named_arg_group_erase( ..., N, pop11_named_arg_mark ) -> ()
*/

define :unittest empty_stack_is_not_a_group();
    lvars answer = is_named_arg_group();
    assert not(answer);
enddefine;

define :unittest a_string_is_not_a_group();
    lvars answer = is_named_arg_group( 'froggy' );
    assert not(answer);
enddefine;

define :unittest a_group_is_a_group();
    lvars N = stacklength();
    lvars answer = is_named_arg_group( new_named_arg_group() );
    assert stacklength() == N + 2;
    assert answer;
enddefine;

define :unittest empty_group_named_arg_group_pop();
    ;;; Arrange
    new_named_arg_group();
    ;;; Act
    lvars ( k, v ) = named_arg_group_pop();
    lvars count = named_arg_group_length();
    ;;; Assert
    assert k == false and v == termin and count == 0;
enddefine;

define :unittest insert_into_empty();
    ;;; Arrange
    new_named_arg_group();
    ;;; Act
    named_arg_group_insert( "aaa", 999 );
    lvars count = named_arg_group_length();
    ;;; Assert
    assert count == 1;
enddefine;

define :unittest pop_from_single_value_group_();
    ;;; Arrange
    new_named_arg_group();
    named_arg_group_insert( "aaa", 999 );
    ;;; Act
    lvars ( k, v ) = named_arg_group_pop();
    lvars count = named_arg_group_length();
    ;;; Assert
    assert k == "aaa" and v == 999 and count == 0;
enddefine;

define :unittest keys_stay_sorted();
    ;;; Arrange
    lvars captured = {%
        new_named_arg_group();
        named_arg_group_insert( "aaa", 666 );
        named_arg_group_insert( "zzz", 777 );
        named_arg_group_insert( "bbb", 888 );
        named_arg_group_insert( "yyy", 999 );
    %};
    ;;; Assert
    assert captured(1) == 666;
    assert captured(2) == "aaa";
    assert captured(3) == 888;
    assert captured(4) == "bbb";
    assert captured(5) == 999;
    assert captured(6) == "yyy";
    assert captured(7) == 777;
    assert captured(8) == "zzz";
    assert captured(9) == 4;
    assert captured(10) == pop11_named_arg_mark;
enddefine;

define :unittest erase_group();
    ;;; Arrange
    lvars N = stacklength();
    new_named_arg_group();
    named_arg_group_insert( "aaa", 666 );
    named_arg_group_insert( "zzz", 777 );
    named_arg_group_insert( "bbb", 888 );
    named_arg_group_insert( "yyy", 999 );
    ;;; Act
    named_arg_group_erase();
    ;;; assert stacklength() == N;
enddefine;

define :unittest convert_to_dict();
    ;;; Arrange
    lvars N = stacklength();
    new_named_arg_group();
    named_arg_group_insert( "aaa", 666 );
    named_arg_group_insert( "zzz", 777 );
    named_arg_group_insert( "bbb", 888 );
    named_arg_group_insert( "yyy", 999 );
    ;;; Act
    lvars d = named_arg_group_to_dict();
enddefine;

endsection;
