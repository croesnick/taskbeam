defmodule Taskbeam.Client do
  @moduledoc """
  HTTP client for Todoist API v1.
  """

  @base_url "https://api.todoist.com/api/v1"
  @sync_url "https://api.todoist.com/api/v1/sync"

  defstruct [:token, :base_url, :sync_url]

  @type t :: %__MODULE__{
          token: String.t(),
          base_url: String.t(),
          sync_url: String.t()
        }

  @doc """
  Creates a new client with the given API token.
  """
  @spec new(String.t()) :: t()
  def new(token) when is_binary(token) do
    %__MODULE__{
      token: token,
      base_url: @base_url,
      sync_url: @sync_url
    }
  end

  @doc """
  Makes a GET request to the REST API.
  """
  @spec get(t(), String.t(), keyword()) :: {:ok, map()} | {:error, term()}
  def get(%__MODULE__{} = client, path, params \\ []) do
    url = Path.join(client.base_url, path)

    Req.get(url,
      headers: auth_headers(client),
      params: params
    )
    |> handle_response()
  end

  @doc """
  Makes a POST request to the REST API.
  """
  @spec post(t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def post(%__MODULE__{} = client, path, body) do
    url = Path.join(client.base_url, path)

    Req.post(url,
      headers: auth_headers(client),
      json: body
    )
    |> handle_response()
  end

  @doc """
  Makes a POST request to the Sync API.
  """
  @spec sync(t(), list(), String.t() | nil) :: {:ok, map()} | {:error, term()}
  def sync(%__MODULE__{} = client, commands \\ [], sync_token \\ nil) do
    body = %{
      commands: Jason.encode!(commands)
    }

    body = if sync_token, do: Map.put(body, :sync_token, sync_token), else: body

    Req.post(client.sync_url,
      headers: auth_headers(client),
      form: body
    )
    |> handle_response()
  end

  def auth_headers(%__MODULE__{token: token}) do
    [{"Authorization", "Bearer #{token}"}]
  end

  defp handle_response({:ok, %{status: status, body: body}}) when status in 200..299 do
    {:ok, body}
  end

  defp handle_response({:ok, %{status: status, body: body}}) do
    {:error, {status, body}}
  end

  defp handle_response({:error, reason}) do
    {:error, reason}
  end
end
