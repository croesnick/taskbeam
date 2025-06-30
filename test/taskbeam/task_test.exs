defmodule Taskbeam.TaskTest do
  use ExUnit.Case
  alias Taskbeam.Task

  describe "new/2" do
    test "creates a task with content" do
      task = Task.new("Buy milk")

      assert task.content == "Buy milk"
      assert task.project_id == nil
    end

    test "creates a task with options" do
      task = Task.new("Buy milk", project_id: "123", priority: 3)

      assert task.content == "Buy milk"
      assert task.project_id == "123"
      assert task.priority == 3
    end
  end

  describe "from_map/1" do
    test "creates task from map" do
      data = %{
        "id" => "123",
        "content" => "Buy milk",
        "project_id" => "456",
        "priority" => 3
      }

      task = Task.from_map(data)

      assert task.id == "123"
      assert task.content == "Buy milk"
      assert task.project_id == "456"
      assert task.priority == 3
    end
  end

  describe "to_args/1" do
    test "converts task to args map" do
      task = Task.new("Buy milk", project_id: "123", priority: 3)
      args = Task.to_args(task)

      assert args["content"] == "Buy milk"
      assert args["project_id"] == "123"
      assert args["priority"] == 3
      refute Map.has_key?(args, "id")
    end

    test "excludes nil values" do
      task = Task.new("Buy milk")
      args = Task.to_args(task)

      assert args["content"] == "Buy milk"
      refute Map.has_key?(args, "project_id")
    end
  end
end
