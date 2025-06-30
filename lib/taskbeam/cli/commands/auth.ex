defmodule Taskbeam.CLI.Commands.Auth do
  @moduledoc """
  Auth command implementation.
  """

  alias Taskbeam.CLI.Helpers

  def run(parsed_args) do
    case Helpers.setup_client(parsed_args) do
      {:ok, client, config} ->
        Helpers.verbose_log("Testing API connection...", config)
        test_connection(client, config)

      {:error, reason} ->
        Helpers.handle_error({:error, reason}, %{json_output: false})
    end
  end

  defp test_connection(client, config) do
    # Test authentication by making a simple API call
    case Taskbeam.Client.get(client, "projects") do
      {:ok, projects} when is_list(projects) ->
        show_auth_success(projects, config)

      {:ok, _projects} ->
        Helpers.output_message("✓ Authentication successful", config)

      {:error, {401, _}} ->
        Helpers.handle_error({:error, "Authentication failed - invalid token"}, config)

      {:error, {403, _}} ->
        Helpers.handle_error({:error, "Authentication failed - insufficient permissions"}, config)

      {:error, reason} ->
        Helpers.handle_error({:error, reason}, config)
    end
  end

  defp show_auth_success(projects, config) do
    project_count = length(projects)

    if config.json_output do
      result = %{
        status: "authenticated",
        message: "Authentication successful",
        stats: %{
          project_count: project_count
        }
      }

      IO.puts(Jason.encode!(result, pretty: true))
    else
      IO.puts("""
      ✓ Authentication successful!

      Account Statistics:
      • Projects: #{project_count}
      • Connection: Active
      • API Access: Granted
      """)
    end
  end
end
