defmodule Taskbeam.Project do
  @moduledoc """
  Project data structure and operations.
  """

  @type t :: %__MODULE__{
          id: String.t() | nil,
          name: String.t(),
          description: String.t() | nil,
          parent_id: String.t() | nil,
          color: map() | nil,
          is_favorite: boolean() | nil,
          view_style: String.t() | nil,
          comment_count: integer() | nil,
          order: integer() | nil,
          is_shared: boolean() | nil,
          is_inbox_project: boolean() | nil,
          is_team_inbox: boolean() | nil,
          url: String.t() | nil
        }

  defstruct [
    :id,
    :name,
    :description,
    :parent_id,
    :color,
    :is_favorite,
    :view_style,
    :comment_count,
    :order,
    :is_shared,
    :is_inbox_project,
    :is_team_inbox,
    :url
  ]

  @doc """
  Creates a new project struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      name: data["name"],
      description: data["description"],
      parent_id: data["parent_id"],
      color: data["color"],
      is_favorite: data["is_favorite"],
      view_style: data["view_style"],
      comment_count: data["comment_count"],
      order: data["order"],
      is_shared: data["is_shared"],
      is_inbox_project: data["is_inbox_project"],
      is_team_inbox: data["is_team_inbox"],
      url: data["url"]
    }
  end

  @doc """
  Converts a project struct to args map for API operations.
  """
  @spec to_args(t()) :: map()
  def to_args(%__MODULE__{} = project) do
    project
    |> Map.from_struct()
    |> Map.drop([
      :id,
      :comment_count,
      :order,
      :is_shared,
      :is_inbox_project,
      :is_team_inbox,
      :url
    ])
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  @doc """
  Creates a new project with required name.
  """
  @spec new(String.t(), keyword()) :: t()
  def new(name, opts \\ []) when is_binary(name) do
    %__MODULE__{
      name: name,
      description: Keyword.get(opts, :description),
      parent_id: Keyword.get(opts, :parent_id),
      color: Keyword.get(opts, :color),
      is_favorite: Keyword.get(opts, :is_favorite),
      view_style: Keyword.get(opts, :view_style)
    }
  end
end
