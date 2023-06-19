-module(jmustache).

-export([prerender/2]).
-export([render/2]).
-export([render/3]).
-export([split_for_streaming/4]).


prerender(ETerms, Opts) ->
  jsone:encode(ETerms, Opts).



render(ETerm, Variables) ->
  render(ETerm, [], Variables).



render(ETerm, Opts, Variables) when is_binary(ETerm) ->
  binary:copy(lists:foldl(replace_fun(Opts), ETerm, maps:to_list(Variables)));

render(ETerm, Opts, Variables) ->
  render(prerender(ETerm, Opts), Opts, Variables).



replace_fun(Opts) ->
  fun
    ({Pattern, {Value, SpecialOpts}}, Subject) ->
      Replacement = jsone:encode(Value, SpecialOpts),
      re:replace(Subject, <<"\"{{",Pattern/binary,"}}\"">>, Replacement, [{return, binary}, global]);
    ({Pattern, Value}, Subject) ->
      Replacement = jsone:encode(Value, Opts),
      re:replace(Subject, <<"\"{{",Pattern/binary,"}}\"">>, Replacement, [{return, binary}, global])
  end.



split_for_streaming(ETerm, Opts, Variables, Split) ->
  [Headers, Trailers] = re:split(render(ETerm, Opts, Variables), <<"\"{{",Split/binary,"}}\"">>, [{return, binary}]),
  {Headers, Trailers}.