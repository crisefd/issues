defmodule Issues.GithubIssues do
  @user_agent [{"User-agent",
                "Elixir cristhian.fuertes@correounivalle.edu.co"}]

  @github_url Application.get_env(:issues, :github_url)

  def fetch(user, project) do
    issues_url(user, project)
    |> HTTPoison.get(@user_agent)
    |> handle_response
  end

  defp issues_url(user, project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  defp  handle_response({_, %{status_code: status_code, body: body}})  do
    {
      status_code |> check_for_errors(),
      body |> Poison.Parser.parse!()
    }
  end

  defp check_for_errors(200), do: :ok
  defp check_for_errors(_), do: :error

end
