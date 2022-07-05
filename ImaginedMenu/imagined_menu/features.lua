--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--

local vector3 = require 'vector3'
local enum = require 'enums'
local NULL = 0
local features = {}
features.player_excludes = {}

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

function features.to_clipboard(text)
	local Popen
	CreateRemoveThread(true, 'copy_clipboard_'..thread_count, function(tick)
		if tick == 0 then
			Popen = io.popen('echo '..text..'|clip')
		elseif tick == 15 then
			Popen:close()
		end
	end)
end

function features.from_clipboard(tabl)
	local Popen
	CreateRemoveThread(true, 'from_clipboard_'..thread_count, function(tick)
		if tick == 0 then
			Popen = io.popen('powershell -command "Get-Clipboard"')
		elseif tick == 30 then
			tabl.output = Popen:read()
		end
	end)
end

function features.lshift(x, by)
  return math.floor(x * 2 ^ by)
end

function features.rshift(x, by)
  return math.floor(x / 2 ^ by)
end

local OR, XOR, AND = 1, 3, 4
local function bitoper(a, b, oper)
   local r, m, s = 0, math.pow(31, 2)
   repeat
      s, a, b = a + b + m, a % m, b % m
      r, m = r + m * oper % (s - a - b), m / 2
   until m < 1
   return math.floor(r)
end

function features.OR(a,b)
	return bitoper(a, b, OR)
end

function features.XOR(a,b)
	return bitoper(a, b, XOR)
end

function features.AND(a, b)
    local result = 0
    local bitval = 1
    while a > 0 and b > 0 do
      if a % 2 == 1 and b % 2 == 1 then -- test the rightmost bits
          result = result + bitval      -- set the current bit
      end
      bitval = bitval * 2 -- shift left
      a = math.floor(a/2) -- shift right
      b = math.floor(b/2)
    end
    return result
end

function features.get_screen_resolution()
	local px, py = alloc(2)
	GRAPHICS._GET_ACTIVE_SCREEN_RESOLUTION(px, py)
	local res = vector3(memory.read_int(px), memory.read_int(py))
	memory.free(px)
	memory.free(py)
	return res
end

function features.get_screen_center()
	local size = features.get_screen_resolution()
	return vector3({x = size.x/2, y = size.y/2})
end

function features.world_to_screen(pos)
	local screenX = memory.malloc(4)
	local screenY = memory.malloc(4)
	WORLD.GET_SCREEN_COORD_FROM_WORLD_COORD(pos.x, pos.y, pos.z, screenX, screenY)
	local vec2 = {
		x = memory.read_float(screenX),
		y = memory.read_float(screenY)
	}
	memory.free(screenX)
	memory.free(screenY)
	return vec2
end

function features.get_memory_address(pointer, offsets)
	for i = 1, #offsets - 1
	do
		pointer = memory.read_int64(pointer + offsets[i])
		if pointer == 0 then return 0 end
	end
	return pointer + offsets[#offsets]
end

function features.world_to_screen(pos)
	local screenX, screenY = memory.malloc(48), memory.malloc(48)
	GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(pos.x, pos.y, pos.z, screenX, screenY)
	local result = {
		x = memory.read_float(screenX),
		y = memory.read_float(screenY)
	}
	memory.free(screenX)
	memory.free(screenY)
	return vector3(result)
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
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(tonumber(name)) == 1 then return tonumber(name) end
	end
	local name = name:lower()
	for i = 0, 31 do
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(tonumber(i)) == 1 and name == online.get_name(i):lower() then 
			return i
		end
	end
	for i = 0, 31 do
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(tonumber(i)) == 1 and online.get_name(i):lower():find(name) then 
			return i
		end
	end
end

function features.player_ped(player)
	player = player or PLAYER.PLAYER_ID()
	return PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player)
end

function features.remove_god(player)
	online.send_script_event(player, 801199324, PLAYER.PLAYER_ID(), 869796886, 0)
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

