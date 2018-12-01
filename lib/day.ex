defmodule Day do
  defmacro __using__(_) do
    quote do
      def part1(_), do: :unimplemented
      def part2(_), do: :unimplemented

      defoverridable part1: 1, part2: 1
    end
  end

  @callback part1(String.t) :: term | :unimplemented
  @callback part2(String.t) :: term | :unimplemented
end
