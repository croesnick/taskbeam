defmodule TaskbeamTest do
  use ExUnit.Case
  doctest Taskbeam

  test "creates a client" do
    client = Taskbeam.new("test_token")
    assert client.token == "test_token"
  end
end
