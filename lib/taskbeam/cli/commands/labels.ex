defmodule Taskbeam.CLI.Commands.Labels do
  @moduledoc """
  Labels command implementation.
  """

  alias Taskbeam.CLI.Helpers

  def run(parsed_args) do
    case Helpers.setup_client(parsed_args) do
      {:ok, client, config} ->
        Helpers.verbose_log("Fetching labels...", config)
        fetch_labels(client, config)

      {:error, reason} ->
        Helpers.handle_error({:error, reason}, %{json_output: false})
    end
  end

  defp fetch_labels(client, config) do
    case Taskbeam.Client.get(client, "labels") do
      {:ok, response} ->
        labels = extract_labels(response)
        formatted_labels = format_labels(labels)
        Helpers.output_data(formatted_labels, config)

      {:error, reason} ->
        Helpers.handle_error({:error, reason}, config)
    end
  end

  defp format_labels(labels) do
    labels
    |> Enum.map(&format_label/1)
    |> Enum.sort_by(& &1.order)
  end

  defp extract_labels(response) when is_list(response) do
    response
  end

  defp extract_labels(response) when is_map(response) do
    cond do
      Map.has_key?(response, "results") -> response["results"]
      Map.has_key?(response, "labels") -> response["labels"]
      Map.has_key?(response, "data") -> response["data"]
      true -> [response]
    end
  end

  defp extract_labels(_), do: []

  defp format_label(label) do
    %{
      id: label["id"],
      name: label["name"],
      color: label["color"] || "",
      order: label["order"] || 0,
      is_favorite: label["is_favorite"] || false
    }
  end
end
