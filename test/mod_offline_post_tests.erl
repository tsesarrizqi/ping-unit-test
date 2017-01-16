-module(mod_offline_post_tests).

-include_lib("eunit/include/eunit.hrl").
-include("jlib.hrl").

offline_chat_test_() ->
	{foreach, fun start/0, fun stop/1, 
		[fun requested/1, 
		 fun not_requested_wrong_type/1, 
		 fun not_requested_empty_body/1]}.

start() ->
	Mods = make_mock(),
	Packet = make_packet(),
	[Mods, Packet].

stop([Mods, _]) ->
	meck:unload(Mods).

requested([[lager, xml, gen_mod, httpc], {From, To, XML}]) ->
	expect_xml(xml, <<"chat">>, <<"ada sesuatu">>),
	mod_offline_post:send_notice(From, To, XML),
	[?_assert(meck:called(httpc, request, ['_','_','_','_']))].
	
not_requested_wrong_type([[lager, xml, gen_mod, httpc], {From, To, XML}]) ->
	expect_xml(xml, <<"data">>, <<"ada sesuatu">>),
	mod_offline_post:send_notice(From, To, XML),
	[?_assert(not meck:called(httpc, request, ['_','_','_','_']))].

not_requested_empty_body([[lager, xml, gen_mod, httpc], {From, To, XML}]) ->
	expect_xml(xml, <<"chat">>, <<"">>),
	mod_offline_post:send_notice(From, To, XML),
	[?_assert(not meck:called(httpc, request, ['_','_','_','_']))].
	
make_packet() ->
	Type = {list_to_binary("type"), <<"sesuatu">>},
	From = #jid{luser="tsesar", lserver="localhost"},
	To = #jid{luser="rizqi", lserver="localhost"},
	Packet = {From, To, [Type]},
	Packet.

make_mock() ->
	Mods = [lager, xml, gen_mod, httpc],
	meck:new(Mods, [non_strict]),
	meck:expect(lager, info, ['_','_'], ok),
	meck:expect(gen_mod, get_module_opt, ['_','_','_','_','_'], <<"">>),
	meck:expect(httpc, request, ['_','_','_','_'], ok),
	Mods.

expect_xml(xml, Type, Body) ->
	meck:expect(xml, get_tag_attr_s, fun(<<"type">>, _) -> Type end),
	meck:expect(xml, get_path_s, fun(_, [{elem, <<"body">>}, cdata]) -> Body end).
