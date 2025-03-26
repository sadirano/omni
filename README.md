# Omni Alias Navigation

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

**Omni** is a PowerShell script designed to simplify folder navigation and file management on Windows. It allows you to quickly change directories using aliases, open files for editing, search for content, and run custom commands—all with ease.

## Features

- **Alias Management:** Register and use aliases for quick navigation to frequently used directories.
- **Folder Navigation:** Change to a specified destination folder or alias, creating it if it doesn’t exist.
- **File Explorer Integration:** Open the destination folder in Windows Explorer.
- **Editor Integration:** Open files or folders in Editor for editing.
- **Search Functionality:** Search for content or files within the destination folder using `ripgrep` and `fzf`.
- **Error Handling:** Suggest close alias matches if an exact match isn’t found.
- **Pause for User Input:** Wait for user acknowledgment before exiting after errors.

## Command Summary

For convenience, Omni provides a set of `.cmd` wrappers that automatically pass specific switches to the base PowerShell script. Use these from the Command Prompt for quick actions:

| Command  | Action Description                                       | Example Usage              |
|----------|----------------------------------------------------------|----------------------------|
| **c**  | Run Omni with default behavior (opens a command prompt)  | `c proj`               |
| **f**  | Open a specific file in Editor                           | `f proj readme.md`     |
| **ff** | Search for filenames using `es` and `fzf`                | `ff proj "report"`     |
| **n**  | Open the directory in Editor                              | `n proj`               |
| **s**  | Open the directory in Windows Explorer                  | `s proj`               |
| **r**  | Run a custom command within the directory               | `r proj "dir /b"`      |
| **sg** | Search file contents using `ripgrep` and `fzf`           | `sg proj "function"`   |
| **sga** | Search file contents using `ripgrep-all` and `fzf`           | `sga proj "function"`   |
| **y**  | Copy the current directory path to the clipboard         | `y proj`               |

## Detailed Command Usage

### General PowerShell Usage

Run Omni using the PowerShell script as follows:

```powershell
.\omni.ps1 <alias> [-switch] [extras]
```

- `<alias>`: The directory alias (required).
- `[-switch]`: Optional flag to specify an action (for example, `-e` for Explorer or `-n` for Editor).
- `[extras]`: Additional parameters (e.g., a filename with `-f`).

### Available Switches

- `-e`: Open the directory in Windows Explorer.
- `-n`: Open the directory in Editor.
- `-c`: Copy the current directory path to the clipboard.
- `-searchContent <query>`: Search file contents using `rg` and `fzf`.
- `-searchFiles <query>`: Search filenames using `es` and `fzf`.
- `-f <file>`: Open a specific file in Editor.
- `-r <command>`: Run a custom command in the directory.

**Note**: Only one switch can be used at a time. If no switch is provided, a command prompt (`cmd.exe`) opens in the directory.


#### Examples:
- **Register an Alias:**

  ```powershell
  .\omni.ps1 -a proj -d C:\Projects\MyProject
  ```
##### If the alias already exists, it will be updated with the new destination.

- **Open in Explorer:**

  ```powershell
  .\omni.ps1 proj -e
  ```

- **Open a File in Editor:**

  ```powershell
  .\omni.ps1 proj -f readme.md
  ```

- **Search File Contents:**

  ```powershell
  .\omni.ps1 proj -sg "function"
  ```

- **Navigate to a Subdirectory and Open in Editor:**

  ```powershell
  .\omni.ps1 proj -Subdir src -n
  ```

### Using the .cmd Wrappers

For those who prefer using the Command Prompt, Omni provides these preconfigured wrappers:

- **c.cmd**  
  Runs `omni.ps1` with no additional switch.  
  _Example:_  
  ```cmd
  c.cmd proj
  ```

- **f.cmd**  
  Opens a specified file in Editor by appending the `-f` switch.  
  _Example:_  
  ```cmd
  f.cmd proj readme.md
  ```

- **ff.cmd**  
  Searches filenames using the `-ff` switch.  
  _Example:_  
  ```cmd
  ff.cmd proj "report"
  ```

- **n.cmd**  
  Opens the target directory in Editor (adds the `-n` switch).  
  _Example:_  
  ```cmd
  n.cmd proj
  ```

- **s.cmd**  
  Opens the directory in Windows Explorer (adds the `-e` switch).  
  _Example:_  
  ```cmd
  s.cmd proj
  ```

- **r.cmd**  
  Runs a custom command in the directory (adds the `-r` switch).  
  _Example:_  
  ```cmd
  r.cmd proj "dir /b"
  ```

- **sg.cmd**  
  Searches file contents using the `-sg` switch.  
  _Example:_  
  ```cmd
  sg.cmd proj "function"
  ```

- **y.cmd**  
  Copies the current directory path to the clipboard (adds the `-y` switch).  
  _Example:_  
  ```cmd
  y.cmd proj
  ```


## Installation

### Prerequisites

- Windows operating system.
- [Scoop](https://scoop.sh/): The script can be installed via a Scoop bucket for easier management.

### Installation via Scoop

A Scoop manifest is available in the [bucket repository](https://github.com/sadirano/bucket.git). To install Omni, run the following commands:

Full install:
```bash
scoop bucket add extras
scoop bucket add sadirano https://github.com/sadirano/bucket.git
scoop install omni
```

Core install: (Optional features won't work)
```bash
scoop bucket add sadirano https://github.com/sadirano/bucket.git
scoop install omni-min
```

## Requirements

- Windows operating system.
- PowerShell 7.5 or later.

## Optionals Requirements
- Neovim as Editor (`nvim`): Configure `$env:EDITOR = nvim`.
- `ripgrep` (`rg`), `fzf` and `bat` are required for search functionality.
    - rg is used for file contents search (initial filter).
    - fzf is used for fuzzy content search (interactive filter).
    - bat is used for previewing file contents.
- `ripgrep-all` (`rga`) is required for search functionality to search all files (pdf, docs, etc.).
    - used in place of rg when searching all files.
- The `es` command-line tool is optional for filename searches. (Everything must be running)

## Known limitations
- Network share is not supported in general.
- Network share must be mounted and properly configured for the `es` command to work on them.

## About

Omni streamlines directory navigation and file management, enabling rapid access via directory aliases and a suite of scriptable actions.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
