--[[

File l3build-text.lua Copyright (C) 2018, 2019 The LaTeX3 Project

It may be distributed and/or modified under the conditions of the
LaTeX Project Public License (LPPL), either version 1.3c of this
license or (at your option) any later version.  The latest version
of this license is in the file

   http://www.latex-project.org/lppl.txt

This file is part of the "l3build bundle" (The Work in LPPL)
and all files in that bundle must be distributed together.

-----------------------------------------------------------------------

The development version of the bundle can be found at

   https://github.com/latex3/l3build

for those people who are interested.

--]]

--- Provides text functions.
-- This module, as the name indicates, provides text functions.
-- This module is self-contained has no other dependencies.
-- @author The LaTeX3 team
-- @license LaTeX Project Public License (LPPL 1.3c)
-- @copyright 2018, 2019 The LaTeX3 Project
-- @release 1.0

-- the LaTeX3 text namespace
local l3text = {}

-- the local namespace
local utils = {}

utils.config = package.config
utils.sub = string.sub
utils.find = string.find
utils.byte = string.byte
utils.tostring = tostring
utils.io = io

-- the streams
l3text.stdout = {}
l3text.stderr = {}

--- Ensures the variable holds any value or falls back to a default value.
-- This function ensures the variable holds any value or falls back to a
-- default value.
-- @param value the variable value to be checked.
-- @param default the default value to be returned in case the variable
-- does not hold any value.
-- @return The existing value variable if it holds any value or a
-- predefined value.
local function ensure(value, default)
  return value or default
end

--- Provides the color map scheme for terminals.
-- This function provides the color map scheme based on the provided
-- key or falls back to a reset command if the color is not mapped.
-- By default, the function does nothing unless a system variable
-- is detected.
-- @param key the color name, currently set to the default one used
-- in the user terminal. These are the available colors: `black`, `red`,
-- `green`, `yellow`, `blue`, `magenta`, `cyan`, `lightgrey`, `darkgrey`, `lightred`,
-- `lightgreen`, `lightyellow`, `lightblue`, `lightmagenta`, `lightcyan`, and `white`.
-- Additionally, there is a `reset` key to restore the defaults.
-- @return A string containing the color scheme for terminals.
local function colormap(key)
  local colors = {
    default      = '39',
    black        = '30',
    red          = '31',
    green        = '32',
    yellow       = '33',
    blue         = '34',
    magenta      = '35',
    cyan         = '36',
    lightgrey    = '37',
    darkgrey     = '90',
    lightred     = '91',
    lightgreen   = '92',
    lightyellow  = '93',
    lightblue    = '94',
    lightmagenta = '95',
    lightcyan    = '96',
    white        = '97',
    reset        = '00'
  }
  return (ensure(os.getenv('L3BUILD_COLORS'), '0') == '1' and '\027[00;' ..
  ensure(colors[key], colors['reset']) .. 'm') or ''
end

--- Returns a string enclosed in a color scheme.
-- This function returns a string enclosed in a color scheme based
-- on the provided key. Note that the `reset` is always applied at
-- the end, in order to ensure the default terminal state.
-- @param key the color key, based on an underlying colormap. These
-- are the available color keys: `black`, `red`, `green`, `yellow`, `blue`,
-- `magenta`, `cyan`, `lightgrey`, `darkgrey`, `lightred`, `lightgreen`, `lightyellow`,
-- `lightblue`, `lightmagenta`, `lightcyan`, and `white`. Additionally, there
-- is a `reset` key to restore the defaults.
-- @param text the string to be enclosed.
-- @return The string enclosed in a color scheme.
function l3text.color(key, text)
  return colormap(key) .. text .. colormap('reset')
end

--- Gets the linebreak symbol, based on the underlying operating system.
-- This function, as the name implies, gets the linebreak symbol based
-- on the underlying operating system (potentially `\n`).
-- @return The linebreak symbol.
function l3text.linebreak()
  return utils.sub(utils.config, 2, 2)
end

--- Replicates the provided string a specific number of times,
-- based on a integer value, returning a corresponding string.
-- This function replicates a string based on an integer value,
-- resulting on a string formed by a repeated concatenation.
-- @param c String to be replicated.
-- @param w Integer denoting the number of times.
-- @return Resulting string, based on the provided parameters.
function l3text.pad(c, w)
  local r = ''
  while #r < w do
    r = r .. c
  end
  return r
end

