defmodule Taskbeam.CLI.Commands.Complete do
  @moduledoc """
  Complete Task command implementation.
  """

  alias Taskbeam.CLI.Helpers

  def run(parsed_args) do
    case Helpers.setup_client(parsed_args) do
      {:ok, client, config} ->
        task_id = parsed_args.args[:task_id]

        Helpers.verbose_log("Completing task: #{task_id}", config)
        complete_task(client, task_id, config)

      {:error, reason} ->
        Helpers.handle_error({:error, reason}, %{json_output: false})
    end
  end

  defp complete_task(client, task_id, config) do
    case Taskbeam.Sync.complete_task(client, task_id) do
      {:ok, response} ->
        handle_success(response, task_id, config)

      {:error, reason} ->
        Helpers.handle_error({:error, reason}, config)
    end
  end

  defp handle_success(response, task_id, config) do
    case response do
      %{"sync_status" => _status} ->
        if config.json_output do
          result = %{
            status: "success",
            message: "Task completed successfully",
            task_id: task_id
          }

          IO.puts(Jason.encode!(result, pretty: true))
        else
          IO.puts("✓ Task completed successfully!")
          IO.puts("  Task ID: #{task_id}")
        end

      _ ->
        Helpers.output_message("Task completed (response format unexpected)", config)
    end
  end
end
