defmodule Tasks.Day4 do
  use Day
  @behaviour Day

  def part1(input) do
    [{id, _, times}] = String.split(input, ~r(\r?\n))
    |> Enum.map(&parse/1)
    |> Enum.sort(& (elem(&1, 5) < elem(&2, 5)))
    |> Enum.reduce(%{latest: nil}, fn {_, _, _, m, a, _}, %{latest: latest} = acc ->
      case a do
        {:change, id} -> %{acc | latest: id}
        :asleep -> Map.put(acc, :start, m)
        :awoke ->
          list = [{acc.start, m}]
          Map.update(acc, latest, list, & list ++ &1)
      end
    end) |> Map.delete(:latest) |> Map.delete(:start)
    |> Enum.to_list() |> Enum.map(fn {k, times} ->
      {k, Enum.reduce(times, 0, fn {from, to}, acc -> acc + (to - from) end), times}
    end)
    |> Enum.sort(& (elem(&1, 1) > elem(&2, 1)))
    |> Enum.take(1)
    [{minute, _}] = Enum.reduce(times, %{}, fn {from, to}, acc ->
      Enum.reduce(from..(to - 1), acc, fn t, map -> Map.update(map, t, 1, & &1 + 1) end)
    end)
    |> Enum.to_list()
    |> Enum.sort(& (elem(&1, 1) > elem(&2, 1)))
    |> Enum.take(1)

    minute * id
  end

  def part2(input) do
    [{id, map}] = String.split(input, ~r(\r?\n))
    |> Enum.map(&parse/1)
    |> Enum.sort(& (elem(&1, 5) < elem(&2, 5)))
    |> Enum.reduce(%{latest: nil}, fn {_, _, _, m, a, _}, %{latest: latest} = acc ->
      case a do
        {:change, id} -> %{acc | latest: id}
        :asleep -> Map.put(acc, :start, m)
        :awoke ->
          Enum.reduce(acc.start .. (m - 1), acc, fn minute, map ->
            Map.update(map, latest, %{}, & Map.update(&1, minute, 1, fn x -> x + 1 end))
          end)
      end
    end) |> Map.delete(:latest) |> Map.delete(:start)
    |> Enum.to_list()
    |> Enum.sort(fn {_, map1}, {_, map2} ->
      most(map1) |> elem(1) > most(map2) |> elem(1)
    end)
    |> Enum.take(1)
    {minute, _} = most(map)
    id * minute
  end

  defp most(map), do:
    Enum.to_list(map)
    |> Enum.sort(& (elem(&1, 1) > elem(&2, 1)))
    |> Enum.take(1)
    |> hd()

  defp parse("[1518-" <> rest) do
    {month, r} = Integer.parse(rest)
    parse(month, r)
  end
  defp parse(month, "-" <> rest) do
    {day, r} = Integer.parse(rest)
    parse(month, day, r)
  end
  defp parse(month, day, " " <> rest) do
    {hour, r} = Integer.parse(rest)
    parse(month, day, hour, r)
  end
  defp parse(month, day, hour, ":" <> rest) do
    {minute, r} = Integer.parse(rest)
    sort_key = minute + hour * 100 + day * 10000 + month *  1000000
    {month, day, hour, minute, action(r), sort_key}
  end
  defp action("] falls asleep"), do: :asleep
  defp action("] wakes up"), do: :awoke
  defp action("] Guard #" <> rest), do: {:change, Integer.parse(rest) |> elem(0)}
end