function features.draw_box_on_entity(entity, r, g, b, a)
	local r, g, b, a = r or 255, g or 255, b or 255, a or 255
	local vec_min, vec_max = features.get_model_dimentions(ENTITY.GET_ENTITY_MODEL(entity))
	local off_min = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_min.y, vec_min.z)
	local off_max = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_min.y, vec_max.z)
	GRAPHICS.DRAW_LINE(off_min.x, off_min.y, off_min.z, off_max.x, off_max.y, off_max.z, r, g, b, a)
	local off_min = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_min.y, vec_min.z)
	local off_max = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_min.y, vec_min.z)
	GRAPHICS.DRAW_LINE(off_min.x, off_min.y, off_min.z, off_max.x, off_max.y, off_max.z, r, g, b, a)
	local off_min = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_min.y, vec_min.z)
	local off_max = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_max.y, vec_min.z)
	GRAPHICS.DRAW_LINE(off_min.x, off_min.y, off_min.z, off_max.x, off_max.y, off_max.z, r, g, b, a)
	local off_min = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_min.y, vec_max.z)
	local off_max = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_min.y, vec_max.z)
	GRAPHICS.DRAW_LINE(off_min.x, off_min.y, off_min.z, off_max.x, off_max.y, off_max.z, r, g, b, a)
	local off_min = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_min.y, vec_max.z)
	local off_max = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_max.y, vec_max.z)
	GRAPHICS.DRAW_LINE(off_min.x, off_min.y, off_min.z, off_max.x, off_max.y, off_max.z, r, g, b, a)
	local off_min = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_max.y, vec_min.z)
	local off_max = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_max.y, vec_max.z)
	GRAPHICS.DRAW_LINE(off_min.x, off_min.y, off_min.z, off_max.x, off_max.y, off_max.z, r, g, b, a)
	local off_min = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_max.y, vec_min.z)
	local off_max = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_max.y, vec_min.z)
	GRAPHICS.DRAW_LINE(off_min.x, off_min.y, off_min.z, off_max.x, off_max.y, off_max.z, r, g, b, a)
	local off_min = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_max.y, vec_min.z)
	local off_max = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_min.y, vec_min.z)
	GRAPHICS.DRAW_LINE(off_min.x, off_min.y, off_min.z, off_max.x, off_max.y, off_max.z, r, g, b, a)
	local off_min = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_min.y, vec_min.z)
	local off_max = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_min.y, vec_max.z)
	GRAPHICS.DRAW_LINE(off_min.x, off_min.y, off_min.z, off_max.x, off_max.y, off_max.z, r, g, b, a)
	local off_min = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_min.y, vec_max.z)
	local off_max = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_max.y, vec_max.z)
	GRAPHICS.DRAW_LINE(off_min.x, off_min.y, off_min.z, off_max.x, off_max.y, off_max.z, r, g, b, a)
	local off_min = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_max.y, vec_max.z)
	local off_max = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_max.y, vec_max.z)
	GRAPHICS.DRAW_LINE(off_min.x, off_min.y, off_min.z, off_max.x, off_max.y, off_max.z, r, g, b, a)
	local off_min = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_max.y, vec_max.z)
	local off_max = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_max.y, vec_min.z)
	GRAPHICS.DRAW_LINE(off_min.x, off_min.y, off_min.z, off_max.x, off_max.y, off_max.z, r, g, b, a)
end

function features.get_offset_cam_coords(cam, offset)
	local rotation = vector3(CAM.GET_CAM_ROT(cam, 2))
	local forward = rotation:rot_to_direction()
	rotation = rotation:rad()
	local num = math.cos(rotation.y)
	local x = num * math.cos(-rotation.z)
	local y = num * math.sin(rotation.z)
	local z = math.sin(-rotation.y)
	local right = vector3(x, y, z)
	local up = right:cross(forward)
	return vector3(CAM.GET_CAM_COORD(cam)) + (right * offset.x) + (forward * offset.y) + (up * offset.z)
end

function features.get_offset_coords_from_entity_rot(entity, dist, offheading, ignore_z)
    local pos = ENTITY.GET_ENTITY_COORDS(entity, false)
    local rot = ENTITY.GET_ENTITY_ROTATION(entity, 2)
    local dist = dist or 5
    local offheading = offheading or 0
    local offz = 0
    local vector = {
        x = -math.sin(math.rad(rot.z + offheading)) * dist, 
        y = math.cos(math.rad(rot.z + offheading)) * dist,
        z = math.sin(math.rad(rot.x)) * dist
    }
    if not ignore_z then
        offz = vector.z
        local absx = math.abs(math.cos(math.rad(rot.x)))
        vector.x = vector.x * absx
        vector.y = vector.y * absx
    end
    return vector3(
        pos.x + vector.x,
        pos.y + vector.y,
        pos.z + offz
    )
