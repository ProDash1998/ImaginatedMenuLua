--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--

-- Global to local
local time = os.time
local format = string.format
local insert = table.insert
local table_remove = table.remove
local abs = math.abs
local random = math.random
local cos = math.cos
local sin = math.sin
local floor = math.floor
local rad = math.rad
local type = type
local select = select
local require = require
local unpack = unpack
local tonumber = tonumber
local tostring = tostring
local ipairs = ipairs
local pairs = pairs
local memory = memory
local system = system
local PED = PED
local CAM = CAM
local PLAYER = PLAYER
local VEHICLE = VEHICLE
local NETWORK = NETWORK
local STREAMING = STREAMING
local utils = utils
local entities = entities
local globals = globals
local online = online
local WEAPON = WEAPON
local TASK = TASK
local MISC = MISC
local GRAPHICS = GRAPHICS
local SHAPETEST = SHAPETEST
local ENTITY = ENTITY
local HUD = HUD
local WATER = WATER
local cache = cache

local vector3 = require 'vector3'
local switch = require 'switch'
local enum = require 'enums'
local s_memory = require 'script_memory'
local TRANSLATION = require('default').translation
local features = {}
features.player_excludes = {}

math.randomseed(time())

local function get_random_args(count)
	local args = {}
	for i = 1, count do
		insert(args, random(-2147483647, 2147483647))
	end
	return unpack(args)
end

local function models_loaded(hashes)
	for _, hash in ipairs(hashes) do
		STREAMING.REQUEST_MODEL(hash)
		if STREAMING.HAS_MODEL_LOADED(hash) == 0 then 
			return
		end
	end
	return true
end

function features.to_hex(value)
	return format("0x%X", value * 255)
end

function features.to_bool(any)
	if type(any) == 'string' then
		return (any ~= 'false' or any ~= '')
	elseif type(any) == 'number' then
		return (any ~= 0)
	end
end

function features.lshift(x, by)
  return floor(x * 2 ^ by)
end

function features.rshift(x, by)
  return floor(x / 2 ^ by)
end

local OR, XOR, AND = 1, 3, 4
local function bitoper(a, b, oper)
   local r, m, s = 0, math.pow(31, 2)
   repeat
      s, a, b = a + b + m, a % m, b % m
      r, m = r + m * oper % (s - a - b), m / 2
   until m < 1
   return floor(r)
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
      a = floor(a/2) -- shift right
      b = floor(b/2)
    end
    return result
end

function features.patch_blame(bool)
	memory.write_short(s_memory.BlameExp, bool and 0xE990 or 0x850F)
end

function features.to_clipboard(text, notify)
	if notify then system.notify(TRANSLATION["Info"], TRANSLATION["Copied to clipboard"], 0, 255, 0, 255, true) end
	system.to_clipboard(text)
end

function features.get_screen_resolution()
	local px, py = s_memory.allocate(2)
	GRAPHICS._GET_ACTIVE_SCREEN_RESOLUTION(px, py)
	return vector3(memory.read_int(px), memory.read_int(py))
end

function features.get_screen_center()
	return features.get_screen_resolution() / 2
end

function features.world_to_screen(pos)
	local screenX, screenY = s_memory.allocate(2)
	GRAPHICS.GET_SCREEN_COORD_FROM_WORLD_COORD(pos.x, pos.y, pos.z, screenX, screenY)
	return vector3(memory.read_float(screenX), memory.read_float(screenY))
end

function features.copy_table(datatable)
  local result = {}
  if type(datatable) == "table" then
    for k, v in pairs(datatable)
    do 
    	result[k] = features.copy_table(v) 
    end
  else
    result = datatable
  end
  return result
end

function features.split(str, sep)
   local result = {}
   local regex = ("([^%s]+)"):format(sep)
   for each in str:gmatch(regex) do
      insert(result, each)
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

function features.get_random_player(no_friend)
	local players = {}
	for i = 0, 31 do
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and i ~= PLAYER.PLAYER_ID() and not (no_friend and features.is_friend(i)) and not features.is_excluded(i) then
			insert(players, i)
		end
	end
	if #players ~= 0 then return players[random(1, #players)] end
	return PLAYER.PLAYER_ID()
end

