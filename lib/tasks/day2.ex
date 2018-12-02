defmodule Tasks.Day2 do
  use Day
  @behaviour Day

  def part1(input) do
    lines = String.split(input, ~r(\r?\n))
    Enum.count(lines, fn line -> count_equal(String.to_charlist(line), 2) end) *
      Enum.count(lines, fn line -> count_equal(String.to_charlist(line), 3) end)
  end

  def part2(input) do
    lines = String.split(input, ~r(\r?\n))
    ids = Enum.flat_map(lines, fn line ->
      Enum.filter(lines, fn line2 ->
        line2 != line && chars_different(String.to_charlist(line), String.to_charlist(line2)) == 1
      end)
    end) |> Enum.map(&String.to_charlist/1)
    without_differing_char(hd(ids), hd(tl ids), [])
    |> List.to_string()
  end

  defp count_equal(line, count, map \\ %{})
  defp count_equal([], count, map) do
    Enum.reduce(map, false, fn {_, v}, acc -> acc || v == count end)
  end
  defp count_equal([ch | tail], count, map) do
    count_equal(tail, count, Map.update(map, ch, 1, & &1 + 1))
  end

  defp chars_different(a, b, acc \\ 0)
  defp chars_different([], [], acc), do: acc
  defp chars_different([a | tailA], [b | tailB], acc) do
    chars_different(tailA, tailB, acc + if a == b do 0 else 1 end)
  end

  defp without_differing_char([], [], acc), do: acc
  defp without_differing_char([a | tailA], [b | tailB], acc) do
    if a == b do
      without_differing_char(tailA, tailB, acc ++ [a])
    else
      without_differing_char(tailA, tailB, acc)
    end
  end
end
