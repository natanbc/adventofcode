defmodule Tasks.Day14 do
  use Day
  @behaviour Day

  def part1(input) do
    last_index = String.to_integer(input) + 10
    table = initial_state()
    loop(table, 0, 1, last_index)
    Enum.map((last_index - 10)..(last_index - 1), fn i ->
      [{^i, v}] = :ets.lookup(table, i)
      v + ?0
    end)
    |> List.to_string()
  end

  def part2(input) do
    wanted = String.to_charlist(input)
    |> Enum.map(& &1 - ?0)
    |> Enum.reverse()
    table = initial_state()
    loop_until_suffix(table, 0, 1, wanted)
    :ets.info(table, :size) - length(wanted) + 1 # add one as the last element of the wanted list is never added to the table
  end

  def initial_state() do
    table = :ets.new(:table, [])
    :ets.insert(table, {0, 3})
    :ets.insert(table, {1, 7})
    table
  end

  defp loop(_, _, _, 0), do: nil
  defp loop(table, elf1, elf2, remaining) do
    [{^elf1, v1}] = :ets.lookup(table, elf1)
    [{^elf2, v2}] = :ets.lookup(table, elf2)
    sum = v1 + v2
    insert(table, div(sum, 10), rem(sum, 10))
    s = :ets.info(table, :size)
    loop(table, rem(elf1 + v1 + 1, s), rem(elf2 + v2 + 1, s), remaining - 1)
  end

  defp insert(table, 0, v), do: :ets.insert(table, {:ets.info(table, :size), v})
  defp insert(table, v1, v2) do
    insert(table, 0, v1)
    insert(table, 0, v2)
  end

  defp loop_until_suffix(table, elf1, elf2, suffix) do
    [{^elf1, v1}] = :ets.lookup(table, elf1)
    [{^elf2, v2}] = :ets.lookup(table, elf2)
    sum = v1 + v2
    if insert_test(table, div(sum, 10), rem(sum, 10), suffix) do
      nil
    else
      s = :ets.info(table, :size)
      loop_until_suffix(table, rem(elf1 + v1 + 1, s), rem(elf2 + v2 + 1, s), suffix)
    end
  end

  defp insert_test(table, 0, v, [h | t]) do
    s = :ets.info(table, :size)
    if v == h && Enum.with_index(t)
      |> Enum.all?(fn {expected, i} ->
        case :ets.lookup(table, s - i - 1) do
          [{_, actual}] -> expected == actual
          [] -> false
        end
      end) do
      true
    else
      :ets.insert(table, {s, v})
      false
    end
  end
  defp insert_test(table, v1, v2, suffix) do
    #short circuit if we found a suffix
    insert_test(table, 0, v1, suffix) || insert_test(table, 0, v2, suffix)
  end
end
