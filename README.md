# Taskbeam

A modern Elixir API client for Todoist. Taskbeam provides a clean and efficient interface to interact with the Todoist API, supporting both REST and Sync endpoints with proper authentication and data structures.

## Features

- 🔐 **Authentication** - Bearer token and OAuth 2.0 support
- 🔄 **Sync API** - Full support for Todoist's Sync API with command batching
- 📝 **Data Structures** - Typed structs for Tasks, Projects, Labels, and Comments
- 🧪 **Well Tested** - Comprehensive test coverage
- 📚 **Documented** - Full documentation with examples
- ⚡ **Modern** - Built with Req HTTP client and Jason JSON library
- 🖥️ **CLI Tool** - Command-line interface for testing and interacting with Todoist
- ✅ **High Quality** - Enforced with Credo and Dialyzer static analysis

## Installation

Add `taskbeam` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:taskbeam, "~> 0.1.0"}
  ]
end
```

## Quick Start

### Basic Usage

```elixir
# Create a client with your API token
client = Taskbeam.Client.new("your_api_token")

# Create and add a new task
task = Taskbeam.Task.new("Buy groceries", project_id: "123", priority: 3)
{:ok, response} = Taskbeam.Sync.add_task(client, "temp_id_1", Taskbeam.Task.to_args(task))

# Perform a full sync to get all data
{:ok, data} = Taskbeam.Sync.full_sync(client)

# Update a task
{:ok, response} = Taskbeam.Sync.update_task(client, "task_id", %{content: "Updated content"})

# Complete a task
{:ok, response} = Taskbeam.Sync.complete_task(client, "task_id")
```

### Using the Main Module

```elixir
# Create a client
client = Taskbeam.new("your_api_token")

# Create data structures
task = Taskbeam.new_task("Buy milk", priority: 4)
project = Taskbeam.new_project("Shopping", color: %{name: "blue"})
label = Taskbeam.new_label("urgent", color: "red")
```

### OAuth Authentication

```elixir
# Generate authorization URL
auth_url = Taskbeam.Auth.authorization_url(
  "your_client_id",
  "http://localhost:4000/callback",
  ["data:read_write"],
  "optional_state"
)

# Exchange authorization code for access token
{:ok, token_response} = Taskbeam.Auth.exchange_code(
  "your_client_id",
  "your_client_secret", 
  "authorization_code"
)

# Use the access token
client = Taskbeam.Client.new(token_response["access_token"])
```

## Command Line Interface

Taskbeam includes a powerful CLI tool for testing and interacting with the Todoist API.

### Building the CLI

```bash
# Install dependencies and build the CLI binary
mix deps.get
mix escript.build

# The binary will be created as ./taskbeam
```

### CLI Usage

```bash
# Get help
./taskbeam --help
./taskbeam help tasks

# Test authentication
./taskbeam auth
./taskbeam auth --token your_token

# List projects
./taskbeam projects
./taskbeam projects --json

# List tasks with filtering
./taskbeam tasks
./taskbeam tasks --project 123456
./taskbeam tasks --priority 4
./taskbeam tasks --completed

# Add a new task
./taskbeam add-task "Buy groceries"
./taskbeam add-task "Important task" --project 123456 --priority 4 --due "tomorrow"

# Complete a task
./taskbeam complete 987654321

