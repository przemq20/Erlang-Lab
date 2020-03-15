%%%-------------------------------------------------------------------
%%% @author lecho
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. mar 2020 16:59
%%%-------------------------------------------------------------------
-module(myLists).
-author("lecho").

%% API
-export([contains/2, duplicateElements/1,sumFloats/1,sumFloats_tail/2]).

contains([],_) -> false;
contains([H|T],A) ->
  if
    H == A -> true;
    true -> contains(T,A)
  end.

  
sumFloats([]) -> 0.0;
sumFloats([H|T]) -> H + sumFloats(T).

sumFloats_tail([],Sum) -> Sum;
sumFloats_tail([H|T], Sum) -> sumFloats_tail(T, Sum+H).

duplicateElements([]) -> [];
duplicateElements([H|T]) -> [H,H] ++ duplicateElements(T).