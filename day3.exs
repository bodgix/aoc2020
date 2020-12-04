defmodule TreeMap do
  defstruct ~w[map max_x max_y]a

  def new(txt) when is_binary(txt) do
    %__MODULE__{}
    |> parse(txt)
  end

  def is_tree?(%__MODULE__{map: map, max_x: max_x, max_y: max_y} = _map, {x, y})
      when y <= max_y do
    map[y][rem(x, max_x + 1)] == "#"
  end

  def in_bounds?(%__MODULE__{max_y: max_y} = _map, {_x, y} = _coords) when y <= max_y, do: true

  def in_bounds?(%__MODULE__{} = _map, _coords), do: false

  defp parse(result, txt) do
    {map, max_y, max_x} =
      txt
      |> String.split()
      |> Enum.map(&String.trim/1)
      |> Enum.reduce({%{}, 0, 0}, fn line, {result, y, _max_x} = _acc ->
        line_as_map =
          0..String.length(line)
          |> Enum.zip(String.graphemes(line))
          |> Enum.into(%{})

        {Map.put(result, y, line_as_map), y + 1, String.length(line) - 1}
      end)

    %{result | map: map, max_y: max_y - 1, max_x: max_x}
  end
end

map =
  File.read!("day3.txt")
  |> TreeMap.new()

slope1 = fn {x, y} ->
  {x + 1, y + 1}
end

slope2 = fn {x, y} ->
  {x + 3, y + 1}
end

slope3 = fn {x, y} ->
  {x + 5, y + 1}
end

slope4 = fn {x, y} ->
  {x + 7, y + 1}
end

slope5 = fn {x, y} ->
  {x + 1, y + 2}
end

[slope1, slope2, slope3, slope4, slope5]
|> Enum.map(fn fun ->
  Stream.iterate({0, 0}, fun)
  |> Enum.take_while(&TreeMap.in_bounds?(map, &1))
  |> Enum.map(fn coords ->
    (TreeMap.is_tree?(map, coords) && 1) || 0
  end)
  |> Enum.sum()
end)
|> Enum.reduce(1, &*/2)
|> IO.puts()