end

function features.set_entity_face_entity(ent1, ent2, use_pitch)
    local rot = vector3(ENTITY.GET_ENTITY_COORDS(ent1, false)):direction_to(vector3(ENTITY.GET_ENTITY_COORDS(ent2, false))):direction_to_rot()
    if not use_pitch then
        ENTITY.SET_ENTITY_HEADING(ent1, rot.z)
    else
        ENTITY.SET_ENTITY_ROTATION(ent1, rot.x, rot.y, rot.z, 2, true)
    end
end

function features.oscillate_to_coord(ent, pos, force)
	local force = force or 1
	local pos = vector3(pos)
	local pos2 = vector3(ENTITY.GET_ENTITY_COORDS(ent, false))
	local to = (pos - pos2) * force
	ENTITY.SET_ENTITY_VELOCITY(ent, to.x, to.y, to.z)
end

function features.oscillate_to_entity(ent, ent2, force)
	features.oscillate_to_coord(ent, ENTITY.GET_ENTITY_COORDS(ent2, false), force)
end

function features.get_player_from_ped(ped)
	if PED.IS_PED_A_PLAYER(ped) == NULL then return -1 end
	for i = 0, 31 do
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 then
			if PLAYER.GET_PLAYER_PED(i) == ped then return i end
		end
	end
	return -1
end

function features.get_ped_weapon(ped)
	ped = ped or features.player_ped()
	local ptr = memory.malloc(8)
	WEAPON.GET_CURRENT_PED_WEAPON(ped, ptr, true)
	local weaponhash = memory.read_int(ptr)
	memory.free(ptr)
	return weaponhash
end

function features.set_godmode(entity, bool)
	ENTITY.SET_ENTITY_CAN_BE_DAMAGED(entity, not bool)
    ENTITY.SET_ENTITY_PROOFS(entity, bool, bool, bool, bool, bool, bool, bool, bool)
    ENTITY.SET_ENTITY_INVINCIBLE(entity, bool)
end

function features.round(value, to)
	return tonumber(string.format("%"..to.."f", value))
end

function features.draw_crosshair(x, y, spacing, tickness, r, g, b, a, b_left, b_right, b_up, b_down, borders, border_r, border_g, border_b, border_a, dot)
	local x, y, spacing, tickness, r, g, b, a = math.floor(x), math.floor(y), math.floor(spacing), math.floor(tickness), math.floor(r), math.floor(g), math.floor(b), math.floor(a)
	local borders, border_r, border_g, border_b, border_a = math.floor(borders), math.floor(border_r), math.floor(border_g), math.floor(border_b), math.floor(border_a)
	local res = features.get_screen_resolution()
	local border_thic = tickness + borders
	if border_thic%2~=0 then border_thic = border_thic + 1 end
	if tickness%2~=0 then tickness = tickness + 1 end
	local to_x = (1 / res.x)
	local to_y = (1 / res.y)
	local spacing_x = (1 / res.x) * spacing
	local spacing_y = (1 / res.y) * spacing
	if borders ~= 0 then
		local x = x + borders
		local y = y + borders
		if b_left then GRAPHICS.DRAW_RECT(.5 - spacing_x - (to_x * x)/2, .5, to_x * x, to_y * border_thic, border_r, border_g, border_b, border_a, false) end
		if b_right then GRAPHICS.DRAW_RECT(.5 + spacing_x + (to_x * x)/2, .5, to_x * x, to_y * border_thic, border_r, border_g, border_b, border_a, false) end
		if b_up then GRAPHICS.DRAW_RECT(.5, .5 - spacing_y - (to_y * y)/2, to_x * border_thic, to_y * y, border_r, border_g, border_b, border_a, false) end
		if b_down then GRAPHICS.DRAW_RECT(.5, .5 + spacing_y + (to_y * y)/2, to_x * border_thic, to_y * y, border_r, border_g, border_b, border_a, false) end
	end
	if b_left then GRAPHICS.DRAW_RECT(.5 - spacing_x - (to_x * x)/2, .5, to_x * x, to_y * tickness, r, g, b, a, false) end
	if b_right then GRAPHICS.DRAW_RECT(.5 + spacing_x + (to_x * x)/2, .5, to_x * x, to_y * tickness, r, g, b, a, false) end
	if b_up then GRAPHICS.DRAW_RECT(.5, .5 - spacing_y - (to_y * y)/2, to_x * tickness, to_y * y, r, g, b, a, false) end
	if b_down then GRAPHICS.DRAW_RECT(.5, .5 + spacing_y + (to_y * y)/2, to_x * tickness, to_y * y, r, g, b, a, false) end
	if dot then GRAPHICS.DRAW_RECT(.5, .5, to_x * tickness, to_y * tickness, r, g, b, a, false) end