function features.draw_box_on_entity(entity, r, g, b, a)
	r, g, b, a = r or 255, g or 255, b or 255, a or 255
	local vec_min, vec_max = features.get_model_dimentions(ENTITY.GET_ENTITY_MODEL(entity))
	local off_1 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_min.y, vec_min.z)
	local off_2 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_min.y, vec_max.z)
	local off_3 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_min.y, vec_min.z)
	local off_4 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_max.y, vec_min.z)
	local off_5 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_min.y, vec_max.z)
	local off_6 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_min.x, vec_max.y, vec_max.z)
	local off_7 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_max.y, vec_min.z)
	local off_8 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, vec_max.x, vec_max.y, vec_max.z)
	GRAPHICS.DRAW_LINE(off_1.x, off_1.y, off_1.z, off_2.x, off_2.y, off_2.z, r, g, b, a)
	GRAPHICS.DRAW_LINE(off_1.x, off_1.y, off_1.z, off_3.x, off_3.y, off_3.z, r, g, b, a)
	GRAPHICS.DRAW_LINE(off_1.x, off_1.y, off_1.z, off_4.x, off_4.y, off_4.z, r, g, b, a)
	GRAPHICS.DRAW_LINE(off_2.x, off_2.y, off_2.z, off_5.x, off_5.y, off_5.z, r, g, b, a)
	GRAPHICS.DRAW_LINE(off_2.x, off_2.y, off_2.z, off_6.x, off_6.y, off_6.z, r, g, b, a)
	GRAPHICS.DRAW_LINE(off_4.x, off_4.y, off_4.z, off_6.x, off_6.y, off_6.z, r, g, b, a)
	GRAPHICS.DRAW_LINE(off_4.x, off_4.y, off_4.z, off_7.x, off_7.y, off_7.z, r, g, b, a)
	GRAPHICS.DRAW_LINE(off_7.x, off_7.y, off_7.z, off_3.x, off_3.y, off_3.z, r, g, b, a)
	GRAPHICS.DRAW_LINE(off_3.x, off_3.y, off_3.z, off_5.x, off_5.y, off_5.z, r, g, b, a)
	GRAPHICS.DRAW_LINE(off_5.x, off_5.y, off_5.z, off_8.x, off_8.y, off_8.z, r, g, b, a)
	GRAPHICS.DRAW_LINE(off_8.x, off_8.y, off_8.z, off_6.x, off_6.y, off_6.z, r, g, b, a)
	GRAPHICS.DRAW_LINE(off_8.x, off_8.y, off_8.z, off_7.x, off_7.y, off_7.z, r, g, b, a)
end

function features.draw_box_on_entity2(entity, pos, r, g, b, a) -- slower but not delayed by frame
	r, g, b, a = r or 255, g or 255, b or 255, a or 255
	local vec_min, vec_max = features.get_model_dimentions(ENTITY.GET_ENTITY_MODEL(entity))
	local rot = vector3(ENTITY.GET_ENTITY_ROTATION(entity, 2))
	local off_1 = features.get_offset_entity_with_given_coords(entity, pos, vector3(vec_min.x, vec_min.y, vec_min.z), rot)
    local off_2 = features.get_offset_entity_with_given_coords(entity, pos, vector3(vec_min.x, vec_min.y, vec_max.z), rot)
    local off_3 = features.get_offset_entity_with_given_coords(entity, pos, vector3(vec_max.x, vec_min.y, vec_min.z), rot)
    local off_4 = features.get_offset_entity_with_given_coords(entity, pos, vector3(vec_min.x, vec_max.y, vec_min.z), rot)
    local off_5 = features.get_offset_entity_with_given_coords(entity, pos, vector3(vec_max.x, vec_min.y, vec_max.z), rot)
    local off_6 = features.get_offset_entity_with_given_coords(entity, pos, vector3(vec_min.x, vec_max.y, vec_max.z), rot)
    local off_7 = features.get_offset_entity_with_given_coords(entity, pos, vector3(vec_max.x, vec_max.y, vec_min.z), rot)
    local off_8 = features.get_offset_entity_with_given_coords(entity, pos, vector3(vec_max.x, vec_max.y, vec_max.z), rot)
    GRAPHICS.DRAW_LINE(off_1.x, off_1.y, off_1.z, off_2.x, off_2.y, off_2.z, r, g, b, a)
    GRAPHICS.DRAW_LINE(off_1.x, off_1.y, off_1.z, off_3.x, off_3.y, off_3.z, r, g, b, a)
    GRAPHICS.DRAW_LINE(off_1.x, off_1.y, off_1.z, off_4.x, off_4.y, off_4.z, r, g, b, a)
    GRAPHICS.DRAW_LINE(off_2.x, off_2.y, off_2.z, off_5.x, off_5.y, off_5.z, r, g, b, a)
    GRAPHICS.DRAW_LINE(off_2.x, off_2.y, off_2.z, off_6.x, off_6.y, off_6.z, r, g, b, a)
    GRAPHICS.DRAW_LINE(off_4.x, off_4.y, off_4.z, off_6.x, off_6.y, off_6.z, r, g, b, a)
    GRAPHICS.DRAW_LINE(off_4.x, off_4.y, off_4.z, off_7.x, off_7.y, off_7.z, r, g, b, a)
    GRAPHICS.DRAW_LINE(off_7.x, off_7.y, off_7.z, off_3.x, off_3.y, off_3.z, r, g, b, a)
    GRAPHICS.DRAW_LINE(off_3.x, off_3.y, off_3.z, off_5.x, off_5.y, off_5.z, r, g, b, a)
    GRAPHICS.DRAW_LINE(off_5.x, off_5.y, off_5.z, off_8.x, off_8.y, off_8.z, r, g, b, a)
    GRAPHICS.DRAW_LINE(off_8.x, off_8.y, off_8.z, off_6.x, off_6.y, off_6.z, r, g, b, a)
    GRAPHICS.DRAW_LINE(off_8.x, off_8.y, off_8.z, off_7.x, off_7.y, off_7.z, r, g, b, a)
