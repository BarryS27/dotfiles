# ⚡ BarryS27's Dotfiles

Welcome to my personal dotfiles repository! This collection of configurations and scripts is designed to maximize terminal performance, automate repetitive development tasks, and maintain a seamless workflow across macOS, Linux, and GitHub Codespaces.

## ✨ Key Features

* **Zero-Friction Installation:** A robust, single-command install script that automatically backs up existing configurations before linking new ones.
* **Blazing Fast Bash Prompt:** Highly optimized `.bashrc` with a custom Git prompt built without spawning expensive subshells.
* **Automated Git Syncing:** The custom `save` command handles stashing, rebasing, committing, and optional pushing in one fluid motion.
* **Global Knowledge Base Search (`note`):** A custom CLI tool to instantly search and open Markdown files from my `Nexus.me` knowledge base, directly into VS Code, from anywhere in the terminal.
* **Streamlined NPM Publishing:** A dedicated script to automate NPM authentication checks, Git status verification, version bumping, and publishing.

## 📦 Installation

To install these dotfiles on a new machine, simply clone the repository and run the install script. It is safe to run multiple times, as it includes an automatic backup mechanism for your existing files.

```bash
git clone [https://github.com/BarryS27/dotfiles.git](https://github.com/BarryS27/dotfiles.git) ~/dotfiles
cd ~/dotfiles
./install.sh
source ~/.bashrc
```

**What the install script does:**
1. Creates a timestamped backup of existing configs in `~/.dotfiles_backup/`.
2. Symlinks `.bashrc`, `.gitconfig`, and `.gitignore_global` to your home directory.
3. Configures cross-platform settings (macOS/Linux).
4. Automatically injects optimized workspace settings if running inside a GitHub Codespace.

## 📂 Repository Structure

```text
~/dotfiles
├── .bashrc                 # Optimized shell configuration, aliases, and functions
├── install.sh              # Master setup script with backup logic
├── bin/                    # Custom workflow scripts (Add this to your $PATH)
│   ├── note.sh             # Global search tool for Nexus.me
│   └── npm-publish.sh      # Automated NPM package publisher
└── git/
    ├── .gitconfig          # Git user config and power aliases (st, co, cm, last)
    └── .gitignore_global   # Global ignores (macOS, VS Code, Logs)
```

## 🛠️ Power Tools & Workflows

### 1. `save` - The Ultimate Git Workflow
A Bash function built into `.bashrc` that replaces the tedious `git add`, `git commit`, `git pull`, and `git push` sequence with a single command, complete with conflict safety.

* **Usage:** `save [commit_message] [--push]`
* **Example:** `save "update styling" --push`
* [cite_start]**How it works:** It automatically stashes dirty changes, pulls remote updates with rebase, applies the stash, commits the changes, and optionally pushes to the remote[cite: 3].

### 2. `note` - Instant Knowledge Retrieval
A globally executable search script that scans my Docsify repository (`Me.archive` / `Nexus.me`) and offers a quick VS Code launch option.

* **Usage:** `note <search_term> [optional_subfolder]`
* **Example 1 (Global):** `note 'elasticity'`
* **Example 2 (Scoped):** `note 'monopoly' ap-microecon`
* **Features:** Skips heavy directories (like `node_modules`) for speed and strips terminal color codes to safely open the exact file path in Visual Studio Code.

### 3. `npm-publish.sh` - Safe Package Releases
Located in `bin/`, this script ensures I never accidentally publish a broken or dirty NPM package.

* **Usage:** `./bin/npm-publish.sh`
* **How it works:** 1. Verifies NPM authentication.
    2. Checks for a clean Git working directory.
    3. Prompts for version bump (patch/minor/major).
    4. Automatically pushes tags to GitHub and publishes to the NPM registry.

---

## 👤 Author
**Bairu Song (BarryS27)** - *Data Science & Business | Web Developer*
