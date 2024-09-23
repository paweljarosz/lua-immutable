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

-- Known issue: Keys referencing `nil` are inaccessible in immutable table
--[[TEST.referencing_nil = function()
	local test_table = SUT { position = nil }

	local is_access_possible, error_message = pcall(function()
		local a = test_table.position
	end)

	return is_access_possible, error_message
end]]

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