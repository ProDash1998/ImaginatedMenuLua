--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--

-- Global to local
local require = require
local ipairs = ipairs
local pairs = pairs
local utils = utils
local ENTITY = ENTITY
local ui = ui
local insert = table.insert

local vehicles = require "vehicle"
local peds = require "peds"
local objects = require "props"
local switch = require "switch"
local EntityDb = {}

EntityDb.entity_data = {}
EntityDb.spawned_options = {}

local f = switch()
	:case(1, function(hash)
		local name = cache:get("Name: "..hash)
		if name then return name end
		for _, v in ipairs(peds.models)
		do
			if hash == utils.joaat(v) then
				local name = peds.GetPedName(v) or v
				cache:set("Name: "..hash, name, 100000)
				return name
			end
		end
	end)
	:case(2, function(hash)
		local name = cache:get("Name: "..hash)
		if name then return name end
		local name = vehicles.get_label_name(hash)
		cache:set("Name: "..hash, name, 100000)
		return name
	end)
	:case(3, function(hash)
		local name = cache:get("Name: "..hash)
		if name then return name end
		for _, v in ipairs(objects)
		do
			if hash == utils.joaat(v) then
				local name = v
				cache:set("Name: "..hash, name, 100000)
				return name
			end
		end
	end)

function EntityDb.AddEntityToDatabase(entity)
	if not EntityDb.entity_data[entity] then
		EntityDb.entity_data[entity] = {
			type = ENTITY.GET_ENTITY_TYPE(entity),
			valid = ENTITY.DOES_ENTITY_EXIST(entity),
		}
		local hash = ENTITY.GET_ENTITY_MODEL(entity)

		EntityDb.entity_data[entity].name = f(EntityDb.entity_data[entity].type, hash) or "UNK"
	end
end

function EntityDb.RemoveFromDatabase(entity)
	if not EntityDb.IsEntityInDatabase(entity) then return end
	for _, v in pairs(EntityDb.spawned_options[entity])
	do
		ui.remove(v)
	end
	EntityDb.spawned_options[entity] = nil
	EntityDb.entity_data[entity] = nil
end

function EntityDb.GetEntitiesInDb(no_attachment)
	local entities = {}
	for k, v in pairs(EntityDb.entity_data)
	do
		if v.valid and not (no_attachment and ENTITY.IS_ENTITY_ATTACHED(k) == 1) then
			insert(entities, k)
		end
	end
	return entities
end

function EntityDb.RemoveInvalidEntities()
	for k, v in pairs(EntityDb.entity_data)
	do
		if v.valid == 0 then
			EntityDb.RemoveFromDatabase(k)
		end
	end
end

function EntityDb.IsEntityInDatabase(entity)
	return EntityDb.entity_data[entity] ~= nil
end

function EntityDb.IsEmpty(invalid)
	for _, v in pairs(EntityDb.entity_data)
	do
		if not invalid then
			return false
		elseif invalid and v.valid == 0 then
			return false
		end
	end
	return true
end

return EntityDb