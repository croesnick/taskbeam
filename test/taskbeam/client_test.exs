defmodule Taskbeam.ClientTest do
  use ExUnit.Case
  alias Taskbeam.Client

  describe "new/1" do
    test "creates a client with token" do
      client = Client.new("test_token")

      assert client.token == "test_token"
      assert client.base_url == "https://api.todoist.com/api/v1"
      assert client.sync_url == "https://api.todoist.com/api/v1/sync"
    end
  end

  describe "auth_headers/1" do
    test "returns proper authorization headers" do
      client = Client.new("test_token")
      headers = Taskbeam.Client.auth_headers(client)

      assert headers == [{"Authorization", "Bearer test_token"}]
    end
  end
end
