local TEST = {}

-- Test suite is a table with test cases
-- that are functions returning result to be asserted
-- with functions that will be triggered before and after each case
--
-- To run tests use function .run_all()

local SUT = require "immutable.immutable"

local function is_table_immutable(table_to_check)
	local can_not_mutate_value = not pcall(function() table_to_check[1] = "wrong" end)
	local can_not_add_value = not pcall(function() table_to_check[5] = 5 end)
	local can_not_remove_value = not pcall(function() table_to_check[1] = nil end)

	return can_not_mutate_value
	and can_not_add_value
	and can_not_remove_value
end

TEST.create_immutable_table_using_call_operator = function()
	local test_table = { 1, 2, 3 }
	SUT( test_table ) -- creates immutable using call

	local is_table_correcty_immutable = SUT.is_immutable(test_table)
	local is_table_unmodifiable = is_table_immutable(test_table)
	local are_table_values_unmodified = test_table[1] == 1
	and test_table[2] == 2
	and test_table[3] == 3

	return is_table_correcty_immutable
	and is_table_unmodifiable
	and are_table_values_unmodified
end

TEST.create_immutable_table_using_make_function = function()
	local test_table = { 1, 2, 3 }
	SUT.make( test_table ) -- creates immutable using make function

	local is_table_correcty_immutable = SUT.is_immutable(test_table)
	local is_table_unmodifiable = is_table_immutable(test_table)
	local are_table_values_unmodified = test_table[1] == 1
	and test_table[2] == 2
	and test_table[3] == 3

	return is_table_correcty_immutable
	and is_table_unmodifiable
	and are_table_values_unmodified
end

TEST.create_immutable_table_using_syntax_sugar = function()
	local test_table = SUT { 1, 2, 3 } -- creates immutable using {} syntax sugar

	local is_table_correcty_immutable = SUT.is_immutable(test_table)
	local is_table_unmodifiable = is_table_immutable(test_table)
	local are_table_values_unmodified = test_table[1] == 1
	and test_table[2] == 2
	and test_table[3] == 3

	return is_table_correcty_immutable
	and is_table_unmodifiable
	and are_table_values_unmodified
end


TEST.make_immutable_returns_same_table_but_immutable = function()
	local test_table = { 1, 2, 3 }
	local new_table = SUT.make( test_table ) -- creates immutable using make function

	local is_table_correcty_immutable = SUT.is_immutable(test_table)
	local is_table_unmodifiable = is_table_immutable(test_table)
	local are_table_values_unmodified = test_table[1] == 1
	and test_table[2] == 2
	and test_table[3] == 3

	local is_new_table_correcty_immutable = SUT.is_immutable(new_table)
	local is_new_table_unmodifiable = is_table_immutable(new_table)
	local are_new_table_values_unmodified = new_table[1] == 1
	and new_table[2] == 2
	and new_table[3] == 3

	return is_table_correcty_immutable
	and is_table_unmodifiable
	and are_table_values_unmodified
	and is_new_table_correcty_immutable
	and is_new_table_unmodifiable
	and are_new_table_values_unmodified
	and new_table == test_table
end

TEST.can_not_modify_entry_in_immutable_table = function()
	local test_table = { 1, 2, 3 }
	local test_immutable_table = SUT.make( test_table )

	local is_modification_impossible = not pcall(function() test_immutable_table[1] = "wrong" end)
	local is_value_unmodified = test_immutable_table[1] == test_table[1]

	return is_modification_impossible and is_value_unmodified
end

TEST.can_not_add_new_entry_to_immutable_table = function()
	local test_table = { 1, 2, 3 }
	local test_immutable_table = SUT.make( test_table )

	local is_modification_impossible = not pcall(function() test_immutable_table[4] = 4 end)
	local is_value_unmodified = test_immutable_table[1] == test_table[1]

	return is_modification_impossible and is_value_unmodified
end

TEST.can_not_remove_entry_from_immutable_table = function()
	local test_table = { 1, 2, 3 }
	local test_immutable_table = SUT.make( test_table )

	local is_modification_impossible = not pcall(function() test_immutable_table[1] = nil end)
	local is_value_unmodified = test_immutable_table[1] == test_table[1]

	return is_modification_impossible and is_value_unmodified
end

TEST.can_not_modify_original_table_too = function()
	local test_table = { 1, 2, 3 }
	local test_immutable_table = SUT.make( test_table )

	local is_modification_impossible = not pcall(function() test_table[1] = 4 end)
	local is_value_unmodified = test_immutable_table[1] == test_table[1]

	return is_modification_impossible and is_value_unmodified
end

