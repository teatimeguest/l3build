--[[

File test_l3build-arguments.lua Copyright (C) 2019 The LaTeX3 Project

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

--- Provides test unit cases for `l3build-arguments`.
-- This test unit aims at checking the `l3build-arguments` module.
-- @author The LaTeX3 team
-- @license LaTeX Project Public License (LPPL 1.3c)
-- @copyright 2019 The LaTeX3 Project
-- @release 1.0

-- load namespaces
local lu = require('luaunit')

-- set path to load modules
-- from the top directory
package.path = package.path .. ';../?.lua'
local l3args = require('l3build-arguments')

local options = l3args.getOptions()
local targets = {'check', 'clean', 'ctan', 'doc', 'install', 'manifest',
                 'save', 'tag', 'uninstall', 'unpack', 'upload' }

function testValidTarget()
  local a, b = l3args.argparse(targets, options, { 'check' })
  lu.assertEquals('check', a['target'])
  lu.assertFalse(b['target'])
end

function testInvalidTarget()
  local _, b = l3args.argparse(targets, options, { 'chekc' })
  lu.assertTrue(b['target'])
end

function testInvalidTarget()
  local _, b = l3args.argparse(targets, options, { 'chekc' })
  lu.assertTrue(b['target'])
end

function testShortBooleanOption()
  local a, b = l3args.argparse(targets, options, { 'check', '-v', '-h' })
  lu.assertTrue(a['version'])
  lu.assertTrue(a['help'])
  lu.assertTrue(#a['remainder'] == 0)
  lu.assertEquals(b, { target = false, unknown = {}, invalid = {},
                       duplicate = {}, remainder = {} })
end

function testLongBooleanOption()
  local a, b = l3args.argparse(targets, options, { 'check', '--version', '--help' })
  lu.assertTrue(a['version'])
  lu.assertTrue(a['help'])
  lu.assertTrue(#a['remainder'] == 0)
  lu.assertEquals(b, { target = false, unknown = {}, invalid = {},
                       duplicate = {}, remainder = {} })
end

function testGroupedBooleanOptions()
  local a, b = l3args.argparse(targets, options, { 'check', '-hv' })
  lu.assertTrue(a['version'])
  lu.assertTrue(a['help'])
  lu.assertTrue(#a['remainder'] == 0)
  lu.assertEquals(b, { target = false, unknown = {}, invalid = {},
                       duplicate = {}, remainder = {} })
end

function testParametricShortOption()
  local a, b = l3args.argparse(targets, options, { 'check', '-m', 'hello' })
  lu.assertEquals(a['message'], 'hello')
  lu.assertTrue(#a['remainder'] == 0)
  lu.assertEquals(b, { target = false, unknown = {}, invalid = {},
                       duplicate = {}, remainder = {} })
end

function testParametricLongOption()
  local a, b = l3args.argparse(targets, options, { 'check', '--message', 'hello' })
  lu.assertEquals(a['message'], 'hello')
  lu.assertTrue(#a['remainder'] == 0)
  lu.assertEquals(b, { target = false, unknown = {}, invalid = {},
                       duplicate = {}, remainder = {} })
end

function testParametricShortOptionWithSeparator()
  local a, b = l3args.argparse(targets, options, { 'check', '-m=hello' })
  lu.assertEquals(a['message'], 'hello')
  lu.assertTrue(#a['remainder'] == 0)
  lu.assertEquals(b, { target = false, unknown = {}, invalid = {},
                       duplicate = {}, remainder = {} })
end

function testParametricLongOptionWithSeparator()
  local a, b = l3args.argparse(targets, options, { 'check', '--message=hello' })
  lu.assertEquals(a['message'], 'hello')
  lu.assertTrue(#a['remainder'] == 0)
  lu.assertEquals(b, { target = false, unknown = {}, invalid = {},
                       duplicate = {}, remainder = {} })
end

function testParametricShortOptionWithTable()
  local a, b = l3args.argparse(targets, options, { 'check', '-e',
                               'pdftex,xelatex,luatex' })
  lu.assertIsTable(a['engine'])
  lu.assertEquals(a['engine'], { 'pdftex', 'xelatex', 'luatex' })
  lu.assertTrue(#a['remainder'] == 0)
  lu.assertEquals(b, { target = false, unknown = {}, invalid = {},
                       duplicate = {}, remainder = {} })
end

function testParametricLongOptionWithTable()
  local a, b = l3args.argparse(targets, options, { 'check', '--engine',
                               'pdftex,xelatex,luatex' })
  lu.assertIsTable(a['engine'])
  lu.assertEquals(a['engine'], { 'pdftex', 'xelatex', 'luatex' })
  lu.assertTrue(#a['remainder'] == 0)
  lu.assertEquals(b, { target = false, unknown = {}, invalid = {},
                       duplicate = {}, remainder = {} })
end

function testDuplicateShortBooleanOptions()
  local a, b = l3args.argparse(targets, options, { 'check', '-h', '-h' })
  lu.assertTrue(a['help'])
  lu.assertTrue(#a['remainder'] == 0)
  lu.assertEquals(b, { target = false, unknown = {}, invalid = {},
                       duplicate = { '--help' }, remainder = {} })
end

function testDuplicateLongBooleanOptions()
  local a, b = l3args.argparse(targets, options, { 'check', '--help', '--help' })
  lu.assertTrue(a['help'])
  lu.assertTrue(#a['remainder'] == 0)
  lu.assertEquals(b, { target = false, unknown = {}, invalid = {},
                       duplicate = { '--help' }, remainder = {} })
end

function testDuplicateGroupedOptions()
  local a, b = l3args.argparse(targets, options, { 'check', '-hh' })
  lu.assertTrue(a['help'])
  lu.assertTrue(#a['remainder'] == 0)
  lu.assertEquals(b, { target = false, unknown = {}, invalid = {},
                       duplicate = { '--help' }, remainder = {} })
end

function testDuplicateMixedBooleanOptions()
  local a, b = l3args.argparse(targets, options, { 'check', '--help', '-h' })
  lu.assertTrue(a['help'])
  lu.assertTrue(#a['remainder'] == 0)
  lu.assertEquals(b, { target = false, unknown = {}, invalid = {},
                       duplicate = { '--help' }, remainder = {} })
end

function testDuplicateShortParametricOptions()
  local a, b = l3args.argparse(targets, options, { 'check', '-m', 'foo', '-m', 'bar', 'baz' })
  lu.assertEquals(a['message'], 'foo')
  lu.assertEquals(a['remainder'], { 'baz' })
  lu.assertEquals(b, { target = false, unknown = {}, invalid = {},
                       duplicate = { '--message' }, remainder = { 'bar' } })
end

function testInvalidOptions()
  local _, b = l3args.argparse(targets, options, { 'check', '-v=2.1' })
  lu.assertEquals(b['invalid'], { '--version' })
  lu.assertEquals(b['remainder'], { '2.1' })
end

function testUnknownOptions()
  local _, b = l3args.argparse(targets, options, { 'check', '-abc=2.1' })
  lu.assertEquals(b['unknown'], { '-abc' })
  lu.assertEquals(b['remainder'], { '2.1' })
end

-- run tests
os.exit(lu.LuaUnit.run())