end

function features.create_object(hash, pos)
	local obj = entities.create_object(hash, pos)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(obj), true)
    NETWORK._NETWORK_SET_ENTITY_INVISIBLE_TO_NETWORK(obj, false)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, false, true)
    return obj
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
	local ptr = memory.malloc(4)
	local result = MISC.GET_GROUND_Z_FOR_3D_COORD(pos.x, pos.y, pos.z, ptr, false, false)
	local groundz = memory.read_float(ptr)
	memory.free(ptr)
	return result == 1, groundz
end

function features.fake_tp(x, y, z)
	local px, py, pz = 0, 0, 0
	local addr = features.get_memory_address(WorldPtr, {0x08, 0x14C7})
	if addr ~= 0 and memory.read_int(addr) == 0x10 then
		px = features.get_memory_address(WorldPtr, {0x08, 0x90})
		py = features.get_memory_address(WorldPtr, {0x08, 0x94})
		pz = features.get_memory_address(WorldPtr, {0x08, 0x98})
	else
		px = features.get_memory_address(WorldPtr, {0x08, 0xD30, 0x90})
		py = features.get_memory_address(WorldPtr, {0x08, 0xD30, 0x94})
		pz = features.get_memory_address(WorldPtr, {0x08, 0xD30, 0x98})
	end
	if px ~= 0 and py ~= 0 and pz ~= 0 then
		memory.write_float(px, x)
		memory.write_float(py, y)
		memory.write_float(pz, z)
	end
end

function features.teleport(entity, x, y, z, heading)
	if ENTITY.IS_ENTITY_A_PED(entity) == 1 then
		if PED.IS_PED_IN_ANY_VEHICLE(entity, true) == 1 then
			entity = PED.GET_VEHICLE_PED_IS_IN(entity, false)
		end
	end
	entities.request_control(entity, function()
		ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, x, y, z, false, false, false)
		if heading then
			ENTITY.SET_ENTITY_HEADING(entity, heading)
		end
	end)
end

function features.get_closest_entity_to_coord(pos, min_distance)
	min_distance = min_distance and min_distance ^ 2 or 1000000
	local entity = 0
	for _, v in ipairs(features.get_entities())
	do
		local e_pos = vector3(ENTITY.GET_ENTITY_COORDS(v, false))
		local distance = pos:sqrlen(e_pos)
		if v ~= features.player_ped() and min_distance > distance then
			entity = v
			min_distance = distance
		end
	end
	return entity, min_distance
end

function features.get_closest_apartment_to_coord(pos)
	local distance
	local aparent
	for i, v in ipairs(enum.apartment_coords)
	do
		local dist = pos:sqrlen(v)
		if not distance then
			distance = dist
			aparent = i
		elseif distance > dist then
			distance = dist
			aparent = i
		end
	end
	return aparent
end

function features.get_blip_objective()
	local blipFound
	local coords
	for _, i in ipairs({enum.blip_sprite.level, enum.blip_sprite.contraband, enum.blip_sprite.supplies, enum.blip_sprite.nhp_bag, enum.blip_sprite.sports_car, enum.blip_sprite.raceflag})
	do
		for t = 1, 100
		do
			local b = HUD.GET_NEXT_BLIP_INFO_ID(i)
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
	end
	if blipFound then
		return coords
	end
	return vector3.zero()
end

function features.get_aimed_ped(player)
	local player = player or PLAYER.PLAYER_ID()
	local ptr = memory.malloc(4)
	local success = PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(player, ptr)
	if success == NULL then return NULL end
	local result = memory.read_int(ptr)
	memory.free(ptr)
	if ENTITY.IS_ENTITY_A_PED(result) == 1 then
		return result
	end
	return NULL
	-- for _, ent in ipairs(entities.get_peds())
	-- do
	-- 	if PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(PLAYER.PLAYER_ID(), ent) == 1 then
	-- 		return ent
	-- 	end
	-- end
	-- return NULL
end

