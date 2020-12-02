# 1-3 a: abcde
parse = fn line ->
  [min, max, char, pwd] =
    line
    |> String.split(["-", " ", ":"], trim: true)

  {String.to_integer(min), String.to_integer(max), char, pwd}
end

valid1 = fn {min, max, char, pwd} ->
  pwd
  |> String.graphemes()
  |> Enum.count(&(&1 == char))
  |> Kernel.in(min..max)
end

valid2 = fn {min, max, char, pwd} ->
  :erlang.xor(String.at(pwd, min - 1) == char, String.at(pwd, max - 1) == char)
end

input_stream = fn path ->
  path
  |> File.stream!()
  |> Stream.map(&String.trim/1)
  |> Stream.map(parse)
end

input_stream.("day2.txt")
|> Enum.count(valid1)
|> IO.inspect(label: "Part 1")

input_stream.("day2.txt")
|> Enum.count(valid2)
|> IO.inspect(label: "Part 2")
