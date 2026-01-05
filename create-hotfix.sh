#!/bin/bash

# Script to create a hotfix branch with stashed changes
# Usage: ./create-hotfix.sh <hotfix-branch-name>

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}➜ $1${NC}"
}

# Function to check if there are uncommitted changes
check_uncommitted_changes() {
    if [[ -n $(git status -s) ]]; then
        return 0  # Has changes
    else
        return 1  # No changes
    fi
}

# Function to check if branch exists
branch_exists() {
    git show-ref --verify --quiet refs/heads/$1
}

# Check if branch name is provided
if [ -z "$1" ]; then
    print_error "Please provide a hotfix branch name"
    echo "Usage: ./create-hotfix.sh <hotfix-branch-name>"
    exit 1
fi

HOTFIX_BRANCH="$1"

# Check if we have uncommitted changes to stash
HAS_CHANGES=false
if check_uncommitted_changes; then
    HAS_CHANGES=true
    print_info "Detected uncommitted changes"
    git status -s
    echo ""
fi

# Confirm action
print_info "This will:"
echo "  1. Stash current changes (if any)"
echo "  2. Fetch latest changes from remote"
echo "  3. Update master and develop branches"
echo "  4. Create hotfix branch '$HOTFIX_BRANCH' from master"
echo "  5. Apply stashed changes (if any)"
echo "  6. Push branch to remote"
echo ""
read -p "Do you want to continue? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "Aborted by user"
    exit 1
fi

# Step 1: Stash changes if any
if [ "$HAS_CHANGES" = true ]; then
    print_info "Stashing current changes..."
    git stash push -m "Temp stash for hotfix: $HOTFIX_BRANCH"
    print_success "Changes stashed"
fi

# Step 2: Fetch from remote
print_info "Fetching from remote..."
git fetch origin
print_success "Fetched from remote"

# Step 3: Update master branch
print_info "Checking out master..."
git checkout master

print_info "Pulling latest master..."
if [ $(git rev-list HEAD...origin/master --count) -gt 0 ]; then
    git pull origin master
    print_success "Master updated"
else
    print_success "Master is already up to date"
fi

# Step 4: Update develop branch
print_info "Checking out develop..."
if branch_exists develop; then
    git checkout develop
else
    print_info "Branch 'develop' does not exist locally. Creating from remote..."
    git checkout -b develop origin/develop
fi

print_info "Pulling latest develop..."
if [ $(git rev-list HEAD...origin/develop --count) -gt 0 ]; then
    git pull origin develop
    print_success "Develop updated"
else
    print_success "Develop is already up to date"
fi

# Step 5: Create hotfix branch from master
print_info "Creating hotfix branch: $HOTFIX_BRANCH from master..."
git checkout master
git checkout -b "$HOTFIX_BRANCH"
print_success "Created branch $HOTFIX_BRANCH"

# Step 6: Apply stashed changes if any
if [ "$HAS_CHANGES" = true ]; then
    print_info "Applying stashed changes..."
    if git stash pop; then
        print_success "Changes applied"
    else
        print_error "Failed to apply stashed changes"
        print_error "Please resolve conflicts manually"
        exit 1
    fi
fi

# Step 7: Push branch to remote
print_info "Pushing branch to remote..."
git push -u origin "$HOTFIX_BRANCH"
print_success "Pushed branch to remote"

echo ""
print_success "Hotfix branch '$HOTFIX_BRANCH' created and pushed successfully!"
if [ "$HAS_CHANGES" = true ]; then
    print_info "Your changes have been applied but not committed"
    print_info "Review your changes and commit them manually"
fi
print_info "Current branch: $(git rev-parse --abbrev-ref HEAD)"
