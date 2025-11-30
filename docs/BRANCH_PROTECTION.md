# Branch Protection Rules Setup Guide

This guide will help you set up branch protection rules for the Spark DevOps project to ensure code quality and prevent accidental merges.

## Setting Up Branch Protection Rules

### Step 1: Navigate to Repository Settings

1. Go to your GitHub repository: `https://github.com/daniahsn/SparkDevOps`
2. Click on **Settings** (top navigation bar)
3. In the left sidebar, click on **Branches**

### Step 2: Add Branch Protection Rule

1. Under **Branch protection rules**, click **Add rule** or **Add branch protection rule**
2. In the **Branch name pattern** field, enter: `main`
3. Configure the following settings:

#### Required Settings:

✅ **Require a pull request before merging**
   - Check: "Require approvals" (set to 1)
   - Check: "Dismiss stale pull request approvals when new commits are pushed"

✅ **Require status checks to pass before merging**
   - Check: "Require branches to be up to date before merging"
   - Under "Status checks that are required", select:
     - `lint` (Lint Code)
     - `test` (Run Tests)
     - `build` (Build Docker Image)
     - `docker-compose` (Test Docker Compose)

✅ **Require conversation resolution before merging**
   - Check this box to ensure all comments are addressed

#### Recommended Additional Settings:

✅ **Do not allow bypassing the above settings**
   - Prevents even admins from bypassing rules

✅ **Include administrators**
   - Ensures even repo admins follow the rules

✅ **Restrict who can push to matching branches**
   - Optional: Only allow specific teams/people to push directly

### Step 3: Save the Rule

1. Click **Create** or **Save changes**
2. The rule is now active for the `main` branch

### Step 4: Optional - Protect `develop` Branch

Repeat the same process for the `develop` branch if you use it:

1. Add another branch protection rule
2. Branch name pattern: `develop`
3. Use the same settings as above

## What This Means

With branch protection enabled:

- ✅ All code must go through pull requests
- ✅ CI/CD pipeline must pass before merging
- ✅ At least one approval required
- ✅ No direct pushes to `main` (must use PRs)
- ✅ All conversations must be resolved

## Workflow

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Make changes and commit
3. Push to GitHub: `git push origin feature/my-feature`
4. Create a Pull Request on GitHub
5. CI/CD pipeline runs automatically
6. Wait for all checks to pass (lint, test, build, docker-compose)
7. Get code review approval
8. Merge the PR (only after all checks pass)

## Troubleshooting

### If CI checks are failing:
- Check the Actions tab to see what failed
- Fix the issues locally
- Push new commits to the PR branch
- CI will re-run automatically

### If you need to bypass (not recommended):
- Only possible if "Do not allow bypassing" is unchecked
- Only for admins
- Use sparingly for hotfixes only

## Verification

After setting up, test it:

1. Try to push directly to `main`: `git push origin main`
2. You should see an error (if protection is working)
3. Create a PR instead - it should require CI to pass

