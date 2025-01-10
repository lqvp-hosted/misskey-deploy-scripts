#!/bin/bash

set -euo pipefail

source ./scripts/config.sh

readonly REPO_DIR="/home/misskey/misskey-temp"
readonly LOG_DIR="./logs/misskey-temp"
readonly LOG_FILE="$LOG_DIR/misskey-deploy.log"
readonly DISCORD_WEBHOOK_URL="YOUR_DISCORD_WEBHOOK_URL"
readonly REPO_URL="https://github.com/lqvp/misskey-temp"
readonly BRANCH="master"

mkdir -p "$LOG_DIR"

source ./scripts/deploy_functions.sh
deploy "$BRANCH"