end

function features.get_offset_entity_with_given_coords(entity, pos, offset, rot)
	local rotation = rot or vector3(ENTITY.GET_ENTITY_ROTATION(entity, 2))
	local forward = rotation:rot_to_direction()
	rotation = rotation:rad()
	local num = cos(rotation.y)
	local x = num * cos(-rotation.z)
	local y = num * sin(rotation.z)
	local z = sin(-rotation.y)
	local right = vector3(x, y, z)
	local up = right:cross(forward)
	return vector3(pos + (right * offset.x) + (forward * offset.y) + (up * offset.z))
end

function features.get_offset_cam_coords(cam, offset)
	local rotation = vector3(CAM.GET_CAM_ROT(cam, 2))
	local forward = rotation:rot_to_direction()
	rotation = rotation:rad()
	local num = cos(rotation.y)
	local x = num * cos(-rotation.z)
	local y = num * sin(rotation.z)
	local z = sin(-rotation.y)
	local right = vector3(x, y, z)
	local up = right:cross(forward)
	return vector3(CAM.GET_CAM_COORD(cam)) + (right * offset.x) + (forward * offset.y) + (up * offset.z)
end

function features.get_offset_coords_from_entity_rot(entity, dist, offheading, ignore_z)
    local pos = features.get_entity_coords(entity)
    local rot = ENTITY.GET_ENTITY_ROTATION(entity, 2)
    dist = dist or 5
    offheading = offheading or 0
    local offz = 0
    local vector = {
        x = -sin(rad(rot.z + offheading)) * dist, 
        y = cos(rad(rot.z + offheading)) * dist,
        z = sin(rad(rot.x)) * dist
    }
    if not ignore_z then
        offz = vector.z
        local absx = abs(cos(rad(rot.x)))
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
    local rot = features.get_entity_coords(ent1):direction_to(features.get_entity_coords(ent2)):direction_to_rot()
    if not use_pitch then
        ENTITY.SET_ENTITY_HEADING(ent1, rot.z)
    else
        ENTITY.SET_ENTITY_ROTATION(ent1, rot.x, rot.y, rot.z, 2, true)
    end
end

function features.oscillate_to_coord(ent, pos, force)
	force = force or 1
	pos = vector3(pos)
	local pos2 = features.get_entity_coords(ent)
	local to = (pos - pos2) * force
	ENTITY.SET_ENTITY_VELOCITY(ent, to.x, to.y, to.z)
end

function features.oscillate_to_entity(ent, ent2, force)
	features.oscillate_to_coord(ent, features.get_entity_coords(ent2), force)
end

function features.get_player_from_ped(ped)
	if PED.IS_PED_A_PLAYER(ped) == 0 then return -1 end
	for i = 0, 31 do
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 then
			if PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(i) == ped then return i end
		end
	end
	return -1
end

function features.get_ped_weapon(ped)
	ped = ped or features.player_ped()
	local ptr = s_memory.alloc(8)
	WEAPON.GET_CURRENT_PED_WEAPON(ped, ptr, true)
	return memory.read_int(ptr)
end

function features.set_godmode(entity, bool)
	ENTITY.SET_ENTITY_CAN_BE_DAMAGED(entity, not bool)
    ENTITY.SET_ENTITY_PROOFS(entity, bool, bool, bool, bool, bool, bool, bool, bool)
    ENTITY.SET_ENTITY_INVINCIBLE(entity, bool)
end

function features.compare(param, ...)
	for _, v in pairs({...})
	do
		if v == param then
			return true
		end
	end
	return false
end

function features.is_table_empty(tabl)
	if type(tabl) ~= 'table' then return end
	for _ in pairs(tabl)
	do
		return false
	end
	return true
end

function features.round(value, to)
	return tonumber(format("%"..to.."f", value))
end

