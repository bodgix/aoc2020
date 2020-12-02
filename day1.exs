defmodule Expenses do
  def from_file(path) when is_binary(path) do
    File.stream!(path)
    |> Stream.map(&String.trim/1)
    |> Stream.map(&String.to_integer/1)
  end

  def find_2020(expenses) when is_map(expenses) do
    expenses
    |> Enum.reduce_while(0, fn {expense, expense}, _acc ->
      case Map.fetch!(expenses, 2020 - expense) do
        {:ok, value} ->
          {:halt, value * expense}

        _ ->
          {:cont, 0}
      end
    end)
  end

  def find_three_2020([x, y, z]) do
    case x + y + z do
      2020 ->
        {:halt, x * y * z}

      _ ->
        {:cont, 0}
    end
  end

  def part1() do
    "day1.txt"
    |> from_file()
    |> stream_to_expense_map()
    |> find_2020()
  end

  def part2() do
    "day1.txt"
    |> from_file()
    |> Enum.to_list()
    |> combinations(3)
    |> Enum.reduce_while(0, fn triplet, acc ->
      find_three_2020(triplet)
    end)
  end

  defp combinations(_, 0), do: [[]]
  defp combinations([], _), do: []

  defp combinations([head | tail], size) do
    for(elem <- combinations(tail, size - 1), do: [head | elem]) ++ combinations(tail, size)
  end

  defp found_expense(expense, expenses) do
    case Map.fetch(expenses, 2020 - expense) do
      {:ok, value} ->
        {:halt, expense * value}

      _ ->
        {:cont, 0}
    end
  end

  defp stream_to_expense_map(stream) do
    stream
    |> Enum.reduce(%{}, fn expense, acc ->
      Map.put(acc, expense, expense)
    end)
  end
end

Expenses.part1()
|> IO.inspect(label: "Part1")

Expenses.part2()
|> IO.inspect(label: "Part2")
