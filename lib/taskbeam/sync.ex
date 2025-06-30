defmodule Taskbeam.Sync do
  @moduledoc """
  Sync API operations for Todoist.
  """

  alias Taskbeam.Client

  @doc """
  Performs a sync operation with optional commands and sync token.
  """
  @spec sync(Client.t(), list(), String.t() | nil) :: {:ok, map()} | {:error, term()}
  def sync(client, commands \\ [], sync_token \\ nil) do
    Client.sync(client, commands, sync_token)
  end

  @doc """
  Adds a new task.
  """
  @spec add_task(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def add_task(client, temp_id, args) do
    command = %{
      type: "item_add",
      temp_id: temp_id,
      args: args
    }

    sync(client, [command])
  end

  @doc """
  Updates an existing task.
  """
  @spec update_task(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update_task(client, task_id, args) do
    command = %{
      type: "item_update",
      args: Map.put(args, :id, task_id)
    }

    sync(client, [command])
  end

  @doc """
  Completes a task.
  """
  @spec complete_task(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def complete_task(client, task_id) do
    command = %{
      type: "item_complete",
      args: %{id: task_id}
    }

    sync(client, [command])
  end

  @doc """
  Deletes a task.
  """
  @spec delete_task(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete_task(client, task_id) do
    command = %{
      type: "item_delete",
      args: %{id: task_id}
    }

    sync(client, [command])
  end

  @doc """
  Adds a new project.
  """
  @spec add_project(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def add_project(client, temp_id, args) do
    command = %{
      type: "project_add",
      temp_id: temp_id,
      args: args
    }

    sync(client, [command])
  end

  @doc """
  Updates an existing project.
  """
  @spec update_project(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update_project(client, project_id, args) do
    command = %{
      type: "project_update",
      args: Map.put(args, :id, project_id)
    }

    sync(client, [command])
  end

  @doc """
  Deletes a project.
  """
  @spec delete_project(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete_project(client, project_id) do
    command = %{
      type: "project_delete",
      args: %{id: project_id}
    }

    sync(client, [command])
  end

  @doc """
  Adds a new label.
  """
  @spec add_label(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def add_label(client, temp_id, args) do
    command = %{
      type: "label_add",
      temp_id: temp_id,
      args: args
    }

    sync(client, [command])
  end

  @doc """
  Updates an existing label.
  """
  @spec update_label(Client.t(), String.t(), map()) :: {:ok, map()} | {:error, term()}
  def update_label(client, label_id, args) do
    command = %{
      type: "label_update",
      args: Map.put(args, :id, label_id)
    }

    sync(client, [command])
  end

  @doc """
  Deletes a label.
  """
  @spec delete_label(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def delete_label(client, label_id) do
    command = %{
      type: "label_delete",
      args: %{id: label_id}
    }

    sync(client, [command])
  end

  @doc """
  Performs a full sync to get all user data.
  """
  @spec full_sync(Client.t()) :: {:ok, map()} | {:error, term()}
  def full_sync(client) do
    sync(client, [], "*")
  end

  @doc """
  Performs an incremental sync using a sync token.
  """
  @spec incremental_sync(Client.t(), String.t()) :: {:ok, map()} | {:error, term()}
  def incremental_sync(client, sync_token) do
    sync(client, [], sync_token)
  end
end