function features.draw_crosshair(x, y, spacing, thickness, r, g, b, a, b_left, b_right, b_up, b_down, borders, border_r, border_g, border_b, border_a, dot)
	x, y, spacing, thickness, r, g, b, a = floor(x), floor(y), floor(spacing), floor(thickness), floor(r), floor(g), floor(b), floor(a)
	borders, border_r, border_g, border_b, border_a = floor(borders), floor(border_r), floor(border_g), floor(border_b), floor(border_a)
	local res = features.get_screen_resolution()
	local border_thic = thickness + borders
	if border_thic%2 ~= 0 then border_thic = border_thic + 1 end
	if thickness%2 ~= 0 then thickness = thickness + 1 end
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
	if b_left then GRAPHICS.DRAW_RECT(.5 - spacing_x - (to_x * x)/2, .5, to_x * x, to_y * thickness, r, g, b, a, false) end
	if b_right then GRAPHICS.DRAW_RECT(.5 + spacing_x + (to_x * x)/2, .5, to_x * x, to_y * thickness, r, g, b, a, false) end
	if b_up then GRAPHICS.DRAW_RECT(.5, .5 - spacing_y - (to_y * y)/2, to_x * thickness, to_y * y, r, g, b, a, false) end
	if b_down then GRAPHICS.DRAW_RECT(.5, .5 + spacing_y + (to_y * y)/2, to_x * thickness, to_y * y, r, g, b, a, false) end
	if dot then GRAPHICS.DRAW_RECT(.5, .5, to_x * thickness, to_y * thickness, r, g, b, a, false) end
end

function features.create_object(hash, pos)
	local obj = OBJECT.CREATE_OBJECT(hash, pos.x, pos.y, pos.z, true, false, true)
    NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(obj), true)
    NETWORK._NETWORK_SET_ENTITY_INVISIBLE_TO_NETWORK(obj, false)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, false, true)
    return obj
end

function features.get_entities()
	local ent = {}
	for _,v in ipairs(entities.get_vehs()) do
		insert(ent, v)
	end
	for _,v in ipairs(entities.get_peds()) do
		insert(ent, v)
	end
	for _,v in ipairs(entities.get_objects()) do
		insert(ent, v)
	end
	return ent
end

function features.get_water_z(pos)
	local ptr = s_memory.alloc()
	local result = WATER.GET_WATER_HEIGHT_NO_WAVES(pos.x, pos.y, pos.z, ptr)
	return result == 1, memory.read_float(ptr)
end

function features.get_ground_z(pos)
	local ptr = s_memory.alloc()
	local result = MISC.GET_GROUND_Z_FOR_3D_COORD(pos.x, pos.y, pos.z, ptr, false, false)
	return result == 1, memory.read_float(ptr)
end

function features.fake_tp(x, y, z)
	local px, py, pz = 0, 0, 0
	local addr = s_memory.get_memory_address(s_memory.WorldPtr, {0x08, 0x14C7})
	if addr ~= 0 and memory.read_int(addr) == 0x10 then
		px = s_memory.get_memory_address(s_memory.WorldPtr, {0x08, 0x90})
		py = s_memory.get_memory_address(s_memory.WorldPtr, {0x08, 0x94})
		pz = s_memory.get_memory_address(s_memory.WorldPtr, {0x08, 0x98})
	else
		px = s_memory.get_memory_address(s_memory.WorldPtr, {0x08, 0xD30, 0x90})
		py = s_memory.get_memory_address(s_memory.WorldPtr, {0x08, 0xD30, 0x94})
		pz = s_memory.get_memory_address(s_memory.WorldPtr, {0x08, 0xD30, 0x98})
	end
	if px ~= 0 and py ~= 0 and pz ~= 0 then
		memory.write_float(px, x)
		memory.write_float(py, y)
		memory.write_float(pz, z)
	end
end

function features.teleport_entity(entity, x, y, z, heading)
	entities.request_control(entity, function()
		ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, x, y, z, false, false, false)
		if heading then
			ENTITY.SET_ENTITY_HEADING(entity, heading)
		end
	end)
end

function features.teleport(entity, x, y, z, heading, velocity)
	if ENTITY.IS_ENTITY_A_PED(entity) == 1 and PED.IS_PED_IN_ANY_VEHICLE(entity, true) == 1 then
		entity = PED.GET_VEHICLE_PED_IS_IN(entity, false)
	end
	if velocity then
		velocity = ENTITY.GET_ENTITY_VELOCITY(entity)
	end
	entities.request_control(entity, function()
		ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, x, y, z, false, false, false)
		if heading then
			ENTITY.SET_ENTITY_HEADING(entity, heading)
		end
		if velocity then
			ENTITY.SET_ENTITY_VELOCITY(entity, velocity.x, velocity.y, velocity.z)
		end
	end)
end

function features.is_in_area(entity, vec1, vec2)
	local min = vector3.min(vec1, vec2)
	local max = vector3.max(vec1, vec2)
	local pos = features.get_entity_coords(entity)
	return min <= pos and max >= pos
end

