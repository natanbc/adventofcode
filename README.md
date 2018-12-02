# Adventofcode

My [AoC](https://adventofcode.com) solutions for 2018.

## Building

Run `mix escript.build`. That's it.

## Running

Create a directory named `input`. Inside it, place the inputs for all days in the format
`Day<day>.txt`, eg `Day1.txt`, `Day2.txt`.

After that, run `escript adventofcode` to run all days, or `escript adventofcode <day a> <day b> ...`
to run specific days.

An average of the execution speed of each task can be calculated by providing a `RUNS` environment variable,
with how many times to run each task.

## Examples

```
escript adventofcode 1 2
```

```
RUNS=100 escript adventofcode 2
```