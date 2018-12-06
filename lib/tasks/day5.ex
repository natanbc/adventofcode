defmodule Tasks.Day5 do
  use Day
  @behaviour Day

  defmacrop letter(b) do
    quote do
      case unquote(b) do
        v when v >= 65 and v <= 90 -> v - 65
        v when v >= 97 and v <= 122 -> v - 97
        v -> raise "Unmatched letter #{inspect v}"
      end
    end
  end

  def part1(input) do
    input
    |> String.to_charlist()
    |> react()
  end

  def part2(input) do
    chars = String.to_charlist(input)
    len = length(chars)
    Enum.map(0..25, fn l -> react_filter(chars, len, l) end)
    |> Enum.sort(& &1 < &2)
    |> List.first()
  end

  defp react(chars), do: react(chars, length(chars))
  defp react(chars, l) do
    r = Enum.reduce(chars, [], fn c, acc ->
      case acc do
        [last | tail] = list when last != c ->
          if letter(last) == letter(c) do tail else [c | list] end
        list -> [c | list]
      end
    end)
    lr = length(r)
    if l == lr do
      lr
    else
      react(r, lr)
    end
  end

  defp react_filter(chars, l, letter) do
    r = Enum.reduce(chars, [], fn c, acc ->
      if letter(c) == letter do
        acc
      else
        case acc do
          [last | tail] = list when last != c ->
            if letter(last) == letter(c) do tail else [c | list] end
          list -> [c | list]
        end
      end
    end)
    lr = length(r)
    if l == lr do
      lr
    else
      react_filter(r, lr, letter)
    end
  end
end