function features.get_closest_entity_to_coord(pos, min_distance)
	min_distance = min_distance and min_distance ^ 2 or 1000000
	local entity = 0
	for _, v in ipairs(features.get_entities())
	do
		local e_pos = features.get_entity_coords(v)
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
		if not distance or (distance and distance > dist) then
			distance = dist
			aparent = i
		end
	end
	return aparent
end

function features.remove_blip(blip)
	if HUD.DOES_BLIP_EXIST(blip) == 0 then return end
	local ptr = s_memory.alloc()
	memory.write_int(ptr, blip)
	HUD.REMOVE_BLIP(ptr)
end

function features.gameplay_cam_rot()
	return vector3(CAM.GET_GAMEPLAY_CAM_ROT(2))
end

function features.gameplay_cam_pos()
	return vector3(CAM.GET_GAMEPLAY_CAM_COORD())
end

function features.get_waypoint_coord()
	return vector3(HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8)))
end

function features.get_blip_for_coord(pos)
	for v = 0, 1000
	do
		if v ~= 8 then
			local blip = HUD.GET_FIRST_BLIP_INFO_ID(v)
			while HUD.DOES_BLIP_EXIST(blip) == 1 do
				local bpos = vector3(HUD.GET_BLIP_COORDS(blip))
				if bpos.z ~= 0 and pos.x == bpos.x and pos.y == bpos.y then
					return bpos
				end
				blip = HUD.GET_NEXT_BLIP_INFO_ID(v)
			end
		end
	end
end

function features.get_blip_objective()
	for _, i in ipairs({enum.blip_sprite.level, enum.blip_sprite.contraband, enum.blip_sprite.supplies, enum.blip_sprite.nhp_bag, enum.blip_sprite.sports_car, enum.blip_sprite.raceflag})
	do
		local blip = HUD.GET_FIRST_BLIP_INFO_ID(i)
		while HUD.DOES_BLIP_EXIST(blip) == 1
		do
			local color = HUD.GET_BLIP_COLOUR(blip)
			local icon = HUD.GET_BLIP_SPRITE(blip)
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
				return vector3(HUD.GET_BLIP_INFO_ID_COORD(blip))
			end
			blip = HUD.GET_NEXT_BLIP_INFO_ID(i)
		end
	end

	return
end

function features.get_aimed_ped(player)
	local ptr = s_memory.alloc()
	if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(player or PLAYER.PLAYER_ID(), ptr) == 0 then return 0 end
	local result = memory.read_int(ptr)
	if ENTITY.IS_ENTITY_A_PED(result) == 1 then
		return result
	end
	return 0
	-- for _, ent in ipairs(entities.get_peds())
	-- do
	-- 	if PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(PLAYER.PLAYER_ID(), ent) == 1 then
	-- 		return ent
	-- 	end
	-- end
	-- return 0
end

function features.get_aimed_entity(player)
	local ptr = s_memory.alloc()
	if PLAYER.GET_ENTITY_PLAYER_IS_FREE_AIMING_AT(player or PLAYER.PLAYER_ID(), ptr) == 0 then return 0 end
	return memory.read_int(ptr)
	-- for _, ent in ipairs(features.get_entities())
	-- do
	-- 	if PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(PLAYER.PLAYER_ID(), ent) == 1 then
	-- 		return ent
	-- 	end
	-- end
	-- return 0
end

function features.get_entity_rot(entity, order)
	return vector3(ENTITY.GET_ENTITY_ROTATION(entity, order or 2))
end

function features.get_entity_coords(entity)
	return vector3(ENTITY.GET_ENTITY_COORDS(entity, false))
end

function features.get_player_heading(player)
	return ENTITY.GET_ENTITY_HEADING(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player or PLAYER.PLAYER_ID()))
end

function features.get_offset_from_entity_in_world_coords(entity, off)
	return vector3(ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entity, off.x, off.y, off.z))
end

function features.get_offset_from_player_coords(offvector, player)
	local offx, offy, offz = offvector:get()
	return vector3(ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player or PLAYER.PLAYER_ID()), offx, offy, offz))
end

function features.get_player_coords(player)
	return features.get_entity_coords(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player or PLAYER.PLAYER_ID()))
end

function features.get_player_coords2(player)
	local pos = features.get_entity_coords(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(player or PLAYER.PLAYER_ID()))
	if pos.z == -50 then
		local blip = HUD.GET_BLIP_FROM_ENTITY(features.player_ped(player))
		if HUD.DOES_BLIP_EXIST(blip) == 1 then
			pos = HUD.GET_BLIP_COORDS(blip)
		end
	end
	return pos
end

function features.is_typing(player)
	return ENTITY.IS_ENTITY_DEAD(features.player_ped(player), false) == 0 and features.AND(globals.get_int(1644218 + 241 + 136 + 2 + player * 1), 65536) ~= 0 --[[ & 1 << 16 ~= 0 ]] 
