defmodule Tasks.Day1 do
  use Day
  @behaviour Day

  def part1(input) do
    String.split(input, ~r(\r?\n))
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce(0, & &1 + &2)
  end

  def part2(input) do
    String.split(input, ~r(\r?\n))
    |> Enum.map(&String.to_integer/1)
    |> Stream.cycle()
    |> find_duplicate()
  end

  defp find_duplicate(stream) do
    Enum.reduce_while(stream, {0, MapSet.new()}, fn i, {freq, seen} ->
      new_freq = freq + i
      if MapSet.member?(seen, new_freq) do
        {:halt, new_freq}
      else
        {:cont, {new_freq, MapSet.put(seen, new_freq)}}
      end
    end)
  end
end
