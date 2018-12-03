defmodule Tasks.Day3 do
  use Day
  @behaviour Day

  @entry_regex Regex.compile!(~S"#(\d+) @ (\d+),(\d+): (\d+)x(\d+)")

  def part1(input) do
    String.split(input, ~r(\r?\n))
    |> Enum.reduce(%{}, fn line, acc ->
      [_, x, y, width, height] = Regex.run(@entry_regex, line)
                                 |> tl
                                 |> Enum.map(&String.to_integer/1)
      Enum.reduce(x..(x + width - 1), acc, fn realX, acc2 ->
        Enum.reduce(y..(y + height - 1), acc2, fn realY, map ->
          Map.update(map, realX * 1000 + realY, 1, & &1 + 1)
        end)
      end)
    end)
    |> Enum.reduce(0, fn {_, v}, acc -> acc + if v > 1 do 1 else 0 end end)
  end

  def part2(input) do
    input = String.split(input, ~r(\r?\n))
    |> Enum.map(fn line ->
      Regex.run(@entry_regex, line)
      |> tl
      |> Enum.map(&String.to_integer/1)
    end)
    Enum.find(input, fn [id1, x1, y1, w1, h1] ->
      Enum.find(input, fn [id2, x2, y2, w2, h2] ->
        id1 != id2 && !(x1 >= x2 + w2 || x2 >= x1 + w1 || y1 >= y2 + h2 || y2 >= y1 + h1)
      end) == nil
    end) |> hd
  end
end
