%%%-------------------------------------------------------------------
%%% @author lecho
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 14. mar 2020 16:07
%%%-------------------------------------------------------------------
-module(qsort).
-author("lecho").

%% API
-import(timer, [tc/2]).
-import(io, [format/1, format/2]).
-export([qs/1, randomElems/3, compareSpeeds/3, digitize/1]).

qs([]) -> [];
qs([H | T]) -> qs(lessThan(T, H)) ++ [H] ++ qs(grtEqThan(T, H)).

lessThan([], _) -> [];
lessThan(List, Arg) -> [X || X <- List, X < Arg].

grtEqThan([], _) -> [];
grtEqThan(List, Arg) -> [X || X <- List, X >= Arg].

randomElems(N, Min, Max) -> [rand:uniform(Max - Min + 1) + Min - 1 || _ <- lists:seq(1, N)].

%% Przykładowe wywołanie compareSpeeds:
%% qsort:compareSpeeds(qsort:randomElems(100000,1,100000000),fun qsort:qs/1, fun lists:sort/1).

compareSpeeds(List, Fun1, Fun2) ->
  {{A, _}, {B, _}} = {tc(Fun1, [List]), tc(Fun2, [List])},
  format("Qsort time: ~ps, lists:sort time: ~ps~n ", [A / 1000000, B / 1000000]). %conversion to seconds from microseconds

digitize(0)-> 0;
digitize(N) when N < 10 -> [N];
digitize(N) when N >= 10 -> digitize(N div 10)++[N rem 10].