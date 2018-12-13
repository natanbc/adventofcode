defmodule Adventofcode do
  def main([]) do
    days = find_days()
    IO.puts("Running all days (#{days})")
    Enum.flat_map(1..days, &run/1)
    |> wait_for()
  end

  def main(["bench"]) do
    bench(1..find_days())
  end

  def main(["bench" | days]) do
   bench(days |> Enum.map(&String.to_integer/1))
  end

  def main(days) do
    days = days |> Enum.map(&String.to_integer/1)
    IO.puts("Running days #{inspect days}")
    Enum.flat_map(days, &run/1)
    |> wait_for()
  end

  def run_day(day), do: run(day) |> wait_for()

  defp bench(days) do
    days |> Enum.flat_map(fn day ->
      content = File.read!("input/Day#{day}.txt")
      mod = String.to_atom("Elixir.Tasks.Day#{day}")
      [{"Day #{day} part 1", fn -> mod.part1(content) end}, {"Day #{day} part 2", fn -> mod.part2(content) end}]
    end)
    |> Map.new
    |> Benchee.run(memory_time: 2, print: [fast_warning: false])
  end

  defp wait_for([]), do: nil

  defp wait_for([pid | pids]) do
    receive do
      {:result, ^pid, {day, part, {time, result}}} ->
        IO.puts("Day #{day} part #{part}: #{result} (#{(time/1000) |> Float.round(3)} ms)")
      {:result, ^pid, {day, part, {time, result, runs}}} ->
        IO.puts("Day #{day} part #{part}: #{result} (#{(time/1000) |> Float.round(3)} ms, average over #{runs} runs)")
    end
    wait_for(pids)
  end

  defp run(day) do
    [] |> maybe_run(day, 1) |> maybe_run(day, 2)
  end

  defp maybe_run(pids, day, part) do
    parent = self()
    mod = String.to_atom("Elixir.Tasks.Day#{day}")
    fname = String.to_atom("part#{part}")
    if Code.ensure_loaded?(mod) && function_exported?(mod, fname, 1) do
      pid = spawn_link fn ->
        content = File.read!("input/Day#{day}.txt")
        runs = System.get_env("RUNS")
        res = if runs && String.to_integer(runs) > 1 do
          n = String.to_integer(runs)
          {time, r} = Enum.map(1..n, fn _ ->
            :timer.tc(mod, fname, [content])
          end) |> Enum.reduce({0, nil}, fn {total, _}, {time, res} -> {total + time, res} end)
          {time / n, r, n}
        else
          :timer.tc(mod, fname, [content])
        end
        send parent, {:result, self(), {day, part, res}}
      end
      pids ++ [pid]
    else
      pids
    end
  end

  defp find_days(day \\ 1) do
    mod = String.to_atom("Elixir.Tasks.Day#{day}")
    if Code.ensure_loaded?(mod) do
      find_days(day + 1)
    else
      day - 1
    end
  end
end