end

function features.is_otr(player)
	return NETWORK.NETWORK_IS_PLAYER_CONNECTED(player) == 1 and globals.get_int(2689224 + 1 + (player * 451) + 207) == 1
end

function features.is_excluded(pid)
	local rid = tostring(online.get_rockstar_id(pid))
	return features.player_excludes[rid] ~= nil
end

function features.is_friend(pid)
	local ptr = s_memory.alloc(104)
	NETWORK.NETWORK_HANDLE_FROM_PLAYER(pid, ptr, 13)
	if NETWORK.NETWORK_IS_HANDLE_VALID(ptr, 13) == 0 then return end
	return (NETWORK.NETWORK_IS_FRIEND(ptr) == 1)
end

local IsFree = switch()
	:case(1, function(dim_max, pos, veh)
    	local poslx = features.get_offset_from_entity_in_world_coords(veh, vector3.left(dim_max.x + .5)) -- left mid
    	local success, groundZ = features.get_ground_z(poslx)
    	if not features.get_raycast_result(pos, poslx, veh).didHit and success and abs(groundZ - pos.z) < 3 then
    		return poslx
    	end
	end)
	:case(2, function(dim_max, pos, veh)
    	local poslx = features.get_offset_from_entity_in_world_coords(veh, vector3(- dim_max.x - .5, 2, 0)) -- left fornt
    	local success, groundZ = features.get_ground_z(poslx)
    	if not features.get_raycast_result(pos, poslx, veh).didHit and success and abs(groundZ - pos.z) < 3 then
    		return poslx
    	end
	end)
	:case(3, function(dim_max, pos, veh)
    	local poslx = features.get_offset_from_entity_in_world_coords(veh, vector3(- dim_max.x - .5, -2, 0)) -- left back
    	local success, groundZ = features.get_ground_z(poslx)
    	if not features.get_raycast_result(pos, poslx, veh).didHit and success and abs(groundZ - pos.z) < 3 then
    		return poslx
    	end
	end)
	:case(4, function(dim_max, pos, veh)
		local posrx = features.get_offset_from_entity_in_world_coords(veh, vector3.right(dim_max.x + .5)) -- right mid
		local success, groundZ = features.get_ground_z(posrx)
    	if not features.get_raycast_result(pos, posrx, veh).didHit and success and abs(groundZ - pos.z) < 3 then
    		return posrx
    	end
	end)
	:case(5, function(dim_max, pos, veh)
    	local posrx = features.get_offset_from_entity_in_world_coords(veh, vector3(dim_max.x + .5, 2, 0)) -- right front
    	local success, groundZ = features.get_ground_z(posrx)
    	if not features.get_raycast_result(pos, posrx, veh).didHit and success and abs(groundZ - pos.z) < 3 then
    		return posrx
    	end
	end)
	:case(6, function(dim_max, pos, veh)
    	local posrx = features.get_offset_from_entity_in_world_coords(veh, vector3(dim_max.x + .5, -2, 0)) -- right back
    	local success, groundZ = features.get_ground_z(posrx)
    	if not features.get_raycast_result(pos, posrx, veh).didHit and success and abs(groundZ - pos.z) < 3 then
    		return posrx
    	end
	end)
	:case(7, function(dim_max, pos, veh)
		if ENTITY.GET_ENTITY_SPEED(veh) > 1 then return end
		local posly = features.get_offset_from_entity_in_world_coords(veh, vector3.forward(dim_max.y + .5)) -- front
		local success, groundZ = features.get_ground_z(posly)
    	if not features.get_raycast_result(pos, posly, veh).didHit and success and abs(groundZ - pos.z) < 3 then
    		return posly
    	end
	end)
	:case(8, function(dim_max, pos, veh)
    	local posry = features.get_offset_from_entity_in_world_coords(veh, vector3.back(dim_max.y + .5)) -- back
    	local success, groundZ = features.get_ground_z(posry)
    	if not features.get_raycast_result(pos, posry, veh).didHit and success and abs(groundZ - pos.z) < 3 then
    		return posry
    	end
	end)
	:default(function(dim_max, pos, veh)
		return pos + vector3.up(dim_max.z) -- top
	end)

function features.get_space_near_vehicle(veh)
    local dim_max = select(2, features.get_model_dimentions(ENTITY.GET_ENTITY_MODEL(veh)))
    local pos = features.get_entity_coords(veh)
    for i = 1, 9 do
    	local result = IsFree(i, dim_max, pos, veh)
    	if result then
    		return result
    	end
    end
end

