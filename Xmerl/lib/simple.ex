defmodule Simple do
  require Record
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  def parse() do
    File.read!("simple.xml")
    |> scan_text
    |> parse_xml
  end

  def scan_text(text) do
    :xmerl_scan.string(String.to_charlist(text))
  end

  def parse_xml({xml, _}) do
    [element] = :xmerl_xpath.string('/breakfast_menu/food[1]/description', xml)
    [text] = xmlElement(element, :content)
    value = xmlText(text, :value)
    IO.puts(value)

    elements = :xmerl_xpath.string('/breakfast_menu//food/name', xml)
    Enum.each(
      elements,
      fn (element) ->
        [text] = xmlElement(element, :content)
        value = xmlText(text, :value)
        IO.puts(value)
      end
    )
  end
end