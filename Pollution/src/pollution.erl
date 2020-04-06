%%%-------------------------------------------------------------------
%%% @author lecho
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. mar 2020 11:37
%%%-------------------------------------------------------------------
-module(pollution).
-author("lecho").

%% API
-export([
  createMonitor/0,
  addStation/3,
  addValue/5,
  removeValue/4,
  getOneValue/4,
  getStationMean/3,
  getDailyMean/3,
  findStation/2,
  getStationMinMaxValue/3,
  getDailyMinMaxValue/3,
  test/0
]).

-record(measurement, {date, type, value}).
-record(station, {name, localization}).

%Funckja pomocnicza, sprawdza czy stacja istnieje. Jeżeli nie- zwraca false, jeżeli tak - zwraca stację.
findStation({X, Y}, [H | T]) ->
  case {X, Y} =:= H#station.localization of
    true -> H;
    _ -> findStation({X, Y}, T)
  end;
findStation({X, Y}, [H]) ->
  case {X, Y} =:= H#station.localization of
    true -> H;
    false -> false
  end;

findStation(Name, [H | T]) ->
  case Name == H#station.name of
    true -> H;
    _ -> findStation(Name, T)
  end;
findStation(Name, [H]) ->
  case Name == H#station.name of
    false -> false;
    _ -> H
  end;

findStation({X, Y}, []) -> false;
findStation(Name, []) -> false.

%Funckja tworzy nowy monitor zanieczyszczń
createMonitor() -> #{}.

%Funkcja dodaje nową stację, sprawdzając czy nie jest utworzona już o podanie nazwie lub koordynatach
addStation(Name, {X, Y}, P) ->
  case findStation(Name, maps:keys(P)) orelse findStation({X, Y}, maps:keys(P)) of
    false -> P#{#station{name = Name, localization = {X, Y}} => []};
    _ -> throw("Station with the given coordinates or name already exists")
  end.

%Funkcja dodaje pomiar do statcji, sprawdzając czy do danej stacji nie jest już dodany pomiar o takiej samej dacie, typie i współrzędnych
addValue(NameOrCoords, {_, _} = NewDate, Type, Val, P) ->
  Station = findStation(NameOrCoords, maps:keys(P)),
  case Station of
    false -> throw("Station does not exists");
    _ ->
      Map = maps:get(Station, P),
      F = fun(#measurement{type = T, date = Date}) -> T =:= Type andalso Date =:= NewDate end,
      case lists:any(F, Map) of
        true -> throw("Measurement already exists");
        _ -> P#{Station := [#measurement{date = NewDate, type = Type, value = Val} | Map]}
      end
  end.

%Funckja usuwa pomiar ze stacji
removeValue(NameOrCoords, Date, Type, P) ->
  Station = findStation(NameOrCoords, maps:keys(P)),
  case Station of
    false -> throw("Station does not exists");
    _ ->
      F = fun(#measurement{date = D, type = T}) -> D =/= Date orelse T =/= Type end,
      List = lists:filter(F, maps:get(Station, P)),
      P#{Station := List}
  end.

%Funkcja zwraca wartosc pomiaru o podanym typie i dacie z podanej stacji
getOneValue(NameOrCoords, Date, Type, P) ->
  Station = findStation(NameOrCoords, maps:keys(P)),
  case Station of
    false -> throw("Station does not exists");
    _ ->
      F = fun(#measurement{date = D, type = T}) ->
        D =:= Date andalso T =:= Type end,
      case lists:filter(F, maps:get(Station, P)) of
        [] -> throw("Measurent does not exist");
        [H] -> H#measurement.value
      end
  end.

%Funkcja zwraca średnią arytmetyczną z wartości pomiarów o podanym Typie z podanej stacji kiedykolwiek
getStationMean(NameOrCoords, Type, P) ->
  Station = findStation(NameOrCoords, maps:keys(P)),
  case Station of
    false -> throw("Station does not exists");
    _ ->
      F = fun(#measurement{value = V1}, V2) -> V1 + V2 end,
      F1 = fun(#measurement{type = T}) -> T =:= Type end,
      Sum = lists:foldl(F, 0, lists:filter(F1, maps:get(Station, P))),
      Length = length(lists:filter(F1, maps:get(Station, P))),
      Sum / Length
  end.

%Funkcja zwraca średnią arytmetyczną z wartości pomiarów danego typu z danego dnia
getDailyMean({_, _, _} = Date, Type, P) ->
  List = lists:flatten(maps:values(P)),
  F1 = fun(#measurement{date = {D, _}, type = T}) -> D =:= Date andalso T =:= Type end,
  List2 = lists:filter(F1, List),
  F2 = fun(#measurement{value = V1}, V2) -> V1 + V2 end,
  lists:foldl(F2, 0, List2) / length(List2).


%Funkcja zwraca minimalną i maksymalną wartość pomiaru danego typu w danym dniu
getDailyMinMaxValue({_, _, _} = Date, Type, P) ->
  List = lists:flatten(maps:values(P)),
  F1 = fun(#measurement{date = {D, _}, type = T}) -> D =:= Date andalso T =:= Type end,
  Values = lists:filter(F1, List),
  Min = lists:min(Values),
  Max = lists:max(Values),
  {Min#measurement.value, Max#measurement.value}.

%Funkcja zwraca minimalną i maksymalną wartość pomiaru danego typu na danej stacji kiedykolwiek
getStationMinMaxValue(NameOrCoords, Type, P) ->
  case findStation(NameOrCoords, maps:keys(P)) of
    false -> throw("Station does not exists");
    Station ->
      List1 = maps:get(Station, P),
      F1 = fun(#measurement{type = T}) -> T =:= Type end,
      List2 = lists:filter(F1, List1),
      F2 = fun(#measurement{value = V}) -> V end,
      Values = lists:map(F2, List2),
      {lists:min(Values), lists:max(Values)}
  end.

%Funkcja testowa
test() ->
  P = pollution:createMonitor(),
  P1 = pollution:addStation("Pierwsza", {10, 20}, P),
  P2 = pollution:addStation("Druga", {1, 30}, P1),
  P3 = pollution:addStation("Trzecia", {45, 90}, P2),
  P4 = pollution:addValue({10, 20}, calendar:local_time(), "PM10", 10, P3),
  P5 = pollution:addValue("Druga", calendar:local_time(), "PM10", 500, P4),
  P6 = pollution:addValue("Trzecia", calendar:local_time(), "PM10", 100, P5),
  P7 = pollution:addValue("Pierwsza", calendar:local_time(), "PM2.5", 1, P6),
  P8 = pollution:addValue({1, 30}, calendar:local_time(), "PM2.5", 20, P7),
  P9 = pollution:addValue({45, 90}, calendar:local_time(), "PM2.5", 30, P8),
  P10 = pollution:addValue("Pierwsza", {{2020, 4, 4}, {20, 20, 20}}, "PM2.5", 3, P9).
