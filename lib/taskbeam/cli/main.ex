defmodule Taskbeam.CLI.Main do
  @moduledoc """
  Main CLI entry point for Taskbeam.
  """

  alias Taskbeam.CLI.Commands

  @common_flags [
    json: [
      short: "-j",
      long: "--json",
      help: "Output results as JSON"
    ],
    verbose: [
      short: "-v",
      long: "--verbose",
      help: "Verbose output"
    ]
  ]

  @common_options [
    token: [
      short: "-t",
      long: "--token",
      help: "Todoist API token (or use TODOIST_API_TOKEN env var)",
      parser: :string
    ]
  ]

  def main(args) do
    args
    |> parse_args()
    |> execute()
  end

  defp parse_args(args) do
    Optimus.new!(
      name: "taskbeam",
      description: "A modern Elixir API client for Todoist",
      version: "0.1.0",
      author: "Taskbeam Team",
      about: "Interact with Todoist API from the command line",
      allow_unknown_args: false,
      parse_double_dash: true,
      flags: [
        json: [
          short: "-j",
          long: "--json",
          help: "Output results as JSON",
          required: false
        ],
        verbose: [
          short: "-v",
          long: "--verbose",
          help: "Verbose output",
          required: false
        ]
      ],
      options: [
        token: [
          short: "-t",
          long: "--token",
          help: "Todoist API token (or use TODOIST_API_TOKEN env var)",
          parser: :string,
          required: false
        ]
      ],
      subcommands: [
        auth: [
          name: "auth",
          about: "Test authentication and show user info",
          flags: @common_flags,
          options: @common_options
        ],
        projects: [
          name: "projects",
          about: "List all projects",
          flags: @common_flags,
          options: @common_options
        ],
        tasks: [
          name: "tasks",
          about: "List tasks with optional filtering",
          flags: @common_flags,
          options:
            @common_options ++
              [
                project: [
                  long: "--project",
                  help: "Filter by project ID",
                  parser: :string
                ],
                completed: [
                  long: "--completed",
                  help: "Show completed tasks"
                ],
                priority: [
                  long: "--priority",
                  help: "Filter by priority (1-4)",
                  parser: :integer
                ],
                due: [
                  long: "--due",
                  help: "Filter by due date (today, overdue, today+overdue, upcoming, none)",
                  parser: :string
                ]
              ]
        ],
        labels: [
          name: "labels",
          about: "List all labels",
          flags: @common_flags,
          options: @common_options
        ],
        add_task: [
          name: "add-task",
          about: "Add a new task",
          flags: @common_flags,
          args: [
            content: [
              value_name: "CONTENT",
              help: "Task content",
              required: true,
              parser: :string
            ]
          ],
          options:
            @common_options ++
              [
                project: [
                  long: "--project",
                  help: "Project ID",
                  parser: :string
                ],
                priority: [
                  long: "--priority",
                  help: "Priority (1-4)",
                  parser: :integer
                ],
                due: [
                  long: "--due",
                  help: "Due date (natural language)",
                  parser: :string
                ]
              ]
        ],
        complete: [
          name: "complete",
          about: "Complete a task",
          flags: @common_flags,
          args: [
            task_id: [
              value_name: "TASK_ID",
              help: "Task ID to complete",
              required: true,
              parser: :string
            ]
          ],
          options: @common_options
        ]
      ]
    )
    |> Optimus.parse!(args)
  end

  defp execute({command_path, %Optimus.ParseResult{} = parsed}) do
    case command_path do
      [:auth] ->
        Commands.Auth.run(parsed)

      [:projects] ->
        Commands.Projects.run(parsed)

      [:tasks] ->
        Commands.Tasks.run(parsed)

      [:labels] ->
        Commands.Labels.run(parsed)

      [:add_task] ->
        Commands.AddTask.run(parsed)

      [:complete] ->
        Commands.Complete.run(parsed)

      [] ->
        show_help()
    end
  end

  defp execute({:error, error}) do
    IO.puts(:stderr, "Error: #{error}")
    System.halt(1)
  end

  defp show_help do
    IO.puts("""
    Taskbeam - A modern Elixir API client for Todoist

    Usage: taskbeam [OPTIONS] <COMMAND>

    Commands:
      auth                     Test authentication and show user info
      projects                 List all projects  
      tasks [OPTIONS]          List tasks with optional filtering
      labels                   List all labels
      add-task <CONTENT>       Add a new task
      complete <TASK_ID>       Complete a task

    Global Options:
      -t, --token <TOKEN>      Todoist API token (or use TODOIST_API_TOKEN env var)
      -j, --json               Output results as JSON
      -v, --verbose            Verbose output
      -h, --help               Show help

    For more information on a specific command, use:
      taskbeam <COMMAND> --help

    Authentication:
      Set your Todoist API token via:
        - Environment variable: export TODOIST_API_TOKEN=your_token
        - Command line flag: --token your_token
        - Interactive prompt (if neither provided)
    """)
  end
end