TEST.can_not_remove_from_original_table_too = function()
	local test_table = { 1, 2, 3 }
	local test_immutable_table = SUT.make( test_table )

	local is_modification_impossible = not pcall(function() test_table[1] = nil end)
	local is_value_unmodified = test_immutable_table[1] == test_table[1]

	return is_modification_impossible and is_value_unmodified
end

TEST.can_not_insert_to_original_table_too = function()
	local test_table = { 1, 2, 3 }
	local test_immutable_table = SUT.make( test_table )

	local is_modification_impossible = not pcall(function() test_table[4] = 4 end)
	local is_value_unmodified = test_immutable_table[1] == test_table[1]

	return is_modification_impossible and is_value_unmodified
end

TEST.error_when_getting_non_existing_entry = function()
	local test_table = SUT { 1, 2, 3 }

	return not pcall(function() local a = test_table.new_entry end)
end

TEST.error_when_getting_non_existing_entry_can_be_toggled_off = function()
	SUT.option_undefined_key_errors(false)
	local test_table = SUT { width = 10 }
	
	local get_property_by_index_is_nil = false
	local get_property_by_sugar_is_nil = false
	local no_errors, error_msg = pcall(function()
		get_property_by_index_is_nil = test_table["height"] == nil
		get_property_by_sugar_is_nil = test_table.height == nil
	end)
	
	SUT.option_undefined_key_errors(true) -- restore global default value for other tests
	if not no_errors then
		error(error_msg)
	end
	
	return get_property_by_index_is_nil and get_property_by_sugar_is_nil
end

TEST.option_undefined_key_errors_defaults_to_true_on_bad_input = function()
	local default_is_true = SUT.option_undefined_key_errors() == true
	local remains_true_on_string = SUT.option_undefined_key_errors("not a boolean")
	local number = SUT.option_undefined_key_errors(5)
	local table = SUT.option_undefined_key_errors({})
	local func = SUT.option_undefined_key_errors(function() end)

	return default_is_true and remains_true_on_string or number or table or func
end

TEST.error_when_getting_out_of_bounds_entry = function()
	local test_table = SUT { 1, 2, 3 }

	return not pcall(function() local a = test_table[4] end)
end

TEST.error_when_getting_entries_in_loops_local_iterator = function()
	local test_table = SUT { 1, 2, 3 }

	local success = true
	-- Manually iterate and check immutability
	for i = 1, #test_table do
		local ok = pcall(function()
			local value = test_table[i]
			test_table[i] = 9
		end)
		if ok then
			success = false
			break
		end
	end

	return success
end

TEST.error_when_setting_entries_in_loops_pairs = function()
	local test_table = SUT { 1, 2, 3 }

	local success = true
	for key, value in pairs(test_table) do
		local ok = pcall(function()
			test_table[key] = 9
		end)
		if ok then
			success = false
			break
		end
	end

	return success
end


TEST.error_when_setting_entries_in_loops_ipairs = function()
	local test_table = SUT { 1, 2, 3 }

	local success = true
	for i, value in ipairs(test_table) do
		local ok = pcall(function()
			test_table[i] = 9
		end)
		if ok then
			success = false
			break
		end
	end

	return success
end

TEST.error_when_modifying_entry_in_function = function()
	local test_table = SUT { 1, 2, 3 }

	local function modify_table(tbl)
		tbl[1] = "wrong"
	end

	return not pcall(function() modify_table(test_table) end)
end


TEST.ok_when_getting_entries_in_loops_local_iterator = function()
	local test_table = SUT { 1, 2, 3 }

	local success = true
	-- Manually iterate and check if getting entries is allowed
	for i = 1, #test_table do
		local ok, value = pcall(function()
			return test_table[i]
		end)
		if not ok or value ~= test_table[i] then
			success = false
			break
		end
	end

	return success
end


TEST.ok_when_getting_entries_in_loops_pairs = function()
	local test_table = SUT { 1, 2, 3 }

	local success = true
	for key, original_value in pairs(test_table) do
		local ok, value = pcall(function()
			return test_table[key]
		end)
		if not ok or value ~= original_value then
			success = false
			break
		end
	end

	return success
end


TEST.ok_when_getting_entries_in_loops_ipairs = function()
	local test_table = SUT { 1, 2, 3 }

	local success = true
	for i, original_value in ipairs(test_table) do
		local ok, value = pcall(function()
			return test_table[i]
		end)
		if not ok or value ~= original_value then
			success = false
			break
		end
	end

	return success
end

TEST.ok_when_getting_entry_in_function = function()
	local test_table = SUT { 1, 2, 3 }

	local function get_entry(tbl)
		return tbl[1]
	end

	local original_value = test_table[1]
	local ok, value = pcall(function() return get_entry(test_table) end)

	return ok and value == original_value
