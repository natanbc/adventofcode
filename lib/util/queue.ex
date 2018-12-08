defmodule Util.Queue do
  @update {2, 1}
  @initial_r {:read, 0}
  @initial_w {:write, 0}

  defstruct [t: nil]

  @spec new(atom(), [:ets.option()]) :: Queue.t()
  def new(name, opts \\ []) do
    q = :ets.new(name, opts)
    :ets.insert(q, @initial_r)
    :ets.insert(q, @initial_w)
    q
  end

  @spec add(Queue.t(), term()) :: boolean()
  def add(q, element) do
    :ets.insert(q, {:ets.update_counter(q, :write, @update, @initial_w), element})
  end

  @spec peek(Queue.t()) :: term() | nil
  def peek(q) do
    case size(q) do
      0 -> nil
      _ ->
        [{:read, i}] = :ets.lookup(q, :read)
        i = i + 1
        [{^i, v}] = :ets.take(q, i)
        v
    end
  end

  @spec poll(Queue.t()) :: term() | nil
  def poll(q) do
    case size(q) do
      0 -> nil
      _ ->
        i = :ets.update_counter(q, :read, @update, @initial_r)
        [{^i, v}] = :ets.take(q, i)
        v
    end
  end

  @spec size(Queue.t()) :: non_neg_integer()
  def size(q) do
    :ets.info(q, :size) - 2
  end
end
