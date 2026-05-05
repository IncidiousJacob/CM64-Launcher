#!/bin/bash
# This script is called when checking for updates in a build
# If you don't know what that means, don't edit it!

FULL_BUILD_PATH="${BUILD_TARGET_DIR}/${BUILD_NAME}"

if [ ! -d "$FULL_BUILD_PATH/.git" ]; then
    echo "Error: Not a git repository at $FULL_BUILD_PATH"
    exit 128
fi

cd "$FULL_BUILD_PATH" || exit 128

echo "Checking for updates in $FULL_BUILD_PATH [Branch: ${BUILD_BRANCH_NAME}]..."

# Fetch updates
git fetch origin "${BUILD_BRANCH_NAME}" --depth=1 || exit 129

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse FETCH_HEAD)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "Update found! Syncing to latest commit..."
    # Force sync to remote state to avoid merge mess
    if git reset --hard FETCH_HEAD; then
        # Handle submodules if they exist
        if [ -f ".gitmodules" ]; then
            echo "Updating submodules..."
            git submodule update --init --recursive --depth=1
        fi
        exit 0
    else
        echo "Error: git reset failed."
        exit 130
    fi
else
    echo "Already up to date."
    exit 1
fi
