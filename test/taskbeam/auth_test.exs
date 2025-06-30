defmodule Taskbeam.AuthTest do
  use ExUnit.Case
  alias Taskbeam.Auth

  describe "authorization_url/4" do
    test "generates authorization URL without state" do
      url = Auth.authorization_url("client_id", "http://localhost", ["data:read"])

      assert String.starts_with?(url, "https://todoist.com/oauth/authorize?")
      assert String.contains?(url, "client_id=client_id")
      assert String.contains?(url, "scope=data%3Aread")
      assert String.contains?(url, "response_type=code")
      assert String.contains?(url, "redirect_uri=http%3A%2F%2Flocalhost")
    end

    test "generates authorization URL with state" do
      url = Auth.authorization_url("client_id", "http://localhost", ["data:read"], "state123")

      assert String.contains?(url, "state=state123")
    end

    test "handles multiple scopes" do
      url =
        Auth.authorization_url("client_id", "http://localhost", ["data:read", "data:read_write"])

      assert String.contains?(url, "scope=data%3Aread%2Cdata%3Aread_write")
    end
  end
end
