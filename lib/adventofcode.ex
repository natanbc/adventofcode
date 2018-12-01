defmodule Adventofcode do
  @days 1
  @days_list Enum.into(1..@days, [])

  def main([]) do
    IO.puts("Running all days (#{inspect @days_list})")
    Enum.flat_map(1..@days, &run/1)
    |> wait_for()
  end

  def main(days) do
    IO.puts("Running days #{inspect days}")
    Enum.flat_map(days |> Enum.map(&String.to_integer/1), &run/1)
    |> wait_for()
  end

  def run_day(day), do: run(day) |> wait_for()

  defp wait_for([]), do: nil

  defp wait_for([pid | pids]) do
    receive do
      {:result, ^pid, {day, part, result}} -> IO.puts("Day #{day} part #{part}: #{result}")
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
    Code.ensure_loaded?(mod)
    if function_exported?(mod, fname, 1) do
      pid = spawn_link fn ->
        res = apply(mod, fname, [
          File.read!("input/Day#{day}-#{part}.txt")
        ])
        send parent, {:result, self(), {day, part, res}}
      end
      pids ++ [pid]
    else
      pids
    end
  end
end
