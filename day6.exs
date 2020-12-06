input_stream = fn ->
  System.argv()
  |> hd()
  |> File.stream!()
  |> Stream.map(&String.trim/1)
end

make_groups = fn stream ->
  stream
  |> Stream.chunk_by(& &1 == "")
  |> Stream.reject(& &1 == [""])
end

questions_anyone_said_yes = fn stream ->
  stream
  |> Stream.map(&Enum.join/1)
  |> Stream.map(&String.to_charlist/1)
  |> Stream.map(&MapSet.new/1)
end

questions_everyone_said_yes = fn stream ->
  stream
  |> Stream.map(fn group ->
    group
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.intersection/2)
  end)
end

count_questions = fn stream ->
  stream
  |> Stream.map(&MapSet.size/1)
end

input_stream.()
|> make_groups.()
|> questions_anyone_said_yes.()
|> count_questions.()
|> Enum.sum()
|> IO.inspect(label: "Part1")

input_stream.()
|> make_groups.()
|> questions_everyone_said_yes.()
|> count_questions.()
|> Enum.sum()
|> IO.inspect(label: "Part2")
