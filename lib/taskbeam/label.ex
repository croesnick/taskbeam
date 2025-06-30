defmodule Taskbeam.Label do
  @moduledoc """
  Label data structure and operations.
  """

  @type t :: %__MODULE__{
          id: String.t() | nil,
          name: String.t(),
          color: String.t() | nil,
          order: integer() | nil,
          is_favorite: boolean() | nil
        }

  defstruct [
    :id,
    :name,
    :color,
    :order,
    :is_favorite
  ]

  @doc """
  Creates a new label struct from a map.
  """
  @spec from_map(map()) :: t()
  def from_map(data) when is_map(data) do
    %__MODULE__{
      id: data["id"],
      name: data["name"],
      color: data["color"],
      order: data["order"],
      is_favorite: data["is_favorite"]
    }
  end

  @doc """
  Converts a label struct to args map for API operations.
  """
  @spec to_args(t()) :: map()
  def to_args(%__MODULE__{} = label) do
    label
    |> Map.from_struct()
    |> Map.drop([:id])
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()
  end

  @doc """
  Creates a new label with required name.
  """
  @spec new(String.t(), keyword()) :: t()
  def new(name, opts \\ []) when is_binary(name) do
    %__MODULE__{
      name: name,
      color: Keyword.get(opts, :color),
      order: Keyword.get(opts, :order),
      is_favorite: Keyword.get(opts, :is_favorite)
    }
  end
end
