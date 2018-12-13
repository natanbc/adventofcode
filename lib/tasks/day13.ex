defmodule Tasks.Day13 do
  use Day
  @behaviour Day

  @cart_up ?^
  @cart_left ?<
  @cart_down ?v
  @cart_right ?>
  @rail_turn_1 ?\\
  @rail_turn_2 ?/
  @rail_junction ?+

  def part1(input) do
    {carts, rails} = parse(input)
    {x, y} = find_crash(carts, rails)
    "#{x},#{y}"
  end

  def part2(input) do
    {carts, rails} = parse(input)
    {x, y} = find_last_cart(carts, rails)
    "#{x},#{y}"
  end

  defp find_crash(carts, rails, current_tick \\ 0) do
    r = :ets.foldl(fn
      {_, {_, _, _, tick}}, acc when tick != current_tick -> acc
      {{y, x}, {vx, vy, t, tick}}, nil ->
        cx = x + vx
        cy = y + vy
        case :ets.lookup(carts, {cy, cx}) do
          [] ->
            {vx, vy, t} = case :ets.lookup(rails, {cy, cx}) do
              [] -> {vx, vy, t}
              [{_, @rail_turn_1}] -> {vy, vx, t}
              [{_, @rail_turn_2}] -> {-vy, -vx, t}
              [{_, @rail_junction}] when t == 0 -> {vy, -vx, 1}
              [{_, @rail_junction}] when t == 1 -> {vx, vy, 2}
              [{_, @rail_junction}] when t == 2 -> {-vy, vx, 0}
            end
            :ets.delete(carts, {y, x})
            :ets.insert(carts, {{cy, cx}, {vx, vy, t, tick + 1}})
            nil
          [_] ->
            {cx, cy}
        end
      _, acc -> acc
    end, nil, carts)
    if r == nil do
      find_crash(carts, rails, current_tick + 1)
    else
      r
    end
  end

  defp find_last_cart(carts, rails, current_tick \\ 0) do
    r = :ets.foldl(fn
      {_, {_, _, _, tick}}, acc when tick != current_tick -> acc
      {{y, x}, {vx, vy, t, tick}}, nil ->
        cx = x + vx
        cy = y + vy
        case :ets.lookup(carts, {cy, cx}) do
          [] ->
            {vx, vy, t} = case :ets.lookup(rails, {cy, cx}) do
              [] -> {vx, vy, t}
              [{_, @rail_turn_1}] -> {vy, vx, t}
              [{_, @rail_turn_2}] -> {-vy, -vx, t}
              [{_, @rail_junction}] when t == 0 -> {vy, -vx, 1}
              [{_, @rail_junction}] when t == 1 -> {vx, vy, 2}
              [{_, @rail_junction}] when t == 2 -> {-vy, vx, 0}
            end
            :ets.delete(carts, {y, x})
            :ets.insert(carts, {{cy, cx}, {vx, vy, t, tick + 1}})
            if :ets.info(carts, :size) == 1 do
              {cx, cy}
            else
              nil
            end
          [_] ->
            :ets.delete(carts, {y, x})
            :ets.delete(carts, {cy, cx})
            nil
        end
      _, acc -> acc
    end, nil, carts)
    if r == nil do
      find_last_cart(carts, rails, current_tick + 1)
    else
      r
    end
  end

  defp parse(input) do
    carts = :ets.new(:carts, [:ordered_set])
    rails = :ets.new(:rails, [])
    String.split(input, ~r(\r?\n))
    |> Enum.with_index
    |> Enum.each(fn {line, y} ->
      String.to_charlist(line)
      |> Enum.with_index()
      |> Enum.each(fn {c, x} ->
        case c do
          @cart_left -> :ets.insert(carts, {{y, x}, {-1, 0, 0, 0}})
          @cart_right -> :ets.insert(carts, {{y, x}, {1, 0, 0, 0}})
          @cart_up -> :ets.insert(carts, {{y, x}, {0, -1, 0, 0}})
          @cart_down -> :ets.insert(carts, {{y, x}, {0, 1, 0, 0}})
          @rail_turn_1 -> :ets.insert(rails, {{y, x}, @rail_turn_1})
          @rail_turn_2 -> :ets.insert(rails, {{y, x}, @rail_turn_2})
          @rail_junction -> :ets.insert(rails, {{y, x}, @rail_junction})
          _ -> nil
        end
      end)
    end)
    {carts, rails}
  end
end
