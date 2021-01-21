:- begin_tests(backtrackable_asserts).
:- use_module(backtrackable_asserts).

% Test-list
test(assert_test):-                     bta_test_assert_test.
test(assert_retract_test):-             bta_test_assert_retract_test.
test(assert_backtrack_test):-           bta_test_assert_backtrack_test.
test(multiple_assert_retract_test):-    bta_test_multiple_assert_retract_test.
test(asserta_assertz_test):-            bta_test_asserta_assertz_test.
test(nb_assert_test):-                  bta_test_nb_assert_test.
% The bodies of the test

% assert_test
bta_test_assert_test:-
    b_assert(bta_assert_test),
    b_query(bta_assert_test), % We can query what we just did
    not( (b_query(X), X\==bta_assert_test) ).

% assert_backtrack_test
bta_test_assert_backtrack_test:-
    b_assert(bta_assert_backtrack_test), 
    (b_query(bta_assert_backtrack_test) -> (true) ; (!,fail)),
    fail. % Test the backtrack  

bta_test_assert_backtrack_test:-
    (b_query(bta_assert_backtrack_test) -> (!, fail) ; true).


% assert_retract_test
bta_test_assert_retract_test:-
    b_assert(bta_assert_retract_test),
    b_query(bta_assert_retract_test), % We can query what we just did
    bta_test_assert_retract_test__retract.

bta_test_assert_retract_test__retract:-
    b_retract(bta_assert_retract_test),
    (b_query(bta_assert_retract_test) -> (!,fail) ; true),
    fail.  % Test whether the retract gets retracted on backtrack

bta_test_assert_retract_test__retract:-
    b_query(bta_assert_retract_test).  % Verify that we can query again.

%multiple_assert_retract_test
bta_test_multiple_assert_retract_test:-
    b_assert(btat_multi_assert_retract),
    b_assert(btat_multi_assert_retract),
    
    b_query(btat_multi_assert_retract),
    
    b_retract(btat_multi_assert_retract),
    b_query(btat_multi_assert_retract),
    
    b_retract(btat_multi_assert_retract),
    not(b_query(btat_multi_assert_retract)),
    !.

% bta_test_asserta_assertz_test
bta_test_asserta_assertz_test:-
    b_assert(btat_asserta_assertz(first)), bta_test_asserta_assertz_test_verify_top(first),
    b_assertz(btat_asserta_assertz(second)), bta_test_asserta_assertz_test_verify_top(first),   % assertz(second) -> first is still on top
    b_asserta(btat_asserta_assertz(third)), bta_test_asserta_assertz_test_verify_top(third),    % asserta(third) -> third is now on top
    
    b_retract(btat_asserta_assertz(_)), !, bta_test_asserta_assertz_test_verify_top(first),        % retract(_) -> pop third -> first is on top again
    b_retract(btat_asserta_assertz(_)), !, bta_test_asserta_assertz_test_verify_top(second),       % retract(_) -> pop first -> second is now on top
    b_retract(btat_asserta_assertz(_)), !, not(b_query(btat_asserta_assertz(_))).                  % retract(_) -> pop second -> nothing left

bta_test_asserta_assertz_test_verify_top(Expected):-
    b_query(btat_asserta_assertz(Actual)), !, Actual == Expected.

% bta_test_nb_assert_test
bta_test_nb_assert_test:- % Clean up any earlier failed tests.
    nb_retract(btat_nb_assert), fail.

bta_test_nb_assert_test:-
    nb_assert(btat_nb_assert),
    fail.

bta_test_nb_assert_test:-
    (b_query(btat_nb_assert) => true ; (!,fail)),
    fail. % This must succeed.

bta_test_nb_assert_test:-
    b_retract(btat_nb_assert),
    (b_query(btat_nb_assert) -> (!,fail) ; true),
    fail.

bta_test_nb_assert_test:-
    b_query(btat_nb_assert), % Should succeed again
    nb_retract(btat_nb_assert).
