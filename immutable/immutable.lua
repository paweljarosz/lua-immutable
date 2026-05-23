-- IMMUTABLE makes any Lua table runtime immutable (read-only) where one:
-- - can get defined entries (unsupported key raises error)
-- - cannot add, remove nor change entries
-- - cannot access values at undefined keys nor out of bounds elements
--
-- Usage:
--
-- local IMMUTABLE = require "immutable"
-- local data_table = { 1, 2, 3 } -- regular table
--
-- [1] convert any table to an immutable table:
-- local my_immutable_table = IMMUTABLE.make( data_table )
--
-- [2] or simply using convenience call:
-- local my_immutable_table = IMMUTABLE( data_table )
--
-- [3] or create it on the go (syntax sugar for call with table parameter):
-- local my_immutable_table = IMMUTABLE { 1, 2, 3 }
--
-- API:
--
-- [ IMMUTABLE.make(original_table) ]
-- Function to make a table immutable, including nested tables
-- @param original_table [table] - table to convert to immutable table
-- @return [table] - original table converted to immutable table
--
-- [ IMMUTABLE.is_immutable(table_to_check) ]
-- Function to check if a given table `t` is immutable
-- @param table_to_check [table] - table to check
-- @return [bool] - true if table t is immutable, false otherwise
--
-- [ IMMUTABLE.mutable_copy(immutable_or_table) ]
-- Returns a mutable copy of the given @Immutable or regular table
-- @param immutable_or_table table|Immutable - Immutable or regular table to make a mutable copy of
-- @return [table] - mutable copy of the @Immutable or regular table data
--
-- [ IMMUTABLE.option_undefined_key_errors(value) ]
-- Configures undefined key lookups into immutable tables to cause an error or not. Default is true.
-- @param value [bool] - true if non-existent keys should throw an error, false otherwise
-- @return [bool] - true if non-existent keys will throw an error, false otherwise
--
-- Known issues:
--
-- Keys referencing `nil` in the original table will be inaccesible in the immutable table.
-- To prevent unidentified key access, initialize the fields with any other value.
-- Or use `IMMUTABLE.option_undefined_key_errors(false)` to return nil like regular tables.
-- 
-- Lua `table` API is not secured against mutability.
-- To prevent it, you can either avoid using table API or override them.
-- Example on how to override table is given in README.
--
-- Author: Paweł Jarosz
-- License: MIT
-- Copyright Paweł Jarosz 2024-2025

---@class Immutable Immutable class to convert any table into runtime read-only table
local Immutable = {}

local immutable_marker = "immutable"
local nil_placeholder = "nil_placeholder"  -- Unique placeholder for nil values
local undefined_key_errors = true

---Configures undefined key lookups into immutable tables to cause an error or not. Default is true.
---@static
---@param	value			boolean				@true if non-existent keys should throw an error, false otherwise
---@return					boolean				@true if non-existent keys will throw an error, false otherwise
function Immutable.option_undefined_key_errors(value)
	if value ~= nil then
		if type(value) == "boolean" then
			undefined_key_errors = value
		else
			undefined_key_errors = true
		end
	end
	
	return undefined_key_errors
end

---Checks if a given table `table_to_check` is immutable
---@static
---@param	table_to_check	table|Immutable		@table to check if is immutable
---@return					boolean				@true if table is immutable, false otherwise
function Immutable.is_immutable(table_to_check)
	return type(table_to_check) == "table" and getmetatable(table_to_check) == immutable_marker
end

---Returns a mutable copy of the given immutable or regular table
---@private
---@param	table			table|Immutable		@Immutable|@table to copy to a mutable @table
---@return					table				@table copy of the original table data
local function mutable_copy(table, seen)
	seen = seen or {}

	if seen[table] then return seen[table] end

	local copy = {}
	seen[table] = copy
	for k, v in pairs(table) do
		if type(v) == "table" then
			if Immutable.is_immutable(v) then
				copy[k] = v.__mutable_copy
			else
				copy[k] = mutable_copy(v, seen)
			end
		elseif v == nil_placeholder then
			copy[k] = nil
		else
			copy[k] = v
		end
	end

	return copy
end

---Makes a table immutable, including nested tables
---@private
---@param	original_table	table|Immutable		@table to convert
---@param	seen?			table|Immutable		@optional table entry for recursion
---@return					Immutable			@converted table
local function make_immutable_table(original_table, seen)
	seen = seen or {}

	-- Skip making a table immutable if it already is
	if Immutable.is_immutable(original_table) then
		return original_table
	end

	if seen[original_table] then return seen[original_table] end

	-- Create a data table to hold the original data
	local data_table = {}
	seen[original_table] = data_table  -- Keep track of processed tables

	for k, v in pairs(original_table) do
		if type(v) == "table" and not Immutable.is_immutable(v) then
			data_table[k] = make_immutable_table(v, seen)
		elseif v == nil then
			data_table[k] = nil_placeholder  -- Use placeholder for nil values
		else
			data_table[k] = v
		end
		original_table[k] = nil  -- Remove the key from the original table
	end

	-- Set the metatable on the original table to make it immutable
	local mt = {
		-- Redirect reads to the data_table
		__index = function(t, key)
			if key == "__mutable_copy" then
				return mutable_copy(data_table)
			elseif data_table[key] ~= nil then
				local value = data_table[key]
				if value == nil_placeholder then
					return nil  -- Return nil for placeholders
				end
				return value
			elseif undefined_key_errors then
				error("Attempt to access undefined key: " .. tostring(key))
			else
				return nil
			end
		end,
		-- Prevent any modifications
		__newindex = function()
			error("Attempt to modify or add keys to an immutable table")
		end,
		-- Lock the metatable
		__metatable = immutable_marker,
		-- Custom ipairs iterator
		__ipairs = function(t)
			local function ipairs_iterator(tab, i)
				i = i + 1
				local v = data_table[i]
				if v == nil_placeholder then
					v = nil
				end
				if v == nil then
					return nil
				else
					return i, v
				end
			end
			return ipairs_iterator, t, 0
		end,
		-- Custom pairs iterator
		__pairs = function(t)
			local function next_wrapper(table, key)
				local next_key, next_value = next(data_table, key)
				if next_value == nil_placeholder then
					next_value = nil
				end
				return next_key, next_value
			end
			return next_wrapper, t, nil
		end,
		-- Custom tostring function
		__tostring = function()
			return "Immutable: " .. tostring(data_table)
		end,
		-- Custom len function
		__len = function()
			return #data_table
		end,
	}

	setmetatable(original_table, mt)
	return original_table
end

---Returns a mutable copy of the given @Immutable table
---@static
---@param	table	table|Immutable				@Immutable table to make a mutable copy of
---@return			table						@table mutable copy of the @Immutable table data
function Immutable.mutable_copy(table)
	if type(table) ~= "table" then
		error("Expected a table but got " .. type(table))
	end

	if not Immutable.is_immutable(table) then
		return mutable_copy(table) -- copies a regular table if necessary
	end

	return table.__mutable_copy
end

---Makes a given table immutable, including nested tables
---@param original_table	table|Immutable @table to convert
---@return					Immutable		@converted table
function Immutable.make(original_table)
	if type(original_table) ~= "table" then
		error("Expected a table but got " .. type(original_table))
	end
	return make_immutable_table(original_table)
end

-- Metatable for the Immutable module
local mt = {
	-- Allows calling the module directly to create an immutable table
	__call = function(t, table_arg)
		return Immutable.make(table_arg)
	end
}

setmetatable(Immutable, mt)

return Immutable