defmodule Passport do
  def valid?(passport) when is_binary(passport) do
    passport
    |> parse()
    |> validate()
  end

  defp parse(passport) do
    passport
    |> String.split([" ", ":"])
    |> Enum.chunk_every(2)
  end

  defp validate(fields) do
    fields
    |> Enum.map(&validate_field/1)
    |> Enum.filter(& &1)
    |> Enum.count() == 7
  end

  defp validate_range(val, range), do: String.to_integer(val) |> Kernel.in(range)

  defp validate_field(["byr", val]), do: validate_range(val, 1920..2002)

  defp validate_field(["iyr", val]), do: validate_range(val, 2010..2020)

  defp validate_field(["eyr", val]), do: validate_range(val, 2020..2030)

  defp validate_field(["hgt", val]) do
    case String.split_at(val, -2) do
      {cms, "cm"} ->
        validate_range(cms, 150..193)

      {ins, "in"} ->
        validate_range(ins, 59..76)

      _ ->
        false
    end
  end

  defp validate_field(["hcl", val]) do
    ~r/#[0-9a-f]{6}/
    |> Regex.match?(val)
  end

  defp validate_field(["ecl", val]) do
    val in ~w[amb blu brn gry grn hzl oth]
  end

  defp validate_field(["pid", val]) do
    ~r/^[0-9]{9}$/
    |> Regex.match?(val)
  end

  defp validate_field(["cid", _val]), do: false
end

input_stream = fn ->
  System.argv()
  |> hd()
  |> File.stream!()
  |> Stream.map(&String.trim/1)
end

make_passports = fn stream ->
  stream
  |> Stream.chunk_by(&(&1 != ""))
  |> Stream.filter(&(&1 != [""]))
  |> Stream.map(&Enum.join(&1, " "))
end

input_stream.()
|> make_passports.()
|> Stream.filter(&Passport.valid?/1)
|> Enum.count()
|> IO.puts()
