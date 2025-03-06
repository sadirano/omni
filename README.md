# Omni Folder Navigation Utility

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

Omni is a Windows batch script designed to simplify folder navigation and file management. It allows users to quickly change directories, open files in Nvim, search for content or files, and more.

## Features

- **Folder Navigation:** Change to a specified destination folder, creating it if it doesn't exist.
- **File Explorer Integration:** Open the destination folder in the default file explorer.
- **Nvim Integration:** Open files or folders in Nvim for editing.
- **Search Functionality:** Search for content or files within the destination folder using `ripgrep` and `fzf`.
- **Start Menu Compatibility:** Handles special cases when launched from the Start Menu.

## Installation

### Prerequisites
- Windows operating system.
- [Scoop](https://scoop.sh/): The scripts can be installed via a Scoop bucket for easier management.

### Installation via Scoop

A Scoop manifest will be available in the [bucket repository](https://github.com/sadirano/bucket.git). Once added, you can install Noir Core Utility Scripts using:
```bash
scoop bucket add sadirano https://github.com/sadirano/bucket.git
scoop install omni
```

## Usage

### Basic Usage

```
omni %0 %~dpn0 destination [option]
```

- **%0:** Full path of the script.
- **%~dpn0:** Base name of the script.
- **destination:** Folder to navigate to.
- **[option]:** Optional argument that determines the action.

### Options

- **-s:** Open the destination folder in the default file explorer.
- **-n:** Open the destination folder in Nvim.
- **-c:** Copy the current directory path to the clipboard (not implemented in the provided script).
- **/** ``: Search for content and open files in Nvim.
- **\** ``: Search for files by name and path, open in Nvim or Explorer.
- **``:** Open a specific file in Nvim.

### Examples

```
omni %0 %~dpn0 myFolder
omni %0 %~dpn0 myFolder -s
omni %0 %~dpn0 myFolder -n
omni %0 %~dpn0 myFolder myfile.txt
omni %0 %~dpn0 myFolder / search_text
omni %0 %~dpn0 myFolder \ search_file_name
```

## Requirements

- Windows operating system.
- Nvim installed and accessible from the command line.
- `ripgrep` and `fzf` installed for search functionality.
- `es` command-line tool for file searching (optional).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
