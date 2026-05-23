![](media/logo.png)

# IMMUTABLE

**IMMUTABLE** makes any Lua table runtime immutable (read-only) where one:
- can get defined entries
- cannot add, remove nor change entries
- cannot access values at undefined keys nor out of bounds elements

---

## Defold dependency:

You can add now Immutable as a dependency to Defold
Open your `game.project` file and add the following line to the dependencies field under the `Project` section:

Current version is 1.2:

`https://github.com/paweljarosz/lua-immutable/archive/refs/tags/v1.2.zip`


## Usage:

Immutable tables can be created using the `.make` function or a direct call on required module:

```lua
    local IMMUTABLE = require "immutable.immutable"
    local data_table = { 1, 2, 3 } -- regular table

    -- convert any table to an immutable table:
    --[[1]] local my_immutable_table = IMMUTABLE.make( data_table )

    -- or simply using convenience call:
    --[[2]] local my_immutable_table = IMMUTABLE( data_table )

    -- or create it on the go (syntax sugar for call with table parameter):
    --[[3]] local my_immutable_table = IMMUTABLE{ 1, 2, 3 }
```

Immutable tables can be deleted at will with just a `nil` assignment:

```lua
    my_immutable_table = nil
```

You can check if any table is immutable (converted using this module) with `.is_immutable()` function:

```lua
    local is_immutable = IMMUTABLE.is_immutable(my_table)
```

If you need to convert an immutable table to JSON you can make a mutable copy of the immutable table:

```lua
    json.encode(IMMUTABLE.mutable_copy(immutable_table))
```

You can configure if attempts to read undefined keys from immutable tables should error (the default) or behave like normal tables by returning `nil`:

```lua
    IMMUTABLE.option_undefined_key_errors(false)
```

---

## API:

#### IMMUTABLE.make(original_table)
- Function to make the `original_table` immutable, including nested tables.
```lua
    @param original_table [table] - table to convert to immutable table
    @return [table] - original table converted to immutable table
```
> **_NOTE:_**  Immutable doesn't create a new table - the original table is converted to an immutable table. So simply comparing references `data_table == my_immutable_table` gives true.


#### IMMUTABLE.is_immutable(table_to_check)
- Function to check if a given table `table_to_check` is immutable.
```lua
    @param table_to_check [table] - table to check
    @return [bool] - true if table `table_to_check` is immutable, false otherwise
```

#### IMMUTABLE.mutable_copy(table)
- Function to return a mutable copy of the given @Immutable (or regular) table
```lua
    @param table table|Immutable - Immutable (or regular) table to make a mutable copy of
    @return [table] - mutable copy of the Immutable table data
```

#### IMMUTABLE.option_undefined_key_errors(value)
- Function to configure behavior on accessing undefined keys in an immutable table.
```lua
    @param value [bool] - true if non-existent keys should throw an error, false otherwise
    @return [bool] - true if non-existent keys will throw an error, false otherwise
```
---

## Known issues and limitations:

### Keys referencing `nil` are inaccessible in immutable table

Immutable tables does not allow access to unidentified keys.
So if in the original table a key is referencing a `nil` value, accessing it in immutable version will not be possible.
To prevent unidentified key access, initialize the fields with any other value.
Or use `IMMUTABLE.option_undefined_key_errors(false)` to return nil like regular tables.

### Lua `table` API is not supported

Immutable tables are secured against modifications in any sort of loops, but are **not** secured against usage with "**table**" API.

```lua
    table.insert(immutable{ 1, 2 }, 3, 3) -- will NOT raise an error!
    table.remove(immutable{ 1, 2 }, 2) -- will NOT raise an error!
```

To prevent it, you can either avoid using `table` API or override its functions.
Example on how to override some `table` functions:

```lua
-- Save original functions
local original_insert = table.insert
local original_remove = table.remove

-- Override table.insert
function table.insert(t, pos, value)
    if IMMUTABLE.is_immutable(t) then
        error("Cannot insert into an immutable table")
    end
    if value == nil then
        value = pos
        pos = nil
    end
    if pos == nil then
        return original_insert(t, value)
    else
        return original_insert(t, pos, value)
    end
end

-- Override table.remove
function table.remove(t, pos)
    if IMMUTABLE.is_immutable(t) then
        error("Cannot remove from an immutable table")
    end
    return original_remove(t, pos)
end
```

### Immutable tables cannot be directly converted to JSON

If you try to `json.encode(IMMUTABLE.make({ type = "Wizard" }))` the result will be `{}`. This may be related to
various table functions not working properly in Lua 5.1 used by Defold (in spite of the metatable adjustments made
by the library). See [stackoverflow](https://stackoverflow.com/questions/25716851/lua-table-length-function-override-not-working) and [Lua 5.1 manual section 2.8 on metatables](https://www.lua.org/manual/5.1/manual.html).

As a workaround you can make a mutable copy of the table before trying to save it:

```lua
local test_table = IMMUTABLE.make({
    type = "Wizard",
    level = 9001,
    abilities = {
        "Smoking",
        "Fireworks",
        "Wisdom"
    }
}

local mutable_copy = IMMUTABLE.mutable_copy(test_table)
local json_encoded = json.encode(mutable_copy)
```

If you spot any issue, please report! PRs are welcome too!

---

### Changelog

#### 1.0
First public version release.

#### 1.1
Added Defold project and allowed to include Immutable as dependency in Defold.
Added Lua annotations.

#### 1.2
Added option_undefined_key_errors to let immutable tables behave more like regular tables.
Added mutable_copy function to enable converting immutable tables to JSON.

---

### License

MIT

Copyright 2024-2025 Paweł Jarosz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.