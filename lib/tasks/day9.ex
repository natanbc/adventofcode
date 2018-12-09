defmodule Tasks.Day9 do
  use Day
  @behaviour Day

  alias Util.Deque

  def part1(input) do
    {players, value} = parse(input)
    play(players, value)
  end

  def part2(input) do
    {players, value} = parse(input)
    play(players, value * 100)
  end

  defp play(players, value) do
    d = Deque.new(:marbles)
    Enum.reduce(1..value, {0, %{}}, fn marble, {current, scores} ->
      if rem(marble, 23) == 0 do
        {_, v, next} = Deque.get_counter_clockwise(d, current, 7)
        scores = Map.update(scores, rem(marble, players), marble + v, & &1 + marble + v)
        Deque.delete_at(d, v)
        {next, scores}
      else
        {_, _, next} = Deque.get_at(d, current)
        Deque.insert_at(d, next, marble)
        {marble, scores}
      end
    end)
    |> elem(1)
    |> Enum.to_list()
    |> Enum.sort(& (elem(&1, 1) > elem(&2, 1)))
    |> List.first
    |> elem(1)
  end

  defp parse(s) do
    {players, rest} = Integer.parse(s)
    parse(players, rest)
  end
  defp parse(players, " players; last marble is worth " <> s) do
    {value, _} = Integer.parse(s)
    {players, value}
  end
end
