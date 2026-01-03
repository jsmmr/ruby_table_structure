# AGENTS.md

This document provides guidance for AI agents working with this codebase.

## Project Overview

**TableStructure** is a Ruby gem for building complex table schemas using a declarative DSL. It's designed for CSV exports, report generation, and data transformation, with support for dynamic columns and streaming output.

- **Repository**: https://github.com/jsmmr/ruby_table_structure
- **License**: MIT
- **Ruby Versions**: 2.4 - 4.0
- **Ruby Version Manager**: [mise](https://mise.jdx.dev/) (see `.ruby-version`)

## Core Components

| Component | File | Description |
|-----------|------|-------------|
| `TableStructure::Schema` | `lib/table_structure/schema.rb` | DSL module for defining table columns |
| `TableStructure::Writer` | `lib/table_structure/writer.rb` | Converts data and outputs to various targets |
| `TableStructure::Iterator` | `lib/table_structure/iterator.rb` | Enumerates table-structured data |
| `TableStructure::Table` | `lib/table_structure/table.rb` | Provides data conversion methods |
| `TableStructure::CSV::Writer` | `lib/table_structure/csv/writer.rb` | CSV-specific writer with BOM support |

## Directory Structure

```
lib/
├── table_structure.rb          # Main entry point
└── table_structure/
    ├── schema.rb               # Schema DSL module
    ├── schema/                 # Schema internals (DSL, definitions, columns)
    ├── writer.rb               # Writer class
    ├── iterator.rb             # Iterator class
    ├── table.rb                # Table class
    ├── csv/                    # CSV-specific utilities
    ├── utils.rb                # Utility functions
    └── version.rb              # Version constant
spec/
├── table_structure/            # Unit tests organized by module
└── spec_helper.rb
```

## Development Commands

```bash
# Install Ruby version via mise
mise install

# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/table_structure/schema_spec.rb
```

## Coding Standards

### Ruby Style

- Use `frozen_string_literal: true` pragma in all Ruby files
- Follow standard Ruby naming conventions (snake_case for methods/variables, CamelCase for classes/modules)

### Testing

- Tests use RSpec
- Test files mirror the `lib/` directory structure under `spec/`
- Run full test suite before committing changes

### Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`

### Branch Naming

Use prefixes: `feature/`, `fix/`, `docs/`, `style/`, `refactor/`, `test/`, `chore/`

Example: `feature/add-custom-formatter`

## Key Concepts

### Schema Definition

Schemas define table columns using DSL:

```ruby
class MySchema
  include TableStructure::Schema

  column name: 'ID', value: ->(row, *) { row[:id] }
  column name: 'Name', value: ->(row, *) { row[:name] }
end
```

### Schema Composition

Schemas can be:
- **Nested**: Using `columns SchemaClass`
- **Concatenated**: Using `SchemaA + SchemaB`
- **Merged**: Using `SchemaA.merge(SchemaB)`

### Output Types

- **Array**: Default row output
- **Hash**: Use `row_type: :hash` with `:key` definitions

## CI/CD

GitHub Actions workflow (`.github/workflows/build.yml`):
- Runs on all pushes
- Tests against Ruby 2.4 - 4.0
- Uses `bundle exec rspec`

## Common Tasks for Agents

### Adding a New Feature

1. Create feature branch: `git checkout -b feature/your-feature`
2. Implement changes in `lib/table_structure/`
3. Add tests in `spec/table_structure/`
4. Run `bundle exec rspec` to verify
5. Update `CHANGELOG.md` if applicable
6. Commit following conventional commit format

### Fixing a Bug

1. Create fix branch: `git checkout -b fix/issue-description`
2. Write a failing test that reproduces the bug
3. Implement the fix
4. Verify all tests pass: `bundle exec rspec`
5. Commit following conventional commit format

### Releasing a New Version

1. Update version in `lib/table_structure/version.rb`
2. Update `CHANGELOG.md` with release notes
3. Commit and tag the release
