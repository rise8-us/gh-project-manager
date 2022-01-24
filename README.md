# gh-project-manager
GitHub CLI Extension for Project(beta) Management

## Install
```sh
gh extension install jnmiller-va/gh-project-manager
```

## Features
- Initiate a project from your repo via organization or user.
- Add your existing issues from a legacy project to your new project (beta).
- Update project fields and state on issues.

## Manual
```
Manage GitHub Projects(beta) seamlessly from the command line.

USAGE
  gh project-manager <command> <subcommands> [flags]

COMMANDS
  add:              Add issues to project
  init:             Initialize a new project (beta)
  view:             View project specific properties and children
  update:           Update project specific properties and children

FLAGS
  --help, -h        Show help for command

EXAMPLES
  $ gh project-manager init
  $ gh project-manager view issues --project-type user --project-num 4 --status "In progress" --state OPEN --legacy > issues.json
  $ gh project-manager add issues --project-type org --project-num 1 --path issues.json
  $ gh project-manager update issue --project-type org --project-num 1 --issue-num 25 --field Sprint --value current

LEARN MORE
  Use 'gh project-manager <command> --help' for more information about a command.
  Read the documentation at https://github.com/jnmiller-va/gh-project-manager
```