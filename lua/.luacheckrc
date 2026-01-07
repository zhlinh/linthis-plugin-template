-- Luacheck Configuration for linthis-plugin-template Plugin
-- Documentation: https://luacheck.readthedocs.io/

-- Lua version
std = "lua54"

-- Maximum line length
max_line_length = 100

-- Allow unused arguments starting with underscore
unused_args = false

-- Allow unused variables starting with underscore
unused = false

-- Global variables that are allowed
globals = {
    "vim",  -- For Neovim configs
}

-- Read-only global variables
read_globals = {
    "awesome",  -- For AwesomeWM
    "client",
    "root",
}

-- Ignore specific warnings
ignore = {
    "212",  -- Unused argument
    "213",  -- Unused loop variable
}
