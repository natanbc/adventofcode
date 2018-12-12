defmodule Tasks.Day12 do
  use Day
  @behaviour Day

  @space (?\ )
  @equals ?=
  @gt ?>
  @dot ?.
  @hash ?#

  def part1(input) do
    run(parse(input), 20).state |> Enum.sum()
  end

  def part2(input) do
    initial_state = parse(input)
    a = run(initial_state, 199)
    b = run(a, 1)
    sum_a = Enum.sum(a.state)
    sum_b = Enum.sum(b.state)
    sum_b + ((50000000000 - 200) * (sum_b - sum_a))
  end

  defp run(state, generations) do
    Enum.reduce(1..generations, state, fn _, state -> update(state) end)
  end

  defp update(%{state: s, rules: rules}) do
    new_state = Enum.reduce((Enum.min(s) - 3)..(Enum.max(s) + 4), MapSet.new(), fn i, acc ->
      if new_state(s, rules, i) == @hash do
        MapSet.put(acc, i)
      else
        acc
      end
    end)
    %{state: new_state, rules: rules}
  end

  defp new_state(current_state, rules, i) do
    if MapSet.member?(rules, {
      pot_repr(current_state, i - 2),
      pot_repr(current_state, i - 1),
      pot_repr(current_state, i),
      pot_repr(current_state, i + 1),
      pot_repr(current_state, i + 2)
    }), do: @hash, else: @dot
  end

  defp pot_repr(current_state, i) do
    if MapSet.member?(current_state, i), do: @hash, else: @dot
  end

  defp parse(s) do
    Enum.reduce(String.split(s, ~r(\r?\n)), %{}, &parse/2)
  end
  defp parse("initial state: " <> s, acc) do
    Map.put(acc, :state, Enum.reduce(0..byte_size(s) - 1, MapSet.new(), fn i, acc ->
      if :binary.at(s, i) == @hash do
        MapSet.put(acc, i)
      else
        acc
      end
    end))
  end
  defp parse(<<l1, l2, c, r1, r2, @space, @equals, @gt, @space, @hash>>, acc) do
    k = {l1, l2, c, r1, r2}
    Map.update(acc, :rules, MapSet.new([k]), & MapSet.put(&1, k))
  end
  defp parse(_, acc), do: acc
end
