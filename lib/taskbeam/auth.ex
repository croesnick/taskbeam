defmodule Taskbeam.Auth do
  @moduledoc """
  OAuth authentication helpers for Todoist API.
  """

  @auth_url "https://todoist.com/oauth/authorize"
  @token_url "https://todoist.com/oauth/access_token"

  @doc """
  Generates an OAuth authorization URL.
  """
  @spec authorization_url(String.t(), String.t(), list(String.t()), String.t() | nil) ::
          String.t()
  def authorization_url(client_id, redirect_uri, scope, state \\ nil) do
    params = [
      client_id: client_id,
      scope: Enum.join(scope, ","),
      response_type: "code",
      redirect_uri: redirect_uri
    ]

    params = if state, do: Keyword.put(params, :state, state), else: params

    query = URI.encode_query(params)
    "#{@auth_url}?#{query}"
  end

  @doc """
  Exchanges an authorization code for an access token.
  """
  @spec exchange_code(String.t(), String.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def exchange_code(client_id, client_secret, code) do
    body = %{
      client_id: client_id,
      client_secret: client_secret,
      code: code,
      grant_type: "authorization_code"
    }

    Req.post(@token_url, json: body)
    |> handle_token_response()
  end

  @doc """
  Revokes an access token.
  """
  @spec revoke_token(String.t(), String.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def revoke_token(client_id, client_secret, access_token) do
    url = "https://api.todoist.com/api/v1/access_tokens/revoke"

    body = %{
      client_id: client_id,
      client_secret: client_secret,
      access_token: access_token
    }

    Req.post(url, json: body)
    |> handle_revoke_response()
  end

  defp handle_token_response({:ok, %{status: 200, body: body}}) do
    {:ok, body}
  end

  defp handle_token_response({:ok, %{status: status, body: body}}) do
    {:error, {status, body}}
  end

  defp handle_token_response({:error, reason}) do
    {:error, reason}
  end

  defp handle_revoke_response({:ok, %{status: 204}}) do
    {:ok, %{revoked: true}}
  end

  defp handle_revoke_response({:ok, %{status: status, body: body}}) do
    {:error, {status, body}}
  end

  defp handle_revoke_response({:error, reason}) do
    {:error, reason}
  end
end
