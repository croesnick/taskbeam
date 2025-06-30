defmodule Taskbeam.CLI.Commands.Projects do
  @moduledoc """
  Projects command implementation.
  """

  alias Taskbeam.CLI.Helpers

  def run(parsed_args) do
    case Helpers.setup_client(parsed_args) do
      {:ok, client, config} ->
        Helpers.verbose_log("Fetching projects...", config)
        fetch_projects(client, config)

      {:error, reason} ->
        Helpers.handle_error({:error, reason}, %{json_output: false})
    end
  end

  defp fetch_projects(client, config) do
    case Taskbeam.Client.get(client, "projects") do
      {:ok, response} ->
        projects = extract_projects(response)
        formatted_projects = format_projects(projects)
        Helpers.output_data(formatted_projects, config)

      {:error, reason} ->
        Helpers.handle_error({:error, reason}, config)
    end
  end

  defp extract_projects(response) when is_list(response) do
    # If response is a list, it's the projects directly
    response
  end

  defp extract_projects(response) when is_map(response) do
    # If response is a map, it might have pagination metadata
    cond do
      Map.has_key?(response, "results") -> response["results"]
      Map.has_key?(response, "projects") -> response["projects"]
      Map.has_key?(response, "data") -> response["data"]
      # Single project response
      true -> [response]
    end
  end

  defp extract_projects(_), do: []

  defp format_projects(projects) do
    projects
    |> Enum.map(&format_project/1)
    |> Enum.sort_by(& &1.order)
  end

  defp format_project(project) when is_map(project) do
    %{
      id: Map.get(project, "id", "unknown"),
      name: Map.get(project, "name", "Unknown Project"),
      color: format_color(Map.get(project, "color")),
      order: Map.get(project, "order", 0),
      parent_id: Map.get(project, "parent_id"),
      is_favorite: Map.get(project, "is_favorite", false),
      is_shared: Map.get(project, "is_shared", false),
      url: Map.get(project, "url")
    }
  end

  defp format_project(project) do
    # Handle unexpected data structure
    %{
      id: "error",
      name: "Invalid project data: #{inspect(project)}",
      color: "",
      order: 0,
      parent_id: nil,
      is_favorite: false,
      is_shared: false,
      url: nil
    }
  end

  defp format_color(nil), do: ""

  defp format_color(color) when is_map(color) do
    case color do
      %{"name" => name} -> name
      _ -> inspect(color)
    end
  end

  defp format_color(color), do: to_string(color)
end
