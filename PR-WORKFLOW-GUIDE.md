# Pull Request Workflow Guide

Your project now has a **professional CI/CD workflow** with separate stages for testing and deployment!

---

## 🎯 How It Works

```
Feature Branch → CI Tests → Pull Request → Code Review → Merge to Main → CD Deploys
```

---

## 📋 Two Workflows

### **1. CI Workflow** (`.github/workflows/ci.yml`)
**Triggers:** 
- When you push to any branch (except main)
- When you create/update a Pull Request

**What it does:**
- ✅ Installs dependencies
- ✅ Runs linter
- ✅ Builds the application
- ✅ Builds Docker image (test only)
- ❌ Does NOT deploy

**Purpose:** Catch errors before merging to production

---

### **2. CD Workflow** (`.github/workflows/deploy-no-registry.yml`)
**Triggers:** 
- ONLY when code is pushed/merged to `main` branch

**What it does:**
- ✅ Connects to EC2
- ✅ Pulls latest code
- ✅ Builds Docker image
- ✅ Deploys to production

**Purpose:** Deploy to production only after approval

---

## 🚀 Daily Development Workflow

### **Step 1: Create Feature Branch**

```bash
# Make sure you're on main
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name

# Examples:
# git checkout -b feature/add-priority-levels
# git checkout -b fix/dark-mode-bug
# git checkout -b improve/search-functionality
```

---

### **Step 2: Make Your Changes**

```bash
# Edit your files
code Frontend/src/App.tsx

# Test locally
cd Frontend
npm run dev

# Test Docker build (optional)
docker-compose up -d
```

---

### **Step 3: Commit and Push**

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "Add task priority feature"

# Push to YOUR feature branch
git push origin feature/your-feature-name
```

---

### **Step 4: CI Runs Automatically**

- GitHub automatically runs CI workflow
- Go to: GitHub → Actions tab
- See "CI - Build and Test" running
- Wait for green checkmark ✅

**If CI fails:** 
- Click on failed workflow to see errors
- Fix the issues
- Push again: `git push`
- CI runs again automatically

---

### **Step 5: Create Pull Request**

**On GitHub:**

1. You'll see: **"Compare & pull request"** button → Click it
2. Fill in PR details:
   - **Title:** Brief description (e.g., "Add task priority feature")
   - **Description:** What changed and why
3. Check: CI status shows ✅ (must pass before merge)
4. Click **"Create pull request"**

---

### **Step 6: Review and Merge**

**Review phase:**
- CI must pass ✅
- (Optional) Team reviews code
- (Optional) Test on staging environment

**When ready to deploy:**

1. Click **"Merge pull request"**
2. Click **"Confirm merge"**
3. Delete the feature branch (optional but clean)

**What happens:**
- ✅ Code merges to `main`
- ✅ CD workflow triggers automatically
- ✅ Deploys to EC2
- ✅ Your changes are LIVE!

---

### **Step 7: Clean Up**

```bash
# Switch back to main
git checkout main

# Pull latest (includes your merged changes)
git pull origin main

# Delete local feature branch (optional)
git branch -d feature/your-feature-name
```

---

## 🛡️ Branch Protection (Recommended)

Protect your `main` branch to enforce the workflow:

### **Setup:**

1. Go to: `https://github.com/YOUR_USERNAME/CI_CD_Pipeline/settings/branches`
2. Click **"Add rule"**
3. Branch name pattern: `main`
4. Enable:
   - ✅ **Require a pull request before merging**
   - ✅ **Require status checks to pass before merging**
   - Select: `build-and-test` (CI check)
   - ✅ **Require branches to be up to date before merging**

5. Click **"Create"**

**Result:** 
- ❌ Can't push directly to main
- ✅ Must use Pull Requests
- ✅ CI must pass before merge
- ✅ Production is protected!

---

## 📊 Workflow Examples

### **Example 1: Adding a New Feature**

