do
-- Branch initialization, upvalue captures, in-file global functions:
-- all idiomatic, all zero-diagnostic material under default settings.

local config
if os.getenv("MODE") == "fast" then
	config = { retries = 1 }
else
	config = { retries = 3 }
end
print(config.retries)

local cached = 1
local function getCached()
	return cached
end
print(getCached())
cached = 2
print(getCached())

-- Intentional global function (script style): setting_global warning is
-- correct here — Luacheck's 111 and Selene's unscoped_variables agree —
-- but calling it must NOT be an undefined_variable error.
-- luck: allow(setting_global)
function describeAll(items)
	local lines = {}
	for index, item in ipairs(items) do
		lines[index] = tostring(item)
	end
	return table.concat(lines, "\n")
end

print(describeAll({ 1, 2, 3 }))

local ok, err = pcall(function()
	error("expected")
end)
if not ok then
	print(err)
end

end

do
-- The canonical Lua module pattern. A linter that warns anywhere in this
-- file with default settings has a false-positive bug.
local M = {}

M.version = "1.0.0"

function M.greet(name)
	return "hello, " .. name
end

function M:describe()
	return "module " .. self.version
end

local Counter = {}
Counter.__index = Counter

function Counter.new(start)
	local instance = setmetatable({}, Counter)
	instance.count = start or 0
	return instance
end

function Counter:increment()
	self.count = self.count + 1
	return self.count
end

M.Counter = Counter

return M

end

do
-- Methods that ignore `self`, write-then-read locals, and shadowing that
-- is deliberate. All idiomatic; default lint must stay silent.

local Shape = {}
Shape.__index = Shape

function Shape.new(kind)
	return setmetatable({ kind = kind }, Shape)
end

-- Ignores self on purpose: interface consistency.
function Shape:typeName()
	return "shape"
end

function Shape:kindName()
	return self.kind
end

local shape = Shape.new("circle")
print(shape:typeName(), shape:kindName())

local result
local attempts = 0
repeat
	attempts = attempts + 1
	if attempts >= 2 then
		result = attempts * 10
	end
until result ~= nil
print(result)

end
