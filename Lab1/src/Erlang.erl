%%%-------------------------------------------------------------------
%%% @author lecho
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. mar 2020 16:44
%%%-------------------------------------------------------------------
-module('Erlang').
-author("lecho").

%% API
-export([pow/2]).

pow(_, 0) -> 1;
pow(A, N) when is_integer(N) -> A * pow(A, N-1).




