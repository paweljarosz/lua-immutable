# IMMUTABLE

**IMMUTABLE** makes any Lua table runtime immutable (read-only) where one:
- can get defined entries
- cannot add, remove nor change entries
- cannot access values at undefined keys nor out of bounds elements

---

## Usage:

Immutable tables can be created using the `.make` function or a direct call on required module:

```lua
    local IMMUTABLE = require "immutable"
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

---

## Known issues and limitations:

### Keys referencing `nil` are inaccessible in immutable table

Immutable tables does not allow access to unidentified keys.
So if in the original table a key is referencing a `nil` value, accessing it in immutable version will not be possible.
To prevent unidentified key access, initialize the fields with any other value.

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

If you spot any issue, please report! PRs are welcome too!

---

### License

MIT

Copyright 2024 Paweł Jarosz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.