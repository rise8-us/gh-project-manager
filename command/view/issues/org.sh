#!/usr/bin/env bash
set -e

help() {
  cat <<EOF
Manage GitHub Projects(beta) seamlessly from the command line.

USAGE
  gh project-manager view issues org <[project-number]> [flags]

FLAGS
  --help, -h        Show help for command
  --legacy          Set project as legacy

EXAMPLES
  $ gh project-manager view issues org 101
  $ gh project-manager view issues org 102 --legacy

LEARN MORE
  Use 'gh project-manager view issues org --help' for more information about a command.
  Read the documentation at https://github.com/jnmiller-va/gh-project-manager
EOF
}

BASEDIR=$(dirname "$0")
OWNER=$(gh repo view --json owner --jq .owner.login)
LEGACY=false
PROJECT=

if [ "${1:0:2}" == "--" ]; then
  help
  exit 0
else
  PROJECT=$1
  shift
fi

while [ $# -gt 0 ]; do
  case "$1" in
  --legacy)
    LEGACY=true
    ;;
  -h|--help)
    help
    exit 0
    ;;
  *)
    help >&2
    exit 1
    ;;
  esac
  shift
done

if [ $LEGACY == true ]; then
  QUERY="
    query(\$org: String!, \$project: Int!, \$endCursor: String) {
      organization(login: \$org) {
        project(number: \$project) {
          name
          body
          state
          columns(first:100) {
            nodes {
              name
              cards(first:100, after: \$endCursor) {
                pageInfo {
                  hasNextPage
                  endCursor
                }
                nodes {
                  content {
                    ... on Issue {
                      id
                      title
                    }
                  }
                }
              }
            }
          }
        }
      }
    }"

  exec gh api graphql -f query="${QUERY}" --paginate -F org="$OWNER" -F project="$PROJECT" -q "[.data.organization.project.columns.nodes[] as \$columns | \$columns.cards.nodes[] | select(.content != null) | {id: .content.id, title: .content.title, status: \$columns.name}]"
else
   QUERY="
     query(\$org: String!, \$project: Int!, \$endCursor: String) {
       organization(login: \$org) {
         projectNext(number: \$project) {
           title
           fields(first:100) {
             nodes {
               id
               name
               settings
             }
           }
           items(first:100, after:\$endCursor ) {
             nodes {
               fieldValues(first: 100) {
                 nodes {
                   value
                   projectField {
                     id
                   }
                 }
               }
               content {
                 ... on Issue {
                   id
                   title
                 }
               }
             }
           }
         }
       }
     }"

  exec gh api graphql -f query="${QUERY}" --paginate -F org="$OWNER" -F project="$PROJECT" -q ".data.organization.projectNext as \$project | \$project.fields.nodes[] | select(.name == \"Status\") | . as \$field | .settings | fromjson | . as \$settings | {id: \$field.id, name: \$field.name, settings: \$settings} as \$status | \$project.items.nodes as \$cards | \$cards | map({id: .content.id, title: .content.title, status: (.fieldValues.nodes[] | select(.projectField.id == \$status.id) as \$setting | \$settings.options[] | select(.id == \$setting.value)| .name) })"
fi
