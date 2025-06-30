defmodule Taskbeam do
  @moduledoc """
  A modern Elixir API client for Todoist.

  Taskbeam provides a clean and efficient interface to interact with the Todoist API,
  supporting both REST and Sync endpoints with proper authentication and data structures.

  ## Quick Start

      # Create a client with your API token
      client = Taskbeam.Client.new("your_api_token")

      # Create a new task
      task = Taskbeam.Task.new("Buy groceries", project_id: "123")
      {:ok, response} = Taskbeam.Sync.add_task(client, "temp_id_1", Taskbeam.Task.to_args(task))

      # Perform a full sync
      {:ok, data} = Taskbeam.Sync.full_sync(client)

  """

  alias Taskbeam.{Auth, Client, Comment, Label, Project, Sync, Task}

  @doc """
  Creates a new Taskbeam client.
  """
  defdelegate new(token), to: Client

  @doc """
  Performs a sync operation.
  """
  defdelegate sync(client, commands \\ [], sync_token \\ nil), to: Sync

  @doc """
  Creates a new task.
  """
  defdelegate new_task(content, opts \\ []), to: Task, as: :new

  @doc """
  Creates a new project.
  """
  defdelegate new_project(name, opts \\ []), to: Project, as: :new

  @doc """
  Creates a new label.
  """
  defdelegate new_label(name, opts \\ []), to: Label, as: :new

  @doc """
  Creates a new comment.
  """
  defdelegate new_comment(content, opts \\ []), to: Comment, as: :new

  @doc """
  Generates OAuth authorization URL.
  """
  defdelegate authorization_url(client_id, redirect_uri, scope, state \\ nil), to: Auth
end
