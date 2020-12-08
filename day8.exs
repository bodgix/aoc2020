defmodule Computer do
  defstruct pc: 0,
            program: %{},
            program_size: 0,
            acc: 0,
            instruction_history: [],
            finished: false,
            last_fixed_instruction: 0

  def new(path) when is_binary(path) do
    %__MODULE__{}
    |> load_program(path)
    |> save_program_size()
  end

  def fix_until_good(broken_computer, original_program) do
    broken_computer
    |> reset(original_program)
    |> fix()
    |> run()
    |> (fn computer ->
          (program_completed?(computer) && computer) || fix_until_good(computer, original_program)
        end).()
  end

  def run(%{pc: pc, program_size: program_size} = computer) when pc == program_size,
    do: %{computer | finished: true}

  def run(%{pc: pc, program: program} = computer) do
    with false <- exit_program?(computer),
         instruction <- Map.fetch!(program, pc) do
      computer |> exec(instruction) |> run()
    else
      _ ->
        computer
    end
  end

  def replace_instr(%{} = computer, pc, new_instr),
    do: %{computer | program: Map.put(computer.program, pc, new_instr)}

  def reset(%{} = computer, program),
    do: %{computer | pc: 0, instruction_history: [], acc: 0, program: program}

  def program_completed?(%{finished: finished} = _computer), do: finished

  def fix(%{} = computer) do
    (computer.last_fixed_instruction + 1)..computer.program_size
    |> Enum.reduce_while(computer, fn pc, acc ->
      case acc.program[pc] do
        {"nop", addr} ->
          new_computer = acc |> replace_instr(pc, {"jmp", addr})
          {:halt, %{new_computer | last_fixed_instruction: pc + 1}}

        {"jmp", addr} ->
          new_computer = acc |> replace_instr(pc, {"nop", addr})
          {:halt, %{new_computer | last_fixed_instruction: pc + 1}}

        _ ->
          {:cont, acc}
      end
    end)
  end

  defp exit_program?(%{pc: pc, instruction_history: history} = _computer),
    do: pc in history

  defp exec(%{} = computer, {"nop", _addr} = _instr),
    do: computer |> save_instruction() |> inc_pc(1)

  defp exec(%{} = computer, {"acc", addr}),
    do: %{computer | acc: computer.acc + addr} |> save_instruction() |> inc_pc(1)

  defp exec(%{} = computer, {"jmp", addr}),
    do: computer |> save_instruction() |> inc_pc(addr)

  defp inc_pc(%{pc: pc} = computer, count), do: %{computer | pc: pc + count}

  defp save_instruction(%{pc: pc} = computer),
    do: %{computer | instruction_history: [pc | computer.instruction_history]}

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

computer =
  System.argv()
  |> hd()
  |> Computer.new()

computer
|> Computer.run()
|> Map.get(:acc)
|> IO.inspect(label: "Part1")

computer
|> Computer.run()
|> Computer.fix_until_good(computer.program)
|> Map.get(:acc)
|> IO.inspect(label: "Part2")

