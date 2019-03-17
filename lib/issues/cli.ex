defmodule Issues.CLI do
  import Enum, only: [sort: 2]
  import Issues.TableFormatter, only: [print_table_for_columns: 2]
  @default_count 4

  @moduledoc """
    Handle the command line parsing and the dispatch to the various
    functions that end up generating a table of the last
    _n_ issues in a Github project
  """
  def main(argv), do: argv |> parse_args |> process()

  @doc """
    ´argv´ can be -h or --help, which returns :help.
    Otherwise it is a Github user name, project name and (optionally)
    the number of entries to format

    Return a tuple of ´{user, project, count}´, or :help if help was givens
  """
  def parse_args(argv) do
    OptionParser.parse(argv,
      switches: [help: :boolean],
      aliases: [h: :help]
    )
    |> elem(1)
    |> args_to_internal_representation()
  end

  def process(:help) do
    IO.puts("""
      usage: issues <owner> <project> [count | #{@default_count}]
    """)

    System.halt(0)
  end

  def process({user, project, count}) do
    Issues.GithubIssues.fetch(user, project)
    |> decode_response()
    |> sort_into_descending_order
    |> last(count)
    |> print_table_for_columns(["number", "created_at", "title"])
  end

  defp last(list, count) do
    list
    |> Enum.take(count)
    |> Enum.reverse()
  end

  defp decode_response({:ok, body}), do: body

  defp decode_response({:error, error}) do
    IO.puts("Error fetching from Github: #{error["message"]}")
    System.halt(2)
  end

  defp args_to_internal_representation([user, project, count]) do
    {user, project, String.to_integer(count)}
  end

  defp args_to_internal_representation([user, project]) do
    {user, project, @default_count}
  end

  defp args_to_internal_representation(_), do: :help

  def sort_into_descending_order(list_of_issues) do
    list_of_issues
    |> sort(&(&1["created_at"] >= &2["created_at"]))
  end
end
