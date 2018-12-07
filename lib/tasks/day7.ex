defmodule Tasks.Day7 do
  use Day
  @behaviour Day

  def part1(input) do
    map = String.split(input, ~r(\r?\n))
    |> Enum.map(&parse/1)
    |> Enum.reduce(%{}, fn {first, second}, acc ->
      Map.update(acc, second, [first], & [first | &1])
    end)
    g = :digraph.new()
    Enum.to_list(map) |> Enum.each(fn {k, deps} ->
      :digraph.add_vertex(g, k)
      Enum.each(deps, fn d -> add_dependency(g, k, d) end)
    end)
    sort(g) |> Enum.reverse
  end

  def part2(input) do
    map = String.split(input, ~r(\r?\n))
          |> Enum.map(&parse/1)
          |> Enum.reduce(%{}, fn {first, second}, acc ->
      Map.update(acc, second, [first], & [first | &1])
    end)
    dependencies = :ets.new(:deps, [])
    Enum.to_list(map) |> Enum.sort(& (elem(&1, 0) < elem(&2, 0))) |> Enum.each(fn {k, deps} ->
      :ets.insert(dependencies, {k, deps})
      Enum.each(deps, fn d -> :ets.insert_new(dependencies, {d, []}) end)
    end)
    loop(dependencies, [new_worker(), new_worker(), new_worker(), new_worker(), new_worker()])
  end

  defp add_dependency(g,l,d) do
    :digraph.add_vertex(g,d)
    :digraph.add_edge(g,d,l)
  end

  defp sort(g, acc \\ []) do
    :digraph.vertices(g)
    |> Enum.filter(fn v -> !(v in acc) && Enum.all?(:digraph.in_neighbours(g, v), fn i -> i in acc end) end)
    |> Enum.sort(&</2)
    |> Enum.reduce(acc, fn v, acc2 ->
      r = sort(g, [v | acc2])
      Enum.filter(r, fn vt -> !(vt in acc2) end) ++ acc2
    end)
  end

  defp new_worker(), do: {nil, 0}

  defp completed(deps, task) do
    :ets.tab2list(deps)
    |> Enum.each(fn {k, d} ->
      :ets.insert(deps, {k, Enum.filter(d, fn e -> e != task end)})
    end)
  end

  defp loop(deps, workers, time \\ 0)
  defp loop(deps, workers, time) do
    if :ets.info(deps, :size) == 0 && Enum.all?(workers, fn {_, c} -> c == 0 end) do
      time
    else
      Enum.each(workers, fn {task, c} ->
        if c == 0 do
          :ets.delete(deps, task);
          completed(deps, task)
        end
      end)
      workers = Enum.map(workers, fn
        {task, count} when count > 0 -> {task, count - 1}
        {task, 0} ->
          case Enum.filter(:ets.tab2list(deps), fn {_, d} -> d == [] end)
               |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))
               |> Enum.take(1) do
            [] -> {task, 0}
            [{t, _}] -> :ets.delete(deps, t); {t, t - ?A + 60}
          end
      end)
      loop(deps, workers, time + 1)
    end
  end

  defp parse(<<"Step ", a, " must be finished before step ", b, " can begin.">>) do
    {a, b}
  end
end
