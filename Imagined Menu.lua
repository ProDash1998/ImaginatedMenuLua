--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--
VERSION = '1.1.6'

local _insert = table.insert
table.insert = function(t, pos, value)
	if (value == nil) then
		t[#t+1] = pos
	else
		_insert( t, pos, value )
	end
end

-- Global to local
local random = math.random
local floor = math.floor
local rad = math.rad
local abs = math.abs
local sqrt = math.sqrt
local clock = os.clock
local rename = os.rename
local os_time = os.time
local format = string.format
local len = string.len
local gsub = string.gsub
local table_remove = table.remove
local insert = table.insert
local concat = table.concat
local lines = io.lines
local type = type
local select = select
local require = require
local unpack = unpack
local setmetatable = setmetatable
local tonumber = tonumber
local xpcall = xpcall
local tostring = tostring
local ipairs = ipairs
local pairs = pairs
local CUTSCENE = CUTSCENE
local memory = memory
local PATHFIND = PATHFIND
local PHYSICS = PHYSICS
local ZONE = ZONE
local MONEY = MONEY
local EVENT = EVENT
local AUDIO = AUDIO
local INTERIOR = INTERIOR
local FILES = FILES
local NETSHOPPING = NETSHOPPING
local REPLAY = REPLAY
local DATAFILE = DATAFILE
local CLOCK = CLOCK
local BRAIN = BRAIN
local PED = PED
local SCRIPT = SCRIPT
local APP = APP
local CAM = CAM
local PLAYER = PLAYER
local VEHICLE = VEHICLE
local ITEMSET = ITEMSET
local NETWORK = NETWORK
local FIRE = FIRE
local WATER = WATER
local http = http
local LOADINGSCREEN = LOADINGSCREEN
local stat = stat
local STREAMING = STREAMING
local utils = utils
local entities = entities
local globals = globals
local online = online
local ui = ui
local system = system
local WEAPON = WEAPON
local LOCALIZATION = LOCALIZATION
local TASK = TASK
local STATS = STATS
local SOCIALCLUB = SOCIALCLUB
local MISC = MISC
local GRAPHICS = GRAPHICS
local SHAPETEST = SHAPETEST
local RECORDING = RECORDING
local PAD = PAD
local OBJECT = OBJECT
local ENTITY = ENTITY
local DECORATOR = DECORATOR
local DLC = DLC
local HUD = HUD
local MOBILE = MOBILE

system.log('Imagined Menu', format('Loading Imagined Menu v%s...', VERSION))

local function getScriptDir(source)
	source = source and source or debug.getinfo(1).source
  local pwd = source:sub(2)
  return pwd:sub(1,pwd:find("[^\\]*%.lua")-1)
end

paths = {}
paths['Lua'] = getScriptDir()
paths['ImaginedMenu'] = paths['Lua']..[[ImaginedMenu]]
paths['Library'] = paths['ImaginedMenu']..[[\lib]]
paths['Data'] = paths['ImaginedMenu']..[[\data]]
paths['Translations'] = paths['ImaginedMenu']..[[\translations]]
paths['SavedVehicles'] = paths['ImaginedMenu']..[[\saved_vehicles]]
paths["SavedMaps"] = paths["ImaginedMenu"]..[[\saved_maps]]
paths['Cache'] = paths['ImaginedMenu']..[[\cache]]

files = {
	-- Important
	['EntityDb'] = paths['Library']..[[\entity_database.lua]],
	['Features'] = paths['Library']..[[\features.lua]],
	['FileSystem'] = paths['Library']..[[\filesys.lua]],
	['FuelConfig'] = paths['Library']..[[\fuel_consumption.lua]],
	['Json'] = paths['Library']..[[\JSON.lua]],
	['Peds'] = paths['Library']..[[\peds.lua]],
	['String'] = paths['Library']..[[\lua-string.lua]],
	['ScriptMemory'] = paths['Library']..[[\script_memory.lua]],
	['Switch'] = paths['Library']..[[\switch.lua]],
	['Vector3'] = paths['Library']..[[\vector3.lua]],
	['Vehicle'] = paths['Library']..[[\vehicle.lua]],
	['Weapons'] = paths['Library']..[[\weapons.lua]],
	['WorldSaver'] = paths['Library']..[[\world_saver.lua]],
	['WorldSpawner'] = paths['Library']..[[\world_spawner.lua]],

	["TrapStTube"] = paths['Data']..[[\cages\st_tube.json]],
	["TrapStTubeInv"] = paths['Data']..[[\cages\st_tube_inv.json]],
	["TrapCage"] = paths['Data']..[[\cages\cage.json]],
	['Default'] = paths['Data']..[[\default.lua]],
	['Enums'] = paths['Data']..[[\enums.lua]],
	['Inputs'] = paths['Data']..[[\inputs.txt]],
	['ObjectList'] = paths['Data']..[[\objectlist.txt]],
	['PedList'] = paths['Data']..[[\peds.txt]],
	['VehData'] = paths['Data']..[[\vehicle_data.json]],
	['Props'] = paths['Data']..[[\props.lua]],
	['WeaponData'] = paths['Data']..[[\weapons.json]],

	['Cache'] = paths['Cache']..[[\cache.lua]],
	['Dump'] = paths['Cache']..[[\dump.lua]],
	['Halo'] = paths['Cache']..[[\halo.lua]],
	['Loadchunk'] = paths['Cache']..[[\loadchunk.lua]],
	['CacheUtil'] = paths['Cache']..[[\util.lua]],
	['HaloClass'] = paths['Cache']..[[\halo\class.lua]],
	['HaloRegistry'] = paths['Cache']..[[\halo\registry.lua]],
	['HaloUtil'] = paths['Cache']..[[\halo\util.lua]],
	['Inmem'] = paths['Cache']..[[\lib\inmem.lua]],
	['UtilIs'] = paths['Cache']..[[\util\is.lua]],
	['UtilString'] = paths['Cache']..[[\util\string.lua]],
	['UtilTable'] = paths['Cache']..[[\util\table.lua]],
	['UtilTypeof'] = paths['Cache']..[[\util\typeof.lua]],

	['TimeToBurn'] = paths['ImaginedMenu']..[[\time_to_burn.wav]]
}

local files = files
local paths = paths

local function FileCheck()
	system.log("Imagined Menu", "Checking files...")
	local missing = {}
	local function exists(file)
	    local ok, err, code = rename(file, file)
	    if not ok and code == 13 then
	        return true
	    end
	    return ok, err
	end

	for k, v in pairs(files)
	do
		if not exists(v) then
			insert(missing, v)
		end
	end

	if #missing == 0 then return end
	error('Missing files found:\n'..concat(missing, "\n"), 0)
end
FileCheck()

files['Config'] = paths['ImaginedMenu']..[[\config.json]]
files['VehicleBlacklist'] = paths['ImaginedMenu']..[[\vehicle_blacklist.json]]
files['PlayerExcludes'] = paths['ImaginedMenu']..[[\player_excludes.json]]
files['SavedLocations'] = paths['ImaginedMenu']..[[\saved_locations.json]]

package.path = package.path..";"..paths['Library']..[[\?.lua]]
package.path = package.path..";"..paths['Data']..[[\?.lua]]
package.path = package.path..";"..paths['Cache']..[[\?.lua]]

local inmem = require('lib.inmem')
require 'lua-string'
cache = inmem.new(30)
local cache = cache
local json = require 'JSON'
local TRANSLATION = require('default').translation
local settings = require('default').settings
local features = require 'features'
local switch = require 'switch'
local s_memory = require 'script_memory'
local vehicles = require 'vehicle'
local peds = require 'peds'
local objects = require 'props'
local enum = require 'enums'
local vector3 = require 'vector3'
local filesystem = require 'filesys'
local EntityDb = require 'entity_database'
local world_spawner = require 'world_spawner'
local world_saver = require 'world_saver'
local fuelConsumption = require 'fuel_consumption'
local weapons = require 'weapons'

cache:set('Default config', settings, 1000000)

local notify_og = system.notify

system.notify = function(prefix, text, r, g, b, a, sound)
	if settings.General["DisableNotifications"] then return end
	if settings.General["NotificationSound"] and sound then AUDIO.PLAY_SOUND_FRONTEND(-1, "GOLF_EAGLE", "HUD_AWARDS", true) end
	notify_og(prefix, text, r, g, b, a)
end

if not filesystem.isdir(paths['Translations']) then
	filesystem.make_dir(paths['Translations'])
end

if not filesystem.isdir(paths['SavedVehicles']) then
	filesystem.make_dir(paths['SavedVehicles'])
end

local __submenus = {}
local __suboptions = {}
local __options = {
	bool = {},
	click = {},
	num = {},
	choose = {},
	players = {},
	color = {},
	string = {}
}

local gRunning = true
local POP_THREAD = 0
local threads = {}
local thread_queue = {}
local active_threads = 0
thread_count = 0
local thread_count = thread_count
local ticks = {}
local ticktime = 0
local avgticktime = 0
local created_preview
local created_preview2
local playerlist = {}
local saved_locations = {}
local vehicle_blips = {}
local _getting_avg_tick
local function GetAvgTickTimes()
	_getting_avg_tick = true
	system.log('Imagined Menu', 'Collecting tick times...')
	local tick_times = {}
	CreateRemoveThread(true, 'getting_avg_tick_time_'..thread_count, 
	function(tick)
		if tick ~= 100 then
			insert(tick_times, ticktime)
		else
			system.log('Imagined Menu', format('Avarage tick time: %.3fs', (features.sum_table(tick_times) / #tick_times)))
			_getting_avg_tick = false
			return POP_THREAD
		end
	end, true, true)
end

-- features
function CreateRemoveThread(...)
	local add, name, func, canqueue, highpriority = ...
	active_threads = 0
	for _ in pairs(threads) do
		active_threads = active_threads + 1
	end
	name = tostring(name)
	if add then
		thread_count = thread_count + 1
		threads[name] = {func, clock()}
		active_threads = active_threads + 1
	else 
		if not threads[name] then return false end
		threads[name] = nil
		active_threads = active_threads - 1
	end
	ticks[name] = nil
	return true
end

local Instructional = {}
function Instructional:New()
	if GRAPHICS.HAS_SCALEFORM_MOVIE_LOADED(self.scaleform) == 1 then
		GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(self.scaleform, "CLEAR_ALL")
		GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
    GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(self.scaleform, "TOGGLE_MOUSE_BUTTONS")
		GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_BOOL(true)
		GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
		self.pos = 0
    return true
	else
		self.scaleform = GRAPHICS.REQUEST_SCALEFORM_MOVIE("INSTRUCTIONAL_BUTTONS")
		return
  end
end

function Instructional:BackgroundColor(r, g, b, a)
	GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(self.scaleform, "SET_BACKGROUND_COLOUR")
	GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(r)
	GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(g)
	GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(b)
	GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(a)
	GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
end

function Instructional:SetDataSlot(control, name, button)
	GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(self.scaleform, "SET_DATA_SLOT")
	GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(self.pos)
	GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_PLAYER_NAME_STRING(button)
	GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING(name)
	GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_BOOL(false)
	GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_INT(control)
	GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
	self.pos = self.pos + 1
end

function Instructional.AddButton(control, name)
	local button = PAD.GET_CONTROL_INSTRUCTIONAL_BUTTON(2, control, true)
  Instructional:SetDataSlot(control, name, button)
end

function Instructional:Draw()
	GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(self.scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
	GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
  GRAPHICS.DRAW_SCALEFORM_MOVIE_FULLSCREEN(self.scaleform, 255, 255, 255, 255, 0)
	self.pos = 0
end

local blockobjects = {}
local function BlockArea(object, x, y, z, rotx, roty, rotz, invisible)
	CreateRemoveThread(true, 'request_model_'..thread_count, function()
	  	if features.request_model(object) == 0 then return end
	    local obj = features.create_object(object, vector3(x, y, z))
	    if obj == 0 then return POP_THREAD end
	    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, false, true)
	    ENTITY._SET_ENTITY_CLEANUP_BY_ENGINE(obj, true)
	    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(obj, x, y, z, false, false, false)
	    ENTITY.SET_ENTITY_ROTATION(obj, rotx, roty, rotz, 5, true)
	    ENTITY.FREEZE_ENTITY_POSITION(obj, true)
	    insert(blockobjects, obj)
	    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(object)
	    if not invisible then return POP_THREAD end
	    ENTITY.SET_ENTITY_VISIBLE(obj, false, false)
	   	return POP_THREAD
	end)
end

local function PlaySound(name, ref, entity)
	local entity = entity or features.player_ped()
	AUDIO.PLAY_SOUND_FROM_ENTITY(-1, name, entity, ref, true, 0)
end

local function StopSounds()
	for i = 0, 100
	do
		AUDIO.STOP_SOUND(i)
	end
end

local function BlockPassive(type)
	for i = 0, 31 do
		if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
			online.send_script_event(i, 65268844, PLAYER.PLAYER_ID(), type)
			-- system.log('debug', "Script event sent to "..online.get_name(i))
		end
	end
end

local function InfiniteInvite(type)
	local found
	for i = 0, 31 do
		if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
	      	online.send_script_event(i, -1390976345, PLAYER.PLAYER_ID(), i, 4294967295, 1, 115, type, type, type)
	      	found = true
	      	-- system.log('debug', "Script event sent to "..online.get_name(i))
      	end
  	end
  	return found
end

local function AskingForMoney(message)
	local text = message:strip():lower()
	for _, v in ipairs(enum.begger_messages)
	do
		if text:find(v) then
			return true
		end
	end
	return false
end

local dont_play_tog
local function HudSound(name)
	if not settings.General["HudSounds"] or (features.compare(name, "TOGGLE_ON", "YES") and dont_play_tog) then return end
	CreateRemoveThread(true, 'play_hud_sound', function()
		AUDIO.PLAY_SOUND_FRONTEND(-1, name, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
		return POP_THREAD
	end)
end

local commad_prefix = {[0]='nf!','/','\\','!','$','%','&','-','+','?','*',',','.','#','€','@'}
local function IsCommand(command)
	if command:lower():find(format('^%s', commad_prefix[settings.Commands['CommandsPrefix']]:escpattern())) then return true end
end

-- commands
local cmd = {
	spawn = function(id, veh)
		if not veh then return end
		CreateRemoveThread(true, 'cmd_spawn_'..thread_count, function(tick)
			if tick==3000 then return POP_THREAD end
			local loaded, hash = features.request_model(veh)
			if hash == 0 then return POP_THREAD end
			if STREAMING.IS_MODEL_A_VEHICLE(hash) == 0 then return POP_THREAD end
			if settings.Session["VehicleBlacklist"] and vehicle_blacklist.vehicles[tostring(hash)] then system.notify(TRANSLATION["Imagined Menu"], format(TRANSLATION["Player %s tried to spawn a blacklisted vehicle"], online.get_name(id)), 255, 0, 0, 255) return POP_THREAD end
			if loaded == 0 then return end
			local target = features.get_offset_coords_from_entity_rot(
				features.player_ped(id), 
				6, 0, true)
			local vehicle = vehicles.spawn_vehicle(hash, target, features.get_player_heading(id))
			if vehicle == 0 then return POP_THREAD end
			entities.request_control(vehicle, function() 
				-- DECORATOR.DECOR_SET_INT(vehicle, "MPBitset", 1024)
				VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, "Nightfal")
			end)
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
			return POP_THREAD
		end)
	end,
	freeze = function(id, pl, bool) 
		local target = features.player_from_name(pl)
		if not target then return end
		if (target == PLAYER.PLAYER_ID()) or (settings.Commands["Don't Affect Friends"] and features.is_friend(target)) or (NETWORK.NETWORK_IS_PLAYER_CONNECTED(target) == 0) or features.is_excluded(target) then return end
		if bool and bool:tobool() == false then
			playerlist[target]["Freeze"] = false
		else
			playerlist[target]["Freeze"] = true
		end
	end,
	island = function(id, pl)
		local target = features.player_from_name(pl)
		CreateRemoveThread(true, 'cmd_island_'..id, function()
			if (not target) or (settings.Commands["Don't Affect Friends"] and features.is_friend(target)) or features.is_excluded(target) --[=[or (i == id)]=] then return POP_THREAD end
			online.send_script_event(target, 1361475530, PLAYER.PLAYER_ID(), 1)
			return POP_THREAD
		end)
	end,
	kick = function(id, pl) 
		local target = features.player_from_name(pl)
		if not target then return end
		CreateRemoveThread(true, 'cmd_kick_'..id, function()
			if (not target) or (settings.Commands["Don't Affect Friends"] and features.is_friend(target)) or features.is_excluded(target) --[=[or (i == id)]=] then return POP_THREAD end
			features.kick_player(target)
			return POP_THREAD
		end)
	end,
	crash = function(id, pl) 
		local target = features.player_from_name(pl)
		CreateRemoveThread(true, 'cmd_crash_'..id, function()
			if (not target) or (settings.Commands["Don't Affect Friends"] and features.is_friend(target)) or features.is_excluded(target) --[=[or (i == id)]=] then return POP_THREAD end
			features.crash_player(target)
			return POP_THREAD
		end)
	end,
	explode = function(id, pl) 
		local target = features.player_from_name(pl)
		CreateRemoveThread(true, 'cmd_explode_'..id, function()
			if (not target) or (target == PLAYER.PLAYER_ID()) or (settings.Commands["Don't Affect Friends"] and features.is_friend(target)) or features.is_excluded(target) --[=[or (i == id)--]=] then return POP_THREAD end
			local pos = features.get_player_coords2(target)
			FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, enum.explosion.ROCKET, 10, true, false, 1.0, false)
			return POP_THREAD
		end)
	end,
	kickAll = function(id) 
		CreateRemoveThread(true, 'cmd_kickall_'..id, function()
			for i = 0, 31 do
				if not (settings.Commands["Don't Affect Friends"] and features.is_friend(i)) and (i ~= id) and (i ~= PLAYER.PLAYER_ID()) and not features.is_excluded(i) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 then
					features.kick_player(i)
				end
			end
			return POP_THREAD
		end)
	end,
	crashAll = function(id) 
		CreateRemoveThread(true, 'cmd_crashall_'..id, function()
			for i = 0, 31 do
				if not (settings.Commands["Don't Affect Friends"] and features.is_friend(i)) and (i ~= id) and (i ~= PLAYER.PLAYER_ID()) and not features.is_excluded(i) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 then
					features.crash_player(i)
				end
			end
			return POP_THREAD
		end)
	end,
	explodeAll = function(id) 
		CreateRemoveThread(true, 'cmd_explodeall_'..id, function()
			for i = 0, 31 do
				if not (settings.Commands["Don't Affect Friends"] and features.is_friend(i)) and (i ~= id) and (i ~= PLAYER.PLAYER_ID()) and not features.is_excluded(i) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 then
					local pos = features.get_player_coords2(i)
					FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, enum.explosion.ROCKET, 10, true, false, 1.0, false)
				end
			end
			return POP_THREAD
		end)
	end,
	clearwanted = function(id, bool) 
		CreateRemoveThread(true, 'cmd_clearwanted_'..id, function(tick)
			if tick%5~=0 then return end
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(id) == 0 or (bool and bool:tobool() == false) then return POP_THREAD end
			online.send_script_event(id, 1449852136, PLAYER.PLAYER_ID(), globals.get_int(1892703 + (1 + (id * 599) + 510)))
			online.send_script_event(id, -1041523091, PLAYER.PLAYER_ID(), 0, 0, NETWORK.GET_NETWORK_TIME(), 0, globals.get_int(1892703 + (1 + (id * 599) + 510)))
		end)
	end,
	offradar = function(id, bool) 
		CreateRemoveThread(true, 'cmd_offradar_'..id, function(tick)
			if tick%5~=0 then return end
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(id) == 0 or (bool and bool:tobool()) then return POP_THREAD end
			online.send_script_event(id, -1973627888, PLAYER.PLAYER_ID(), NETWORK.GET_NETWORK_TIME() - 60, NETWORK.GET_NETWORK_TIME(), 1, 1, globals.get_int(1892703 + (1 + (id * 599) + 510)))
		end)
	end,
	vehiclegod = function(id, bool) 
		CreateRemoveThread(true, 'cmd_vehiclegod_'..id, function()
			local value = true
			if bool then
				if bool:tobool() == false then value = false end
			end
			local veh = vehicles.get_player_vehicle(id)
			if veh == 0 then return POP_THREAD end
			entities.request_control(veh, function() vehicles.set_godmode(veh, value) end)
			return POP_THREAD
		end)
	end,
	upgrade = function(id) 
		CreateRemoveThread(true, 'cmd_upgrade_'..id, function()
			local veh = vehicles.get_player_vehicle(id)
			if veh == 0 then return POP_THREAD end
			entities.request_control(veh, function() vehicles.upgrade(veh) end)
			return POP_THREAD
		end)
	end,
	repair = function(id) 
		CreateRemoveThread(true, 'cmd_repair_'..id, function()
			local veh = vehicles.get_player_vehicle(id)
			if veh == 0 then return POP_THREAD end
			entities.request_control(veh, function() vehicles.repair(veh) end)
			return POP_THREAD
		end)
	end,
	freezeall = function(id, bool)
		for i = 0, 31
		do
			if not (settings.Commands["Don't Affect Friends"] and features.is_friend(i)) and (i ~= id) and (i ~= PLAYER.PLAYER_ID()) and not features.is_excluded(i) then
				playerlist[id]["Freeze"] = bool == 'off' and false or true
			end
		end
	end,
	bounty = function(id, pl, amount)
		local target = features.player_from_name(pl)
		CreateRemoveThread(true, 'cmd_bounty_'..id, function()
			if (not target) or (target == PLAYER.PLAYER_ID()) or (settings.Commands["Don't Affect Friends"] and features.is_friend(target)) or features.is_excluded(target) --[=[or (i == id)--]=] then return POP_THREAD end
			local amount = (amount and tonumber(amount)) or 10000
			features.set_bounty(pl, amount)
			return POP_THREAD
		end)
	end,
	bountyall = function(id, amount)
		CreateRemoveThread(true, 'cmd_bountyall', function()
			local amount = (amount and tonumber(amount)) or 10000
			for i = 0, 31
			do
				if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.Commands["Don't Affect Friends"] and features.is_friend(i)) and (i ~= id) and (i ~= PLAYER.PLAYER_ID()) and not features.is_excluded(i) then
					features.set_bounty(i, amount)
				end
			end
			return POP_THREAD
		end)
	end,
	apartment = function(id, pl, apart)
		local target = features.player_from_name(pl)
		local apart = (apart and tonumber(apart) and tonumber(apart) > 0 and tonumber(apart) < 115) and floor(tonumber(apart)) or 1
		CreateRemoveThread(true, 'cmd_explode_'..id, function()
			if (not target) or (settings.Commands["Don't Affect Friends"] and features.is_friend(target)) or features.is_excluded(target) --[=[or (i == id)]=] then return POP_THREAD end
			online.send_script_event(target, -1390976345, PLAYER.PLAYER_ID(), target, 1, 0, apart, 1, 1, 1)
			return POP_THREAD
		end)
	end,
	killaliens = function(id, bool)
		dont_play_tog = true
		ui.set_value(__options.bool["KillAliens"], bool == 'off' and false or true, false)
	end,
	kickbarcodes = function(id, bool)
		dont_play_tog = true
		ui.set_value(__options.bool["KickBarcodes"], bool == 'off' and false or true, false)
	end,
	gift = function(id)
		local veh = vehicles.get_player_vehicle(id)
		if veh == 0 then return end
		entities.request_control(veh, function()
			local pl_veh
			DECORATOR.DECOR_REGISTER("Player_Vehicle", 3)
			DECORATOR.DECOR_REGISTER("Previous_Owner", 3)
			DECORATOR.DECOR_REGISTER("Vehicle_Reward", 3)
			DECORATOR.DECOR_REGISTER("MPBitset", 3)
			DECORATOR.DECOR_REGISTER("Veh_Modded_By_Player", 3)
			if ENTITY.IS_ENTITY_VISIBLE(veh) == 1 then
				if DECORATOR.DECOR_EXIST_ON(veh, "Player_Vehicle") == 1 then
					DECORATOR.DECOR_SET_INT(veh, "Player_Vehicle", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(id))
				else
					pl_veh = DECORATOR.DECOR_GET_INT(veh, "Player_Vehicle")
					DECORATOR.DECOR_SET_INT(veh, "Player_Vehicle", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(id))
				end
				if pl_veh and pl_veh ~= -1 then
					DECORATOR.DECOR_SET_INT(veh, "Previous_Owner", pl_veh)
				end
			end
			if DECORATOR.DECOR_EXIST_ON(veh, "Player_Vehicle") == 0 then
				DECORATOR.DECOR_SET_BOOL(veh, "Vehicle_Reward", true)
				DECORATOR.DECOR_SET_INT(veh, "Vehicle_Reward", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(id))
			end
			local veh_modd = DECORATOR.DECOR_GET_INT(veh, "Veh_Modded_By_Player")
			if veh_modd ~= 0 and veh_modd ~= -1 then
				DECORATOR.DECOR_SET_INT(veh, "Veh_Modded_By_Player", -1)
			end
			VEHICLE.SET_VEHICLE_CAN_SAVE_IN_GARAGE(veh, true)
			VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, true)
			VEHICLE.SET_VEHICLE_IS_STOLEN(veh, false)
		end)
	end,
}

local DoCommand = switch()
	:case('spawn', function(id, command)
		cmd.spawn(id, command[2])
		return true
	end)
	:case('freeze', function(id, command)
		cmd.freeze(id, command[2], command[3])
		return true
	end)
	:case('island', function(id, command)
		cmd.island(id, command[2])
		return true
	end)
	:case('kick', function(id, command)
		cmd.kick(id, command[2])
		return true
	end)
	:case('crash', function(id, command)
		cmd.crash(id, command[2])
		return true
	end)
	:case('explode', function(id, command)
		cmd.explode(id, command[2])
		return true
	end)
	:case('kickall', function(id, command)
		cmd.kickAll(id)
		return true
	end)
	:case('crashall', function(id, command)
		cmd.crashAll(id)
		return true
	end)
	:case('explodeall', function(id, command)
		cmd.explodeAll(id)
		return true
	end)
	:case('clearwanted', function(id, command)
		cmd.clearwanted(id, command[2])
		return true
	end)
	:case('offradar', function(id, command)
		cmd.offradar(id, command[2])
		return true
	end)
	:case('vehiclegod', function(id, command)
		cmd.vehiclegod(id, command[2])
		return true
	end)
	:case('upgrade', function(id, command)
		cmd.upgrade(id)
		return true
	end)
	:case('repair', function(id, command)
		cmd.repair(id)
		return true
	end)
	:case('freezeall', function(id, command)
		cmd.freezeall(id, command[2])
		return true
	end)
	:case('bounty', function(id, command)
		cmd.bounty(id, command[2], command[3])
		return true
	end)
	:case('bountyall', function(id, command)
		cmd.bountyall(id, command[2])
		return true
	end)
	:case('apartment', function(id, command)
		cmd.apartment(id, command[2], command[3])
		return true
	end)
	:case('killaliens', function(id, command)
		cmd.killaliens(id, command[2])
		return true
	end)
	:case('kickbarcodes', function(id, command)
		cmd.kickbarcodes(id, command[2])
		return true
	end)
	:case('gift', function(id, command)
		cmd.gift(id)
		return true
	end)

local function HandleCommand(command, id)
	if settings.Dev.Enable then system.log('debug', format('command from %i', id)) end
	return DoCommand(command[1], id, command)
end

-- callbacks

function on_votekick(ply, target)
	if settings.Dev.Enable then system.log('debug', 'votekick recived...') end
	if target == PLAYER.PLAYER_ID() then
		if (features.is_friend(ply) and settings.General['Exclude Friends']) or features.is_excluded(ply) then return end
		if settings.Misc.OnVotekickSendChat then
			CreateRemoveThread(true, 'vote_kick_'..thread_count, function()
				online.send_chat("I tried to votekick a Nightfall user!", false, ply)
				return POP_THREAD
			end)
		end
		if settings.Misc.OnVotekickCrash then
			CreateRemoveThread(true, 'vote_kick_'..thread_count, function()
				features.crash_player(ply)
				return POP_THREAD
			end)
		end
		if settings.Misc.OnVotekickKick then
			CreateRemoveThread(true, 'vote_kick_'..thread_count, function()
				features.kick_player(ply)
				return POP_THREAD
			end)
		end
	end
end

function on_report(ply, reason)
	if settings.Dev.Enable then system.log('debug', 'report recived...') end
	if (features.is_friend(ply) and settings.General['Exclude Friends']) or features.is_excluded(ply) then return end
	if settings.Misc.OnReportSendChat then
		CreateRemoveThread(true, 'report_'..thread_count, function()
			online.send_chat("I tried to report a Nightfall user! Reason: "..reason, false, ply)
			return POP_THREAD
		end)
	end
	if settings.Misc.OnReportCrash then
		CreateRemoveThread(true, 'report_'..thread_count, function()
			features.crash_player(ply)
			return POP_THREAD
		end)
	end
	if settings.Misc.OnReportKick then
		CreateRemoveThread(true, 'report_'..thread_count, function()
			features.kick_player(ply)
			return POP_THREAD
		end)
	end
end


local SimplifiedCommand = switch()
	:case('kill', function()
		return 'explode'
	end)
	:case('killa', function()
		return 'explodeall'
	end)
	:case('nocop', function()
		return 'clearwanted'
	end)
	:case('ghost', function()
		return 'offradar'
	end)
	:case('god', function()
		return 'vehiclegod'
	end)
	:case('vaca', function()
		return 'island'
	end)
	:case('sp', function()
		return 'spawn'
	end)
	:case('rep', 'fix', function()
		return 'repair'
	end)
	:case('upg', function()
		return 'upgrade'
	end) 
	:case('bye', function()
		return 'crash'
	end)
	:case('byea', function()
		return 'crashall'
	end)
	:case('nomove', function()
		return 'freeze'
	end)
	:case('leave', function()
		return 'kick'
	end)
	:case('plsleave', function()
		return 'kickall'
	end)
	:case('nomovea', function()
		return 'freezeall'
	end)
	:case('hunt', function()
		return 'bounty'
	end)
	:case('hunta', function()
		return 'bountyall'
	end)
	:case('apa', function()
		return 'apartment'
	end)
	:case('nogay', function()
		return 'killaliens'
	end)
	:case('lz', function()
		return 'kickbarcodes'
	end)

local BeggerPunishment = switch()
	:case(1, function(id)
		CreateRemoveThread(true, 'begger_punishment_'..thread_count, function()
			local pos = features.get_player_coords2(id)
			local veh = vehicles.get_player_vehicle(id)
			if veh ~= 0 then
				entities.request_control(veh, function()
					vehicles.set_godmode(veh, false)
					NETWORK.NETWORK_EXPLODE_VEHICLE(veh, true, false, id)
				end)
			end
			FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, enum.explosion.ROCKET, 10, false, false, 1.0, false)
			return POP_THREAD
		end)
	end)
	:case(2, function(id)
		playerlist[id]["Freeze"] = true
	end)
	:case(3, function(id)
  		CreateRemoveThread(true, 'begger_punishment_'..thread_count, function()
			features.kick_player(id)
			return POP_THREAD
		end)
	end)
	:case(4, function(id)
		CreateRemoveThread(true, 'begger_punishment_'..thread_count, function()
			features.crash_player(id)
			return POP_THREAD
		end)
	end)

function on_script_event(ply, event_id, args)
	if __options.bool["DebugSELog"] and ui.get_value(__options.bool["DebugSELog"]) then
		system.log("SE", string.format("Recived script event from: %s | args [%i]: %s", online.get_name(ply), #args, table.concat(args, ", ")))
	end
end

function on_chat_message(...)
	local id, is_team, text, spoofed_as_ply = ... 
	if settings.Misc["LogChat"] then
		system.log(format("Chat|%s", is_team and 'Team' or 'All'), format("%s wrote: %s", online.get_name(id), text))
	end
	if settings.Session["PunishBeggers"] ~= 0 and spoofed_as_ply == -1 and AskingForMoney(text) then
  	if not (settings.General["Exclude Friends"] and features.is_friend(id)) and not features.is_excluded(id) then
	    BeggerPunishment(settings.Session["PunishBeggers"], id)
    end
  end

  if spoofed_as_ply == -1 and IsCommand(text) then
  	local text = text:lower():gsub(format('^%s', commad_prefix[settings.Commands['CommandsPrefix']]:escpattern()), '')
  	if settings["Commands"]["Friends Only"] and not features.is_friend(id) and not playerlist[id].Commands then return true end
  	local command = text:split('%s+', true)
  	command[1] = SimplifiedCommand(command[1]) or command[1]
  	if not settings["Commands"]['cmd_'..command[1]] then return true end
  	if HandleCommand(command, id) then 
  		system.log('Imagined Menu', format("Player %s requested command %s", online.get_name(id), command[1]))
  		system.notify(TRANSLATION['Chat command'], format(TRANSLATION["Player %s requested command %s"], online.get_name(id), command[1]), 100, 0, 255, 255)
  	end
  elseif (settings.Session["ChatMocker"] and not (settings.General["Exclude Friends"] and features.is_friend(id)) and not features.is_excluded(id)) or playerlist[id].ChatMock then
  	local message = {}
  	for i = 1, len(text)
  	do
  		local character = text[i]
  		message[i] = i%2 ~= 0 and character:lower() or character:upper()
  	end
  	local id = settings.Session["MockerSpoof"] and id or -1
  	online.send_chat(concat(message, ""), false, id)
  end
end

local TRANSLATION_FILES = filesystem.scandir(paths['Translations'])

for i, v in ipairs(TRANSLATION_FILES)
do
	if not v:endswith('.json') then
		table_remove(TRANSLATION_FILES, i)
	else
		rename(paths['Translations']:ensureend('\\')..v, paths['Translations']:ensureend('\\')..v:lower())
	end
end

local function GetLanguage()
	local languages = {
		[0] = 'english.json',
		'french.json',
		'german.json',
		'italian.json',
		'spanish.json',
		'brazilian.json',
		'polish.json',
		'russian.json',
		'korean.json',
		'chinese.json',
		'japanese.json',
		'mexican.json',
		'simplified_chinese.json'
	}
	local curr_lang = LOCALIZATION.GET_CURRENT_LANGUAGE()
	if curr_lang and (curr_lang >= 0 and curr_lang <= 12) then
		return languages[curr_lang]
	end
	return languages[0]
end

local function SaveConfig()
	if settings.Dev.Enable then system.log('debug', 'saving config...') end
	local config = {}
	local default = cache:get('Default config')
	for k, v in pairs(settings) do
		for e, i in pairs(v) do
			if i ~= default[k][e] and not features.is_table_empty(i) then
				if not config[k] then
					config[k] = {}
				end
				config[k][e] = i
			end
		end
	end
	filesystem.write(json:encode_pretty(config), files['Config'])
end

--settings
local function LoadConfig()
	if settings.Dev.Enable then system.log('debug', 'loading config...') end
  if settings.General.Translation:isempty() then
  	settings.General.Translation = GetLanguage()
  end
	if not filesystem.exists(files['Config']) then return end
	local new = json:decode(filesystem.read_all(files['Config']))
  if new and new ~= '' then
	  for k, v in pairs(new) do
	  	for i, e in pairs(v) do
	  		if settings[k] and settings[k][i] ~= nil then
	  			settings[k][i] = e
	  		end
	  	end
	  end
	  system.log('Imagined Menu', 'Default config loaded')
  end
  SaveConfig()
end
LoadConfig()

if settings.Dev.Enable then system.log('debug', 'config loaded') end

if not filesystem.exists(files['Config']) then SaveConfig() end

local function LoadConfTog(conf)
	dont_play_tog = true
	for _, v in pairs(conf) do
		for i, x in pairs(v) do
			if type(x) == 'boolean' and __options.bool[i] then
				ui.set_value(__options.bool[i], x, false)
				-- ui.set_value(__options.bool[i], x, true)
			elseif type(x) == 'number' then
				if __options.num[i] then
					ui.set_value(__options.num[i], x, false)
					-- ui.set_value(__options.num[i], x, true)
				end
				if __options.choose[i] then
					ui.set_value(__options.choose[i], x, false)
					-- ui.set_value(__options.choose[i], x, true)
				end
			elseif type(x) == 'table' and x.r and x.g and x.b and x.a then
				ui.set_value(__options.color[i], x.r, x.g, x.b, x.a, false)
			elseif i == "BlockInput" and type(x) == 'table' then
				for _, e in pairs(x)
				do
					if __options.bool["INPUT_"..e] then
						ui.set_value(__options.bool["INPUT_"..e], true, true)
					end
				end
			elseif i == 'Translation' and type(x) == 'string' and not x:isempty() then
				for e, v in pairs(TRANSLATION_FILES) do
					if v == x then
						ui.set_value(__options.choose[i], e-1, true)
						break
					end
				end
			elseif type(x) == 'string' then
				if __options.string[i] then
					ui.set_value(__options.string[i], x, false)
				end
			end
		end
	end
end

local function SaveTranslation()
	filesystem.write(json:encode_pretty(TRANSLATION), paths['Translations']:ensureend('\\')..settings.General.Translation)
end

local function LoadTranslations()
	local deftrans = settings.General.Translation
	if not deftrans or deftrans:isempty() then settings.General.Translation = GetLanguage() end
	if (#filesystem.scandir(paths['Translations']) == 0) or (not filesystem.exists(paths['Translations']:ensureend('\\')..settings.General.Translation)) then
		system.notify(TRANSLATION["Imagined Menu"], format('No translation found for your language! You can translate the %s file if you want :)', settings.General.Translation), 255, 128, 0, 255)
		system.log('Imagined Menu', format('Translation %s not found!', settings.General.Translation))
		SaveTranslation()
		return
	end

	local new = json:decode(filesystem.read_all(paths['Translations']:ensureend('\\')..settings.General.Translation))
    if not new then return end
    for k, v in pairs(new) do
    	if type(v) == 'table' then
    		if v.Credits then 
    			TRANSLATION[1].Credits = v.Credits
    		end
    		if v.Language then 
    			TRANSLATION[1].Language = v.Language
    		end
			elseif TRANSLATION[k] then
				TRANSLATION[k] = v
			end
    end

    SaveTranslation()
    if not TRANSLATION[1].Credits:isempty() then
    	system.log('Imagined Menu', TRANSLATION[1].Language..' translation loaded, made by '..TRANSLATION[1].Credits)
    end
end
if settings.Dev.Enable then system.log('debug', 'loading translations...') end
LoadTranslations()

local function SaveLocations()
	filesystem.write(json:encode_pretty(saved_locations), files['SavedLocations'])
end

local function LoadLocations()
	if not filesystem.exists(files['SavedLocations']) then return end
	saved_locations = json:decode(filesystem.read_all(files['SavedLocations']))
	system.log('Imagined Menu', format(TRANSLATION["Saved locations found %s"], #saved_locations))
end
LoadLocations()

local uc_finished
function check_for_updates()
	local URL = [[https://raw.githubusercontent.com/ProDash1998/ImaginatedMenuLua/main/version]]
	http.get(URL, function(content, header, response_code)
		uc_finished = true
		if not content or content:isempty() or type(content) ~= 'string' then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Failed to check for updates"], 255, 0, 0, 255, true) return end
		local success, char = content:find('\n')
		if not success then return end
		local content = content:sub(1, char-1)
		if content == VERSION then
			return
		end
		CreateRemoveThread(true, 'add_download_button', function()
			system.log('Imagined Menu', format('New version available: %s', content))
			system.notify('Imagined Menu', format(TRANSLATION['New version available: %s'], content), 0, 255, 0, 255, true)
			__options.click["Download"] = ui.add_click_option(TRANSLATION["Go to download"]..' »', __submenus["MainSub"], function()
				HudSound("SELECT")
				filesystem.open([[https://github.com/ProDash1998/ImaginatedMenuLua/releases/tag/]]..content)
			end)
			return POP_THREAD
		end)
	end)
end

if http.is_enabled() then
	system.log('Imagined Menu', 'Checking for updates...')
	check_for_updates()
else
	time = clock() + 11
	CreateRemoveThread(true, thread_count, function()
		if time > clock() then return end
		system.notify('Imagined Menu', TRANSLATION['Enable "Allow http" to check for updates'], 0, 128, 255, 255, true)
		return POP_THREAD
	end)
	uc_finished = true
end

if settings.Dev.Enable then system.log('debug', 'update check') end

while not uc_finished
do
	system.yield()
end

local vehicle_blacklist = {}
vehicle_blacklist.vehicles = {}
vehicle_blacklist.options = {}

function vehicle_blacklist.add_option_vehicle(hash, model, v_kick, v_max_speed, v_expl, v_del, v_laun, killzone, kick, crash)
	if vehicle_blacklist.options[hash] or not __submenus["BlacklistedVehicles"] then if settings.Dev.Enable then system.log('debug', 'adding blacklist option fail') end return end
	local name = vehicles.get_label_name(model)
	local sub = ui.add_submenu(name)
	vehicle_blacklist.options[hash] = {
		sub_menu = sub,
		sub_option = ui.add_sub_option(name, __submenus["BlacklistedVehicles"], sub),
		remove = ui.add_click_option(TRANSLATION["Remove"], sub, function() CreateRemoveThread(true, 'veh_bl_remove', function(tick) if tick < 10 then return end HudSound("SELECT") vehicle_blacklist.remove(hash);vehicle_blacklist.remove_option_vehicle(hash);vehicle_blacklist.save() return POP_THREAD end) end),
		separator = ui.add_separator(TRANSLATION["Reactions"], sub),
		opt_v_kick = ui.add_bool_option(TRANSLATION["Kick from vehicle"], sub, function(bool) HudSound("TOGGLE_ON") vehicle_blacklist.vehicles[hash].vehicle_kick = bool;vehicle_blacklist.save() end),
		opt_v_max_speed = ui.add_bool_option(TRANSLATION["Limit max speed"], sub, function(bool) HudSound("TOGGLE_ON") vehicle_blacklist.vehicles[hash].set_max_speed = bool;vehicle_blacklist.save() end),
		opt_v_expl = ui.add_bool_option(TRANSLATION["Explode vehicle"], sub, function(bool) HudSound("TOGGLE_ON") vehicle_blacklist.vehicles[hash].vehicle_explode = bool;vehicle_blacklist.save() end),
		opt_v_del = ui.add_bool_option(TRANSLATION["Delete vehicle"], sub, function(bool) HudSound("TOGGLE_ON") vehicle_blacklist.vehicles[hash].vehicle_delete = bool;vehicle_blacklist.save() end),
		opt_v_laun = ui.add_bool_option(TRANSLATION["Launch vehicle"], sub, function(bool) HudSound("TOGGLE_ON") vehicle_blacklist.vehicles[hash].vehicle_launch = bool;vehicle_blacklist.save() end),
		opt_tp_killzone = ui.add_bool_option(TRANSLATION["Teleport to kill zone"], sub, function(bool) HudSound("TOGGLE_ON") vehicle_blacklist.vehicles[hash].tp_killzone = bool;vehicle_blacklist.save() end),
		opt_kick = ui.add_bool_option(TRANSLATION["Kick player"], sub, function(bool) HudSound("TOGGLE_ON") vehicle_blacklist.vehicles[hash].kick = bool;vehicle_blacklist.save() end),
		opt_crash = ui.add_bool_option(TRANSLATION["Crash player"], sub, function(bool) HudSound("TOGGLE_ON") vehicle_blacklist.vehicles[hash].crash = bool;vehicle_blacklist.save() end),
	}
	local tabl = vehicle_blacklist.options[hash]
	ui.set_value(tabl.opt_v_kick, v_kick, true)
	ui.set_value(tabl.opt_v_max_speed, v_max_speed, true)
	ui.set_value(tabl.opt_v_expl, v_expl, true)
	ui.set_value(tabl.opt_v_del, v_del, true)
	ui.set_value(tabl.opt_v_laun, v_laun, true)
	ui.set_value(tabl.opt_tp_killzone, killzone, true)
	ui.set_value(tabl.opt_kick, kick, true)
	ui.set_value(tabl.opt_crash, crash, true)
end

function vehicle_blacklist.remove_option_vehicle(hash)
	if settings.Dev.Enable then system.log('debug', 'removing vehicle blacklist '..hash) end
	if not vehicle_blacklist.options[hash] or not __submenus["BlacklistedVehicles"] then return end
	local tabl = vehicle_blacklist.options[hash]
	for k, v in pairs(tabl)
	do
		ui.remove(v)
	end
	vehicle_blacklist.options[hash] = nil
end

function vehicle_blacklist.save()
	if settings.Dev.Enable then system.log('debug', 'saving vehicle blacklist...') end
	filesystem.write(json:encode_pretty(vehicle_blacklist.vehicles), files['VehicleBlacklist'])
end 

function vehicle_blacklist.load()
	if not filesystem.exists(files['VehicleBlacklist']) then return end
	system.log('Imagined Menu', 'Loading vehicle blacklist...')
	vehicle_blacklist.vehicles = json:decode(filesystem.read_all(files['VehicleBlacklist']))
	for k, v in pairs(vehicle_blacklist.vehicles)
	do
		if not tonumber(k) then error('Failed to load vehicle from blacklist invalid hash', 1) end
		if not v.model then error('Failed to load vehicle from blacklist invalid model', 1) end
		if v.vehicle_kick == nil then v.vehicle_kick = false end
		if v.set_max_speed == nil then v.set_max_speed = false end
		if v.vehicle_explode == nil then v.vehicle_explode = false end 
		if v.vehicle_delete == nil then v.vehicle_delete = false end 
		if v.vehicle_launch == nil then v.vehicle_launch = false end 
		if v.tp_killzone == nil then v.tp_killzone = false end
		if v.kick == nil then v.kick = false end 
		if v.crash == nil then v.crash = false end
		vehicle_blacklist.add_option_vehicle(k, v.model, v.vehicle_kick, v.set_max_speed, v.vehicle_explode, v.vehicle_delete, v.vehicle_launch, v.tp_killzone, v.kick, v.crash)
	end
end

function vehicle_blacklist.add(int)
	CreateRemoveThread(true, 'adding_blacklist_'..thread_count, function()
		local hash = tostring(vehicles.models[int][2])
		if vehicle_blacklist.vehicles[hash] then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION['Vehicle already blacklisted'], 255, 0, 0, 255, true) return POP_THREAD end
		vehicle_blacklist.vehicles[hash] = {
			model = vehicles.models[int][1],
			vehicle_kick = settings.Session["VehBlVehicleKick"],
			set_max_speed = settings.Session["VehBlSetMaxSpeed"],
			vehicle_explode = settings.Session["VehBlVehicleExplode"],
			vehicle_delete = settings.Session["VehBlVehicleDelete"],
			vehicle_launch = settings.Session["VehBlVehicleLaunch"],
			tp_killzone = settings.Session["VehBlKillZone"],
			kick = settings.Session["VehBlKick"],
			crash = settings.Session["VehBlCrash"],
		}
		vehicle_blacklist.save()
		system.notify(TRANSLATION["Imagined Menu"], TRANSLATION['Vehicle added to blacklist'], 0, 128, 255, 255, true)
		vehicle_blacklist.add_option_vehicle(hash, vehicles.models[int][1],
			settings.Session["VehBlVehicleKick"], 
			settings.Session["VehBlSetMaxSpeed"],
			settings.Session["VehBlVehicleExplode"], 
			settings.Session["VehBlVehicleDelete"], 
			settings.Session["VehBlVehicleLaunch"], 
			settings.Session["VehBlKillZone"],
			settings.Session["VehBlKick"], 
			settings.Session["VehBlCrash"])
		return POP_THREAD
	end)
end

function vehicle_blacklist.remove(hash)
	vehicle_blacklist.vehicles[hash] = nil
	vehicle_blacklist.save()
	system.notify(TRANSLATION["Imagined Menu"], TRANSLATION['Vehicle removed from blacklist'], 0, 128, 255, 255, true)
end

local function SaveExcludes()
	if settings.Dev.Enable then system.log('debug', 'saving player excludes...') end
	filesystem.write(json:encode_pretty(features.player_excludes), files['PlayerExcludes'])
end

local function LoadExcludes()
	if not filesystem.exists(files['PlayerExcludes']) then return end
	system.log('Imagined Menu', 'Loading excluded players...')
	features.player_excludes = json:decode(filesystem.read_all(files['PlayerExcludes']))
end
LoadExcludes()

local Cages = {
	[0] = json:decode(filesystem.read_all(files['TrapStTube'])),
	json:decode(filesystem.read_all(files['TrapStTubeInv'])),
	json:decode(filesystem.read_all(files['TrapCage']))
}

---------------------------------------------------------------------------------------------------------------------------------
-- Main Sub
---------------------------------------------------------------------------------------------------------------------------------

__submenus["MainSub"] = ui.add_main_submenu(TRANSLATION["Imagined Menu"])

do
	local unload
	local was_open
	local open_time = clock()
	ui.add_click_option(TRANSLATION["Stop script"], __submenus["MainSub"], function()
		if open_time > clock() then HudSound("ERROR") return end
		HudSound("SELECT")
		if not unload then
			system.notify(TRANSLATION["Warning"], TRANSLATION["Are you sure you want to quit?"], 255, 0, 0, 255, true)
			unload = true
			return
		end
		CreateRemoveThread(true, 'stop_script', function(tick)
			if tick < 10 then return end
			system.log('Imagined Menu', 'Unloading Imagined Menu...')
			if settings.General["AutoSave"] then SaveConfig() end
			dont_play_tog = true
			for _, v in pairs(__options.bool)
			do
				if ui.get_value(v) then
					ui.set_value(v, false, false)
				end
			end
			if ui.get_value(__options.choose["NoClip"]) ~= 0 then
				ui.set_value(__options.choose["NoClip"], 0, false)
			end
			if ui.get_value(__options.num["SwimSpeed"]) ~= 1 then
				ui.set_value(__options.num["SwimSpeed"], 1, false)
			end
			if ui.get_value(__options.num["RunSpeed"]) ~= 1 then
				ui.set_value(__options.num["RunSpeed"], 1, false)
			end
			for _, v in pairs(vehicle_blips)
			do
				features.remove_blip(v[2])
			end
			gRunning = false
			system.notify(TRANSLATION["Imagined Menu"], TRANSLATION['See you soon!']..' :)', 0, 255, 0, 255)
			return POP_THREAD
		end)
	end)

	CreateRemoveThread(true, 'is_main_sub_open', function()
		if not was_open and ui.is_sub_open(__submenus["MainSub"]) then
			was_open = true
			open_time = clock() + .5
		elseif was_open and not ui.is_sub_open(__submenus["MainSub"]) then
			was_open = false
		end
		if unload and not ui.is_sub_open(__submenus["MainSub"]) then
			unload = false
		end
	end)
end

---------------------------------------------------------------------------------------------------------------------------------
-- Players
---------------------------------------------------------------------------------------------------------------------------------

for i = 0, 31
do
	playerlist[i] = {
		SendJets = false,
		HonkBoosting = false,
		VehicleHorn = false,
		Commands = false,
		ChatMock = false,
		Freeze = false,
		InvincibleEnemyVeh = true
	}
end

if settings.Dev.Enable then system.log('debug', 'player submenu') end
__submenus["Imagined"] = ui.add_player_submenu(TRANSLATION["Imagined Menu"])

__submenus["PlayerlistVehicle"] = ui.add_submenu(TRANSLATION["Vehicle"])
__suboptions["PlayerlistVehicle"] = ui.add_sub_option(TRANSLATION["Vehicle"], __submenus["Imagined"], __submenus["PlayerlistVehicle"])

__submenus["SpawnVehicle"] = ui.add_submenu(TRANSLATION["Spawn vehicle"])
__suboptions["SpawnVehicle"] = ui.add_sub_option(TRANSLATION["Spawn vehicle"], __submenus["PlayerlistVehicle"], __submenus["SpawnVehicle"])

__submenus["PlayerlistTeleport"] = ui.add_submenu(TRANSLATION["Teleport"])
__suboptions["PlayerlistTeleport"] = ui.add_sub_option(TRANSLATION["Teleport"], __submenus["Imagined"], __submenus["PlayerlistTeleport"])

__submenus["PlayerlistOther"] = ui.add_submenu(TRANSLATION["Other"])
__suboptions["PlayerlistOther"] = ui.add_sub_option(TRANSLATION["Other"], __submenus["Imagined"], __submenus["PlayerlistOther"])

ui.add_separator(TRANSLATION["Trolling"], __submenus["Imagined"])

do
	local blame_delay = 0
	__submenus["Blame"] = ui.add_submenu(TRANSLATION["Blame"])
	__suboptions["Blame"] = ui.add_sub_option(TRANSLATION["Blame"], __submenus["Imagined"], __submenus["Blame"])

	ui.add_click_option(TRANSLATION["All"], __submenus["Blame"], function()
		if blame_delay > clock() then return end
		local target = online.get_selected_player()
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(target) == 0 then return HudSound("ERROR") end
		local ped = features.player_ped(target)
		local found
		features.patch_blame(true)
		for i = 0, 31 do
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and i ~= PLAYER.PLAYER_ID() and not (settings.General["Exclude Friends"] and features.is_friend(i)) and not features.is_excluded(i) then
				local pos = features.get_player_coords2(i)
				FIRE.ADD_OWNED_EXPLOSION(ped, pos.x, pos.y, pos.z, enum.explosion.GRENADE, 1, true, false, 1.0)
				found = true
			end
		end
		features.patch_blame(false)
		if not found then return HudSound("ERROR") end
		HudSound("SELECT")
		blame_delay = clock() + .2
	end)
	ui.add_separator(TRANSLATION["Player"], __submenus["Blame"])

	local blame_players = {}
	CreateRemoveThread(true, 'blame_players', function()
		for i = 0, 31
		do
			if not blame_players[i] and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and NETWORK.NETWORK_IS_SESSION_STARTED() == 1 then
				local tag = ""
				if i == PLAYER.PLAYER_ID() then
					tag = format('(%s)', TRANSLATION["Self"])
				elseif features.is_friend(i) then
					tag = format('(%s)', TRANSLATION["Friend"])
				end
				local name = PLAYER.GET_PLAYER_NAME(i)..' '..tag
				blame_players[i] = ui.add_click_option(name, __submenus["Blame"], function()
					if blame_delay > clock() then HudSound("ERROR") return end
					HudSound("SELECT")
					local ped = features.player_ped(online.get_selected_player())
					local pos = features.get_player_coords2(i)
					features.patch_blame(true)
					FIRE.ADD_OWNED_EXPLOSION(ped, pos.x, pos.y, pos.z, enum.explosion.GRENADE, 1, true, false, 1.0)
					features.patch_blame(false)
					blame_delay = clock() + .2
				end)
			elseif blame_players[i] and (NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 0 or NETWORK.NETWORK_IS_SESSION_STARTED() == 0) then
				ui.remove(blame_players[i])
				blame_players[i] = nil
			end
		end
	end)
end

do
	local coords
	local veh
	local current
	local hash2
	local amount = 1
	local pid
	local pos
	local enemy_vehicles = {}

	local function spawn_0()
		coords = pos:point_on_circle(rad((360/amount) * current), 10)
		local success, Z = features.get_ground_z(coords)
		veh = vehicles.spawn_vehicle(hash2, vector3(coords.x, coords.y, success and Z or coords.z))
		insert(enemy_vehicles[pid], veh)
		features.set_entity_face_entity(veh, features.player_ped(pid))
		VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)
		VEHICLE.SET_VEHICLE_MOD(veh, 10, 2, false)
		local blip = HUD.ADD_BLIP_FOR_ENTITY(veh)
		HUD.SET_BLIP_SPRITE(blip, enum.blip_sprite.gr_wvm_1)
	end

	local function spawn_1()
		coords = pos:point_on_circle(rad((360/amount) * current), 10)
		local success, Z = features.get_ground_z(coords)
		veh = vehicles.spawn_vehicle(hash2, vector3(coords.x, coords.y, success and Z or coords.z))
		insert(enemy_vehicles[pid], veh)
		features.set_entity_face_entity(veh, features.player_ped(pid))
		local blip = HUD.ADD_BLIP_FOR_ENTITY(veh)
		HUD.SET_BLIP_SPRITE(blip, enum.blip_sprite.arena_rc_car)
	end

	local function spawn_2()
		coords = pos:point_on_circle(rad((360/amount) * current), 20)
		local success, Z = features.get_ground_z(coords)
		veh = vehicles.spawn_vehicle(hash2, vector3(coords.x, coords.y, success and Z or coords.z))
		insert(enemy_vehicles[pid], veh)
		features.set_entity_face_entity(veh, features.player_ped(pid))
		local blip = HUD.ADD_BLIP_FOR_ENTITY(veh)
		HUD.SET_BLIP_SPRITE(blip, enum.blip_sprite.tank)
	end

	local function spawn_3()
		coords = pos:point_on_circle(rad((360/amount) * current), 200)
		veh = vehicles.spawn_vehicle(hash2, vector3(coords.x, coords.y, coords.z + 500))
		insert(enemy_vehicles[pid], veh)
		features.set_entity_face_entity(veh, features.player_ped(pid))
		VEHICLE.CONTROL_LANDING_GEAR(veh, 3)
  	VEHICLE.SET_HELI_BLADES_FULL_SPEED(veh)
  	VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 200)
  	local blip = HUD.ADD_BLIP_FOR_ENTITY(veh)
		HUD.SET_BLIP_SPRITE(blip, enum.blip_sprite.player_jet)
	end

	local function spawn_4()
		coords = pos:point_on_circle(rad((360/amount) * current), 50)
		veh = vehicles.spawn_vehicle(hash2, vector3(coords.x, coords.y, coords.z + 30))
		insert(enemy_vehicles[pid], veh)
		features.set_entity_face_entity(veh, features.player_ped(pid))
  	VEHICLE.SET_HELI_BLADES_FULL_SPEED(veh)
  	local blip = HUD.ADD_BLIP_FOR_ENTITY(veh)
		HUD.SET_BLIP_SPRITE(blip, enum.blip_sprite.player_heli)
	end

	local CreateVeh = switch()
		:case(0, spawn_0)
		:case(1, spawn_1)
		:case(2, spawn_2)
		:case(3, spawn_3)
    	:case(4, spawn_4)

	for i = 0, 31
	do
		enemy_vehicles[i] = {}
	end
	
	local models = {
		[0] = {utils.joaat("ig_dom"), utils.joaat("minitank")},
		{utils.joaat("ig_dom"), utils.joaat("rcbandito")},
		{utils.joaat("ig_dom"), utils.joaat("rhino")},
		{utils.joaat("ig_dom"), utils.joaat("lazer")},
		{utils.joaat("ig_dom"), utils.joaat("buzzard")},
	}

	local types = {HUD._GET_LABEL_TEXT("MINITANK"), HUD._GET_LABEL_TEXT("RCBANDITO"), HUD._GET_LABEL_TEXT("RHINO"), HUD._GET_LABEL_TEXT("LAZER"), HUD._GET_LABEL_TEXT("BUZZARD")}
	__submenus["SendEnemyVehicle"] = ui.add_submenu(TRANSLATION["Send enemy vehicle"])
	__suboptions["SendEnemyVehicle"] = ui.add_sub_option(TRANSLATION["Send enemy vehicle"], __submenus["Imagined"], __submenus["SendEnemyVehicle"])
	local _amount = ui.add_num_option(TRANSLATION["Amount"], __submenus["SendEnemyVehicle"], 1, 15, 1, function(int) HudSound("YES") amount = int end)
	__options.players["InvincibleEnemyVeh"] = ui.add_bool_option(TRANSLATION['Invincible'], __submenus["SendEnemyVehicle"], function(bool)
		HudSound("TOGGLE_ON")
		local player = online.get_selected_player()
		playerlist[player]["InvincibleEnemyVeh"] = bool
		for _, v in ipairs(enemy_vehicles[player])
		do
			entities.request_control(v, function()
				if ENTITY.IS_ENTITY_A_VEHICLE(v) == 1 then
					vehicles.set_godmode(v,	bool)
				else
					features.set_godmode(v, bool)
				end
			end)
		end
	end)
	ui.set_value(_amount, amount, true)
	ui.add_choose(TRANSLATION["Send enemies"], __submenus["SendEnemyVehicle"], false, types, function(int)
		pid = online.get_selected_player()
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
		HudSound("YES")
		CreateRemoveThread(true, 'send_enemies_'..thread_count, function()
			local loaded, hash1 = features.request_model(models[int][1])
			if loaded == 0 then return end
			loaded, hash2 = features.request_model(models[int][2])
			if loaded == 0 then return end
			pos = features.get_player_coords2(pid)
			for i = 1, amount
			do
				current = i
				CreateVeh(int)				
				VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
				local ped = peds.create_ped(hash1, coords)
				PED.SET_PED_INTO_VEHICLE(ped, veh, -1)
				if ui.get_value(__options.players["InvincibleEnemyVeh"]) then
					vehicles.set_godmode(veh, true)
					peds.set_ped_god(ped)
				end
				insert(enemy_vehicles[pid], ped)
				peds.calm_ped(ped, true)
				for _, v in ipairs({1,2,5,46,52}) do
					PED.SET_PED_COMBAT_ATTRIBUTES(ped, v, true)
				end
				PED.SET_PED_ACCURACY(ped, 100)
				PED.SET_PED_COMBAT_RANGE(ped, 2)
				PED.SET_PED_COMBAT_ABILITY(ped, 2)
				PED.SET_PED_COMBAT_MOVEMENT(ped, 2)
				PED.SET_PED_KEEP_TASK(ped, true)
				if int == 3 then
					TASK.TASK_PLANE_MISSION(ped, veh, 0, features.player_ped(pid), 0, 0, 0, 6, 100, 0, 0, 80, 50, nil)
				elseif int == 4 then
					TASK.TASK_HELI_MISSION(ped, veh, 0, features.player_ped(pid), 0, 0, 0, 23, 40, 40, -1, 0, 10, -1, 0)
				end
				CreateRemoveThread(true, 'emeny_'..thread_count, function()
					if ENTITY.DOES_ENTITY_EXIST(ped) == 0 or NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then 
						features.delete_entity(veh)
						features.delete_entity(ped)
						return POP_THREAD
					elseif int ~= 3 and PED.IS_PED_IN_COMBAT(ped, features.player_ped(pid)) == 0 and PED.IS_PED_INJURED(features.player_ped(pid)) == 0 then
						entities.request_control(ped, function()
							TASK.CLEAR_PED_TASKS(ped)
							TASK.TASK_COMBAT_PED(ped, features.player_ped(pid), 0, 16)
							PED.SET_PED_KEEP_TASK(ped, true)
						end)
					end
				end)
			end
			features.unload_models(models[int])
			return POP_THREAD
		end)
	end)
	ui.add_click_option(TRANSLATION['Delete enemies'], __submenus["SendEnemyVehicle"], function()
		HudSound("SELECT")
		for _, v in ipairs(enemy_vehicles[online.get_selected_player()])
		do
			features.delete_entity(v)
		end
		enemy_vehicles[online.get_selected_player()] = {}
	end)
end

do
	__submenus["CustomExplosion"] = ui.add_submenu(TRANSLATION["Custom explosion"])
	__suboptions["CustomExplosion"] = ui.add_sub_option(TRANSLATION["Custom explosion"], __submenus["Imagined"], __submenus["CustomExplosion"])
	local explosion_types = {}
	for i = 0, 82
	do
		for k, v in pairs(enum.explosion)
		do
			if v == i then
				insert(explosion_types, k)
				break
			end
		end
	end
	local blamed
	local invisible = false
	local silent = false
	__options.bool["ExplodeBlamed"] = ui.add_bool_option(TRANSLATION["Kill as self"], __submenus["CustomExplosion"], function(bool) HudSound("TOGGLE_ON") blamed = bool end)
	__options.bool["ExplodeInvisible"] = ui.add_bool_option(TRANSLATION["Invisible"], __submenus["CustomExplosion"], function(bool) HudSound("TOGGLE_ON") invisible = bool end)
	__options.bool["ExplodeSilet"] = ui.add_bool_option(TRANSLATION["Silent"], __submenus["CustomExplosion"], function(bool) HudSound("TOGGLE_ON") silent = bool end)
	__options.choose["Explode"] = ui.add_choose(TRANSLATION["Explode"], __submenus["CustomExplosion"], false, explosion_types, function(int)
		local pid = online.get_selected_player()
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
		HudSound("YES")
		local pos = features.get_player_coords2(pid)
		if blamed then
			FIRE.ADD_OWNED_EXPLOSION(features.player_ped(), pos.x, pos.y, pos.z, int, 1, not silent, invisible, 1)
		else
			FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, int, 1, not silent, invisible, 1, false)
		end
	end)
end

ui.add_click_option(TRANSLATION["Airstrike player"], __submenus["Imagined"], function()
	HudSound("SELECT")
	local target = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(target) == 0 then return HudSound("ERROR") end
	local pos = features.get_player_coords2(target)
	MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 100, pos.x, pos.y, pos.z, 5, true, utils.joaat("weapon_rpg"), features.player_ped(), true, true, 50000)
end)

ui.add_click_option(TRANSLATION["Kidnap player"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	CreateRemoveThread(true, 'crush_player_'..thread_count, function()
		local loaded, hash = features.request_model(utils.joaat("ig_lestercrest_2"))
		if loaded == 0 then return end
		local loaded, hash2 = features.request_model(utils.joaat("stockade"))
		if loaded == 0 then return end
		TASK.CLEAR_PED_TASKS_IMMEDIATELY(features.player_ped(pid))
		local pos = features.get_offset_from_player_coords(vector3(0, 2, -1), pid)
		local veh = vehicles.spawn_vehicle(hash2, pos, features.get_player_heading(pid))
		vehicles.set_godmode(veh, true)
		ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, pos.x, pos.y, pos.z, false, false, false)
		ENTITY.SET_ENTITY_HEADING(veh, features.get_player_heading(pid))
		local ped = peds.create_ped(hash, pos, true)
		peds.calm_ped(ped)
		PED.SET_PED_INTO_VEHICLE(ped, veh, -1)
		TASK.TASK_VEHICLE_DRIVE_WANDER(ped, veh, 200, 786603)
		VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 6)
		VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 2)
		features.unload_models(hash, hash2)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Crush player"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	CreateRemoveThread(true, 'crush_player_'..thread_count, function()
		TASK.CLEAR_PED_TASKS_IMMEDIATELY(features.player_ped(pid))
		local loaded, hash = features.request_model(utils.joaat("rhino"))
		if loaded == 0 then return end
		local pos = features.get_offset_from_player_coords(vector3.up(15), pid)
		local veh = vehicles.spawn_vehicle(hash, pos, features.get_player_heading(pid))
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
		entities.request_control(veh, function()
			features.apply_force_to_entity(veh, 1, 0, 0, -20, 0, 0, 0, 0, true, false, true, false, true)
		end)
		local time = clock() + 3
		CreateRemoveThread(true, 'delete_entity_'..thread_count, function()
			if time > clock() then return end
			features.delete_entity(veh)
			return POP_THREAD
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Send IP in chat"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	if pid == PLAYER.PLAYER_ID() then return HudSound("ERROR") end
	HudSound("SELECT")
	online.send_chat(format("My IP adress is: %s", online.get_ip(pid)), false, pid)
end)

ui.add_choose(TRANSLATION["Trap"], __submenus["Imagined"], false, {TRANSLATION["Stunt tube"], TRANSLATION["Invisible tube"], TRANSLATION["Cage"]}, function(int)
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	HudSound("YES")
	local type = Cages[int] 
	CreateRemoveThread(true, 'trap_'..thread_count, function()
		local ped = features.player_ped(pid)
		TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
		local result = world_spawner.request(type)
        if result == -1 then return 0 end -- invalid model
        if result == 0 then return end -- not loaded
        local pos = features.get_player_coords2(pid)
        local heading = features.get_entity_rot(ped).z
        type[1].position.x = pos.x
        type[1].position.y = pos.y
        type[1].position.z = pos.z
        type[1].position.yaw = heading
        world_spawner.spawn_map(type, true)
        return POP_THREAD
	end)
end)

ui.add_choose(TRANSLATION["Infinite invite"], __submenus["Imagined"], false, {TRANSLATION['v1'], TRANSLATION['v2']}, function(int)
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	HudSound("YES")
	online.send_script_event(pid, -1390976345, PLAYER.PLAYER_ID(), pid, 4294967295, 1, 115, int, int, int)
end)

local GetType = switch()
	:case(0, function()
		return 205991906
	end)
	:case(1, function()
		return 911657153
	end)
	:default(function()
		return -1355376991
	end)

do
	local types = {HUD._GET_LABEL_TEXT("WT_SNIP_HVY2"), HUD._GET_LABEL_TEXT("WT_STUN"), HUD._GET_LABEL_TEXT("WT_RAYPISTOL")}
	__options.choose["ShootWithBullet"] = ui.add_choose(TRANSLATION["Shoot with bullet"], __submenus["Imagined"], false, types, function(int)
		local pid = online.get_selected_player()
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
		HudSound("YES")
		local hash = GetType(int)
		local pos = features.get_player_coords2(pid)
		local pos2 = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(features.player_ped(pid), 0xe0fd)
		if WEAPON.HAS_WEAPON_ASSET_LOADED(hash) == 0 then
			WEAPON.REQUEST_WEAPON_ASSET(hash, 31, 0)
		end
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 2, pos.x, pos.y, pos.z - 2, 5, true, hash, features.player_ped(), true, true, 24000)
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 2, pos.x, pos.y, pos.z - 2, 5, true, hash, features.player_ped(), true, true, 24000)
	end)
end

__options.players["Freeze"] = ui.add_bool_option(TRANSLATION["Freeze"], __submenus["Imagined"], function(bool)
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	HudSound("TOGGLE_ON")
	playerlist[pid]["Freeze"] = bool
end)

do
	local vehs = {}
	local god
	local upgrade = 0
	for i, v in ipairs(vehicles.models) do
		vehs[i] = v[3]
	end
	ui.add_bool_option(TRANSLATION['Spawn with godmode'],  __submenus["SpawnVehicle"], function(bool) HudSound("TOGGLE_ON") god = bool end)
	__options.choose["PlSpawnPerformancePreset"] = ui.add_choose(TRANSLATION["Upgrade preset"], __submenus["SpawnVehicle"], true, {TRANSLATION["Stock"], TRANSLATION["Max upgrade"], TRANSLATION["Max without livery"], TRANSLATION["Performance"], TRANSLATION["Performance with spoiler"]}, function(int) HudSound("YES") upgrade = int end)

	local selected_vehicle = 1
	local class = 0
	local classes = {}
	local curr_class
	for i = 0, 61
	do
		insert(classes, enum.vehicle_class[i])
	end

	local function spawn(model, player)
		CreateRemoveThread(true, 'request_model_'..thread_count, function()
			local loaded, hash = features.request_model(model)
			if not hash then return POP_THREAD end
			if loaded == 0 then return end
			local target = features.get_offset_coords_from_entity_rot(features.player_ped(player), 6, 0, true)
			local vehicle = vehicles.spawn_vehicle(hash, target, features.get_player_heading(player))
			if vehicle == 0 then return end
			entities.request_control(vehicle, function()
				-- DECORATOR.DECOR_SET_INT(vehicle, "MPBitset", 1024)
				vehicles.repair(vehicle)
				VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, "Nightfal")
				if god then vehicles.set_godmode(vehicle, true) end
				if upgrade == 1 then
					vehicles.upgrade(vehicle)
				elseif upgrade == 2 then
					vehicles.upgrade(vehicle)
					VEHICLE.SET_VEHICLE_MOD(vehicle, 48, -1, false)
				elseif upgrade == 3 then
					vehicles.performance(vehicle)
				elseif upgrade == 4 then
					vehicles.performance(vehicle)
					local num = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, 0) - 1
					VEHICLE.SET_VEHICLE_MOD(vehicle, 0, num, false)
				end
			end)
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
			return POP_THREAD
		end)
	end

	ui.add_input_string(TRANSLATION["Input model"], __submenus["SpawnVehicle"], function(text)
		local pid = online.get_selected_player()
		if not text or text == '' or NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) then return HudSound("ERROR") end
		local text = text:lower()
		local hash = utils.joaat(text)
		if STREAMING.IS_MODEL_VALID(hash) == 1 and STREAMING.IS_MODEL_A_VEHICLE(hash) == 1 then
			spawn(hash, pid)
		else
			for _, v in ipairs(vehicles.data)
			do
				if v.Name:find(text) or (v.DisplayName and v.DisplayName:lower():find(text)) or vehicles.get_label_name(v.Hash):lower():find(text) then
					hash = v.Hash
					break
				end
			end
			if STREAMING.IS_MODEL_VALID(hash) == 1 and STREAMING.IS_MODEL_A_VEHICLE(hash) == 1 then
				spawn(hash, pid)
			else
				system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Sorry I couldn't find any matching model"], 225, 0, 0, 225)
				HudSound("ERROR")
			end
		end
	end)

	local sel_class = ui.add_choose(TRANSLATION["Select class"], __submenus["SpawnVehicle"], true, classes, function(int) class = int
		HudSound("YES")
		if curr_class then 
			ui.remove(curr_class)
			curr_class = nil
		end
	end)
	ui.set_value(sel_class, class, true)
	CreateRemoveThread(true, 'selected_class_'..thread_count, function()
		if not curr_class then
			curr_class = ui.add_choose(TRANSLATION["Select vehicle"], __submenus["SpawnVehicle"], false, settings.Vehicle["VehManufacturer"] and vehicles.class_manufacturer[class] or vehicles.class[class], function(int)
				local pid = online.get_selected_player()
				if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
				HudSound("YES")
				selected_vehicle = int + 1
				spawn(vehicles.models[vehicles.get_veh_index(selected_vehicle, class)][2], pid)
			end)
		end
	end)
end

ui.add_click_option(TRANSLATION["Gift vehicle"], __submenus["PlayerlistVehicle"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	local veh = vehicles.get_player_vehicle(pid)
	if veh == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	entities.request_control(veh, function()
		local pl_veh
		DECORATOR.DECOR_REGISTER("Player_Vehicle", 3)
		DECORATOR.DECOR_REGISTER("Previous_Owner", 3)
		DECORATOR.DECOR_REGISTER("Vehicle_Reward", 3)
		DECORATOR.DECOR_REGISTER("MPBitset", 3)
		DECORATOR.DECOR_REGISTER("Veh_Modded_By_Player", 3)
		if ENTITY.IS_ENTITY_VISIBLE(veh) == 1 then
			if DECORATOR.DECOR_EXIST_ON(veh, "Player_Vehicle") == 1 then
				DECORATOR.DECOR_SET_INT(veh, "Player_Vehicle", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid))
			else
				pl_veh = DECORATOR.DECOR_GET_INT(veh, "Player_Vehicle")
				DECORATOR.DECOR_SET_INT(veh, "Player_Vehicle", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid))
			end
			if pl_veh and pl_veh ~= -1 then
				DECORATOR.DECOR_SET_INT(veh, "Previous_Owner", pl_veh)
			end
		end
		if DECORATOR.DECOR_EXIST_ON(veh, "Player_Vehicle") == 0 then
			DECORATOR.DECOR_SET_BOOL(veh, "Vehicle_Reward", true)
			DECORATOR.DECOR_SET_INT(veh, "Vehicle_Reward", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid))
		end
		local veh_modd = DECORATOR.DECOR_GET_INT(veh, "Veh_Modded_By_Player")
		if veh_modd ~= 0 and veh_modd ~= -1 then
			DECORATOR.DECOR_SET_INT(veh, "Veh_Modded_By_Player", -1)
		end
		VEHICLE.SET_VEHICLE_CAN_SAVE_IN_GARAGE(veh, true)
		VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, true)
		VEHICLE.SET_VEHICLE_IS_STOLEN(veh, false)
	end)
end)

ui.add_click_option(TRANSLATION["Lester takes the wheel"], __submenus["PlayerlistVehicle"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	local veh = vehicles.get_player_vehicle(pid)
	if veh == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	local time = os_time() + 10
	CreateRemoveThread(true, 'lester_takes_the_wheel_'..thread_count, function(tick)
		if time < os_time() then STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(utils.joaat('ig_lestercrest_2')) return POP_THREAD end
		local loaded, hash = features.request_model('ig_lestercrest_2')
		if loaded == 0 then return end
		local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, true)
		if ped ~= 0 then
			TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
			return
		end
		local lester = peds.create_ped(hash, features.get_player_coords(pid), true)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
		entities.request_control(veh, function()
			PED.SET_PED_INTO_VEHICLE(lester, veh, -1)
			peds.calm_ped(lester, true)
			TASK.TASK_VEHICLE_DRIVE_WANDER(lester, veh, 200, 786603)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 6)
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 2)
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Blow up vehicle"], __submenus["PlayerlistVehicle"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	local veh = vehicles.get_player_vehicle(pid)
	if veh == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	CreateRemoveThread(true, 'blow_up_vehicle_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			vehicles.set_godmode(veh, false)
			NETWORK.NETWORK_EXPLODE_VEHICLE(veh, true, false, pid)
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Pop tires"], __submenus["PlayerlistVehicle"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	local veh = vehicles.get_player_vehicle(pid)
	if veh == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	CreateRemoveThread(true, 'pop_tires_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			vehicles.set_godmode(veh, false)
		    for i = 0, 5 do
		      VEHICLE.SET_VEHICLE_TYRE_BURST(veh, i, true, 1000.0)
		    end
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Rotate vehicle"], __submenus["PlayerlistVehicle"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	local veh = vehicles.get_player_vehicle(pid)
	if veh == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	CreateRemoveThread(true, 'rotate_vehicle_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			local rot = features.get_entity_rot(veh, 5)
			ENTITY.SET_ENTITY_ROTATION(veh, rot.x, rot.y, rot.z - 180, 5, true)
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Flip vehicle"], __submenus["PlayerlistVehicle"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	local veh = vehicles.get_player_vehicle(pid)
	if veh == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	CreateRemoveThread(true, 'flip_vehicle_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			local rot = features.get_entity_rot(veh, 5)
			ENTITY.SET_ENTITY_ROTATION(veh, rot.x, rot.y - 180, rot.z, 5, true)
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Boost forward"], __submenus["PlayerlistVehicle"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	local veh = vehicles.get_player_vehicle(pid)
	if veh == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	CreateRemoveThread(true, 'boost_forward_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 500)
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Boost backward"], __submenus["PlayerlistVehicle"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	local veh = vehicles.get_player_vehicle(pid)
	if veh == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	CreateRemoveThread(true, 'boost_backward_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, -500)
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Launch up vehicle"], __submenus["PlayerlistVehicle"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	local veh = vehicles.get_player_vehicle(pid)
	if veh == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	CreateRemoveThread(true, 'launch_up_vehicle_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			ENTITY.FREEZE_ENTITY_POSITION(veh, false)
			features.set_entity_velocity(veh, 0, 0, 500)
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Launch down vehicle"], __submenus["PlayerlistVehicle"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	local veh = vehicles.get_player_vehicle(pid)
	if veh == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	CreateRemoveThread(true, 'launch_down_vehicle_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			ENTITY.FREEZE_ENTITY_POSITION(veh, false)
			features.set_entity_velocity(veh, 0, 0, -500)
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Hijack vehicle"], __submenus["PlayerlistVehicle"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	local veh = vehicles.get_player_vehicle(pid)
	if veh == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	CreateRemoveThread(true, 'hijack_vehicle_'..thread_count, function(tick)
		if tick == 100 then return POP_THREAD end
		entities.request_control(veh, function()
			local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, true)
			if ped and ped ~= features.player_ped() then
				online.send_script_event(pid, -2126830022, PLAYER.PLAYER_ID(), pid)
       			online.send_script_event(pid, -714268990, PLAYER.PLAYER_ID(), 0, 0, 0, 0, 1, pid, random(0, 2147483647))
				TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
			end
			PED.SET_PED_INTO_VEHICLE(features.player_ped(), veh, -1)
		end)
		if VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, true) ~= features.player_ped() then return end
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Disable ability to drive"], __submenus["PlayerlistVehicle"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	online.send_script_event(pid, -1390976345, PLAYER.PLAYER_ID(), 2, 4294967295, 1, 115, 0, 0, 0)
end)

__options.players["VehicleGod"] = ui.add_bool_option(TRANSLATION["Set vehicle godmode"], __submenus["PlayerlistVehicle"], function(bool)
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	local veh = vehicles.get_player_vehicle(pid)
	if veh == 0 then ui.set_value(__options.players["VehicleGod"], (ui.get_value(__options.players["VehicleGod"])==1), true) HudSound("ERROR") return end
	HudSound("TOGGLE_ON")
	CreateRemoveThread(true, 'vehicle_god_on_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			vehicles.set_godmode(veh, bool)
		end)
		return POP_THREAD
	end)
end)

__options.players["VehicleHorn"] = ui.add_bool_option(TRANSLATION["Start vehicle horn"], __submenus["PlayerlistVehicle"], function(bool)
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	playerlist[pid]["VehicleHorn"] = bool
	HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'horn_vehicle_'..pid, function(tick)
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return POP_THREAD end
		local veh = vehicles.get_player_vehicle(pid)
		if veh == 0 then return end
		entities.request_control(veh, function()
			VEHICLE.START_VEHICLE_HORN(veh, 3000, 0, false)
		end)
	end)
end)

__options.players["HonkBoosting"] = ui.add_bool_option(TRANSLATION["Honk boosting"], __submenus["PlayerlistVehicle"], function(bool)
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	HudSound("TOGGLE_ON")
	playerlist[pid]["HonkBoosting"] = bool
end)

__options.players["LockVehicle"] = ui.add_bool_option(TRANSLATION["Lock vehicle"], __submenus["PlayerlistVehicle"], function(bool)
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	local veh = vehicles.get_player_vehicle(pid)
	if veh == 0 then ui.set_value(__options.players["LockVehicle"], (ui.get_value(__options.players["LockVehicle"])==1), true) HudSound("ERROR") return end
	HudSound("TOGGLE_ON")
	CreateRemoveThread(true, 'lock_vehicle_'..thread_count, function(tick)
		-- if tick == 50 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			if bool then
				VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 6)
			  	VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 2)
			else
			 	VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 1)
			end
		end)
		return POP_THREAD
	end)
end)

__options.players["ChildLocks"] = ui.add_bool_option(TRANSLATION["Child locks"], __submenus["PlayerlistVehicle"], function(bool)
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	local veh = vehicles.get_player_vehicle(pid)
	if veh == 0 then ui.set_value(__options.players["ChildLocks"], (ui.get_value(__options.players["ChildLocks"])==1), true) HudSound("ERROR") return end
	HudSound("TOGGLE_ON")
	CreateRemoveThread(true, 'lock_vehicle_'..thread_count, function(tick)
		-- if tick == 50 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			if bool then
				VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 6)
		    VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 4)
			else
			  VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 1)
			end
		end)
		return POP_THREAD
	end)
end)

do
	local topspeed = {}
	for i = 0, 31 do
		insert(topspeed, 0)
	end
	ui.add_num_option(TRANSLATION["Change max speed"], __submenus["PlayerlistVehicle"], 0, 1000, 1, function(int) HudSound("YES") topspeed[online.get_selected_player()] = int end)
	ui.add_click_option(TRANSLATION["Set max speed"], __submenus["PlayerlistVehicle"], function()
		local pid = online.get_selected_player()
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
		local veh = vehicles.get_player_vehicle(pid)
		if veh == 0 then HudSound("ERROR") return end
		HudSound("SELECT")
		CreateRemoveThread(true, 'set_max_speed_'..thread_count, function(tick)
			-- if tick == 50 then return POP_THREAD end
			-- if not features.request_control_once(veh) then return end
			entities.request_control(veh, function()
				ENTITY.SET_ENTITY_MAX_SPEED(veh, topspeed[pid])
			end)
			return POP_THREAD
		end)
	end)

end

do
	local change
	ui.add_click_option(TRANSLATION["Copy outfit"], __submenus["PlayerlistOther"], function()
		local pid = online.get_selected_player()
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
		HudSound("SELECT")
		local ped = features.player_ped(pid)
		local model = ENTITY.GET_ENTITY_MODEL(ped)
		local outfit = peds.get_outfit(ped)
		local weapon = peds.get_weapons()
		if model ~= ENTITY.GET_ENTITY_MODEL(features.player_ped()) then
			if change == pid then
				CreateRemoveThread(true, 'change_model', function()
					local loaded, hash = features.request_model(model)
					if loaded == 0 then return end
					PLAYER.SET_PLAYER_MODEL(PLAYER.PLAYER_ID(), model)
					local my_ped = features.player_ped()
					PED._SET_PED_EYE_COLOR(my_ped, PED._GET_PED_EYE_COLOR(ped))
					for i = 0, 12
					do
						PED.SET_PED_HEAD_OVERLAY(my_ped, i, PED._GET_PED_HEAD_OVERLAY_VALUE(ped, i), 1)
					end
					peds.apply_outfit(outfit.components, outfit.props)
					peds.set_weapons(weapon)
					return POP_THREAD
				end)
				change = nil
			else
				system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Player has different model, would you like to change?"], 0, 128, 255, 255)
				change = pid
			end
			return
		end
		peds.apply_outfit(outfit.components, outfit.props)
		change = nil
	end)

	CreateRemoveThread(true, 'player_check', function()
		if not ui.is_sub_open(__submenus["PlayerlistOther"]) or (change and NETWORK.NETWORK_IS_PLAYER_CONNECTED(change) == 0) then
			change = nil
		end
	end)
end

ui.add_click_option(TRANSLATION["Clone vehicle"], __submenus["PlayerlistOther"], function()
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	local veh = vehicles.get_player_vehicle(pid)
	if veh == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	world_spawner.create_vehicle({world_saver.get_properties(veh, true)}, false, veh)
end)

__options.players["ChatMock"] = ui.add_bool_option(TRANSLATION["Chat mOcK"], __submenus["PlayerlistOther"], function(bool)
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	HudSound("TOGGLE_ON")
	playerlist[pid]["ChatMock"] = bool
end)

__options.players["Commands"] = ui.add_bool_option(TRANSLATION["Allow commands"], __submenus["PlayerlistOther"], function(bool)
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	HudSound("TOGGLE_ON")
	playerlist[pid]["Commands"] = bool
end)

__options.players["Exclude"] = ui.add_bool_option(TRANSLATION["Exclude player"], __submenus["PlayerlistOther"], function(bool)
	HudSound("TOGGLE_ON")
	if bool then
		features.player_excludes[tostring(online.get_rockstar_id(online.get_selected_player()))] = {
			name = online.get_name(online.get_selected_player())
		}
		SaveExcludes()
		system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Player added to excludes"], 0, 255, 0, 225, true)
	else
		features.player_excludes[tostring(online.get_rockstar_id(online.get_selected_player()))] = nil
		SaveExcludes()
		system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Player removed from excludes"], 0, 255, 0, 225, true) 
	end
end)

__options.players["Waypoint"] = ui.add_bool_option(TRANSLATION["Add waypoint"], __submenus["PlayerlistOther"], function(bool)
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	HudSound("TOGGLE_ON")
	for i = 0, 31
	do
		playerlist[i]["Waypoint"] = false
	end
	playerlist[pid]["Waypoint"] = bool
	CreateRemoveThread(bool, 'waypoint_player', function()
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return POP_THREAD end
		local pos = features.get_player_coords(pid)
		HUD.SET_NEW_WAYPOINT(pos.x, pos.y)
	end)
end)

do
	local tp
	ui.add_click_option(TRANSLATION["To me"], __submenus["PlayerlistTeleport"], function()
		local pid = online.get_selected_player()
		if tp or pid == PLAYER.PLAYER_ID() or NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
		local veh = vehicles.get_player_vehicle(pid)
		local ped = features.player_ped(pid)
		local pos_to = features.get_offset_from_player_coords(vector3.forward(5))
		local my_pos = features.get_player_coords()
		if veh ~= 0 then
			entities.request_control(veh, function()
				features.teleport(veh, pos_to.x, pos_to.y, pos_to.z)
			end)
			return
		end
		tp = true
		local bail = clock() + 30
		local function BailCheck()
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 or bail < clock() then
				NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(false, ped)
				features.teleport(features.player_ped(), my_pos.x, my_pos.y, my_pos.z)
				tp = false
				system.notify(TRANSLATION["Imagined Menu"], TRANSLATION['Failed to teleport'], 255, 0, 0, 255, true)
				return POP_THREAD
			end
		end
		local se
		local wait
		local inveh
		CreateRemoveThread(true, 'teleport_player', function()
			PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
			if BailCheck() == 0 then return POP_THREAD end
			NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(true, ped)
			local pos = features.get_player_coords(pid)
			local veh = vehicles.get_player_vehicle(pid)
			if veh ~= 0 then
				inveh = true
				entities.request_control(veh, function()
					features.teleport(veh, pos_to.x, pos_to.y, pos_to.z)
				end)
				if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) == 1 then
					wait = clock() + .2
				end
				if wait and wait < clock() then
					TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
					features.delete_entity(veh)
					NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(false, ped)
					features.teleport(features.player_ped(), my_pos.x, my_pos.y, my_pos.z)
					tp = false
					return POP_THREAD
				end
			elseif pos.z ~= -50 and not se then
				se = true
				online.send_script_event(pid, -555356783, PLAYER.PLAYER_ID(), 1, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
			end
			if inveh and veh == 0 then
				inveh = false
				se = false
			end
		end)
	end)

	ui.add_click_option(TRANSLATION["To waypoint"], __submenus["PlayerlistTeleport"], function()
		local pid = online.get_selected_player()
		if tp or pid == PLAYER.PLAYER_ID() or NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
		if HUD.IS_WAYPOINT_ACTIVE() == 0 then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["No waypoint has been set"], 255, 128, 0, 255) HudSound("ERROR") return end
		HudSound("SELECT")
		local w_pos = features.get_waypoint_coord()
		local success, groundZ
		local b_pos = features.get_blip_for_coord(w_pos)
		CreateRemoveThread(true, 'get_waypoint_Z', function(tick)
			if not b_pos then
				system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Preparing teleport"], 0, 128, 255, 255)
				local Z = (tick+1) * 100
				STREAMING.REQUEST_COLLISION_AT_COORD(w_pos.x, w_pos.y, Z)
				success, groundZ = features.get_ground_z(vector3(w_pos.x, w_pos.y, Z))
				if not success and Z < 900 then return end
				if not success then ticks['get_waypoint_Z'] = nil return end
			end
			local veh = vehicles.get_player_vehicle(pid)
			local ped = features.player_ped(pid)
			local my_pos = features.get_player_coords()
			local pos_to = b_pos and b_pos or vector3(w_pos.x, w_pos.y, groundZ + 1)
			if veh ~= 0 then
				entities.request_control(veh, function()
					features.teleport(veh, pos_to.x, pos_to.y, pos_to.z)
				end)
				return
			end
			tp = true
			local bail = clock() + 30
			local function BailCheck()
				PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
				if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 or bail < clock() then
					NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(false, ped)
					features.teleport(features.player_ped(), my_pos.x, my_pos.y, my_pos.z)
					tp = false
					system.notify(TRANSLATION["Imagined Menu"], TRANSLATION['Failed to teleport'], 255, 0, 0, 255, true)
					return POP_THREAD
				end
			end
			local se
			local wait
			local inveh
			CreateRemoveThread(true, 'teleport_player', function()
				if BailCheck() == 0 then return POP_THREAD end
				NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(true, ped)
				local pos = features.get_player_coords(pid)
				local veh = vehicles.get_player_vehicle(pid)
				if veh ~= 0 then
					inveh = true
					entities.request_control(veh, function()
						features.teleport(veh, pos_to.x, pos_to.y, pos_to.z)
					end)
					if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) == 1 then
						wait = clock() + .2
					end
					if wait and wait < clock() then
						TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
						features.delete_entity(veh)
						NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(false, ped)
						features.teleport(features.player_ped(), my_pos.x, my_pos.y, my_pos.z)
						tp = false
						return POP_THREAD
					end
				elseif pos.z ~= -50 and not se then
					se = true
					online.send_script_event(pid, -555356783, PLAYER.PLAYER_ID(), 1, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
				end
				if inveh and veh == 0 then
					inveh = false
					se = false
				end
			end)
			return POP_THREAD
		end)
	end)
end

ui.add_click_option(TRANSLATION["Near me"], __submenus["PlayerlistTeleport"], function() 
	local pid = online.get_selected_player()
	if pid == PLAYER.PLAYER_ID() or NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	local my_pos = features.get_player_coords()
	local apartment = features.get_closest_apartment_to_coord(my_pos)
	online.send_script_event(pid, -1390976345, PLAYER.PLAYER_ID(), pid, 1, 0, apartment, 1, 1, 1)
end)

ui.add_click_option(TRANSLATION["Near waypoint"], __submenus["PlayerlistTeleport"], function()
	local pid = online.get_selected_player()
	if pid == PLAYER.PLAYER_ID() or NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	if HUD.IS_WAYPOINT_ACTIVE() == 0 then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["No waypoint has been set"], 255, 128, 0, 255) HudSound("ERROR") return end
	HudSound("SELECT")
	local my_pos = features.get_waypoint_coord()
	local apartment = features.get_closest_apartment_to_coord(my_pos)
	online.send_script_event(pid, -1390976345, PLAYER.PLAYER_ID(), pid, 1, 0, apartment, 1, 1, 1)
end)

ui.add_click_option(TRANSLATION["Send to cutscene"], __submenus["PlayerlistTeleport"], function() 
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	local time = clock() + 1.5
	local f_pos = features.get_player_coords()
	local veh = vehicles.get_player_vehicle()
	local teleported
	CreateRemoveThread(true, 'send_to_cutscene', function()
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then
			if not teleported then return POP_THREAD end
			if veh ~= 0 then
				PED.SET_PED_INTO_VEHICLE(features.player_ped(), veh, -1)
			end
			features.teleport(features.player_ped(), f_pos.x, f_pos.y, f_pos.z)
			return POP_THREAD 
		end
		local my_pos = features.get_player_coords()
		local pl_pos = features.get_player_coords2(pid)
		if my_pos:sqrlen(pl_pos) > 2500 then
			features.teleport(features.player_ped(), pl_pos.x, pl_pos.y + 50, pl_pos.z == -50 and 1000 or pl_pos.z)
			teleported = true
		end
		online.send_script_event(pid, 2131601101, PLAYER.PLAYER_ID())
		if pl_pos.z == -50 then time = clock() + 1.5 return end 
		if time > clock() then return end 
		if not teleported then return POP_THREAD end
		if veh ~= 0 then
			PED.SET_PED_INTO_VEHICLE(features.player_ped(), veh, -1)
		end
		features.teleport(features.player_ped(), f_pos.x, f_pos.y, f_pos.z)
		return POP_THREAD
	end)
end)

__options.choose["PlayerWarehouse"] = ui.add_choose(TRANSLATION["Send to warehouse"], __submenus["PlayerlistTeleport"], false, {TRANSLATION["Random"], "Pacific Bait Storage", "White Widow Garage", "Celltowa Unit", "Convenience Store Lockup", "Foreclosed Garage", "Xero Gas Factory", "Derriere Lingerie Backlot", "Bilgeco Warehouse", "Pier 400 Utility Building", "GEE Warehouse", "LS Marine Building 3", "Railyard Warehouse", "Fridgit Annexe", "Disused Factory Outlet", "Discount Retail Unit", "Logistics Depot", "Darnel Bros Warehouse", "Wholesale Furniture", "Cypress Warehouses", "West Vinewood Backlot", "Old Power Station", "Walker & Sons Warehouse"}, function(int)
	system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["This feature is currently not available"], 255, 0, 0, 255)
	return HudSound("ERROR")
	-- local pid = online.get_selected_player()
	-- if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	-- HudSound("YES")
	-- online.send_script_event(pid, 3848692214, PLAYER.PLAYER_ID(), 0, 1, int == 0 and random(1, 22) or int)
end)

__options.choose["PlayerTpCayo"] = ui.add_choose(TRANSLATION["Send to island"], __submenus["PlayerlistTeleport"], false, {TRANSLATION["Normal"], TRANSLATION["Instant"], TRANSLATION["LSIA"], TRANSLATION["Beach"]}, function(int)
	local pid = online.get_selected_player()
	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
	HudSound("YES")
	if int == 0 then
		online.send_script_event(pid, 1361475530, PLAYER.PLAYER_ID(), 1)
	elseif int == 1 then
		online.send_script_event(pid, 1214823473, PLAYER.PLAYER_ID(), pid, pid, 4, 1)
	elseif int == 2 then
		online.send_script_event(pid, 1214823473, PLAYER.PLAYER_ID(), pid, pid, 3, 0)
	elseif int == 3 then
		online.send_script_event(pid, 1214823473, PLAYER.PLAYER_ID(), pid, pid, 4, 0)
	end
end)

do
	local types = {TRANSLATION["Severe Weather Patterns"], TRANSLATION["Half-truck Bully"], TRANSLATION["Exit Strategy"], TRANSLATION["Offshore Assets"], TRANSLATION["Cover Blown"], TRANSLATION["Mole Hunt"], TRANSLATION["Data Breach"], TRANSLATION["Work Dispute"]}
	__options.choose["SendMission"] = ui.add_choose(TRANSLATION["Send to job"], __submenus["PlayerlistTeleport"], false, types, function(int)
		local pid = online.get_selected_player()
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then return HudSound("ERROR") end
		HudSound("YES")
		online.send_script_event(pid, -283041276, PLAYER.PLAYER_ID(), int)
	end)
end

ui.add_separator(TRANSLATION["Kicks and crashes"], __submenus["Imagined"])

ui.add_click_option(TRANSLATION["Kick"], __submenus["Imagined"], function()
	local player = online.get_selected_player()
	if player == PLAYER.PLAYER_ID() or NETWORK.NETWORK_IS_PLAYER_CONNECTED(player) == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	features.kick_player(player)
end)

ui.add_click_option(TRANSLATION["SE Crash"], __submenus["Imagined"], function()
	local player = online.get_selected_player()
	if player == PLAYER.PLAYER_ID() or NETWORK.NETWORK_IS_PLAYER_CONNECTED(player) == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	features.crash_player(player)
end)

CreateRemoveThread(true, 'playerlist', function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if ui.is_open() and features.is_excluded(pid) and not ui.get_value(__options.players["Exclude"]) then
		ui.set_value(__options.players["Exclude"], true, true)
	elseif not features.is_excluded(pid) and ui.get_value(__options.players["Exclude"]) then
		ui.set_value(__options.players["Exclude"], false, true)
	end
	if veh ~= 0 then
		local doorlock = VEHICLE.GET_VEHICLE_DOOR_LOCK_STATUS(veh)
		if doorlock == 2 and not ui.get_value(__options.players["LockVehicle"]) then
			ui.set_value(__options.players["LockVehicle"], true, true)
		elseif doorlock ~= 2 and ui.get_value(__options.players["LockVehicle"]) then
			ui.set_value(__options.players["LockVehicle"], false, true)
		end
		if doorlock == 4 and not ui.get_value(__options.players["ChildLocks"]) then
			ui.set_value(__options.players["ChildLocks"], true, true)
		elseif  doorlock ~= 4 and ui.get_value(__options.players["ChildLocks"]) then
			ui.set_value(__options.players["ChildLocks"], false, true)
		end
		ui.set_value(__options.players["VehicleGod"], features.get_godmode(veh), true)
	else
		if ui.get_value(__options.players["LockVehicle"]) then
			ui.set_value(__options.players["LockVehicle"], false, true)
		end
		if ui.get_value(__options.players["ChildLocks"]) then
			ui.set_value(__options.players["ChildLocks"], false, true)
		end
		if ui.get_value(__options.players["VehicleGod"]) then
			ui.set_value(__options.players["VehicleGod"], false, true)
		end
	end
	for k, v in pairs(playerlist[pid])
	do
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 then
			playerlist[pid][k] = false
		end
		if playerlist[pid][k] and not ui.get_value(__options.players[k]) then
			ui.set_value(__options.players[k], true, true)
		elseif not playerlist[pid][k] and ui.get_value(__options.players[k]) then
			ui.set_value(__options.players[k], false, true)
		end
	end
	for i = 0, 31
	do
		if playerlist[i]["Freeze"] then
			online.send_script_event(i, 1280542040, PLAYER.PLAYER_ID(), 0, 1, 0, globals.get_int(1892703 + (1 + (i * 599) + 510)))
			TASK.CLEAR_PED_TASKS_IMMEDIATELY(features.player_ped(i))
		end
		if playerlist[i]["HonkBoosting"] then
			local veh = vehicles.get_player_vehicle(pid)
			if veh ~= 0 and AUDIO.IS_HORN_ACTIVE(veh) ~= 0 then 
				entities.request_control(veh, function()
					local speed = ENTITY.GET_ENTITY_SPEED(veh)
					VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, speed + 20)
				end)
			end
		end
	end
end)

---------------------------------------------------------------------------------------------------------------------------------
-- Self
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'self submenu') end
__submenus["Self"] = ui.add_submenu(TRANSLATION["Self"])
__suboptions["Self"] = ui.add_sub_option(TRANSLATION["Self"], __submenus["MainSub"], __submenus["Self"])

__submenus["GhostRider"] = ui.add_submenu(TRANSLATION["Ghost rider"])
__suboptions["GhostRider"] = ui.add_sub_option(TRANSLATION["Ghost rider"], __submenus["Self"], __submenus["GhostRider"])

do
	local comp = {}
	local props = {}
	local chains = {}
	local flame = {
		vehicle = {}
	}
	local sanctus = 0
	local spawn
	for i = 1, 8 do
		chains[i] = 0
	end
	local ghostrider_chains = {
    {0.00999999885, 0.139999986, 0.0299999975, 0, -49.9999962, 0},
    {-0.119999982, -0.0699999779, -0.0699999928, 9.99999714, -49.9999962, 0},
    {0.0299999993, -0.0900000036, 0.049999997, 0, -39.9999962, -7.4505806e-08},
    {0.170000002, -0.0500000007, 0.139999986, 0, -30.9999962, 0},
    {0.0899999887, 0.0999999717, 0.109999985, 1.86264515e-09, -39.9999924, 0},
    {-0.0999998376, 0.100000001, -0.0900002569, -9.99999905, -50.0299911, 0},
    {-0.0699571669, 0.130019873, -0.0500002541, -19.9999981, -54.9999962, 0},
    {38, 0.139999971, 0.0299999844, 0.139999986, 0, -29.9999962, 0},
	}
	local ghostRider = {
		male = {
			components = {
				[0] = {24, 0},
				{2, 2},
				{22, 3},
				{33, 0},
				{4, 0},
				{0, 0},
				{12, 6},
				{0, 0},
				{2, 2},
				{0, 0},
				{0, 0},
				{64, 0},
			},
		},
		female = {
			components = {
				[0] = {24, 0},
				{2, 2},
				{22, 3},
				{36, 0},
				{27, 0},
				{0, 0},
				{24, 0},
				{0, 0},
				{1, 0},
				{0, 0},
				{0, 0},
				{55, 0},
			},
		}
	}

	local function DeleteGhostRider()
		local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(sanctus, -1, true)
		TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
		features.delete_entity(sanctus)
		for i = 1, 2
		do
			if flame.vehicle[i] then features.delete_entity(flame.vehicle[i]) end
		end
		spawn = nil
	end

	__options.bool["GhostRiderOutfit"] = ui.add_bool_option(TRANSLATION["Become rider"], __submenus["GhostRider"], function(bool)
		local ped = features.player_ped()
		local model = ENTITY.GET_ENTITY_MODEL(ped)
		if model ~= utils.joaat("mp_f_freemode_01") and model ~= utils.joaat("mp_m_freemode_01") then
			system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Ghost rider outfit works only on mp male and female"], 255, 0, 0, 255)
			ui.set_value(__options.bool["GhostRiderOutfit"], false, true)
			return HudSound("ERROR")
		end
		HudSound("TOGGLE_ON")
		if bool then
			if filesystem.exists(files['TimeToBurn']) then
				system.play_wav(files['TimeToBurn'])
			end
			local outfit = peds.get_outfit()
			comp = outfit.components
			props = outfit.props
		end
		if not bool then
			peds.apply_outfit(comp, props)
			for _, v in ipairs(chains)
			do
				features.delete_entity(v)
			end
			flame._self = nil
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(utils.joaat("prop_cs_leg_chain_01"))
			STREAMING.REMOVE_NAMED_PTFX_ASSET("core")
		end
		CreateRemoveThread(bool, 'ghost_rider_outfit', function()
			if STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("core") == 0 then
				STREAMING.REQUEST_NAMED_PTFX_ASSET("core")
				return
			end
			local ped = features.player_ped()
			local model = ENTITY.GET_ENTITY_MODEL(ped)
			if model == utils.joaat("mp_f_freemode_01") then
				PED.CLEAR_ALL_PED_PROPS(features.player_ped())
				peds.apply_outfit(ghostRider.female.components, {})
			elseif model == utils.joaat("mp_m_freemode_01") then
				PED.CLEAR_ALL_PED_PROPS(features.player_ped())
				peds.apply_outfit(ghostRider.male.components, {})
			else
				system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Ghost rider outfit works only on mp male and female"], 255, 0, 0, 255, true)
				ui.set_value(__options.bool["GhostRiderOutfit"], false, true)
				return POP_THREAD
			end
			local ok, hash = features.request_model(utils.joaat("prop_cs_leg_chain_01"))
			if ok == 0 then return end
			local pos = features.get_player_coords()
			for i, v in ipairs(chains)
			do
				if v == 0 or ENTITY.DOES_ENTITY_EXIST(v) == 0 then
					local obj = features.create_object(hash, pos)
					ENTITY.ATTACH_ENTITY_TO_ENTITY(obj, ped, 38,
						ghostrider_chains[i][1], ghostrider_chains[i][2], ghostrider_chains[i][3],
						ghostrider_chains[i][4], ghostrider_chains[i][5], ghostrider_chains[i][6],
						false, true, false, false, 5, true)
					chains[i] = obj
				end
			end
			if not flame._self then
				GRAPHICS.USE_PARTICLE_FX_ASSET("core")
				flame._self = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY("ent_amb_beach_campfire", chains[1], 0.190000423, -0.0799999833, -0.200000033, 0, 0, 0, 0.7, false, false, false, 0, 0, 0, 1)
        GRAPHICS.SET_PARTICLE_FX_LOOPED_SCALE(flame._self, 0.7)
			end
		end)
	end)

	ui.add_click_option(TRANSLATION["Request bike"], __submenus["GhostRider"], function()
		HudSound("SELECT")
		if spawn then 
			if sanctus == 0 then return end
			DeleteGhostRider()
		end
		spawn = true
		sanctus = 0
		CreateRemoveThread(true, 'ghostrider_veh_'..thread_count, function()
			local ok, hash = features.request_model(utils.joaat("sanctus"))
			if ok == 0 then return end
			if STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("core") == 0 then 
				STREAMING.REQUEST_NAMED_PTFX_ASSET("core")
				return
			end
			local loaded, chip = features.request_model(utils.joaat("prop_crisp_small"))
			if not loaded then return end
			local pos = features.get_offset_from_player_coords(vector3(0, 5, 0))
			sanctus = vehicles.spawn_vehicle(hash, pos, features.get_player_heading())
			vehicles.set_godmode(sanctus, true)
			flame.vehicle[1] = features.create_object(chip, pos)
			flame.vehicle[2] = features.create_object(chip, pos)
			-- ENTITY.SET_ENTITY_ALPHA(flame.vehicle[1], 0, false)
			-- ENTITY.SET_ENTITY_ALPHA(flame.vehicle[2], 0, false)
			ENTITY.ATTACH_ENTITY_TO_ENTITY(flame.vehicle[1], sanctus, 0, 0, 0.8, -0.2, 0, 0, 0, false, true, false, false, 5, true)
      ENTITY.ATTACH_ENTITY_TO_ENTITY(flame.vehicle[2], sanctus, 0, 0, -0.8, -0.2, 0, 0, 0, false, true, false, false, 5, true)
      VEHICLE.SET_VEHICLE_MOD_KIT(sanctus, 0)
      local modindex = {11, 12, 13, 16, 18}
      local modtype = {3, 2, 2, 4, 1}
      for i = 1, #modindex
      do
        if VEHICLE.GET_VEHICLE_MOD(sanctus, modindex[i]) ~= modtype[i] then
          VEHICLE.SET_VEHICLE_MOD(sanctus, modindex[i], modtype[i], false)
        end
      end
      VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(sanctus, false)
      VEHICLE.SET_VEHICLE_COLOURS(sanctus, 126, 126)
      VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(sanctus, 0, 0, 0)
      VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(sanctus, 0, 0, 0)
      VEHICLE.SET_VEHICLE_EXTRA_COLOURS(sanctus, 0, 0)
      VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(sanctus, "RIDER")
      ENTITY.SET_ENTITY_RENDER_SCORCHED(sanctus, true)
			features.unload_models(utils.joaat("prop_crisp_small"), utils.joaat("sanctus"))
			for i = 1, 2
			do
				GRAPHICS.USE_PARTICLE_FX_ASSET("core")
				local ptfx = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY("ent_amb_beach_campfire", flame.vehicle[i], 0, 0, 0, 0, 0, 0, 1, false, false, false, 0, 0, 0, 1)
				GRAPHICS.SET_PARTICLE_FX_LOOPED_SCALE(ptfx, 1)
	    end
			STREAMING.REMOVE_NAMED_PTFX_ASSET("core")
			return POP_THREAD
		end)
	end)

	ui.add_click_option(TRANSLATION["Return bike"], __submenus["GhostRider"], function()
		if not spawn then HudSound("ERROR") return end
		HudSound("SELECT")
		DeleteGhostRider()
	end)

end

do
	local anims = {}

	for i, v in ipairs(peds.anims)
	do
		insert(anims, TRANSLATION[v[1]])
	end

	local blend_in_speed = 8
	local blend_out_speed = -8
	local duration = -1
	local playback_rate = 0
	local flags = {0,0,0,0,0}
	local lock = false
	local on_peds
	__submenus["PlayAnim"] = ui.add_submenu(TRANSLATION["Play animation"])
	__suboptions["PlayAnim"] = ui.add_sub_option(TRANSLATION["Play animation"], __submenus["Self"], __submenus["PlayAnim"])
	ui.add_click_option(TRANSLATION["Stop animation"], __submenus["PlayAnim"], function() HudSound("SELECT") TASK.CLEAR_PED_TASKS_IMMEDIATELY(features.player_ped()) end)
	__options.bool["OnNearbyPeds"] = ui.add_bool_option(TRANSLATION["Play only on nearby peds"], __submenus["PlayAnim"], function(bool) HudSound("TOGGLE_ON") on_peds = bool end)
	ui.add_separator(TRANSLATION["Animations"], __submenus["PlayAnim"])

	__options.num["BlendInSpeed"] = ui.add_num_option(TRANSLATION["Blend-In Speed"], __submenus["PlayAnim"], -999999999, 999999999, 1, function(int) HudSound("YES") blend_in_speed = int end)
	ui.set_value(__options.num["BlendInSpeed"], blend_in_speed, true)
	__options.num["BlendOutSpeed"] = ui.add_num_option(TRANSLATION["Blend-Out Speed"], __submenus["PlayAnim"], -999999999, 999999999, 1, function(int) HudSound("YES") blend_out_speed = int end)
	ui.set_value(__options.num["BlendOutSpeed"], blend_out_speed, true)
	__options.num["Duration"] = ui.add_num_option(TRANSLATION["Duration (ms)"], __submenus["PlayAnim"], -1, 999999999, 100, function(int) HudSound("YES") duration = int end)
	ui.set_value(__options.num["Duration"], duration, true)
	__options.num["PlaybackRate"] = ui.add_float_option(TRANSLATION["Playback rate"], __submenus["PlayAnim"], 0, 1, .1, 1, function(float) HudSound("YES") playback_rate = int end)
	ui.set_value(__options.num["PlaybackRate"], playback_rate, true)
	__options.bool["Loop"] = ui.add_bool_option(TRANSLATION["Loop"], __submenus["PlayAnim"], function(bool) HudSound("TOGGLE_ON") if bool then flags[1] = enum.anim_flag.Loop else flags[1] = 0 end end)
	__options.bool["StopOnLastFrame"] = ui.add_bool_option(TRANSLATION["Stop on last frame"], __submenus["PlayAnim"], function(bool) HudSound("TOGGLE_ON") if bool then flags[2] = enum.anim_flag.StopOnLastFrame else flags[2] = 0 end end)
	__options.bool["OnlyAnimateUpperBody"] = ui.add_bool_option(TRANSLATION["Only animate upper body"], __submenus["PlayAnim"], function(bool) HudSound("TOGGLE_ON") if bool then flags[3] = enum.anim_flag.OnlyAnimateUpperBody else flags[3] = 0 end end)
	__options.bool["AllowPlayerControl"] = ui.add_bool_option(TRANSLATION["Allow player control"], __submenus["PlayAnim"], function(bool) HudSound("TOGGLE_ON") if bool then flags[4] = enum.anim_flag.AllowPlayerControl else flags[4] = 0 end end)
	__options.bool["Cancellable"] = ui.add_bool_option(TRANSLATION["Cancellable"], __submenus["PlayAnim"], function(bool) HudSound("TOGGLE_ON") if bool then flags[5] = enum.anim_flag.Cancellable else flags[5] = 0 end end)
	__options.bool["LockPos"] = ui.add_bool_option(TRANSLATION["Lock position"], __submenus["PlayAnim"], function(bool) HudSound("TOGGLE_ON") lock = bool end)

	__options.choose["PlayAnim"] = ui.add_choose(TRANSLATION["Play"], __submenus["PlayAnim"], false, anims, function(int) 
		HudSound("YES")
		local anim_dict = peds.anims[int + 1][2]
		local anim_name = peds.anims[int + 1][3]
		local flag = 0
		for _, v in ipairs(flags)
		do
			flag = --[[features.OR(flag, v)]] flag + v
		end
		CreateRemoveThread(true, 'animation_'..thread_count, function()
			if STREAMING.HAS_ANIM_DICT_LOADED(anim_dict) == 0 then
				STREAMING.REQUEST_ANIM_DICT(anim_dict)
				return
			end
			if on_peds then
				for _, v in ipairs(entities.get_peds())
				do
					if v ~= features.player_ped() then
						entities.request_control(v, function()
							PED.SET_PED_CAN_RAGDOLL(v, false)
							PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT(v, false)
							peds.calm_ped(v, true)
							TASK.CLEAR_PED_TASKS_IMMEDIATELY(v)
							peds.play_anim(v, anim_dict, anim_name, blend_in_speed, blend_out_speed, duration, flag, playback_rate, lock)
						end)
					end
				end
			else
				peds.play_anim(features.player_ped(), anim_dict, anim_name, blend_in_speed, blend_out_speed, duration, flag, playback_rate, lock)
			end
			STREAMING.REMOVE_ANIM_DICT(anim_dict)
			return POP_THREAD
		end)
	end)

	ui.add_separator(TRANSLATION["Scenarios"], __submenus["PlayAnim"])
	local scenarios = {}
	for i = 1, #peds.scenario
	do
		scenarios[i] = TRANSLATION[peds.scenario[i][1]]
	end
	__options.choose["PlayScenario"] = ui.add_choose(TRANSLATION["Play"], __submenus["PlayAnim"], false, scenarios, function(int) 
		HudSound("YES")
		if on_peds then
			for _, v in ipairs(entities.get_peds())
			do
				if v ~= features.player_ped() then
					entities.request_control(v, function()
						PED.SET_PED_CAN_RAGDOLL(v, false)
						PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT(v, false)
						peds.calm_ped(v, true)
						TASK.CLEAR_PED_TASKS_IMMEDIATELY(v)
						peds.play_scenario(v, peds.scenario[int + 1][2])
					end)
				end
			end
		else
			peds.play_scenario(features.player_ped(), peds.scenario[int + 1][2])
		end
	end)
end

do
	__submenus["PlayPTFX"] = ui.add_submenu(TRANSLATION["Play ptfx"])
	__suboptions["PlayPTFX"] = ui.add_sub_option(TRANSLATION["Play ptfx"], __submenus["Self"], __submenus["PlayPTFX"])
	local wait
	local ptfx
	local particle_efects = {}
	local bones = {}
	for i, v in ipairs(enum.ptfx)
	do
		particle_efects[i] = TRANSLATION[v[1]]
	end

	__options.bool["PtfxLooped"] = ui.add_bool_option(TRANSLATION["Looped"], __submenus["PlayPTFX"], function(bool) HudSound("TOGGLE_ON")
		settings.Self["PtfxLooped"] = bool 
	end)
	__options.bool["PtfxHead"] = ui.add_bool_option(TRANSLATION["Head"], __submenus["PlayPTFX"], function(bool) HudSound("TOGGLE_ON")
		settings.Self["PtfxHead"] = bool
		bones[0x796e] = bool
	end)
	__options.bool["PtfxLeftArm"] = ui.add_bool_option(TRANSLATION["Left arm"], __submenus["PlayPTFX"], function(bool) HudSound("TOGGLE_ON")
		settings.Self["PtfxLeftArm"] = bool
		bones[0x49d9] = bool
	end)
	__options.bool["PtfxRightArm"] = ui.add_bool_option(TRANSLATION["Right arm"], __submenus["PlayPTFX"], function(bool) HudSound("TOGGLE_ON")
		settings.Self["PtfxRightArm"] = bool
		bones[0xdead] = bool
	end)
	__options.bool["PtfxLeftLeg"] = ui.add_bool_option(TRANSLATION["Left leg"], __submenus["PlayPTFX"], function(bool) HudSound("TOGGLE_ON")
		settings.Self["PtfxLeftLeg"] = bool
		bones[0x3779] = bool
	end)
	__options.bool["PtfxRightLeg"] = ui.add_bool_option(TRANSLATION["Right leg"], __submenus["PlayPTFX"], function(bool) HudSound("TOGGLE_ON")
		settings.Self["PtfxRightLeg"] = bool
		bones[0xcc4d] = bool
	end)
	__options.num["PtfxDelay"] = ui.add_float_option(TRANSLATION["Delay (seconds)"], __submenus["PlayPTFX"], 0, 1, .01, 3, function(float) HudSound("YES") settings.Self["PtfxDelay"] = features.round(float, 3) end)
	__options.num["PtfxScale"] = ui.add_float_option(TRANSLATION["Scale"], __submenus["PlayPTFX"], 0, 10, .05, 2, function(float) HudSound("YES") settings.Self["PtfxScale"] = features.round(float, 2) end)
	ui.add_choose(TRANSLATION["Particle effects"], __submenus["PlayPTFX"], false, particle_efects, function(int)
		HudSound("YES")
		CreateRemoveThread(true, 'self_play_ptfx', function()
			if ptfx and ptfx ~= enum.ptfx[int+1][2] then
				STREAMING.REMOVE_NAMED_PTFX_ASSET(ptfx)
			end
			ptfx = enum.ptfx[int+1][2]
			if STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(ptfx) == 0 then 
				STREAMING.REQUEST_NAMED_PTFX_ASSET(ptfx)
				return
			end
			if not settings.Self["PtfxLooped"] then wait = nil end
			if wait and wait > clock() - settings.Self["PtfxDelay"] then return end
			wait = clock()
			for k, v in pairs(bones)
			do
				if v then
					GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx)
					GRAPHICS._START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY_BONE(enum.ptfx[int+1][3], features.player_ped(), 0, 0, 0, -90, 0, 0, PED.GET_PED_BONE_INDEX(features.player_ped(), k), settings.Self["PtfxScale"], false, false, false)
				end
			end
			if not settings.Self["PtfxLooped"] then
				return POP_THREAD
			end
		end)
	end)
end

do
	__options.num["NoClipMultiplier"] = ui.add_float_option(TRANSLATION["No clip speed multiplier"], __submenus["Self"], 0.1, 20, .1, 1, function(float) HudSound("YES") settings.Self["NoClipMultiplier"] = features.round(float, 1) end)

	local nocliptype = 0
	__options.choose["NoClip"] = ui.add_choose(TRANSLATION["No clip"], __submenus["Self"], false, {TRANSLATION["None"], TRANSLATION["Mouse"], TRANSLATION["Keyboard"]}, function(int)
		HudSound("YES")
		nocliptype = int
		if int == 0 then
      if vehicles.get_player_vehicle() ~= 0 then
        local Vehicle = vehicles.get_player_vehicle()
        entities.request_control(Vehicle, function()
        	ENTITY.FREEZE_ENTITY_POSITION(features.player_ped(), false)
          ENTITY.FREEZE_ENTITY_POSITION(Vehicle, false)
          ENTITY.SET_ENTITY_COLLISION(Vehicle, true, true)
          features.set_entity_velocity(Vehicle, 0, 0, -0.0001)
      	end)
      else
        local ped = features.player_ped()
        ENTITY.FREEZE_ENTITY_POSITION(ped, false)
        ENTITY.SET_ENTITY_COLLISION(ped, true, true)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
      end
    else
    	dont_play_tog = true
    	if __options.bool["FreeCam"] then
    		ui.set_value(__options.bool["FreeCam"], false, false)
    	end
	    if vehicles.get_player_vehicle() == 0 then
	      TASK.CLEAR_PED_TASKS_IMMEDIATELY(features.player_ped())
	    end
	  end
	end)
  CreateRemoveThread(true, 'self_no_clip', 
  function()
  	if nocliptype == 0 then return end
  	PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.ATTACK, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.NEXT_CAMERA, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.LOOK_LR, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.LOOK_UD, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.MULTIPLAYER_INFO, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.AIM, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.WEAPON_WHEEL_UD, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.WEAPON_WHEEL_LR, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.WEAPON_WHEEL_NEXT, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.WEAPON_WHEEL_PREV, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.SELECT_NEXT_WEAPON, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.SELECT_PREV_WEAPON, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.CHARACTER_WHEEL, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.SNIPER_ZOOM, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.FRONTEND_PAUSE, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.FRONTEND_PAUSE_ALTERNATE, true)
  	PAD.ENABLE_CONTROL_ACTION(0, enum.input.VEH_FLY_ATTACK, true)
    local entself = features.player_ped()
    if vehicles.get_player_vehicle() ~= 0 then
    	entself = vehicles.get_player_vehicle()
    	features.request_control_once(entself)
    end 
    if nocliptype == 2 then
    	if vehicles.get_player_vehicle() == 0 then
      	TASK.CLEAR_PED_TASKS_IMMEDIATELY(features.player_ped())
     	end
      local rot = features.get_entity_rot(entself, 5)
      ENTITY.SET_ENTITY_ROTATION(entself, 0, 0, rot.z, 5, true)
    end
    ENTITY.FREEZE_ENTITY_POSITION(entself, true)
    ENTITY.SET_ENTITY_COLLISION(entself, false, true)
    if nocliptype == 1 then 
      local rot = CAM.GET_GAMEPLAY_CAM_ROT(2)
      ENTITY.SET_ENTITY_ROTATION(entself, rot.x, rot.y, rot.z, 2, true)
    end
    local multiplier = settings.Self["NoClipMultiplier"]
    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_SUB_ASCEND) == 1 then
        multiplier = settings.Self["NoClipMultiplier"] * 5
    end
    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_UP) == 1 then
    	local posW = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entself, 0, 1 * multiplier, 0)
      ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entself, posW.x, posW.y, posW.z, false, false, false)
    end
    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_DOWN) == 1 then
        local posS = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entself, 0, -1 * multiplier, 0)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entself, posS.x, posS.y, posS.z, false, false, false)
    end
    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_LEFT) == 1 then
    	if nocliptype == 1 then
        local posA = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entself, -1 * multiplier, 0, 0)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entself, posA.x, posA.y, posA.z, false, false, false)
      else
      	local rot = features.get_entity_rot(entself, 5)
      	ENTITY.SET_ENTITY_ROTATION(entself, 0, 0, rot.z + 2, 5, true)
      end
    end
    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_RIGHT) == 1 then
    	if nocliptype == 1 then
        local posD = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entself, 1 * multiplier, 0, 0)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entself, posD.x, posD.y, posD.z, false, false, false)
      else
      	local rot = features.get_entity_rot(entself, 5)
      	ENTITY.SET_ENTITY_ROTATION(entself, 0, 0, rot.z - 2, 5, true)
      end
    end
    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_PUSHBIKE_SPRINT) == 1 then
      local posUp = features.get_entity_coords(entself)
      ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entself, posUp.x, posUp.y, posUp.z + 1 * multiplier, false, false, false)
    end
    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_SUB_DESCEND) == 1 then
      local posDow = features.get_entity_coords(entself)
      ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entself, posDow.x, posDow.y, posDow.z -1 * multiplier, false, false, false)
    end
    if settings.General["ShowControls"] and Instructional:New() then
    	Instructional.AddButton(enum.input.VEH_SUB_ASCEND, TRANSLATION["Faster"])
    	Instructional.AddButton(enum.input.VEH_FLY_THROTTLE_UP, TRANSLATION["Forward"])
    	Instructional.AddButton(enum.input.VEH_FLY_THROTTLE_DOWN, TRANSLATION["Backward"])
    	Instructional.AddButton(enum.input.VEH_FLY_YAW_LEFT, TRANSLATION["Left"])
    	Instructional.AddButton(enum.input.VEH_FLY_YAW_RIGHT, TRANSLATION["Right"])
    	Instructional.AddButton(enum.input.VEH_PUSHBIKE_SPRINT, TRANSLATION["Up"])
    	Instructional.AddButton(enum.input.VEH_SUB_DESCEND, TRANSLATION["Down"])
    	Instructional:BackgroundColor(0, 0, 0, 80)
    	Instructional:Draw()
    end
  end)
end

__options.bool["BeastMode"] = ui.add_bool_option(TRANSLATION["Beast mode"], __submenus["Self"], function(bool) HudSound("TOGGLE_ON")
	settings.Self["BeastMode"] = bool
	CreateRemoveThread(bool, 'self_beast', 
	function()
		MISC._SET_BEAST_MODE_ACTIVE(PLAYER.PLAYER_ID())
		MISC.SET_SUPER_JUMP_THIS_FRAME(PLAYER.PLAYER_ID())
	end)
end)

__options.bool["NoRagdoll"] = ui.add_bool_option(TRANSLATION["No ragdoll"], __submenus["Self"], function(bool) HudSound("TOGGLE_ON")
	settings.Self["NoRagdoll"] = bool
	local ped = features.player_ped()
	if not bool then
		PED.SET_PED_CAN_RAGDOLL(ped, true)
		PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT(ped, true)
	end
	CreateRemoveThread(bool, 'self_no_ragdoll', 
	function()
		ped = features.player_ped()
		PED.SET_PED_CAN_RAGDOLL(ped, false)
		PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT(ped, false)
	end)
end)

__options.bool["FlyMode"] = ui.add_bool_option(TRANSLATION["Fly-mode"], __submenus["Self"], function(bool) HudSound("TOGGLE_ON")
	settings.Self["FlyMode"] = bool
	local in_air
	local started
	local wait_time
	local force
	if not bool then
		STREAMING.REMOVE_ANIM_DICT('missheistfbi3b_ig6_v2')
		STREAMING.REMOVE_ANIM_DICT('missexile1_cargoplanejumpout')
	end

	CreateRemoveThread(bool, 'self_flymode', 
	function()
		if STREAMING.HAS_ANIM_DICT_LOADED('missheistfbi3b_ig6_v2') == 0 then
			STREAMING.REQUEST_ANIM_DICT('missheistfbi3b_ig6_v2')
			return
		end
		if STREAMING.HAS_ANIM_DICT_LOADED('missexile1_cargoplanejumpout') == 0 then
			STREAMING.REQUEST_ANIM_DICT('missexile1_cargoplanejumpout')
			return
		end
		if vehicles.get_player_vehicle() ~= 0 then return end
		PAD.DISABLE_CONTROL_ACTION(0, enum.input.JUMP, true)
		local ped = features.player_ped()
		if ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(ped) == 1 or ENTITY.IS_ENTITY_IN_AIR(ped) == 0 then
			if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.JUMP) == 1 and not wait_time then
				peds.play_anim(ped, 'missexile1_cargoplanejumpout', 'jump_launch_l_to_skydive', 4, -4, -1, 0, 0, false)
				wait_time = clock() + .7
				started = nil
				force = true
			end
			if in_air and ENTITY.IS_ENTITY_IN_AIR(ped) ~= 0 and started then
				local vel = vector3(ENTITY.GET_ENTITY_VELOCITY(ped))
				TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
				if vel:abs() > vector3.right(8) or vel:abs() > vector3.forward(8) then
					peds.play_anim(ped, 'missheistfbi3b_ig6_v2', 'rubble_slide_alt_franklin', 4, -4, 1000, 0, 0, false)
					local vel = vector3.zero():direction_to(vel) * 70
					features.set_entity_velocity(ped, vel.x, vel.y, 0)
					in_air = nil
				end
			end
			if started then return end
		end
		if wait_time and wait_time < clock() and force then
			features.apply_force_to_entity(ped, 1, 0, 0, 20, 0, 0, 0, 0, true, false, true, false, true)
			force = nil
			return
		elseif wait_time and wait_time + .2 > clock() then
			return
		elseif not started and wait_time then
			TASK.TASK_SKY_DIVE(ped, true)
			started = true
			wait_time = nil
		end
		if not started then return end
		if PED.IS_PED_IN_PARACHUTE_FREE_FALL(ped) == 0 then TASK.TASK_SKY_DIVE(ped, true) end
		in_air = true
		if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_UP) == 1 then
      features.apply_force_to_entity(ped, 1, 0, 1, 0, 0, 0, 0, 0, true, false, true, false, true)
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_DOWN) == 1 then
      features.apply_force_to_entity(ped, 1, 0, 10, 0, 0, 0, 0, 0, true, false, true, false, true)
    end
    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.JUMP) == 1 then
      features.apply_force_to_entity(ped, 1, 0, 0, 10, 0, 0, 0, 0, true, false, true, false, true)
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_MOVE_UD) == 1 then
      features.apply_force_to_entity(ped, 1, 0, 0, -10, 0, 0, 0, 0, true, false, true, false, true)
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_MOVE_UP_ONLY) == 1 then
      local vel = vector3(ENTITY.GET_ENTITY_VELOCITY(ped))
      local final = (vector3.zero():direction_to(vel) * 10)
      features.set_entity_velocity(ped, final.x, final.y, final.z)
    end
	  if settings.General["ShowControls"] and Instructional:New() then
    	Instructional.AddButton(enum.input.VEH_FLY_THROTTLE_UP, TRANSLATION["Forwards & down"])
    	Instructional.AddButton(enum.input.VEH_FLY_THROTTLE_DOWN, TRANSLATION["Forward"])
    	Instructional.AddButton(enum.input.JUMP, TRANSLATION["Up"])
    	Instructional.AddButton(enum.input.VEH_MOVE_UD, TRANSLATION["Down"])
    	Instructional.AddButton(enum.input.VEH_MOVE_UP_ONLY, TRANSLATION["Slow down"])
    	Instructional:BackgroundColor(0, 0, 0, 80)
    	Instructional:Draw()
    end
	end)
end)

do
	local onwater
	__options.bool["WalkOnWater"] = ui.add_bool_option(TRANSLATION["Walk on water"], __submenus["Self"], function(bool) HudSound("TOGGLE_ON")
		settings.Self["WalkOnWater"] = bool
		local Z = 0
		if not bool then
		    features.delete_entity(onwater)
		    onwater = nil
		    features.unload_models(utils.joaat("stt_prop_stunt_bblock_huge_01"))
		    MISC.WATER_OVERRIDE_SET_STRENGTH(0)
		end
		CreateRemoveThread(bool, 'self_walk_on_water', 
		function()
			MISC.WATER_OVERRIDE_SET_STRENGTH(1)
			local loaded, hash = features.request_model(utils.joaat("stt_prop_stunt_bblock_huge_01"))
			if loaded == 0 then return end
			local ped = features.player_ped()
		    local veh = vehicles.get_player_vehicle()
		    local pos = features.get_player_coords()
		    local found, Z = features.get_water_z(pos)
		    local vel = ENTITY.GET_ENTITY_VELOCITY(veh)
		    if found then
		      if not onwater or ENTITY.DOES_ENTITY_EXIST(onwater) == 0 then
		        onwater = features.create_object(hash, vector3(pos.x, pos.y, veh == 0 and Z - .2 or Z))
		        ENTITY.SET_ENTITY_VISIBLE(onwater, false, false)
		      end
		      if Z > pos.z then
		      	features.teleport(ped, pos.x, pos.y, Z + 1, nil, true)
		      else
		        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(onwater, pos.x, pos.y, veh == 0 and Z - .2 or Z, false, false, false)
		      end
		    end
		    if not found and onwater then
				features.delete_entity(onwater)
				onwater = nil
		    end
		end)
	end)
end

__options.bool["DemiGod"] = ui.add_bool_option(TRANSLATION["Demi-god"], __submenus["Self"], function(bool) HudSound("TOGGLE_ON")
	settings.Self["DemiGod"] = bool
	local maxhealth = 328
	if bool then
		maxhealth = PED.GET_PED_MAX_HEALTH(features.player_ped())
	end
	CreateRemoveThread(bool, 'self_demi_god', 
	function()
		local ped = features.player_ped()
		PED.SET_PED_MAX_HEALTH(ped, 10000)
    ENTITY.SET_ENTITY_HEALTH(ped, 10000, 0)
    ENTITY.SET_ENTITY_PROOFS(ped, true, true, true, false, true, true, true, true)
    ENTITY.SET_ENTITY_MAX_HEALTH(ped, 10000)
	end)
	if not bool then
		local ped = features.player_ped()
		PED.SET_PED_MAX_HEALTH(ped, maxhealth)
    ENTITY.SET_ENTITY_HEALTH(ped, maxhealth, 0)
    ENTITY.SET_ENTITY_PROOFS(ped, false, false, false, false, false, false, false, false)
	end
end)

__options.bool["DisableCollision"] = ui.add_bool_option(TRANSLATION["Disable collision"], __submenus["Self"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'self_no_collision', 
	function(tick)
		ENTITY.SET_ENTITY_COLLISION(features.player_ped(), false, true)
	end)
	if not bool then ENTITY.SET_ENTITY_COLLISION(features.player_ped(), true, true) end
end)

__options.bool["PedsIgnorePlayer"] = ui.add_bool_option(TRANSLATION["Peds ignore player"], __submenus["Self"], function(bool) HudSound("TOGGLE_ON")
	settings.Self['PedsIgnorePlayer'] = bool
	CreateRemoveThread(bool, 'self_peds_ignore',
	function(tick)
		if tick%10~=0 then return end
		for _, ped in ipairs(entities.get_peds())
		do
			peds.calm_ped(ped, true)
		end
		PLAYER.SET_POLICE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), true)
		PLAYER.SET_EVERYONE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), true)
		PLAYER.SET_PLAYER_CAN_BE_HASSLED_BY_GANGS(PLAYER.PLAYER_ID(), false)
		PLAYER.SET_IGNORE_LOW_PRIORITY_SHOCKING_EVENTS(PLAYER.PLAYER_ID(), true)
	end)

	if not bool then
		PLAYER.SET_POLICE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), false)
		PLAYER.SET_EVERYONE_IGNORE_PLAYER(PLAYER.PLAYER_ID(), false)
		PLAYER.SET_PLAYER_CAN_BE_HASSLED_BY_GANGS(PLAYER.PLAYER_ID(), true)
		PLAYER.SET_IGNORE_LOW_PRIORITY_SHOCKING_EVENTS(PLAYER.PLAYER_ID(), false)
		for _, ped in ipairs(entities.get_peds())
		do
			peds.calm_ped(ped, false)
		end
	end

end)

__options.bool["PoliceMode"] = ui.add_bool_option(TRANSLATION["Police mode"], __submenus["Self"], function(bool) HudSound("TOGGLE_ON")
	settings.Self['PoliceMode'] = bool
	CreateRemoveThread(bool, 'self_police_mode',
	function()
		local veh = vehicles.get_player_vehicle()
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh and features.get_entity_coords(v):sqrlen(features.get_player_coords()) <= 2500 then
				local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(v, -1, true)
				if ped ~= 0 then
					TASK.TASK_VEHICLE_TEMP_ACTION(ped, v, 26, 500)
				end
			end
		end
	end)
end)

__options.bool["LinkHeading"] = ui.add_bool_option(TRANSLATION["Link heading with camera"], __submenus["Self"], function(bool) HudSound("TOGGLE_ON")
	settings.Self['LinkHeading'] = bool
	CreateRemoveThread(bool, 'self_link_heading',
	function()
		if vehicles.get_player_vehicle() ~= 0 then return end
		ENTITY.SET_ENTITY_HEADING(features.player_ped(), CAM.GET_GAMEPLAY_CAM_ROT(2).z)
	end)
end)

__options.bool["ForceOutfit"] = ui.add_bool_option(TRANSLATION["Force outfit"], __submenus["Self"], function(bool) HudSound("TOGGLE_ON")
	settings.Self['ForceOutfit'] = bool
	local outfit = peds.get_outfit()
	CreateRemoveThread(bool, 'self_force_outfit',
	function()
		peds.apply_outfit(outfit.components, outfit.props)
	end)

end)

__options.num["RunSpeed"] = ui.add_float_option(TRANSLATION["Run speed multiplier"], __submenus["Self"], -10000, 10000, 0.1, 3, function(float) HudSound("YES")
	if float == 10000 then
		system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["I don't think you need to be faster"], 0, 128, 255, 255, true)
	end
	CreateRemoveThread(true, 'self_run_speed', function()
		local addr = s_memory.get_memory_address(s_memory.WorldPtr, {0x08, 0x10C8, 0xCF0})
		if addr == 0 then return end
		memory.write_float(addr, float)
		if float == 1 then return POP_THREAD end
	end)
end)

ui.set_value(__options.num["RunSpeed"], 1.0, true)
__options.num["SwimSpeed"] = ui.add_float_option(TRANSLATION["Swim speed multiplier"], __submenus["Self"], -10000, 10000, 0.1, 3, function(float) HudSound("YES")
	CreateRemoveThread(true, 'self_swim_speed', function()
		local addr = s_memory.get_memory_address(s_memory.WorldPtr, {0x08, 0x10C8, 0x170})
		if addr == 0 then return end
		memory.write_float(addr, float)
	end)
end)
ui.set_value(__options.num["SwimSpeed"], 1.0, true)

__options.num["Set Alpha"] = ui.add_num_option(TRANSLATION["Set alpha"], __submenus["Self"], 0, 255, 1, function(int)
	HudSound("YES") 
	ENTITY.SET_ENTITY_ALPHA(features.player_ped(), int, false)
end)

__options.num["ForceField"] = ui.add_num_option(TRANSLATION["Force field"], __submenus["Self"], 0, 100, 1, function(int) HudSound("YES") settings.Self["ForceField"] = int end)

CreateRemoveThread(true, 'self_force_field', function()
	if settings.Self["ForceField"] == 0 then return end
	local me, veh1, veh2 = features.player_ped(), vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
	local pos = features.get_player_coords()
	local distance = settings.Self["ForceField"] * settings.Self["ForceField"]
	for _, v in ipairs(features.get_entities())
	do
		local pos2 = features.get_entity_coords(v)
		if (v ~= me and v ~= veh1 and v ~= veh2) and (pos:sqrlen(pos2) <= distance) then
			features.request_control_once(v)
			if ENTITY.IS_ENTITY_A_PED(v) == 1 then
				PED.SET_PED_TO_RAGDOLL(v, 5000, 5000, 0, true, true, false)
			end
			local force = pos2 - pos
			features.apply_force_to_entity(v, 1, force.x, force.y, force.z, 0, 0, 0, 0, false, true, true, false, true)
		end
	end
end)


---------------------------------------------------------------------------------------------------------------------------------
-- Session
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'session submenu') end
__submenus["Session"] = ui.add_submenu(TRANSLATION["Session"])
__suboptions["Session"] = ui.add_sub_option(TRANSLATION["Session"], __submenus["MainSub"], __submenus["Session"])
---------------------------------------------------------------------------------------------------------------------------------
-- Commands
---------------------------------------------------------------------------------------------------------------------------------

__submenus["Commands"] = ui.add_submenu(TRANSLATION["Commands"])
__suboptions["Commands"] = ui.add_sub_option(TRANSLATION["Commands"], __submenus["Session"], __submenus["Commands"])

do
	local prefixes = {'nf!','/', '\\','!','$','%','&','-','+','?','*',',','.','#','€','@'}
	__options.choose["CommandsPrefix"] = ui.add_choose(TRANSLATION["Prefix"], __submenus["Commands"], true, prefixes, function(int)
		HudSound("YES")
		settings.Commands["CommandsPrefix"] = int
	end)
end

__options.bool["cmd_spawn"] = ui.add_bool_option("spawn/sp <Vehicle>", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
	settings.Commands["cmd_spawn"] = bool
end)
__options.bool["cmd_freeze"] = ui.add_bool_option("freeze/nomove <Player/ID> <on/off>", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
  settings.Commands["cmd_freeze"] = bool
end)
__options.bool["cmd_island"] = ui.add_bool_option("island/vaca <Player/ID>", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
  settings.Commands["cmd_island"] = bool
end)
__options.bool["cmd_kick"] = ui.add_bool_option("kick/leave <Player/ID>", __submenus["Commands"], function(bool)HudSound("TOGGLE_ON")
  settings.Commands["cmd_kick"] = bool
end)
__options.bool["cmd_crash"] = ui.add_bool_option("crash/bye <Player/ID>", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
  settings.Commands["cmd_crash"] = bool
end)
__options.bool["cmd_explode"] = ui.add_bool_option("explode/kill <Player/ID>", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
  settings.Commands["cmd_explode"] = bool
end)
__options.bool["cmd_kickall"] = ui.add_bool_option("kickall/plsleave", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
  settings.Commands["cmd_kickall"] = bool
end)
__options.bool["cmd_crashall"] = ui.add_bool_option("crashall/byea", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
  settings.Commands["cmd_crashall"] = bool
end)
__options.bool["cmd_explodeall"] = ui.add_bool_option("explodeall/killa", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
  settings.Commands["cmd_explodeall"] = bool
end)
__options.bool["cmd_clearwanted"] = ui.add_bool_option("clearwanted/nocop <on/off>", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
  settings.Commands["cmd_clearwanted"] = bool
  if not bool then
  	for i = 0, 31 do
  		CreateRemoveThread(false,"cmd_clearwanted_"..i)
  	end
  end
end)
__options.bool["cmd_offradar"] = ui.add_bool_option("offradar/ghost <on/off>", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
  settings.Commands["cmd_offradar"] = bool
  if not bool then
  	for i = 0, 31 do
  		CreateRemoveThread(false,"cmd_offradar_"..i)
  	end
  end
end)
__options.bool["cmd_vehiclegod"] = ui.add_bool_option("vehiclegod/god <on/off>", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
    settings.Commands["cmd_vehiclegod"] = bool
end)
__options.bool["cmd_upgrade"] = ui.add_bool_option("upgrade/upg", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
    settings.Commands["cmd_upgrade"] = bool
end)
__options.bool["cmd_repair"] = ui.add_bool_option("repair/rep/fix", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
    settings.Commands["cmd_repair"] = bool
end)
__options.bool["cmd_freezeall"] = ui.add_bool_option("freezeall/nomovea <on/off>", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
    settings.Commands["cmd_freezeall"] = bool
end)
__options.bool["cmd_bounty"] = ui.add_bool_option("bounty/hunt <Player/ID> <amount>", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
    settings.Commands["cmd_bounty"] = bool
end)
__options.bool["cmd_bountyall"] = ui.add_bool_option("bountyall/hunta <Player/ID> <amount>", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
    settings.Commands["cmd_bountyall"] = bool
end)
__options.bool["cmd_apartment"] = ui.add_bool_option("apartment/apa <Player/ID> <1-114>", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
    settings.Commands["cmd_apartment"] = bool
end)
__options.bool["cmd_killaliens"] = ui.add_bool_option("killaliens/nogay <on/off>", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
    settings.Commands["cmd_killaliens"] = bool
end)
__options.bool["cmd_kickbarcodes"] = ui.add_bool_option("kickbarcodes/lz <on/off>", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
    settings.Commands["cmd_kickbarcodes"] = bool
end)
__options.bool["cmd_gift"] = ui.add_bool_option("gift", __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
    settings.Commands["cmd_gift"] = bool
end)

ui.add_separator(TRANSLATION['Chat commands settings'], __submenus["Commands"])

__options.bool["Friends Only"] = ui.add_bool_option(TRANSLATION["Friends only"], __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
	settings.Commands["Friends Only"] = bool
end)
__options.bool["Don't Affect Friends"] = ui.add_bool_option(TRANSLATION["Don't affect friends"]..'*', __submenus["Commands"], function(bool) HudSound("TOGGLE_ON")
	settings.Commands["Don't Affect Friends"] = bool
end)

---------------------------------------------------------------------------------------------------------------------------------
-- Vehicle blacklist
---------------------------------------------------------------------------------------------------------------------------------

__submenus["VehicleBlacklist"] = ui.add_submenu(TRANSLATION["Vehicle blacklist"])
__suboptions["VehicleBlacklist"] = ui.add_sub_option(TRANSLATION["Vehicle blacklist"], __submenus["Session"], __submenus["VehicleBlacklist"])

__options.bool["VehicleBlacklist"] = ui.add_bool_option(TRANSLATION["Vehicle blacklist"], __submenus["VehicleBlacklist"], function(bool) HudSound("TOGGLE_ON")
	settings.Session["VehicleBlacklist"] = bool
	CreateRemoveThread(bool, 'session_vehicle_blacklist', function()
		for i = 0, 31 do
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and i ~= PLAYER.PLAYER_ID() and not (settings.General["Exclude Friends"] and features.is_friend(i)) and not features.is_excluded(i) and vehicles.get_player_vehicle(i) ~= 0 and vehicles.get_player_vehicle(i) ~= vehicles.get_player_vehicle() then
				local ped = features.player_ped(i)
				local veh = vehicles.get_player_vehicle(i)
				local hash = tostring(ENTITY.GET_ENTITY_MODEL(veh))
				local tabl = vehicle_blacklist.vehicles[hash]
				if tabl then
					if tabl.set_max_speed then
						entities.request_control(veh, function()
							ENTITY.SET_ENTITY_MAX_SPEED(veh, 0)
							VEHICLE.MODIFY_VEHICLE_TOP_SPEED(veh, 0)
						end)
					end
					if tabl.vehicle_kick then
						online.send_script_event(i, -2126830022, PLAYER.PLAYER_ID(), i)

        				online.send_script_event(i, -714268990, PLAYER.PLAYER_ID(), 0, 0, 0, 0, 1, i, random(0, 2147483647))
						TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
					end
					if tabl.vehicle_explode then
						features.remove_god(i)
						local pos = features.get_entity_coords(ent)
						FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, enum.explosion.ROCKET, 10, false, false, 1.0, false)
						entities.request_control(veh, function()
							vehicles.set_godmode(veh, false)
							NETWORK.NETWORK_EXPLODE_VEHICLE(veh, true, false, i)
						end)
					end
					if tabl.vehicle_launch then
						entities.request_control(veh, function()
							features.set_entity_velocity(veh, 0, 0, 1000)
						end)
					end
					if tabl.vehicle_delete then
						features.delete_entity(veh)
					end
					if tabl.tp_killzone then
						entities.request_control(veh, function()
							ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, -1396.040, -605, 31.313, false, false, false)
						end)
					end
					if tabl.crash then
						features.crash_player(i)
					end
					if tabl.kick then
						features.kick_player(i)
					end
				end
			end
		end
	end)
end)

__submenus["BlacklistedVehicles"] = ui.add_submenu(TRANSLATION["Blacklisted vehicles"])
__suboptions["BlacklistedVehicles"] = ui.add_sub_option(TRANSLATION["Blacklisted vehicles"], __submenus["VehicleBlacklist"], __submenus["BlacklistedVehicles"])

__submenus["AddVehToBl"] = ui.add_submenu(TRANSLATION["Add vehicles"])
__suboptions["AddVehToBl"] = ui.add_sub_option(TRANSLATION["Add vehicles"], __submenus["VehicleBlacklist"], __submenus["AddVehToBl"])

do
	local selected_vehicle = 1
	local class = 0
	local classes = {}
	local curr_class
	for i = 0, 61
	do
		insert(classes, enum.vehicle_class[i])
	end
	ui.add_separator(TRANSLATION["Reactions"], __submenus["AddVehToBl"])

	__options.bool["VehBlVehicleKick"] = ui.add_bool_option(TRANSLATION["Kick from vehicle"], __submenus["AddVehToBl"], function(bool) HudSound("TOGGLE_ON") settings.Session["VehBlVehicleKick"] = bool end)
	__options.bool["VehBlSetMaxSpeed"] = ui.add_bool_option(TRANSLATION["Limit max speed"], __submenus["AddVehToBl"], function(bool) HudSound("TOGGLE_ON") settings.Session["VehBlSetMaxSpeed"] = bool end)
	__options.bool["VehBlVehicleExplode"] = ui.add_bool_option(TRANSLATION["Explode vehicle"], __submenus["AddVehToBl"], function(bool) HudSound("TOGGLE_ON") settings.Session["VehBlVehicleExplode"] = bool end)
	__options.bool["VehBlVehicleDelete"] = ui.add_bool_option(TRANSLATION["Delete vehicle"], __submenus["AddVehToBl"], function(bool) HudSound("TOGGLE_ON") settings.Session["VehBlVehicleDelete"] = bool end)
	__options.bool["VehBlVehicleLaunch"] = ui.add_bool_option(TRANSLATION["Launch vehicle"], __submenus["AddVehToBl"], function(bool) HudSound("TOGGLE_ON") settings.Session["VehBlVehicleLaunch"] = bool end)
	__options.bool["VehBlKillZone"] = ui.add_bool_option(TRANSLATION["Teleport to kill zone"], __submenus["AddVehToBl"], function(bool) HudSound("TOGGLE_ON") settings.Session["VehBlKillZone"] = bool end)
	__options.bool["VehBlKick"] = ui.add_bool_option(TRANSLATION["Kick player"], __submenus["AddVehToBl"], function(bool) HudSound("TOGGLE_ON") settings.Session["VehBlKick"] = bool end)
	__options.bool["VehBlCrash"] = ui.add_bool_option(TRANSLATION["Crash player"], __submenus["AddVehToBl"], function(bool) HudSound("TOGGLE_ON") settings.Session["VehBlCrash"] = bool end)

	ui.add_separator(TRANSLATION["Add"], __submenus["AddVehToBl"])

	-- ui.add_click_option(TRANSLATION["Add and save"], __submenus["AddVehToBl"], function() 
	local function add_and_save()
		local veh_index = vehicles.get_veh_index(selected_vehicle, class)
		vehicle_blacklist.add(veh_index) 
	end

	local sel_class = ui.add_choose(TRANSLATION["Select class"], __submenus["AddVehToBl"], true, classes, function(int) class = int
		HudSound("YES")
		if curr_class then 
			ui.remove(curr_class)
			curr_class = nil
		end
	end)
	ui.set_value(sel_class, class, true)
	CreateRemoveThread(true, 'selected_class_'..thread_count, function()
		if not curr_class then
			curr_class = ui.add_choose(TRANSLATION["Select vehicle"], __submenus["AddVehToBl"], false, settings.Vehicle["VehManufacturer"] and vehicles.class_manufacturer[class] or vehicles.class[class], function(int) HudSound("YES") selected_vehicle = int + 1;add_and_save() end)
		end
	end)
end

---------------------------------------------------------------------------------------------------------------------------------
-- Play sound
---------------------------------------------------------------------------------------------------------------------------------
__submenus["PlaySound"] = ui.add_submenu(TRANSLATION["Play sound"])
__suboptions["PlaySound"] = ui.add_sub_option(TRANSLATION["Play sound"], __submenus["Session"], __submenus["PlaySound"])

ui.add_click_option(TRANSLATION["Stop all sounds"], __submenus["PlaySound"], function()
	StopSounds()
	HudSound("SELECT")
end)
do
	local warning
	__options.bool["EarRape"] = ui.add_bool_option(TRANSLATION['Ear rape'], __submenus["PlaySound"], function(bool)
		HudSound("TOGGLE_ON")
		if not warning then
			ui.set_value(__options.bool["EarRape"], false, true)
			system.notify(TRANSLATION["Warning"], TRANSLATION["Turn your headphones down"], 255, 0, 0, 255, true)
			warning = true
			return
		end
		CreateRemoveThread(bool, 'session_ear_rape', 
		function()
			for i = 1, 30
			do
				PlaySound("07", "DLC_GR_CS2_Sounds")
			end
		end)
		if not bool then
			StopSounds()
		end
	end)
end
ui.add_click_option(TRANSLATION['10s timer'], __submenus["PlaySound"], function()
	HudSound("SELECT")
	PlaySound("Timer_10s", "DLC_TG_Dinner_Sounds")
end)
ui.add_click_option(TRANSLATION['Phone ring'], __submenus["PlaySound"], function()
	HudSound("SELECT")
	PlaySound("Remote_Ring", "Phone_SoundSet_Michael")
end)
ui.add_click_option(TRANSLATION['Beast'], __submenus["PlaySound"], function()
	HudSound("SELECT")
	PlaySound("Beast_Cloak", "APT_BvS_Soundset")
	PlaySound("Beast_Die", "APT_BvS_Soundset")
	PlaySound("Beast_Uncloak", "APT_BvS_Soundset")
end)
ui.add_click_option(TRANSLATION['Beeps'], __submenus["PlaySound"], function()
	HudSound("SELECT")
	PlaySound("Crate_Beeps", "MP_CRATE_DROP_SOUNDS")
end)
ui.add_click_option(TRANSLATION['CCTV camera'], __submenus["PlaySound"], function()
	HudSound("SELECT")
	PlaySound("Microphone", "POLICE_CHOPPER_CAM_SOUNDS")
end)
ui.add_click_option(TRANSLATION['Door ring'], __submenus["PlaySound"], function()
	HudSound("SELECT")
	PlaySound("DOOR_BUZZ", "MP_PLAYER_APARTMENT")
end)
ui.add_click_option(TRANSLATION['Franklin whistle'], __submenus["PlaySound"], function()
	HudSound("SELECT")
	PlaySound("Franklin_Whistle_For_Chop", "SPEECH_RELATED_SOUNDS")
end)
ui.add_click_option(TRANSLATION['Heist hacking snake'], __submenus["PlaySound"], function()
	HudSound("SELECT")
	PlaySound("Trail_Custom", "DLC_HEIST_HACKING_SNAKE_SOUNDS")
	PlaySound("Background", "DLC_HEIST_HACKING_SNAKE_SOUNDS")
end)
ui.add_click_option(TRANSLATION['Heist hacking snake fail'], __submenus["PlaySound"], function()
	HudSound("SELECT")
	PlaySound("Crash", "DLC_HEIST_HACKING_SNAKE_SOUNDS")
end)
ui.add_click_option(TRANSLATION['Keycard'], __submenus["PlaySound"], function()
	HudSound("SELECT")
	PlaySound("Keycard_Fail", "DLC_HEISTS_BIOLAB_FINALE_SOUNDS")
	PlaySound("Keycard_Success", "DLC_HEISTS_BIOLAB_FINALE_SOUNDS")
end)
ui.add_click_option(TRANSLATION['Scanner'], __submenus["PlaySound"], function()
	HudSound("SELECT")
	PlaySound("SCAN", "EPSILONISM_04_SOUNDSET")
end)
ui.add_click_option(TRANSLATION['Wasted'], __submenus["PlaySound"], function()
	HudSound("SELECT")
	PlaySound("Bed", "WastedSounds")
end)
ui.add_click_option(TRANSLATION['Wind'], __submenus["PlaySound"], function()
	HudSound("SELECT")
	PlaySound("Helicopter_Wind", "BASEJUMPS_SOUNDS")
	PlaySound("Helicopter_Wind_Idle", "BASEJUMPS_SOUNDS")
end)

__submenus["ChatMocker"] = ui.add_submenu(TRANSLATION["Chat mOcKEr"])
__suboptions["ChatMocker"] = ui.add_sub_option(TRANSLATION["Chat mOcKEr"], __submenus["Session"], __submenus["ChatMocker"])

__options.bool["ChatMocker"] = ui.add_bool_option(TRANSLATION["Mock chat"], __submenus["ChatMocker"], function(bool) HudSound("TOGGLE_ON")
	settings.Session["ChatMocker"] = bool
end)

__options.bool["MockerSpoof"] = ui.add_bool_option(TRANSLATION["Spoof as them"]..'*', __submenus["ChatMocker"], function(bool) HudSound("TOGGLE_ON")
	settings.Session["MockerSpoof"] = bool
end)

---------------------------------------------------------------------------------------------------------------------------------
-- Teleport
---------------------------------------------------------------------------------------------------------------------------------
__submenus["SessionTeleport"] = ui.add_submenu(TRANSLATION["Teleport"])
__suboptions["SessionTeleport"] = ui.add_sub_option(TRANSLATION["Teleport"], __submenus["Session"], __submenus["SessionTeleport"])

do
	local tp
	ui.add_click_option(TRANSLATION["To me"], __submenus["SessionTeleport"], function()
		if tp then return HudSound("ERROR") end
		local found
		for i = 0, 31 
		do
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and (i ~= PLAYER.PLAYER_ID()) and not (settings.Commands["Don't Affect Friends"] and features.is_friend(i)) and not features.is_excluded(i) then
				found = true
			end
		end
		if found then HudSound("YES") else return HudSound("ERROR") end
		tp = true
		local pos_to = features.get_offset_from_player_coords(vector3.forward(5))
		local my_pos = features.get_player_coords()
		local pid = 0
		local prev = -1
		local ped
		local se
		local wait
		local inveh
		local bail
		CreateRemoveThread(true, 'session_teleport_to_me', function()
			if pid == 32 then NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(false, ped);tp = false;features.teleport(features.player_ped(), my_pos.x, my_pos.y, my_pos.z) return POP_THREAD end
			PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 or (pid == PLAYER.PLAYER_ID()) or (settings.Commands["Don't Affect Friends"] and features.is_friend(pid)) or features.is_excluded(pid) then
				pid = pid + 1
				return
			end
			if pid ~= prev then
				prev = pid
				NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(false, ped)
				local veh = vehicles.get_player_vehicle(pid)
				if veh ~= 0 then
					entities.request_control(veh, function()
						features.teleport(veh, pos_to.x, pos_to.y, pos_to.z)
					end)
					pid = pid + 1
					return
				end
				ped = features.player_ped(pid)
				bail = clock() + 15
				se = nil
				wait = nil
				inveh = nil
			end
			if bail < clock() then
				pid = pid + 1
				return
			end
			NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(true, ped)
			local pos = features.get_player_coords(pid)
			local veh = vehicles.get_player_vehicle(pid)
			if veh ~= 0 then
				inveh = true
				entities.request_control(veh, function()
					features.teleport(veh, pos_to.x, pos_to.y, pos_to.z)
				end)
				if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) == 1 then
					wait = clock() + .2
				end
				if wait and wait < clock() then
					TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
					features.delete_entity(veh)
					NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(false, ped)
					tp = false
					pid = pid + 1
					return
				end
			elseif pos.z ~= -50 and not se then
				se = true
				online.send_script_event(pid, -555356783, PLAYER.PLAYER_ID(), 1, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
			end
			if inveh and veh == 0 then
				inveh = false
				se = false
			end
		end)
	end)

	ui.add_click_option(TRANSLATION["To waypoint"], __submenus["SessionTeleport"], function()
		if tp then return HudSound("ERROR") end
		if HUD.IS_WAYPOINT_ACTIVE() == 0 then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["No waypoint has been set"], 255, 128, 0, 255) HudSound("ERROR") return end
		local found
		for i = 0, 31 
		do
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and (i ~= PLAYER.PLAYER_ID()) and not (settings.Commands["Don't Affect Friends"] and features.is_friend(i)) and not features.is_excluded(i) then
				found = true
			end
		end
		if found then HudSound("YES") else return HudSound("ERROR") end
		tp = true
		local w_pos = features.get_waypoint_coord()
		local pos_to
		local my_pos
		local pid = 0
		local prev = -1
		local ped
		local se
		local wait
		local inveh
		local bail
		local waypoint
		local b_pos = features.get_blip_for_coord(w_pos)
		CreateRemoveThread(true, 'session_teleport_to_waypoint', function(tick)
			if not waypoint then
				if b_pos then
					my_pos = features.get_player_coords()
					pos_to = b_pos
					waypoint = true
					return
				end
				system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Preparing teleport"], 0, 128, 255, 255)
				local Z = (tick+1) * 100
				local success, groundZ = features.get_water_z(vector3(w_pos.x, w_pos.y, 500))
				if not success then
					STREAMING.REQUEST_COLLISION_AT_COORD(w_pos.x, w_pos.y, Z)
					success, groundZ = features.get_ground_z(vector3(w_pos.x, w_pos.y, Z))
					if not success and Z < 900 then return end
					if not success then ticks['session_teleport_to_waypoint'] = nil return end
				end
				my_pos = features.get_player_coords()
				pos_to = vector3(w_pos.x, w_pos.y, groundZ + 1)
				waypoint = true
			end
			if pid == 32 then NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(false, ped);tp = false;features.teleport(features.player_ped(), my_pos.x, my_pos.y, my_pos.z) return POP_THREAD end
			PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 or (pid == PLAYER.PLAYER_ID()) or (settings.Commands["Don't Affect Friends"] and features.is_friend(pid)) or features.is_excluded(pid) then
				pid = pid + 1
				return
			end
			if pid ~= prev then
				prev = pid
				NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(false, ped)
				local veh = vehicles.get_player_vehicle(pid)
				if veh ~= 0 then
					entities.request_control(veh, function()
						features.teleport(veh, pos_to.x, pos_to.y, pos_to.z)
					end)
					pid = pid + 1
					return
				end
				ped = features.player_ped(pid)
				bail = clock() + 15
				se = nil
				wait = nil
				inveh = nil
			end
			if bail < clock() then
				pid = pid + 1
				return
			end
			NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(true, ped)
			local pos = features.get_player_coords(pid)
			local veh = vehicles.get_player_vehicle(pid)
			if veh ~= 0 then
				inveh = true
				entities.request_control(veh, function()
					features.teleport(veh, pos_to.x, pos_to.y, pos_to.z)
				end)
				if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) == 1 then
					wait = clock() + .2
				end
				if wait and wait < clock() then
					TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
					features.delete_entity(veh)
					NETWORK.NETWORK_SET_IN_SPECTATOR_MODE(false, ped)
					tp = false
					pid = pid + 1
					return
				end
			elseif pos.z ~= -50 and not se then
				se = true
				online.send_script_event(pid, -555356783, PLAYER.PLAYER_ID(), 1, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
			end
			if inveh and veh == 0 then
				inveh = false
				se = false
			end
		end)
	end)
end

ui.add_click_option(TRANSLATION["Near me"], __submenus["SessionTeleport"], function() 
	local found
	local my_pos = features.get_player_coords()
	local apartment = features.get_closest_apartment_to_coord(my_pos)
	for i = 0, 31
	do
		if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
			found = true
			online.send_script_event(i, -1390976345, PLAYER.PLAYER_ID(), i, 1, 0, apartment, 1, 1, 1)
		end
	end
	if found then HudSound("YES") else HudSound("ERROR") end
end)

ui.add_click_option(TRANSLATION["Near waypoint"], __submenus["SessionTeleport"], function() 
	if HUD.IS_WAYPOINT_ACTIVE() == 0 then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["No waypoint has been set"], 255, 128, 0, 255) HudSound("ERROR") return end
	local found
	local my_pos = features.get_waypoint_coord()
	local apartment = features.get_closest_apartment_to_coord(my_pos)
	for i = 0, 31
	do
		if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
			found = true
			online.send_script_event(i, -1390976345, PLAYER.PLAYER_ID(), i, 1, 0, apartment, 1, 1, 1)
		end
	end
	if found then HudSound("YES") else HudSound("ERROR") end
end)

do
	local active
	local pid
	local f_pos
	local veh
	local teleported
	local time
	ui.add_click_option(TRANSLATION["Send to cutscene"], __submenus["SessionTeleport"], function() 
		local found
		for i = 0, 31 
		do
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and (i ~= PLAYER.PLAYER_ID()) and not (settings.Commands["Don't Affect Friends"] and features.is_friend(i)) and not features.is_excluded(i) then
				found = true
			end
		end
		if found then HudSound("YES") else return HudSound("ERROR") end
		if not active then
			pid = 0
			f_pos = features.get_player_coords()
			veh = vehicles.get_player_vehicle()
			teleported = false
			time = clock() + 1.5
		end
		active = not active
		CreateRemoveThread(true, 'send_to_cutscene', function()
			if not active then 
				if teleported then
					if veh ~= 0 then
						PED.SET_PED_INTO_VEHICLE(features.player_ped(), veh, -1)
					end
					features.teleport(features.player_ped(), f_pos.x, f_pos.y, f_pos.z)
				end
				active = false 
				return POP_THREAD 
			end
			if pid == 32 then active = false return POP_THREAD end
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == 0 or (pid == PLAYER.PLAYER_ID()) or (settings.Commands["Don't Affect Friends"] and features.is_friend(pid)) or features.is_excluded(pid) or INTERIOR.GET_INTERIOR_FROM_ENTITY(features.player_ped(pid)) ~= 0 then
				if not teleported then time = clock() + 1.5; pid = pid + 1 return end
				if veh ~= 0 then
					PED.SET_PED_INTO_VEHICLE(features.player_ped(), veh, -1)
				end
				features.teleport(features.player_ped(), f_pos.x, f_pos.y, f_pos.z)
				time = clock() + 1.5
				pid = pid + 1
				return
			end
			local my_pos = features.get_player_coords()
			local pl_pos = features.get_player_coords2(pid)
			if my_pos:sqrlen(pl_pos) > 2500 then
				features.teleport(features.player_ped(), pl_pos.x, pl_pos.y + 50, pl_pos.z == -50 and 1000 or pl_pos.z)
				teleported = true
			end
			online.send_script_event(pid, 2131601101, PLAYER.PLAYER_ID())
			if pl_pos.z == -50 then time = clock() + 1.5 return end 
			if time > clock() then return end
			if not teleported then time = clock() + 5; pid = pid + 1 return end
			if veh ~= 0 then
				PED.SET_PED_INTO_VEHICLE(features.player_ped(), veh, -1)
			end
			features.teleport(features.player_ped(), f_pos.x, f_pos.y, f_pos.z)
			time = clock() + 1.5
			pid = pid + 1
			return
		end)
	end)
end

__options.choose["SessionWarehouse"] = ui.add_choose(TRANSLATION["Send to warehouse"], __submenus["SessionTeleport"], false, {TRANSLATION["Random"], "Pacific Bait Storage", "White Widow Garage", "Celltowa Unit", "Convenience Store Lockup", "Foreclosed Garage", "Xero Gas Factory", "Derriere Lingerie Backlot", "Bilgeco Warehouse", "Pier 400 Utility Building", "GEE Warehouse", "LS Marine Building 3", "Railyard Warehouse", "Fridgit Annexe", "Disused Factory Outlet", "Discount Retail Unit", "Logistics Depot", "Darnel Bros Warehouse", "Wholesale Furniture", "Cypress Warehouses", "West Vinewood Backlot", "Old Power Station", "Walker & Sons Warehouse"}, function(int)
	system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["This feature is currently not available"], 255, 0, 0, 255)
	return HudSound("ERROR")
	-- HudSound("YES")
	-- local pid = online.get_selected_player()
	-- local id = int == 0 and random(1, 22) or int
	-- local found
	-- for i = 0, 31 
	-- do
	-- 	if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and not (settings.Commands["Don't Affect Friends"] and features.is_friend(i)) and not features.is_excluded(i) then
	-- 		online.send_script_event(i, 3848692214, PLAYER.PLAYER_ID(), 0, 1, id)
	-- 		found = true
	-- 	end
	-- end
	-- if found then HudSound("YES") else return HudSound("ERROR") end
end)


__options.choose["SessionTpCayo"] = ui.add_choose(TRANSLATION["Send to island"], __submenus["SessionTeleport"], false, {TRANSLATION["Normal"], TRANSLATION["Instant"], TRANSLATION["LSIA"], TRANSLATION["Beach"]}, function(int)
	local found
	for i = 0, 31 
	do
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and not (settings.Commands["Don't Affect Friends"] and features.is_friend(i)) and not features.is_excluded(i) then
			if int == 0 then
				online.send_script_event(i, 1361475530, PLAYER.PLAYER_ID(), 1)
			elseif int == 1 then
				online.send_script_event(i, 1214823473, PLAYER.PLAYER_ID(), i, i, 4, 1)
			elseif int == 2 then
				online.send_script_event(i, 1214823473, PLAYER.PLAYER_ID(), i, i, 3, 0)
			elseif int == 3 then
				online.send_script_event(i, 1214823473, PLAYER.PLAYER_ID(), i, i, 4, 0)
			end
			found = true
		end
	end
	if found then HudSound("YES") else return HudSound("ERROR") end
end)

do
	local types = {TRANSLATION["Severe Weather Patterns"], TRANSLATION["Half-truck Bully"], TRANSLATION["Exit Strategy"], TRANSLATION["Offshore Assets"], TRANSLATION["Cover Blown"], TRANSLATION["Mole Hunt"], TRANSLATION["Data Breach"], TRANSLATION["Work Dispute"]}
	__options.choose["SendAllMission"] = ui.add_choose(TRANSLATION["Send to job"], __submenus["SessionTeleport"], false, types, function(int)
		local found
		for i = 0, 31
		do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				online.send_script_event(i, -283041276, PLAYER.PLAYER_ID(), int)
				found = true
			end
		end
		if found then HudSound("YES") else HudSound("ERROR") end
	end)
end

__submenus["ExcludedPlayers"] = ui.add_submenu(TRANSLATION["Excluded players"])
__suboptions["ExcludedPlayers"] = ui.add_sub_option(TRANSLATION["Excluded players"], __submenus["Session"], __submenus["ExcludedPlayers"])

ui.add_separator(TRANSLATION["Click to delete"], __submenus["ExcludedPlayers"])

CreateRemoveThread(true, 'misc_excluded_players', function()
	if not __options.excludes then __options.excludes = {} end
	for k, v in pairs(__options.excludes)
	do
		if not features.player_excludes[k] then
			ui.remove(v)
			__options.excludes[k] = nil
		end
	end	
	for k, v in pairs(features.player_excludes)
	do
		if not __options.excludes[k] then
			__options.excludes[k] = ui.add_click_option(v.name, __submenus["ExcludedPlayers"], function() HudSound("SELECT") features.player_excludes[k] = nil;SaveExcludes();system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Player removed from excludes"], 0, 255, 0, 225, true) end)
		end
	end
end)

do
	local explosion_types = {}
	__submenus["SessionCustomExplosion"] = ui.add_submenu(TRANSLATION["Custom explosion"])
	__suboptions["SessionCustomExplosion"] = ui.add_sub_option(TRANSLATION["Custom explosion"], __submenus["Session"], __submenus["SessionCustomExplosion"])
	for i = 0, 82
	do
		for k, v in pairs(enum.explosion)
		do
			if v == i then
				insert(explosion_types, k)
				break
			end
		end
	end
	local blamed
	local invisible = false
	local silent = false
	__options.bool["SessionExplodeBlamed"] = ui.add_bool_option(TRANSLATION["Kill as self"], __submenus["SessionCustomExplosion"], function(bool) HudSound("TOGGLE_ON") blamed = bool end)
	__options.bool["SessionExplodeInvisible"] = ui.add_bool_option(TRANSLATION["Invisible"], __submenus["SessionCustomExplosion"], function(bool) HudSound("TOGGLE_ON") invisible = bool end)
	__options.bool["SessionExplodeSilet"] = ui.add_bool_option(TRANSLATION["Silent"], __submenus["SessionCustomExplosion"], function(bool) HudSound("TOGGLE_ON") silent = bool end)
	__options.choose["SessionExplode"] = ui.add_choose(TRANSLATION["Explode"], __submenus["SessionCustomExplosion"], false, explosion_types, function(int)
		local found
		for i = 0, 31
		do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				found = true
				local pos = features.get_player_coords2(i)
				if blamed then
					FIRE.ADD_OWNED_EXPLOSION(features.player_ped(), pos.x, pos.y, pos.z, int, 1, not silent, invisible, 1)
				else
					FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, int, 1, not silent, invisible, 1, false)
				end
			end
		end
		if found then HudSound("YES") else HudSound("ERROR") end
	end)
	__options.bool["SessionExplodeSpam"] = ui.add_bool_option(TRANSLATION["Spam"], __submenus["SessionCustomExplosion"], function(bool) HudSound("TOGGLE_ON")
		CreateRemoveThread(bool, 'session_explode', function(tick)
			if tick%5~=0 then return end
			for i = 0, 31
			do
				if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
					local pos = features.get_player_coords2(i)
					if blamed then
						FIRE.ADD_OWNED_EXPLOSION(features.player_ped(), pos.x, pos.y, pos.z, ui.get_value(__options.choose["SessionExplode"]), 1, not silent, invisible, 1)
					else
						FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, ui.get_value(__options.choose["SessionExplode"]), 1, not silent, invisible, 1, false)
					end
				end
			end
		end)
	end)
end

do
	local types = {TRANSLATION['None'], TRANSLATION["Explode"], TRANSLATION["Freeze"], TRANSLATION["Kick"], TRANSLATION["Crash"]}
	__options.choose["PunishBeggers"] = ui.add_choose(TRANSLATION["Punish beggers"], __submenus["Session"], true, types, function(int) HudSound("YES") settings.Session["PunishBeggers"] = int end)
end

---------------------------------------------------------------------------------------------------------------------------------
-- Buttons
---------------------------------------------------------------------------------------------------------------------------------
ui.add_separator(TRANSLATION['Buttons'], __submenus["Session"])

do
	local blame_delay = 0
	__options.choose["RandomPlayer"] = ui.add_choose(TRANSLATION['Random player'], __submenus["Session"], false, {TRANSLATION["Kill"], TRANSLATION["Blame"], TRANSLATION['Kick'], TRANSLATION['Crash']}, function(int) 
		local target = features.get_random_player(settings.General["Exclude Friends"])
		if target == PLAYER.PLAYER_ID() then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["No players found"], 255, 0, 0, 255) return HudSound("ERROR") end
		HudSound("YES")
		if int == 0 then
			local pos = features.get_player_coords2(target)
			FIRE.ADD_OWNED_EXPLOSION(features.player_ped(), pos.x, pos.y, pos.z, 4, 1, false, false, 1)
		elseif int == 1 then
			if blame_delay > clock() then return end
			features.patch_blame(true)
			local ped = features.player_ped(target)
			for i = 0, 31 do
				if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and i ~= PLAYER.PLAYER_ID() and not (settings.General["Exclude Friends"] and features.is_friend(i)) and not features.is_excluded(i) then
					local pos = features.get_player_coords2(i)
					FIRE.ADD_OWNED_EXPLOSION(ped, pos.x, pos.y, pos.z, 4, 1, true, false, 1.0)
				end
			end
			features.patch_blame(false)
			blame_delay = clock() + .2
		elseif int == 2 then
			features.kick_player(target)
		elseif int == 3 then
			features.crash_player(target)
		end
	end)
end

__options.choose["InfiniteInviteAll"] = ui.add_choose(TRANSLATION['Infinite invite'], __submenus["Session"], false, {TRANSLATION['v1'], TRANSLATION['v2']}, function(int) 
	if InfiniteInvite(int) then
		HudSound("YES")
	else
		HudSound("ERROR") 
	end
end)

__options.choose["TrapSession"] = ui.add_choose(TRANSLATION["Trap"], __submenus["Session"], false, {TRANSLATION["Stunt tube"], TRANSLATION["Invisible tube"], TRANSLATION["Cage"]}, function(int)
	HudSound("YES")
	local type = Cages[int] 
 	CreateRemoveThread(true, 'trap_'..thread_count, function()
 		local result = world_spawner.request(type)
        if result == -1 then return 0 end -- invalid model
        if result == 0 then return end -- not loaded
		for i = 0, 31
		do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				local pos = features.get_player_coords2(i)
		        local heading = features.get_player_heading(i)
		        type[1].position.x = pos.x
		        type[1].position.y = pos.y
		        type[1].position.z = pos.z
		        type[1].position.yaw = heading
		        world_spawner.spawn_map(type, true)
			end
		end
		return POP_THREAD
	end)
end)

__options.click["NoDrivingAll"] = ui.add_click_option(TRANSLATION['Disable ability to drive'], __submenus["Session"], function() 
	local found 
	for i = 0, 31
	do
		if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
			online.send_script_event(i, -1390976345, PLAYER.PLAYER_ID(), 2, 4294967295, 1, 115, 0, 0, 0)
			found = true
		end
	end
	if found then HudSound("YES") else HudSound("ERROR") end
end)
do
	local amount =  10000
	__options.num["BountyAmount"] = ui.add_num_option(TRANSLATION['Amount'], __submenus["Session"], 0, 10000, 1000, function(int) HudSound("YES") amount = int end)
	ui.set_value(__options.num["BountyAmount"], amount, true)
	__options.click["LobbyBounty"] = ui.add_click_option(TRANSLATION['Bounty all'], __submenus["Session"], function() 
		local found
		for i = 0, 31 do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				features.set_bounty(i, amount)
				found = true
			end
		end
		if found then HudSound("YES") else HudSound("ERROR") end
	end)
end

---------------------------------------------------------------------------------------------------------------------------------
-- Toggles
---------------------------------------------------------------------------------------------------------------------------------
ui.add_separator(TRANSLATION['Toggles'], __submenus["Session"])

__options.bool["FreezeAll"] = ui.add_bool_option(TRANSLATION['Freeze all'], __submenus["Session"], function(bool) HudSound("TOGGLE_ON")
	if not bool then
		for i = 0, 31
		do
			playerlist[i]["Freeze"] = false
		end
	end
	CreateRemoveThread(bool, 'session_freeze', 
	function()
		for i = 0, 31
		do
			if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				playerlist[i]["Freeze"] = true
			end
		end
	end)
end)

__options.bool["CamForwardAll"] = ui.add_bool_option(TRANSLATION['Force cam forward'], __submenus["Session"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'session_cam_forward', 
	function(tick)
		for i = 0, 31
		do
			if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				features.remove_god(i)
			end
		end
	end)
end)

__options.bool["AutoCrashFurry"] = ui.add_bool_option(TRANSLATION['Auto crash furry'], __submenus["Session"], function(bool) HudSound("TOGGLE_ON")
	settings.Session["AutoCrashFurry"] = bool
	CreateRemoveThread(bool, 'crash_furry', 
	function()
		for i = 0, 31
		do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				local triggered
				for _, v in ipairs({'fox','furry','wolf','owo','uwu','woof', 'anime'})
				do
					if online.get_name(i):lower():find(v) then
						triggered = true
						break
					end
				end
				if not triggered then
					local outfit = peds.get_outfit(features.player_ped(i))
					for v = 17, 26
					do
						if outfit.components[1][1] == v then
							triggered = true
							break
						end
					end
				end
				if triggered then
					features.crash_player(i)
				end
			end
		end
	end)
end)

do
	local IsTexture = switch()
		:case(8, function()
			return true
		end)
		:case(9, function()
			return true
		end)
		:default(function()
			return false
		end)

	__options.bool["KillAliens"] = ui.add_bool_option(TRANSLATION['Kill aliens'], __submenus["Session"], function(bool) HudSound("TOGGLE_ON")
		settings.Session["KillAliens"] = bool
		CreateRemoveThread(bool, 'kill_aliens', 
		function()
			for i = 0, 31
			do
				if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) and ENTITY.IS_ENTITY_DEAD(features.player_ped(i), false) == 0 then
					local ped = features.player_ped(i)
					local outfit = peds.get_outfit(ped)
					local model = ENTITY.GET_ENTITY_MODEL(ped)
					local triggered
					if model == utils.joaat("mp_f_freemode_01") then
						if (outfit.components[1][1] == 134 and IsTexture(outfit.components[1][2])) and (outfit.components[4][1] == 113 and IsTexture(outfit.components[4][2])) and (outfit.components[6][1] == 87 and IsTexture(outfit.components[6][2])) and (outfit.components[11][1] == 287 and IsTexture(outfit.components[11][2])) then
							triggered = true
						end
					elseif model == utils.joaat("mp_m_freemode_01") then
						if (outfit.components[1][1] == 134 and IsTexture(outfit.components[1][2])) and (outfit.components[4][1] == 106 and IsTexture(outfit.components[4][2])) and (outfit.components[6][1] == 83 and IsTexture(outfit.components[6][2])) and (outfit.components[11][1] == 274 and IsTexture(outfit.components[11][2])) then
							triggered = true
						end
					end
					if triggered then
						local pos = features.get_player_coords2(i)
						if pos.z == -50 then
							TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
						else
							features.remove_god(i)
							if vehicles.get_player_vehicle(i) ~= 0 then
								local veh = vehicles.get_player_vehicle(i)
								entities.request_control(veh, function()
									vehicles.set_godmode(veh, false)
									NETWORK.NETWORK_EXPLODE_VEHICLE(veh, true, false, i)
								end)
							end
							FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, enum.explosion.ROCKET, 10, false, false, 1.0, false)
						end
					end
				end
			end
		end)
	end)
end

__options.bool["KickBarcodes"] = ui.add_bool_option(TRANSLATION['Kick barcodes'], __submenus["Session"], function(bool) HudSound("TOGGLE_ON")
	settings.Session["KickBarcodes"] = bool
	CreateRemoveThread(bool, 'kick_barcodes', 
	function()
		for i = 0, 31
		do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				local name = online.get_name(i)
				local name = name:lower()
				local chars = #gsub(name, "[^il]", "")
				local percent = chars / #name
				if percent > .5 then
			    features.kick_player(i)
				end
			end
		end
	end)
end)

__options.bool["DisableChat"] = ui.add_bool_option(TRANSLATION['Disable Chat'], __submenus["Session"], function(bool) HudSound("TOGGLE_ON")
	settings.Session["DisableChat"] = bool
	local spam_mes = '\n' * 200
	CreateRemoveThread(bool, 'session_disable_chat', 
	function(tick)
		if tick%6~=0 then return end
		online.send_chat(spam_mes, false) -- doesn't work for local
	end)
end)

do
	local player_blips = {}
	for i = 0, 31
	do
		player_blips[i] = 0
	end
	local function AddBlipForPlayer(i)
		local ped = features.player_ped(i)
		features.remove_blip(HUD.GET_BLIP_FROM_ENTITY(ped))
		player_blips[i] = HUD.ADD_BLIP_FOR_ENTITY(ped)
		HUD.SET_BLIP_CATEGORY(player_blips[i], 7)
		HUD.SET_BLIP_SPRITE(player_blips[i], enum.blip_sprite.level)
		HUD.SET_BLIP_NAME_TO_PLAYER_NAME(player_blips[i], i)
		HUD.SET_BLIP_ALPHA(player_blips[i], 255)
		HUD._SET_BLIP_SHRINK(player_blips[i], true)
	end

	__options.bool["AddBlipForOtr"] = ui.add_bool_option(TRANSLATION["Add blip for otr players"], __submenus["Session"], function(bool) HudSound("TOGGLE_ON")
		settings.Session["AddBlipForOtr"] = bool
		if not bool then
			for i = 0, 31
			do
				features.remove_blip(player_blips[i])
				player_blips[i] = 0
			end
		end
		CreateRemoveThread(bool, 'session_blip_otr', function()
			for i = 0, 31
			do
				if i ~= PLAYER.PLAYER_ID() then
					if ENTITY.IS_ENTITY_DEAD(features.player_ped(i), false) == 1 and player_blips[i] ~= 0 then
						features.remove_blip(player_blips[i])
						player_blips[i] = 0
					end	
					if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and player_blips[i] == 0 and ENTITY.IS_ENTITY_DEAD(features.player_ped(i), false) == 0 and features.is_otr(i) then
						AddBlipForPlayer(i)
					elseif player_blips[i] ~= 0 and (NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 0 or not features.is_otr(i)) then
						features.remove_blip(player_blips[i])
						player_blips[i] = 0
					end
				end
			end
		end)
	end)

end

__options.bool["SoundSpam"] = ui.add_bool_option(TRANSLATION['Sound spam'], __submenus["Session"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'session_sound_spam',
	function()
	    for i = 0, 31
	    do
    		if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
        		online.send_script_event(i, 1111927333, PLAYER.PLAYER_ID(), random(1, 6))
       		end
	    end
	end)
end)

__options.bool["OffRadarAll"] = ui.add_bool_option(TRANSLATION['Off radar'], __submenus["Session"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'session_off_radar',
	function(tick)
		if tick%10~=0 then return end
		for i = 0, 31
		do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				online.send_script_event(i, -1973627888, PLAYER.PLAYER_ID(), NETWORK.GET_NETWORK_TIME() - 60, NETWORK.GET_NETWORK_TIME(), 1, 1, globals.get_int((1892703 + (1 + (i * 599) + 510))))
			end
		end
	end)
end)

__options.bool["RemoveWantedAll"] = ui.add_bool_option(TRANSLATION['Remove wanted'], __submenus["Session"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'session_remove_wanted',
	function()
		for i = 0, 31
		do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				online.send_script_event(i, 1449852136, PLAYER.PLAYER_ID(), globals.get_int(1892703 + (1 + (i * 599) + 510)))
			end
		end
	end)
end)

__options.bool["BribeAuthoritiesAll"] = ui.add_bool_option(TRANSLATION['Bribe authorities'], __submenus["Session"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'session_bribe_authorities',
	function(tick)
		if tick%10~=0 then return end
		for i = 0, 31
		do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				online.send_script_event(i, -1041523091, PLAYER.PLAYER_ID(), 0, 0, NETWORK.GET_NETWORK_TIME(), 0, globals.get_int(1892703 + (1 + (i * 599) + 510)))
			end
		end
	end)
end)

__options.bool["BlockPassive"] = ui.add_bool_option(TRANSLATION['Block passive'], __submenus["Session"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'session_block_passive',
	function(tick)
		if tick%10~=0 then return end
		BlockPassive(1)
	end)
	if not bool then BlockPassive(0) end
end)

__options.bool["TransactionError"] = ui.add_bool_option(TRANSLATION['Transaction error'], __submenus["Session"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'session_transaction_error',
	function(tick)
		if tick%2~=0 then return end
		for i = 0, 31
		do
			if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				online.send_script_event(i, -768108950, PLAYER.PLAYER_ID(), 50000, 0, 1, globals.get_int(1892703 + (1 + (i * 599) + 510)), globals.get_int(1920255 + 9), globals.get_int(1920255 + 10), 1)
			end
		end
	end)
end)

---------------------------------------------------------------------------------------------------------------------------------
-- Vehicle
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'vehicle submenu') end
__submenus["Vehicle"] = ui.add_submenu(TRANSLATION["Vehicle"])
__suboptions["Vehicle"] = ui.add_sub_option(TRANSLATION["Vehicle"], __submenus["MainSub"], __submenus["Vehicle"])

__submenus["SpawnVeh"] = ui.add_submenu(TRANSLATION["Spawn vehicle"])
__suboptions["SpawnVeh"] = ui.add_sub_option(TRANSLATION["Spawn vehicle"], __submenus["Vehicle"], __submenus["SpawnVeh"])

__submenus["ChangeSound"] = ui.add_submenu(TRANSLATION["Change sound"])
__suboptions["ChangeSound"] = ui.add_sub_option(TRANSLATION["Change sound"], __submenus["Vehicle"], __submenus["ChangeSound"])

__submenus["RealFuel"] = ui.add_submenu(TRANSLATION["Real fuel"])
__suboptions["RealFuel"] = ui.add_sub_option(TRANSLATION["Real fuel"], __submenus["Vehicle"], __submenus["RealFuel"])

__submenus["SpawnSettings"] = ui.add_submenu(TRANSLATION["Spawn settings"])
__suboptions["SpawnSettings"] = ui.add_sub_option(TRANSLATION["Spawn settings"], __submenus["SpawnVeh"], __submenus["SpawnSettings"])

__submenus["SavedVehicles"] = ui.add_submenu(TRANSLATION["Saved vehicles"])
__suboptions["SavedVehicles"] = ui.add_sub_option(TRANSLATION["Saved vehicles"], __submenus["SpawnVeh"], __submenus["SavedVehicles"])

do
	local saved = {}
	local options = {}
	local vehicle_name
	local delete_mode
	local function RefreshSavedVehicles()
		saved = {}
		if not filesystem.isdir(paths['SavedVehicles']) then
			filesystem.make_dir(paths['SavedVehicles'])
		end
		local files = filesystem.scandir(paths['SavedVehicles'])
		for _, v in ipairs(files)
		do
			if v:endswith('.json') then
				local name = v:gsub('.json$', '')
				saved[name] = true
				if not options[name] then
					options[name] = ui.add_click_option(name, __submenus["SavedVehicles"], function()
						HudSound("SELECT")
						CreateRemoveThread(true, 'spawn_vehicle_'..thread_count, function()
							if delete_mode then
								ui.remove(options[name])
								options[name] = nil
								os.remove(paths['SavedVehicles']:ensureend('\\')..name..'.json')
							else
								local file = paths['SavedVehicles']:ensureend('\\')..v
								if not filesystem.exists(file) then HudSound("ERROR");system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["File doesn't exist"], 255, 0, 0, 255) return POP_THREAD end 
								local tabl = json:decode(filesystem.read_all(file))
								world_spawner.create_vehicle(tabl, true)
							end
							return POP_THREAD
						end)
					end)
				end
			end
		end

		for k, v in pairs(options)
		do
			if not saved[k] then
				ui.remove(options[k])
				options[k] = nil
			end
		end
	end

	__options.string["SaveVehicleName"] = ui.add_input_string(TRANSLATION["Name"], __submenus["SavedVehicles"], function(text) vehicle_name = text end)
	ui.add_click_option(TRANSLATION["Save current vehicle"], __submenus["SavedVehicles"], function()
		local veh = vehicles.get_player_vehicle()
		if veh == 0 then return HudSound("ERROR") end
		HudSound("SELECT")
		cache:delete("Save Veh")
		CreateRemoveThread(true, 'save_vehicle_'..thread_count, function(tick)
			if not world_saver.save_vehicle(veh, tick) then return end
			local vehicle = cache:get("Save Veh")
			local name = (vehicle_name and vehicle_name ~= '') and vehicle_name or vehicles.get_label_name(ENTITY.GET_ENTITY_MODEL(veh))
			ui.set_value(__options.string["SaveVehicleName"], '', true)
			vehicle_name = nil
			local repeats = 0
			local found
			for k in pairs(saved)
			do
				if k == name then
					found = true
				end
				local n = k:match("[^%s]*$"):gsub('%D', '')
				if k:gsub(' %('..n..'%)', '') == name and k:sub(-len(' ('..n..')'), -1) == ' ('..n..')' then
					repeats = tonumber(n) and tonumber(n) + 1 or repeats
				end
			end
			if found then
				local repeats = repeats > 0 and repeats or 1
				name = format("%s (%d)", name, repeats)
			end
			-- vehicle.version = '1.0'
			filesystem.write(json:encode_pretty(vehicle), paths['SavedVehicles']:ensureend('\\')..name..[[.json]])
			system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Vehicle saved, you can rename the file later"], 0, 128, 255, 255, true)
			RefreshSavedVehicles()
			return POP_THREAD
		end)
	end)
	ui.add_click_option(TRANSLATION['Open folder'], __submenus["SavedVehicles"], function() HudSound("SELECT") if not filesystem.isdir(paths['SavedVehicles']) then filesystem.make_dir(paths['SavedVehicles']) end filesystem.open(paths['SavedVehicles']) end)
	__options.bool["SavedVehiclesDelMod"] = ui.add_bool_option(TRANSLATION['Delete mode'], __submenus["SavedVehicles"], function(bool) HudSound("TOGGLE_ON") delete_mode = bool end)
	__options.bool["AddToDb"] = ui.add_bool_option(TRANSLATION["Add to database"], __submenus["SavedVehicles"], function(bool) HudSound("TOGGLE_ON") settings.Vehicle["AddToDb"] = bool end)
	ui.add_separator(TRANSLATION["Saved vehicles"], __submenus["SavedVehicles"])

	local sub_open
	CreateRemoveThread(true, 'saved_vehicles', function()
		if ui.is_sub_open(__submenus["SavedVehicles"]) and not sub_open then
			RefreshSavedVehicles()
			if delete_mode then
				system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Delete mode is enabled!"], 255, 0, 0, 255, true)
			end
			sub_open = true
		elseif not ui.is_sub_open(__submenus["SavedVehicles"]) and sub_open then
			sub_open = false
		end
	end)
end

__options.bool["RealFuelUsage"] = ui.add_bool_option(TRANSLATION["Realistic fuel usage"], __submenus["RealFuel"], function(bool) HudSound("TOGGLE_ON")
	settings.Vehicle["RealFuelUsage"] = bool
	CreateRemoveThread(bool, 'vehicle_fuel_usage', function()
		local veh = vehicles.get_player_vehicle()
		if veh == 0 then return end
		fuelConsumption.DoTick()
		local fuel = fuelConsumption.GetFuel(veh)
		if not fuel then return end
		local pos = features.get_entity_coords(veh)
		for _, v in ipairs(fuelConsumption.gas_pumps)
		do
			if pos:sqrlen(v) <= 25 then
				PAD.DISABLE_CONTROL_ACTION(0, enum.input.FRONTEND_ACCEPT, true)
				if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.FRONTEND_ACCEPT) == 1 then
					local add = fuelConsumption.tankVolume[veh].fill + (fuelConsumption.IsElectric(veh) and .1 or 1)
					fuelConsumption.tankVolume[veh].fill = add < fuelConsumption.tankVolume[veh].capacity and add or fuelConsumption.tankVolume[veh].capacity
				end
				if Instructional:New() then
					Instructional.AddButton(enum.input.FRONTEND_ACCEPT, TRANSLATION["Refuel"])
					Instructional:BackgroundColor(0, 0, 0, 80)
					Instructional:Draw()
				end
				break
			end
		end
		fuelConsumption.Draw(fuel)
	end)
end)

__options.bool["ShowGasStations"] = ui.add_bool_option(TRANSLATION["Show gas stations"], __submenus["RealFuel"], function(bool) HudSound("TOGGLE_ON")
	settings.Vehicle["ShowGasStations"] = bool
	fuelConsumption.AddBlips(bool)
end)
ui.add_click_option(TRANSLATION["Navigate to closest gas station"], __submenus["RealFuel"], function()
	HudSound("SELECT")
	local pos = fuelConsumption.GetClosestGasStation(features.get_player_coords())
	HUD.SET_NEW_WAYPOINT(pos.x, pos.y)
end)

__options.num["FuelOffsetX"] = ui.add_num_option(TRANSLATION["Offset x"], __submenus["RealFuel"], -10000, 10000, 1, function(int) HudSound("YES")
	settings.Vehicle["FuelOffsetX"] = int
end)

__options.num["FuelOffsetY"] = ui.add_num_option(TRANSLATION["Offset y"], __submenus["RealFuel"], -10000, 10000, 1, function(int) HudSound("YES")
	settings.Vehicle["FuelOffsetY"] = int
end)

do
	local selected_vehicle = 1
	local class = 0
	local classes = {}
	local curr_class
	local display_preview
	for i = 0, 61
	do
		insert(classes, enum.vehicle_class[i])
	end

	CreateRemoveThread(true, 'request_ptfx', function()
		if STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_rcbarry2") == 0 then 
			STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2")
			return
		end
		return POP_THREAD
	end)

	local function spawn(hash)
		CreateRemoveThread(true, "spawn_vehicle_"..thread_count, function()
			if features.request_model(hash) == 0 then return end
			local prev_veh = vehicles.get_player_vehicle()
			local velocity
			if settings.Vehicle["SpawnerKeepSpeed"] and settings.Vehicle["SpawnerInside"] and prev_veh ~= 0 then
				velocity = ENTITY.GET_ENTITY_VELOCITY(prev_veh)
			end
			if settings.Vehicle["SpawnerDeleteOld"] and prev_veh ~= 0 then
				TASK.CLEAR_PED_TASKS_IMMEDIATELY(features.player_ped())
				features.delete_entity(prev_veh)
			end
			local pos = features.get_offset_from_player_coords(vector3(0, 5, 0))
			local veh = vehicles.spawn_vehicle(hash, pos, features.get_player_heading())
			if settings.Vehicle["SpawnWithEffect"] then
				GRAPHICS.USE_PARTICLE_FX_ASSET("scr_rcbarry2")
				GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY("scr_clown_appears", veh, 0, 0, 0, 0, 0, 0, 1.5, false, false, false, 0, 0, 0, 1)
				-- local alpha_table = {255, 204, 153, 102, 51, 0}
				-- local curr = 1
				local dir = true
				CreateRemoveThread(true, 'spawn_anim_'..thread_count, function(tick)
					if tick > 200 and ENTITY.GET_ENTITY_ALPHA(veh) ~= 255 then
						entities.request_control(veh, function()
							ENTITY.RESET_ENTITY_ALPHA(veh)
						end)
						return POP_THREAD
					elseif ENTITY.GET_ENTITY_ALPHA(veh) == 255 then
						entities.request_control(veh, function()
							ENTITY.SET_ENTITY_ALPHA(veh, 0, false)
						end)
					elseif ENTITY.GET_ENTITY_ALPHA(veh) == 0 then
						entities.request_control(veh, function()
							ENTITY.RESET_ENTITY_ALPHA(veh)
						end)
					end
				end)
			end
			entities.request_control(veh, function()
				vehicles.set_godmode(veh, settings.Vehicle["SpawnerGod"])
				vehicles.repair(veh)
				VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(veh, settings.Vehicle["SpawnerLicenceText"])
				if settings.Vehicle["SpawnerPerformancePreset"] == 1 then
					vehicles.upgrade(veh)
				elseif settings.Vehicle["SpawnerPerformancePreset"] == 2 then
					vehicles.upgrade(veh)
					VEHICLE.SET_VEHICLE_MOD(veh, 48, -1, false)
				elseif settings.Vehicle["SpawnerPerformancePreset"] == 3 then
					vehicles.performance(veh)
				elseif settings.Vehicle["SpawnerPerformancePreset"] == 4 then
					vehicles.performance(veh)
					local num = VEHICLE.GET_NUM_VEHICLE_MODS(veh, 0) - 1
					VEHICLE.SET_VEHICLE_MOD(veh, 0, num, false)
				end
				local class = VEHICLE.GET_VEHICLE_CLASS(veh)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, settings.Vehicle["SpawnerLicence"])
				if settings.Vehicle["SpawnerInAir"] and features.compare(class, 15, 16) then
					ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, pos.x, pos.y, pos.z + 50, false, false, false)
					VEHICLE.CONTROL_LANDING_GEAR(veh, 3)
					VEHICLE.SET_HELI_BLADES_FULL_SPEED(veh)
					if class == 16 then
						VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 50)
					end
				end
				if velocity and class ~= 16 then
					features.set_entity_velocity(veh, velocity.x, velocity.y, velocity.z)
				end
				if settings.Vehicle["SpawnerInside"] then
					PED.SET_PED_INTO_VEHICLE(features.player_ped(), veh, -1)
				end
				STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
			end)
			return POP_THREAD
		end)
	end

	__options.bool["SpawnerGod"] = ui.add_bool_option(TRANSLATION["Spawn in godmode"], __submenus["SpawnSettings"], function(bool) HudSound("TOGGLE_ON") settings.Vehicle["SpawnerGod"] = bool end)
	__options.choose["SpawnerPerformancePreset"] = ui.add_choose(TRANSLATION["Upgrade preset"], __submenus["SpawnSettings"], true, {TRANSLATION["Stock"], TRANSLATION["Max upgrade"], TRANSLATION["Max without livery"], TRANSLATION["Performance"], TRANSLATION["Performance with spoiler"]}, function(int) HudSound("YES") settings.Vehicle["SpawnerPerformancePreset"] = int end)
	__options.choose["SpawnerLicence"] = ui.add_choose(TRANSLATION["Licence plate"], __submenus["SpawnSettings"], true, enum.plate_index, function(int) HudSound("YES") settings.Vehicle["SpawnerLicence"] = int end)
	__options.string["SpawnerLicenceText"] = ui.add_input_string(TRANSLATION["Plate text"], __submenus["SpawnSettings"], function(text) settings.Vehicle["SpawnerLicenceText"] = text:truncate(8):upper() ui.set_value(__options.string["SpawnerLicenceText"], settings.Vehicle["SpawnerLicenceText"], true) end)
	__options.bool["SpawnerKeepSpeed"] = ui.add_bool_option(TRANSLATION["Keep speed"], __submenus["SpawnSettings"], function(bool) HudSound("TOGGLE_ON") settings.Vehicle["SpawnerKeepSpeed"] = bool end)
	__options.bool["SpawnerInside"] = ui.add_bool_option(TRANSLATION["Spawn inside"], __submenus["SpawnSettings"], function(bool) HudSound("TOGGLE_ON") settings.Vehicle["SpawnerInside"] = bool end)
	__options.bool["SpawnerInAir"] = ui.add_bool_option(TRANSLATION["Spawn in air"], __submenus["SpawnSettings"], function(bool) HudSound("TOGGLE_ON") settings.Vehicle["SpawnerInAir"] = bool end)
	__options.bool["SpawnerDeleteOld"] = ui.add_bool_option(TRANSLATION["Delete old vehicle"], __submenus["SpawnSettings"], function(bool) HudSound("TOGGLE_ON") settings.Vehicle["SpawnerDeleteOld"] = bool end)
	__options.bool["SpawnWithEffect"] = ui.add_bool_option(TRANSLATION["Spawn with effect"], __submenus["SpawnSettings"], function(bool) HudSound("TOGGLE_ON") settings.Vehicle["SpawnWithEffect"] = bool end)

	ui.add_separator(TRANSLATION["Spawn"], __submenus["SpawnVeh"])

	__options.bool["VehPreview"] = ui.add_bool_option(TRANSLATION["Display preview"], __submenus["SpawnVeh"], function(bool) HudSound("TOGGLE_ON")
		settings.Vehicle["VehPreview"] = bool
	end)

	local value
	__options.bool["VehManufacturer"] = ui.add_bool_option(TRANSLATION["Show manufacturer"], __submenus["SpawnVeh"], function(bool) HudSound("TOGGLE_ON")
		settings.Vehicle["VehManufacturer"] = bool 
		if curr_class then
			value = ui.get_value(curr_class)
			ui.remove(curr_class)
			curr_class = nil
		end
	end)

	ui.add_input_string(TRANSLATION["Input model"], __submenus["SpawnVeh"], function(text)
		if not text or text == '' then return HudSound("ERROR") end
		local text = text:lower()
		local hash = utils.joaat(text)
		if STREAMING.IS_MODEL_VALID(hash) == 1 and STREAMING.IS_MODEL_A_VEHICLE(hash) == 1 then
			spawn(hash)
		else
			for _, v in ipairs(vehicles.data)
			do
				if v.Name:find(text) or (v.DisplayName and v.DisplayName:lower():find(text)) or vehicles.get_label_name(v.Hash):lower():find(text) then
					hash = v.Hash
					break
				end
			end
			if STREAMING.IS_MODEL_VALID(hash) == 1 and STREAMING.IS_MODEL_A_VEHICLE(hash) == 1 then
				spawn(hash)
			else
				system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Sorry I couldn't find any matching model"], 225, 0, 0, 225, true)
				HudSound("ERROR")
			end
		end
	end)

	local sel_class = ui.add_choose(TRANSLATION["Select class"], __submenus["SpawnVeh"], true, classes, function(int) class = int
		HudSound("YES")
		if curr_class then 
			ui.remove(curr_class)
			curr_class = nil
		end
	end)
	ui.set_value(sel_class, class, true)
	CreateRemoveThread(true, 'selected_class_'..thread_count, function()
		if not curr_class then
			curr_class = ui.add_choose(TRANSLATION["Select vehicle"], __submenus["SpawnVeh"], false, settings.Vehicle["VehManufacturer"] and vehicles.class_manufacturer[class] or vehicles.class[class], function(int) HudSound("YES") selected_vehicle = int + 1;spawn(vehicles.models[vehicles.get_veh_index(ui.get_value(curr_class) + 1, class)][2]) end)
			if value then
				ui.set_value(curr_class, value, true)
				value = nil
			end
		end
	end)
	local veh_preview
	local hash
	CreateRemoveThread(true, 'display_vehicle_preview', function()
		if not settings.Vehicle["VehPreview"] or not ui.is_sub_open(__submenus["SpawnVeh"]) then 
			if created_preview then
				features.delete_entity(created_preview)
				created_preview = nil
				veh_preview = nil
			end
			return 
		end
		if not curr_class then return end
		local selected = ui.get_value(curr_class) + 1
		if veh_preview ~= vehicles.get_veh_index(selected, class) then
			if hash then
				STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
			end
			veh_preview = vehicles.get_veh_index(selected, class)
			if created_preview then
				features.delete_entity(created_preview)
				created_preview = nil
			end
		end
		if not created_preview then
			hash = vehicles.models[veh_preview][2]
			if features.request_model(hash) == 0 then return end
			local pos = features.get_offset_coords_from_entity_rot(features.player_ped(), 5, 0, true) + vector3.up(1.5)
			created_preview = vehicles.spawn_vehicle(hash, pos)
			NETWORK._NETWORK_SET_ENTITY_INVISIBLE_TO_NETWORK(created_preview, true)
			NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(created_preview), false)
			ENTITY.SET_ENTITY_COLLISION(created_preview, false, false)
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(created_preview, pos.x, pos.y, pos.z, false, false, false)
			ENTITY.SET_ENTITY_ALPHA(created_preview, 160, false)
			VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(created_preview, "Nightfal")
			if settings.Vehicle["SpawnerPerformancePreset"] == 1 then
				vehicles.upgrade(created_preview)
			elseif settings.Vehicle["SpawnerPerformancePreset"] == 2 then
				vehicles.upgrade(created_preview)
				VEHICLE.SET_VEHICLE_MOD(created_preview, 48, -1, false)
			elseif settings.Vehicle["SpawnerPerformancePreset"] == 3 then
				vehicles.performance(created_preview)
			elseif settings.Vehicle["SpawnerPerformancePreset"] == 4 then
				vehicles.performance(created_preview)
				local num = VEHICLE.GET_NUM_VEHICLE_MODS(created_preview, 0) - 1
				VEHICLE.SET_VEHICLE_MOD(created_preview, 0, num, false)
			end
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
		else
			if ENTITY.DOES_ENTITY_EXIST(created_preview) == 0 then created_preview = nil return end
			local max = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(hash) - 2
		    for i = -1, max do
		    	local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(created_preview, i, true)
		    	if ped ~= 0 then
		    		TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
		    	end
		    end
			features.request_control_once(created_preview)
			vehicles.set_godmode(created_preview, true)
			local model_dim_max, model_dim_max = features.get_model_dimentions(ENTITY.GET_ENTITY_MODEL(created_preview))
			local pos = features.get_offset_coords_from_entity_rot(features.player_ped(), 3 + model_dim_max.y, 0, true) + vector3.up(model_dim_max.z)
			features.draw_box_on_entity2(created_preview, pos)
			ENTITY.SET_ENTITY_COLLISION(created_preview, false, false)
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(created_preview, pos.x, pos.y, pos.z, false, false, false)
			ENTITY.SET_ENTITY_ALPHA(created_preview, 160, false)
			local rot = features.get_entity_rot(created_preview)
			ENTITY.SET_ENTITY_ROTATION(created_preview, 0, 0, rot.z - 1, 2, true)
		end
	end)
end

local veh_customs = {}
veh_customs.sub_mods = ui.add_submenu(TRANSLATION["Vehicle customs"])
veh_customs.subopt_mods = ui.add_sub_option(TRANSLATION["Vehicle customs"], __submenus["Vehicle"], veh_customs.sub_mods)
ui.hide(veh_customs.subopt_mods, true)

do
	local selected_vehicle = 1
	local class = 0
	local classes = {}
	local curr_class
	for i = 0, 61
	do
		insert(classes, enum.vehicle_class[i])
	end
	local function change_sound()
		local veh = vehicles.get_player_vehicle()
		if veh == 0 then return end
		AUDIO._FORCE_VEHICLE_ENGINE_AUDIO(veh, vehicles.models[vehicles.get_veh_index(ui.get_value(curr_class) + 1, class)][1])
	end
	local sel_class = ui.add_choose(TRANSLATION["Select class"], __submenus["ChangeSound"], true, classes, function(int) class = int
		HudSound("YES")
		if curr_class then 
			ui.remove(curr_class)
			curr_class = nil
		end
	end)
	ui.set_value(sel_class, class, true)
	CreateRemoveThread(true, 'selected_class_'..thread_count, function()
		if not curr_class then
			curr_class = ui.add_choose(TRANSLATION["Select vehicle"], __submenus["ChangeSound"], false, settings.Vehicle["VehManufacturer"] and vehicles.class_manufacturer[class] or vehicles.class[class], function(int) HudSound("YES") selected_vehicle = int + 1;change_sound() end)
		end
	end)
end

local function LastVehicleAction(last_veh, int)
	if int == 0 then
		CreateRemoveThread(true, 'seat_change_'..thread_count, function(tick)
			if tick == 100 then return POP_THREAD end
			features.request_control_once(last_veh)
			local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(last_veh, -1, true)
			if ped and ped ~= features.player_ped() then
				TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
			end
			PED.SET_PED_INTO_VEHICLE(features.player_ped(), last_veh, -1)
			if VEHICLE.GET_PED_IN_VEHICLE_SEAT(last_veh, -1, true) ~= features.player_ped() then return end
			return POP_THREAD
		end)
	elseif int == 1 then
		local dim_max = select(2, features.get_model_dimentions(ENTITY.GET_ENTITY_MODEL(last_veh))).x
		local pos = features.get_offset_from_entity_in_world_coords(last_veh, vector3.left(dim_max + 1))
		features.teleport_entity(features.player_ped(), pos.x, pos.y, pos.z)
		ENTITY.SET_ENTITY_HEADING(features.player_ped(), ENTITY.GET_ENTITY_HEADING(last_veh) - 90)
	elseif int == 2 then
		entities.request_control(last_veh, function()
			local dim_max = select(2, features.get_model_dimentions(ENTITY.GET_ENTITY_MODEL(last_veh))).y
			local pos = features.get_offset_from_player_coords(vector3.forward(dim_max + 3), player)
			features.teleport(last_veh, pos.x, pos.y, pos.z, features.get_player_heading())
			VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(last_veh, 0)
		end)
	elseif int == 3 then
		entities.request_control(last_veh, function()
			local dim_max = select(2, features.get_model_dimentions(ENTITY.GET_ENTITY_MODEL(last_veh))).y
			local pos = features.get_offset_from_player_coords(vector3.forward(dim_max + 3), player)
			features.teleport(last_veh, pos.x, pos.y, pos.z, features.get_player_heading())
			VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(last_veh, 0)
			CreateRemoveThread(true, 'seat_change_'..thread_count, function(tick)
				if tick == 100 then return POP_THREAD end
				features.request_control_once(last_veh)
				local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(last_veh, -1, true)
				if ped and ped ~= features.player_ped() then
					TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
				end
				PED.SET_PED_INTO_VEHICLE(features.player_ped(), last_veh, -1)
				if VEHICLE.GET_PED_IN_VEHICLE_SEAT(last_veh, -1, true) ~= features.player_ped() then return end
				return POP_THREAD
			end)
		end)
	end
end

__options.choose["PersonalVehicle"] = ui.add_choose(TRANSLATION["Personal vehicle"], __submenus["Vehicle"], false, {TRANSLATION["Drive"], TRANSLATION["Teleport me to..."], TRANSLATION["Teleport to me"], TRANSLATION["Teleport to me and drive"]}, function(int)
	local last_veh = vehicles.get_personal_vehicle()
	if last_veh ~= 0 and last_veh == vehicles.get_player_vehicle() then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Aren't you already in?"], 255, 0, 0, 255) return HudSound("ERROR") end
	if last_veh == 0 or HUD.GET_BLIP_FROM_ENTITY(last_veh) == 0 then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Personal vehicle not found"], 255, 0, 0, 255) return HudSound("ERROR") end
	HudSound("YES")
	LastVehicleAction(last_veh, int)
end)

__options.choose["LasetVehicle"] = ui.add_choose(TRANSLATION["Last vehicle"], __submenus["Vehicle"], false, {TRANSLATION["Drive"], TRANSLATION["Teleport me to..."], TRANSLATION["Teleport to me"], TRANSLATION["Teleport to me and drive"]}, function(int)
	local last_veh = vehicles.get_player_last_vehicle()
	if last_veh == 0 then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Last vehicle not found"], 255, 0, 0, 255) return HudSound("ERROR") end
	if last_veh == vehicles.get_player_vehicle() then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Aren't you already in?"], 255, 0, 0, 255) return HudSound("ERROR") end
	HudSound("YES")
	LastVehicleAction(last_veh, int)
end)

ui.add_separator(TRANSLATION["Other"], __submenus["Vehicle"])

__submenus["VehicleWeapons"] = ui.add_submenu(TRANSLATION["Vehicle weapons"])
__suboptions["VehicleWeapons"] = ui.add_sub_option(TRANSLATION["Vehicle weapons"], __submenus["Vehicle"],__submenus["VehicleWeapons"])

__submenus["VehicleDoors"] = ui.add_submenu(HUD._GET_LABEL_TEXT("PIM_TDPV"))
__suboptions["VehicleDoors"] = ui.add_sub_option(HUD._GET_LABEL_TEXT("PIM_TDPV"), __submenus["Vehicle"],__submenus["VehicleDoors"])

__submenus["HornBoost"] = ui.add_submenu(TRANSLATION["Horn boost"])
__suboptions["HornBoost"] = ui.add_sub_option(TRANSLATION["Horn boost"], __submenus["Vehicle"], __submenus["HornBoost"])

__submenus["EnterExitVeh"] = ui.add_submenu(TRANSLATION["Enter/exit"])
__suboptions["EnterExitVeh"] = ui.add_sub_option(TRANSLATION["Enter/exit"], __submenus["Vehicle"], __submenus["EnterExitVeh"])

__submenus["VehMultipliers"] = ui.add_submenu(TRANSLATION["Multipliers"])
__suboptions["VehMultipliers"] = ui.add_sub_option(TRANSLATION["Multipliers"], __submenus["Vehicle"], __submenus["VehMultipliers"])

__options.bool["BoostEffect"] = ui.add_bool_option(TRANSLATION["With effect"], __submenus["HornBoost"], function(bool) HudSound("TOGGLE_ON") settings.Vehicle["BoostEffect"] = bool end)

do
	local types = {TRANSLATION['Constant'] ,TRANSLATION['Non constant']}
	__options.choose["AccelerationType"] = ui.add_choose(TRANSLATION["Acceleration type"], __submenus["HornBoost"], true, types, function(int) HudSound("YES") settings.Vehicle["AccelerationType"] = int end)
	__options.num["HornBoostPower"] = ui.add_num_option(TRANSLATION["Horn boost power"], __submenus["HornBoost"], 1, 20, 1, function(int) HudSound("YES") settings.Vehicle["HornBoostPower"] = int end)
end

__options.bool["HornBoost"] = ui.add_bool_option(TRANSLATION["Horn boost"], __submenus["HornBoost"], function(bool) HudSound("TOGGLE_ON")
	settings.Vehicle['HornBoost'] = bool
	CreateRemoveThread(bool, 'vehicle_horn_boost',
	function()
		if vehicles.get_player_vehicle() == 0 or PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_HORN) == 0 then return end
		local veh = vehicles.get_player_vehicle()
		features.request_control_once(veh)
		ENTITY.SET_ENTITY_MAX_SPEED(veh, 10000000)
		local speed = ENTITY.GET_ENTITY_SPEED(veh)
		if settings.Vehicle["BoostEffect"] then AUDIO.SET_VEHICLE_BOOST_ACTIVE(veh, true) GRAPHICS.ANIMPOSTFX_PLAY("DrivingFocusOut", 0, false) end
		if settings.Vehicle["AccelerationType"] == 0 then
			speed = speed + settings.Vehicle["HornBoostPower"]
		elseif settings.Vehicle["AccelerationType"] == 1 then
			if speed < 1 then speed = 1 end
			speed = speed + speed * settings.Vehicle["HornBoostPower"] / 100
		end
		VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, speed)
		if settings.Vehicle["BoostEffect"] then AUDIO.SET_VEHICLE_BOOST_ACTIVE(veh, false) GRAPHICS.ANIMPOSTFX_STOP("DrivingFocusOut") end
	end)
	
end)

__options.bool["InstaEnter/ExitVehicle"] = ui.add_bool_option(TRANSLATION["Instant enter/exit vehicle"], __submenus["EnterExitVeh"], function(bool) HudSound("TOGGLE_ON")
	settings.Vehicle['InstaEnter/ExitVehicle'] = bool
	CreateRemoveThread(bool, 'vehicle_insta_exit',
	function()
		PAD.DISABLE_CONTROL_ACTION(0, enum.input.VEH_EXIT, true)
		if ENTITY.IS_ENTITY_DEAD(features.player_ped(), false) == 1 then return end
		if vehicles.get_player_vehicle() == 0 and PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, enum.input.VEH_EXIT) == 1 then
			local veh, dist = vehicles.get_closest_vehicle(features.get_player_coords())
			if features.compare(veh, created_preview, created_preview2) then return end
			local _veh = features.get_parent_attachment(veh)
			if ENTITY.IS_ENTITY_A_VEHICLE(_veh) then
				veh = _veh
			end
			local seat = vehicles.get_first_free_seat(veh)
			if settings.Vehicle["InstaEnter/ExitVehicleFroceDriver"] then seat = -1 end
			if not seat or dist > 400 then return end
			CreateRemoveThread(true, 'seat_change_'..thread_count, function(tick)
				if tick == 100 then return POP_THREAD end
				features.request_control_once(veh)
				local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, seat, true)
				if ped and ped ~= features.player_ped() then
					TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
				end
				PED.SET_PED_INTO_VEHICLE(features.player_ped(), veh, seat)
				if VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, seat, true) ~= features.player_ped() then return end
				return POP_THREAD
			end)
		elseif PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, enum.input.VEH_EXIT) == 1 then
			local pos = features.get_space_near_vehicle(vehicles.get_player_vehicle())
			features.teleport_entity(features.player_ped(), pos.x, pos.y, pos.z)
		end
	end)
end)

__options.bool["InstaEnter/ExitVehicleFroceDriver"] = ui.add_bool_option(TRANSLATION["Force driver seat"], __submenus["EnterExitVeh"], function(bool) HudSound("TOGGLE_ON") settings.Vehicle["InstaEnter/ExitVehicleFroceDriver"] = bool end)
__options.bool["StopVehWhenExit"] = ui.add_bool_option(TRANSLATION["Stop vehicle when exiting"], __submenus["EnterExitVeh"], function(bool) HudSound("TOGGLE_ON")
	settings.Vehicle["StopVehWhenExit"] = bool 
	local veh
	CreateRemoveThread(bool, 'veh_stop', function()
		if not veh then
			if vehicles.get_player_vehicle() == 0 then return end
			veh = vehicles.get_player_vehicle()
		end
		if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, enum.input.VEH_EXIT) == 1 then
			features.request_control_once(veh)
			VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 0)
			veh = nil
		end
	end)
end)

do
	ui.add_separator(TRANSLATION["Open/close"], __submenus["VehicleDoors"])
	ui.add_click_option(TRANSLATION["Open all"], __submenus["VehicleDoors"], function()
		local veh = vehicles.get_player_vehicle()
		if veh == 0 then return HudSound("ERROR") end
		HudSound("SELECT")
		for i = 0, 5
		do
			entities.request_control(veh, function()
				VEHICLE.SET_VEHICLE_DOOR_OPEN(veh, i, false, false)
			end)
		end
	end)
	ui.add_click_option(TRANSLATION["Close all"], __submenus["VehicleDoors"], function()
		local veh = vehicles.get_player_vehicle()
		if veh == 0 then return HudSound("ERROR") end
		HudSound("SELECT")
		for i = 0, 5
		do
			entities.request_control(veh, function()
					VEHICLE.SET_VEHICLE_DOOR_SHUT(veh, i, false)
			end)
		end
	end)
	for i, v in ipairs(vehicles.door_index())
	do
		ui.add_click_option(v, __submenus["VehicleDoors"], function()
			local veh = vehicles.get_player_vehicle()
			if veh == 0 then return HudSound("ERROR") end
			HudSound("SELECT")
			entities.request_control(veh, function()
				if VEHICLE.GET_VEHICLE_DOOR_ANGLE_RATIO(veh, i) == 0 then
					VEHICLE.SET_VEHICLE_DOOR_OPEN(veh, i, false, false)
				else
					VEHICLE.SET_VEHICLE_DOOR_SHUT(veh, i, false)
				end
			end)
		end)
	end
	ui.add_separator(TRANSLATION["Break"], __submenus["VehicleDoors"])
	ui.add_click_option(TRANSLATION["Break all"], __submenus["VehicleDoors"], function()
		local veh = vehicles.get_player_vehicle()
		if veh == 0 then return HudSound("ERROR") end
		HudSound("SELECT")
		for i = 0, 5
		do
			entities.request_control(veh, function()
				VEHICLE._SET_VEHICLE_DOOR_CAN_BREAK(veh, i, true)
				VEHICLE.SET_VEHICLE_DOOR_BROKEN(veh, i, false)
			end)
		end
	end)
	for i, v in ipairs(vehicles.door_index())
	do
		ui.add_click_option(v, __submenus["VehicleDoors"], function()
			local veh = vehicles.get_player_vehicle()
			if veh == 0 then return HudSound("ERROR") end
			HudSound("SELECT")
			entities.request_control(veh, function()
				VEHICLE._SET_VEHICLE_DOOR_CAN_BREAK(veh, i, true)
				VEHICLE.SET_VEHICLE_DOOR_BROKEN(veh, i, false)
			end)
		end)
	end

end

ui.add_click_option(TRANSLATION["Repair vehicle"], __submenus["Vehicle"], function()
	local veh = vehicles.get_player_vehicle()
	if veh == 0 then return HudSound("ERROR") end
	HudSound("SELECT")
	entities.request_control(veh, function()
		vehicles.repair(veh)
	end)
end)

do
	ui.add_click_option(TRANSLATION["Add blip to vehicle"], __submenus["Vehicle"], function()
		local veh = vehicles.get_player_vehicle()
		if veh == 0 then return HudSound("ERROR") end
		if veh == vehicles.get_personal_vehicle() then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["You can't do this on personal vehicle"], 255, 0, 0, 255) return HudSound("ERROR") end
		HudSound("SELECT")
		if HUD.GET_BLIP_FROM_ENTITY(veh) ~= 0 then
			features.remove_blip(HUD.GET_BLIP_FROM_ENTITY(veh))
			return
		end
		local blip = HUD.ADD_BLIP_FOR_ENTITY(veh)
		insert(vehicle_blips, {veh, blip})
		HUD.SET_BLIP_SPRITE(blip, enum.blip_sprite.gang_vehicle)
		HUD.SET_BLIP_COLOUR(blip, enum.blip_color.Yellow)
		HUD.SET_BLIP_NAME_FROM_TEXT_FILE(blip, VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(ENTITY.GET_ENTITY_MODEL(veh)))
	end)

	CreateRemoveThread(true, 'vehicle_blips', function()
		for i, v in pairs(vehicle_blips)
		do
			if ENTITY.DOES_ENTITY_EXIST(v[1]) == 0 or ENTITY.GET_ENTITY_HEALTH(v[1]) == 0 or HUD.DOES_BLIP_EXIST(v[2]) == 0 then
				features.remove_blip(v[2])
				table_remove(vehicle_blips, i)
				break
			end
		end
	end)
end

ui.add_click_option(TRANSLATION["Allow saving"], __submenus["Vehicle"], function(bool)
	local veh = vehicles.get_player_vehicle()
	if veh == 0 or VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, true) ~= features.player_ped() then return HudSound("ERROR") end
	HudSound("SELECT")
	local pid = PLAYER.PLAYER_ID()
	entities.request_control(veh, function()
		local pl_veh
		DECORATOR.DECOR_REGISTER("Player_Vehicle", 3)
		DECORATOR.DECOR_REGISTER("Previous_Owner", 3)
		DECORATOR.DECOR_REGISTER("Vehicle_Reward", 3)
		DECORATOR.DECOR_REGISTER("MPBitset", 3)
		DECORATOR.DECOR_REGISTER("Veh_Modded_By_Player", 3)
		if ENTITY.IS_ENTITY_VISIBLE(veh) == 1 then
			if DECORATOR.DECOR_EXIST_ON(veh, "Player_Vehicle") == 1 then
				DECORATOR.DECOR_SET_INT(veh, "Player_Vehicle", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid))
			else
				pl_veh = DECORATOR.DECOR_GET_INT(veh, "Player_Vehicle")
				DECORATOR.DECOR_SET_INT(veh, "Player_Vehicle", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid))
			end
			if pl_veh and pl_veh ~= -1 then
				DECORATOR.DECOR_SET_INT(veh, "Previous_Owner", pl_veh)
			end
		end
		if DECORATOR.DECOR_EXIST_ON(veh, "Player_Vehicle") == 0 then
			DECORATOR.DECOR_SET_BOOL(veh, "Vehicle_Reward", true)
			DECORATOR.DECOR_SET_INT(veh, "Vehicle_Reward", NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid))
		end
		local veh_modd = DECORATOR.DECOR_GET_INT(veh, "Veh_Modded_By_Player")
		if veh_modd ~= 0 and veh_modd ~= -1 then
			DECORATOR.DECOR_SET_INT(veh, "Veh_Modded_By_Player", -1)
		end
		VEHICLE.SET_VEHICLE_CAN_SAVE_IN_GARAGE(veh, true)
		VEHICLE.SET_VEHICLE_HAS_BEEN_OWNED_BY_PLAYER(veh, true)
		VEHICLE.SET_VEHICLE_IS_STOLEN(veh, false)
	end)
end)

__options.bool["VehicleRapidFire"] = ui.add_bool_option(TRANSLATION["Vehicle rapid fire"], __submenus["Vehicle"], function(bool) HudSound("TOGGLE_ON")
	settings.Vehicle["VehicleRapidFire"] = bool
	CreateRemoveThread(bool, 'vehicle_rapid_fire',
	function()
		local veh = vehicles.get_player_vehicle()
		if veh == 0 then return end
		VEHICLE.SET_VEHICLE_FIXED(veh)
		VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(veh)
	end)
end)

__options.bool["InvisibleVehicle"] = ui.add_bool_option(TRANSLATION["Invisible"], __submenus["Vehicle"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'vehicle_invisible',
	function()
		if vehicles.get_player_vehicle() == 0 then return end
		features.request_control_once(vehicles.get_player_vehicle())
		ENTITY.SET_ENTITY_VISIBLE(vehicles.get_player_vehicle(), false, false)
		NETWORK._NETWORK_SET_ENTITY_INVISIBLE_TO_NETWORK(vehicles.get_player_vehicle(), false)
		ENTITY.SET_ENTITY_VISIBLE(features.player_ped(), true, false)
	end)
	if not bool then
		NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicles.get_player_vehicle())
		NETWORK._NETWORK_SET_ENTITY_INVISIBLE_TO_NETWORK(vehicles.get_player_vehicle(), true)
		ENTITY.SET_ENTITY_VISIBLE(vehicles.get_player_vehicle(), true, false) 
	end
end)

__options.bool["DisableVehicleCollision"] = ui.add_bool_option(TRANSLATION["Disable collision"], __submenus["Vehicle"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'vehicle_invisible',
	function()
		if vehicles.get_player_vehicle() == 0 then return end
		features.request_control_once(vehicles.get_player_vehicle())
		ENTITY.SET_ENTITY_COLLISION(vehicles.get_player_vehicle(), false, true)
	end)
	if not bool then
		entities.request_control(vehicles.get_player_vehicle(), function()
			ENTITY.SET_ENTITY_COLLISION(vehicles.get_player_vehicle(), true, true)
		end)
	end
end)

__options.bool["AutoFlip"] = ui.add_bool_option(TRANSLATION["Auto flip"], __submenus["Vehicle"], function(bool) HudSound("TOGGLE_ON")
	settings.Vehicle['AutoFlip'] = bool
	CreateRemoveThread(bool, 'vehicle_auto_flip',
	function()
		if vehicles.get_player_vehicle() == 0 then return end
		local veh = vehicles.get_player_vehicle()
		local rot = features.get_entity_rot(veh)
		if ENTITY.IS_ENTITY_IN_AIR(veh) == 0 and (rot.y < -110 or rot.y > 110) then
			if VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(veh) == 0 then
				features.request_control_once(veh)
				ENTITY.SET_ENTITY_ROTATION(veh, 0, 0, rot.z, 5, true)
				VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh, 0)
			end
		end
	end)
end)

__options.bool["SuperHandbrake"] = ui.add_bool_option(TRANSLATION["Super handbrake"], __submenus["Vehicle"], function(bool) HudSound("TOGGLE_ON")
	settings.Vehicle['SuperHandbrake'] = bool
	CreateRemoveThread(bool, 'vehicle_handbrake',
	function()
		local veh = vehicles.get_player_vehicle()
		if veh == 0 or PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_HANDBRAKE) == 0 then return end
		entities.request_control(veh, function()
			features.set_entity_velocity(veh, 0, 0, 0)
		end)
	end)
end)

__options.bool["EngineAlwaysOn"] = ui.add_bool_option(TRANSLATION["Engine always on"], __submenus["Vehicle"], function(bool) HudSound("TOGGLE_ON")
	settings.Vehicle['EngineAlwaysOn'] = bool
	CreateRemoveThread(bool, 'vehicle_always_on_engine',
	function()
		if vehicles.get_player_vehicle() == 0 then return end
		VEHICLE.SET_VEHICLE_ENGINE_ON(vehicles.get_player_vehicle(), true, true, false)
		ticks["EngineAlwaysOn"] = nil
	end)
end)

__options.bool["ScorchedVehicle"] = ui.add_bool_option(TRANSLATION["Scorched vehicle"], __submenus["Vehicle"], function(bool) HudSound("TOGGLE_ON")
	if vehicles.get_player_vehicle() == 0 then return end
	ENTITY.SET_ENTITY_RENDER_SCORCHED(vehicles.get_player_vehicle(), bool)
end)

__options.bool["SlidyVehicle"] = ui.add_bool_option(TRANSLATION["Slidy vehicle"], __submenus["Vehicle"], function(bool) HudSound("TOGGLE_ON")
	if vehicles.get_player_vehicle() == 0 then return end
	VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicles.get_player_vehicle(), bool)
end)

__options.bool["LicenceSpeedo"] = ui.add_bool_option(TRANSLATION["Licence plate speedo"], __submenus["Vehicle"], function(bool) HudSound("TOGGLE_ON")
	settings.Vehicle['LicenceSpeedo'] = bool
	local mult = 2.236936
	local unit = 'mph'
	if MISC.SHOULD_USE_METRIC_MEASUREMENTS() == 1 then
		mult = 3.6
		unit = 'kmph'
	end
	CreateRemoveThread(bool, 'vehicle_licence_speedo', function()
		if vehicles.get_player_vehicle() == 0 then return end
		local speed = ENTITY.GET_ENTITY_SPEED(vehicles.get_player_vehicle())
		VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicles.get_player_vehicle(), tostring(floor(speed * mult))..' '..unit)
	end)
end)

-- __options.bool["Speedo"] = ui.add_bool_option(TRANSLATION["Speedometer"], __submenus["Vehicle"], function(bool)
-- 	settings.Vehicle['Speedo'] = bool
-- 	local mult = 2.236936
-- 	local unit = 'mph'
-- 	if MISC.SHOULD_USE_METRIC_MEASUREMENTS() == 1 then
-- 		mult = 3.6
-- 		unit = 'kmph'
-- 	end
-- 	CreateRemoveThread(bool, 'speedometer', function()
-- 		if vehicles.get_player_vehicle() == 0 then return end
-- 		local speed = ENTITY.GET_ENTITY_SPEED(vehicles.get_player_vehicle())
-- 		HUD.BEGIN_TEXT_COMMAND_PRINT("STRING")
-- 		HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(tostring(floor(speed * mult))..' '..unit)
-- 		HUD.END_TEXT_COMMAND_PRINT(100, true)
-- 	end)
-- end)

__options.bool["MaxSpeedBypass"] = ui.add_bool_option(TRANSLATION["Max speed bypass"], __submenus["Vehicle"], function(bool) HudSound("TOGGLE_ON")
	settings.Vehicle["MaxSpeedBypass"] = bool
	CreateRemoveThread(bool, 'vehicle_speed_bypass', function()
		local veh = vehicles.get_player_vehicle()
		if veh == 0 then return end
		ENTITY.SET_ENTITY_MAX_SPEED(veh, 10000000)
	end)
	if not bool then
		ENTITY.SET_ENTITY_MAX_SPEED(veh, 540)
	end
end)

__options.bool["NoTurbulence"] = ui.add_bool_option(TRANSLATION["No turbulence"], __submenus["Vehicle"], function(bool) HudSound("TOGGLE_ON")
	settings.Vehicle["NoTurbulence"] = bool
	CreateRemoveThread(bool, 'vehicle_no_turbulence', function()
		local veh = vehicles.get_player_vehicle()
		if veh == 0 then return end
		VEHICLE.SET_PLANE_TURBULENCE_MULTIPLIER(veh, 0)
	end)
end)

__options.bool["StickToGround"] = ui.add_bool_option(TRANSLATION["Stick to ground"], __submenus["Vehicle"], function(bool) HudSound("TOGGLE_ON")
	settings.Vehicle["StickToGround"] = bool
	CreateRemoveThread(bool, 'vehicle_stick_to_ground', function()
		local veh = vehicles.get_player_vehicle()
		if veh == 0 or ENTITY.IS_ENTITY_IN_AIR(veh) == 0 then return end
		VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh, 5)
	end)
end)

__options.bool["SlamIt"] = ui.add_bool_option(TRANSLATION["Slam it"], __submenus["Vehicle"], function(bool) HudSound("TOGGLE_ON")
	settings.Vehicle["SlamIt"] = bool
	CreateRemoveThread(bool, 'vehicle_slam_vehicle', function()
		local veh = vehicles.get_player_vehicle()
		if veh == 0 then return end
		features.apply_force_to_entity(veh, 0, 0, 0, -30, 0, 0, 0, 0, true, false, true, false, true)
	end)
end)

do
	local pressed
	__options.choose["VehicleJumping"] = ui.add_choose(TRANSLATION["Vehicle jump"], __submenus["Vehicle"], true, {TRANSLATION['None'], TRANSLATION["Press"], TRANSLATION['Hold']}, function(int) HudSound("YES") settings.Vehicle["VehicleJumping"] = int	end)

	CreateRemoveThread(true, 'vehicle_jump', function()
		if settings.Vehicle["VehicleJumping"] == 0 then return end
		local veh = vehicles.get_player_vehicle()
		if veh == 0 then return end
		PAD.DISABLE_CONTROL_ACTION(0, enum.input.VEH_HANDBRAKE, true)
		if settings.Vehicle["VehicleJumping"] == 1 then
			if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_HANDBRAKE) == 1 and ENTITY.IS_ENTITY_IN_AIR(veh) == 0 then
				if pressed then return end
				local vel = ENTITY.GET_ENTITY_VELOCITY(veh)
	      features.set_entity_velocity(veh, vel.x, vel.y, vel.z + 10)
	      pressed = true
	    elseif pressed then
	    	pressed = nil
	    end
	    return
		end
		if settings.Vehicle["VehicleJumping"] == 2 then
			if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_HANDBRAKE) == 1 then
				local vel = ENTITY.GET_ENTITY_VELOCITY(veh)
	      features.set_entity_velocity(veh, vel.x, vel.y, vel.z + 2)
	    end
	  end
	end)
end

do
	__options.num["VehicleAccelMult"] = ui.add_float_option(TRANSLATION["Acceleration multiplier"], __submenus["VehMultipliers"], 0, 200, .1, 2, function(float) HudSound("YES") settings.Vehicle["VehicleAccelMult"] = features.round(float, 1) end)
	__options.num["VehicleBrakeMult"] = ui.add_float_option(TRANSLATION["Brake multiplier"], __submenus["VehMultipliers"], 0, 200, .1, 2, function(float) HudSound("YES") settings.Vehicle["VehicleBrakeMult"] = features.round(float, 1) end)
	__options.num["VehicleHandlingMult"] = ui.add_float_option(TRANSLATION["Handling multiplier"], __submenus["VehMultipliers"], 0, 100, .1, 2, function(float) HudSound("YES") settings.Vehicle["VehicleHandlingMult"] = features.round(float, 1) end)

	CreateRemoveThread(true, 'veh_multipliers', function()
		local veh = vehicles.get_player_vehicle()
		if veh == 0 then return end
		local model = ENTITY.GET_ENTITY_MODEL(veh)
		if VEHICLE.IS_THIS_MODEL_A_HELI(model) == 0 and (VEHICLE.IS_THIS_MODEL_A_PLANE(model) == 1 or VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(veh) == 1) then 
			if settings.Vehicle["VehicleAccelMult"] ~= 0 and PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_ACCELERATE) == 1 then
				features.apply_force_to_entity(veh, 1, 0, settings.Vehicle["VehicleAccelMult"] / 69, 0, 0, 0, 0, 0, true, true, true, false, true)
			end
			if settings.Vehicle["VehicleBrakeMult"] ~= 0 and PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_BRAKE) == 1 then
				features.apply_force_to_entity(veh, 0, 0, 0 - settings.Vehicle["VehicleAccelMult"], 0, 0, 0, 0, 0, true, true, true, false, true)
			end
			if settings.Vehicle["VehicleHandlingMult"] ~= 0 and ENTITY.GET_ENTITY_SPEED_VECTOR(veh, true).y > 2 then
				if PAD._IS_USING_KEYBOARD(0) == 1 then
					if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.SCRIPT_PAD_RIGHT) == 1 then
						features.apply_force_to_entity(veh, 1, settings.Vehicle["VehicleHandlingMult"] / 220, 0, 0, 0, 0, 0, 0, true, true, true, false, true)
					end
					if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.SCRIPT_PAD_LEFT) == 1 then
						features.apply_force_to_entity(veh, 1, (0 - settings.Vehicle["VehicleHandlingMult"]) / 220, 0, 0, 0, 0, 0, 0, true, true, true, false, true)
					end
				else
					local normal = PAD.GET_CONTROL_NORMAL(2, enum.input.SCRIPT_LEFT_AXIS_X)
					if normal > .5 or normal < -0.5 then
						features.apply_force_to_entity(veh, 1, (settings.Vehicle["VehicleHandlingMult"] * normal) / 220, 0, 0, 0, 0, 0, 0, true, true, true, false, true)
					end
				end
			end
		end
	end)
end

do
	local types = {TRANSLATION['None'], TRANSLATION['Keyboard'], TRANSLATION['Cam fly'], TRANSLATION['Glide fly']}
	local type = 0
	__options.choose["VehicleFly"] = ui.add_choose(TRANSLATION["Vehicle fly"], __submenus["Vehicle"], false, types, function(int) HudSound("YES") type = int 
		settings.Vehicle["VehicleFly"] = int
	end)

	local function f_1()
		local rot = cache:get('Veh fly rot')
		local veh = cache:get('Veh fly vehicle')
		ENTITY.SET_ENTITY_ROTATION(veh, rot.x, rot.y, rot.z, 2, true)
    local pad
  	if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_UP) == 1 then
      features.apply_force_to_entity(veh, 1, 0, 50, 0, 0, 0, 0, 0, true, false, true, false, true)
      pad = true
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_DOWN) == 1 then
      features.apply_force_to_entity(veh, 1, 0, -50, 0, 0, 0, 0, 0, true, false, true, false, true)
      pad = true
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_LEFT) == 1 then
      features.apply_force_to_entity(veh, 1, -50, 0, 0, 0, 0, 0, 0, true, false, true, false, true)
      pad = true
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_RIGHT) == 1 then
      features.apply_force_to_entity(veh, 1, 50, 0, 0, 0, 0, 0, 0, true, false, true, false, true)
      pad = true
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_MOVE_UP_ONLY) == 1 then
      features.apply_force_to_entity(veh, 1, 0, 0, 50, 0, 0, 0, 0, true, false, true, false, true)
      pad = true
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_MOVE_UD) == 1 then
      features.apply_force_to_entity(veh, 1, 0, 0, -50, 0, 0, 0, 0, true, false, true, false, true)
      pad = true
    end
    if not pad then
    	features.set_entity_velocity(veh, 0, 0, 0)
    end
    if settings.General["ShowControls"] and Instructional:New() then
    	Instructional.AddButton(enum.input.VEH_FLY_THROTTLE_UP, TRANSLATION["Forward"])
    	Instructional.AddButton(enum.input.VEH_FLY_THROTTLE_DOWN, TRANSLATION["Backward"])
    	Instructional.AddButton(enum.input.VEH_FLY_YAW_LEFT, TRANSLATION["Left"])
    	Instructional.AddButton(enum.input.VEH_FLY_YAW_RIGHT, TRANSLATION["Right"])
    	Instructional.AddButton(enum.input.VEH_MOVE_UP_ONLY, TRANSLATION["Up"])
    	Instructional.AddButton(enum.input.VEH_MOVE_UD, TRANSLATION["Down"])
    	Instructional:BackgroundColor(0, 0, 0, 80)
    	Instructional:Draw()
    end
	end

	local function f_2()
		local rot = vector3(cache:get('Veh fly rot'))
		local veh = cache:get('Veh fly vehicle')
		if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_UP) == 1 then
			local force = 20
			if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_MOVE_UP_ONLY) == 1 then force = 100 end
			local dir = rot:rot_to_direction() * force
			features.set_entity_velocity(veh, dir.x, dir.y, dir.z)
		end
		if settings.General["ShowControls"] and Instructional:New() then
    	Instructional.AddButton(enum.input.VEH_FLY_THROTTLE_UP, TRANSLATION["Fly"])
    	Instructional.AddButton(enum.input.VEH_MOVE_UP_ONLY, TRANSLATION["Faster"])
    	Instructional:BackgroundColor(0, 0, 0, 80)
    	Instructional:Draw()
    end
	end

	local function f_3()
		local rot = cache:get('Veh fly rot')
		local veh = cache:get('Veh fly vehicle')
		ENTITY.SET_ENTITY_ROTATION(veh, rot.x, rot.y, rot.z, 2, true)
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_UP) == 1 then
      features.apply_force_to_entity(veh, 1, 0, 1, 0, 0, 0, 0, 0, true, false, true, false, true)
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_DOWN) == 1 then
      features.apply_force_to_entity(veh, 1, 0, -1, 0, 0, 0, 0, 0, true, false, true, false, true)
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_LEFT) == 1 then
      features.apply_force_to_entity(veh, 1, -1, 0, 0, 0, 0, 0, 0, true, false, true, false, true)
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_RIGHT) == 1 then
      features.apply_force_to_entity(veh, 1, 1, 0, 0, 0, 0, 0, 0, true, false, true, false, true)
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_MOVE_UP_ONLY) == 1 then
      features.apply_force_to_entity(veh, 1, 0, 0, 1, 0, 0, 0, 0, true, false, true, false, true)
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_MOVE_UD) == 1 then
      features.apply_force_to_entity(veh, 1, 0, 0, -1, 0, 0, 0, 0, true, false, true, false, true)
    end
    if settings.General["ShowControls"] and Instructional:New() then
    	Instructional.AddButton(enum.input.VEH_FLY_THROTTLE_UP, TRANSLATION["Forward"])
    	Instructional.AddButton(enum.input.VEH_FLY_THROTTLE_DOWN, TRANSLATION["Backward"])
    	Instructional.AddButton(enum.input.VEH_FLY_YAW_LEFT, TRANSLATION["Left"])
    	Instructional.AddButton(enum.input.VEH_FLY_YAW_RIGHT, TRANSLATION["Right"])
    	Instructional.AddButton(enum.input.VEH_MOVE_UP_ONLY, TRANSLATION["Up"])
    	Instructional.AddButton(enum.input.VEH_MOVE_UD, TRANSLATION["Down"])
    	Instructional:BackgroundColor(0, 0, 0, 80)
    	Instructional:Draw()
    end
	end

	local f = switch()
		:case(1, f_1)
		:case(2, f_2)
		:case(3, f_3)

	CreateRemoveThread(true, 'vehicle_fly', function()
		local veh = vehicles.get_player_vehicle()
		if type == 0 or veh == 0 then return end
		cache:set('Veh fly vehicle', veh)
		cache:set('Veh fly rot', features.gameplay_cam_rot())
		features.request_control_once(veh)
		f(type)
	end)
end

do
	__options.bool["VehicleWeaponsShowLasers"] = ui.add_bool_option(TRANSLATION["Show lasers"], __submenus["VehicleWeapons"], function(bool) HudSound("TOGGLE_ON") settings.Vehicle["VehicleWeaponsShowLasers"] = bool end)
	__options.bool["VehicleWeaponsAimCamera"] = ui.add_bool_option(TRANSLATION["Aim with camera"], __submenus["VehicleWeapons"], function(bool) HudSound("TOGGLE_ON") settings.Vehicle["VehicleWeaponsAimCamera"] = bool end)
	__options.num["VehicleWeaponsDelay"] = ui.add_float_option(TRANSLATION["Delay between shots"], __submenus["VehicleWeapons"], 0, 5, .1, 3, function(float) HudSound("YES") settings.Vehicle["VehicleWeaponsDelay"] = features.round(float, 3) end)
	local types = {TRANSLATION['None'], HUD._GET_LABEL_TEXT("WT_SNIP_HVY2"), HUD._GET_LABEL_TEXT("WT_RPG"), HUD._GET_LABEL_TEXT("WT_MOLOTOV"), HUD._GET_LABEL_TEXT("WT_SNWBALL"), HUD._GET_LABEL_TEXT("WT_RAYPISTOL"), HUD._GET_LABEL_TEXT("WT_FIREWRK"), HUD._GET_LABEL_TEXT("WT_EMPL"), HUD._GET_LABEL_TEXT("WT_V_KHA_CA"), HUD._GET_LABEL_TEXT("LAZER")}
	local weapons = {
		177293209,
		-1312131151,
		615608432,
		126349499,
		-1355376991,
		2138347493,
		3676729658,
		1945616459,
		3800181289,
	}
	local type = 0
	__options.choose["VehicleWeapons"] = ui.add_choose(TRANSLATION["Vehicle weapons"], __submenus["VehicleWeapons"], false, types, function(int) HudSound("YES") type = int 
		settings.Vehicle["VehicleWeapons"] = int
	end)
	local delay
	CreateRemoveThread(true, 'vehicle_weapons', function()
		local veh = vehicles.get_player_vehicle()
		if veh == 0 or settings.Vehicle["VehicleWeapons"] == 0 then return end
		if WEAPON.HAS_WEAPON_ASSET_LOADED(weapons[type]) == 0 then
			WEAPON.REQUEST_WEAPON_ASSET(weapons[type], 31, 0)
			return
		end
		local v_min, v_max = features.get_model_dimentions(ENTITY.GET_ENTITY_MODEL(veh))
		local offset_right1 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(veh, v_max.x, v_max.y + .1, .35)
		local offset_left1 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(veh, v_min.x, v_max.y + .1, .35)
		local offset_right2 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(veh, v_max.x, v_max.y + 1500, .35)
		local offset_left2 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(veh, v_min.x, v_max.y + 1500, .35)
		if settings.Vehicle["VehicleWeaponsAimCamera"] then
			local dir = features.gameplay_cam_rot():rot_to_direction()
			local camcoord = features.gameplay_cam_pos()
			local target_pos = camcoord + dir * 1500
			local offset = ENTITY.GET_OFFSET_FROM_ENTITY_GIVEN_WORLD_COORDS(veh, target_pos.x, target_pos.y, target_pos.z)
			offset_right2 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(veh, offset.x, offset.y, offset.z)
			offset_left2 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(veh, offset.x, offset.y, offset.z)
		end
		if settings.Vehicle["VehicleWeaponsShowLasers"] then
			GRAPHICS.DRAW_LINE(offset_right1.x, offset_right1.y, offset_right1.z, offset_right2.x, offset_right2.y, offset_right2.z, 0, 255, 0, 100)
			GRAPHICS.DRAW_LINE(offset_left1.x, offset_left1.y, offset_left1.z, offset_left2.x, offset_left2.y, offset_left2.z, 0, 255, 0, 100)
		end
		if settings.General["ShowControls"] and Instructional:New() then
			Instructional.AddButton(enum.input.ATTACK2, TRANSLATION["Shoot"])
			Instructional:BackgroundColor(0, 0, 0, 80)
			Instructional:Draw()
		end
		PAD.DISABLE_CONTROL_ACTION(0, enum.input.ATTACK2, true)
		if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.ATTACK2) == 0 or (delay and delay > clock() - ui.get_value(__options.num["VehicleWeaponsDelay"])) then return end
		delay = clock()
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(offset_right1.x, offset_right1.y, offset_right1.z, offset_right2.x, offset_right2.y, offset_right2.z, 50, true, weapons[type], features.player_ped(), true, true, 24000)
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(offset_left1.x, offset_left1.y, offset_left1.z, offset_left2.x, offset_left2.y, offset_left2.z, 50, true, weapons[type], features.player_ped(), true, true, 24000)
	end)
end

__options.num["VehicleLightMultiplier"] = ui.add_float_option(TRANSLATION["Lights intensity"], __submenus["VehMultipliers"], 0, 1000, .1, 1, function(float) HudSound("YES")
	local veh = vehicles.get_player_vehicle()
	if veh == 0 then return end
	VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(veh, float)
end)

ui.set_value(__options.num["VehicleLightMultiplier"], 1, true)
__options.num["VehicleAlpha"] = ui.add_num_option(TRANSLATION["Set alpha"], __submenus["Vehicle"], 0, 255, 1, function(int)
	HudSound("YES")
	local veh = vehicles.get_player_vehicle()
	if veh == 0 then return end
	entities.request_control(veh, function()
		ENTITY.SET_ENTITY_ALPHA(veh, int, false)
		if int == 255 then
			ENTITY.RESET_ENTITY_ALPHA(veh)
		end
	end)
end)

do
	local max = -1
	local num_seat
	local is_custom
	local del_veh
	local _seat = -1
	CreateRemoveThread(true, 'vehicle_handle', function()
		local veh = vehicles.get_player_vehicle()
		if vehicles.get_player_vehicle() ~= 0 then
			if not is_custom then
				vehicles.tuning_menu(veh, __submenus["Vehicle"], veh_customs, veh_customs.sub_mods and true or false)
				is_custom = true
			end
			if not num_seat then
				num_seat = ui.add_num_option(TRANSLATION["Change seat"], __submenus["Vehicle"], -1, max, 1, function(seat)
					HudSound("YES")
					CreateRemoveThread(true, 'seat_change_'..thread_count, function(tick)
						if tick == 100 then return POP_THREAD end
						local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, seat, true)
						if ped and ped ~= features.player_ped() then
							TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
						end
						features.request_control_once(veh)
						PED.SET_PED_INTO_VEHICLE(features.player_ped(), veh, seat)
						if VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, seat, true) ~= features.player_ped() then return end
						return POP_THREAD
					end)
				end)
				local hash = ENTITY.GET_ENTITY_MODEL(veh)
				max = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(hash) - 2
				ui.set_num_max(num_seat, max)
			end
			if not del_veh then
				del_veh = ui.add_click_option(TRANSLATION["Delete current vehicle"], __submenus["Vehicle"], function()
					local veh = vehicles.get_player_vehicle()
					if veh == 0 then return HudSound("ERROR") end
					HudSound("SELECT")
					TASK.CLEAR_PED_TASKS_IMMEDIATELY(features.player_ped())
					features.delete_entity(veh)
				end)
			end
			local _seat = vehicles.get_ped_seat(features.player_ped())
			if _seat ~= ui.get_value(num_seat) then
				ui.set_value(num_seat, _seat, true)
			end

			if ui.is_sub_open(veh_customs.sub_mods) then
				local primary, secondary = s_memory.allocate(2)
	            VEHICLE.GET_VEHICLE_COLOURS(veh, primary, secondary)
	            ui.set_value(veh_customs.paint_primary_select, memory.read_int(primary), true)
	            ui.set_value(veh_customs.paint_secondary_select, memory.read_int(secondary), true)
	            local r, g, b = s_memory.allocate(3)
	            VEHICLE.GET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, r, g, b)
	            ui.set_value(veh_customs.paint_primary_rgb, memory.read_int(r), memory.read_int(g), memory.read_int(b), 255, true)
	            VEHICLE.GET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, r, g, b)
	            ui.set_value(veh_customs.paint_secondary_rgb, memory.read_int(r), memory.read_int(g), memory.read_int(b), 255, true)
	            local pearl, wheel = s_memory.allocate(2)
	            VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
	            ui.set_value(veh_customs.paint_pearlescent_select, memory.read_int(pearl), true)
	            for i = 0, 48
	            do
	                if i < 17 or i > 24 and veh_customs["veh_mod_"..i] then
	                    ui.set_value(veh_customs["veh_mod_"..i], VEHICLE.GET_VEHICLE_MOD(veh, i) + 1, true)
	                end
	            end
	            ui.set_value(veh_customs.turbo, VEHICLE.IS_TOGGLE_MOD_ON(veh, 18) == 1, true)
	            ui.set_value(veh_customs.tyre_smoke, VEHICLE.IS_TOGGLE_MOD_ON(veh, 20) == 1, true)
	            ui.set_value(veh_customs.xenons, VEHICLE.IS_TOGGLE_MOD_ON(veh, 22) == 1, true)
	            ui.set_value(veh_customs.bulletproof_tires, VEHICLE.GET_VEHICLE_TYRES_CAN_BURST(veh) == 0, true)
	            ui.set_value(veh_customs.licence_index, VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh), true)
	            ui.set_value(veh_customs.licence_text, VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT(veh), true)
	            for i = 0, 20
	            do
	                if VEHICLE.DOES_EXTRA_EXIST(veh, i) == 1 then
	                    ui.set_value(veh_customs["extra_"..i], VEHICLE.IS_VEHICLE_EXTRA_TURNED_ON(veh, i) == 1, true)
	                end
	            end
	            ui.set_value(veh_customs.window_tint, VEHICLE.GET_VEHICLE_WINDOW_TINT(veh), true)
	            local xenon_color = VEHICLE._GET_VEHICLE_XENON_LIGHTS_COLOR(veh)
	            ui.set_value(veh_customs.xenon_color, xenon_color == 255 and 0 or xenon_color + 1, true)
	            local interior, dashboard = s_memory.allocate(2)
	            VEHICLE._GET_VEHICLE_INTERIOR_COLOR(veh, interior)
	            ui.set_value(veh_customs.interior_color, memory.read_int(interior), true)
	            VEHICLE._GET_VEHICLE_DASHBOARD_COLOR(veh, dashboard)
	            ui.set_value(veh_customs.dashboard_color, memory.read_int(dashboard), true)
	            for i = 0, 3
	            do
	                ui.set_value(veh_customs["neon_"..i], VEHICLE._IS_VEHICLE_NEON_LIGHT_ENABLED(veh, i) == 1, true)
	            end
	            VEHICLE._GET_VEHICLE_NEON_LIGHTS_COLOUR(veh, r, g, b)
	            ui.set_value(veh_customs.neon_rgb, memory.read_int(r), memory.read_int(g), memory.read_int(b), 255, true)
	            VEHICLE.GET_VEHICLE_TYRE_SMOKE_COLOR(veh, r, g, b)
				ui.set_value(veh_customs.tyre_smoke_color, memory.read_int(r), memory.read_int(g), memory.read_int(b), 255, true)
	        elseif ui.is_sub_open(veh_customs.wheel_sub) then 
	        	local pearl, wheel = s_memory.allocate(2)
	            VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
	        	ui.set_num_max(veh_customs.wheels, VEHICLE.GET_NUM_VEHICLE_MODS(veh, 23))
	            ui.set_value(veh_customs.custom_wheels, VEHICLE.GET_VEHICLE_MOD_VARIATION(veh, 23) == 1 or VEHICLE.GET_VEHICLE_MOD_VARIATION(veh, 24) == 1, true)
	            if VEHICLE.IS_THIS_MODEL_A_BIKE(ENTITY.GET_ENTITY_MODEL(veh)) == 1 then
	                ui.set_value(veh_customs.wheels_front, VEHICLE.GET_VEHICLE_MOD(veh, 23), true)
	                ui.set_value(veh_customs.wheels_back, VEHICLE.GET_VEHICLE_MOD(veh, 24) + 1, true)
	            else
	            	local wheel_type = VEHICLE.GET_VEHICLE_WHEEL_TYPE(veh)
	                ui.set_value(veh_customs.wheel_type, wheel_type < 6 and wheel_type or wheel_type - 1, true)
	                ui.set_value(veh_customs.wheels, VEHICLE.GET_VEHICLE_MOD(veh, 23) + 1, true)
	            end
	            ui.set_value(veh_customs.wheel_color, memory.read_int(wheel), true)
	        end
		else
			if num_seat then
				ui.remove(num_seat)
				num_seat = nil
			end
			if del_veh then
				ui.remove(del_veh)
				del_veh = nil
			end
			if is_custom then
				for k, v in pairs(veh_customs)
				do
					if k == 'subopt_mods' then
						ui.hide(v, true)
					elseif k ~= 'sub_mods' then
						ui.remove(v)
					end
				end
				is_custom = nil
			end
		end
	end)
end

---------------------------------------------------------------------------------------------------------------------------------
-- World
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'world submenu') end
__submenus["World"] = ui.add_submenu(TRANSLATION["World"])
__suboptions["World"] = ui.add_sub_option(TRANSLATION["World"], __submenus["MainSub"], __submenus["World"])

__submenus["WorldEditor"] = ui.add_submenu(TRANSLATION["Editor"])
__suboptions["WorldEditor"] = ui.add_sub_option(TRANSLATION["Editor"], __submenus["World"] , __submenus["WorldEditor"])

__submenus["WorldEditorSpawned"] = ui.add_submenu(TRANSLATION["Spawned"])
__suboptions["WorldEditorSpawned"] = ui.add_sub_option(TRANSLATION["Spawned"], __submenus["WorldEditor"] , __submenus["WorldEditorSpawned"])

__submenus["WorldEditorMaps"] = ui.add_submenu(TRANSLATION["Maps"])
__suboptions["WorldEditorMaps"] = ui.add_sub_option(TRANSLATION["Maps"], __submenus["WorldEditor"] , __submenus["WorldEditorMaps"])

__submenus["WorldEditorSettings"] = ui.add_submenu(TRANSLATION["Settings"])
__suboptions["WorldEditorSettings"] = ui.add_sub_option(TRANSLATION["Settings"], __submenus["WorldEditor"] , __submenus["WorldEditorSettings"])

__submenus["WorldEditorSaveMap"] = ui.add_submenu(TRANSLATION["Save"])
__suboptions["WorldEditorSaveMap"] = ui.add_sub_option(TRANSLATION["Save"], __submenus["WorldEditorMaps"] , __submenus["WorldEditorSaveMap"])
ui.add_click_option(TRANSLATION["Open folder"], __submenus["WorldEditorMaps"], function(bool) HudSound("SELECT") if not filesystem.isdir(paths["SavedMaps"]) then filesystem.make_dir(paths["SavedMaps"]) end filesystem.open(paths["SavedMaps"]) end)
ui.add_separator(TRANSLATION["Saved"], __submenus["WorldEditorMaps"])

do
	local name
	local is_open
	local maps = {}
	local saved
	__options.string["SaveMapName"] = ui.add_input_string(TRANSLATION["Name"], __submenus["WorldEditorSaveMap"], function(text) name = text end)

	ui.add_separator(TRANSLATION["Reference position"], __submenus["WorldEditorSaveMap"])

	local x = ui.add_float_option("X", __submenus["WorldEditorSaveMap"], -10000, 10000, 1, 3, function() HudSound("YES") end)
	local y = ui.add_float_option("Y", __submenus["WorldEditorSaveMap"], -10000, 10000, 1, 3, function() HudSound("YES") end)
	local z = ui.add_float_option("Z", __submenus["WorldEditorSaveMap"], -10000, 10000, 1, 3, function() HudSound("YES") end)

	ui.add_separator(TRANSLATION["Database"], __submenus["WorldEditorSaveMap"])

	ui.add_click_option(TRANSLATION["Save entities in database"], __submenus["WorldEditorSaveMap"], function()
		if not name or name:isblank() then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Please enter name"], 255, 0, 0, 255) return HudSound("ERROR") end
		local entities = EntityDb.GetEntitiesInDb()
		if #entities == 0 then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["No entities in database"], 255, 0, 0, 255) return HudSound("ERROR") end
		HudSound("SELECT")
		if not filesystem.isdir(paths["SavedMaps"]) then
			filesystem.make_dir(paths["SavedMaps"])
		end
		local refernce_pos = vector3(ui.get_value(x), ui.get_value(y), ui.get_value(z))
		world_saver.save_map(entities, paths["SavedMaps"]:ensureend('\\')..name..[[.json]], refernce_pos)
	end)

	ui.add_separator(TRANSLATION["Nearby"], __submenus["WorldEditorSaveMap"])

	__options.num["EntitySaveDistance"] = ui.add_num_option(TRANSLATION["Radius"], __submenus["WorldEditorSaveMap"], 0, 10000, 1, function(int)
		HudSound("YES")
		CreateRemoveThread(true, 'draw_prev_shere', function(tick)
			if tick > 100 then return POP_THREAD end
			local pos = features.get_player_coords()
			GRAPHICS._DRAW_SPHERE(pos.x, pos.y, pos.z, int, 0, 255, 255, .5)
		end)
	end)

	ui.add_click_option(TRANSLATION["Save nearby entities"], __submenus["WorldEditorSaveMap"], function()
		if not name or name:isblank() then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Please enter name"], 255, 0, 0, 255) return HudSound("ERROR") end
		local entities = {}
		local distance = ui.get_value(__options.num["EntitySaveDistance"]) ^ 2
		local pos = features.get_player_coords()
		for _, v in ipairs(features.get_entities())
		do
			if distance >= features.get_entity_coords(v):sqrlen(pos) then
				insert(entities, v)
			end
		end
		if #entities == 0 then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["No entities to save"], 255, 0, 0, 255) return HudSound("ERROR") end
		HudSound("SELECT")
		if not filesystem.isdir(paths["SavedMaps"]) then
			filesystem.make_dir(paths["SavedMaps"])
		end
		local refernce_pos = vector3(ui.get_value(x), ui.get_value(y), ui.get_value(z))
		world_saver.save_map(entities, paths["SavedMaps"]:ensureend('\\')..name..[[.json]], refernce_pos)
	end)

	local repeats = 0
	local function RefreshMaps()
		saved = {}
		if not filesystem.isdir(paths['SavedMaps']) then
			filesystem.make_dir(paths['SavedMaps'])
		end
		local files = filesystem.scandir(paths['SavedMaps'])
		local found
		repeats = 0
		for _, v in ipairs(files)
		do
			if v:endswith('.json') then
				local name = v:gsub('.json$', '')

				local n = name:match("[^%s]*$"):gsub('%D', '')
				if name:gsub(' %('..n..'%)', '') == TRANSLATION["My new map"] and name:sub(-len(' ('..n..')'), -1) == ' ('..n..')' then
					repeats = tonumber(n) and tonumber(n) + 1 or repeats
				end

				saved[name] = true
				if not maps[name] then
					local sub = ui.add_submenu(name)
					maps[name] = {
						sub = sub,
						sub_opt = ui.add_sub_option(name, __submenus["WorldEditorMaps"], sub),
						spawn = ui.add_click_option(TRANSLATION["Spawn"], sub, function()
							CreateRemoveThread(true, 'spawn_map', function()
								local file = paths['SavedMaps']:ensureend('\\')..v
								if not filesystem.exists(file) then HudSound("ERROR");system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["File doesn't exist"], 255, 0, 0, 255) return POP_THREAD end 
								local data = json:decode(filesystem.read_all(file))
								world_spawner.spawn_map(data)
								if settings.World["WorldEditorTpToReference"] then
									for _, v in ipairs(data)
									do
										if v.reference then
											features.teleport(features.player_ped(), v.reference.x, v.reference.y, v.reference.z)
											break
										end
									end
								end
								return POP_THREAD
							end)
						end),
						teleport_to = ui.add_click_option(TRANSLATION["Teleport to reference"], sub, function()
							CreateRemoveThread(true, 'tp_to_reference', function()
								local file = paths['SavedMaps']:ensureend('\\')..v
								if not filesystem.exists(file) then HudSound("ERROR");system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["File doesn't exist"], 255, 0, 0, 255) return POP_THREAD end 
								local data = json:decode(filesystem.read_all(file))
								local found
								for _, v in ipairs(data)
								do
									if v.reference then
										features.teleport(features.player_ped(), v.reference.x, v.reference.y, v.reference.z)
										found = true
										HudSound("SELECT")
										break
									end
								end
								if not found then HudSound("ERROR") end
								return POP_THREAD
							end)
						end),
						rename = ui.add_input_string(TRANSLATION["Rename"], sub, function(text)
							if text:isblank() then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Please enter name"], 255, 0, 0, 255) return HudSound("ERROR") end
							if maps[text] then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Name already taken"], 255, 0, 0, 255) return HudSound("ERROR") end
							os.rename(paths['SavedMaps']:ensureend('\\')..v, paths['SavedMaps']:ensureend('\\')..text..[[.json]])
							RefreshMaps()
						end),
						delete = ui.add_click_option(TRANSLATION["Delete"], sub, function()
							HudSound("SELECT")
							os.remove(paths['SavedMaps']:ensureend('\\')..v)
							for _, e in pairs(maps[name])
							do
								ui.remove(e)
							end
							maps[name] = nil
							RefreshMaps()
						end)
					}
				end
			end
		end

		for k, v in pairs(maps)
		do
			if not saved[k] then
				for _, e in pairs(v)
				do
					ui.remove(e)
				end
				maps[k] = nil
			end
		end
	end

	local maps_open
	CreateRemoveThread(true, 'map_saver', function()
		if ui.is_sub_open(__submenus["WorldEditorSaveMap"]) and not is_open then
			is_open = true
			local pos = features.get_player_coords()
			ui.set_value(x, pos.x, true)
			ui.set_value(y, pos.y, true)
			ui.set_value(z, pos.z, true)
		elseif not ui.is_sub_open(__submenus["WorldEditorSaveMap"]) and is_open then
			is_open = false
		end

		if ui.is_sub_open(__submenus["WorldEditorMaps"]) and not maps_open then
			RefreshMaps()
			ui.set_value(__options.string["SaveMapName"], TRANSLATION["My new map"]..string.format(' (%i)', repeats), false)			
			maps_open = true
		elseif not ui.is_sub_open(__submenus["WorldEditorMaps"]) and maps_open then
			maps_open = false
		end
	end)


end

ui.add_click_option(TRANSLATION["Remove invalid entities"], __submenus["WorldEditorSpawned"], function()
	if EntityDb.IsEmpty(true) then HudSound("ERROR") return end
	HudSound("SELECT")
	EntityDb.RemoveInvalidEntities()
end)

ui.add_click_option(TRANSLATION["Remove all entities from db"], __submenus["WorldEditorSpawned"], function()
	if EntityDb.IsEmpty() then HudSound("ERROR") return end
	HudSound("SELECT")
	for k, v in pairs(EntityDb.entity_data)
	do
		EntityDb.RemoveFromDatabase(k)
	end
end)

ui.add_click_option(TRANSLATION["Delete all entities"], __submenus["WorldEditorSpawned"], function()
	if EntityDb.IsEmpty() then HudSound("ERROR") return end
	HudSound("SELECT")
	local veh = vehicles.get_player_vehicle()
	for k, v in pairs(EntityDb.entity_data)
	do
		EntityDb.RemoveFromDatabase(k)
		if veh ~= 0 and k == veh then TASK.CLEAR_PED_TASKS_IMMEDIATELY(features.player_ped()) end
		features.delete_entity(k)
	end
end)

do
	local selected = {}
	local options = {}

	__submenus["WorldEditorEditEntities"] = ui.add_submenu(TRANSLATION["Edit entities"])
	__suboptions["WorldEditorEditEntities"] = ui.add_sub_option(TRANSLATION["Edit entities"], __submenus["WorldEditorSpawned"], __submenus["WorldEditorEditEntities"])

	__submenus["WorldEditorSelectEntities"] = ui.add_submenu(TRANSLATION["Select"])
	__suboptions["WorldEditorSelectEntities"] = ui.add_sub_option(TRANSLATION["Select"], __submenus["WorldEditorEditEntities"], __submenus["WorldEditorSelectEntities"])

	ui.add_click_option(TRANSLATION["Select all"],  __submenus["WorldEditorSelectEntities"], function()
		local found
		dont_play_tog = true
		for _, v in pairs(options)
		do
			ui.set_value(v, true, false)
			found = true
		end
		if found then HudSound("SELECT") else HudSound("ERROR") end
	end)
	ui.add_click_option(TRANSLATION["Unselect all"],  __submenus["WorldEditorSelectEntities"], function()
		local found
		dont_play_tog = true
		for _, v in pairs(options)
		do
			ui.set_value(v, false, false)
			found = true
		end
		if found then HudSound("SELECT") else HudSound("ERROR") end
	end)
	ui.add_separator(TRANSLATION["Entities"], __submenus["WorldEditorSelectEntities"])
	CreateRemoveThread(true, 'entities_in_db', function()
		if ui.is_sub_open(__submenus["WorldEditorEditEntities"]) or ui.is_sub_open(__submenus["WorldEditorSelectEntities"]) then
			for k, v in pairs(EntityDb.entity_data)
			do
				if not options[k] and v.valid == 1 then
					options[k] = ui.add_bool_option(v.name, __submenus["WorldEditorSelectEntities"], function(bool)
						HudSound("TOGGLE_ON")
						selected[k] = bool			
					end)
				end
			end
			for k, v in pairs(options)
			do
				if not EntityDb.entity_data[k] or EntityDb.entity_data[k].valid == 0 then
					ui.remove(v)
					selected[k] = nil
					options[k] = nil
				end
			end
		else
			for _, v in pairs(options)
			do
				ui.remove(v)
			end
			selected = {}
			options = {}
		end
	end)

	local position = {}
	local step_val = {'0.0001','0.001', '0.01', '0.1', '1.0', '10.0', '100.0'}
	local step = ui.add_choose(TRANSLATION["Step"], __submenus["WorldEditorEditEntities"], true, step_val, function(type)
		HudSound("YES")
		local value = tonumber(step_val[type + 1])
		for _, v in pairs(position)
		do
			ui.set_step(v, value)
		end
	end)
	dont_play_tog = true
	ui.set_value(step, 3, false)
	position.x = ui.add_float_option("X", __submenus["WorldEditorEditEntities"], -10000, 10000, .1, 4, function(float)
		local found
		for k in pairs(selected)
		do
			local pos = features.get_entity_coords(k)
			features.teleport(k, pos.x + float, pos.y, pos.z)
			found = true
		end
		if found then HudSound("SELECT") else HudSound("ERROR") end
		ui.set_value(position.x, 0, true)
	end)
	position.y = ui.add_float_option("Y", __submenus["WorldEditorEditEntities"], -10000, 10000, .1, 4, function(float)
		local found
		for k in pairs(selected)
		do
			local pos = features.get_entity_coords(k)
			features.teleport(k, pos.x, pos.y + float, pos.z)
			found = true
		end
		if found then HudSound("SELECT") else HudSound("ERROR") end
		ui.set_value(position.y, 0, true)
	end)
	position.z = ui.add_float_option("Z", __submenus["WorldEditorEditEntities"], -10000, 10000, .1, 4, function(float)
		local found
		for k in pairs(selected)
		do
			local pos = features.get_entity_coords(k)
			features.teleport(k, pos.x, pos.y, pos.z + float)
			found = true
		end
		if found then HudSound("SELECT") else HudSound("ERROR") end
		ui.set_value(position.z, 0, true)
	end)

	position.pitch = ui.add_float_option(TRANSLATION["Pitch"], __submenus["WorldEditorEditEntities"], -10000, 10000, .1, 4, function(float)
		local found
		for k in pairs(selected)
		do
			local rot = features.get_entity_rot(k)
			ENTITY.SET_ENTITY_ROTATION(k, rot.x + float, rot.y, rot.z, 2, true)
			found = true
		end
		if found then HudSound("SELECT") else HudSound("ERROR") end
		ui.set_value(position.pitch, 0, true)
	end)
	position.roll = ui.add_float_option(TRANSLATION["Roll"], __submenus["WorldEditorEditEntities"], -10000, 10000, .1, 4, function(float)
		local found
		for k in pairs(selected)
		do
			local rot = features.get_entity_rot(k)
			ENTITY.SET_ENTITY_ROTATION(k, rot.x, rot.y + float, rot.z, 2, true)
			found = true
		end
		if found then HudSound("SELECT") else HudSound("ERROR") end
		ui.set_value(position.roll, 0, true)
	end)
	position.yaw = ui.add_float_option(TRANSLATION["Yaw"], __submenus["WorldEditorEditEntities"], -10000, 10000, .1, 4, function(float)
		local found
		for k in pairs(selected)
		do
			local rot = features.get_entity_rot(k)
			ENTITY.SET_ENTITY_ROTATION(k, rot.x, rot.y, rot.z + float, 2, true)
			found = true
		end
		if found then HudSound("SELECT") else HudSound("ERROR") end
		ui.set_value(position.yaw, 0, true)
	end)

	ui.add_click_option(TRANSLATION["Copy"], __submenus["WorldEditorEditEntities"], function()
		local found
		for k in pairs(selected)
		do
			world_spawner.copy_entity(k, false)
			found = true
		end
		if found then HudSound("SELECT") else HudSound("ERROR") end
	end)

	ui.add_click_option(TRANSLATION["Delete"], __submenus["WorldEditorEditEntities"], function()
		local found
		for k in pairs(selected)
		do
			features.delete_entity(k)
			EntityDb.RemoveFromDatabase(k)
			found = true
		end
		if found then HudSound("SELECT") else HudSound("ERROR") end
	end)
end

ui.add_separator(TRANSLATION["Entities"], __submenus["WorldEditorSpawned"])
do
	local wait = 0
	local cam = 0
	local cam_pos
	local cam_rot
	local DrawInstructions = switch()
	  	:case(1, function(IsPointingAtEntity)
			if IsPointingAtEntity then
				Instructional.AddButton(enum.input.ATTACK2, TRANSLATION["Grab entity"])
				Instructional.AddButton(enum.input.FRONTEND_DELETE, TRANSLATION["Delete"])
				Instructional.AddButton(enum.input.VEH_LOOK_BEHIND, TRANSLATION["Copy"])
			end
		  	Instructional.AddButton(enum.input.VEH_SUB_ASCEND, TRANSLATION["Faster"])
		  	Instructional.AddButton(enum.input.VEH_FLY_THROTTLE_UP, TRANSLATION["Forward"])
		  	Instructional.AddButton(enum.input.VEH_FLY_THROTTLE_DOWN, TRANSLATION["Backward"])
		  	Instructional.AddButton(enum.input.VEH_FLY_YAW_LEFT, TRANSLATION["Left"])
		  	Instructional.AddButton(enum.input.VEH_FLY_YAW_RIGHT, TRANSLATION["Right"])
		  	Instructional.AddButton(enum.input.VEH_PUSHBIKE_SPRINT, TRANSLATION["Up"])
		  	Instructional.AddButton(enum.input.VEH_SUB_DESCEND, TRANSLATION["Down"])
			end)
	    :case(2, function()
			Instructional.AddButton(enum.input.VEH_SUB_ASCEND, TRANSLATION["Precision"])
		  	Instructional.AddButton(enum.input.CELLPHONE_UP, "")
		  	Instructional.AddButton(enum.input.CELLPHONE_DOWN, TRANSLATION["Pitch"])
		  	Instructional.AddButton(enum.input.VEH_LOOK_BEHIND, "")
		  	Instructional.AddButton(enum.input.MULTIPLAYER_INFO, TRANSLATION["Roll"])
		  	Instructional.AddButton(enum.input.VEH_HORN, "")
		  	Instructional.AddButton(enum.input.VEH_RADIO_WHEEL, TRANSLATION["Yaw"])
		end)

	__options.num["FreeCamSens"] = ui.add_num_option(TRANSLATION["Free cam sensitivity"], __submenus["WorldEditorSettings"], 1, 100, 5, function(int) HudSound("YES") settings.World["FreeCamSens"] = int end)
	__options.num["FreeCamMovement"] = ui.add_float_option(TRANSLATION["Free cam movement speed"], __submenus["WorldEditorSettings"], 0, 10, .1, 1, function(float) HudSound("YES") settings.World["FreeCamMovement"] = features.round(float, 1) end)

	__options.bool["FreeCam"] = ui.add_bool_option(TRANSLATION["Free cam"], __submenus["WorldEditor"], function(bool) HudSound("TOGGLE_ON")
		HUD.DISPLAY_RADAR(not bool)
		if not bool then
			CAM.RENDER_SCRIPT_CAMS(false, false, 0, true, false, 0)
			CAM.SET_CAM_ACTIVE(cam, false)
			CAM.DESTROY_CAM(cam, false)
			globals.set_int(20266 + 1, 0)
			cam = 0
		elseif ui.get_value(__options.choose["NoClip"] ~= 0) then
			dont_play_tog = true
			ui.set_value(__options.choose["NoClip"], 0, false)
		end
		ENTITY.FREEZE_ENTITY_POSITION(features.player_ped(), bool)
		local Entity
		CreateRemoveThread(bool, 'free_cam', function(tick)
			ENTITY.FREEZE_ENTITY_POSITION(features.player_ped(), true)
			local add_to_db = nil
			if CAM.DOES_CAM_EXIST(cam) == 0 then
				CAM.DESTROY_ALL_CAMS(true)
				cam = CAM.CREATE_CAM("DEFAULT_SCRIPTED_CAMERA", false)
				cam_rot = features.gameplay_cam_rot()
				CAM.SET_CAM_ROT(cam, cam_rot.x, cam_rot.y, cam_rot.z, 2)
				CAM.SET_CAM_FOV(cam, 50)
				cam_pos = features.gameplay_cam_pos()
				CAM.SET_CAM_COORD(cam, cam_pos.x, cam_pos.y, cam_pos.z)
				CAM.SET_CAM_ACTIVE(cam, true)
				CAM.RENDER_SCRIPT_CAMS(true, false, 0, true, false, 0)
			else
				local entity
				local IsPointingAtEntity
				local instructional_type = 1
				PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
				globals.set_int(20266 + 1, 1) -- disable phone
				local color = {r = 255, g = 255, b = 255}
				local rot = cam_rot
				local end_pos = cam_pos + (rot:rot_to_direction() * 50)
				local result = features.get_raycast_result(cam_pos, end_pos, 0, 2+4+8+16)
				if result.hitEntity ~= 0 and not Entity then
					entity = result.hitEntity
					color = {r = 0, g = 255, b = 0}
					IsPointingAtEntity = true
					if not EntityDb.IsEntityInDatabase(entity) then
						add_to_db = true
						if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, enum.input.SPECIAL_ABILITY_SECONDARY) == 1 then
							EntityDb.AddEntityToDatabase(entity)
						end
					else
						add_to_db = false
						if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, enum.input.SPECIAL_ABILITY_SECONDARY) == 1 then
							EntityDb.RemoveFromDatabase(entity)
						end
					end
					if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.FRONTEND_DELETE) == 1 then
						features.delete_entity(entity)
						EntityDb.RemoveFromDatabase(entity)
					end
					if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, enum.input.VEH_LOOK_BEHIND) == 1 then
						CreateRemoveThread(true, 'copy_entity', function(tick)
							if tick < 2 then return end
							world_spawner.copy_entity(entity, false)
							return POP_THREAD
						end)
					end
				end
				local X = -PAD.GET_DISABLED_CONTROL_NORMAL(0, enum.input.LOOK_LR) * (settings.World["FreeCamSens"] / 10)
				local Y = -PAD.GET_DISABLED_CONTROL_NORMAL(0, enum.input.LOOK_UD) * (settings.World["FreeCamSens"] / 10)
				cam_rot = vector3((rot.x + Y > -89 and rot.x + Y < 89) and rot.x + Y or rot.x, 0, rot.z + X)
				CAM.SET_CAM_ROT(cam, cam_rot.x, cam_rot.y, cam_rot.z, 2)
				local mult = .3 * settings.World["FreeCamMovement"]
				if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_SUB_ASCEND) == 1 then
			    	mult = 1 * settings.World["FreeCamMovement"]
			    end
				local pos = vector3.zero()
			    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_UP) == 1 then
			    	pos = pos + vector3.forward(mult)
			    end
			    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_DOWN) == 1 then
			      pos = pos + vector3.back(mult)
			    end
			    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_LEFT) == 1 then
			      pos = pos + vector3.left(mult)
			    end
			    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_RIGHT) == 1 then
			       pos = pos + vector3.right(mult)
			    end
			    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_PUSHBIKE_SPRINT) == 1 then
			      pos = pos + vector3.up(mult)
			    end
			    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_SUB_DESCEND) == 1 then
			      pos = pos + vector3.down(mult)
			    end
			    if wait < clock() then
					local _cam_pos = features.get_offset_cam_coords(cam, pos)
					local my_coord = features.get_player_coords()
					if _cam_pos:sqrlen(my_coord) > 160000 then
						if tick%20==0 then AUDIO.PLAY_SOUND_FRONTEND(-1, "ERROR", "HUD_FRONTEND_TATTOO_SHOP_SOUNDSET", true) end
						GRAPHICS._DRAW_SPHERE(my_coord.x, my_coord.y, my_coord.z, 400, 255, 0, 0, .2)
					else
						cam_pos = _cam_pos
					end
					if _cam_pos:sqrlen(my_coord) > 2500 then
						GRAPHICS.DRAW_LINE(my_coord.x, my_coord.y, -1000, my_coord.x, my_coord.y, 6000, 0, 255, 0, 255)
					end
					CAM.SET_CAM_COORD(cam, cam_pos.x, cam_pos.y, cam_pos.z)
				end
				if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.ATTACK2) == 1 then
					if not Entity and entity then
						Entity = entity
					elseif Entity then
						instructional_type = 2
						features.request_control_once(Entity)
						local pos = cam_pos + (cam_rot:rot_to_direction() * 20)
						erot = features.get_entity_rot(Entity)
						local mult = 1
						if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_SUB_ASCEND) == 1 then
							mult = 10
				    	end
						if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.CELLPHONE_UP) == 1 then
							erot = erot + vector3.right() / mult
						end
						if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.CELLPHONE_DOWN) == 1 then
							erot = erot + vector3.left() / mult
						end
						if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_LOOK_BEHIND) == 1 then
							erot = erot + vector3.forward() / mult
						end
						if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.MULTIPLAYER_INFO) == 1 then
							erot = erot + vector3.back() / mult
						end
						if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_HORN) == 1 then
							erot = erot + vector3.up() / mult
						end
						if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_RADIO_WHEEL) == 1 then
							erot = erot + vector3.down() / mult
						end
						rot = erot
						ENTITY.SET_ENTITY_ROTATION(Entity, erot.x, erot.y, erot.z, 2, true)
						local endCoords = cam_pos + (cam_rot:rot_to_direction() * 100)
						local result2 = features.get_raycast_result(cam_pos, endCoords, Entity, -1)
						if result2.didHit and settings.World["WorldEditorPlacementAssist"] then
							local dim = features.get_model_dimentions(ENTITY.GET_ENTITY_MODEL(Entity))
							pos = vector3(result2.endCoords.x, result2.endCoords.y, result2.endCoords.z + abs(dim.z))
						end
						ENTITY.SET_ENTITY_COORDS_NO_OFFSET(Entity, pos.x, pos.y, pos.z, false, false, false)
						color = {r = 255, g = 100, b = 0}
					end
				else
					Entity = nil
				end
				features.draw_crosshair(20, 20, 0, 2, color.r, color.g, color.b, 255, true, true, true, true, 0, 0, 0, 0, 0, false)
				if settings.General["ShowControls"] and Instructional:New() then
					DrawInstructions(instructional_type, IsPointingAtEntity)
				    if add_to_db then
				    	Instructional.AddButton(enum.input.SPECIAL_ABILITY_SECONDARY, TRANSLATION["Add to database"])
				    elseif add_to_db == false then
				    	Instructional.AddButton(enum.input.SPECIAL_ABILITY_SECONDARY, TRANSLATION["Remove from db"])
				    end
				    Instructional:BackgroundColor(0, 0, 0, 80)
			    	Instructional:Draw()
		    	end
		  	end
		end)
	end)
	__options.bool["WorldEditorPlacementAssist"] = ui.add_bool_option(TRANSLATION["Easy placement"], __submenus["WorldEditorSettings"], function(bool) HudSound("TOGGLE_ON") settings.World["WorldEditorPlacementAssist"] = bool end)
	__options.bool["WorldEditorTpToReference"] = ui.add_bool_option(TRANSLATION["Auto teleport to reference"], __submenus["WorldEditorSettings"], function(bool) HudSound("TOGGLE_ON") settings.World["WorldEditorTpToReference"] = bool end)
	ui.add_separator(TRANSLATION["Spawn settings"], __submenus["WorldEditorSettings"])
	__options.bool["WorldEditorSpawnInvincible"] = ui.add_bool_option(TRANSLATION["Spawn invincible"], __submenus["WorldEditorSettings"], function(bool) HudSound("TOGGLE_ON") settings.World["WorldEditorSpawnInvincible"] = bool end)
	__options.bool["WorldEditorBlockFleeing"] = ui.add_bool_option(TRANSLATION["Block fleeing"], __submenus["WorldEditorSettings"], function(bool) HudSound("TOGGLE_ON") settings.World["WorldEditorBlockFleeing"] = bool end)
	__options.bool["WorldEditorSpawnFrozen"] = ui.add_bool_option(TRANSLATION["Spawn frozen in place"], __submenus["WorldEditorSettings"], function(bool) HudSound("TOGGLE_ON") settings.World["WorldEditorSpawnFrozen"] = bool end)

	local preview_obj = 1
	local preview_ped = 1
	local preview_veh = 1 
	local rot = vector3.zero()
	local function Spawn(model)
		CreateRemoveThread(true, 'spawn_object_'..thread_count, function()
			local loaded, ihash = features.request_model(model)
			if not ihash then return POP_THREAD end
			if loaded == 0 then return end
			local pos = CAM.DOES_CAM_EXIST(cam) == 1 and cam_pos or features.gameplay_cam_pos()
			local crot = CAM.DOES_CAM_EXIST(cam) == 1 and cam_rot or features.gameplay_cam_rot()
			local endCoords = pos + (crot:rot_to_direction() * 100)
			local result = features.get_raycast_result(pos, endCoords, created_preview2, -1)
			if result.didHit and settings.World["WorldEditorPlacementAssist"] then
				local dim = features.get_model_dimentions(ENTITY.GET_ENTITY_MODEL(created_preview2))
				pos = vector3(result.endCoords.x, result.endCoords.y, result.endCoords.z + abs(dim.z))
			else
				pos = pos + crot:rot_to_direction() * 10
			end
			local entity
			if STREAMING.IS_MODEL_A_PED(ihash) == 1 then
				entity = peds.create_ped(ihash, pos)
			elseif STREAMING.IS_MODEL_A_VEHICLE(ihash) == 1 then
				entity = vehicles.spawn_vehicle(ihash, pos)
				model = vehicles.get_label_name(model)
			else
				entity = features.create_object(ihash, pos)
			end
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ihash)
			if settings.World["WorldEditorSpawnInvincible"] then
				if ENTITY.IS_ENTITY_A_VEHICLE(entity) == 1 then
					vehicles.set_godmode(entity, true)
				else
					features.set_godmode(entity, true)
				end
			end
			ENTITY.FREEZE_ENTITY_POSITION(entity, true)
			if created_preview2 then
				ENTITY.SET_ENTITY_ROTATION(entity, rot.x, rot.y, rot.z, 2, true)
			end
			ENTITY.SET_ENTITY_COORDS(entity, pos.x, pos.y, pos.z, false, false, false, false)
			EntityDb.AddEntityToDatabase(entity)
			if settings.World["WorldEditorBlockFleeing"] then
				EntityDb.entity_data[entity].noflee = true
				peds.calm_ped(entity, true)
			end
			if settings.World["WorldEditorSpawnFrozen"] then
				EntityDb.entity_data[entity].freeze_position = true
			end
			return POP_THREAD
		end)
	end
	local step_val = {'0.0001','0.001', '0.01', '0.1', '1.0', '10.0', '100.0'}
	ui.add_input_string(TRANSLATION["Input model"], __submenus["WorldEditor"], function(text)
		if not text or text == '' then return HudSound("ERROR") end
		local text = text:lower()
		local data = cache:get("Input: "..text)
		if data then
			if data == 'none' then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Sorry I couldn't find any matching model"], 225, 0, 0, 225) return HudSound("ERROR") end
			Spawn(data)
			return
		end
		local hash = tonumber(text) and tonumber(text) or utils.joaat(text)
		if STREAMING.IS_MODEL_VALID(hash) == 1 then
			cache:set("Input: "..text, hash, 100000)
			Spawn(hash)
			return
		end
		for _, v in ipairs(vehicles.data)
		do
			if v.Name:find(text) or (v.DisplayName and v.DisplayName:lower():find(text)) or vehicles.get_label_name(v.Hash):lower():find(text) then
				hash = v.Hash
				break
			end
		end
		if STREAMING.IS_MODEL_VALID(hash) == 1 and STREAMING.IS_MODEL_A_VEHICLE(hash) == 1 then
			cache:set("Input: "..text, hash, 100000)
			Spawn(hash)
			return
		end
		for _, v in ipairs(peds.models)
		do
			local name = peds.GetPedName(v)
			if v:find(text) or (name and name:lower():find(text)) then
				cache:set("Input: "..text, v, 100000)
				Spawn(v)
				return
			end
		end
		cache:set("Input: "..text, 'none', 100000)
		system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Sorry I couldn't find any matching model"], 225, 0, 0, 225)
		HudSound("ERROR")
	end)

	__submenus["WorldPeds"] = ui.add_submenu(TRANSLATION["Spawn ped"])
	__suboptions["WorldPeds"] = ui.add_sub_option(TRANSLATION["Spawn ped"], __submenus["WorldEditor"] , __submenus["WorldPeds"])
	local ped_type = 1
	local selectedped = 0
	local curr_type
	local pedtypes = {
	    "Ambient female",
	    "Ambient male",
	    "Animals",
	    "Cutscene",
	    "Gang female",
	    "Gang male",
	    "Multiplayer",
	    "Scenario female",
	    "Scenario male",
	    "Story",
	    "Story scenario female",
	    "Story scenario male",
	    "Other",
	}	
	local sel_ped = ui.add_choose(TRANSLATION["Select type"], __submenus["WorldPeds"], true, pedtypes, function(int) HudSound("YES") ped_type = int + 1
		if curr_type then 
			ui.remove(curr_type)
			curr_type = nil
		end
	end)
	ui.set_value(sel_class, class, true)
	CreateRemoveThread(true, 'selected_ped_'..thread_count, function()
		if not curr_type then
			curr_type = ui.add_choose(TRANSLATION["Select ped"], __submenus["WorldPeds"], false, peds.get_table_names(peds.sorted[ped_type]), function(int) HudSound("YES") Spawn(peds.sorted[ped_type][int + 1]) end)
		end
	end)

	__submenus["WorldVehicles"] = ui.add_submenu(TRANSLATION["Spawn vehicle"])
	__suboptions["WorldVehicles"] = ui.add_sub_option(TRANSLATION["Spawn vehicle"], __submenus["WorldEditor"] , __submenus["WorldVehicles"])
	local class = 0
	local selected = 0
	local classes = {}
	local curr_class
	for i = 0, 61
	do
		insert(classes, enum.vehicle_class[i])
	end
	local sel_class = ui.add_choose(TRANSLATION["Select class"], __submenus["WorldVehicles"], true, classes, function(int) HudSound("YES") class = int
		if curr_class then 
			ui.remove(curr_class)
			curr_class = nil
		end
	end)
	ui.set_value(sel_class, class, true)
	CreateRemoveThread(true, 'selected_class_'..thread_count, function()
		if not curr_class then
			curr_class = ui.add_choose(TRANSLATION["Select vehicle"], __submenus["WorldVehicles"], false, settings.Vehicle["VehManufacturer"] and vehicles.class_manufacturer[class] or vehicles.class[class], function(int) HudSound("YES") Spawn(vehicles.models[vehicles.get_veh_index(int + 1, class)][2]) end)
		end
	end)

	__submenus["WorldObjects"] = ui.add_submenu(TRANSLATION["Spawn object"])
	__suboptions["WorldObjects"] = ui.add_sub_option(TRANSLATION["Spawn object"], __submenus["WorldEditor"] , __submenus["WorldObjects"])
	__options.choose["Objects"] = ui.add_choose(TRANSLATION["Objects"], __submenus["WorldObjects"], false, objects, function(int) HudSound("YES") Spawn(objects[int+1]) end)
	local object_results = {}
	__options.string["ObjectsSearch"] = ui.add_input_string(TRANSLATION["Search"], __submenus["WorldObjects"], function(text)
		local len = #object_results
		CreateRemoveThread(true, 'search_objects', function()
			local time = clock() + .01
			for i = 1, len
			do
				ui.remove(object_results[1])
				table_remove(object_results, 1)
				len = len - 1
				if time < clock() then return end
			end
			object_results = {}
			text = text:lower()
			if #text < 3 then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Please enter name with at least 3 characters"], 255, 0, 0, 255) HudSound("ERROR") return POP_THREAD end
			local count = 0
			for i, v in ipairs(objects)
			do
				if v:find(text) then
					object_results[i] = ui.add_click_option(v, __submenus["WorldObjects"], function() HudSound("SELECT") Spawn(v) end)
					count = i
					if count == 5000 then
						system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["You reached limit of 5000 results"], 255, 0, 0, 255, true)
						return POP_THREAD
					end
				end
			end
			if count == 0 then
				system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Sorry I couldn't find any matching model"], 255, 0, 0, 255)
				HudSound("ERROR")
			end
			return POP_THREAD
		end)
	end)

	ui.add_separator(TRANSLATION["Useful links"], __submenus["WorldEditor"])
	ui.add_click_option(TRANSLATION["Peds"]..' »', __submenus["WorldEditor"], function() HudSound("SELECT") filesystem.open('https://wiki.rage.mp/index.php?title=Peds') end)
	ui.add_click_option(TRANSLATION["Vehicles"]..' »', __submenus["WorldEditor"], function() HudSound("SELECT") filesystem.open('https://wiki.rage.mp/index.php?title=Vehicles') end)
	ui.add_click_option(TRANSLATION["Objects"]..' »', __submenus["WorldEditor"], function() HudSound("SELECT") filesystem.open('https://gta-objects.xyz/objects') end)

	local model_prev
	local current_sub = 0
	local function GetSubSpawn()
		if ui.is_sub_open(__submenus["WorldPeds"]) then
			return 1
		elseif ui.is_sub_open(__submenus["WorldVehicles"]) then
			return 2
		elseif ui.is_sub_open(__submenus["WorldObjects"]) then
			return 3
		else
			return 0
		end
	end

	CreateRemoveThread(true, 'world_editor_obj_spawner', function()
		local sub_open = GetSubSpawn()
		if sub_open == 0 then 
			if created_preview2 then
				features.delete_entity(created_preview2)
				created_preview2 = nil
				rot = vector3.zero()
			end
			current_sub = 0
			return
		end

		if (current_sub ~= sub_open and sub_open == 3) or (preview_obj ~= ui.get_value(__options.choose["Objects"]) + 1) then
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_prev)
			if created_preview2 then
				features.delete_entity(created_preview2)
				created_preview2 = nil
				rot = vector3.zero()
			end
			preview_obj = ui.get_value(__options.choose["Objects"]) + 1
			current_sub = 3
			model_prev = objects[preview_obj]
		elseif (current_sub ~= sub_open and sub_open == 2) or (curr_class and preview_veh ~= ui.get_value(curr_class) + 1) or selected ~= ui.get_value(sel_class) then
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_prev)
			if created_preview2 then
				features.delete_entity(created_preview2)
				created_preview2 = nil
				rot = vector3.zero()
			end
			preview_veh = ui.get_value(curr_class) + 1
			current_sub = 2
			selected = ui.get_value(sel_class)
			model_prev = vehicles.models[vehicles.get_veh_index(ui.get_value(curr_class) + 1, class)][2]
		elseif (current_sub ~= sub_open and sub_open == 1) or (curr_type and preview_ped ~= ui.get_value(curr_type) + 1) or selectedped ~= ui.get_value(sel_ped) then
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(model_prev)
			if created_preview2 then
				features.delete_entity(created_preview2)
				created_preview2 = nil
				rot = vector3.zero()
			end
			preview_ped = ui.get_value(curr_type) + 1
			current_sub = 1
			selectedped = ui.get_value(sel_ped)
			model_prev = peds.sorted[ped_type][ui.get_value(curr_type) + 1]
		end
		if not created_preview2 and model_prev then
			local loaded, hash = features.request_model(model_prev)
			if not hash or loaded == 0 then return end
			local pos = CAM.DOES_CAM_EXIST(cam) == 1 and cam_pos or features.gameplay_cam_pos()
			local rot = CAM.DOES_CAM_EXIST(cam) == 1 and cam_rot or features.gameplay_cam_rot()
			local dir = rot:rot_to_direction() * 10
			pos = pos + dir
			if STREAMING.IS_MODEL_A_PED(hash) == 1 then
				created_preview2 = peds.create_ped(hash, pos)
			elseif STREAMING.IS_MODEL_A_VEHICLE(hash) == 1 then
				created_preview2 = vehicles.spawn_vehicle(hash, pos)
			else
				created_preview2 = entities.create_object(hash, pos)
			end
			NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(created_preview2), false)
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
			ENTITY.FREEZE_ENTITY_POSITION(created_preview2, true)
			ENTITY.SET_ENTITY_COLLISION(created_preview2, false, false)
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(created_preview2, pos.x, pos.y, pos.z, false, false, false)
			ENTITY.SET_ENTITY_ROTATION(created_preview2, 0, 0, 0, 2, true)
			ENTITY.SET_ENTITY_ALPHA(created_preview2, 160, false)
			rot = vector3.zero()
		else
			if ENTITY.DOES_ENTITY_EXIST(created_preview2) == 0 then created_preview2 = nil return end
			peds.calm_ped(created_preview2, true)
			features.set_godmode(created_preview2, true)
			ENTITY.FREEZE_ENTITY_POSITION(created_preview2, true)
			local pos = CAM.DOES_CAM_EXIST(cam) == 1 and cam_pos or features.gameplay_cam_pos()
			local crot = CAM.DOES_CAM_EXIST(cam) == 1 and cam_rot or features.gameplay_cam_rot()
			local endCoords = pos + (crot:rot_to_direction() * 100)
			local result = features.get_raycast_result(pos, endCoords, created_preview2, -1)
			if result.didHit and settings.World["WorldEditorPlacementAssist"] then
				local dim = features.get_model_dimentions(ENTITY.GET_ENTITY_MODEL(created_preview2))
				pos = vector3(result.endCoords.x, result.endCoords.y, result.endCoords.z + abs(dim.z))
			else
				pos = pos + crot:rot_to_direction() * 10
			end
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(created_preview2, pos.x, pos.y, pos.z, false, false, false)
			features.draw_box_on_entity2(created_preview2, pos)
			ENTITY.SET_ENTITY_ALPHA(created_preview2, 160, false)
			ENTITY.SET_ENTITY_COLLISION(created_preview2, false, false)
			erot = features.get_entity_rot(created_preview2)
			PAD.DISABLE_CONTROL_ACTION(0, enum.input.VEH_SUB_ASCEND, true)
			PAD.DISABLE_CONTROL_ACTION(0, enum.input.CELLPHONE_UP, true)
			PAD.DISABLE_CONTROL_ACTION(0, enum.input.CELLPHONE_DOWN, true)
			PAD.DISABLE_CONTROL_ACTION(0, enum.input.VEH_LOOK_BEHIND, true)
			PAD.DISABLE_CONTROL_ACTION(0, enum.input.MULTIPLAYER_INFO, true)
			PAD.DISABLE_CONTROL_ACTION(0, enum.input.VEH_HORN, true)
			PAD.DISABLE_CONTROL_ACTION(0, enum.input.VEH_RADIO_WHEEL, true)
			local model = ENTITY.GET_ENTITY_MODEL(created_preview2)
			if STREAMING.IS_MODEL_A_VEHICLE(model) == 1 then
				local max = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(model) - 2
			    for i = -1, max do
			    	local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(created_preview2, i, true)
			    	if ped ~= 0 then
			    		TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
			    	end
			    end
			end
			local mult = 1
			if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_SUB_ASCEND) == 1 then
				mult = 10
	    	end
			if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.CELLPHONE_UP) == 1 then
				erot = erot + vector3.right() / mult
			end
			if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.CELLPHONE_DOWN) == 1 then
				erot = erot + vector3.left() / mult
			end
			if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_LOOK_BEHIND) == 1 then
				erot = erot + vector3.forward() / mult
			end
			if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.MULTIPLAYER_INFO) == 1 then
				erot = erot + vector3.back() / mult
			end
			if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_HORN) == 1 then
				erot = erot + vector3.up() / mult
			end
			if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_RADIO_WHEEL) == 1 then
				erot = erot + vector3.down() / mult
			end
			rot = erot
			ENTITY.SET_ENTITY_ROTATION(created_preview2, erot.x, erot.y, erot.z, 2, true)
			if settings.General["ShowControls"] and Instructional:New() then
				Instructional.AddButton(enum.input.VEH_SUB_ASCEND, TRANSLATION["Precision"])
		    	Instructional.AddButton(enum.input.CELLPHONE_UP, "")
		    	Instructional.AddButton(enum.input.CELLPHONE_DOWN, TRANSLATION["Pitch"])
		    	Instructional.AddButton(enum.input.VEH_LOOK_BEHIND, "")
		    	Instructional.AddButton(enum.input.MULTIPLAYER_INFO, TRANSLATION["Roll"])
		    	Instructional.AddButton(enum.input.VEH_HORN, "")
		    	Instructional.AddButton(enum.input.VEH_RADIO_WHEEL, TRANSLATION["Yaw"])
		    	Instructional:BackgroundColor(0, 0, 0, 80)
		    	Instructional:Draw()
		    end
		end
	end)
	local attachment_entities = {}
	local function RemoveAttachmentOptions()
		for _, v in pairs(attachment_entities)
		do
			ui.remove(v)
		end
		attachment_entities = {}
	end
	local function ChangeAttachParams(entity)
		if ENTITY.IS_ENTITY_ATTACHED(entity) == 0 or EntityDb.entity_data[entity].valid == 0 then return end
		local attachment = ENTITY.GET_ENTITY_ATTACHED_TO(entity)
		local tabl = EntityDb.spawned_options[entity]
		EntityDb.entity_data[entity].attach_bone = ui.get_value(tabl.attach_bone)
		EntityDb.entity_data[entity].attachx = ui.get_value(tabl.attachx)
		EntityDb.entity_data[entity].attachy = ui.get_value(tabl.attachy)
		EntityDb.entity_data[entity].attachz = ui.get_value(tabl.attachz)
		EntityDb.entity_data[entity].pitch = ui.get_value(tabl.pitch)
		EntityDb.entity_data[entity].roll = ui.get_value(tabl.roll)
		EntityDb.entity_data[entity].yaw = ui.get_value(tabl.yaw)
		entities.request_control(entity, function()
			ENTITY.ATTACH_ENTITY_TO_ENTITY(entity, attachment, ui.get_value(tabl.attach_bone),
				ui.get_value(tabl.attachx), ui.get_value(tabl.attachy), ui.get_value(tabl.attachz),
				ui.get_value(tabl.pitch), ui.get_value(tabl.roll), ui.get_value(tabl.yaw),
				false, true, EntityDb.entity_data[entity].collision, EntityDb.entity_data[entity].type == 1, 2, true
			)
		end)
	end

	local classes = {}
	for i = 0, 61
	do
		insert(classes, enum.vehicle_class[i])
	end

	local function change_sound(v, veh, class, parent)
		if v.valid == 0 then return HudSound("ERROR") end
		HudSound("YES")
		local model = vehicles.models[vehicles.get_veh_index(ui.get_value(parent.curr_class) + 1, class)][1]
		AUDIO._FORCE_VEHICLE_ENGINE_AUDIO(veh, model)
		v.engine_sound = model
	end

	local function AddMenuPed(ped, sub, parent, v)
		parent.block_flee = ui.add_bool_option(TRANSLATION["Block fleeing"], sub, function(bool)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("TOGGLE_ON")
			peds.calm_ped(ped, bool)
			v.noflee = bool
		end)
		parent.can_ragdoll = ui.add_bool_option(TRANSLATION["Can ragdoll"], sub, function(bool)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("TOGGLE_ON")
			entities.request_control(ped, function()
				PED.SET_PED_CAN_RAGDOLL(ped, bool)
				PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT(ped, bool)
			end)
		end)
		parent.is_tiny = ui.add_bool_option(TRANSLATION["Tiny"], sub, function(bool)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("TOGGLE_ON")
			entities.request_control(ped, function()
				PED.SET_PED_CONFIG_FLAG(ped, 223, bool)
			end)
		end)
		parent.ped_health = ui.add_num_option(TRANSLATION["Health"], sub, 0, PED.GET_PED_MAX_HEALTH(ped), 1, function(int)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("YES")
			entities.request_control(ped, function()
				ENTITY.SET_ENTITY_HEALTH(ped, int, 0)
			end)
		end)
		parent.ped_armor = ui.add_num_option(TRANSLATION["Armour"], sub, 0, 100, 1, function(int)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("YES")
			entities.request_control(ped, function()
				PED.SET_PED_ARMOUR(ped, int)
			end)
		end)
		parent.weapons_choose = ui.add_choose(TRANSLATION["Give weapon"], sub, false, weapons.names, function(int)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("YES")
			if WEAPON.HAS_PED_GOT_WEAPON(ped, weapons.hashes[int+1], false) == 0 then
				WEAPON.GIVE_WEAPON_TO_PED(ped, weapons.hashes[int+1], 9999, false, true)
			end
			WEAPON.SET_CURRENT_PED_WEAPON(ped, weapons.hashes[int+1], true)
		end)
		parent.wardobe_sub = ui.add_submenu(TRANSLATION["Wardrobe"])
		parent.wardobe_subopt = ui.add_sub_option(TRANSLATION["Wardrobe"], sub, parent.wardobe_sub)
		parent.wardobe_default = ui.add_click_option(TRANSLATION["Default"], parent.wardobe_sub, function()
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("SELECT")
			entities.request_control(ped, function()
				PED.SET_PED_DEFAULT_COMPONENT_VARIATION(ped)
				PED.CLEAR_ALL_PED_PROPS(ped)
			end)
		end)
		parent.wardobe_random = ui.add_click_option(TRANSLATION["Random"], parent.wardobe_sub, function()
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("SELECT")
			entities.request_control(ped, function()
				PED.SET_PED_RANDOM_COMPONENT_VARIATION(ped, 0)
				PED.SET_PED_RANDOM_PROPS(ped)
			end)
		end)
		EntityDb.entity_data[ped].drawables = {}
		local drawables_names = {}
		for i = 0, 11 do
			if PED.GET_NUMBER_OF_PED_DRAWABLE_VARIATIONS(ped, i) ~= 0 then
				insert(EntityDb.entity_data[ped].drawables, i)
				insert(drawables_names, TRANSLATION[enum.drawables[i+1]])
			end
		end
		parent.component_choose = ui.add_choose(TRANSLATION["Component"], parent.wardobe_sub, true, drawables_names, function(int)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("YES")
			ui.set_num_max(parent.component_id, PED.GET_NUMBER_OF_PED_DRAWABLE_VARIATIONS(ped, EntityDb.entity_data[ped].drawables[int+1]) - 1)
		end)
		parent.component_id = ui.add_num_option(TRANSLATION["Variation"], parent.wardobe_sub, 0, 0, 1, function(int)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("YES")
			entities.request_control(ped, function()
				local id = EntityDb.entity_data[ped].drawables[ui.get_value(parent.component_choose)+1]
				if PED.IS_PED_COMPONENT_VARIATION_VALID(ped, id, int, 0) == 0 then return end
				PED.SET_PED_COMPONENT_VARIATION(ped, id, int, 0, 0)
			end)
		end)
		parent.texture_id = ui.add_num_option(TRANSLATION["Texture"], parent.wardobe_sub, 0, 0, 1, function(int)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("YES")
			entities.request_control(ped, function()
				local id = EntityDb.entity_data[ped].drawables[ui.get_value(parent.component_choose)+1]
				local drawable = PED.GET_PED_DRAWABLE_VARIATION(ped, id)
				if PED.IS_PED_COMPONENT_VARIATION_VALID(ped, id, drawable, int) == 0 then return end
				PED.SET_PED_COMPONENT_VARIATION(ped, id, drawable, int, 0)
			end)
		end)

		EntityDb.entity_data[ped].props = {}
		local props_names = {}
		for i = 0, 9 do
			if PED.GET_NUMBER_OF_PED_PROP_DRAWABLE_VARIATIONS(ped, i) ~= 0 then
				insert(EntityDb.entity_data[ped].props, i)
				insert(props_names, TRANSLATION[enum.props[i+1]] or enum.props[i+1])
			end
		end
		if #props_names ~= 0 then
			parent.prop_choose = ui.add_choose(TRANSLATION["Prop"], parent.wardobe_sub, true, props_names, function(int)
				if v.valid == 0 then return HudSound("ERROR") end
				HudSound("YES")
				ui.set_num_max(parent.prop_id, PED.GET_NUMBER_OF_PED_PROP_DRAWABLE_VARIATIONS(ped, EntityDb.entity_data[ped].props[int+1]) - 1)
			end)
			parent.prop_id = ui.add_num_option(TRANSLATION["Variation"], parent.wardobe_sub, -1, 0, 1, function(int)
				if v.valid == 0 then return HudSound("ERROR") end
				HudSound("YES")
				entities.request_control(ped, function()
					local id = EntityDb.entity_data[ped].props[ui.get_value(parent.prop_choose)+1]
					if int == - 1 then
						PED.CLEAR_PED_PROP(ped, id)
					else
						PED.SET_PED_PROP_INDEX(ped, id, int, 0, true)
					end
				end)
			end)
			parent.proptexture_id = ui.add_num_option(TRANSLATION["Texture"], parent.wardobe_sub, 0, 0, 1, function(int)
				if v.valid == 0 then return HudSound("ERROR") end
				HudSound("YES")
				entities.request_control(ped, function()
					local id = EntityDb.entity_data[ped].props[ui.get_value(parent.prop_choose)+1]
					local prop = PED.GET_PED_PROP_INDEX(ped, id)
					if prop == -1 then return end
					PED.SET_PED_COMPONENT_VARIATION(ped, id, prop, int, true)
				end)
			end)
		end
	end

	local function AddMenuVehicle(veh, sub, parent, v)
		vehicles.tuning_menu(veh, sub, parent)

		parent.repair = ui.add_click_option(TRANSLATION["Repair vehicle"], sub, function()
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("SELECT")
			entities.request_control(veh, function()
				vehicles.repair(veh)
			end)
		end)
		parent.change_sound_sub = ui.add_submenu(TRANSLATION["Change sound"])
		parent.change_sound_subopt = ui.add_sub_option(TRANSLATION["Change sound"], sub, parent.change_sound_sub)
		local selected_vehicle = 1
		local class = 0
		parent.sel_class = ui.add_choose(TRANSLATION["Select class"], parent.change_sound_sub, true, classes, function(int) class = int
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("YES")
			if parent.curr_class then 
				ui.remove(parent.curr_class)
				parent.curr_class = nil
			end
		end)
		ui.set_value(parent.sel_class, class, true)
		CreateRemoveThread(true, 'selected_class_'..thread_count, function()
			if v.valid == 0 then return POP_THREAD end
			if not ui.is_sub_open(parent.change_sound_sub) or parent.curr_class then return end
			parent.curr_class = ui.add_choose(TRANSLATION["Select vehicle"], parent.change_sound_sub, false, settings.Vehicle["VehManufacturer"] and vehicles.class_manufacturer[class] or vehicles.class[class], function(int) selected_vehicle = int + 1;change_sound(v, veh, class, parent) end)
		end)

		parent.door_control_sub = ui.add_submenu(HUD._GET_LABEL_TEXT("PIM_TDPV"))
		parent.door_control_subopt = ui.add_sub_option(HUD._GET_LABEL_TEXT("PIM_TDPV"), sub, parent.door_control_sub)
		parent.doorsepar = ui.add_separator(TRANSLATION["Open/close"], parent.door_control_sub)
		parent.door_open = ui.add_click_option(TRANSLATION["Open all"], parent.door_control_sub, function()
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("SELECT")
			for i = 0, 5
			do
				entities.request_control(veh, function()
					VEHICLE.SET_VEHICLE_DOOR_OPEN(veh, i, false, false)
				end)
			end
		end)
		parent.door_close = ui.add_click_option(TRANSLATION["Close all"], parent.door_control_sub, function()
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("SELECT")
			for i = 0, 5
			do
				entities.request_control(veh, function()
					VEHICLE.SET_VEHICLE_DOOR_SHUT(veh, i, false)
				end)
			end
		end)
		for i, e in ipairs(vehicles.door_index())
		do
			parent['door_'..i] = ui.add_click_option(e, parent.door_control_sub, function()
				if v.valid == 0 then return HudSound("ERROR") end
				HudSound("SELECT")
				entities.request_control(veh, function()
					if VEHICLE.GET_VEHICLE_DOOR_ANGLE_RATIO(veh, i) == 0 then
						VEHICLE.SET_VEHICLE_DOOR_OPEN(veh, i, false, false)
					else
						VEHICLE.SET_VEHICLE_DOOR_SHUT(veh, i, false)
					end
				end)
			end)
		end
		parent.doorsepar_break = ui.add_separator(TRANSLATION["Break"], parent.door_control_sub)
		parent.door_break = ui.add_click_option(TRANSLATION["Break all"], parent.door_control_sub, function()
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("SELECT")
			for i = 0, 5
			do
				entities.request_control(veh, function()
					VEHICLE._SET_VEHICLE_DOOR_CAN_BREAK(veh, i, true)
					VEHICLE.SET_VEHICLE_DOOR_BROKEN(veh, i, false)
				end)
			end
		end)
		parent.pop_tire = ui.add_choose(TRANSLATION["Pop tires"], sub, false, {TRANSLATION["All"], TRANSLATION["Front left"], TRANSLATION["Front right"], "2", "3", TRANSLATION["Rear left"], TRANSLATION["Rear right"], "45", "47"}, function(int)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("YES")
			entities.request_control(veh, function()
				VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh, true)
				if int == 0 then
					for i = 0, 5
					do
						VEHICLE.SET_VEHICLE_TYRE_BURST(veh, i, true, 1000)
					end
					VEHICLE.SET_VEHICLE_TYRE_BURST(veh, 45, true, 1000)
					VEHICLE.SET_VEHICLE_TYRE_BURST(veh, 47, true, 1000)
				elseif int < 7 then
					VEHICLE.SET_VEHICLE_TYRE_BURST(veh, int - 1, true, 1000)
				elseif int == 7 then
					VEHICLE.SET_VEHICLE_TYRE_BURST(veh, 45, true, 1000)
				elseif int == 8 then
					VEHICLE.SET_VEHICLE_TYRE_BURST(veh, 47, true, 1000)
				end
			end)
		end)
		for i, e in ipairs(vehicles.door_index())
		do
			parent["break_"..i] = ui.add_click_option(e, parent.door_control_sub, function()
				if v.valid == 0 then return HudSound("ERROR") end
				HudSound("SELECT")
				entities.request_control(veh, function()
					VEHICLE._SET_VEHICLE_DOOR_CAN_BREAK(veh, i, true)
					VEHICLE.SET_VEHICLE_DOOR_BROKEN(veh, i, false)
				end)
			end)
		end
		parent.light_mult = ui.add_float_option(TRANSLATION["Lights intensity"], sub, 0, 1, .1, 1, function(float)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("YES")
			entities.request_control(veh, function()
				VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(veh, float)
			end)
		end)
		parent.paint_fade = ui.add_float_option(TRANSLATION["Paint fade"], sub, 0, 1, .1, 1, function(float)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("YES")
			entities.request_control(veh, function()
				VEHICLE.SET_VEHICLE_ENVEFF_SCALE(veh, float)
			end)
		end)
		parent.dirt_level = ui.add_float_option(TRANSLATION["Dirt level"], sub, 0, 15, .1, 1, function(float)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("YES")
			entities.request_control(veh, function()
				VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, float)
			end)
		end)
		parent.engine_on = ui.add_bool_option(TRANSLATION["Engine on"], sub, function(bool)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("TOGGLE_ON")
			entities.request_control(veh, function()
				VEHICLE.SET_VEHICLE_ENGINE_ON(veh, bool, true, false)
			end)
		end)
		parent.lock_vehicle = ui.add_bool_option(TRANSLATION["Lock vehicle"], sub, function(bool)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("TOGGLE_ON")
			entities.request_control(veh, function()
				if bool then
					VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 6)
				 	VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 2)
				else
				 	VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 1)
				end
			end)
		end)
		parent.child_locks = ui.add_bool_option(TRANSLATION["Child locks"], sub, function(bool)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("TOGGLE_ON")
			entities.request_control(veh, function()
				if bool then
					VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 6)
				 	VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 4)
				else
				 	VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 1)
				end
			end)
		end)
		parent.siren = ui.add_bool_option(TRANSLATION["Siren"], sub, function(bool)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("TOGGLE_ON")
			entities.request_control(veh, function()
				VEHICLE.SET_VEHICLE_SIREN(veh, bool)
			end)
		end)
		parent.render_scorched = ui.add_bool_option(TRANSLATION["Scorched vehicle"], sub, function(bool)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("TOGGLE_ON")
			entities.request_control(veh, function()
				ENTITY.SET_ENTITY_RENDER_SCORCHED(veh, bool)
			end)
		end)
		parent.reduce_grip = ui.add_bool_option(TRANSLATION["Reduce grip"], sub, function(bool)
			if v.valid == 0 then return HudSound("ERROR") end
			HudSound("TOGGLE_ON")
			entities.request_control(veh, function()
				VEHICLE.SET_VEHICLE_REDUCE_GRIP(veh, bool)
			end)
		end)
	end


	CreateRemoveThread(true, 'world_editor_spawned_entities', function(tick)
		for k, v in pairs(EntityDb.entity_data)
		do
			if v.valid ~= 0 then
				v.valid = ENTITY.DOES_ENTITY_EXIST(k)
				if (ui.is_open() and EntityDb.spawned_options[k] and ui.is_sub_open(EntityDb.spawned_options[k].submenu) and v.valid ~= 0) or not v.pos then
					v.pos = features.get_entity_coords(k)
					v.rot = features.get_entity_rot(k)
					v.god = features.get_godmode(k)
					v.alpha = ENTITY.GET_ENTITY_ALPHA(k)
					v.lod_dist = ENTITY.GET_ENTITY_LOD_DIST(k)
					v.collision = ENTITY.GET_ENTITY_COLLISION_DISABLED(k) == 0
					v.visible = ENTITY.IS_ENTITY_VISIBLE(k) == 1
					v.is_attached = ENTITY.IS_ENTITY_ATTACHED(k) == 1
					local attpos = vector3.zero()
					local pitch, roll, yaw = vector3.zero():get()
					if v.is_attached and not v.attach_bone then
						local offset = vector3(ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(k, 0, 0, VEHICLE._GET_VEHICLE_SUSPENSION_HEIGHT(k) ~= -1 and VEHICLE._GET_VEHICLE_SUSPENSION_HEIGHT(k) or 0))
			            local offpos1 = vector3(ENTITY.GET_OFFSET_FROM_ENTITY_GIVEN_WORLD_COORDS(k, offset.x, offset.y, offset.z))
			            local offset = vector3(ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ENTITY.GET_ENTITY_ATTACHED_TO(k), 0, 0, VEHICLE._GET_VEHICLE_SUSPENSION_HEIGHT(ENTITY.GET_ENTITY_ATTACHED_TO(k)) ~= -1 and VEHICLE._GET_VEHICLE_SUSPENSION_HEIGHT(ENTITY.GET_ENTITY_ATTACHED_TO(k)) or 0))
			            local offpos2 = vector3(ENTITY.GET_OFFSET_FROM_ENTITY_GIVEN_WORLD_COORDS(ENTITY.GET_ENTITY_ATTACHED_TO(k), offset.x, offset.y, offset.z))
			            local pos = features.get_entity_coords(k) + offpos1 + offpos2
			          	attpos.x = ENTITY.GET_OFFSET_FROM_ENTITY_GIVEN_WORLD_COORDS(ENTITY.GET_ENTITY_ATTACHED_TO(k), pos.x, pos.y, pos.z).x
	                    attpos.y = ENTITY.GET_OFFSET_FROM_ENTITY_GIVEN_WORLD_COORDS(ENTITY.GET_ENTITY_ATTACHED_TO(k), pos.x, pos.y, pos.z).y
	                    attpos.z = ENTITY.GET_OFFSET_FROM_ENTITY_GIVEN_WORLD_COORDS(ENTITY.GET_ENTITY_ATTACHED_TO(k), pos.x, pos.y, pos.z).z
			            local rot1 = features.get_entity_rot(ENTITY.GET_ENTITY_ATTACHED_TO(k))
			            local rot2 = features.get_entity_rot(k)
			            pitch, roll, yaw = (rot2 - rot1):get()
					end
					v.attach_bone = (v.is_attached and not v.attach_bone) and 0 or v.attach_bone
					v.attachx = (v.is_attached and not v.attachx) and attpos.x or v.attachx
					v.attachy = (v.is_attached and not v.attachy) and attpos.y or v.attachy
					v.attachz = (v.is_attached and not v.attachz) and attpos.z or v.attachz
					v.attachpitch = (v.is_attached and not v.attachpitch) and pitch or v.attachpitch
					v.attachroll = (v.is_attached and not v.attachroll) and roll or v.attachroll
					v.attachyaw = (v.is_attached and not v.attachyaw) and yaw or v.attachyaw
					v.noflee = v.noflee ~= nil and v.noflee or false
					if v.type == 3 then
						v.texture = OBJECT._GET_OBJECT_TEXTURE_VARIATION(k)
					end
				end
			end
			if not EntityDb.spawned_options[k] then
				local update_attachment = function() HudSound("YES") ChangeAttachParams(k) end
				local sub = ui.add_submenu(v.name)
				local sub_attach = ui.add_submenu(TRANSLATION["Attach to something"])
				local sub_attached = ui.add_submenu(TRANSLATION["Attachment options"])
				local ped_properties = ui.add_submenu(TRANSLATION["Ped properties"])
				local vehicle_properties = ui.add_submenu(TRANSLATION["Vehicle properties"])
				EntityDb.spawned_options[k] = {
					submenu = sub,
					sub_option = ui.add_sub_option(v.name, __submenus["WorldEditorSpawned"], sub),
					step = ui.add_choose(TRANSLATION["Step"], sub, true, step_val, function(type)
						HudSound("YES")
						local value = tonumber(step_val[type + 1])
						ui.set_step(EntityDb.spawned_options[k].posx, value)
						ui.set_step(EntityDb.spawned_options[k].posy, value)
						ui.set_step(EntityDb.spawned_options[k].posz, value)
						ui.set_step(EntityDb.spawned_options[k].rotx, value)
						ui.set_step(EntityDb.spawned_options[k].roty, value)
						ui.set_step(EntityDb.spawned_options[k].rotz, value)
					end),
					separator_pos = ui.add_separator(TRANSLATION["Position"], sub),
					posx = ui.add_float_option("X", sub, -10000, 10000, .1, 4, function(float)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("YES")
						entities.request_control(k, function()
							local pos = features.get_entity_coords(k)
							ENTITY.SET_ENTITY_COORDS_NO_OFFSET(k, float, pos.y, pos.z, false, false, false)
						end)
					end),
					posy = ui.add_float_option("Y", sub, -10000, 10000, .1, 4, function(float)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("YES")
						entities.request_control(k, function()
							local pos = features.get_entity_coords(k)
							ENTITY.SET_ENTITY_COORDS_NO_OFFSET(k, pos.x, float, pos.z, false, false, false)
						end)
					end),
					posz = ui.add_float_option("Z", sub, -10000, 10000, .1, 4, function(float)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("YES")
						entities.request_control(k, function()
							local pos = features.get_entity_coords(k)
							ENTITY.SET_ENTITY_COORDS_NO_OFFSET(k, pos.x, pos.y, float, false, false, false)
						end)
					end),
					separator_rot = ui.add_separator(TRANSLATION["Rotation"], sub),
					rotx = ui.add_float_option(TRANSLATION["Pitch"], sub, -90, 90, .1, 4, function(float)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("YES")
						entities.request_control(k, function()
							local rot = features.get_entity_rot(k)
							ENTITY.SET_ENTITY_ROTATION(k, float, rot.y, rot.z, 2, true)
						end)
					end),
					roty = ui.add_float_option(TRANSLATION["Roll"], sub, -180, 180, .1, 4, function(float)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("YES")
						entities.request_control(k, function()
							local rot = features.get_entity_rot(k)
							ENTITY.SET_ENTITY_ROTATION(k, rot.x, float, rot.z, 2, true)
						end)
					end),
					rotz = ui.add_float_option(TRANSLATION["Yaw"], sub, -180, 180, .1, 4, function(float)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("YES")
						entities.request_control(k, function()
							local rot = features.get_entity_rot(k)
							ENTITY.SET_ENTITY_ROTATION(k, rot.x, rot.y, float, 2, true)
						end)
					end),
					reset_rot = ui.add_click_option(TRANSLATION["Reset rotation"], sub, function()
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("SELECT")
						entities.request_control(k, function()
							ENTITY.SET_ENTITY_ROTATION(k, 0, 0, 0, 2, true)
						end)
					end),
					separator_other = ui.add_separator(TRANSLATION["Other"], sub),
					godmode = ui.add_bool_option(TRANSLATION["Set entity godmode"], sub, function(bool)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("TOGGLE_ON")
						entities.request_control(k, function()
							if ENTITY.IS_ENTITY_A_VEHICLE(k) == 1 then
								vehicles.set_godmode(k, bool)
							else
								features.set_godmode(k, bool)
							end
						end)
					end),
					freeze_position = ui.add_bool_option(TRANSLATION["Freeze entity position"], sub, function(bool)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("TOGGLE_ON")
						if not bool then
							entities.request_control(k, function()
								ENTITY.FREEZE_ENTITY_POSITION(k, false)
							end)
						end
						CreateRemoveThread(bool, 'freeze_position_'..k, function()
							if v.valid == 0 then return POP_THREAD end
							entities.request_control(k, function()
								ENTITY.FREEZE_ENTITY_POSITION(k, true)
							end)
						end)
					end),
					has_gravity = ui.add_bool_option(TRANSLATION["Gravity"], sub, function(bool)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("TOGGLE_ON")
						entities.request_control(k, function()
							ENTITY.SET_ENTITY_HAS_GRAVITY(k, bool)
						end)
						v.gravity = bool
					end),
					dynamic = ui.add_bool_option(TRANSLATION["Dynamic"], sub, function(bool)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("TOGGLE_ON")
						entities.request_control(k, function()
							ENTITY.SET_ENTITY_DYNAMIC(k, bool)
							if bool then
								features.set_entity_velocity(k, 0, 0, 0)
							end
						end)
					end),
					collision = ui.add_bool_option(TRANSLATION["Collision"], sub, function(bool)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("TOGGLE_ON")
						entities.request_control(k, function()
							ENTITY.SET_ENTITY_COLLISION(k, bool, true)
						end)
					end),
					visible = ui.add_bool_option(TRANSLATION["Visible"], sub, function(bool)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("TOGGLE_ON")
						entities.request_control(k, function()
							ENTITY.SET_ENTITY_VISIBLE(k, bool, false)
						end)
					end),
					alpha = ui.add_num_option(TRANSLATION["Alpha (local)"], sub, 0, 255, 1, function(int)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("YES")
						entities.request_control(k, function()
							ENTITY.SET_ENTITY_ALPHA(k, int, false)
							if int == 255 then
								ENTITY.RESET_ENTITY_ALPHA(k)
							end
						end)
					end),
					lod_dist = ui.add_num_option(TRANSLATION["Lod distance"], sub, 0, 0xffff, 1, function(int)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("YES")
						entities.request_control(k, function()
							ENTITY.SET_ENTITY_LOD_DIST(k, int)
						end)
					end),
					place_on_ground = ui.add_click_option(TRANSLATION["Place on ground"], sub, function()
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("SELECT")
						local pos = features.get_entity_coords(k)
						local success, z = features.get_ground_z(pos)
						if not success then return end
						local min = features.get_model_dimentions(ENTITY.GET_ENTITY_MODEL(k))
						entities.request_control(k, function()
							ENTITY.SET_ENTITY_COORDS_NO_OFFSET(k, pos.x, pos.y, z + abs(min.z), false, false, false)
							if v.type == 2 then
								VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(k, v)
							end
						end)
					end),
					tp_to = ui.add_click_option(TRANSLATION["Teleport to entity"], sub, function()
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("SELECT")
						local pos = v.pos
						if CAM.DOES_CAM_EXIST(cam) ~= 0 then
							CAM.SET_CAM_COORD(cam, pos.x, pos.y, pos.z)
							wait = clock() + 0.1
						else
							features.teleport(features.player_ped(), pos.x, pos.y, pos.z)
						end
					end),
					tp_toself = ui.add_click_option(TRANSLATION["Teleport to self"], sub, function()
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("SELECT")
						entities.request_control(k, function()
							local pos
							if CAM.DOES_CAM_EXIST(cam) ~= 0 then
								pos = CAM.GET_CAM_COORD(cam)
							else
								pos = features.get_player_coords()
							end
							ENTITY.SET_ENTITY_COORDS_NO_OFFSET(k, pos.x, pos.y, pos.z, false, false, false)
						end)
					end),
					sub_ped_prop = ped_properties,
					subopt_ped_prop = ui.add_sub_option(TRANSLATION["Ped properties"], sub, ped_properties),
					sub_veh_prop = vehicle_properties,
					subopt_veh_prop = ui.add_sub_option(TRANSLATION["Vehicle properties"], sub, vehicle_properties),
					sub_attach = sub_attach,
					sub_attached = sub_attached,
					subopt_attach = ui.add_sub_option(TRANSLATION["Attach to something"], sub, sub_attach),
					attachto = ui.add_click_option(TRANSLATION["Attach"], sub_attach, function()
						if v.valid == 0 then return HudSound("ERROR") end
						ticks['world_editor_attach'] = nil
						RemoveAttachmentOptions()
						CreateRemoveThread(true, 'world_editor_attach', function(tick)
							local _entities = 0
							for _ in pairs(EntityDb.entity_data)
							do
								_entities = _entities + 1
								if _entities > 1 then break end
							end

							if _entities < 2 then
								system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["No entities to attach"], 255, 0, 0, 255)
								RemoveAttachmentOptions()
								if tick == 0 then HudSound("ERROR") end
								return POP_THREAD
							end
							features.draw_box_on_entity(k, 255, 128, 0)
							if tick == 0 then
								HudSound("SELECT")
								attachment_entities[0] = ui.add_separator(TRANSLATION["Entities"], sub_attach)
								for i, e in pairs(EntityDb.entity_data)
								do
									if e.valid == 1 and k ~= i then
										attachment_entities[i] = ui.add_choose(format(e.name..' (%i)', i), sub_attach, false, {TRANSLATION["Attach"], TRANSLATION["Highlight"]}, function(int)
											HudSound("YES")
											if int == 0 then
												if e.valid == 1 and v.valid == 1 then
													entities.request_control(k, function()
														if ENTITY.IS_ENTITY_ATTACHED(k) == 1 then
															ENTITY.DETACH_ENTITY(k, ui.get_value(EntityDb.spawned_options[k].dynamic), v.collision)
														end
														local tabl = EntityDb.spawned_options[k]
														ENTITY.ATTACH_ENTITY_TO_ENTITY(k, i, 0,
															0, 0, 0,
															0, 0, 0,
															false, true, v.collision, v.type == 1, 2, true
														)
													end)
												end
												RemoveAttachmentOptions()
												CreateRemoveThread(false, 'world_editor_attach')
											else
												CreateRemoveThread(true, 'highlight_entity_'..thread_count, function(tick)
													features.draw_box_on_entity(i, 0, 255, 0, 255)
													if tick == 30 then return POP_THREAD end
												end)
											end
										end)
									end
								end
							end
						end)
					end),
					attached_opt = ui.add_sub_option(TRANSLATION["Attachment options"], sub, sub_attached),
					attachstep = ui.add_choose(TRANSLATION["Step"], sub_attached, true, step_val, function(type)
						HudSound("YES")
						local value = tonumber(step_val[type + 1])
						ui.set_step(EntityDb.spawned_options[k].attachx, value)
						ui.set_step(EntityDb.spawned_options[k].attachy, value)
						ui.set_step(EntityDb.spawned_options[k].attachz, value)
						ui.set_step(EntityDb.spawned_options[k].pitch, value)
						ui.set_step(EntityDb.spawned_options[k].roll, value)
						ui.set_step(EntityDb.spawned_options[k].yaw, value)
					end),
					attachx = ui.add_float_option(TRANSLATION["Offset x"], sub_attached, -10000, 10000, .1, 4, update_attachment),
					attachy = ui.add_float_option(TRANSLATION["Offset y"], sub_attached, -10000, 10000, .1, 4, update_attachment),
					attachz = ui.add_float_option(TRANSLATION["Offset z"], sub_attached, -10000, 10000, .1, 4, update_attachment),
					pitch = ui.add_float_option(TRANSLATION["Pitch"], sub_attached, -10000, 10000, .1, 4, update_attachment),
					roll = ui.add_float_option(TRANSLATION["Roll"], sub_attached, -10000, 10000, .1, 4, update_attachment),
					yaw = ui.add_float_option(TRANSLATION["Yaw"], sub_attached, -10000, 10000, .1, 4, update_attachment),
					attach_bone = ui.add_num_option(TRANSLATION["Bone"], sub_attached, 0, 100, 1,  update_attachment),
					detach = ui.add_click_option(TRANSLATION["Detach"], sub_attached, function()
						HudSound("SELECT")
						entities.request_control(k, function()
							for _, attachment in pairs(features.get_all_attachments(k))
							do
								entities.request_control(attachment, function()
									ENTITY.DETACH_ENTITY(attachment, true, true)
								end)
							end
							entities.request_control(k, function()
								ENTITY.DETACH_ENTITY(k, ui.get_value(EntityDb.spawned_options[k].dynamic), v.collision)
							end)
						end)
					end),
					copy = ui.add_choose(TRANSLATION["Copy"], sub, false, {TRANSLATION["Only entity"], TRANSLATION["With attachments"]}, function(int)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("YES")
						world_spawner.copy_entity(k, int == 1)
					end),
					delete = ui.add_click_option(TRANSLATION["Delete"], sub, function()
						HudSound("SELECT")
						if tick < 10 then return end
						if v.type == 2 and vehicles.get_player_vehicle() ~= 0 and k == vehicles.get_player_vehicle() then
							TASK.CLEAR_PED_TASKS_IMMEDIATELY(features.player_ped())
						end
						features.delete_entity(k)
						for _, v in pairs(EntityDb.spawned_options[k])
						do
							ui.remove(v)
						end
						EntityDb.spawned_options[k] = nil
						EntityDb.entity_data[k] = nil
						EntityDb.RemoveInvalidEntities()
					end),
					remove = ui.add_click_option(TRANSLATION["Remove from db"], sub, function()
						HudSound("SELECT")
						if tick < 10 then return end
						for _, v in pairs(EntityDb.spawned_options[k])
						do
							ui.remove(v)
						end
						EntityDb.spawned_options[k] = nil
						EntityDb.entity_data[k] = nil
						EntityDb.RemoveInvalidEntities()
					end),
				}
				if v.type == 1 then
					AddMenuPed(k, ped_properties, EntityDb.spawned_options[k], v)
				else
					ui.hide(EntityDb.spawned_options[k].subopt_ped_prop, true)
				end
				if v.type == 2 then
					AddMenuVehicle(k, vehicle_properties, EntityDb.spawned_options[k], v)
				else
					ui.hide(EntityDb.spawned_options[k].subopt_veh_prop, true)
				end
				if v.type == 3 then
					EntityDb.spawned_options[k].texture = ui.add_num_option(TRANSLATION["Texture"], sub, 1, 255, 1, function(int)
						if v.valid == 0 then return HudSound("ERROR") end
						HudSound("YES")
						entities.request_control(k, function()
							OBJECT._SET_OBJECT_TEXTURE_VARIATION(k, int)
						end)
					end)
				end
				ui.set_value(EntityDb.spawned_options[k].step, 3, true)
				ui.set_value(EntityDb.spawned_options[k].attachstep, 2, true)
				ui.set_value(EntityDb.spawned_options[k].dynamic, v.dynamic or true, true)
				ui.set_value(EntityDb.spawned_options[k].has_gravity, v.gravity or true, true)
				ui.set_value(EntityDb.spawned_options[k].light_mult, v.light_mult or 1, true)
				dont_play_tog = true
				ui.set_value(EntityDb.spawned_options[k].freeze_position, v.freeze_position or false, false)
			elseif ui.is_open() then
				local parent = EntityDb.spawned_options[k]
				if v.valid == 0 then
					-- ui.set_name(EntityDb.spawned_options[k].submenu, v.name..' **INVALID**')
					ui.set_name(parent.sub_option, v.name..' '..TRANSLATION["**INVALID**"])
				elseif ui.is_sub_open(parent.submenu) then
					features.draw_box_on_entity(k, 0, 255, 0, 255)
                    if not ui.is_hidden(parent.attached_opt) and ENTITY.IS_ENTITY_ATTACHED(k) == 0 then
                        ui.hide(parent.attached_opt, true)
                    elseif ui.is_hidden(parent.attached_opt) and ENTITY.IS_ENTITY_ATTACHED(k) == 1 then
                        ui.hide(parent.attached_opt, false)
                    end
                    ui.set_value(parent.godmode, v.god, true)
                    ui.set_value(parent.alpha, v.alpha, true)
                    ui.set_value(parent.lod_dist, v.lod_dist, true)
                    ui.set_value(parent.visible, v.visible, true)
                    ui.set_value(parent.collision, v.collision, true)
                    ui.set_value(parent.posx, v.pos.x, true)
                    ui.set_value(parent.posy, v.pos.y, true)
                    ui.set_value(parent.posz, v.pos.z, true)
                    ui.set_value(parent.rotx, v.rot.x, true)
                    ui.set_value(parent.roty, v.rot.y, true)
                    ui.set_value(parent.rotz, v.rot.z, true)
                    ui.set_value(parent.attach_bone, v.attach_bone, true)
                    ui.set_value(parent.attachx, v.attachx, true)
                    ui.set_value(parent.attachy, v.attachy, true)
                    ui.set_value(parent.attachz, v.attachz, true)
                    ui.set_value(parent.attachpitch, v.attachpitch, true)
                    ui.set_value(parent.attachroll, v.attachroll, true)
                    ui.set_value(parent.attachyaw, v.attachyaw, true)
                    if v.type == 3 then
                        ui.set_value(parent.texture, v.texture, true)
                    end
                elseif v.type == 2 and ui.is_sub_open(parent.sub_mods) then
                    local primary, secondary = s_memory.allocate(2)
                    VEHICLE.GET_VEHICLE_COLOURS(k, primary, secondary)
                    ui.set_value(parent.paint_primary_select, memory.read_int(primary), true)
                    ui.set_value(parent.paint_secondary_select, memory.read_int(secondary), true)
                    local r, g, b = s_memory.allocate(3)
                    VEHICLE.GET_VEHICLE_CUSTOM_PRIMARY_COLOUR(k, r, g, b)
                    ui.set_value(parent.paint_primary_rgb, memory.read_int(r), memory.read_int(g), memory.read_int(b), 255, true)
                    VEHICLE.GET_VEHICLE_CUSTOM_SECONDARY_COLOUR(k, r, g, b)
                    ui.set_value(parent.paint_secondary_rgb, memory.read_int(r), memory.read_int(g), memory.read_int(b), 255, true)
                    local pearl, wheel = s_memory.allocate(2)
                    VEHICLE.GET_VEHICLE_EXTRA_COLOURS(k, pearl, wheel)
                    ui.set_value(parent.paint_pearlescent_select, memory.read_int(pearl), true)
                    for i = 0, 48
				    do
				        if i < 17 or i > 24 and parent["veh_mod_"..i] then
				        	ui.set_value(parent["veh_mod_"..i], VEHICLE.GET_VEHICLE_MOD(k, i) + 1, true)
                    	end
                    end
                    ui.set_value(parent.turbo, VEHICLE.IS_TOGGLE_MOD_ON(k, 18) == 1, true)
                    ui.set_value(parent.tyre_smoke, VEHICLE.IS_TOGGLE_MOD_ON(k, 20) == 1, true)
                    ui.set_value(parent.xenons, VEHICLE.IS_TOGGLE_MOD_ON(k, 22) == 1, true)
                    ui.set_value(parent.bulletproof_tires, VEHICLE.GET_VEHICLE_TYRES_CAN_BURST(k) == 0, true)
                    ui.set_value(parent.licence_index, VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(k), true)
                    ui.set_value(parent.licence_text, VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT(k), true)
                    for i = 0, 20
				    do
				        if VEHICLE.DOES_EXTRA_EXIST(k, i) == 1 then
				        	ui.set_value(parent["extra_"..i], VEHICLE.IS_VEHICLE_EXTRA_TURNED_ON(k, i) == 1, true)
				        end
				    end
				    ui.set_value(parent.window_tint, VEHICLE.GET_VEHICLE_WINDOW_TINT(k), true)
				    local xenon_color = VEHICLE._GET_VEHICLE_XENON_LIGHTS_COLOR(k)
				    ui.set_value(parent.xenon_color, xenon_color == 255 and 0 or xenon_color + 1, true)
				    local interior, dashboard = s_memory.allocate(2)
				    VEHICLE._GET_VEHICLE_INTERIOR_COLOR(k, interior)
				    ui.set_value(parent.interior_color, memory.read_int(interior), true)
				    VEHICLE._GET_VEHICLE_DASHBOARD_COLOR(k, dashboard)
				    ui.set_value(parent.dashboard_color, memory.read_int(dashboard), true)
				    for i = 0, 3
				    do
				    	ui.set_value(parent["neon_"..i], VEHICLE._IS_VEHICLE_NEON_LIGHT_ENABLED(k, i) == 1, true)				    	
				    end
				    VEHICLE._GET_VEHICLE_NEON_LIGHTS_COLOUR(k, r, g, b)
				    ui.set_value(parent.neon_rgb, memory.read_int(r), memory.read_int(g), memory.read_int(b), 255, true)
				    VEHICLE.GET_VEHICLE_TYRE_SMOKE_COLOR(k, r, g, b)
				    ui.set_value(parent.tyre_smoke_color, memory.read_int(r), memory.read_int(g), memory.read_int(b), 255, true)
				elseif v.type == 2 and ui.is_sub_open(parent.wheel_sub) then 
					local pearl, wheel = s_memory.allocate(2)
	            	VEHICLE.GET_VEHICLE_EXTRA_COLOURS(k, pearl, wheel)
					ui.set_num_max(parent.wheels, VEHICLE.GET_NUM_VEHICLE_MODS(k, 23))
				    ui.set_value(parent.custom_wheels, VEHICLE.GET_VEHICLE_MOD_VARIATION(k, 23) == 1 or VEHICLE.GET_VEHICLE_MOD_VARIATION(k, 24) == 1, true)
				    if VEHICLE.IS_THIS_MODEL_A_BIKE(ENTITY.GET_ENTITY_MODEL(k)) == 1 then
				    	ui.set_value(parent.wheels_front, VEHICLE.GET_VEHICLE_MOD(k, 23), true)
				    	ui.set_value(parent.wheels_back, VEHICLE.GET_VEHICLE_MOD(k, 24) + 1, true)
				    else
				    	local wheel_type = VEHICLE.GET_VEHICLE_WHEEL_TYPE(k)
	               		ui.set_value(parent.wheel_type, wheel_type < 6 and wheel_type or wheel_type - 1, true)
				    	ui.set_value(parent.wheels, VEHICLE.GET_VEHICLE_MOD(k, 23) + 1, true)
				    end
				    ui.set_value(parent.wheel_color, memory.read_int(wheel), true)
				elseif v.type == 2 and ui.is_sub_open(parent.sub_veh_prop) then
				    ui.set_value(parent.paint_fade, VEHICLE.GET_VEHICLE_ENVEFF_SCALE(k), true)
				    ui.set_value(parent.dirt_level, VEHICLE.GET_VEHICLE_DIRT_LEVEL(k), true)
				    ui.set_value(parent.engine_on, VEHICLE.GET_IS_VEHICLE_ENGINE_RUNNING(k) == 1, true)
				   	ui.set_value(parent.lock_vehicle, VEHICLE.GET_VEHICLE_DOOR_LOCK_STATUS(k) == 2, true) 
				   	ui.set_value(parent.child_locks, VEHICLE.GET_VEHICLE_DOOR_LOCK_STATUS(k) == 4, true)
				    ui.set_value(parent.siren, VEHICLE.IS_VEHICLE_SIREN_ON(k) == 1, true)
				elseif v.type == 1 and ui.is_sub_open(parent.sub_ped_prop) then
					ui.set_value(parent.block_flee, v.noflee, true)
					ui.set_value(parent.can_ragdoll, PED.CAN_PED_RAGDOLL(k) == 1, true)
					ui.set_value(parent.is_tiny, PED.GET_PED_CONFIG_FLAG(k, 223, false) == 1, true)
					ui.set_value(parent.ped_health, ENTITY.GET_ENTITY_HEALTH(k), true)
					ui.set_value(parent.ped_armor, PED.GET_PED_ARMOUR(k), true)
				elseif v.type == 1 and ui.is_sub_open(parent.wardobe_sub) then
					local component_id = EntityDb.entity_data[k].drawables[ui.get_value(parent.component_choose)+1]
					ui.set_value(parent.component_id, PED.GET_PED_DRAWABLE_VARIATION(k, component_id), true)
					ui.set_value(parent.texture_id, PED.GET_PED_TEXTURE_VARIATION(k, component_id), true)
					ui.set_num_max(parent.texture_id, PED.GET_NUMBER_OF_PED_TEXTURE_VARIATIONS(k, component_id, PED.GET_PED_DRAWABLE_VARIATION(k, component_id))-1)
					local prop_id = EntityDb.entity_data[k].props[ui.get_value(parent.prop_choose)+1]
					ui.set_value(parent.prop_id, PED.GET_PED_PROP_INDEX(k, prop_id), true)
					ui.set_value(parent.proptexture_id, PED.GET_PED_PROP_TEXTURE_INDEX(k, prop_id), true)
					ui.set_num_max(parent.proptexture_id, PED.GET_NUMBER_OF_PED_PROP_TEXTURE_VARIATIONS(k, component_id, PED.GET_PED_PROP_INDEX(k, prop_id))-1)
                end
			end
		end
	end)
end

__submenus["BlockAreas"] = ui.add_submenu(TRANSLATION["Block areas"])
__suboptions["BlockAreas"] = ui.add_sub_option(TRANSLATION["Block areas"], __submenus["World"] , __submenus["BlockAreas"])

ui.add_click_option(TRANSLATION["Block Orbital Room"], __submenus["BlockAreas"], function() 
	HudSound("SELECT")
    BlockArea(-1003748966, 328.337, 4828.734, -58.553, 0.0, 90.0, 0.0, true) 
end)

ui.add_click_option(TRANSLATION["Block all LSC"], __submenus["BlockAreas"], function()
	HudSound("SELECT")
    BlockArea(-1003748966, -1145.897, -1991.144, 14.1836, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 723.1160, -1088.831, 23.2320, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, -356.0905, -134.7714, 40.0130, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 1174.6543, 2645.2222, 38.6396, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 1182.3055, 2645.2324, 38.6396, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 114.3135, 6623.2334, 32.6731, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 108.8502, 6617.8770, 32.6731, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, -205.6828, -1310.682, 30.2957, 0.0, 90.0, 0.0, true)
end)

ui.add_click_option(TRANSLATION["Block all Ammu-Nation"], __submenus["BlockAreas"], function()
	HudSound("SELECT")
    BlockArea(-1003748966, 1699.9373, 3753.4202, 34.8553, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 243.8379, -46.5232, 70.0910, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 842.7685, -1024.539, 28.3448, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, -324.2730, 6077.1094, 31.6047, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, -662.6415, -944.3256, 21.9792, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, -1314.465, -391.6472, 36.8457, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, -1120.070, 2691.5046, 18.7041, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, -3163.811, 1083.7786, 20.9887, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 2568.3037, 303.3556, 108.8848, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 17.729, -1114.047, 29.809, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 811.496, -2149.082, 29.631, 0.0, 90.0, 0.0, true)
end)

ui.add_click_option(TRANSLATION["Block Casino"], __submenus["BlockAreas"], function()
	HudSound("SELECT")
    BlockArea(-1003748966, 924.796, 46.537, 82.332, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 936.130, 0.807, 79.608, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 987.713, 80.519, 81.877, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 966.303, 61.289, 112.845, 0.0, 90.0, 0.0, true)
end)

ui.add_click_option(TRANSLATION["Block Eclipse Towers"], __submenus["BlockAreas"], function()
	HudSound("SELECT")
    BlockArea(-1003748966, -773.986, 313.359, 85.677, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, -796.079, 308.323, 85.677, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, -796.079, 308.323, 87.677, 0.0, 90.0, 0.0, true)
end)

ui.add_click_option(TRANSLATION["Windmill main LSC"], __submenus["BlockAreas"], function()
	HudSound("SELECT")
    BlockArea(1952396163, -405.3579, -142.0034, 36.3176, -90.0, 60.0, 0.0, false)
end)

ui.add_click_option(TRANSLATION["Block Strip Club"], __submenus["BlockAreas"], function()
	HudSound("SELECT")
    BlockArea(-1003748966, 127.9552, -1298.503, 29.4196, 0.0, 90.0, 0.0, true)
end)

ui.add_separator(TRANSLATION['Delete'], __submenus["BlockAreas"])

ui.add_click_option(TRANSLATION["Delete all blocking objects"], __submenus["BlockAreas"], function()
	HudSound("SELECT")
	for _, v in ipairs(blockobjects) do
		features.delete_entity(v)
	end
	blockobjects = {}
end)

do
	local clear_peds
	local clear_vehicles
	local clear_props
	local clear_pickups
	local clearing_area
	__submenus["ClearArea"] = ui.add_submenu(TRANSLATION["Clear area"])
	__suboptions["ClearArea"] = ui.add_sub_option(TRANSLATION["Clear area"], __submenus["World"] , __submenus["ClearArea"])

	__options.bool["ClearAreaPeds"] = ui.add_bool_option(TRANSLATION["Peds"], __submenus["ClearArea"], function(bool) HudSound("TOGGLE_ON") clear_peds = bool 
		settings.World["ClearAreaPeds"] = bool
	end)
	__options.bool["ClearAreaVehicles"] = ui.add_bool_option(TRANSLATION["Vehicles"], __submenus["ClearArea"], function(bool) HudSound("TOGGLE_ON") clear_vehicles = bool 
		settings.World["ClearAreaVehicles"] = bool
	end)
	__options.bool["ClearAreaProps"] = ui.add_bool_option(TRANSLATION["Props"], __submenus["ClearArea"], function(bool) HudSound("TOGGLE_ON") clear_props = bool 
		settings.World["ClearAreaProps"] = bool
	end)
	__options.bool["ClearAreaPickups"] = ui.add_bool_option(TRANSLATION["Pickups"], __submenus["ClearArea"], function(bool) HudSound("TOGGLE_ON") clear_pickups = bool 
		settings.World["ClearAreaPickups"] = bool
	end)

	__options.num["ClearAreaDistance"] = ui.add_num_option(TRANSLATION["Distance"], __submenus["ClearArea"], 0, 50, 10, function(int) HudSound("YES") settings.World["ClearAreaDistance"] = int end)

	__options.click["ClearArea"] = ui.add_click_option(TRANSLATION["Clear area"], __submenus["ClearArea"], function()
		if ui.get_value(__options.num["ClearAreaDistance"]) > 50 then settings.World["ClearAreaDistance"] = 50; ui.set_value(__options.num["ClearAreaDistance"], 50, true) end
		if not clearing_area then
			HudSound("SELECT")
			clearing_area = true
			local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
			CreateRemoveThread(true, 'world_clear_area', function()
				local dist = settings.World["ClearAreaDistance"] * settings.World["ClearAreaDistance"]
				local pos = features.get_player_coords()
				if clear_peds then
					for _, v in ipairs(entities.get_peds())
					do
						if PED.IS_PED_A_PLAYER(v) == 0 and pos:sqrlen(features.get_entity_coords(v)) <= dist then
							features.delete_entity(v)
						end
					end
				end
				if clear_vehicles then
					for _, v in ipairs(entities.get_vehs())
					do
						if v ~= veh1 and v ~= veh2 and pos:sqrlen(features.get_entity_coords(v)) <= dist then
							features.delete_entity(v)
						end
					end
				end
				if clear_props then

					for _, v in ipairs(entities.get_objects())
					do
						if pos:sqrlen(features.get_entity_coords(v)) <= dist then
							features.delete_entity(v)
						end
					end
				end
				if clear_pickups then
					for _, v in ipairs(entities.get_pickups())
					do
						if pos:sqrlen(features.get_entity_coords(v)) <= dist then
							features.delete_entity(v)
						end
					end
				end
				clearing_area = nil
				system.notify(TRANSLATION["Imagined Menu"], TRANSLATION['Clear area finished'], 0, 255, 0, 255)
				return POP_THREAD
			end)
		end
	end)

	CreateRemoveThread(true, 'clear_area_prev', function()
		if not ui.is_sub_open(__submenus["ClearArea"]) then return end
		local pos = features.get_player_coords()
		GRAPHICS._DRAW_SPHERE(pos.x, pos.y, pos.z, settings.World["ClearAreaDistance"], 0, 255, 0, .5)
		local dist = settings.World["ClearAreaDistance"] * settings.World["ClearAreaDistance"]
	end)
end

__submenus["BlackHole"] = ui.add_submenu(TRANSLATION["Black hole"])
__suboptions["BlackHole"] = ui.add_sub_option(TRANSLATION["Black hole"], __submenus["World"] , __submenus["BlackHole"])

do
	local blackhole_pos = vector3.zero()
	local blackhole_dist = 1000
	local on_vehs
	local on_peds
	local on_obj
	local force_types = {TRANSLATION['Low'], TRANSLATION['Medium']..'*', TRANSLATION['High']}
	local force = {
		[0] = 10,
		50,
		1000,
	}
	local blackhole_force = force[1]

	__options.bool["BlackHoleOnVehicles"] = ui.add_bool_option(TRANSLATION['On vehicles'], __submenus["BlackHole"], function(bool) HudSound("TOGGLE_ON") on_vehs = bool
		settings.World["BlackHoleOnVehicles"] = bool
	end)
	__options.bool["BlackHoleOnPeds"] = ui.add_bool_option(TRANSLATION['On peds'], __submenus["BlackHole"], function(bool) HudSound("TOGGLE_ON") on_peds = bool	
		settings.World["BlackHoleOnPeds"] = bool
	end)
	__options.bool["BlackHoleOnObjects"] = ui.add_bool_option(TRANSLATION['On objects'], __submenus["BlackHole"], function(bool) HudSound("TOGGLE_ON") on_obj = bool	
		settings.World["BlackHoleOnObjects"] = bool
	end)

	__options.choose["BlackHoleForce"] = ui.add_choose(TRANSLATION['Force'], __submenus["BlackHole"], true, force_types, function(int) blackhole_force = force[int] 
		HudSound("YES")
		settings.World["BlackHoleForce"] = int
	end)

	ui.add_click_option(TRANSLATION['Bring to self'], __submenus["BlackHole"], function() HudSound("SELECT") blackhole_pos = features.get_player_coords() + vector3.up(10) end)

	__options.bool['AttackBlHole'] = ui.add_bool_option(TRANSLATION['Attach to self'], __submenus["BlackHole"], function(bool)  HudSound("TOGGLE_ON")
		CreateRemoveThread(bool, 'world_attach_blackhole', function()
			blackhole_pos = features.get_player_coords()
		end)
	end)

	local x = ui.add_float_option('X', __submenus["BlackHole"], -10000, 10000, 10, 3, function(float) HudSound("YES") blackhole_pos.x = float end)
	local y = ui.add_float_option('Y', __submenus["BlackHole"], -10000, 10000, 10, 3, function(float) HudSound("YES") blackhole_pos.y = float end)
	local z = ui.add_float_option('Z', __submenus["BlackHole"], -10000, 10000, 10, 3, function(float) HudSound("YES") blackhole_pos.z = float end)

	__options.num["BlackHoleDistance"] = ui.add_num_option(TRANSLATION['Distance'], __submenus["BlackHole"], 0, 100000, 10, function(int) HudSound("YES") blackhole_dist = int
		settings.World["BlackHoleDistance"] = int
	end)

	CreateRemoveThread(true, 'world_black_hole_position', function(tick)
		ui.set_value(x, blackhole_pos.x, true)
		ui.set_value(y, blackhole_pos.y, true)
		ui.set_value(z, blackhole_pos.z, true)
	end)

	__options.bool['BlackHoleSuckIn'] = ui.add_bool_option(TRANSLATION['Suck in'], __submenus["BlackHole"], function(bool) HudSound("TOGGLE_ON") settings.World["BlackHoleSuckIn"] = bool end)
	__options.bool['ShowBlackHole'] = ui.add_bool_option(TRANSLATION['Show blackhole'], __submenus["BlackHole"], function(bool) HudSound("TOGGLE_ON") settings.World["ShowBlackHole"] = bool end)

	__options.bool['BlackHole'] = ui.add_bool_option(TRANSLATION['Enable blackhole'], __submenus["BlackHole"], function(bool) HudSound("TOGGLE_ON")
		CreateRemoveThread(bool, 'world_black_hole', function()
			local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
			if settings.World["ShowBlackHole"] then
				GRAPHICS._DRAW_SPHERE(blackhole_pos.x, blackhole_pos.y, blackhole_pos.z, 6, 0, 0, 0, 1)
			end
			for _, v in ipairs(features.get_entities())
			do
				if ((ENTITY.IS_ENTITY_A_PED(v) == 1 and on_peds) or (ENTITY.IS_ENTITY_A_VEHICLE(v) == 1 and on_vehs) or (ENTITY.IS_ENTITY_AN_OBJECT(v) == 1 and on_obj)) and PED.IS_PED_A_PLAYER(v) == 0 then
					local pos = features.get_entity_coords(v)
					local distance = pos:sqrlen(blackhole_pos)
					if distance <= blackhole_dist * blackhole_dist then
						if not (features.compare(v, veh1, veh2) and ENTITY.IS_ENTITY_A_VEHICLE(v) == 1) then
							features.request_control_once(v)
							if ENTITY.IS_ENTITY_A_PED(v) == 1 and PED.IS_PED_A_PLAYER(v) == 0 then
								PED.SET_PED_TO_RAGDOLL(v, 5000, 5000, 0, true, true, false)
							end
							if distance > 36 then
								pos = features.get_entity_coords(v)
								local dir = pos:direction_to(blackhole_pos) * blackhole_force
								ENTITY.FREEZE_ENTITY_POSITION(v, false)
								features.set_entity_velocity(v, dir.x, dir.y, dir.z)
							else
								ENTITY.FREEZE_ENTITY_POSITION(v, true)
								if settings.World["BlackHoleSuckIn"] then
									features.delete_entity(v)
								end
							end
						end
					end
				end
			end
		end)
		if not bool then
			local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
			for _, v in ipairs(features.get_entities())
			do
				local pos = features.get_entity_coords(v)
				local distance = pos:sqrlen(blackhole_pos)
				if (distance <= blackhole_dist * blackhole_dist) and (ENTITY.IS_ENTITY_A_VEHICLE(v) == 1 and v ~= veh1 and v ~= veh2 and v ~= features.player_ped()) then
					features.request_control_once(v)
					if distance <= 100 then
						ENTITY.FREEZE_ENTITY_POSITION(v, false)
						local pos = features.get_entity_coords(v)
						local dir = blackhole_pos:direction_to(pos) * 100
						features.set_entity_velocity(v, dir.x, dir.y, dir.z)
					end
				end
			end
		end
	end)
end

__submenus["Peds"] = ui.add_submenu(TRANSLATION["Peds"])
__suboptions["Peds"] = ui.add_sub_option(TRANSLATION["Peds"], __submenus["World"] , __submenus["Peds"])

ui.add_click_option(TRANSLATION["Resurrect peds"], __submenus["Peds"], function()
	HudSound("SELECT")
	for _, v in ipairs(entities.get_peds())
	do
		if ENTITY.IS_ENTITY_DEAD(v, false) == 1 and v ~= features.player_ped() and PED.IS_PED_A_PLAYER(v) == 0 then
			peds.revive(v)
		end
	end
end)

ui.add_click_option(TRANSLATION["Explode peds"], __submenus["Peds"], function()
	HudSound("SELECT")
	for _, v in ipairs(entities.get_peds())
	do
		if ENTITY.IS_ENTITY_DEAD(v, false) == 0 and v ~= features.player_ped() and PED.IS_PED_A_PLAYER(v) == 0 then
			local pos = features.get_entity_coords(v)
			FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, enum.explosion.ROCKET, 10, true, false, 1.0, false)
		end
	end
end)

__options.bool["FreezePeds"] = ui.add_bool_option(TRANSLATION["Freeze peds"], __submenus["Peds"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'freeze_peds', function()
		for _, v in ipairs(entities.get_peds())
		do
			if v ~= features.player_ped() and PED.IS_PED_A_PLAYER(v) == 0 then
				TASK.CLEAR_PED_TASKS_IMMEDIATELY(v)
			end
		end
	end)
end)

__submenus["Vehicles"] = ui.add_submenu(TRANSLATION["Vehicles"])
__suboptions["Vehicles"] = ui.add_sub_option(TRANSLATION["Vehicles"], __submenus["World"] , __submenus["Vehicles"])

ui.add_click_option(TRANSLATION["Repair vehicles"], __submenus["Vehicles"], function()
	HudSound("SELECT")
	local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
	for _, v in ipairs(entities.get_vehs())
	do
		if v ~= veh1 and v ~= veh2 then
			entities.request_control(v, function()
				vehicles.repair(v)
			end)
		end
	end
end)

ui.add_click_option(TRANSLATION["Boost vehicles"], __submenus["Vehicles"], function()
	HudSound("SELECT")
	local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
	for _, v in ipairs(entities.get_vehs())
	do
		if v ~= veh1 and v ~= veh2 then
			entities.request_control(v, function()
				VEHICLE.SET_VEHICLE_FORWARD_SPEED(v, 200)
			end)
		end
	end
end)

-- ui.add_click_option(TRANSLATION["Pop tires"], __submenus["Vehicles"], function()
-- 	local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
-- 	for _, v in ipairs(entities.get_vehs())
-- 	do
-- 		if v ~= veh1 and v ~= veh2 then
-- 			entities.request_control(v, function()
-- 				vehicles.set_godmode(v, false)
-- 				for i = 0, 5 do
-- 		      VEHICLE.SET_VEHICLE_TYRE_BURST(veh, i, true, 1000.0)
-- 		    end
-- 			end)
-- 		end
-- 	end
-- end)

__options.bool['Beyblades'] = ui.add_bool_option(TRANSLATION["Beyblades"], __submenus["Vehicles"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'world_beyblades', function()
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 then
				features.request_control_once(v)
				VEHICLE.SET_VEHICLE_REDUCE_GRIP(v, true)
				features.apply_force_to_entity(v, 1, 1, 0, 0, 100, 100, 0, 0, true, true, true, false, true)
			end
		end
	end)
	if not bool then
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 then
				entities.request_control(v, function()
					VEHICLE.SET_VEHICLE_REDUCE_GRIP(v, false)
				end)
			end
		end
	end
end)

do
	local ApplyForce = switch()
		:case(1, function(veh)
			features.apply_force_to_entity(veh, 1, 0, 0, 1, 3, 0, 0, 0, true, true, true, false, true)
		end)
		:case(2, function(veh)
			features.apply_force_to_entity(veh, 1, 0, 0, 1, -3, 0, 0, 0, true, true, true, false, true)
		end)
		:case(3, function(veh)
			features.apply_force_to_entity(veh, 1, 0, 0, 1, 0, -7, 0, 0, true, true, true, false, true)
		end)
		:case(4, function(veh)
			features.apply_force_to_entity(veh, 1, 0, 0, 1, 0, 7, 0, 0, true, true, true, false, true)
		end)
		:case(5, function(veh)
			features.apply_force_to_entity(veh, 1, 0, 0, 5, 0, 0, 0, 0, true, true, true, false, true)
		end)

	__options.bool['JumpyVehicles'] = ui.add_bool_option(TRANSLATION["Jumpy vehicles"], __submenus["Vehicles"], function(bool) HudSound("TOGGLE_ON")
		CreateRemoveThread(bool, 'world_jumpy_vehicles', function(tick)
			if tick%100 ~= 0 then return end
			local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
			for _, v in ipairs(entities.get_vehs())
			do
				if ENTITY.IS_ENTITY_IN_AIR(v) == 0 and v ~= veh1 and v ~= veh2 then
					features.request_control_once(v)
					ApplyForce(random(1, 5), v)
				end
			end
		end)
	end)
end

__options.bool['VehiclesExplodeOnImpact'] = ui.add_bool_option(TRANSLATION["Vehicles explode on impact"], __submenus["Vehicles"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'vehicles_explode_on_impact', function(tick)
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 and ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(v) ~= 0 then
				entities.request_control(v, function()
					vehicles.set_godmode(v, false)
					NETWORK.NETWORK_EXPLODE_VEHICLE(v, true, false, PLAYER.PLAYER_ID())
				end)
			end
		end
	end)
end)

__options.bool['LaunchVehicles'] = ui.add_bool_option(TRANSLATION["Launch vehicles"], __submenus["Vehicles"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'world_launch_vehicles', function(tick)
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 then
				features.request_control_once(v)
				ENTITY.FREEZE_ENTITY_POSITION(v, false)
				features.set_entity_velocity(v, 0, 0, 100)
			end
		end
	end)
end)

__options.bool['HornHavoc'] = ui.add_bool_option(TRANSLATION["Horn havoc"], __submenus["Vehicles"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'world_horn_havoc', function(tick)
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 then
				features.request_control_once(v)
				VEHICLE.START_VEHICLE_HORN(v, 3000, 0, false)
			end
		end
	end)
end)

__options.bool['HornBoosting'] = ui.add_bool_option(TRANSLATION["Horn boosting"], __submenus["Vehicles"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'world_horn_boosting', function(tick)
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 and AUDIO.IS_HORN_ACTIVE(v) == 1 then
				entities.request_control(v, function()
					local speed = ENTITY.GET_ENTITY_SPEED(v)
					VEHICLE.SET_VEHICLE_FORWARD_SPEED(v, speed + speed * .05 + 1)
				end)
			end
		end
	end)
end)

do
	local spawned
	local ufo
	local ufo_position = vector3.zero()
	__options.bool["UFO"] = ui.add_bool_option(TRANSLATION["UFO invasion"], __submenus["World"], function(bool) HudSound("TOGGLE_ON")
		if not spawned then
			ufo_position = features.get_offset_from_player_coords(vector3(0, 300, 200))
		end

		if not bool and ufo then
			local out_pos = vector3(ufo_position.x + 1000, ufo_position.y, ufo_position.z + 1000)
			CreateRemoveThread(true, 'world_ufo_delete', function()
				if ENTITY.DOES_ENTITY_EXIST(ufo) == 0 then ufo = nil spawned = nil return POP_THREAD end
				local pos = features.get_entity_coords(ufo)
				if pos:sqrlen(out_pos) > 100 then 
					local move = pos:move_towards(out_pos, 50)
					entities.request_control(ufo, function()
						ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ufo, move.x, move.y, move.z, false, false, false)
					end)
					dont_play_tog = true
					ui.set_value(__options.bool["UFO"], false, false)
					return
				else
					features.delete_entity(ufo)
					STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(utils.joaat('p_spinning_anus_s'))
					ufo = nil
					spawned = nil
				end
			end)
		end

		CreateRemoveThread(bool, 'world_ufo', function()
			local pos = features.get_offset_from_player_coords(vector3(0, 200, 0))
			if not ufo then 
				local loaded, hash = features.request_model(utils.joaat('p_spinning_anus_s'), false)
				if loaded == 0 then return end
				if not spawned then 
					pos = vector3(pos.x + 1000, pos.y, pos.z + 1000) 
				else
					pos = ufo_position
				end
				ufo = features.create_object(hash, pos)
				spawned = true
			end
			if ENTITY.DOES_ENTITY_EXIST(ufo) == 0 then ufo = nil return end
			ENTITY.SET_ENTITY_LOD_DIST(ufo, 0xFFFF)
			local pos2 = features.get_entity_coords(ufo)
			if pos2:sqrlen(ufo_position) > 100 then 
				local move = pos2:move_towards(ufo_position, 50)
				entities.request_control(ufo, function()
					ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ufo, move.x, move.y, move.z, false, false, false)
				end)
				return
			else
				entities.request_control(ufo, function()
					ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ufo, ufo_position.x, ufo_position.y, ufo_position.z, false, false, false)
				end)
			end
			
			local me, veh1, veh2 = features.player_ped(), vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
			for _, v in ipairs(features.get_entities())
			do
				if v ~= me and v ~= veh1 and v ~= veh2 and v ~= ufo then
					features.request_control_once(v)
					local ent_pos = features.get_entity_coords(v)
					local diff = ufo_position - ent_pos
					local dist_no_z = diff.x ^ 2 + diff.y ^ 2
					if ENTITY.IS_ENTITY_A_PED(v) == 1 then
						PED.SET_PED_TO_RAGDOLL(v, 5000, 5000, 0, true, true, false)
					end
					if ENTITY.IS_ENTITY_A_VEHICLE(v) == 1 and ent_pos:sqrlen(ufo_position) <= 1000 then
						VEHICLE.SET_VEHICLE_ENGINE_ON(v, false, true, true)
					end
					if dist_no_z <= 27 then
						ENTITY.FREEZE_ENTITY_POSITION(v, false)
						features.set_entity_velocity(v, 0, 0, 40)
						if ent_pos.z < ufo_position.z and ent_pos.z >= ufo_position.z - 10 then
							features.delete_entity(v)
						end
					elseif ent_pos.z < ufo_position.z - 30 then
						local pos_to = ent_pos:direction_to(ufo_position) * 100
						ENTITY.FREEZE_ENTITY_POSITION(v, false)
						features.set_entity_velocity(v, pos_to.x, pos_to.y, 10)
					end
				end
			end
			
			entities.request_control(ufo, function()
				local rot = features.get_entity_rot(ufo)
				ENTITY.SET_ENTITY_ROTATION(ufo, rot.x, rot.y, rot.z + 1, 2, true)
				ENTITY.FREEZE_ENTITY_POSITION(ufo, true)
				ENTITY.SET_ENTITY_COLLISION(ufo, false, true)
			end)

		end)
	end)
end

do
	local distance, force, angle = 100, 30, -80
	local GetSize = switch()
		:case(2, function()
			return 300, 50, -83
		end)
		:case(3, function()
			return 500, 70, -85
		end)
		:case(4, function()
			return 1000, 90, -90
		end)
		:case(5, function()
			return 2000, 100, -100
		end)
		:case(6, function()
			return 10000, 1000, -150
		end)
		:default(function()
			return 100, 30, -80
		end)

	__options.num["TornadoSize"] = ui.add_num_option(TRANSLATION["Tornado size"], __submenus["World"], 1, 6, 1, function(int) HudSound("YES") settings.World["TornadoSize"] = int 
		distance, force, angle = GetSize(int)
	end)

	__options.bool['Tornado'] = ui.add_bool_option(TRANSLATION["Tornado"], __submenus["World"], function(bool) HudSound("TOGGLE_ON")
		local tornado_pos = features.get_offset_from_player_coords(vector3.forward(20))
		CreateRemoveThread(bool, 'world_tornado', function()
			local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
			local sqrdistance = distance * distance
			for _, v in ipairs(features.get_entities())
			do
				if v ~= veh1 and v ~= veh2 and PED.IS_PED_A_PLAYER(v) == 0 then
					local pos = features.get_entity_coords(v)
					if pos:sqrlen(tornado_pos) <= sqrdistance then
						features.request_control_once(v)
						if ENTITY.IS_ENTITY_A_PED(v) == 1 then
							PED.SET_PED_TO_RAGDOLL(v, 5000, 5000, 0, true, true, false)
						end
						local final_pos = pos:direction_to(tornado_pos:point_on_circle(pos:direction_to(tornado_pos):angle() + rad(angle), 100)) * force
						ENTITY.FREEZE_ENTITY_POSITION(v, false)
						features.set_entity_velocity(v, final_pos.x, final_pos.y, .3)
					end
				end
			end
		end)
	end)
end

__options.bool["Earthquake"] = ui.add_bool_option(TRANSLATION["Earthquake"], __submenus["World"], function(bool) HudSound("TOGGLE_ON")
	CreateRemoveThread(bool, 'world_earthquake', function(tick)
		if tick%5 ~= 0 then return end
		CAM.SHAKE_GAMEPLAY_CAM("LARGE_EXPLOSION_SHAKE", .05)
		local force = MISC.GET_RANDOM_FLOAT_IN_RANGE(-9, -7)
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		for _, v in ipairs(features.get_entities())
		do
			local model = ENTITY.GET_ENTITY_MODEL(v)
			if v ~= veh1 and v ~= veh2 and VEHICLE.IS_THIS_MODEL_A_PLANE(model) == 0 and VEHICLE.IS_THIS_MODEL_A_HELI(model) == 0 then
				features.request_control_once(v)
				features.apply_force_to_entity(v, 1, 0, 0, force, 0, 0, 0, 0, true, true, true, false, true)
			end
		end
	end)
	if not bool then
		CAM.STOP_GAMEPLAY_CAM_SHAKING(true)
	end
end)

__options.bool['DisablePedSpawn'] = ui.add_bool_option(TRANSLATION["Disable ped spawn"], __submenus["World"], function(bool) HudSound("TOGGLE_ON")
	settings.World['DisablePedSpawn'] = bool
	CreateRemoveThread(bool, 'world_disable_peds', function(tick)
		PED.SET_PED_DENSITY_MULTIPLIER_THIS_FRAME(0)
	end)
end)

__options.bool['DisableVehicleSpawn'] = ui.add_bool_option(TRANSLATION["Disable vehicle spawn"], __submenus["World"], function(bool) HudSound("TOGGLE_ON")
	settings.World['DisableVehicleSpawn'] = bool
	CreateRemoveThread(bool, 'world_disable_vehicles', function(tick)
	 	VEHICLE.SET_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME(0)
    VEHICLE.SET_PARKED_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME(0)
    VEHICLE.SET_RANDOM_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME(0)
    VEHICLE.SET_AMBIENT_VEHICLE_RANGE_MULTIPLIER_THIS_FRAME(0)
	end)
end)

do
	opt = ui.add_float_option(TRANSLATION["Set waves height"], __submenus["World"], -100, 100, .1, 1, function(float) HudSound("YES")
		WATER.SET_DEEP_OCEAN_SCALER(float)
	end)
	CreateRemoveThread(true, 'world_get_waves_intensity', function()
		ui.set_value(opt, WATER.GET_DEEP_OCEAN_SCALER(), true)
	end)
end

do
	opt = ui.add_float_option(TRANSLATION["Set rain level"], __submenus["World"], 0, 5, .1, 1, function(float) HudSound("YES")
		MISC._SET_RAIN_LEVEL(float)
	end)
	CreateRemoveThread(true, 'world_get_rain_intensity', function()
		ui.set_value(opt, MISC.GET_RAIN_LEVEL(), true)
	end)
end

do
	local scaler = 0
	opt = ui.add_float_option(TRANSLATION["Set wind speed"], __submenus["World"], -10, 10, .1, 1, function(float) HudSound("YES")
		MISC.SET_WIND_SPEED(float)
	end)
	CreateRemoveThread(true, 'world_get_wind_intensity', function()
		ui.set_value(opt, MISC.GET_WIND_SPEED(), true)
	end)
end

---------------------------------------------------------------------------------------------------------------------------------
-- Teleport
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'teleport submenu') end
local last_teleports = {}
__submenus["Teleport"] = ui.add_submenu(TRANSLATION["Teleport"])
__suboptions["Teleport"] = ui.add_sub_option(TRANSLATION["Teleport"], __submenus["MainSub"], __submenus["Teleport"])

__submenus["SavedLocations"] = ui.add_submenu(TRANSLATION["Saved locations"])
__suboptions["SavedLocations"] = ui.add_sub_option(TRANSLATION["Saved locations"], __submenus["Teleport"], __submenus["SavedLocations"])

__submenus["SaveLocation"] = ui.add_submenu(TRANSLATION["Save location"])
__suboptions["SaveLocation"] = ui.add_sub_option(TRANSLATION["Save location"], __submenus["SavedLocations"], __submenus["SaveLocation"])

do
	local name = ""
	local locations = {}
	local folders = {}
	local separator
	local function RefreshLocations()
		for _, v in ipairs(locations)
		do
			for _, e in pairs(v)
			do
				ui.remove(e)
			end
		end
		for _, v in pairs(folders)
		do
			ui.remove(v.choose)
			ui.remove(v.sub)
			ui.remove(v.sub_option)
		end
		folders = {}

		if separator then
			ui.remove(separator)
		end

		for i, v in pairs(saved_locations)
		do
			if v.folder and not folders[v.folder] then
				local sub = ui.add_submenu(v.folder)
				folders[v.folder] = {
					choose = ui.add_choose(TRANSLATION["Delete"], sub, false, {TRANSLATION["Only folder"], TRANSLATION["Folder & locations"]}, function(int)
						HudSound("YES")
						CreateRemoveThread(true, 'ui_refresh_'..thread_count, function()
							local to_del = {}
							for j, e in pairs(saved_locations)
							do
								if e.folder == v.folder then
									insert(to_del, j)
								end
							end
							for _, x in ipairs(to_del)
							do
								if int == 0 then
									saved_locations[x].folder = nil
								else
									for k, l in ipairs(saved_locations)
									do
										if l.folder == v.folder then
											table_remove(saved_locations, k)
											break
										end
									end
								end
							end
							RefreshLocations()
							SaveLocations()
							return POP_THREAD
						end)
					end),
					sub = sub,
					sub_option = ui.add_sub_option( v.folder, __submenus["SavedLocations"], sub)
				}
			end
		end
		separator = ui.add_separator(TRANSLATION["Saved"], __submenus["SavedLocations"])

		for i, v in ipairs(saved_locations)
		do
			local sub = ui.add_submenu(v.name)
			locations[i] = {
				submenu = sub,
				sub_option = ui.add_sub_option(v.name, v.folder and folders[v.folder].sub or __submenus["SavedLocations"], sub),
				teleport = ui.add_click_option(TRANSLATION["Teleport to"], sub, function()
					HudSound("SELECT")
					insert(last_teleports, features.get_player_coords())
					features.teleport(features.player_ped(), v.x, v.y, v.z, v.heading)
				end),
				rename = ui.add_input_string(TRANSLATION["Rename"], sub, function(text) 
					if not text or text:isblank() then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Please enter name"], 255, 0, 0, 255) return HudSound("ERROR") end
					saved_locations[i].name = text
					ui.set_name(locations[i].submenu, text)
					ui.set_name(locations[i].sub_option, text)
					SaveLocations()
				end),
				delete = ui.add_click_option(TRANSLATION["Delete"], sub, function()
					HudSound("SELECT")
					CreateRemoveThread(true, 'ui_refresh_'..thread_count, function()
						table_remove(saved_locations, i)
						RefreshLocations()
						SaveLocations()
						return POP_THREAD
					end)
				end)
			}
			if not v.folder then
				locations[i].add_to_folder = ui.add_submenu(TRANSLATION["Add to folder"])
				locations[i].add_to_folder_s = ui.add_sub_option(TRANSLATION["Add to folder"], locations[i].submenu, locations[i].add_to_folder) 
				locations[i].string = ui.add_input_string(TRANSLATION["Create folder"], locations[i].add_to_folder, function(text)
					if not text or text:isblank() or folders[text] then return end
					CreateRemoveThread(true, 'ui_refresh_'..thread_count, function()
						saved_locations[i].folder = text
						RefreshLocations()
						SaveLocations()
						return POP_THREAD
					end)
				end)
				for k in pairs(folders)
				do
					locations[i][k] = ui.add_click_option(k, locations[i].add_to_folder, function()
						HudSound("SELECT")
						CreateRemoveThread(true, 'ui_refresh_'..thread_count, function()
							saved_locations[i].folder = k
							RefreshLocations()
							SaveLocations()
							return POP_THREAD
						end)
					end)
				end
			end
		end
	end

	ui.add_input_string(TRANSLATION["Name"], __submenus["SaveLocation"], function(text) name = text end)
	__options.click["TeleportSelectedFolder"] = ui.add_click_option('', __submenus["SaveLocation"], function() HudSound("ERROR") end)
	local folder
	__submenus["TeleportFolders"] = ui.add_submenu(TRANSLATION["Select folder"])
	__suboptions["TeleportFolders"] = ui.add_sub_option(TRANSLATION["Select folder"], __submenus["SaveLocation"], __submenus["TeleportFolders"])
	ui.add_input_string(TRANSLATION["Create folder"], __submenus["TeleportFolders"], function(text)
		CreateRemoveThread(true, 'ui_refresh_'..thread_count, function()
			if text:isblank() then folder = nil return POP_THREAD end
			if text and not folders[text] then
				folder = text
			end
			return POP_THREAD
		end)
	end)
	ui.add_click_option(TRANSLATION['No folder'], __submenus["SaveLocation"], function() HudSound("SELECT") folder = nil end)

	ui.add_separator(TRANSLATION["Folders"], __submenus["SavedLocations"])
	local created_folders = {}
	CreateRemoveThread(true, 'ui_teleport_folders', function()
		ui.set_name(__options.click["TeleportSelectedFolder"], format(TRANSLATION["Folder: %s"], folder or TRANSLATION["None"]))
		for k, v in pairs(created_folders)
		do
			if not folders[k] then
				ui.remove(v)
			end
		end
		for k in pairs(folders)
		do
			if not created_folders[k] then
				created_folders[k] = ui.add_click_option(k, __submenus["TeleportFolders"], function()
					HudSound("SELECT")
					folder = k
				end)
			end
		end
	end)

	ui.add_click_option(TRANSLATION["Save"], __submenus["SaveLocation"], function()
		if not name or name:isblank() then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Please enter name"], 255, 0, 0, 255) return HudSound("ERROR") end
		HudSound("SELECT")
		CreateRemoveThread(true, 'ui_refresh_'..thread_count, function()
			local pos = features.get_player_coords()
			local heading = features.get_player_heading()
			insert(saved_locations, {
				folder = folder,
				name = name,
				x = pos.x,
				y = pos.y,
				z = pos.z,
				heading = heading
			})
			folder = nil
			RefreshLocations()
			SaveLocations()
			return POP_THREAD
		end)
	end)

	RefreshLocations()
end

__options.choose["TeleportMethod"] = ui.add_choose(TRANSLATION["Teleport method"], __submenus["Teleport"], true, {TRANSLATION["Load collision"]..'*', TRANSLATION["Fake teleport"]}, function(int) HudSound("YES")
	settings.Teleport["TeleportMethod"] = int
end)

local function UndoTeleport()
	local pos = last_teleports[#last_teleports]
	table_remove(last_teleports, #last_teleports)
	features.teleport(features.player_ped(), pos.x, pos.y, pos.z)
end

local function FixTeleport(Z, undo)
	CreateRemoveThread(true, 'fix_teleport', function(tick)
		if tick < 5 then return end
		local pos = features.get_player_coords()
		if tick > 20 then if undo then UndoTeleport();system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Land not found"], 255, 0, 0, 255) else features.teleport(features.player_ped(), pos.x, pos.y, Z + 2) end return POP_THREAD end
		local success, groundZ = features.get_ground_z(pos + vector3.up(20))
		local water, waterZ = features.get_water_z(pos + vector3.up(20))
		if not success then
			features.teleport(features.player_ped(), pos.x, pos.y, pos.z + 30)
			return
		elseif success and groundZ >= Z and groundZ >= waterZ then
			features.teleport(features.player_ped(), pos.x, pos.y, groundZ + 1)
			return POP_THREAD
		end
	end)
end

ui.add_click_option(TRANSLATION['Teleport to objective'], __submenus["Teleport"], function()
	local pos = features.get_blip_objective()
	if not pos then
		system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Blip not found"], 255, 0, 0, 255)
		HudSound("ERROR")
		return
	end
	insert(last_teleports, features.get_player_coords())
	HudSound("SELECT")
	features.teleport(features.player_ped(), pos.x, pos.y, pos.z)
end)

ui.add_click_option(TRANSLATION['Teleport to waypoint'], __submenus["Teleport"], function()
	if HUD.IS_WAYPOINT_ACTIVE() == 0 then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["No waypoint has been set"], 255, 0, 0, 255) return HudSound("ERROR") end
	HudSound("SELECT")
	insert(last_teleports, features.get_player_coords())
	local coords = features.get_waypoint_coord()
	local entity = features.player_ped()
	local result = cache:get(tostring(coords))
	if result then
		local pos = vector3(result)
		features.teleport(entity, pos.x, pos.y, pos.z)
		HUD.SET_WAYPOINT_OFF()
		return
	end
	local b_pos = features.get_blip_for_coord(coords)
	if b_pos then
		features.teleport(entity, b_pos.x, b_pos.y, b_pos.z)
		cache:set(tostring(coords), b_pos, 1000)
		insert(last_teleports, coords_mem)
		HUD.SET_WAYPOINT_OFF()
		tp = false
		return
	end
	local thread = 'teleport_'..thread_count
	CreateRemoveThread(true, thread, function(tick)
		system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Preparing teleport"], 0, 128, 255, 255)
		local Z = (tick+1) * 100
		if settings.Teleport["TeleportMethod"] == 0 then
			STREAMING.REQUEST_COLLISION_AT_COORD(coords.x, coords.y, Z)
		else
			features.fake_tp(coords.x, coords.y, Z)
		end
		local water, groundZ = features.get_water_z(vector3(coords.x, coords.y, 500))
		if not water or settings.Teleport["TeleportMethod"] == 1 then
			success, groundZ = features.get_ground_z(vector3(coords.x, coords.y, Z))
			if not success and Z < 900 then return end
			if not success and settings.Teleport["TeleportMethod"] == 0 then ticks[thread] = nil return end
		end
		HUD.SET_WAYPOINT_OFF()
		features.teleport(entity, coords.x, coords.y, groundZ + 1)
		if water or groundZ <= 10 then FixTeleport(groundZ) end
		cache:set(tostring(coords), vector3(coords.x, coords.y, groundZ + 1), 1000)
		return POP_THREAD
	end)	
end)

__options.bool["AutoTpToWp"] = ui.add_bool_option(TRANSLATION['Auto teleport to waypoint'], __submenus["Teleport"], function(bool) HudSound("TOGGLE_ON")
	settings.Teleport["AutoTpToWp"] = bool
	local tp
	CreateRemoveThread(bool, 'teleport_auto_to_wp', function()
		if HUD.IS_WAYPOINT_ACTIVE() == 0 or tp then return end
		local coords = features.get_waypoint_coord()
		if cache:get('bad'..tostring(coords)) then return end
		tp = true
		local coords_mem = features.get_player_coords()
		local entity = features.player_ped()
		local result = cache:get(tostring(coords))
		if result then
			local pos = vector3(result)
			features.teleport(entity, pos.x, pos.y, pos.z)
			insert(last_teleports, coords_mem)
			HUD.SET_WAYPOINT_OFF()
			tp = false
			return
		end
		local b_pos = features.get_blip_for_coord(coords)
		if b_pos then
			features.teleport(entity, b_pos.x, b_pos.y, b_pos.z)
			cache:set(tostring(coords), b_pos, 1000)
			insert(last_teleports, coords_mem)
			HUD.SET_WAYPOINT_OFF()
			tp = false
			return
		end
		local thread = 'teleport_'..thread_count
		local water, groundZ = features.get_water_z(vector3(coords.x, coords.y, 500))
		CreateRemoveThread(true, thread, function(tick)
			local Z = (tick+1) * 100
			local rot = features.get_entity_rot(entity, 5)
			ENTITY.SET_ENTITY_ROTATION(entity, 0, 0, rot.z, 5, true)
			if settings.Teleport["TeleportMethod"] == 0 and vehicles.get_player_vehicle() ~= 0 and VEHICLE.GET_VEHICLE_CLASS(vehicles.get_player_vehicle()) ~= 14 and not settings.Self["WalkOnWater"] and water then tp = false cache:set('bad'..tostring(coords), true, 10000);system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["I won't teleport you into water"]..' :(', 255, 0, 0, 255, true) return POP_THREAD end
			system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Preparing teleport"], 0, 128, 255, 255)
			if settings.Teleport["TeleportMethod"] == 0 then
				STREAMING.REQUEST_COLLISION_AT_COORD(coords.x, coords.y, Z)
			else
				features.fake_tp(coords.x, coords.y, Z > groundZ and Z or groundZ + 5)
			end
			if not water or settings.Teleport["TeleportMethod"] == 1 then
				local success, testZ = features.get_ground_z(vector3(coords.x, coords.y, Z))
				if (not success or testZ < groundZ) and (water and Z < 200 or Z < 900) then return end
				if not success and settings.Teleport["TeleportMethod"] == 0 then ticks[thread] = nil return end
				groundZ = testZ > groundZ and testZ or groundZ
			end
			features.teleport(entity, coords.x, coords.y, groundZ + 1)
			insert(last_teleports, coords_mem)
			HUD.SET_WAYPOINT_OFF()
			tp = false
			if water or groundZ <= 10 then FixTeleport(groundZ, vehicles.get_player_vehicle() ~= 0 and VEHICLE.GET_VEHICLE_CLASS(vehicles.get_player_vehicle()) ~= 14 and not settings.Self["WalkOnWater"]) end
			return POP_THREAD
		end)
	end)
end)

ui.add_click_option(TRANSLATION['Undo teleport'], __submenus["Teleport"], function()
	if #last_teleports == 0 then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["No teleport to undo"], 255, 0, 0, 255) return HudSound("ERROR") end 
	HudSound("SELECT")
	UndoTeleport()
end)

ui.add_separator(TRANSLATION["Forward"], __submenus["Teleport"])

__options.num['TpForwardDist'] = ui.add_num_option(TRANSLATION["Distance"], __submenus["Teleport"], 1, 50, 1, function(int) HudSound("YES") settings.Teleport['TpForwardDist'] = int end)
ui.add_click_option(TRANSLATION['Teleport Forward'], __submenus["Teleport"], function()
	HudSound("SELECT")
	insert(last_teleports, features.get_player_coords())
	local pos = features.get_offset_from_player_coords(vector3(0, settings.Teleport['TpForwardDist'], 0))
	features.teleport(features.player_ped(), pos.x, pos.y, pos.z)
end)

ui.add_separator(TRANSLATION["Clipboard"], __submenus["Teleport"])

ui.add_click_option(TRANSLATION['Copy position'], __submenus["Teleport"], function()
	system.log('My position', tostring(features.get_player_coords()))
	if system.is_safe_mode_enabled() then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["This feature requires Safe mode to be disabled"], 255, 0, 0, 255) return HudSound("ERROR") end
	HudSound("SELECT")
	features.to_clipboard(tostring(features.get_player_coords()), true)
end)

ui.add_click_option(TRANSLATION['Teleport from clipboard'], __submenus["Teleport"], function()
	if system.is_safe_mode_enabled() then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["This feature requires Safe mode to be disabled"], 255, 0, 0, 255) return HudSound("ERROR") end
	local data = system.from_clipboard():split('%,', true)
	for i, v in ipairs(data)
	do
		local num = v:gsub('[^%-%d%.]', '')
		data[i] = num and tonumber(num) or nil
	end
	if not data[1] or not data[2] then system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["I can't find any Vector3 or Vector2 data in clipboard, expected format (x, y, z)"], 255, 0, 0, 255) return HudSound("ERROR") end 
	HudSound("SELECT")
	insert(last_teleports, features.get_player_coords())
	if not data[3] then
		local pos = cache:get(tostring(data[1]..', '..data[2]))
		if pos then
			features.teleport(features.player_ped(), pos.x, pos.y, pos.z)
			return
		end
		local thread = 'teleport_'..thread_count
		CreateRemoveThread(true, thread, function(tick)
			system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Preparing teleport"], 0, 128, 255, 255)
			local Z = (tick+1) * 100
			if settings.Teleport["TeleportMethod"] == 0 then
				STREAMING.REQUEST_COLLISION_AT_COORD(data[1], data[2], Z)
			else
				features.fake_tp(data[1], data[2], Z)
			end
			local water, groundZ = features.get_water_z(vector3(data[1], data[2], 500))
			if not water or settings.Teleport["TeleportMethod"] == 1 then
				success, groundZ = features.get_ground_z(vector3(data[1], data[2], Z))
				if not success and Z < 900 then return end
				if not success and settings.Teleport["TeleportMethod"] == 0 then ticks[thread] = nil return end
			end
			features.teleport(features.player_ped(), data[1], data[2], groundZ + 1)
			if water or groundZ <= 10 then FixTeleport(groundZ) return POP_THREAD end
			cache:set(tostring(data[1]..', '..data[2]), vector3(data[1], data[2], groundZ + 1), 1000)
			return POP_THREAD
		end)
	else
		features.teleport(features.player_ped(), data[1], data[2], data[3])
	end
end)

ui.add_separator(TRANSLATION['Input coords'], __submenus["Teleport"])

do
	local tp = vector3.zero()
	ui.add_click_option(TRANSLATION["Get current position"], __submenus["Teleport"], function()
		HudSound("SELECT")
		local pos = features.get_player_coords()
		dont_play_tog = true
		ui.set_value(__options.num["InputCoordX"], pos.x, false)
		ui.set_value(__options.num["InputCoordY"], pos.y, false)
		ui.set_value(__options.num["InputCoordZ"], pos.z, false)
	end)
	__options.num["InputCoordX"] = ui.add_float_option('X', __submenus["Teleport"], -10000, 10000, 1, 3, function(float) HudSound("YES") tp.x = float end)
	__options.num["InputCoordY"] = ui.add_float_option('Y', __submenus["Teleport"], -10000, 10000, 1, 3, function(float) HudSound("YES") tp.y = float end)
	__options.num["InputCoordZ"] = ui.add_float_option('Z', __submenus["Teleport"], -10000, 10000, 1, 3, function(float) HudSound("YES") tp.z = float end)
	ui.add_click_option(TRANSLATION['Teleport'], __submenus["Teleport"], function()
		HudSound("SELECT")
		insert(last_teleports, features.get_player_coords())
		features.teleport(features.player_ped(), tp.x, tp.y, tp.z)
	end)
end

---------------------------------------------------------------------------------------------------------------------------------
-- Weapons
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'weapons submenu') end
__submenus["Weapons"] = ui.add_submenu(TRANSLATION["Weapons"])
__suboptions["Weapons"] = ui.add_sub_option(TRANSLATION["Weapons"], __submenus["MainSub"], __submenus["Weapons"])

__submenus["AimAssist"] = ui.add_submenu(TRANSLATION["Aim assist"])
__suboptions["Weapons"] = ui.add_sub_option(TRANSLATION["Aim assist"], __submenus["Weapons"], __submenus["AimAssist"])

ui.add_separator(TRANSLATION["Targets"], __submenus["AimAssist"])

__options.bool["TargetPeds"] = ui.add_bool_option(TRANSLATION['Target NPCs'], __submenus["AimAssist"], function(bool) HudSound("TOGGLE_ON") settings.Weapons["TargetPeds"] = bool end)
__options.bool["TargetPlayers"] = ui.add_bool_option(TRANSLATION['Target players'], __submenus["AimAssist"], function(bool) HudSound("TOGGLE_ON") settings.Weapons["TargetPlayers"] = bool end)
__options.bool["TargetEnemies"] = ui.add_bool_option(TRANSLATION['Target enemies'], __submenus["AimAssist"], function(bool) HudSound("TOGGLE_ON") settings.Weapons["TargetEnemies"] = bool end)
__options.bool["TargetCops"] = ui.add_bool_option(TRANSLATION['Target cops'], __submenus["AimAssist"], function(bool) HudSound("TOGGLE_ON") settings.Weapons["TargetCops"] = bool end)

do
	local bone_id = {
		[0] = 0x796e,
		0x9995,
		0xe0fd,
		0x3fcf
	}
	__options.choose["AimBone"] = ui.add_choose(TRANSLATION['Bone'], __submenus["AimAssist"], true, {TRANSLATION["Head"]..'*', TRANSLATION["Neck"], TRANSLATION["Spine"], TRANSLATION["Knee"]}, function(int) HudSound("YES") settings.Weapons["AimBone"] = int end)

	ui.add_separator(TRANSLATION["Assistance"], __submenus["AimAssist"])

	__options.bool["Triggerbot"] = ui.add_bool_option(TRANSLATION['Triggerbot'], __submenus["AimAssist"], function(bool) HudSound("TOGGLE_ON")
		settings.Weapons["Triggerbot"] = bool 
		CreateRemoveThread(bool, "weapons_trigger",
		function()	
			if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 and ENTITY.IS_ENTITY_DEAD(features.player_ped(), false) == 0 then
				local entity = features.get_aimed_ped()
				if entity == 0 then return end
				if ENTITY.IS_ENTITY_A_PED(entity) == 1 and ENTITY.IS_ENTITY_DEAD(entity, false) == 0 and not (settings.General['Exclude Friends'] and features.is_friend(features.get_player_from_ped(v))) and not features.is_excluded(features.get_player_from_ped(v)) then
					local triggered
					if settings.Weapons["TargetPlayers"] and PED.IS_PED_A_PLAYER(entity) == 1 then
						triggered = true
					elseif settings.Weapons["TargetEnemies"] and peds.is_ped_an_enemy(entity) then
						triggered = true
					elseif settings.Weapons["TargetCops"] and (PED.GET_PED_TYPE(entity) == 6 or PED.GET_PED_TYPE(entity) == 27) then
						triggered = true
					end
					if triggered or settings.Weapons["TargetPeds"] then
						-- PAD._SET_CONTROL_NORMAL(0, enum.input.ATTACK, 1)

						local coord = vector3(ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(entity, PED.GET_PED_BONE_INDEX(entity, bone_id[settings.Weapons["AimBone"]])))
						if not (coord == vector3.zero()) then
							if PED.IS_PED_IN_ANY_VEHICLE(entity, false) == 1 then
								coord.z = coord.z + .08
							end
							PED.SET_PED_SHOOTS_AT_COORD(features.player_ped(), coord.x, coord.y, coord.z, true)
						end
					end
				end
			end
		end)
	end)

	ui.add_separator(TRANSLATION["Aimbot"], __submenus["AimAssist"])
	__options.bool["AimbotWallCheck"] = ui.add_bool_option(TRANSLATION["Wall check"]..'*', __submenus["AimAssist"], function(bool) HudSound("TOGGLE_ON") settings.Weapons["AimbotWallCheck"] = bool end)
	__options.bool["AimbotFollowTarget"] = ui.add_bool_option(TRANSLATION["Follow target"], __submenus["AimAssist"], function(bool) HudSound("TOGGLE_ON") settings.Weapons["AimbotFollowTarget"] = bool end)
	__options.bool["AimbotShowBox"] = ui.add_bool_option(TRANSLATION["Show box"], __submenus["AimAssist"], function(bool) HudSound("TOGGLE_ON") settings.Weapons["AimbotShowBox"] = bool end)
	__options.num["AimbotDistance"] = ui.add_float_option(TRANSLATION["Distance"], __submenus["AimAssist"], 10, 1500, 10, 3, function(float) HudSound("YES") settings.Weapons["AimbotDistance"] = features.round(float, 3) end)
	__options.num["AimbotFov"] = ui.add_num_option(TRANSLATION["FOV"], __submenus["AimAssist"], 10, 360, 10, function(int) HudSound("YES") settings.Weapons["AimbotFov"] = int end)
	__options.choose["AimbotPrioritize"] = ui.add_choose(TRANSLATION["Prioritize"], __submenus["AimAssist"], true, {TRANSLATION["Distance"], TRANSLATION["Screen center"]..'*'}, function(int) HudSound("YES") settings.Weapons["AimbotPrioritize"] = int end)
	__options.bool["AimbotDrawFov"] = ui.add_bool_option(TRANSLATION['Draw FOV'], __submenus["AimAssist"], function(bool) HudSound("TOGGLE_ON") settings.Weapons["AimbotDrawFov"] = bool end)

	__options.bool["Aimbot"] = ui.add_bool_option(TRANSLATION['Aimbot'], __submenus["AimAssist"], function(bool) HudSound("TOGGLE_ON")
		settings.Weapons["Aimbot"] = bool 
		local entity
		CreateRemoveThread(bool, "weapons_aimbot",
		function()	
			if ENTITY.IS_ENTITY_DEAD(features.player_ped(), false) == 0 then
				local fov = (settings.Weapons["AimbotFov"]) ^ 2
				local pos = features.get_player_coords()
				local move_to
				local distance = settings.Weapons["AimbotDistance"] * settings.Weapons["AimbotDistance"]
				local cent = features.get_screen_center()
				local res = features.get_screen_resolution()
				if settings.Weapons["AimbotDrawFov"] then
					local to_x = (1 / res.x)
					local to_y = (1 / res.y)
					local points = vector3(cent.x, cent.y):points_on_circle(settings.Weapons["AimbotFov"], settings.Weapons["AimbotFov"])
					for _, v in ipairs(points)
					do
						GRAPHICS.DRAW_RECT(v.x * to_x, v.y * to_y, 2 * to_x, 2 * to_y, 255, 255, 255, 100, false)
					end
				end
				if not settings.Weapons["AimbotFollowTarget"] then
					entity = nil
				end
				if not entity then
					for _, v in ipairs(entities.get_peds())
					do
						if v ~= features.player_ped() and ENTITY.IS_ENTITY_DEAD(v, false) == 0 and ENTITY.IS_ENTITY_ON_SCREEN(v) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(features.get_player_from_ped(v))) and not features.is_excluded(features.get_player_from_ped(v)) then
							local triggered
							if settings.Weapons["TargetPlayers"] and PED.IS_PED_A_PLAYER(v) == 1 then
								triggered = true
							elseif settings.Weapons["TargetEnemies"] and peds.is_ped_an_enemy(v) then
								triggered = true
							elseif settings.Weapons["TargetCops"] and features.compare(PED.GET_PED_TYPE(v), 6, 27) then
								triggered = true
							end
							local dist = features.get_entity_coords(v):sqrlen(pos)
							-- local dir = pos:direction_to(vector3(ENTITY.GET_ENTITY_COORDS(v, false)))
							local screen_pos = features.world_to_screen(ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(v, PED.GET_PED_BONE_INDEX(v, bone_id[settings.Weapons["AimBone"]])))
							local dist_to_sc = cent:sqrlen(vector3(res.x * screen_pos.x, res.y * screen_pos.y))
							if (triggered or settings.Weapons["TargetPeds"]) and dist < distance and dist_to_sc <= fov then
								entity = v
								if settings.Weapons["AimbotPrioritize"] == 0 then
									distance = dist
								else
									fov = dist_to_sc
								end
							end
						end
					end
				elseif entity and (ENTITY.IS_ENTITY_DEAD(entity, false) == 1 or ENTITY.DOES_ENTITY_EXIST(entity) == 0 or ENTITY.IS_ENTITY_ON_SCREEN(entity) == 0) then
					entity = nil
				end

				if entity then
					if settings.Weapons["AimbotWallCheck"] then
						local result = features.get_raycast_result(features.get_player_coords(), features.get_entity_coords(entity), features.player_ped(), 1)
						if result.didHit then entity = nil return end
					end
					local screen_pos = features.world_to_screen(ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(entity, PED.GET_PED_BONE_INDEX(entity, bone_id[settings.Weapons["AimBone"]])))
					if settings.Weapons["AimbotFollowTarget"] and PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 --[[and ENTITY.IS_ENTITY_ON_SCREEN(entity) == 1]] then
						local pos_on_screen = vector3(res.x * screen_pos.x, res.y * screen_pos.y)
						if pos_on_screen ~= vector3.zero() then
							local dist = pos_on_screen:len(cent)
							move_to = (cent:direction_to(pos_on_screen) * dist) / 100
						end
					end
					if move_to then
						PAD._SET_CONTROL_NORMAL(0, enum.input.LOOK_LR, move_to.x)
						PAD._SET_CONTROL_NORMAL(0, enum.input.LOOK_UD, move_to.y)
					end
					local coord = vector3(ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(entity, PED.GET_PED_BONE_INDEX(entity, bone_id[settings.Weapons["AimBone"]])))
					if settings.Weapons["AimbotShowBox"] then
						features.draw_box_on_entity(entity, 0, 0, 255, 100)
					end
					PAD.DISABLE_CONTROL_ACTION(0, enum.input.ATTACK, true)
					PAD.DISABLE_CONTROL_ACTION(0, enum.input.ATTACK2, true)
					if not (PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.ATTACK) == 1 or PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.ATTACK2) == 1) then return end
					if not (coord == vector3.zero()) then
						if PED.IS_PED_IN_ANY_VEHICLE(entity, false) == 1 then
							coord.z = coord.z + .08
						end
						PED.SET_PED_SHOOTS_AT_COORD(features.player_ped(), coord.x, coord.y, coord.z, true)
					end
				end
			end
		end)
	end)

	__options.bool["AutoShoot"] = ui.add_bool_option(TRANSLATION['Auto shoot'], __submenus["AimAssist"], function(bool) HudSound("TOGGLE_ON")
		settings.Weapons["AutoShoot"] = bool 
		CreateRemoveThread(bool, "weapons_auto_shoot",
		function()	
			if ENTITY.IS_ENTITY_DEAD(features.player_ped(), false) == 0 then
				local pos = features.get_player_coords()
				local entity
				local distance = settings.Weapons["AimbotDistance"] * settings.Weapons["AimbotDistance"]
				for _, v in ipairs(entities.get_peds())
				do
					if v ~= features.player_ped() and ENTITY.IS_ENTITY_DEAD(v, false) == 0 and not (settings.General['Exclude Friends'] and features.is_friend(features.get_player_from_ped(v))) and not features.is_excluded(features.get_player_from_ped(v)) then
						local triggered
						if settings.Weapons["TargetPlayers"] and PED.IS_PED_A_PLAYER(v) == 1 then
							triggered = true
						end
						if settings.Weapons["TargetEnemies"] and peds.is_ped_an_enemy(v) then
							triggered = true
						end
						if settings.Weapons["TargetCops"] and features.compare(PED.GET_PED_TYPE(v), 6, 27) then
							triggered = true
						end
						local dist = features.get_entity_coords(v):sqrlen(pos)
						if (triggered or settings.Weapons["TargetPeds"]) and dist < distance then
							entity = v
							distance = dist
						end
					end
				end
				if entity then
					local coord = vector3(ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(entity, PED.GET_PED_BONE_INDEX(entity, bone_id[settings.Weapons["AimBone"]])))
					if settings.Weapons["AimbotWallCheck"] then
						local result = features.get_raycast_result(features.get_player_coords(), coord, features.player_ped(), 1)
						if result.didHit then return end
					end
					if not (coord == vector3.zero()) then
						if PED.IS_PED_IN_ANY_VEHICLE(entity, false) == 1 then
							coord.z = coord.z + .08
						end
						if settings.Weapons["AimbotShowBox"] then
							features.draw_box_on_entity(entity, 0, 0, 255, 100)
						end
						PED.SET_PED_SHOOTS_AT_COORD(features.player_ped(), coord.x, coord.y, coord.z, true)
					end
				end
			end
		end)
	end)

end

__options.bool["RapidFire"] = ui.add_bool_option(TRANSLATION['Rapid fire'], __submenus["Weapons"], function(bool) HudSound("TOGGLE_ON")
	settings.Weapons['RapidFire'] = bool
	CreateRemoveThread(bool, 'rapid_fire',
	function()
		local weaponhash = features.get_ped_weapon()
		if WEAPON.GET_WEAPONTYPE_GROUP(weaponhash) == enum.weapon_group.Melee then
			return
		end
		WEAPON.REQUEST_WEAPON_ASSET(weaponhash, 31, 0)
		if WEAPON.HAS_WEAPON_ASSET_LOADED(weaponhash) == 0 then return end
		PAD.DISABLE_CONTROL_ACTION(0, enum.input.ATTACK, true)
		PAD.DISABLE_CONTROL_ACTION(0, enum.input.ATTACK2, true)
		if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.ATTACK) == 1 then
			local ped = features.player_ped()
			local weapo = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(ped, 1)
			local cam_dir = features.gameplay_cam_rot():rot_to_direction()
			local cam_pos = features.gameplay_cam_pos()
			local pos1 = cam_pos + (cam_dir * (cam_pos:len(features.get_entity_coords(weapo)) + 0.4))
			local pos2 = cam_pos + (cam_dir * 200)
			-- MISC.CLEAR_AREA_OF_PROJECTILES(pos1.x, pos1.y, pos1.z, 6, 0)
			MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z, 5, true, weaponhash, ped, true, true, 24000)
			MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z, 5, true, weaponhash, ped, true, true, 24000)
		end
	end)
end)

__options.bool["DriveGun"] = ui.add_bool_option(TRANSLATION['Drive gun'], __submenus["Weapons"], function(bool) HudSound("TOGGLE_ON")
	settings.Weapons['DriveGun'] = bool
	CreateRemoveThread(bool, 'weapons_drivegun',
	function()
		if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 and PED.IS_PED_SHOOTING(features.player_ped()) == 1 then
			local entity = features.get_aimed_entity()
			if entity == 0 then return end
			local veh
			local ped
			if ENTITY.IS_ENTITY_A_PED(entity) == 1 then
				veh = PED.GET_VEHICLE_PED_IS_IN(entity, false)
				ped = entity
			elseif ENTITY.IS_ENTITY_A_VEHICLE(entity) == 1 then
				veh = entity
			end
			if veh and not features.compare(veh, created_preview, created_preview2) then
				CreateRemoveThread(true, 'seat_change_'..thread_count, function(tick)
					if tick == 100 then return POP_THREAD end
					if ped and ped ~= features.player_ped() and veh ~= 0 then
						TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
					end
					features.request_control_once(veh) 
					PED.SET_PED_INTO_VEHICLE(features.player_ped(), veh, -1)
					if VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, true) ~= features.player_ped() then return end
					return POP_THREAD
				end)
			end
		end
	end)
end)

do
	local entity
	local gunactive
	local distance
	__options.bool["PickUpGun"] = ui.add_bool_option(TRANSLATION['Pick up gun'], __submenus["Weapons"], function(bool) HudSound("TOGGLE_ON")
		settings.Weapons['PickUpGun'] = bool
		CreateRemoveThread(bool, 'weapons_pickup_gun',
		function()
			if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 then
				if gunactive then return end
				if not entity then
					entity = features.get_aimed_entity()
					if entity == 0 then entity = nil return end
					if ENTITY.IS_ENTITY_A_PED(entity) == 1 and PED.IS_PED_IN_ANY_VEHICLE(entity, true) == 1 then
						entity = PED.GET_VEHICLE_PED_IS_IN(entity, false)
					end
					local pos = features.gameplay_cam_pos()
					distance = pos:len(features.get_entity_coords(entity))
				end
				PAD.DISABLE_CONTROL_ACTION(0, enum.input.WEAPON_WHEEL_NEXT, true)
        PAD.DISABLE_CONTROL_ACTION(0, enum.input.WEAPON_WHEEL_PREV, true)
        PAD.DISABLE_CONTROL_ACTION(0, enum.input.MULTIPLAYER_INFO, true)
        PAD.DISABLE_CONTROL_ACTION(0, enum.input.SPRINT, true)
        PAD.DISABLE_CONTROL_ACTION(0, enum.input.JUMP, true)
        PAD.DISABLE_CONTROL_ACTION(0, enum.input.FRONTEND_RS, true)
        features.request_control_once(entity)
      	local radmult = 10
        if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.SPRINT) == 1 then
            radmult = 1
        end
        local rot = features.get_entity_rot(entity)
        if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.WEAPON_WHEEL_NEXT) == 1 then
          if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.FRONTEND_RS) == 1 then
              ENTITY.SET_ENTITY_ROTATION(entity, rot.x-1*radmult, rot.y, rot.z, 2, true)
          elseif PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.JUMP) == 1 then
              ENTITY.SET_ENTITY_ROTATION(entity, rot.x, rot.y-1*radmult, rot.z, 2, true)
          elseif PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.MULTIPLAYER_INFO) == 1 then
              ENTITY.SET_ENTITY_ROTATION(entity, rot.x, rot.y, rot.z-1*radmult, 2, true)
          else
              distance = (distance - radmult) < 5 and 5 or distance - radmult
          end
        elseif PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.WEAPON_WHEEL_PREV) == 1 then
          if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.FRONTEND_RS) == 1 then
              ENTITY.SET_ENTITY_ROTATION(entity, rot.x+1*radmult, rot.y, rot.z, 2, true)
          elseif PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.JUMP) == 1 then
              ENTITY.SET_ENTITY_ROTATION(entity, rot.x, rot.y+1*radmult, rot.z, 2, true)
          elseif PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.MULTIPLAYER_INFO) == 1 then
              ENTITY.SET_ENTITY_ROTATION(entity, rot.x, rot.y, rot.z+1*radmult, 2, true)
          else
              distance = distance + radmult
          end
        end
        if settings.General["ShowControls"] and Instructional:New() then
		    	Instructional.AddButton(enum.input.WEAPON_WHEEL_NEXT, TRANSLATION["Towards me"])
		    	Instructional.AddButton(enum.input.WEAPON_WHEEL_PREV, TRANSLATION["Outwards me"])
		    	Instructional.AddButton(enum.input.FRONTEND_RS, TRANSLATION["Pitch"])
		    	Instructional.AddButton(enum.input.JUMP, TRANSLATION["Roll"])
		    	Instructional.AddButton(enum.input.MULTIPLAYER_INFO, TRANSLATION["Yaw"])
		    	Instructional.AddButton(enum.input.JUMP, TRANSLATION["Precision"])
		    	Instructional:BackgroundColor(0, 0, 0, 80)
		    	Instructional:Draw()
		    end
        local dir = features.gameplay_cam_rot():rot_to_direction()
				local camcoord = features.gameplay_cam_pos()
				local target_pos = camcoord + dir * distance
				ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, target_pos.x, target_pos.y, target_pos.z, false, false, false)
				if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, enum.input.ATTACK2) == 1 then
					if ENTITY.IS_ENTITY_A_PED(entity) == 1 then
						PED.SET_PED_TO_RAGDOLL(entity, 5000, 5000, 0, true, true, false)
					end
					local force = dir * 500
					ENTITY.FREEZE_ENTITY_POSITION(entity, false)
          features.set_entity_velocity(entity, force.x, force.y, force.z)
          gunactive = true
        end
        return
			elseif entity then
				entity = nil
				return
			end
			gunactive = false
		end)
	end)
end

do
	local entity
	local gunactive
	local distance
	__options.bool["GravityGun"] = ui.add_bool_option(TRANSLATION['Gravity gun'], __submenus["Weapons"], function(bool) HudSound("TOGGLE_ON")
		settings.Weapons['GravityGun'] = bool
		CreateRemoveThread(bool, 'weapons_gravity_gun',
		function()
			if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 then
				if not entity then
					entity = features.get_aimed_entity()
					if entity == 0 then entity = nil return end
					if ENTITY.IS_ENTITY_A_PED(entity) == 1 and PED.IS_PED_IN_ANY_VEHICLE(entity, true) == 1 then
						entity = PED.GET_VEHICLE_PED_IS_IN(entity, false)
					end
					distance = 10
				end
				if gunactive then return end
				PAD.DISABLE_CONTROL_ACTION(0, enum.input.WEAPON_WHEEL_NEXT, true)
        PAD.DISABLE_CONTROL_ACTION(0, enum.input.WEAPON_WHEEL_PREV, true)
        PAD.DISABLE_CONTROL_ACTION(0, enum.input.SPRINT, true)
      	local radmult = 10
        if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.SPRINT) == 1 then
            radmult = 1
        end
        if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.WEAPON_WHEEL_NEXT) == 1 then
          distance = distance - radmult
          if distance < 5 then distance = 5 end
        elseif PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.WEAPON_WHEEL_PREV) == 1 then
          distance = distance + radmult
        end
        local dir = features.gameplay_cam_rot():rot_to_direction()
				local camcoord = features.gameplay_cam_pos()
				local target_pos = camcoord + dir * distance
				GRAPHICS._DRAW_SPHERE(target_pos.x, target_pos.y, target_pos.z, 0.2, 255, 0, 255, 0.5)
				local pos = features.get_entity_coords(entity)
				local force_to = (target_pos - pos) * 3
				ENTITY.FREEZE_ENTITY_POSITION(entity, false)
				features.request_control_once(entity)
				features.set_entity_velocity(entity, force_to.x, force_to.y, force_to.z)
				if PAD.IS_DISABLED_CONTROL_JUST_PRESSED(0, enum.input.ATTACK2) == 1 then
					if ENTITY.IS_ENTITY_A_PED(entity) == 1 then
						PED.SET_PED_TO_RAGDOLL(entity, 5000, 5000, 0, true, true, false)
					end
					local force = dir * 500
					entities.request_control(entity, function()
						ENTITY.FREEZE_ENTITY_POSITION(entity, false)
	          features.set_entity_velocity(entity, force.x, force.y, force.z)
	         end)
          gunactive = true
        end
        return
			elseif entity then
				entity = nil
				return
			end
			gunactive = false
		end)
	end)
end

__options.bool["GrappleHookGun"] = ui.add_bool_option(TRANSLATION["Grapple hook gun"], __submenus["Weapons"], function(bool) HudSound("TOGGLE_ON")
	settings.Weapons["GrappleHookGun"] = bool
	CreateRemoveThread(bool, 'weapons_grapple_hook', function()
		if vehicles.get_player_vehicle() ~= 0 or PED.IS_PED_SHOOTING(features.player_ped()) == 0 then return end
		local start = features.gameplay_cam_pos()
		local end_pos = start + features.gameplay_cam_rot():rot_to_direction() * 1500
		local result = features.get_raycast_result(start, end_pos, features.player_ped(), 1+2+4+8+16)
		local pos = result.endCoords
		if pos == vector3.zero() then return end
		CreateRemoveThread(true, 'hook_gun', function()
			if vehicles.get_player_vehicle() ~= 0 then return POP_THREAD end
			TASK.TASK_SKY_DIVE(features.player_ped(), true)
			features.oscillate_to_coord(features.player_ped(), pos, 5)
			if ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(features.player_ped()) == 0 and features.get_player_coords():sqrlen(pos) > 4 then return end
			TASK.CLEAR_PED_TASKS_IMMEDIATELY(features.player_ped())
			features.set_entity_velocity(features.player_ped(), 0, 0, 0)
			return POP_THREAD
		end)
	end)
end)

__options.bool["PTFXGun"] = ui.add_bool_option(TRANSLATION["Particle FX gun"], __submenus["Weapons"], function(bool) HudSound("TOGGLE_ON")
	settings.Weapons["PTFXGun"] = bool
	CreateRemoveThread(bool, 'weapons_ptfx_gun', function()
		if STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_rcbarry2") == 0 then
			STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2")
			return
		end
		if PED.IS_PED_SHOOTING(features.player_ped()) == 0 then return end
		local weapon = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(features.player_ped(), false)
		GRAPHICS.USE_PARTICLE_FX_ASSET("scr_rcbarry2")
		GRAPHICS._START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY_BONE("muz_clown", weapon, 0, 0, 0, 90, 0, 0, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(weapon, "gun_muzzle"), .5, false, false, false)
	end)
end)

__options.bool["SuperPunch"] = ui.add_bool_option(TRANSLATION["Super punch"], __submenus["Weapons"], function(bool) HudSound("TOGGLE_ON")
	settings.Weapons["SuperPunch"] = bool
	local punch
	local result
	local wait
	local playing
	local anim_dict = "melee@thrown@streamed_core"
	local anim_name = "plyr_takedown_rear"
	if not bool then
		STREAMING.REMOVE_ANIM_DICT(anim_dict)
		STREAMING.REMOVE_NAMED_PTFX_ASSET("scr_trevor1")
	end
	CreateRemoveThread(bool, 'weapons_super_punch', function()
		if STREAMING.HAS_ANIM_DICT_LOADED(anim_dict) == 0 then
			STREAMING.REQUEST_ANIM_DICT(anim_dict)
			return
		end
		if STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_trevor1") == 0 then 
			STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_trevor1")
			return
		end
		local addr = s_memory.get_memory_address(s_memory.WorldPtr, {0x08, 0x10C8, 0xCF0})
		if addr ~= 0 then
			memory.write_float(addr, ui.get_value(__options.num["RunSpeed"]))
		end
		if wait and wait > clock() then features.set_entity_velocity(features.player_ped(), 0, 0, 0) return end
		wait = nil
		if PAD.IS_CONTROL_RELEASED(0, enum.input.ATTACK2) == 1 then punch = nil end
		if vehicles.get_player_vehicle() ~= 0 or features.get_ped_weapon() ~= -1569615261 then return end
		PAD.DISABLE_CONTROL_ACTION(0, enum.input.ATTACK, true)
		if result and not playing and PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.ATTACK) == 1 and features.get_entity_coords(result.hitEntity):sqrlen(features.get_player_coords()) < 27 + select(2, features.get_model_dimentions(ENTITY.GET_ENTITY_MODEL(result.hitEntity))).y ^ 2 then
			peds.play_anim(features.player_ped(), anim_dict, anim_name, 8, -8, 1000, enum.anim_flag.AllowPlayerControl, 0, false)
			playing = true
			local _wait = clock() + .6
			CreateRemoveThread(true, 'hit_entity', function(tick)
				if tick%10 == 0 then
					GRAPHICS.USE_PARTICLE_FX_ASSET("scr_trevor1")
					GRAPHICS._START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY_BONE("scr_trev1_trailer_boosh", features.player_ped(), 0, 0, 0, 0, 0, 0, PED.GET_PED_BONE_INDEX(features.player_ped(), 0xdead), .3, false, false, false)
				end
				if _wait > clock() then return end
				if ENTITY.IS_ENTITY_A_PED(result.hitEntity) == 1 then
					PED.SET_PED_TO_RAGDOLL(result.hitEntity, 5000, 5000, 0, true, true, false)
				else
					wait = clock() + .5
					punch = nil
				end
				playing = nil
				entities.request_control(result.hitEntity, function()
					local rot = features.get_entity_rot(features.player_ped())
					local force = rot:rot_to_direction() * 200
					features.set_entity_velocity(result.hitEntity, force.x, force.y, force.z)
				end)
				return POP_THREAD
			end)
			return
		end

		local impact = features.get_bullet_impact()
		if impact ~= vector3.zero() then
			local ent = features.get_closest_entity_to_coord(impact, 49)
			entities.request_control(ent, function()
				if ENTITY.IS_ENTITY_A_PED(ent) == 1 then
					PED.SET_PED_TO_RAGDOLL(ent, 5000, 5000, 0, true, true, false)
				end
				local rot = features.get_entity_rot(features.player_ped())
				local force = rot:rot_to_direction() * 50
				features.set_entity_velocity(ent, force.x, force.y, force.z)
			end)
		end

		if not punch then
			local start = features.gameplay_cam_pos()
			local end_pos = start + features.gameplay_cam_rot():rot_to_direction() * 100
			result = features.get_raycast_result(start, end_pos, features.player_ped(), 2+4+8)
			if not result.didHit then return end
			local pos = features.get_entity_coords(result.hitEntity)
			if pos == vector3.zero() then return end
			local my_pos = features.get_player_coords()
			GRAPHICS.DRAW_LINE(my_pos.x, my_pos.y, my_pos.z, pos.x, pos.y, pos.z, 0, 100, 255, 255)
			features.draw_box_on_entity(result.hitEntity, 0, 100, 255, 255)
			if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.ATTACK) == 0 then return end
			punch = true
		else
			local my_pos = features.get_player_coords()
			local pos = features.get_entity_coords(result.hitEntity)
			GRAPHICS.DRAW_LINE(my_pos.x, my_pos.y, my_pos.z, pos.x, pos.y, pos.z, 255, 0, 0, 255)
			features.draw_box_on_entity(result.hitEntity, 255, 0, 0, 255)
			if addr ~= 0 then
				memory.write_float(addr, 5)
			end
			features.set_entity_face_entity(features.player_ped(), result.hitEntity)
			features.oscillate_to_coord(features.player_ped(), pos, 16)
		end
	end)
end)

do
	__options.num["FlamethrowerScale"] = ui.add_num_option(TRANSLATION["Flamethrower scale"], __submenus["Weapons"], 1, 25, 1, function(int) HudSound("YES") settings.Weapons["FlamethrowerScale"] = int end)
	__options.choose["Flamethrower"] = ui.add_choose(TRANSLATION["Flamethrower"], __submenus["Weapons"], true, {TRANSLATION["None"], TRANSLATION["Orange"], TRANSLATION["Green"]}, function(int) HudSound("YES") settings.Weapons["Flamethrower"] = int end)
	local type = settings.Weapons["Flamethrower"]
	local flame
	local chip
	CreateRemoveThread(true, 'weapons_flamethrower', function() 
		if settings.Weapons["FlamethrowerScale"] == 0 then
			if flame then
				GRAPHICS.REMOVE_PARTICLE_FX(flame, true)
				features.delete_entity(chip)
				STREAMING.REMOVE_NAMED_PTFX_ASSET("weap_xs_vehicle_weapons")
				flame = nil
				chip = nil
		    end
		  	return
		end
		if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 then
			if STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("weap_xs_vehicle_weapons") == 0 then
			    STREAMING.REQUEST_NAMED_PTFX_ASSET("weap_xs_vehicle_weapons")
			    return
		  	end
			if not chip then
				local loaded, hash = features.request_model(utils.joaat("prop_crisp_small"))
				local pos = features.get_player_coords()
				chip = features.create_object(hash, pos)
				ENTITY.SET_ENTITY_COLLISION(chip, false, true)
				ENTITY.SET_ENTITY_ALPHA(chip, 0, false)
				STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
			end
			local pos_h = PED.GET_PED_BONE_COORDS(features.player_ped(), 57005, 0, 0, 0)
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(chip, pos_h.x, pos_h.y, pos_h.z, false, false, false)
			local rot = CAM.GET_GAMEPLAY_CAM_ROT(5)
			ENTITY.SET_ENTITY_ROTATION(chip, rot.x, rot.y, rot.z, 5, true)
			if flame == nil then
				GRAPHICS.USE_PARTICLE_FX_ASSET("weap_xs_vehicle_weapons")
				if settings.Weapons["Flamethrower"] == 1 then
					flame = GRAPHICS.START_PARTICLE_FX_LOOPED_ON_ENTITY("muz_xs_turret_flamethrower_looping", chip, 0, 0, 0, 0, 0, 0, settings.Weapons["FlamethrowerScale"], false, false, false)
				elseif settings.Weapons["Flamethrower"] == 2 then
					flame = GRAPHICS.START_PARTICLE_FX_LOOPED_ON_ENTITY("muz_xs_turret_flamethrower_looping_sf", chip, 0, 0, 0, 0, 0, 0, settings.Weapons["FlamethrowerScale"], false, false, false)
				end
				type = settings.Weapons["Flamethrower"]
			end
			if flame then
				GRAPHICS.SET_PARTICLE_FX_LOOPED_SCALE(flame, settings.Weapons["FlamethrowerScale"])
			end
    	end
	    if (flame and PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 0) or (flame and type ~= settings.Weapons["Flamethrower"] and PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1) then
			GRAPHICS.REMOVE_PARTICLE_FX(flame, true)
			flame = nil
			features.delete_entity(chip)
			chip = nil
	    end
	end)
end

do
	local types = {TRANSLATION["None"], HUD._GET_LABEL_TEXT("WT_SNIP_HVY2"), HUD._GET_LABEL_TEXT("WT_RPG"), HUD._GET_LABEL_TEXT("WT_MOLOTOV"), HUD._GET_LABEL_TEXT("WT_SNWBALL"), HUD._GET_LABEL_TEXT("WT_RAYPISTOL"), HUD._GET_LABEL_TEXT("WT_FIREWRK"), HUD._GET_LABEL_TEXT("WT_EMPL"), HUD._GET_LABEL_TEXT("WT_V_KHA_CA"), HUD._GET_LABEL_TEXT("LAZER")}
	local type = settings.Weapons["BulletChanger"]
	local hases = {
		177293209,
		-1312131151,
		615608432,
		126349499,
		-1355376991,
		2138347493,
		3676729658,
		1945616459,
		3800181289,
	}
	local wait = 0
	local ammo
	local selected
	__options.choose["BulletChanger"] = ui.add_choose(TRANSLATION["Bullet changer"], __submenus["Weapons"], false, types, function(int) HudSound("YES")
		settings.Weapons["BulletChanger"] = int
	end)

	local function GetTime()
		local handle = memory.handle_to_pointer(features.player_ped())
		local addr = s_memory.get_memory_address(handle, {0x10D8, 0x20, 0x013C})
		return addr == 0 and .1 or memory.read_float(addr)
	end

	CreateRemoveThread(true, 'bullet_changer', function()
		if settings.Weapons["BulletChanger"] == 0 then
			if ammo then
				WEAPON.REMOVE_WEAPON_ASSET(ammo)
				ammo = nil
			end
			return
		end
		if selected ~= settings.Weapons["BulletChanger"] and ammo then
			WEAPON.REMOVE_WEAPON_ASSET(ammo)
		end
		selected = settings.Weapons["BulletChanger"]
		ammo = hases[settings.Weapons["BulletChanger"]]
		if WEAPON.HAS_WEAPON_ASSET_LOADED(ammo) == 0 then
			WEAPON.REQUEST_WEAPON_ASSET(ammo, 31, 0)
			return
		end
		PLAYER.DISABLE_PLAYER_FIRING(PLAYER.PLAYER_ID(), true)
		if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.ATTACK2) == 1 and PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 and time < os.clock() then
			local ped = features.player_ped()
			local weapo = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(ped, 1)
			local cam_dir = features.gameplay_cam_rot():rot_to_direction()
			local cam_pos = features.gameplay_cam_pos()
			local pos1 = cam_pos + (cam_dir * (cam_pos:len(features.get_entity_coords(weapo)) + 0.4))
			local pos2 = cam_pos + (cam_dir * 200)
			MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z, 5, true, ammo, ped, true, true, 24000)
			time = os.clock() + GetTime()
		end

	end)
end

do
	local vehs = {}
	for i, v in ipairs(vehicles.models) do
		insert(vehs, v[3])
	end

	local curr_model
	local spawned_vehs = {}
	__options.choose["VehicleGun"] = ui.add_choose(TRANSLATION["Vehicle gun"], __submenus["Weapons"], true, vehs, function(int) HudSound("YES") settings.Weapons["VehicleGun"] = int end)
	__options.bool["VehicleGunEnabled"] = ui.add_bool_option(TRANSLATION["Enable vehicle gun"], __submenus["Weapons"], function(bool) HudSound("TOGGLE_ON") settings.Weapons["VehicleGunEnabled"] = bool end)

	CreateRemoveThread(true, 'weapons_vehicle_gun', function()
		if not settings.Weapons["VehicleGunEnabled"]then return end
		local model = settings.Weapons["VehicleGun"] + 1
		if not curr_model then
			if features.request_model(vehicles.models[model][2]) == 0 then return end
			curr_model = model
		elseif curr_model ~= model then
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehicles.models[curr_model][2])
			curr_model = nil
			return
		end
		if PED.IS_PED_SHOOTING(features.player_ped()) == 0 then return end
		local pos = features.get_offset_from_player_coords(vector3(0, 2, 1))
		local rot = features.gameplay_cam_rot()
		local dir = rot:rot_to_direction() * 500
		local veh = vehicles.spawn_vehicle(vehicles.models[model][2], pos + vector3.up(10))
		entities.request_control(veh, function()
			--vehicles.set_godmode(veh, true)
			ENTITY.SET_ENTITY_ALPHA(veh, 50, false)
			ENTITY.SET_ENTITY_COLLISION(veh, false, true)
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, pos.x, pos.y, pos.z, false, false, false)
			ENTITY.SET_ENTITY_ROTATION(veh, rot.x, rot.y, rot.z, 2, true)
			features.set_entity_velocity(veh, dir.x, dir.y, dir.z)
		end)
		spawned_vehs[veh] = clock()
	end)

	CreateRemoveThread(true, 'weapons_vehicle_tracker', function()
		for k, v in pairs(spawned_vehs) do
			local waittime = .1
			local class = VEHICLE.GET_VEHICLE_CLASS(k)
			if class == 16 then
				waittime = .3
			end
			if v + 5 < clock() then
				features.delete_entity(k)
				spawned_vehs[k] = nil
				return
			end
			entities.request_control(k, function()
				if v + waittime < clock() then
					ENTITY.SET_ENTITY_COLLISION(k, true, true)
				end
				if v + .3 < clock() then
					ENTITY.SET_ENTITY_ALPHA(k, 255, false)
				elseif v + .2 < clock() then
					ENTITY.SET_ENTITY_ALPHA(k, 160, false)
				elseif v + .1 < clock() then
					ENTITY.SET_ENTITY_ALPHA(k, 89, false)
				end
			end)
		end
	end)
end

do
	local guns = {}
	function guns.delete(ent)
		features.delete_entity(ent)
	end
	function guns.push(ent, force)
		entities.request_control(ent, function()
			if ENTITY.IS_ENTITY_A_PED(ent) == 1 then
				PED.SET_PED_TO_RAGDOLL(ent, 5000, 5000, 0, true, true, false)
			end
			ENTITY.FREEZE_ENTITY_POSITION(ent, false)
			features.set_entity_velocity(ent, force.x, force.y, force.z)
		end)
	end
	function guns.explode(ent)
		local pos = features.get_entity_coords(ent)
		if pos == vector3.zero() then return end
		FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, enum.explosion.ROCKET, 10, true, false, 1.0, false)
		if ENTITY.IS_ENTITY_A_VEHICLE(ent) == 1 then
			entities.request_control(ent, function()
				vehicles.set_godmode(ent, false)
				NETWORK.NETWORK_EXPLODE_VEHICLE(ent, true, false, PLAYER.PLAYER_ID())
			end)
		end
	end
	function guns.paint(ent)
		if ENTITY.IS_ENTITY_A_VEHICLE(ent) == 1 then
			entities.request_control(ent, function()
				local p = random(1, #vehicles.colors)
				VEHICLE.SET_VEHICLE_MOD_KIT(ent, 0)
				VEHICLE.SET_VEHICLE_COLOURS(ent, 160, 160)
				VEHICLE.SET_VEHICLE_EXTRA_COLOURS(ent, 160, 160)
				VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(ent, vehicles.colors[p][1], vehicles.colors[p][2], vehicles.colors[p][3])
				VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(ent, vehicles.colors[p][1], vehicles.colors[p][2], vehicles.colors[p][3])
		    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(ent, vehicles.colors[p][1], vehicles.colors[p][2], vehicles.colors[p][3])
		    VEHICLE._SET_VEHICLE_NEON_LIGHTS_COLOUR(ent, vehicles.colors[p][1], vehicles.colors[p][2], vehicles.colors[p][3])
			end)
		end
	end
	function guns.revive(ent)
		if ENTITY.IS_ENTITY_A_PED(ent) == 1 and ENTITY.IS_ENTITY_DEAD(ent, false) == 1 then
			peds.revive(ent)
		end
	end
	function guns.soul_switch(ent)
		if ENTITY.IS_ENTITY_A_PED(ent) == 1 and PED.IS_PED_A_PLAYER(ent) == 0 then
			local weapon = peds.get_weapons()
			ENTITY.SET_ENTITY_HEALTH(ent, 200, 0)
            ENTITY.SET_ENTITY_MAX_HEALTH(ent, 400)
            PED.RESURRECT_PED(ent)
            PED.REVIVE_INJURED_PED(ent)
            ENTITY.SET_ENTITY_HEALTH(ent, 200, 0)
            PED.SET_PED_GENERATES_DEAD_BODY_EVENTS(ent, false)
            if PED.IS_PED_IN_ANY_VEHICLE(ent, false) == 0 then
            	TASK.CLEAR_PED_TASKS_IMMEDIATELY(ent)
            end
			PLAYER.CHANGE_PLAYER_PED(PLAYER.PLAYER_ID(), ent, true, true)
			peds.set_weapons(weapon)
		end
	end
	-- function guns.teleport()
	-- 	local pos = features.get_bullet_impact()
	-- 	if pos == vector3.zero() then return end
	-- 	features.teleport(features.player_ped(), pos.x, pos.y, pos.z)
	-- end
	function guns.teleport_aim()
		local start = features.gameplay_cam_pos()
		local end_pos = start + features.gameplay_cam_rot():rot_to_direction() * 1500
		local result = features.get_raycast_result(start, end_pos, features.player_ped())
		local pos = result.endCoords
		if pos == vector3.zero() then return end
		features.teleport(features.player_ped(), pos.x, pos.y, pos.z)
	end
	function guns.airstrike()
		local start = features.gameplay_cam_pos()
		local end_pos = start + features.gameplay_cam_rot():rot_to_direction() * 1500
		local result = features.get_raycast_result(start, end_pos, features.player_ped())
		local pos = result.endCoords
		if pos == vector3.zero() then return end
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 100, pos.x, pos.y, pos.z, 5, true, utils.joaat("weapon_rpg"), features.player_ped(), true, true, 5000)
	end

	local action = {TRANSLATION["None"], TRANSLATION["On aim"], TRANSLATION["On shoot"]}

	__options.choose["DeleteGun"] = ui.add_choose(TRANSLATION["Delete gun"], __submenus["Weapons"], true, action, function(int) HudSound("YES") settings.Weapons["DeleteGun"] = int end)
	__options.choose["PushGun"] = ui.add_choose(TRANSLATION["Push gun"], __submenus["Weapons"], true, action, function(int) HudSound("YES") settings.Weapons["PushGun"] = int end)
	__options.choose["ExplodeGun"] = ui.add_choose(TRANSLATION["Explode gun"], __submenus["Weapons"], true, action, function(int) HudSound("YES") settings.Weapons["ExplodeGun"] = int end)
	__options.choose["PaintGun"] = ui.add_choose(TRANSLATION["Paint gun"], __submenus["Weapons"], true, action, function(int) HudSound("YES") settings.Weapons["PaintGun"] = int end)
	__options.choose["ReviveGun"] = ui.add_choose(TRANSLATION["Revive gun"], __submenus["Weapons"], true, action, function(int) HudSound("YES") settings.Weapons["ReviveGun"] = int end)
	__options.choose["SoulSwitchGun"] = ui.add_choose(TRANSLATION["Soul switch gun"], __submenus["Weapons"], true, action, function(int) HudSound("YES") settings.Weapons["SoulSwitchGun"] = int end)
	__options.choose["TeleportGun"] = ui.add_choose(TRANSLATION["Teleport gun"], __submenus["Weapons"], true, action, function(int) HudSound("YES") settings.Weapons["TeleportGun"] = int end)
	__options.choose["AirstrikeGun"] = ui.add_choose(TRANSLATION["Airstrike gun"], __submenus["Weapons"], true, action, function(int) HudSound("YES") settings.Weapons["AirstrikeGun"] = int end)

	CreateRemoveThread(true, 'weapons_guns', function()
		if WEAPON.HAS_WEAPON_ASSET_LOADED(-1312131151) == 0 then
			WEAPON.REQUEST_WEAPON_ASSET(-1312131151, 31, 0)	
		end

		if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 0 and PED.IS_PED_SHOOTING(features.player_ped()) == 0 then return end

		if settings.Weapons["TeleportGun"] == 1 then
			guns.teleport_aim()
		elseif settings.Weapons["TeleportGun"] == 2 and PED.IS_PED_SHOOTING(features.player_ped()) == 1 then
			guns.teleport_aim()
		end

		if settings.Weapons["AirstrikeGun"] == 1 then
			guns.airstrike()
		elseif settings.Weapons["AirstrikeGun"] == 2 and PED.IS_PED_SHOOTING(features.player_ped()) == 1 then
			guns.airstrike()
		end

		local ent = features.get_aimed_entity()
		if ent == 0 then return end
		local ped = ent
		local cam_dir = features.gameplay_cam_rot():rot_to_direction()
		if ENTITY.IS_ENTITY_A_PED(ent) == 1 and PED.IS_PED_IN_ANY_VEHICLE(ent, true) == 1 then
			ent = PED.GET_VEHICLE_PED_IS_IN(ent, false)
		end

		if settings.Weapons["ReviveGun"] == 1 then
			guns.revive(ped)
		end
		if settings.Weapons["SoulSwitchGun"] == 1 then
			guns.soul_switch(ped)
		end
		if settings.Weapons["PaintGun"] == 1 then
			guns.paint(ent)
		end
		if settings.Weapons["ExplodeGun"] == 1 then
			guns.explode(ent)
		end
		if settings.Weapons["PushGun"] == 1 then
			guns.push(ent, cam_dir * 200)
		end
		if settings.Weapons["DeleteGun"] == 1 then
			guns.delete(ent)
		end

		if PED.IS_PED_SHOOTING(features.player_ped()) == 0 then return end

		if settings.Weapons["ReviveGun"] == 2 then
			guns.revive(ped)
		end
		if settings.Weapons["SoulSwitchGun"] == 2 then
			guns.soul_switch(ped)
		end
		if settings.Weapons["PaintGun"] == 2 then
			guns.paint(ent)
		end
		if settings.Weapons["ExplodeGun"] == 2 then
			guns.explode(ent)
		end
		if settings.Weapons["PushGun"] == 2 then
			guns.push(ent, cam_dir * 200)
		end
		if settings.Weapons["DeleteGun"] == 2 then
			guns.delete(ent)
		end
	end)
end

---------------------------------------------------------------------------------------------------------------------------------
-- Misc
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'misc submenu') end
__submenus["Misc"] = ui.add_submenu(TRANSLATION["Misc"])
__suboptions["Misc"] = ui.add_sub_option(TRANSLATION["Misc"], __submenus["MainSub"], __submenus["Misc"])

-- local train_models = {
--     utils.joaat("metrotrain"), utils.joaat("freight"), utils.joaat("freightcar"), utils.joaat("freightcar2"), utils.joaat("freightcont1"), utils.joaat("freightcont2"), utils.joaat("freightgrain"), utils.joaat("tankercar")
-- }
-- system.log('Imagined Menu', 'Loading trains')
-- CreateRemoveThread(true, 'load_trains', function()
-- 	for _, v in ipairs(train_models)
-- 	do
-- 		if features.request_model(v) == 0 then
-- 			return
-- 		end
-- 	end
-- 	system.log('Imagined Menu', 'Trains loaded')
-- 	return POP_THREAD
-- end)

__submenus["TrainDriver"] = ui.add_submenu(TRANSLATION["Train driver"])
__suboptions["TrainDriver"] = ui.add_sub_option(TRANSLATION["Train driver"], __submenus["Misc"], __submenus["TrainDriver"])

-- do
-- 	local function create_train(variation, pos, direction, inside)
-- 		local train = VEHICLE.CREATE_MISSION_TRAIN(variation, pos.x, pos.y, pos.z, false)
-- 		local carriages = {}
--     for i = 1, 100 do
--         local cart = VEHICLE.GET_TRAIN_CARRIAGE(train, i)
--         if cart == 0 then
--             break
--         end
--         insert(carriages, cart)
--     end
--     VEHICLE.SET_TRAIN_CRUISE_SPEED(train, 10)
--     VEHICLE.SET_TRAIN_SPEED(train, 10)
--     if inside then
--     	PED.SET_PED_INTO_VEHICLE(features.player_ped(), train, -1)
--     end
-- 	end

-- 	local trains = {"Long train"}
-- 	local train_types = {
-- 		[0] = 23,
-- 	}

-- 	__options.choose["CreateTrain"] = ui.add_choose(TRANSLATION["Create train"], __submenus["TrainDriver"], false, trains, function(type)  
-- 		create_train(type, features.get_player_coords(), nil, true)
-- 	end)
-- end

do
	local opt
	local opt2
	local train
	__options.bool["TrainsAlot"] = ui.add_bool_option(TRANSLATION["Trains alot"], __submenus["TrainDriver"], function(bool) HudSound("TOGGLE_ON")
		settings.Misc['TrainsAlot'] = bool
		if not bool then
			VEHICLE.SET_RANDOM_TRAINS(false)
		end
		CreateRemoveThread(bool, 'misc_trains', function()
			VEHICLE.SET_RANDOM_TRAINS(true)
		end)
	end)

	__options.bool["TrainControl"] = ui.add_bool_option(TRANSLATION["Train control"], __submenus["TrainDriver"], function(bool) HudSound("TOGGLE_ON")
		settings.Misc['TrainControl'] = bool
		if not bool then
			train = nil
		end
		CreateRemoveThread(bool, 'misc_train_driver', function()
			train = vehicles.get_player_vehicle()
			if VEHICLE.IS_THIS_MODEL_A_TRAIN(ENTITY.GET_ENTITY_MODEL(train)) == 0 then train = nil return end
			features.request_control_once(train)
		end)
	end)
	
	CreateRemoveThread(true, 'misc_train_speed', function()
		if settings.Misc['TrainControl'] and not opt and train then
			opt = ui.add_num_option(TRANSLATION["Set speed"], __submenus["TrainDriver"], -999999999, 999999999, 1, function(int)
				if train then
					HudSound("YES")
					VEHICLE.SET_TRAIN_CRUISE_SPEED(train, int)
			    	VEHICLE.SET_TRAIN_SPEED(train, int)
			    else
			    	HudSound("ERROR")
				end
			end)
			opt2 = ui.add_bool_option(TRANSLATION["Derail"], __submenus["TrainDriver"], function(bool) HudSound("TOGGLE_ON")
				if train then
					VEHICLE.SET_RENDER_TRAIN_AS_DERAILED(train, bool)
				end
			end)
		elseif opt and (not settings.Misc['TrainControl'] or not train) then
			ui.remove(opt)
			ui.remove(opt2)
			opt2 = nil
			opt = nil
			-- elseif settings.Misc['TrainControl'] and opt and train then
			-- ui.set_value(opt, floor(ENTITY.GET_ENTITY_SPEED(train)), true)
		end
	end)
end

__submenus["Reactions"] = ui.add_submenu(TRANSLATION["Reactions"])
__suboptions["Reactions"] = ui.add_sub_option(TRANSLATION["Reactions"], __submenus["Misc"], __submenus["Reactions"])

ui.add_separator(TRANSLATION["On report"] ,__submenus["Reactions"])

__options.bool["OnReportKick"] = ui.add_bool_option(TRANSLATION["Kick"], __submenus["Reactions"], function(bool) HudSound("TOGGLE_ON")
	settings.Misc['OnReportKick'] = bool
end)
__options.bool["OnReportCrash"] = ui.add_bool_option(TRANSLATION["Crash"], __submenus["Reactions"], function(bool) HudSound("TOGGLE_ON")
	settings.Misc['OnReportCrash'] = bool
end)
__options.bool["OnReportSendChat"] = ui.add_bool_option(TRANSLATION["Send chat"], __submenus["Reactions"], function(bool) HudSound("TOGGLE_ON")
	settings.Misc['OnReportSendChat'] = bool
end)

ui.add_separator(TRANSLATION["On votekick"] ,__submenus["Reactions"])

__options.bool["OnVotekickKick"] = ui.add_bool_option(TRANSLATION["Kick"], __submenus["Reactions"], function(bool) HudSound("TOGGLE_ON")
	settings.Misc['OnVotekickKick'] = bool
end)
__options.bool["OnVotekickCrash"] = ui.add_bool_option(TRANSLATION["Crash"], __submenus["Reactions"], function(bool) HudSound("TOGGLE_ON")
	settings.Misc['OnVotekickCrash'] = bool
end)
__options.bool["OnVotekickSendChat"] = ui.add_bool_option(TRANSLATION["Send chat"], __submenus["Reactions"], function(bool) HudSound("TOGGLE_ON")
	settings.Misc['OnVotekickSendChat'] = bool
end)

__submenus["Crosshair"] = ui.add_submenu(TRANSLATION["Crosshair"])
__suboptions["Crosshair"] = ui.add_sub_option(TRANSLATION["Crosshair"], __submenus["Misc"], __submenus["Crosshair"])

local crosshair_presets = {}
__options.choose["CrosshairPresets"] = ui.add_choose(TRANSLATION["Presets"], __submenus["Crosshair"], false, {TRANSLATION["Default"], TRANSLATION["Dot"], TRANSLATION["Cross"], TRANSLATION["Saved"]}, function(int)
	dont_play_tog = true
	HudSound("YES")
	for _, v in ipairs(crosshair_presets)
	do
		if type(v.value[int+1]) == 'table' then
			ui.set_value(v.option, v.value[int+1].r, v.value[int+1].g, v.value[int+1].b, v.value[int+1].a, false)
		else
			ui.set_value(v.option, v.value[int+1], false)
		end
	end
end)

do
	local add = switch()
		:case(enum.weapon_group.Throwables, function()
			return 0
		end)
		:case(enum.weapon_group.Shotgun, function()
			return 15
		end)
		:case(enum.weapon_group.Sniper, function()
			return 20
		end)
		:case(enum.weapon_group.Heavy_Weapon, function()
			return 8
		end)
		:default(function()
			return 4
		end)

	__options.bool["CrosshairEnable"] = ui.add_bool_option(TRANSLATION["Enable"], __submenus["Crosshair"], function(bool) HudSound("TOGGLE_ON")
		settings.Misc["CrosshairEnable"] = bool
		local dynamic_spacing = 0
		local cooldown
		local delay = 0
		CreateRemoveThread(bool, 'misc_custom_crosshair', function()
			if ui.get_value(__options.bool["FreeCam"]) then return end
			delay = PED.IS_PED_SHOOTING(features.player_ped()) == 1 and clock() + 1.35 or delay
			if PED.IS_PED_SHOOTING(features.player_ped()) == 1 and settings.Misc["CrosshairDynamic"] then
				local ptr = s_memory.alloc()
				WEAPON.GET_CURRENT_PED_WEAPON(features.player_ped(), ptr, true)
				local wreapon_group = WEAPON.GET_WEAPONTYPE_GROUP(memory.read_int(ptr))
				dynamic_spacing = dynamic_spacing < 20 and dynamic_spacing + add(wreapon_group) or dynamic_spacing
				cooldown = clock() + .5
			elseif cooldown and cooldown < clock() then
				dynamic_spacing = dynamic_spacing > 0 and dynamic_spacing - 1 or dynamic_spacing
			end
			if settings.Misc["CrosshairDisableIngame"] then
				HUD.HIDE_HUD_COMPONENT_THIS_FRAME(14)
			end
			if (PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 0 and PED.IS_PED_SHOOTING(features.player_ped()) == 0) and not settings.Misc["CrosshairShowAllTime"] and (delay <= clock()) then return end
			delay = delay <= clock() and 0 or delay
			features.draw_crosshair(settings.Misc["CrosshairWidth"], settings.Misc["CrosshairHeight"],
				settings.Misc["CrosshairSpacing"] + dynamic_spacing, settings.Misc["CrosshairThickness"],
				settings.Misc["CrosshairColor"].r, settings.Misc["CrosshairColor"].g, settings.Misc["CrosshairColor"].b, settings.Misc["CrosshairColor"].a,
				settings.Misc["CrosshairLeft"], settings.Misc["CrosshairRight"], settings.Misc["CrosshairUp"], settings.Misc["CrosshairDown"], 
				settings.Misc["CrosshairBorderThickness"], settings.Misc["CrosshairBorderColor"].r, settings.Misc["CrosshairBorderColor"].g, settings.Misc["CrosshairBorderColor"].b, settings.Misc["CrosshairBorderColor"].a,
				settings.Misc["CrosshairDot"])
		end)
	end)
end

__options.bool["CrosshairLink"] = ui.add_bool_option(TRANSLATION["Link width & height"], __submenus["Crosshair"], function(bool) HudSound("TOGGLE_ON") settings.Misc["CrosshairLink"] = bool end)
__options.num["CrosshairWidth"] = ui.add_num_option(TRANSLATION["Width"], __submenus["Crosshair"], 0, 500, 1, function(int) HudSound("YES") settings.Misc["CrosshairWidth"] = int  end)
__options.num["CrosshairHeight"] = ui.add_num_option(TRANSLATION["Height"], __submenus["Crosshair"], 0, 500, 1, function(int) HudSound("YES") settings.Misc["CrosshairHeight"] = int end)
__options.num["CrosshairSpacing"] = ui.add_num_option(TRANSLATION["Spacing"], __submenus["Crosshair"], 0, 500, 1, function(int) HudSound("YES") settings.Misc["CrosshairSpacing"] = int end)
__options.num["CrosshairThickness"] = ui.add_num_option(TRANSLATION["Thickness"], __submenus["Crosshair"], 0, 300, 2, function(int) HudSound("YES") settings.Misc["CrosshairThickness"] = int end)
__options.color["CrosshairColor"] = ui.add_color_picker(TRANSLATION["Color"], __submenus["Crosshair"], function(color) settings.Misc["CrosshairColor"] = color end)
__options.bool["CrosshairLeft"] = ui.add_bool_option(TRANSLATION["Left"], __submenus["Crosshair"], function(bool) HudSound("TOGGLE_ON") settings.Misc["CrosshairLeft"] = bool end)
__options.bool["CrosshairRight"] = ui.add_bool_option(TRANSLATION["Right"], __submenus["Crosshair"], function(bool) HudSound("TOGGLE_ON") settings.Misc["CrosshairRight"] = bool end)
__options.bool["CrosshairUp"] = ui.add_bool_option(TRANSLATION["Up"], __submenus["Crosshair"], function(bool) HudSound("TOGGLE_ON") settings.Misc["CrosshairUp"] = bool end)
__options.bool["CrosshairDown"] = ui.add_bool_option(TRANSLATION["Down"], __submenus["Crosshair"], function(bool) HudSound("TOGGLE_ON") settings.Misc["CrosshairDown"] = bool end)
__options.bool["CrosshairDot"] = ui.add_bool_option(TRANSLATION["Dot"], __submenus["Crosshair"], function(bool) HudSound("TOGGLE_ON") settings.Misc["CrosshairDot"] = bool end)
__options.bool["CrosshairDynamic"] = ui.add_bool_option(TRANSLATION["Dynamic"], __submenus["Crosshair"], function(bool) HudSound("TOGGLE_ON") settings.Misc["CrosshairDynamic"] = bool end)
__options.bool["CrosshairShowAllTime"] = ui.add_bool_option(TRANSLATION["Show all time"], __submenus["Crosshair"], function(bool) HudSound("TOGGLE_ON") settings.Misc["CrosshairShowAllTime"] = bool end)
__options.bool["CrosshairDisableIngame"] = ui.add_bool_option(TRANSLATION["Disable in-game crosshair"]..'*', __submenus["Crosshair"], function(bool) settings.Misc["CrosshairDisableIngame"] = bool end)
ui.add_separator(TRANSLATION["Borders"], __submenus["Crosshair"])
__options.num["CrosshairBorderThickness"] = ui.add_num_option(TRANSLATION["Thickness"], __submenus["Crosshair"], 0, 100, 1, function(int) HudSound("YES") settings.Misc["CrosshairBorderThickness"] = int end)
__options.color["CrosshairBorderColor"] = ui.add_color_picker(TRANSLATION["Color"], __submenus["Crosshair"], function(color) settings.Misc["CrosshairBorderColor"] = color end)

crosshair_presets = {
	{option = __options.bool["CrosshairEnable"],
	value = {true, true, true, settings.Misc["CrosshairEnable"]}},
	{option = __options.num["CrosshairWidth"],
	value = {5, 2, 3, settings.Misc["CrosshairWidth"]}},
	{option = __options.num["CrosshairHeight"],
	value = {5, 2, 3, settings.Misc["CrosshairHeight"]}},
	{option = __options.num["CrosshairSpacing"],
	value = {2, 0, 2, settings.Misc["CrosshairSpacing"]}},
	{option = __options.num["CrosshairThickness"],
	value = {2, 2, 2, settings.Misc["CrosshairThickness"]}},
	{option = __options.color["CrosshairColor"],
	value = {{r=255,g=0,b=255,a=255}, {r=255,g=255,b=255,a=120}, {r=180,g=255,b=0,a=255}, settings.Misc["CrosshairColor"]}},
	{option = __options.bool["CrosshairLeft"],
	value = {true, true, true, settings.Misc["CrosshairLeft"]}},
	{option = __options.bool["CrosshairRight"],
	value = {true, true, true, settings.Misc["CrosshairRight"]}},
	{option = __options.bool["CrosshairUp"],
	value = {true, true, true, settings.Misc["CrosshairUp"]}},
	{option = __options.bool["CrosshairDown"],
	value = {true, true, true, settings.Misc["CrosshairDown"]}},
	{option = __options.bool["CrosshairDot"],
	value = {true, true, false, settings.Misc["CrosshairDot"]}},
	{option = __options.bool["CrosshairDynamic"],
	value = {true, false, false, settings.Misc["CrosshairDynamic"]}},
	{option = __options.num["CrosshairBorderThickness"],
	value = {1, 1, 1, settings.Misc["CrosshairBorderThickness"]}},
	{option = __options.num["CrosshairBorderColor"],
	value = {{r=0,g=0,b=0,a=255}, {r=0,g=0,b=0,a=70}, {r=0,g=0,b=0,a=255}, settings.Misc["CrosshairBorderColor"]}},
	{option = __options.bool["CrosshairDisableIngame"],
	value = {true, true, true, settings.Misc["CrosshairDisableIngame"]}},
	{option = __options.bool["CrosshairShowAllTime"],
	value = {false, true, false, settings.Misc["CrosshairShowAllTime"]}}
}

CreateRemoveThread(true, 'crosshair_link', function()
	if settings.Misc["CrosshairLink"] and ui.get_value(__options.num["CrosshairWidth"]) ~= ui.get_value(__options.num["CrosshairHeight"]) then dont_play_tog = true ui.set_value(__options.num["CrosshairHeight"], ui.get_value(__options.num["CrosshairWidth"]), false) end
	if settings.Misc["CrosshairLink"] and ui.get_value(__options.num["CrosshairWidth"]) ~= ui.get_value(__options.num["CrosshairHeight"]) then dont_play_tog = true ui.set_value(__options.num["CrosshairWidth"], ui.get_value(__options.num["CrosshairHeight"]), false) end
end)

__options.bool["LogChat"] = ui.add_bool_option(TRANSLATION["Log chat"], __submenus["Misc"], function(bool) HudSound("TOGGLE_ON")
	settings.Misc["LogChat"] = bool
end)

__options.bool["LockGameplayCam"] = ui.add_bool_option(TRANSLATION["Lock gameplay cam"], __submenus["Misc"], function(bool)  HudSound("TOGGLE_ON")
	settings.Misc['LockGameplayCam'] = bool
	CreateRemoveThread(bool, 'misc_lock_camera',
	function(tick)
		if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 or PAD.GET_CONTROL_NORMAL(0, enum.input.LOOK_LR) ~= 0 or PAD.GET_CONTROL_NORMAL(0, enum.input.LOOK_UD) ~= 0 then return end
		CAM.SET_GAMEPLAY_CAM_RELATIVE_HEADING(0)
	end)
end)

__options.bool["DisableCamCenter"] = ui.add_bool_option(TRANSLATION["Disable cam centering"], __submenus["Misc"], function(bool) HudSound("TOGGLE_ON")
	settings.Misc['DisableCamCenter'] = bool
	local h = CAM.GET_GAMEPLAY_CAM_RELATIVE_HEADING()
	local p = CAM.GET_GAMEPLAY_CAM_RELATIVE_PITCH()
	CreateRemoveThread(bool, 'misc_disable_cam_center',
	function(tick)
		if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 or PAD.GET_CONTROL_NORMAL(0, enum.input.LOOK_LR) ~= 0 or PAD.GET_CONTROL_NORMAL(0, enum.input.LOOK_UD) ~= 0 then 
			h = CAM.GET_GAMEPLAY_CAM_RELATIVE_HEADING()
			p = CAM.GET_GAMEPLAY_CAM_RELATIVE_PITCH()
		else
			CAM.SET_GAMEPLAY_CAM_RELATIVE_HEADING(h)
			CAM.SET_GAMEPLAY_CAM_RELATIVE_PITCH(p, 0)
		end
	end)
end)

__options.bool["DisableRecording"] = ui.add_bool_option(TRANSLATION["Disable recording"], __submenus["Misc"], function(bool) HudSound("TOGGLE_ON")
	settings.Misc['DisableRecording'] = bool
	CreateRemoveThread(bool, 'misc_disable_recording',
	function(tick)
		RECORDING._STOP_RECORDING_THIS_FRAME()
	end)
end)

__options.bool["ShootGodmodePlayers"] = ui.add_bool_option(TRANSLATION["Shoot godmode players"], __submenus["Misc"], function(bool) HudSound("TOGGLE_ON")
	settings.Misc['ShootGodmodePlayers'] = bool
	CreateRemoveThread(bool, 'misc_disable_god_on_aimed',
	function()
		if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 0 then return end
		local player = features.get_player_from_ped(features.get_aimed_ped())
		if player == -1 then return end
		if not (settings.General["Exclude Friends"] and features.is_friend(player)) and not features.is_excluded(player) then
			features.remove_god(player)
		end
	end)
end)

__options.num["SetCamDistance"] = ui.add_float_option(TRANSLATION["Set cam distance"], __submenus["Misc"], 0, 10000, .1, 2, function(float)
	HudSound("YES")
	settings.Misc['SetCamDistance'] = features.round(float, 2)
end)

do
	local defZoom = 83
	__options.num["SetMapZoom"] = ui.add_num_option(TRANSLATION["Set map zoom"], __submenus["Misc"], 1, 100, 1, function(int)
		HudSound("YES")
		defZoom = int
		CreateRemoveThread(true, 'map_zoom', function()
			HUD.SET_RADAR_ZOOM_PRECISE(defZoom)
			if defZoom == 83 then return POP_THREAD end
		end)
	end)
	ui.set_value(__options.num["SetMapZoom"], defZoom, true)
end

do
	local unload
	local was_open
	
	ui.add_click_option(TRANSLATION["Panic button"], __submenus["Misc"], function()
		if open_time > clock() then HudSound("ERROR") return end
		HudSound("SELECT")
		if not unload then
			system.notify(TRANSLATION["Warning"], TRANSLATION["This will close your game, continue?"], 255, 0, 0, 255, true)
			unload = true
			return
		end
		os.exit()
	end)

	CreateRemoveThread(true, 'is_misc_open', function()
		if not was_open and ui.is_sub_open(__submenus["Misc"]) then
			was_open = true
			open_time = clock() + .5
		elseif was_open and not ui.is_sub_open(__submenus["Misc"]) then
			was_open = false
		end
		if unload and not ui.is_sub_open(__submenus["Misc"]) then
			unload = false
		end
	end)
end

CreateRemoveThread(true, 'set_cam_dist', function()
	if settings.Misc['SetCamDistance'] <= 0 then return end
	CAM._ANIMATE_GAMEPLAY_CAM_ZOOM(1, settings.Misc['SetCamDistance'])
end)

---------------------------------------------------------------------------------------------------------------------------------
-- Recovery
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'recovery submenu') end
__submenus["Recovery"] = ui.add_submenu(TRANSLATION["Recovery"])
__suboptions["Recovery"] = ui.add_sub_option(TRANSLATION["Recovery"], __submenus["MainSub"], __submenus["Recovery"])

do
	__submenus["StatEditor"] = ui.add_submenu(TRANSLATION["Stat editor"])
	__suboptions["StatEditor"] = ui.add_sub_option(TRANSLATION["Stat editor"], __submenus["Recovery"], __submenus["StatEditor"])

	__submenus["StatEditorManual"] = ui.add_submenu(TRANSLATION["Manual edit"])
	__suboptions["StatEditorManual"] = ui.add_sub_option(TRANSLATION["Manual edit"], __submenus["StatEditor"], __submenus["StatEditorManual"])

	local stat = 1
	-- local _bool
	-- local _int
	-- local _float
	local value = 0
	local stats = {}
	-- local values = {'0.001', '0.01', '0.1', '1', '100', '10000', '1000000'}
	local mult = 1

	for i, v in ipairs(enum.stats)
	do
		stats[i] = v.name
	end

	__options.choose["StatName"] = ui.add_choose(TRANSLATION["Stat"], __submenus["StatEditor"], true, stats, function(int) stat = int + 1 
		HudSound("YES")
		-- system.notify('Comment: '..enum.stats[stat].name, enum.stats[stat].comment, 0, 255, 255, 255)
	end)

	-- __options.bool["Bool"] = ui.add_bool_option(TRANSLATION["Bool"], __submenus["StatEditor"], function(bool) _bool = bool end)
	-- __options.bool["Int"] = ui.add_bool_option(TRANSLATION["Int"], __submenus["StatEditor"], function(bool) _int = bool end)
	-- __options.bool["Float"] = ui.add_bool_option(TRANSLATION["Float"], __submenus["StatEditor"], function(bool) _float = bool end)
	__options.num["StatValue"] = ui.add_float_option(TRANSLATION["Value"], __submenus["StatEditor"], -999999999, 999999999, 1, 4, function(float) HudSound("YES") value = float end)

	ui.add_click_option(TRANSLATION["Change stat"], __submenus["StatEditor"], function()
		HudSound("SELECT")
		local type = enum.stats[stat].type
		local charstat = enum.stats[stat].characterStat
		local GetHash = switch()
			:case(true, function()
				local char = features.get_last_char()
				return utils.joaat('MP'..char..'_'..enum.stats[stat].name)
			end)
			:default(function()
				return utils.joaat(enum.stats[stat].name)
			end)

		if type == 'bool' then
			STATS.STAT_SET_BOOL(GetHash(charstat), features.to_bool(value), true)
			return
		elseif type == 'float' then
			STATS.STAT_SET_FLOAT(GetHash(charstat), value, true)
			return
		elseif features.compare(type, 'int', 'u32', 'u64') then
			STATS.STAT_SET_INT(GetHash(charstat), floor(value), true)
			return
		end
	end)

	local stat_input
	local prefix
	local GetStatHash = switch()
		:case(true, function()
			local char = features.get_last_char()
			return utils.joaat('MP'..char..'_'..stat_input)
		end)
		:default(function()
			return utils.joaat(stat_input)
		end)

	__options.string["StatInput"] = ui.add_input_string(TRANSLATION["Stat name"], __submenus["StatEditorManual"], function(text) stat_input = text end)
	__options.bool["UseMPPrefix"] = ui.add_bool_option(TRANSLATION["Use \"MP\" prefix"], __submenus["StatEditorManual"], function(bool) HudSound("TOGGLE_ON") prefix = bool end)
	ui.add_num_option(TRANSLATION["Set int"], __submenus["StatEditorManual"], -999999999, 999999999, 1, function(int)
		if not stat_input or stat_input:isblank() then return HudSound("ERROR") end
		local hash = GetStatHash(prefix)
		if not hash or hash == 0 then return HudSound("ERROR") end
		if STATS.STAT_SET_INT(hash, int, true) == 1 then
			HudSound("YES")
		else
			system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Something went wrong"], 255, 0, 0, 255)
			HudSound("ERROR")
		end
	end)
	ui.add_float_option(TRANSLATION["Set float"], __submenus["StatEditorManual"], -999999999, 999999999, .1, 4, function(float)
		if not stat_input or stat_input:isblank() then return HudSound("ERROR") end
		local hash = GetStatHash(prefix)
		if not hash or hash == 0 then return HudSound("ERROR") end
		if STATS.STAT_SET_FLOAT(hash, float, true) == 1 then
			HudSound("YES")
		else
			system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Something went wrong"], 255, 0, 0, 255)
			HudSound("ERROR")
		end
	end)
	ui.add_bool_option(TRANSLATION["Set bool"], __submenus["StatEditorManual"], function(bool)
		if not stat_input or stat_input:isblank() then return HudSound("ERROR") end
		local hash = GetStatHash(prefix)
		if not hash or hash == 0 then return HudSound("ERROR") end
		if STATS.STAT_SET_BOOL(hash, bool, true) == 1 then
			HudSound("YES")
		else
			system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Something went wrong"], 255, 0, 0, 255)
			HudSound("ERROR")
		end
	end)
	ui.add_input_string(TRANSLATION["Set user ID"], __submenus["StatEditorManual"], function(text)
		if not stat_input or stat_input:isblank() then return HudSound("ERROR") end
		local hash = GetStatHash(prefix)
		if not hash or hash == 0 then return HudSound("ERROR") end
		if STATS.STAT_SET_USER_ID(hash, text, true) == 1 then
			HudSound("YES")
		else
			system.notify(TRANSLATION["Imagined Menu"], TRANSLATION["Something went wrong"], 255, 0, 0, 255)
			HudSound("ERROR")
		end
	end)
end

do
	local snacks = {
		{'NO_BOUGHT_YUM_SNACKS', 30},
		{'NO_BOUGHT_HEALTH_SNACKS', 15},
		{'NO_BOUGHT_EPIC_SNACKS', 5},
		{'NUMBER_OF_ORANGE_BOUGHT', 10},
		{'NUMBER_OF_BOURGE_BOUGHT', 10},
		{'NUMBER_OF_CHAMP_BOUGHT', 5},
		{'CIGARETTES_BOUGHT', 20}
	}
	local armor = {
		{'MP_CHAR_ARMOUR_1_COUNT', 10},
		{'MP_CHAR_ARMOUR_2_COUNT', 10},
		{'MP_CHAR_ARMOUR_3_COUNT', 10},
		{'MP_CHAR_ARMOUR_4_COUNT', 10},
		{'MP_CHAR_ARMOUR_5_COUNT', 10}
	}
	local fast_run = {
		'CHAR_FM_ABILITY_1_UNLCK',
		'CHAR_FM_ABILITY_2_UNLCK',
		'CHAR_FM_ABILITY_3_UNLCK',
		'CHAR_ABILITY_1_UNLCK',
		'CHAR_ABILITY_2_UNLCK',
		'CHAR_ABILITY_3_UNLCK'
	}

	local kills = 0
	local deaths = 0
	ui.add_num_option(TRANSLATION["Player kills"], __submenus["Recovery"], -999999999, 999999999, 1, function(int) HudSound("YES") kills = int end)
	ui.add_num_option(TRANSLATION["Player deaths"], __submenus["Recovery"], -999999999, 999999999, 1, function(int) HudSound("YES") deaths = int end)
	ui.add_click_option(TRANSLATION["Set k/d"], __submenus["Recovery"], function() 
		HudSound("SELECT")
		STATS.STAT_SET_INT(utils.joaat("MPPLY_KILLS_PLAYERS"), kills, true)
    	STATS.STAT_SET_INT(utils.joaat("MPPLY_DEATHS_PLAYER"), deaths, true)
	end)

	ui.add_click_option(TRANSLATION["Unlock fast-run"], __submenus["Recovery"], function()
		HudSound("SELECT")
		for _, v in ipairs(fast_run)
		do
			local char = features.get_last_char()
			STATS.STAT_SET_INT(utils.joaat('MP'..char..'_'..v), -1, true)
		end
	end)

	ui.add_click_option(TRANSLATION["Fill snacks"], __submenus["Recovery"], function()
		HudSound("SELECT")
		for _, v in ipairs(snacks)
		do
			local char = features.get_last_char()
			STATS.STAT_SET_INT(utils.joaat('MP'..char..'_'..v[1]), v[2], true)
		end
	end)

	ui.add_click_option(TRANSLATION["Fill armour"], __submenus["Recovery"], function()
		HudSound("SELECT")
		for _, v in ipairs(armor)
		do
			local char = features.get_last_char()
			STATS.STAT_SET_INT(utils.joaat('MP'..char..'_'..v[1]), v[2], true)
		end
	end)
end

---------------------------------------------------------------------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'settings submenu') end
__submenus["Settings"] = ui.add_submenu(TRANSLATION["Settings"])
__suboptions["Settings"] = ui.add_sub_option(TRANSLATION["Settings"], __submenus["MainSub"], __submenus["Settings"])

local LANGUAGES = {}

do
	local text
	local lang = switch()
		:case('English', function()
			return 'English (US)'
		end)
		:case('French', function()
			return 'French (Français)'
		end)
		:case('German', function()
			return 'German (Deutsch)'
		end)
		:case('Italian', function()
			return 'Italian (Italiano)'
		end)
		:case('Spanish', function()
			return 'Spanish (Español)'
		end)
		:case('Polish', function()
			return 'Polish (Polski)'
		end)
		:case('Russian', function()
			return 'Russian (Русский)'
		end)
		:case('Korean', function()
			return 'Korean (한국인)'
		end)
		:case('Chinese', function()
			return 'Chinese (中國人)'
		end)
		:case('Japanese', function()
			return 'Japanese (日本)'
		end)
		:case('Simplified_chinese', function()
			return 'Simplified Chinese (简体中文)'
		end)
		:default(function()
			return text
		end)

	for i = 1, #TRANSLATION_FILES do
		text = TRANSLATION_FILES[i]:gsub('.json$', '')
		LANGUAGES[i] = lang(text:capitalize())
	end
end

__options.choose["Translation"] = ui.add_choose(TRANSLATION['Default translation'], __submenus["Settings"], true, LANGUAGES, function(i) 
	HudSound("YES")
	settings.General['Translation'] = TRANSLATION_FILES[i + 1] 
end)

__options.bool["Exclude Self"] = ui.add_bool_option(TRANSLATION["Exclude self"]..'*', __submenus["Settings"], function(bool) HudSound("TOGGLE_ON") settings.General["Exclude Self"] = bool end)
__options.bool["Exclude Friends"] = ui.add_bool_option(TRANSLATION["Exclude friends"], __submenus["Settings"], function(bool) HudSound("TOGGLE_ON") settings.General["Exclude Friends"] = bool end)
ui.add_separator(TRANSLATION['Menu'], __submenus["Settings"])

__submenus["DisableControls"] = ui.add_submenu(TRANSLATION["Disable controls"])
__suboptions["DisableControls"] = ui.add_sub_option(TRANSLATION["Disable controls"], __submenus["Settings"], __submenus["DisableControls"])

__options.bool["DisableControls"] = ui.add_bool_option(TRANSLATION["Disable controls when menu is active"], __submenus["DisableControls"], function(bool) HudSound("TOGGLE_ON")
	settings.Controls["DisableControls"] = bool
	CreateRemoveThread(bool, 'disable_controls', function()
		for _, v in ipairs(settings.Controls['BlockInput'])
		do
			if ui.is_open() then
				PAD.DISABLE_CONTROL_ACTION(0, v, true)
			end
		end
	end)
end)

do
	local l = 0
	local inputs = {}
	local arrow_keys = {27, 172, 173, 174, 175, 187, 188, 189, 190, 299, 300, 307, 308, 18, 176, 191, 201, 215, 177, 194, 202, 344, 200, 322}
	local numpad = {96, 97, 107, 108, 109, 110, 111, 112, 117, 118, 123, 124, 125, 126, 127, 128, 201, 314, 315, 200, 322}
	for line in lines(files["Inputs"])
	do
		inputs[l] = line
		l = l + 1
	end

	local InputPreset = switch()
		:case(1, function()
			dont_play_tog = true
			for _, i in ipairs(arrow_keys)
			do
				ui.set_value(__options.bool["INPUT_"..i], true, false)
			end
		end)
		:case(2, function()
			dont_play_tog = true
			for _, i in ipairs(numpad)
			do
				ui.set_value(__options.bool["INPUT_"..i], true, false)
			end
		end)
		:case(3, function()
			for i = 0, 360
			do
				ui.set_value(__options.bool["INPUT_"..i], true, true)
				insert(settings.Controls['BlockInput'], i)
			end
		end)

	local presets = {TRANSLATION["None"], TRANSLATION["Arrow keys"], TRANSLATION["Numpad"], TRANSLATION["All"]}
	ui.add_choose(TRANSLATION["Presets"], __submenus["DisableControls"], false, presets, function(int)
		HudSound("YES")
		settings.Controls['BlockInput'] = {}
		for i = 0, 360 do
			ui.set_value(__options.bool["INPUT_"..i], false, true)
		end

		InputPreset(int)
	end)
	ui.add_separator(TRANSLATION["Controls"], __submenus["DisableControls"])

	for i, v in pairs(inputs)
	do
		__options.bool["INPUT_"..i] = ui.add_bool_option(v, __submenus["DisableControls"], function(bool) HudSound("TOGGLE_ON")
			if bool then
				insert(settings.Controls['BlockInput'], i)
			else
				for j, e in ipairs(settings.Controls['BlockInput'])
				do
					if e == i then
						table_remove(settings.Controls['BlockInput'], j)
						break
					end
				end
			end
		end)
	end
end

__options.bool["HideInPauseMenu"] = ui.add_bool_option(TRANSLATION["Hide menu when pause"]..'*', __submenus["Settings"], function(bool)
	HudSound("TOGGLE_ON")
	settings.General["HideInPauseMenu"] = bool
	local paused
	CreateRemoveThread(bool, 'hide_menu_when_pause', function()
		if not paused and HUD.IS_PAUSE_MENU_ACTIVE() == 1 and NETWORK.NETWORK_IS_SESSION_STARTED() == 1 and ui.is_open() then
			paused = true
			ui.close()
		elseif HUD.IS_PAUSE_MENU_ACTIVE() == 0 and paused then
			ui.open()
			paused = false
		end
	end)
end)

__options.bool["HideOnActiveChat"] = ui.add_bool_option(TRANSLATION["Hide menu when chat is active"], __submenus["Settings"], function(bool)
	HudSound("TOGGLE_ON")
	settings.General["HideOnActiveChat"] = bool
	local chat_active
	CreateRemoveThread(bool, 'hide_menu_when_chat', function()
		if not chat_active and HUD._IS_MULTIPLAYER_CHAT_ACTIVE() == 1 and ui.is_open() then
			chat_active = true
		elseif HUD._IS_MULTIPLAYER_CHAT_ACTIVE() == 0 and chat_active then
			ui.open()
			chat_active = false
		elseif chat_active then
			ui.close()
		end
	end)
end)

__options.bool["ShowTypingIndicators"] = ui.add_bool_option(TRANSLATION["Show typing indicators"], __submenus["Settings"], function(bool)
	HudSound("TOGGLE_ON")
	settings.General["ShowTypingIndicators"] = bool
	CreateRemoveThread(bool, 'show_typing_indicator', function()
		for i = 0, 31
		do
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) and i ~= PLAYER.PLAYER_ID() and features.is_typing(i) then
				system.notify(TRANSLATION['Chat'], format(TRANSLATION["Player %s is typing..."], PLAYER.GET_PLAYER_NAME(i)), 0, 128, 255, 255)
			end
		end
	end)
end)

__options.bool["ShowPlayers3DPosition"] = ui.add_bool_option(TRANSLATION["Show 3D markers on players"], __submenus["Settings"], function(bool)
	HudSound("TOGGLE_ON")
	settings.General["ShowPlayers3DPosition"] = bool
	CreateRemoveThread(bool, 'show_players_position', function()
		if ui.get_value(__options.bool["FreeCam"]) then return end
		if ui.is_sub_open(__submenus["Session"]) or ui.is_sub_open(__submenus["Commands"]) or ui.is_sub_open(__submenus["VehicleBlacklist"]) or ui.is_sub_open(__submenus["BlacklistedVehicles"]) or ui.is_sub_open(__submenus["AddVehToBl"]) or ui.is_sub_open(__submenus["PlaySound"]) or ui.is_sub_open(__submenus["ChatMocker"]) or ui.is_sub_open(__submenus["SessionTeleport"]) or ui.is_sub_open(__submenus["ExcludedPlayers"]) or ui.is_sub_open(__submenus["SessionCustomExplosion"]) then
			for i = 0, 31
			do
				if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 then
					local pos = features.get_player_coords(i)
					if features.is_friend(i) then
						GRAPHICS.DRAW_LINE(pos.x, pos.y, -1000, pos.x, pos.y, 6000, 0, 255, 0, 255)
					else
						GRAPHICS.DRAW_LINE(pos.x, pos.y, -1000, pos.x, pos.y, 6000, 0, 168, 255, 255)
					end
				end
			end
		elseif ui.is_sub_open(__submenus["Imagined"]) or ui.is_sub_open(__submenus["PlayerlistVehicle"]) or ui.is_sub_open(__submenus["SpawnVehicle"]) or ui.is_sub_open(__submenus["PlayerlistTeleport"]) or ui.is_sub_open(__submenus["PlayerlistOther"]) or ui.is_sub_open(__submenus["Blame"]) or ui.is_sub_open(__submenus["SendEnemyVehicle"])  or ui.is_sub_open(__submenus["CustomExplosion"]) then
			local pos = features.get_player_coords2(online.get_selected_player())
			local my_pos = features.get_player_coords()
			local color = {r = 0, g = 168, b = 255}
			if features.is_friend(online.get_selected_player()) then
				color = {r = 0, g = 255, b = 0}
			end
			if ENTITY.IS_ENTITY_ON_SCREEN(features.player_ped(online.get_selected_player())) == 1 then
				GRAPHICS.DRAW_LINE(pos.x, pos.y, -1000, pos.x, pos.y, 6000, color.r, color.g, color.b, 255)
			else
				GRAPHICS.DRAW_LINE(my_pos.x, my_pos.y, my_pos.z, pos.x, pos.y, pos.z, color.r, color.g, color.b, 255)
			end
		end
	end)
end)

__options.bool["HudSounds"] = ui.add_bool_option(TRANSLATION["Hud sounds"], __submenus["Settings"], function(bool) HudSound("TOGGLE_ON")
	settings.General["HudSounds"] = bool
end)

__options.bool["DisableNotifications"] = ui.add_bool_option(TRANSLATION["Disable notifications"], __submenus["Settings"], function(bool) HudSound("TOGGLE_ON")
	settings.General["DisableNotifications"] = bool
end)

__options.bool["NotificationSound"] = ui.add_bool_option(TRANSLATION["Notification sound"], __submenus["Settings"], function(bool) HudSound("TOGGLE_ON")
	settings.General["NotificationSound"] = bool
end)

ui.add_separator(TRANSLATION['Configs'], __submenus["Settings"])
__options.click["Save Config"] = ui.add_click_option(TRANSLATION["Save config"], __submenus["Settings"], function() HudSound("SELECT") SaveConfig() end)
__options.click["Load Config"] = ui.add_click_option(TRANSLATION["Load config"], __submenus["Settings"], function() HudSound("SELECT") LoadConfig();LoadConfTog(settings) end)

ui.add_separator(TRANSLATION['Other'], __submenus["Settings"])

__options.bool["ShowControls"] = ui.add_bool_option(TRANSLATION["Show controls"]..'*', __submenus["Settings"], function(bool)
	HudSound("TOGGLE_ON")
	settings.General["ShowControls"] = bool
end)

__options.bool["AutoSave"] = ui.add_bool_option(TRANSLATION["Auto save settings"]..'*', __submenus["Settings"], function(bool)
	HudSound("TOGGLE_ON")
	settings.General["AutoSave"] = bool
end)

ui.add_click_option(TRANSLATION["Reset to default"], __submenus["Settings"], function()
	HudSound("SELECT")
	LoadConfTog(cache:get('Default config'))
end)

__submenus["Help"] = ui.add_submenu(TRANSLATION["Help"])
__suboptions["Help"] = ui.add_sub_option(TRANSLATION["Help"], __submenus["Settings"], __submenus["Help"])

ui.add_click_option('(*) '..TRANSLATION["means recommended"], __submenus["Help"], function() HudSound("Error") end)
ui.add_click_option('(») '..TRANSLATION["means hyperlink"], __submenus["Help"], function() HudSound("Error") end)
ui.add_click_option(format(TRANSLATION["Press %s to use free cam"], 'F8'), __submenus["Help"], function() HudSound("Error") end)

if settings.Dev.Enable then
	ui.add_separator('Dev', __submenus["Settings"])

	ui.add_click_option("Print active threads", __submenus["Settings"], function()
		HudSound("SELECT")
		local active_threads = 0
		for k, v in pairs(threads) do
			active_threads = active_threads + 1
			system.log('Imagined Menu', format('Thread: %s, run time: %.3fs', k, clock() - v[2]))
		end
		system.log('Imagined Menu', 'Active Threads: '..active_threads)
		system.log('Imagined Menu', format('Last tick time: %.3fs', ticktime))
	end)

	ui.add_click_option("Print avarage tick time", __submenus["Settings"], function()
		HudSound("SELECT")
		system.log('Imagined Menu', format('Avarage tick time: %.3fs', avgticktime))
	end)

	local threads = 300
	local loops = 10000
	ui.add_separator('Stress test', __submenus["Settings"])
	local num_th = ui.add_num_option('Threads', __submenus["Settings"], 1, 1000, 10, function(int) HudSound("YES") threads = int end)
	local num_lp = ui.add_num_option('Loops', __submenus["Settings"], 1, 1000000, 10, function(int) HudSound("YES") loops = int end)
	ui.set_value(num_th, threads, true)
	ui.set_value(num_lp, loops, true)

	ui.add_click_option("Run", __submenus["Settings"], function()
		HudSound("SELECT")
		system.log('Imagined Menu', format('Starting stress test on %i threads and %i loops', threads, loops))
		GetAvgTickTimes()
		for i = 1, threads do
			CreateRemoveThread(true, 'stress_test_'..thread_count, function()
				for t = 1, loops do sqrt(random(0,147483647)) end
				if not _getting_avg_tick then return POP_THREAD end
			end, true, true)
		end
	end)
end

__submenus["Credits"] = ui.add_submenu(TRANSLATION["Credits"])
__suboptions["Credits"] = ui.add_sub_option(TRANSLATION["Credits"], __submenus["MainSub"], __submenus["Credits"])
local click = 0
ui.add_click_option(format(TRANSLATION['%s for scripting'], 'SATTY'), __submenus["Credits"], function() click = click + 1 if system.is_safe_mode_enabled() then return HudSound("ERROR") end HudSound("SELECT") features.to_clipboard("SATTY", true) end)
ui.add_click_option(format(TRANSLATION['%s for bug finding'], 'Dr Donger'), __submenus["Credits"], function() if system.is_safe_mode_enabled() then return HudSound("ERROR") end HudSound("SELECT") features.to_clipboard("Dr Donger", true) end)
ui.add_click_option(format(TRANSLATION['%s for improving lua API'], 'ItsPxel'), __submenus["Credits"], function() if system.is_safe_mode_enabled() then return HudSound("ERROR") end HudSound("SELECT") features.to_clipboard("ItsPxel", true) end)
if not TRANSLATION[1]['Credits']:isblank() then
	ui.add_click_option(format(TRANSLATION['%s for translation'], TRANSLATION[1]['Credits']), __submenus["Credits"], function() if system.is_safe_mode_enabled() then return HudSound("ERROR") end HudSound("SELECT") features.to_clipboard(TRANSLATION[1]['Credits'], true) end)
end
ui.add_click_option("DurtyFree »", __submenus["Credits"], function() HudSound("SELECT") filesystem.open("https://github.com/DurtyFree") end)
ui.add_click_option("Sainan »", __submenus["Credits"], function() HudSound("SELECT") filesystem.open("https://github.com/Sainan") end)
ui.add_click_option("Stack Overflow »", __submenus["Credits"], function() HudSound("SELECT") filesystem.open("https://stackoverflow.com") end)
ui.add_click_option("alloc8or »", __submenus["Credits"], function() HudSound("SELECT") filesystem.open("https://alloc8or.re/gta5/nativedb/") end)
ui.add_click_option("Parik27 »", __submenus["Credits"], function() HudSound("SELECT") filesystem.open("https://github.com/Parik27") end)

for _, v in pairs(__options.bool) do
	ui.set_value(v, false, true)
end

LoadConfTog(settings)
vehicle_blacklist.load()

CreateRemoveThread(true, 'debug_menu', function()
	if click > 20 then
		local sub = ui.add_submenu("Debug")
		__options.bool["DebugSELog"] = ui.add_bool_option('Log script events', sub, function() HudSound("TOGGLE_ON") end)
		ui.add_sub_option("Debug", __submenus["MainSub"], sub)
		ui.add_num_option("Blip", sub, 0, 1000, 1, function(int)
			local blip = HUD.GET_FIRST_BLIP_INFO_ID(int)
			while HUD.DOES_BLIP_EXIST(blip) == 1 do
				system.log('blip', tostring(vector3(HUD.GET_BLIP_COORDS(blip))))
				blip = HUD.GET_NEXT_BLIP_INFO_ID(int)
			end
		end)
		local x1 = 0
		local y1 = 0
		local z1 = 0
		local x2 = 0
		local y2 = 0
		local z2 = 0
		ui.add_separator('Box', sub)
		ui.add_float_option("X1", sub, -10000, 10000, 1, 3, function(float) x1 = float end)
		ui.add_float_option("Y1", sub, -10000, 10000, 1, 3, function(float) y1 = float end)
		ui.add_float_option("Z1", sub, -10000, 10000, 1, 3, function(float) z1 = float end)
		ui.add_float_option("X2", sub, -10000, 10000, 1, 3, function(float) x2 = float end)
		ui.add_float_option("Y2", sub, -10000, 10000, 1, 3, function(float) y2 = float end)
		ui.add_float_option("Z2", sub, -10000, 10000, 1, 3, function(float) z2 = float end)
		ui.add_bool_option('Draw', sub, function(bool)
			CreateRemoveThread(bool, 'draw_debug_box', function()
				GRAPHICS.DRAW_LINE(x1, y1, z1, x1, y1, z2, 255, 255, 255, 255)
				GRAPHICS.DRAW_LINE(x1, y1, z1, x1, y2, z1, 255, 255, 255, 255)
				GRAPHICS.DRAW_LINE(x1, y1, z1, x2, y1, z1, 255, 255, 255, 255)
				GRAPHICS.DRAW_LINE(x1, y1, z2, x2, y1, z2, 255, 255, 255, 255)
				GRAPHICS.DRAW_LINE(x1, y1, z2, x1, y2, z2, 255, 255, 255, 255)
				GRAPHICS.DRAW_LINE(x1, y2, z1, x1, y2, z2, 255, 255, 255, 255)
				GRAPHICS.DRAW_LINE(x1, y2, z1, x2, y2, z1, 255, 255, 255, 255)
				GRAPHICS.DRAW_LINE(x2, y2, z2, x2, y2, z1, 255, 255, 255, 255)
				GRAPHICS.DRAW_LINE(x2, y2, z2, x2, y1, z2, 255, 255, 255, 255)
				GRAPHICS.DRAW_LINE(x2, y2, z2, x1, y2, z2, 255, 255, 255, 255)
				GRAPHICS.DRAW_LINE(x2, y1, z1, x2, y1, z2, 255, 255, 255, 255)
				GRAPHICS.DRAW_LINE(x2, y1, z1, x2, y2, z1, 255, 255, 255, 255)
			end)
		end)
		local x = 0
		local y = 0
		local z = 0
		local rad = 0
		ui.add_separator('Sphere', sub)
		ui.add_float_option("X", sub, -10000, 10000, 1, 3, function(float) x = float end)
		ui.add_float_option("Y", sub, -10000, 10000, 1, 3, function(float) y = float end)
		ui.add_float_option("Z", sub, -10000, 10000, 1, 3, function(float) z = float end)
		ui.add_float_option("Rad", sub, 0, 10000, 1, 3, function(float) rad = float end)
		ui.add_bool_option('Draw', sub, function(bool)
			CreateRemoveThread(bool, 'draw_debug_sphere', function()
				GRAPHICS._DRAW_SPHERE(x, y, z, rad, 255, 255, 255, .5)
			end)
		end)

		local lastveh
		local cases = {}
		ui.add_bool_option("Get fuel", sub, function(bool)
			CreateRemoveThread(bool, 'fuel_get', function()
				local veh = vehicles.get_player_vehicle()
				if veh == 0 or veh == lastveh then return end
				lastveh = veh
				local fuel = vehicles.fuel_get(veh)
				if fuel ~= 65 then
					local str = string.format(":case(%i, function()\n\treturn %s\nend)", ENTITY.GET_ENTITY_MODEL(veh), fuel)
					features.to_clipboard(str, true)
					for _, v in ipairs(cases)
					do
						if v == str then return end
					end
					table.insert(cases, str)
				end
			end)
		end)
		ui.add_click_option("Print cases", sub, function()
			system.log('debug', concat(cases, '\n'))
		end)

		ui.add_click_option("Print empty translation", sub, function()
			cache:set("TRANSLATION", TRANSLATION)
			local translation = cache:get("TRANSLATION")
			for k in pairs(translation)
			do
				translation[k] = ""
			end
			filesystem.write(json:encode_pretty(translation), paths['Lua']..[[\translation.txt]])
		end)

		return POP_THREAD
	end
end)

do
	local scaleform = GRAPHICS.REQUEST_SCALEFORM_MOVIE("MP_BIG_MESSAGE_FREEMODE")
	while GRAPHICS.HAS_SCALEFORM_MOVIE_LOADED(scaleform) == 0
	do 
		system.yield()
	end
	system.log('Imagined Menu', 'Loaded successfully')
	local welcome = (not settings.General["TutorialCompleted"] and TRANSLATION["Welcome %s to Imagined Menu!"] or TRANSLATION["Welcome back %s!"])
	system.notify('Imagined Menu', format(welcome..'\n%s %s\n%s %s, %s %s %s', PLAYER.GET_PLAYER_NAME(PLAYER.PLAYER_ID()), TRANSLATION["Version"], VERSION, TRANSLATION["Credits to"], 'SATTY', 'Dr Donger', TRANSLATION["and"], 'ItsPxel'), 0, 255, 0, 255)
	AUDIO.PLAY_SOUND_FRONTEND(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true)
	local t = clock() + 2.5
	CreateRemoveThread(true, 'start_screen', function()
		if clock() <= t then
	    GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
	    GRAPHICS.DRAW_SCALEFORM_MOVIE_FULLSCREEN(scaleform, 0, 0, 0, 0, 0)
	    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING('~p~'..TRANSLATION["Welcome"])
	    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING(format('~b~'..welcome, (PLAYER.GET_PLAYER_NAME(PLAYER.PLAYER_ID()):gsub('~.~', ''))))
	    GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
		return
		end
		AUDIO.PLAY_SOUND_FRONTEND(-1, "FocusOut", "HintCamSounds", true)
		return POP_THREAD
	end)
end

---------------------------------------------------------------------------------------------------------------------------------
-- Main Loop
---------------------------------------------------------------------------------------------------------------------------------

do
	CreateRemoveThread(true, 'main', function(tick)
		if ENTITY.GET_ENTITY_ALPHA(features.player_ped()) ~= ui.get_value(__options.num["Set Alpha"]) then
			ui.set_value(__options.num["Set Alpha"], ENTITY.GET_ENTITY_ALPHA(features.player_ped()), true)
		end
		if ui.get_value(__options.bool["DisableCollision"]) ~= (ENTITY.GET_ENTITY_COLLISION_DISABLED(features.player_ped()) == 1) then
			ui.set_value(__options.bool["DisableCollision"], ENTITY.GET_ENTITY_COLLISION_DISABLED(features.player_ped()) == 1, true)
		end
		if vehicles.get_player_vehicle() ~= 0 then
			if ui.get_value(__options.bool["InvisibleVehicle"]) ~= (ENTITY.IS_ENTITY_VISIBLE(vehicles.get_player_vehicle()) == 0) then
				ui.set_value(__options.bool["InvisibleVehicle"], ENTITY.IS_ENTITY_VISIBLE(vehicles.get_player_vehicle()) == 0, true)
			end
			if ui.get_value(__options.bool["DisableVehicleCollision"]) ~= (ENTITY.GET_ENTITY_COLLISION_DISABLED(vehicles.get_player_vehicle()) ~= 0) then
				ui.set_value(__options.bool["DisableVehicleCollision"], ENTITY.GET_ENTITY_COLLISION_DISABLED(vehicles.get_player_vehicle()) ~= 0, true)
			end
			if ui.get_value(__options.num["VehicleAlpha"]) ~= ENTITY.GET_ENTITY_ALPHA(vehicles.get_player_vehicle()) then
				ui.set_value(__options.num["VehicleAlpha"], ENTITY.GET_ENTITY_ALPHA(vehicles.get_player_vehicle()), true)
			end
		end

		if tick%300==0 then
			if settings.General["AutoSave"] then
				SaveConfig()
			end
		end
	end)
end
local last_ticks = {}
local memoized
local is_open
local open = ui.is_open()
local time
if settings.Dev.Enable then system.log('debug', 'stated') end
local prev_sub
local this_thread
local this_name
local foo = function()
	return this_thread(ticks[this_name])
end
local err = function(e)
	system.notify(TRANSLATION["Error"], TRANSLATION["Caught an exception"], 255, 0, 0, 255, true)
	system.log("ERROR", "Caught an exception, thread: "..this_name)
	system.log("ERROR", e)
	return 0
end
settings.General["TutorialCompleted"] = true
SaveConfig()

while gRunning
do
	time = clock()
	if dont_play_tog then
		dont_play_tog = false
	end

	globals.set_int(4539659, 1) -- bypass for vehicle despawn

	local found
	for k, v in pairs(__submenus)
	do
		if ui.is_sub_open(v) then
			found = true
			if v ~= prev_sub then
				HudSound("continue")
				prev_sub = v
				break
			end
		end
	end

	PAD.DISABLE_CONTROL_ACTION(0, enum.input.SELECT_CHARACTER_MULTIPLAYER, true)
	if PAD.IS_DISABLED_CONTROL_JUST_RELEASED(0, enum.input.SELECT_CHARACTER_MULTIPLAYER) == 1 then
		ui.set_value(__options.bool["FreeCam"], not ui.get_value(__options.bool["FreeCam"]), false)
	end

	if is_open and not found then
		is_open = false
		HudSound("continue")
	elseif not is_open and found then
		is_open = true
		HudSound("continue")
	end

	if not open and ui.is_open() then
		HudSound("continue")
		open = true
	elseif open and not ui.is_open() then
		HudSound("Back")
		open = false
	end

	for k, v in pairs(threads) 
	do
		if not ticks[k] then 
			ticks[k] = 0
		else
			ticks[k] = ticks[k] + 1
		end
		this_thread = v[1]
		this_name = k
		local ok, value = xpcall(foo, err)
		if value == POP_THREAD or not ok then 
			CreateRemoveThread(false, k) 
			if settings.Dev.Enable then system.log('debug', format('thread %s finished', k)) end
		end
	end

	s_memory.free()

	system.yield()

	ticktime = clock() - time

	if memoized or #last_ticks == 10 then
		memoized = true
		table_remove(last_ticks, 1) 
	end

	insert(last_ticks, ticktime)
	avgticktime = features.sum_table(last_ticks) / (memoized and 10 or #last_ticks)

	if settings.Dev.Enable and avgticktime > settings.Dev.TickTimeLimit then
		system.notify(TRANSLATION['Warning'], TRANSLATION['Too high ticktime!'], 255, 0, 0, 255) 
	end
end
