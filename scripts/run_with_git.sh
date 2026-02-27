#!/bin/bash
#
# run_with_git - Run commands with temporary Git credentials
#
# Usage: run_with_git.sh <command> [arguments...]
#
# Example: run_with_git.sh pip install git+https://github.com/org/private-repo.git

# confirm github username and token
set -e

echo "Number of arguments: $#"
if [ $# -lt 1 ]; then
  echo "Usage: $0 <command> [arguments...]"
  exit 1
fi

# Build the command array to preserve argument structure
CMD_STR=""
for arg in "$@"; do
  # Properly escape each argument
  CMD_STR="$CMD_STR \"${arg//\"/\\\"}\""
done

# Create the command to run as the other user
if [ -n "$GITHUB_USERNAME" ] && [ -n "$GITHUB_TOKEN" ]; then
  # If GITHUB_TOKEN is set, run with git credential helper
  /bin/bash -c "
  # Save original Git config if it exists
  ORIGINAL_HELPER=\$(git config --global credential.helper 2>/dev/null || echo '')
  # Set up temporary Git credential helper
  git config --global credential.helper '!f() { 
    echo username=\"\$GITHUB_USERNAME\"
    echo password=\"\$GITHUB_TOKEN\"
  }; f'
  # Make sure we restore the config on exit, regardless of success or failure
  trap 'echo \"Cleaning up Git credentials...\"; 
        if [ -n \"\$ORIGINAL_HELPER\" ]; then 
          git config --global credential.helper \"\$ORIGINAL_HELPER\"
        else 
          git config --global --unset credential.helper
        fi' EXIT
  # Export GITHUB_USERNAME and GITHUB_TOKEN so it's available to subprocesses
  export GITHUB_USERNAME=\"$GITHUB_USERNAME\"
  export GITHUB_TOKEN=\"$GITHUB_TOKEN\"
  # Run the user's command with all the provided arguments
  echo \"Running command: $CMD_STR\"
  $CMD_STR
  "
else
  # If GITHUB_TOKEN is not set, just run the command as the user
  echo "GITHUB_USERNAME or GITHUB_TOKEN not set, running command without git credential helper"
  /bin/bash -c "
  echo \"Running command: $CMD_STR\"
  $CMD_STR
  "
fi
