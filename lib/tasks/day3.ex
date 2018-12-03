defmodule Tasks.Day3 do
  use Day
  @behaviour Day

  def part1(input) do
    table = :ets.new(:overlaps, [])
    String.split(input, ~r(\r?\n))
    |> Enum.each(fn line ->
      [_, x, y, width, height] = parse(line)
      Enum.each(x..(x + width - 1), fn realX ->
        Enum.each(y..(y + height - 1), fn realY ->
          k = realX * 1000 + realY
          :ets.update_counter(table, k, {2, 1}, {k, 0})
        end)
      end)
    end)
    :ets.select_delete(table, [{{:"$1",:"$2"},[{:"=<",:"$2",1}],[true]}])
    size = :ets.info(table, :size)
    :ets.delete(table)
    size
  end

  def part2(input) do
    input = String.split(input, ~r(\r?\n))
    |> Enum.map(&parse/1)
    Enum.find(input, fn [id1, x1, y1, w1, h1] ->
      Enum.find(input, fn [id2, x2, y2, w2, h2] ->
        id1 != id2 && !(x1 >= x2 + w2 || x2 >= x1 + w1 || y1 >= y2 + h2 || y2 >= y1 + h1)
      end) == nil
    end) |> hd
  end

  defp parse("#" <> rest) do
    {id, r} = Integer.parse(rest)
    parse(id, r)
  end
  defp parse(id, " @ " <> rest) do
    {x, r} = Integer.parse(rest)
    parse(id, x, r)
  end
  defp parse(id, x, "," <> rest) do
    {y, r} = Integer.parse(rest)
    parse(id, x, y, r)
  end
  defp parse(id, x, y, ": " <> rest) do
    {w, r} = Integer.parse(rest)
    parse(id, x, y, w, r)
  end
  defp parse(id, x, y, w, "x" <> rest) do
    {h, _} = Integer.parse(rest)
    [id, x, y, w, h]
  end
end
