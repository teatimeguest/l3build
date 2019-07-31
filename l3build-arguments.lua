--[[

File l3build-arguments.lua Copyright (C) 2018 The LaTeX3 Project

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

--- Provides handling and parsing of command line arguments.
-- This module is self-contained has no other dependencies.
-- @author The LaTeX3 team
-- @license LaTeX Project Public License (LPPL 1.3c)
-- @copyright 2019 The LaTeX3 Project
-- @release 1.0

-- the LaTeX3 namespace
local l3args = {}

-- helper table
local utils = {}

-- table iterators
utils.ipairs = ipairs
utils.pairs  = pairs

-- table operations
utils.insert = table.insert
utils.remove = table.remove

-- string operations
utils.find   = string.find
utils.length = string.len
utils.sub    = string.sub
utils.gsub   = string.gsub

--- Checks whether the provided value is available as a table element.
-- This function searches and compares the provided value against
-- every element in the table. If a match is found, the value
-- therefore is available and the search ends. Otherwise, after scanning
-- the entire table with no match, the function returns `false` as result.
-- @param a Table of elements.
-- @param hit Value to be searched.
-- @return Boolean value whether the table contains the provided value
-- as an element.
function l3args.contains(a, hit)
  for _, v in utils.ipairs(a) do
    if v == hit then
      return true
    end
  end
  return false
end

--- Parses the argument table based on a table of targets and options.
-- This function parses the argument table obtained from the command line
-- invocation and extracts options and potential corresponding values
-- based on rules set forth in a table of targets and options. As a result,
-- two tables are returned (one containing the correct elements and the
-- other holding potential issues found).
-- @param targets Table of targets which dictate the tool behaviour, given
-- the remaining set of command line arguments.
-- @param options Table of options which dictate the parsing operation.
-- @param arguments Argument table obtained from the command line.
-- @return Table holding option keys and potential corresponding values.
-- @return Table holding potential issues found during the parsing
-- operation. These issues are grouped into five categories, presented
-- as follows:
--
-- - `unknown`: This table holds unknown options, either in their long or short
-- forms. An unknown option is any element preceed by `-` and `--` and not
-- explicitly described in the `options` table. The table has no duplicate values.
-- - `duplicate`: This table holds duplicate options, i.e, options that were
-- previously found during the argument processing, either in their long or
-- short forms. Whenever possible, options are always normalized to their
-- long forms. The table has no duplicate values.
-- - `invalid`: This table holds invalid options, either in their long or short
-- forms. An invalid option, in this case, is a boolean switch which was
-- inadvertently specified with a value, using the `=` separator. The table has
-- no duplicate values.
-- - `remainder`: This table, as the name implies, holds remainder values obtained
-- from duplicate and invalid options (see previous descriptions). The table
-- might have duplicate values, as they are simply inserted into the structure.
-- - `target`: This boolean switch holds the reference to an invalid target, i.e,
-- when the first positional argument does not correspond to an element in the
-- list of valid targets. Initially, this switch is set to `false` (invalid).
function l3args.argparse(targets, options, arguments)

  local keys, key, issues = {}, 'remainder', {}
  local switch, a, b, c = false

  -- inner table
  keys['remainder'] = {}

  -- inner tables
  issues[ 'unknown' ] = {}
  issues['duplicate'] = {}
  issues[ 'invalid' ] = {}
  issues['remainder'] = {}

  -- boolean switch for an invalid
  -- target, initially set to true
  issues['target'] = true

  for _, v in utils.ipairs(arguments) do

    -- look for a short option (no separator)
    a, _, b = utils.find(v, '^%-(%w+)$')

    -- we got a hit
    if a then
      for _, x in utils.ipairs(options) do

        -- get the key reference
        key = 'remainder'
        if x['short'] == b then
          key = x['long']

          -- check if the key was
          -- already defined
          if not keys[key] then

            -- check if this is a
            -- boolean switch
            if not x['argument'] then
              keys[key] = true
            end

          -- we got a duplicate
          else
            if not l3args.contains(issues['duplicate'], '--' .. key) then
              utils.insert(issues['duplicate'], '--' .. key)
            end
          end
          break
        end
      end

      -- key is unknown, log it
      if key == 'remainder' then

        for i = 1, utils.length(b) do
          a = utils.sub(b, i, i)

          for _, x in utils.ipairs(options) do

            key = 'remainder'
            if x['short'] == a then
              key = x['long']

              -- check if the key was
              -- already defined
              if not keys[key] then

                -- check if this is a
                -- boolean switch
                if not x['argument'] then
                  keys[key] = true

                -- it is not a boolean switch,
                -- so report as an invalid flag
                else
                  if not l3args.contains(issues['invalid'], '--' .. key) then
                    utils.insert(issues['invalid'], '--' .. key)
                  end
                end

              -- the key already exists,
              -- report as a duplicate
              else
                if not l3args.contains(issues['duplicate'], '--' .. key) then
                  utils.insert(issues['duplicate'], '--' .. key)
                end
              end

              break
            end
          end

          -- key is unknown, log it
          if key == 'remainder' then
            if not l3args.contains(issues['unknown'], '-' .. a) then
              utils.insert(issues['unknown'], '-' .. a)
            end
          end
        end
      end

    -- no short option, move
    -- on to the next branch
    else

      -- look for a long option (no separator)
      a, _, b = utils.find(v, '^%-%-([%w-]+)$')

      -- we got a hit
      if a then
        for _, x in utils.ipairs(options) do

          -- get the key reference
          key = 'remainder'
          if x['long'] == b then
            key = b

            -- check if the key was
            -- already defined
            if not keys[key] then

              -- check if this is a
              -- boolean switch
              if not x['argument'] then
                keys[key] = true
              end

            -- we got a duplicate
            else
              if not l3args.contains(issues['duplicate'], '--' .. key) then
                utils.insert(issues['duplicate'], '--' .. key)
              end
            end
            break
          end
        end

        -- key is unknown, log it
        if key == 'remainder' then
          if not l3args.contains(issues['unknown'], '--' .. b) then
            utils.insert(issues['unknown'], '--' .. b)
          end
        end

      -- no long option, move
      -- on to the next branch
      else

        -- look for a long option
        -- (with the '=' separator)
        a, _, b, c = utils.find(v, '^%-%-([%w-]+)=(.+)$')

        -- there is a hit
        if a then
          for _, x in utils.ipairs(options) do

            -- get the key reference
            key = 'remainder'
            if x['long'] == b then
              key = b

              -- check if the key is not
              -- a boolean switch
              if x['argument'] then

                -- check if the key was
                -- already defined
                if not keys[key] then
                  if x['handler'] then
                    keys[key] = x['handler'](c)
                  else
                    keys[key] = c
                  end

                -- we got a duplicate, so the value
                -- goes to the remainder, as the
                -- other counterparts
                else

                  -- log the duplicate key
                  if not l3args.contains(issues['duplicate'], '--' .. key) then
                    utils.insert(issues['duplicate'], '--' .. key)
                  end

                  -- the value is thrown to the remainder
                  utils.insert(issues['remainder'], c)
                end

              -- the option is actually a boolean
              -- switch, so report the invalid key
              else
                if not l3args.contains(issues['invalid'], '--' .. key) then
                  utils.insert(issues['invalid'], '--' .. key)
                end

                -- the value is thrown to the remainder
                utils.insert(issues['remainder'], c)
              end

              break
            end
          end

          -- key is unknown, log it
          if key == 'remainder' then
            if not l3args.contains(issues['unknown'], '--' .. b) then
              utils.insert(issues['unknown'], '--' .. b)
            end

            -- the value is thrown to the remainder
            utils.insert(issues['remainder'], c)
          end

        -- no long option with separator,
        -- so move on to the next branch
        else

          -- look for a short option
          -- (with the '=' separator)
          a, _, b, c = utils.find(v, '^%-([%w-]+)=(.+)$')

          -- there is a hit
          if a then
            for _, x in utils.ipairs(options) do

              -- get the key reference
              key = 'remainder'
              if x['short'] == b then
                key = x['long']

                -- check if this is not
                -- a boolean switch
                if x['argument'] then

                  -- check if the key was
                  -- already defined
                  if not keys[key] then
                    if x['handler'] then
                      keys[key] = x['handler'](c)
                    else
                      keys[key] = c
                    end

                  -- we got a duplicate, so the value
                  -- goes to the remainder, as the
                  -- other counterparts
                  else
                    if not l3args.contains(issues['duplicate'], '--' .. key) then
                      utils.insert(issues['duplicate'], '--' .. key)
                    end

                    -- the value is thrown to the remainder
                    utils.insert(issues['remainder'], c)
                  end

                -- the option is actually a boolean
                -- switch, so report the invalid key
                else
                  if not l3args.contains(issues['invalid'], '--' .. key) then
                    utils.insert(issues['invalid'], '--' .. key)
                  end

                  -- the value is thrown to the remainder
                  utils.insert(issues['remainder'], c)
                end

                break
              end
            end

            -- key is unknown, log it
            if key == 'remainder' then
              if not l3args.contains(issues['unknown'], '-' .. b) then
                utils.insert(issues['unknown'], '-' .. b)
              end

              -- the value is thrown to the remainder
              utils.insert(issues['remainder'], c)
            end

          -- no short option with separator,
          -- so move to the next branch
          else

            -- we have a valid key
            if key ~= 'remainder' then
              for _, x in utils.ipairs(options) do

                -- check if the current key reference
                -- accepts a corresponding value
                if x['long'] == key then
                  if not (x['argument'] and not keys[key] ) then
                    key = 'remainder'
                    switch = true
                  end
                  c = x['handler']
                  break
                end
              end

              -- set value accordingly
              if key ~= 'remainder' then
                if c then
                  keys[key] = c(v)
                else
                  keys[key] = v
                end
              else
                if switch then
                  utils.insert(issues['remainder'], v)
                  switch = false
                else
                  utils.insert(keys['remainder'], v)
                end
              end

            -- there is no key, so we are
            -- in the remainder branch
            else

              -- insert the value into the table
              utils.insert(keys[key], v)
            end
          end
        end
      end
    end
  end

  -- potential target extraction, check
  -- whether the remainder is not empty
  if #keys['remainder'] > 0 then

    -- verify if the first element in the
    -- remainder tablle is a valid target
    if l3args.contains(targets, keys['remainder'][1]) then

      -- the first element is a valid key,
      -- so remove it from the remainder
      -- table and update the target key
      keys['target'] = utils.remove(keys['remainder'], 1)

      -- there is no issue regarding
      -- an unknown target, so update
      issues['target'] = false
    end
  end

  -- return the key/value table and
  -- the potential issues
  return keys, issues
end

--- Splits the provided string at every comma.
-- This function splits the provided string at every comma,
-- adding each part to a table of elements.
-- @param a The string to be splitted at every comma.
-- @return A table contaninig every part of the splitted
-- text, in extraction order.
function l3args.split(a)
   local sep, fields = ',', {}
   local pattern = string.format("([^%s]+)", sep)
   utils.gsub(a, pattern,
    function(c)
      fields[#fields + 1] = c
    end)
   return fields
end

--- Fetches all command line options `l3build` has, as a table.
-- This function simply returns all command line options
-- `l3build` has, as a table, to be used later on by certain
-- helper methods. The elements of such table follow a certain
-- structure.
-- @return A table containing all command line options. Each
-- element is a table on itself and has the following structure:
--
-- - `short`: optional, it denotes the option in its short form. Please
-- mind that at least one of the forms must be present, so the
-- corresponding instance can be detected at runtime.
-- - `long`: optional, it denotes the option in its long form. Please
-- mind that at least one of the forms must be present, so the
-- corresponding instance can be detected at runtime.
-- - `description`: as the name implies, this entry holds the option
-- description, to be displayed in the help menu. This entry is
-- optional. If absent, the corresponding option will not be
-- displayed in the help menu.
-- `- handler`: optional, it denotes the handler in which the option
-- value will be transformed. This feature will only be in effect
-- when the corresponding `argument` entry is set to `true`.
-- - `argument`: mandatory, it denotes whether the option will take
-- an associated value. When set to `false`, the option will
-- automatically act as a boolean switch.
function l3args.getOptions()
  return {
    {
      short       = "c",
      long        = "config",
      description = "Sets the config(s) used for running tests",
      handler     = l3args.split,
      argument    = true
    },
    {
      long        = "date",
      description = "Sets the date to insert into sources",
      argument    = true
    },
    {
      long        = "debug",
      description = "Runs target in debug mode (not supported by all targets)",
      argument    = false
    },
    {
      long        = "dirty",
      description = "Skip cleaning up the test area",
      argument    = false
    },
    {
      long        = "dry-run",
      description = "Dry run for install",
      argument    = false
    },
    {
      long        = "email",
      description = "Email address of CTAN uploader",
      argument    = true
    },
    {
      short       = "e",
      long        = "engine",
      description = "Sets the engine(s) to use for running test",
      handler     = l3args.split,
      argument    = true
    },
    {
      long        = "epoch",
      description = "Sets the epoch for tests and typesetting",
      argument    = true
    },
    {
      long        = "file",
      short       = "F",
      description = "Take the upload announcement from the given file",
      argument    = true
    },
    {
      long        = "first",
      description = "Name of first test to run",
      argument    = true
    },
    {
      long        = "force",
      short       = "f",
      description = "Force tests to run if engine is not set up",
      argument    = false
    },
    {
      long        = "full",
      description = "Install all files",
      argument    = false
    },
    {
      long        = "halt-on-error",
      short       = "H",
      description = "Stops running tests after the first failure",
      argument    = false
    },
    {
      long        = "help",
      short       = "h",
      argument    = false
    },
    {
      long        = "last",
      description = "Name of last test to run",
      argument    = true
    },
    {
      long        = "message",
      short       = "m",
      description = "Text for upload announcement message",
      argument    = true
    },
    {
      long        = "quiet",
      short       = "q",
      description = "Suppresses TeX output when unpacking",
      argument    = false
    },
    {
      long        = "rerun",
      description = "Skip setup: simply rerun tests",
      argument    = false
    },
    {
      long        = "show-log-on-error",
      description = "If 'halt-on-error' stops, show the full log of the failure",
      argument    = false
    },
    {
      long        = "shuffle",
      description = "Shuffle order of tests",
      argument    = false
    },
    {
      long        = "texmfhome",
      description = "Location of user texmf tree",
      argument    = true
    },
    {
      long        = "version",
      short       = "v",
      argument    = false
    }
  }
end

return l3args
