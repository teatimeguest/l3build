--[[

File test_l3build-text.lua Copyright (C) 2019 The LaTeX3 Project

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

--- Provides test unit cases for `l3build-text`.
-- This test unit aims at checking the `l3build-text` module.
-- @author The LaTeX3 team
-- @license LaTeX Project Public License (LPPL 1.3c)
-- @copyright 2019 The LaTeX3 Project
-- @release 1.0

-- load namespaces
local lu = require('luaunit')

-- set path to load modules
-- from the top directory
package.path = package.path .. ';../?.lua'
local l3text = require('l3build-text')

function testWrap()
  local a = 'Hello, welcome to my terminal text. This might be a long, very long entry,' ..
            ' but hopefully the wrap() function will break it into smaller chunks of text!' ..
            ' Also with color support!'
  local b = 'Hello, welcome to my terminal text. This might be a long, very long \n' ..
            'entry, but hopefully the wrap() function will break it into smaller \n' ..
            'chunks of text! Also with color support!'
  lu.assertEquals(l3text.wrap(a, 70), b)
end

function testWrapPad()
  local a = 'Hello, welcome to my terminal text. This might be a long, very long entry,' ..
            ' but hopefully the wrap() function will break it into smaller chunks of text!' ..
            ' Also with color support!'
  local b = 'Hello, welcome to my terminal text. This might be a long, very long \n' ..
            '   entry, but hopefully the wrap() function will break it into smaller \n' ..
            '   chunks of text! Also with color support!'
  lu.assertEquals(l3text.wrap(a, 70, 3, false), b)
end

function testWrapPadWithFirstLine()
  local a = 'Hello, welcome to my terminal text. This might be a long, very long entry,' ..
            ' but hopefully the wrap() function will break it into smaller chunks of text!' ..
            ' Also with color support!'
  local b = '   Hello, welcome to my terminal text. This might be a long, very long \n' ..
            '   entry, but hopefully the wrap() function will break it into smaller \n' ..
            '   chunks of text! Also with color support!'
  lu.assertEquals(l3text.wrap(a, 70, 3, true), b)
end

-- run tests
os.exit(lu.LuaUnit.run())