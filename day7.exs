defmodule LuggageRules do
  def new(path) do
    path
    |> input_stream()
    |> make_digraph()
  end

  def can_carry(graph, bag_color) do
    :digraph.vertices(graph)
    |> Enum.map(fn
      ^bag_color -> false
      v1 -> :digraph.get_path(graph, v1, bag_color)
    end)
  end

  def bags_count(graph, bag_color) do
    inner_bags = get_bags_inside(graph, bag_color)

    inner_bags_count =
      inner_bags
      |> Enum.map(fn {count, _color} -> count end)
      |> Enum.sum()

    inner_bags
    |> Enum.reduce(inner_bags_count, fn {count, bag}, acc ->
      acc + count * bags_count(graph, bag)
    end)
  end

  defp get_bags_inside(graph, bag_color) do
    :digraph.edges(graph, bag_color)
    |> Enum.map(&:digraph.edge(graph, &1))
    |> Enum.map(fn
      {_, ^bag_color, v2, count} -> {count, v2}
      _ -> false
    end)
    |> Enum.filter(& &1)
  end

  defp input_stream(path) when is_binary(path) do
    path
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end

  defp make_digraph(stream) do
    stream
    |> Enum.reduce(:digraph.new(), fn rule, graph ->
      parse_rule(rule)
      |> add_vertices_edges(graph)

      graph
    end)
  end

  defp add_vertices_edges({bag, []}, graph), do: :digraph.add_vertex(graph, bag)

  defp add_vertices_edges({bag, contains}, graph) do
    :digraph.add_vertex(graph, bag)

    contains
    |> Enum.map(fn {count, contained_bag} ->
      :digraph.add_vertex(graph, contained_bag)
      :digraph.add_edge(graph, bag, contained_bag, count)
    end)
  end

  defp parse_rule(rule) do
    [bag1 | contains] =
      rule
      |> String.split(["contain", ","], trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.replace(&1, ~r/ bag[s.]*/, ""))

    contains =
      contains
      |> Enum.map(&String.split/1)
      |> Enum.map(fn
        ["no", "other"] ->
          []

        [count, color1, color2] ->
          {String.to_integer(count), "#{color1} #{color2}"}
      end)
      |> List.flatten()

    {bag1, contains}
  end
end

rules =
  System.argv()
  |> hd()
  |> LuggageRules.new()

rules
|> LuggageRules.can_carry("shiny gold")
|> Enum.filter(& &1)
|> Enum.count()
|> IO.inspect(label: "Part1")

rules
|> LuggageRules.bags_count("shiny gold")
|> IO.inspect(label: "Part2")
