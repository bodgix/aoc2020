defmodule Aoc2020.Day5 do
  @moduledoc """
  Module with helpers for the day5
  """

  @rows 0..127
  @cols 0..7
  @data "day5.txt"

  def part1() do
    input_stream()
    |> Enum.max()
    |> IO.inspect(label: "Part1")
  end

  def part2() do
    input_stream()
    |> Enum.sort()
    |> Enum.chunk_every(2)
    |> Enum.find(fn
      [seat1, seat2] when seat2 == seat1 + 2 -> true
      _ -> false
    end)
    |> (fn [seat1, _seat2] -> seat1 + 1 end).()
    |> IO.inspect(label: "Part2")
  end

  defp input_stream() do
    @data
    |> File.stream!()
    |> Stream.map(&String.trim/1)
    |> Stream.map(&get_seat_id/1)
  end

  def get_seat_id(binary_id) when is_binary(binary_id) do
    with {rest, row} <- get_row({binary_id, @rows}),
         {"", col} <-
           get_col({rest, @cols}) do
      row * 8 + col
    end
  end

  defp get_row({"F" <> rest, rows}), do: get_row({rest, take_lower_half(rows)})

  defp get_row({"B" <> rest, rows}), do: get_row({rest, take_upper_half(rows)})

  defp get_row(arg), do: arg

  defp get_col({"L" <> rest, cols}), do: get_col({rest, take_lower_half(cols)})
  defp get_col({"R" <> rest, cols}), do: get_col({rest, take_upper_half(cols)})
  defp get_col(arg), do: arg

  def take_lower_half(low..high) when high == low + 1, do: low
  def take_lower_half(low..high), do: low..(low + half_of_range(low..high))

  def take_upper_half(low..high) when high == low + 1, do: high
  def take_upper_half(low..high), do: (low + half_of_range(low..high) + 1)..high

  defp half_of_range(low..high), do: div(high - low, 2)
end

Aoc2020.Day5.part1()
Aoc2020.Day5.part2()
