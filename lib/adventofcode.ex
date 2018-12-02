defmodule Adventofcode do
  def main([]) do
    days = find_days()
    IO.puts("Running all days (#{days})")
    Enum.flat_map(1..days, &run/1)
    |> wait_for()
  end

  def main(days) do
    days = days |> Enum.map(&String.to_integer/1)
    IO.puts("Running days #{inspect days}")
    Enum.flat_map(days, &run/1)
    |> wait_for()
  end

  def run_day(day), do: run(day) |> wait_for()

  defp wait_for([]), do: nil

  defp wait_for([pid | pids]) do
    receive do
      {:result, ^pid, {day, part, {time, result}}} ->
        IO.puts("Day #{day} part #{part}: #{result} (#{time/1000} ms)")
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
        res = :timer.tc(mod, fname, [content])
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
