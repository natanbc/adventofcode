defmodule Benchmark do 
  def run(days) do
    days |> Enum.flat_map(fn day ->
      content = File.read!("input/Day#{day}.txt")
      mod = String.to_atom("Elixir.Tasks.Day#{day}")
      [{"Day #{day} part 1", fn -> mod.part1(content) end}, {"Day #{day} part 2", fn -> mod.part2(content) end}]
    end)
    |> Map.new
    |> Benchee.run(
         memory_time: 2,
         formatters: [Benchee.Formatters.Console, Benchee.Formatters.HTML],
         print: [fast_warning: false]
       )
  end

  def find_days(day \\ 1) do
    mod = String.to_atom("Elixir.Tasks.Day#{day}")
    if Code.ensure_loaded?(mod) do
      find_days(day + 1)
    else
      day - 1
    end
  end
end

case System.argv() do
  [] -> Benchmark.run(1..Benchmark.find_days())
  days -> Benchmark.run(days |> Enum.map(&String.to_integer/1))
end