function features.get_collider_usage()
	local handle = memory.read_int64(s_memory.phInstance)
	if handle == 0 then return 0 end
	local usedCollidersOffset = memory.read_int(s_memory.ColliderOffset + 3)
	local maxCollidersOffset = memory.read_int(s_memory.ColliderOffset + 9)
	return memory.read_int(handle + maxCollidersOffset) - memory.read_int(handle + usedCollidersOffset)
end

function features.can_activate_physics()
	return features.get_collider_usage() > 50
end

function features.set_entity_velocity(entity, x, y, z)
	if not features.can_activate_physics() then return end
	ENTITY.SET_ENTITY_VELOCITY(entity, x, y, z)
end

function features.apply_force_to_entity(entity, forceFlags, x, y, z, offX, offY, offZ, boneIndex, isDirectionRel, ignoreUpVec, isForceRel, p12, p13)
	if not features.can_activate_physics() then return end
	ENTITY.APPLY_FORCE_TO_ENTITY(entity, forceFlags, x, y, z, offX, offY, offZ, boneIndex, isDirectionRel, ignoreUpVec, isForceRel, p12, p13)
end

function features.get_raycast_result(start, end_pos, ent_ignore, flag)
	flag = flag or -1
	local hit, endCoords, surfaceNormal, entityHit = s_memory.alloc(8), s_memory.allocv3(), s_memory.allocv3(), s_memory.alloc(8)
	SHAPETEST.GET_SHAPE_TEST_RESULT(
		SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(start.x, start.y, start.z, end_pos.x, end_pos.y, end_pos.z, flag, ent_ignore, 1),
		hit, endCoords, surfaceNormal, entityHit
	)
	return {
		didHit = features.to_bool(memory.read_byte(hit)),
		endCoords = s_memory.readv3(endCoords),
		surfaceNormal = s_memory.readv3(surfaceNormal),
		hitEntity = memory.read_int(entityHit)
	}
end

function features.get_all_attachments(entity, entities)
	entities = entities or {}
	for _, v in ipairs(features.get_entities())
	do
		if ENTITY.GET_ENTITY_ATTACHED_TO(v) == entity then
			insert(entities, v)
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
	local bulletProof, fireProof, explosionProof, collisionProof, meleeProof, steamProof, p7, drownProof = s_memory.allocate(8)
	ENTITY._GET_ENTITY_PROOFS(entity, bulletProof, fireProof, explosionProof, collisionProof, meleeProof, steamProof, p7, drownProof)
	return {
		bulletProof 	= features.to_bool(memory.read_byte(bulletProof)),
		fireProof 		= features.to_bool(memory.read_byte(fireProof)),
		explosionProof = features.to_bool(memory.read_byte(explosionProof)),
		collisionProof = features.to_bool(memory.read_byte(collisionProof)),
		meleeProof 		= features.to_bool(memory.read_byte(meleeProof)),
		steamProof 		= features.to_bool(memory.read_byte(steamProof)),
		p7 				= features.to_bool(memory.read_byte(p7)),
		drownProof 		= features.to_bool(memory.read_byte(drownProof))
	}
end

function features.get_godmode(entity)
	local proofs = features.get_entity_proofs(entity)
	return ENTITY._GET_ENTITY_CAN_BE_DAMAGED(entity) == 0 or (proofs.bulletProof and proofs.fireProof and proofs.explosionProof)
end

function features.is_frozen(entity)
	return MISC.IS_BIT_SET(memory.handle_to_pointer(entity) + 0x2E, 1) == 1
end

function features.delete_entity(entity)
	if not entity or entity == PLAYER.PLAYER_ID() or ENTITY.DOES_ENTITY_EXIST(entity) == 0 then return end
	for _, v in ipairs(features.get_all_attachments(entity))
	do
		features.delete_entity(v)
	end
	if ENTITY.IS_ENTITY_A_PED(entity) == 1 then
	  TASK.CLEAR_PED_TASKS_IMMEDIATELY(entity)
	end
	entities.request_control(entity, function()
		ENTITY.SET_ENTITY_COLLISION(entity, false, true)
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
	if STREAMING.IS_MODEL_VALID(hash) == 0 then return hash end
	STREAMING.REQUEST_MODEL(hash)
	return STREAMING.HAS_MODEL_LOADED(hash), hash
end

function features.get_model_dimentions(model)
	local data = cache:get(tostring(model))
	if data then return vector3(data.minimum), vector3(data.maximum) end
	local vec_min = s_memory.alloc(6 * 4)
	local vec_max = s_memory.alloc(6 * 4)
	MISC.GET_MODEL_DIMENSIONS(model, vec_min, vec_max)
	local minimum = s_memory.readv3(vec_min)
	local maximum = s_memory.readv3(vec_max)
	cache:set(tostring(model), {minimum = minimum, maximum = maximum}, 1000)
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
	ped = ped or PLAYER.PLAYER_PED_ID()
	local vec = s_memory.alloc(6 * 4)
	WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(ped, vec)
	return s_memory.readv3(vec)
end

function features.set_bounty(player, amount)
	amount = tonumber(amount) or 10000
	for i = 0, 31
	do	
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) ~= 0 then
			online.send_script_event(i, 1294995624, PLAYER.PLAYER_ID(), player, 1, (amount >= 0 and amount <= 10000) and floor(amount) or 10000, 0, 1,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, globals.get_int(1921039 + 9), globals.get_int(1921039 + 10))
		end
	end
