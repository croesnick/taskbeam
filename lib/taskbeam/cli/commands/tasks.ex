defmodule Taskbeam.CLI.Commands.Tasks do
  @moduledoc """
  Tasks command implementation.
  """

  alias Taskbeam.CLI.Helpers

  def run(parsed_args) do
    case Helpers.setup_client(parsed_args) do
      {:ok, client, config} ->
        Helpers.verbose_log("Fetching tasks...", config)
        fetch_tasks(client, config, parsed_args.options)

      {:error, reason} ->
        Helpers.handle_error({:error, reason}, %{json_output: false})
    end
  end

  defp fetch_tasks(client, config, options) do
    # Build query parameters based on options
    params = build_params(options)

    endpoint =
      if options[:completed] do
        "tasks"
      else
        "tasks"
      end

    case Taskbeam.Client.get(client, endpoint, params) do
      {:ok, response} ->
        tasks = extract_tasks(response)
        filtered_tasks = apply_filters(tasks, options)
        formatted_tasks = format_tasks(filtered_tasks)
        Helpers.output_data(formatted_tasks, config)

      {:error, reason} ->
        Helpers.handle_error({:error, reason}, config)
    end
  end

  defp build_params(options) do
    params = []

    params =
      if project_id = options[:project] do
        [{"project_id", project_id} | params]
      else
        params
      end

    params
  end

  defp extract_tasks(response) when is_list(response) do
    response
  end

  defp extract_tasks(response) when is_map(response) do
    cond do
      Map.has_key?(response, "results") -> response["results"]
      Map.has_key?(response, "tasks") -> response["tasks"]
      Map.has_key?(response, "data") -> response["data"]
      true -> [response]
    end
  end

  defp extract_tasks(_), do: []

  defp apply_filters(tasks, options) do
    tasks
    |> filter_by_priority(options[:priority])
    |> filter_by_completion(options[:completed])
    |> filter_by_due_date(options[:due])
  end

  defp filter_by_priority(tasks, nil), do: tasks

  defp filter_by_priority(tasks, priority) do
    Enum.filter(tasks, fn task ->
      (task["priority"] || 1) == priority
    end)
  end

  defp filter_by_completion(tasks, nil), do: tasks

  defp filter_by_completion(tasks, show_completed) do
    if show_completed do
      Enum.filter(tasks, & &1["is_completed"])
    else
      Enum.filter(tasks, &(not &1["is_completed"]))
    end
  end

  defp filter_by_due_date(tasks, nil), do: tasks

  defp filter_by_due_date(tasks, due_filter) do
    today = Date.utc_today()

    case due_filter do
      "today" ->
        Enum.filter(tasks, &due_today?(&1, today))

      "overdue" ->
        Enum.filter(tasks, &overdue?(&1, today))

      "today+overdue" ->
        Enum.filter(tasks, fn task ->
          due_today?(task, today) or overdue?(task, today)
        end)

      "upcoming" ->
        Enum.filter(tasks, &upcoming?(&1, today))

      "none" ->
        Enum.filter(tasks, &is_nil(get_task_due_date(&1)))

      _ ->
        tasks
    end
  end

  defp get_task_due_date(task) do
    case task["due"] do
      %{"date" => date_str} -> parse_date(date_str)
      %{"datetime" => datetime_str} -> parse_date(datetime_str)
      _ -> nil
    end
  end

  defp parse_date(date_str) when is_binary(date_str) do
    case Date.from_iso8601(String.slice(date_str, 0..9)) do
      {:ok, date} -> date
      {:error, _} -> nil
    end
  end

  defp parse_date(_), do: nil

  defp due_today?(task, today) do
    case get_task_due_date(task) do
      ^today -> true
      _ -> false
    end
  end

  defp overdue?(task, today) do
    case get_task_due_date(task) do
      date when not is_nil(date) -> Date.before?(date, today)
      _ -> false
    end
  end

  defp upcoming?(task, today) do
    case get_task_due_date(task) do
      date when not is_nil(date) -> Date.after?(date, today)
      _ -> false
    end
  end

  defp format_tasks(tasks) do
    tasks
    |> Enum.map(&format_task/1)
    |> Enum.sort_by(& &1.order)
  end

  defp format_task(task) do
    %{
      id: task["id"],
      content: task["content"],
      project_id: task["project_id"],
      priority: format_priority(task["priority"]),
      due: format_due_date(task["due"]),
      labels: format_labels(task["labels"]),
      is_completed: task["is_completed"] || false,
      order: task["order"] || 0,
      url: task["url"]
    }
  end

  defp format_priority(nil), do: 1
  defp format_priority(priority) when is_integer(priority), do: priority
  defp format_priority(_), do: 1

  defp format_due_date(nil), do: ""

  defp format_due_date(due) when is_map(due) do
    case due do
      %{"date" => date} -> date
      %{"datetime" => datetime} -> datetime
      _ -> ""
    end
  end

  defp format_due_date(_), do: ""

  defp format_labels(nil), do: []
  defp format_labels(labels) when is_list(labels), do: labels
  defp format_labels(_), do: []
end
