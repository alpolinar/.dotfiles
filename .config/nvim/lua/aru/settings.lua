local global = vim.g
local o = vim.opt

-- Editor options

o.number = true -- print the line number in front of each line
o.relativenumber = true -- show the line number relative to the line with the cursor in front of each line
o.clipboard = "unnamedplus" -- uses the clipboard register for all operations except yank
o.syntax = "on" -- when this option is set, the syntax with this name is loaded
o.autoindent = true -- copy indent from current line when starting a new line
o.cursorline = true -- highlight the screen line of the cursor with cursorline
o.expandtab = true -- in insert mode: use the appropriate number of spaces to insert a <Tab>
o.shiftwidth = 2 -- number of spaces to use for each step of (auto)indent
o.tabstop = 2 -- number of spaces that a <tab> in the file counts for
o.encoding = "UTF-8" --sets the character encoding used inside Vim
o.ruler = true -- show the line and column number of the cursor position, separated by a comma
o.mouse = "a" -- enable the use of the mouse. "a" you can use on all modes
o.title = true -- when on, the title of the window will be set to the value of 'titlestring'
o.hidden = true -- when on, a buffer becomes hidden when it is |abandon|ed
o.ttimeoutlen = 0 -- the time in milliseconds that is waited for a key code or mapped key sequence to complete
o.wildmenu = true -- when 'wildmenu' is on, command-line completion operates in an enhanced mode
o.showcmd = true -- show (partial) command in the last line of the screen. Set this option off if your terminal is slow
o.showmatch = true -- when a bracket is inserted, briefly jump to the matching one
o.inccommand = "split" -- when nonempty, shows the effects of :substitute, :smagic, :snomagic and user coimmands with the :command-preview flag as you type
o.splitright = true
o.splitbelow = true -- when on, splitting a window will put the new window below the current one
o.termguicolors = true
