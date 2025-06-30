defmodule Taskbeam.CLI.Helpers do
  @moduledoc """
  Shared utilities for CLI commands.
  """

  alias Taskbeam.CLI.Config

  @doc """
  Sets up a Taskbeam client from parsed CLI arguments.
  """
  def setup_client(parsed_args) do
    with {:ok, token} <- Config.get_token(parsed_args) do
      client = Taskbeam.Client.new(token)
      config = Config.get_config(parsed_args)
      {:ok, client, config}
    end
  end

  @doc """
  Handles errors consistently across commands.
  """
  def handle_error({:error, reason}, _config) do
    case reason do
      {status, body} when is_integer(status) ->
        IO.puts(:stderr, "API Error #{status}: #{format_error_body(body)}")

      reason when is_binary(reason) ->
        IO.puts(:stderr, "Error: #{reason}")

      _ ->
        IO.puts(:stderr, "Error: #{inspect(reason)}")
    end

    System.halt(1)
  end

  @doc """
  Outputs data in the appropriate format (JSON or table).
  """
  def output_data(data, config) do
    if config.json_output do
      IO.puts(Jason.encode!(data, pretty: true))
    else
      format_table_output(data)
    end
  end

  @doc """
  Outputs a simple message.
  """
  def output_message(message, config) do
    if config.json_output do
      IO.puts(Jason.encode!(%{message: message}))
    else
      IO.puts(message)
    end
  end

  @doc """
  Verbose logging when enabled.
  """
  def verbose_log(message, config) do
    if config.verbose do
      IO.puts(:stderr, "[DEBUG] #{message}")
    end
  end

  defp format_error_body(body) when is_map(body) do
    case body do
      %{"error" => error} -> error
      %{"message" => message} -> message
      _ -> inspect(body)
    end
  end

  defp format_error_body(body) when is_binary(body), do: body
  defp format_error_body(body), do: inspect(body)

  defp format_table_output(data) when is_list(data) and length(data) > 0 do
    case List.first(data) do
      %{} = first_item ->
        headers = Map.keys(first_item) |> Enum.map(&to_string/1)

        rows = build_table_rows(data, headers)

        TableRex.quick_render!(rows, headers)
        |> IO.puts()

      _ ->
        inspect_output(data)
    end
  end

  defp format_table_output(data) when is_list(data) do
    IO.puts("No data found.")
  end

  defp format_table_output(data) do
    inspect_output(data)
  end

  defp build_table_rows(data, headers) do
    Enum.map(data, fn item ->
      Enum.map(headers, fn header ->
        value = Map.get(item, String.to_atom(header), "")
        format_cell_value(value)
      end)
    end)
  end

  defp inspect_output(data) do
    IO.puts(inspect(data))
  end

  defp format_cell_value(value) when is_list(value) do
    Enum.join(value, ", ")
  end

  defp format_cell_value(value) when is_map(value) do
    case value do
      %{"name" => name} -> name
      _ -> inspect(value)
    end
  end

  defp format_cell_value(value) when is_nil(value), do: ""
  defp format_cell_value(value) when is_boolean(value), do: to_string(value)
  defp format_cell_value(value), do: to_string(value)
end
