# Omni Script Help

The `omni.ps1` script is a PowerShell tool for managing directory aliases and performing actions like opening files, searching content, or running commands in those directories.

## Usage

### Register an Alias
To associate a directory with an alias:
```powershell
.\omni.ps1 -a <alias> -d <destination>
```
- `-a <alias>`: The alias name to create or update.
- `-d <destination>`: The full path to the directory.

If the alias already exists, it will be updated with the new destination.

### Navigate and Perform Actions
To navigate to a directory using an alias and optionally perform an action:
```powershell
.\omni.ps1 <alias> [-switch] [extras]
```
- `<alias>`: The alias for the directory (required, positional).
- `[-switch]`: An optional switch to specify the action (e.g., `-e`, `-n`).
- `[extras]`: Additional arguments for certain actions (e.g., a file name for `-f`).

### Available Switches
- `-e`: Open the directory in Windows Explorer.
- `-n`: Open the directory in Neovim (`nvim`).
- `-c`: Copy the current directory path to the clipboard.
- `-searchContent <query>`: Search file contents using `rg` and `fzf`.
- `-searchFiles <query>`: Search filenames using `es` and `fzf`.
- `-f <file>`: Open a specific file in Neovim.
- `-r <command>`: Run a custom command in the directory.

**Note**: Only one switch can be used at a time. If no switch is provided, a command prompt (`cmd.exe`) opens in the directory.

### Additional Options
- `-Subdir <path>`: Navigate to a subdirectory within the alias destination.
- `-Help`: Display this help file.

### Examples
- Register an alias:
  ```powershell
  .\omni.ps1 -a proj -d C:\Projects\MyProject
  ```
- Open in Explorer:
  ```powershell
  .\omni.ps1 proj -e
  ```
- Open a file in Neovim:
  ```powershell
  .\omni.ps1 proj -f readme.md
  ```
- Search file contents:
  ```powershell
  .\omni.ps1 proj -searchContent "function"
  ```
- Navigate to a subdirectory and open in Neovim:
  ```powershell
  .\omni.ps1 proj -Subdir src -n
  ```

### Requirements
- **Tools**: `nvim`, `rg` (ripgrep), and `fzf` must be installed and available in your PATH.
- **Platform**: Some features (e.g., `explorer.exe`) are Windows-specific. A warning will appear on non-Windows platforms.

### Notes
- Aliases are stored in `aliases.txt` in the script’s directory.
- If a destination directory doesn’t exist, it will be created automatically.
- Use `-searchContent` and `-searchFiles` with `enter` to open in Neovim or `ctrl-e` for Explorer/start.
