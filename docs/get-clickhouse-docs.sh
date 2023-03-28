#!/usr/bin/env bash
set -e
# The script to clone or update the user-guides documentation repo
# https://github.com/ClickHouse/clickhouse-docs

WORKDIR=$(dirname "$0")
WORKDIR=$(readlink -f "${WORKDIR}")
cd "$WORKDIR"

if [ -d "clickhouse-docs" ]; then
  git -C clickhouse-docs pull
else
  if [ -n "$1" ]; then
    url_type="$1"
  else
    read -rp "Enter the URL type (ssh | https): " url_type
  fi
  case "$url_type" in
  ssh)
    git_url=git@github.com:ClickHouse/clickhouse-docs.git
    ;;
  https)
    git_url=https://github.com/ClickHouse/clickhouse-docs.git
    ;;
  *)
    echo "Url type must be 'ssh' or 'https'"
    exit 1
    ;;
  esac

  if [ -n "$2" ]; then
    set_git_hook="$2"
  elif [ ! -n "$1" ]; then
    read -rp "Would you like to setup git hook for automatic update? (y|n): " set_git_hook
  fi

  if [ "$set_git_hook" = "y" ]; then
    hook_command="$(pwd)/pull-clickhouse-docs-hook.sh 24"
    hook_file=$(realpath "$(pwd)/../.git/hooks/post-checkout")
    already_have=$(grep -Faq "pull-clickhouse-docs-hook.sh" "$hook_file" 2>/dev/null && echo 1 || echo 0)
    if [ $already_have -eq 0 ]; then
      echo "Appending '$hook_command' to $hook_file"
      echo "$hook_command" >> "$hook_file"
      chmod u+x "$hook_file"  # Just in case it did not exist before append
    else
      echo "Looks like the update hook already exists, will not add another one"
    fi
  elif [ ! "$set_git_hook" = "n" ]; then
    echo "Expected 'y' or 'n', got '$set_git_hook', will not setup git hook"
  fi

  git clone "$git_url" "clickhouse-docs"
fi
