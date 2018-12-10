defmodule Tasks.Day10 do
  use Day
  @behaviour Day

  @dot hd '.'
  @hash hd '#'
  @newline hd '\n'

  def part1(input) do
    points = String.split(input, ~r(\r?\n))
    |> Enum.map(&parse/1)
    {sec, {min_x, max_x, min_y, max_y}, _} = find_message(points)
    width = max_x - min_x + 1
    grid = :ets.new(:grid, [:ordered_set])
    Enum.each(min_x..max_x + 1, fn x ->
      Enum.each(min_y..max_y, fn y ->
        :ets.insert(grid, {(y - min_y) * width + (x - min_x), @dot})
      end)
    end)
    Enum.each(points, fn {x, y, vx, vy} ->
      :ets.insert(grid, {(y + vy * sec - min_y) * width + (x + vx * sec - min_x), @hash})
    end)
    :ets.tab2list(grid)
    |> Enum.sort(& (elem(&1, 0) < elem(&2, 0)))
    |> Enum.chunk_every(width)
    |> Enum.map(fn l -> [@newline | l |> Enum.map(& elem(&1, 1))] end)
    |> Enum.reduce("", fn line, acc ->
      acc <> List.to_string(line)
    end)
  end

  def part2(input) do
    points = String.split(input, ~r(\r?\n))
    |> Enum.map(&parse/1)
    {sec, _, _} = find_message(points)
    sec
  end

  defp find_message(points) do
    Enum.map(8000..12000, fn sec ->
      {min_x, max_x, min_y, max_y} = box = Enum.reduce(points, {100000, 0, 100000, 0}, fn {x, y, vx, vy}, {min_x, max_x, min_y, max_y} ->
        {
          min(min_x, x + vx * sec),
          max(max_x, x + vx * sec),
          min(min_y, y + vy * sec),
          max(max_y, y + vy * sec),
        }
      end)
      {sec, box, max_x - min_x + max_y - min_y}
    end)
    |> Enum.sort(& (elem(&1, 2) < elem(&2, 2)))
    |> List.first
  end

  defp parse("position=<" <> s) do
    {x, s} = parse_int(s)
    parse(x, s)
  end
  defp parse(x, ", " <> s) do
    {y, s} = parse_int(s)
    parse(x, y, s)
  end
  defp parse(x, y, "> velocity=<" <> s) do
    {vx, s} = parse_int(s)
    parse(x, y, vx, s)
  end
  defp parse(x, y, vx, ", " <> s) do
    {vy, _} = parse_int(s)
    {x, y, vx, vy}
  end

  defp parse_int(" " <> s), do: Integer.parse(s)
  defp parse_int(s), do: Integer.parse(s)
end