# List labels
./taskbeam labels
```

### Authentication Options

The CLI supports multiple ways to provide your API token:

1. **Environment variable** (recommended):
   ```bash
   export TODOIST_API_TOKEN=your_api_token
   ./taskbeam auth
   ```

2. **Command line argument**:
   ```bash
   ./taskbeam auth --token your_api_token
   ```

3. **Interactive prompt**: The CLI will prompt for your token if none is provided

4. **Saved configuration**: Tokens can be saved to `~/.taskbeam/config.json`

### CLI Commands

- `auth` - Test authentication and show account info
- `projects` - List all projects with details
- `tasks [options]` - List tasks with filtering options:
  - `--project <id>` - Filter by project ID
  - `--priority <1-4>` - Filter by priority level
  - `--completed` - Show completed tasks
- `labels` - List all labels
- `add-task <content>` - Create a new task:
  - `--project <id>` - Assign to project
  - `--priority <1-4>` - Set priority
  - `--due <date>` - Set due date (natural language)
- `complete <task-id>` - Mark task as completed

### Output Formats

- **Table format** (default): Human-readable tables
- **JSON format**: Use `--json` flag for machine-readable output
- **Verbose mode**: Use `--verbose` for detailed output

## API Reference

### Client Operations

- `Taskbeam.Client.new/1` - Create a new client
- `Taskbeam.Client.get/3` - GET request to REST API
- `Taskbeam.Client.post/3` - POST request to REST API
- `Taskbeam.Client.sync/3` - POST request to Sync API

### Sync Operations

- `Taskbeam.Sync.add_task/3` - Add a new task
- `Taskbeam.Sync.update_task/3` - Update an existing task
- `Taskbeam.Sync.complete_task/2` - Complete a task
- `Taskbeam.Sync.delete_task/2` - Delete a task
- `Taskbeam.Sync.add_project/3` - Add a new project
- `Taskbeam.Sync.update_project/3` - Update a project
- `Taskbeam.Sync.delete_project/2` - Delete a project
- `Taskbeam.Sync.full_sync/1` - Perform full sync
- `Taskbeam.Sync.incremental_sync/2` - Perform incremental sync

### Data Structures

All data structures support:
- `from_map/1` - Create struct from API response
- `to_args/1` - Convert struct to API parameters
- `new/2` - Create new struct with options

#### Task Parameters

```elixir
task = Taskbeam.Task.new("Task content", [
  description: "Task description",
  project_id: "123",
  section_id: "456", 
  parent_id: "789",
  order: 1,
  labels: ["label1", "label2"],
  priority: 4,
  assignee_id: 123,
  due_string: "tomorrow",
  due_date: "2023-12-01",
  due_datetime: "2023-12-01T15:00:00Z",
  duration: 60,
  duration_unit: "minute"
])
```

#### Project Parameters

```elixir
project = Taskbeam.Project.new("Project name", [
  description: "Project description",
  parent_id: "123",
  color: %{name: "blue", hex: "#0000FF"},
  is_favorite: true,
  view_style: "list"
])
```

## Error Handling

All API calls return `{:ok, response}` or `{:error, reason}` tuples:

```elixir
case Taskbeam.Sync.add_task(client, "temp_id", task_args) do
  {:ok, response} -> 
    # Handle success
    IO.inspect(response)
  {:error, {status, body}} ->
    # Handle HTTP error
    IO.puts("HTTP #{status}: #{inspect(body)}")
  {:error, reason} ->
    # Handle other errors
    IO.puts("Error: #{inspect(reason)}")
end
```

## Configuration

No configuration is required. Simply create a client with your API token:

```elixir
client = Taskbeam.Client.new(System.get_env("TODOIST_API_TOKEN"))
```

## Development

### Code Quality

This project maintains high code quality standards using:

- **Credo** - Static code analysis for consistency and best practices
- **Dialyzer** - Static type analysis to catch type errors
- **ExUnit** - Comprehensive test suite
- **Formatter** - Consistent code formatting

### Running Quality Checks

```bash
# Format code
mix format

# Run tests
mix test

# Check code quality
mix credo --strict

# Run static type analysis
mix dialyzer

# Run all quality checks
mix format && mix test && mix credo --strict && mix dialyzer
```

### Development Workflow

1. Make your changes
2. Run `mix format` to format code
3. Run `mix test` to ensure tests pass
4. Run `mix credo --strict` to check code quality
5. Run `mix dialyzer` to check for type issues
6. Build and test the CLI: `mix escript.build && ./taskbeam --help`

### Continuous Integration

This project uses GitHub Actions for continuous integration with the following jobs:

- **Test Matrix**: Tests against Elixir 1.17 & 1.18 with OTP 27
- **Code Quality**: Format checking, Credo linting, and Dialyzer analysis  
- **CLI Testing**: Build and test the CLI binary functionality

The CI pipeline runs on:
- All pushes to `main` and `develop` branches
- All pull requests to `main` branch

### Automated Dependency Updates

Dependabot is configured to:
- Check for Elixir dependency updates weekly
- Check for GitHub Actions updates weekly  
- Group minor and patch updates together
- Auto-label PRs with appropriate tags

## Publishing Releases

Taskbeam is automatically published to [Hex.pm](https://hex.pm/packages/taskbeam) when a GitHub release is created.

### Release Process

1. **Create a GitHub Release**: 
   - Go to [Releases](https://github.com/croesnick/taskbeam/releases) and click "Create a new release"
   - Use semantic versioning for the tag (e.g., `v1.0.0`, `v1.1.0`, `v2.0.0-beta.1`)
   - Add release notes describing the changes

2. **Automated Publishing**:
   - The release workflow automatically triggers
   - Extracts version from the tag and updates `mix.exs`
   - Runs full test suite and quality checks
   - Publishes package to Hex.pm
   - Publishes documentation to HexDocs
   - Commits version bump back to main branch

3. **Required Secrets**:
   - `HEX_API_KEY`: Your Hex.pm API key (set in repository secrets)

### Manual Publishing (Development)

For testing the publishing process locally:

```bash
# Generate documentation
mix docs

# Publish to Hex.pm (requires HEX_API_KEY)
mix hex.publish

# Publish docs only
mix hex.publish docs
```

## Documentation

Full documentation is available on [HexDocs](https://hexdocs.pm/taskbeam).

You can generate documentation locally with:

```bash
mix docs
```

The documentation will be generated in the `doc/` directory.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Ensure tests pass (`mix test`)
5. Commit your changes (`git commit -am 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

