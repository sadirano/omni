=======================================================
        Omni Folder Navigation Utility Help
=======================================================

USAGE:
  omni <script> <scriptBase> <destination> [option] [option_extras]

PARAMETERS:
  <script>       : Full path of the script (e.g., %~0).
  <scriptBase>   : Base name of the script (e.g., %~dpnx0).
  <destination>  : Folder to navigate to. This folder will be created if it does not already exist.
  [option]       : Optional argument that determines the action.
  [option_extras]: Optional argument to complement an option.

OPTIONS:
  -s    : Open the destination folder in the default file explorer.
          NOTE: When using -s, the script leaves the current directory set to the destination folder.
  -n    : Open the destination folder in Neovim (nvim).
          NOTE: When using -n, the script returns to the original directory after launching nvim.
  -c    : Copy the current directory path to the clipboard.
          NOTE: When using -c, the current directory remains set to the destination folder.
  / <text>
         : Search for the provided text in files within the destination folder.
         Allows the user to open the file in nvim interactively.
  \ <text>
         : Search for a file name and path in the destination folder.
         Allows opening the file in nvim or Explorer interactively.
  <filename>
         : Open the specified file in nvim (provided the file name does not begin with a dot).
         NOTE: The script returns to the original directory after launching nvim.

SPECIAL CASE:
  When launched from the Start Menu, the first parameter may equal the script base name 
  with a .cmd extension. In this case, a new command prompt window is opened.

EXAMPLES:
  omni dest
      - Change to the destination folder dest.

  omni dest -s
      - Open the dest folder in File Explorer.

  omni dest -n
      - Open the dest folder in Neovim.

  omni dest -c
      - Copy the dest folder path to the clipboard.

  omni dest myfile.txt
      - Open "myfile.txt" in the dest folder in Neovim.

  omni dest / sometext
      - Search for "sometext" in the designed folder.

  omni dest \ myfile
      - Search for "myfile" in the dest folder.

