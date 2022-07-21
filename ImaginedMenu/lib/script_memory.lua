--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--

local insert = table.insert
local memory = memory
local unpack = unpack

local vector3 = require "vector3"

local s_memory = {}
local to_free = {}

function s_memory.add(key, pointer)
	local bad = {}
	if pointer == 0 then error("Failed to find pattern: "..key, 0) end
	s_memory[key] = pointer
end

local addr = memory.find_pattern("48 8B 05 ? ? ? ? 45 ? ? ? ? 48 8B 48 08 48 85 C9 74 07")
s_memory.add("WorldPtr", memory.read_int64(memory.rip(addr + 3)))
addr = memory.find_pattern("0F 85 ? ? ? ? 48 8B 05 ? ? ? ? 48 8B 48 08 E8")
s_memory.add("BlameExp", addr)
addr = memory.find_pattern("76 03 0F 28 F0 F3 44 0F 10 93")
s_memory.add("RPM", memory.read_int(addr + 10))
s_memory.add("Throttle", memory.read_int(addr + 10) + 0x10)
addr = memory.find_pattern("74 26 0F 57 C9")
s_memory.add("FuelOffset", memory.read_int(addr + 8))
addr = memory.find_pattern("48 8D 8F ? ? ? ? 4C 8B C3 F3 0F 11 7C 24")
s_memory.add("CurrentGear", memory.read_int(addr + 3) + 2)
addr = memory.find_pattern("? 8B 0D ? ? ? ? ? 83 64 ? ? 00 ? 0F B7 D1 ? 33 C9 E8")
s_memory.add("phInstance", memory.rip(addr + 3))
addr = memory.find_pattern("? 63 ? ? ? ? ? 3B ? ? ? ? ? 0F 8D ? ? ? ? ? 8B C8")
s_memory.add("ColliderOffset", addr)

function s_memory.allocate(count)
	count = count or 1
	local output = {}
	for i = 1, count do
		insert(output, s_memory.alloc())
	end
	return unpack(output)
end

function s_memory.alloc(size)
	local ptr = memory.malloc(size or 4)
	insert(to_free, ptr)
	return ptr
end

function s_memory.allocv3()
	local ptr = memory.malloc(24)
	insert(to_free, ptr)
	return ptr
end

function s_memory.readv3(pointer)
	return vector3(memory.read_vector3(pointer))
end

function s_memory.free()
	for _, v in ipairs(to_free)
	do
		memory.free(v)
	end
	to_free = {}
end

function s_memory.get_memory_address(pointer, offsets)
	for i = 1, #offsets - 1
	do
		if not pointer then return 0 end
		pointer = memory.read_int64(pointer + offsets[i])
		if not pointer or pointer == 0 then return 0 end
	end
	return pointer + offsets[#offsets]
end

return s_memory