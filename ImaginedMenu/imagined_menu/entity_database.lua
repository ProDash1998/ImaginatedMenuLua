--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--

local vehicles = require "vehicle"
local peds = require "peds"
local objects = require "props"
local EntityDb = {}

EntityDb.entity_data = {}
EntityDb.spawned_options = {}

function EntityDb.AddEntityToDatabase(entity)
	if not EntityDb.entity_data[entity] then
		EntityDb.entity_data[entity] = {
			type = ENTITY.GET_ENTITY_TYPE(entity),
			valid = ENTITY.DOES_ENTITY_EXIST(entity),
		}
		local model = 'NULL'
		local hash = ENTITY.GET_ENTITY_MODEL(entity)
		if EntityDb.entity_data[entity].type == 1 then
			for _, v in ipairs(peds.models)
			do
				if hash == utils.joaat(v) then
					model = v
					break
				end
			end
		elseif EntityDb.entity_data[entity].type == 2 then
			model = vehicles.get_label_name(hash)
		elseif EntityDb.entity_data[entity].type == 3 then
			for _, v in ipairs(objects)
			do
				if hash == utils.joaat(v) then
					model = v
					break
				end
			end
		end
		EntityDb.entity_data[entity].name = model
	end
end

function EntityDb.RemoveFromDatabase(entity)
	for _, v in pairs(EntityDb.spawned_options[entity])
	do
		ui.remove(v)
	end
	EntityDb.spawned_options[entity] = nil
	EntityDb.entity_data[entity] = nil
end

return EntityDb