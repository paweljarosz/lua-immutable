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
-- Known issues:
--
-- Keys referencing `nil` in the original table will be inaccesible in the immutable table.
-- To prevent unidentified key access, initialize the fields with any other value.
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

---Checks if a given table `table_to_check` is immutable
---@static
---@param	table_to_check	table|Immutable		@table to check if is immutable
---@return					boolean				@true if table is immutable, false otherwise
function Immutable.is_immutable(table_to_check)
	return type(table_to_check) == "table" and getmetatable(table_to_check) == immutable_marker
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
			if data_table[key] ~= nil then
				local value = data_table[key]
				if value == nil_placeholder then
					return nil  -- Return nil for placeholders
				end
				return value
			else
				error("Attempt to access undefined key: " .. tostring(key))
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