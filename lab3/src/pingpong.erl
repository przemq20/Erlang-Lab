%%%-------------------------------------------------------------------
%%% @author lecho
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. mar 2020 11:44
%%%-------------------------------------------------------------------
-module(pingpong).
-author("lecho").

%% API
-export([start/0, stop/0, play/1, ping_loop/1, pong_loop/1]).

start() ->
  Ping = spawn(pingpong, ping_loop, [0]),
  Pong = spawn(pingpong, pong_loop, [0]),
  register(ping, Ping),
  register(pong, Pong).

stop() ->
  ping ! stop,
  pong ! stop.

play(N) when is_integer(N) ->
  ping ! N.

ping_loop(Sum) ->
  receive
    stop -> ok;
    0 -> ping_loop(Sum);
    N -> io:format("Ping! Received: ~w Sum: ~w~n", [N, Sum+N]),
      timer:sleep(1000),
      pong ! (N - 1),
      ping_loop(Sum + N)
  after
    20000 -> ok
  end.

pong_loop(Sum) ->
  receive
    stop -> ok;
    0 -> pong_loop(Sum);
    N -> io:format("Pong! Received: ~w~n", [N]),
      timer:sleep(1000),
      ping ! (N - 1),
      pong_loop(Sum)
  after
    20000 -> ok
  end.