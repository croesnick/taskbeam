defmodule Taskbeam.CLI.Commands.AddTask do
  @moduledoc """
  Add Task command implementation.
  """

  alias Taskbeam.CLI.Helpers

  def run(parsed_args) do
    case Helpers.setup_client(parsed_args) do
      {:ok, client, config} ->
        content = parsed_args.args[:content]
        options = parsed_args.options

        Helpers.verbose_log("Creating task: #{content}", config)
        create_task(client, content, options, config)

      {:error, reason} ->
        Helpers.handle_error({:error, reason}, %{json_output: false})
    end
  end

  defp create_task(client, content, options, config) do
    # Build task args
    task_args = build_task_args(content, options)
    temp_id = generate_temp_id()

    case Taskbeam.Sync.add_task(client, temp_id, task_args) do
      {:ok, response} ->
        handle_success(response, temp_id, config)

      {:error, reason} ->
        Helpers.handle_error({:error, reason}, config)
    end
  end

  defp build_task_args(content, options) do
    args = %{content: content}

    args =
      if project_id = options[:project] do
        Map.put(args, :project_id, project_id)
      else
        args
      end

    args =
      if priority = options[:priority] do
        Map.put(args, :priority, priority)
      else
        args
      end

    args =
      if due_string = options[:due] do
        Map.put(args, :due_string, due_string)
      else
        args
      end

    args
  end

  defp generate_temp_id do
    "temp_#{System.system_time(:microsecond)}"
  end

  defp handle_success(response, temp_id, config) do
    case response do
      %{"sync_status" => _status, "temp_id_mapping" => mapping} ->
        handle_mapping_response(mapping, temp_id, config)

      _ ->
        Helpers.output_message("Task created (response format unexpected)", config)
    end
  end

  defp handle_mapping_response(mapping, temp_id, config) do
    case Map.get(mapping, temp_id) do
      task_id when is_binary(task_id) ->
        output_success(task_id, temp_id, config)

      nil ->
        Helpers.output_message("Task created but ID not returned", config)
    end
  end

  defp output_success(task_id, temp_id, config) do
    if config.json_output do
      result = %{
        status: "success",
        message: "Task created successfully",
        task_id: task_id,
        temp_id: temp_id
      }

      IO.puts(Jason.encode!(result, pretty: true))
    else
      IO.puts("✓ Task created successfully!")
      IO.puts("  Task ID: #{task_id}")
    end
  end
end
