# Backtrackable asserts
A quick-hack with b_setval/nb_setval to achieve backtrackable asserts, because I coulnd't find one.
If you're familiar with how the assert/retract behaves, this library should work how you expect it to ( with backtracking resetting the assert/retracts, ofcourse).
But I still recommend you read the whole readme for the caveats.

## Usage:
The library can be used in programs using `:- use_module(backtrackable_asserts).`.
The library's export list is the following: `[b_assert/1, b_asserta/1, b_assertz/1, b_retract/1, b_query/1]`.
They're named so copying the b_ in backtrable versions of predicates (e.g. b_setval).

b_assert* & retract work similar to the corresponding assert* & retract predicates.
The notable difference is b_query - All predicates which are asserted using b_assert cannot be queried directly. They must be queried using b_query. 
**Do NOT try to mix regular dynamic facts and b_assert dynamic facts. It will not work. ** 

### Examples:

	?- use_module(backtrackable_asserts). 	% Include the module
	true.

	?- b_assert(foo(a)), foo(X).			% these facts cannot be queried directly.
	ERROR: Undefined procedure: foo/1 (DWIM could not correct goal)
	?- b_assert(foo(a)), b_query(foo(X)).	% You must use b_query/1
	X = a.

	?- assert(bar(b)), b_query(bar(X)).		% Conversely, you can't query regular dynamic facts with b_query either.
	false.

	?- b_assert(foo(a)), ((b_assert(foo(b)), fail); b_query(foo(X))). % The assert to foo(b) was removed on backtracking.
	X = a.

	?- b_assert(foo(a)), b_assert(foo(b)), (b_retract(foo(a));true), b_query(foo(X)). % this time with retract
	X = b ;
	X = a ;
	X = b.

## Performance concerns
If you asserting and retracting the same fact over and over is not going to be efficient.
For a query (or retract), We'd have to 'walk down the stack' till we find a fact that hasn't been retracted yet.
This would be of the order of the number of facts matching your query that have been asserted.
Otherwise, I expect the overhead to stay reasonably small.


## nb_assert
Because I can imagine it being useful, nb_assert provides a way to persist facts which aren't reset on backtracking - The difference to regular assert being that it is now queriable using b_query. So you can mix nb_assert and b_assert.

How do they mix? b_retract on an nb_asserted fact does retract it. The retraction will reset on backtracking, the assert will not. To get rid of it completely, do an nb_retract. 

Use nb_retract carefully. It does a full retract of an (n)b_asserted fact. 

**nb_retract'ing an already retracted fact will fail**. The reasoning is: 
Which foo does nb_retract retract? 

	nb_assert(foo), b_asserta(foo), b_retract(foo), nb_retract(foo), b_query(foo).

Hence, nb_retract always retracts the top-most occurence. The following query succeeds once when the b_retract is backtrack-resetted.

	nb_assert(foo), b_asserta(foo), nb_retract(foo), (b_retract(foo);true), b_query(foo).
