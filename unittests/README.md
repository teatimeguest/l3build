# Unit tests

This directory contains unit tests for the `l3build` modules, using
the [LuaUnit](https://github.com/bluebird75/luaunit) framework.
For simplicity, LuaUnit is explicitly included in the directory
structure instead of an external reference (specified through the
`LUA_PATH` variable).

LuaUnit is provided by Philippe Fremy and distributed under the
[BSD license](https://github.com/bluebird75/luaunit/blob/master/LICENSE.txt).

## Usage

Unit tests are organized by modules. The naming scheme follows the
`test_l3build-<mname>.lua` pattern, in which `<mname>` holds the module
name to be inspected (e.g, `arguments`). In order to run unit tests on
a module `m`, run

```bash
$ make m
```

Note that multiple unit tests are available through chaining module names:

```bash
$ make a b c
```

The previous command will run unit tests on modules `a`, `b`, and `c`,
respectivelly. In order to run all unit tests on all modules, simply run

```bash
$ make
```

