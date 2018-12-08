defmodule Util.Queue do
  @update {2, 1}
  @initial_r {:read, 0}
  @initial_w {:write, 0}

  alias Util.Queue

  @opaque internal :: :ets.tab()
  @type t :: %Queue{q: internal}
  @type access :: :public | :protected | :private
  @type option :: access
                  | :named_table
                  | {:keypos, pos_integer()}
                  | {:heir, pid :: pid(), term()}
                  | {:heir, :none}
                  | {:write_concurrency, boolean()}
                  | {:read_concurrency, boolean()}
                  | :compressed

  defstruct q: nil

  @spec new(atom(), [option]) :: t
  def new(name, opts \\ []) do
    q = :ets.new(name, opts)
    :ets.insert(q, @initial_r)
    :ets.insert(q, @initial_w)
    %Queue{q: q}
  end

  @spec add(t, term()) :: boolean()
  def add(%Queue{q: q}, element) do
    :ets.insert(q, {:ets.update_counter(q, :write, @update, @initial_w), element})
  end

  @spec peek(t) :: term() | nil
  def peek(%Queue{q: q}) do
    case size(q) do
      0 -> nil
      _ ->
        [{:read, i}] = :ets.lookup(q, :read)
        i = i + 1
        [{^i, v}] = :ets.take(q, i)
        v
    end
  end

  @spec poll(t) :: term() | nil
  def poll(%Queue{q: q}) do
    case size(q) do
      0 -> nil
      _ ->
        i = :ets.update_counter(q, :read, @update, @initial_r)
        [{^i, v}] = :ets.take(q, i)
        v
    end
  end

  @spec size(t) :: non_neg_integer()
  def size(%Queue{q: q}) do
    :ets.info(q, :size) - 2
  end
end