end

TEST.ok_when_getting_entry_by_key = function()
	local test_table = SUT { ["test_key"] = 1 }

	local function get_entry(tbl)
		return tbl.test_key
	end

	local original_value = test_table.test_key
	local ok, value = pcall(function() return get_entry(test_table) end)

	return ok and value == original_value
end

TEST.error_when_setting_entry_by_key = function()
	local test_table = SUT { ["test_key"] = 1 }

	local function modify_table(tbl)
		tbl.test_key = "wrong"
	end

	return not pcall(function() modify_table(test_table) end)
end

TEST.can_remake_immutable_table_again = function()
	local test_table = SUT { 1, 2, 3 }

	local is_remake_possible = pcall(function() local new_test_table = SUT( test_table ) end)
	local is_new_table_same = false

	if is_remake_possible then
		local new_test_table = SUT( test_table )
		if new_test_table == test_table then
			is_new_table_same = true
		end
	end

	return is_remake_possible
	and is_new_table_same
end

TEST.can_delete_whole_table = function()
	local test_table = SUT { 1, 2, 3 }

	local is_deletion_possible = pcall(function()
		test_table = nil
	end)

	return is_deletion_possible
	and test_table == nil
end

TEST.json_encoding_of_immutable_table_fails_silently = function()
	local test_table = SUT {
		type = "Wizard",
		level = 9001,
		abilities = {
			"Smoking",
			"Fireworks",
			"Wisdom"
		}
	}

	local json_encoded = ""
	local json_encoding_without_error, json_encoding_error = pcall(function() json_encoded = json.encode(test_table) end)
	if not json_encoding_without_error then
		error(json_encoding_error)
	end

	local encoded_json_is_empty = json_encoded == "{}"

	return encoded_json_is_empty
end

TEST.json_encoding_with_mutable_copy_works = function()
	local test_table = SUT {
		type = "Wizard",
		level = 9001,
		abilities = {
			"Smoking",
			"Fireworks",
			"Wisdom"
		}
	}
	local mutable_copy = SUT.mutable_copy(test_table)

	local json_encoded = ""
	local json_encoding_without_error, json_encoding_error = pcall(function() json_encoded = json.encode(mutable_copy) end)
	if not json_encoding_without_error then
		error(json_encoding_error)
	end

	if json_encoded == "{}" then
		error("Bad JSON encoding, only got: {}")
	end

	local json_decoded = json.decode(json_encoded)
	local type_matches = test_table.type == json_decoded.type
	local level_matches = test_table.level == json_decoded.level
	local abilities_match = test_table.abilities[1] == json_decoded.abilities[1]
	and test_table.abilities[2] == json_decoded.abilities[2]
	and test_table.abilities[3] == json_decoded.abilities[3]

	return type_matches and level_matches and abilities_match
end

TEST.mutable_copy_can_also_copy_regular_tables = function()
	local test_table = {
		type = "Wizard",
		level = 9001,
		abilities = {
			"Smoking",
			"Fireworks",
			"Wisdom"
		}
	}

	local mutable_copy = SUT.mutable_copy(test_table)

	local type_matches = test_table.type == mutable_copy.type
	local level_matches = test_table.level == mutable_copy.level
	local abilities_match = test_table.abilities[1] == mutable_copy.abilities[1]
	and test_table.abilities[2] == mutable_copy.abilities[2]
	and test_table.abilities[3] == mutable_copy.abilities[3]

	mutable_copy.type = "Rogue"
	local mutating_copy_does_not_modify_original = test_table.type ~= mutable_copy.type

	return type_matches and level_matches and abilities_match and mutating_copy_does_not_modify_original
end

-- Known issue: Lua `table` API is not supported
--[[TEST.table_api_inserting_value = function()
	local test_table = SUT { 1, 2, 3 }

	local is_insert_possible, error_message = pcall(function()
		table.insert(test_table, 4)
	end)

	return not is_insert_possible, error_message
end

TEST.table_api_removing_value = function()
	local test_table = SUT { 1, 2, 3 }

	local is_removal_possible, error_message = pcall(function()
		table.remove(test_table, 3)
	end)

	return not is_removal_possible, error_message
end]]

TEST.run_all = function()
	for test_name, test_case in pairs(TEST) do
		if test_name ~= "run_all" then
			local is_succesful, returned_value, error_message = pcall(test_case)
			if is_succesful and returned_value then
				print ("[OK] " .. test_name)
			else
				print ("[X] " .. test_name .. " | Returned: ", returned_value, " | Error: ", error_message)
			end
		end
	end
end

return TEST