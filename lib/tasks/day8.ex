defmodule Tasks.Day8 do
  use Day
  @behaviour Day

  alias Util.Queue

  def part1(input) do
    q = Queue.new(:q)
    String.split(input, ~r( ))
    |> Enum.each(fn n ->
      Queue.add(q, String.to_integer(n))
    end)
    sum_metadata(parse_node(q))
  end

  def part2(input) do
    q = Queue.new(:q)
    String.split(input, ~r( ))
    |> Enum.each(fn n ->
      Queue.add(q, String.to_integer(n))
    end)
    node_value(parse_node(q))
  end

  defp sum_metadata({children, metadata}) do
    Enum.reduce(children, 0, fn c, acc -> acc + sum_metadata(c) end) + Enum.reduce(metadata, 0, fn a, acc -> a + acc end)
  end

  defp node_value({[], metadata}) do
    Enum.reduce(metadata, 0, fn n, acc -> n + acc end)
  end
  defp node_value({children, metadata}) do
    Enum.reduce(metadata, 0, fn
      0, acc -> acc
      n, acc -> node_value(Enum.at(children, n - 1)) + acc
    end)
  end
  defp node_value(nil), do: 0

  defp parse_node(q) do
    n_children = Queue.poll(q)
    n_metadata = Queue.poll(q)
    children = Enum.map(range(n_children), fn _ -> parse_node(q) end)
    metadata = Enum.map(range(n_metadata), fn _ -> Queue.poll(q) end)
    {children, metadata}
  end

  # workaround for 1..0 yielding [1, 0]
  defp range(0), do: []
  defp range(n), do: 1..n
end
