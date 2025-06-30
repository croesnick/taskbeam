defmodule Taskbeam.CLI.Config do
  @moduledoc """
  Configuration management for Taskbeam CLI.
  """

  @config_dir Path.join(System.user_home!(), ".taskbeam")
  @config_file Path.join(@config_dir, "config.json")

  @doc """
  Gets the API token from various sources in order of preference:
  1. Command line argument
  2. Environment variable
  3. Saved config file
  4. Interactive prompt
  """
  def get_token(parsed_args) do
    cond do
      token = parsed_args.options[:token] ->
        {:ok, token}

      token = System.get_env("TODOIST_API_TOKEN") ->
        {:ok, token}

      token = get_saved_token() ->
        {:ok, token}

      true ->
        prompt_for_token()
    end
  end

  @doc """
  Gets configuration from parsed CLI arguments.
  """
  def get_config(parsed_args) do
    %{
      json_output: parsed_args.flags[:json] || false,
      verbose: parsed_args.flags[:verbose] || false
    }
  end

  @doc """
  Saves the API token to the config file.
  """
  def save_token(token) when is_binary(token) do
    config = load_config()
    new_config = Map.put(config, "api_token", token)

    with :ok <- ensure_config_dir(),
         :ok <- File.write(@config_file, Jason.encode!(new_config, pretty: true)) do
      {:ok, "Token saved to #{@config_file}"}
    else
      error -> {:error, "Failed to save token: #{inspect(error)}"}
    end
  end

  @doc """
  Clears the saved configuration.
  """
  def clear_config do
    case File.rm(@config_file) do
      :ok -> {:ok, "Configuration cleared"}
      {:error, :enoent} -> {:ok, "No configuration file to clear"}
      error -> {:error, "Failed to clear config: #{inspect(error)}"}
    end
  end

  @doc """
  Shows the current configuration.
  """
  def show_config do
    config = load_config()

    %{
      config_file: @config_file,
      config_exists: File.exists?(@config_file),
      api_token_set: Map.has_key?(config, "api_token"),
      env_token_set: System.get_env("TODOIST_API_TOKEN") != nil
    }
  end

  defp get_saved_token do
    case load_config() do
      %{"api_token" => token} when is_binary(token) -> token
      _ -> nil
    end
  end

  defp load_config do
    case File.read(@config_file) do
      {:ok, content} ->
        case Jason.decode(content) do
          {:ok, config} -> config
          _ -> %{}
        end

      _ ->
        %{}
    end
  end

  defp ensure_config_dir do
    case File.mkdir_p(@config_dir) do
      :ok -> :ok
      error -> error
    end
  end

  defp prompt_for_token do
    IO.puts("""
    No Todoist API token found. You can get your token from:
    https://todoist.com/prefs/integrations

    Please enter your API token (or press Ctrl+C to exit):
    """)

    case IO.gets("Token: ") do
      :eof ->
        {:error, "No token provided"}

      input when is_binary(input) ->
        handle_token_input(input)

      _ ->
        {:error, "Failed to read token"}
    end
  end

  defp handle_token_input(input) do
    token = String.trim(input)

    if String.length(token) > 0 do
      case save_token(token) do
        {:ok, _} -> {:ok, token}
        error -> error
      end
    else
      {:error, "Empty token provided"}
    end
  end
end
