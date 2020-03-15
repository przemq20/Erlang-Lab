%%%-------------------------------------------------------------------
%%% @author lecho
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. mar 2020 17:32
%%%-------------------------------------------------------------------
-module(onp).
-author("lecho").

%% API
-export([onp/1]).

%% 1 + 2 * 3 - 4 / 5 + 6 =  1 2 3 * 4 5 / - 6 + +
%% 1 + 2 + 3 + 4 + 5 + 6 * 7 = 1 2 + 3 + 4 + 5 + 6 7 * +
%% ( (4 + 7) / 3 ) * (2 - 19) = 4 7 + 3 / 2 19 - *
%% 17 * (31 + 4) / ( (26 - 15) * 2 - 22 ) - 1 = 17 31 4 + 26 15 - 2 * 22 - / 1 - *     //dzielenie przez 0

%% Kalkulator obsługuje dodawanie, odejmowanie, mnożenie, dzielenie (sprawdzane jest dzielenie przez 0), pierwiastek (nie może być z ujemnej liczby)
%% podnoszenie do potęgi, sinus, cosinus, tangens oraz dwa zmyślone operatory: "#" i ","
%% kalkulator obsługuje zarówno typ Integer jak i Float


onp(Wyr) ->
  List = string:tokens(Wyr, " "),
  calc(List, []).

calc([], [H | T]) -> H;
calc(["+" | T], [A, B | T1]) -> calc(T, [B + A | T1]);
calc(["-" | T], [A, B | T1]) -> calc(T, [B - A | T1]);
calc(["*" | T], [A, B | T1]) -> calc(T, [B * A | T1]);
calc(["/" | T], [A, B | T1]) when(A == 0) -> io:format("Dzielenie przez 0 \n");
calc(["/" | T], [A, B | T1]) -> calc(T, [B / A | T1]);
calc(["sqrt" | T], [A | T1]) when (A < 0) -> io:format("Pierwiastek z ujemnej liczby \n");
calc(["sqrt" | T], [A | T1]) -> calc(T, [math:sqrt(A) | T1]);
calc(["pow" | T], [A, B | T1]) -> calc(T, [math:pow(B, A) | T1]);
calc(["sin" | T], [H | T1]) -> calc(T, [math:sin(H) | T1]);
calc(["cos" | T], [H | T1]) -> calc(T, [math:cos(H) | T1]);
calc(["tan" | T], [H | T1]) -> calc(T, [math:tan(H) | T1]);
calc(["#" | T], [A, B | T1]) when(A*B == 0)-> io:format("Dzielenie przez 0 \n");
calc(["#" | T], [A, B | T1]) -> calc(T, [((B + 1) * (A + 1)) / (A * B) | T1]);
calc(["," | T], [H | T1]) -> calc(T, [(H + 2) * 2 | T1]);
calc([H | T], Stack) ->
  case string:str(H, ".") of
    0 -> calc(T, [list_to_integer(H) | Stack]);
    _ -> calc(T, [list_to_float(H) | Stack])
  end.

