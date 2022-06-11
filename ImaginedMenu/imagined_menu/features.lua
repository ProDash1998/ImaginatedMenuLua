--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--

local vector3 = require 'vector3'
local enum = require 'enums'
local NULL = 0
local features = {}

math.randomseed(os.time())

local function get_random_args(count)
	local args = {}
	for i = 1, count do
		table.insert(args, math.random(-2147483647, 2147483647))
	end
	return unpack(args)
end

local function models_loaded(hashes)
	for _, hash in ipairs(hashes) do
		STREAMING.REQUEST_MODEL(hash)
		if STREAMING.HAS_MODEL_LOADED(hash) == NULL then 
			return
		end
	end
	return true
end

local function alloc(count)
	local output = {}
	for i = 1, count do
		table.insert(output,memory.malloc(1))
	end
	return unpack(output)
end

function features.to_bool(any)
	if type(any) == 'string' then
		return (any ~= 'false' or any ~= '')
	elseif type(any) == 'number' then
		return (any ~= NULL)
	end
end

function features.get_screen_resolution()
	local px, py = alloc(2)
	GRAPHICS._GET_ACTIVE_SCREEN_RESOLUTION(px, py)
	local res = {x = memory.read_int(px), y = memory.read_int(py)}
	memory.free(px)
	memory.free(py)
	return res
end

function features.get_screen_center()
	local size = features.get_screen_resolution()
	return {x = size.x/2, y = size.y/2}
end

function features.split(str, sep)
   local result = {}
   local regex = ("([^%s]+)"):format(sep)
   for each in str:gmatch(regex) do
      table.insert(result, each)
   end
   return result
end

function features.player_from_name(name)
	if tonumber(name) then
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(tonumber(name)) == 1 then return name end
	end
	local name = name:lower()
	for i = 0, 31 do
		if name == online.get_name(i):lower() then 
			return i
		end
	end
end

function features.request_control_once(ent)
	if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) == 1 then return true end
	NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ent)
	if NETWORK.NETWORK_IS_SESSION_STARTED() == 1 then
		local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(ent)
		NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(netId)
		NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netId, true)
	end
	return (NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(ent) == 1)
end

function features.request_control_of_entities(entities)
	for _, v in ipairs(entities) do
		features.request_control_once(v)
	end
end

function features.get_random_player()
	local players = {}
	for i = 0, 31 do
		if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 then
			table.insert(players, i)
		end
	end
	if #players ~= NULL then return players[math.random(1, #players)] end
	return PLAYER.PLAYER_ID()
end

function features.get_entities()
	local ent = {}
	for _,v in ipairs(entities.get_vehs()) do
		table.insert(ent, v)
	end
	for _,v in ipairs(entities.get_peds()) do
		table.insert(ent, v)
	end
	for _,v in ipairs(entities.get_objects()) do
		table.insert(ent, v)
	end
	return ent
end

function features.get_ground_z(pos)
	local ptr = memory.malloc(1)
	MISC.GET_GROUND_Z_FOR_3D_COORD(pos.x, pos.y, pos.z, ptr, false, false)
	local groundz = memory.read_float(ptr)
	memory.free(ptr)
	return math.floor(groundz)
end

function features.teleport(entity, x, y, z)
	if ENTITY.IS_ENTITY_A_PED(entity) == 1 then
		if PED.IS_PED_IN_ANY_VEHICLE(entity, true) == 1 then
			entity = PED.GET_VEHICLE_PED_IS_IN(entity, false)
		end
	end
	entities.request_control(entity, function()
		ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, x, y, z, false, false, false)
	end)
end

function features.get_blip_objective()
	local blipFound
	local coords
	for i = 0, 1000
	do
		local b = HUD.GET_FIRST_BLIP_INFO_ID(i)
		if HUD.DOES_BLIP_EXIST(b) == 1 then
			local color = HUD.GET_BLIP_COLOUR(b)
			local icon = HUD.GET_BLIP_SPRITE(b)
			if (color == enum.blip_color.YellowMission and icon == enum.blip_sprite.level) or
				(color == enum.blip_color.YellowMission2 and icon == enum.blip_sprite.level) or
				(color == enum.blip_color.Yellow and icon == enum.blip_sprite.level) or
				(color == enum.blip_color.Green and icon == enum.blip_sprite.contraband) or
				(color == enum.blip_color.Blue and icon == enum.blip_sprite.supplies) or
				(color == enum.blip_color.Green and icon == enum.blip_sprite.nhp_bag) or
				(color == enum.blip_color.Blue and icon == enum.blip_sprite.sports_car) or
				(color == enum.blip_color.White and icon == enum.blip_sprite.raceflag) or
				(color == enum.blip_color.Blue and icon == enum.blip_sprite.level) or
				(color == enum.blip_color.Green and icon == enum.blip_sprite.level) --	or
				-- (icon == enum.blip_sprite.cratedrop)
			then
				coords = vector3(HUD.GET_BLIP_INFO_ID_COORD(b))
				blipFound = true
				break
			end
		end
	end
	if blipFound then
		return coords
	end
	return vector3.zero()
end

function features.get_aimed_ped()
	for _, ent in ipairs(entities.get_peds())
	do
		if PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(PLAYER.PLAYER_ID(), ent) == 1 then
			return ent
		end
	end
	return NULL
end

function features.get_aimed_entity()
	for _, ent in ipairs(features.get_entities())
	do
		if PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(PLAYER.PLAYER_ID(), ent) == 1 then
			return ent
		end
	end
	return NULL
end

function features.get_offset_from_player_coords(offvector, player)
	local player = player or PLAYER.PLAYER_ID()
	local offx, offy, offz = offvector:get()
	return ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(player), offx, offy, offz)
