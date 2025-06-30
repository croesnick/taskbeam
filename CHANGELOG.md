# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of Taskbeam
- Modern Elixir API client for Todoist
- Bearer token and OAuth 2.0 authentication support
- Full Sync API support with command batching
- Typed structs for Tasks, Projects, Labels, and Comments
- Command-line interface (CLI) tool
- Comprehensive test coverage
- Built with modern dependencies (Req, Jason)
- Code quality enforcement with Credo and Dialyzer

### Features
- **Client Operations**: HTTP client with authentication
- **Sync Operations**: Full and incremental sync support
- **Data Structures**: Task, Project, Label, and Comment structs
- **CLI Commands**: auth, projects, tasks, labels, add-task, complete
- **Task Filtering**: By project, priority, completion status, due dates
- **Output Formats**: ASCII table and JSON output
- **Authentication**: Multiple methods (env var, CLI flag, interactive prompt)

## [0.1.0] - 2024-12-30

### Added
- Initial project setup
- Basic API client functionality
- Core data structures
- CLI implementation
- Test suite
- Documentation
- CI/CD pipeline
- Automated publishing to Hex.pm and HexDocs