end

function features.crash_player(player)
	if (NETWORK.NETWORK_IS_PLAYER_CONNECTED(player) == 0) or (player == PLAYER.PLAYER_ID()) or (players.crash[player] and players.crash[player] > time()) then return end

	system.log('Imagined Menu', format("Sending crash to %s", online.get_name(player)))
	system.notify('Imagined Menu', format(TRANSLATION["Sending crash to %s"], online.get_name(player)), 255, 50, 0, 255)

	online.send_script_event(player, 962740265, PLAYER.PLAYER_ID(), -72614, 63007, 59027, -12012, -26996, 33398, player)
	online.send_script_event(player, -1386010354, PLAYER.PLAYER_ID(), 2147483647, 2147483647, -72614, 63007, 59027, -12012, -26996, 33398, player)
	online.send_script_event(player, -1386010354, PLAYER.PLAYER_ID(), 2147483647, 2147483647, -788905164)
	online.send_script_event(player, 962740265, PLAYER.PLAYER_ID(), 4294894682, -4294904289, -788905164)
	online.send_script_event(player, 2908956942, PLAYER.PLAYER_ID(), get_random_args(15))
	online.send_script_event(player, 962740265, PLAYER.PLAYER_ID(), get_random_args(15))
	online.send_script_event(player, -1386010354, PLAYER.PLAYER_ID(), get_random_args(15))
	online.send_script_event(player, -1970125962, PLAYER.PLAYER_ID(), get_random_args(15))
	online.send_script_event(player, -1767058336, PLAYER.PLAYER_ID(), get_random_args(15))
	online.send_script_event(player, 1757755807, PLAYER.PLAYER_ID(), get_random_args(15))

	players.crash[player] = time() + 10
end

function features.kick_player(player)
	if (NETWORK.NETWORK_IS_PLAYER_CONNECTED(player) == 0) or (player == PLAYER.PLAYER_ID()) or (players.kick[player] and players.kick[player] > time()) then return end

	system.log('Imagined Menu', format("Kicking %s", online.get_name(player)))
	system.notify('Imagined Menu', format(TRANSLATION["Kicking %s"], online.get_name(player)), 255, 50, 0, 255)

	if NETWORK.NETWORK_IS_HOST() == 1 then
		NETWORK.NETWORK_SESSION_KICK_PLAYER(player)
	else
		local state = 0
		CreateRemoveThread(true, 'player_kick_'..player, function()
			if state == 0 then
				online.send_script_event(player, 1228916411, PLAYER.PLAYER_ID(), globals.get_int(1893551 + (1 + (player * 599) + 510)))
				state = 1
				return
			elseif state == 1 then
				online.send_script_event(player, 927169576, PLAYER.PLAYER_ID(), get_random_args(15))
				online.send_script_event(player, -1308840134, PLAYER.PLAYER_ID(), get_random_args(15))
				online.send_script_event(player, 436475575, PLAYER.PLAYER_ID(), get_random_args(15))
				online.send_script_event(player, -290218924, PLAYER.PLAYER_ID(), get_random_args(15))
				online.send_script_event(player, -368423380, PLAYER.PLAYER_ID(), get_random_args(15))
				online.send_script_event(player, -614457627, PLAYER.PLAYER_ID(), get_random_args(15))
				online.send_script_event(player, -1991317864, PLAYER.PLAYER_ID(), get_random_args(15))
				online.send_script_event(player, 163598572, PLAYER.PLAYER_ID(), 0, 30583, 0, 0, 0, -328966, 2098891836, 0)
				online.send_script_event(player, 998716537, PLAYER.PLAYER_ID(), 1, -1)
				state = 2
				return
			elseif state == 2 then
				online.send_script_event(player, 603406648, PLAYER.PLAYER_ID(), random(32, 2147483647), random(-2147483647, 2147483647), 1, 115, random(-2147483647, 2147483647), random(-2147483647, 2147483647), random(-2147483647, 2147483647))
				online.send_script_event(player, 603406648, PLAYER.PLAYER_ID(), random(-2147483647, -1), random(-2147483647, 2147483647), 1, 115, random(-2147483647, 2147483647), random(-2147483647, 2147483647), random(-2147483647, 2147483647))
			end
		end)
	end
	players.kick[player] = time() + 10
end

return features