defmodule Util.Deque do
  @opaque internal :: :ets.tab()
  @type t :: %__MODULE__{d: internal}
  @type access :: :public | :protected | :private
  @type option :: access
                  | :named_table
                  | {:keypos, pos_integer()}
                  | {:heir, pid :: pid(), term()}
                  | {:heir, :none}
                  | {:write_concurrency, boolean()}
                  | {:read_concurrency, boolean()}
                  | :compressed

  @type node_id :: integer()
  @type element :: {node_id, integer(), node_id}

  defstruct d: nil

  @spec new(atom(), [option]) :: t
  def new(name, opts \\ []) do
    d = :ets.new(name, opts)
    :ets.insert(d, {initial_node_id(), {0, 0, 0}}) # initial node
    %__MODULE__{d: d}
  end

  @spec initial_node_id() :: node_id
  def initial_node_id(), do: 0

  @spec get_at(t, node_id) :: element
  def get_at(%__MODULE__{d: d}, node_id) do
    [{^node_id, current}] = :ets.lookup(d, node_id)
    current
  end

  @spec insert_at(t, node_id, integer()) :: nil
  def insert_at(%__MODULE__{d: d}, node_id, value) do
    [{^node_id, current}] = :ets.lookup(d, node_id)
    next_id = elem(current, 2)
    [{^next_id, next}] = :ets.lookup(d, next_id)
    :ets.insert(d, {next_id, put_elem(next, 0, value)})
    :ets.insert(d, {value, {node_id, value, next_id}})
    [{^node_id, current}] = :ets.lookup(d, node_id)
    :ets.insert(d, {node_id, put_elem(current, 2, value)})
    nil
  end

  @spec delete_at(t, node_id) :: nil
  def delete_at(%__MODULE__{d: d}, node_id) do
    [{^node_id, {previous, _, next}}] = :ets.lookup(d, node_id)
    [{^previous, prev}] = :ets.lookup(d, previous)
    prev = put_elem(prev, 2, next)
    :ets.insert(d, {previous, prev})
    [{^next, n}] = :ets.lookup(d, next)
    n = put_elem(n, 0, previous)
    :ets.insert(d, {next, n})
    :ets.delete(d, node_id)
    nil
  end

  @spec get_counter_clockwise(t, node_id, integer()) :: element
  def get_counter_clockwise(%__MODULE__{d: d}, node_id, 0) do
    [{^node_id, node}] = :ets.lookup(d, node_id)
    node
  end
  def get_counter_clockwise(%__MODULE__{d: d} = deque, node_id, offset) do
    [{^node_id, {previous, _, _}}] = :ets.lookup(d, node_id)
    get_counter_clockwise(deque, previous, offset - 1)
  end
end
