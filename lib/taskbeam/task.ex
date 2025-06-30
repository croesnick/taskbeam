defmodule Taskbeam.Task do
  @moduledoc """
  Task data structure and operations.
  """

  @type t :: %__MODULE__{
          id: String.t() | nil,
          content: String.t(),
          description: String.t() | nil,
          project_id: String.t() | nil,
          section_id: String.t() | nil,
          parent_id: String.t() | nil,
          order: integer() | nil,
          labels: list(String.t()) | nil,
          priority: integer() | nil,
          assignee_id: integer() | nil,
          due_string: String.t() | nil,
          due_date: String.t() | nil,
          due_datetime: String.t() | nil,
          due_lang: String.t() | nil,
          duration: integer() | nil,
          duration_unit: String.t() | nil,
          deadline_date: String.t() | nil,
          deadline_lang: String.t() | nil,
          url: String.t() | nil,
          comment_count: integer() | nil,
          is_completed: boolean() | nil,
          creator_id: String.t() | nil,
          created_at: String.t() | nil
        }

  defstruct [
    :id,
    :content,
    :description,
    :project_id,
    :section_id,
    :parent_id,
    :order,
    :labels,
    :priority,
    :assignee_id,
    :due_string,
    :due_date,
    :due_datetime,
    :due_lang,
    :duration,
    :duration_unit,
    :deadline_date,
    :deadline_lang,
    :url,
    :comment_count,
    :is_completed,
    :creator_id,
    :created_at
  ]

  @doc """
  Creates a new task struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      content: data["content"],
      description: data["description"],
      project_id: data["project_id"],
      section_id: data["section_id"],
      parent_id: data["parent_id"],
      order: data["order"],
      labels: data["labels"],
      priority: data["priority"],
      assignee_id: data["assignee_id"],
      due_string: data["due_string"],
      due_date: data["due_date"],
      due_datetime: data["due_datetime"],
      due_lang: data["due_lang"],
      duration: data["duration"],
      duration_unit: data["duration_unit"],
      deadline_date: data["deadline_date"],
      deadline_lang: data["deadline_lang"],
      url: data["url"],
      comment_count: data["comment_count"],
      is_completed: data["is_completed"],
      creator_id: data["creator_id"],
      created_at: data["created_at"]
    }
  end

  @doc """
  Converts a task struct to args map for API operations.
  """
  @spec to_args(t()) :: map()
  def to_args(%__MODULE__{} = task) do
    task
    |> Map.from_struct()
    |> Map.drop([:id, :url, :comment_count, :is_completed, :creator_id, :created_at])
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Enum.into(%{}, fn {k, v} -> {to_string(k), v} end)
  end

  @doc """
  Creates a new task with required content.
  """
  @spec new(String.t(), keyword()) :: t()
  def new(content, opts \\ []) when is_binary(content) do
    %__MODULE__{
      content: content,
      description: Keyword.get(opts, :description),
      project_id: Keyword.get(opts, :project_id),
      section_id: Keyword.get(opts, :section_id),
      parent_id: Keyword.get(opts, :parent_id),
      order: Keyword.get(opts, :order),
      labels: Keyword.get(opts, :labels),
      priority: Keyword.get(opts, :priority),
      assignee_id: Keyword.get(opts, :assignee_id),
      due_string: Keyword.get(opts, :due_string),
      due_date: Keyword.get(opts, :due_date),
      due_datetime: Keyword.get(opts, :due_datetime),
      due_lang: Keyword.get(opts, :due_lang),
      duration: Keyword.get(opts, :duration),
      duration_unit: Keyword.get(opts, :duration_unit),
      deadline_date: Keyword.get(opts, :deadline_date),
      deadline_lang: Keyword.get(opts, :deadline_lang)
    }
  end
end
