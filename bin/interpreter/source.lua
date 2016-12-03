#!/usr/bin/env lua
local parser = require("fusion.core.parsers.source")
parser.inject_loader()

local arg_index = 1
while arg_index <= #arg do
	if arg[arg_index] == "--metadata" then -- return metadata from module
		assert(arg[arg_index + 1], "missing argument to --metadata: module")
		local ok, module = pcall(require, arg[arg_index + 1] ..
			".metadata")
		if not ok then
			error("Could not find module metadata for package: " ..
				arg[arg_index + 1])
		else
			local function check(name)
				assert(module[name], "Missing field: " .. name)
			end
			local opts = {"version", "description", "author", "copyright",
				"license"}
			for _, name in ipairs(opts) do
				check(name)
			end
			for _, name in ipairs(opts) do
				value = module[name]
				_type = type(value)
				if _type == "string" then
					print(("['%s'] = %q"):format(name, value))
				else
					print(("['%s'] = %s"):format(name, tostring(value)))
				end
			end
			break
		end
	elseif arg[arg_index] == "-m" then -- load <module>.main and exit
		local module = arg[arg_index + 1]
		assert(module, "missing argument to -m: module")
		require(module .. ".main")
		break
	elseif arg[arg_index] == "-h" then -- print help
		local usage = {
			("Usage: %s [OPTIONS]"):format(arg[0])
		}
		print(table.concat(usage, "\n"))
		break
	else -- run a file
		local file = assert(arg[arg_index]:match("^.+%.fuse"),
			("Incorrect filetype: %s"):format(arg[arg_index]))
		parser.do_file(file)
		break
	end
	arg_index = arg_index + 1
end