--- Wraps a string into a sequence of lines according to a specified
--- width, respecting words (i.e, breaks happen only at spaces).
-- This function takes a string and splits it into a sequence of lines,
-- separated by the default linebreak symbol (potentially `\n`). Lines
-- are broken at spaces (i.e, preserving words). It is also possible
-- to specify an indentation shift for each line and disable this
-- potential shift for the first line.
-- @param text Text to be wrapped, may include colored parts.
-- @param width Nonzero, positive integer representing the number of
-- colums to be displayed (in general, a sensible value would be lower
-- than 80 columns).
-- @param shift Optional, nonzero, positive value denoting the indentation
-- shift to add to each line of the resulting wrapped string. This parameter
-- defaults to zero when absent.
-- @param first Optional, boolean value indicating whether the first
-- line should be indented. This parameter defaults to `false` when absent,
-- or has no effect when the indentation shift is absent or equals zero.
-- @return The wrapped string.
function l3text.wrap(text, width, shift, first)

  -- handlers
  local wrapped, colour, lb = '', '', l3text.linebreak()
  local checkpoint, counter = 1, 1
  local closed, reset = true, '\027[00;00m'

  -- ensure optional values
  shift = ensure(shift, 0)
  first = ensure(first, false)

  -- defines a local function to inspect
  -- potential colored parts in the string
  local peek = function(t)
    local _, b, c = utils.find(t, '^(\027%[00;%d%dm)')
    b = ensure(b, 0)
    return utils.sub(t, b + 1, b + 1), c, utils.sub(t, b + 2)
  end

  while #text ~= 0 do

    -- extract lexical elements
    -- from the text
    local a, b, c = peek(text)
    text = c

    -- there is a colored part,
    -- prepare closing counterpart
    if b then
      colour = b
      closed = not closed
    end

    -- compose wrapped text
    wrapped = wrapped .. ensure(b, '') .. a

    -- check for a special character
    -- and increments counter
    if utils.byte(a) ~= 195 then
      counter = counter + 1
    end

    -- set a checkpoint based on
    -- a potential linebreak
    if a == ' ' then
      checkpoint = #wrapped
    end

    -- effectively breaks the line,
    -- including a potential indentation
    if counter >= width then
      wrapped =  utils.sub(wrapped, 1, checkpoint) ..
            ((not closed and reset) or '') .. lb ..
            l3text.pad(' ', shift) .. ((not closed and colour) or '') ..
            utils.sub(wrapped, checkpoint + 1)
      counter = 0
    end
  end

  -- return the wrapped string, with the
  -- last check on indenting the first line
  return (first and l3text.pad(' ', shift) or '') .. wrapped
end

--- Prints the provided parameter in the standard output, with no linebreak.
-- This function prints the provided parameter in the standard output,
-- without adding a trailing linebreak. The parameter is properly converted
-- to its string representation based on the underlying `tostring` function, as
-- a typical `print` implementation does.
-- @param The parameter to be printed in the standard output.
function l3text.stdout.print(a)
  utils.io.write(utils.tostring(a))
end

--- Prints the provided parameter in the standard output, with a linebreak.
-- This function prints the provided parameter in the standard output,
-- adding a trailing linebreak. The parameter is properly converted to its
-- string representation based on the underlying `tostring` function, as a
-- typical `print` implementation does.
-- @param The parameter to be printed in the standard output.
function l3text.stdout.println(a)
  utils.io.write(utils.tostring(a) .. l3text.linebreak())
end

--- Prints the provided parameter in the standard error, with no linebreak.
-- This function prints the provided parameter in the standard error,
-- without adding a trailing linebreak. The parameter is properly converted
-- to its string representation based on the underlying `tostring` function, as
-- a typical `print` implementation does.
-- @param The parameter to be printed in the standard error.
function l3text.stderr.print(a)
  utils.io.stderr:write(utils.tostring(a))
end

--- Prints the provided parameter in the standard error, with a linebreak.
-- This function prints the provided parameter in the standard error,
-- adding a trailing linebreak. The parameter is properly converted to its
-- string representation based on the underlying `tostring` function, as a
-- typical `print` implementation does.
-- @param The parameter to be printed in the standard error.
function l3text.stderr.println(a)
  utils.io.stderr:write(utils.tostring(a) .. l3text.linebreak())
end

--- Draws the `l3build` logo, in ASCII art, in the terminal.
-- This function, as the name implies, draws the `l3build` logo in
-- the terminal, as an ASCII art, and applies a light blue colour
-- when the proper color support is enabled.
function l3text.drawLogo()
  l3text.stdout.println(l3text.color('lightblue',
      '   ______ __        _ __   __'))
  l3text.stdout.println(l3text.color('lightblue',
      '  / /_  // /  __ __(_) /__/ /'))
  l3text.stdout.println(l3text.color('lightblue',
      ' / //_ </ _ \\/ // / / / _  / '))
  l3text.stdout.println(l3text.color('lightblue',
      '/_/____/_.__/\\_,_/_/_/\\_,_/  '))
  l3text.stdout.println('');
end

-- export module
return l3text
