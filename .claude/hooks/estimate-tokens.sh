#!/bin/bash
# estimate-tokens.sh - Get real token usage from transcript
#
# This script reads the transcript JSONL file and extracts actual token counts
# from the usage data that Claude Code embeds in each message.
#
# Usage:
#   ./estimate-tokens.sh                    # Auto-detect current session
#   ./estimate-tokens.sh /path/to/transcript.jsonl  # Specific transcript
#
# Output: JSON with token counts and context percentage

set -e

# Configuration
MAX_CONTEXT_TOKENS=200000  # Claude's context window

# Find the transcript file
find_transcript() {
    local project_dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"
    local claude_projects_dir="$HOME/.claude/projects"

    # Claude Code normalizes project paths:
    # - Replaces / with -
    # - Replaces _ with - (and other special chars)
    # So /Users/foo/my_project becomes -Users-foo-my-project

    # Try exact conversion first
    local project_name=$(echo "$project_dir" | sed 's/\//-/g')
    local project_folder="$claude_projects_dir/$project_name"

    # If not found, try with underscores converted to hyphens
    if [ ! -d "$project_folder" ]; then
        project_name=$(echo "$project_dir" | sed 's/\//-/g' | sed 's/_/-/g')
        project_folder="$claude_projects_dir/$project_name"
    fi

    # If still not found, search for a folder containing the project basename
    if [ ! -d "$project_folder" ]; then
        local basename=$(basename "$project_dir" | sed 's/_/-/g')
        project_folder=$(find "$claude_projects_dir" -maxdepth 1 -type d -name "*$basename*" 2>/dev/null | head -1)
    fi

    if [ -z "$project_folder" ] || [ ! -d "$project_folder" ]; then
        echo "Error: Project folder not found for: $project_dir" >&2
        return 1
    fi

    # Find the most recent non-agent transcript (main conversation)
    # Agent transcripts start with "agent-", main session transcripts are UUIDs
    local transcript=$(ls -t "$project_folder"/*.jsonl 2>/dev/null | grep -v '/agent-' | head -1)

    if [ -z "$transcript" ] || [ ! -f "$transcript" ]; then
        echo "Error: No transcript found in $project_folder" >&2
        return 1
    fi

    echo "$transcript"
}

# Extract token usage from transcript
get_token_usage() {
    local transcript="$1"

    if [ ! -f "$transcript" ]; then
        echo "Error: Transcript file not found: $transcript" >&2
        return 1
    fi

    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed" >&2
        return 1
    fi

    # Get the LAST message with usage data (most recent = current context size)
    # The context window at any point = input_tokens + cache_creation_input_tokens + cache_read_input_tokens
    local usage=$(cat "$transcript" | jq -s '
        [.[] | select(.message.usage != null)] |
        if length == 0 then
            {
                "current_context": 0,
                "input_tokens": 0,
                "output_tokens": 0,
                "cache_creation": 0,
                "cache_read": 0,
                "message_count": 0,
                "has_data": false
            }
        else
            (last | .message.usage) as $last |
            {
                "current_context": (($last.input_tokens // 0) + ($last.cache_creation_input_tokens // 0) + ($last.cache_read_input_tokens // 0)),
                "input_tokens": ($last.input_tokens // 0),
                "output_tokens": ($last.output_tokens // 0),
                "cache_creation": ($last.cache_creation_input_tokens // 0),
                "cache_read": ($last.cache_read_input_tokens // 0),
                "message_count": length,
                "has_data": true
            }
        end
    ' 2>/dev/null)

    if [ -z "$usage" ]; then
        echo '{"error": "Failed to parse transcript", "has_data": false}'
        return 1
    fi

    echo "$usage"
}

# Calculate percentage and status
calculate_status() {
    local usage="$1"
    local current_context=$(echo "$usage" | jq -r '.current_context')
    local has_data=$(echo "$usage" | jq -r '.has_data')

    if [ "$has_data" != "true" ]; then
        echo "$usage" | jq '. + {"percentage": 0, "status": "unknown", "status_emoji": "❓"}'
        return
    fi

    local percentage=$((current_context * 100 / MAX_CONTEXT_TOKENS))
    local status=""
    local status_emoji=""

    if [ "$percentage" -lt 25 ]; then
        status="healthy"
        status_emoji="✅"
    elif [ "$percentage" -lt 50 ]; then
        status="good"
        status_emoji="✅"
    elif [ "$percentage" -lt 70 ]; then
        status="moderate"
        status_emoji="⚠️"
    elif [ "$percentage" -lt 85 ]; then
        status="high"
        status_emoji="⚠️"
    else
        status="critical"
        status_emoji="🚨"
    fi

    echo "$usage" | jq --argjson pct "$percentage" --arg status "$status" --arg emoji "$status_emoji" \
        '. + {"percentage": $pct, "status": $status, "status_emoji": $emoji, "max_tokens": '"$MAX_CONTEXT_TOKENS"'}'
}

# Format output for human reading
format_human() {
    local result="$1"

    local percentage=$(echo "$result" | jq -r '.percentage')
    local status=$(echo "$result" | jq -r '.status')
    local status_emoji=$(echo "$result" | jq -r '.status_emoji')
    local current=$(echo "$result" | jq -r '.current_context')
    local messages=$(echo "$result" | jq -r '.message_count')
    local has_data=$(echo "$result" | jq -r '.has_data')

    if [ "$has_data" != "true" ]; then
        echo "❓ No token data available yet (need at least one response)"
        return
    fi

    # Format numbers with K suffix
    local current_k=$(echo "scale=1; $current / 1000" | bc)
    local max_k=$((MAX_CONTEXT_TOKENS / 1000))

    echo "$status_emoji Context: ${current_k}K / ${max_k}K tokens (~${percentage}%) - Status: $status"
    echo "   Messages with usage data: $messages"
}

# Main execution
main() {
    local transcript=""
    local output_format="${2:-human}"  # human or json

    # Get transcript path
    if [ -n "$1" ] && [ "$1" != "--json" ] && [ "$1" != "--human" ]; then
        transcript="$1"
    else
        transcript=$(find_transcript) || exit 1
        # Check if first arg is format flag
        if [ "$1" = "--json" ]; then
            output_format="json"
        fi
    fi

    # Get usage data
    local usage=$(get_token_usage "$transcript") || exit 1

    # Calculate status
    local result=$(calculate_status "$usage")

    # Output
    if [ "$output_format" = "json" ]; then
        echo "$result" | jq '.'
    else
        format_human "$result"
    fi
}

main "$@"
