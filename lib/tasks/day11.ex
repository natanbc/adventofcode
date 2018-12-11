defmodule Tasks.Day11 do
  use Day
  @behaviour Day

  def part1(input) do
    serial = String.to_integer(input)
    {x, y, power} = Enum.reduce(1..298, [], fn x, acc ->
      Enum.reduce(1..298, acc, fn y, acc ->
        power =
          power_level(x, y, serial) + power_level(x + 1, y, serial) + power_level(x + 2, y, serial) +
          power_level(x, y + 1, serial) + power_level(x + 1, y + 1, serial) + power_level(x + 2, y + 1, serial) +
          power_level(x, y + 2, serial) + power_level(x + 1, y + 2, serial) + power_level(x + 2, y + 2, serial)
        [{x, y, power} | acc]
      end)
    end)
    |> Enum.sort(& (elem(&1, 2) > elem(&2, 2)))
    |> List.first
    "#{x},#{y} @ #{power}"
  end

  def part2(input) do
    serial = String.to_integer(input)
    t = :ets.new(:t, [])
    :ets.insert(t, {:best, {0, 0, 0, -10000}})
    build_table(t, serial)
    Enum.each(1..30, fn s ->
      Enum.each(1..300-s, fn x ->
        Enum.each(1..300-s, fn y ->
          power = value_at(t, x, y) - value_at(t, x - s, y) - value_at(t, x, y - s) + value_at(t, x - s, y - s)
          [{:best, {_, _, _, p}}] = :ets.lookup(t, :best)
          if power > p do
            :ets.insert(t, {:best, {x - s + 1, y - s + 1, s, power}})
          end
        end)
      end)
    end)
    [{:best, {x, y, size, power}}] = :ets.lookup(t, :best)
    "#{x},#{y},#{size} @ #{power}"
  end

  defp power_level(x, y, serial) do
    rack = x + 10
    div(rem(((rack * y) + serial) * rack, 1000), 100) - 5
  end

  defp value_at(t, x, y) do
    case :ets.lookup(t, {x, y}) do
      [] -> 0
      [{_, v}] -> v
    end
  end

  defp build_table(t, serial) do
    Enum.each(1..300, fn x ->
      Enum.each(1..300, fn y ->
        :ets.insert(t, {
          {x, y},
          power_level(x, y, serial) + value_at(t, x - 1, y) + value_at(t, x, y - 1) - value_at(t, x - 1, y - 1)
        })
      end)
    end)
  end
end
