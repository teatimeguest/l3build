--[[

File l3build-help.lua Copyright (C) 2018, 2019 The LaTeX3 Project

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

--- Provides functions related to the tool usage.
-- This module, as the name indicates, provides functions
-- related to the tool usage.
-- This module depends on the `text` module.
-- @author The LaTeX3 team
-- @license LaTeX Project Public License (LPPL 1.3c)
-- @copyright 2018, 2019 The LaTeX3 Project
-- @release 1.0

-- the LaTeX3 help namespace
local l3help = {}

-- the local namespace
local utils = {}

-- helper text module
utils.l3text = require('l3build-text')

-- table iterators
utils.ipairs = ipairs
utils.pairs  = pairs

-- table operations
utils.insert = table.insert
utils.remove = table.remove
utils.sort   = table.sort

-- string operations
utils.length = string.len
utils.match  = string.match

--- Gets the script name based on the actual file name.
-- This function gets the script name based on the actual
-- file name. If it is the original `l3build.lua` reference,
-- simply return it without the corresponding extesion.
-- Otherwise, return the script name, potentially with
-- the full path included.
local function getScriptName()
  return (utils.match(arg[0], 'l3build%.lua')
        and 'l3build') or arg[0]
end

--- Prints the script usage.
-- This function, as the name implies, prints the script
-- usage, based on the table of targets and parameters.
-- @param targets Table of targets.
-- @param options Table of options.
function l3help.printUsage(targets, options)
  local a, b, c, d, e = {}, 0, 3, {}, 74

  -- print the script usage syntax
  utils.l3text.stdout.println(utils.l3text.wrap('usage: ' ..
        utils.l3text.color('blue', getScriptName()) .. ' ' ..
        utils.l3text.color('lightyellow', '<command>') .. ' ' ..
        utils.l3text.color('cyan', '[<options>]') .. ' ' ..
        utils.l3text.color('lightcyan', '[<names>]'), e))
  utils.l3text.stdout.println('')

  -- print the list of valid targets
  utils.l3text.stdout.println('Valid commands are:')

  -- get all targets
  for _, v in ipairs(targets) do
    utils.insert(a, v['name'])
    d[v['name']] = v['description']
    if utils.length(v['name']) > b then
      b = utils.length(v['name'])
    end
  end

  -- sort them alphabetically
  -- for a better display
  utils.sort(a)

  -- print each target and corresponding
  -- description, with colour support
  for _, v in ipairs(a) do
    utils.l3text.stdout.println(utils.l3text.pad(' ', c) ..
          utils.l3text.color('lightyellow', v) ..
          utils.l3text.pad(' ', b - utils.length(v) + c ) ..
          utils.l3text.wrap(d[v], e - (2*c + b), (2*c + b), false))
  end

  -- print the list of valid options
  utils.l3text.stdout.println('')
  utils.l3text.stdout.println('Valid options are:')

  a, b, d = {}, 0, {}

  -- get all options that actually
  -- have an associated description
  for _, v in ipairs(options) do

    if v['description'] then
      utils.insert(a, v['long'])

      d[v['long']] = {}

      d[v['long']]['description'] = v['description']
      if v['short'] then
        d[v['long']]['size'] = utils.length(v['long']) +
            utils.length(v['short']) + 4
        d[v['long']]['entry'] = utils.l3text.color('cyan', '--' ..
            v['long']) .. ',' .. utils.l3text.color('green', '-' .. v['short'])
      else
        d[v['long']]['size'] = utils.length(v['long']) + 2
        d[v['long']]['entry'] = utils.l3text.color('cyan', '--' .. v['long'])
      end

      if d[v['long']]['size'] > b then
        b = d[v['long']]['size']
      end
    end
  end

  -- sort them alphabetically
  -- for a better display
  utils.sort(a)

  -- print each option and corresponding
  -- description, with colour support
  for _, v in ipairs(a) do
    utils.l3text.stdout.println(utils.l3text.pad(' ', c) ..
        d[v]['entry'] .. utils.l3text.pad(' ', b - d[v]['size'] + c) ..
        utils.l3text.wrap(d[v]['description'], e - (2*c + b), (2*c + b), false))
  end

  -- print the reference to the user manual
  utils.l3text.stdout.println('')
  utils.l3text.stdout.println('See ' ..
        utils.l3text.color('lightblue', 'l3build.pdf') ..
        ' for further details.')
end

--- Prints the script version.
-- This function prints the script version, which
-- is based on the release date, with colour support.
-- @param date Release date
function l3help.printVersion(date)
  utils.l3text.stdout.println(utils.l3text.color('cyan', 'l3build:') ..
        ' a testing and building system for LaTeX')
  utils.l3text.stdout.println('')
  utils.l3text.stdout.println(utils.l3text.wrap('Release ' ..
        utils.l3text.color('cyan', date) .. ', distributed ' ..
        'under the conditions of the LaTeX Project Public License (LPPL)', 54))
end

-- export module
return l3help
