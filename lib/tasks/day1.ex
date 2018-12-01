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
    |> find_duplicate()
  end

  defp find_duplicate(list, frequency \\ 0, seen \\ MapSet.new()) do
    case update(frequency, list, seen) do
      {:yes, freq} -> freq
      {:no, freq, seen} -> find_duplicate(list, freq, seen)
    end
  end

  defp update(freq, [], seen), do: {:no, freq, seen}

  defp update(freq, [head | tail], seen) do
    new_freq = freq + head
    if MapSet.member?(seen, new_freq) do
      {:yes, new_freq}
    else
      update(new_freq, tail, MapSet.put(seen, new_freq))
    end
  end
end
