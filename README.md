# Omni Smart Navigation

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

Omni is a PowerShell script designed to simplify folder navigation and file management on Windows. It allows users to quickly change directories using aliases, open files in Neovim (Nvim), search for content or files, and perform other actions with ease.

## Features

- **Alias Management:** Register and use aliases for quick navigation to frequently used directories.
- **Folder Navigation:** Change to a specified destination folder or alias, creating it if it doesn’t exist.
- **File Explorer Integration:** Open the destination folder in Windows Explorer.
- **Neovim Integration:** Open files or folders in Neovim for editing.
- **Search Functionality:** Search for content or files within the destination folder using `ripgrep` and `fzf`.
- **Error Handling:** Suggest close alias matches if an exact match isn’t found.
- **Pause for User Input:** Wait for user acknowledgment before exiting after errors.

## Installation

### Prerequisites

- Windows operating system.
- [Scoop](https://scoop.sh/): The script can be installed via a Scoop bucket for easier management.

### Installation via Scoop

A Scoop manifest is available in the [bucket repository](https://github.com/sadirano/bucket.git). To install Omni, run the following commands:

```bash
scoop bucket add sadirano https://github.com/sadirano/bucket.git
scoop install omni
```

## Usage

### Basic Usage

To navigate to a directory using an alias and optionally perform an action:

```powershell
omni.ps1 <alias> [-switch] [extras]
```

- `<alias>`: The alias for the directory (required, positional).
- `[-switch]`: An optional switch to specify the action (e.g., `-e`, `-n`).
- `[extras]`: Additional arguments for certain actions (e.g., a file name for `-f`).

### Register an Alias

To associate a directory with an alias:

```powershell
omni.ps1 -a <alias> -d <destination>
```

- `-a <alias>`: The alias name to create or update.
- `-d <destination>`: The full path to the directory.

If the alias already exists, it will be updated with the new destination.

### Available Switches

- `-e`: Open the directory in Windows Explorer.
- `-n`: Open the directory in Neovim (`nvim`).
- `-c`: Copy the current directory path to the clipboard.
- `-searchContent <query>`: Search file contents using `rg` and `fzf`.
- `-searchFiles <query>`: Search filenames using `es` and `fzf`.
- `-f <file>`: Open a specific file in Neovim.
- `-r <command>`: Run a custom command in the directory.

**Note**: Only one switch can be used at a time. If no switch is provided, a command prompt (`cmd.exe`) opens in the directory.

### Examples

- Register an alias:
  ```powershell
  omni.ps1 -a proj -d C:\Projects\MyProject
  ```

- Open in Explorer:
  ```powershell
  omni.ps1 proj -e
  ```

- Open a file in Neovim:
  ```powershell
  omni.ps1 proj -f readme.md
  ```

- Search file contents:
  ```powershell
  omni.ps1 proj -searchContent "function"
  ```

- Navigate to a subdirectory and open in Neovim:
  ```powershell
  omni.ps1 proj -s src -n
  ```

## Requirements

- Windows operating system.
- PowerShell 5.1 or later.
- Neovim (`nvim`) installed and accessible from the command line.
- `ripgrep` and `fzf` installed for search functionality.
- `es` command-line tool for file searching (optional).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
