defmodule Taskbeam.Comment do
  @moduledoc """
  Comment data structure and operations.
  """

  @type t :: %__MODULE__{
          id: String.t() | nil,
          task_id: String.t() | nil,
          project_id: String.t() | nil,
          content: String.t(),
          posted_at: String.t() | nil,
          attachment: map() | nil
        }

  defstruct [
    :id,
    :task_id,
    :project_id,
    :content,
    :posted_at,
    :attachment
  ]

  @doc """
  Creates a new comment struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      task_id: data["task_id"],
      project_id: data["project_id"],
      content: data["content"],
      posted_at: data["posted_at"],
      attachment: data["attachment"]
    }
  end

  @doc """
  Converts a comment struct to args map for API operations.
  """
  @spec to_args(t()) :: map()
  def to_args(%__MODULE__{} = comment) do
    comment
    |> Map.from_struct()
    |> Map.drop([:id, :posted_at])
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  @doc """
  Creates a new comment with required content.
  """
  @spec new(String.t(), keyword()) :: t()
  def new(content, opts \\ []) when is_binary(content) do
    %__MODULE__{
      content: content,
      task_id: Keyword.get(opts, :task_id),
      project_id: Keyword.get(opts, :project_id),
      attachment: Keyword.get(opts, :attachment)
    }
  end
end
