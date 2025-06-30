# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Taskbeam is a modern Elixir API client for Todoist. It provides a clean and efficient interface to interact with the Todoist API, supporting both REST and Sync endpoints with proper authentication and data structures.

### Key Features

- Bearer token and OAuth 2.0 authentication
- Full Sync API support with command batching
- Typed structs for Tasks, Projects, Labels, and Comments
- Comprehensive test coverage
- Built with modern dependencies (Req, Jason)

## Development Commands

### Dependencies and Setup

- `mix deps.get` - Fetch dependencies
- `mix deps.compile` - Compile dependencies

### Testing

- `mix test` - Run all tests
- `mix test test/taskbeam_test.exs` - Run specific test file
- `mix test --trace` - Run tests with detailed output
- `mix test test/taskbeam/` - Run tests for specific modules

### Code Quality

- `mix compile` - Compile the project
- `mix clean` - Clean compiled files
- `mix format` - Format code automatically
- `mix credo` - Run code quality analysis
- `mix credo --strict` - Run strict code quality analysis
- `mix dialyzer` - Run static type analysis

### CLI Development

- `mix escript.build` - Build the CLI binary
- `./taskbeam --help` - Test the CLI help
- `./taskbeam auth` - Test CLI authentication (requires API token)
- `./taskbeam projects` - List all projects
- `./taskbeam tasks` - List all tasks
- `./taskbeam tasks --due today+overdue` - Show today's and overdue tasks
- `./taskbeam labels` - List all labels

### Interactive Development

- `iex -S mix` - Start IEx with the project loaded for interactive testing

## Architecture

The project follows standard Elixir/Mix conventions with a modular structure:

### Core Modules

- `Taskbeam` - Main module with convenient delegates
- `Taskbeam.Client` - HTTP client with authentication (lib/taskbeam/client.ex)
- `Taskbeam.Sync` - Sync API operations (lib/taskbeam/sync.ex)
- `Taskbeam.Auth` - OAuth 2.0 authentication helpers (lib/taskbeam/auth.ex)

### CLI Modules

- `Taskbeam.CLI.Main` - Main CLI entry point (lib/taskbeam/cli/main.ex)
- `Taskbeam.CLI.Config` - Configuration management (lib/taskbeam/cli/config.ex)
- `Taskbeam.CLI.Helpers` - Shared CLI utilities (lib/taskbeam/cli/helpers.ex)
- `Taskbeam.CLI.Commands.*` - Individual command implementations (lib/taskbeam/cli/commands/)

### Data Structures

- `Taskbeam.Task` - Task data structure and operations (lib/taskbeam/task.ex)
- `Taskbeam.Project` - Project data structure and operations (lib/taskbeam/project.ex)
- `Taskbeam.Label` - Label data structure and operations (lib/taskbeam/label.ex)
- `Taskbeam.Comment` - Comment data structure and operations (lib/taskbeam/comment.ex)

### Dependencies

- `req` - Modern HTTP client for API requests
- `jason` - JSON encoding/decoding
- `optimus` - CLI argument parsing
- `table_rex` - ASCII table formatting for CLI output

### Development Dependencies

- `credo` - Code quality analysis
- `dialyxir` - Static type analysis

### Testing Structure

- Tests follow the same structure as lib/ directory
- Each module has corresponding test file in test/taskbeam/
- All tests use ExUnit framework

### API Endpoints

- Base URL: `https://api.todoist.com/api/v1`
- Sync URL: `https://api.todoist.com/api/v1/sync`
- Auth uses Bearer token authentication

## Development Guidelines

### When Adding New Features

1. Add the feature to the appropriate module
2. Write comprehensive tests
3. Update documentation and typespecs
4. Run `mix test` to ensure all tests pass
5. Run `mix compile` to check for warnings
6. Run `mix credo --strict` to ensure code quality
7. Run `mix dialyzer` to check for type issues

### Code Conventions

- Follow standard Elixir naming conventions
- Use typespecs for all public functions
- Include comprehensive documentation with @doc
- Handle errors with {:ok, result} | {:error, reason} tuples
- Convert API responses to/from structs using from_map/1 and to_args/1

### Testing Guidelines

- Test all public functions
- Include both success and error cases
- Use descriptive test names
- Group related tests with describe blocks

### CLI Development Guidelines

- Use Optimus for argument parsing
- Handle errors consistently with Helpers.handle_error/2
- Support both JSON and table output formats
- Provide helpful error messages for common issues
- Use verbose logging when --verbose flag is set

### Code Quality Guidelines

- Run `mix format` before committing
- Ensure `mix credo --strict` passes with no issues
- Address any Dialyzer warnings (or add to ignore file if intentional)
- Follow Elixir naming conventions and documentation standards
- Use typespecs for all public functions

## CLI Usage

### Authentication

Set your Todoist API token via:

- Environment variable: `export TODOIST_API_TOKEN=your_token`
- Command line flag: `--token your_token`
- Interactive prompt (if neither provided)

### Available Commands

- `taskbeam auth` - Test authentication and show user info
- `taskbeam projects` - List all projects
- `taskbeam tasks [OPTIONS]` - List tasks with optional filtering
- `taskbeam labels` - List all labels
- `taskbeam add-task <CONTENT>` - Add a new task
- `taskbeam complete <TASK_ID>` - Complete a task

### Task Filtering Options

- `--project PROJECT_ID` - Filter by project ID
- `--priority 1-4` - Filter by priority level
- `--completed` - Show completed tasks
- `--due FILTER` - Filter by due date:
  - `today` - Tasks due today only
  - `overdue` - Overdue tasks only
  - `today+overdue` - Today's and overdue tasks (recommended for daily workflow)
  - `upcoming` - Future tasks
  - `none` - Tasks with no due date

### Output Formats

- Default: ASCII table format
- `--json` - JSON output for programmatic use
- `--verbose` - Include debug information

### Examples

```bash
# Show today's work and overdue items
./taskbeam tasks --due today+overdue

# Show high priority tasks from a specific project
./taskbeam tasks --project 6c69HwF9R6g8G9Cj --priority 4

# Get all tasks as JSON for processing
./taskbeam tasks --json

# Add a new task
./taskbeam add-task "Review PR #123" --priority 3 --due "tomorrow"

# Complete a task
./taskbeam complete 68vmP9w7cH48mCG8
```

## CI/CD

### GitHub Actions

The project uses GitHub Actions for continuous integration:

- **ci.yml** - Main CI pipeline with test matrix, quality checks, and CLI testing
- Runs on push to main/develop and PRs to main
- Tests multiple Elixir/OTP versions
- Includes format checking, Credo linting, Dialyzer analysis
- Builds and tests CLI binary

### Dependabot

Automated dependency updates configured in `.github/dependabot.yml`:

- Weekly checks for Elixir dependencies
- Weekly checks for GitHub Actions updates
- Groups minor/patch updates
- Auto-labels PRs appropriately
