%%%-------------------------------------------------------------------
%%% @author lecho
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. kwi 2020 16:40
%%%-------------------------------------------------------------------
-module(parcellockerfinder).
-author("lecho").

%% API
-export([test/0, findLockerForEachPerson/2, testOneProc/4, testProcCount/2, testSeparateProc/3, findLockerForPersonProc/3,splitListOnFour/1,randomPointList/1]).

-define(ProcCount, 4).

randomPointList(N) ->
  [{rand:uniform(10000), rand:uniform(10000)} || _ <- lists:seq(1, N)].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
findLockerForEachPerson(People, Lockers) ->
  [{findLockerForPerson(Person, Lockers)} || Person <- People].

findLockerForPerson(Person, Lockers) ->
  {X1, Y1} = Person,
  Distances = [{X2, Y2, (X1 - X2) * (X1 - X2) + (Y1 - Y2) * (Y1 - Y2)} || {X2, Y2} <- Lockers],
  Result = lists:keysort(3, Distances),
  [{X, Y, _} | _] = Result,
  {{X1, Y1}, {X, Y}}.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
findLockerForPersonProc(PersonLocation, LockerLocations, Parent) ->
  {_, Locker} = findLockerForPerson(PersonLocation, LockerLocations),
  Parent ! {PersonLocation, Locker}.

testSeparateProc([], _, N) ->
  collect([], N);
testSeparateProc([H | T], Lockers, N) ->
  spawn(parcellockerfinder, findLockerForPersonProc, [H, Lockers, self()]),
  testSeparateProc(T, Lockers, N).

collectAll(Pairs, Pair, N) when is_list(Pair) ->
  collect(Pair ++ Pairs, N - 1);
collectAll(Pairs, Pair, N) ->
  collect([Pair | Pairs], N - 1).

collect(Pairs, N) when (N > 0) ->
  receive
    Pair ->
      collectAll(Pairs, Pair, N)
  end;
collect(Pairs, _) -> Pairs.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

testOneProc([], _, Pairs, Parent) ->
  Parent ! Pairs;
testOneProc([H | T], Lockers, Pairs, Parent) ->
  Pair = findLockerForPerson(H, Lockers),
  testOneProc(T, Lockers, [Pair | Pairs], Parent).

testProcCount(People, Lockers) ->
  {L1, L2, L3, L4}  = splitListOnFour(People),
  spawn(parcellockerfinder, testOneProc, [L1, Lockers, [], self()]),
  spawn(parcellockerfinder, testOneProc, [L2, Lockers, [], self()]),
  spawn(parcellockerfinder, testOneProc, [L3, Lockers, [], self()]),
  spawn(parcellockerfinder, testOneProc, [L4, Lockers, [], self()]),
  collect([], 4).

splitListOnFour(List) ->
  L = trunc(length(List)/4),
  L1 = lists:sublist(List, 1, L),
  L2 = lists:sublist(List, 2501, L),
  L3 = lists:sublist(List, 5001, L),
  L4 = lists:sublist(List, 7501, L),
  {L1,L2,L3,L4}.

test() ->
  People = randomPointList(10000),
  Lockers = randomPointList(1000),
  {T1, _} = timer:tc(parcellockerfinder, findLockerForEachPerson, [People, Lockers]),
  {T2, _} = timer:tc(parcellockerfinder, testSeparateProc, [People, Lockers, length(People)]),
  {T3, _} = timer:tc(parcellockerfinder, testProcCount, [People, Lockers]),
  io:format("Wersja sekwencyjna: ~ps~nWersja bardzo rownolegla: ~ps~nWersja mniej rownolegla: ~ps~n", [T1/1000000, T2/1000000, T3/1000000]).



