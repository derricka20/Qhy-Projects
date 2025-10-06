#!/bin/bash
# QhySync Branch & Repo Setup Script
# Derrick Adkison / Kumplex Media Group

# Config
REPO_NAME="Qhy-Projects"
REMOTE_NAME="origin"
MAIN_BRANCH="main"

# Feature branches to create by default
BRANCHES=(
  "develop"
  "feature/repo-template"
  "feature/docs-update"
  "feature/workflows"
  "feature/tests-setup"
  "hotfix/bugfix"
  "release/v1.0.0"
)

# Ensure git repo initialized
if [ ! -d ".git" ]; then
  git init
  git remote add $REMOTE_NAME git@github.com:USERNAME/$REPO_NAME.git
fi

# Ensure main branch exists
git checkout -B $MAIN_BRANCH

# Commit initial files if none exist
if [ -z "$(git status --porcelain)" ]; then
  git add .
  git commit -m "initial: setup QhySync starter repo structure and README"
fi

# Create and push branches
for BRANCH in "${BRANCHES[@]}"; do
  git checkout -B $BRANCH $MAIN_BRANCH
  git push -u $REMOTE_NAME $BRANCH
done

# Setup feature/repo-template branch with repo-template.json
git checkout -B "feature/repo-template" $MAIN_BRANCH
git add .github/config/repo-template.json
git commit -m "repo-template: add JSON-based starter template for QhySync projects with folders, files, and placeholders"
git push -u $REMOTE_NAME "feature/repo-template"

# Return to main branch
git checkout $MAIN_BRANCH

echo "Branches created and pushed successfully:"
git branch -v