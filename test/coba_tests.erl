-module(coba_tests).

-include_lib("eunit/include/eunit.hrl").

coba_test() -> 
	meck:new(asu, [non_strict]),
	meck:expect(asu, gug, 0, "Gug!"),
	?assertEqual(coba:gonggong(), "Gug!").
 
	
