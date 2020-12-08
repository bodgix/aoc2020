defmodule Computer do
  defstruct pc: 0, program: %{}, program_size: 0, acc: 0, instruction_history: MapSet.new()

  def new(path) when is_binary(path) do
    %__MODULE__{}
    |> load_program(path)
    |> save_program_size()
  end

  def run(%{pc: pc, program_size: program_size} = computer) when pc == program_size, do: computer

  def run(%{pc: pc, program: program} = computer) do
    with false <- exit_program?(computer),
         instruction <- Map.fetch!(program, pc) do
      computer |> exec(instruction) |> run()
    else
      _ ->
        computer
    end
  end

  defp exit_program?(%{pc: pc, instruction_history: history} = _computer),
    do: MapSet.member?(history, pc)

  defp exec(%{} = computer, {"nop", _addr} = _instr),
    do: computer |> save_instruction() |> inc_pc(1)

  defp exec(%{} = computer, {"acc", addr}),
    do: %{computer | acc: computer.acc + addr} |> save_instruction() |> inc_pc(1)

  defp exec(%{} = computer, {"jmp", addr}),
    do: computer |> save_instruction() |> inc_pc(addr)

  defp inc_pc(%{pc: pc} = computer, count), do: %{computer | pc: pc + count}

  defp save_instruction(%{pc: pc} = computer),
    do: %{computer | instruction_history: MapSet.put(computer.instruction_history, pc)}

  defp load_program(computer, path) do
    program =
      path
      |> input_stream()
      |> parse_program()

    %{computer | program: program}
  end

  defp input_stream(path), do: File.stream!(path) |> Stream.map(&String.trim/1)

  defp parse_program(stream) do
    {program, _meh} =
      stream
      |> Enum.map(&String.split/1)
      |> Enum.reduce({%{}, 0}, fn [instr, addr], {program, line} = _acc ->
        {Map.put(program, line, {instr, String.to_integer(addr)}), line + 1}
      end)

    program
  end

  defp save_program_size(%{program: program} = computer),
    do: %{computer | program_size: map_size(program)}
end

System.argv()
|> hd()
|> Computer.new()
|> Computer.run()
|> Map.get(:acc)
|> IO.inspect(label: "Part1")
