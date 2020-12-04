input_stream = fn ->
  System.argv()
  |> hd()
  |> File.stream!()
  |> Stream.map(&String.trim/1)
end

count_trees = fn stream, {v_x, v_y} ->
  {_meh, trees} =
    stream
    |> Stream.take_every(v_y)
    |> Enum.reduce({0, 0}, fn trees, {x, trees_count} ->
      trees
      |> String.to_charlist()
      |> Stream.cycle()
      |> Enum.at(x)
      |> case do
        ?. -> {x + v_x, trees_count}
        ?# -> {x + v_x, trees_count + 1}
      end
    end)

  trees
end

[
  {1, 1},
  {3, 1},
  {5, 1},
  {7, 1},
  {1, 2}
]
|> Enum.map(fn speed ->
  input_stream.()
  |> count_trees.(speed)
end)
|> Enum.reduce(1, &*/2)
|> IO.puts()
