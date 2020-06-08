defmodule PollutionData do
  require Record
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  def scan_text(text) do
    :xmerl_scan.string(String.to_charlist(text))
  end

  def count() do
    data = File.read!("pollution.xml")
           |> String.split("</measure>")
    count = length(data)
    count-1
  end

  def pollution_parse() do
    File.read!("pollution.xml")
    |> scan_text
  end

  def parse_line(xml, line) do
    [date_element] = :xmerl_xpath.string('/root/measure[' ++ to_charlist(line) ++ ']/date', xml)
    [date_text] = xmlElement(date_element, :content)
    date = xmlText(date_text, :value)
    date = List.to_string(date)
    date = date
           |> String.split("-")
           |> Enum.reverse()
           |> Enum.map(&String.to_integer/1)
           |> List.to_tuple()

    [time_element] = :xmerl_xpath.string('/root/measure[' ++ to_charlist(line) ++ ']/time', xml)
    [time_text] = xmlElement(time_element, :content)
    time = xmlText(time_text, :value)
    time = List.to_string(time)
    time = String.split(time, ":", [])
    time = time ++ ["0"]
    time = time
           |> Enum.map(&String.to_integer/1)
           |> List.to_tuple()

    [length_element] = :xmerl_xpath.string('/root/measure[' ++ to_charlist(line) ++ ']/length', xml)
    [length_text] = xmlElement(length_element, :content)
    length = xmlText(length_text, :value)
    length = List.to_string(length)
    length = String.to_float(length)

    [width_element] = :xmerl_xpath.string('/root/measure[' ++ to_charlist(line) ++ ']/width', xml)
    [width_text] = xmlElement(width_element, :content)
    width = xmlText(width_text, :value)
    width = List.to_string(width)
    width = String.to_float(width)

    [value_element] = :xmerl_xpath.string('/root/measure[' ++ to_charlist(line) ++ ']/value', xml)
    [value_text] = xmlElement(value_element, :content)
    value = xmlText(value_text, :value)
    value = List.to_string(value)
    value = String.trim(value)
    value = String.to_integer(value)

    %{:datetime => {date, time}, :location => {width, length}, :pollutionLevel => value}
  end

  def identify_stations({xml, _}) do
    count = count()
    lines = for line <- 1..count do
      parse_line(xml, line)
    end
    uniq_stations = Enum.uniq_by(lines, &(&1.location))
    stations = for station <- uniq_stations, do: station[:location]
    stations
  end

  def add_stations() do
    stations = PollutionData.identify_stations(PollutionData.pollution_parse())
    for station <- stations, do:
      :pollution_gen_server.addStation(
        "station_#{
          station
          |> elem(0)
        }_#{
          station
          |> elem(1)
        }",
        station
      )
  end

  def add_values() do
    {xml,_} = PollutionData.pollution_parse()
    count = count()
    separated_lines = for line <- 1..count do
      parse_line(xml, line)
    end

    for station <- separated_lines, do:
      :pollution_gen_server.addValue(
        "station_#{
          station[:location]
          |> elem(0)
        }_#{
          station[:location]
          |> elem(1)
        }",
        station[:datetime],
        "PM10",
        station[:pollutionLevel]
      )
  end
  def test() do
    :pollution_sup.start_link()
    importStations = fn -> add_stations() end
    importValues = fn -> add_values() end
    IO.puts(
      "#{
        importStations
        |> :timer.tc([])
        |> elem(0)
      }"
    )
    IO.puts(
      "#{
        importValues
        |> :timer.tc([])
        |> elem(0)
      }"
    )
    {time, value} = (&:pollution_gen_server.getDailyMean/2)
                    |> :timer.tc([{2017, 5, 3}, "PM10"])
    IO.puts("#{time}; #{value}")
  end
end

