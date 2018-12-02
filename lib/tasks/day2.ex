defmodule Tasks.Day2 do
  use Day
  @behaviour Day

  def part1(input) do
    lines = String.split(input, ~r(\r?\n))
    map = Enum.reduce(lines, %{two: 0, three: 0}, fn line, %{two: two, three: three} ->
      %{two: two + if count_equal(line, 2) do 1 else 0 end,
        three: three + if count_equal(line, 3) do 1 else 0 end}
    end)
    map.two * map.three
  end

  def part2(input) do
    lines = String.split(input, ~r(\r?\n))
    [a, _] = pair = Enum.reduce_while(lines, nil, fn line,_ ->
      res = Enum.filter(lines, fn line2 ->
        # This works because we only need to check if there's one different byte between the strings.
        # So, we can check if the length is equal to the common prefix length + the common suffix length + 1
        byte_size(line) -
          (:binary.longest_common_prefix([line, line2]) + :binary.longest_common_suffix([line, line2])) == 1
      end)
      if length(res) == 0 do
        {:cont, nil}
      else
        {:halt, [line | res]}
      end
    end)
    # Same hack as above
    binary_part(a, 0, :binary.longest_common_prefix(pair)) <>
    binary_part(a, byte_size(a), -:binary.longest_common_suffix(pair))
  end

  defp count_equal(line, count, map \\ %{})
  defp count_equal(<<>>, _, _), do: false
  defp count_equal(<<ch, tail::binary>>, count, map) do
    case map do
      %{^ch => c} when c == count - 1 -> true
      %{^ch => c} -> count_equal(tail, count, %{map | ch => c + 1})
      _ -> count_equal(tail, count, Map.put(map, ch, 1))
    end
  end
end