end

function features.get_player_coords(player)
	local player = player or PLAYER.PLAYER_ID()
	return ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(player), false)
end

function features.is_friend(pid)
	local ptr = memory.malloc(104)
	NETWORK.NETWORK_HANDLE_FROM_PLAYER(pid, ptr, 13)
	if NETWORK.NETWORK_IS_HANDLE_VALID(ptr, 13) == NULL then memory.free(ptr) return end
	local isfriend = (NETWORK.NETWORK_IS_FRIEND(ptr) == 1)
	memory.free(ptr)
	return isfriend
end

function features.get_entity_proofs(entity)
	local bulletProof, fireProof, explosionProof, collisionProof, meleeProof, steamProof, p7, drownProof = alloc(8)
	ENTITY._GET_ENTITY_PROOFS(entity, bulletProof, fireProof, explosionProof, collisionProof, meleeProof, steamProof, p7, drownProof)
	local proofs = {
		bulletProof 	= features.to_bool(memory.read_byte(bulletProof)),
		fireProof 		= features.to_bool(memory.read_byte(fireProof)),
		explosionProof = features.to_bool(memory.read_byte(explosionProof)),
		collisionProof = features.to_bool(memory.read_byte(collisionProof)),
		meleeProof 		= features.to_bool(memory.read_byte(meleeProof)),
		steamProof 		= features.to_bool(memory.read_byte(steamProof)),
		p7 				= features.to_bool(memory.read_byte(p7)),
		drownProof 		= features.to_bool(memory.read_byte(drownProof))
	}
	memory.free(bulletProof)
	memory.free(fireProof)
	memory.free(explosionProof)
	memory.free(collisionProof)
	memory.free(meleeProof)
	memory.free(steamProof)
	memory.free(p7)
	memory.free(drownProof)
	return proofs
end

function features.delete_entity(entity)
	if ENTITY.DOES_ENTITY_EXIST(entity) == NULL then return end
	ENTITY.SET_ENTITY_COLLISION(entity, false, true) -- crash fix?
	if ENTITY.IS_ENTITY_A_PED(entity) == 1 then
	  TASK.CLEAR_PED_TASKS_IMMEDIATELY(entity)
	end
	entities.request_control(entity, function()
		ENTITY.DETACH_ENTITY(entity, false, false)
		ENTITY.SET_ENTITY_AS_MISSION_ENTITY(entity, true, true)
		ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, 10000, 10000, -100, false, false, false)
		entities.delete(entity)
	end)
	return true
end

function features.unload_models(...)
	for _, v in ipairs({...}) do
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(v)
	end
end

function features.request_model(hashname, loop)
	local hash = 0
	if tonumber(hashname) then 
		hash = tonumber(hashname) 
	else
		hash = utils.joaat(hashname)
	end 
	if STREAMING.IS_MODEL_VALID(hash) == NULL then return hash end
	STREAMING.REQUEST_MODEL(hash)

	local tick = 0

	while loop and (STREAMING.HAS_MODEL_LOADED(hash) == NULL and tick <= 300) do
		tick = tick + 1
		STREAMING.REQUEST_MODEL(hash)
		system.yield(0)
	end

	return STREAMING.HAS_MODEL_LOADED(hash), hash
end

function features.sum_table(array)
	local sum = 0
	for _, v in ipairs(array) do
		sum = sum + v
	end
	return sum
end

function features.crash_player(player)
	if (NETWORK.NETWORK_IS_PLAYER_CONNECTED(player) == NULL) or (player == PLAYER.PLAYER_ID()) then return end

	system.log('Imagined Menu', string.format("Sending crash to %s", online.get_name(player)))
	system.notify('Imagined Menu', string.format(TRANSLATION["Sending crash to %s"], online.get_name(player)), 255, 50, 0, 255)

	online.send_script_event(player, 2908956942, get_random_args(15))
	online.send_script_event(player, 962740265, get_random_args(15))
	online.send_script_event(player, -1386010354, get_random_args(15))
	online.send_script_event(player, -1970125962, get_random_args(15))
	online.send_script_event(player, -1767058336, get_random_args(15))
	online.send_script_event(player, 1757755807, get_random_args(15))
end

function features.kick_player(player)
	if (NETWORK.NETWORK_IS_PLAYER_CONNECTED(player) == NULL) or (player == PLAYER.PLAYER_ID()) then return end

	system.log('Imagined Menu', string.format("Kicking %s", online.get_name(player)))
	system.notify('Imagined Menu', string.format(TRANSLATION["Kicking %s"], online.get_name(player)), 255, 50, 0, 255)

	if NETWORK.NETWORK_IS_HOST() == 1 then
		NETWORK.NETWORK_SESSION_KICK_PLAYER(player)
	else
		online.send_script_event(player, 1228916411, player, globals.get_int(1893551 + (1 + (player * 599) + 510)))

		online.send_script_event(player, 927169576, get_random_args(15))
		online.send_script_event(player, -1308840134, get_random_args(15))
		online.send_script_event(player, 436475575, get_random_args(15))
		online.send_script_event(player, -290218924, get_random_args(15))
		online.send_script_event(player, -368423380, get_random_args(15))
		online.send_script_event(player, -614457627, get_random_args(15))
		online.send_script_event(player, -1991317864, get_random_args(15))
		online.send_script_event(player, 163598572, player, 0, 30583, 0, 0, 0, -328966, 2098891836, 0)
		online.send_script_event(player, 998716537, player, 1, -1)

		online.send_script_event(player, 603406648, math.random(32, 2147483647), math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647))
		online.send_script_event(player, 603406648, math.random(-2147483647, -1), math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647))
	end
end

return features