--!nolint
--!nocheck
--!native
--[[ ]]
--[==[ a level-two comment: ]] and ]=] do not end it ]==]
--[=[
  multi-line, level one ]]
]=]

-- ===== every kind of type syntax ============================================
type Scalar = number | string | boolean
type Maybe<T> = T?
type Pair<A, B = A> = { first: A, second: B }
type Fn<A..., R...> = (A...) -> R...
type Thunk<T> = () -> T
type Curried = (number) -> (string) -> (boolean) -> ()
type Mixed = { [string]: number, x: number?, read y: string, write z: boolean }
type Both = { a: number } & { b: string } & ((number) -> string)
type Lit = "red" | "green" | true | false | nil
type Gen = <T, U...>(T, U...) -> (T, U...)
type PackDefault<T = string, U... = (number, boolean)> = (T) -> U...
type Typeof = typeof(table.create(1))
type Nested = { { { [string]: { number } } } }
type Prefixed = Host.Thing<number, string>
type LeadingUnion = | number | string
type LeadingAnd = & { x: number } & { y: number }
type OptFn = ((number) -> string)?
type VarFn = (...number) -> ...string
type Named = (first: number, second: string, ...boolean) -> ()
export type Public = { id: number, tag: string? }
export type PublicGeneric<T> = { value: T, next: PublicGeneric<T>? }
type function Identity(t) return t end
export type function Keys(t) return t end
-- the runnable corpus's own types
export type Point = { x: number, y: number }
export type Shade = "light" | "dark"
type MaybeNum = number?
type StrOrNum = string | number
type Callback<T...> = (T...) -> ()
type Transform<In, Out = string> = (In) -> Out
type Dict = { [string]: number }
type Placed = { pos: Point, tags: { string }, meta: { [string]: boolean }? }
type FnField = { run: (self: FnField, n: number) -> number }
type function Echo(t)
	return t
end
-- and what the conformance tests spell besides
type ReadOnly = { read x: number, read y: number }
type WriteOnly = { write sink: (any) -> () }
type Recursive<T> = { value: T, children: { Recursive<T> } }
type Overloaded = ((number) -> number) & ((string) -> string)
type Variadic<T...> = (T...) -> (number, T...)
type Indexer = { [number]: string, n: number }
type Singletons = "a" | "b" | "c" | "\n" | "\u{1F600}"
type NilableFn = (() -> ())?
type ParenPack = () -> (number)
type EmptyPack = () -> ()
type GenericPackFn = <A..., B...>(((A...) -> B...), A...) -> B...
type Typed = typeof(setmetatable({}, { __index = {} }))
type BuiltinKeys = keyof<{ a: number, b: string }>
type BuiltinIndex = index<{ a: number }, "a">
type Unioned = number | string | boolean | nil | { any } | ((...any) -> ...any)
type Bufferish = { data: buffer, at: vector, co: thread, ud: userdata?, any: any, never: never, unknown: unknown }
type function Strip(t)
	if t:is("union") then
		local parts = {}
		for _, c in t:components() do
			if not c:is("nil") then table.insert(parts, c) end
		end
		return types.unionof(table.unpack(parts))
	end
	return t
end
type Stripped = Strip<number?>

-- ===== opaque inputs and mutated globals ====================================
local Host, Sink, Now = _G.Host, _G.Sink, os.clock
local SceneRoot, SceneName = Engine.Scene, Engine.Scene.Root.Children.First.Name
local chunk_args, chunk_count = { ... }, select("#", ...)
counter = 0
registry = registry or {}
registry.chunk = { args = chunk_args, count = chunk_count, root = SceneRoot, name = SceneName, at = Now() }
-- the runnable corpus's operands: assigned, so the compiler can never fold through them
GA, GB, GC = 7, 3, 2
GF = 2.5
GS = "gs"
GNEG = -5
GZERO = 0
GBIG = 1e15
GHEX = 0x2A
local STEP = 0
local function T(tag: string, ...: any)
	STEP += 1
	Sink(STEP, tag, ...)
end
local function banner(name: string)
	Sink("==== " .. name .. " ====")
end
-- strip "path:line: " prefixes from runtime error messages
local function scrub(e: any): string
	return (string.gsub(tostring(e), "^.-:%d+:%s*", ""))
end

-- ===== a metatable class with every metamethod ==============================
local Vec = {}
Vec.__index = Vec
local function isvec(v) return type(v) == "table" and getmetatable(v) == Vec end
function Vec.new(x: number?, y: number?, z: number?)
	return setmetatable({ x = x or 0, y = y or 0, z = z or 0 }, Vec)
end
function Vec.__add(a, b)
	if isvec(a) and isvec(b) then return Vec.new(a.x + b.x, a.y + b.y, a.z + b.z)
	elseif isvec(a) then return Vec.new(a.x + b, a.y + b, a.z + b) end
	return b + a
end
function Vec.__sub(a, b) return a + (-b) end
function Vec.__unm(a) return Vec.new(-a.x, -a.y, -a.z) end
function Vec.__mul(a, b)
	local va, vb = isvec(a), isvec(b)
	return if va and vb then a.x * b.x + a.y * b.y + a.z * b.z
		elseif va then Vec.new(a.x * b, a.y * b, a.z * b)
		else Vec.new(a * b.x, a * b.y, a * b.z)
end
function Vec.__div(a, b) return Vec.new(a.x / b, a.y / b, a.z / b) end
function Vec.__idiv(a, b) return Vec.new(a.x // b, a.y // b, a.z // b) end
function Vec.__mod(a, b) return Vec.new(a.x % b, a.y % b, a.z % b) end
function Vec.__pow(a, b) return Vec.new(a.x ^ b, a.y ^ b, a.z ^ b) end
function Vec.__eq(a, b) return a.x == b.x and a.y == b.y and a.z == b.z end
function Vec.__lt(a, b) return a:len2() < b:len2() end
function Vec.__le(a, b) return not (b < a) end
function Vec.__len(a) return 3 end
function Vec.__concat(a, b) return tostring(a) .. tostring(b) end
function Vec.__call(self, field, ...) local v = self[field]; if select("#", ...) > 0 then self[field] = (...) end return v end
function Vec.__tostring(a) return `<{a.x}, {a.y}, {a.z}>` end
function Vec.__iter(a) local i = 0; local names = { "x", "y", "z" } return function() i += 1; local n = names[i]; if n then return n, a[n] end end end
function Vec:len2() return self.x ^ 2 + self.y ^ 2 + self.z ^ 2 end
function Vec:len() return math.sqrt(self:len2()) end
function Vec:unit(): any local l = self:len() return if l == 0 then self else self / l end
function Vec:each(f, ...) for k, v in self do self[k] = f(v, k, ...) end return self end
function Vec.lerp(a, b, t: number) return a + (b - a) * t end
registry.Vec = Vec

-- ===== inheritance, mixins, proxies, __newindex, weak caches ================
local Class do
	local function construct(klass, ...)
		local instance = setmetatable({}, klass)
		local ctor = klass.init
		if ctor then ctor(instance, ...) end
		return instance
	end
	function Class(name, base, ...)
		local klass = { __name = name, super = base }
		klass.__index = klass
		for i = 1, select("#", ...) do
			for key, value in pairs((select(i, ...))) do
				if klass[key] == nil then klass[key] = value end
			end
		end
		return setmetatable(klass, { __index = base, __call = construct, __tostring = function() return "class " .. name end })
	end
end
local Named = { describe = function(self) return self.__name or self.name end }
local Counted = { tally = 0, bump = function(self, by) self.tally += by or 1; return self end }
local Animal = Class("Animal", nil, Named, Counted)
function Animal:init(name, legs) self.name, self.legs = name, legs or 4 end
function Animal:speak(...) return self.name .. " says " .. table.concat({ ... }, ", ") end
local Dog = Class("Dog", Animal)
function Dog:init(name) Animal.init(self, name, 4); self.tricks = {} end
function Dog:learn(trick, ...) table.insert(self.tricks, trick); return if select("#", ...) > 0 then self:learn(...) else self end
function Dog:speak(...) return Animal.speak(self, "woof", ...) end
Sink(Dog("rex"):learn("sit", "roll", "beg"):bump(2):speak("hi", Host.name), tostring(Animal), Dog.super == Animal)

local function observable(target, onread, onwrite)
	local shadow = {}
	for k, v in next, target do shadow[k], target[k] = v, nil end
	return setmetatable(target, {
		__index = function(_, k) local v = rawget(shadow, k); if onread then onread(k, v) end return v end,
		__newindex = function(t, k, v)
			local old = shadow[k]
			if old == v then return end
			shadow[k] = v
			if onwrite and onwrite(k, v, old) == false then shadow[k] = old end
		end,
		__len = function() return rawlen(shadow) end,
		__iter = function() return next, shadow end,
		__metatable = "locked",
	})
end
local function memoize(f, weak)
	local root, NIL = setmetatable({}, weak and { __mode = "k" } or nil), newproxy(true)
	return function(...)
		local node, n = root, select("#", ...)
		for i = 1, n do
			local arg = select(i, ...)
			if arg == nil then arg = NIL end
			local nextnode = node[arg]
			if not nextnode then nextnode = {}; node[arg] = nextnode end
			node = nextnode
		end
		if node.result == nil then node.result = table.pack(f(...)) end
		return table.unpack(node.result, 1, node.result.n)
	end
end
registry.observable, registry.memoize = observable, memoize

-- ===== signals: closures that mutate each other's upvalues ==================
local function Signal(name: string, ...)
	local listeners, nextid, firing, doomed = {}, 1, 0, nil
	local defaults = table.pack(...)
	local object
	local function sweep()
		if firing > 0 or not doomed then return end
		for i = #listeners, 1, -1 do
			if doomed[listeners[i].id] then table.remove(listeners, i) end
		end
		doomed = nil
	end
	object = setmetatable({
		connect = function(self, fn, once)
			local id = nextid
			nextid += 1
			listeners[#listeners + 1] = { id = id, fn = fn, once = once }
			return function()
				doomed = doomed or {}
				doomed[id] = true
				sweep()
				return self, id
			end
		end,
		wait = function(self)
			local co = coroutine.running()
			self:connect(function(...) coroutine.resume(co, ...) end, true)
			return coroutine.yield()
		end,
	}, {
		__len = function() return #listeners end,
		__tostring = function() return `Signal<{name}:{#listeners}:{firing}>` end,
		__call = function(self, ...)
			local count, args = 0, select("#", ...) > 0 and table.pack(...) or defaults
			firing += 1
			for index, listener in listeners do
				if doomed and doomed[listener.id] then continue end
				local ok, err = pcall(listener.fn, table.unpack(args, 1, args.n))
				if not ok then Sink(name, index, err); break end
				count += 1
				if listener.once then
					doomed = doomed or {}
					doomed[listener.id] = true
				end
			end
			firing -= 1
			sweep()
			return count, self
		end,
	})
	return object
end
registry.Signal = Signal

-- ===== a tokenizer, a Pratt parser and a tree-walking interpreter ===========
local Lang = {}
function Lang.tokenize(src: string)
	local tokens, pos, len = {}, 1, #src
	local function push(kind, text, at) tokens[#tokens + 1] = { kind = kind, text = text, at = at } end
	while pos <= len do
		local c = string.sub(src, pos, pos)
		if c:match("%s") then
			pos += 1
		elseif c == "#" then
			repeat pos += 1 until pos > len or src:sub(pos, pos) == "\n"
		elseif c:match("[%a_]") then
			local stop = select(2, src:find("^[%w_]*", pos))
			push("name", src:sub(pos, stop), pos)
			pos = stop + 1
		elseif c:match("%d") then
			local s, e = src:find("^%d+%.?%d*", pos)
			local nextc = src:sub(e + 1, e + 1)
			if nextc == "e" or nextc == "E" then
				local _, e2 = src:find("^[eE][+-]?%d+", e + 1)
				e = e2 or error(`bad exponent at {e}`, 2)
			end
			push("num", tonumber(src:sub(s, e)), s)
			pos = e + 1
		elseif c == '"' or c == "'" then
			local buffer, i, closed = {}, pos + 1, false
			while i <= len do
				local d = src:sub(i, i)
				if d == c then closed = true; break
				elseif d == "\\" then
					i += 1
					local esc = src:sub(i, i)
					buffer[#buffer + 1] = ({ n = "\n", t = "\t", ["\\"] = "\\", ['"'] = '"' })[esc] or esc
				else
					buffer[#buffer + 1] = d
				end
				i += 1
			end
			if not closed then error({ code = "unterminated", at = pos }) end
			push("str", table.concat(buffer), pos)
			pos = i + 1
		else
			local two = src:sub(pos, pos + 1)
			if two == "==" or two == "~=" or two == "<=" or two == ">=" or two == ".." or two == "//" then
				push("op", two, pos); pos += 2
			else
				push("op", c, pos); pos += 1
			end
		end
	end
	push("eof", "<eof>", pos)
	return tokens
end
local BINARY = {
	["or"] = { 1, 2 }, ["and"] = { 3, 4 },
	["=="] = { 5, 6 }, ["~="] = { 5, 6 }, ["<"] = { 7, 8 }, [">"] = { 7, 8 }, ["<="] = { 7, 8 }, [">="] = { 7, 8 },
	[".."] = { 10, 9 }, ["+"] = { 11, 12 }, ["-"] = { 11, 12 },
	["*"] = { 13, 14 }, ["/"] = { 13, 14 }, ["//"] = { 13, 14 }, ["%"] = { 13, 14 }, ["^"] = { 18, 17 },
}
function Lang.parse(tokens)
	local at = 1
	local expression, statement, block
	local function peek(o) return tokens[at + (o or 0)] end
	local function take() local t = tokens[at]; at += 1; return t end
	local function accept(text) if peek().text == text and peek().kind ~= "str" then at += 1; return true end return false end
	local function expect(text) if not accept(text) then error(`expected {text} near {peek().text} @ {peek().at}`) end end
	local function arguments()
		local list = {}
		if not accept(")") then
			repeat list[#list + 1] = expression(0) until not accept(",")
			expect(")")
		end
		return list
	end
	local function primary()
		local t = take()
		if t.kind == "num" or t.kind == "str" then return { tag = "lit", value = t.text }
		elseif t.text == "(" then local e = expression(0); expect(")"); return e
		elseif t.text == "{" then
			local items = {}
			while not accept("}") do
				if peek().kind == "name" and peek(1).text == "=" then
					local key = take().text; take()
					items[#items + 1] = { key = key, value = expression(0) }
				else
					items[#items + 1] = { value = expression(0) }
				end
				if not accept(",") then expect("}"); break end
			end
			return { tag = "table", items = items }
		elseif t.text == "fn" then
			expect("(")
			local params = {}
			if not accept(")") then
				repeat params[#params + 1] = take().text until not accept(",")
				expect(")")
			end
			return { tag = "fn", params = params, body = block() }
		elseif t.text == "not" or t.text == "-" or t.text == "#" then
			return { tag = "un", op = t.text, value = expression(15) }
		elseif t.text == "nil" or t.text == "true" or t.text == "false" then
			return { tag = "lit", value = (({ ["true"] = true, ["false"] = false })[t.text]) }
		elseif t.kind == "name" then
			return { tag = "var", name = t.text }
		end
		error({ code = "unexpected", token = t })
	end
	local function suffixed()
		local e = primary()
		while true do
			if accept("(") then e = { tag = "call", fn = e, args = arguments() }
			elseif accept("[") then local k = expression(0); expect("]"); e = { tag = "index", object = e, key = k }
			elseif accept(".") then e = { tag = "index", object = e, key = { tag = "lit", value = take().text } }
			else return e end
		end
	end
	function expression(limit)
		local left = suffixed()
		while true do
			local op = peek()
			local rule = op.kind ~= "str" and BINARY[op.text]
			if not rule or rule[1] <= limit then return left end
			take()
			left = { tag = "bin", op = op.text, left = left, right = expression(rule[2]) }
		end
	end
	function statement()
		if accept("if") then
			local arms, otherwise = {}, nil
			repeat
				local cond = expression(0)
				arms[#arms + 1] = { cond = cond, body = block() }
			until not accept("elif")
			if accept("else") then otherwise = block() end
			return { tag = "if", arms = arms, otherwise = otherwise }
		elseif accept("while") then
			local cond = expression(0)
			return { tag = "while", cond = cond, body = block() }
		elseif accept("let") then
			local name = take().text
			expect("=")
			return { tag = "let", name = name, value = expression(0) }
		elseif accept("return") then
			return { tag = "return", value = if peek().text == "}" then nil else expression(0) }
		elseif accept("break") then
			return { tag = "break" }
		end
		local target = expression(0)
		if accept("=") then return { tag = "set", target = target, value = expression(0) } end
		return { tag = "expr", value = target }
	end
	function block()
		expect("{")
		local list = {}
		while not accept("}") do
			list[#list + 1] = statement()
			accept(";")
		end
		return list
	end
	local program = {}
	while peek().kind ~= "eof" do program[#program + 1] = statement(); accept(";") end
	return program
end
do
	local BREAK, RETURN = newproxy(), newproxy()
	local exec
	local function child(env) return setmetatable({ vars = {}, up = env }, getmetatable(env)) end
	local function lookup(env, name)
		local scope = env
		while scope do
			local v = scope.vars[name]
			if v ~= nil then return v, scope end
			scope = scope.up
		end
		return nil, nil
	end
	local eval
	local ops = {
		["+"] = function(a, b) return a + b end, ["-"] = function(a, b) return a - b end,
		["*"] = function(a, b) return a * b end, ["/"] = function(a, b) return a / b end,
		["//"] = function(a, b) return a // b end, ["%"] = function(a, b) return a % b end,
		["^"] = function(a, b) return a ^ b end, [".."] = function(a, b) return a .. b end,
		["=="] = function(a, b) return a == b end, ["~="] = function(a, b) return a ~= b end,
		["<"] = function(a, b) return a < b end, [">"] = function(a, b) return a > b end,
		["<="] = function(a, b) return a <= b end, [">="] = function(a, b) return a >= b end,
	}
	function eval(node, env)
		local tag = node.tag
		if tag == "lit" then return node.value
		elseif tag == "var" then return (lookup(env, node.name))
		elseif tag == "bin" then
			if node.op == "and" then local l = eval(node.left, env); return if l then eval(node.right, env) else l
			elseif node.op == "or" then local l = eval(node.left, env); return if l then l else eval(node.right, env) end
			return ops[node.op](eval(node.left, env), eval(node.right, env))
		elseif tag == "un" then
			local v = eval(node.value, env)
			if node.op == "not" then return not v elseif node.op == "-" then return -v end
			return #v
		elseif tag == "index" then return eval(node.object, env)[eval(node.key, env)]
		elseif tag == "table" then
			local t, n = {}, 0
			for _, item in ipairs(node.items) do
				if item.key then t[item.key] = eval(item.value, env) else n += 1; t[n] = eval(item.value, env) end
			end
			return t
		elseif tag == "call" then
			local fn, args = eval(node.fn, env), {}
			for i, a in node.args do args[i] = eval(a, env) end
			return fn(table.unpack(args, 1, #node.args))
		elseif tag == "fn" then
			return function(...)
				local scope, values = child(env), { ... }
				for i, name in node.params do scope.vars[name] = values[i] end
				local signal, value = exec(node.body, scope)
				if signal == RETURN then return value end
				return nil
			end
		end
		error("bad node " .. tostring(tag))
	end
	function exec(list, env)
		for _, s in list do
			local tag = s.tag
			if tag == "let" then env.vars[s.name] = eval(s.value, env)
			elseif tag == "expr" then eval(s.value, env)
			elseif tag == "set" then
				local target = s.target
				if target.tag == "var" then
					local _, scope = lookup(env, target.name);
					(scope or env).vars[target.name] = eval(s.value, env)
				else
					eval(target.object, env)[eval(target.key, env)] = eval(s.value, env)
				end
			elseif tag == "if" then
				local done = false
				for _, arm in s.arms do
					if eval(arm.cond, env) then
						local signal, value = exec(arm.body, child(env))
						if signal then return signal, value end
						done = true
						break
					end
				end
				if not done and s.otherwise then
					local signal, value = exec(s.otherwise, child(env))
					if signal then return signal, value end
				end
			elseif tag == "while" then
				while eval(s.cond, env) do
					local signal, value = exec(s.body, child(env))
					if signal == BREAK then break elseif signal == RETURN then return signal, value end
				end
			elseif tag == "return" then
				return RETURN, s.value and eval(s.value, env)
			elseif tag == "break" then
				return BREAK
			end
		end
		return nil
	end
	function Lang.run(src, globals)
		local env = setmetatable({ vars = globals or {} }, { __tostring = function(e) return "env" end })
		local signal, value = exec(Lang.parse(Lang.tokenize(src)), env)
		return value, signal == RETURN, env
	end
end
registry.Lang = Lang

-- ===== JSON both ways: recursion, escapes, string building ==================
local Json = {}
do
	local ESC = { ['"'] = '\\"', ["\\"] = "\\\\", ["\b"] = "\\b", ["\f"] = "\\f", ["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t" }
	local function quote(s) return '"' .. s:gsub('[%c"\\]', function(c) return ESC[c] or string.format("\\u%04x", c:byte()) end) .. '"' end
	local function encode(value, stack, indent, depth)
		local kind = typeof(value)
		if kind == "nil" then return "null"
		elseif kind == "boolean" then return tostring(value)
		elseif kind == "number" then
			if value ~= value or value == math.huge or value == -math.huge then error("not representable: " .. value) end
			return if value % 1 == 0 and math.abs(value) < 2 ^ 53 then string.format("%d", value) else string.format("%.17g", value)
		elseif kind == "string" then return quote(value)
		elseif kind ~= "table" then error(`cannot encode {kind}`) end
		if stack[value] then error("cycle") end
		stack[value] = true
		local parts, keys, n = {}, {}, rawlen(value)
		local nl = if indent then "\n" .. string.rep(indent, depth + 1) else ""
		if n > 0 or next(value) == nil then
			for i = 1, n do parts[i] = encode(value[i], stack, indent, depth + 1) end
			stack[value] = nil
			return "[" .. nl .. table.concat(parts, "," .. nl) .. (if indent then "\n" .. indent:rep(depth) else "") .. "]"
		end
		for k in value do keys[#keys + 1] = k end
		table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
		for i, k in ipairs(keys) do parts[i] = quote(tostring(k)) .. (indent and ": " or ":") .. encode(value[k], stack, indent, depth + 1) end
		stack[value] = nil
		return `\{{nl}{table.concat(parts, "," .. nl)}{if indent then "\n" .. indent:rep(depth) else ""}}`
	end
	function Json.encode(value, indent) return encode(value, {}, indent, 0) end
	function Json.decode(text)
		local i = 1
		local value
		local function ws() i = text:find("%S", i) or #text + 1 end
		local function fail(what) error(string.format("%s at %d near %q", what, i, text:sub(i, i + 8)), 3) end
		local function str()
			local out, start = {}, i + 1
			i += 1
			while true do
				local c = text:byte(i)
				if not c then fail("eof in string")
				elseif c == 34 then out[#out + 1] = text:sub(start, i - 1); i += 1; return table.concat(out)
				elseif c == 92 then
					out[#out + 1] = text:sub(start, i - 1)
					local e = text:sub(i + 1, i + 1)
					local map = ({ b = "\b", f = "\f", n = "\n", r = "\r", t = "\t" })[e]
					if map then out[#out + 1] = map; i += 2
					elseif e == "u" then out[#out + 1] = utf8.char(tonumber(text:sub(i + 2, i + 5), 16) or fail("bad hex")); i += 6
					else out[#out + 1] = e; i += 2 end
					start = i
				else i += 1 end
			end
		end
		function value()
			ws()
			local c = text:sub(i, i)
			if c == "{" then
				local t = {}
				i += 1; ws()
				if text:sub(i, i) == "}" then i += 1; return t end
				repeat
					ws()
					local k = str()
					ws()
					if text:sub(i, i) ~= ":" then fail("expected colon") end
					i += 1
					t[k] = value()
					ws()
					local d = text:sub(i, i)
					i += 1
				until d ~= "," or (d == "}" and false)
				return t
			elseif c == "[" then
				local t, n = {}, 0
				i += 1; ws()
				if text:sub(i, i) == "]" then i += 1; return t end
				while true do
					n += 1
					t[n] = value()
					ws()
					local d = text:sub(i, i)
					i += 1
					if d == "]" then break elseif d ~= "," then fail("expected comma") end
				end
				return t
			elseif c == '"' then return str()
			elseif text:find("^true", i) then i += 4; return true
			elseif text:find("^false", i) then i += 5; return false
			elseif text:find("^null", i) then i += 4; return nil end
			local s, e = text:find("^-?%d+%.?%d*[eE]?[+-]?%d*", i)
			if not s then fail("bad value") end
			i = e + 1
			return tonumber(text:sub(s, e))
		end
		local result = value()
		ws()
		if i <= #text then fail("trailing data") end
		return result
	end
end
registry.Json = Json

-- ===== coroutines of every kind =============================================
local function generate(a, b, step)
	return coroutine.wrap(function()
		for i = a, b, step or 1 do
			local reply = coroutine.yield(i, i * i)
			if reply == "stop" then return "stopped", i end
			if reply then a += reply end
		end
		return "done"
	end)
end
local function scheduler()
	local ready, sleeping, clock, log = {}, {}, 0, table.create(16)
	local api = {}
	function api.spawn(fn, ...)
		local co = if type(fn) == "thread" then fn else coroutine.create(fn)
		ready[#ready + 1] = { co = co, args = table.pack(...) }
		return co
	end
	function api.sleep(t) return coroutine.yield("sleep", t) end
	function api.run(limit)
		local steps = 0
		while #ready > 0 or next(sleeping) do
			if #ready == 0 then
				local soonest, slot = math.huge, nil
				for i, s in ipairs(sleeping) do
					if s.at < soonest then soonest, slot = s.at, i end
				end
				if slot == nil then break end
				clock = soonest
				ready[1] = table.remove(sleeping, slot)
				ready[1].args = table.pack(clock)
			end
			local task = table.remove(ready, 1)
			local results = table.pack(coroutine.resume(task.co, table.unpack(task.args, 1, task.args.n)))
			steps += 1
			if not results[1] then
				log[#log + 1] = debug.traceback(task.co, tostring(results[2]))
				coroutine.close(task.co)
			elseif coroutine.status(task.co) == "dead" then
				log[#log + 1] = { done = task.co, n = results.n }
			elseif results[2] == "sleep" then
				sleeping[#sleeping + 1] = { co = task.co, at = clock + (results[3] or 0) }
			else
				ready[#ready + 1] = { co = task.co, args = table.pack(table.unpack(results, 2, results.n)) }
			end
			if limit and steps >= limit then return false, steps, log end
		end
		return true, steps, log
	end
	return api, coroutine.isyieldable(), coroutine.running()
end
registry.generate, registry.scheduler = generate, scheduler

-- ===== codecs: buffer, bit32, string.pack, utf8, vector =====================
local Codec = {}
function Codec.roundtrip(values, size)
	local b = buffer.create(size or 64)
	local off = 0
	local function w(fn, n, v) fn(b, off, v); off += n end
	w(buffer.writei8, 1, values.i8); w(buffer.writeu8, 1, values.u8)
	w(buffer.writei16, 2, values.i16); w(buffer.writeu16, 2, values.u16)
	w(buffer.writei32, 4, values.i32); w(buffer.writeu32, 4, values.u32)
	w(buffer.writef32, 4, values.f32); w(buffer.writef64, 8, values.f64)
	buffer.writestring(b, off, values.text, #values.text); off += #values.text
	buffer.writebits(b, off * 8, 13, values.bits)
	buffer.fill(b, off + 2, 0xAB, 4)
	local copy = buffer.create(buffer.len(b))
	buffer.copy(copy, 0, b, 0, off)
	return buffer.readi8(copy, 0), buffer.readu8(copy, 1), buffer.readi16(copy, 2), buffer.readu16(copy, 4),
		buffer.readi32(copy, 6), buffer.readu32(copy, 10), buffer.readf32(copy, 14), buffer.readf64(copy, 18),
		buffer.readstring(copy, 26, #values.text), buffer.readbits(b, off * 8, 13), buffer.tostring(copy), buffer.fromstring(values.text)
end
do
	local TABLE = table.create(256, 0)
	for i = 0, 255 do
		local c = i
		for _ = 1, 8 do c = if bit32.btest(c, 1) then bit32.bxor(0xEDB88320, bit32.rshift(c, 1)) else bit32.rshift(c, 1) end
		TABLE[i + 1] = c
	end
	function Codec.crc32(s: string, seed: number?)
		local crc = bit32.bnot(seed or 0)
		for i = 1, #s do crc = bit32.bxor(TABLE[bit32.band(bit32.bxor(crc, s:byte(i)), 255) + 1], bit32.rshift(crc, 8)) end
		return bit32.bnot(crc)
	end
	local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	function Codec.base64(s: string)
		local out, n = {}, 0
		for i = 1, #s, 3 do
			local a, b, c = s:byte(i, i + 2)
			local word = bit32.bor(bit32.lshift(a, 16), bit32.lshift(b or 0, 8), c or 0)
			for j = 0, 3 do
				n += 1
				out[n] = if (j == 2 and not b) or (j == 3 and not c) then "=" else B64:sub(bit32.extract(word, 18 - 6 * j, 6) + 1, bit32.extract(word, 18 - 6 * j, 6) + 1)
			end
		end
		return table.concat(out)
	end
end
function Codec.bits(x, y, n, ...)
	Sink(bit32.arshift(x, n), bit32.band(x, y), bit32.band(x, y, n), bit32.band(...), bit32.bnot(x), bit32.bor(x, y), bit32.bor(x, 1), bit32.btest(x, y), bit32.btest(x, 0xFF))
	Sink(bit32.bxor(x, y), bit32.bxor(x, y, n, 1), bit32.extract(x, n), bit32.extract(x, n, 3), bit32.extract(x, 2, 3), bit32.replace(x, y, n), bit32.replace(x, y, n, 4))
	Sink(bit32.lrotate(x, n), bit32.lshift(x, n), bit32.lshift(x, 3), bit32.rrotate(x, n), bit32.rshift(x, n), bit32.rshift(1024, n), bit32.countlz(x), bit32.countrz(y), bit32.byteswap(x))
end
function Codec.strings(s: string, n: number, ...)
	Sink(s:len(), s:lower(), s:upper(), s:rep(n), s:rep(n, ","), s:reverse(), s:sub(n), s:sub(n, -n), s:sub(2, 3), s:byte(), s:byte(n), s:byte(1, -1))
	Sink(s:find("x"), s:find("x", n), s:find("x", n, true), s:match("(%a+)"), s:match("(%d)(%d)", n), s:gmatch("%w+"), s:split(","), s:split())
	Sink(s:gsub("a", "b"), s:gsub("a", "b", n), s:gsub("%w", { a = "1", b = false }), s:gsub("(%w)(%w)", function(a, b) return b .. a end), s:format(...))
	Sink(string.char(65, 66, n), string.char(), string.char(n), string.format("%5.2f|%-5d|%x|%q|%s|%%|%c|%e|%g|%i|%o|%u|%X|%*d", n, n, n, s, s, n, n, n, n, n, n, n, 4, n))
	Sink(string.pack("<i4 >u2 z s1 B b h H l L f d", n, n, s, s, n, n, n, n, n, n, n, n), string.unpack("<i4", s), string.unpack("<i4 z", s, n), string.packsize("<i4 d"))
	for word, sep in s:gmatch("(%w+)(%p?)") do
		if sep == "" then continue end
		Sink(word:upper() .. sep)
	end
end
function Codec.unicode(s, ...)
	Sink(utf8.char(), utf8.char(0x41), utf8.char(0x1F600, ...), utf8.charpattern, utf8.codepoint(s), utf8.codepoint(s, 2), utf8.codepoint(s, 1, -1), utf8.len(s), utf8.len(s, 2), utf8.len(s, 2, -1), utf8.offset(s, 2), utf8.offset(s, 2, 3))
	for position, code in utf8.codes(s) do
		if code > 127 then Sink(position, code, utf8.char(code)) end
	end
end
function Codec.vectors(a: vector, b: vector, t: number)
	local c = a + b * t - a / t
	Sink(c, -c, c.x, c.y, c.z, c.X, a * b, a // b, a // 2, 2 * a, a == b, a ~= b, vector.create(t, t, t), vector.create(t, 0, 1), vector.create(1, t, 2, 3))
	Sink(vector.magnitude(a), vector.normalize(a), vector.cross(a, b), vector.dot(a, b), vector.angle(a, b), vector.angle(a, b, c), vector.floor(a), vector.ceil(a), vector.abs(a), vector.sign(a))
	Sink(vector.clamp(a, b, c), vector.max(a, b), vector.max(a, b, c), vector.min(a, b), vector.min(a, b, c), vector.lerp(a, b, t), vector.zero, vector.one, typeof(a), type(a))
	return { [a] = b, origin = vector.create(0, 0, 0), up = vector.create(0, 1, 0), diag = vector.one * t }
end
registry.Codec = Codec

-- ===== algorithms over tables, using the whole table library ================
local Algo = {}
function Algo.quicksort(t, lo, hi, less)
	lo, hi, less = lo or 1, hi or #t, less or function(a, b) return a < b end
	while lo < hi do
		local pivot, i, j = t[(lo + hi) // 2], lo, hi
		while i <= j do
			while less(t[i], pivot) do i += 1 end
			while less(pivot, t[j]) do j -= 1 end
			if i <= j then t[i], t[j] = t[j], t[i]; i += 1; j -= 1 end
		end
		if j - lo < hi - i then Algo.quicksort(t, lo, j, less); lo = i
		else Algo.quicksort(t, i, hi, less); hi = j end
	end
	return t
end
function Algo.bfs(graph, start, goal)
	local queue, head, tail, parent = { start }, 1, 1, { [start] = false }
	while head <= tail do
		local node = queue[head]
		head += 1
		if node == goal then
			local path = {}
			repeat
				table.insert(path, 1, node)
				node = parent[node]
			until not node
			return path, #path - 1
		end
		for _, neighbor in ipairs(graph[node] or {}) do
			if parent[neighbor] == nil then
				parent[neighbor] = node
				tail += 1
				queue[tail] = neighbor
			end
		end
	end
	return nil, -1
end
function Algo.lcs(a: string, b: string)
	local prev, cur = table.create(#b + 1, 0), table.create(#b + 1, 0)
	for i = 1, #a do
		for j = 1, #b do
			cur[j + 1] = if a:byte(i) == b:byte(j) then prev[j] + 1 else math.max(prev[j + 1], cur[j])
		end
		prev, cur = cur, prev
	end
	return prev[#b + 1]
end
function Algo.binary(t, x, cmp)
	local lo, hi = 1, #t
	while lo <= hi do
		local mid = lo + (hi - lo) // 2
		local order = if cmp then cmp(t[mid], x) elseif t[mid] < x then -1 elseif t[mid] > x then 1 else 0
		if order == 0 then return mid elseif order < 0 then lo = mid + 1 else hi = mid - 1 end
	end
	return nil, lo
end
function Algo.determinant(m)
	local n, det = #m, 1
	for i = 1, n do
		local best = i
		for r = i + 1, n do if math.abs(m[r][i]) > math.abs(m[best][i]) then best = r end end
		if m[best][i] == 0 then return 0 end
		if best ~= i then m[i], m[best] = m[best], m[i]; det = -det end
		det *= m[i][i]
		for r = i + 1, n do
			local factor = m[r][i] / m[i][i]
			for c = i, n do m[r][c] -= factor * m[i][c] end
		end
	end
	return det
end
function Algo.library(t, u, n, ...)
	table.insert(t, n); table.insert(t, 1, n); table.remove(t); table.remove(t, 1); table.sort(t); table.sort(t, function(a, b) return a > b end)
	Sink(table.concat(t), table.concat(t, ","), table.concat(t, ",", 2), table.concat(t, ",", 2, 3), table.find(t, n), table.find(t, n, 2), table.getn(t), table.maxn(t))
	Sink(table.move(t, 1, 2, 3), table.move(t, 1, 2, 3, u), table.pack(...), table.pack(), table.unpack(t), table.unpack(t, 2), table.unpack(t, 2, 3), table.clone(t), table.freeze(u), table.isfrozen(t), table.create(n), table.create(n, t))
	table.clear(u); table.foreach(t, print); table.foreachi(t, print)
	Sink(rawget(t, n), rawset(t, n, u), rawequal(t, u), rawlen(t), next(t), next(t, n), select("#"), select("#", ...), select(n, ...), select(-1, ...), getmetatable(t), setmetatable(t, u), tostring(t), tonumber(n), tonumber(n, 16), type(t), typeof(t))
	Sink(assert(t), assert(t, n), pcall(error), pcall(error, n), pcall(error, n, 2), xpcall(print, print), xpcall(print, print, n), gcinfo(), collectgarbage("count"), os.time(), os.time({ year = 2020, month = 1, day = 1 }), os.date(), os.date("*t", n), os.difftime(n, n), os.clock(), debug.info(1, "sln"), debug.info(print, "n"), debug.traceback(), debug.traceback("m", 2))
	Sink(math.abs(n), math.acos(n), math.asin(n), math.atan(n), math.atan2(n, 1), math.ceil(n), math.clamp(n, 0, 1), math.cos(n), math.cosh(n), math.deg(n), math.exp(n), math.floor(n), math.fmod(n, 2), math.frexp(n), math.ldexp(n, 2), math.lerp(0, 1, n))
	Sink(math.log(n), math.log(n, 2), math.log10(n), math.map(n, 0, 1, 2, 3), math.max(n, 1), math.max(n, 1, 2), math.min(n, 1), math.min(...), math.modf(n), math.noise(n), math.noise(n, 1), math.noise(n, 1, 2), math.pow(n, 2), math.rad(n), math.random(), math.random(n), math.random(1, n), math.randomseed(n))
	Sink(math.round(n), math.sign(n), math.sin(n), math.sinh(n), math.sqrt(n), math.tan(n), math.tanh(n), math.isnan(n), math.isinf(n), math.isfinite(n), math.pi, math.huge)
end
registry.Algo = Algo

-- ===== closures: capture by value, by reference, through levels =============
local Closures = {}
function Closures.levels(a, ...)
	local byvalue, byref = a.x, a.y
	byref = byref + 1
	local count = select("#", ...)
	return function(b)
		local mid = b + byvalue
		byref += mid
		return function(c)
			local inner = c * mid
			mid -= 1
			return function(d)
				byref, mid, inner = inner, byref, mid
				return function(...)
					a.result = byvalue + byref + mid + inner + d + count + select("#", ...)
					return a, ...
				end
			end
		end
	end
end
function Closures.loops(list)
	local out = {}
	for i = 1, 8 do out[#out + 1] = function() return i end end
	for i = 1, #list do local copy = i * 2; out[#out + 1] = function() copy += 1; return copy, i end end
	for i, v in ipairs(list) do out[i] = function(x) v = x or v; return v, i end end
	for k, v in pairs(list) do if k == "stop" then break end out[k] = function() k, v = v, k end end
	local n = 0
	while n < 4 do n += 1; local fresh = n; if fresh == 2 then continue end out[n] = function() fresh += n; return fresh end end
	repeat local tail = n; out[tail] = function() tail -= 1; return tail end; n -= 1 until tail <= 1
	local shared = 0
	for _ = 1, 3 do out[#out + 1] = function() shared += 1; return shared end end
	return out, function() return shared, n end
end
function Closures.mutual(limit)
	local isodd
	local function iseven(n) if n == 0 then return true end return isodd(n - 1) end
	function isodd(n) if n == 0 then return false end return iseven(n - 1) end
	local function fact(n, acc) if n <= 1 then return acc or 1 end return fact(n - 1, (acc or 1) * n) end
	local fib; fib = function(n) return if n < 2 then n else fib(n - 1) + fib(n - 2) end
	local ackermann = nil
	ackermann = function(m, n) if m == 0 then return n + 1 elseif n == 0 then return ackermann(m - 1, 1) end return ackermann(m - 1, ackermann(m, n - 1)) end
	return iseven(limit), isodd(limit), fact(limit), fib(limit), ackermann(2, limit)
end
function Closures.functional()
	local function curry(f, n, ...)
		n = n or 2
		if n <= select("#", ...) then return f(...) end
		local held = table.pack(...)
		return function(...)
			local merged = table.move({ ... }, 1, select("#", ...), held.n + 1, table.move(held, 1, held.n, 1, {}))
			return curry(f, n, table.unpack(merged, 1, held.n + select("#", ...)))
		end
	end
	local function compose(f, g, ...)
		if g == nil then return f end
		local rest = compose(g, ...)
		return function(...) return f(rest(...)) end
	end
	local function map(t, f) local r = {} for k, v in t do r[k] = f(v, k) end return r end
	local function filter(t, p) local r, n = {}, 0 for _, v in t do if p(v) then n += 1; r[n] = v end end return r, n end
	local function fold(t, f, acc) for _, v in ipairs(t) do acc = f(acc, v) end return acc end
	local function zip(...)
		local lists, n = { ... }, select("#", ...)
		local i = 0
		return function()
			i += 1
			local row = table.create(n)
			for j = 1, n do
				local v = lists[j][i]
				if v == nil then return nil end
				row[j] = v
			end
			return i, table.unpack(row, 1, n)
		end
	end
	return curry, compose, map, filter, fold, zip
end
function Closures.iterators(t)
	local function stateless(s, i) i += 1; local v = s[i]; if v ~= nil then return i, v end end
	for i, v in stateless, t, 0 do Sink(i, v) end
	local function stateful(s) local i = 0 return function() i += 1; return s[i] end end
	for v in stateful(t) do Sink(v) end
	for v, w in (function() local n = 0 return function() n += 1; if n < 3 then return n, n * n end end end)() do Sink(v, w) end
	for a, b, c, d in coroutine.wrap(function() coroutine.yield(1, 2, 3, 4) end) do Sink(a, b, c, d) end
	for k, v in setmetatable({}, { __iter = function(s) return next, t end }) do Sink(k, v) end
	for k, v in t do Sink(k, v) end
	for k in t do Sink(k) end
	for k, v in next, t do Sink(k, v) end
	for k, v in next, t, nil do Sink(k, v) end
	for k, v in pairs(t) do t[k] = nil end
	for i, v in ipairs(t) do i += 1; v = i; Sink(v) end
	for i: number, v: string in ipairs(t) do Sink(i, v) end
	for k: string in t do Sink(k) end
end
registry.Closures = Closures

-- ===== control flow, knotted =================================================
local Flow = {}
function Flow.labyrinth(grid, limit, ...)
	local found, trail = nil, {}
	for y, row in ipairs(grid) do
		local x = 0
		while x < #row do
			x += 1
			local cell = row[x]
			if cell == nil then continue elseif cell == false then break end
			repeat
				local probe = cell.next
				if not probe then break end
				for k, v in pairs(probe) do
					if k == "skip" then continue end
					if v == limit then
						found = function() return x, y, k, v, trail end
						return found, ...
					end
					trail[#trail + 1] = function() x += 1; return v end
				end
				cell = probe
			until cell == row[x] or #trail > limit
		end
	end
	return nil, trail
end
function Flow.machine(input)
	local state, i, out, depth = "start", 1, {}, 0
	while true do
		local c = input:sub(i, i)
		if state == "start" then
			if c == "" then state = "end"; continue end
			state = if c == "(" then "open" elseif c == ")" then "close" else "text"
		elseif state == "open" then
			depth += 1; i += 1; state = "start"
		elseif state == "close" then
			if depth == 0 then return nil, "unbalanced", i end
			depth -= 1; i += 1; state = "start"
		elseif state == "text" then
			local j = i
			repeat j += 1; local d = input:sub(j, j) until d == "" or d == "(" or d == ")"
			out[#out + 1] = { depth = depth, text = input:sub(i, j - 1) }
			i, state = j, "start"
		else
			break
		end
	end
	if depth ~= 0 then return nil, "unclosed", depth end
	return out, #out
end
function Flow.exits(a, b, c, ...)
	do
		if a then return 1 end
	end
	do local x = a; if x then do do return x, ... end end end end
	for i = 1, 3 do
		for j = 1, 3 do
			if i == j then continue end
			if i + j == 5 then break end
			if a == j then return i, j end
			Sink(i, j)
		end
		if b then break end
	end
	while a do
		while b do
			if c then break end
			repeat
				if a then break end
				if b then return ... end
				if c then continue end
				Sink(a)
			until b
			a = nil
		end
		if not a then break else b = c end
	end
	repeat
		local done = a or b
		if done then Sink(done); break end
	until done
	repeat local z = b; if z then break else z = not z end until z
	if a then
		if b then return else return a end
	elseif b then
		do return b end
	else
		return c, b, a
	end
end
function Flow.conditions(a, b, c, d)
	if a then Sink(1) end
	if not a then Sink(2) end
	if a and b then Sink(3) end
	if a or b then Sink(4) end
	if not (a and b) then Sink(5) end
	if not (a or b) then Sink(6) end
	if not a and not b then Sink(7) end
	if a == b then Sink(8) end
	if a ~= b then Sink(9) end
	if a < b then Sink(10) elseif a <= b then Sink(11) elseif a > b then Sink(12) elseif a >= b then Sink(13) else Sink(14) end
	if a == nil then Sink(15) elseif a == true then Sink(16) elseif a == false then Sink(17) elseif a == 1 then Sink(18) elseif a == "s" then Sink(19) end
	if nil == a or true == b or 2 == c or "t" == d then Sink(20) end
	if a ~= nil and b ~= false and c ~= 3 and d ~= "u" then Sink(21) end
	if a < 1 then Sink(22) end if 1 < a then Sink(23) end if a <= 1 then Sink(24) end if 1 <= a then Sink(25) end if a > 1 then Sink(26) end if 1 > a then Sink(27) end if a >= 1 then Sink(28) end if 1 >= a then Sink(29) end
	if not (a < b) then Sink(30) end if not (a <= b) then Sink(31) end if not (a > b) then Sink(32) end if not (a >= b) then Sink(33) end if not (a == b) then Sink(34) end if not (a ~= b) then Sink(35) end
end
function Flow.mixed(a, b, c, d, e)
	if (a and b) or (c and d) then Sink(1) else Sink(2) end
	if (a or b) and (c or d) then Sink(3) end
	if a and (b or (c and (d or e))) then Sink(4) end
	if (((a or b) and c) or d) and e then Sink(5) end
	if not (a and not (b or not c)) then Sink(6) end
	while (a and b) or c do if d or e then break end; a = e end
	repeat a = b until (a or c) and (d or not e)
end
function Flow.values(a, b, c, d)
	Sink(a and b, a or b, a and b or c, a or b and c, (a or b) and c, a and (b or c), not a and b, not (a and b), a and not b, not a or not b)
	Sink(a and 1, a or 1, 1 and a, 1 or a, a and "s", a or "s", a and nil, a or nil, nil and a, nil or a, a and true, a or true, true and a, true or a, a and false, a or false, false and a, false or a)
	Sink(a == b, a ~= b, a < b, a <= b, a > b, a >= b, a == 1, 1 == a, a ~= "s", "s" ~= a, a == nil, nil == a, a ~= true, false == a, a < 1, 1 < a, a <= "s", a > 2, a >= 2, not (a == b), not (a < b))
	Sink(a == b and c, a < b or c, (a == b) == (c == d), (a < b) ~= (c > d), a == (b and c), (a or b) == c, not a == b, not (a == b) and c, a < b and b < c and c < d, a < b or b < c or c < d)
	local x = a and b; local y = a or b; local z = a and b or c; local w = not a; local v = a == b; local u = a < b
	x = x and y; y = y or x; z = z and x or y; w = not w; v = v == u; u = not (u and v)
	local tern = if a then b else c
	local chain = if a then 1 elseif b then 2 elseif c then 3 else 4
	local nested = if (if a then b else c) then (if b then c else d) else (if c then d else a)
	local tall = if a and b then c or d elseif a or b then c and d else not c
	Sink(x, y, z, w, v, u, tern, chain, nested, tall, if x then y else z, (if x then y else z), -(if x then 1 else 2), not (if x then y else z), `{if x then y else z}`, { if x then y else z }, (if x then Sink else print)(z))
end
function Flow.precedence(a, b, c, d)
	Sink(a + b * c, a * b + c, (a + b) * c, a * (b + c), a + b + c, a - b - c, a - (b - c), a / b / c, a / (b / c), a ^ b ^ c, (a ^ b) ^ c, -a ^ b, (-a) ^ b, a ^ -b, 2 ^ -3)
	Sink(a .. b .. c, (a .. b) .. c, a .. (b .. c), a .. b + c, (a .. b) + c, a + b .. c, a * b .. c ^ d, a .. "x" .. b .. "y" .. c, 1 .. a .. 2, "a" .. "b" .. a .. "c" .. "d")
	Sink(a % b, a // b, a % b % c, a // b // c, a % b * c, a // b + c, a + 1, 1 + a, a - 1, 1 - a, a * 2, 2 * a, a / 2, 2 / a, a % 2, 2 % a, a // 2, 2 // a, a ^ 2, 2 ^ a, a ^ 0.5, a * 1.5, 1.5 * a, a // 1.5, 1.5 // a, a % 1.5, 1.5 % a)
	Sink(-a, - -a, not a, not not a, #a, # #a, -#a, not #a, -(-a), not -a, #-a, -not a, - - - a, not not not a)
	Sink(a < b == c, a == b < c, a .. b == c, a + b < c * d, a + b == c - d, not a == not b, -a < -b, #a == #b, #a + #b, #a .. #b, -a .. -b, a < b .. c)
end
registry.Flow = Flow

-- ===== every write, every read ===============================================
local Places = {}
function Places.writes(t, i, j, k, ...)
	local l, m = t.l, t.m
	t.x = i; t["y"] = j; t[1] = k; t[256] = k; t[257] = k; t[i] = j; t[i][j] = k; t.a.b.c = i; t[1][2][3] = j; t["a b"].c = k; t[#t + 1] = i; t[-1] = j; t[0.5] = k; t[true] = i; t[t] = t; t[nil] = i
	t["not an identifier"] = 1; t["end"] = 2; t["nil"] = 3; t[""] = 4; t["1"] = 5; t[1.0] = 6; t[2 ^ 53] = 7; t.very_long_member_name_that_keeps_going_and_going_for_quite_a_while = 8
	l, m = m, l; t.x, t.y = t.y, t.x; t[i], t[j] = t[j], t[i]; i, t[i] = i + 1, 20; t[i], i = 20, i + 1; l, t.l, m = m, l, t.l
	t.a, t.b, t.c, t.d = 1, 2; t.a, t.b = 1, 2, 3; t.a, t.b = ...; t.a, t.b = i, ...; t.a, t.b = Host.pair(); t.a, t.b = i, Host.pair(); t.a, t.b = (Host.pair()); t.a, t.b = (Host.pair()), (...)
	l, l = 1, 2; t.a, t.a = 1, 2; t[i], t[i] = i, j; i, i, i = j, k, l
	t, i = i, t; t.t, t = t, t.t; t[t], t = 1, 2
	l += 1; m -= i; t.x *= 2; t["y"] /= j; t[1] //= 3; t[i] %= j; t.a.b ^= 2; t[i][j] ..= "s"; t[1][2] += k; l ..= m; m ..= "tail"; l ..= 1; m += Host.get(); t.z += ...
	counter += 1; counter ..= "s"; registry.n += i; Engine.Scene.Hits += 1; Engine.Scene.Root.Weight *= j
	Host.get().x = i; Host.get()[1] = j; Host.get().y.z = k; Host.get(i, j).w[k] = l; Host:self().p = m; Host.a.b:c().d = i; Host.a[i]:b().c[j] = k;
	(Host.get()).q = 1;
	(t).r = 2;
	(t.a)[i] = 3;
	((t)).s = 4;
	(t or m).u = 5;
	(function() return t end)().v = 6;
	({})[i] = j;
	("x").y = k;
	return i, j, k, l, m
end
function Places.reads(t, i, j, ...)
	local l = t.l
	Sink(t.x, t["y"], t[1], t[256], t[257], t[i], t[i][j], t.a.b.c, t[1][2][3], t["a b"].c, t[#t], t[-1], t[0.5], t[true], t[t], t["end"], t[l], t[l + 1], t[i .. j], t[(i)], t[-i], t[not i], t[#i])
	Sink(Host.get().x, Host.get()[1], Host.get().y.z, Host.get(i)[j], Host:self().p, (Host.get()).q, (t).r, (t.a)[i], ((t)).s, (t or l).u, (function() return t end)().v, ({ t })[1], ({ k = t }).k, ("x").y, ("x"):len(), (`a{i}`):upper(), (1).x, (nil).x, (true).x, (...).x, (...)[i], (...):m())
	Sink(global_never_written, global_never_written.field, global_never_written.field.field2, global_never_written.field.field2.field3, global_never_written.field.field2.field3.field4, counter, counter.x, registry.chunk.args, _G, _G.x, _G["x y"], _VERSION, Engine["Scene"], Engine["Scene"]["Root"])
	Sink(math, math.nope, string, table.nope, bit32, utf8, os, debug, buffer, vector, coroutine, self, shared, script, game, workspace)
	local shadow = t; do local shadow = shadow.x; do local shadow = shadow.y; Sink(shadow) end; Sink(shadow) end; Sink(shadow)
	local math = { abs = t }; Sink(math.abs(i), math.floor)
	local type = t.ty; Sink(type(i)); local select = j; Sink(select("#", ...))
	local i = i; local j, i = i, j; local t = t or i; Sink(i, j, t)
end
registry.Places = Places

-- ===== calls, in every spelling ==============================================
local Calls = {}
function Calls.spellings(f, t, s, n, ...)
	f(); f(n); f(n, s); f(n, s, t); f(...); f(n, ...); f(n, s, ...); f(f()); f(n, f()); f(f(), n); f((f())); f(n, (f())); f((...)); f(n, (...)); f(f(f())); f(f(), f()); f(f(), f(), f())
	f"str"; f'str'; f[[long]]; f[==[long]==]; f{}; f{1}; f{k = 1}; f{ f() }; t.f"str"; t.f{}; t.f[[x]]; t:m"str"; t:m'str'; t:m{}; t:m{1, 2}; t:m[[x]]; t.a.b:c"str"; t[n]"str"; t[n]{}; f"a""b"; f{}{}{}; f"a"{}[[b]]"c"{d = 1}(n)
	t.f(); t.f(n); t["f"](n); t[1](n); t[n](s); t.a.b.c(n); t.a[n].c(s); f().g(); f()(); f()()(); f(n)(s)(t); f().g().h(); f():m(); f():m():n(); f().g:m(); f()[n](); f()[n]:m(n); t:m():n():o()
	t:m(); t:m(n); t:m(n, s); t:m(...); t:m(n, ...); t:m(f()); t:m(n, f()); t.a:m(n); t.a.b:m(n); t[n]:m(s); t[n][s]:m(t); t["k k"]:m(); t[1]:m();
	(f)();
	(t.f)(n);
	(t[n])(s);
	(f or t)(n);
	(f and t)(s);
	((f))();
	(function() end)();
	(function(...) return ... end)(n, ...);
	(function(a, b) return a + b end)(n, s);
	(if n then f else t)(s);
	({})();
	({ f })[1](n);
	("x")();
	(n + 1)();
	(t):m();
	(t.a):m(n);
	(t or f):m(n);
	(f()):m(s);
	("x"):rep(n);
	("%d"):format(n);
	(`x{n}`):rep(2);
	({}):m();
	(1):m();
	(nil):m();
	(n + 1):m(s);
	t:a_very_long_method_name_used_only_to_push_the_name_constant_out_of_the_short_range(n)
	Host.deep.path:method(n); Host.deep["path x"]:method(n); Engine.Scene:Find(n):Parent():Name(); registry.chunk:m(); counter:m(); _G:m(); s:upper():lower():rep(2):sub(1, n):len()
	local a = f(); local b, c = f(); local d, e, g = n, f(); local h = (f()); local i, j = (f()); local k, l = f(), f(); local m, o = ...; local p = ...; local q = (...); local r, u, v = n, ...; local w = f(...); local x, y = t:m(...)
	Sink(a, b, c, d, e, g, h, i, j, k, l, m, o, p, q, r, u, v, w, x, y)
	Sink({ f() }, { f(), n }, { n, f() }, { (f()) }, { ... }, { ..., n }, { n, ... }, { (...) }, { t:m() }, { n, t:m() })
	Sink(pcall(f), pcall(f, n), pcall(f, n, s, t), pcall(f, ...), pcall(f, n, f()), pcall(t.f, n), pcall(t.f, t, n), pcall(function(...) return ... end), select(pcall(f, n)), (pcall(f)))
	if n then return f() elseif s then return (f()) elseif t then return f(), n elseif f then return n, f() elseif a then return ... elseif b then return (...) elseif c then return n, ... elseif d then return t:m() elseif e then return n, t:m() else return end
end
registry.Calls = Calls

-- ===== tables, in every layout ===============================================
local Tables = {}
function Tables.layouts(a, b, c, ...)
	Sink({}, { nil }, { nil, nil }, { a, nil }, { nil, a }, { a, nil, b }, { a; b; c }, { a, b; c, }, { k = a; j = b, }, { [a] = b; [b] = c, })
	Sink({ 1 }, { 1, 2, 3 }, { 1.5, 2.5 }, { "a", "b" }, { true, false }, { true, false, nil }, { 1, "a", true, nil, 2.5 }, { 1, 2, a }, { a, 1, 2 }, { 1, a, 2 })
	Sink({ k = 1 }, { k = "s" }, { k = true }, { k = nil }, { k = 1.5 }, { x = 1, y = 2, z = 3 }, { x = a, y = b, z = c }, { x = 1, y = a, z = "s", w = true, v = nil }, { x = { y = { z = { w = a } } } })
	Sink({ ["k"] = 1 }, { ["k k"] = a }, { ["end"] = b }, { [1] = a }, { [2] = a }, { [1] = a, [2] = b, [3] = c }, { [3] = c, [1] = a }, { [0] = a }, { [-1] = a }, { [1.5] = a }, { [true] = a }, { [false] = b }, { [a] = 1 }, { [a] = b }, { [a.k] = b.k }, { [a[1]] = b[1] }, { [f()] = 1 }, { [a + 1] = b * 2 }, { [`k{a}`] = b }, { [{}] = {} }, { [function() end] = function() end })
	Sink({ k = 1, k = 2 }, { k = a, k = b }, { [1] = a, a }, { a, [1] = b }, { [1] = a, [1] = b }, { k = a, ["k"] = b }, { a, k = b, c, j = a, b, [c] = a, a })
	Sink({ f() }, { f(), a }, { a, f() }, { (f()) }, { f(), f() }, { ... }, { a, ... }, { ..., a }, { (...) }, { a, (...) }, { k = ... }, { k = f() }, { [...] = ... }, { [f()] = f() }, { k = (...), a, ... }, { a = 1, f() }, { f(), a = 1 }, { a = 1, ... })
	Sink({ {} }, { {}, {} }, { { {} } }, { { { { { { { {} } } } } } } }, { { a }, { b }, { k = { j = { c } } } }, { { 1, 2 }, { 3, 4 } }, { x = {}, y = {} }, { [{}] = { [{}] = {} } }, { {}, k = {}, [a] = {} })
	Sink({ function() end }, { function() return a end, function() return b end }, { f = function(self) return self end, g = function(self, ...) return self, ... end }, { function(...) return ... end, k = function() return c end, [a] = function() end })
	Sink({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 }, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 }, { a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a }, { a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a })
	Sink({ a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, ... })
	Sink({ a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, a, b, c, f() })
	Sink({ k1 = a, k2 = a, k3 = a, k4 = a, k5 = a, k6 = a, k7 = a, k8 = a, k9 = a, k10 = a, k11 = a, k12 = a, k13 = a, k14 = a, k15 = a, k16 = a, k17 = a, k18 = a, k19 = a, k20 = a, k21 = a, k22 = a, k23 = a, k24 = a, k25 = a, k26 = a, k27 = a, k28 = a, k29 = a, k30 = a, k31 = a, k32 = a, k33 = a })
	Sink({ k1 = 1, k2 = 2, k3 = 3, k4 = 4, k5 = 5, k6 = 6, k7 = 7, k8 = 8, k9 = 9, k10 = 10, k11 = 11, k12 = 12, k13 = 13, k14 = 14, k15 = 15, k16 = 16, k17 = 17, k18 = 18, k19 = 19, k20 = 20, k21 = 21, k22 = 22, k23 = 23, k24 = 24, k25 = 25, k26 = 26, k27 = 27, k28 = 28, k29 = 29, k30 = 30, k31 = 31, k32 = 32, k33 = 33 })
	Sink(#{}, #{ 1, 2, 3 }, #{ ... }, ({}).k, ({ k = a }).k, ({ a })[1], ({ ... })[1], ({ ... })[a], ({ a })[1] == nil)
end
function Tables.building(n, ...)
	local t = {}
	t.a = 1; t.b = 2; t.c = 3
	local u = {}
	u[1] = n; u[2] = n; u[3] = n
	local v = { x = n }
	v.y = n; v.x = v.y; v[1] = v
	local w = { n }
	w[#w + 1] = n
	local shape1, shape2 = { x = 0, y = 0 }, { x = 1, y = 1 }
	shape1.x, shape2.y = shape2.x, shape1.y
	local grid = {}
	for r = 1, n do grid[r] = {}; for col = 1, n do grid[r][col] = r * col end end
	for i = 1, 4 do t[i] = { i, k = i, [i] = i, [i + 1] = { i } } end
	local proto = { __index = t, __newindex = function(s, k, v) rawset(s, k, v) end, __mode = "kv", __metatable = false, __call = function(s, ...) return s, ... end, __namecall = nil }
	local o = setmetatable({}, proto)
	o.field = n; Sink(o.field, o.a, o(n, ...), getmetatable(o), rawget(o, "a"))
	return t, u, v, w, shape1, shape2, grid
end
registry.Tables = Tables

-- ===== local scope, declaration shapes, new statement forms ==================
local Scope = {}
function Scope.declarations(a, ...)
	local p; local q, r; local s, t, u = 1; local v = nil; local w, x = nil, nil; local y = a; local z = y
	local aa: number = 1; local ab: string?, ac: { number } = nil, {}; local ad = a :: any; local ae = (a :: any) :: number; local af = a.b :: any
	Sink(p, q, r, s, t, u, v, w, x, y, z, aa, ab, ac, ad, ae, af, a :: number, (a) :: string, (Host.get()) :: any, (...) :: any, ... :: any, { a :: any }, `{a :: any}`)
	const k1 = a; const k2, k3 = a.x, a.y; const k4 = 1; const k5 = "s"; const k6 = k4 + 1; const k7 = function() return k1 end; const k8: number = 2
	Sink(k1, k2, k3, k4, k5, k6, k7, k8, function() return k1, k2, k3, k4, k5 end)
	const function cf(x) return x, k1 end
	Sink(cf, cf(a))
	if local h1 = Host.a() then Sink(h1) end
	if local h2 = Host.b() then Sink(h2, function() return h2 end) else Sink(0) end
	if local h3: number = Host.c() then h3 += 1; Sink(h3) elseif local h4 = Host.d() then Sink(h4) elseif a then Sink(a) else Sink(1) end
	if const h5 = Host.e() then Sink(h5) elseif const h6 = Host.f() then Sink(h6, function() return h6 end) end
	while local n1 = Host.g() do if n1 == 1 then continue end if n1 == 2 then break end Sink(n1, function() return n1 end) end
	while const n2 = Host.h() do Sink(n2); if n2 then break end end
	while local n3: number = Host.i() do n3 -= 1; Sink(n3) end
	local ie1 = if local e1 = Host.j() then e1 else 0
	local ie2 = if const e2 = Host.k() then e2 + 1 elseif local e3 = Host.l() then e3 else nil
	Sink(ie1, ie2, if local e4 = Host.m() then e4 else 1)
	local function f1() end; local function f2(a1) return a1 end; local function f3(a1, a2, ...) return a2, a1, ... end; local function f4(...) return select("#", ...), ... end
	local f5 = function() end; local f6 = function(self) return self end; local f7 = function(...: number): ...number return ... end; local f8 = function<T>(x: T): T return x end
	local function f9<T, U...>(x: T, ...: U...): (T, U...) return x, ... end
	local function f10(x: number?, y: { string }, z: (number) -> string, w: typeof(a)): (number, string?) return x, y end
	Sink(f1, f2, f3, f4, f5, f6, f7, f8, f9, f10)
	@checked local function a1() return 1 end
	@deprecated local function a2() return 2 end
	@[deprecated{reason = "old", use = "new"}] local function a3() return 3 end
	local a4 = @checked function() return 4 end
	Sink(a1, a2, a3, a4, (@checked function() return 5 end)())
end
function Scope.functions(t, ...)
	function t.a() return 1 end
	function t.a.b() return 2 end
	function t.a.b.c.d.e(x) return x end
	function t:m() return self end
	function t.a:m(...) return self, ... end
	function t.a.b.c:m(x, y) return self, x, y end
	function global_func() return 1 end
	function global_func2(...) return ... end
	function registry.fn() return registry end
	function registry.sub.fn:m() return self end
	function Engine.Scene.Hook(x) return x end
	local up
	function up() return up end
	function t.nested() function t.inner() function t.innermost() return t end end end
	return t, up, ...
end
function Scope.registers(a)
	local b = a
	do local c = b; do local d = c; do local e = d; do local f = e; Sink(c, d, e, f) end end end end
	do local c = b; Sink(c) end do local d = b; Sink(d) end
	for i = 1, 2 do local a = i; for i = 1, 2 do local a = i; Sink(a, i) end Sink(a, i) end
	for a = 1, 2 do Sink(a) end for a, b in pairs(a) do Sink(a, b) end Sink(a)
	local x = 1 + 2; local x = x + 1; local x = x * x; Sink(x)
	local y = a; y = y; y = (y); local z = y; z = y; y = z; Sink(y, z)
end
registry.Scope = Scope

-- ===== the shapes an optimizer collapses =====================================
local Bait = {}
function Bait.inlining(a, b, ...)
	local function id(x) return x end
	local function twice(x) return x * 2 end
	local function pair(x, y) return y, x end
	local function none() end
	local function sideways(x) Sink(x) end
	local function early(x) if x then return 1 end return 2 end
	local function branchy(x) if x then return x else return nil end end
	local function looped(x) for i = 1, 2 do Sink(i, x) end return x end
	local function nest1(x) return id(x) + id(x) end
	local function nest2(x) return nest1(x) * twice(x) end
	local function nest3(x) return nest2(id(x)) end
	local function vfn(...) return ... end
	local function rec(x) if x then return rec(x.up) end return 0 end
	local function maker(x) return { x, k = x } end
	local function clos(x) return function() return x end end
	local function writes(x) x = x + 1; return x end
	local function locs(x) local y = x + 1; local z = y * 2; return z end
	local function ternary(x) return if x then 1 else 2 end
	local function andor(x) return x and 1 or 2 end
	local function meth(x) return x:m() end
	local function fast(x) return math.abs(x) end
	local function opencall(x) return Host.get(x) end
	local function const1() return 1 end
	local function const2() return 1, 2 end
	local function retnil() return nil end
	local captured = Host.get()
	local function capt(x) return captured + x end
	local mutated = Host.get(); mutated = Host.other()
	local function capm(x) mutated = x; return mutated end
	local function capa(x) return a, x end
	local reassigned = function(x) return x end; reassigned = Host.get
	const conin = function(x) return x end
	Sink(id(a), id(1), id("s"), id(nil), id(true), id(), id(a, b), id(Host.get()), id(...), id((Host.get())), id(id(a)), id(id(id(1))))
	Sink(twice(a), twice(2), twice(twice(a)), twice(a) + twice(b), twice(a) + 1, 1 + twice(2), -twice(a), #twice(a), not twice(a), `{twice(a)}`, { twice(a) }, { k = twice(a) }, a[twice(1)], twice)
	local p1, p2 = pair(a, b); local p3 = pair(a, b); local p4, p5, p6 = pair(a, b); local p7, p8 = pair(1, 2); Sink(p1, p2, p3, p4, p5, p6, p7, p8, pair(a, b), (pair(a, b)), pair(pair(a, b)), { pair(a, b) })
	none(); sideways(a); sideways(1); id(a); twice(a); early(a); Sink(none(), early(a), early(true), early(nil), branchy(a), branchy(1), looped(a), nest1(a), nest1(1), nest2(a), nest3(a), nest3(1))
	Sink(vfn(a), vfn(...), rec(a), maker(a), maker(1), clos(a), clos(1)(), writes(a), writes(1), locs(a), locs(1), ternary(a), ternary(1), andor(a), andor(nil), meth(a), fast(a), fast(-1), opencall(a))
	Sink(const1(), const1() + 1, const2(), (const2()), retnil(), capt(a), capt(1), capm(a), capa(a), reassigned(a), conin(a), conin(1))
	if early(a) then Sink(1) end
	if not ternary(a) then Sink(2) end
	while andor(a) do Sink(3); break end
	for i = 1, 3 do Sink(twice(i), id(i), early(i)) end
	for i = 1, a do Sink(twice(i), locs(i)) end
	return twice(a), id(b)
end
function Bait.unrolling(a, t)
	for i = 1, 1 do Sink(i) end
	for i = 1, 2 do Sink(i, a) end
	for i = 1, 3 do t[i] = i end
	for i = 1, 4 do Sink(t[i], i * 2, i .. "x", i == 2, -i, not i) end
	for i = 0, 3 do Sink(i) end
	for i = -2, 2 do Sink(i) end
	for i = 8, 2, -2 do local f = function() return i end; Sink(f) end
	for i = 1, 5, 2 do Sink(function() end) end
	for i = 0.5, 2.5 do Sink(i) end
	for i = 1, 0 do Sink(i) end
	for i = 2, 1 do Sink(i) end
	for i = 1, 2, 0.5 do Sink(i) end
	for i = 1, 3 do if i == 2 then Sink(i) end end
	for i = 1, 3 do if i == 2 then break end Sink(i) end
	for i = 1, 3 do if i == 2 then continue end Sink(i) end
	for i = 1, 3 do if a then break end Sink(i) end
	for i = 1, 3 do if a then continue end Sink(i) end
	for i = 1, 3 do if a then return i end end
	for i = 1, 2 do for j = 1, 2 do Sink(i, j, i * j) end end
	for i = 1, 3 do for j = 1, i do Sink(j) end end
	for i = 1, 3 do local x = i * 2; local y = x + i; Sink(y, { x, y = y }, `{i}-{x}`, math.abs(i), math.floor(x)) end
	for i = 1, 3 do local function g(x) return x + i end; Sink(g(i)) end
	for i = 1, 26 do Sink(i) end
	for i = 1, 100 do Sink(i) end
	for i = 1, 3 do a[i], a[i + 1] = a[i + 1], a[i] end
	local n = 3; for i = 1, n do Sink(i) end
	const m = 4; for i = m, 1, -1 do Sink(i) end
end
function Bait.folding(a, b)
	Sink(1 + 2, 3 - 4, 5 * 6, 7 / 8, 9 // 2, 10 % 3, 2 ^ 10, -7 % 3, 7 % -3, -7 // 2, 5.5 // 2, 5.5 % 2, 2 ^ 53, 2 ^ 53 + 1, 2 ^ 1023 * 2, 1e308 * 10, -1e308 * 10, 1 / 0, -1 / 0, 0 / 0, 0 * -1, -0, - -0, 0.1 + 0.2)
	Sink(not true, not false, not nil, not 0, not "s", -1, - 1, -(-1), -(- (1)), #"abc", #"", "a" .. "b", "a" .. 1, 1 .. 2, 1 == 1, 1 ~= 1, 1 < 2, 1 <= 2, 1 > 2, 1 >= 2, "a" == "a", "a" < "b", nil == nil, true == false)
	Sink(true and a, false and a, nil and a, 1 and a, "s" and a, a and true, a and false, a and nil, a and 1, true or a, false or a, nil or a, 1 or a, a or true, a or false, a or nil, a or 1, true and false or a, nil and 1 or 2)
	Sink(if true then a else b, if false then a else b, if nil then a else b, if 1 then a else b, if "s" then a else b, if a then 1 else 1, if a then nil else nil, if true then if false then a else b else a)
	if true then Sink(1) else Sink(2) end
	if false then Sink(3) else Sink(4) end
	if nil then Sink(5) elseif 1 then Sink(6) else Sink(7) end
	if not true then Sink(8) end
	if not false then Sink(9) end
	if true and a then Sink(10) end
	if false and a then Sink(11) end
	if true or a then Sink(12) end
	if false or a then Sink(13) end
	if a and true then Sink(14) end
	if a and false then Sink(15) end
	if a or true then Sink(16) end
	if a or false then Sink(17) end
	while false do Sink(18) end
	while nil do Sink(19) end
	repeat Sink(20) until true
	repeat Sink(21) until 1
	while true do Sink(22); break end
	local k = 5; local s = "str"; local yes, no, nothing = true, false, nil
	Sink(k, k + 1, k * k, s, s .. "x", #s, yes, no, nothing, not yes, a[k], a[s], { k }, { [k] = k }, { [s] = s }, `{k}{s}`, a + k, k + a, a * k, k * a, a == k, a == s)
	if yes then Sink(23) else Sink(24) end
	if no then Sink(25) end
	if nothing then Sink(26) end
	if a == k then Sink(27) end
	if a == s then Sink(28) end
	if a == yes then Sink(29) end
	if a == nothing then Sink(30) end
	local changed = 5; changed = 6; Sink(changed, changed + 1)
	local captured = 5; Sink(function() return captured end)
	local written = 5; Sink(function() written = 6 end)
	const ck = 40; const cs = "pre" .. "fix"; const cb = ck > 39; Sink(ck + 2, cs, `{ck}`, cb, if cb then a else b, a[ck], { [cs] = ck })
	Sink(math.pi, math.huge, -math.huge, math.pi * 2, math.abs(-4), math.floor(2.5), math.ceil(2.5), math.sqrt(16), math.max(1, 2), math.max(1, 2, 3), math.min(1, 2), math.clamp(5, 1, 3), math.sign(-3), math.round(1.5), math.pow(2, 3), math.fmod(7, 3), math.exp(0), math.log(1), math.log(8, 2), math.log10(100))
	Sink(math.sin(0), math.cos(0), math.tan(0), math.asin(0), math.acos(1), math.atan(0), math.atan2(0, 1), math.deg(1), math.rad(1), math.sinh(0), math.cosh(0), math.tanh(0), math.ldexp(1, 2), math.lerp(0, 1, 0.5), math.isnan(1), math.isinf(1), math.isfinite(1))
	Sink(bit32.band(12, 10), bit32.band(12, 10, 8), bit32.bor(1, 2), bit32.bxor(1, 3), bit32.bnot(1), bit32.btest(1, 3), bit32.lshift(1, 4), bit32.rshift(16, 1), bit32.arshift(-4, 1), bit32.lrotate(1, 2), bit32.rrotate(1, 2), bit32.extract(5, 0, 2), bit32.extract(5, 1), bit32.replace(0, 1, 0, 2), bit32.countlz(1), bit32.countrz(4), bit32.byteswap(1))
	Sink(string.len("four"), string.byte("a"), string.char(65), type(nil), type(1), type("s"), type(true), typeof(nil), typeof(1), tonumber("1"), tonumber(1), tostring(1), tostring("s"), `a`, ``, `{1}`, `{"s"}`, `{nil}`, `{true}`, `{1.5}`)
	Sink(vector.create(1, 2, 3), vector.create(1, 2, 3, 4), vector.create(1.5, -2.5, 0), vector.create(a, 2, 3), vector.create(0 / 0, 0, 0), vector.create(1, 2, 3).x, vector.create(1, 2, 3) + vector.create(1, 2, 3), vector.create(1, 2, 3) * 2, 2 * vector.create(1, 2, 3), vector.create(1, 2, 3) / 2, -vector.create(1, 2, 3), vector.magnitude(vector.create(3, 4, 0)), vector.dot(vector.create(1, 2, 3), vector.create(1, 2, 3)), vector.zero, vector.one)
end
function Bait.aliases(a, b, ...)
	local abs, floor, m, huge = math.abs, math.floor, math, math.huge
	Sink(abs(a), floor(b), abs(-1), floor(1.5), m.abs(a), m.floor, m["ceil"](b), (math.abs)(a), math["sqrt"](a), huge, abs)
	local reassigned_abs = math.abs; reassigned_abs = Host.get; Sink(reassigned_abs(a))
	const cabs = math.abs; Sink(cabs(a), cabs(1))
	local band = bit32.band; Sink(band(a, b), band(1, 3), band(a, 1), band(...))
	local type_, len, sel = type, string.len, select; Sink(type_(a), len(b), len("x"), sel("#", ...), sel(1, ...))
	local math = Host.math; Sink(math.abs(a), math.floor(b))
end
function Bait.fastcalls(a, b, c, d, ...)
	Sink(math.abs(a), math.abs(1), math.abs(...), math.abs(a, b), math.abs(), math.max(a, b), math.max(a, 1), math.max(1, a), math.max(a, b, c), math.max(a, b, c, d), math.max(a, 1, 2), math.max(1, a, 2), math.max(...), math.max(a, ...), math.max(a, b, ...), math.max(a, Host.get()), math.max(a, b, Host.get()))
	Sink(type(a), type(1), type(...), typeof(a), rawget(a, b), rawget(a, 1), rawget(a, "k"), rawset(a, b, c), rawset(a, "k", c), rawset(a, 1, 2), rawequal(a, b), rawequal(a, 1), rawlen(a), getmetatable(a), setmetatable(a, b), setmetatable({}, b), setmetatable({}, {}), tonumber(a), tostring(a), assert(a), assert(a, b), assert(a, "m"), assert(...), select("#", ...), select(a, ...), select(1, ...), select(-1, ...), (select("#", ...)), (select(a, ...)))
	Sink(string.byte(a), string.byte(a, 1), string.byte(a, b, c), string.char(a), string.char(a, b), string.len(a), string.sub(a, b), string.sub(a, 1, c), string.sub(a, b, 2), table.insert(a, b), table.insert(a, 1, c), table.unpack(a), table.unpack(a, 1), table.unpack(a, b, c), vector.create(a, b, c), vector.create(a, b, c, d), math.clamp(a, b, c), math.clamp(a, 0, 1), math.lerp(a, b, c))
	Sink(bit32.extract(a, 1, 2), bit32.extract(a, b, c), bit32.extract(a, 3), bit32.extract(a, b), bit32.replace(a, b, c, 1), bit32.lrotate(a, 3), bit32.rshift(a, b), bit32.band(a, 1), bit32.band(1, a), bit32.band(a, b, c), bit32.band(a, b, 1), buffer.readu8(a, 0), buffer.writeu8(a, b, c), buffer.readi32(a, b), buffer.readf64(a, 0), buffer.writef32(a, 0, 1.5), buffer.len(a), buffer.create(a), table.create(a), table.create(a, b), table.clear(a), table.freeze(a), table.isfrozen(a), table.clone(a), table.find(a, b), table.concat(a), table.pack(...), pcall(Host.get), pcall(Host.get, a), pcall(Host.get, ...), xpcall(Host.get, Host.err), xpcall(Host.get, Host.err, a))
	local x = math.abs(a); local y, z = math.modf(a); local v, w = math.frexp(b)
	math.abs(a); math.max(a, b); type(a); rawset(a, b, c); assert(a); select("#", ...); string.len(b); table.insert(a, b); bit32.band(a, b); buffer.writeu8(a, 0, 1); pcall(Host.get); setmetatable(a, b)
	if math.abs(a) then Sink(x, y, z, v, w) end
	if type(a) == "number" then return math.abs(a) elseif typeof(a) == "vector" then return vector.magnitude(a) elseif rawequal(a, b) then return table.unpack(a) end
	return math.max(a, b), math.min(...)
end
registry.Bait = Bait

-- ===== literals, all of them =================================================
local function literals(a)
	Sink(0, 1, 2, 3, 255, 256, 32767, 32768, -32768, -32769, 65535, 65536, 2147483647, 2147483648, 4294967295, 4294967296, 9007199254740992, 9007199254740993, 1e15, 1e16, 1e21, 1e22, 1e100, 1e300, 1e308, 1.7976931348623157e308, 5e-324, 2.2250738585072014e-308, 0.1, 0.2, 0.3)
	Sink(1.5, -1.5, 0.5, 3.14159, 100.5, 1e-5, 1e-10, .5, 5., 1.e2, 1E2, 1e+2, 1e-2, 0x0, 0x1, 0xF, 0xFF, 0xff, 0XAB, 0xFFFF, 0xFFFFFFFF, 0xFFFFFFFFFFFFF, 0b0, 0b1, 0b101, 0B11, 0b11111111, 1_000, 1_000_000, 0xFF_FF, 0b1_0_1, 1_0.5_0, 1e1_0, 1e999, -1e999, -0, -0.0, 0.0)
	Sink("", '', "a", 'a', "it's", 'say "x"', "\a\b\f\n\r\t\v\\\"\'", "\x00\x41\xFF\xfe", "\0\65\122\255", "\u{0}\u{41}\u{7FF}\u{FFFF}\u{10FFFF}\u{1F600}", "a\z
		b", "a\
b", [[]], [[a]], [[
leading newline dropped]], [[a
b]], [=[]]]=], [==[ ]=] ]==], [===[a]]b]==]c]===], "--not a comment", "[[x]]", "`{x}`", "%d %s %%", "héllo wörld ☃ 🙂", "end", "nil", "k k", "1", "1.5", "0x10")
	Sink(``, `a`, `{a}`, `{a}{a}`, `{a} {a}`, `x{a}`, `{a}x`, `x{a}y{a}z`, `\{a}`, `\``, `%d {a}`, `%%{a}%`, `{`{a}`}`, `{`{`{a}`}`}`, `{"s"}`, `{1}`, `{nil}`, `{true}`, `{a + 1}`, `{a .. a}`, `{Host.get()}`, `{(Host.get())}`, `{a:m()}`, `{a.k}`, `{a[1]}`, `{ {a} }`, `{ {k = a} }`, `{function() end}`, `{if a then 1 else 2}`, `{a and 1}`, `{not a}`, `{-a}`, `\n\t{a}\x41\u{41}`, `\z   {a}`)
	Sink(a[0], a[1], a[255], a[256], a[257], a[32768], a[1.5], a[-1], a["0"], a[""], a[1e300])
	a[0] = 1; a[1] = 1.5; a[255] = "s"; a[256] = true; a[257] = nil; a[32768] = a; a[1.5] = 1; a[-1] = 1; a[1e300] = 1
	return nil, true, false, 0, "", {}, function() end
end
registry.literals = literals

-- ===== the register wall, by hand ============================================
function registry.wall(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35, p36, p37, p38, p39, p40, p41, p42, p43, p44, p45, p46, p47, p48, p49, p50, p51, p52, p53, p54, p55, p56, p57, p58, p59, p60, p61, p62, p63, p64, ...)
	local sum = 0
	sum += p1; sum += p2; sum += p3; sum += p4; sum += p5; sum += p6; sum += p7; sum += p8; sum += p9; sum += p10; sum += p11; sum += p12; sum += p13; sum += p14; sum += p15; sum += p16
	local chain = p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8 + p9 + p10 + p11 + p12 + p13 + p14 + p15 + p16 + p17 + p18 + p19 + p20 + p21 + p22 + p23 + p24 + p25 + p26 + p27 + p28 + p29 + p30 + p31 + p32
	local right = p1 .. p2 .. p3 .. p4 .. p5 .. p6 .. p7 .. p8 .. p9 .. p10 .. p11 .. p12 .. p13 .. p14 .. p15 .. p16 .. p17 .. p18 .. p19 .. p20 .. p21 .. p22 .. p23 .. p24 .. p25 .. p26 .. p27 .. p28 .. p29 .. p30 .. p31 .. p32
	local deep = (p1 + (p2 * (p3 - (p4 / (p5 % (p6 ^ (p7 // (p8 + (p9 * (p10 - (p11 / (p12 % (p13 ^ (p14 // (p15 + p16)))))))))))))))
	Sink(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31, p32, p33, p34, p35, p36, p37, p38, p39, p40, p41, p42, p43, p44, p45, p46, p47, p48, p49, p50, p51, p52, p53, p54, p55, p56, p57, p58, p59, p60, p61, p62, p63, p64, sum, chain, right, deep, ...)
	p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12 = p12, p11, p10, p9, p8, p7, p6, p5, p4, p3, p2, p1
	return function()
		p1 += p2; p3 += p4; p5 += p6; p7 += p8; p9 += p10; p11 += p12; p13 += p14; p15 += p16; p17 += p18; p19 += p20; p21 += p22; p23 += p24; p25 += p26; p27 += p28; p29 += p30; p31 += p32
		return p1, p3, p5, p7, p9, p11, p13, p15, p17, p19, p21, p23, p25, p27, p29, p31, p33, p35, p37, p39, p41, p43, p45, p47, p49, p51, p53, p55, p57, p59, p61, p63
	end
end
function registry.manylocals(a)
	local v1, v2, v3, v4, v5, v6, v7, v8, v9, v10 = a.a, a.b, a.c, a.d, a.e, a.f, a.g, a.h, a.i, a.j
	local v11, v12, v13, v14, v15, v16, v17, v18, v19, v20 = v10, v9, v8, v7, v6, v5, v4, v3, v2, v1
	local v21, v22, v23, v24, v25, v26, v27, v28, v29, v30 = v11 + 1, v12 + 1, v13 + 1, v14 + 1, v15 + 1, v16 + 1, v17 + 1, v18 + 1, v19 + 1, v20 + 1
	local v31, v32, v33, v34, v35, v36, v37, v38, v39, v40 = {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
	local v41, v42, v43, v44, v45, v46, v47, v48, v49, v50 = Host.a(), Host.b(), Host.c(), Host.d(), Host.e(), Host.f(), Host.g(), Host.h(), Host.i(), Host.j()
	local v51, v52, v53, v54, v55, v56, v57, v58, v59, v60 = function() return v1 end, function() return v2 end, function() v3 = 1 end, function() v4 = 1 end, function() return v5, v6 end, function() v7, v8 = v8, v7 end, function() return v9 end, function() return v10 end, function() v11 += 1 end, function() v12 ..= "x" end
	Sink(v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, v20, v21, v22, v23, v24, v25, v26, v27, v28, v29, v30, v31, v32, v33, v34, v35, v36, v37, v38, v39, v40, v41, v42, v43, v44, v45, v46, v47, v48, v49, v50, v51, v52, v53, v54, v55, v56, v57, v58, v59, v60)
	return function()
		return v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 + v11 + v12 + v13 + v14 + v15 + v16 + v17 + v18 + v19 + v20 + v21 + v22 + v23 + v24 + v25 + v26 + v27 + v28 + v29 + v30, function() v13, v14, v15, v16 = v16, v15, v14, v13; return v41, v42, v43, v44, v45, v46, v47, v48, v49, v50 end
	end
end

-- ===== things that should not be nested, nested ==============================
local function cursed(a, b, c, ...)
	local first = ({ [(function(...) return select("#", ...) end)(a, (b))] = `{(a or {}).d and "x" or `inner{not b}`}`, (function(...) return ... end)(...) })[1]
	local second = (if a then { b, k = function() return c end } elseif b then setmetatable({}, { __index = function(_, k) return k .. `{a}` end }) else { [a] = { [b] = { [c] = ... } } }).k
	local third = (function(x, ...) for i, v in { ... } do if v == x then return i, function() return v, x end else continue end end return nil end)(a, b, c, ...)
	Sink(first, second, third)
	Sink(#{ (function() return 1, 2, 3 end)() }, #{ ((function() return 1, 2, 3 end)()) }, -(#a + #b), not not (a and (b or (c and (a or (b and c))))))
	for i = (function() return a end)(), (if b then c else #a), (b and 1 or -1) do
		for k, v in (function(t) return next, t, nil end)({ i, [i] = function() return i end, n = `{i}` }) do
			while (function() return k end)() do
				local g = function() k = nil; return i, k, v end
				if g() then repeat local h = g; Sink(h, function() return h end) until h ~= g or (function() return true end)() else break end
				k = (if k then nil else k)
			end
		end
	end
	a[b][c], a[c][b] = (function(...) return select(2, ...), select(1, ...) end)(a[c][b], a[b][c])
	a[(function() return b end)()] = { [(function() return c end)()] = (function() return a end)() };
	(function(...) Sink(...) end)((function(...) return ... end)((function() return a, b, c end)()));
	((function() return Sink end)())((a or b)[c], (a and b).c, ((a))[(b)], (a):m((b):n((c):o())), `{`{`{(a):m()}`}{(b).k}`}{#c}`, { { { { (...) } } } }, function(...) return function(...) return function(...) return ... end end end);
	(a or b or c).x, (a and b and c).y = (b or c or a).z, (c and a and b).w;
	({ a, b }).x, ({ c })[1] = ({ x = 1 }).x, ({ 2 })[1]
	local function self_reference() return self_reference, (self_reference), { self_reference }, self_reference == self_reference end
	local t = { t = nil }; t.t = t; t.t.t.t.t = t.t.t; t[t] = t[t] or t; t[t.t] = t[t[t]]
	local swap1, swap2, swap3 = a, b, c; swap1, swap2, swap3 = swap3, swap1, swap2; swap1, swap1, swap2 = swap2, swap3, swap1
	Sink(self_reference, t, swap1, swap2, swap3, (function(...) local n = select("#", ...); return if n > 0 then (select(n, ...)) else nil end)(a, b, c, ...))
	return (function(...) return ... end)(...), (function(...) return ... end)(...)
end
registry.cursed = cursed

local function everywhere(obj, key, list, ...)
	-- A method call on the result of an if-expression inside an interpolation
	-- inside a table key inside a call inside a loop bound inside a closure.
	local run = function()
		for i = #{ [`{(if obj then key else list):upper()}`] = Sink(obj[key]), obj[key]:m(list[#list]) }, (list[1] or { n = 1 }).n do
			obj[key .. i] = obj[key .. i] and obj[key .. i]:next(i) or { i, key, list, parent = obj, self = function(s, ...) return s, i, ... end }
			local entry = obj[key .. i]
			if entry.self(entry, i).parent == obj then entry.count = (entry.count or 0) + 1 elseif entry[1] > i then entry.count -= 1 else entry.count ..= i end
			list[#list + 1], list[#list + 2] = entry, entry[2]
		end
	end
	local co = coroutine.wrap(function(...) local first = coroutine.yield(run(), ...); local second = coroutine.yield(first and first.x or first); return second, first, ... end)
	local a1, a2 = co(...); local b1 = co(a1); local c1, c2, c3 = co(b1, a2)
	local ok, err, extra = pcall(function(...) local n = select("#", ...); if n > 2 then error({ code = n, info = { ... } }, 2) end return ..., n end, c1, c2, c3)
	local rethrown = (function() local s, e = xpcall(function() error(err) end, function(m) return debug.traceback(tostring(m), 2) end); return s or e end)()
	if not ok and type(err) == "table" and err.code ~= nil and err.info[1] then
		local _ = (function(code, info) for i = code, 1, -1 do if info[i] == nil then continue end return info[i], i end end)(err.code, err.info)
		obj[_ or key] = rethrown
	end
	return setmetatable({ co = co, ok = ok, err = err, extra = extra }, { __index = obj, __call = function(self, ...) return self.co(...) end, __tostring = function(self) return `[{self.ok}|{self.err}|{self.extra}]` end })
end
registry.everywhere = everywhere

-- ===== the runnable corpus, S01..S34, at chunk scope =========================
-- Every section exercises a family of opcodes and syntax permutations, and
-- every observable step goes through T (a step counter + tag) into Sink. The
-- operands come from the assigned globals GA..GHEX, so nothing folds through
-- them. 78 of the 89 opcodes are produced here; the rest are unreachable from
-- portable source (NOP, BREAK, COVERAGE, NATIVECALL, LOADKX, JUMPX, CMPPROTO,
-- NEWCLASSMEMBER, GETUDATAKS, SETUDATAKS, NAMECALLUDATA).

banner("S01 literals & constants")
do
	local n = nil
	local bt, bf = true, false
	T("s01.nil", n)
	T("s01.bools", bt, bf, not bt)
	T("s01.small-int", 0, 1, -1, 255, 32767, -32768)
	T("s01.big-int", 32768, -32769, 100000, 16777217)
	T("s01.floats", 0.5, .5, 5., 3.14159, 1e2, 1e-3, 2.5e10, 1E4)
	T("s01.hex", 0xFF, 0xff, 0xDEADBEEF, 0x0)
	T("s01.bin", 0b1010, 0B11111111, 0b0)
	T("s01.separators", 1_000_000, 0xFF_FF, 0b1010_1010)
	T("s01.huge", 2^53, 2^53 + 2, 1e308, 2^-1074)
	T("s01.negzero", tostring(-0.0), 1 / -0.0)
	T("s01.inf", 1/0, -1/0, math.huge, -math.huge)
	local nan = 0/0
	T("s01.nan", tostring(nan), nan ~= nan, nan == nan)
	T("s01.str-escapes", "a\tb\nc", "q\"q", 'a\'a', "back\\slash", "\65\66\67", "\x41\x42", "\u{48}\u{49}")
	T("s01.str-z", "one\z
	   two")
	T("s01.longstr", [[long ]] .. [==[nested ]==] .. [=[levels]=])
	T("s01.longstr-nl", [[
first-line-skipped]])
	T("s01.char-len", #"\u{1F600}", #"\u{E9}")
end

banner("S02 locals, assignment, scope")
do
	local a = 1
	local b = a
	local c, d = 2, 3
	local e, f, g = 4
	T("s02.basic", a, b, c, d, e, f, g)
	a, b = b, a
	T("s02.swap", a, b)
	c, d = d, c, 99
	T("s02.extra-dropped", c, d)
	local h = nil
	T("s02.explicit-nil", h)
	local x = 10
	do
		local x = 20
		T("s02.shadow-inner", x)
		do
			local x = 30
			T("s02.shadow-deep", x)
		end
	end
	T("s02.shadow-outer", x)
	local p = 1; local q = 2; T("s02.semicolons", p, q);
	local r1 = GA + 1
	local r2 = r1 + 1
	local r3 = r2 + 1
	T("s02.chain", r1, r2, r3)
	local t = {}
	local i = 1
	GMULTI = 0
	t.f, t[i], GMULTI, x = 10, 20, 30, 40
	T("s02.multi-targets", t.f, t[1], GMULTI, x)
end

banner("S03 arithmetic")
do
	local a, b = GA, GB
	T("s03.add", a + b)
	T("s03.sub", a - b)
	T("s03.mul", a * b)
	T("s03.div", a / b)
	T("s03.mod", a % b)
	T("s03.pow", a ^ b)
	T("s03.idiv", a // b)
	T("s03.addk", a + 100)
	T("s03.subk", a - 100)
	T("s03.mulk", a * 100)
	T("s03.divk", a / 4)
	T("s03.modk", a % 4)
	T("s03.powk", a ^ 2)
	T("s03.idivk", a // 2)
	T("s03.subrk", 100 - a)
	T("s03.divrk", 100 / a)
	T("s03.minus", -a, -(a + b), - -a)
	T("s03.neg-mod", -7 % 3, 7 % -3, -7 % -3)
	T("s03.neg-idiv", -7 // 2, 7 // -2, -7 // -2)
	T("s03.float-idiv", 7.5 // GC, GF // 0.5)
	T("s03.div-zero", a / GZERO, -a / GZERO, GZERO / GZERO ~= GZERO / GZERO)
	T("s03.idiv-zero", a // GZERO)
	T("s03.mod-zero", tostring(a % GZERO))
	T("s03.pow-neg", GC ^ -2, (-8) ^ (1/3) ~= (-8) ^ (1/3))
	T("s03.pow-rassoc", 2 ^ 3 ^ 2, (2 ^ 3) ^ 2)
	T("s03.precedence", 2 + 3 * 4, (2 + 3) * 4, 2 - 3 - 4, 2 - (3 - 4), -2 ^ 2)
	T("s03.mixed-float", a + 0.5, b * 0.1, GBIG + 1)
	T("s03.string-coerce", "10" + 5, "3" * "4", "0x10" + 0, "2.5" / 0.5)
	local v = 10
	v += GA; T("s03.ca-add", v)
	v -= GB; T("s03.ca-sub", v)
	v *= GC; T("s03.ca-mul", v)
	v /= GC; T("s03.ca-div", v)
	v //= GB; T("s03.ca-idiv", v)
	v %= GC; T("s03.ca-mod", v)
	v ^= GB; T("s03.ca-pow", v)
	local s = "x"
	s ..= "y"; s ..= GS; T("s03.ca-concat", s)
	local t = { n = 5, arr = { 10 } }
	t.n += 1
	t.arr[1] *= 3
	t["n"] -= GC
	T("s03.ca-fields", t.n, t.arr[1])
	local deep = ((((((a + b) * GC) - GB) / GC) + ((a - GB) * (GC + 1))) % 100) ^ GC
	T("s03.deep-parens", deep)
end

banner("S04 comparisons & conditional jumps")
do
	local a, b, eq = GA, GB, GB
	if a == b then T("s04.eq", "yes") else T("s04.eq", "no") end
	if a ~= b then T("s04.ne", "yes") else T("s04.ne", "no") end
	if a < b  then T("s04.lt", "yes") else T("s04.lt", "no") end
	if a <= b then T("s04.le", "yes") else T("s04.le", "no") end
	if a > b  then T("s04.gt", "yes") else T("s04.gt", "no") end
	if a >= b then T("s04.ge", "yes") else T("s04.ge", "no") end
	if b == eq then T("s04.eq2", "yes") else T("s04.eq2", "no") end
	if not (a < b) then T("s04.not-lt", "inverted") end
	if not (a == b) then T("s04.not-eq", "inverted") end
	if not (b <= GZERO) then T("s04.not-le", "inverted") end
	local v = GA
	if v == 7 then T("s04.eq-kn", "hit") end
	if v ~= 8 then T("s04.ne-kn", "hit") end
	local s = GS
	if s == "gs" then T("s04.eq-ks", "hit") end
	if s ~= "zz" then T("s04.ne-ks", "hit") end
	local misc: any = nil
	if misc == nil then T("s04.eq-knil", "hit") end
	misc = false
	if misc == false then T("s04.eq-kb-false", "hit") end
	misc = true
	if misc == true then T("s04.eq-kb-true", "hit") end
	if misc ~= nil then T("s04.ne-knil", "hit") end
	local c1 = a < b
	local c2 = a >= b
	local c3 = s == "gs"
	local c4 = misc ~= true
	T("s04.cmp-values", c1, c2, c3, c4)
	T("s04.str-cmp", "apple" < "banana", "a" < "ab", "B" < "a", "" < "a")
	T("s04.mixed-eq", 1 == "1", nil == false, {} ~= {}, GA == 7.0)
	local nan = GZERO / GZERO
	T("s04.nan-cmp", nan == nan, nan ~= nan, nan < nan, nan <= nan)
	if (a > b and s == "gs") or (misc == true and not (a == b)) then
		T("s04.compound", "path-A")
	else
		T("s04.compound", "path-B")
	end
	if not ((a < b or misc == false) and (s ~= "gs" or b >= a)) then
		T("s04.demorgan", "outer-not")
	end
end

banner("S05 logical operators as values")
do
	local a, z, f = GA, GZERO, false
	T("s05.and-reg", a and z)
	T("s05.or-reg", f or a)
	T("s05.andk", a and 42)
	T("s05.ork", f or "fallback")
	T("s05.and-nil", nil and 1, false and 1)
	T("s05.or-truthy", 1 or error("never"), z or 99)
	T("s05.ternary", a > 5 and "big" or "small")
	T("s05.not-not", not not z, not not nil, not not "")
	local x = nil
	local y = x or 3.5
	T("s05.default-idiom", y)
	local order = {}
	local function eff(id: number, ret: any)
		order[#order + 1] = id
		return ret
	end
	local r1 = eff(1, false) or eff(2, nil) or eff(3, "third")
	local r2 = eff(4, 1) and eff(5, 2)
	local r3 = eff(6, nil) and eff(7, "never")
	T("s05.effect-order", table.concat(order, ","), r1, r2, r3)
	T("s05.mixed-chain", (a and z or f) ~= nil, nil and 1 or 2, false or nil and 3)
end

banner("S06 concat, length, interpolation")
do
	local a, b = "foo", "bar"
	T("s06.concat2", a .. b)
	T("s06.concat3", a .. "-" .. b)
	T("s06.concat5", a .. "/" .. b .. "/" .. GS)
	T("s06.concat-num", 1 .. "", GA .. "x", "v" .. 2.5, GA .. GB)
	T("s06.concat-rassoc", "a" .. "b" .. "c" .. "d" .. "e" .. "f" .. "g")
	T("s06.len-str", #"", #"abc", #a)
	local arr = { 10, 20, 30, 40 }
	T("s06.len-table", #arr, #{})
	T("s06.len-expr", #(a .. b))
	local who = GS
	T("s06.interp-basic", `hello {who}`)
	T("s06.interp-expr", `sum={GA + GB} nest={`inner{GC}`}`)
	T("s06.interp-brace", `esc \{ok}`)
	T("s06.interp-call", `len={#arr} up={string.upper(who)}`)
	T("s06.interp-only", `{GA}`)
end

banner("S07 tables: construction & indexing")
do
	local empty = {}
	T("s07.empty", #empty, next(empty))
	local list = { 1, 2, 3 }
	T("s07.list", list[1], list[2], list[3], #list)
	local rec = { x = 1, y = 2 }
	local rec2 = { x = 10, y = 20 }
	T("s07.record", rec.x, rec.y, rec2.x, rec2.y)
	local mixed = { 5, 6, tag = "m", 7, [100] = "hundred" }
	T("s07.mixed", mixed[1], mixed[2], mixed[3], mixed.tag, mixed[100])
	local nested = { a = { b = { c = { d = "deep" } } } }
	T("s07.nested-get", nested.a.b.c.d)
	nested.a.b.c.d = "changed"
	nested.a.b.c.e = GA * GB
	T("s07.nested-set", nested.a.b.c.d, nested.a.b.c.e)
	local t = {}
	t.name = "ks"
	t[1] = "n1"
	t[256] = "n256"
	t[257] = "n257"
	t[0] = "zero"
	t[-3] = "neg"
	t[1.5] = "float"
	t[true] = "bool-t"
	t[false] = "bool-f"
	t["key with spaces"] = "spacey"
	local dyn = "dy" .. "n"
	t[dyn] = "dynamic"
	local ik = GA - GB
	t[ik] = "reg-key"
	T("s07.get-ks", t.name, t["name"])
	T("s07.get-n", t[1], t[256], t[257], t[0], t[-3])
	T("s07.get-misc", t[1.5], t[true], t[false], t["key with spaces"], t[dyn], t[ik])
	local function three() return 3, 33, 333 end
	local ck = { [GA] = "seven", [GS .. "!"] = "bang", three(), n = three() }
	T("s07.computed", ck[GA], ck["gs!"], ck[1], ck.n)
	local multi = { 0, three() }
	T("s07.trailing-call", #multi, multi[2], multi[3], multi[4])
	local big = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
		19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32 }
	T("s07.big-array", #big, big[1], big[16], big[32])
	local holey = { 1, 2, nil, 4 }
	T("s07.holes", holey[2], holey[3], holey[4])
	local alias = list
	alias[2] = 222
	T("s07.alias", list[2], rawequal(alias, list))
	local rt = setmetatable({ real = 1 }, { __index = function() return "ghost" end })
	T("s07.raw", rawget(rt, "real"), rawget(rt, "fake"), rt.fake, rawlen(list), rawlen("abcd"), rawequal("a", "a"))
	rawset(rt, "fake", "solid")
	T("s07.rawset", rt.fake)
	local tl = { 30, 10, 20 }
	table.insert(tl, 40)
	table.insert(tl, 1, 5)
	T("s07.insert", table.concat(tl, ","))
	local popped = table.remove(tl)
	local shifted = table.remove(tl, 1)
	T("s07.remove", popped, shifted, table.concat(tl, ","))
	table.sort(tl)
	T("s07.sort", table.concat(tl, ","))
	table.sort(tl, function(x, y) return x > y end)
	T("s07.sort-desc", table.concat(tl, ","))
	T("s07.find", table.find(tl, 20), table.find(tl, 999))
	T("s07.concat-sep", table.concat({ "a", "b", "c" }, "-", 2, 3))
	local moved = table.move({ 1, 2, 3, 4, 5 }, 2, 4, 1, {})
	T("s07.move", table.concat(moved, ","))
	local packed = table.pack("p", "q", "r")
	T("s07.pack", packed.n, packed[1], packed[3])
	T("s07.unpack", table.unpack({ 11, 22, 33 }))
	T("s07.unpack-range", table.unpack({ 11, 22, 33, 44 }, 2, 3))
	T("s07.unpack-global", unpack({ 9, 8 }))
	local created = table.create(4, "fill")
	T("s07.create", #created, created[4])
	local cloned = table.clone(rec)
	cloned.x = 999
	T("s07.clone", cloned.x, rec.x, cloned.y)
	local frozen = table.freeze({ locked = true })
	T("s07.freeze", table.isfrozen(frozen), table.isfrozen(rec))
	local okF, errF = pcall(function() frozen.locked = false end)
	T("s07.freeze-write", okF, scrub(errF))
	local clearable = { 1, 2, 3 }
	table.clear(clearable)
	T("s07.clear", #clearable, next(clearable))
	local fsum = 0
	table.foreach({ a = 1, b = 2 }, function(k, fv) fsum += fv end)
	table.foreachi({ 10, 20 }, function(i, fv) fsum += i * fv end)
	T("s07.foreach", fsum)
end

banner("S08 globals & imports")
do
	GCOUNT = 0
	GCOUNT += 1
	GCOUNT = GCOUNT + GA
	T("s08.scalar", GCOUNT)
	GTAB = { slot = 1 }
	GTAB.slot += 5
	GTAB.extra = { deep = "g" }
	T("s08.table", GTAB.slot, GTAB.extra.deep)
	function GFUNC(x)
		return x * 2 + GCOUNT
	end
	T("s08.func", GFUNC(10))
	T("s08.import1", type(print), typeof(print))
	T("s08.import2", math.pi, math.huge, string.rep("ab", 2), os.clock ~= nil)
	T("s08.import-alias", (function() local pi = math.pi return pi end)())
	T("s08.version", _VERSION)
	local g = _G
	GVIA = "via-_G"
	T("s08._G", g.GVIA, rawequal(g, _G))
end

banner("S09 numeric for")
do
	local acc = {}
	for i = 1, 3 do acc[#acc + 1] = i end
	T("s09.basic", table.concat(acc, ","))
	acc = {}
	for i = 10, 1, -3 do acc[#acc + 1] = i end
	T("s09.down", table.concat(acc, ","))
	acc = {}
	for i = 0, 1, 0.25 do acc[#acc + 1] = i end
	T("s09.float", table.concat(acc, ","))
	local hits = 0
	for i = 3, 1 do hits += 1 end
	for i = 1, 3, -1 do hits += 1 end
	T("s09.zero-trip", hits)
	acc = {}
	for i = GA, GA + GB * 2, GB do acc[#acc + 1] = i end
	T("s09.dynamic", table.concat(acc, ","))
	local function bound() return 4 end
	acc = {}
	for i = bound() - 2, bound() do acc[#acc + 1] = i end
	T("s09.call-bounds", table.concat(acc, ","))
	local grid = {}
	for r = 1, 3 do
		for c = 1, 2 do
			grid[#grid + 1] = r * 10 + c
		end
	end
	T("s09.nested", table.concat(grid, ","))
	local caps = {}
	for i = 1, 3 do
		caps[i] = function() return i end
	end
	T("s09.iter-capture", caps[1](), caps[2](), caps[3]())
	acc = {}
	for i = 1, 3 do
		local snapshot = i
		i = i + 100
		acc[#acc + 1] = snapshot .. ":" .. i
	end
	T("s09.var-mutate", table.concat(acc, " "))
	acc = {}
	for i = 1, 10 do
		if i % 2 == 0 then continue end
		if i > 7 then break end
		acc[#acc + 1] = i
	end
	T("s09.break-continue", table.concat(acc, ","))
end

banner("S10 generic for & iterators")
do
	local arr = { "a", "b", "c" }
	local parts = {}
	for i, v in ipairs(arr) do parts[#parts + 1] = i .. v end
	T("s10.ipairs", table.concat(parts, ","))
	parts = {}
	for i, v in ipairs({ 1, 2, nil, 4 }) do parts[#parts + 1] = tostring(v) end
	T("s10.ipairs-hole", table.concat(parts, ","))
	local sum, keys = 0, {}
	for k, v in pairs({ alpha = 1, beta = 2, gamma = 3 }) do
		sum += v
		keys[#keys + 1] = k
	end
	table.sort(keys)
	T("s10.pairs", sum, table.concat(keys, ","))
	sum = 0
	for k, v in next, { 5, 6, 7 } do sum += k * v end
	T("s10.next-explicit", sum)
	T("s10.next-manual", next({}), next({ 9 }))
	sum = 0
	for k, v in { 10, 20, 30 } do sum += k + v end
	T("s10.generalized", sum)
	local count = 0
	for k in pairs({ x = 1, y = 2 }) do count += 1 end
	T("s10.one-var", count)
	local function stepIter(limit: number, ctrl: number)
		if ctrl < limit then return ctrl + 1, (ctrl + 1) * 11 end
		return nil
	end
	parts = {}
	for i, v in stepIter, 3, 0 do parts[#parts + 1] = i .. "=" .. v end
	T("s10.stateless", table.concat(parts, ","))
	local function makeCountdown(from: number)
		local cur = from + 1
		return function()
			cur -= 1
			if cur > 0 then return cur end
			return nil
		end
	end
	parts = {}
	for v in makeCountdown(4) do parts[#parts + 1] = v end
	T("s10.stateful", table.concat(parts, ","))
	local function tripler(state, ctrl)
		ctrl += 1
		if ctrl > state then return nil end
		return ctrl, ctrl * 2, ctrl * 3
	end
	parts = {}
	for x, y, z in tripler, 2, 0 do parts[#parts + 1] = x .. "/" .. y .. "/" .. z end
	T("s10.three-vars", table.concat(parts, ","))
	local bag = setmetatable({ hidden = true }, {
		__iter = function(self)
			return ipairs({ 100, 200 })
		end,
	})
	sum = 0
	for _, v in bag do sum += v end
	T("s10.iter-mm", sum)
	parts = {}
	for word in string.gmatch("the quick brown fox", "%a+") do
		parts[#parts + 1] = word:sub(1, 2)
	end
	T("s10.gmatch-iter", table.concat(parts, ","))
	local pairsFound = {}
	for _, x in ipairs({ 1, 2 }) do
		for _, y in ipairs({ "p", "q", "r" }) do
			if y == "r" then break end
			pairsFound[#pairsFound + 1] = x .. y
		end
	end
	T("s10.nested-generic", table.concat(pairsFound, ","))
end

banner("S11 while / repeat / break / continue")
do
	local n, acc = 0, {}
	while n < 4 do
		n += 1
		acc[#acc + 1] = n
	end
	T("s11.while", table.concat(acc, ","))
	n = 10
	while n > 0 and n % 2 == 0 do n -= 2 end
	T("s11.while-compound", n)
	n = 0
	while true do
		n += 1
		if n >= 3 then break end
	end
	T("s11.while-true", n)
	while false do T("s11.never", "DEAD") end
	T("s11.while-false", "skipped")
	local fuel = 3
	local function burn()
		fuel -= 1
		return fuel > 0
	end
	while burn() do end
	T("s11.empty-body", fuel)
	n = 0
	repeat n += 1 until n >= 3
	T("s11.repeat", n)
	n = 0
	repeat
		n += 1
		local stop = n * n >= 9
	until stop or n > 10
	T("s11.repeat-scope", n)
	local odds = {}
	n = 0
	while n < 8 do
		n += 1
		if n % 2 == 0 then continue end
		odds[#odds + 1] = n
	end
	T("s11.while-continue", table.concat(odds, ","))
	local tries, granted = 0, 0
	repeat
		tries += 1
		local ok = tries % 3 == 0
		if not ok then continue end
		granted += 1
	until granted >= 2 or tries >= 10
	T("s11.repeat-continue", tries, granted)
	local log = {}
	local outerDone = false
	local i = 0
	while not outerDone do
		i += 1
		local j = 0
		repeat
			j += 1
			if i * j >= 6 then
				outerDone = true
				break
			end
			log[#log + 1] = i .. "*" .. j
		until j >= 2
		if i > 5 then break end
	end
	T("s11.nested-mixed", table.concat(log, " "))
	local total = 0
	local rounds = 0
	while rounds < 2 do
		rounds += 1
		for k = 1, 3 do
			local pulse = 0
			repeat
				pulse += 1
				total += k
			until pulse >= rounds
		end
	end
	T("s11.triple-nest", rounds, total)
end

banner("S12 functions, calls, returns")
do
	local function zero() return end
	local function one() return 1 end
	local function two() return "a", "b" end
	local function tail(n) return one(), two() end
	T("s12.arities", zero(), "|", one(), "|", two())
	T("s12.tail-expand", tail())
	local r0 = zero()
	local ra, rb, rc = two()
	T("s12.assign-truncate", r0, ra, rb, rc)
	T("s12.paren-truncate", (two()))
	local packed = { two(), two() }
	T("s12.list-expand", #packed, packed[1], packed[2], packed[3])
	local function greet(name, punct)
		name = name or "world"
		punct = punct or "!"
		return "hi " .. name .. punct
	end
	T("s12.defaults", greet(), greet("bob"), greet("ann", "?"), greet(nil, "!!"))
	local function add1(x) return x + 1 end
	T("s12.nested-call", add1(add1(add1(GA))))
	local function curryAdd(x)
		return function(y)
			return function(z) return x + y + z end
		end
	end
	T("s12.chained-call", curryAdd(1)(2)(3))
	local function apply(f, v) return f(v) end
	T("s12.higher-order", apply(add1, 41), apply(function(x) return x * x end, 6))
	local obj = { base = 100 }
	function obj:offset(d) return self.base + d end
	function obj.raw(self, d) return self.base - d end
	T("s12.method-colon", obj:offset(5))
	T("s12.method-dot", obj.offset(obj, 7), obj.raw(obj, 1))
	function obj:multi() return self.base, self.base + 1, self.base + 2 end
	T("s12.namecall-multret", obj:multi())
	local sv = "shout"
	T("s12.string-method", sv:upper(), ("quiet"):upper(), sv:len(), sv:sub(2, 3))
	if one() == 1 then T("s12.call-cond", "called") end
	T("s12.feed", math.max(one(), select("#", two())))
	local builder = { parts = {} }
	function builder:add(p)
		self.parts[#self.parts + 1] = p
		return self
	end
	function builder:build() return table.concat(self.parts, "+") end
	T("s12.fluent", builder:add("a"):add("b"):add("c"):build())
	T("s12.iife", (function(x) return x * 3 end)(14))
	local function wide(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16,
		p17, p18, p19, p20, p21, p22, p23, p24, p25, p26, p27, p28, p29, p30, p31, p32)
		return p1 + p2 + p3 + p4 + p5 + p6 + p7 + p8 + p9 + p10 + p11 + p12 + p13 + p14
			+ p15 + p16 + p17 + p18 + p19 + p20 + p21 + p22 + p23 + p24 + p25 + p26 + p27
			+ p28 + p29 + p30 + p31 + p32
	end
	T("s12.wide-call", wide(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
		17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32))
	local function classifyNum(x)
		if x ~= x then return "nan" end
		if x == 0 then return "zero" end
		if x < 0 then
			if x < -100 then return "very-negative" end
			return "negative"
		end
		for _ = 1, 1 do
			if x > 100 then return "very-positive" end
		end
		return "positive"
	end
	T("s12.early-returns", classifyNum(0), classifyNum(-5), classifyNum(-500),
		classifyNum(5), classifyNum(500), classifyNum(GZERO / GZERO))
	T("s12.spread", math.max(table.unpack({ 3, 9, 4 })))
end

banner("S13 varargs")
do
	T("s13.main-chunk", select("#", ...))
	local function vinfo(...)
		local n = select("#", ...)
		local first = select(1, ...)
		local lastOnly = nil
		if n > 0 then
			lastOnly = select(-1, ...)
		end
		local a, b = ...
		local all = { ... }
		local packed = table.pack(...)
		return n, first, lastOnly, a, b, #all, packed.n
	end
	T("s13.info", vinfo("x", "y", "z"))
	T("s13.info-empty", vinfo())
	T("s13.info-nils", vinfo(nil, nil))
	local function forward(...)
		return vinfo(...)
	end
	T("s13.forward", forward(10, 20))
	local function mixedParams(first, second, ...)
		local rest = select("#", ...)
		return first, second, rest, ...
	end
	T("s13.mixed", mixedParams(1, 2, 3, 4, 5))
	local function midTruncate(...)
		local t = { ..., "cap" }
		return #t, t[1], t[2]
	end
	T("s13.mid-truncate", midTruncate("v1", "v2", "v3"))
	T("s13.select-tail", select(2, "p", "q", "r"))
	local function vsum(...)
		if select("#", ...) == 0 then return 0 end
		local head = ...
		return head + vsum(select(2, ...))
	end
	T("s13.vararg-recursion", vsum(1, 2, 3, 4, 5))
	local function joinv(...)
		return table.concat({ ... }, "|")
	end
	T("s13.join", joinv("m", "n", "o"), `count={select("#", "x", "y")}`)
end

banner("S14 closures & upvalues")
do
	local base = GA * 10
	local readBase = function() return base end
	T("s14.cap-val", readBase())
	local counter = 0
	local function bump()
		counter += 1
		return counter
	end
	bump(); bump()
	T("s14.cap-ref", bump(), counter)
	local shared = 100
	local function readShared() return shared end
	local function writeShared(v) shared = v end
	writeShared(555)
	T("s14.shared-cell", readShared(), shared)
	local function level1()
		local secret = "L1"
		local function level2()
			local mid = "L2"
			local function level3()
				return secret .. "/" .. mid .. "/L3"
			end
			return level3
		end
		return level2()
	end
	T("s14.three-level", level1()())
	local function makeCounter(start: number)
		local c = start
		return function()
			c += 1
			return c
		end,
		function() return c end
	end
	local incA, getA = makeCounter(0)
	local incB, getB = makeCounter(100)
	incA(); incA(); incB()
	T("s14.factory", getA(), getB(), incA(), incB())
	local fns = {}
	for i = 1, 3 do
		local double = i * 2
		fns[i] = function() return i .. ":" .. double end
	end
	T("s14.loop-fresh", fns[1](), fns[2](), fns[3]())
	local grabbed
	local w = 0
	while true do
		w += 1
		local snapshot = w * 11
		if w == 2 then
			grabbed = function() return snapshot end
			break
		end
	end
	T("s14.break-close", grabbed())
	-- the rawequal identity of two captureless closures is opt-level dependent
	-- (DUPCLOSURE dedups them at -O1/-O2 but not -O0), so only behavior is sunk
	local pures = {}
	for i = 1, 2 do
		pures[i] = function(x) return x * 2 end
	end
	T("s14.dupclosure", pures[1](21), pures[2](50), type(pures[1]) == type(pures[2]))
	local accum = {}
	for i = 1, 2 do
		local tweak = function() i += 100 return i end
		accum[#accum + 1] = tweak()
	end
	T("s14.mutate-loopvar", table.concat(accum, ","))
	local escape
	do
		local trapped = "inside"
		escape = function() return trapped end
	end
	T("s14.block-close", escape())
end

banner("S15 recursion")
do
	local function fact(n)
		if n <= 1 then return 1 end
		return n * fact(n - 1)
	end
	T("s15.factorial", fact(1), fact(5), fact(10))
	local function fib(n)
		if n < 2 then return n end
		return fib(n - 1) + fib(n - 2)
	end
	T("s15.fib", fib(10), fib(15))
	local isEven, isOdd
	function isEven(n)
		if n == 0 then return true end
		return isOdd(n - 1)
	end
	function isOdd(n)
		if n == 0 then return false end
		return isEven(n - 1)
	end
	T("s15.mutual", isEven(10), isOdd(7), isEven(3))
	local function ack(m, n)
		if m == 0 then return n + 1 end
		if n == 0 then return ack(m - 1, 1) end
		return ack(m - 1, ack(m, n - 1))
	end
	T("s15.ackermann", ack(1, 3), ack(2, 3), ack(3, 3))
	local function depth(n)
		if n == 0 then return "bottom" end
		local r = depth(n - 1)
		return r
	end
	T("s15.deep", depth(100))
	local function countdown(n)
		if n <= 0 then return "liftoff" end
		return countdown(n - 1)
	end
	T("s15.tail-form", countdown(50))
	local tree = { value = 1, kids = {
		{ value = 2, kids = {} },
		{ value = 3, kids = { { value = 4, kids = {} } } },
	} }
	local walker = {}
	function walker:sum(node)
		local s = node.value
		for _, kid in ipairs(node.kids) do
			s += self:sum(kid)
		end
		return s
	end
	T("s15.tree-method", walker:sum(tree))
	local anonFib
	anonFib = function(n)
		if n < 2 then return n end
		return anonFib(n - 1) + anonFib(n - 2)
	end
	T("s15.anon-rec", anonFib(12))
	local function revAcc(s, acc)
		acc = acc or ""
		if #s == 0 then return acc end
		return revAcc(string.sub(s, 2), string.sub(s, 1, 1) .. acc)
	end
	T("s15.accumulator", revAcc("stressed"))
end

banner("S16 branch matrices & control-flow soup")
do
	local function ladder(x)
		if x == 1 then return "one"
		elseif x == 2 then return "two"
		elseif x == 3 then return "three"
		elseif x < 10 then return "small"
		elseif x < 100 then return "medium"
		else return "large"
		end
	end
	T("s16.ladder", ladder(1), ladder(2), ladder(3), ladder(7), ladder(42), ladder(1000))
	local function classify(a: boolean, b: boolean, c: boolean): string
		if a and b and c then
			return "all"
		elseif a and b then
			return "ab"
		elseif a and (b or c) then
			return "a+c"
		elseif not a and not b and not c then
			return "none"
		elseif (a or b) and not c then
			return "some-noc"
		else
			return "rest"
		end
	end
	for mask = 0, 7 do
		T("s16.matrix" .. mask, classify(bit32.btest(mask, 4), bit32.btest(mask, 2), bit32.btest(mask, 1)))
	end
	local report = {}
	if GA > 0 then
		for i = 1, 4 do
			if i % 2 == 0 then
				local j = 0
				while j < i do
					j += 1
					if j == 3 then break end
				end
				report[#report + 1] = "e" .. i .. "j" .. j
			else
				report[#report + 1] = "o" .. i
			end
		end
	else
		report[1] = "unreachable"
	end
	T("s16.soup", table.concat(report, " "))
	if GA == 7 then end
	if GA == 8 then else end
	do end
	T("s16.empty-branches", "survived")
	local cfg = { enabled = true, threshold = 5 }
	local function reading() return 6 end
	if cfg.enabled and reading() > cfg.threshold then
		T("s16.cfg-cond", "over")
	else
		T("s16.cfg-cond", "under")
	end
	local pick = if GA > GB then "gt" else "le"
	local chain = if GA == 1 then "a" elseif GA == 7 then "b" elseif GA == 9 then "c" else "d"
	local nested = if GA > 0 then (if GB > 5 then "pp" else "pn") else "n"
	local inExpr = 10 + (if GC == 2 then 1 else 100) * 2
	T("s16.ifexpr", pick, chain, nested, inExpr)
	T("s16.ifexpr-inline", if GZERO == 0 then `z{GZERO}` else "nz")
end

banner("S17 error handling")
do
	local ok1, v1 = pcall(function() return "fine", 123 end)
	T("s17.pcall-ok", ok1, v1)
	local ok2, e2 = pcall(function() error("boom", 0) end)
	T("s17.pcall-err", ok2, e2)
	local ok3, e3 = pcall(function() error("located") end)
	T("s17.pcall-scrubbed", ok3, scrub(e3))
	local ok4, e4 = pcall(function() error({ code = 42, msg = "obj" }) end)
	T("s17.error-table", ok4, type(e4), e4.code, e4.msg)
	local ok5, e5 = pcall(function() error() end)
	T("s17.error-nil", ok5, tostring(e5))
	local okA, eA = pcall(function() local x = nil return x.field end)
	T("s17.index-nil", okA, scrub(eA))
	local okB, eB = pcall(function() local f = nil f() end)
	T("s17.call-nil", okB, scrub(eB))
	local okC, eC = pcall(function() return {} + 1 end)
	T("s17.arith-table", okC, scrub(eC))
	local okD, eD = pcall(function() return #GA end)
	T("s17.len-number", okD, scrub(eD))
	local okE, eE = pcall(function() return 1 < "2" end)
	T("s17.cmp-mixed", okE, scrub(eE))
	T("s17.assert-pass", assert(5, "unused"), assert("keep", "msg", "extra"))
	local okF, eF = pcall(function() assert(false) end)
	T("s17.assert-fail", okF, scrub(eF))
	local okG, eG = pcall(function() assert(nil, "custom assert") end)
	T("s17.assert-msg", okG, scrub(eG))
	local function innerThrow() error("deep-throw", 0) end
	local function midFrame() innerThrow() end
	local okH, eH = pcall(midFrame)
	T("s17.nested-frames", okH, eH)
	local okI, vI = pcall(function()
		local innerOk, innerErr = pcall(error, "inner", 0)
		return "outer-fine:" .. tostring(innerOk) .. ":" .. tostring(innerErr)
	end)
	T("s17.nested-pcall", okI, vI)
	local okJ, eJ = pcall(42)
	T("s17.pcall-nonfunc", okJ, scrub(eJ))
	local okK, s1, s2 = pcall(function(a, b) return a + b, a * b end, GA, GB)
	T("s17.pcall-args", okK, s1, s2)
	local okL, vL = xpcall(function(n) error("xp:" .. n, 0) end, function(e)
		return "handled(" .. scrub(e) .. ")"
	end, 9)
	T("s17.xpcall", okL, vL)
	local okM, vM = xpcall(function(a, b) return a - b end, function() return "nope" end, 10, 4)
	T("s17.xpcall-ok", okM, vM)
	local okN, eN = pcall(function()
		local innerOk, innerErr = pcall(function() error("first", 0) end)
		if not innerOk then
			error("rethrown:" .. tostring(innerErr), 0)
		end
	end)
	T("s17.rethrow", okN, eN)
end

banner("S18 metatables & metamethods")
do
	local W = {}
	W.__index = W
	local function wrap(v: number)
		return setmetatable({ v = v }, W)
	end
	local function unwrapv(x): number
		if type(x) == "table" then return x.v end
		return x
	end
	W.__add = function(a, b) return wrap(unwrapv(a) + unwrapv(b)) end
	W.__sub = function(a, b) return wrap(unwrapv(a) - unwrapv(b)) end
	W.__mul = function(a, b) return wrap(unwrapv(a) * unwrapv(b)) end
	W.__div = function(a, b) return wrap(unwrapv(a) / unwrapv(b)) end
	W.__idiv = function(a, b) return wrap(unwrapv(a) // unwrapv(b)) end
	W.__mod = function(a, b) return wrap(unwrapv(a) % unwrapv(b)) end
	W.__pow = function(a, b) return wrap(unwrapv(a) ^ unwrapv(b)) end
	W.__unm = function(a) return wrap(-a.v) end
	W.__eq = function(a, b) return a.v == b.v end
	W.__lt = function(a, b) return a.v < b.v end
	W.__le = function(a, b) return a.v <= b.v end
	W.__len = function(a) return math.floor(a.v) end
	W.__concat = function(a, b)
		local function s(x) return type(x) == "table" and "W" .. x.v or tostring(x) end
		return s(a) .. "~" .. s(b)
	end
	W.__call = function(self, mult) return self.v * mult end
	W.__tostring = function(self) return "<W:" .. self.v .. ">" end
	local w9, w4 = wrap(9), wrap(4)
	T("s18.add", (w9 + w4).v, (w9 + 1).v, (1 + w9).v)
	T("s18.sub", (w9 - w4).v, (w9 - 2).v, (20 - w9).v)
	T("s18.mul", (w9 * w4).v)
	T("s18.div", (w9 / w4).v)
	T("s18.idiv", (w9 // w4).v)
	T("s18.mod", (w9 % w4).v)
	T("s18.pow", (w4 ^ 2).v)
	T("s18.unm", (-w9).v)
	T("s18.eq", w9 == wrap(9), w9 == w4, w9 ~= w4)
	T("s18.lt-le", w4 < w9, w9 < w4, w4 <= wrap(4), w9 > w4, w9 >= wrap(9))
	T("s18.len", #wrap(7.9))
	T("s18.concat", w9 .. "end", "start" .. w4, w9 .. w4)
	T("s18.call", w9(3), wrap(2.5)(4))
	T("s18.tostring", tostring(w9))
	print("s18.print-mm", w9)
	local root = { inherited = "from-root" }
	local mid = setmetatable({ own = "mid" }, { __index = root })
	local leaf = setmetatable({}, { __index = mid })
	T("s18.index-chain", leaf.inherited, leaf.own, leaf.missing)
	local dyn = setmetatable({}, { __index = function(_, k) return "dyn:" .. tostring(k) end })
	T("s18.index-func", dyn.anything, dyn[7])
	local writes = {}
	local audit = setmetatable({}, {
		__newindex = function(t, k, v)
			writes[#writes + 1] = k .. "=" .. tostring(v)
			rawset(t, k, v)
		end,
	})
	audit.a = 1
	audit.b = 2
	audit.a = 3
	T("s18.newindex-func", table.concat(writes, ","), audit.a, audit.b)
	local store = {}
	local mirror = setmetatable({}, { __newindex = store })
	mirror.hidden = "in-store"
	T("s18.newindex-table", rawget(mirror, "hidden"), store.hidden)
	rawset(mirror, "direct", "raw")
	T("s18.newindex-rawset", rawget(mirror, "direct"))
	local locked = setmetatable({}, { __metatable = "LOCKED" })
	T("s18.metatable-lock", getmetatable(locked))
	local okSet, errSet = pcall(setmetatable, locked, {})
	T("s18.metatable-protect", okSet, scrub(errSet))
	T("s18.getmeta-plain", getmetatable({}), type(getmetatable("")))
	local swap = setmetatable({}, { __index = function() return 1 end })
	setmetatable(swap, { __index = function() return 2 end })
	T("s18.mt-swap", swap.x)
	setmetatable(swap, nil)
	T("s18.mt-removed", swap.x, getmetatable(swap))
	local reversed = setmetatable({ 1, 2, 3 }, {
		__iter = function(self)
			local i = #self + 1
			return function()
				i -= 1
				if i >= 1 then return i, self[i] end
				return nil
			end
		end,
	})
	local order = {}
	for i, v in reversed do order[#order + 1] = i .. ":" .. v end
	T("s18.iter", table.concat(order, ","))
	local weak = setmetatable({}, { __mode = "k" })
	weak[{}] = "ephemeral"
	T("s18.weak-declared", getmetatable(weak).__mode)
	local proxy = newproxy(true)
	local pmt = getmetatable(proxy)
	pmt.__index = { kind = "proxy-ud" }
	pmt.__tostring = function() return "<proxy>" end
	pmt.__len = function() return 12321 end
	T("s18.userdata", typeof(proxy), type(proxy), proxy.kind, tostring(proxy), #proxy)
end

banner("S19 OOP & inheritance")
do
	local Animal = {}
	Animal.__index = Animal
	function Animal.new(name: string, sound: string)
		local self = setmetatable({}, Animal)
		self.name = name
		self.sound = sound
		return self
	end
	function Animal:speak()
		return self.name .. " says " .. self.sound
	end
	function Animal:id()
		return "animal:" .. self.name
	end
	local Dog = setmetatable({}, { __index = Animal })
	Dog.__index = Dog
	function Dog.new(name: string)
		local self = Animal.new(name, "woof")
		return setmetatable(self, Dog)
	end
	function Dog:speak()
		return Animal.speak(self) .. " (wagging)"
	end
	function Dog:fetch()
		return self.name .. " fetches"
	end
	local Puppy = setmetatable({}, { __index = Dog })
	Puppy.__index = Puppy
	function Puppy.new(name: string)
		return setmetatable(Dog.new(name), Puppy)
	end
	function Puppy:speak()
		return "(tiny) " .. Dog.speak(self)
	end
	local generic = Animal.new("cat", "meow")
	local rex = Dog.new("rex")
	local pup = Puppy.new("bit")
	T("s19.base", generic:speak(), generic:id())
	T("s19.override-super", rex:speak())
	T("s19.inherited-method", rex:id(), pup:fetch())
	T("s19.grandchild", pup:speak(), pup:id())
	local function isa(obj, class)
		local mt = getmetatable(obj)
		while mt do
			if rawequal(mt, class) then return true end
			local idx = rawget(mt, "__index")
			mt = type(idx) == "table" and getmetatable(idx) or getmetatable(mt.__index or nil)
			if mt == nil then
				break
			end
		end
		return false
	end
	T("s19.isa", isa(pup, Puppy), isa(rex, Dog), isa(generic, Animal))
	Dog.population = 1
	Dog.population += 1
	function Dog.describe()
		return "dogs:" .. Dog.population
	end
	T("s19.static", Dog.describe())
end

banner("S20 string library")
do
	local s = "Hello, Luau World"
	T("s20.len-upper-lower", string.len(s), string.upper("abc"), string.lower("ABC"))
	T("s20.sub", string.sub(s, 1, 5), string.sub(s, -5), string.sub(s, 8, -7), string.sub(s, 99))
	T("s20.rep", string.rep("ab", 3), string.rep("x", 3, "-"), string.rep("q", 0))
	T("s20.reverse", string.reverse("stressed"))
	T("s20.byte", string.byte("A"), string.byte("ABC", 2), string.byte("ABC", 1, 3))
	T("s20.char", string.char(72, 101, 121))
	T("s20.find-plain", string.find(s, "Luau", 1, true))
	T("s20.find-pattern", string.find(s, "%u%a+"))
	T("s20.find-captures", string.find("key=val", "(%w+)=(%w+)"))
	T("s20.find-init", string.find(s, "o", 6))
	T("s20.find-miss", string.find(s, "zebra"))
	T("s20.match", string.match(s, "^(%a+)"), string.match(s, "(%a+)$"))
	T("s20.match-multi", string.match("2026-07-21", "(%d+)-(%d+)-(%d+)"))
	T("s20.match-pos", string.match("abc", "()b()"))
	T("s20.match-classes", string.match("a1 _x", "%l"), string.match("a1 _x", "%d"),
		string.match("a1 _x", "%s"), string.match("a1 _x", "%p"))
	T("s20.match-set", string.match("caterpillar", "[aeiou]+"), string.match("x9y", "[^%a]"))
	T("s20.match-lazy-greedy", string.match("<a><b>", "<(.-)>"), string.match("<a><b>", "<(.+)>"))
	T("s20.match-balanced", string.match("fn(a(b)c)d", "%b()"))
	T("s20.match-frontier", string.match("THE cat", "%f[%l]%a+"))
	T("s20.match-quantifiers", string.match("aaa", "a*"), string.match("", "a*"),
		string.match("color", "colou?r"), string.match("colour", "colou?r"))
	local words = {}
	for w in string.gmatch("alpha beta gamma", "%a+") do words[#words + 1] = w end
	T("s20.gmatch", table.concat(words, ","))
	local kvs = {}
	for k, v in string.gmatch("a=1,b=2,c=3", "(%w+)=(%w+)") do kvs[#kvs + 1] = k .. v end
	T("s20.gmatch-2cap", table.concat(kvs, ","))
	T("s20.gsub-str", string.gsub("banana", "a", "o"))
	T("s20.gsub-limit", string.gsub("banana", "a", "o", 2))
	T("s20.gsub-backref", string.gsub("hello world", "(%w+)", "<%1>"))
	T("s20.gsub-swap", string.gsub("k=v", "(%w+)=(%w+)", "%2=%1"))
	T("s20.gsub-table", string.gsub("cat dog", "%a+", { cat = "feline", dog = "canine" }))
	T("s20.gsub-func", string.gsub("1 2 3", "%d", function(d) return tostring(tonumber(d) * 2) end))
	T("s20.gsub-func-nil", string.gsub("keep drop", "%a+", function(word)
		if word == "drop" then return "gone" end
		return nil
	end))
	T("s20.gsub-percent", string.gsub("100%", "%%", " pct"))
	T("s20.fmt-int", string.format("%d|%5d|%-5d|%05d|%+d", 42, 42, 42, 42, 42))
	T("s20.fmt-numeric", string.format("%i|%u|%x|%X|%o|%c", 7, 7, 255, 255, 8, 65))
	T("s20.fmt-float", string.format("%f|%.2f|%10.3f|%e|%g|%g", 3.14159, 3.14159, 3.14159, 12345.678, 0.00001, 1e20))
	T("s20.fmt-str", string.format("[%s][%10s][%-10s][%.3s]", "luau", "luau", "luau", "luau"))
	T("s20.fmt-q", string.format("%q", 'he said "hi"\n\\end'))
	T("s20.fmt-escape", string.format("100%%"))
	T("s20.fmt-mixed", string.format("%s=%d (%.1f%%)", "score", 9, 87.5))
	T("s20.split", table.concat(string.split("a,b,c", ","), "|"))
	T("s20.split-empty", #string.split("a,,c", ","), string.split("a,,c", ",")[2])
	T("s20.split-char", table.concat(string.split("abc", ""), "-"))
	local blob = string.pack("<i4i2z", 258, 7, "tail")
	T("s20.packsize", string.packsize("<i4i2"), #blob)
	T("s20.unpack", string.unpack("<i4i2z", blob))
	local f32blob = string.pack("<f", 0.5)
	T("s20.pack-float", #f32blob, string.unpack("<f", f32blob))
	T("s20.pack-endian", string.byte(string.pack(">I2", 1), 1, 2), string.byte(string.pack("<I2", 1), 1, 2))
	local sv = "MiXeD"
	T("s20.namecall", sv:lower(), sv:upper(), ("chain"):rep(2):sub(1, 7))
end

banner("S21 math library")
do
	local x = GF
	T("s21.abs", math.abs(-x), math.abs(x), math.abs(GNEG))
	T("s21.ceil-floor", math.ceil(x), math.floor(x), math.ceil(-x), math.floor(-x))
	T("s21.round-sign", math.round(2.5), math.round(-2.5), math.round(2.4),
		math.sign(GNEG), math.sign(GZERO), math.sign(x))
	T("s21.clamp", math.clamp(15, 0, 10), math.clamp(-5, 0, 10), math.clamp(5, 0, 10))
	T("s21.minmax", math.min(GA, GB, GC), math.max(GA, GB, GC), math.min(1.5, GF))
	T("s21.sqrt-exp", math.sqrt(16), math.sqrt(GC), math.exp(0), math.exp(1))
	T("s21.log", math.log(1), math.log(math.exp(2)), math.log(8, 2), math.log(100, 10), math.log10(1000))
	T("s21.trig", math.sin(0), math.cos(0), math.tan(0), math.sin(math.pi / 2))
	T("s21.trig-inverse", math.asin(1), math.acos(1), math.atan(1), math.atan(1, 1), math.atan(1, 0))
	T("s21.hyperbolic", math.sinh(0), math.cosh(0), math.tanh(0))
	T("s21.deg-rad", math.deg(math.pi), math.rad(180), math.rad(0))
	T("s21.fmod", math.fmod(7, 3), math.fmod(-7, 3), math.fmod(7, -3))
	T("s21.modf", math.modf(3.7), math.modf(-3.7))
	T("s21.frexp-ldexp", math.frexp(8), math.ldexp(0.5, 4), math.ldexp(1, 10))
	T("s21.pow-fn", math.pow(2, 10), math.pow(9, 0.5))
	T("s21.constants", math.pi, math.huge)
	T("s21.lerp-map", math.lerp(0, 10, 0.25), math.map(5, 0, 10, 100, 200))
	T("s21.noise", math.noise(0.5), math.noise(0.5, 1.5), math.noise(0.5, 1.5, 2.5))
	math.randomseed(12345)
	T("s21.random-seeded", math.random(), math.random(100), math.random(50, 60))
	math.randomseed(12345)
	T("s21.random-replay", math.random(), math.random(100), math.random(50, 60))
end

banner("S22 bit32 library")
do
	local v = GHEX
	T("s22.band-bor-bxor", bit32.band(v, 0xF), bit32.bor(v, 0x80), bit32.bxor(v, 0xFF))
	T("s22.multi-arg", bit32.band(0xFF, 0xF0, 0x3C), bit32.bor(1, 2, 4, 8), bit32.bxor(1, 3, 5))
	T("s22.bnot", bit32.bnot(0), bit32.bnot(v))
	T("s22.shifts", bit32.lshift(v, 4), bit32.rshift(v, 1), bit32.lshift(1, 31), bit32.rshift(0x80000000, 31))
	T("s22.shift-edges", bit32.lshift(1, 32), bit32.rshift(1, 32), bit32.lshift(1, 0))
	T("s22.arshift", bit32.arshift(0x80000000, 4), bit32.arshift(64, 3), bit32.arshift(-16, 2))
	T("s22.extract", bit32.extract(0xABCD, 4, 8), bit32.extract(0xFF, 0), bit32.extract(0xFFFFFFFF, 31, 1))
	T("s22.replace", bit32.replace(0xABCD, 0xF, 4, 4), bit32.replace(0, 1, 31))
	T("s22.btest", bit32.btest(6, 4), bit32.btest(6, 1), bit32.btest(0))
	T("s22.count", bit32.countlz(1), bit32.countlz(0), bit32.countrz(8), bit32.countrz(0))
	T("s22.byteswap", bit32.byteswap(1), bit32.byteswap(0x11223344))
	T("s22.wraparound", bit32.band(-1), bit32.bor(2^32 + 5, 0))
end

banner("S23 utf8 library")
do
	local heart = "\u{2764}"
	local accent = "caf\u{E9}"
	T("s23.char", utf8.char(72, 105), utf8.char(0x2764) == heart)
	T("s23.codepoint", utf8.codepoint("A"), utf8.codepoint(accent, 1, #accent))
	T("s23.len", utf8.len("plain"), utf8.len(accent), utf8.len(heart))
	T("s23.len-bytes", #accent, #heart, #utf8.char(0x1F600))
	T("s23.offset", utf8.offset(accent, 2), utf8.offset(accent, 4), utf8.offset(accent, -1))
	local cps = {}
	for pos, cp in utf8.codes(accent) do cps[#cps + 1] = pos .. ":" .. cp end
	T("s23.codes", table.concat(cps, ","))
	local units = 0
	for _ in string.gmatch(accent, utf8.charpattern) do units += 1 end
	T("s23.charpattern", units)
	T("s23.len-invalid", utf8.len("\xFF\xFE"))
end

banner("S24 os library (deterministic subset)")
do
	T("s24.date-fixed", os.date("!%Y-%m-%d %H:%M:%S", 86400))
	T("s24.date-fmt", os.date("!%j|%W|%w|%p", 0))
	local dt = os.date("!*t", 0)
	T("s24.date-table", dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec, dt.wday, dt.yday, dt.isdst)
	T("s24.difftime", os.difftime(100, 25))
	T("s24.clock-type", type(os.clock()), type(os.time()))
	T("s24.gc-type", type(gcinfo()), type(collectgarbage("count")))
end

banner("S25 coroutines")
do
	local co = coroutine.create(function(a, b)
		local got = coroutine.yield(a + b)
		local more1, more2 = coroutine.yield(got * 2)
		return a, more1 + more2
	end)
	T("s25.status0", coroutine.status(co))
	T("s25.resume1", coroutine.resume(co, 4, 6))
	T("s25.resume2", coroutine.resume(co, 100))
	T("s25.status-mid", coroutine.status(co))
	T("s25.resume3", coroutine.resume(co, 7, 8))
	T("s25.status-dead", coroutine.status(co))
	T("s25.resume-dead", coroutine.resume(co))
	local gen = coroutine.wrap(function()
		for i = 1, 3 do coroutine.yield(i * 5) end
		return "wrapped-done"
	end)
	T("s25.wrap", gen(), gen(), gen(), gen())
	local failing = coroutine.wrap(function() error("wrap-fail", 0) end)
	local okW, errW = pcall(failing)
	T("s25.wrap-error", okW, errW)
	local inner, outer
	inner = coroutine.create(function()
		T("s25.inner-sees-outer", coroutine.status(outer))
		coroutine.yield("inner-yield")
		return "inner-ret"
	end)
	outer = coroutine.create(function()
		local ok1, v1 = coroutine.resume(inner)
		local ok2, v2 = coroutine.resume(inner)
		return v1 .. "/" .. v2
	end)
	T("s25.nested", coroutine.resume(outer))
	local shielded = coroutine.create(function()
		local ok, v = pcall(function()
			local injected = coroutine.yield("asking")
			return injected * 3
		end)
		return ok, v
	end)
	T("s25.yield-in-pcall-1", coroutine.resume(shielded))
	T("s25.yield-in-pcall-2", coroutine.resume(shielded, 14))
	local dying = coroutine.create(function() error("co-death", 0) end)
	T("s25.resume-error", coroutine.resume(dying), coroutine.status(dying))
	T("s25.main-running", coroutine.running() == nil, coroutine.isyieldable())
	local introspect = coroutine.create(function()
		return coroutine.running() ~= nil, coroutine.isyieldable()
	end)
	T("s25.co-running", coroutine.resume(introspect))
	local sleeper = coroutine.create(function() coroutine.yield() end)
	coroutine.resume(sleeper)
	T("s25.close", coroutine.close(sleeper), coroutine.status(sleeper))
	local function producer()
		return coroutine.create(function()
			for _, item in ipairs({ "wood", "iron", "gold" }) do
				coroutine.yield(item)
			end
		end)
	end
	local received = {}
	local prod = producer()
	while true do
		local ok, item = coroutine.resume(prod)
		if not ok or item == nil then break end
		received[#received + 1] = item
	end
	T("s25.pipeline", table.concat(received, ","))
end

banner("S26 buffer library")
do
	local b = buffer.create(32)
	T("s26.create", buffer.len(b), typeof(b))
	buffer.writeu8(b, 0, 200)
	buffer.writei8(b, 1, -100)
	buffer.writeu16(b, 2, 65500)
	buffer.writei16(b, 4, -12345)
	buffer.writeu32(b, 6, 4000000000)
	buffer.writei32(b, 10, -2000000000)
	buffer.writef32(b, 14, 0.5)
	buffer.writef64(b, 18, 1/3)
	T("s26.ints", buffer.readu8(b, 0), buffer.readi8(b, 1), buffer.readu16(b, 2),
		buffer.readi16(b, 4), buffer.readu32(b, 6), buffer.readi32(b, 10))
	T("s26.floats", buffer.readf32(b, 14), buffer.readf64(b, 18))
	T("s26.reinterpret", buffer.readu8(b, 2), buffer.readu8(b, 3))
	local sb = buffer.fromstring("buffer-str")
	T("s26.fromstring", buffer.len(sb), buffer.readstring(sb, 0, 6), buffer.tostring(sb))
	buffer.writestring(sb, 7, "XYZ")
	T("s26.writestring", buffer.tostring(sb))
	local dst = buffer.create(4)
	buffer.copy(dst, 0, sb, 7, 3)
	T("s26.copy", buffer.readstring(dst, 0, 3))
	buffer.fill(dst, 0, 65, 4)
	T("s26.fill", buffer.tostring(dst))
	buffer.writebits(b, 24 * 8, 4, 0xA)
	buffer.writebits(b, 24 * 8 + 4, 4, 0x5)
	T("s26.bits", buffer.readbits(b, 24 * 8, 8), buffer.readu8(b, 24))
	local okOOB, errOOB = pcall(function() buffer.readu8(b, 32) end)
	T("s26.oob", okOOB, scrub(errOOB))
end

banner("S27 vector library")
do
	local v = vector.create(1, 2, 3)
	local u = vector.create(4, 5, 6)
	T("s27.create", v, typeof(v), type(v))
	T("s27.components", v.x, v.y, v.z)
	T("s27.constants", vector.zero, vector.one)
	T("s27.add-sub", v + u, u - v)
	T("s27.scale", v * 2, 2 * v, u / 2)
	T("s27.componentwise", v * u, u / v)
	T("s27.neg", -v)
	T("s27.eq", v == vector.create(1, 2, 3), v == u)
	T("s27.magnitude", vector.magnitude(vector.create(3, 4, 0)))
	T("s27.normalize", vector.normalize(vector.create(0, 8, 0)))
	T("s27.dot-cross", vector.dot(v, u), vector.cross(vector.create(1, 0, 0), vector.create(0, 1, 0)))
	T("s27.angle", vector.angle(vector.create(1, 0, 0), vector.create(0, 1, 0)))
	T("s27.rounding", vector.floor(vector.create(1.7, -1.2, 0.5)), vector.ceil(vector.create(1.2, -1.7, 0.5)))
	T("s27.abs-sign", vector.abs(vector.create(-1, 2, -3)), vector.sign(vector.create(-5, 0, 9)))
	T("s27.clamp", vector.clamp(vector.create(5, -5, 0), vector.zero, vector.one * 2))
	T("s27.minmax", vector.min(v, u), vector.max(v, vector.create(0, 9, 2)))
	local vkey = {}
	vkey[vector.create(1, 1, 1)] = "unit-corner"
	T("s27.as-key", vkey[vector.create(1, 1, 1)])
	local sum = vector.zero
	for _, vec in ipairs({ v, u, vector.one }) do
		sum += vec
	end
	T("s27.accumulate", sum)
end

banner("S28 type syntax zoo (erased at runtime)")
do
	local pt: Point = { x = 3, y = 4 }
	local shade: Shade = "dark"
	local maybe: MaybeNum = nil
	local either: StrOrNum = "str-now"
	either = 99
	local dict: Dict = { one = 1, two = 2 }
	T("s28.annotated", pt.x, pt.y, shade, maybe, either, dict.two)
	local function hyp(p: Point): number
		return math.sqrt(p.x * p.x + p.y * p.y)
	end
	T("s28.fn-types", hyp(pt))
	local function identity<T>(v: T): T
		return v
	end
	T("s28.generic-fn", identity(5), identity("gen"), identity(true))
	local function firstOf<T, U>(a: T, b: U): T
		return a
	end
	T("s28.two-params", firstOf(1, "x"), firstOf("y", 2))
	local function packThrough<A...>(...: A...): (number, A...)
		return select("#", ...), ...
	end
	T("s28.type-pack", packThrough("p", "q"))
	local casted = (("55" :: any) :: string)
	T("s28.cast-chain", tonumber(casted :: string), casted :: string)
	local anyv: any = { deep = { 1, 2 } }
	T("s28.any-nav", (anyv :: any).deep[2])
	local idv: Identity<number> = 77
	T("s28.type-function", idv)
	local vararg: (...number) -> number = function(...: number): number
		local s = 0
		for i = 1, select("#", ...) do s += select(i, ...) end
		return s
	end
	T("s28.variadic-ann", vararg(1, 2, 3, 4))
	local tv: typeof(math.abs) = math.abs
	T("s28.typeof-type", tv(-9))
	local nested: Placed = { pos = pt, tags = { "a", "b" } }
	T("s28.nested-type", nested.pos.y, nested.tags[2], nested.meta)
	T("s28.typeof-values", typeof(nil), typeof(true), typeof(0), typeof(""), typeof({}),
		typeof(print), typeof(coroutine.create(function() end)), typeof(buffer.create(1)),
		typeof(vector.zero), typeof(newproxy()))
	T("s28.type-values", type(nil), type(true), type(0), type(""), type({}), type(print),
		type(coroutine.create(function() end)), type(buffer.create(1)), type(vector.zero), type(newproxy()))
end

banner("S29 register & constant pressure")
do
	-- >256 distinct numeric constants in one proto: past K255 ADDK falls back to LOADK+ADD
	local function konst(): number
		local k = 0
		k += 10001; k += 10002; k += 10003; k += 10004; k += 10005; k += 10006
		k += 10007; k += 10008; k += 10009; k += 10010; k += 10011; k += 10012
		k += 10013; k += 10014; k += 10015; k += 10016; k += 10017; k += 10018
		k += 10019; k += 10020; k += 10021; k += 10022; k += 10023; k += 10024
		k += 10025; k += 10026; k += 10027; k += 10028; k += 10029; k += 10030
		k += 10031; k += 10032; k += 10033; k += 10034; k += 10035; k += 10036
		k += 10037; k += 10038; k += 10039; k += 10040; k += 10041; k += 10042
		k += 10043; k += 10044; k += 10045; k += 10046; k += 10047; k += 10048
		k += 10049; k += 10050; k += 10051; k += 10052; k += 10053; k += 10054
		k += 10055; k += 10056; k += 10057; k += 10058; k += 10059; k += 10060
		k += 10061; k += 10062; k += 10063; k += 10064; k += 10065; k += 10066
		k += 10067; k += 10068; k += 10069; k += 10070; k += 10071; k += 10072
		k += 10073; k += 10074; k += 10075; k += 10076; k += 10077; k += 10078
		k += 10079; k += 10080; k += 10081; k += 10082; k += 10083; k += 10084
		k += 10085; k += 10086; k += 10087; k += 10088; k += 10089; k += 10090
		k += 10091; k += 10092; k += 10093; k += 10094; k += 10095; k += 10096
		k += 10097; k += 10098; k += 10099; k += 10100; k += 10101; k += 10102
		k += 10103; k += 10104; k += 10105; k += 10106; k += 10107; k += 10108
		k += 10109; k += 10110; k += 10111; k += 10112; k += 10113; k += 10114
		k += 10115; k += 10116; k += 10117; k += 10118; k += 10119; k += 10120
		k += 10121; k += 10122; k += 10123; k += 10124; k += 10125; k += 10126
		k += 10127; k += 10128; k += 10129; k += 10130; k += 10131; k += 10132
		k += 10133; k += 10134; k += 10135; k += 10136; k += 10137; k += 10138
		k += 10139; k += 10140; k += 10141; k += 10142; k += 10143; k += 10144
		k += 10145; k += 10146; k += 10147; k += 10148; k += 10149; k += 10150
		k += 10151; k += 10152; k += 10153; k += 10154; k += 10155; k += 10156
		k += 10157; k += 10158; k += 10159; k += 10160; k += 10161; k += 10162
		k += 10163; k += 10164; k += 10165; k += 10166; k += 10167; k += 10168
		k += 10169; k += 10170; k += 10171; k += 10172; k += 10173; k += 10174
		k += 10175; k += 10176; k += 10177; k += 10178; k += 10179; k += 10180
		k += 10181; k += 10182; k += 10183; k += 10184; k += 10185; k += 10186
		k += 10187; k += 10188; k += 10189; k += 10190; k += 10191; k += 10192
		k += 10193; k += 10194; k += 10195; k += 10196; k += 10197; k += 10198
		k += 10199; k += 10200; k += 10201; k += 10202; k += 10203; k += 10204
		k += 10205; k += 10206; k += 10207; k += 10208; k += 10209; k += 10210
		k += 10211; k += 10212; k += 10213; k += 10214; k += 10215; k += 10216
		k += 10217; k += 10218; k += 10219; k += 10220; k += 10221; k += 10222
		k += 10223; k += 10224; k += 10225; k += 10226; k += 10227; k += 10228
		k += 10229; k += 10230; k += 10231; k += 10232; k += 10233; k += 10234
		k += 10235; k += 10236; k += 10237; k += 10238; k += 10239; k += 10240
		k += 10241; k += 10242; k += 10243; k += 10244; k += 10245; k += 10246
		k += 10247; k += 10248; k += 10249; k += 10250; k += 10251; k += 10252
		k += 10253; k += 10254; k += 10255; k += 10256; k += 10257; k += 10258
		k += 10259; k += 10260; k += 10261; k += 10262; k += 10263; k += 10264
		k += 10265; k += 10266; k += 10267; k += 10268; k += 10269; k += 10270
		return k
	end
	T("s29.k-overflow", konst())
	local a1, a2, a3, a4, a5 = 1, 2, 3, 4, 5
	local b1, b2, b3, b4, b5 = 6, 7, 8, 9, 10
	local c1, c2, c3, c4, c5 = 11, 12, 13, 14, 15
	local d1, d2, d3, d4, d5 = 16, 17, 18, 19, 20
	local e1, e2, e3, e4, e5 = 21, 22, 23, 24, 25
	local f1, f2, f3, f4, f5 = 26, 27, 28, 29, 30
	local live = a1 + a2 + a3 + a4 + a5 + b1 + b2 + b3 + b4 + b5
		+ c1 + c2 + c3 + c4 + c5 + d1 + d2 + d3 + d4 + d5
		+ e1 + e2 + e3 + e4 + e5 + f1 + f2 + f3 + f4 + f5
	T("s29.many-locals", live)
	local deep = (((a1 + b1) * (c1 + d1)) - ((e1 + f1) * (a2 - b2)))
		+ ((((c2 * d2) - (e2 // f2)) + ((a3 ^ 2) % (b3 + c3))) * 2)
	T("s29.deep-expr", deep)
	local lc = "a" .. "b" .. "c" .. "d" .. "e" .. "f" .. "g" .. "h" .. "i" .. "j"
		.. "k" .. "l" .. "m" .. "n" .. "o" .. "p" .. "q" .. "r" .. "s" .. "t"
	T("s29.long-concat", lc, #lc)
	local function sum3(p, q, r) return p + q + r end
	T("s29.nested-args", sum3(sum3(1, 2, 3), sum3(4, 5, sum3(6, 7, 8)), sum3(9, 10, 11)))
end

banner("S30 builtin fastcall shapes")
do
	local x, y, z = GF, GA, GB
	T("s30.fc1", math.floor(x), math.abs(GNEG), math.sqrt(y + 2))
	T("s30.fc2", math.max(x, y), math.min(y, z), math.fmod(y, z))
	T("s30.fc2k", math.max(y, 100), bit32.band(y, 0xFE), bit32.lshift(y, 4),
		bit32.rshift(y, 1), math.min(y, 5))
	T("s30.fc3", math.clamp(y, 0, 5), bit32.extract(y, 1, 2), vector.create(x, y, z))
	T("s30.fc-generic", bit32.bor(1, 2, 4, y), math.max(1, 2, y, 4, 5), string.char(72, 73, 74, 75))
	T("s30.fc-type", type(x), typeof(x), tostring(y), tonumber("42"), rawlen({ 1, 2 }))
	T("s30.fc-multiret", string.byte("ABCD", 1, 4))
	T("s30.folded", math.floor(2.5), math.abs(-5), math.max(7, 100), bit32.band(7, 0xFE))
	local floor, maxv = math.floor, math.max
	T("s30.aliased", floor(x + 1), maxv(x, 99))
	T("s30.chained", math.floor(math.abs(GNEG) + math.sqrt(y * y)))
	T("s30.select", select("#", y, z, x), select(2, "s1", "s2", "s3"))
	T("s30.tonumber", tonumber("0x1F"), tonumber("101", 2), tonumber("z", 36),
		tonumber("  10  "), tonumber("bad"), tonumber("10", 8))
	T("s30.tostring", tostring(nil), tostring(true), tostring(-0.5), tostring(GBIG))
end

banner("S31 debug info (arity survives compilation)")
do
	local function namedLocal(a, b, c) return a end
	local function varArity(a, ...) return a end
	T("s31.name-present", type(debug.info(namedLocal, "n")))
	T("s31.arity", debug.info(namedLocal, "a"))
	T("s31.arity-vararg", debug.info(varArity, "a"))
	local holder = {}
	function holder:method(q) return q end
	T("s31.name-method", debug.info(holder.method, "a"))
	T("s31.currentline-type", type(debug.info(1, "l")))
	T("s31.traceback-type", type(debug.traceback("msg", 1)))
end

banner("S32 the gauntlet (integrated stress)")
do
	local state, hops = "start", 0
	while state ~= "halt" do
		hops += 1
		if state == "start" then
			state = "load"
		elseif state == "load" then
			state = if hops > 2 then "run" else "load"
		elseif state == "run" then
			state = hops % 2 == 0 and "flush" or "run"
		elseif state == "flush" then
			state = "halt"
		end
		if hops > 20 then break end
	end
	T("s32.fsm", state, hops)
	local trace = {}
	local function emit(entry: string)
		trace[#trace + 1] = entry
	end
	local machine = { acc = 0, steps = 0 }
	local ops = setmetatable({}, {
		__index = function(_, name)
			return function(m, _arg)
				m.steps += 1
				emit("?" .. name)
			end
		end,
	})
	function ops.add(m, arg) m.steps += 1 m.acc += arg emit("+" .. arg) end
	function ops.mul(m, arg) m.steps += 1 m.acc *= arg emit("*" .. arg) end
	function ops.jam(m, _arg) m.steps += 1 error("jammed@" .. m.steps, 0) end
	local program = "add:5 mul:3 hop:1 add:2 jam:0 mul:2 add:1"
	local feed = coroutine.wrap(function()
		for op, arg in string.gmatch(program, "(%a+):(%d+)") do
			coroutine.yield(op, tonumber(arg))
		end
		return nil
	end)
	local jams = 0
	repeat
		local op, arg = feed()
		if op == nil then break end
		local ok, err = pcall(ops[op], machine, arg)
		if not ok then
			jams += 1
			emit("!" .. tostring(err))
			continue
		end
	until machine.steps > 50
	T("s32.vm", machine.acc, machine.steps, jams)
	T("s32.vm-trace", table.concat(trace, " "))
	local checksum = 0
	local blob = table.concat(trace, ";")
	for i = 1, #blob do
		local byte = string.byte(blob, i)
		checksum = bit32.bxor(bit32.lshift(checksum, 1) % 2^24, byte + i)
		if checksum % 7 == 0 then
			checksum += 13
		end
	end
	T("s32.checksum", checksum, #blob)
	local layers = {}
	for layer = 1, 3 do
		local row = {}
		for slot = 1, 3 do
			row[slot] = function(v)
				return v + layer * 10 + slot
			end
		end
		layers[layer] = row
	end
	local lattice = 0
	for layer = 1, 3 do
		for slot = 1, 3 do
			lattice = layers[layer][slot](lattice)
		end
	end
	T("s32.lattice", lattice)
	local doc = {
		kind = "root",
		items = {
			{ kind = "leaf", weight = 2 },
			{ kind = "node", items = {
				{ kind = "leaf", weight = 3 },
				{ kind = "skip" },
				{ kind = "node", items = { { kind = "leaf", weight = 5 } } },
			} },
			{ kind = "skip" },
			{ kind = "leaf", weight = 7 },
		},
	}
	local function weigh(node): number
		if node.kind == "leaf" then
			return node.weight
		elseif node.kind == "skip" then
			return 0
		end
		local total = 0
		local idx = 0
		repeat
			idx += 1
			local child = node.items[idx]
			if child == nil then break end
			if child.kind == "skip" then continue end
			total += weigh(child)
		until idx >= #node.items
		return total
	end
	T("s32.weigh", weigh(doc))
end

banner("S33 edge cases")
-- Every shape that once produced a miscompilation: each recompiled cleanly but
-- computed a wrong value, a wrong order, or a wrong branch, mostly at -O1/-O2.
do
	-- 33.1 operand position is observable through non-commutative metamethods
	local NC = {}
	NC.__index = NC
	local function nc(v: number) return setmetatable({ v = v }, NC) end
	local function nv(x): number
		if type(x) == "table" then return x.v end
		return x
	end
	NC.__add = function(a, b) return nc(nv(a) - nv(b)) end
	NC.__mul = function(a, b) return nc(nv(a) / nv(b)) end
	NC.__sub = function(a, b) return nc(nv(a) - 2 * nv(b)) end
	NC.__concat = function(a, b) return "[" .. tostring(nv(a)) .. "|" .. tostring(nv(b)) .. "]" end
	local three = nc(3)
	T("s33.mm-add", (6 + three).v, (three + 6).v)
	T("s33.mm-mul", (6 * three).v, (three * 6).v)
	T("s33.mm-sub", (6 - three).v, (three - 6).v)
	T("s33.mm-concat", 6 .. three, three .. 6)
	local n7 = GA
	T("s33.k-order", 2 * n7, n7 * 2, 2 + n7, n7 + 2, 2 - n7, n7 - 2)
	T("s33.k-order-div", 2 / n7, n7 / 2, 2 % n7, n7 % 2, 2 // n7, n7 // 2)
	T("s33.k-order-mixed", (2 * (n7 % 4) + 4 * (n7 % 7) + 6 * n7 + 1) % 7, 22 + n7 + 1)
	-- 33.2 a multiple assignment evaluates every right-hand side before any store
	local reads = {}
	local probe = setmetatable({}, {
		__index = function(_, k)
			reads[#reads + 1] = tostring(k)
			return "<" .. tostring(k) .. ">"
		end,
	})
	local p1, p2 = probe.alpha, probe.beta
	T("s33.multi-local", p1, p2, table.concat(reads, ","))
	reads = {}
	GMA, GMB = probe.gamma, probe.delta
	T("s33.multi-global", GMA, GMB, table.concat(reads, ","))
	reads = {}
	local box = {}
	box.one, box.two = probe.eps, probe.zeta
	T("s33.multi-field", box.one, box.two, table.concat(reads, ","))
	reads = {}
	local sw1, sw2 = probe.x, probe.y
	sw1, sw2 = sw2, sw1
	T("s33.multi-swap", sw1, sw2, table.concat(reads, ","))
	-- 33.3 a captured cell is shared: re-read it after a sibling may have changed it
	local cell = 0
	local function nudge() cell += 100 end
	local function stamp(v: number)
		cell = v
		nudge()
		return cell == v, cell
	end
	T("s33.upval-reread", stamp(5))
	T("s33.upval-reread2", stamp(7))
	local latch = "start"
	local function setLatch(v: string) latch = v end
	local function getLatch() return latch end
	T("s33.upval-before", getLatch())
	setLatch("changed")
	T("s33.upval-after", getLatch())
	local later
	local function peek() return later end
	T("s33.upval-nil", peek())
	later = "set"
	T("s33.upval-set", peek())
	-- 33.4 a table constructor may not be deferred past the closure that sees its slot
	local seenKeys = {}
	local watch = setmetatable({}, {
		__index = function(_, k)
			seenKeys[#seenKeys + 1] = tostring(k)
			return "w:" .. tostring(k)
		end,
	})
	seenKeys = {}
	local w1, w2 = watch.one, watch.two
	T("s33.deferred-table", w1, w2, table.concat(seenKeys, ","))
	seenKeys = {}
	local w3 = watch.three
	T("s33.deferred-table2", w3, table.concat(seenKeys, ","))
	-- 33.5 and/or chains whose operands have side effects
	local calls = {}
	local function eff(tag: string, ret: any)
		calls[#calls + 1] = tag
		return ret
	end
	local syn = { request = false }
	local htt = { request = "H" }
	local chosen = eff("a", nil) or (syn and eff("b", syn.request))
		or (htt and eff("c", htt.request)) or "fallback"
	T("s33.or-chain", tostring(chosen), table.concat(calls, ","))
	local function diamond(x: any, y: any)
		if (eff("a", x) and eff("b", y)) or (eff("c", not x) and eff("d", not y)) then
			return "T"
		end
		return "F"
	end
	for _, x in ipairs({ true, false }) do
		for _, y in ipairs({ true, false }) do
			calls = {}
			T("s33.diamond", tostring(x), tostring(y), diamond(x, y), table.concat(calls, ","))
		end
	end
	-- 33.6 a then-branch ending in `if C then ... return end`, then an else: at
	-- -O1/-O2 the jump over the else is threaded straight to the final RETURN
	local steps = {}
	local function loader(outer: any, inner: any)
		if outer then
			if inner then
				local ok = inner == "good"
				if not ok then
					steps[#steps + 1] = "retry"
					return
				end
			else
				steps[#steps + 1] = "rewrite"
				return
			end
		else
			steps[#steps + 1] = "factory"
		end
	end
	for _, outer in ipairs({ true, false }) do
		for _, inner in ipairs({ "good", "bad", false }) do
			steps = {}
			loader(outer, inner)
			T("s33.threaded-else", tostring(outer), tostring(inner),
				"[" .. table.concat(steps, ",") .. "]")
		end
	end
	local function nestedLoader(a: any, b: any, c: any)
		local hits = {}
		if a then
			if b then
				if c then
					hits[#hits + 1] = "abc"
					return table.concat(hits, ",")
				end
				hits[#hits + 1] = "ab"
			else
				hits[#hits + 1] = "a"
				return table.concat(hits, ",")
			end
			hits[#hits + 1] = "a-tail"
		else
			hits[#hits + 1] = "none"
		end
		hits[#hits + 1] = "end"
		return table.concat(hits, ",")
	end
	for mask = 0, 7 do
		T("s33.threaded-deep" .. mask, nestedLoader(
			bit32.btest(mask, 4), bit32.btest(mask, 2), bit32.btest(mask, 1)))
	end
	-- 33.7 the same escaping branch inside a loop, and two exits to one join
	local marks = {}
	for i = 1, 6 do
		if i % 2 == 0 then
			if i > 3 then
				marks[#marks + 1] = "big" .. i
				continue
			end
			marks[#marks + 1] = "even" .. i
		else
			marks[#marks + 1] = "odd" .. i
		end
		marks[#marks + 1] = "tail" .. i
	end
	T("s33.loop-escape", table.concat(marks, " "))
	local twin = {}
	local function twoExits(p: any, q: any)
		if p then
			if q then
				twin[#twin + 1] = "pq"
				return "both"
			end
			twin[#twin + 1] = "p"
			return "first"
		end
		twin[#twin + 1] = "none"
		return "neither"
	end
	for _, p in ipairs({ true, false }) do
		for _, q in ipairs({ true, false }) do
			twin = {}
			T("s33.twin-exits", tostring(p), tostring(q), twoExits(p, q),
				table.concat(twin, ","))
		end
	end
	-- 33.8 a for control variable named like the outer local its bounds read
	local idx = 2
	local walked = {}
	for idx = idx, idx + 2 do walked[#walked + 1] = idx end
	T("s33.for-var-outer", idx, table.concat(walked, ","))
	local key = "outer"
	local pairsSeen = {}
	for key, v in ipairs({ "p", "q" }) do pairsSeen[#pairsSeen + 1] = key .. v end
	T("s33.forg-var-outer", key, table.concat(pairsSeen, ","))
	-- 33.9 `local function` captures the very register it is stored into
	local function pathOf(text: string)
		if text ~= "" then
			local ext = ""
			local function grow()
				if #ext < 2 then
					ext = ext .. "!"
					return grow()
				end
				return text .. ext
			end
			return grow()
		end
		return "empty"
	end
	T("s33.self-capture", pathOf("name"), pathOf(""))
	-- 33.10 a slot closed by CLOSEUPVALS reused for an unrelated variable at once
	local made = {}
	for round = 1, 2 do
		local acc = round * 10
		made[#made + 1] = function()
			acc += 1
			return acc
		end
	end
	local reuse = (GA > GB) and "gt" or "le"
	T("s33.closeupvals", made[1](), made[1](), made[2](), reuse)
	-- 33.11 never-written registers hold nil; one slot defaults several conditionals
	local function defaulted(c1: any, c2: any)
		local r1
		if c1 then r1 = "one" end
		local r2
		if c2 then r2 = "two" end
		return r1, r2, (if c1 then r1 else nil), (if c2 then "y" else nil)
	end
	T("s33.nil-defaults", defaulted(true, false))
	T("s33.nil-defaults2", defaulted(false, true))
	T("s33.nil-defaults3", defaulted(false, false))
	local function keep(c: any, cur: string)
		local v = cur
		if c then v = "new" end
		return v
	end
	local function bsel(s: any)
		return (if s ~= nil then s ~= "" else false), (if s == nil then true else s == "x")
	end
	T("s33.keep", keep(false, "old"), keep(true, "old"))
	T("s33.bsel-nil", bsel(nil))
	T("s33.bsel-empty", bsel(""))
	T("s33.bsel-x", bsel("x"))
	-- 33.12 `..` is right-associative and lowers to one range CONCAT
	local ca, cb, cc = "x", "y", "z"
	T("s33.concat-assoc", ca .. cb .. cc, (ca .. cb) .. cc, ca .. (cb .. cc))
	T("s33.concat-mm", three .. ca, ca .. three)
end

-- ===== conformance: the core language ========================================
-- basic.luau       arithmetic, comparison and concat on every operand kind, register moves, overflow edges
-- constructs.luau  priorities and short-circuit soup over constants and variables, nested branches
-- literals.luau    every number and string spelling, escapes, long brackets
-- locals.luau      shadowing, scope ends, a hundred live locals, `do return end` before dead code
-- move.luau        table.move over every overlap, through metamethods, into other tables
-- vararg.luau      `...` in every position: locals, tables, calls, returns, select, pack/unpack
-- calls.luau       deep, tail, method and __call chains, a hundred arguments, pcall of pcall
-- closure.luau     captures in every loop kind, shared cells, closing on break/return/error
-- ndebug_upvalues  upvalues read and written through levels with no names to lean on
-- tpack.luau       string.pack/unpack/packsize with every format option
-- types.luau, explicit_type_instantiations.luau: annotations, casts, f<<T>>() instantiation
-- stringinterp.luau, ifelseexpr.luau, attrib.luau, assert.luau, strconv.luau
local ConfCore = {}
function ConfCore.basic(a, b, s, t, ...)
	Sink(a + b, a - b, a * b, a / b, a % b, a ^ b, a // b, -a, a .. b, #s, #t, not a)
	Sink(a == b, a ~= b, a < b, a <= b, a > b, a >= b, s < "m", "m" <= s, s == "x", t == nil)
	Sink(1 + a, 1 - a, 2 * a, 2 / a, 3 % a, 2 ^ a, 7 // a, a + 0.5, a - -1, a * -1, a / -2, a % -3, a ^ 0.5, a // -2)
	Sink("10" + 1, "0x10" * 2, " 3 " - 1, 10 .. 20, 1.5 .. "", -0.0 .. "", 2 ^ 63 .. "", 1e100 .. "", (0 / 0) .. "")
	a = a + a; b = b * b; a, b = b, a; a = -a; b = not b; s = s .. s .. s
	local x, y, z = a, a, a
	x = y; y = z; z = x
	Sink(x, y, z, a, b, s)
	do local p = a; do local q = p + 1; do local r = q + 1; Sink(p, q, r) end end end
	if a == 0 then Sink(0) elseif a == -1 then Sink(-1) elseif a == 0.5 then Sink(0.5) elseif a == 1e300 then Sink(1e300) elseif a == "s" then Sink("s") elseif a == true then Sink(true) elseif a == nil then Sink(nil) end
	if 0 == a or "s" == a or nil == a or false == a then Sink(1) end
	if a ~= a then Sink("nan") end
	conf_acc = (conf_acc or 0) + a; conf_acc = conf_acc * 2; conf_acc += 1
	Sink(conf_acc, conf_unset, conf_unset and conf_unset.x)
	Sink(#"", #"abc", #{}, #{ 1, 2, 3 }, #{ n = 1 }, #{ 1, nil, 3 }, #t, #s, #(s .. s), #{ ... }, select("#", ...))
	Sink(2 ^ 53 + 1 == 2 ^ 53, 2 ^ 31 * 2, -2 ^ 31, 0xFFFFFFFF + 1, 1e308 + 1e308, -(0 / 0), math.huge - math.huge, 1 / (-1 / math.huge), 5 // 0, -5 // 0, 0 // 0, 5 % math.huge, -5 % math.huge, 5.5 % -math.huge)
	return a, b, ...
end
function ConfCore.constructs(a, b, c)
	Sink(2 ^ 3 ^ 2, -2 ^ 2, 2 ^ -2, not nil == true, not 1 == false, 1 .. 2 == "12", 2 .. 3 + 1, "a" .. "b" == "ab", 1 < 2 == true, a or b and c, (a or b) and c, a and b or c and a)
	Sink(nil and 1, nil or 1, false and nil, false or nil, 1 and nil, 1 or nil, not not nil, not (1 and nil), (nil or false) == false, (1 and 2) == 2, (nil and nil) == nil)
	for _, x in { a, false, 0, "", b } do
		for _, y in { c, true, 1 } do
			Sink(x and y, x or y, not x and y, x and not y, not (x or y), x and y or x, (x or y) and (y or x), x == y, x ~= y)
			if x and y then Sink(1) elseif x or y then Sink(2) elseif not x then Sink(3) else Sink(4) end
			if not (x and y) and (x or y) then Sink(5) end
			while x and not y do x = y end
			repeat y = not y until y or x
		end
	end
	local i = 0
	while i < 10 do i += 1; if i % 3 == 0 then continue elseif i == 8 then break end Sink(i) end
	repeat local j = i; i -= 1 until j <= 1
	if a then if b then if c then Sink("abc") else Sink("ab") end elseif c then Sink("ac") else Sink("a") end elseif b then Sink("b") else Sink("-") end
	Sink(a + b * c, (a + b) * c, a * b + c, a * (b + c), a - b ^ c, (a - b) ^ c, a .. b .. c == a .. (b .. c), a < b and b < c, a < (b and c), (a or b) < c, not a < b, not (a < b), -a ^ 2, (-a) ^ 2, a % b * c, a % (b * c), a // b ^ c, (a // b) ^ c)
	return if a then b elseif b then c else a
end
function ConfCore.literals(a)
	Sink(0.1e1, 1e-400, 123456789012345678, 0x7FFFFFFFFFFFFFFF, 0xFFFFFFFFFFFFFFFF, 0b11111111111111111111111111111111, 1_2_3, 1e+308, 4.9e-324, .0, 0., 00012, 0e0, 0E-0, 3e0, 0x10, 0X10, 0b10, 0B10)
	Sink("\1\12\123\0011", "\x7f\x7F\x00", "\u{7F}\u{80}\u{800}\u{10000}", "tab\tnl\nsq\'dq\"bs\\", "\z

		     trimmed", [==[
]] ]=] ]==], [[a\nb]], "a" .. [[
]] .. "b", '\'', "\"", '"', "'")
	Sink(`{a}{a}{a}{a}{a}{a}{a}{a}`, `\u{1F600}{a}`, `{ {a, a} }`, `{a}\``, `\\{a}\\`, `{"}"}`, `{'{'}`)
	return [[
]], [==[]==], "", ``
end
function ConfCore.locals(p, q, ...)
	local p = p; local q = q or p; local p, q = q, p
	local l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12, l13, l14, l15, l16, l17, l18, l19, l20, l21, l22, l23, l24, l25 = p, q, ...
	local m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16, m17, m18, m19, m20, m21, m22, m23, m24, m25 = l25, l24, l23, l22, l21, l20, l19, l18, l17, l16, l15, l14, l13, l12, l11, l10, l9, l8, l7, l6, l5, l4, l3, l2, l1
	local n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25 = Host.many()
	local o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12, o13, o14, o15, o16, o17, o18, o19, o20, o21, o22, o23, o24, o25 = ...
	Sink(l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12, l13, l14, l15, l16, l17, l18, l19, l20, l21, l22, l23, l24, l25, m1, m2, m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15, m16, m17, m18, m19, m20, m21, m22, m23, m24, m25, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12, o13, o14, o15, o16, o17, o18, o19, o20, o21, o22, o23, o24, o25)
	local grab = function() l1 += m25; n13 = o7; return l1, m25, n13, o7, o25, n25, m1 end
	local function rec(n) if n > 0 then return rec(n - 1) end return n end
	local x = 1; do local x = x + 1; do local x = x * 2; Sink(x) end Sink(x) end Sink(x)
	for x = x, x + 1 do local x = x; Sink(x) end
	local f = function() return x end; local x = 5; Sink(f(), x, grab(), rec(3))
	do return l1, ... end
	Sink("dead after do return end", p, q)
end
function ConfCore.move(t, u, n, proxy)
	Sink(table.move(t, 1, 3, 2), table.move(t, 2, 4, 1), table.move(t, 1, 0, 5), table.move(t, 1, n, n + 1), table.move(t, n, 1, 1), table.move(t, -2, 2, 1), table.move(t, 1, 3, 1, u), table.move(t, 1, 3, 3, t), table.move({}, 1, 0, 1, u))
	local logged = setmetatable({}, { __index = function(_, k) Sink("get", k) return k * 10 end, __newindex = function(s, k, v) Sink("set", k, v); rawset(s, k, v) end })
	Sink(table.move(logged, 1, 4, 2), table.move(logged, 1, 4, 1, proxy), table.move(proxy, 1, n, 1, logged), pcall(table.move, t, 1, math.huge, 2), pcall(table.move, t, -math.huge, 1, 1), pcall(table.move, t, 1, 2, math.huge))
	return table.move(table.move(t, 1, #t, 1, {}), 1, #t, 1, table.create(#t))
end
function ConfCore.vararg(f, ...)
	local a, b, c = ...
	local n = select("#", ...)
	local packed, listed = table.pack(...), { ... }
	Sink(..., n, a, b, c, packed.n, #listed, (...), select(2, ...), select(-1, ...), select(n, ...))
	Sink(f(...), f(..., 1), f(1, ...), f((...)), { ..., ... }, { (...), ... }, `{...}`, ... == nil, (...) == nil, if ... then 1 else 2, not ..., -(...))
	local function count(...) return select("#", ...) end
	local function tail(...) return ... end
	local function pass(...) return count(...), tail(...) end
	local function drop(_, ...) return ... end
	local function keepFirst(x) return x end
	Sink(count(), count(nil), count(nil, nil), count(...), count(tail(...)), count((tail(...))), pass(...), drop(...), keepFirst(...), table.unpack({ ... }, 1, n), table.unpack(packed, 1, packed.n))
	for i = 1, select("#", ...) do Sink(i, (select(i, ...))) end
	for i, v in { ... } do Sink(i, v) end
	local co = coroutine.wrap(function(...) local got = { coroutine.yield(...) } return select("#", table.unpack(got)), ... end)
	Sink(co(...), co(...))
	if select("#", ...) > 3 then return ... end
	return select(2, ...)
end
function ConfCore.calls(f, t, n, ...)
	local function deep(k) if k == 0 then return 0 end return 1 + deep(k - 1) end
	local function tail(k, acc) if k == 0 then return acc end return tail(k - 1, acc + k) end
	local callable = setmetatable({}, { __call = function(self, x, ...) return self, x, ... end })
	local chained = setmetatable({}, { __call = callable })
	local o = { v = n }
	function o:get(...) return self.v, ... end
	function o.static(...) return ... end
	Sink(deep(n), tail(n, 0), callable(1, 2), chained(3), pcall(chained, 4), o:get(), o.get(o, 1), o.static(o), pcall(pcall, error, "e"), select("#", pcall(error)), pcall(pcall, pcall, f), xpcall(pcall, f, error))
	Sink(f(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, ...))
	Sink(t.a.b.c.d(n), t["a"]["b"]:c(n), t[1][2][3](n), (t.f or f)(n), t:m(n):m(n):m(n), f(f(f(f(f(n))))), f(n)(n)(n)(n), string.format("%d", n), ("x"):rep(n):len())
	return f(...)
end
function ConfCore.closure(list, n)
	local fs = {}
	for i = 1, n do fs[#fs + 1] = function() return i end end
	for i, v in ipairs(list) do fs[#fs + 1] = function() return i, v end end
	for k in pairs(list) do fs[#fs + 1] = function() return k end end
	local w = 0
	while w < n do w += 1; local c = w; fs[#fs + 1] = function() c += 1; return c end end
	local r = 0
	repeat r += 1; local d = r; fs[#fs + 1] = function() return d end until d >= n
	for i = 1, n do local e = i; fs[#fs + 1] = function() return e end; if i == 2 then break end end
	for i = 1, n do local g = i; if g == 3 then fs[#fs + 1] = function() return g end; return fs end end
	local ok = pcall(function() for i = 1, n do local h = i; fs[#fs + 1] = function() return h end; if i == 4 then error("closing on error") end end end)
	local shared = 0
	local inc, get = function() shared += 1 end, function() return shared end
	local a = { f = function() return inc end }
	a.f()(); inc()
	local function outer()
		local x = 0
		local function mid()
			local y = x
			return function() x += 1; y += 1; return x, y end
		end
		return mid(), mid()
	end
	local m1, m2 = outer()
	Sink(fs, ok, get(), m1(), m2(), m1(), shared)
	local self_ref
	self_ref = function(k) if k > 0 then return self_ref(k - 1) end return self_ref end
	return self_ref
end
function ConfCore.upvalues(a)
	local u1, u2, u3 = a, a + 1, a + 2
	local function f() u1 = u2; u2 = u3; u3 = u1; return u1 + u2 + u3 end
	local function g() return function() return function() u1 += 1; return u1, u2, u3 end end end
	return f, g()()
end
function ConfCore.tpack(s, n, x)
	Sink(string.pack("b", n), string.pack("B", n), string.pack("h", n), string.pack("H", n), string.pack("i", n), string.pack("I", n), string.pack("l", n), string.pack("L", n), string.pack("j", n), string.pack("J", n), string.pack("T", n))
	Sink(string.pack("i1", n), string.pack("i2", n), string.pack("i3", n), string.pack("i4", n), string.pack("i7", n), string.pack("i8", n), string.pack("I1", n), string.pack("I3", n), string.pack("I5", n), string.pack("I16", n))
	Sink(string.pack("<i4", n), string.pack(">i4", n), string.pack("=i4", n), string.pack("!i4", n), string.pack("!4 i1 i4", n, n), string.pack("<!8 b xX i8", n, n), string.pack("f", x), string.pack("d", x), string.pack("n", x))
	Sink(string.pack("s", s), string.pack("s1", s), string.pack("s2", s), string.pack("s4", s), string.pack("z", s), string.pack("c5", s), string.pack("c0", ""), string.pack("x"), string.pack("Xi4"), string.pack(" < i 4 > i 2 ", n, n))
	Sink(string.unpack("<i4", s), string.unpack("<i4", s, 5), string.unpack("<i4", s, -4), string.unpack("z z", s), string.unpack("s1 B", s), string.unpack("c3", s), string.unpack("<d f", s), string.unpack(">I2 <I2 =I2", s))
	Sink(string.packsize("i4"), string.packsize("!8 i1 i8"), string.packsize("<i4 d"), string.packsize("c10"), string.packsize("b B h H l L j J T f d n x"), pcall(string.packsize, "s"), pcall(string.pack, "i17", 1), pcall(string.unpack, "i4", "\0"))
end
function ConfCore.types<T>(a: T, b: number, ...: string): (T, number, ...string)
	local x: number = b
	local y: { [string]: number } = { k = b }
	local z: (number) -> number = function(v: number): number return v * 2 end
	local w: typeof(z) = z
	local q = (a :: any) :: number
	local function identity<U>(v: U): U return v end
	local function multipleReturns<U>(v: U): (U, U) return v, v end
	local function typePacks<U...>(...: U...): U... return ... end
	local p1 = identity<<number>>(b)
	local p2, p3 = multipleReturns<<number>>(b)
	local p4, p5 = typePacks<<(string, number)>>(b, "a")
	local holder = {}
	function holder:method<U>(v: U): U return v end
	function holder:methodTypePacks<U...>(...: U...): U... return ... end
	local p6 = holder:method(b)
	local p7, p8 = holder:methodTypePacks<<(string, number)>>(b, "a")
	local r: Recursive<number> = { value = b, children = {} }
	local ro: ReadOnly = { x = b, y = b }
	Sink(x, y, z(x), w(x), q + 1, (q :: number) + 1, p1, p2, p3, p4, p5, p6, p7, p8, identity<<string>>("s"), r, ro, (Host :: any).x, (z :: any)(1), a :: any)
	return a, x, ...
end
function ConfCore.stringinterp(a, b, t)
	local mt = setmetatable({}, { __tostring = function() return "custom" end })
	Sink(`{a}`, `{a}{b}`, `pre{a}mid{b}post`, `{a + b}`, `{a .. b}`, `{t[1]}`, `{t.k}`, `{t:m()}`, `{mt}`, `{nil}`, `{true}`, `{ {} }`, `{`{`{a}`}`}`)
	Sink(`\{a}`, `a\nb`, `\t{a}\t`, `\u{48}{a}`, `\x41{a}`, `\65{a}`, `{a}%d`, `%{a}%`, `100%`, `{string.format("%5.2f", a)}`, `{if a then "y" else "n"}`, `{(function() return "iife" end)()}`, `{#t}`, `{-a}`, `{not a}`, `{a == b}`, `{a :: any}`)
	local s = `{a}`
	s ..= `{b}`
	s = `{s}{s}`
	return `{s}{a}{b}`, string.format("%*%*", a, b), string.format("%*", t)
end
function ConfCore.ifelseexpr(a, b, c, t)
	local x = if a then b else c
	local y = if a then if b then 1 else 2 elseif c then if b then 3 else 4 else 5
	t[if a then "k" else "j"] = if b then a else c
	Sink(x, y, t[if c then 1 else 2], (if a then t else {}).k, -(if a then 1 else -1), (if a then 1 else 2) + (if b then 3 else 4), if a then 1 else 2 + 3, `{if a then b else c}`, { if a then 1 else 2, k = if b then 3 else 4 })
	while if a then b else c do a = not a; if not a then break end end
	repeat x = if x then nil else 1 until if x then true else false
	for i = if a then 1 else 2, if b then 3 else 4 do Sink(i) end
	local fn = if a then function() return 1 end else function() return 2 end
	local side = if Host.get(1) then Host.get(2) elseif Host.get(3) then Host.get(4) else Host.get(5)
	return if a then b elseif c then t else nil, fn, side
end
function ConfCore.attrib(a)
	@native local function hot(x: number): number local s = 0 for i = 1, x do s += i * i end return s end
	@checked local function checked(x) return x end
	@deprecated local function old(x) return x end
	@native @checked local function both(x) return x end
	@[deprecated{reason = "use other", use = "other"}] local function reasoned(x) return x end
	local anon = @native function(x) return x + 1 end
	Sink(hot(a), checked(a), old(a), both(a), reasoned(a), anon(a), (@native function() return a end)(), debug.info(hot, "n"), debug.info(anon, "s"))
end
function ConfCore.assert(a, b, ...)
	Sink(assert(a), assert(a, b), assert(a, b, ...), select("#", assert(a, b, ...)), pcall(assert, nil), pcall(assert, false, "msg"), pcall(assert, nil, { code = 1 }), pcall(assert, a, nil), pcall(assert))
	local v = assert(Host.get(), "no host")
	return assert(v, `missing {a}`), assert(...)
end
function ConfCore.strconv(a, s)
	Sink(tostring(0.1), tostring(1 / 3), tostring(-0), tostring(1e15), tostring(1e16), tostring(123456789012), tostring(2 ^ 63), tostring(5e-324), tostring(1e308 * 10), tostring(-(0 / 0)), tostring(100), tostring(-1.5), tostring(a))
	Sink(tonumber("0x"), tonumber("1e"), tonumber(" 1 "), tonumber("1 2"), tonumber("inf"), tonumber("nan"), tonumber("0x1p4"), tonumber("1e400"), tonumber("-0"), tonumber(".5"), tonumber("5."), tonumber("0b101"), tonumber("1_000"), tonumber(""), tonumber(s))
	Sink(tonumber("ff", 16), tonumber("FF", 16), tonumber("zz", 36), tonumber("777", 8), tonumber("102", 2), tonumber("-ff", 16), tonumber(" 10 ", 10), tonumber(s, a), pcall(tonumber, "1", 1), pcall(tonumber, "1", 37))
	Sink(string.format("%.14g", a), string.format("%.17g", a), string.format("%.0f", a), string.format("%5.1f", a), string.format("%g", 1e300), string.format("%d", -0), a .. "", "" .. a, `{a}`)
end
registry.ConfCore = ConfCore

-- ===== conformance: bindings, iteration, tables ===============================
-- iflocal.luau / whilelocal.luau  every `if local`/`if const`/`while local`/`while const` spelling
-- iter.luau        generalized iteration, __iter, mutation while iterating, float and infinite bounds
-- iter_fenv.luau / safeenv.luau  the same loops with an environment swapped in (through _G, so the
--                  rest of this file keeps its imports, fastcalls and inlining)
-- sort.luau        table.sort with every comparator shape and every way it can fail
-- tables.luau      insert/remove/concat/unpack/create/find/clone/freeze edges, key normalisation
-- clear.luau       table.clear and reuse;  lazyload.luau  a module table filled on first touch
-- classes.luau     needs the DebugLuauUserDefinedClasses flag for `class`, so it is spelled with metatables
local ConfBind = {}
function ConfBind.iflocal(a, t, f)
	local x = "outer"
	if local x = t.x then Sink(x) end
	if local x = x then Sink(x) end
	if local y: number = f() then y += 1; Sink(y) else Sink("none") end
	if const z = f() then Sink(z, function() return z end) elseif local w = t.w then w = w .. "!"; Sink(w) elseif const v = t.v then Sink(v) else Sink(x) end
	if local hit = t[a] then if local inner = hit[a] then return inner end Sink(hit) end
	for i = 1, 3 do if local e = t[i] then if e == a then break end Sink(e) else continue end end
	local r = if local q = t.q then q * 2 elseif local p = t.p then p else 0
	local fs = {}
	for i = 1, 3 do if local cap = t[i] then fs[i] = function() cap += i; return cap end end end
	while true do if local stop = f() then break end end
	Sink(r, fs, if local g = f() then g else nil, (if const h = t.h then h else 1) + 1)
	if local m = t:method() then Sink(m) end
	if local n = (a or t).n then Sink(n) end
	if local o = t.x and t.y or f() then Sink(o) end
	if local c1 = t.c1 then if local c2 = c1.c2 then if local c3 = c2.c3 then return c1, c2, c3 end end end
	return x
end
function ConfBind.whilelocal(t, f, g, n)
	-- the binding is rebound every trip and is not visible in its own condition
	local x = t
	while local x = x.next do Sink(x) end
	while local item = f() do Sink(item) end
	while local item: string = f() do item ..= "!"; Sink(item) end
	while const item = f() do Sink(item, function() return item end) end
	while const item: number = g(n) do Sink(item + 1) end
	-- control leaving the body every way it can
	while local v = f() do if v == 1 then continue end if v == 2 then break end if v == 3 then return v end Sink(v) end
	-- a fresh capture per trip, read-only and written
	local caps = {}
	while local v = f() do caps[#caps + 1] = function() return v end; v = nil end
	while local v = f() do caps[#caps + 1] = function() v += 1; return v end end
	-- nested, shadowing the outer binding
	while local outer = f() do
		while local outer = outer.child do
			while local inner = g(outer) do
				if inner == outer then break end
				Sink(outer, inner)
			end
		end
	end
	-- inside every other loop, and every other loop inside it
	for i = 1, n do while local v = t[i] do t[i] = v.next; Sink(i, v) end end
	for k, v in t do while local w = v[k] do v[k] = nil; Sink(w) end end
	repeat local stop = f(); while local v = g(stop) do Sink(v) end until stop
	while local v = f() do for i = 1, v do Sink(i) end; repeat v -= 1 until v <= 0 end
	while local v = f() do if local w = v.w then Sink(w) elseif const u = v.u then Sink(u) end end
	-- conditions of every shape
	while local v = t.a and t.b or t.c do Sink(v) end
	while local v = f() == g() do Sink(v); break end
	while local v = not f() do Sink(v); break end
	while local v = (f()) do Sink(v); break end
	while local v = if n then f() else g() do Sink(v); break end
	while local v = `{n}` do Sink(v); break end
	while local v = { f() } do if #v == 0 then break end Sink(v) end
	while local v = function() return n end do Sink(v()); break end
	while local v = t[n] do n -= 1; Sink(v) end
	while local v = coroutine.wrap(f)() do Sink(v) end
	while local v = math.max(n, 0) > 0 and n do n -= 1; Sink(v) end
	while local v = select("#", f()) do if v == 0 then break end Sink(v) end
	while local v = n > 0 do n -= 1; Sink(v) end
	while const v = t.flag do t.flag = nil; Sink(v) end
	-- inside closures and coroutines, yielding from the body
	local co = coroutine.wrap(function() while local v = f() do coroutine.yield(v) end return "drained" end)
	local drain = function() local out = {} while local v = co() do if v == "drained" then break end out[#out + 1] = v end return out end
	Sink(caps, drain(), x)
	-- an iterator spelled with while local: the shape a for-in lowers to by hand
	local it, state, ctl = pairs(t)
	while local k = it(state, ctl) do ctl = k; Sink(k, state[k]) end
	-- a linked list walked, reversed, and walked again
	local head, prev = t, nil
	while local node = head do head = node.next; node.next = prev; prev = node end
	while local node = prev do Sink(node.value); prev = node.next end
	-- a queue drained while it grows
	local queue, front = { t }, 1
	while local node = queue[front] do
		front += 1
		for _, child in ipairs(node.children or {}) do queue[#queue + 1] = child end
	end
	return caps, front
end
function ConfBind.iter(t, n, f)
	for k, v in t do Sink(k, v) end
	for k, v in pairs(t) do if v == nil then continue end t[k] = nil end
	for i, v in ipairs(t) do t[i + 1] = nil; Sink(i, v) end
	for k, v in next, t, n do Sink(k, v) end
	for i = 0, 1, 0.1 do Sink(i) end
	for i = 1, math.huge do if i > n then break end end
	for i = -math.huge, 0 do break end
	for i = n, 1, -1 do Sink(i) end
	for i = 1, n, n do Sink(i) end
	for i = 1.5, n + 0.5 do Sink(i) end
	for i = 2 ^ 53, 2 ^ 53 + 2 do Sink(i) end
	for i = 1, n / 0 do if i > 3 then break end end
	for _ = 1, 3 do end
	for k in string.gmatch("a b c", "%a") do Sink(k) end
	for p, c in utf8.codes("héllo") do Sink(p, c) end
	for a, b, c, d, e in f do Sink(a, b, c, d, e) end
	for k, v in setmetatable({}, { __iter = function(s) local i = 0 return function() i += 1; if i <= n then return i, i * i end end end }) do Sink(k, v) end
	for k, v in setmetatable({}, { __call = function(s, st, c) return nil end }) do Sink(k, v) end
	for k, v in table.freeze({ 1, 2, 3 }) do Sink(k, v) end
	for k, v in { a = 1, b = 2, [1] = 3, [2.5] = 4, [true] = 5 } do Sink(k, v) end
	for _, row in ipairs(t) do for _, cell in ipairs(row) do for k, v in cell do Sink(k, v) end end end
	local keys = {}
	for k in t do keys[#keys + 1] = k end
	table.sort(keys, function(x, y) return tostring(x) < tostring(y) end)
	for i = #keys, 1, -1 do local k = keys[i]; t[k] = nil end
	local env = _G["getfenv"](1)
	for k, v in env do if type(v) == "function" then Sink(k) end end
	_G["setfenv"](f, setmetatable({}, { __index = env }))
	_G.string = _G.string; rawset(_G, "math", rawget(_G, "math"))
	return keys
end
function ConfBind.sort(t, n, cmp)
	table.sort(t)
	table.sort(t, cmp)
	table.sort(t, function(a, b) return a > b end)
	table.sort(t, function(a, b) return a.key < b.key or (a.key == b.key and a.id < b.id) end)
	table.sort(t, function(a, b) if a.p ~= b.p then return a.p > b.p end if a.q ~= b.q then return a.q < b.q end return tostring(a) < tostring(b) end)
	local words = { "pear", "Apple", "fig", "banana", "", "apple" }
	table.sort(words, function(a, b) return a:lower() < b:lower() end)
	local mt = { __lt = function(a, b) return a.v < b.v end }
	local objs = {}
	for i = n, 1, -1 do objs[#objs + 1] = setmetatable({ v = i }, mt) end
	table.sort(objs)
	Sink(pcall(table.sort, t, function() return true end), pcall(table.sort, { 1, "x", 2 }), pcall(table.sort, { 1, nil, 3 }), pcall(table.sort, table.freeze({ 2, 1 })))
	local big = table.create(n)
	for i = 1, n do big[i] = (i * 7919) % n end
	table.sort(big)
	return words, objs, big
end
function ConfBind.tables(t, n, k, ...)
	table.insert(t, 1, n); table.insert(t, #t + 1, n); table.insert(t, n)
	Sink(table.remove(t, 1), table.remove(t, #t), table.remove(t), table.remove({}), table.remove(t, #t + 1), pcall(table.insert, t, 0, n), pcall(table.insert, t, #t + 2, n), pcall(table.remove, t, -1))
	t[#t + 1] = n; t[#t] = nil; t[#t + 1], t[#t + 2] = n, n
	Sink(#t, rawlen(t), table.maxn(t), table.getn(t), table.concat(t, ", ", 1, #t), table.concat({ 1, 2.5, "s" }), pcall(table.concat, { {} }), table.concat({}, "x"), table.concat(t, "", 3, 2))
	Sink(table.unpack(t, 1, n), table.unpack({ 1, 2, 3 }, -1, 1), pcall(table.unpack, t, 1, 1e7), select("#", table.unpack({}, 1, 3)))
	Sink(table.create(0), table.create(n, n), table.create(n, {}), pcall(table.create, -1), table.find(t, n, 2), table.find({ nil, 2 }, 2), table.clone(table.freeze({ 1 })), table.isfrozen(table.clone(table.freeze({}))))
	local f = table.freeze({ x = 1, y = { 2 } })
	f.y[1] = 3
	Sink(pcall(rawset, f, "x", 2), pcall(setmetatable, f, {}), pcall(table.insert, f, 1), pcall(table.clear, f))
	local keys = { [1] = "int", [1.0] = "same", [-0.0] = "zero", [0] = "also zero", [2 ^ 53] = "big", ["1"] = "string", [true] = "bool" }
	Sink(keys[1], keys[0], keys[-0], pcall(function() keys[0 / 0] = 1 end), pcall(function() keys[nil] = 1 end), rawget(keys, 0 / 0), keys[nil])
	local grow, hash = {}, {}
	for i = 1, n do grow[i] = i end
	for i = n, 1, -1 do grow[i] = nil end
	for i = 1, n do hash["k" .. i] = i; hash[i * 0.5] = i end
	for i = 1, n do hash["k" .. i] = nil end
	local lenmt = setmetatable({}, { __len = function() return k end, __index = function(_, i) return i end })
	Sink(#lenmt, rawlen(lenmt), lenmt[5], rawget(lenmt, 5), next(grow), next(hash), #grow)
	table.foreach(hash, function(key, v) Sink(key, v) end)
	table.foreachi(t, function(i, v) if i > 2 then return true end end)
	return t, keys, grow, hash, ...
end
function ConfBind.clear(t, n)
	table.clear(t)
	for i = 1, n do t[i] = i; t["k" .. i] = i end
	table.clear(t)
	t.reuse = true
	local frozen = table.freeze({})
	Sink(next(t), #t, t.reuse, pcall(table.clear, frozen), pcall(table.clear, nil))
	return t
end
function ConfBind.lazyload(require_)
	local cache = {}
	return setmetatable({}, { __index = function(self, name)
		local mod = cache[name]
		if mod == nil then mod = require_(name); cache[name] = mod; rawset(self, name, mod) end
		return mod
	end })
end
function ConfBind.classes(base)
	local Point = {}
	Point.__index = Point
	Point.count = 0
	function Point.new(x, y) Point.count += 1; return setmetatable({ x = x or 0, y = y or 0 }, Point) end
	function Point:len() return math.sqrt(self.x * self.x + self.y * self.y) end
	function Point.__add(a, b) return Point.new(a.x + b.x, a.y + b.y) end
	function Point.__eq(a, b) return a.x == b.x and a.y == b.y end
	function Point.__tostring(p) return `Point({p.x}, {p.y})` end
	local Point3 = setmetatable({}, { __index = Point })
	Point3.__index = Point3
	Point3.__add, Point3.__eq, Point3.__tostring = Point.__add, Point.__eq, function(p) return `Point3({p.x}, {p.y}, {p.z})` end
	function Point3.new(x, y, z) local p = Point.new(x, y); p.z = z or 0; return setmetatable(p, Point3) end
	function Point3:len() local flat = Point.len(self) return math.sqrt(flat * flat + self.z * self.z) end
	local p, q = Point3.new(1, 2, 3), Point.new(base, base)
	Sink(p:len(), q:len(), tostring(p + q), p == q, getmetatable(p) == Point3, Point.count, rawget(p, "len"), p.len == Point3.len)
	return Point, Point3
end
registry.ConfBind = ConfBind

-- ===== conformance: coroutines, errors, metamethods, the debug library ========
-- coroutine.luau   create/resume/yield/wrap/status/close/isyieldable/running in every nesting
-- coroutinehost.luau / cyield.luau  yields through host calls, loops, iterators and metamethods
-- pcall.luau       pcall/xpcall with yields, erroring handlers, error objects, deep nesting
-- errors.luau      every runtime error an operator or builtin can raise, error levels and values
-- exceptions.luau / tmerror.luau  errors raised inside metamethods, caught a frame up
-- events.luau      every metamethod, raw access, __metatable, __mode, __namecall declared
-- gc.luau          weak tables, newproxy, collectgarbage, garbage built in loops
-- interrupt / debugger / coverage / apicalls  long loops and host calls a host stops in
-- debug.luau       debug.info with every option and level, debug.traceback in every arity
local ConfRun = {}
function ConfRun.coroutine(f, n, ...)
	local co = coroutine.create(function(a, b, ...)
		local x, y = coroutine.yield(a + b, ...)
		for i = 1, n do
			local got = coroutine.yield(i, x, y)
			if got == "stop" then return "stopped", i end
			if got then x += got end
		end
		local ok, v = pcall(coroutine.yield, "inside pcall")
		local ok2, v2 = xpcall(function() return coroutine.yield("inside xpcall") end, debug.traceback)
		return "done", ok, v, ok2, v2
	end)
	Sink(coroutine.status(co), coroutine.resume(co, 1, 2, ...), coroutine.status(co), coroutine.resume(co, 3, 4), coroutine.resume(co, "stop"), coroutine.status(co), coroutine.resume(co), coroutine.isyieldable(), coroutine.running())
	local wrapped = coroutine.wrap(function(...) local args = { ... }; while true do args = { coroutine.yield(table.unpack(args)) } end end)
	Sink(wrapped(1), wrapped(2, 3), wrapped())
	local function gen(k) return coroutine.wrap(function() for i = 1, k do coroutine.yield(i) end end) end
	for v in gen(n) do Sink(v) end
	local nested = coroutine.wrap(function()
		local inner = coroutine.create(function() coroutine.yield(coroutine.status(coroutine.running()), coroutine.isyieldable()) return "inner done" end)
		coroutine.yield(coroutine.resume(inner))
		coroutine.yield(coroutine.resume(inner))
		return coroutine.status(inner), coroutine.resume(inner)
	end)
	Sink(nested(), nested(), nested())
	local self_resume = coroutine.create(function() return coroutine.resume(coroutine.running()) end)
	local dead = coroutine.create(function() error({ "obj" }) end)
	Sink(coroutine.resume(self_resume), coroutine.resume(dead), coroutine.status(dead), coroutine.close(dead), coroutine.close(coroutine.create(f)), pcall(coroutine.wrap(function() error("wrapped", 2) end)))
	local suspended = coroutine.create(function() coroutine.yield(1); coroutine.yield(2) end)
	coroutine.resume(suspended)
	Sink(coroutine.close(suspended), coroutine.status(suspended), coroutine.resume(suspended), pcall(coroutine.resume, nil), pcall(coroutine.wrap, 1), pcall(coroutine.yield))
	local yielding = setmetatable({}, {
		__index = function(_, k) return coroutine.yield(k) end,
		__add = function(a, b) return coroutine.yield("add") end,
		__call = function(_, ...) return coroutine.yield(...) end,
		__eq = function() return coroutine.yield("eq") end,
		__lt = function() return coroutine.yield("lt") end,
		__concat = function() return coroutine.yield("concat") end,
		__len = function() return coroutine.yield("len") end,
	})
	local mm = coroutine.wrap(function() return yielding.key, yielding + 1, yielding(1, 2), yielding == setmetatable({}, getmetatable(yielding)), yielding < yielding, yielding .. "x", #yielding end)
	Sink(mm(), mm(1), mm(2), mm(3), mm(4), mm(5), mm(6), mm(7))
	local host = coroutine.wrap(function()
		for i = 1, n do Host.yield(i); Sink(Host.cyield(i, coroutine.yield(i))) end
		table.sort({ 3, 2, 1 }, function(a, b) return coroutine.yield(a, b) end)
	end)
	return host, co
end
function ConfRun.pcall(f, n, ...)
	Sink(pcall(f), pcall(f, ...), pcall(error), pcall(error, nil), pcall(error, "s", 0), pcall(error, "s", 1), pcall(error, "s", 2), pcall(error, { code = n }), pcall(error, setmetatable({}, { __tostring = function() return "custom error" end })))
	Sink(xpcall(f, debug.traceback), xpcall(f, function(e) return "handled", e end, ...), xpcall(f, function(e) error("handler failed") end), xpcall(f, f), xpcall(error, function(...) return select("#", ...), ... end, "e"))
	local depth = 0
	local function recurse() depth += 1; return pcall(recurse) end
	Sink(recurse(), depth, pcall(string.rep, "x", -1), pcall(string.rep, "x", 2 ^ 31))
	local co = coroutine.wrap(function(...)
		local ok, a, b = pcall(function(...) local x = coroutine.yield(...); error({ x }) end, ...)
		local ok2, c = xpcall(function() return coroutine.yield(a) end, function(e) return e end)
		return ok, a, b, ok2, c
	end)
	Sink(co(...), co(n), co(n))
	local okf, errf = pcall(function() local t = setmetatable({}, { __index = function() error("from __index", 2) end }) return t.x end)
	return okf, errf, pcall(pcall), pcall(xpcall), pcall(xpcall, f)
end
function ConfRun.errors(a, t, s, f)
	local probes = {
		function() return a.x.y.z end, function() return nil + 1 end, function() return {} .. "x" end, function() return #a end,
		function() return a < t end, function() return t <= 1 end, function() return -{} end, function() return ("x")() end,
		function() return t:missing() end, function() return (nil)[1] end, function() local u; u.v = 1 end, function() return 1 // nil end,
		function() return "a" + 1 end, function() return true .. "" end, function() return setmetatable(1, {}) end, function() return string.rep() end,
		function() return ("x"):bad() end, function() return math.floor("x") end, function() return bit32.band({}) end, function() return f(f(f())) end,
		function() error() end, function() error(nil, 2) end, function() error(t, 0) end, function() assert(false, t) end, function() return select(0) end,
		function() return table.concat({ {} }) end, function() return ipairs() end, function() return next({}, "missing") end, function() return rawset(1, 2, 3) end,
		function() return tostring() end, function() return utf8.char(-1) end, function() return buffer.create(-1) end, function() return vector.create() + 1 end,
	}
	for i, probe in ipairs(probes) do
		local ok, err = pcall(probe)
		Sink(i, ok, type(err), if type(err) == "string" then scrub(err) else err)
	end
	local bad = setmetatable({}, {
		__index = function(_, k) error("index " .. tostring(k)) end,
		__newindex = function(_, k) error({ newindex = k }) end,
		__call = function() error("call", 2) end,
		__add = function() error() end,
		__eq = function() error("eq") end,
		__len = function() return error("len", 0) end,
		__concat = function() error(setmetatable({}, { __tostring = function() return "concat obj" end })) end,
		__unm = function() return a.b.c end,
		__iter = function() error("iter") end,
	})
	Sink(pcall(function() return bad.k end), pcall(function() bad.k = 1 end), pcall(bad), pcall(function() return bad + 1 end), pcall(function() return bad == setmetatable({}, getmetatable(bad)) end), pcall(function() return #bad end), pcall(function() return bad .. "" end), pcall(function() return -bad end), pcall(function() for _ in bad do end end))
	return probes
end
function ConfRun.events(a, b, k)
	local log = {}
	local mt = {}
	for _, ev in ipairs({ "__add", "__sub", "__mul", "__div", "__idiv", "__mod", "__pow", "__unm", "__concat", "__len", "__eq", "__lt", "__le", "__call", "__index", "__newindex", "__tostring", "__iter" }) do
		mt[ev] = function(...) log[#log + 1] = ev; return ... end
	end
	mt.__metatable = nil
	mt.__mode = "k"
	mt.__namecall = function(self, ...) return ... end
	mt.__type = "Fake"
	local x, y = setmetatable({}, mt), setmetatable({}, mt)
	Sink(x + y, x - 1, 1 * x, x / y, x // 2, 2 % x, x ^ y, -x, x .. y, "s" .. x, x .. 1, #x, x == y, x ~= y, x < y, x <= y, x > y, x >= y, x(1, 2), x.field, x[1], x[x], tostring(x))
	x.field = 1; x[1] = 2; x[y] = 3
	for k2, v2 in x do Sink(k2, v2); break end
	Sink(rawequal(x, y), rawget(x, "field"), rawset(x, "field", 4), rawlen(x), getmetatable(x) == mt, table.concat(log, ","))
	local base = { inherited = 1 }
	local mid = setmetatable({}, { __index = base, __newindex = base })
	local top = setmetatable({}, { __index = mid, __newindex = function(t2, k2, v2) rawset(t2, k2, v2 * 2) end })
	top.n = 2; mid.m = 3
	Sink(top.inherited, top.n, rawget(top, "n"), top.m, base.m, rawget(mid, "m"))
	local eqmt = { __eq = function() return true end, __lt = function(p, q) return (type(p) == "table" and p.v or p) < (type(q) == "table" and q.v or q) end }
	local e1, e2 = setmetatable({ v = 1 }, eqmt), setmetatable({ v = 2 }, eqmt)
	Sink(e1 == e2, e1 == 1, e1 ~= e2, e1 < e2, pcall(function() return e1 < 5 end), pcall(function() return e1 <= e2 end))
	local locked = setmetatable({}, { __metatable = false })
	Sink(getmetatable(locked), pcall(setmetatable, locked, nil), getmetatable("").__index == string, getmetatable("x").__index.upper("y"), ("abc"):upper())
	local wk, wv, wkv = setmetatable({}, { __mode = "k" }), setmetatable({}, { __mode = "v" }), setmetatable({}, { __mode = "kv" })
	for i = 1, k do wk[{}] = i; wv[i] = {}; wkv[{}] = {} end
	return x, y, wk, wv, wkv
end
function ConfRun.gc(n)
	local before = collectgarbage("count")
	local junk = {}
	for i = 1, n do junk[i] = { i, tostring(i), function() return i end, newproxy(false) } end
	junk = nil
	collectgarbage("collect")
	local cache = setmetatable({}, { __mode = "v" })
	for i = 1, n do cache[i] = { i } end
	local strs = {}
	for i = 1, n do strs[#strs + 1] = string.rep("x", i) .. i end
	local function build(d) if d == 0 then return {} end return { build(d - 1), build(d - 1) } end
	local tree = build(n % 10)
	return collectgarbage("count") - before, gcinfo(), cache, #strs, tree, junk
end
function ConfRun.hosted(n)
	local i = 0
	while true do i += 1; if Host.interrupted(i) then break end end
	repeat i -= 1 until i <= 0 or Host.stop()
	for j = 1, n do if j % 1000 == 0 then Host.check(j) end end
	local function recursive(k) if k <= 0 then return Host.breakpoint(k) end return recursive(k - 1) end
	Host.api.call(1, "s", true, nil, {}, function() end, Host.api.push(n), Host.api.pop())
	return recursive(n), Host.coverage(function() if n then return 1 else return 2 end end)
end
function ConfRun.debug(f, co, n)
	Sink(debug.info(1, "s"), debug.info(1, "l"), debug.info(1, "n"), debug.info(1, "a"), debug.info(1, "f"), debug.info(1, "slnaf"), debug.info(2, "sl"), debug.info(n, "f"))
	Sink(debug.info(f, "s"), debug.info(f, "n"), debug.info(f, "a"), debug.info(f, "slnaf"), debug.info(print, "sna"), debug.info(co, 1, "l"), debug.info(co, 0, "f"), pcall(debug.info, 1, "?"), pcall(debug.info))
	Sink(debug.traceback(), debug.traceback("msg"), debug.traceback("msg", 2), debug.traceback(co), debug.traceback(co, "msg"), debug.traceback(co, "msg", 1), debug.traceback(nil), debug.traceback({}), debug.traceback(123))
	local function whoami() return debug.info(1, "n"), debug.info(2, "n") end
	local named = { method = function() return whoami() end }
	return whoami(), named.method(), named:method()
end
registry.ConfRun = ConfRun

-- ===== conformance: the libraries =============================================
-- strings.luau     byte/sub/rep/char/format edges, %q of every special value, comparison, building
-- pm.luau          every class and its complement, sets, anchors, %b, %f, captures, gsub repls, errors
-- utf8.luau        char/charpattern/codepoint/len/offset/codes with negative, invalid and out-of-range input
-- math.luau        every function at its edges: signed zero, nan, inf, rounding ties, random ranges
-- bitwise.luau     bit32 with no arguments, negative and >32-bit inputs, every shift width
-- datetime.luau    os.time tables, os.date formats both zones, difftime, clock
-- buffers.luau     every read/write at the last valid offset and one past it, wrapping values, copy/fill/bits
-- vector.luau / vector_library.luau  vector operators, components, the whole vector library
-- userdata.luau / udata_direct.luau  host userdata: fields, namecalls, operators
local ConfLib = {}
function ConfLib.strings(s, n, t)
	Sink(s:byte(-1), s:byte(0), s:byte(1, -1), s:byte(n, n + 2), s:sub(0), s:sub(-100, 100), s:sub(n, n - 1), s:sub(-n), ("x"):rep(0), ("x"):rep(-1), ("ab"):rep(3, ", "), string.char(), string.char(0, 255), s:len(), #s)
	Sink(s:lower(), s:upper(), ("ÀÉ"):lower(), s:reverse(), (""):reverse(), s:split(", "), s:split("x"), ("a,b,,c,"):split(","), (""):split(","), s:find("", 1), s:find("", #s + 1), s:find("", #s + 2), s:find("x", -1), s:find(".", 1, true), s:find("%d", n))
	Sink(string.format("%5.1s|%-3c|%#x|%#o|% d|%+.3e|%G|%E|%%|%c%c%c", s, 65, n, n, n, n, n, n, 72, 105, 33), string.format("%q", "\0\1\r\n\t\"\\\127\255"), string.format("%q", 1 / 0), string.format("%q", -1 / 0), string.format("%q", 0 / 0), string.format("%q", 2 ^ 63), string.format("%q", n), string.format("%s %s %s", nil, true, {}), string.format("%10.4f|%-10d|%x", n, n, n))
	Sink(string.format("%*", t), string.format("%* %* %*", 1, "s", nil), pcall(string.format, "%d", 1.5), pcall(string.format, "%y", 1), pcall(string.format, "%", 1), pcall(string.format, "%s"), string.format("%-+ #0d", n), string.format("%.0s", s), string.format("%.99f", 1 / 3))
	Sink("a" < "b", "a" < "aa", "" < "\0", "Z" < "a", "\255" > "\0", s == s .. "", s .. n .. n, n .. s, 1 .. 2, 1.5 .. "", s:upper():lower():len(), string.len(s), string.lower(s))
	local parts = table.create(n)
	for i = 1, n do parts[i] = string.char(65 + i % 26) end
	local joined = table.concat(parts)
	local built = ""
	for i = 1, n do built ..= parts[i] end
	return joined == built, #joined, joined:byte(1, -1)
end
function ConfLib.pm(s, p, r)
	Sink(s:find("%a+"), s:find("%A+"), s:find("%c"), s:find("%C+"), s:find("%d+"), s:find("%D+"), s:find("%g+"), s:find("%G"), s:find("%l+"), s:find("%L+"), s:find("%p"), s:find("%P+"), s:find("%s+"), s:find("%S+"), s:find("%u+"), s:find("%U+"), s:find("%w+"), s:find("%W"), s:find("%x+"), s:find("%X"))
	Sink(s:match("^(%w+)"), s:match("(%w+)$"), s:match("^$"), s:match("."), s:match("[%a_][%w_]*"), s:match("[^%s]+"), s:match("[]]"), s:match("[a-]"), s:match("[%]]"), s:match("[%-%+]"), s:match("[a-f0-9]+"), s:match("[^a-z]"), s:match("x*"), s:match("x+"), s:match("x-y"), s:match("x?y"))
	Sink(s:match("%b()"), s:match("%b{}"), s:match("%f[%w]%w+"), s:match("%f[%W]"), s:match("(%w+)=(%w+)"), s:match("()(%w+)()"), s:match("([\"'])(.-)%1"), s:match("((a)(b))"), s:match("(.-)(%d+)$"), s:match("%s*(.-)%s*$"), s:match(p), s:match(p, 2), s:match(p, -3))
	Sink(s:gsub("%w+", "%0 %0"), s:gsub("(%w+)", "<%1>"), s:gsub("%%", "%%%%"), s:gsub("", "-"), s:gsub("x", "y", 0), s:gsub("(%w)(%w)", "%2%1", 2), s:gsub("%w+", { hello = "HI", world = false }), s:gsub("%w+", function(w) if #w > 3 then return w:upper() end return nil end), s:gsub("%w+", function() return false end), s:gsub(p, r))
	Sink(pcall(string.find, s, "("), pcall(string.find, s, "%"), pcall(string.find, s, "[a"), pcall(string.gsub, s, "(", ""), pcall(string.gsub, s, "x", "%2"), pcall(string.rep, s, 1e10), pcall(string.match, s, string.rep("(", 40)))
	local found = {}
	for k, v in s:gmatch("(%w+)=(%w+)") do found[k] = v end
	for w in s:gmatch("%a+") do found[#found + 1] = w end
	for pos in s:gmatch("()x") do found[#found + 1] = pos end
	for a, b, c in s:gmatch("(%d)(%d)(%d)") do found[#found + 1] = a .. b .. c end
	return found
end
function ConfLib.utf8(s, n)
	Sink(utf8.char(72, 0x7FF, 0x800, 0xFFFF, 0x10000, 0x10FFFF), utf8.charpattern, utf8.codepoint(s, 1, -1), utf8.codepoint(s, -1), utf8.codepoint(s, n), pcall(utf8.codepoint, "\xFF"), pcall(utf8.char, 0x110000))
	Sink(utf8.len(s), utf8.len(s, 1, -1), utf8.len(s, -2), utf8.len(s, n, n), utf8.len("\xC0\x80"), utf8.len("\xF4\x90\x80\x80"), utf8.len("\xED\xA0\x80"), utf8.len(""), pcall(utf8.len, s, 100))
	Sink(utf8.offset(s, 0), utf8.offset(s, 1), utf8.offset(s, -1), utf8.offset(s, n), utf8.offset(s, -n), utf8.offset(s, 0, 2), utf8.offset(s, 1, -1), utf8.offset(s, 100), pcall(utf8.offset, s, 1, 100))
	local cps = {}
	for p, c in utf8.codes(s) do cps[#cps + 1] = p * 0x110000 + c end
	Sink(pcall(function() for _ in utf8.codes("\xFF\xFE") do end end), #cps, string.gsub(s, utf8.charpattern, function(ch) return utf8.codepoint(ch) .. " " end))
	return cps
end
function ConfLib.math(x, y, n)
	Sink(math.floor(-0.5), math.ceil(-0.5), math.floor(-0), math.round(0.5), math.round(-0.5), math.round(2.5), math.round(-2.5), math.round(1e300), math.fmod(1, 0), math.fmod(-6, 4), math.fmod(6, -4), math.fmod(x, y), math.modf(-0), math.modf(math.huge), math.modf(-math.huge), math.modf(0 / 0))
	Sink(math.frexp(0), math.frexp(-8), math.frexp(math.huge), math.ldexp(1, -1074), math.ldexp(1, 1024), math.log(0), math.log(-1), math.log(x, 10), math.log(x, 2), math.log(x, x), math.sqrt(-1), math.exp(710), math.exp(-745), math.pow(0, 0), math.pow(-1, 0.5))
	Sink(math.max(0 / 0, 1), math.max(1, 0 / 0), math.min(-0, 0), math.max(-0, 0), math.min(x), math.max(x, y, n, 1, 2, 3, 4, 5, 6, 7, 8), pcall(math.max), pcall(math.clamp, 1, 2, 1), math.clamp(x, -math.huge, math.huge), math.clamp(0 / 0, 0, 1))
	Sink(pcall(math.random, 0), math.random(-5, -1), pcall(math.random, 2, 1), math.random(n), math.random(1, 2 ^ 31), pcall(math.random, 1, 2 ^ 53), math.random(), math.randomseed(x), math.randomseed(), math.noise(x, y, n), math.noise(x), math.noise(0, 0, 0))
	Sink(math.sign(-0), math.sign(0 / 0), math.abs(-0), math.abs(-math.huge), math.pi / 2, math.huge * 0, -math.huge < x, math.isnan(x), math.isinf(y), math.isfinite(n), math.lerp(x, y, 0.5), math.lerp(x, y, 2), math.map(x, 0, 1, y, n), math.deg(x), math.rad(y))
	Sink(math.sin(x), math.cos(x), math.tan(x), math.asin(x), math.acos(x), math.atan(x), math.atan(y, x), math.atan2(y, x), math.sinh(x), math.cosh(x), math.tanh(x), math.log10(x), math.exp(x), math.sqrt(x), math.ceil(x), math.floor(x), math.abs(x))
end
function ConfLib.bitwise(x, y, n)
	Sink(bit32.band(), bit32.bor(), bit32.bxor(), bit32.btest(), bit32.band(x), bit32.band(-1), bit32.band(2 ^ 32), bit32.band(2 ^ 32 + 1), bit32.band(-2 ^ 31), bit32.band(2.5, 3), bit32.bnot(-1), bit32.bnot(2 ^ 32 - 1), bit32.bnot(x))
	Sink(bit32.lshift(x, -1), bit32.rshift(x, -1), bit32.lshift(x, 31), bit32.lshift(x, 32), bit32.lshift(x, 33), bit32.rshift(x, 32), bit32.arshift(-1, 31), bit32.arshift(-1, 32), bit32.arshift(x, -2), bit32.arshift(0x7FFFFFFF, 1), bit32.arshift(0x80000000, 1))
	Sink(bit32.lrotate(x, -1), bit32.rrotate(x, 33), bit32.lrotate(x, 32), bit32.rrotate(x, 0), bit32.lrotate(0x80000001, 1), bit32.rrotate(0x80000001, 1))
	Sink(bit32.extract(x, 0, 32), bit32.extract(x, 31), bit32.extract(x, 31, 1), bit32.extract(x, n, 1), pcall(bit32.extract, x, 32), pcall(bit32.extract, x, 0, 33), pcall(bit32.extract, x, -1), bit32.replace(x, y, 0, 32), bit32.replace(x, y, 31), bit32.replace(x, -1, 4, 4), pcall(bit32.replace, x, y, 30, 4))
	Sink(bit32.countlz(0), bit32.countlz(1), bit32.countlz(-1), bit32.countlz(x), bit32.countrz(0), bit32.countrz(0x80000000), bit32.countrz(x), bit32.byteswap(0), bit32.byteswap(0xFFFFFFFF), bit32.byteswap(0x12345678), bit32.byteswap(x))
	Sink(bit32.band(x, y, n, 0xFF, 0xF0F0), bit32.bor(x, y, n, 1, 2, 4, 8), bit32.bxor(x, y, n, x, y), bit32.btest(x, y, n), bit32.btest(x, 0), bit32.band(x, 0xFFFFFFFF) == x % 2 ^ 32)
end
function ConfLib.datetime(t)
	local now = os.time()
	Sink(now, os.time({ year = 2000, month = 1, day = 1 }), os.time({ year = 2038, month = 1, day = 19, hour = 3, min = 14, sec = 8 }), os.time({ year = 1970, month = 1, day = 1, hour = 0, isdst = false }), os.time({ year = 2024, month = 13, day = 40 }), pcall(os.time, { year = 2024 }), os.time(t))
	Sink(os.date(), os.date("*t"), os.date("!*t", 0), os.date("*t", now), os.date("!%c", 0), os.date("!%x %X", 0), os.date("!%A %a %B %b %d %H %I %j %m %M %p %S %U %w %W %y %Y %%", 1e9), os.date("%Y-%m-%dT%H:%M:%S"), pcall(os.date, "%Ez"), pcall(os.date, "*t", -1e100))
	Sink(os.difftime(now, 0), os.difftime(t, now), os.clock(), os.clock() - os.clock())
end
function ConfLib.buffers(n, s, b)
	local z = buffer.create(0)
	local e = buffer.fromstring("")
	local big = buffer.create(n)
	Sink(buffer.len(z), buffer.len(e), buffer.tostring(z), buffer.tostring(e), typeof(z), z == e, z == z, buffer.len(buffer.fromstring(s)))
	buffer.writeu8(big, 0, 256); buffer.writeu8(big, 1, -1); buffer.writei8(big, 2, -129); buffer.writei8(big, 3, 128)
	buffer.writeu16(big, 4, 65536); buffer.writei16(big, 6, -32769); buffer.writeu32(big, 8, -1); buffer.writei32(big, 12, 2 ^ 31)
	buffer.writef32(big, 16, 0 / 0); buffer.writef32(big, 20, math.huge); buffer.writef64(big, 24, -0); buffer.writef32(big, 32, 1e40); buffer.writef64(big, 36, 5e-324)
	Sink(buffer.readu8(big, 0), buffer.readu8(big, 1), buffer.readi8(big, 2), buffer.readi8(big, 3), buffer.readu16(big, 4), buffer.readi16(big, 6), buffer.readu32(big, 8), buffer.readi32(big, 12), buffer.readf32(big, 16), buffer.readf32(big, 20), buffer.readf64(big, 24), buffer.readf32(big, 32), buffer.readf64(big, 36))
	Sink(buffer.readu8(big, n - 1), buffer.readu16(big, n - 2), buffer.readu32(big, n - 4), buffer.readf64(big, n - 8), pcall(buffer.readu8, big, n), pcall(buffer.readu16, big, n - 1), pcall(buffer.readu32, big, -1), pcall(buffer.writeu8, big, n, 0), pcall(buffer.readf64, big, 0.5))
	buffer.writestring(big, 0, s); buffer.writestring(big, 0, s, 2); buffer.writestring(big, n - #s, s)
	Sink(buffer.readstring(big, 0, #s), buffer.readstring(big, 0, 0), pcall(buffer.readstring, big, 0, n + 1), pcall(buffer.writestring, big, 0, s, #s + 1), pcall(buffer.writestring, big, n, "x"))
	buffer.copy(big, 1, big, 0, n - 1); buffer.copy(big, 0, big, 1); buffer.copy(big, 0, b); buffer.copy(big, 4, b, 2); buffer.copy(big, 0, b, 0, 0)
	buffer.fill(big, 0, 0); buffer.fill(big, 0, 0xAB, 4); buffer.fill(big, n - 1, 0xFF); buffer.fill(big, 0, 0x1FF, n)
	Sink(pcall(buffer.copy, big, 0, b, 0, n + 1), pcall(buffer.fill, big, 0, 0, n + 1), pcall(buffer.create, -1), pcall(buffer.create, 2 ^ 31))
	buffer.writebits(big, 0, 0, 0); buffer.writebits(big, 0, 32, 0xFFFFFFFF); buffer.writebits(big, 3, 13, 0x1ABC); buffer.writebits(big, 7, 1, 1)
	Sink(buffer.readbits(big, 0, 0), buffer.readbits(big, 0, 32), buffer.readbits(big, 3, 13), buffer.readbits(big, 7, 1), buffer.readbits(big, n * 8 - 1, 1), pcall(buffer.readbits, big, 0, 33), pcall(buffer.readbits, big, n * 8, 1), pcall(buffer.writebits, big, -1, 1, 0))
	local sum = 0
	for i = 0, n - 1 do sum = (sum * 31 + buffer.readu8(big, i)) % 2 ^ 32 end
	for i = 0, n - 4, 4 do buffer.writeu32(big, i, bit32.bxor(buffer.readu32(big, i), sum)) end
	local keyed = { [big] = "by buffer" }
	return sum, keyed[big], buffer.tostring(big), (function(...) return select("#", ...), ... end)(big, z, e)
end
function ConfLib.vectors(a: vector, b: vector, s: number)
	local c = vector.create(1, 2, 3)
	local d = vector.create(s, s, s)
	Sink(a + b, a - b, a * b, a / b, a // b, -a, a * s, s * a, a / s, s / a, a // s, a == b, a ~= b, a == c, c == vector.create(1, 2, 3), pcall(function() return a < b end), pcall(function() return a + 1 end), pcall(function() return a % b end))
	Sink(a.x, a.y, a.z, a.X, a.Y, a.Z, pcall(function() return a.w end), pcall(function() return a.magnitude end), c.x + c.y + c.z, vector.create(1, 2, 3).y, vector.create(0 / 0, 1 / 0, -0))
	Sink(vector.magnitude(a), vector.normalize(a), vector.normalize(vector.zero), vector.cross(a, b), vector.dot(a, b), vector.angle(a, b), vector.angle(a, b, c), vector.floor(a), vector.ceil(a), vector.abs(a), vector.sign(a), vector.clamp(a, vector.zero, vector.one), vector.max(a), vector.max(a, b, c, d), vector.min(a, b, c, d), vector.lerp(a, b, s))
	Sink(pcall(vector.clamp, a, vector.one, vector.zero), pcall(vector.create), pcall(vector.create, "x", 1, 2), vector.create(1, 2), vector.create(1, 2, 3, 4), typeof(a), type(a), tostring(a), `{a}`, { [a] = 1 }, rawequal(a, b))
	local acc = vector.zero
	for i = 1, s do acc += vector.create(i, i * 2, i * 3) * 0.5; acc = vector.normalize(acc) * vector.magnitude(acc) end
	local grid = {}
	for x = -1, 1 do for y = -1, 1 do for z = -1, 1 do grid[vector.create(x, y, z)] = x + y + z end end end
	return acc, grid
end
function ConfLib.userdata(ud, other, n)
	local v = Host.Vec2(1, 2)
	Sink(v.X, v.Y, v.Magnitude, v:Dot(other), v:Lerp(other, 0.5), v + other, v - other, v * n, n * v, v / n, -v, v == other, tostring(v), typeof(v), type(v), #ud, ud[1], ud.field, ud(n))
	ud.field = n; ud[1] = n; ud.Nested.Value = n
	ud:Method(); ud:Method(1, 2, 3); ud.Child:Method(n):Chain():Chain()
	for i = 1, n do ud:Accumulate(i); v = v + other * i end
	return v, ud:Result()
end
registry.ConfLib = ConfLib

-- ===== conformance: what the native backend specialises =======================
-- native.luau / native_types.luau / native_userdata.luau / promotion.luau / jit_inliner.luau:
-- typed parameters, numeric/vector/buffer loops, small helpers inlined into hot loops,
-- and functions hot enough to be promoted, all under @native
local ConfNative = {}
@native function ConfNative.typed(n: number, v: vector, b: buffer, s: string, t: { number }, f: (number) -> number, c: thread, o: boolean?, u: any)
	local acc = 0
	for i = 1, n do acc += f(i) * (t[i] or 0) end
	local vv = v
	for i = 1, n do vv = vv * 0.5 + vector.create(i, i, i) end
	local bsum = 0
	for i = 0, buffer.len(b) - 1 do bsum += buffer.readu8(b, i) end
	local ssum = 0
	for i = 1, #s do ssum += string.byte(s, i) end
	return acc, vv, bsum, ssum, coroutine.status(c), if o then 1 else 0, u
end
@native function ConfNative.loops(a: number, b: number, n: number)
	local x, y, z = a, b, 0
	for i = 1, n do
		x = x * 1.000001 + y
		y = math.sqrt(math.abs(x - y)) + math.sin(i)
		z += if x > y then x - y else y - x
		if z > 1e10 then z = z % 1e10 end
	end
	local i = 0
	while i < n do i += 1; x = bit32.bxor(bit32.lshift(x // 1, 3), i) % 2 ^ 32 end
	repeat n -= 1; y = math.floor(y / 2) until n <= 0 or y < 1
	return x, y, z
end
@native function ConfNative.arrays(t: { number }, n: number)
	local out = table.create(n, 0)
	for i = 1, n do out[i] = (t[i] or 0) * 2 + (out[i - 1] or 0) end
	for i = n, 2, -1 do out[i], out[i - 1] = out[i - 1], out[i] end
	local s = 0
	for _, v in ipairs(out) do s += v end
	for k, v in pairs(t) do s -= v end
	return out, s, #out
end
@native function ConfNative.buffers(b: buffer, n: number)
	for i = 0, n - 1 do buffer.writef32(b, i * 4, i * 0.25) end
	local s = 0
	for i = 0, n - 1 do s += buffer.readf32(b, i * 4) end
	for i = 0, n * 4 - 1 do buffer.writeu8(b, i, bit32.band(buffer.readu8(b, i) + 1, 255)) end
	return s
end
do
	local function nativeAdd(a: number, b: number): number return a + b end
	local function nativeLen(v: vector): number return vector.magnitude(v) end
	local function nativeClamp(x: number, lo: number, hi: number): number return if x < lo then lo elseif x > hi then hi else x end
	@native function ConfNative.inliner(n: number, v: vector)
		local s = 0
		for i = 1, n do s = nativeAdd(s, nativeClamp(i * 0.5, 1, 10)) + nativeLen(v * i) end
		local function local_helper(x) return x * x end
		for i = 1, n do s += local_helper(i) end
		return s
	end
end
function ConfNative.promotion(n)
	local function hot(x) return x * 2 + 1 end
	local acc = 0
	for i = 1, n do acc = hot(acc) % 1000003 end
	for _ = 1, 3 do for i = 1, n do acc += i end end
	return acc
end
@native function ConfNative.udata(ud: any, n: number)
	local acc = 0
	for i = 1, n do acc += ud.X * i + ud.Y; ud.X = acc end
	return acc, ud:Method(acc)
end
registry.ConfNative = ConfNative

-- ===== bench: micro_tests and gc ==============================================
-- micro_tests: one operation per benchmark, hammered in a loop: abs/add/sub, assert,
-- factorial, floor, global reads, ipairs, large table sums, method calls, multiple
-- assignment, polar conversion, sqrt, interpolation, table create/insert/move/remove/sort,
-- tonumber/tostring, vector math, string building, varargs, pcall, closure creation.
-- gc: binary and Boehm trees, tree pruning, keyed hashtables, mandelbrot, large
-- constructors, table.create fills, marshalling through select/pack/varargs, pcall+yield.
local BenchMicro = {}
function BenchMicro.ops(n, t, obj, ...)
	local s = 0
	for i = 1, n do s = math.abs(s - i) + i end
	for i = 1, n do assert(i, "never") end
	local function fact(k) if k <= 1 then return 1 end return k * fact(k - 1) end
	for i = 1, n do s += fact(i % 20) end
	for i = 1, n do s += math.floor(i / 3) end
	for i = 1, n do s += GA + GB end
	for i, v in ipairs(t) do s += i * v end
	for i = 1, #t do s += t[i] end
	for i = 1, n do s += obj:get(i) end
	for i = 1, n do local a, b, c = i, i + 1, i + 2; a, b, c = c, a, b; s += a - b + c end
	for i = 1, n do local r, th = math.sqrt(i * i + 1), math.atan2(i, 1); s += r * math.cos(th) + r * math.sin(th) end
	for i = 1, n do s += math.sqrt(i) end
	local str = ""
	for i = 1, n do str = `{i}:{s}` end
	for i = 1, n do local tt = table.create(8, i); s += #tt end
	local ins = {}
	for i = 1, n do table.insert(ins, i) end
	for i = 1, n do table.insert(ins, 1, i) end
	for i = 1, n do table.remove(ins) end
	for i = 1, n do table.remove(ins, 1) end
	local mv = table.create(n, 1)
	for i = 1, n do table.move(mv, 1, n - 1, 2) end
	table.sort(ins, function(a, b) return a > b end)
	for i = 1, n do s += tonumber(tostring(i)) end
	local v = vector.zero
	for i = 1, n do v = v * 0.99 + vector.create(i, -i, i * 0.5) end
	local parts = {}
	for i = 1, n do parts[#parts + 1] = tostring(i) end
	local sel = 0
	local function va(...) return select("#", ...) end
	for i = 1, n do sel += va(...) + va(i, i) end
	for i = 1, n do local ok = pcall(error, i); s += if ok then 1 else 0 end
	for i = 1, n do local f = function() return i end; s += f() end
	return s, str, v, table.concat(parts), sel, unpack({ 1, 2, 3 })
end
function BenchMicro.gc(depth, n)
	local function bottomUp(d) if d == 0 then return {} end d -= 1 return { bottomUp(d), bottomUp(d) } end
	local function check(tree) if not tree[1] then return 1 end return 1 + check(tree[1]) + check(tree[2]) end
	local long = bottomUp(depth)
	local total = 0
	for d = 4, depth, 2 do
		local iters = 2 ^ (depth - d + 4)
		for _ = 1, iters do total += check(bottomUp(d)) end
	end
	local function prune(tree, d) if d == 0 or not tree[1] then return end if d % 2 == 0 then tree[2] = nil end prune(tree[1], d - 1) end
	prune(long, depth)
	local hash = {}
	for i = 1, n do hash[tostring(i)] = { key = i, val = tostring(i):rep(2) } end
	for i = 1, n, 2 do hash[tostring(i)] = nil end
	local w, h, iter = n, n, 50
	local mandel = 0
	for y = 0, h - 1 do
		local ci = 2 * y / h - 1
		for x = 0, w - 1 do
			local cr, zr, zi, k = 2 * x / w - 1.5, 0, 0, 0
			while k < iter and zr * zr + zi * zi < 4 do zr, zi = zr * zr - zi * zi + cr, 2 * zr * zi + ci; k += 1 end
			mandel += k
		end
	end
	local arr = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70 }
	local rec = { a1 = 1, a2 = 2, a3 = 3, a4 = 4, a5 = 5, a6 = 6, a7 = 7, a8 = 8, a9 = 9, a10 = 10, b1 = "1", b2 = "2", b3 = "3", b4 = "4", b5 = "5", b6 = "6", b7 = "7", b8 = "8", b9 = "9", b10 = "10", c1 = true, c2 = false, c3 = 1.5, c4 = -1, c5 = {}, c6 = arr, c7 = n, c8 = depth, c9 = nil, c10 = "end" }
	local tc1, tc2, tc3 = table.create(n), table.create(n, 0), table.create(n, nil)
	local function marshal(...) return select("#", ...), table.pack(...), { ... } end
	for i = 1, n do marshal(i, i, i, i) end
	local co = coroutine.wrap(function() for i = 1, n do pcall(coroutine.yield, i) end end)
	for _ = 1, n do co() end
	return total, mandel, hash, arr, rec, tc1, tc2, tc3
end
registry.BenchMicro = BenchMicro

-- ===== bench: shootout, sunspider, integers, and the top-level tests ===========
-- shootout: fannkuch, fixpoint-fact, heapsort, n-body, qt (quadtree), queen, scimark
-- (FFT, SOR, Monte Carlo, sparse matmul, LU), spectral-norm (ack, binary-trees and
-- mandel live in Closures and BenchMicro). sunspider: 3d-cube, 3d-morph, bitops
-- (3bit, bits-in-byte, bitwise-and, nsieve), controlflow-recursive, crypto-aes,
-- crypto-md5, math-cordic, math-partial-sums. integers: 64-bit hashing on bit32
-- hi/lo pairs (blake2b, murmur, pollard_rho, sha3, sha512, xxh64). top level: chess,
-- life, matrixmult, mesh-normal-scalar/vector, pcmmix, sha256, sieve, tictactoe,
-- trig, voxelgen (base64 and qsort live in Codec and Algo).
local BenchClassic = {}
function BenchClassic.fannkuch(n)
	local perm, perm1, count = {}, {}, {}
	local maxFlips, checksum, r, permCount = 0, 0, n, 0
	for i = 0, n - 1 do perm1[i] = i end
	while true do
		while r ~= 1 do count[r - 1] = r; r -= 1 end
		for i = 0, n - 1 do perm[i] = perm1[i] end
		local flips = 0
		local k = perm[0]
		while k ~= 0 do
			local i, j = 0, k
			while i < j do perm[i], perm[j] = perm[j], perm[i]; i += 1; j -= 1 end
			flips += 1
			k = perm[0]
		end
		maxFlips = math.max(maxFlips, flips)
		checksum += if permCount % 2 == 0 then flips else -flips
		while true do
			if r == n then return checksum, maxFlips end
			local perm0 = perm1[0]
			for i = 0, r - 1 do perm1[i] = perm1[i + 1] end
			perm1[r] = perm0
			count[r] -= 1
			if count[r] > 0 then break end
			r += 1
		end
		permCount += 1
	end
end
function BenchClassic.fixpoint(n)
	local function Y(f) return (function(x) return x(x) end)(function(x) return f(function(...) return x(x)(...) end) end) end
	local fact = Y(function(self) return function(k) if k == 0 then return 1 end return k * self(k - 1) end end)
	return fact(n)
end
function BenchClassic.heapsort(a, n)
	local j, i, t
	local l = (n // 2) + 1
	local ir = n
	while true do
		if l > 1 then l -= 1; t = a[l]
		else
			t = a[ir]; a[ir] = a[1]; ir -= 1
			if ir == 1 then a[1] = t; return a end
		end
		i = l; j = l * 2
		while j <= ir do
			if j < ir and a[j] < a[j + 1] then j += 1 end
			if t < a[j] then a[i] = a[j]; i = j; j += i else j = ir + 1 end
		end
		a[i] = t
	end
end
function BenchClassic.nbody(bodies, steps, dt)
	local n = #bodies
	local function energy()
		local e = 0
		for i = 1, n do
			local b = bodies[i]
			e += 0.5 * b.mass * (b.vx * b.vx + b.vy * b.vy + b.vz * b.vz)
			for j = i + 1, n do
				local c = bodies[j]
				local dx, dy, dz = b.x - c.x, b.y - c.y, b.z - c.z
				e -= b.mass * c.mass / math.sqrt(dx * dx + dy * dy + dz * dz)
			end
		end
		return e
	end
	local start = energy()
	for _ = 1, steps do
		for i = 1, n do
			local b = bodies[i]
			local bx, by, bz, bm = b.x, b.y, b.z, b.mass
			local bvx, bvy, bvz = b.vx, b.vy, b.vz
			for j = i + 1, n do
				local c = bodies[j]
				local dx, dy, dz = bx - c.x, by - c.y, bz - c.z
				local d2 = dx * dx + dy * dy + dz * dz
				local mag = dt / (d2 * math.sqrt(d2))
				local bmm, cmm = bm * mag, c.mass * mag
				bvx -= dx * cmm; bvy -= dy * cmm; bvz -= dz * cmm
				c.vx += dx * bmm; c.vy += dy * bmm; c.vz += dz * bmm
			end
			b.vx, b.vy, b.vz = bvx, bvy, bvz
			b.x += dt * bvx; b.y += dt * bvy; b.z += dt * bvz
		end
	end
	return start, energy()
end
function BenchClassic.quadtree(points, cap)
	local function node(x, y, w, h) return { x = x, y = y, w = w, h = h, pts = {}, kids = nil } end
	local function contains(q, p) return p.x >= q.x and p.x < q.x + q.w and p.y >= q.y and p.y < q.y + q.h end
	local insert
	local function split(q)
		local hw, hh = q.w / 2, q.h / 2
		q.kids = { node(q.x, q.y, hw, hh), node(q.x + hw, q.y, hw, hh), node(q.x, q.y + hh, hw, hh), node(q.x + hw, q.y + hh, hw, hh) }
		for _, p in ipairs(q.pts) do for _, k in ipairs(q.kids) do if insert(k, p) then break end end end
		q.pts = nil
	end
	function insert(q, p)
		if not contains(q, p) then return false end
		if q.kids == nil then
			if #q.pts < cap then table.insert(q.pts, p); return true end
			split(q)
		end
		for _, k in ipairs(q.kids) do if insert(k, p) then return true end end
		return false
	end
	local function query(q, x, y, w, h, out)
		if q.x > x + w or q.x + q.w < x or q.y > y + h or q.y + q.h < y then return out end
		if q.pts then
			for _, p in ipairs(q.pts) do if p.x >= x and p.x <= x + w and p.y >= y and p.y <= y + h then out[#out + 1] = p end end
		else
			for _, k in ipairs(q.kids) do query(k, x, y, w, h, out) end
		end
		return out
	end
	local root = node(0, 0, 1, 1)
	for _, p in ipairs(points) do insert(root, p) end
	return #query(root, 0.25, 0.25, 0.5, 0.5, {})
end
function BenchClassic.queens(n)
	local cols, d1, d2, solutions = {}, {}, {}, 0
	local function place(row)
		if row > n then solutions += 1; return end
		for c = 1, n do
			if not cols[c] and not d1[row + c] and not d2[row - c + n] then
				cols[c], d1[row + c], d2[row - c + n] = true, true, true
				place(row + 1)
				cols[c], d1[row + c], d2[row - c + n] = false, false, false
			end
		end
	end
	place(1)
	return solutions
end
function BenchClassic.scimark(n, cycles, rand)
	local function fft(data, direction)
		local m = #data // 2
		local j = 1
		for i = 1, 2 * m, 2 do
			if j > i then data[i], data[j] = data[j], data[i]; data[i + 1], data[j + 1] = data[j + 1], data[i + 1] end
			local k = m
			while k >= 2 and j > k do j -= k; k //= 2 end
			j += k
		end
		local dual = 1
		while dual < m do
			local theta = direction * math.pi / dual
			local s, s2 = math.sin(theta), math.sin(theta / 2)
			local t = 2 * s2 * s2
			local wr, wi = 1, 0
			for a = 0, dual - 1 do
				for b = 0, m - 1, 2 * dual do
					local i, k = 2 * (b + a) + 1, 2 * (b + a + dual) + 1
					local zr, zi = data[k], data[k + 1]
					local xr, xi = wr * zr - wi * zi, wr * zi + wi * zr
					data[k], data[k + 1] = data[i] - xr, data[i + 1] - xi
					data[i], data[i + 1] = data[i] + xr, data[i + 1] + xi
				end
				wr, wi = wr - s * wi - t * wr, wi + s * wr - t * wi
			end
			dual *= 2
		end
		return data
	end
	local function sor(grid, omega)
		local m = #grid
		for _ = 1, cycles do
			for i = 2, m - 1 do
				local gi, gim, gip = grid[i], grid[i - 1], grid[i + 1]
				for j = 2, #gi - 1 do gi[j] = omega * 0.25 * (gim[j] + gip[j] + gi[j - 1] + gi[j + 1]) + (1 - omega) * gi[j] end
			end
		end
		return grid
	end
	local function monte(samples)
		local under = 0
		for _ = 1, samples do local x, y = rand(), rand(); if x * x + y * y <= 1 then under += 1 end end
		return under / samples * 4
	end
	local function sparse(y, val, row, col, x)
		for r = 1, #row - 1 do
			local sum = 0
			for i = row[r], row[r + 1] - 1 do sum += x[col[i]] * val[i] end
			y[r] = sum
		end
		return y
	end
	local function lu(a, pivot)
		local m = #a
		for j = 1, m do
			local jp, t = j, math.abs(a[j][j])
			for i = j + 1, m do local ab = math.abs(a[i][j]); if ab > t then jp, t = i, ab end end
			pivot[j] = jp
			if a[jp][j] == 0 then return false end
			if jp ~= j then a[j], a[jp] = a[jp], a[j] end
			if j < m then
				local recp = 1 / a[j][j]
				for k = j + 1, m do a[k][j] *= recp end
				for ii = j + 1, m do
					local aii, aij = a[ii], a[ii][j]
					for jj = j + 1, m do aii[jj] -= aij * a[j][jj] end
				end
			end
		end
		return true
	end
	local data = table.create(2 * n, 0)
	for i = 1, 2 * n do data[i] = rand() end
	local grid, mat = {}, {}
	for i = 1, n do grid[i] = table.create(n, 0); mat[i] = {}; for j = 1, n do grid[i][j] = rand(); mat[i][j] = rand() end end
	return fft(fft(data, -1), 1), sor(grid, 1.25), monte(n * 100), sparse({}, { 1, 2, 3 }, { 1, 2, 3, 4 }, { 1, 2, 3 }, { 4, 5, 6 }), lu(mat, {})
end
function BenchClassic.spectralnorm(n)
	local function A(i, j) local ij = i + j - 1 return 1 / (ij * (ij - 1) * 0.5 + i) end
	local function Av(x, y, N) for i = 1, N do local a = 0 for j = 1, N do a += x[j] * A(i, j) end y[i] = a end end
	local function Atv(x, y, N) for i = 1, N do local a = 0 for j = 1, N do a += x[j] * A(j, i) end y[i] = a end end
	local function AtAv(x, y, t, N) Av(x, t, N); Atv(t, y, N) end
	local u, v, t = table.create(n, 1), {}, {}
	for _ = 1, 10 do AtAv(u, v, t, n); AtAv(v, u, t, n) end
	local vBv, vv = 0, 0
	for i = 1, n do local ui, vi = u[i], v[i]; vBv += ui * vi; vv += vi * vi end
	return math.sqrt(vBv / vv)
end
function BenchClassic.cube(q, angle)
	local function mmul(m1, m2)
		local r = {}
		for i = 1, 4 do r[i] = {}; for j = 1, 4 do local s = 0; for k = 1, 4 do s += m1[i][k] * m2[k][j] end r[i][j] = s end end
		return r
	end
	local function rotX(a) local c, s = math.cos(a), math.sin(a) return { { 1, 0, 0, 0 }, { 0, c, -s, 0 }, { 0, s, c, 0 }, { 0, 0, 0, 1 } } end
	local function rotY(a) local c, s = math.cos(a), math.sin(a) return { { c, 0, s, 0 }, { 0, 1, 0, 0 }, { -s, 0, c, 0 }, { 0, 0, 0, 1 } } end
	local function rotZ(a) local c, s = math.cos(a), math.sin(a) return { { c, -s, 0, 0 }, { s, c, 0, 0 }, { 0, 0, 1, 0 }, { 0, 0, 0, 1 } } end
	local m = mmul(mmul(rotX(angle), rotY(angle * 2)), rotZ(angle * 3))
	local out = {}
	for i, p in ipairs(q) do
		out[i] = { m[1][1] * p[1] + m[1][2] * p[2] + m[1][3] * p[3] + m[1][4], m[2][1] * p[1] + m[2][2] * p[2] + m[2][3] * p[3] + m[2][4], m[3][1] * p[1] + m[3][2] * p[2] + m[3][3] * p[3] + m[3][4] }
	end
	return out
end
function BenchClassic.morph(a, f, n)
	for i = 0, n - 1 do
		local x = math.sin((f % 1) * math.pi * 2 + i / n)
		a[3 * i + 2] = x
		a[3 * i + 1] = x * 0.5
	end
	return a
end
function BenchClassic.bitops(n)
	local function bits3(b) local m = 0xE994; return bit32.band(bit32.rshift(m, 2 * bit32.band(b, 7)), 3) + bit32.band(bit32.rshift(m, 2 * bit32.band(bit32.rshift(b, 3), 7)), 3) + bit32.band(bit32.rshift(m, 2 * bit32.band(bit32.rshift(b, 6), 7)), 3) end
	local function bitsinbyte(b) local m, c = 1, 0 while m < 0x100 do if bit32.band(b, m) ~= 0 then c += 1 end m = bit32.lshift(m, 1) end return c end
	local total, bitwiseAnd = 0, 4294967296
	for i = 0, n do total += bits3(i % 256) + bitsinbyte(i % 256); bitwiseAnd = bit32.band(bitwiseAnd, i) end
	local nsieve = table.create(n + 1, true)
	local count = 0
	for i = 2, n do if nsieve[i] then count += 1; for k = i + i, n, i do nsieve[k] = false end end end
	return total, bitwiseAnd, count
end
function BenchClassic.recursive(n)
	local function ack(m, k) if m == 0 then return k + 1 end if k == 0 then return ack(m - 1, 1) end return ack(m - 1, ack(m, k - 1)) end
	local function fib(k) if k < 2 then return 1 end return fib(k - 2) + fib(k - 1) end
	local function tak(x, y, z) if y >= x then return z end return tak(tak(x - 1, y, z), tak(y - 1, z, x), tak(z - 1, x, y)) end
	local r = 0
	for i = 3, n do r += ack(3, i) + fib(17 + i) + tak(3 * i + 3, 2 * i + 2, i + 1) end
	return r
end
function BenchClassic.aes(state, w, sbox, rounds)
	local function subBytes(s) for r = 0, 3 do for c = 0, 3 do s[r][c] = sbox[s[r][c]] end end end
	local function shiftRows(s) for r = 1, 3 do local t = {}; for c = 0, 3 do t[c] = s[r][(c + r) % 4] end; for c = 0, 3 do s[r][c] = t[c] end end end
	local function mixColumns(s)
		for c = 0, 3 do
			local a, b = {}, {}
			for i = 0, 3 do a[i] = s[i][c]; b[i] = if bit32.band(s[i][c], 0x80) ~= 0 then bit32.band(bit32.bxor(bit32.lshift(s[i][c], 1), 0x011B), 0xFF) else bit32.lshift(s[i][c], 1) end
			s[0][c] = bit32.bxor(b[0], a[1], b[1], a[2], a[3])
			s[1][c] = bit32.bxor(a[0], b[1], a[2], b[2], a[3])
			s[2][c] = bit32.bxor(a[0], a[1], b[2], a[3], b[3])
			s[3][c] = bit32.bxor(a[0], b[0], a[1], a[2], b[3])
		end
	end
	local function addRoundKey(s, round) for r = 0, 3 do for c = 0, 3 do s[r][c] = bit32.bxor(s[r][c], w[round * 4 + c][r]) end end end
	addRoundKey(state, 0)
	for round = 1, rounds - 1 do subBytes(state); shiftRows(state); mixColumns(state); addRoundKey(state, round) end
	subBytes(state); shiftRows(state); addRoundKey(state, rounds)
	return state
end
function BenchClassic.md5(words)
	local K, S = {}, { 7, 12, 17, 22, 5, 9, 14, 20, 4, 11, 16, 23, 6, 10, 15, 21 }
	for i = 0, 63 do K[i] = bit32.band(math.floor(math.abs(math.sin(i + 1)) * 2 ^ 32), 0xFFFFFFFF) end
	local a0, b0, c0, d0 = 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476
	for chunk = 0, #words // 16 - 1 do
		local A, B, C, D = a0, b0, c0, d0
		for i = 0, 63 do
			local F, g
			if i < 16 then F, g = bit32.bor(bit32.band(B, C), bit32.band(bit32.bnot(B), D)), i
			elseif i < 32 then F, g = bit32.bor(bit32.band(D, B), bit32.band(bit32.bnot(D), C)), (5 * i + 1) % 16
			elseif i < 48 then F, g = bit32.bxor(B, C, D), (3 * i + 5) % 16
			else F, g = bit32.bxor(C, bit32.bor(B, bit32.bnot(D))), (7 * i) % 16 end
			F = (F + A + K[i] + words[chunk * 16 + g + 1]) % 2 ^ 32
			A, D, C = D, C, B
			B = (B + bit32.lrotate(F, S[(i // 16) * 4 + i % 4 + 1])) % 2 ^ 32
		end
		a0, b0, c0, d0 = (a0 + A) % 2 ^ 32, (b0 + B) % 2 ^ 32, (c0 + C) % 2 ^ 32, (d0 + D) % 2 ^ 32
	end
	return string.format("%08x%08x%08x%08x", bit32.byteswap(a0), bit32.byteswap(b0), bit32.byteswap(c0), bit32.byteswap(d0))
end
function BenchClassic.sha256(msg: string)
	local k = {
		0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
		0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
		0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
		0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
	}
	local h = { 0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19 }
	local ml = #msg * 8
	msg ..= "\128" .. string.rep("\0", (55 - #msg) % 64) .. string.pack(">I8", ml)
	local w = table.create(64, 0)
	for chunk = 1, #msg, 64 do
		for i = 0, 15 do w[i] = string.unpack(">I4", msg, chunk + i * 4) end
		for i = 16, 63 do
			local s0 = bit32.bxor(bit32.rrotate(w[i - 15], 7), bit32.rrotate(w[i - 15], 18), bit32.rshift(w[i - 15], 3))
			local s1 = bit32.bxor(bit32.rrotate(w[i - 2], 17), bit32.rrotate(w[i - 2], 19), bit32.rshift(w[i - 2], 10))
			w[i] = bit32.band(w[i - 16] + s0 + w[i - 7] + s1, 0xFFFFFFFF)
		end
		local a, b, c, d, e, f, g, hh = h[1], h[2], h[3], h[4], h[5], h[6], h[7], h[8]
		for i = 0, 63 do
			local S1 = bit32.bxor(bit32.rrotate(e, 6), bit32.rrotate(e, 11), bit32.rrotate(e, 25))
			local ch = bit32.bxor(bit32.band(e, f), bit32.band(bit32.bnot(e), g))
			local t1 = hh + S1 + ch + k[i + 1] + w[i]
			local S0 = bit32.bxor(bit32.rrotate(a, 2), bit32.rrotate(a, 13), bit32.rrotate(a, 22))
			local maj = bit32.bxor(bit32.band(a, b), bit32.band(a, c), bit32.band(b, c))
			hh, g, f, e, d, c, b, a = g, f, e, bit32.band(d + t1, 0xFFFFFFFF), c, b, a, bit32.band(t1 + S0 + maj, 0xFFFFFFFF)
		end
		h[1] = bit32.band(h[1] + a, 0xFFFFFFFF); h[2] = bit32.band(h[2] + b, 0xFFFFFFFF); h[3] = bit32.band(h[3] + c, 0xFFFFFFFF); h[4] = bit32.band(h[4] + d, 0xFFFFFFFF)
		h[5] = bit32.band(h[5] + e, 0xFFFFFFFF); h[6] = bit32.band(h[6] + f, 0xFFFFFFFF); h[7] = bit32.band(h[7] + g, 0xFFFFFFFF); h[8] = bit32.band(h[8] + hh, 0xFFFFFFFF)
	end
	return string.format(string.rep("%08x", 8), table.unpack(h))
end
function BenchClassic.cordic(target, n)
	local angles = { 45, 26.565, 14.0362, 7.12502, 3.57633, 1.78991, 0.895174, 0.447614, 0.223811, 0.111906, 0.055953, 0.027977 }
	local x, y, cur = 0.607252935, 0, 0
	for step = 1, #angles do
		local nx
		if target > cur then nx = x - y / 2 ^ (step - 1); y = x / 2 ^ (step - 1) + y; cur += angles[step]
		else nx = x + y / 2 ^ (step - 1); y = -x / 2 ^ (step - 1) + y; cur -= angles[step] end
		x = nx
	end
	local a1, a2, a3, a4, a5, a6, a7, a8, a9, alt = 0, 0, 0, 0, 0, 0, 0, 0, 0, -1
	for k = 1, n do
		local k2, k3, sk, ck = k * k, k * k * k, math.sin(k), math.cos(k)
		alt = -alt
		a1 += (2 / 3) ^ (k - 1); a2 += 1 / math.sqrt(k); a3 += 1 / (k * (k + 1)); a4 += 1 / (k3 * sk * sk); a5 += 1 / (k3 * ck * ck)
		a6 += 1 / k; a7 += 1 / k2; a8 += alt / k; a9 += alt / (2 * k - 1)
	end
	return x, y, a1, a2, a3, a4, a5, a6, a7, a8, a9
end
function BenchClassic.int64(hi, lo, n)
	local function add64(ah, al, bh, bl) local l = al + bl; local h = ah + bh + (if l >= 2 ^ 32 then 1 else 0) return bit32.band(h, 0xFFFFFFFF), bit32.band(l, 0xFFFFFFFF) end
	local function rotr64(h, l, k)
		if k >= 32 then h, l = l, h; k -= 32 end
		if k == 0 then return h, l end
		return bit32.bor(bit32.rshift(h, k), bit32.lshift(l, 32 - k)), bit32.bor(bit32.rshift(l, k), bit32.lshift(h, 32 - k))
	end
	local function mul32(a, b)
		local ah, al = bit32.rshift(a, 16), bit32.band(a, 0xFFFF)
		local bh, bl = bit32.rshift(b, 16), bit32.band(b, 0xFFFF)
		local mid = ah * bl + al * bh
		local low = al * bl + bit32.lshift(bit32.band(mid, 0xFFFF), 16)
		return bit32.band(low, 0xFFFFFFFF), ah * bh + bit32.rshift(mid, 16) + (if low >= 2 ^ 32 then 1 else 0)
	end
	local function xor64(ah, al, bh, bl) return bit32.bxor(ah, bh), bit32.bxor(al, bl) end
	local state = {}
	for i = 0, 24 do state[i] = { 0, 0 } end
	for i = 1, n do
		hi, lo = add64(hi, lo, 0x9E3779B9, 0x7F4A7C15)
		hi, lo = rotr64(hi, lo, i % 64)
		hi, lo = xor64(hi, lo, mul32(hi, lo))
		local s = state[i % 25]
		s[1], s[2] = xor64(s[1], s[2], hi, lo)
	end
	for round = 1, 24 do
		local c = {}
		for x = 0, 4 do c[x] = { bit32.bxor(state[x][1], state[x + 5][1], state[x + 10][1], state[x + 15][1], state[x + 20][1]), bit32.bxor(state[x][2], state[x + 5][2], state[x + 10][2], state[x + 15][2], state[x + 20][2]) } end
		for x = 0, 4 do
			local dh, dl = rotr64(c[(x + 1) % 5][1], c[(x + 1) % 5][2], 63)
			dh, dl = xor64(dh, dl, c[(x + 4) % 5][1], c[(x + 4) % 5][2])
			for y = 0, 20, 5 do state[x + y][1], state[x + y][2] = xor64(state[x + y][1], state[x + y][2], dh, dl) end
		end
		for y = 0, 20, 5 do
			local row = { state[y], state[y + 1], state[y + 2], state[y + 3], state[y + 4] }
			for x = 0, 4 do
				local a, b, cc = row[x + 1], row[(x + 1) % 5 + 1], row[(x + 2) % 5 + 1]
				state[y + x] = { bit32.bxor(a[1], bit32.band(bit32.bnot(b[1]), cc[1])), bit32.bxor(a[2], bit32.band(bit32.bnot(b[2]), cc[2])) }
			end
		end
		state[0][2] = bit32.bxor(state[0][2], round)
	end
	return hi, lo, state
end
function BenchClassic.life(cells: { string }, gens: number)
	local h, w = #cells, #cells[1]
	local grid = {}
	for y = 1, h do grid[y] = {}; for x = 1, w do grid[y][x] = cells[y]:sub(x, x) == "#" end end
	for _ = 1, gens do
		local nextg = {}
		for y = 1, h do
			local row = {}
			for x = 1, w do
				local n = 0
				for dy = -1, 1 do for dx = -1, 1 do if (dy ~= 0 or dx ~= 0) and grid[(y + dy - 1) % h + 1][(x + dx - 1) % w + 1] then n += 1 end end end
				row[x] = n == 3 or (n == 2 and grid[y][x])
			end
			nextg[y] = row
		end
		grid = nextg
	end
	local out = {}
	for y = 1, h do local line = table.create(w); for x = 1, w do line[x] = if grid[y][x] then "#" else "." end out[y] = table.concat(line) end
	return table.concat(out, "\n")
end
function BenchClassic.matrix(a, b, n)
	local c = table.create(n)
	for i = 1, n do
		local ci, ai = table.create(n, 0), a[i]
		for j = 1, n do local s = 0; for k = 1, n do s += ai[k] * b[k][j] end ci[j] = s end
		c[i] = ci
	end
	return c
end
function BenchClassic.meshnormals(verts: { vector }, tris: { number })
	local normals = table.create(#verts, vector.zero)
	for i = 1, #tris, 3 do
		local a, b, c = tris[i], tris[i + 1], tris[i + 2]
		local n = vector.cross(verts[b] - verts[a], verts[c] - verts[a])
		normals[a] += n; normals[b] += n; normals[c] += n
	end
	for i, n in normals do normals[i] = vector.normalize(n) end
	local nx, ny, nz = table.create(#verts, 0), table.create(#verts, 0), table.create(#verts, 0)
	for i = 1, #tris, 3 do
		local a, b, c = verts[tris[i]], verts[tris[i + 1]], verts[tris[i + 2]]
		local ux, uy, uz = b.x - a.x, b.y - a.y, b.z - a.z
		local vx, vy, vz = c.x - a.x, c.y - a.y, c.z - a.z
		local cx, cy, cz = uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
		for _, k in { tris[i], tris[i + 1], tris[i + 2] } do nx[k] += cx; ny[k] += cy; nz[k] += cz end
	end
	return normals, nx, ny, nz
end
function BenchClassic.pcmmix(a: buffer, b: buffer, out: buffer, gain: number)
	for i = 0, buffer.len(out) - 2, 2 do
		local s = buffer.readi16(a, i) + buffer.readi16(b, i) * gain
		buffer.writei16(out, i, math.clamp(s // 1, -32768, 32767))
	end
	return out
end
function BenchClassic.sieve(n)
	local flags, count = table.create(n, true), 0
	for i = 2, n do
		if flags[i] then
			count += 1
			for k = i * i, n, i do flags[k] = false end
		end
	end
	return count
end
function BenchClassic.tictactoe(board, player)
	local lines = { { 1, 2, 3 }, { 4, 5, 6 }, { 7, 8, 9 }, { 1, 4, 7 }, { 2, 5, 8 }, { 3, 6, 9 }, { 1, 5, 9 }, { 3, 5, 7 } }
	local function winner(b) for _, l in ipairs(lines) do local v = b[l[1]] if v ~= 0 and v == b[l[2]] and v == b[l[3]] then return v end end return 0 end
	local function minimax(b, p, depth)
		local w = winner(b)
		if w ~= 0 then return w * (10 - depth) end
		local best, any = if p == 1 then -math.huge else math.huge, false
		for i = 1, 9 do
			if b[i] == 0 then
				any = true
				b[i] = p
				local score = minimax(b, -p, depth + 1)
				b[i] = 0
				best = if p == 1 then math.max(best, score) else math.min(best, score)
			end
		end
		return if any then best else 0
	end
	return minimax(board, player, 0)
end
function BenchClassic.trig(n)
	local s = 0
	for i = 1, n do local a = i * 0.001; s += math.sin(a) * math.cos(a) + math.tan(a * 0.5) - math.atan2(math.sin(a), math.cos(a)) + math.asin(a % 1) + math.acos(a % 1) end
	return s
end
function BenchClassic.voxels(size, seed)
	local data = buffer.create(size * size * size)
	local function noise(x, y, z) return math.noise(x * 0.1 + seed, y * 0.1, z * 0.1) end
	local solid = 0
	for x = 0, size - 1 do
		for y = 0, size - 1 do
			for z = 0, size - 1 do
				local d = noise(x, y, z) - (y / size - 0.5)
				local id = if d > 0.2 then 3 elseif d > 0 then 2 elseif d > -0.1 then 1 else 0
				buffer.writeu8(data, x + y * size + z * size * size, id)
				if id ~= 0 then solid += 1 end
			end
		end
	end
	return data, solid
end
function BenchClassic.chess(board, side, depth)
	local KNIGHT = { -21, -19, -12, -8, 8, 12, 19, 21 }
	local KING = { -11, -10, -9, -1, 1, 9, 10, 11 }
	local SLIDES = { b = { -11, -9, 9, 11 }, r = { -10, -1, 1, 10 }, q = KING }
	local VALUE = { p = 100, n = 320, b = 330, r = 500, q = 900, k = 20000 }
	local function moves(b, s)
		local out = {}
		for sq = 21, 98 do
			local piece = b[sq]
			if piece and piece ~= "." and piece ~= " " and (piece:upper() == piece) == (s == 1) then
				local kind = piece:lower()
				if kind == "p" then
					local dir = if s == 1 then -10 else 10
					if b[sq + dir] == "." then out[#out + 1] = { sq, sq + dir } end
					for _, cap in { dir - 1, dir + 1 } do local t = b[sq + cap] if t and t ~= "." and t ~= " " and (t:upper() == t) ~= (s == 1) then out[#out + 1] = { sq, sq + cap } end end
				elseif kind == "n" or kind == "k" then
					for _, d in (if kind == "n" then KNIGHT else KING) do local t = b[sq + d] if t == "." or (t and t ~= " " and (t:upper() == t) ~= (s == 1)) then out[#out + 1] = { sq, sq + d } end end
				else
					for _, d in SLIDES[kind] do
						local to = sq + d
						while b[to] == "." do out[#out + 1] = { sq, to }; to += d end
						local t = b[to]
						if t and t ~= " " and (t:upper() == t) ~= (s == 1) then out[#out + 1] = { sq, to } end
					end
				end
			end
		end
		return out
	end
	local function eval(b) local score = 0 for sq = 21, 98 do local p = b[sq] if p and VALUE[p:lower()] then score += if p:upper() == p then VALUE[p:lower()] else -VALUE[p:lower()] end end return score end
	local function search(b, s, d, alpha, beta)
		if d == 0 then return s * eval(b) end
		for _, m in ipairs(moves(b, s)) do
			local from, to = m[1], m[2]
			local captured = b[to]
			b[to], b[from] = b[from], "."
			local score = -search(b, -s, d - 1, -beta, -alpha)
			b[from], b[to] = b[to], captured
			if score >= beta then return beta end
			if score > alpha then alpha = score end
		end
		return alpha
	end
	return search(board, side, depth, -math.huge, math.huge)
end
registry.BenchClassic = BenchClassic

-- ===== bench: zefbench, other, and the vibemark67 programs ====================
-- zefbench: richards (OOP task scheduler), cdx (collision detection over a red-black
-- tree); air and basic run a whole interpreter (Lang covers that shape). other:
-- LuauPolyfillMap (insertion-ordered Map), HashLib (sha256/md5 live in BenchClassic),
-- regex (a backtracking matcher). vibemark67, one kernel per program: noise
-- (chacha20, x25519 field math, ML-KEM NTT; keccak in BenchClassic.int64), deflate
-- (huffman lengths, lz77), ppm (arithmetic coding), qoi, markdown, neural (forward,
-- softmax, backprop), erosion, charonvg (bezier flattening, scanline fill, blending),
-- sarcasm (x86 encoder, linear-scan regalloc), stinky (RISC-V emulator), typeset
-- (Knuth-Plass breaking), physics (sweep and prune, impulses), sql, http, luau_interp
-- (register VM dispatch), raytrace (BVH over vectors), sat (DPLL), xz (LZMA range
-- decoding), git (object store, LCS diff), vibechess/chess-dir (BenchClassic.chess).
local BenchApps = {}
function BenchApps.richards(count)
	local ID_IDLE, ID_WORKER, ID_HANDLER_A, ID_HANDLER_B, ID_DEVICE_A, ID_DEVICE_B = 1, 2, 3, 4, 5, 6
	local KIND_DEVICE, KIND_WORK = 0, 1
	local STATE_RUNNING, STATE_RUNNABLE, STATE_SUSPENDED, STATE_HELD = 0, 1, 2, 4
	local Packet = {}
	Packet.__index = Packet
	function Packet.new(link, id, kind) return setmetatable({ link = link, id = id, kind = kind, a1 = 0, a2 = table.create(4, 0) }, Packet) end
	function Packet:addTo(queue)
		self.link = nil
		if queue == nil then return self end
		local peek, nxt = nil, queue
		while nxt do peek = nxt; nxt = peek.link end
		peek.link = self
		return queue
	end
	local TaskControlBlock = {}
	TaskControlBlock.__index = TaskControlBlock
	function TaskControlBlock.new(link, id, priority, queue, task) return setmetatable({ link = link, id = id, priority = priority, queue = queue, task = task, state = if queue == nil then STATE_SUSPENDED else STATE_SUSPENDED + STATE_RUNNABLE }, TaskControlBlock) end
	function TaskControlBlock:isHeldOrSuspended() return bit32.band(self.state, STATE_HELD) ~= 0 or self.state == STATE_SUSPENDED end
	function TaskControlBlock:markAsRunnable() self.state = bit32.bor(self.state, STATE_RUNNABLE) end
	function TaskControlBlock:markAsSuspended() self.state = bit32.bor(self.state, STATE_SUSPENDED) end
	function TaskControlBlock:markAsHeld() self.state = bit32.bor(self.state, STATE_HELD) end
	function TaskControlBlock:markAsNotHeld() self.state = bit32.band(self.state, bit32.bnot(STATE_HELD)) end
	function TaskControlBlock:checkPriorityAdd(task, packet)
		if self.queue == nil then
			self.queue = packet
			self:markAsRunnable()
			if self.priority > task.priority then return self end
		else
			self.queue = packet:addTo(self.queue)
		end
		return task
	end
	function TaskControlBlock:run()
		local packet
		if self.state == STATE_SUSPENDED + STATE_RUNNABLE then
			packet = self.queue
			self.queue = packet.link
			self.state = if self.queue == nil then STATE_RUNNING else STATE_RUNNABLE
		end
		return self.task:run(packet)
	end
	local Scheduler = {}
	Scheduler.__index = Scheduler
	function Scheduler.new() return setmetatable({ queueCount = 0, holdCount = 0, blocks = table.create(6), list = nil, currentTcb = nil, currentId = nil }, Scheduler) end
	function Scheduler:addTask(id, priority, queue, task) self.currentTcb = TaskControlBlock.new(self.list, id, priority, queue, task); self.list = self.currentTcb; self.blocks[id] = self.currentTcb end
	function Scheduler:schedule()
		self.currentTcb = self.list
		while self.currentTcb do
			if self.currentTcb:isHeldOrSuspended() then self.currentTcb = self.currentTcb.link
			else self.currentId = self.currentTcb.id; self.currentTcb = self.currentTcb:run() end
		end
	end
	function Scheduler:release(id) local tcb = self.blocks[id] if not tcb then return tcb end tcb:markAsNotHeld() if tcb.priority > self.currentTcb.priority then return tcb end return self.currentTcb end
	function Scheduler:holdCurrent() self.holdCount += 1; self.currentTcb:markAsHeld(); return self.currentTcb.link end
	function Scheduler:suspendCurrent() self.currentTcb:markAsSuspended(); return self.currentTcb end
	function Scheduler:queue(packet) local t = self.blocks[packet.id] if not t then return t end self.queueCount += 1; packet.link = nil; packet.id = self.currentId; return t:checkPriorityAdd(self.currentTcb, packet) end
	local s = Scheduler.new()
	local idle = { scheduler = s, v1 = 1, count = count }
	function idle:run(packet)
		self.count -= 1
		if self.count == 0 then return self.scheduler:holdCurrent() end
		if bit32.band(self.v1, 1) == 0 then self.v1 = bit32.rshift(self.v1, 1); return self.scheduler:release(ID_DEVICE_A) end
		self.v1 = bit32.bxor(bit32.rshift(self.v1, 1), 0xD008)
		return self.scheduler:release(ID_DEVICE_B)
	end
	local worker = { scheduler = s, v1 = ID_HANDLER_A, v2 = 0 }
	function worker:run(packet)
		if packet == nil then return self.scheduler:suspendCurrent() end
		self.v1 = if self.v1 == ID_HANDLER_A then ID_HANDLER_B else ID_HANDLER_A
		packet.id = self.v1; packet.a1 = 0
		for i = 1, 4 do self.v2 += 1; if self.v2 > 26 then self.v2 = 1 end packet.a2[i] = self.v2 end
		return self.scheduler:queue(packet)
	end
	s:addTask(ID_IDLE, 0, nil, idle)
	local queue = Packet.new(nil, ID_WORKER, KIND_WORK)
	queue = Packet.new(queue, ID_WORKER, KIND_DEVICE)
	s:addTask(ID_WORKER, 1000, queue, worker)
	s:schedule()
	return s.queueCount, s.holdCount
end
function BenchApps.redblack(keys)
	local RED, BLACK = true, false
	local root = nil
	local function rotateLeft(x)
		local y = x.right
		x.right = y.left
		if y.left then y.left.parent = x end
		y.parent = x.parent
		if not x.parent then root = y elseif x == x.parent.left then x.parent.left = y else x.parent.right = y end
		y.left = x; x.parent = y
	end
	local function rotateRight(x)
		local y = x.left
		x.left = y.right
		if y.right then y.right.parent = x end
		y.parent = x.parent
		if not x.parent then root = y elseif x == x.parent.right then x.parent.right = y else x.parent.left = y end
		y.right = x; x.parent = y
	end
	local function insert(key, value)
		local parent, node = nil, root
		while node do
			parent = node
			if key < node.key then node = node.left elseif key > node.key then node = node.right else node.value = value; return end
		end
		local z = { key = key, value = value, color = RED, parent = parent }
		if not parent then root = z elseif key < parent.key then parent.left = z else parent.right = z end
		while z.parent and z.parent.color == RED do
			local gp = z.parent.parent
			if z.parent == gp.left then
				local uncle = gp.right
				if uncle and uncle.color == RED then z.parent.color, uncle.color, gp.color = BLACK, BLACK, RED; z = gp
				else
					if z == z.parent.right then z = z.parent; rotateLeft(z) end
					z.parent.color, gp.color = BLACK, RED; rotateRight(gp)
				end
			else
				local uncle = gp.left
				if uncle and uncle.color == RED then z.parent.color, uncle.color, gp.color = BLACK, BLACK, RED; z = gp
				else
					if z == z.parent.left then z = z.parent; rotateRight(z) end
					z.parent.color, gp.color = BLACK, RED; rotateLeft(gp)
				end
			end
		end
		root.color = BLACK
	end
	for i, k in ipairs(keys) do insert(k, i) end
	local function walk(n, out) if n then walk(n.left, out); out[#out + 1] = n.key; walk(n.right, out) end return out end
	return walk(root, {})
end
function BenchApps.map()
	local Map = {}
	Map.__index = Map
	function Map.new(iterable) local self = setmetatable({ size = 0, _map = {}, _array = {} }, Map) if iterable then for _, entry in ipairs(iterable) do self:set(entry[1], entry[2]) end end return self end
	function Map:set(key, value) if self._map[key] == nil then self.size += 1; table.insert(self._array, key) end self._map[key] = value return self end
	function Map:get(key) return self._map[key] end
	function Map:has(key) return self._map[key] ~= nil end
	function Map:delete(key) if not self:has(key) then return false end self.size -= 1; self._map[key] = nil; local i = table.find(self._array, key); if i then table.remove(self._array, i) end return true end
	function Map:clear() table.clear(self._map); table.clear(self._array); self.size = 0 end
	function Map:forEach(cb) for _, key in ipairs(self._array) do cb(self._map[key], key, self) end end
	function Map:keys() return table.clone(self._array) end
	function Map:entries() local out = table.create(self.size) for i, key in ipairs(self._array) do out[i] = { key, self._map[key] } end return out end
	function Map:__iter() local i = 0 return function() i += 1; local key = self._array[i]; if key ~= nil then return key, self._map[key] end return nil end end
	function Map.__len(self) return self.size end
	function Map.__tostring(self) local parts = {} for k, v in self do parts[#parts + 1] = `{k} => {v}` end return `Map(\{{table.concat(parts, ", ")}})` end
	return Map
end
function BenchApps.regex(pattern: string, subject: string)
	local pos = 1
	local parseAlt
	local function parseAtom()
		local c = pattern:sub(pos, pos)
		pos += 1
		if c == "." then return { op = "any" }
		elseif c == "^" then return { op = "bol" }
		elseif c == "$" then return { op = "eol" }
		elseif c == "(" then local inner = parseAlt(); pos += 1; return { op = "group", inner }
		elseif c == "[" then
			local negate, set = pattern:sub(pos, pos) == "^", {}
			if negate then pos += 1 end
			while pattern:sub(pos, pos) ~= "]" do
				local lo = pattern:sub(pos, pos)
				if pattern:sub(pos + 1, pos + 1) == "-" and pattern:sub(pos + 2, pos + 2) ~= "]" then set[#set + 1] = { lo:byte(), pattern:byte(pos + 2) }; pos += 3
				else set[#set + 1] = { lo:byte(), lo:byte() }; pos += 1 end
			end
			pos += 1
			return { op = "class", negate = negate, set = set }
		elseif c == "\\" then local e = pattern:sub(pos, pos); pos += 1; return { op = "char", e }
		end
		return { op = "char", c }
	end
	local function parseRepeat()
		local atom = parseAtom()
		local q = pattern:sub(pos, pos)
		if q == "*" or q == "+" or q == "?" then pos += 1; local lazy = pattern:sub(pos, pos) == "?"; if lazy then pos += 1 end return { op = q, atom, lazy = lazy } end
		return atom
	end
	local function parseSeq()
		local seq = { op = "seq" }
		while pos <= #pattern and pattern:sub(pos, pos) ~= "|" and pattern:sub(pos, pos) ~= ")" do seq[#seq + 1] = parseRepeat() end
		return seq
	end
	function parseAlt()
		local alts = { op = "alt", parseSeq() }
		while pattern:sub(pos, pos) == "|" do pos += 1; alts[#alts + 1] = parseSeq() end
		return if #alts == 1 then alts[1] else alts
	end
	local tree = parseAlt()
	local function m(node, i, k)
		local op = node.op
		if op == "char" then if subject:sub(i, i) == node[1] then return k(i + 1) end return nil
		elseif op == "any" then if i <= #subject then return k(i + 1) end return nil
		elseif op == "bol" then if i == 1 then return k(i) end return nil
		elseif op == "eol" then if i == #subject + 1 then return k(i) end return nil
		elseif op == "class" then
			local b = subject:byte(i)
			if not b then return nil end
			local hit = false
			for _, r in node.set do if b >= r[1] and b <= r[2] then hit = true; break end end
			if hit ~= node.negate then return k(i + 1) end
			return nil
		elseif op == "group" then return m(node[1], i, k)
		elseif op == "seq" then
			local function step(idx, j) if idx > #node then return k(j) end return m(node[idx], j, function(nj) return step(idx + 1, nj) end) end
			return step(1, i)
		elseif op == "alt" then for _, alt in ipairs(node) do local r = m(alt, i, k) if r then return r end end return nil
		elseif op == "?" then
			if node.lazy then return k(i) or m(node[1], i, k) end
			return m(node[1], i, k) or k(i)
		elseif op == "*" or op == "+" then
			local function star(j, count)
				if node.lazy then
					if count > 0 or op == "*" then local r = k(j) if r then return r end end
					return m(node[1], j, function(nj) if nj == j then return nil end return star(nj, count + 1) end)
				end
				local r = m(node[1], j, function(nj) if nj == j then return nil end return star(nj, count + 1) end)
				if r then return r end
				if count > 0 or op == "*" then return k(j) end
				return nil
			end
			return star(i, 0)
		end
		error(`bad op {op}`)
	end
	for start = 1, #subject + 1 do
		local stop = m(tree, start, function(j) return j end)
		if stop then return start, stop - 1, subject:sub(start, stop - 1) end
	end
	return nil
end
function BenchApps.chacha20(key, nonce, counter, blocks)
	local function qr(s, a, b, c, d)
		s[a] = bit32.band(s[a] + s[b], 0xFFFFFFFF); s[d] = bit32.lrotate(bit32.bxor(s[d], s[a]), 16)
		s[c] = bit32.band(s[c] + s[d], 0xFFFFFFFF); s[b] = bit32.lrotate(bit32.bxor(s[b], s[c]), 12)
		s[a] = bit32.band(s[a] + s[b], 0xFFFFFFFF); s[d] = bit32.lrotate(bit32.bxor(s[d], s[a]), 8)
		s[c] = bit32.band(s[c] + s[d], 0xFFFFFFFF); s[b] = bit32.lrotate(bit32.bxor(s[b], s[c]), 7)
	end
	local out = buffer.create(64 * blocks)
	for blk = 0, blocks - 1 do
		local init = { 0x61707865, 0x3320646e, 0x79622d32, 0x6b206574, key[1], key[2], key[3], key[4], key[5], key[6], key[7], key[8], counter + blk, nonce[1], nonce[2], nonce[3] }
		local s = table.clone(init)
		for _ = 1, 10 do
			qr(s, 1, 5, 9, 13); qr(s, 2, 6, 10, 14); qr(s, 3, 7, 11, 15); qr(s, 4, 8, 12, 16)
			qr(s, 1, 6, 11, 16); qr(s, 2, 7, 12, 13); qr(s, 3, 8, 9, 14); qr(s, 4, 5, 10, 15)
		end
		for i = 1, 16 do buffer.writeu32(out, blk * 64 + (i - 1) * 4, bit32.band(s[i] + init[i], 0xFFFFFFFF)) end
	end
	return out
end
function BenchApps.field25519(a, b)
	local function car(o) for i = 1, 16 do o[i] += 65536; local c = o[i] // 65536; if i < 16 then o[i + 1] += c - 1 else o[1] += 38 * (c - 1) end o[i] -= c * 65536 end end
	local function mul(x, y)
		local t = table.create(31, 0)
		for i = 1, 16 do for j = 1, 16 do t[i + j - 1] += x[i] * y[j] end end
		for i = 1, 15 do t[i] += 38 * t[i + 16] end
		local o = table.move(t, 1, 16, 1, {})
		car(o); car(o)
		return o
	end
	local function add(x, y) local o = {} for i = 1, 16 do o[i] = x[i] + y[i] end return o end
	local function sub(x, y) local o = {} for i = 1, 16 do o[i] = x[i] - y[i] end return o end
	local function sel(p, q, bit) for i = 1, 16 do local t = bit * (p[i] - q[i]) p[i] -= t; q[i] += t end end
	local A24 = { 0xdb41, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	local x2, z2, x3, z3 = table.create(16, 0), table.create(16, 0), table.clone(b), table.create(16, 0)
	x2[1], z3[1] = 1, 1
	for i = 254, 0, -1 do
		local bit = bit32.extract(a[i // 8 + 1], i % 8, 1)
		sel(x2, x3, bit); sel(z2, z3, bit)
		local e, f = add(x2, z2), sub(x2, z2)
		local g, h = add(x3, z3), sub(x3, z3)
		local da, cb = mul(h, e), mul(g, f)
		local ee, ff = mul(e, e), mul(f, f)
		x3, z3 = mul(add(da, cb), add(da, cb)), mul(b, mul(sub(da, cb), sub(da, cb)))
		x2, z2 = mul(ee, ff), mul(sub(ee, ff), add(ee, mul(A24, sub(ee, ff))))
		sel(x2, x3, bit); sel(z2, z3, bit)
	end
	return x2, z2
end
function BenchApps.ntt(poly, zetas)
	local q = 3329
	local k, len = 1, 128
	while len >= 2 do
		for start = 0, 255, 2 * len do
			local zeta = zetas[k]; k += 1
			for j = start, start + len - 1 do
				local t = (zeta * poly[j + len + 1]) % q
				poly[j + len + 1] = (poly[j + 1] - t) % q
				poly[j + 1] = (poly[j + 1] + t) % q
			end
		end
		len //= 2
	end
	local function barrett(a) local v = (a * 20159 + 2 ^ 25) // 2 ^ 26 return a - v * q end
	for i = 1, 256 do poly[i] = barrett(poly[i]) end
	return poly
end
function BenchApps.deflate(data: string, window: number)
	local freq = {}
	for i = 1, #data do local b = data:byte(i); freq[b] = (freq[b] or 0) + 1 end
	local nodes = {}
	for sym, f in freq do nodes[#nodes + 1] = { f = f, sym = sym } end
	while #nodes > 1 do
		table.sort(nodes, function(a, b) return a.f > b.f end)
		local a, b = table.remove(nodes), table.remove(nodes)
		nodes[#nodes + 1] = { f = a.f + b.f, a, b }
	end
	local lengths = {}
	local function walk(n, depth) if n.sym then lengths[n.sym] = math.max(depth, 1) else walk(n[1], depth + 1); walk(n[2], depth + 1) end end
	if nodes[1] then walk(nodes[1], 0) end
	local tokens, i, head = {}, 1, {}
	while i <= #data do
		local key = data:sub(i, i + 2)
		local bestLen, bestDist = 0, 0
		local cand = head[key]
		while cand and i - cand.pos <= window do
			local l = 0
			while l < 258 and i + l <= #data and data:byte(cand.pos + l) == data:byte(i + l) do l += 1 end
			if l > bestLen then bestLen, bestDist = l, i - cand.pos end
			cand = cand.prev
		end
		head[key] = { pos = i, prev = head[key] }
		if bestLen >= 3 then tokens[#tokens + 1] = { bestLen, bestDist }; i += bestLen
		else tokens[#tokens + 1] = data:byte(i); i += 1 end
	end
	return lengths, tokens
end
function BenchApps.arith(symbols, model)
	local low, high, pending, bits = 0, 0xFFFFFFFF, 0, {}
	local function emit(b) bits[#bits + 1] = b; for _ = 1, pending do bits[#bits + 1] = 1 - b end pending = 0 end
	for _, s in ipairs(symbols) do
		local total, cumLow, cumHigh = 0, 0, 0
		for sym, count in ipairs(model) do if sym < s then cumLow += count end if sym <= s then cumHigh += count end total += count end
		local range = high - low + 1
		high = low + (range * cumHigh) // total - 1
		low = low + (range * cumLow) // total
		while true do
			if high < 0x80000000 then emit(0)
			elseif low >= 0x80000000 then emit(1); low -= 0x80000000; high -= 0x80000000
			elseif low >= 0x40000000 and high < 0xC0000000 then pending += 1; low -= 0x40000000; high -= 0x40000000
			else break end
			low *= 2; high = high * 2 + 1
		end
		model[s] += 1
	end
	return bits
end
function BenchApps.qoi(pixels: buffer, w: number, h: number)
	local out = buffer.create(w * h * 5 + 22)
	local pos = 14
	buffer.writestring(out, 0, "qoif"); buffer.writeu32(out, 4, bit32.byteswap(w)); buffer.writeu32(out, 8, bit32.byteswap(h)); buffer.writeu8(out, 12, 4); buffer.writeu8(out, 13, 0)
	local index = table.create(64 * 4, 0)
	local pr, pg, pb, pa, run = 0, 0, 0, 255, 0
	for px = 0, w * h - 1 do
		local r, g, b, a = buffer.readu8(pixels, px * 4), buffer.readu8(pixels, px * 4 + 1), buffer.readu8(pixels, px * 4 + 2), buffer.readu8(pixels, px * 4 + 3)
		if r == pr and g == pg and b == pb and a == pa then
			run += 1
			if run == 62 or px == w * h - 1 then buffer.writeu8(out, pos, 0xC0 + run - 1); pos += 1; run = 0 end
			continue
		end
		if run > 0 then buffer.writeu8(out, pos, 0xC0 + run - 1); pos += 1; run = 0 end
		local hash = (r * 3 + g * 5 + b * 7 + a * 11) % 64
		if index[hash * 4 + 1] == r and index[hash * 4 + 2] == g and index[hash * 4 + 3] == b and index[hash * 4 + 4] == a then
			buffer.writeu8(out, pos, hash); pos += 1
		else
			index[hash * 4 + 1], index[hash * 4 + 2], index[hash * 4 + 3], index[hash * 4 + 4] = r, g, b, a
			local dr, dg, db = (r - pr + 128) % 256 - 128, (g - pg + 128) % 256 - 128, (b - pb + 128) % 256 - 128
			if a ~= pa then buffer.writeu8(out, pos, 0xFF); buffer.writeu8(out, pos + 1, r); buffer.writeu8(out, pos + 2, g); buffer.writeu8(out, pos + 3, b); buffer.writeu8(out, pos + 4, a); pos += 5
			elseif dr >= -2 and dr <= 1 and dg >= -2 and dg <= 1 and db >= -2 and db <= 1 then buffer.writeu8(out, pos, bit32.bor(0x40, bit32.lshift(dr + 2, 4), bit32.lshift(dg + 2, 2), db + 2)); pos += 1
			elseif dg >= -32 and dg <= 31 and dr - dg >= -8 and dr - dg <= 7 and db - dg >= -8 and db - dg <= 7 then buffer.writeu8(out, pos, 0x80 + dg + 32); buffer.writeu8(out, pos + 1, bit32.bor(bit32.lshift(dr - dg + 8, 4), db - dg + 8)); pos += 2
			else buffer.writeu8(out, pos, 0xFE); buffer.writeu8(out, pos + 1, r); buffer.writeu8(out, pos + 2, g); buffer.writeu8(out, pos + 3, b); pos += 4 end
		end
		pr, pg, pb, pa = r, g, b, a
	end
	buffer.writestring(out, pos, "\0\0\0\0\0\0\0\1")
	return out, pos + 8
end
function BenchApps.markdown(src: string)
	local blocks, para = {}, {}
	local function flush() if #para > 0 then blocks[#blocks + 1] = { kind = "p", text = table.concat(para, " ") }; table.clear(para) end end
	local inCode, code = false, {}
	for line in (src .. "\n"):gmatch("(.-)\n") do
		if line:match("^```") then
			if inCode then blocks[#blocks + 1] = { kind = "code", text = table.concat(code, "\n") }; table.clear(code) end
			inCode = not inCode
		elseif inCode then code[#code + 1] = line
		elseif line:match("^%s*$") then flush()
		elseif line:match("^#+%s") then flush(); local hashes, text = line:match("^(#+)%s+(.*)$"); blocks[#blocks + 1] = { kind = "h" .. #hashes, text = text }
		elseif line:match("^%s*[-*+]%s") then flush(); blocks[#blocks + 1] = { kind = "li", text = line:gsub("^%s*[-*+]%s+", "") }
		elseif line:match("^>") then flush(); blocks[#blocks + 1] = { kind = "quote", text = line:sub(2) }
		else para[#para + 1] = line end
	end
	flush()
	local function inline(s)
		s = s:gsub("&", "&amp;"):gsub("<", "&lt;")
		s = s:gsub("`([^`]+)`", "<code>%1</code>")
		s = s:gsub("%*%*(.-)%*%*", "<b>%1</b>"):gsub("%*(.-)%*", "<i>%1</i>")
		s = s:gsub("%[(.-)%]%((.-)%)", function(text, url) return `<a href="{url}">{text}</a>` end)
		return s
	end
	local html = {}
	for _, b in ipairs(blocks) do
		html[#html + 1] = if b.kind == "code" then `<pre>{b.text}</pre>` elseif b.kind == "li" then `<li>{inline(b.text)}</li>` else `<{b.kind}>{inline(b.text)}</{b.kind}>`
	end
	return table.concat(html, "\n")
end
function BenchApps.neural(input, weights, biases, target, lr)
	local function matvec(w, x, b) local out = table.create(#w, 0) for i = 1, #w do local s = b[i] for j = 1, #x do s += w[i][j] * x[j] end out[i] = s end return out end
	local function relu(v) local o = {} for i, x in v do o[i] = if x > 0 then x else 0 end return o end
	local function softmax(v) local m = math.max(table.unpack(v)) local e, sum = {}, 0 for i, x in v do e[i] = math.exp(x - m); sum += e[i] end for i in e do e[i] /= sum end return e end
	local acts = { input }
	for l = 1, #weights do
		local z = matvec(weights[l], acts[l], biases[l])
		acts[l + 1] = if l == #weights then softmax(z) else relu(z)
	end
	local delta = {}
	for i, p in acts[#acts] do delta[i] = p - (target[i] or 0) end
	for l = #weights, 1, -1 do
		local prev, w = acts[l], weights[l]
		local nextDelta = table.create(#prev, 0)
		for i = 1, #w do
			for j = 1, #prev do nextDelta[j] += w[i][j] * delta[i]; w[i][j] -= lr * delta[i] * prev[j] end
			biases[l][i] -= lr * delta[i]
		end
		for j, v in prev do if v <= 0 then nextDelta[j] = 0 end end
		delta = nextDelta
	end
	local loss = 0
	for i, p in acts[#acts] do loss -= (target[i] or 0) * math.log(p + 1e-12) end
	return loss, acts[#acts]
end
function BenchApps.erosion(height: { number }, w: number, h: number, drops: number, rand)
	local function idx(x, y) return y * w + x + 1 end
	for _ = 1, drops do
		local x, y, dx, dy, speed, water, sediment = rand() * (w - 2), rand() * (h - 2), 0, 0, 1, 1, 0
		for _ = 1, 30 do
			local ix, iy = x // 1, y // 1
			local fx, fy = x - ix, y - iy
			local h00, h10, h01, h11 = height[idx(ix, iy)], height[idx(ix + 1, iy)], height[idx(ix, iy + 1)], height[idx(ix + 1, iy + 1)]
			local gx, gy = (h10 - h00) * (1 - fy) + (h11 - h01) * fy, (h01 - h00) * (1 - fx) + (h11 - h10) * fx
			dx, dy = dx * 0.9 - gx * 0.1, dy * 0.9 - gy * 0.1
			local len = math.sqrt(dx * dx + dy * dy)
			if len == 0 then break end
			dx /= len; dy /= len
			local nx, ny = x + dx, y + dy
			if nx < 0 or ny < 0 or nx >= w - 1 or ny >= h - 1 then break end
			local hOld = h00 * (1 - fx) * (1 - fy) + h10 * fx * (1 - fy) + h01 * (1 - fx) * fy + h11 * fx * fy
			local diff = height[idx(nx // 1, ny // 1)] - hOld
			local capacity = math.max(-diff, 0.01) * speed * water * 4
			if sediment > capacity or diff > 0 then
				local deposit = if diff > 0 then math.min(diff, sediment) else (sediment - capacity) * 0.3
				sediment -= deposit
				height[idx(ix, iy)] += deposit * (1 - fx) * (1 - fy)
			else
				local erode = math.min((capacity - sediment) * 0.3, -diff)
				sediment += erode
				height[idx(ix, iy)] -= erode
			end
			speed = math.sqrt(math.max(speed * speed + diff * 4, 0)); water *= 0.99
			x, y = nx, ny
		end
	end
	return height
end
function BenchApps.raster(path, w: number, h: number, color: { number })
	local edges = {}
	local function line(x0, y0, x1, y1) if y0 ~= y1 then edges[#edges + 1] = if y0 < y1 then { x0, y0, x1, y1, 1 } else { x1, y1, x0, y0, -1 } end end
	local function cubic(x0, y0, x1, y1, x2, y2, x3, y3, depth)
		local flat = math.abs(x0 + x2 - 2 * x1) + math.abs(y0 + y2 - 2 * y1) + math.abs(x1 + x3 - 2 * x2) + math.abs(y1 + y3 - 2 * y2)
		if depth > 8 or flat < 0.25 then line(x0, y0, x3, y3); return end
		local ax, ay, bx, by, cx, cy = (x0 + x1) / 2, (y0 + y1) / 2, (x1 + x2) / 2, (y1 + y2) / 2, (x2 + x3) / 2, (y2 + y3) / 2
		local dx, dy, ex, ey = (ax + bx) / 2, (ay + by) / 2, (bx + cx) / 2, (by + cy) / 2
		local mx, my = (dx + ex) / 2, (dy + ey) / 2
		cubic(x0, y0, ax, ay, dx, dy, mx, my, depth + 1); cubic(mx, my, ex, ey, cx, cy, x3, y3, depth + 1)
	end
	local px, py, sx, sy = 0, 0, 0, 0
	for _, cmd in ipairs(path) do
		local op = cmd[1]
		if op == "M" then px, py, sx, sy = cmd[2], cmd[3], cmd[2], cmd[3]
		elseif op == "L" then line(px, py, cmd[2], cmd[3]); px, py = cmd[2], cmd[3]
		elseif op == "C" then cubic(px, py, cmd[2], cmd[3], cmd[4], cmd[5], cmd[6], cmd[7], 0); px, py = cmd[6], cmd[7]
		elseif op == "Z" then line(px, py, sx, sy); px, py = sx, sy end
	end
	local img = buffer.create(w * h * 4)
	for y = 0, h - 1 do
		local scan, xs = y + 0.5, {}
		for _, e in edges do if scan >= e[2] and scan < e[4] then xs[#xs + 1] = { e[1] + (scan - e[2]) * (e[3] - e[1]) / (e[4] - e[2]), e[5] } end end
		table.sort(xs, function(a, b) return a[1] < b[1] end)
		local winding = 0
		for i = 1, #xs - 1 do
			winding += xs[i][2]
			if winding ~= 0 then
				for x = math.max(0, math.ceil(xs[i][1] - 0.5)), math.min(w - 1, math.floor(xs[i + 1][1] - 0.5)) do
					local o = (y * w + x) * 4
					local da, sa = buffer.readu8(img, o + 3) / 255, color[4] / 255
					local oa = sa + da * (1 - sa)
					for c = 0, 2 do buffer.writeu8(img, o + c, math.floor((color[c + 1] * sa + buffer.readu8(img, o + c) * da * (1 - sa)) / math.max(oa, 1e-9) + 0.5)) end
					buffer.writeu8(img, o + 3, math.floor(oa * 255 + 0.5))
				end
			end
		end
	end
	return img, #edges
end
function BenchApps.assembler(src: string)
	local REG = { rax = 0, rcx = 1, rdx = 2, rbx = 3, rsp = 4, rbp = 5, rsi = 6, rdi = 7 }
	local out, at, labels, fixups = buffer.create(4096), 0, {}, {}
	local function byte(b) buffer.writeu8(out, at, bit32.band(b, 0xFF)); at += 1 end
	local function imm32(v) buffer.writei32(out, at, v); at += 4 end
	local function modrm(mod, reg, rm) byte(bit32.bor(bit32.lshift(mod, 6), bit32.lshift(reg, 3), rm)) end
	for line in src:gmatch("[^\n]+") do
		line = line:gsub(";.*", ""):match("^%s*(.-)%s*$")
		if line == "" then continue end
		local label = line:match("^([%w_]+):$")
		if label then labels[label] = at; continue end
		local op, a, b = line:match("^(%a+)%s*([^,]*),?%s*(.*)$")
		if op == "mov" and REG[a] and REG[b] then byte(0x48); byte(0x89); modrm(3, REG[b], REG[a])
		elseif op == "mov" and REG[a] then byte(0x48); byte(0xC7); modrm(3, 0, REG[a]); imm32(tonumber(b) or 0)
		elseif op == "add" or op == "sub" or op == "xor" or op == "cmp" then
			local ext = ({ add = 0, sub = 5, xor = 6, cmp = 7 })[op]
			if REG[b] then byte(0x48); byte(({ add = 0x01, sub = 0x29, xor = 0x31, cmp = 0x39 })[op]); modrm(3, REG[b], REG[a])
			else byte(0x48); byte(0x81); modrm(3, ext, REG[a]); imm32(tonumber(b) or 0) end
		elseif op == "jmp" or op == "jne" or op == "je" then
			if op == "jmp" then byte(0xE9) else byte(0x0F); byte(if op == "je" then 0x84 else 0x85) end
			fixups[#fixups + 1] = { at = at, label = a }; imm32(0)
		elseif op == "ret" then byte(0xC3)
		elseif op == "push" then byte(0x50 + REG[a])
		elseif op == "pop" then byte(0x58 + REG[a])
		else error(`unknown instruction {op}`) end
	end
	for _, f in fixups do buffer.writei32(out, f.at, (labels[f.label] or error(`no label {f.label}`)) - (f.at + 4)) end
	return out, at
end
function BenchApps.regalloc(intervals, k)
	table.sort(intervals, function(a, b) return a.start < b.start end)
	local active, free, spills = {}, {}, 0
	for r = k, 1, -1 do free[#free + 1] = r end
	for _, iv in ipairs(intervals) do
		for i = #active, 1, -1 do
			if active[i].stop < iv.start then free[#free + 1] = active[i].reg; table.remove(active, i) end
		end
		if #free == 0 then
			local victim = active[#active]
			if victim.stop > iv.stop then iv.reg, victim.reg, victim.spilled = victim.reg, nil, true; active[#active] = iv
			else iv.spilled = true end
			spills += 1
		else
			iv.reg = table.remove(free)
			active[#active + 1] = iv
		end
		table.sort(active, function(a, b) return a.stop < b.stop end)
	end
	return intervals, spills
end
function BenchApps.emulator(mem: buffer, steps: number)
	local reg = table.create(32, 0)
	local pc = 0
	for _ = 1, steps do
		local ins = buffer.readu32(mem, pc)
		local opcode, rd, f3, rs1, rs2, f7 = bit32.band(ins, 0x7F), bit32.extract(ins, 7, 5), bit32.extract(ins, 12, 3), bit32.extract(ins, 15, 5), bit32.extract(ins, 20, 5), bit32.extract(ins, 25, 7)
		local immI = bit32.arshift(ins, 20)
		local nextpc = pc + 4
		if opcode == 0x13 then
			local a = reg[rs1 + 1]
			reg[rd + 1] = if f3 == 0 then a + immI elseif f3 == 4 then bit32.bxor(a, immI) elseif f3 == 6 then bit32.bor(a, immI) elseif f3 == 7 then bit32.band(a, immI) elseif f3 == 1 then bit32.lshift(a, bit32.band(immI, 31)) elseif f3 == 5 then (if f7 == 0x20 then bit32.arshift(a, bit32.band(immI, 31)) else bit32.rshift(a, bit32.band(immI, 31))) else (if a < immI then 1 else 0)
		elseif opcode == 0x33 then
			local a, b = reg[rs1 + 1], reg[rs2 + 1]
			if f7 == 1 then reg[rd + 1] = if f3 == 0 then a * b elseif f3 == 4 then (if b == 0 then -1 else a // b) else (if b == 0 then a else a % b)
			elseif f3 == 0 then reg[rd + 1] = if f7 == 0x20 then a - b else a + b
			elseif f3 == 7 then reg[rd + 1] = bit32.band(a, b)
			elseif f3 == 6 then reg[rd + 1] = bit32.bor(a, b)
			else reg[rd + 1] = bit32.bxor(a, b) end
		elseif opcode == 0x03 then
			reg[rd + 1] = if f3 == 0 then buffer.readi8(mem, reg[rs1 + 1] + immI) elseif f3 == 1 then buffer.readi16(mem, reg[rs1 + 1] + immI) elseif f3 == 4 then buffer.readu8(mem, reg[rs1 + 1] + immI) else buffer.readi32(mem, reg[rs1 + 1] + immI)
		elseif opcode == 0x23 then
			local off = reg[rs1 + 1] + bit32.bor(bit32.lshift(bit32.arshift(ins, 25), 5), rd)
			if f3 == 0 then buffer.writeu8(mem, off, bit32.band(reg[rs2 + 1], 0xFF)) elseif f3 == 1 then buffer.writeu16(mem, off, bit32.band(reg[rs2 + 1], 0xFFFF)) else buffer.writei32(mem, off, reg[rs2 + 1]) end
		elseif opcode == 0x63 then
			local a, b = reg[rs1 + 1], reg[rs2 + 1]
			local take = if f3 == 0 then a == b elseif f3 == 1 then a ~= b elseif f3 == 4 then a < b elseif f3 == 5 then a >= b else bit32.band(a, 0xFFFFFFFF) < bit32.band(b, 0xFFFFFFFF)
			if take then nextpc = pc + bit32.bor(bit32.lshift(bit32.extract(ins, 31, 1), 12), bit32.lshift(bit32.extract(ins, 7, 1), 11), bit32.lshift(bit32.extract(ins, 25, 6), 5), bit32.lshift(bit32.extract(ins, 8, 4), 1)) end
		elseif opcode == 0x6F then reg[rd + 1] = nextpc; nextpc = pc + bit32.arshift(bit32.lshift(bit32.extract(ins, 12, 20), 12), 11)
		elseif opcode == 0x67 then reg[rd + 1] = nextpc; nextpc = bit32.band(reg[rs1 + 1] + immI, bit32.bnot(1))
		elseif opcode == 0x37 then reg[rd + 1] = bit32.band(ins, 0xFFFFF000)
		elseif opcode == 0x73 then
			local num = reg[18]
			if num == 93 then return reg[11], pc elseif num == 64 then Host.write(buffer.readstring(mem, reg[12], reg[13])) end
		else error(string.format("illegal instruction %08x at %x", ins, pc)) end
		reg[1] = 0
		pc = nextpc
	end
	return nil, pc
end
function BenchApps.typeset(words: { string }, width: number, measure: (string) -> number)
	local n = #words
	local widths = table.create(n, 0)
	for i, w in ipairs(words) do widths[i] = measure(w) end
	local space = measure(" ")
	local cost, prev = table.create(n + 1, math.huge), table.create(n + 1, 0)
	cost[1] = 0
	for i = 1, n do
		if cost[i] == math.huge then continue end
		local lineWidth = -space
		for j = i, n do
			lineWidth += widths[j] + space
			if lineWidth > width and j > i then break end
			local slack = width - lineWidth
			local badness = if j == n then 0 else slack * slack * slack
			if cost[i] + badness < cost[j + 1] then cost[j + 1], prev[j + 1] = cost[i] + badness, i end
		end
	end
	local lines, j = {}, n + 1
	while j > 1 do
		local i = prev[j]
		table.insert(lines, 1, table.concat(words, " ", i, j - 1))
		j = i
	end
	return lines, cost[n + 1]
end
function BenchApps.physics(bodies, dt: number, gravity: vector)
	for _, b in bodies do if b.invMass > 0 then b.vel += gravity * dt; b.pos += b.vel * dt end end
	local order = table.clone(bodies)
	table.sort(order, function(a, b) return a.pos.x - a.radius < b.pos.x - b.radius end)
	local contacts = {}
	for i = 1, #order do
		local a = order[i]
		for j = i + 1, #order do
			local b = order[j]
			if b.pos.x - b.radius > a.pos.x + a.radius then break end
			local d = b.pos - a.pos
			local dist = vector.magnitude(d)
			local overlap = a.radius + b.radius - dist
			if overlap > 0 and dist > 0 then contacts[#contacts + 1] = { a = a, b = b, n = d / dist, depth = overlap } end
		end
	end
	for _ = 1, 4 do
		for _, c in contacts do
			local a, b, n = c.a, c.b, c.n
			local rel = vector.dot(b.vel - a.vel, n)
			if rel < 0 then
				local e = math.min(a.restitution, b.restitution)
				local j = -(1 + e) * rel / (a.invMass + b.invMass)
				a.vel -= n * (j * a.invMass); b.vel += n * (j * b.invMass)
			end
			local correction = n * (math.max(c.depth - 0.01, 0) / (a.invMass + b.invMass) * 0.8)
			a.pos -= correction * a.invMass; b.pos += correction * b.invMass
		end
	end
	return #contacts
end
function BenchApps.sql(query: string, tables)
	local tokens = {}
	for word in query:gsub("([(),=<>*])", " %1 "):gmatch("%S+") do tokens[#tokens + 1] = word end
	local pos = 1
	local function peek() return tokens[pos] and tokens[pos]:upper() end
	local function take() pos += 1; return tokens[pos - 1] end
	local function expect(kw) if peek() ~= kw then error(`expected {kw}, got {tokens[pos]}`) end pos += 1 end
	expect("SELECT")
	local columns = {}
	repeat columns[#columns + 1] = take() until peek() ~= "," or not take()
	expect("FROM")
	local source = tables[take()]
	local where
	if peek() == "WHERE" then
		pos += 1
		local col, op, value = take(), take(), take()
		value = tonumber(value) or value:gsub("^'(.*)'$", "%1")
		where = function(row) local v = row[col] return if op == "=" then v == value elseif op == "<" then v < value elseif op == ">" then v > value else v ~= value end
	end
	local groupBy
	if peek() == "GROUP" then pos += 1; expect("BY"); groupBy = take() end
	local rows, groups = {}, {}
	for _, row in ipairs(source) do
		if where and not where(row) then continue end
		if groupBy then
			local key = row[groupBy]
			local g = groups[key]
			if not g then g = { [groupBy] = key, count = 0 }; groups[key] = g; rows[#rows + 1] = g end
			g.count += 1
		else
			local out = {}
			for _, c in columns do if c == "*" then for k, v in row do out[k] = v end else out[c] = row[c] end end
			rows[#rows + 1] = out
		end
	end
	return rows
end
function BenchApps.http(raw: string)
	local headerEnd = raw:find("\r\n\r\n", 1, true)
	if not headerEnd then return nil, "incomplete" end
	local head, body = raw:sub(1, headerEnd - 1), raw:sub(headerEnd + 4)
	local lines = head:split("\r\n")
	local method, target, version = lines[1]:match("^(%u+) (%S+) HTTP/(%d%.%d)$")
	if not method then return nil, "bad request line" end
	local headers = {}
	for i = 2, #lines do
		local name, value = lines[i]:match("^([^:]+):%s*(.-)%s*$")
		if not name then return nil, `bad header {i}` end
		name = name:lower()
		headers[name] = if headers[name] then headers[name] .. ", " .. value else value
	end
	local path, query = target:match("^([^?]*)%??(.*)$")
	local params = {}
	for k, v in query:gmatch("([^&=]+)=([^&]*)") do params[k] = v:gsub("%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end):gsub("%+", " ") end
	if (headers["transfer-encoding"] or ""):lower():find("chunked") then
		local decoded, at = {}, 1
		while true do
			local sizeLine, nextAt = body:match("^(%x+)[^\r]*\r\n()", at)
			if not sizeLine then return nil, "bad chunk" end
			local size = tonumber(sizeLine, 16)
			if size == 0 then break end
			decoded[#decoded + 1] = body:sub(nextAt, nextAt + size - 1)
			at = nextAt + size + 2
		end
		body = table.concat(decoded)
	elseif headers["content-length"] then
		body = body:sub(1, tonumber(headers["content-length"]))
	end
	return { method = method, path = path, version = tonumber(version), headers = headers, params = params, body = body }
end
function BenchApps.vm(code: { number }, consts: { any }, nregs: number)
	local R = table.create(nregs, nil)
	local pc, top = 1, 0
	local handlers = {}
	handlers[0] = function(a, b, c) R[a] = consts[b] end
	handlers[1] = function(a, b, c) R[a] = R[b] + R[c] end
	handlers[2] = function(a, b, c) R[a] = R[b] - R[c] end
	handlers[3] = function(a, b, c) R[a] = R[b] * R[c] end
	handlers[4] = function(a, b, c) if R[a] < R[b] then pc += c end end
	handlers[5] = function(a, b, c) pc += b end
	handlers[6] = function(a, b, c) R[a] = { table.unpack(R, b, c) } end
	handlers[7] = function(a, b, c) R[a] = R[b][R[c]] end
	handlers[8] = function(a, b, c) R[a][R[b]] = R[c] end
	while true do
		local ins = code[pc]
		pc += 1
		local op, a, b, c = bit32.extract(ins, 0, 8), bit32.extract(ins, 8, 8), bit32.extract(ins, 16, 8), bit32.arshift(ins, 24)
		if op == 255 then return table.unpack(R, a, a + b - 1) end
		local h = handlers[op]
		if h then h(a, b, c) else error(`bad opcode {op} at {pc - 1}`) end
		top = math.max(top, a)
	end
end
function BenchApps.raytrace(spheres, w: number, h: number)
	local function build(items, depth)
		if #items <= 2 then return { leaf = items } end
		local axis = depth % 3
		table.sort(items, function(a, b) local pa, pb = a.center, b.center return if axis == 0 then pa.x < pb.x elseif axis == 1 then pa.y < pb.y else pa.z < pb.z end)
		local mid = #items // 2
		local lo, hi = vector.create(math.huge, math.huge, math.huge), vector.create(-math.huge, -math.huge, -math.huge)
		for _, s in items do lo = vector.min(lo, s.center - vector.one * s.radius); hi = vector.max(hi, s.center + vector.one * s.radius) end
		return { lo = lo, hi = hi, build(table.move(items, 1, mid, 1, {}), depth + 1), build(table.move(items, mid + 1, #items, 1, {}), depth + 1) }
	end
	local function hitBox(node, o, inv)
		local t1, t2 = (node.lo - o) * inv, (node.hi - o) * inv
		local tmin, tmax = vector.min(t1, t2), vector.max(t1, t2)
		return math.max(tmin.x, tmin.y, tmin.z) <= math.min(tmax.x, tmax.y, tmax.z)
	end
	local function trace(node, o, d, inv, best, bestT)
		if node.leaf then
			for _, s in node.leaf do
				local oc = o - s.center
				local b, c = vector.dot(oc, d), vector.dot(oc, oc) - s.radius * s.radius
				local disc = b * b - c
				if disc > 0 then local t = -b - math.sqrt(disc) if t > 1e-4 and t < bestT then best, bestT = s, t end end
			end
			return best, bestT
		end
		if not hitBox(node, o, inv) then return best, bestT end
		best, bestT = trace(node[1], o, d, inv, best, bestT)
		return trace(node[2], o, d, inv, best, bestT)
	end
	local root = build(spheres, 0)
	local img, light = buffer.create(w * h), vector.normalize(vector.create(1, 1, -1))
	for y = 0, h - 1 do
		for x = 0, w - 1 do
			local d = vector.normalize(vector.create((x - w / 2) / h, (h / 2 - y) / h, 1))
			local s, t = trace(root, vector.zero, d, vector.one / d, nil, math.huge)
			local shade = 0
			if s then local n = vector.normalize(d * t - s.center) shade = math.max(vector.dot(n, light), 0) * 255 end
			buffer.writeu8(img, y * w + x, shade // 1)
		end
	end
	return img
end
function BenchApps.sat(clauses, nvars)
	local assign, trail = table.create(nvars, 0), {}
	local function value(lit) local v = assign[math.abs(lit)] if v == 0 then return 0 end return if (lit > 0) == (v > 0) then 1 else -1 end
	local function propagate()
		local changed = true
		while changed do
			changed = false
			for _, clause in clauses do
				local unassigned, count, satisfied = nil, 0, false
				for _, lit in clause do
					local v = value(lit)
					if v == 1 then satisfied = true; break elseif v == 0 then count += 1; unassigned = lit end
				end
				if not satisfied then
					if count == 0 then return false end
					if count == 1 then assign[math.abs(unassigned)] = if unassigned > 0 then 1 else -1; trail[#trail + 1] = math.abs(unassigned); changed = true end
				end
			end
		end
		return true
	end
	local function solve()
		local mark = #trail
		if not propagate() then
			for i = #trail, mark + 1, -1 do assign[trail[i]] = 0; trail[i] = nil end
			return false
		end
		local var = table.find(assign, 0)
		if not var then return true end
		for _, choice in { 1, -1 } do
			assign[var] = choice; trail[#trail + 1] = var
			if solve() then return true end
			for i = #trail, mark + 1, -1 do assign[trail[i]] = 0; trail[i] = nil end
		end
		return false
	end
	return solve(), assign
end
function BenchApps.lzma(input: buffer, probs: { number }, outLen: number)
	local range, code, at = 0xFFFFFFFF, 0, 1
	for _ = 1, 4 do code = bit32.bor(bit32.lshift(code, 8), buffer.readu8(input, at)); at += 1 end
	local function bit(p)
		local bound = (range // 2048) * probs[p]
		local b
		if code < bound then range = bound; probs[p] += (2048 - probs[p]) // 32; b = 0
		else range -= bound; code -= bound; probs[p] -= probs[p] // 32; b = 1 end
		if range < 0x1000000 then range = bit32.lshift(range, 8); code = bit32.bor(bit32.lshift(code, 8), buffer.readu8(input, at)); at += 1 end
		return b
	end
	local function tree(base, bits) local m = 1 for _ = 1, bits do m = m * 2 + bit(base + m) end return m - 2 ^ bits end
	local out, prevByte, rep0, pos = buffer.create(outLen), 0, 1, 0
	while pos < outLen do
		if bit(1) == 0 then
			prevByte = tree(2 + prevByte % 3 * 256, 8)
			buffer.writeu8(out, pos, prevByte); pos += 1
		else
			local len = 2 + tree(800, 3)
			if bit(2) == 1 then rep0 = 1 + tree(1000, 6) end
			for _ = 1, len do if pos >= outLen then break end buffer.writeu8(out, pos, buffer.readu8(out, pos - rep0)); pos += 1 end
		end
	end
	return out
end
function BenchApps.git(files, sha1)
	local objects, index = {}, {}
	local function store(kind, data) local body = `{kind} {#data}\0{data}` local id = sha1(body) objects[id] = body return id end
	local entries = {}
	for name, content in files do index[name] = store("blob", content); entries[#entries + 1] = name end
	table.sort(entries)
	local treeParts = {}
	for _, name in entries do treeParts[#treeParts + 1] = `100644 {name}\0{index[name]}` end
	local tree = store("tree", table.concat(treeParts))
	local commit = store("commit", `tree {tree}\nauthor stress <s@s> 0 +0000\n\ninitial\n`)
	local function diff(a, b)
		local la, lb = a:split("\n"), b:split("\n")
		local n, m = #la, #lb
		local dp = {}
		for i = 0, n do dp[i] = table.create(m + 1, 0) end
		for i = n - 1, 0, -1 do for j = m - 1, 0, -1 do dp[i][j + 1] = if la[i + 1] == lb[j + 1] then dp[i + 1][j + 2] + 1 else math.max(dp[i + 1][j + 1], dp[i][j + 2]) end end
		local out, i, j = {}, 0, 0
		while i < n and j < m do
			if la[i + 1] == lb[j + 1] then out[#out + 1] = " " .. la[i + 1]; i += 1; j += 1
			elseif dp[i + 1][j + 1] >= dp[i][j + 2] then out[#out + 1] = "-" .. la[i + 1]; i += 1
			else out[#out + 1] = "+" .. lb[j + 1]; j += 1 end
		end
		while i < n do i += 1; out[#out + 1] = "-" .. la[i] end
		while j < m do j += 1; out[#out + 1] = "+" .. lb[j] end
		return table.concat(out, "\n")
	end
	return commit, tree, objects, diff
end
registry.BenchApps = BenchApps

-- ===== and the rest: shapes none of the sources spell =========================
local Extra = {}
-- a hundred locals, one closure capturing every one of them
function Extra.upvalwall(seed)
	local u1, u2, u3, u4, u5, u6, u7, u8, u9, u10, u11, u12, u13, u14, u15, u16, u17, u18, u19, u20, u21, u22, u23, u24, u25 = Host.many(seed)
	local u26, u27, u28, u29, u30, u31, u32, u33, u34, u35, u36, u37, u38, u39, u40, u41, u42, u43, u44, u45, u46, u47, u48, u49, u50 = Host.many(seed)
	local u51, u52, u53, u54, u55, u56, u57, u58, u59, u60, u61, u62, u63, u64, u65, u66, u67, u68, u69, u70, u71, u72, u73, u74, u75 = Host.many(seed)
	local u76, u77, u78, u79, u80, u81, u82, u83, u84, u85, u86, u87, u88, u89, u90, u91, u92, u93, u94, u95, u96, u97, u98, u99, u100 = Host.many(seed)
	return function()
		u1 = u2 + u3 + u4 + u5 + u6 + u7 + u8 + u9 + u10 + u11 + u12 + u13 + u14 + u15 + u16 + u17 + u18 + u19 + u20 + u21 + u22 + u23 + u24 + u25 + u26 + u27 + u28 + u29 + u30 + u31 + u32 + u33 + u34 + u35 + u36 + u37 + u38 + u39 + u40 + u41 + u42 + u43 + u44 + u45 + u46 + u47 + u48 + u49 + u50
			+ u51 + u52 + u53 + u54 + u55 + u56 + u57 + u58 + u59 + u60 + u61 + u62 + u63 + u64 + u65 + u66 + u67 + u68 + u69 + u70 + u71 + u72 + u73 + u74 + u75 + u76 + u77 + u78 + u79 + u80 + u81 + u82 + u83 + u84 + u85 + u86 + u87 + u88 + u89 + u90 + u91 + u92 + u93 + u94 + u95 + u96 + u97 + u98 + u99 + u100
		u100, u99, u98, u51, u50, u49 = u1, u100, u99, u50, u49, u51
		return u1, u50, u100
	end
end
-- a call two hundred and forty arguments wide, near the register ceiling
function Extra.argwall()
	return Sink(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
		41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80,
		81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120,
		121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160,
		161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200,
		201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240)
end
-- compound assignment whose target index has side effects: each is evaluated once
function Extra.compound(t, f, g)
	t[f()] += 1
	t[f()].x ..= g()
	t[f()][g()] *= 2
	f().x -= 1
	f()[g()] //= 3
	t.a.b[f()] %= 7
	local i = 0
	local function nexti() i += 1; return i end
	t[nexti()], t[nexti()] = nexti(), nexti()
	t[nexti()] = t[nexti()]
	return i, t[1] < t[2] < t[3]
end
-- loops used as gotos, and closures closed on every way out
function Extra.onceloops(a, b, list)
	repeat
		if a then break end
		Sink("not a")
		if b then break end
		Sink("not b")
	until true
	repeat local x = Host.get(); local g = function() return x end until g()
	for i = 1, #list do
		if list[i] == nil then continue end
		local cell = list[i]
		list[i] = function() return cell, i end
		do if cell == a then break end end
	end
	while true do do do break end end end
	for _ = 1, 1 do do continue end end
	return list
end
-- nesting: closures eight deep, parentheses, constructors, indexes, calls and ifs
function Extra.nesting(a)
	local function l1() local x1 = a return function() local x2 = x1 return function() local x3 = x2 return function() local x4 = x3 return function() local x5 = x4 return function() local x6 = x5 return function() local x7 = x6 return function() local x8 = x7 return function() x1 += 1; x4 += 1; x8 += 1 return a, x1, x2, x3, x4, x5, x6, x7, x8 end end end end end end end end end
	local deep = ((((((((((((((((((((a + 1) * 2) - 3) / 4) + 5) * 6) - 7) / 8) + 9) * 10) - 11) / 12) + 13) * 14) - 15) / 16) + 17) * 18) - 19) / 20)
	local nest = { { { { { { { { { { { { { { { { { { { { a } } } } } } } } } } } } } } } } } } } }
	local chain = a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.q.r.s.t.u.v.w.x.y.z
	local calls = a:b():c():d():e():f():g():h():i():j()
	local idx = a[1][2][3][4][5][6][7][8][9][10][11][12]
	if a then if a.b then if a.b.c then if a.b.c.d then if a.b.c.d.e then if a.b.c.d.e.f then if a.b.c.d.e.f.g then Sink("seven deep") end end end end end end end
	return l1()()()()()()()()(), deep, nest, chain, calls, idx
end
-- comments wedged into every gap a statement has
function Extra.comments(a)
	local --[[ before the name ]] x --[=[ between the name and = ]=] = --[==[ after = ]==] a -- trailing
	local y = { --[[ in a constructor ]] 1, --[[ between ]] 2 --[[ before the close ]] }
	return --[[ before the value ]] x + --[[ inside a binary ]] y[1] --[[ after it all ]]
end
-- every byte value, spelled as an escape
function Extra.bytes()
	return "\0\1\2\3\4\5\6\7\8\9\10\11\12\13\14\15\16\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31\32\33\34\35\36\37\38\39\40\41\42\43\44\45\46\47\48\49\50\51\52\53\54\55\56\57\58\59\60\61\62\63\64\65\66\67\68\69\70\71\72\73\74\75\76\77\78\79\80\81\82\83\84\85\86\87\88\89\90\91\92\93\94\95\96\97\98\99\100\101\102\103\104\105\106\107\108\109\110\111\112\113\114\115\116\117\118\119\120\121\122\123\124\125\126\127\128\129\130\131\132\133\134\135\136\137\138\139\140\141\142\143\144\145\146\147\148\149\150\151\152\153\154\155\156\157\158\159\160\161\162\163\164\165\166\167\168\169\170\171\172\173\174\175\176\177\178\179\180\181\182\183\184\185\186\187\188\189\190\191\192\193\194\195\196\197\198\199\200\201\202\203\204\205\206\207\208\209\210\211\212\213\214\215\216\217\218\219\220\221\222\223\224\225\226\227\228\229\230\231\232\233\234\235\236\237\238\239\240\241\242\243\244\245\246\247\248\249\250\251\252\253\254\255"
end
-- builtins shadowed by locals, inside one function only (no global is ever written)
function Extra.shadows(a)
	local print, type, select, pairs, math = Sink, function() return "shadow" end, function(...) return ... end, ipairs, { floor = function(x) return x end }
	for k, v in pairs({ a }) do print(k, v, type(v), select(1, v), math.floor(v)) end
	local function f(f) return f end
	local function g(...) local g = ... return g end
	return f(a), g(a)
end
registry.Extra = Extra

banner("S34 finale")
T("s34.globals-final", GA, GB, GC, GCOUNT, GMULTI, GTAB.slot, GMA, GMB)
T("s34.step-total", STEP)
Sink("DONE steps=" .. STEP)

-- ===== directly at chunk scope: no enclosing function ========================
for i = 1, Host.n do Sink(i, ...) end
for i = 1, 3 do Sink(i) end
for k, v in pairs(Host.t) do Sink(k, v, ...) end
while Host.go do if Host.stop then break end Sink(Host.value) end
repeat local z = Host.step(); Sink(z) until z
if Host.a then Sink(...) elseif Host.b then Sink(select("#", ...)) else Sink((...)) end
while local item = Host.next() do Sink(item, ...) end
while const flag = Host.flag do Sink(flag); break end
if local held = Host.held then Sink(held) elseif const other = Host.other then Sink(other) end
do
	local function scoped(x) return x + 1 end
	local tbl = { ... }
	Sink(scoped(Host.a), scoped(1), tbl, { Host.a, ... }, function() return tbl, chunk_count, Host end)
	tbl[#tbl + 1] = function(...) return ... end
	chunk_count += 1
end
local late_capture = Host.late
Sink(function() late_capture = late_capture + 1; return late_capture, chunk_args end)
global_written_at_chunk, registry.late, Engine.Scene.Late = Host.a, Host.b, Host.c
function global_function_at_chunk(...) return ... end
@checked function checked_global() return 1 end
@deprecated function deprecated_global() return 2 end
@[deprecated{reason = "old"}] function reasoned_global() return 3 end
@native function native_global(n: number) local s = 0 for i = 1, n do s += i end return s end
export local exported_value = Host.export
export const exported_constant = 1
export function exported_function() return exported_value, exported_constant end
Sink(chunk_args, chunk_count, registry, counter, Vec, Class, Dog, Lang, Json, Codec, Algo, Closures, Flow, Places, Calls, Tables, Scope, Bait)
Sink(ConfCore, ConfBind, ConfRun, ConfLib, ConfNative, BenchMicro, BenchClassic, BenchApps, Extra, STEP, T, banner, scrub)

-- ===== forms that were once refused or exploded, pinned at safe sizes =========
do
	local Pins = {}
	function Pins.compound(a, b, c, l)
		if (a and b) or (c and not l) then if a then return 0 end if b then return 0 end end
		if (a and b) or (c and not l) then if a then return 1 end if b then return -1 end end
		if (a and b) or (c and not l) then if a then return 2 end if b then return -2 end end
		if (a and b) or (c and not l) then if a then return 3 end if b then return -3 end end
		if (a and b) or (c and not l) then if a then return 4 end if b then return -4 end end
		if (a and b) or (c and not l) then if a then return 5 end if b then return -5 end end
		if (a and b) or (c and not l) then if a then return 6 end if b then return -6 end end
		if (a and b) or (c and not l) then if a then return 7 end if b then return -7 end end
		return -1
	end
	function Pins.ladder(a, b, sink)
		if a and b then sink(0) elseif a and b then sink(1) elseif a and b then sink(2) elseif a and b then sink(3) elseif a and b then sink(4) elseif a and b then sink(5) elseif a and b then sink(6) elseif a and b then sink(7) elseif a and b then sink(8) elseif a and b then sink(9) elseif a and b then sink(10) elseif a and b then sink(11) elseif a and b then sink(12) elseif a and b then sink(13) elseif a and b then sink(14) elseif a and b then sink(15) end
		sink(99)
	end
	function Pins.valued(a, b, sink)
		local x = if a and b then 0 elseif a and b then 1 elseif a and b then 2 elseif a and b then 3 elseif a and b then 4 elseif a and b then 5 elseif a and b then 6 elseif a and b then 7 elseif a and b then 8 elseif a and b then 9 elseif a and b then 10 elseif a and b then 11 elseif a and b then 12 elseif a and b then 13 elseif a and b then 14 elseif a and b then 15 elseif a and b then 16 elseif a and b then 17 elseif a and b then 18 elseif a and b then 19 elseif a and b then 20 elseif a and b then 21 elseif a and b then 22 elseif a and b then 23 else -1
		sink(x) sink(x) return x
	end
	function Pins.nested(a, b, c, l, sink)
		if (a and b) or (c and not l) then if a then return 0 end if (a and b) or (c and not l) then if a then return 1 end if (a and b) or (c and not l) then if a then return 2 end if (a and b) or (c and not l) then if a then return 3 end if (a and b) or (c and not l) then if a then return 4 end if (a and b) or (c and not l) then if a then return 5 end if (a and b) or (c and not l) then if a then return 6 end if (a and b) or (c and not l) then if a then return 7 end sink(8) sink(7) end sink(6) end sink(5) end sink(4) end sink(3) end sink(2) end sink(1) end sink(0) end
		return -1
	end
	function Pins.breakGeneric(t) for k, v in pairs(t) do break end end
	function Pins.breakNumeric(n) for i = 1, n do break end end
	function Pins.breakIterator(iter, t) for v in iter, t do break end end
	function Pins.breakBranch(t, c, log) if c then for k, v in pairs(t) do break end else log[#log + 1] = "else" end end
	-- 513 names in one function: the last no longer fits GETIMPORT's constant field.
	function Pins.globals() if pin_global_1 and pin_global_2 and pin_global_3 and pin_global_4 and pin_global_5 and pin_global_6 and pin_global_7 and pin_global_8 and pin_global_9 and pin_global_10 and pin_global_11 and pin_global_12 and pin_global_13 and pin_global_14 and pin_global_15 and pin_global_16 and pin_global_17 and pin_global_18 and pin_global_19 and pin_global_20 and pin_global_21 and pin_global_22 and pin_global_23 and pin_global_24 and pin_global_25 and pin_global_26 and pin_global_27 and pin_global_28 and pin_global_29 and pin_global_30 and pin_global_31 and pin_global_32 and pin_global_33 and pin_global_34 and pin_global_35 and pin_global_36 and pin_global_37 and pin_global_38 and pin_global_39 and pin_global_40 and pin_global_41 and pin_global_42 and pin_global_43 and pin_global_44 and pin_global_45 and pin_global_46 and pin_global_47 and pin_global_48 and pin_global_49 and pin_global_50 and pin_global_51 and pin_global_52 and pin_global_53 and pin_global_54 and pin_global_55 and pin_global_56 and pin_global_57 and pin_global_58 and pin_global_59 and pin_global_60 and pin_global_61 and pin_global_62 and pin_global_63 and pin_global_64 and pin_global_65 and pin_global_66 and pin_global_67 and pin_global_68 and pin_global_69 and pin_global_70 and pin_global_71 and pin_global_72 and pin_global_73 and pin_global_74 and pin_global_75 and pin_global_76 and pin_global_77 and pin_global_78 and pin_global_79 and pin_global_80 and pin_global_81 and pin_global_82 and pin_global_83 and pin_global_84 and pin_global_85 and pin_global_86 and pin_global_87 and pin_global_88 and pin_global_89 and pin_global_90 and pin_global_91 and pin_global_92 and pin_global_93 and pin_global_94 and pin_global_95 and pin_global_96 and pin_global_97 and pin_global_98 and pin_global_99 and pin_global_100 and pin_global_101 and pin_global_102 and pin_global_103 and pin_global_104 and pin_global_105 and pin_global_106 and pin_global_107 and pin_global_108 and pin_global_109 and pin_global_110 and pin_global_111 and pin_global_112 and pin_global_113 and pin_global_114 and pin_global_115 and pin_global_116 and pin_global_117 and pin_global_118 and pin_global_119 and pin_global_120 and pin_global_121 and pin_global_122 and pin_global_123 and pin_global_124 and pin_global_125 and pin_global_126 and pin_global_127 and pin_global_128 and pin_global_129 and pin_global_130 and pin_global_131 and pin_global_132 and pin_global_133 and pin_global_134 and pin_global_135 and pin_global_136 and pin_global_137 and pin_global_138 and pin_global_139 and pin_global_140 and pin_global_141 and pin_global_142 and pin_global_143 and pin_global_144 and pin_global_145 and pin_global_146 and pin_global_147 and pin_global_148 and pin_global_149 and pin_global_150 and pin_global_151 and pin_global_152 and pin_global_153 and pin_global_154 and pin_global_155 and pin_global_156 and pin_global_157 and pin_global_158 and pin_global_159 and pin_global_160 and pin_global_161 and pin_global_162 and pin_global_163 and pin_global_164 and pin_global_165 and pin_global_166 and pin_global_167 and pin_global_168 and pin_global_169 and pin_global_170 and pin_global_171 and pin_global_172 and pin_global_173 and pin_global_174 and pin_global_175 and pin_global_176 and pin_global_177 and pin_global_178 and pin_global_179 and pin_global_180 and pin_global_181 and pin_global_182 and pin_global_183 and pin_global_184 and pin_global_185 and pin_global_186 and pin_global_187 and pin_global_188 and pin_global_189 and pin_global_190 and pin_global_191 and pin_global_192 and pin_global_193 and pin_global_194 and pin_global_195 and pin_global_196 and pin_global_197 and pin_global_198 and pin_global_199 and pin_global_200 and pin_global_201 and pin_global_202 and pin_global_203 and pin_global_204 and pin_global_205 and pin_global_206 and pin_global_207 and pin_global_208 and pin_global_209 and pin_global_210 and pin_global_211 and pin_global_212 and pin_global_213 and pin_global_214 and pin_global_215 and pin_global_216 and pin_global_217 and pin_global_218 and pin_global_219 and pin_global_220 and pin_global_221 and pin_global_222 and pin_global_223 and pin_global_224 and pin_global_225 and pin_global_226 and pin_global_227 and pin_global_228 and pin_global_229 and pin_global_230 and pin_global_231 and pin_global_232 and pin_global_233 and pin_global_234 and pin_global_235 and pin_global_236 and pin_global_237 and pin_global_238 and pin_global_239 and pin_global_240 and pin_global_241 and pin_global_242 and pin_global_243 and pin_global_244 and pin_global_245 and pin_global_246 and pin_global_247 and pin_global_248 and pin_global_249 and pin_global_250 and pin_global_251 and pin_global_252 and pin_global_253 and pin_global_254 and pin_global_255 and pin_global_256 and pin_global_257 and pin_global_258 and pin_global_259 and pin_global_260 and pin_global_261 and pin_global_262 and pin_global_263 and pin_global_264 and pin_global_265 and pin_global_266 and pin_global_267 and pin_global_268 and pin_global_269 and pin_global_270 and pin_global_271 and pin_global_272 and pin_global_273 and pin_global_274 and pin_global_275 and pin_global_276 and pin_global_277 and pin_global_278 and pin_global_279 and pin_global_280 and pin_global_281 and pin_global_282 and pin_global_283 and pin_global_284 and pin_global_285 and pin_global_286 and pin_global_287 and pin_global_288 and pin_global_289 and pin_global_290 and pin_global_291 and pin_global_292 and pin_global_293 and pin_global_294 and pin_global_295 and pin_global_296 and pin_global_297 and pin_global_298 and pin_global_299 and pin_global_300 and pin_global_301 and pin_global_302 and pin_global_303 and pin_global_304 and pin_global_305 and pin_global_306 and pin_global_307 and pin_global_308 and pin_global_309 and pin_global_310 and pin_global_311 and pin_global_312 and pin_global_313 and pin_global_314 and pin_global_315 and pin_global_316 and pin_global_317 and pin_global_318 and pin_global_319 and pin_global_320 and pin_global_321 and pin_global_322 and pin_global_323 and pin_global_324 and pin_global_325 and pin_global_326 and pin_global_327 and pin_global_328 and pin_global_329 and pin_global_330 and pin_global_331 and pin_global_332 and pin_global_333 and pin_global_334 and pin_global_335 and pin_global_336 and pin_global_337 and pin_global_338 and pin_global_339 and pin_global_340 and pin_global_341 and pin_global_342 and pin_global_343 and pin_global_344 and pin_global_345 and pin_global_346 and pin_global_347 and pin_global_348 and pin_global_349 and pin_global_350 and pin_global_351 and pin_global_352 and pin_global_353 and pin_global_354 and pin_global_355 and pin_global_356 and pin_global_357 and pin_global_358 and pin_global_359 and pin_global_360 and pin_global_361 and pin_global_362 and pin_global_363 and pin_global_364 and pin_global_365 and pin_global_366 and pin_global_367 and pin_global_368 and pin_global_369 and pin_global_370 and pin_global_371 and pin_global_372 and pin_global_373 and pin_global_374 and pin_global_375 and pin_global_376 and pin_global_377 and pin_global_378 and pin_global_379 and pin_global_380 and pin_global_381 and pin_global_382 and pin_global_383 and pin_global_384 and pin_global_385 and pin_global_386 and pin_global_387 and pin_global_388 and pin_global_389 and pin_global_390 and pin_global_391 and pin_global_392 and pin_global_393 and pin_global_394 and pin_global_395 and pin_global_396 and pin_global_397 and pin_global_398 and pin_global_399 and pin_global_400 and pin_global_401 and pin_global_402 and pin_global_403 and pin_global_404 and pin_global_405 and pin_global_406 and pin_global_407 and pin_global_408 and pin_global_409 and pin_global_410 and pin_global_411 and pin_global_412 and pin_global_413 and pin_global_414 and pin_global_415 and pin_global_416 and pin_global_417 and pin_global_418 and pin_global_419 and pin_global_420 and pin_global_421 and pin_global_422 and pin_global_423 and pin_global_424 and pin_global_425 and pin_global_426 and pin_global_427 and pin_global_428 and pin_global_429 and pin_global_430 and pin_global_431 and pin_global_432 and pin_global_433 and pin_global_434 and pin_global_435 and pin_global_436 and pin_global_437 and pin_global_438 and pin_global_439 and pin_global_440 and pin_global_441 and pin_global_442 and pin_global_443 and pin_global_444 and pin_global_445 and pin_global_446 and pin_global_447 and pin_global_448 and pin_global_449 and pin_global_450 and pin_global_451 and pin_global_452 and pin_global_453 and pin_global_454 and pin_global_455 and pin_global_456 and pin_global_457 and pin_global_458 and pin_global_459 and pin_global_460 and pin_global_461 and pin_global_462 and pin_global_463 and pin_global_464 and pin_global_465 and pin_global_466 and pin_global_467 and pin_global_468 and pin_global_469 and pin_global_470 and pin_global_471 and pin_global_472 and pin_global_473 and pin_global_474 and pin_global_475 and pin_global_476 and pin_global_477 and pin_global_478 and pin_global_479 and pin_global_480 and pin_global_481 and pin_global_482 and pin_global_483 and pin_global_484 and pin_global_485 and pin_global_486 and pin_global_487 and pin_global_488 and pin_global_489 and pin_global_490 and pin_global_491 and pin_global_492 and pin_global_493 and pin_global_494 and pin_global_495 and pin_global_496 and pin_global_497 and pin_global_498 and pin_global_499 and pin_global_500 and pin_global_501 and pin_global_502 and pin_global_503 and pin_global_504 and pin_global_505 and pin_global_506 and pin_global_507 and pin_global_508 and pin_global_509 and pin_global_510 and pin_global_511 and pin_global_512 and pin_global_513 then Sink(1) else Sink(2) end end
	function Pins.chain(a, b, c)
		local x = a and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b
		return x
	end
	function Pins.whileseq(a, b, c, l, sink)
		while sink() do
			if (a and b) or (c and not l) then if a then continue end if b then sink(0) end end
			if (a and b) or (c and not l) then if a then continue end if b then sink(1) end end
			if (a and b) or (c and not l) then if a then continue end if b then sink(2) end end
			if (a and b) or (c and not l) then if a then continue end if b then sink(3) end end
			if (a and b) or (c and not l) then if a then continue end if b then sink(4) end end
			if (a and b) or (c and not l) then if a then continue end if b then sink(5) end end
		end
	end
	function Pins.pairs(sink)
		if (Host.a and Host.b) or (Host.c and Host.d) or (Host.e and Host.f) or (Host.g and Host.h) or (Host.i and Host.j) or (Host.k and Host.l) or (Host.m and Host.n) or (Host.o and Host.p) then sink(1) end
	end
	function Pins.callchain(a, b, c, g, h)
		if (c or g(a)) and (b or h(c)) and (c or g(b)) and (b or h(a)) then return g(1) end
		return (c or g(a)) and (b or h(c)) and (c or g(b)) and (b or h(a)) and g(2)
	end
	Sink(Pins, function(Sink)
	local function chain100(a, b, c)
		local x = a and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b
		return x
	end
	local function guarded(a, b, c, d, g, h)
		if (c or g(a)) and (d or h(b)) and (a or g(b)) and b or a then return 1 else return 2 end
	end
	local function guardedloop(a, b, c, d, g, h, sink)
		for i = 1, 3 do
			if (c or g(i)) and (d or h(i)) and (a or g(b)) and b or a then continue end
			if i == 2 then break end
			sink(i)
		end
	end
	local function choice(a, b, c, d, g, h)
		return (c or g(a)) and (d or h(b)) and a or b
	end
	local function choicelocal(a, b, c, d, g, h)
		local x = (c or g(a)) and (d or h(b)) and (a or g(b)) and b or a
		g(x)
		return x
	end
	local function multientry(a, b, c, d, g, h)
		local x = (((c or g(1)) and (d or h(0)) or (a or g(0))) and (d or h(1)) or (a or g(1))) and b or a
		return x
	end
	local function multientry4(a, b, c, d, g, h)
		local x = ((((((c or g(1)) and (d or h(0)) or (a or g(0))) and (d or h(1)) or (a or g(1))) and (d or h(2)) or (a or g(2))) and (d or h(3)) or (a or g(3)))) and b or a
		return x
	end
	local function multientryloop(a, b, c, d, g, h, sink)
		for i = 1, 3 do
			local x = (((c or g(1)) and (d or h(0)) or (a or g(0))) and (d or h(1)) or (a or g(1))) and (d or h(2)) or (a or g(2))
			x = x and b or a
			if x then sink(i) else break end
			if i == 2 then continue end
			sink(x)
		end
	end
	local function ifchain(a, b, c, sink)
		if a and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b then sink(1) end
	end
	local function ifchainelse(a, b, c, sink)
		if a and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b and (c or a[3]) and b then sink(1) else sink(2) end
	end
	local function manypairs(g, sink)
		if (g[1] and g[2]) or (g[3] and g[4]) or (g[5] and g[6]) or (g[7] and g[8]) or (g[9] and g[10]) or (g[11] and g[12]) or (g[13] and g[14]) or (g[15] and g[16]) or (g[17] and g[18]) or (g[19] and g[20]) or (g[21] and g[22]) or (g[23] and g[24]) or (g[25] and g[26]) or (g[27] and g[28]) or (g[29] and g[30]) or (g[31] and g[32]) or (g[33] and g[34]) or (g[35] and g[36]) or (g[37] and g[38]) or (g[39] and g[40]) or (g[41] and g[42]) or (g[43] and g[44]) or (g[45] and g[46]) or (g[47] and g[48]) or (g[49] and g[50]) or (g[51] and g[52]) or (g[53] and g[54]) or (g[55] and g[56]) or (g[57] and g[58]) or (g[59] and g[60]) or (g[61] and g[62]) or (g[63] and g[64]) or (g[65] and g[66]) or (g[67] and g[68]) or (g[69] and g[70]) or (g[71] and g[72]) or (g[73] and g[74]) or (g[75] and g[76]) or (g[77] and g[78]) or (g[79] and g[80]) then sink(1) end
	end
	-- More locals than one frame holds at O2: every inlined maker keeps its own
	-- captured local. Multiple assignment and per-iteration captures share the frame.
	local function spilled(p, out)
		local function make(x) return function() x = x + 1 return x end end
		out[#out + 1] = make(p(0)) out[#out + 1] = make(p(1)) out[#out + 1] = make(p(2)) out[#out + 1] = make(p(3)) out[#out + 1] = make(p(4)) out[#out + 1] = make(p(5)) out[#out + 1] = make(p(6)) out[#out + 1] = make(p(7)) out[#out + 1] = make(p(8)) out[#out + 1] = make(p(9)) out[#out + 1] = make(p(10)) out[#out + 1] = make(p(11)) out[#out + 1] = make(p(12)) out[#out + 1] = make(p(13)) out[#out + 1] = make(p(14)) out[#out + 1] = make(p(15)) out[#out + 1] = make(p(16)) out[#out + 1] = make(p(17)) out[#out + 1] = make(p(18)) out[#out + 1] = make(p(19)) out[#out + 1] = make(p(20)) out[#out + 1] = make(p(21)) out[#out + 1] = make(p(22)) out[#out + 1] = make(p(23)) out[#out + 1] = make(p(24)) out[#out + 1] = make(p(25)) out[#out + 1] = make(p(26)) out[#out + 1] = make(p(27)) out[#out + 1] = make(p(28)) out[#out + 1] = make(p(29)) out[#out + 1] = make(p(30)) out[#out + 1] = make(p(31)) out[#out + 1] = make(p(32)) out[#out + 1] = make(p(33)) out[#out + 1] = make(p(34)) out[#out + 1] = make(p(35)) out[#out + 1] = make(p(36)) out[#out + 1] = make(p(37)) out[#out + 1] = make(p(38)) out[#out + 1] = make(p(39)) out[#out + 1] = make(p(40)) out[#out + 1] = make(p(41)) out[#out + 1] = make(p(42)) out[#out + 1] = make(p(43)) out[#out + 1] = make(p(44)) out[#out + 1] = make(p(45)) out[#out + 1] = make(p(46)) out[#out + 1] = make(p(47)) out[#out + 1] = make(p(48)) out[#out + 1] = make(p(49)) out[#out + 1] = make(p(50)) out[#out + 1] = make(p(51)) out[#out + 1] = make(p(52)) out[#out + 1] = make(p(53)) out[#out + 1] = make(p(54)) out[#out + 1] = make(p(55)) out[#out + 1] = make(p(56)) out[#out + 1] = make(p(57)) out[#out + 1] = make(p(58)) out[#out + 1] = make(p(59)) out[#out + 1] = make(p(60)) out[#out + 1] = make(p(61)) out[#out + 1] = make(p(62)) out[#out + 1] = make(p(63)) out[#out + 1] = make(p(64)) out[#out + 1] = make(p(65)) out[#out + 1] = make(p(66)) out[#out + 1] = make(p(67)) out[#out + 1] = make(p(68)) out[#out + 1] = make(p(69)) out[#out + 1] = make(p(70)) out[#out + 1] = make(p(71)) out[#out + 1] = make(p(72)) out[#out + 1] = make(p(73)) out[#out + 1] = make(p(74)) out[#out + 1] = make(p(75)) out[#out + 1] = make(p(76)) out[#out + 1] = make(p(77)) out[#out + 1] = make(p(78)) out[#out + 1] = make(p(79)) out[#out + 1] = make(p(80)) out[#out + 1] = make(p(81)) out[#out + 1] = make(p(82)) out[#out + 1] = make(p(83)) out[#out + 1] = make(p(84)) out[#out + 1] = make(p(85)) out[#out + 1] = make(p(86)) out[#out + 1] = make(p(87)) out[#out + 1] = make(p(88)) out[#out + 1] = make(p(89)) out[#out + 1] = make(p(90)) out[#out + 1] = make(p(91)) out[#out + 1] = make(p(92)) out[#out + 1] = make(p(93)) out[#out + 1] = make(p(94)) out[#out + 1] = make(p(95)) out[#out + 1] = make(p(96)) out[#out + 1] = make(p(97)) out[#out + 1] = make(p(98)) out[#out + 1] = make(p(99)) out[#out + 1] = make(p(100)) out[#out + 1] = make(p(101)) out[#out + 1] = make(p(102)) out[#out + 1] = make(p(103)) out[#out + 1] = make(p(104)) out[#out + 1] = make(p(105)) out[#out + 1] = make(p(106)) out[#out + 1] = make(p(107)) out[#out + 1] = make(p(108)) out[#out + 1] = make(p(109)) out[#out + 1] = make(p(110)) out[#out + 1] = make(p(111)) out[#out + 1] = make(p(112)) out[#out + 1] = make(p(113)) out[#out + 1] = make(p(114)) out[#out + 1] = make(p(115)) out[#out + 1] = make(p(116)) out[#out + 1] = make(p(117)) out[#out + 1] = make(p(118)) out[#out + 1] = make(p(119)) out[#out + 1] = make(p(120)) out[#out + 1] = make(p(121)) out[#out + 1] = make(p(122)) out[#out + 1] = make(p(123)) out[#out + 1] = make(p(124)) out[#out + 1] = make(p(125)) out[#out + 1] = make(p(126)) out[#out + 1] = make(p(127)) out[#out + 1] = make(p(128)) out[#out + 1] = make(p(129)) out[#out + 1] = make(p(130)) out[#out + 1] = make(p(131)) out[#out + 1] = make(p(132)) out[#out + 1] = make(p(133)) out[#out + 1] = make(p(134)) out[#out + 1] = make(p(135)) out[#out + 1] = make(p(136)) out[#out + 1] = make(p(137)) out[#out + 1] = make(p(138)) out[#out + 1] = make(p(139)) out[#out + 1] = make(p(140)) out[#out + 1] = make(p(141)) out[#out + 1] = make(p(142)) out[#out + 1] = make(p(143)) out[#out + 1] = make(p(144)) out[#out + 1] = make(p(145)) out[#out + 1] = make(p(146)) out[#out + 1] = make(p(147)) out[#out + 1] = make(p(148)) out[#out + 1] = make(p(149)) out[#out + 1] = make(p(150)) out[#out + 1] = make(p(151)) out[#out + 1] = make(p(152)) out[#out + 1] = make(p(153)) out[#out + 1] = make(p(154)) out[#out + 1] = make(p(155)) out[#out + 1] = make(p(156)) out[#out + 1] = make(p(157)) out[#out + 1] = make(p(158)) out[#out + 1] = make(p(159)) out[#out + 1] = make(p(160)) out[#out + 1] = make(p(161)) out[#out + 1] = make(p(162)) out[#out + 1] = make(p(163)) out[#out + 1] = make(p(164)) out[#out + 1] = make(p(165)) out[#out + 1] = make(p(166)) out[#out + 1] = make(p(167)) out[#out + 1] = make(p(168)) out[#out + 1] = make(p(169)) out[#out + 1] = make(p(170)) out[#out + 1] = make(p(171)) out[#out + 1] = make(p(172)) out[#out + 1] = make(p(173)) out[#out + 1] = make(p(174)) out[#out + 1] = make(p(175)) out[#out + 1] = make(p(176)) out[#out + 1] = make(p(177)) out[#out + 1] = make(p(178)) out[#out + 1] = make(p(179)) out[#out + 1] = make(p(180)) out[#out + 1] = make(p(181)) out[#out + 1] = make(p(182)) out[#out + 1] = make(p(183)) out[#out + 1] = make(p(184)) out[#out + 1] = make(p(185)) out[#out + 1] = make(p(186)) out[#out + 1] = make(p(187)) out[#out + 1] = make(p(188)) out[#out + 1] = make(p(189)) out[#out + 1] = make(p(190)) out[#out + 1] = make(p(191)) out[#out + 1] = make(p(192)) out[#out + 1] = make(p(193)) out[#out + 1] = make(p(194)) out[#out + 1] = make(p(195)) out[#out + 1] = make(p(196)) out[#out + 1] = make(p(197)) out[#out + 1] = make(p(198)) out[#out + 1] = make(p(199)) out[#out + 1] = make(p(200)) out[#out + 1] = make(p(201)) out[#out + 1] = make(p(202)) out[#out + 1] = make(p(203)) out[#out + 1] = make(p(204))
		local a, b = p(), p()
		local shared = a
		out[#out + 1] = function() shared = shared + b return shared end
		out[#out + 1] = function() shared = shared * 2 return shared end
		a, b = b, a
		return a, b
	end
	local function spilledloop(out)
		local function make(x) return function() x = x + 1 return x end end
		for i = 1, 2 do
			out[#out + 1] = make(i * 0) out[#out + 1] = make(i * 1) out[#out + 1] = make(i * 2) out[#out + 1] = make(i * 3) out[#out + 1] = make(i * 4) out[#out + 1] = make(i * 5) out[#out + 1] = make(i * 6) out[#out + 1] = make(i * 7) out[#out + 1] = make(i * 8) out[#out + 1] = make(i * 9) out[#out + 1] = make(i * 10) out[#out + 1] = make(i * 11) out[#out + 1] = make(i * 12) out[#out + 1] = make(i * 13) out[#out + 1] = make(i * 14) out[#out + 1] = make(i * 15) out[#out + 1] = make(i * 16) out[#out + 1] = make(i * 17) out[#out + 1] = make(i * 18) out[#out + 1] = make(i * 19) out[#out + 1] = make(i * 20) out[#out + 1] = make(i * 21) out[#out + 1] = make(i * 22) out[#out + 1] = make(i * 23) out[#out + 1] = make(i * 24) out[#out + 1] = make(i * 25) out[#out + 1] = make(i * 26) out[#out + 1] = make(i * 27) out[#out + 1] = make(i * 28) out[#out + 1] = make(i * 29) out[#out + 1] = make(i * 30) out[#out + 1] = make(i * 31) out[#out + 1] = make(i * 32) out[#out + 1] = make(i * 33) out[#out + 1] = make(i * 34) out[#out + 1] = make(i * 35) out[#out + 1] = make(i * 36) out[#out + 1] = make(i * 37) out[#out + 1] = make(i * 38) out[#out + 1] = make(i * 39) out[#out + 1] = make(i * 40) out[#out + 1] = make(i * 41) out[#out + 1] = make(i * 42) out[#out + 1] = make(i * 43) out[#out + 1] = make(i * 44) out[#out + 1] = make(i * 45) out[#out + 1] = make(i * 46) out[#out + 1] = make(i * 47) out[#out + 1] = make(i * 48) out[#out + 1] = make(i * 49) out[#out + 1] = make(i * 50) out[#out + 1] = make(i * 51) out[#out + 1] = make(i * 52) out[#out + 1] = make(i * 53) out[#out + 1] = make(i * 54) out[#out + 1] = make(i * 55) out[#out + 1] = make(i * 56) out[#out + 1] = make(i * 57) out[#out + 1] = make(i * 58) out[#out + 1] = make(i * 59) out[#out + 1] = make(i * 60) out[#out + 1] = make(i * 61) out[#out + 1] = make(i * 62) out[#out + 1] = make(i * 63) out[#out + 1] = make(i * 64) out[#out + 1] = make(i * 65) out[#out + 1] = make(i * 66) out[#out + 1] = make(i * 67) out[#out + 1] = make(i * 68) out[#out + 1] = make(i * 69) out[#out + 1] = make(i * 70) out[#out + 1] = make(i * 71) out[#out + 1] = make(i * 72) out[#out + 1] = make(i * 73) out[#out + 1] = make(i * 74) out[#out + 1] = make(i * 75) out[#out + 1] = make(i * 76) out[#out + 1] = make(i * 77) out[#out + 1] = make(i * 78) out[#out + 1] = make(i * 79) out[#out + 1] = make(i * 80) out[#out + 1] = make(i * 81) out[#out + 1] = make(i * 82) out[#out + 1] = make(i * 83) out[#out + 1] = make(i * 84) out[#out + 1] = make(i * 85) out[#out + 1] = make(i * 86) out[#out + 1] = make(i * 87) out[#out + 1] = make(i * 88) out[#out + 1] = make(i * 89) out[#out + 1] = make(i * 90) out[#out + 1] = make(i * 91) out[#out + 1] = make(i * 92) out[#out + 1] = make(i * 93) out[#out + 1] = make(i * 94) out[#out + 1] = make(i * 95) out[#out + 1] = make(i * 96) out[#out + 1] = make(i * 97) out[#out + 1] = make(i * 98) out[#out + 1] = make(i * 99) out[#out + 1] = make(i * 100) out[#out + 1] = make(i * 101) out[#out + 1] = make(i * 102) out[#out + 1] = make(i * 103) out[#out + 1] = make(i * 104) out[#out + 1] = make(i * 105) out[#out + 1] = make(i * 106) out[#out + 1] = make(i * 107) out[#out + 1] = make(i * 108) out[#out + 1] = make(i * 109) out[#out + 1] = make(i * 110) out[#out + 1] = make(i * 111) out[#out + 1] = make(i * 112) out[#out + 1] = make(i * 113) out[#out + 1] = make(i * 114) out[#out + 1] = make(i * 115) out[#out + 1] = make(i * 116) out[#out + 1] = make(i * 117) out[#out + 1] = make(i * 118) out[#out + 1] = make(i * 119) out[#out + 1] = make(i * 120) out[#out + 1] = make(i * 121) out[#out + 1] = make(i * 122) out[#out + 1] = make(i * 123) out[#out + 1] = make(i * 124) out[#out + 1] = make(i * 125) out[#out + 1] = make(i * 126) out[#out + 1] = make(i * 127) out[#out + 1] = make(i * 128) out[#out + 1] = make(i * 129) out[#out + 1] = make(i * 130) out[#out + 1] = make(i * 131) out[#out + 1] = make(i * 132) out[#out + 1] = make(i * 133) out[#out + 1] = make(i * 134) out[#out + 1] = make(i * 135) out[#out + 1] = make(i * 136) out[#out + 1] = make(i * 137) out[#out + 1] = make(i * 138) out[#out + 1] = make(i * 139) out[#out + 1] = make(i * 140) out[#out + 1] = make(i * 141) out[#out + 1] = make(i * 142) out[#out + 1] = make(i * 143) out[#out + 1] = make(i * 144) out[#out + 1] = make(i * 145) out[#out + 1] = make(i * 146) out[#out + 1] = make(i * 147) out[#out + 1] = make(i * 148) out[#out + 1] = make(i * 149) out[#out + 1] = make(i * 150) out[#out + 1] = make(i * 151) out[#out + 1] = make(i * 152) out[#out + 1] = make(i * 153) out[#out + 1] = make(i * 154) out[#out + 1] = make(i * 155) out[#out + 1] = make(i * 156) out[#out + 1] = make(i * 157) out[#out + 1] = make(i * 158) out[#out + 1] = make(i * 159) out[#out + 1] = make(i * 160) out[#out + 1] = make(i * 161) out[#out + 1] = make(i * 162) out[#out + 1] = make(i * 163) out[#out + 1] = make(i * 164) out[#out + 1] = make(i * 165) out[#out + 1] = make(i * 166) out[#out + 1] = make(i * 167) out[#out + 1] = make(i * 168) out[#out + 1] = make(i * 169) out[#out + 1] = make(i * 170) out[#out + 1] = make(i * 171) out[#out + 1] = make(i * 172) out[#out + 1] = make(i * 173) out[#out + 1] = make(i * 174) out[#out + 1] = make(i * 175) out[#out + 1] = make(i * 176) out[#out + 1] = make(i * 177) out[#out + 1] = make(i * 178) out[#out + 1] = make(i * 179) out[#out + 1] = make(i * 180) out[#out + 1] = make(i * 181) out[#out + 1] = make(i * 182) out[#out + 1] = make(i * 183) out[#out + 1] = make(i * 184) out[#out + 1] = make(i * 185) out[#out + 1] = make(i * 186) out[#out + 1] = make(i * 187) out[#out + 1] = make(i * 188) out[#out + 1] = make(i * 189) out[#out + 1] = make(i * 190) out[#out + 1] = make(i * 191) out[#out + 1] = make(i * 192) out[#out + 1] = make(i * 193) out[#out + 1] = make(i * 194) out[#out + 1] = make(i * 195) out[#out + 1] = make(i * 196) out[#out + 1] = make(i * 197) out[#out + 1] = make(i * 198) out[#out + 1] = make(i * 199) out[#out + 1] = make(i * 200) out[#out + 1] = make(i * 201) out[#out + 1] = make(i * 202) out[#out + 1] = make(i * 203) out[#out + 1] = make(i * 204)
		end
	end
	-- A conditional jump to its own fall-through decides nothing.
	local function emptytests(a, b, g, t, sink)
		if a then end
		if g() then end
		if t.x then end
		if a < b then end
		if a or true then sink(1) end
		if a and false then sink(2) end
		local v = t.y
		if v then end
		sink(v)
	end
	-- Sequential guards in one body stay flat, whatever their transfer.
	local function breakguards(g, sink)
		for i = 1, 3 do
			if g(1) then break end
			if g(2) then break end
			if g(3) then break end
			sink(i)
		end
	end
	local function continueguards(g, sink)
		for i = 1, 3 do
			if g(1) then continue end
			if g(2) then continue end
			if g(3) then continue end
			sink(i)
		end
	end
	local function returnguards(g, sink)
		for i = 1, 3 do
			if g(1) then return end
			if g(2) then return end
			if g(3) then return end
			sink(i)
		end
	end
	-- An early return whose suffix ends a loop body spells the guard, not an else.
	local function earlyreturn(t, goal, sink)
		for _, v in ipairs(t) do
			if v == goal then
				sink(v)
				return v
			end
			sink(v + 1)
		end
	end
	local function longchain(a, sink)
		if a == 0 then sink(0)
		elseif a == 1 then sink(1)
		elseif a == 2 then sink(2)
		elseif a == 3 then sink(3)
		elseif a == 4 then sink(4)
		elseif a == 5 then sink(5)
		elseif a == 6 then sink(6)
		elseif a == 7 then sink(7)
		elseif a == 8 then sink(8)
		elseif a == 9 then sink(9)
		elseif a == 10 then sink(10)
		elseif a == 11 then sink(11)
		elseif a == 12 then sink(12)
		elseif a == 13 then sink(13)
		elseif a == 14 then sink(14)
		elseif a == 15 then sink(15)
		elseif a == 16 then sink(16)
		elseif a == 17 then sink(17)
		elseif a == 18 then sink(18)
		elseif a == 19 then sink(19)
		elseif a == 20 then sink(20)
		elseif a == 21 then sink(21)
		elseif a == 22 then sink(22)
		elseif a == 23 then sink(23)
		elseif a == 24 then sink(24)
		elseif a == 25 then sink(25)
		elseif a == 26 then sink(26)
		elseif a == 27 then sink(27)
		elseif a == 28 then sink(28)
		elseif a == 29 then sink(29)
		elseif a == 30 then sink(30)
		elseif a == 31 then sink(31)
		elseif a == 32 then sink(32)
		elseif a == 33 then sink(33)
		elseif a == 34 then sink(34)
		elseif a == 35 then sink(35)
		elseif a == 36 then sink(36)
		elseif a == 37 then sink(37)
		elseif a == 38 then sink(38)
		elseif a == 39 then sink(39)
		end
		sink(-1)
	end
	local function manyguards(g, sink)
		for i = 1, 2 do
			if g(0) then return 0 end
			if g(1) then return 1 end
			if g(2) then return 2 end
			if g(3) then return 3 end
			if g(4) then return 4 end
			if g(5) then return 5 end
			if g(6) then return 6 end
			if g(7) then return 7 end
			if g(8) then return 8 end
			if g(9) then return 9 end
			if g(10) then return 10 end
			if g(11) then return 11 end
			if g(12) then return 12 end
			if g(13) then return 13 end
			if g(14) then return 14 end
			if g(15) then return 15 end
			if g(16) then return 16 end
			if g(17) then return 17 end
			if g(18) then return 18 end
			if g(19) then return 19 end
			if g(20) then return 20 end
			if g(21) then return 21 end
			if g(22) then return 22 end
			if g(23) then return 23 end
			if g(24) then return 24 end
			if g(25) then return 25 end
			if g(26) then return 26 end
			if g(27) then return 27 end
			if g(28) then return 28 end
			if g(29) then return 29 end
			if g(30) then return 30 end
			if g(31) then return 31 end
			if g(32) then return 32 end
			if g(33) then return 33 end
			if g(34) then return 34 end
			if g(35) then return 35 end
			if g(36) then return 36 end
			if g(37) then return 37 end
			if g(38) then return 38 end
			if g(39) then return 39 end
			sink(i)
		end
	end
	local function longand(a, b, sink)
		local x = a and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b
		if a and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b and b then sink(x) end
	end
		Sink(chain100, guarded, guardedloop, choice, choicelocal, multientry, ifchain, multientry4, multientryloop, ifchainelse, manypairs, spilled, spilledloop, emptytests, breakguards, continueguards, returnguards, earlyreturn, longchain, manyguards, longand)
	end)
	-- The inner literal was numbered before PinOwner, but O2 inlines this maker
	-- past it and the folded capture stops the maker being restored.
	local function pinned(x)
		local y = x + 1
		return function() return math.abs(y) end
	end
	function PinOwner() return math.sqrt end
	PinInlined = pinned(1)
end
