defmodule Password do
  defstruct ~w[policy password]a

  def new(policy_and_password, part \\ 1) when is_binary(policy_and_password) do
    %__MODULE__{}
    |> parse(policy_and_password, part)
  end

  def meets_policy?(
        %__MODULE__{policy: {min, max, character} = _policy, password: password},
        1
      ) do
    count = Map.get(password, character, 0)
    count >= min and count <= max
  end

  def meets_policy?(
        %__MODULE__{policy: {pos1, pos2, character} = _policy, password: password},
        2
      ) do
    {password[pos1], password[pos2]}
    |> case do
      {^character, x} when x != character ->
        true

      {x, ^character} when x != character ->
        true

      _ ->
        false
    end
  end

  defp parse(%__MODULE__{} = result, policy_and_password, part) do
    [_full | matches] =
      ~r/(\d+)-(\d+) ([a-z]): (.*)/
      |> Regex.run(policy_and_password)

    result
    |> parse_policy(matches)
    |> parse_password(matches, part)
  end

  defp parse_policy(%__MODULE__{} = result, [min, max, character, _password]),
    do: %{result | policy: {String.to_integer(min), String.to_integer(max), character}}

  defp parse_password(%__MODULE__{} = result, [_min, _max, _character, password], 1) do
    %{
      result
      | password: string_to_char_frequency_map(password)
    }
  end

  defp parse_password(%__MODULE__{} = result, [_min, _max, _character, password], 2) do
    %{
      result
      | password: string_to_ordered_map(password)
    }
  end

  defp string_to_char_frequency_map(string) when is_binary(string) do
    string
    |> String.graphemes()
    |> Enum.reduce(%{}, fn char, acc ->
      Map.put(acc, char, (acc[char] || 0) + 1)
    end)
  end

  defp string_to_ordered_map(password) when is_binary(password) do
    {_meh, result} =
      password
      |> String.graphemes()
      |> Enum.reduce({1, %{}}, fn char, {index, map} = _acc ->
        {index + 1, Map.put(map, index, char)}
      end)

    result
  end
end

File.stream!("day2.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&Password.new/1)
|> Stream.filter(&Password.meets_policy?(&1, 1))
|> Enum.count()
|> IO.inspect(label: "Part1")

File.stream!("day2.txt")
|> Stream.map(&String.trim/1)
|> Stream.map(&Password.new(&1, 2))
|> Stream.filter(&Password.meets_policy?(&1, 2))
|> Enum.count()
|> IO.inspect(label: "Part2")