function features.get_aimed_entity(player)
	local player = player or PLAYER.PLAYER_ID()
	local ptr = memory.malloc(4)
	local success = PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(player, ptr)
	if success == NULL then return NULL end
	local result = memory.read_int(ptr)
	memory.free(ptr)
	return result
	-- for _, ent in ipairs(features.get_entities())
	-- do
	-- 	if PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(PLAYER.PLAYER_ID(), ent) == 1 then
	-- 		return ent
	-- 	end
	-- end
	-- return NULL
end

function features.get_player_heading(player)
	local player = player or PLAYER.PLAYER_ID()
	return ENTITY.GET_ENTITY_HEADING(PLAYER.GET_PLAYER_PED(player))
end

function features.get_offset_from_player_coords(offvector, player)
	local player = player or PLAYER.PLAYER_ID()
	local offx, offy, offz = offvector:get()
	return vector3(ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(player), offx, offy, offz))
end

function features.get_player_coords(player)
	local player = player or PLAYER.PLAYER_ID()
	return vector3(ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(player), false))
end

function features.is_typing(player)
	return ENTITY.IS_ENTITY_DEAD(PLAYER.GET_PLAYER_PED(player), false) == 0 and features.AND(globals.get_int(1644218 + 241 + 136 + 2 + player * 1), 65536) ~= 0 --[[ & 1 << 16 ~= 0 ]] 
end

function features.is_otr(player)
	return globals.get_int(2689224 + (1 + (player * 451) + 207)) == 1
end

function features.is_excluded(pid)
	local rid = tostring(online.get_rockstar_id(pid))
	return features.player_excludes[rid] ~= nil
end

function features.is_friend(pid)
	local ptr = memory.malloc(104)
	NETWORK.NETWORK_HANDLE_FROM_PLAYER(pid, ptr, 13)
	if NETWORK.NETWORK_IS_HANDLE_VALID(ptr, 13) == NULL then memory.free(ptr) return end
	local isfriend = (NETWORK.NETWORK_IS_FRIEND(ptr) == 1)
	memory.free(ptr)
	return isfriend
end

function features.get_raycast_result(start, end_pos, ent_ignore, flag)
	local flag = flag or -1
	local hit, endCoords, surfaceNormal, entityHit = memory.malloc(8), memory.malloc(4 * 6), memory.malloc(4 * 6), memory.malloc(8)
	SHAPETEST.GET_SHAPE_TEST_RESULT(
		SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(start.x, start.y, start.z, end_pos.x, end_pos.y, end_pos.z, flag, ent_ignore, 1),
		hit, endCoords, surfaceNormal, entityHit
	)
	local result = {
		didHit = features.to_bool(memory.read_byte(hit)),
		endCoords = vector3(memory.read_vector3(endCoords)),
		surfaceNormal = vector3(memory.read_vector3(surfaceNormal)),
		hitEntity = memory.read_int(entityHit)
	}
	memory.free(hit)
	memory.free(endCoords)
	memory.free(surfaceNormal)
	memory.free(entityHit)
	return result
end

function features.get_all_attachments(entity, entities)
	local entities = entities or {}
	for _, v in ipairs(features.get_entities())
	do
		if ENTITY.GET_ENTITY_ATTACHED_TO(v) == entity then
			table.insert(entities, v)
			features.get_all_attachments(v, entities)
		end
	end
	return entities
end

function features.get_parent_attachment(...)
	local entity = ...
	if ENTITY.IS_ENTITY_ATTACHED(entity) == 1 then
		return features.get_parent_attachment(ENTITY.GET_ENTITY_ATTACHED_TO(entity))
	else
		return entity
	end
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

function features.get_godmode(entity)
	local proofs = features.get_entity_proofs(entity)
	return (proofs.bulletProof and proofs.fireProof and proofs.explosionProof)
end

function features.delete_entity(entity)
	if not entity then return end
	if ENTITY.DOES_ENTITY_EXIST(entity) == NULL then return end
	ENTITY.SET_ENTITY_COLLISION(entity, false, true)
	if ENTITY.IS_ENTITY_A_PED(entity) == 1 then
	  TASK.CLEAR_PED_TASKS_IMMEDIATELY(entity)
	end
	for _, v in ipairs(features.get_all_attachments(entity))
	do
		features.delete_entity(v)
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