```bash
# Day 1: Start work
git checkout -b feature/add-task-tags
# ... make changes ...
git push origin feature/add-task-tags
# CI runs → ✅ Passed

# Day 2: Continue work
# ... more changes ...
git push origin feature/add-task-tags
# CI runs again → ✅ Passed

# Day 3: Ready to deploy
# Create PR on GitHub
# Review → Looks good!
# Merge PR → CD deploys to production!
```

---

### **Example 2: Quick Bug Fix**

```bash
# Oh no! Bug in production!
git checkout -b fix/button-color-bug

# Fix the bug
# ... edit code ...

git add .
git commit -m "Fix button color in dark mode"
git push origin fix/button-color-bug

# CI runs → ✅ Passed

# Create PR immediately
# Merge quickly
# CD deploys the fix!
```

---

### **Example 3: Experimenting**

```bash
# Try something new
git checkout -b experiment/new-ui-layout

# Make experimental changes
# ... edit code ...

git push origin experiment/new-ui-layout

# CI runs → ❌ Failed (build error)

# Fix issues
git push origin experiment/new-ui-layout

# CI runs → ✅ Passed

# Create PR
# Team reviews: "Not ready yet"
# Continue working on the branch
# Don't merge → Production stays safe!
```

---

## 🎓 Best Practices

### **Branch Naming:**
- `feature/` - New features (e.g., `feature/add-notifications`)
- `fix/` - Bug fixes (e.g., `fix/login-error`)
- `improve/` - Improvements (e.g., `improve/performance`)
- `refactor/` - Code refactoring (e.g., `refactor/api-structure`)

### **Commit Messages:**
- Be descriptive: ✅ "Add task priority dropdown"
- Not vague: ❌ "Updates"
- Present tense: ✅ "Fix bug" not "Fixed bug"

### **Pull Request Tips:**
- Keep PRs small (easier to review)
- One feature per PR
- Include description of changes
- Reference issues if applicable

### **Before Merging:**
- ✅ CI must be green
- ✅ Test locally
- ✅ Review your own changes
- ✅ Make sure you're merging to correct branch

---

## 🚨 Common Mistakes

### ❌ **Pushing directly to main**
```bash
git checkout main
git push origin main  # This will deploy immediately!
```
**Solution:** Use branch protection rules

---

### ❌ **Merging without CI passing**
- Never merge if CI shows ❌
- Fix issues first, then merge

---

### ❌ **Not pulling latest main**
```bash
# Before creating new branch, always:
git checkout main
git pull origin main
git checkout -b feature/new-feature
```

---

## 🎯 Quick Reference

```bash
# Start new work
git checkout main
git pull
git checkout -b feature/my-feature

# Make changes and test
# ... edit files ...
npm run dev

# Push and create PR
git add .
git commit -m "Description"
git push origin feature/my-feature
# Go to GitHub → Create PR

# After merge
git checkout main
git pull
```

---

## 📈 Benefits You Get

### **Safety:**
- ✅ No accidental deployments
- ✅ Code reviewed before production
- ✅ CI catches errors early

### **Quality:**
- ✅ Consistent code quality
- ✅ Automated testing
- ✅ Build verification

### **Collaboration:**
- ✅ Team can review code
- ✅ Discuss changes in PR
- ✅ Track what was deployed

### **Professional:**
- ✅ Industry standard workflow
- ✅ Portfolio-ready setup
- ✅ Shows DevOps knowledge

---

## 🎉 You Now Have:

✅ Professional CI/CD pipeline  
✅ Separate test and deploy stages  
✅ Pull Request workflow  
✅ Protected production branch  
✅ Automated quality checks  
✅ Safe deployment process  

**This is how real companies work!** 🚀

---

## 📚 Next Steps

1. **Practice:** Create a feature branch and go through the workflow
2. **Enable branch protection** (see above)
3. **Try breaking something** on a feature branch (see how CI catches it)
4. **Add tests** to your CI workflow later
5. **Add staging environment** for even more safety

---

*Need help? Check the [GitHub Flow documentation](https://guides.github.com/introduction/flow/)*

