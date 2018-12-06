defmodule Tasks.Day6 do
  use Day
  @behaviour Day

  def part1(input) do
    points = String.split(input, ~r(\r?\n))
    |> Enum.map(&parse/1)
    {max_x, max_y} = Enum.reduce(points, fn {x,y}, {max_x, max_y} ->
      {max(x, max_x), max(y, max_y)}
    end)
    areas = :ets.new(:areas, [])
    infinite = :ets.new(:infinite, [])
    Enum.each((0)..(max_x), fn x ->
      Enum.each((0)..(max_y), fn y ->
        [{p1, d1}, {_, d2}] =
          Enum.map(points, fn a -> {a, distance(a, {x,y})} end)
          |> Enum.sort(& (elem(&1, 1) < elem(&2, 1)))
          |> Enum.take(2)
        if x == 0 || x == max_x || y == 0 || y == max_y do
          :ets.insert(infinite, {p1, 1})
        end
        if d1 < d2 do
          :ets.update_counter(areas, p1, {2, 1}, {p1, 0})
        end
      end)
    end)
    inf = :ets.tab2list(infinite) |> Enum.map(fn {k, _} -> k end)
    :ets.tab2list(areas)
    |> Enum.filter(fn {p, _} -> !(p in inf) end)
    |> Enum.sort(fn {_, area1}, {_, area2} -> area1 > area2 end)
    |> List.first
    |> elem(1)
  end

  def part2(input) do
    points = String.split(input, ~r(\r?\n))
             |> Enum.map(&parse/1)
    {max_x, max_y} = Enum.reduce(points, fn {x,y}, {max_x, max_y} ->
      {max(x, max_x), max(y, max_y)}
    end)
    count = :ets.new(:count, [])
    Enum.each((0)..(max_x), fn x ->
      Enum.each((0)..(max_y), fn y ->
        p = {x, y}
        if Enum.reduce(points, 0, fn p2, acc -> acc + distance(p, p2) end) < 10000 do
          :ets.update_counter(count, :count, {2, 1}, {:count, 0})
        end
      end)
    end)
    [{:count, c}] = :ets.lookup(count, :count)
    c
  end

  defp distance({x,y}, {x2,y2}) do
    abs(x2 - x) + abs(y2 - y)
  end

  defp parse(s) do
    {x, rest} = Integer.parse(s)
    parse(x, rest)
  end
  defp parse(x, ", " <> s) do
    {y, _} = Integer.parse(s)
    {x, y}
  end
end