function features.request_model(hashname)
	local hash = 0
	if tonumber(hashname) then 
		hash = tonumber(hashname) 
	else
		hash = utils.joaat(hashname)
	end 
	if STREAMING.IS_MODEL_VALID(hash) == NULL then return hash end
	STREAMING.REQUEST_MODEL(hash)
	return STREAMING.HAS_MODEL_LOADED(hash), hash
end

function features.get_model_dimentions(model)
	local vec_min = memory.malloc(6 * 4)
	local vec_max = memory.malloc(6 * 4)
	MISC.GET_MODEL_DIMENSIONS(model, vec_min, vec_max)
	local minimum = vector3(memory.read_vector3(vec_min))
	local maximum = vector3(memory.read_vector3(vec_max))
	memory.free(vec_min)
	memory.free(vec_max)
	return minimum, maximum
end

function features.sum_table(array)
	local sum = 0
	for _, v in ipairs(array) do
		sum = sum + v
	end
	return sum
end

local players = {
	kick = {},
	crash = {}
}

function features.get_bullet_impact(ped)
	local ped = ped or PLAYER.PLAYER_PED_ID()
	local vec = memory.malloc(6 * 4)
	WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(ped, vec)
	local pos = vector3(memory.read_vector3(vec))
	memory.free(vec)
	return pos
end

function features.set_bounty(player, amount)
	local amount = tonumber(amount) or 10000
	for i = 0, 31
	do	
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) ~= NULL then
			online.send_script_event(i, 1294995624, PLAYER.PLAYER_ID(), player, 1, (amount >= 0 and amount <= 10000) and math.floor(amount) or 10000, 0, 1,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals.get_int(1921039 + 9), globals.get_int(1921039 + 10))
		end
	end
end

function features.crash_player(player)
	if (NETWORK.NETWORK_IS_PLAYER_CONNECTED(player) == NULL) or (player == PLAYER.PLAYER_ID()) or (players.crash[player] and players.crash[player] > os.time()) then return end

	system.log('Imagined Menu', string.format("Sending crash to %s", online.get_name(player)))
	system.notify('Imagined Menu', string.format(TRANSLATION["Sending crash to %s"], online.get_name(player)), 255, 50, 0, 255)

	online.send_script_event(player, 2908956942, get_random_args(15))
	online.send_script_event(player, 962740265, get_random_args(15))
	online.send_script_event(player, -1386010354, get_random_args(15))
	online.send_script_event(player, -1970125962, get_random_args(15))
	online.send_script_event(player, -1767058336, get_random_args(15))
	online.send_script_event(player, 1757755807, get_random_args(15))

	players.crash[player] = os.time() + 10
end

function features.kick_player(player)
	if (NETWORK.NETWORK_IS_PLAYER_CONNECTED(player) == NULL) or (player == PLAYER.PLAYER_ID()) or (players.kick[player] and players.kick[player] > os.time()) then return end

	system.log('Imagined Menu', string.format("Kicking %s", online.get_name(player)))
	system.notify('Imagined Menu', string.format(TRANSLATION["Kicking %s"], online.get_name(player)), 255, 50, 0, 255)

	if NETWORK.NETWORK_IS_HOST() == 1 then
		NETWORK.NETWORK_SESSION_KICK_PLAYER(player)
	else
		online.send_script_event(player, 1228916411, PLAYER.PLAYER_ID(), globals.get_int(1893551 + (1 + (player * 599) + 510)))

		online.send_script_event(player, 927169576, get_random_args(15))
		online.send_script_event(player, -1308840134, get_random_args(15))
		online.send_script_event(player, 436475575, get_random_args(15))
		online.send_script_event(player, -290218924, get_random_args(15))
		online.send_script_event(player, -368423380, get_random_args(15))
		online.send_script_event(player, -614457627, get_random_args(15))
		online.send_script_event(player, -1991317864, get_random_args(15))
		online.send_script_event(player, 163598572, PLAYER.PLAYER_ID(), 0, 30583, 0, 0, 0, -328966, 2098891836, 0)
		online.send_script_event(player, 998716537, PLAYER.PLAYER_ID(), 1, -1)

		online.send_script_event(player, 603406648, math.random(32, 2147483647), math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647))
		online.send_script_event(player, 603406648, math.random(-2147483647, -1), math.random(-2147483647, 2147483647), 1, 115, math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647), math.random(-2147483647, 2147483647))
	end
	players.kick[player] = os.time() + 10
end

return features