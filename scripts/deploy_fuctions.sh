#!/bin/bash

log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >>"$LOG_FILE"
}

info() { log "INFO" "$1"; }
error() { log "ERROR" "$1"; }
warn() { log "WARN" "$1"; }

send_discord_notification() {
    local status="$1"
    local message="$2"
    local color="$3"
    local details="${4:-}"
    local max_retries=3
    local retry_delay=5

    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local payload
    if [[ -n "$details" ]]; then
        payload=$(jq -n \
            --arg title "Deployment Notification" \
            --arg desc "$status $message" \
            --arg color "$color" \
            --arg timestamp "$timestamp" \
            --arg details "$details" \
            '{
                embeds: [{
                    title: $title,
                    description: $desc,
                    color: ($color | tonumber),
                    timestamp: $timestamp,
                    fields: [{
                        name: "Details",
                        value: $details,
                        inline: false
                    }]
                }]
            }')
    else
        payload=$(jq -n \
            --arg title "Deployment Notification" \
            --arg desc "$status $message" \
            --arg color "$color" \
            --arg timestamp "$timestamp" \
            '{
                embeds: [{
                    title: $title,
                    description: $desc,
                    color: ($color | tonumber),
                    timestamp: $timestamp
                }]
            }')
    fi

    local attempt=1
    while ((attempt <= max_retries)); do
        local response
        response=$($CURL -H "Content-Type: application/json" \
            -d "$payload" \
            -w "%{http_code}" \
            -s -o /dev/null \
            "$DISCORD_WEBHOOK_URL")

        if [[ "$response" == "204" ]]; then
            info "Discord notification sent successfully"
            return 0
        fi

        warn "Discord notification failed (attempt $attempt/$max_retries) with status $response"
        ((attempt++))
        sleep "$retry_delay"
    done

    error "Failed to send Discord notification after $max_retries attempts"
    return 1
}

handle_error() {
    local error_message="$1"
    error "$error_message"
    send_discord_notification "$STATUS_ERROR" \
        "An error occurred" \
        "$DISCORD_COLOR_ERROR" \
        "**Error Details:**\n\`\`\`\n$error_message\n\`\`\`" || true
    exit 1
}

deploy() {
    local branch="$1"

    cd "$REPO_DIR" || handle_error "Repository directory not found: $REPO_DIR"

    info "Starting deployment process for branch: $branch"

    local current_hash
    current_hash=$($GIT rev-parse HEAD)

    info "Checking for updates on branch: $branch..."
    $GIT fetch origin "$branch"

    local remote_hash
    remote_hash=$($GIT rev-parse "origin/$branch")

    if [[ "$current_hash" == "$remote_hash" ]]; then
        info "No updates found"
        return 0
    fi

    local commit_message commit_author commit_link
    commit_message=$($GIT log --format=%B -n 1 "$remote_hash")
    commit_author=$($GIT log --format=%an -n 1 "$remote_hash")
    commit_link="${REPO_URL}/commit/${remote_hash}"

    local update_details="**Commit Info:**
🔗 [${remote_hash:0:7}]($commit_link)
👤 Author: $commit_author
📝 Message: $commit_message"

    send_discord_notification "$STATUS_WARNING" \
        "Updates detected" \
        "$DISCORD_COLOR_WARNING" \
        "$update_details"

    info "Pulling updates from branch: $branch..."
    $GIT pull origin "$branch"

    local deploy_details="**Deployment Info:**
🔗 [${remote_hash:0:7}]($commit_link) deployed successfully"

    send_discord_notification "$STATUS_SUCCESS" \
        "Deployment completed 🎉" \
        "$DISCORD_COLOR_SUCCESS" \
        "$deploy_details"
}
