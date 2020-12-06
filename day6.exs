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

make_set_for_each_person = fn stream ->
  stream
  |> Stream.map(fn group ->
    group
    |> Enum.map(fn person ->
      person
      |> String.to_charlist()
      |> MapSet.new()
    end)
  end)
end

make_set_with_groups_common_answers = fn stream ->
  stream
  |> Stream.map(fn answers_from_persons ->
    answers_from_persons
    |> Enum.reduce(MapSet.new(?a..?z), fn answers_from_person, acc ->
      MapSet.intersection(acc, answers_from_person)
    end)
  end)
end

questions_everyone_said_yes = fn stream ->
  stream
  |> make_set_for_each_person.()
  |> make_set_with_groups_common_answers.()
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
|> Enum.to_list()
|> count_questions.()
|> Enum.sum()
|> IO.inspect(label: "Part2")
