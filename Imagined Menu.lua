--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--
VERSION = '1.1.2'

system.log('Imagined Menu', string.format('Loading Imagined Menu v%s...', VERSION))

local function string_cut(s,pattern)
  if not pattern then pattern = " " end
  local cutstring = {}
  local i1 = 0
  repeat
    local i2
    i2 = string.find(s,pattern,i1+1)
    if i2 == nil then i2 = string.len(s)+1 end
    table.insert(cutstring,string.sub(s,i1+1,i2-1))
    i1 = i2
  until i2 == string.len(s)+1
  return cutstring
end

local function getScriptDir(source)
  if not source then
    source = debug.getinfo(1).source
  end
  local pwd1 = (io.popen("echo %cd%"):read("*l")):gsub("\\","/")
  local pwd2 = source:sub(2):gsub("\\","/")
  local pwd = ""
  if pwd2:sub(2,3) == ":/" then
    pwd = pwd2:sub(1,pwd2:find("[^/]*%.lua")-1)
  else
    local path1 = string_cut(pwd1:sub(4),"/")
    local path2 = string_cut(pwd2,"/")
    for i = 1,#path2-1 do
      if path2[i] == ".." then
        table.remove(path1)
      else
        table.insert(path1,path2[i])
      end
    end
    pwd = pwd1:sub(1,3)
    for i = 1,#path1 do
      pwd = pwd..path1[i].."/"
    end
  end
  return pwd
end

paths = {}
paths['Lua'] = getScriptDir()
paths['ImaginedMenu'] = paths['Lua']..[[ImaginedMenu]]
paths['Library'] = paths['ImaginedMenu']..[[\lib]]
paths['Data'] = paths['ImaginedMenu']..[[\imagined_menu]]
paths['Translations'] = paths['ImaginedMenu']..[[\translations]]
paths['SavedVehicles'] = paths['ImaginedMenu']..[[\saved_vehicles]]

files = {
	['Config'] = paths['ImaginedMenu']..[[\config.json]],
	['VehicleBlacklist'] = paths['ImaginedMenu']..[[\vehicle_blacklist.json]],
	['PlayerExcludes'] = paths['ImaginedMenu']..[[\player_excludes.json]],
	['Json'] = paths['Library']..[[\JSON.lua]],
	['VehData'] = paths['Data']..[[\vehicle_data.json]],
	['Default'] = paths['Data']..[[\default.lua]],
	['features'] = paths['Data']..[[\features.lua]],
	['Vectors'] = paths['Data']..[[\vectors.lua]],
	['Vehicle'] = paths['Data']..[[\vehicle.lua]],
	['Enums'] = paths['Data']..[[\enums.lua]],
	['Weapons'] = paths['Data']..[[\weapons.lua]],
	['Peds'] = paths['Data']..[[\peds.lua]],
	['Props'] = paths['Data']..[[\props.lua]],
	['ObjectList'] = paths['Data']..[[\objectlist.txt]],
}

package.path = package.path..";"..paths['Library']..[[\?.lua]]
package.path = package.path..";"..paths['Data']..[[\?.lua]]

local json = require 'JSON'
local f = require 'default'
TRANSLATION = f.translation
local features = require 'features'
local vehicles = require 'vehicle'
local peds = require 'peds'
local objects = require 'props'
local weapons = require 'weapon'
local enum = require 'enums'
local custom_vehicles = require 'custom_vehicles'
local vector3 = require 'vector3'
local file = require 'files'
local settings = f.settings
local default = {}
-- local WorldPtr = memory.find_pattern("48 8B 05 ? ? ? ? 45 ? ? ? ? 48 8B 48 08 48 85 C9 74 07")
-- WorldPtr = (WorldPtr + memory.read_int(WorldPtr + 3) + 7)
-- WorldPtr = memory.read_int64(WorldPtr)

-- if WorldPtr == 0 then
-- 	error("Filed to find some patterns", 0)
-- end

-- local ptr = features.get_memory_pointer(WorldPtr, {0x08, 0x10D8, 0x20, 0x54})

if not file.isdir(paths['Translations']) then
	file.make_dir(paths['Translations'])
end

if not file.isdir(paths['SavedVehicles']) then
	file.make_dir(paths['SavedVehicles'])
end

for k, v in pairs(settings) do
	default[k] = {}
	for i, e in pairs(v) do
		default[k][i] = e
	end
end

local __submenus = {}
local __suboptions = {}
local __options = {
	bool = {},
	click = {},
	num = {},
	choose = {},
	players = {}
}
string.empty = ""
local gRunning = true
local NULL = 0
local POP_THREAD = 0
local threads = {}
local thread_queue = {}
local active_threads = 0
local thread_count = 0
local ticks = {}
local ticktime = 0
local avgticktime = 0
local created_preview
local playerlist = {}
-- features
local function AddThreadFromQueue()
	if os.clock() - thread_queue[1][3] > 5.0 then 
		table.remove(thread_queue, 1)
		return 
	end
	ticks[thread_queue[1][1]] = nil
	threads[thread_queue[1][1]] = {thread_queue[1][2], os.clock()}
	table.remove(thread_queue, 1)
	active_threads = active_threads + 1
	return true
end

function CreateRemoveThread(...)
	local add, name, func, canqueue, highpriority = ...
	active_threads = 0
	for _ in pairs(threads) do
		active_threads = active_threads + 1
	end

	if add then
		if settings.Dev.Enable then system.log('debug', string.format('adding thread %s', name)) end
		thread_count = thread_count + 1
		-- if avgticktime > settings.Dev.TickTimeLimit and not highpriority then
		-- 	system.log('Imagined Menu', 'Failed to add a new thread, to high ticktime (over 35ms) might cause some major lags')
		-- 	if #thread_queue < 100 and canqueue then table.insert(thread_queue, {name,func,os.clock()}) system.log('Imagined Menu', 'Adding thread to queue') end
		-- 	return false
		-- elseif active_threads > settings.Dev["ThreadLimit"] and not threads[name] and not highpriority then 
		-- 	system.log('Imagined Menu', 'Failed to add a new thread, hit limit: '..settings.Dev["ThreadLimit"])
		-- 	if #thread_queue < 100 and canqueue then table.insert(thread_queue, {name,func,os.clock()}) system.log('Imagined Menu', 'Adding thread to queue') end
		-- 	return false
		-- end
		threads[name] = {func, os.clock()}
		active_threads = active_threads + 1
	else 
		if not threads[name] then return false end
		if settings.Dev.Enable then system.log('debug', string.format('removing thread %s', name)) end
		threads[name] = nil
		active_threads = active_threads - 1
		while #thread_queue > 0 do
			if AddThreadFromQueue() then break end
		end
	end
	ticks[name] = nil
	return true
end

local _getting_avg_tick
local function GetAvgTickTimes()
	_getting_avg_tick = true
	system.log('Imagined Menu', 'Collecting tick times...')
	local tick_times = {}
	CreateRemoveThread(true, 'getting_avg_tick_time_'..thread_count, 
	function(tick)
		if tick ~= 100 then
			table.insert(tick_times, ticktime)
		else
			system.log('Imagined Menu', string.format('Avarage tick time: %.3fs', (features.sum_table(tick_times) / #tick_times)))
			_getting_avg_tick = false
			return POP_THREAD
		end
	end, true, true)
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
  	if features.request_model(object) == NULL then return end
    local obj = features.create_object(object, vector3(x, y, z))
    if obj == NULL then return POP_THREAD end
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(obj, false, true)
    ENTITY._SET_ENTITY_CLEANUP_BY_ENGINE(obj, true)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(obj, x, y, z, false, false, false)
    ENTITY.SET_ENTITY_ROTATION(obj, rotx, roty, rotz, 5, true)
    ENTITY.FREEZE_ENTITY_POSITION(obj, true)
    table.insert(blockobjects, obj)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(object)
    if not invisible then return POP_THREAD end
    ENTITY.SET_ENTITY_VISIBLE(obj, false, false)
   	return POP_THREAD
	end)
end

local function PlaySound(name, ref, entity)
	local entity = entity or PLAYER.PLAYER_PED_ID()
	AUDIO.PLAY_SOUND_FROM_ENTITY(-1, name, entity, ref, true, 0)
end

local function StopSounds()
	for i = 0, 100
	do
		AUDIO.STOP_SOUND(i)
	end
end

local function RevivePed(ped)
	local anim_dict = "get_up@directional@movement@from_knees@standard"
	local anim_name = "getup_r_90"
	local tick = 0
	CreateRemoveThread(true, 'revive_'..ped, function()
		if STREAMING.HAS_ANIM_DICT_LOADED(anim_dict) == NULL then
			STREAMING.REQUEST_ANIM_DICT(anim_dict)
			return
		end
		tick = tick + 1
		if tick == 1 then
			entities.request_control(ped, function()
				ENTITY.SET_ENTITY_HEALTH(ped, 200, 0)
				ENTITY.SET_ENTITY_MAX_HEALTH(ped, 400)
				PED.RESURRECT_PED(ped)
				PED.REVIVE_INJURED_PED(ped)
				ENTITY.SET_ENTITY_HEALTH(ped, 200, 0)
				PED.SET_PED_GENERATES_DEAD_BODY_EVENTS(ped, false)
				PED.SET_PED_CONFIG_FLAG(ped, 166, false)
				PED.SET_PED_CONFIG_FLAG(ped, 187, false)
				TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
				peds.play_anim(ped, anim_dict, anim_name, 8, -8, -1, enum.anim_flag.StopOnLastFrame, 0, false)
			end)
		end
		if tick < 100 then return end
		entities.request_control(ped, function()
			TASK.TASK_WANDER_STANDARD(ped, 10, 10)
		end)
		return POP_THREAD
	end)
end

local function BlockPassive(type)
	for i = 0, 31 do
		if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
			online.send_script_event(i, 1114091621, PLAYER.PLAYER_ID(), type)
			-- system.log('debug', "Script event sent to "..online.get_name(i))
		end
	end
end

local function InfiniteInvite(type)
	for i = 0, 31 do
			if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
      	online.send_script_event(i, 603406648, PLAYER.PLAYER_ID(), i, 4294967295, 1, 115, type, type, type)
      	-- system.log('debug', "Script event sent to "..online.get_name(i))
      end
  end
end


local function AskingForMoney(message)
	local text = message:gsub(" +", string.empty):lower()
	for _, v in ipairs(enum.begger_messages)
	do
		if text:find(v) then
			return true
		end
	end
	return false
end

local commad_prefix = {[0]='nf!',[1]='%/', [2]='\\',[3]='%!',[4]='%$',[5]='%%',[6]='%&',[7]='%-',[8]='%+',[9]='%?',[10]='%*',[11]='%,',[12]='%.',[13]='%#',[14]='%€',[15]='%@'}
local function IsCommand(command)
	if command:lower():find(string.format('^%s', commad_prefix[settings.Commands['CommandsPrefix']])) then return true end
end

-- commands
local cmd = {
	spawn = function(id, veh)
		if not veh then return end
		CreateRemoveThread(true, 'cmd_spawn_'..thread_count, function(tick)
			if tick==3000 then return POP_THREAD end
			local loaded, hash = features.request_model(veh)
			if hash == NULL then return POP_THREAD end
			if STREAMING.IS_MODEL_A_VEHICLE(hash) == NULL then return POP_THREAD end
			if settings.Session["VehicleBlacklist"] and vehicle_blacklist.vehicles[tostring(hash)] then system.notify(TRANSLATION["Info"], string.format(TRANSLATION["Player %s tried to spawn a blacklisted vehicle"], online.get_name(id)), 255, 0, 0, 255) return end
			if loaded == NULL then return end
			local target = features.get_offset_coords_from_entity_rot(
				PLAYER.GET_PLAYER_PED(id), 
				6, 0, true)
			local vehicle = vehicles.spawn_vehicle(hash, target, features.get_player_heading(id))
			if vehicle == NULL then return POP_THREAD end
			entities.request_control(vehicle, function() 
				DECORATOR.DECOR_SET_INT(vehicle, "MPBitset", 1024)
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
		if (target == PLAYER.PLAYER_ID()) or (settings.Commands["Don't Affect Friends"] and features.is_friend(target)) or (NETWORK.NETWORK_IS_PLAYER_CONNECTED(target) == NULL) or features.is_excluded(target) then return end
		if bool == 'off' then
			playerlist[target]["Freeze"] = false
		else
			playerlist[target]["Freeze"] = true
		end
	end,
	island = function(id, pl)
		local target = features.player_from_name(pl)
		CreateRemoveThread(true, 'cmd_island_'..id, function()
			if (not target) or (settings.Commands["Don't Affect Friends"] and features.is_friend(target)) or features.is_excluded(target) --[=[or (i == id)]=] then return POP_THREAD end
			online.send_script_event(target, -621279188, PLAYER.PLAYER_ID(), 1)
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
			local pos = features.get_player_coords(target)
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
					local pos = features.get_player_coords(i)
					FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, enum.explosion.ROCKET, 10, true, false, 1.0, false)
				end
			end
			return POP_THREAD
		end)
	end,
	clearwanted = function(id, bool) 
		CreateRemoveThread(true, 'cmd_clearwanted_'..id, function(tick)
			if tick%5~=NULL then return end
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(id) == NULL or bool == 'off' then return POP_THREAD end
			online.send_script_event(id, -91354030, id, globals.get_int(1893551 + (1 + (id * 599) + 510)))
			online.send_script_event(id, 1722873242, PLAYER.PLAYER_ID(), 0, 0, NETWORK.GET_NETWORK_TIME(), 0, globals.get_int(1893551 + (1 + (id * 599) + 510)))
		end)
	end,
	offradar = function(id, bool) 
		CreateRemoveThread(true, 'cmd_offradar_'..id, function(tick)
			if tick%5~=NULL then return end
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(id) == NULL or bool == 'off' then return POP_THREAD end
			online.send_script_event(id, -391633760, PLAYER.PLAYER_ID(), NETWORK.GET_NETWORK_TIME() - 60, NETWORK.GET_NETWORK_TIME(), 1, 1, globals.get_int(1893551 + (1 + (id * 599) + 510)))
		end)
	end,
	vehiclegod = function(id, bool) 
		CreateRemoveThread(true, 'cmd_vehiclegod_'..id, function()
			local value = true
			if bool then
				if bool == 'off' then value = false end
			end
			local veh = vehicles.get_player_vehicle(id)
			if veh == NULL then return POP_THREAD end
			entities.request_control(veh, function() vehicles.set_godmode(veh, value) end)
			return POP_THREAD
		end)
	end,
	upgrade = function(id) 
		CreateRemoveThread(true, 'cmd_upgrade_'..id, function()
			local veh = vehicles.get_player_vehicle(id)
			if veh == NULL then return POP_THREAD end
			entities.request_control(veh, function() vehicles.upgrade(veh) end)
			return POP_THREAD
		end)
	end,
	repair = function(id) 
		CreateRemoveThread(true, 'cmd_repair_'..id, function()
			local veh = vehicles.get_player_vehicle(id)
			if veh == NULL then return POP_THREAD end
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
				if not (settings.Commands["Don't Affect Friends"] and features.is_friend(i)) and (i ~= id) and (i ~= PLAYER.PLAYER_ID()) and not features.is_excluded(i) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 then
					features.set_bounty(i, amount)
				end
			end
			return POP_THREAD
		end)
	end,
	apartment = function(id, pl, apart)
		local target = features.player_from_name(pl)
		local apart = (apart and tonumber(apart) and tonumber(apart) > 0 and tonumber(apart) < 115) and math.floor(tonumber(apart)) or 1
		CreateRemoveThread(true, 'cmd_explode_'..id, function()
			if (not target) or (settings.Commands["Don't Affect Friends"] and features.is_friend(target)) or features.is_excluded(target) --[=[or (i == id)]=] then return POP_THREAD end
			online.send_script_event(target, 603406648, PLAYER.PLAYER_ID(), target, 1, 0, apart, 1, 1, 1)
			return POP_THREAD
		end)
	end,
	killaliens = function(id, bool)
		ui.set_value(__options.bool["KillAliens"], bool == 'off' and false or true, false)
	end,
	kickbarcodes = function(id, bool)
		ui.set_value(__options.bool["KickBarcodes"], bool == 'off' and false or true, false)
	end,
}

local function HandleCommand(command, id)
	if settings.Dev.Enable then system.log('debug', string.format('command from %i', id)) end
	if command[1] == 'spawn' then cmd.spawn(id, command[2]) return true end
	if command[1] == 'freeze' then cmd.freeze(id, command[2], command[3]) return true end
	if command[1] == 'island' then cmd.island(id, command[2]) return true end
	if command[1] == 'kick' then cmd.kick(id, command[2]) return true end
	if command[1] == 'crash' then cmd.crash(id, command[2]) return true end
	if command[1] == 'explode' then cmd.explode(id, command[2]) return true end
	if command[1] == 'kickall' then cmd.kickAll(id) return true end
	if command[1] == 'crashall' then cmd.crashAll(id) return true end
	if command[1] == 'explodeall'	then cmd.explodeAll(id) return true end
	if command[1] == 'clearwanted' then cmd.clearwanted(id, command[2]) return true end
	if command[1] == 'offradar' then cmd.offradar(id, command[2]) return true end
	if command[1] == 'vehiclegod' then cmd.vehiclegod(id, command[2]) return true end
	if command[1] == 'upgrade' then cmd.upgrade(id) return true end
	if command[1] == 'repair' then cmd.repair(id) return true end
	if command[1] == 'freezeall' then cmd.freezeall(id, command[2]) return true end
	if command[1] == 'bounty' then cmd.bounty(id, command[2], command[3]) return true end
	if command[1] == 'bountyall' then cmd.bountyall(id, command[2]) return true end
	if command[1] == 'apartment' then cmd.apartment(id, command[2], command[3]) return true end
	if command[1] == 'killaliens' then cmd.killaliens(id, command[2]) return true end
	if command[1] == 'kickbarcodes' then cmd.kickbarcodes(id, command[2]) return true end
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

function on_chat_message(...)
	local id, is_team, text, spoofed_as_ply = ... 
	if settings.Misc["LogChat"] then
		system.log(string.format("Chat|%s", is_team == true and 'Team' or 'All'), string.format("%s wrote: %s", online.get_name(id), text))
	end
	if settings.Session["PunishBeggers"] ~= NULL and spoofed_as_ply == -1 and AskingForMoney(text) then
  	if not (settings.General["Exclude Friends"] and features.is_friend(id)) and not features.is_excluded(id) then
			if settings.Session["PunishBeggers"] == 1 then
    		CreateRemoveThread(true, 'begger_punishment_'..thread_count, function()
    			local pos = features.get_player_coords(id)
    			local veh = vehicles.get_player_vehicle(id)
    			if veh ~= NULL then
    				entities.request_control(veh, function()
    					local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(veh)
							vehicles.set_godmode(veh, false)
							NETWORK.NETWORK_EXPLODE_VEHICLE(veh, true, false, netId)
    				end)
    			end
    			FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, enum.explosion.ROCKET, 10, true, false, 1.0, false)
    			return POP_THREAD
    		end)
    	elseif settings.Session["PunishBeggers"] == 2 then
    		playerlist[id]["Freeze"] = true
    	elseif settings.Session["PunishBeggers"] == 3 then
    		CreateRemoveThread(true, 'begger_punishment_'..thread_count, function()
    			features.kick_player(id)
    			return POP_THREAD
    		end)
    	elseif settings.Session["PunishBeggers"] == 4 then
    		CreateRemoveThread(true, 'begger_punishment_'..thread_count, function()
    			features.crash_player(id)
    			return POP_THREAD
    		end)
    	end
    end
  end

  if spoofed_as_ply == -1 and IsCommand(text) then
  	local text = text:lower():gsub(string.format('^%s', commad_prefix[settings.Commands['CommandsPrefix']]), '')
  	if settings["Commands"]["Friends Only"] and not features.is_friend(id) and not playerlist[id].Commands then return true end
  	local command = features.split(text, ' +')
  	if command[1] == 'kill' then command[1] = 'explode' end
  	if command[1] == 'killa' then command[1] = 'explodeall' end
  	if command[1] == 'nocop' then command[1] = 'clearwanted' end
  	if command[1] == 'ghost' then command[1] = 'offradar' end
  	if command[1] == 'god' then command[1] = 'vehiclegod' end
  	if command[1] == 'vaca' then command[1] = 'island' end
  	if command[1] == 'sp' then command[1] = 'spawn' end
  	if command[1] == 'rep' then command[1] = 'repair' end
  	if command[1] == 'fix' then command[1] = 'repair' end
  	if command[1] == 'upg' then command[1] = 'upgrade' end 
  	if command[1] == 'bye' then command[1] = 'crash' end
  	if command[1] == 'byea' then command[1] = 'crashall' end
  	if command[1] == 'nomove' then command[1] = 'freeze' end
  	if command[1] == 'leave' then command[1] = 'kick' end
  	if command[1] == 'plsleave' then command[1] = 'kickall' end
  	if command[1] == 'nomovea' then command[1] = 'freezeall' end
  	if command[1] == 'hunt' then command[1] = 'bounty' end
  	if command[1] == 'hunta' then command[1] = 'bountyall' end
  	if command[1] == 'apa' then command[1] = 'apartment' end
  	if command[1] == 'nogay' then command[1] = 'killaliens' end
  	if command[1] == 'lz' then command[1] = 'kickbarcodes' end
  	if not settings["Commands"]['cmd_'..command[1]] then return true end
  	if HandleCommand(command, id) then 
  		system.log('Imagined Menu', string.format("Player %s requested command %s", online.get_name(id), command[1]))
  		system.notify(TRANSLATION['Chat command'], string.format(TRANSLATION["Player %s requested command %s"], online.get_name(id), command[1]), 100, 0, 255, 255)
  	end
  elseif (settings.Session["ChatMocker"] and not (settings.General["Exclude Friends"] and features.is_friend(id)) and not features.is_excluded(id)) or playerlist[id].ChatMock then
  	local message = string.empty
  	for i = 1, string.len(text)
  	do
  		local character = text:sub(i, i)
  		character = i%2 ~= NULL and character:lower() or character:upper()
  		message = message..character
  	end
  	local id = settings.Session["MockerSpoof"] and id or -1
  	online.send_chat(message, false, id)
  end
end

local TRANSLATION_FILES = file.scandir(paths['Translations'])

for i, v in ipairs(TRANSLATION_FILES)
do
	if not v:find('%.json') then
		table.remove(TRANSLATION_FILES, i)
	else
		os.rename(paths['Translations']..[[\]]..v, paths['Translations']..[[\]]..v:lower())
	end
end

local function GetLanguage()
	local languages = {
		[0] = 'english.json',
		[1] = 'french.json',
		[2] = 'german.json',
		[3] = 'italian.json',
		[4] = 'spanish.json',
		[5] = 'brazilian.json',
		[6] = 'polish.json',
		[7] = 'russian.json',
		[8] = 'korean.json',
		[9] = 'chinese.json',
		[10] = 'japanese.json',
		[11] = 'mexican.json',
		[12] = 'simplified_chinese.json'
	}
	local curr_lang = LOCALIZATION.GET_CURRENT_LANGUAGE()
	if curr_lang and (curr_lang >= 0 and curr_lang <= 12) then
		return languages[curr_lang]
	end
	return languages[0]
end

local function SaveConfig()
	if settings.Dev.Enable then system.log('debug', 'saving config...') end
	file.write(json:encode_pretty(settings), files['Config'])
end

--settings
local function LoadConfig()
	if settings.Dev.Enable then system.log('debug', 'loading config...') end
	if not file.exists(files['Config']) then return end
	local new = json:decode(file.readAll(files['Config']))
  if new and new  ~= string.empty then
	  for k, v in pairs(new) do
	  	for i, e in pairs(v) do
	  		if settings[k][i] ~= nil then
	  			settings[k][i] = e
	  		end
	  	end
	  end
	  if settings.General.Translation == string.empty then
	  	settings.General.Translation = GetLanguage()
	  end
	  system.log('Imagined Menu', 'Default config loaded')
  end
  SaveConfig()
end
LoadConfig()
if settings.Dev.Enable then system.log('debug', 'config loaded') end

if not file.exists(files['Config']) then SaveConfig() end

local function LoadConfTog(conf)
	for _, v in pairs(conf) do
		for i, x in pairs(v) do
			if type(x) == 'boolean' and __options.bool[i] then
				ui.set_value(__options.bool[i], x, false)
				ui.set_value(__options.bool[i], x, true)
			elseif type(x) == 'string' and x ~= string.empty and i == 'Translation' then
				for e, v in pairs(TRANSLATION_FILES) do
					if v == x then
						ui.set_value(__options.choose[i], e-1, true)
						break
					end
				end
			elseif type(x) == 'number' then
				if __options.num[i] then
					ui.set_value(__options.num[i], x, false)
					ui.set_value(__options.num[i], x, true)
				end
				if __options.choose[i] then
					ui.set_value(__options.choose[i], x, false)
					ui.set_value(__options.choose[i], x, true)
				end
			end
		end
	end
end

local function SaveTranslation()
	file.write(json:encode_pretty(TRANSLATION), paths['Translations']..[[\]]..settings.General.Translation)
end

local function LoadTranslations()
	local deftrans = settings.General['Translation']
	if not deftrans then deftrans = string.empty end

	if (#file.scandir(paths['Translations']) == NULL) or (not file.exists(paths['Translations']..[[\]]..deftrans) or deftrans == string.empty) then
		settings.General.Translation = GetLanguage()
		system.notify(TRANSLATION['Info'], string.format('No translation found for your language! You can translate the %s file if you want :)', settings.General.Translation), 255, 128, 0, 255)
		system.log('Imagined Menu', string.format('Translation %s not found!',deftrans))
		SaveTranslation()
		return
	end

	local new = json:decode(file.readAll(paths['Translations']..[[\]]..deftrans))
    if new == string.empty or not new then return end
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

    if TRANSLATION[1].Credits ~= string.empty then
    	system.log('Imagined Menu', TRANSLATION[1].Language..' translation loaded, made by '..TRANSLATION[1].Credits)
    end
end
if settings.Dev.Enable then system.log('debug', 'loading translations...') end
LoadTranslations()

local new_version
local ver_checked
function check_for_updates()
	system.log('Imagined Menu', 'Checking for updates...')
	local URL = [[https://raw.githubusercontent.com/ProDash1998/ImaginatedMenuLua/main/version]]
	http.get(URL, function(content, header, response_code)
		ver_checked = true
		if not content or content == string.empty then return end
		local success, char = content:find('\n')
		if not success then return end
		local content = content:sub(1, char-1)
		if content == VERSION then return end
		new_version = content
	end)
end
check_for_updates()
if settings.Dev.Enable then system.log('debug', 'update check') end

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
		remove = ui.add_click_option(TRANSLATION["Remove"], sub, function() vehicle_blacklist.remove(hash); vehicle_blacklist.remove_option_vehicle(hash);vehicle_blacklist.save() end),
		separator = ui.add_separator(TRANSLATION["Reactions"], sub),
		opt_v_kick = ui.add_bool_option(TRANSLATION["Kick from vehicle"], sub, function(bool) vehicle_blacklist.vehicles[hash].vehicle_kick = bool;vehicle_blacklist.save() end),
		opt_v_max_speed = ui.add_bool_option(TRANSLATION["Limit max speed"], sub, function(bool) vehicle_blacklist.vehicles[hash].set_max_speed = bool;vehicle_blacklist.save() end),
		opt_v_expl = ui.add_bool_option(TRANSLATION["Explode vehicle"], sub, function(bool) vehicle_blacklist.vehicles[hash].vehicle_explode = bool;vehicle_blacklist.save() end),
		opt_v_del = ui.add_bool_option(TRANSLATION["Delete vehicle"], sub, function(bool) vehicle_blacklist.vehicles[hash].vehicle_delete = bool;vehicle_blacklist.save() end),
		opt_v_laun = ui.add_bool_option(TRANSLATION["Launch vehicle"], sub, function(bool)vehicle_blacklist.vehicles[hash].vehicle_launch = bool;vehicle_blacklist.save() end),
		opt_tp_killzone = ui.add_bool_option(TRANSLATION["Teleport to kill zone"], sub, function(bool)vehicle_blacklist.vehicles[hash].tp_killzone = bool;vehicle_blacklist.save() end),
		opt_kick = ui.add_bool_option(TRANSLATION["Kick player"], sub, function(bool) vehicle_blacklist.vehicles[hash].kick = bool;vehicle_blacklist.save() end),
		opt_crash = ui.add_bool_option(TRANSLATION["Crash player"], sub, function(bool)vehicle_blacklist.vehicles[hash].crash = bool;vehicle_blacklist.save() end),
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
	file.write(json:encode_pretty(vehicle_blacklist.vehicles), files['VehicleBlacklist'])
end 

function vehicle_blacklist.load()
	if not file.exists(files['VehicleBlacklist']) then return end
	system.log('Imagined Menu', 'Loading vehicle blacklist...')
	vehicle_blacklist.vehicles = json:decode(file.readAll(files['VehicleBlacklist']))
	for k, v in pairs(vehicle_blacklist.vehicles)
	do
		if not tonumber(k) then error('Failed to load vehicle form blacklist invalid hash', 1) end
		if not v.model then error('Failed to load vehicle form blacklist invalid model', 1) end
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
		if vehicle_blacklist.vehicles[hash] then system.notify(TRANSLATION['Info'], TRANSLATION['Vehicle already blacklisted'], 255, 0, 0, 255) return POP_THREAD end
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
		system.notify(TRANSLATION['Info'], TRANSLATION['Vehicle added to blacklist'], 0, 128, 255, 255)
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
	system.notify(TRANSLATION['Info'], TRANSLATION['Vehicle removed from blacklist'], 0, 128, 255, 255)
end

local function SaveExcludes()
	if settings.Dev.Enable then system.log('debug', 'saving player excludes...') end
	file.write(json:encode_pretty(features.player_excludes), files['PlayerExcludes'])
end

local function LoadExcludes()
	if not file.exists(files['PlayerExcludes']) then return end
	system.log('Imagined Menu', 'Loading vehicle blacklist...')
	features.player_excludes = json:decode(file.readAll(files['PlayerExcludes']))
end
LoadExcludes()
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
	}
end

if settings.Dev.Enable then system.log('debug', 'player submenu') end
__submenus["Imagined"] = ui.add_player_submenu(TRANSLATION["Imagined Menu"])

local main_submenu = ui.add_main_submenu(TRANSLATION["Imagined Menu"])

ui.add_separator(TRANSLATION["Trolling"], __submenus["Imagined"])

-- still don't know how to bypass network errors after using this xD
-- do
-- 	local blame_delay = 0
-- 	__submenus["Blame"] = ui.add_submenu(TRANSLATION["Blame"])
-- 	__suboptions["Blame"] = ui.add_sub_option(TRANSLATION["Blame"], __submenus["Imagined"], __submenus["Blame"])

-- 	ui.add_click_option(TRANSLATION["All"], __submenus["Blame"], function()
-- 		if blame_delay > os.clock() then return end
-- 		local target = online.get_selected_player()
-- 		local ped = PLAYER.GET_PLAYER_PED(target)
-- 		for i = 0, 31 do
-- 			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and i ~= PLAYER.PLAYER_ID() and not (settings.General["Exclude Friends"] and features.is_friend(i)) and not features.is_excluded(i) then
-- 				local pos = features.get_player_coords(i)
-- 				FIRE.ADD_OWNED_EXPLOSION(ped, pos.x, pos.y, pos.z, enum.explosion.GRENADE, 1, true, false, 1.0)
-- 			end
-- 		end
-- 		blame_delay = os.clock() + .2
-- 	end)
-- 	ui.add_separator(TRANSLATION["Player"], __submenus["Blame"])

-- 	local blame_players = {}
-- 	CreateRemoveThread(true, 'blame_players', function()
-- 		for i = 0, 31
-- 		do
-- 			if not blame_players[i] and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 then
-- 				local tag = string.empty
-- 				if i == PLAYER.PLAYER_ID() then
-- 					tag = '(Self)'
-- 				elseif features.is_friend(i) then
-- 					tag = '(Friend)'
-- 				end
-- 				local name = PLAYER.GET_PLAYER_NAME(i)..' '..tag
-- 				blame_players[i] = ui.add_click_option(name, __submenus["Blame"], function()
-- 					if blame_delay > os.clock() then return end
-- 					local ped = PLAYER.GET_PLAYER_PED(online.get_selected_player())
-- 					local pos = features.get_player_coords(i)
-- 					FIRE.ADD_OWNED_EXPLOSION(ped, pos.x, pos.y, pos.z, enum.explosion.GRENADE, 1, true, false, 1.0)
-- 					blame_delay = os.clock() + .2
-- 				end)
-- 			elseif blame_players[i] and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == NULL then
-- 				ui.remove(blame_players[i])
-- 				blame_players[i] = nil
-- 			end
-- 		end
-- 	end)
-- end

ui.add_click_option(TRANSLATION["Send IP in chat"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	if pid == PLAYER.PLAYER_ID() then return end
	online.send_chat(string.format("My IP adress is: %s", online.get_ip(pid)), false, pid)
end)

ui.add_click_option(TRANSLATION["Crush player"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	CreateRemoveThread(true, 'crush_player_'..thread_count, function()
		local loaded, hash = features.request_model(utils.joaat("rhino"))
		if loaded == NULL then return end
		local pos = features.get_offset_from_player_coords(vector3.up() * 15, pid)
		local veh = vehicles.spawn_vehicle(hash, pos, features.get_player_heading(pid))
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
		entities.request_control(veh, function()
			ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0, 0, -20, 0, 0, 0, 0, true, false, true, false, true)
		end)
		local time = os.clock() + 3
		CreateRemoveThread(true, 'delete_entity_'..thread_count, function()
			if time > os.clock() then return end
			features.delete_entity(veh)
			return POP_THREAD
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Trap in invisible tube"], __submenus["Imagined"], function()
	local target = online.get_selected_player()
	local pos = features.get_player_coords(target)
	BlockArea(1125864094, pos.x, pos.y, pos.z, 0, 90, 0, true)
end)

ui.add_click_option(TRANSLATION["Infinite invite v1"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	online.send_script_event(pid, 603406648, PLAYER.PLAYER_ID(), pid, 4294967295, 1, 115, 0, 0, 0)
end)

ui.add_click_option(TRANSLATION["Infinite invite v2"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	online.send_script_event(pid, 603406648, PLAYER.PLAYER_ID(), pid, 4294967295, 1, 115, 1, 1, 1)
end)

do
	local explosion_types = {}
	for i = 0, 82
	do
		for k, v in pairs(enum.explosion)
		do
			if v == i then
				table.insert(explosion_types, k)
				break
			end
		end
	end
	local blamed
	__options.bool["ExplodeBlamed"] = ui.add_bool_option(TRANSLATION["Kill as self"], __submenus["Imagined"], function(bool) blamed = bool end)
	__options.choose["Explode"] = ui.add_choose(TRANSLATION["Explode"], __submenus["Imagined"], false, explosion_types, function(int)
		local pos = features.get_player_coords(online.get_selected_player())
		if blamed then
			FIRE.ADD_OWNED_EXPLOSION(PLAYER.PLAYER_PED_ID(), pos.x, pos.y, pos.z, int, 1, true, false, 1)
		else
			FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, int, 1, true, false, 1, false)
		end
	end)
end

do
	local types = {HUD._GET_LABEL_TEXT("WT_SNIP_HVY2"), HUD._GET_LABEL_TEXT("WT_STUN"), HUD._GET_LABEL_TEXT("WT_RAYPISTOL")}
	__options.choose["ShootWithBullet"] = ui.add_choose(TRANSLATION["Shoot with bullet"], __submenus["Imagined"], false, types, function(int)
		local hash
		if int == 0 then
			hash = 205991906
		elseif int == 1 then
			hash = 911657153
		else
			hash = -1355376991
		end
		local pos = features.get_player_coords(online.get_selected_player())
		local pos2 = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(PLAYER.GET_PLAYER_PED(online.get_selected_player()), 0xe0fd)
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 5, true, hash, PLAYER.PLAYER_PED_ID(), true, true, 24000)
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 5, true, hash, PLAYER.PLAYER_PED_ID(), true, true, 24000)
	end)
end

__options.players["Freeze"] = ui.add_bool_option(TRANSLATION["Freeze"], __submenus["Imagined"], function(bool)
	playerlist[online.get_selected_player()]["Freeze"] = bool
end)

do
	local spawned_jets = {}

	__options.players["SendJets"] = ui.add_bool_option(TRANSLATION["Send jets"], __submenus["Imagined"], function(bool)
		local player = online.get_selected_player()
		playerlist[player]["SendJets"] = bool
		if spawned_jets[player] and not bool then
			for _, v in ipairs(spawned_jets[player]) do
				features.request_control_of_entities(v)
				features.delete_entity(v[1])
				features.delete_entity(v[2])
			end
			spawned_jets[player] = nil
			features.unload_models(utils.joaat('lazer'),utils.joaat('ig_dom'))
		end
		CreateRemoveThread(bool, 'send_jets_'..player, function()
			if features.request_model(utils.joaat('ig_dom')) == NULL then return end
			if features.request_model(utils.joaat('lazer')) == NULL then return end

			local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(player), false)
			spawned_jets[player] = {}
			for i = -2, 3 do
				local offcoords = features.get_offset_coords_from_entity_rot(PLAYER.GET_PLAYER_PED(player), 300, i*60, true)
				local finalpos = {
					x = offcoords.x,
					y = offcoords.y,
					z = pos.z + 200
				}
				local jet = vehicles.spawn_vehicle(utils.joaat('lazer'), finalpos, 0)
				local ped = peds.create_ped(utils.joaat('ig_dom'), finalpos, true, false, nil, 17)
				table.insert(spawned_jets[player], {jet, ped})
				features.request_control_of_entities({jet, ped})
				vehicles.set_godmode(jet, true)
				PED.SET_PED_INTO_VEHICLE(ped, jet, -1)
				features.set_entity_face_entity(jet, PLAYER.GET_PLAYER_PED(player), true)
				VEHICLE.SET_VEHICLE_ENGINE_ON(jet, true, true, false)
				VEHICLE.CONTROL_LANDING_GEAR(jet, 3)
		      	VEHICLE.SET_HELI_BLADES_FULL_SPEED(jet)
		      	VEHICLE.SET_VEHICLE_DOORS_LOCKED(jet, 5)
				PED.SET_PED_FLEE_ATTRIBUTES(ped, 0, false)
				for _, v in ipairs({1,2,5,46,52}) do
					PED.SET_PED_COMBAT_ATTRIBUTES(ped, v, true)
				end
				PED.SET_PED_ACCURACY(ped, 100)
				PED.SET_PED_COMBAT_RANGE(ped, 3)
				PED.SET_PED_COMBAT_ABILITY(ped, 2)
				PED.SET_PED_COMBAT_MOVEMENT(ped, 2)
				TASK.TASK_COMBAT_PED(ped, PLAYER.GET_PLAYER_PED(player), 0, 16)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED(jet, 6)
				VEHICLE.SET_VEHICLE_DOORS_LOCKED(jet, 2)
			end
			return POP_THREAD
		end)
	end)

end

ui.add_separator(TRANSLATION["Vehicle"], __submenus["Imagined"])

__submenus["SpawnVehicle"] = ui.add_submenu(TRANSLATION["Spawn vehicle"])
__suboptions["SpawnVehicle"] = ui.add_sub_option(TRANSLATION["Spawn vehicle"], __submenus["Imagined"], __submenus["SpawnVehicle"])

do
	local vehs = {}
	local god
	local upgrade
	for _, v in ipairs(vehicles.models) do
		table.insert(vehs, v[3])
	end
	ui.add_bool_option(TRANSLATION['Spawn with godmode'],  __submenus["SpawnVehicle"], function(bool) god = bool end)
	ui.add_bool_option(TRANSLATION['Spawn upgraded'],  __submenus["SpawnVehicle"], function(bool) upgrade = bool end)

	local selected_vehicle = 1
	local class = 0
	local classes = {}
	local curr_class
	for i = 0, 22
	do
		table.insert(classes, enum.vehicle_class[i])
	end

	local function spawn()
		local model, player = vehicles.models[vehicles.get_veh_index(selected_vehicle, class)][2], online.get_selected_player()
		CreateRemoveThread(true, 'request_model_'..thread_count, function()
			local loaded, hash = features.request_model(model)
			if not hash then return POP_THREAD end
			if loaded == NULL then return end
			local target = features.get_offset_coords_from_entity_rot(PLAYER.GET_PLAYER_PED(player), 6, 0, true)
			local vehicle = vehicles.spawn_vehicle(hash, target, features.get_player_heading(player))
			if vehicle == NULL then return end
			entities.request_control(vehicle, function()
				DECORATOR.DECOR_SET_INT(vehicle, "MPBitset", 1024)
				vehicles.repair(vehicle)
				VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, "Nightfal")
				if god then vehicles.set_godmode(vehicle, true) end
				if upgrade then vehicles.upgrade(vehicle) end
			end)
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
			return POP_THREAD
		end)
	end

	local sel_class = ui.add_choose(TRANSLATION["Select class"], __submenus["SpawnVehicle"], true, classes, function(int) class = int
		if curr_class then 
			ui.remove(curr_class)
			curr_class = nil
		end
	end)
	ui.set_value(sel_class, class, true)
	CreateRemoveThread(true, 'selected_class_'..thread_count, function()
		if not curr_class then
			curr_class = ui.add_choose(TRANSLATION["Select vehicle"], __submenus["SpawnVehicle"], false, vehicles.class[class], function(int) selected_vehicle = int + 1;spawn() end)
		end
	end)
end

ui.add_click_option(TRANSLATION["Clone vehicle"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	custom_vehicles.create({custom_vehicles.get_properties(veh, true)}, false, veh)
end)

ui.add_click_option(TRANSLATION["Blow up vehicle"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'blow_up_vehicle_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(veh)
			vehicles.set_godmode(veh, false)
			NETWORK.NETWORK_EXPLODE_VEHICLE(veh, true, false, netId)
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Pop tires"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
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

ui.add_click_option(TRANSLATION["Rotate vehicle"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'rotate_vehicle_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			local rot = ENTITY.GET_ENTITY_ROTATION(veh, 5)
			ENTITY.SET_ENTITY_ROTATION(veh, rot.x, rot.y, rot.z - 180, 5, true)
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Flip vehicle"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'flip_vehicle_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			local rot = ENTITY.GET_ENTITY_ROTATION(veh, 5)
			ENTITY.SET_ENTITY_ROTATION(veh, rot.x, rot.y - 180, rot.z, 5, true)
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Boost forward"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'boost_forward_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 500)
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Boost backward"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'boost_backward_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, -500)
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Launch up vehicle"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'launch_up_vehicle_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			ENTITY.FREEZE_ENTITY_POSITION(veh, false)
			ENTITY.SET_ENTITY_VELOCITY(veh, 0, 0, 500)
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Launch down vehicle"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'launch_down_vehicle_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			ENTITY.FREEZE_ENTITY_POSITION(veh, false)
			ENTITY.SET_ENTITY_VELOCITY(veh, 0, 0, -500)
		end)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Hijack vehicle"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'hijack_vehicle_'..thread_count, function(tick)
		if tick == 100 then return POP_THREAD end
		entities.request_control(veh, function()
			local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, true)
			if ped and ped ~= PLAYER.PLAYER_PED_ID() then
				online.send_script_event(pid, -1026787486, PLAYER.PLAYER_ID(), pid)
       			online.send_script_event(pid, 578856274, PLAYER.PLAYER_ID(), 0, 0, 0, 0, 1, pid, math.random(0, 2147483647))
				TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
			end
			PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
		end)
		if VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, true) ~= PLAYER.PLAYER_PED_ID() then return end
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Disable ability to drive"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	online.send_script_event(pid, 603406648, PLAYER.PLAYER_ID(), 2, 4294967295, 1, 115, 0, 0, 0)
end)

__options.players["VehicleGod"] = ui.add_bool_option(TRANSLATION["Set vehicle godmode"], __submenus["Imagined"], function(bool)
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then ui.set_value(__options.players["VehicleGod"], (ui.get_value(__options.players["VehicleGod"])==1), true) return end
	CreateRemoveThread(true, 'vehicle_god_on_'..thread_count, function(tick)
		-- if tick == 100 then return POP_THREAD end
		-- if not features.request_control_once(veh) then return end
		entities.request_control(veh, function()
			vehicles.set_godmode(veh, bool)
		end)
		return POP_THREAD
	end)
end)

__options.players["VehicleHorn"] = ui.add_bool_option(TRANSLATION["Start vehicle horn"], __submenus["Imagined"], function(bool)
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	playerlist[pid]["VehicleHorn"] = bool
	if veh == NULL then return end
	CreateRemoveThread(bool, 'horn_vehicle_'..pid, function(tick)
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == NULL then return POP_THREAD end
		entities.request_control(veh, function()
			VEHICLE.START_VEHICLE_HORN(veh, 3000, 0, false)
		end)
	end)
end)

__options.players["HonkBoosting"] = ui.add_bool_option(TRANSLATION["Honk boosting"], __submenus["Imagined"], function(bool)
	local pid = online.get_selected_player()
	playerlist[pid]["HonkBoosting"] = bool
end)

__options.players["LockVehicle"] = ui.add_bool_option(TRANSLATION["Lock vehicle"], __submenus["Imagined"], function(bool)
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then ui.set_value(__options.players["LockVehicle"], (ui.get_value(__options.players["LockVehicle"])==1), true) return end
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

__options.players["ChildLocks"] = ui.add_bool_option(TRANSLATION["Child locks"], __submenus["Imagined"], function(bool)
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then ui.set_value(__options.players["ChildLocks"], (ui.get_value(__options.players["ChildLocks"])==1), true) return end
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
		table.insert(topspeed, 0)
	end
	ui.add_num_option(TRANSLATION["Change max speed"], __submenus["Imagined"], 0, 1000, 1, function(int) topspeed[online.get_selected_player()] = int end)
	ui.add_click_option(TRANSLATION["Set max speed"], __submenus["Imagined"], function()
		local pid = online.get_selected_player()
		local veh = vehicles.get_player_vehicle(pid)
		if veh == NULL then return end
		CreateRemoveThread(true, 'set_max_speed_'..thread_count, function(tick)
			-- if tick == 50 then return POP_THREAD end
			-- if not features.request_control_once(veh) then return end
			entities.request_control(veh, function()
				ENTITY.SET_ENTITY_MAX_SPEED(veh, topspeed[pid])
				VEHICLE.MODIFY_VEHICLE_TOP_SPEED(veh, topspeed[pid])
			end)
			return POP_THREAD
		end)
	end)

end

ui.add_separator(TRANSLATION["Other"], __submenus["Imagined"])

ui.add_click_option(TRANSLATION["Copy outfit"], __submenus["Imagined"], function()
	local outfit = peds.get_outfit(PLAYER.GET_PLAYER_PED(online.get_selected_player()))
	peds.apply_outfit(outfit.components, outfit.props)
end)

__options.players["ChatMock"] = ui.add_bool_option(TRANSLATION["Chat mOcK"], __submenus["Imagined"], function(bool)
	local pid = online.get_selected_player()
	playerlist[pid]["ChatMock"] = bool
end)

__options.players["Commands"] = ui.add_bool_option(TRANSLATION["Allow commands"], __submenus["Imagined"], function(bool)
	local pid = online.get_selected_player()
	playerlist[pid]["Commands"] = bool
end)

__options.players["Exclude"] = ui.add_bool_option(TRANSLATION["Exclude player"], __submenus["Imagined"], function(bool)
	if bool then
		features.player_excludes[tostring(online.get_rockstar_id(online.get_selected_player()))] = {
			name = online.get_name(online.get_selected_player())
		}
		SaveExcludes()
		system.notify(TRANSLATION["Info"], TRANSLATION["Player added to excludes"], 0, 255, 0, 225)
	else
		features.player_excludes[tostring(online.get_rockstar_id(online.get_selected_player()))] = nil
		SaveExcludes()
		system.notify(TRANSLATION["Info"], TRANSLATION["Player removed from excludes"], 0, 255, 0, 225) 
	end
end)

__options.players["Waypoint"] = ui.add_bool_option(TRANSLATION["Add waypoint"], __submenus["Imagined"], function(bool)
	local pid = online.get_selected_player()
	for i = 0, 31
	do
		playerlist[i]["Waypoint"] = false
	end
	playerlist[pid]["Waypoint"] = bool
	CreateRemoveThread(bool, 'waypoint_player', function()
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == NULL then return POP_THREAD end
		local pos = features.get_player_coords(pid)
		HUD.SET_NEW_WAYPOINT(pos.x, pos.y)
	end)
end)

ui.add_separator(TRANSLATION["Teleport"], __submenus["Imagined"])

-- ui.add_click_option(TRANSLATION["Teleport vehicle to waypoint"], __submenus["Imagined"], function()
-- 	if HUD.IS_WAYPOINT_ACTIVE() == NULL then system.notify(TRANSLATION['Info'], TRANSLATION["No waypoint has been set"], 255, 128, 0, 255) return end
-- 	local pid = online.get_selected_player()
-- 	local veh = vehicles.get_player_vehicle(pid)
-- 	if veh == NULL then return end
-- 	CreateRemoveThread(true, 'teleport_vehicle_'..thread_count, function(tick)
-- 		-- if tick == 100 then return POP_THREAD end
-- 		-- if not features.request_control_once(veh) then return end
-- 		entities.request_control(veh, function()
-- 			local pos = vector3(HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8)))
-- 			features.teleport(veh, pos.x, pos.y, 800)
-- 		end)
-- 		return POP_THREAD
-- 	end)
-- end)

ui.add_click_option(TRANSLATION["Near me"], __submenus["Imagined"], function() 
	local my_pos = features.get_player_coords()
	local apartment = features.get_closest_apatrment_to_coord(my_pos)
	local pid = online.get_selected_player()
	online.send_script_event(pid, 603406648, PLAYER.PLAYER_ID(), pid, 1, 0, apartment, 1, 1, 1)
end)

ui.add_click_option(TRANSLATION["Near waypoint"], __submenus["Imagined"], function() 
	if HUD.IS_WAYPOINT_ACTIVE() == NULL then system.notify(TRANSLATION['Info'], TRANSLATION["No waypoint has been set"], 255, 128, 0, 255) return end
	local my_pos = vector3(HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8)))
	local apartment = features.get_closest_apatrment_to_coord(my_pos)
	local pid = online.get_selected_player()
	online.send_script_event(pid, 603406648, PLAYER.PLAYER_ID(), pid, 1, 0, apartment, 1, 1, 1)
end)

ui.add_click_option(TRANSLATION["Send to cutscene"], __submenus["Imagined"], function() 
	local pid = online.get_selected_player()
	local time = os.clock() + 1.5
	local f_pos = features.get_player_coords()
	local veh = vehicles.get_player_vehicle()
	local teleported
	CreateRemoveThread(true, 'send_to_cutscene', function()
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == NULL then
			if not teleported then return POP_THREAD end
			if veh ~= NULL then
				PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
			end
			features.teleport(PLAYER.PLAYER_PED_ID(), f_pos.x, f_pos.y, f_pos.z)
			return POP_THREAD 
		end
		local my_pos = features.get_player_coords()
		local pl_pos = features.get_player_coords(pid)
		if my_pos:sqrlen(pl_pos) > 2500 then
			features.teleport(PLAYER.PLAYER_PED_ID(), pl_pos.x, pl_pos.y + 50, pl_pos.z == -50 and 1000 or pl_pos.z)
			teleported = true
		end
		online.send_script_event(pid, 1068259786, PLAYER.PLAYER_ID())
		if pl_pos.z == -50 then time = os.clock() + 1.5 return end 
		if time > os.clock() then return end 
		if not teleported then return POP_THREAD end
		if veh ~= NULL then
			PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
		end
		features.teleport(PLAYER.PLAYER_PED_ID(), f_pos.x, f_pos.y, f_pos.z)
		return POP_THREAD
	end)
end)

do
	local types = {TRANSLATION["Severe Weather Patterns"], TRANSLATION["Half-truck Bully"], TRANSLATION["Exit Strategy"], TRANSLATION["Offshore Assets"], TRANSLATION["Cover Blown"], TRANSLATION["Mole Hunt"], TRANSLATION["Data Breach"], TRANSLATION["Work Dispute"]}
	__options.choose["SendMission"] = ui.add_choose(TRANSLATION["Send to job"], __submenus["Imagined"], true, types, function(int)
		local pid = online.get_selected_player()
		online.send_script_event(pid, 2020588206, PLAYER.PLAYER_ID(), int)
	end)
end

CreateRemoveThread(true, 'playerlist', function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if features.is_excluded(pid) and not ui.get_value(__options.players["Exclude"]) then
		ui.set_value(__options.players["Exclude"], true, true)
	elseif not features.is_excluded(pid) and ui.get_value(__options.players["Exclude"]) then
		ui.set_value(__options.players["Exclude"], false, true)
	end
	if veh ~= NULL then
		local doorlock = VEHICLE.GET_VEHICLE_DOOR_LOCK_STATUS(veh)
		if doorlock == 2 then
			if not ui.get_value(__options.players["LockVehicle"]) then
				ui.set_value(__options.players["LockVehicle"], true, true)
			end
		elseif ui.get_value(__options.players["LockVehicle"]) then
			ui.set_value(__options.players["LockVehicle"], false, true)
		end
		if doorlock == 4 then
			if not ui.get_value(__options.players["ChildLocks"]) then
				ui.set_value(__options.players["ChildLocks"], true, true)
			end
		elseif ui.get_value(__options.players["ChildLocks"]) then
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
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == NULL then
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
			online.send_script_event(i, -446275082, PLAYER.PLAYER_ID(), 0, 1, 0, globals.get_int(1893551 + (1 + (i * 599) + 510)))
			TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED(i))
		end
		if playerlist[i]["HonkBoosting"] then
			local veh = vehicles.get_player_vehicle(pid)
			if veh ~= NULL and AUDIO.IS_HORN_ACTIVE(veh) ~= NULL then 
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
__suboptions["Self"] = ui.add_sub_option(TRANSLATION["Self"], main_submenu, __submenus["Self"])

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
		table.insert(chains, NULL)
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
				[1] = {2, 2},
				[2] = {22, 3},
				[3] = {33, 0},
				[4] = {4, 0},
				[5] = {0, 0},
				[6] = {12, 6},
				[7] = {0, 0},
				[8] = {2, 2},
				[9] = {0, 0},
				[10] = {0, 0},
				[11] = {64, 0},
			},
		},
		female = {
			components = {
				[0] = {24, 0},
				[1] = {2, 2},
				[2] = {22, 3},
				[3] = {36, 0},
				[4] = {27, 0},
				[5] = {0, 0},
				[6] = {24, 0},
				[7] = {0, 0},
				[8] = {1, 0},
				[9] = {0, 0},
				[10] = {0, 0},
				[11] = {55, 0},
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
		local ped = PLAYER.PLAYER_PED_ID()
		if bool then
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
		end
		CreateRemoveThread(bool, 'ghost_rider_outfit', function()
			if STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("core") == NULL then
				STREAMING.REQUEST_NAMED_PTFX_ASSET("core")
				return
			end
			local ped = PLAYER.PLAYER_PED_ID()
			local model = ENTITY.GET_ENTITY_MODEL(ped)
			if model == utils.joaat("mp_f_freemode_01") then
				PED.CLEAR_ALL_PED_PROPS(PLAYER.PLAYER_PED_ID())
				peds.apply_outfit(ghostRider.female.components, {})
			elseif model == utils.joaat("mp_m_freemode_01") then
				PED.CLEAR_ALL_PED_PROPS(PLAYER.PLAYER_PED_ID())
				peds.apply_outfit(ghostRider.male.components, {})
			else
				system.notify("Imagined Menu", TRANSLATION["Ghost rider outfit works only on mp male and female"], 255, 0, 0, 255)
				return POP_THREAD
			end
			local ok, hash = features.request_model(utils.joaat("prop_cs_leg_chain_01"))
			if ok == NULL then return end
			local pos = features.get_player_coords()
			for i, v in ipairs(chains)
			do
				if v == NULL or ENTITY.DOES_ENTITY_EXIST(v) == NULL then
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
				flame._self = GRAPHICS.START_PARTICLE_FX_LOOPED_ON_ENTITY("ent_amb_beach_campfire", chains[1], 0.190000423, -0.0799999833, -0.200000033, 0, 0, 0, 0.7, false, false, false)
        GRAPHICS.SET_PARTICLE_FX_LOOPED_SCALE(flame._self, 0.7)
			end
		end)
	end)

	ui.add_click_option(TRANSLATION["Request bike"], __submenus["GhostRider"], function()
		if spawn then 
			if sanctus == NULL then return end
			DeleteGhostRider()
		end
		spawn = true
		sanctus = NULL
		CreateRemoveThread(true, 'ghostrider_veh_'..thread_count, function()
			local ok, hash = features.request_model(utils.joaat("sanctus"))
			if ok == NULL then return end
			if STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("core") == NULL then 
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
      VEHICLE.SET_VEHICLE_COLOURS(sanctus, enum.vehicle_colors["Worn Taxi Yellow"], enum.vehicle_colors["Worn Taxi Yellow"])
      VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(sanctus, 0, 0, 0)
      VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(sanctus, 0, 0, 0)
      VEHICLE.SET_VEHICLE_EXTRA_COLOURS(sanctus, 0, 0)
      VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(sanctus, "RIDER")
      ENTITY.SET_ENTITY_RENDER_SCORCHED(sanctus, true)
			features.unload_models(utils.joaat("prop_crisp_small"), utils.joaat("sanctus"))
			for i = 1, 2
			do
				GRAPHICS.USE_PARTICLE_FX_ASSET("core")
				local ptfx = GRAPHICS.START_PARTICLE_FX_LOOPED_ON_ENTITY("ent_amb_beach_campfire", flame.vehicle[i], 0, 0, 0, 0, 0, 0, 1, false, false, false)
				GRAPHICS.SET_PARTICLE_FX_LOOPED_SCALE(ptfx, 1)
	    end
			return POP_THREAD
		end)
	end)

	ui.add_click_option(TRANSLATION["Return bike"], __submenus["GhostRider"], function()
		if not spawn then return end
		DeleteGhostRider()
	end)

end

do
	local anims = {}

	for i = 1, #peds.anims
	do
		table.insert(anims, TRANSLATION[peds.anims[i][1]])
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
	ui.add_click_option(TRANSLATION["Stop animation"], __submenus["PlayAnim"], function() TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.PLAYER_PED_ID()) end)
	__options.bool["OnNearbyPeds"] = ui.add_bool_option(TRANSLATION["Play only on nearby peds"], __submenus["PlayAnim"], function(bool) on_peds = bool end)
	ui.add_separator(TRANSLATION["Animations"], __submenus["PlayAnim"])

	__options.num["BlendInSpeed"] = ui.add_num_option(TRANSLATION["Blend-In Speed"], __submenus["PlayAnim"], -999999999, 999999999, 1, function(int) blend_in_speed = int end)
	ui.set_value(__options.num["BlendInSpeed"], blend_in_speed, true)
	__options.num["BlendOutSpeed"] = ui.add_num_option(TRANSLATION["Blend-Out Speed"], __submenus["PlayAnim"], -999999999, 999999999, 1, function(int) blend_out_speed = int end)
	ui.set_value(__options.num["BlendOutSpeed"], blend_out_speed, true)
	__options.num["Duration"] = ui.add_num_option(TRANSLATION["Duration (ms)"], __submenus["PlayAnim"], -1, 999999999, 100, function(int) duration = int end)
	ui.set_value(__options.num["Duration"], duration, true)
	__options.num["PlaybackRate"] = ui.add_num_option(TRANSLATION["Playback rate"], __submenus["PlayAnim"], 0, 100, 1, function(int) playback_rate = int end)
	ui.set_value(__options.num["PlaybackRate"], playback_rate, true)
	__options.bool["Loop"] = ui.add_bool_option(TRANSLATION["Loop"], __submenus["PlayAnim"], function(bool) if bool then flags[1] = enum.anim_flag.Loop else flags[1] = 0 end end)
	__options.bool["StopOnLastFrame"] = ui.add_bool_option(TRANSLATION["Stop on last frame"], __submenus["PlayAnim"], function(bool) if bool then flags[2] = enum.anim_flag.StopOnLastFrame else flags[2] = 0 end end)
	__options.bool["OnlyAnimateUpperBody"] = ui.add_bool_option(TRANSLATION["Only animate upper body"], __submenus["PlayAnim"], function(bool) if bool then flags[3] = enum.anim_flag.OnlyAnimateUpperBody else flags[3] = 0 end end)
	__options.bool["AllowPlayerControl"] = ui.add_bool_option(TRANSLATION["Allow player control"], __submenus["PlayAnim"], function(bool) if bool then flags[4] = enum.anim_flag.AllowPlayerControl else flags[4] = 0 end end)
	__options.bool["Cancellable"] = ui.add_bool_option(TRANSLATION["Cancellable"], __submenus["PlayAnim"], function(bool) if bool then flags[5] = enum.anim_flag.Cancellable else flags[5] = 0 end end)
	__options.bool["LockPos"] = ui.add_bool_option(TRANSLATION["Lock position"], __submenus["PlayAnim"], function(bool) lock = bool end)

	__options.choose["PlayAnim"] = ui.add_choose(TRANSLATION["Play"], __submenus["PlayAnim"], false, anims, function(int) 
		local anim_dict = peds.anims[int + 1][2]
		local anim_name = peds.anims[int + 1][3]
		local flag = 0
		for _, v in ipairs(flags)
		do
			flag = --[[features.OR(flag, v)]] flag + v
		end
		CreateRemoveThread(true, 'animation_'..thread_count, function()
			if STREAMING.HAS_ANIM_DICT_LOADED(anim_dict) == NULL then
				STREAMING.REQUEST_ANIM_DICT(anim_dict)
				return
			end
			if on_peds then
				for _, v in ipairs(entities.get_peds())
				do
					if v ~= PLAYER.PLAYER_PED_ID() then
						entities.request_control(v, function()
							PED.SET_PED_CAN_RAGDOLL(v, false)
							PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT(v, false)
							peds.calm_ped(v)
							TASK.CLEAR_PED_TASKS_IMMEDIATELY(v)
							peds.play_anim(v, anim_dict, anim_name, blend_in_speed, blend_out_speed, duration, flag, playback_rate / 100, lock)
						end)
					end
				end
			else
				peds.play_anim(PLAYER.PLAYER_PED_ID(), anim_dict, anim_name, blend_in_speed, blend_out_speed, duration, flag, playback_rate / 100, lock)
			end
			return POP_THREAD
		end)
	end)

	ui.add_separator(TRANSLATION["Scenarios"], __submenus["PlayAnim"])
	local scenarios = {}
	for i = 1, #peds.scenario
	do
		table.insert(scenarios, TRANSLATION[peds.scenario[i][1]])
	end
	__options.choose["PlayScenario"] = ui.add_choose(TRANSLATION["Play"], __submenus["PlayAnim"], false, scenarios, function(int) 
		if on_peds then
			for _, v in ipairs(entities.get_peds())
			do
				if v ~= PLAYER.PLAYER_PED_ID() then
					entities.request_control(v, function()
						PED.SET_PED_CAN_RAGDOLL(v, false)
						PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT(v, false)
						peds.calm_ped(v)
						TASK.CLEAR_PED_TASKS_IMMEDIATELY(v)
						peds.play_scenario(v, peds.scenario[int + 1][2])
					end)
				end
			end
		else
			peds.play_scenario(PLAYER.PLAYER_PED_ID(), peds.scenario[int + 1][2])
		end
	end)

end

do
	__options.num["NoClipMultiplier"] = ui.add_num_option(TRANSLATION["No clip speed multiplier"], __submenus["Self"], 1, 20, 1, function(int) settings.Self["NoClipMultiplier"] = int end)

	local nocliptype = 0
	__options.choose["NoClip"] = ui.add_choose(TRANSLATION["No clip"], __submenus["Self"], false, {TRANSLATION["None"], TRANSLATION["Mouse"], TRANSLATION["Keyboard"]}, function(int)
		nocliptype = int
		if int == NULL then
      if vehicles.get_player_vehicle() ~= NULL then
        local Vehicle = vehicles.get_player_vehicle()
        entities.request_control(Vehicle, function()
        	ENTITY.FREEZE_ENTITY_POSITION(PLAYER.PLAYER_PED_ID(), false)
          ENTITY.FREEZE_ENTITY_POSITION(Vehicle, false)
          ENTITY.SET_ENTITY_COLLISION(Vehicle, true, true)
          ENTITY.SET_ENTITY_VELOCITY(Vehicle, 0, 0, -0.0001)
      	end)
      else
        local ped = PLAYER.PLAYER_PED_ID()
        ENTITY.FREEZE_ENTITY_POSITION(ped, false)
        ENTITY.SET_ENTITY_COLLISION(ped, true, true)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
      end
    else
    	if __options.bool["FreeCam"] then
    		ui.set_value(__options.bool["FreeCam"], false, false)
    	end
	    if vehicles.get_player_vehicle() == NULL then
	      TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.PLAYER_PED_ID())
	    end
	  end
	end)
  CreateRemoveThread(true, 'self_no_clip', 
  function()
  	if nocliptype == NULL then return end

    local entself = PLAYER.PLAYER_PED_ID()

    if vehicles.get_player_vehicle() ~= NULL then
    	entself = vehicles.get_player_vehicle()
    	features.request_control_once(entself)
    end
           
    if nocliptype == 2 then
    	if vehicles.get_player_vehicle() == NULL then
      	TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.PLAYER_PED_ID())
     	end
      local rot = ENTITY.GET_ENTITY_ROTATION(entself, 5)
      ENTITY.SET_ENTITY_ROTATION(entself, 0, 0, rot.z, 5, true)
    end
    ENTITY.FREEZE_ENTITY_POSITION(entself, true)
    ENTITY.SET_ENTITY_COLLISION(entself, false, true)
    if nocliptype == 1 then 
      local rot = CAM.GET_GAMEPLAY_CAM_ROT(2)
      ENTITY.SET_ENTITY_ROTATION(entself, rot.x, rot.y, rot.z, 2, true)
    end

    local multiplier = .5

    PAD.DISABLE_CONTROL_ACTION(0, enum.input.VEH_SUB_ASCEND, true)
    PAD.DISABLE_CONTROL_ACTION(0, enum.input.VEH_FLY_THROTTLE_UP, true)
    PAD.DISABLE_CONTROL_ACTION(0, enum.input.VEH_FLY_THROTTLE_DOWN, true)
    PAD.DISABLE_CONTROL_ACTION(0, enum.input.VEH_FLY_YAW_LEFT, true)
    PAD.DISABLE_CONTROL_ACTION(0, enum.input.VEH_FLY_YAW_RIGHT, true)
    PAD.DISABLE_CONTROL_ACTION(0, enum.input.VEH_PUSHBIKE_SPRINT, true)
    PAD.DISABLE_CONTROL_ACTION(0, enum.input.VEH_SUB_DESCEND, true)

    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_SUB_ASCEND) == 1 then
        multiplier = settings.Self["NoClipMultiplier"]
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
      	local rot = ENTITY.GET_ENTITY_ROTATION(entself, 5)
      	ENTITY.SET_ENTITY_ROTATION(entself, 0, 0, rot.z + 2, 5, true)
      end
    end

    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_RIGHT) == 1 then
    	if nocliptype == 1 then
        local posD = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entself, 1 * multiplier, 0, 0)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entself, posD.x, posD.y, posD.z, false, false, false)
      else
      	local rot = ENTITY.GET_ENTITY_ROTATION(entself, 5)
      	ENTITY.SET_ENTITY_ROTATION(entself, 0, 0, rot.z - 2, 5, true)
      end
    end

    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_PUSHBIKE_SPRINT) == 1 then
      local posUp = ENTITY.GET_ENTITY_COORDS(entself, false)
      ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entself, posUp.x, posUp.y, posUp.z + 1 * multiplier, false, false, false)
    end

    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_SUB_DESCEND) == 1 then
      local posDow = ENTITY.GET_ENTITY_COORDS(entself, false)
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

__options.bool["BeastMode"] = ui.add_bool_option(TRANSLATION["Beast mode"], __submenus["Self"], function(bool) 
	settings.Self["BeastMode"] = bool
	CreateRemoveThread(bool, 'self_beast', 
	function()
		MISC._SET_BEAST_MODE_ACTIVE(PLAYER.PLAYER_ID())
		MISC.SET_SUPER_JUMP_THIS_FRAME(PLAYER.PLAYER_ID())
	end)
end)

__options.bool["NoRagdoll"] = ui.add_bool_option(TRANSLATION["No ragdoll"], __submenus["Self"], function(bool) 
	settings.Self["NoRagdoll"] = bool
	local ped = PLAYER.PLAYER_PED_ID()
	if not bool then
		PED.SET_PED_CAN_RAGDOLL(ped, true)
		PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT(ped, true)
	end
	CreateRemoveThread(bool, 'self_no_ragdoll', 
	function()
		ped = PLAYER.PLAYER_PED_ID()
		PED.SET_PED_CAN_RAGDOLL(ped, false)
		PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT(ped, false)
	end)
end)

__options.bool["FlyMode"] = ui.add_bool_option(TRANSLATION["Fly-mode"], __submenus["Self"], function(bool) 
	settings.Self["FlyMode"] = bool
	local in_air
	local started
	local wait_time
	local force
	CreateRemoveThread(true, 'request_anim_'..thread_count, function()
		if STREAMING.HAS_ANIM_DICT_LOADED('missheistfbi3b_ig6_v2') == NULL then
			STREAMING.REQUEST_ANIM_DICT('missheistfbi3b_ig6_v2')
			return
		end
		return POP_THREAD
	end)
	CreateRemoveThread(bool, 'self_flymode', 
	function()
		if vehicles.get_player_vehicle() ~= NULL then return end
		if STREAMING.HAS_ANIM_DICT_LOADED('missexile1_cargoplanejumpout') == NULL then
			STREAMING.REQUEST_ANIM_DICT('missexile1_cargoplanejumpout')
			return
		end
		PAD.DISABLE_CONTROL_ACTION(0, enum.input.JUMP, true)
		local ped = PLAYER.PLAYER_PED_ID()
		if ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(ped) == 1 or ENTITY.IS_ENTITY_IN_AIR(ped) == NULL then
			if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.JUMP) == 1 and not wait_time then
				peds.play_anim(ped, 'missexile1_cargoplanejumpout', 'jump_launch_l_to_skydive', 4, -4, -1, 0, 0, false)
				wait_time = os.clock() + .7
				started = nil
				force = true
			end
			if in_air and ENTITY.IS_ENTITY_IN_AIR(ped) ~= NULL and started then
				local vel = vector3(ENTITY.GET_ENTITY_VELOCITY(ped))
				TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
				if vel:abs() > vector3.right() * 8 or vel:abs() > vector3.forward() * 8 then
					peds.play_anim(ped, 'missheistfbi3b_ig6_v2', 'rubble_slide_alt_franklin', 4, -4, 1000, 0, 0, false)
					local vel = vector3.zero():direction_to(vel) * 70
					ENTITY.SET_ENTITY_VELOCITY(ped, vel.x, vel.y, 0)
					in_air = nil
				end
			end
			if started then return end
		end
		if wait_time and wait_time < os.clock() and force then
			ENTITY.APPLY_FORCE_TO_ENTITY(ped, 1, 0, 0, 20, 0, 0, 0, 0, true, false, true, false, true)
			force = nil
			return
		elseif wait_time and wait_time + .2 > os.clock() then
			return
		elseif not started and wait_time then
			TASK.TASK_SKY_DIVE(ped, true)
			started = true
			wait_time = nil
		end
		if not started then return end
		if PED.IS_PED_IN_PARACHUTE_FREE_FALL(ped) == NULL then TASK.TASK_SKY_DIVE(ped, true) end
		in_air = true
		if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_UP) == 1 then
      ENTITY.APPLY_FORCE_TO_ENTITY(ped, 1, 0, 1, 0, 0, 0, 0, 0, true, false, true, false, true)
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_DOWN) == 1 then
      ENTITY.APPLY_FORCE_TO_ENTITY(ped, 1, 0, 10, 0, 0, 0, 0, 0, true, false, true, false, true)
    end
    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.JUMP) == 1 then
      ENTITY.APPLY_FORCE_TO_ENTITY(ped, 1, 0, 0, 10, 0, 0, 0, 0, true, false, true, false, true)
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_MOVE_UD) == 1 then
      ENTITY.APPLY_FORCE_TO_ENTITY(ped, 1, 0, 0, -10, 0, 0, 0, 0, true, false, true, false, true)
    end
    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_MOVE_UP_ONLY) == 1 then
      local vel = vector3(ENTITY.GET_ENTITY_VELOCITY(ped))
      local final = (vector3.zero():direction_to(vel) * 10)
      ENTITY.SET_ENTITY_VELOCITY(ped, final.x, final.y, final.z)
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
	__options.bool["WalkOnWater"] = ui.add_bool_option(TRANSLATION["Walk on water"], __submenus["Self"], function(bool) 
		settings.Self["WalkOnWater"] = bool
		local Z = 0
		if not bool then
	    features.delete_entity(onwater)
	    onwater = nil
	    features.unload_models(utils.joaat("stt_prop_stunt_target_small"))
		end
		CreateRemoveThread(bool, 'self_walk_on_water', 
		function()
			WATER.SET_DEEP_OCEAN_SCALER(0)
			local loaded, hash = features.request_model(utils.joaat("stt_prop_stunt_target_small"))
			if loaded == NULL then return end
			local ped = PLAYER.PLAYER_PED_ID()
	    local submerge = ENTITY.GET_ENTITY_SUBMERGED_LEVEL(ped)
	    local pos = features.get_player_coords()
	    if submerge ~= NULL then
	      if not onwater or ENTITY.DOES_ENTITY_EXIST(onwater) == NULL then
	        Z = pos.z - 6.2
	        onwater = features.create_object(hash, vector3(pos.x, pos.y, Z))
	        ENTITY.SET_ENTITY_VISIBLE(onwater, false, false)
	      end
	      if submerge > .15 then 
	        ENTITY.APPLY_FORCE_TO_ENTITY(ped, 1, 0, 0, 1, 0, 0, 0, 0, true, false, true, false, true)
	      else
	        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(onwater, pos.x, pos.y, Z, false, false, false)
	      end
	    end
	    if submerge == NULL and onwater then
	      features.delete_entity(onwater)
	      onwater = nil
	    end
		end)
	end)
end

__options.bool["DemiGod"] = ui.add_bool_option(TRANSLATION["Demi-god"], __submenus["Self"], function(bool) 
	settings.Self["DemiGod"] = bool
	local maxhealth = 328
	if bool then
		maxhealth = PED.GET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID())
	end
	CreateRemoveThread(bool, 'self_demi_god', 
	function()
		local ped = PLAYER.PLAYER_PED_ID()
		PED.SET_PED_MAX_HEALTH(ped, 10000)
    ENTITY.SET_ENTITY_HEALTH(ped, 10000, 0)
    ENTITY.SET_ENTITY_PROOFS(ped, true, true, true, false, true, true, true, true)
    ENTITY.SET_ENTITY_MAX_HEALTH(ped, 10000)
	end)
	if not bool then
		local ped = PLAYER.PLAYER_PED_ID()
		PED.SET_PED_MAX_HEALTH(ped, maxhealth)
    ENTITY.SET_ENTITY_HEALTH(ped, maxhealth, 0)
    ENTITY.SET_ENTITY_PROOFS(ped, false, false, false, false, false, false, false, false)
	end
end)

__options.bool["DisableCollision"] = ui.add_bool_option(TRANSLATION["Disable collision"], __submenus["Self"], function(bool) 
	CreateRemoveThread(bool, 'self_no_collision', 
	function(tick)
		ENTITY.SET_ENTITY_COLLISION(PLAYER.PLAYER_PED_ID(), false, true)
	end)
	if not bool then ENTITY.SET_ENTITY_COLLISION(PLAYER.PLAYER_PED_ID(), true, true) end
end)

__options.bool["PedsIgnorePlayer"] = ui.add_bool_option(TRANSLATION["Peds ignore player"], __submenus["Self"], function(bool) 
	settings.Self['PedsIgnorePlayer'] = bool
	CreateRemoveThread(bool, 'self_peds_ignore',
	function(tick)
		if tick%10~=NULL then return end
		for _, ped in ipairs(entities.get_peds())
		do
			peds.calm_ped(ped)
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
	end

end)

__options.bool["PoliceMode"] = ui.add_bool_option(TRANSLATION["Police mode"], __submenus["Self"], function(bool) 
	settings.Self['PoliceMode'] = bool
	CreateRemoveThread(bool, 'self_police_mode',
	function()
		local veh = vehicles.get_player_vehicle()
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh and vector3(ENTITY.GET_ENTITY_COORDS(v, false)):sqrlen(vector3(features.get_player_coords())) <= 2500 then
				local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(v, -1, true)
				if ped ~= NULL then
					TASK.TASK_VEHICLE_TEMP_ACTION(ped, v, 26, 500)
				end
			end
		end
	end)
end)

__options.bool["ForceOutfit"] = ui.add_bool_option(TRANSLATION["Force outfit"], __submenus["Self"], function(bool) 
	settings.Self['ForceOutfit'] = bool
	local outfit = peds.get_outfit()
	CreateRemoveThread(bool, 'self_force_outfit',
	function()
		peds.apply_outfit(outfit.components, outfit.props)
	end)

end)

__options.num["Set Alpha"] = ui.add_num_option(TRANSLATION["Set alpha"], __submenus["Self"], 0, 255, 1, function(int) 
	ENTITY.SET_ENTITY_ALPHA(PLAYER.PLAYER_PED_ID(), int, false)
end)

__options.num["ForceField"] = ui.add_num_option(TRANSLATION["Force field"], __submenus["Self"], 0, 100, 1, function(int) settings.Self["ForceField"] = int end)

CreateRemoveThread(true, 'self_force_field', function()
	if settings.Self["ForceField"] == NULL then return end
	local me, veh1, veh2 = PLAYER.PLAYER_PED_ID(), vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
	local pos = vector3(features.get_player_coords())
	local distance = math.pow(settings.Self["ForceField"], 2)
	for _, v in ipairs(features.get_entities())
	do
		local pos2 = vector3(ENTITY.GET_ENTITY_COORDS(v, false))
		if (v ~= me and v ~= veh1 and v ~= veh2) and (pos:sqrlen(pos2) <= distance) then
			features.request_control_once(v)
			if ENTITY.IS_ENTITY_A_PED(v) == 1 then
				PED.SET_PED_TO_RAGDOLL(v, 5000, 5000, 0, true, true, false)
			end
			local force = pos2 - pos
			ENTITY.APPLY_FORCE_TO_ENTITY(v, 1, force.x, force.y, force.z, 0, 0, 0, 0, false, true, true, false, true)
		end
	end
end)

---------------------------------------------------------------------------------------------------------------------------------
-- Session
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'session submenu') end
__submenus["Session"] = ui.add_submenu(TRANSLATION["Session"])
__suboptions["Session"] = ui.add_sub_option(TRANSLATION["Session"], main_submenu, __submenus["Session"])
---------------------------------------------------------------------------------------------------------------------------------
-- Commands
---------------------------------------------------------------------------------------------------------------------------------

__submenus["Commands"] = ui.add_submenu(TRANSLATION["Commands"])
__suboptions["Commands"] = ui.add_sub_option(TRANSLATION["Commands"], __submenus["Session"], __submenus["Commands"])

do
	local prefixes = {'nf!','/', '\\','!','$','%','&','-','+','?','*',',','.','#','€','@'}
	__options.choose["CommandsPrefix"] = ui.add_choose(TRANSLATION["Prefix"], __submenus["Commands"], true, prefixes, function(int)
		settings.Commands["CommandsPrefix"] = int
	end)
end

__options.bool["cmd_spawn"] = ui.add_bool_option("spawn/sp <Vehicle>", __submenus["Commands"], function(bool)
	settings.Commands["cmd_spawn"] = bool
end)
__options.bool["cmd_freeze"] = ui.add_bool_option("freeze/nomove <Player/ID> <on/off>", __submenus["Commands"], function(bool)
  settings.Commands["cmd_freeze"] = bool
end)
__options.bool["cmd_island"] = ui.add_bool_option("island/vaca <Player/ID>", __submenus["Commands"], function(bool)
  settings.Commands["cmd_island"] = bool
end)
__options.bool["cmd_kick"] = ui.add_bool_option("kick/leave <Player/ID>", __submenus["Commands"], function(bool)
  settings.Commands["cmd_kick"] = bool
end)
__options.bool["cmd_crash"] = ui.add_bool_option("crash/bye <Player/ID>", __submenus["Commands"], function(bool)
  settings.Commands["cmd_crash"] = bool
end)
__options.bool["cmd_explode"] = ui.add_bool_option("explode/kill <Player/ID>", __submenus["Commands"], function(bool)
  settings.Commands["cmd_explode"] = bool
end)
__options.bool["cmd_kickall"] = ui.add_bool_option("kickall/plsleave", __submenus["Commands"], function(bool)
  settings.Commands["cmd_kickall"] = bool
end)
__options.bool["cmd_crashall"] = ui.add_bool_option("crashall/byea", __submenus["Commands"], function(bool)
  settings.Commands["cmd_crashall"] = bool
end)
__options.bool["cmd_explodeall"] = ui.add_bool_option("explodeall/killa", __submenus["Commands"], function(bool)
  settings.Commands["cmd_explodeall"] = bool
end)
__options.bool["cmd_clearwanted"] = ui.add_bool_option("clearwanted/nocop <on/off>", __submenus["Commands"], function(bool)
  settings.Commands["cmd_clearwanted"] = bool
  if not bool then
  	for i = 0, 31 do
  		CreateRemoveThread(false,"cmd_clearwanted_"..i)
  	end
  end
end)
__options.bool["cmd_offradar"] = ui.add_bool_option("offradar/ghost <on/off>", __submenus["Commands"], function(bool)
  settings.Commands["cmd_offradar"] = bool
  if not bool then
  	for i = 0, 31 do
  		CreateRemoveThread(false,"cmd_offradar_"..i)
  	end
  end
end)
__options.bool["cmd_vehiclegod"] = ui.add_bool_option("vehiclegod/god <on/off>", __submenus["Commands"], function(bool)
    settings.Commands["cmd_vehiclegod"] = bool
end)
__options.bool["cmd_upgrade"] = ui.add_bool_option("upgrade/upg", __submenus["Commands"], function(bool)
    settings.Commands["cmd_upgrade"] = bool
end)
__options.bool["cmd_repair"] = ui.add_bool_option("repair/rep/fix", __submenus["Commands"], function(bool)
    settings.Commands["cmd_repair"] = bool
end)
__options.bool["cmd_freezeall"] = ui.add_bool_option("freezeall/nomovea <on/off>", __submenus["Commands"], function(bool)
    settings.Commands["cmd_freezeall"] = bool
end)
__options.bool["cmd_bounty"] = ui.add_bool_option("bounty/hunt <Player/ID> <amount>", __submenus["Commands"], function(bool)
    settings.Commands["cmd_bounty"] = bool
end)
__options.bool["cmd_bountyall"] = ui.add_bool_option("bountyall/hunta <Player/ID> <amount>", __submenus["Commands"], function(bool)
    settings.Commands["cmd_bountyall"] = bool
end)
__options.bool["cmd_apartment"] = ui.add_bool_option("apartment/apa <Player/ID> <1-114>", __submenus["Commands"], function(bool)
    settings.Commands["cmd_apartment"] = bool
end)
__options.bool["cmd_killaliens"] = ui.add_bool_option("killaliens/nogay <on/off>", __submenus["Commands"], function(bool)
    settings.Commands["cmd_killaliens"] = bool
end)
__options.bool["cmd_kickbarcodes"] = ui.add_bool_option("kickbarcodes/lz <on/off>", __submenus["Commands"], function(bool)
    settings.Commands["cmd_kickbarcodes"] = bool
end)

ui.add_separator(TRANSLATION['Chat commands settings'], __submenus["Commands"])

__options.bool["Friends Only"] = ui.add_bool_option(TRANSLATION["Friends only"], __submenus["Commands"], function(bool)
	settings.Commands["Friends Only"] = bool
end)
__options.bool["Don't Affect Friends"] = ui.add_bool_option(TRANSLATION["Don't affect friends"], __submenus["Commands"], function(bool)
	settings.Commands["Don't Affect Friends"] = bool
end)

---------------------------------------------------------------------------------------------------------------------------------
-- Vehicle blacklist
---------------------------------------------------------------------------------------------------------------------------------

__submenus["VehicleBlacklist"] = ui.add_submenu(TRANSLATION["Vehicle blacklist"])
__suboptions["VehicleBlacklist"] = ui.add_sub_option(TRANSLATION["Vehicle blacklist"], __submenus["Session"], __submenus["VehicleBlacklist"])

__options.bool["VehicleBlacklist"] = ui.add_bool_option(TRANSLATION["Vehicle blacklist"], __submenus["VehicleBlacklist"], function(bool) 
	settings.Session["VehicleBlacklist"] = bool
	CreateRemoveThread(bool, 'session_vehicle_blacklist', function()
		for i = 0, 31 do
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and i ~= PLAYER.PLAYER_ID() and not (settings.General["Exclude Friends"] and features.is_friend(i)) and not features.is_excluded(i) and vehicles.get_player_vehicle(i) ~= NULL and vehicles.get_player_vehicle(i) ~= vehicles.get_player_vehicle() then
				local ped = PLAYER.GET_PLAYER_PED(i)
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
						online.send_script_event(i, -1026787486, PLAYER.PLAYER_ID(), i)
        		online.send_script_event(i, 578856274, PLAYER.PLAYER_ID(), 0, 0, 0, 0, 1, i, math.random(0, 2147483647))
						TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
					end
					if tabl.vehicle_explode then
						features.remove_god(i)
						local pos = vector3(ENTITY.GET_ENTITY_COORDS(ent, false))
						FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, enum.explosion.ROCKET, 10, true, false, 1.0, false)
						entities.request_control(veh, function()
							local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(veh)
							vehicles.set_godmode(veh, false)
							NETWORK.NETWORK_EXPLODE_VEHICLE(veh, true, false, netId)
						end)
					end
					if tabl.vehicle_launch then
						entities.request_control(veh, function()
							ENTITY.SET_ENTITY_VELOCITY(veh, 0, 0, 1000)
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
	for i = 0, 22
	do
		table.insert(classes, enum.vehicle_class[i])
	end
	ui.add_separator(TRANSLATION["Reactions"], __submenus["AddVehToBl"])

	__options.bool["VehBlVehicleKick"] = ui.add_bool_option(TRANSLATION["Kick from vehicle"], __submenus["AddVehToBl"], function(bool) settings.Session["VehBlVehicleKick"] = bool end)
	__options.bool["VehBlSetMaxSpeed"] = ui.add_bool_option(TRANSLATION["Limit max speed"], __submenus["AddVehToBl"], function(bool) settings.Session["VehBlSetMaxSpeed"] = bool end)
	__options.bool["VehBlVehicleExplode"] = ui.add_bool_option(TRANSLATION["Explode vehicle"], __submenus["AddVehToBl"], function(bool) settings.Session["VehBlVehicleExplode"] = bool end)
	__options.bool["VehBlVehicleDelete"] = ui.add_bool_option(TRANSLATION["Delete vehicle"], __submenus["AddVehToBl"], function(bool) settings.Session["VehBlVehicleDelete"] = bool end)
	__options.bool["VehBlVehicleLaunch"] = ui.add_bool_option(TRANSLATION["Launch vehicle"], __submenus["AddVehToBl"], function(bool) settings.Session["VehBlVehicleLaunch"] = bool end)
	__options.bool["VehBlKillZone"] = ui.add_bool_option(TRANSLATION["Teleport to kill zone"], __submenus["AddVehToBl"], function(bool) settings.Session["VehBlKillZone"] = bool end)
	__options.bool["VehBlKick"] = ui.add_bool_option(TRANSLATION["Kick player"], __submenus["AddVehToBl"], function(bool) settings.Session["VehBlKick"] = bool end)
	__options.bool["VehBlCrash"] = ui.add_bool_option(TRANSLATION["Crash player"], __submenus["AddVehToBl"], function(bool) settings.Session["VehBlCrash"] = bool end)

	ui.add_separator(TRANSLATION["Add"], __submenus["AddVehToBl"])

	-- ui.add_click_option(TRANSLATION["Add and save"], __submenus["AddVehToBl"], function() 
	local function add_and_save()
		local veh_index = vehicles.get_veh_index(selected_vehicle, class)
		vehicle_blacklist.add(veh_index) 
	end

	local sel_class = ui.add_choose(TRANSLATION["Select class"], __submenus["AddVehToBl"], true, classes, function(int) class = int
		if curr_class then 
			ui.remove(curr_class)
			curr_class = nil
		end
	end)
	ui.set_value(sel_class, class, true)
	CreateRemoveThread(true, 'selected_class_'..thread_count, function()
		if not curr_class then
			curr_class = ui.add_choose(TRANSLATION["Select vehicle"], __submenus["AddVehToBl"], false, vehicles.class[class], function(int) selected_vehicle = int + 1;add_and_save() end)
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
end)
__options.bool["EarRape"] = ui.add_bool_option(TRANSLATION['Ear rape'], __submenus["PlaySound"], function(bool)
	CreateRemoveThread(bool, 'session_ear_rape', 
	function()
		PlaySound("07", "DLC_GR_CS2_Sounds")
	end)
	if not bool then
		StopSounds()
	end
end)
ui.add_click_option(TRANSLATION['10s timer'], __submenus["PlaySound"], function()
	PlaySound("Timer_10s", "DLC_TG_Dinner_Sounds")
end)
ui.add_click_option(TRANSLATION['Phone ring'], __submenus["PlaySound"], function()
	PlaySound("Remote_Ring", "Phone_SoundSet_Michael")
end)
ui.add_click_option(TRANSLATION['Beast'], __submenus["PlaySound"], function()
	PlaySound("Beast_Cloak", "APT_BvS_Soundset")
	PlaySound("Beast_Die", "APT_BvS_Soundset")
	PlaySound("Beast_Uncloak", "APT_BvS_Soundset")
end)
ui.add_click_option(TRANSLATION['Beeps'], __submenus["PlaySound"], function()
	PlaySound("Crate_Beeps", "MP_CRATE_DROP_SOUNDS")
end)
ui.add_click_option(TRANSLATION['CCTV camera'], __submenus["PlaySound"], function()
	PlaySound("Microphone", "POLICE_CHOPPER_CAM_SOUNDS")
end)
ui.add_click_option(TRANSLATION['Door ring'], __submenus["PlaySound"], function()
	PlaySound("DOOR_BUZZ", "MP_PLAYER_APARTMENT")
end)
ui.add_click_option(TRANSLATION['Franklin whistle'], __submenus["PlaySound"], function()
	PlaySound("Franklin_Whistle_For_Chop", "SPEECH_RELATED_SOUNDS")
end)
ui.add_click_option(TRANSLATION['Heist hacking snake'], __submenus["PlaySound"], function()
	PlaySound("Trail_Custom", "DLC_HEIST_HACKING_SNAKE_SOUNDS")
	PlaySound("Background", "DLC_HEIST_HACKING_SNAKE_SOUNDS")
end)
ui.add_click_option(TRANSLATION['Heist hacking snake fail'], __submenus["PlaySound"], function()
	PlaySound("Crash", "DLC_HEIST_HACKING_SNAKE_SOUNDS")
end)
ui.add_click_option(TRANSLATION['Keycard'], __submenus["PlaySound"], function()
	PlaySound("Keycard_Fail", "DLC_HEISTS_BIOLAB_FINALE_SOUNDS")
	PlaySound("Keycard_Success", "DLC_HEISTS_BIOLAB_FINALE_SOUNDS")
end)
ui.add_click_option(TRANSLATION['Scanner'], __submenus["PlaySound"], function()
	PlaySound("SCAN", "EPSILONISM_04_SOUNDSET")
end)
ui.add_click_option(TRANSLATION['Wasted'], __submenus["PlaySound"], function()
	PlaySound("Bed", "WastedSounds")
end)
ui.add_click_option(TRANSLATION['Wind'], __submenus["PlaySound"], function()
	PlaySound("Helicopter_Wind", "BASEJUMPS_SOUNDS")
	PlaySound("Helicopter_Wind_Idle", "BASEJUMPS_SOUNDS")
end)

__submenus["ChatMocker"] = ui.add_submenu(TRANSLATION["Chat mOcKEr"])
__suboptions["ChatMocker"] = ui.add_sub_option(TRANSLATION["Chat mOcKEr"], __submenus["Session"], __submenus["ChatMocker"])

__options.bool["ChatMocker"] = ui.add_bool_option(TRANSLATION["Mock chat"], __submenus["ChatMocker"], function(bool)
	settings.Session["ChatMocker"] = bool
end)

__options.bool["MockerSpoof"] = ui.add_bool_option(TRANSLATION["Spoof as them"], __submenus["ChatMocker"], function(bool)
	settings.Session["MockerSpoof"] = bool
end)

---------------------------------------------------------------------------------------------------------------------------------
-- Teleport
---------------------------------------------------------------------------------------------------------------------------------
__submenus["SessionTeleport"] = ui.add_submenu(TRANSLATION["Teleport"])
__suboptions["SessionTeleport"] = ui.add_sub_option(TRANSLATION["Teleport"], __submenus["Session"], __submenus["SessionTeleport"])

ui.add_click_option(TRANSLATION["Near me"], __submenus["SessionTeleport"], function() 
	local my_pos = features.get_player_coords()
	local apartment = features.get_closest_apatrment_to_coord(my_pos)
	for i = 0, 31
	do
		if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
			online.send_script_event(i, 603406648, PLAYER.PLAYER_ID(), i, 1, 0, apartment, 1, 1, 1)
		end
	end
end)

ui.add_click_option(TRANSLATION["Near waypoint"], __submenus["SessionTeleport"], function() 
	if HUD.IS_WAYPOINT_ACTIVE() == NULL then system.notify(TRANSLATION['Info'], TRANSLATION["No waypoint has been set"], 255, 128, 0, 255) return end
	local my_pos = vector3(HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8)))
	local apartment = features.get_closest_apatrment_to_coord(my_pos)
	for i = 0, 31
	do
		if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
			online.send_script_event(i, 603406648, PLAYER.PLAYER_ID(), i, 1, 0, apartment, 1, 1, 1)
		end
	end
end)

do
	local active
	local pid
	local f_pos
	local veh
	local teleported
	local time
	ui.add_click_option(TRANSLATION["Send to cutscene"], __submenus["SessionTeleport"], function() 
		if not active then
			pid = 0
			f_pos = features.get_player_coords()
			veh = vehicles.get_player_vehicle()
			teleported = false
			time = os.clock() + 1.5
		end
		active = not active
		CreateRemoveThread(true, 'send_to_cutscene', function()
			if not active then 
				if teleported then
					if veh ~= NULL then
						PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
					end
					features.teleport(PLAYER.PLAYER_PED_ID(), f_pos.x, f_pos.y, f_pos.z)
				end
				active = false 
				return POP_THREAD 
			end
			if pid == 32 then active = false return POP_THREAD end
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == NULL or (pid == PLAYER.PLAYER_ID()) or (settings.Commands["Don't Affect Friends"] and features.is_friend(pid)) or features.is_excluded(pid) then
				if not teleported then time = os.clock() + 1.5; pid = pid + 1 return end
				if veh ~= NULL then
					PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
				end
				features.teleport(PLAYER.PLAYER_PED_ID(), f_pos.x, f_pos.y, f_pos.z)
				time = os.clock() + 1.5
				pid = pid + 1
				return
			end
			local my_pos = features.get_player_coords()
			local pl_pos = features.get_player_coords(pid)
			if my_pos:sqrlen(pl_pos) > 2500 then
				features.teleport(PLAYER.PLAYER_PED_ID(), pl_pos.x, pl_pos.y + 50, pl_pos.z == -50 and 1000 or pl_pos.z)
				teleported = true
			end
			online.send_script_event(pid, 1068259786, PLAYER.PLAYER_ID())
			if pl_pos.z == -50 then time = os.clock() + 1.5 return end 
			if time > os.clock() then return end
			if not teleported then time = os.clock() + 5; pid = pid + 1 return end
			if veh ~= NULL then
				PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
			end
			features.teleport(PLAYER.PLAYER_PED_ID(), f_pos.x, f_pos.y, f_pos.z)
			time = os.clock() + 1.5
			pid = pid + 1
			return
		end)
	end)
end

do
	local types = {TRANSLATION["Severe Weather Patterns"], TRANSLATION["Half-truck Bully"], TRANSLATION["Exit Strategy"], TRANSLATION["Offshore Assets"], TRANSLATION["Cover Blown"], TRANSLATION["Mole Hunt"], TRANSLATION["Data Breach"], TRANSLATION["Work Dispute"]}
	__options.choose["SendAllMission"] = ui.add_choose(TRANSLATION["Send to job"], __submenus["SessionTeleport"], true, types, function(int)
		for i = 0, 31
		do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				online.send_script_event(i, 2020588206, PLAYER.PLAYER_ID(), int)
			end
		end
	end)
end

do
	local types = {TRANSLATION['None'], TRANSLATION["Explode"], TRANSLATION["Freeze"], TRANSLATION["Kick"], TRANSLATION["Crash"]}
	__options.choose["PunishBeggers"] = ui.add_choose(TRANSLATION["Punish beggers"], __submenus["Session"], true, types, function(int) settings.Session["PunishBeggers"] = int end)
end

---------------------------------------------------------------------------------------------------------------------------------
-- Buttons
---------------------------------------------------------------------------------------------------------------------------------
ui.add_separator(TRANSLATION['Buttons'], __submenus["Session"])

__options.click["InfiniteInviteAllV1"] = ui.add_click_option(TRANSLATION['Infinite invite v1'], __submenus["Session"], function() 
	InfiniteInvite(0)
end)
__options.click["InfiniteInviteAllV2"] = ui.add_click_option(TRANSLATION['Infinite invite v2'], __submenus["Session"], function() 
	InfiniteInvite(1)
end)
__options.click["NoDrivingAll"] = ui.add_click_option(TRANSLATION['Disable ability to drive'], __submenus["Session"], function() 
	for i = 0, 31
	do
		if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
			online.send_script_event(i, 603406648, PLAYER.PLAYER_ID(), 2, 4294967295, 1, 115, 0, 0, 0)
		end
	end
end)
do
	local amount =  10000
	__options.num["BountyAmount"] = ui.add_num_option(TRANSLATION['Amount'], __submenus["Session"], 0, 10000, 1000, function(int) amount = int end)
	ui.set_value(__options.num["BountyAmount"], amount, true)
	__options.click["LobbyBounty"] = ui.add_click_option(TRANSLATION['Bounty all'], __submenus["Session"], function() 
		for i = 0, 31 do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				features.set_bounty(i, amount)
			end
		end
	end)
end

do
	local explosion_types = {}
	for i = 0, 82
	do
		for k, v in pairs(enum.explosion)
		do
			if v == i then
				table.insert(explosion_types, k)
				break
			end
		end
	end
	local blamed
	__options.bool["ExplodeAllBlamed"] = ui.add_bool_option(TRANSLATION["Kill as self"], __submenus["Session"], function(bool) blamed = bool end)
	__options.choose["ExplodeAll"] = ui.add_choose(TRANSLATION["Explode all"], __submenus["Session"], false, explosion_types, function(int)
		for i = 0, 31
		do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				local pos = features.get_player_coords(i)
				if blamed then
					FIRE.ADD_OWNED_EXPLOSION(PLAYER.PLAYER_PED_ID(), pos.x, pos.y, pos.z, int, 1, true, false, 1)
				else
					FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, int, 1, true, false, 1, false)
				end
			end
		end
	end)
end

---------------------------------------------------------------------------------------------------------------------------------
-- Toggles
---------------------------------------------------------------------------------------------------------------------------------
ui.add_separator(TRANSLATION['Toggles'], __submenus["Session"])

__options.bool["FreezeAll"] = ui.add_bool_option(TRANSLATION['Freeze all'], __submenus["Session"], function(bool)
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

__options.bool["CamForwardAll"] = ui.add_bool_option(TRANSLATION['Force cam forward'], __submenus["Session"], function(bool)
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

__options.bool["KillAliens"] = ui.add_bool_option(TRANSLATION['Kill aliens'], __submenus["Session"], function(bool)
	settings.Session["KillAliens"] = bool
	CreateRemoveThread(bool, 'kill_aliens', 
	function()
		for i = 0, 31
		do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) and ENTITY.IS_ENTITY_DEAD(PLAYER.GET_PLAYER_PED(i), false) == NULL then
				local ped = PLAYER.GET_PLAYER_PED(i)
				local outfit = peds.get_outfit(ped)
				local model = ENTITY.GET_ENTITY_MODEL(ped)
				local triggered
				if model == utils.joaat("mp_f_freemode_01") then
					if (outfit.components[1][1] == 134 and (outfit.components[1][2] == 8 or outfit.components[1][2] == 9)) and (outfit.components[4][1] == 113 and (outfit.components[4][2] == 8 or outfit.components[4][2] == 9)) and (outfit.components[6][1] == 87 and (outfit.components[6][2] == 8 or outfit.components[6][2] == 9)) and (outfit.components[11][1] == 287 and (outfit.components[11][2] == 8 or outfit.components[11][2] == 9)) then
						triggered = true
					end
				elseif model == utils.joaat("mp_m_freemode_01") then
					if (outfit.components[1][1] == 134 and (outfit.components[1][2] == 8 or outfit.components[1][2] == 9)) and (outfit.components[4][1] == 106 and (outfit.components[4][2] == 8 or outfit.components[4][2] == 9)) and (outfit.components[6][1] == 83 and (outfit.components[6][2] == 8 or outfit.components[6][2] == 9)) and (outfit.components[11][1] == 274 and (outfit.components[11][2] == 8 or outfit.components[11][2] == 9)) then
						triggered = true
					end
				end
				if triggered then
					local pos = features.get_player_coords(i)
					if pos.z == -50 then
						TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
					else
						features.remove_god(i)
						if vehicles.get_player_vehicle(i) ~= NULL then
							entities.request_control(vehicles.get_player_vehicle(i), function()
								local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(vehicles.get_player_vehicle(i))
								NETWORK.NETWORK_EXPLODE_VEHICLE(vehicles.get_player_vehicle(i), true, false, netId)
							end)
						end
						FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, enum.explosion.ROCKET, 10, true, false, 1.0, false)
					end
				end
			end
		end
	end)
end)

__options.bool["KickBarcodes"] = ui.add_bool_option(TRANSLATION['Kick barcodes'], __submenus["Session"], function(bool)
	settings.Session["KickBarcodes"] = bool
	CreateRemoveThread(bool, 'kick_barcodes', 
	function()
		for i = 0, 31
		do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				local name = online.get_name(i)
				local name = name:lower()
				local chars = #string.gsub(name, "[^il]", string.empty)
				local percent = chars / #name
				if percent > .5 then
			    features.kick_player(i)
				end
			end
		end
	end)
end)

__options.bool["DisableChat"] = ui.add_bool_option(TRANSLATION['Disable Chat'], __submenus["Session"], function(bool)
	settings.Session["DisableChat"] = bool
	local spam_mes = string.rep('\n', 200)
	CreateRemoveThread(bool, 'session_disable_chat', 
	function(tick)
		if tick%6~=NULL then return end
		online.send_chat(spam_mes, false) -- doesn't work for local
	end)
end)

__options.bool["SoundSpam"] = ui.add_bool_option(TRANSLATION['Sound spam'], __submenus["Session"], function(bool)
	CreateRemoveThread(bool, 'session_sound_spam',
	function()
	    for i = 0, 31
	    do
    		if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
        	online.send_script_event(i, 1132878564, PLAYER.PLAYER_ID(), math.random(1, 6))
        end
	    end
	end)
end)

__options.bool["OffRadarAll"] = ui.add_bool_option(TRANSLATION['Off radar'], __submenus["Session"], function(bool)	
	CreateRemoveThread(bool, 'session_off_radar',
	function(tick)
		if tick%5~=NULL then return end
		for i = 0, 31
		do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				online.send_script_event(i, -391633760, PLAYER.PLAYER_ID(), NETWORK.GET_NETWORK_TIME() - 60, NETWORK.GET_NETWORK_TIME(), 1, 1, globals.get_int((1893551 + (1 + (i * 599) + 510))))
			end
		end
	end)
end)

__options.bool["RemoveWantedAll"] = ui.add_bool_option(TRANSLATION['Remove wanted'], __submenus["Session"], function(bool)
	CreateRemoveThread(bool, 'session_remove_wanted',
	function()
		for i = 0, 31
		do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				online.send_script_event(i, -91354030, PLAYER.PLAYER_ID(), globals.get_int(1893551 + (1 + (i * 599) + 510)))
			end
		end
	end)
end)

__options.bool["BribeAuthoritiesAll"] = ui.add_bool_option(TRANSLATION['Bribe authorities'], __submenus["Session"], function(bool)
	CreateRemoveThread(bool, 'session_bribe_authorities',
	function(tick)
		if tick%5~=NULL then return end
		for i = 0, 31
		do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				online.send_script_event(i, 1722873242, PLAYER.PLAYER_ID(), 0, 0, NETWORK.GET_NETWORK_TIME(), 0, globals.get_int(1893551 + (1 + (i * 599) + 510)))
			end
		end
	end)
end)

__options.bool["BlockPassive"] = ui.add_bool_option(TRANSLATION['Block passive'], __submenus["Session"], function(bool)
	CreateRemoveThread(bool, 'session_block_passive',
	function(tick)
		if tick%5~=NULL then return end
		BlockPassive(1)
	end)
	if not bool then BlockPassive(0) end
end)

__options.bool["TransactionError"] = ui.add_bool_option(TRANSLATION['Transaction error'], __submenus["Session"], function(bool)
	CreateRemoveThread(bool, 'session_transaction_error',
	function(tick)
		if tick%2~=NULL then return end
		for i = 0, 31
		do
			if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) and not features.is_excluded(i) then
				online.send_script_event(i, -1704141512, PLAYER.PLAYER_ID(), 50000, 0, 1, globals.get_int(1893551 + (1 + (i * 599) + 510)), globals.get_int(1921039 + 9), globals.get_int(1921039 + 10), 1)
			end
		end
	end)
end)

---------------------------------------------------------------------------------------------------------------------------------
-- Vehicle
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'vehicle submenu') end
__submenus["Vehicle"] = ui.add_submenu(TRANSLATION["Vehicle"])
__suboptions["Vehicle"] = ui.add_sub_option(TRANSLATION["Vehicle"], main_submenu, __submenus["Vehicle"])

__submenus["SpawnVeh"] = ui.add_submenu(TRANSLATION["Spawn vehicle"])
__suboptions["SpawnVeh"] = ui.add_sub_option(TRANSLATION["Spawn vehicle"], __submenus["Vehicle"], __submenus["SpawnVeh"])

__submenus["ChangeSound"] = ui.add_submenu(TRANSLATION["Change sound"])
__suboptions["ChangeSound"] = ui.add_sub_option(TRANSLATION["Change sound"], __submenus["Vehicle"], __submenus["ChangeSound"])

__submenus["SpawnSettings"] = ui.add_submenu(TRANSLATION["Spawn settings"])
__suboptions["SpawnSettings"] = ui.add_sub_option(TRANSLATION["Spawn settings"], __submenus["SpawnVeh"], __submenus["SpawnSettings"])

__submenus["SavedVehicles"] = ui.add_submenu(TRANSLATION["Saved vehicles"])
__suboptions["SavedVehicles"] = ui.add_sub_option(TRANSLATION["Saved vehicles"], __submenus["SpawnVeh"], __submenus["SavedVehicles"])

do
	local files = file.scandir(paths['SavedVehicles'])
	local saved = {}
	for _, v in ipairs(files)
	do
		local tabl = json:decode(file.readAll(paths['SavedVehicles']..[[\]]..v))
		if v:sub(-5, -1) == '.json' then
			tabl.name = v:gsub('%.json', '')
			saved[#saved+1] = tabl
		end
	end
	local options = {}
	ui.add_click_option(TRANSLATION["Save current vehicle"], __submenus["SavedVehicles"], function()
		local veh = vehicles.get_player_vehicle()
		if veh == NULL then return end
		local vehicle = custom_vehicles.save(veh)
		local name = vehicles.get_label_name(ENTITY.GET_ENTITY_MODEL(veh))
		local repeats = 0
		local found
		for _, v in ipairs(saved)
		do
			if v.name == name then
				found = true
			end
			local n = v.name:match("[^ ]*$"):gsub('%D', '')
			if v.name:gsub(' %('..n..'%)', '') == name and v.name:sub(-string.len(' ('..n..')'), -1) == ' ('..n..')' then
				repeats = tonumber(n) and tonumber(n) + 1 or repeats
			end
		end
		if found then
			local repeats = repeats > 0 and repeats or 1
			name = string.format("%s (%d)", name, repeats)
		end
		-- vehicle.version = '1.0'
		file.write(json:encode_pretty(vehicle), paths['SavedVehicles']..[[\]]..name..[[.json]])
		vehicle.name = name
		saved[#saved+1] = vehicle
		system.notify(TRANSLATION['Info'], TRANSLATION["Vehicle saved, you can rename the file later"], 0, 128, 255, 255)
	end)
	ui.add_click_option(TRANSLATION['Open folder'], __submenus["SavedVehicles"], function() file.open(paths['SavedVehicles']) end)
	local delete_mode
	__options.bool["SavedVehiclesDelMod"] = ui.add_bool_option(TRANSLATION['Delete mode'], __submenus["SavedVehicles"], function(bool) delete_mode = bool end)
	ui.add_separator(TRANSLATION["Saved vehicles"], __submenus["SavedVehicles"])
	CreateRemoveThread(true, 'saved_vehicles', function()
		for i, v in ipairs(saved)
		do
			if not options[v.name] then
				local sub = ui.add_submenu(v.name)
				options[v.name] = ui.add_click_option(v.name, __submenus["SavedVehicles"], function()
					if delete_mode then
						ui.remove(options[v.name])
						os.remove(paths['SavedVehicles']..[[\]]..v.name..[[.json]])
					else
						custom_vehicles.create(v, true)
					end
				end)
			end
		end
	end)
end

do
	local selected_vehicle = 1
	local class = 0
	local classes = {}
	local curr_class
	local display_preview
	for i = 0, 22
	do
		table.insert(classes, enum.vehicle_class[i])
	end

	CreateRemoveThread(true, 'request_ptfx', function()
		if STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_rcbarry2") == NULL then 
			STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2")
			return
		end
		return POP_THREAD
	end)

	local function spawn()
		CreateRemoveThread(true, "spawn_vehicle_"..thread_count, function()
			local hash = vehicles.models[vehicles.get_veh_index(ui.get_value(curr_class) + 1, class)][2]
			if features.request_model(hash) == NULL then return end
			local prev_veh = vehicles.get_player_vehicle()
			local velocity
			if settings.Vehicle["SpawnerKeepSpeed"] and settings.Vehicle["SpawnerInside"] and prev_veh ~= NULL then
				velocity = ENTITY.GET_ENTITY_VELOCITY(prev_veh)
			end
			if settings.Vehicle["SpawnerDeleteOld"] and prev_veh ~= NULL then
				TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.PLAYER_PED_ID())
				features.delete_entity(prev_veh)
			end
			local pos = features.get_offset_from_player_coords(vector3(0, 5, 0))
			local veh = vehicles.spawn_vehicle(hash, pos, features.get_player_heading())
			if settings.Vehicle["SpawnWithEffect"] then
				GRAPHICS.USE_PARTICLE_FX_ASSET("scr_rcbarry2")
				GRAPHICS.START_PARTICLE_FX_NON_LOOPED_ON_ENTITY("scr_clown_appears", veh, 0, 0, 0, 0, 0, 0, 1.5, false, false, false)
				local alpha_table = {255, 204, 153, 102, 51, 0}
				local curr = 1
				local dir = true
				CreateRemoveThread(true, 'spawn_anim_'..thread_count, function(tick)
					if tick%2 ~= NULL then return end
					entities.request_control(veh, function()
						ENTITY.SET_ENTITY_ALPHA(veh, alpha_table[curr], false)
					end)
					if tick > 200 and curr == 1 then
						entities.request_control(veh, function()
							ENTITY.RESET_ENTITY_ALPHA(veh)
						end)
						return POP_THREAD
					end
					if dir then
						curr = curr + 1
						if curr == 6 then dir = false end
					else
						curr = curr - 1
						if curr == 1 then dir = true end
					end
				end)
			end
			entities.request_control(veh, function()
				DECORATOR.DECOR_SET_INT(veh, "MPBitset", 1024)
				vehicles.set_godmode(veh, settings.Vehicle["SpawnerGod"])
				vehicles.repair(veh)
				VEHICLE.SET_VEHICLE_ENGINE_ON(veh, true, true, false)
				if settings.Vehicle["SpawnerUpgraded"] then
					vehicles.upgrade(veh)
				end
				if settings.Vehicle["SpawnerInAir"] and (class == 15 or class == 16) then
					ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, pos.x, pos.y, pos.z + 50, false, false, false)
					VEHICLE.CONTROL_LANDING_GEAR(veh, 3)
					VEHICLE.SET_HELI_BLADES_FULL_SPEED(veh)
					if class == 16 then
						VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 50)
					end
				end
				if velocity and class ~= 16 then
					ENTITY.SET_ENTITY_VELOCITY(veh, velocity.x, velocity.y, velocity.z)
				end
				if settings.Vehicle["SpawnerInside"] then
					PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
				end
				STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
			end)
			return POP_THREAD
		end)
	end

	__options.bool["SpawnerGod"] = ui.add_bool_option(TRANSLATION["Spawn in godmode"], __submenus["SpawnSettings"], function(bool) settings.Vehicle["SpawnerGod"] = bool end)
	__options.bool["SpawnerUpgraded"] = ui.add_bool_option(TRANSLATION["Spawn upgraded"], __submenus["SpawnSettings"], function(bool) settings.Vehicle["SpawnerUpgraded"] = bool end)
	__options.bool["SpawnerKeepSpeed"] = ui.add_bool_option(TRANSLATION["Keep speed"], __submenus["SpawnSettings"], function(bool) settings.Vehicle["SpawnerKeepSpeed"] = bool end)
	__options.bool["SpawnerInside"] = ui.add_bool_option(TRANSLATION["Spawn inside"], __submenus["SpawnSettings"], function(bool) settings.Vehicle["SpawnerInside"] = bool end)
	__options.bool["SpawnerInAir"] = ui.add_bool_option(TRANSLATION["Spawn in air"], __submenus["SpawnSettings"], function(bool) settings.Vehicle["SpawnerInAir"] = bool end)
	__options.bool["SpawnerDeleteOld"] = ui.add_bool_option(TRANSLATION["Delete old vehicle"], __submenus["SpawnSettings"], function(bool) settings.Vehicle["SpawnerDeleteOld"] = bool end)
	__options.bool["SpawnWithEffect"] = ui.add_bool_option(TRANSLATION["Spawn with effect"], __submenus["SpawnSettings"], function(bool) settings.Vehicle["SpawnWithEffect"] = bool end)

	ui.add_separator(TRANSLATION["Spawn"], __submenus["SpawnVeh"])

	__options.bool["VehPreview"] = ui.add_bool_option(TRANSLATION["Display preview"], __submenus["SpawnVeh"], function(bool) display_preview = bool end)

	local sel_class = ui.add_choose(TRANSLATION["Select class"], __submenus["SpawnVeh"], true, classes, function(int) class = int
		if curr_class then 
			ui.remove(curr_class)
			curr_class = nil
		end
	end)
	ui.set_value(sel_class, class, true)
	CreateRemoveThread(true, 'selected_class_'..thread_count, function()
		if not curr_class then
			curr_class = ui.add_choose(TRANSLATION["Select vehicle"], __submenus["SpawnVeh"], false, vehicles.class[class], function(int) selected_vehicle = int + 1;spawn() end)
		end
	end)
	local veh_preview
	local hash
	CreateRemoveThread(true, 'display_vehicle_preview', function()
		if not display_preview then 
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
			if features.request_model(hash) == NULL then return end
			local pos = vector3(features.get_offset_coords_from_entity_rot(PLAYER.PLAYER_PED_ID(), 5, 0, true)) + vector3.up() * 1.5
			created_preview = vehicles.spawn_vehicle(hash, pos)
			NETWORK._NETWORK_SET_ENTITY_INVISIBLE_TO_NETWORK(created_preview, true)
			NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(created_preview), false)
			ENTITY.SET_ENTITY_COLLISION(created_preview, false, true)
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(created_preview, pos.x, pos.y, pos.z, false, false, false)
			ENTITY.SET_ENTITY_ALPHA(created_preview, 160, false)
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
		else
			if ENTITY.DOES_ENTITY_EXIST(created_preview) == NULL then created_preview = nil return end
			local model_dim_min = vehicles.data[veh_preview].DimensionsMin
			local model_dim_max = vehicles.data[veh_preview].DimensionsMax
			features.draw_box_on_entity(created_preview, vector3(model_dim_min.X, model_dim_min.Y, model_dim_min.Z), vector3(model_dim_max.X, model_dim_max.Y, model_dim_max.Z))
			local max = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(hash) - 2
	    for i = -1, max do
	    	local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(created_preview, i, true)
	    	if ped ~= NULL then
	    		TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
	    	end
	    end
			features.request_control_once(created_preview)
			vehicles.set_godmode(created_preview, true)
			local pos = vector3(features.get_offset_coords_from_entity_rot(PLAYER.PLAYER_PED_ID(), 3 + model_dim_max.Y, 0, true)) + vector3.up() * model_dim_max.Z
			ENTITY.SET_ENTITY_COLLISION(created_preview, false, true)
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(created_preview, pos.x, pos.y, pos.z, false, false, false)
			ENTITY.SET_ENTITY_ALPHA(created_preview, 160, false)
			local rot = ENTITY.GET_ENTITY_ROTATION(created_preview, 2)
			ENTITY.SET_ENTITY_ROTATION(created_preview, 0, 0, rot.z - 1, 2, true)
		end
	end)
end

do
	local selected_vehicle = 1
	local class = 0
	local classes = {}
	local curr_class
	for i = 0, 22
	do
		table.insert(classes, enum.vehicle_class[i])
	end
	local function change_sound()
		local veh = vehicles.get_player_vehicle()
		if veh == NULL then return end
		AUDIO._FORCE_VEHICLE_ENGINE_AUDIO(veh, vehicles.models[vehicles.get_veh_index(ui.get_value(curr_class) + 1, class)][1])
	end
	local sel_class = ui.add_choose(TRANSLATION["Select class"], __submenus["ChangeSound"], true, classes, function(int) class = int
		if curr_class then 
			ui.remove(curr_class)
			curr_class = nil
		end
	end)
	ui.set_value(sel_class, class, true)
	CreateRemoveThread(true, 'selected_class_'..thread_count, function()
		if not curr_class then
			curr_class = ui.add_choose(TRANSLATION["Select vehicle"], __submenus["ChangeSound"], false, vehicles.class[class], function(int) selected_vehicle = int + 1;change_sound() end)
		end
	end)
end

ui.add_separator(TRANSLATION["Horn boost"], __submenus["Vehicle"])

__options.bool["BoostEffect"] = ui.add_bool_option(TRANSLATION["With effect"], __submenus["Vehicle"], function(bool) settings.Vehicle["BoostEffect"] = bool end)

do
	local types = {TRANSLATION['Constant'] ,TRANSLATION['Non constant']}
	__options.choose["AccelerationType"] = ui.add_choose(TRANSLATION["Acceleration type"], __submenus["Vehicle"], true, types, function(int) settings.Vehicle["AccelerationType"] = int end)
	__options.num["HornBoostPower"] = ui.add_num_option(TRANSLATION["Horn boost power"], __submenus["Vehicle"], 1, 20, 1, function(int) settings.Vehicle["HornBoostPower"] = int end)
end

__options.bool["HornBoost"] = ui.add_bool_option(TRANSLATION["Horn boost"], __submenus["Vehicle"], function(bool)
	settings.Vehicle['HornBoost'] = bool
	CreateRemoveThread(bool, 'vehicle_horn_boost',
	function()
		if vehicles.get_player_vehicle() == NULL or PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_HORN) == NULL then return end
		local veh = vehicles.get_player_vehicle()
		features.request_control_once(veh)
		ENTITY.SET_ENTITY_MAX_SPEED(veh, 10000000)
		local speed = ENTITY.GET_ENTITY_SPEED(veh)
		if settings.Vehicle["BoostEffect"] then AUDIO.SET_VEHICLE_BOOST_ACTIVE(veh, true) GRAPHICS.ANIMPOSTFX_PLAY("DrivingFocusOut", 0, false) end
		if settings.Vehicle["AccelerationType"] == NULL then
			speed = speed + settings.Vehicle["HornBoostPower"]
		elseif settings.Vehicle["AccelerationType"] == 1 then
			if speed < 1 then speed = 1 end
			speed = speed + speed * settings.Vehicle["HornBoostPower"] / 100
		end
		VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, speed)
		if settings.Vehicle["BoostEffect"] then AUDIO.SET_VEHICLE_BOOST_ACTIVE(veh, false) GRAPHICS.ANIMPOSTFX_STOP("DrivingFocusOut") end
	end)
	
end)

ui.add_separator(TRANSLATION["Enter/exit"], __submenus["Vehicle"])

__options.bool["InstaEnter/ExitVehicle"] = ui.add_bool_option(TRANSLATION["Instant enter/exit vehicle"], __submenus["Vehicle"], function(bool)
	settings.Vehicle['InstaEnter/ExitVehicle'] = bool
	CreateRemoveThread(bool, 'vehicle_insta_exit',
	function()
		if ENTITY.IS_ENTITY_DEAD(PLAYER.PLAYER_PED_ID(), false) == 1 then return end
		if vehicles.get_player_vehicle() == NULL then
			local veh, dist = vehicles.get_closest_vehicle(features.get_player_coords())
			if veh == created_preview then return end
			local seat = vehicles.get_first_free_seat(veh)
			if settings.Vehicle["InstaEnter/ExitVehicleFroceDriver"] then seat = -1 end
			if not seat or dist > 400 or PAD.IS_CONTROL_JUST_PRESSED(0, enum.input.VEH_EXIT) == NULL then return end
			CreateRemoveThread(true, 'seat_change_'..thread_count, function(tick)
				if tick == 100 then return POP_THREAD end
				features.request_control_once(veh)
				local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, seat, true)
				if ped and ped ~= PLAYER.PLAYER_PED_ID() then
					TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
				end
				PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, seat)
				if VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, seat, true) ~= PLAYER.PLAYER_PED_ID() then return end
				return POP_THREAD
			end)
		elseif PAD.IS_CONTROL_JUST_PRESSED(0, enum.input.VEH_EXIT) == 1 then
			TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.PLAYER_PED_ID())
		end
	end)
end)

__options.bool["InstaEnter/ExitVehicleFroceDriver"] = ui.add_bool_option(TRANSLATION["Force driver seat"], __submenus["Vehicle"], function(bool) settings.Vehicle["InstaEnter/ExitVehicleFroceDriver"] = bool end)
__options.bool["StopVehWhenExit"] = ui.add_bool_option(TRANSLATION["Stop vehicle when exiting"], __submenus["Vehicle"], function(bool)
	settings.Vehicle["StopVehWhenExit"] = bool 
	local veh
	CreateRemoveThread(bool, 'veh_stop', function()
		if not veh then
			if vehicles.get_player_vehicle() == NULL then return end
			veh = vehicles.get_player_vehicle()
		end
		if PAD.IS_CONTROL_JUST_PRESSED(0, enum.input.VEH_EXIT) == NULL then return end
		features.request_control_once(veh)
		ENTITY.SET_ENTITY_VELOCITY(veh, 0, 0, 0)
		veh = nil
	end)
end)

ui.add_separator(TRANSLATION["Other"], __submenus["Vehicle"])

__submenus["VehicleWeapons"] = ui.add_submenu(TRANSLATION["Vehicle weapons"])
__suboptions["VehicleWeapons"] = ui.add_sub_option(TRANSLATION["Vehicle weapons"], __submenus["Vehicle"],__submenus["VehicleWeapons"])

__submenus["VehicleDoors"] = ui.add_submenu(HUD._GET_LABEL_TEXT("PIM_TDPV"))
__suboptions["VehicleDoors"] = ui.add_sub_option(HUD._GET_LABEL_TEXT("PIM_TDPV"), __submenus["Vehicle"],__submenus["VehicleDoors"])

do
	ui.add_separator(TRANSLATION["Open/close"], __submenus["VehicleDoors"])
	local door = {
		index = {
			[0] = TRANSLATION["Driver's Front Door"],
			[1] = TRANSLATION["Passenger's Front Door"],
			[2] = TRANSLATION["Driver's Rear Door"],
			[3] = TRANSLATION["Passenger's Rear Door"],
			[4] = TRANSLATION["Vehicle Hood"],
			[5] = TRANSLATION["Vehicle Trunk"],
		}
	}

	ui.add_click_option(TRANSLATION["Open all"], __submenus["VehicleDoors"], function()
		local veh = vehicles.get_player_vehicle()
		if veh == NULL then return end
		for i = 0, 5
		do
			entities.request_control(veh, function()
					VEHICLE.SET_VEHICLE_DOOR_OPEN(veh, i, false, false)
			end)
		end
	end)
	ui.add_click_option(TRANSLATION["Close all"], __submenus["VehicleDoors"], function()
		local veh = vehicles.get_player_vehicle()
		if veh == NULL then return end
		for i = 0, 5
		do
			entities.request_control(veh, function()
					VEHICLE.SET_VEHICLE_DOOR_SHUT(veh, i, false)
			end)
		end
	end)
	for i, v in ipairs(door.index)
	do
		ui.add_click_option(v, __submenus["VehicleDoors"], function()
			local veh = vehicles.get_player_vehicle()
			if veh == NULL then return end
			entities.request_control(veh, function()
				if VEHICLE.GET_VEHICLE_DOOR_ANGLE_RATIO(veh, i) == NULL then
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
		if veh == NULL then return end
		for i = 0, 5
		do
			entities.request_control(veh, function()
				VEHICLE._SET_VEHICLE_DOOR_CAN_BREAK(veh, i, true)
				VEHICLE.SET_VEHICLE_DOOR_BROKEN(veh, i, false)
			end)
		end
	end)
	for i, v in ipairs(door.index)
	do
		ui.add_click_option(v, __submenus["VehicleDoors"], function()
			local veh = vehicles.get_player_vehicle()
			if veh == NULL then return end
			entities.request_control(veh, function()
				VEHICLE._SET_VEHICLE_DOOR_CAN_BREAK(veh, i, true)
				VEHICLE.SET_VEHICLE_DOOR_BROKEN(veh, i, false)
			end)
		end)
	end

end

ui.add_click_option(TRANSLATION["Repair vehicle"], __submenus["Vehicle"], function()
	local veh = vehicles.get_player_vehicle()
	if veh == NULL then return end
	entities.request_control(veh, function()
		vehicles.repair(veh)
	end)
end)

do
	local blip
	ui.add_click_option(TRANSLATION["Add blip to vehicle"], __submenus["Vehicle"], function()
		local veh = vehicles.get_player_vehicle()
		if veh == NULL then return end
		if HUD.GET_BLIP_FROM_ENTITY(veh) ~= NULL then
			return
		end
		blip = HUD.ADD_BLIP_FOR_ENTITY(veh)
		HUD.SET_BLIP_SPRITE(blip, enum.blip_sprite.gang_vehicle)
		HUD.SET_BLIP_COLOUR(blip, enum.blip_color.Yellow)
	end)
end
__options.bool["VehicleRapidFire"] = ui.add_bool_option(TRANSLATION["Vehicle rapid fire"], __submenus["Vehicle"], function(bool)
	settings.Vehicle["VehicleRapidFire"] = bool
	CreateRemoveThread(bool, 'vehicle_rapid_fire',
	function()
		local veh = vehicles.get_player_vehicle()
		if veh == NULL then return end
		VEHICLE.SET_VEHICLE_FIXED(veh)
		VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(veh)
	end)
end)

__options.bool["InvisibleVehicle"] = ui.add_bool_option(TRANSLATION["Invisible"], __submenus["Vehicle"], function(bool)
	CreateRemoveThread(bool, 'vehicle_invisible',
	function()
		if vehicles.get_player_vehicle() == NULL then return end
		features.request_control_once(vehicles.get_player_vehicle())
		ENTITY.SET_ENTITY_VISIBLE(vehicles.get_player_vehicle(), false, false)
		NETWORK._NETWORK_SET_ENTITY_INVISIBLE_TO_NETWORK(vehicles.get_player_vehicle(), false)
		ENTITY.SET_ENTITY_VISIBLE(PLAYER.PLAYER_PED_ID(), true, false)
	end)
	if not bool then
		NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicles.get_player_vehicle())
		NETWORK._NETWORK_SET_ENTITY_INVISIBLE_TO_NETWORK(vehicles.get_player_vehicle(), true)
		ENTITY.SET_ENTITY_VISIBLE(vehicles.get_player_vehicle(), true, false) 
	end
end)

__options.bool["DisableVehicleCollision"] = ui.add_bool_option(TRANSLATION["Disable collision"], __submenus["Vehicle"], function(bool)
	CreateRemoveThread(bool, 'vehicle_invisible',
	function()
		if vehicles.get_player_vehicle() == NULL then return end
		features.request_control_once(vehicles.get_player_vehicle())
		ENTITY.SET_ENTITY_COLLISION(vehicles.get_player_vehicle(), false, true)
	end)
	if not bool then
		entities.request_control(vehicles.get_player_vehicle(), function()
			ENTITY.SET_ENTITY_COLLISION(vehicles.get_player_vehicle(), true, true)
		end)
	end
end)

__options.bool["AutoFlip"] = ui.add_bool_option(TRANSLATION["Auto flip"], __submenus["Vehicle"], function(bool)
	settings.Vehicle['AutoFlip'] = bool
	CreateRemoveThread(bool, 'vehicle_auto_flip',
	function(tick)
		if tick%2~=NULL then return end
		if vehicles.get_player_vehicle() == NULL then return end
		local veh = vehicles.get_player_vehicle()
		local rot = ENTITY.GET_ENTITY_ROTATION(veh, 2)
		if ENTITY.IS_ENTITY_IN_AIR(veh) == NULL and (rot.y < -110 or rot.y > 110) then
			if VEHICLE.IS_VEHICLE_ON_ALL_WHEELS(veh) == NULL then
				features.request_control_once(veh)
				ENTITY.SET_ENTITY_ROTATION(veh, 0, 0, rot.z, 5, true)
				VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh, 0)
			end
		end
	end)
end)

__options.bool["EngineAlwaysOn"] = ui.add_bool_option(TRANSLATION["Engine always on"], __submenus["Vehicle"], function(bool)
	settings.Vehicle['EngineAlwaysOn'] = bool
	CreateRemoveThread(bool, 'vehicle_always_on_engine',
	function()
		if vehicles.get_player_vehicle() == NULL then return end
		VEHICLE.SET_VEHICLE_ENGINE_ON(vehicles.get_player_vehicle(), true, true, false)
		ticks["EngineAlwaysOn"] = nil
	end)
end)

__options.bool["ScorchedVehicle"] = ui.add_bool_option(TRANSLATION["Scorched vehicle"], __submenus["Vehicle"], function(bool)
	if vehicles.get_player_vehicle() == NULL then return end
	ENTITY.SET_ENTITY_RENDER_SCORCHED(vehicles.get_player_vehicle(), bool)
end)

__options.bool["SlidyVehicle"] = ui.add_bool_option(TRANSLATION["Slidy vehicle"], __submenus["Vehicle"], function(bool)
	if vehicles.get_player_vehicle() == NULL then return end
	VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicles.get_player_vehicle(), bool)
end)

__options.bool["LicenceSpeedo"] = ui.add_bool_option(TRANSLATION["Licence plate speedo"], __submenus["Vehicle"], function(bool)
	settings.Vehicle['LicenceSpeedo'] = bool
	local mult = 2.236936
	local unit = 'mph'
	if MISC.SHOULD_USE_METRIC_MEASUREMENTS() == 1 then
		mult = 3.6
		unit = 'kmph'
	end
	CreateRemoveThread(bool, 'vehicle_licence_speedo', function()
		if vehicles.get_player_vehicle() == NULL then return end
		local speed = ENTITY.GET_ENTITY_SPEED(vehicles.get_player_vehicle())
		VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicles.get_player_vehicle(), tostring(math.floor(speed * mult))..' '..unit)
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
-- 		if vehicles.get_player_vehicle() == NULL then return end
-- 		local speed = ENTITY.GET_ENTITY_SPEED(vehicles.get_player_vehicle())
-- 		HUD.BEGIN_TEXT_COMMAND_PRINT("STRING")
-- 		HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(tostring(math.floor(speed * mult))..' '..unit)
-- 		HUD.END_TEXT_COMMAND_PRINT(100, true)
-- 	end)
-- end)

__options.bool["MaxSpeedBypass"] = ui.add_bool_option(TRANSLATION["Max speed bypass"], __submenus["Vehicle"], function(bool)
	settings.Vehicle["MaxSpeedBypass"] = bool
	CreateRemoveThread(bool, 'vehicle_speed_bypass', function()
		local veh = vehicles.get_player_vehicle()
		if veh == NULL then return end
		ENTITY.SET_ENTITY_MAX_SPEED(veh, 10000000)
	end)
	if not bool then
		ENTITY.SET_ENTITY_MAX_SPEED(veh, 540)
	end
end)

__options.bool["StickToGround"] = ui.add_bool_option(TRANSLATION["Stick to ground"], __submenus["Vehicle"], function(bool)
	settings.Vehicle["StickToGround"] = bool
	CreateRemoveThread(bool, 'vehicle_stick_to_ground', function()
		local veh = vehicles.get_player_vehicle()
		if veh == NULL or ENTITY.IS_ENTITY_IN_AIR(veh) == NULL then return end
		VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh, 5)
	end)
end)

__options.bool["SlamIt"] = ui.add_bool_option(TRANSLATION["Slam it"], __submenus["Vehicle"], function(bool)
	settings.Vehicle["SlamIt"] = bool
	CreateRemoveThread(bool, 'vehicle_slam_vehicle', function()
		local veh = vehicles.get_player_vehicle()
		if veh == NULL then return end
		ENTITY.APPLY_FORCE_TO_ENTITY(veh, 0, 0, 0, -30, 0, 0, 0, 0, true, false, true, false, true)
	end)
end)

do
	local pressed
	__options.choose["VehicleJumping"] = ui.add_choose(TRANSLATION["Vehicle jump"], __submenus["Vehicle"], true, {TRANSLATION['None'], TRANSLATION["Press"], TRANSLATION['Hold']}, function(int) settings.Vehicle["VehicleJumping"] = int	end)

	CreateRemoveThread(true, 'vehicle_jump', function()
		if settings.Vehicle["VehicleJumping"] == 0 then return end
		local veh = vehicles.get_player_vehicle()
		if veh == NULL then return end
		PAD.DISABLE_CONTROL_ACTION(0, enum.input.VEH_HANDBRAKE, true)
		if settings.Vehicle["VehicleJumping"] == 1 then
			if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_HANDBRAKE) == 1 and ENTITY.IS_ENTITY_IN_AIR(veh) == NULL then
				if pressed then return end
				local vel = ENTITY.GET_ENTITY_VELOCITY(veh)
	      ENTITY.SET_ENTITY_VELOCITY(veh, vel.x, vel.y, vel.z + 10)
	      pressed = true
	    elseif pressed then
	    	pressed = nil
	    end
	    return
		end
		if settings.Vehicle["VehicleJumping"] == 2 then
			if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_HANDBRAKE) == 1 then
				local vel = ENTITY.GET_ENTITY_VELOCITY(veh)
	      ENTITY.SET_ENTITY_VELOCITY(veh, vel.x, vel.y, vel.z + 2)
	    end
	  end
	end)
end

do
	local types = {TRANSLATION['None'], TRANSLATION['Keyboard'], TRANSLATION['Cam fly'], TRANSLATION['Glide fly']}
	local type = 0
	__options.choose["VehicleFly"] = ui.add_choose(TRANSLATION["Vehicle fly"], __submenus["Vehicle"], false, types, function(int) type = int 
		settings.Vehicle["VehicleFly"] = int
	end)
	CreateRemoveThread(true, 'vehicle_fly', function()
		local veh = vehicles.get_player_vehicle()
		if type == NULL or veh == NULL then return end
		local rot = vector3(CAM.GET_GAMEPLAY_CAM_ROT(2))
		features.request_control_once(veh)
		if type == 1 then
      ENTITY.SET_ENTITY_ROTATION(veh, rot.x, rot.y, rot.z, 2, true)
      local pad
    	if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_UP) == 1 then
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0, 50, 0, 0, 0, 0, 0, true, false, true, false, true)
        pad = true
      end
      if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_DOWN) == 1 then
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0, -50, 0, 0, 0, 0, 0, true, false, true, false, true)
         pad = true
      end
      if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_LEFT) == 1 then
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, -50, 0, 0, 0, 0, 0, 0, true, false, true, false, true)
         pad = true
      end
      if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_RIGHT) == 1 then
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 50, 0, 0, 0, 0, 0, 0, true, false, true, false, true)
         pad = true
      end
      if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_MOVE_UP_ONLY) == 1 then
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0, 0, 50, 0, 0, 0, 0, true, false, true, false, true)
         pad = true
      end
      if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_MOVE_UD) == 1 then
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0, 0, -50, 0, 0, 0, 0, true, false, true, false, true)
         pad = true
      end
      if not pad then
      	ENTITY.SET_ENTITY_VELOCITY(veh, 0, 0, 0)
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
		elseif type == 2 then
			if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_UP) == 1 then
				local force = 20
				if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_MOVE_UP_ONLY) == 1 then force = 100 end
				local dir = rot:rot_to_direction() * force
				ENTITY.SET_ENTITY_VELOCITY(veh, dir.x, dir.y, dir.z)
			end
			if settings.General["ShowControls"] and Instructional:New() then
	    	Instructional.AddButton(enum.input.VEH_FLY_THROTTLE_UP, TRANSLATION["Fly"])
	    	Instructional.AddButton(enum.input.VEH_MOVE_UP_ONLY, TRANSLATION["Faster"])
	    	Instructional:BackgroundColor(0, 0, 0, 80)
	    	Instructional:Draw()
	    end
		elseif type == 3 then
     ENTITY.SET_ENTITY_ROTATION(veh, rot.x, rot.y, rot.z, 2, true)
	    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_UP) == 1 then
	      ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0, 1, 0, 0, 0, 0, 0, true, false, true, false, true)
      end
      if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_DOWN) == 1 then
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0, -1, 0, 0, 0, 0, 0, true, false, true, false, true)
      end
      if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_LEFT) == 1 then
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, -1, 0, 0, 0, 0, 0, 0, true, false, true, false, true)
      end
      if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_RIGHT) == 1 then
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 1, 0, 0, 0, 0, 0, 0, true, false, true, false, true)
      end
      if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_MOVE_UP_ONLY) == 1 then
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0, 0, 1, 0, 0, 0, 0, true, false, true, false, true)
      end
      if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_MOVE_UD) == 1 then
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0, 0, -1, 0, 0, 0, 0, true, false, true, false, true)
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
	end)
end

do
	__options.bool["VehicleWeaponsShowLasers"] = ui.add_bool_option(TRANSLATION["Show lasers"], __submenus["VehicleWeapons"], function(bool) settings.Vehicle["VehicleWeaponsShowLasers"] = bool end)
	__options.bool["VehicleWeaponsAimCamera"] = ui.add_bool_option(TRANSLATION["Aim with camera"], __submenus["VehicleWeapons"], function(bool) settings.Vehicle["VehicleWeaponsAimCamera"] = bool end)
	__options.num["VehicleWeaponsDelay"] = ui.add_num_option(TRANSLATION["Delay between shots"], __submenus["VehicleWeapons"], 0, 5000, 10, function(int) settings.Vehicle["VehicleWeaponsDelay"] = int end)
	local types = {TRANSLATION['None'], HUD._GET_LABEL_TEXT("WT_SNIP_HVY2"), HUD._GET_LABEL_TEXT("WT_RPG"), HUD._GET_LABEL_TEXT("BCK_WEAPON_5"), HUD._GET_LABEL_TEXT("WT_SNWBALL"), HUD._GET_LABEL_TEXT("WT_RAYPISTOL"), HUD._GET_LABEL_TEXT("WT_FIREWRK"), HUD._GET_LABEL_TEXT("WT_EMPL"), HUD._GET_LABEL_TEXT("WT_V_KHA_CA"), HUD._GET_LABEL_TEXT("LAZER")}
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
	__options.choose["VehicleWeapons"] = ui.add_choose(TRANSLATION["Vehicle weapons"], __submenus["VehicleWeapons"], false, types, function(int) type = int 
		settings.Vehicle["VehicleWeapons"] = int
	end)
	local delay
	CreateRemoveThread(true, 'vehicle_weapons', function()
		local veh = vehicles.get_player_vehicle()
		if veh == NULL or settings.Vehicle["VehicleWeapons"] == NULL then return end
		if WEAPON.HAS_WEAPON_ASSET_LOADED(weapons[type]) == NULL then
			WEAPON.REQUEST_WEAPON_ASSET(weapons[type], 31, 0)
			return
		end
		local model = ENTITY.GET_ENTITY_MODEL(veh)
		local v_min
		local v_max
		for _, v in ipairs(vehicles.data)
		do
			if model == v.Hash then
				v_min = v.DimensionsMin
				v_max = v.DimensionsMax
				break
			end
		end
		local offset_right1 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(veh, v_max.X, v_max.Y + .1, .35)
		local offset_left1 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(veh, v_min.X, v_max.Y + .1, .35)
		local offset_right2 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(veh, v_max.X, v_max.Y + 1500, .35)
		local offset_left2 = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(veh, v_min.X, v_max.Y + 1500, .35)
		if settings.Vehicle["VehicleWeaponsAimCamera"] then
			local dir = vector3(CAM.GET_GAMEPLAY_CAM_ROT(2)):rot_to_direction()
			local camcoord = vector3(CAM.GET_GAMEPLAY_CAM_COORD())
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
		if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.ATTACK2) == NULL or (delay and delay > os.clock()) then return end
		delay = os.clock() + ui.get_value(__options.num["VehicleWeaponsDelay"]) / 1000
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(offset_right1.x, offset_right1.y, offset_right1.z, offset_right2.x, offset_right2.y, offset_right2.z, 50, true, weapons[type], PLAYER.PLAYER_PED_ID(), true, true, 24000)
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(offset_left1.x, offset_left1.y, offset_left1.z, offset_left2.x, offset_left2.y, offset_left2.z, 50, true, weapons[type], PLAYER.PLAYER_PED_ID(), true, true, 24000)
	end)
end

__options.num["VehicleLightMultiplier"] = ui.add_num_option(TRANSLATION["Lights intensity"], __submenus["Vehicle"], 0, 100000, 10, function(int)
	local veh = vehicles.get_player_vehicle()
	if veh == NULL then return end
	VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(veh, int/100)
end)
ui.set_value(__options.num["VehicleLightMultiplier"], 100, true)
__options.num["VehicleAlpha"] = ui.add_num_option(TRANSLATION["Set alpha"], __submenus["Vehicle"], 0, 255, 1, function(int)
	local veh = vehicles.get_player_vehicle()
	if veh == NULL then return end
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
	local _seat = -1
	CreateRemoveThread(true, 'vehicle_change_vehicle_seat', function()
		local veh = vehicles.get_player_vehicle()
		if vehicles.get_player_vehicle() ~= NULL then
			if not num_seat then
				num_seat = ui.add_num_option(TRANSLATION["Change seat"], __submenus["Vehicle"], -1, max, 1, function(seat)
					CreateRemoveThread(true, 'seat_change_'..thread_count, function(tick)
						if tick == 100 then return POP_THREAD end
						local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, seat, true)
						if ped and ped ~= PLAYER.PLAYER_PED_ID() then
							TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
						end
						features.request_control_once(veh)
						PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, seat)
						if VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, seat, true) ~= PLAYER.PLAYER_PED_ID() then return end
						return POP_THREAD
					end)
				end)
				local hash = ENTITY.GET_ENTITY_MODEL(veh)
				max = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(hash) - 2
				ui.set_num_max(num_seat, max)
			end
			local _seat = vehicles.get_ped_seat(PLAYER.PLAYER_PED_ID())
			if _seat ~= ui.get_value(num_seat) then
				ui.set_value(num_seat, _seat, true)
			end
		elseif num_seat then
			ui.remove(num_seat)
			num_seat = nil
		end
	end)
end

ui.add_click_option(TRANSLATION["Delete current vehicle"], __submenus["Vehicle"], function()
	local veh = vehicles.get_player_vehicle()
	if veh == NULL then return end
	TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.PLAYER_PED_ID())
	features.delete_entity(veh)
end)

---------------------------------------------------------------------------------------------------------------------------------
-- World
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'world submenu') end
__submenus["World"] = ui.add_submenu(TRANSLATION["World"])
__suboptions["World"] = ui.add_sub_option(TRANSLATION["World"], main_submenu, __submenus["World"])

__submenus["WorldEditor"] = ui.add_submenu(TRANSLATION["Editor"])
__suboptions["WorldEditor"] = ui.add_sub_option(TRANSLATION["Editor"], __submenus["World"] , __submenus["WorldEditor"])

__submenus["WorldEditorSpawned"] = ui.add_submenu(TRANSLATION["Spawned"])
__suboptions["WorldEditorSpawned"] = ui.add_sub_option(TRANSLATION["Spawned"], __submenus["WorldEditor"] , __submenus["WorldEditorSpawned"])
ui.add_separator(TRANSLATION["Here will appear your spawned objects"], __submenus["WorldEditorSpawned"])
do
	local wait = NULL
	local cam = NULL
	__options.num["FreeCamSens"] = ui.add_num_option(TRANSLATION["Free cam sensitivity"], __submenus["WorldEditor"], 1, 100, 5, function(int) settings.World["FreeCamSens"] = int end)
	__options.bool["FreeCam"] = ui.add_bool_option(TRANSLATION["Free cam"], __submenus["WorldEditor"], function(bool)
		HUD.DISPLAY_RADAR(not bool)
		if not bool then
			CAM.RENDER_SCRIPT_CAMS(false, false, 0, true, false, 0)
			CAM.SET_CAM_ACTIVE(cam, false)
			CAM.DESTROY_CAM(cam, false)
			cam = NULL
		elseif ui.get_value(__options.choose["NoClip"] ~= NULL) then
			ui.set_value(__options.choose["NoClip"], 0, false)
		end
		ENTITY.FREEZE_ENTITY_POSITION(PLAYER.PLAYER_PED_ID(), bool)
		CreateRemoveThread(bool, 'free_cam', function()
			ENTITY.FREEZE_ENTITY_POSITION(PLAYER.PLAYER_PED_ID(), true)
			if CAM.DOES_CAM_EXIST(cam) == NULL then
				CAM.DESTROY_ALL_CAMS(true)
				cam = CAM.CREATE_CAM("DEFAULT_SCRIPTED_CAMERA", false)
				local rot = vector3(CAM.GET_GAMEPLAY_CAM_ROT(2))
				CAM.SET_CAM_ROT(cam, rot.x, rot.y, rot.z, 2)
				CAM.SET_CAM_FOV(cam, 50)
				local pos = vector3(CAM.GET_GAMEPLAY_CAM_COORD())
				CAM.SET_CAM_COORD(cam, pos.x, pos.y, pos.z)
				CAM.SET_CAM_ACTIVE(cam, true)
				CAM.RENDER_SCRIPT_CAMS(true, false, 0, true, false, 0)
			else
				features.draw_crosshair(20, 20, 0, 2, 255, 255, 255, 255, true, true, true, true, 0, 0, 0, 0, 0, false)
				PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
				globals.set_int(19937, 1)
				local rot = vector3(CAM.GET_CAM_ROT(cam, 2))
				local X = -PAD.GET_DISABLED_CONTROL_NORMAL(0, enum.input.LOOK_LR) * (settings.World["FreeCamSens"] / 10)
				local Y = -PAD.GET_DISABLED_CONTROL_NORMAL(0, enum.input.LOOK_UD) * (settings.World["FreeCamSens"] / 10)
				CAM.SET_CAM_ROT(cam, (rot.x + Y > -89 and rot.x + Y < 89) and rot.x + Y or rot.x, 0, rot.z + X, 2)
				local mult = .3
				if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_SUB_ASCEND) == 1 then
		    	mult = 1
		    end
				local pos = vector3.zero()
		    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_UP) == 1 then
		    	pos = pos + vector3.forward() * mult
		    end
		    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_DOWN) == 1 then
		      pos = pos + vector3.back() * mult
		    end
		    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_LEFT) == 1 then
		      pos = pos + vector3.left() * mult
		    end
		    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_RIGHT) == 1 then
		       pos = pos + vector3.right() * mult
		    end
		    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_PUSHBIKE_SPRINT) == 1 then
		      pos = pos + vector3.up() * mult
		    end
		    if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_SUB_DESCEND) == 1 then
		      pos = pos + vector3.down() * mult
		    end
		    if wait < os.clock() then
			    local pos = features.get_offset_cam_coords(cam, pos)
			    CAM.SET_CAM_COORD(cam, pos.x, pos.y, pos.z)
			  end
			  if settings.General["ShowControls"] and not settings.World["SpawnMode"] and Instructional:New() then
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
		  end
		end)
	end)
	__options.bool["SpawnMode"] = ui.add_bool_option(TRANSLATION["Spawn mode"], __submenus["WorldEditor"], function(bool)
		settings.World["SpawnMode"] = bool
	end)

	local entity_data = {}
	local selected = 1
	local created_preview
	local rot = vector3.zero()
	local function Spawn(model)
		CreateRemoveThread(true, 'spawn_object_'..thread_count, function()
			local loaded, ihash = features.request_model(utils.joaat(model))
			if not ihash then return POP_THREAD end
			if loaded == NULL then return end
			local pos = CAM.DOES_CAM_EXIST(cam) == 1 and vector3(CAM.GET_CAM_COORD(cam)) or vector3(CAM.GET_GAMEPLAY_CAM_COORD())
			local crot = CAM.DOES_CAM_EXIST(cam) == 1 and vector3(CAM.GET_CAM_ROT(cam, 2)) or vector3(CAM.GET_GAMEPLAY_CAM_ROT(2))
			local dir = crot:rot_to_direction() * 10
			pos = pos + dir
			local obj = features.create_object(ihash, pos)
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ihash)
			ENTITY.FREEZE_ENTITY_POSITION(obj, true)
			if created_preview then
				ENTITY.SET_ENTITY_ROTATION(obj, rot.x, rot.y, rot.z, 2, true)
			end
			ENTITY.SET_ENTITY_COORDS(obj, pos.x, pos.y, pos.z, false, false, false, false)
			entity_data[obj] = {
				type = 3,
				valid = ENTITY.DOES_ENTITY_EXIST(obj),
				name = model,
				pos = pos,
				rot = rot
			}
			return POP_THREAD
		end)
	end
	__options.choose["Objects"] = ui.add_choose(TRANSLATION["Object"], __submenus["WorldEditor"], false, objects, function(int) Spawn(objects[int+1]) end)
	CreateRemoveThread(true, 'world_editor_obj_spawner', function()
		if not settings.World["SpawnMode"] then 
			if created_preview then
				features.delete_entity(created_preview)
				created_preview = nil
				rot = vector3.zero()
			end
			return
		end
		if selected ~= ui.get_value(__options.choose["Objects"]) + 1 then
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(utils.joaat(objects[selected]))
			if created_preview then
				features.delete_entity(created_preview)
				created_preview = nil
				rot = vector3.zero()
			end
			selected = ui.get_value(__options.choose["Objects"]) + 1
		end
		if not created_preview then
			local loaded, hash = features.request_model(utils.joaat(objects[selected]))
			if not hash or loaded == NULL then return end
			local pos = CAM.DOES_CAM_EXIST(cam) == 1 and vector3(CAM.GET_CAM_COORD(cam)) or vector3(CAM.GET_GAMEPLAY_CAM_COORD())
			local rot = CAM.DOES_CAM_EXIST(cam) == 1 and vector3(CAM.GET_CAM_ROT(cam, 2)) or vector3(CAM.GET_GAMEPLAY_CAM_ROT(2))
			local dir = rot:rot_to_direction() * 10
			pos = pos + dir
			created_preview = entities.create_object(hash, pos)
			NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(created_preview), false)
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
			ENTITY.FREEZE_ENTITY_POSITION(created_preview, true)
			ENTITY.SET_ENTITY_COLLISION(created_preview, false, true)
			ENTITY.SET_ENTITY_COORDS(created_preview, pos.x, pos.y, pos.z, false, false, false, false)
			ENTITY.SET_ENTITY_ROTATION(created_preview, 0, 0, 0, 2, true)
			ENTITY.SET_ENTITY_ALPHA(created_preview, 160, false)
			rot = vector3.zero()
		else
			if ENTITY.DOES_ENTITY_EXIST(created_preview) == NULL then created_preview = nil return end
			local pos = CAM.DOES_CAM_EXIST(cam) == 1 and vector3(CAM.GET_CAM_COORD(cam)) or vector3(CAM.GET_GAMEPLAY_CAM_COORD())
			local crot = CAM.DOES_CAM_EXIST(cam) == 1 and vector3(CAM.GET_CAM_ROT(cam, 2)) or vector3(CAM.GET_GAMEPLAY_CAM_ROT(2))
			local dir = crot:rot_to_direction() * 10
			pos = pos + dir
			features.set_godmode(created_preview, true)
			ENTITY.FREEZE_ENTITY_POSITION(created_preview, true)
			ENTITY.SET_ENTITY_COLLISION(created_preview, false, true)
			ENTITY.SET_ENTITY_COORDS(created_preview, pos.x, pos.y, pos.z, false, false, false, false)
			ENTITY.SET_ENTITY_ALPHA(created_preview, 160, false)
			erot = vector3(ENTITY.GET_ENTITY_ROTATION(created_preview, 2))
			PAD.DISABLE_ALL_CONTROL_ACTIONS(0)
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
			ENTITY.SET_ENTITY_ROTATION(created_preview, erot.x, erot.y, erot.z, 2, true)
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
	local spawned_options = {}
	CreateRemoveThread(true, 'world_editor_spawned_entities', function(tick)
		for k, v in pairs(entity_data)
		do
			if v.valid ~= NULL then
				v.valid = ENTITY.DOES_ENTITY_EXIST(k)
				if v.valid ~= NULL then
					v.pos = vector3(ENTITY.GET_ENTITY_COORDS(k, false))
					v.rot = vector3(ENTITY.GET_ENTITY_ROTATION(k, 2))
				end
			end

			local sub = ui.add_submenu(v.name)
			if not spawned_options[k] then
				spawned_options[k] = {
					submenu = sub,
					sub_option = ui.add_sub_option(v.name, __submenus["WorldEditorSpawned"], sub),
					separator_pos = ui.add_separator(TRANSLATION["Position"], sub),
					posx = ui.add_num_option("X", sub, -10000, 10000, 1, function(int)
						if v.valid == NULL then return end
						entities.request_control(k, function()
							local pos = v.pos
							ENTITY.SET_ENTITY_COORDS(k, int, pos.y, pos.z, false, false, false, false)
						end)
					end),
					posy = ui.add_num_option("Y", sub, -10000, 10000, 1, function(int)
						if v.valid == NULL then return end
						entities.request_control(k, function()
							local pos = v.pos
							ENTITY.SET_ENTITY_COORDS(k, pos.x, int, pos.z, false, false, false, false)
						end)
					end),
					posz = ui.add_num_option("Z", sub, -10000, 10000, 1, function(int)
						if v.valid == NULL then return end
						entities.request_control(k, function()
							local pos = v.pos
							ENTITY.SET_ENTITY_COORDS(k, pos.x, pos.y, int, false, false, false, false)
						end)
					end),
					separator_rot = ui.add_separator(TRANSLATION["Rotation"], sub),
					rotx = ui.add_num_option(TRANSLATION["Pitch"], sub, -90, 90, 1, function(int)
						if v.valid == NULL then return end
						entities.request_control(k, function()
							local rot = v.rot
							ENTITY.SET_ENTITY_ROTATION(k, int, rot.y, rot.z, 2, true)
						end)
					end),
					roty = ui.add_num_option(TRANSLATION["Roll"], sub, -180, 180, 1, function(int)
						if v.valid == NULL then return end
						entities.request_control(k, function()
							local rot = v.rot
							ENTITY.SET_ENTITY_ROTATION(k, rot.x, int, rot.z, 2, true)
						end)
					end),
					rotz = ui.add_num_option(TRANSLATION["Yaw"], sub, -180, 180, 1, function(int)
						if v.valid == NULL then return end
						entities.request_control(k, function()
							local rot = v.rot
							ENTITY.SET_ENTITY_ROTATION(k, rot.x, rot.y, int, 2, true)
						end)
					end),
					reset_rot = ui.add_click_option(TRANSLATION["Reset rotation"], sub, function()
						if v.valid == NULL then return end
						entities.request_control(k, function()
							ENTITY.SET_ENTITY_ROTATION(k, 0, 0, 0, 2, true)
						end)
					end),
					tp_to = ui.add_click_option(TRANSLATION["Teleport to entity"], sub, function()
						if v.valid == NULL then return end
						local pos = v.pos
						if CAM.DOES_CAM_EXIST(cam) ~= NULL then
							CAM.SET_CAM_COORD(cam, pos.x, pos.y, pos.z)
							wait = os.clock() + 0.1
						else
							features.teleport(PLAYER.PLAYER_PED_ID(), pos.x, pos.y, pos.z)
						end
					end),
					tp_toself = ui.add_click_option(TRANSLATION["Teleport to self"], sub, function()
						if v.valid == NULL then return end
						entities.request_control(k, function()
							local pos
							if CAM.DOES_CAM_EXIST(cam) ~= NULL then
								pos = CAM.GET_CAM_COORD(cam)
							else
								pos = features.get_player_coords()
							end
							ENTITY.SET_ENTITY_COORDS(k, pos.x, pos.y, pos.z, false, false, false, false)
						end)
					end),
					delete = ui.add_click_option(TRANSLATION["Delete"], sub, function()
						features.delete_entity(k)
						for _, v in pairs(spawned_options[k])
						do
							ui.remove(v)
						end
						spawned_options[k] = nil
						entity_data[k] = nil
					end)
				}
			else
				if v.valid == NULL then
					ui.set_name(spawned_options[k].submenu, v.name..' **INVALID**')
					ui.set_name(spawned_options[k].sub_option, v.name..' **INVALID**')
				elseif tick%10==NULL then
					ui.set_value(spawned_options[k].posx, math.floor(v.pos.x), true)
					ui.set_value(spawned_options[k].posy, math.floor(v.pos.y), true)
					ui.set_value(spawned_options[k].posz, math.floor(v.pos.z), true)
					ui.set_value(spawned_options[k].rotx, math.floor(v.rot.x), true)
					ui.set_value(spawned_options[k].roty, math.floor(v.rot.y), true)
					ui.set_value(spawned_options[k].rotz, math.floor(v.rot.z), true)
				end
			end
		end
	end)
end

__submenus["BlockAreas"] = ui.add_submenu(TRANSLATION["Block areas"])
__suboptions["BlockAreas"] = ui.add_sub_option(TRANSLATION["Block areas"], __submenus["World"] , __submenus["BlockAreas"])

ui.add_click_option(TRANSLATION["Block Orbital Room"], __submenus["BlockAreas"], function() 
    BlockArea(-1003748966, 328.337, 4828.734, -58.553, 0.0, 90.0, 0.0, true) 
end)

ui.add_click_option(TRANSLATION["Block all LSC"], __submenus["BlockAreas"], function()
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
    BlockArea(-1003748966, 924.796, 46.537, 82.332, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 936.130, 0.807, 79.608, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 987.713, 80.519, 81.877, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, 966.303, 61.289, 112.845, 0.0, 90.0, 0.0, true)
end)

ui.add_click_option(TRANSLATION["Block Eclipse Towers"], __submenus["BlockAreas"], function()
    BlockArea(-1003748966, -773.986, 313.359, 85.677, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, -796.079, 308.323, 85.677, 0.0, 90.0, 0.0, true)
    BlockArea(-1003748966, -796.079, 308.323, 87.677, 0.0, 90.0, 0.0, true)
end)

ui.add_click_option(TRANSLATION["Windmill main LSC"], __submenus["BlockAreas"], function()
    BlockArea(1952396163, -405.3579, -142.0034, 36.3176, -90.0, 60.0, 0.0, false)
end)

ui.add_click_option(TRANSLATION["Block Strip Club"], __submenus["BlockAreas"], function()
    BlockArea(-1003748966, 127.9552, -1298.503, 29.4196, 0.0, 90.0, 0.0, true)
end)

ui.add_separator(TRANSLATION['Delete'], __submenus["BlockAreas"])

ui.add_click_option(TRANSLATION["Delete all blocking objects"], __submenus["BlockAreas"], function()
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

	__options.bool["ClearAreaPeds"] = ui.add_bool_option(TRANSLATION["Peds"], __submenus["ClearArea"], function(bool) clear_peds = bool 
		settings.World["ClearAreaPeds"] = bool
	end)
	__options.bool["ClearAreaVehicles"] = ui.add_bool_option(TRANSLATION["Vehicles"], __submenus["ClearArea"], function(bool) clear_vehicles = bool 
		settings.World["ClearAreaVehicles"] = bool
	end)
	__options.bool["ClearAreaProps"] = ui.add_bool_option(TRANSLATION["Props"], __submenus["ClearArea"], function(bool) clear_props = bool 
		settings.World["ClearAreaProps"] = bool
	end)
	__options.bool["ClearAreaPickups"] = ui.add_bool_option(TRANSLATION["Pickups"], __submenus["ClearArea"], function(bool) clear_pickups = bool 
		settings.World["ClearAreaPickups"] = bool
	end)

	__options.num["ClearAreaDistance"] = ui.add_num_option(TRANSLATION["Distance"], __submenus["ClearArea"], 0, 10000, 10, function(int) settings.World["ClearAreaDistance"] = int end)

	__options.click["ClearArea"] = ui.add_click_option(TRANSLATION["Clear area"], __submenus["ClearArea"], function()
		if not clearing_area then
			clearing_area = true
			CreateRemoveThread(true, 'world_clear_area', function()
				local dist = math.pow(settings.World["ClearAreaDistance"], 2)
				local pos = vector3(features.get_player_coords())
				if clear_peds then
					features.request_control_of_entities(entities.get_peds())
					for _, v in ipairs(entities.get_peds())
					do
						if PED.IS_PED_A_PLAYER(v) == NULL and pos:sqrlen(vector3(ENTITY.GET_ENTITY_COORDS(v, false))) <= dist then
							features.delete_entity(v)
						end
					end
				end
				if clear_vehicles then
					features.request_control_of_entities(entities.get_vehs())
					for _, v in ipairs(entities.get_vehs())
					do
						if v ~= vehicles.get_personal_vehicle() and v ~= vehicles.get_player_vehicle() and pos:sqrlen(vector3(ENTITY.GET_ENTITY_COORDS(v, false))) <= dist then
							features.delete_entity(v)
						end
					end
				end
				if clear_props then
					features.request_control_of_entities(entities.get_objects())
					for _, v in ipairs(entities.get_objects())
					do
						if pos:sqrlen(vector3(ENTITY.GET_ENTITY_COORDS(v, false))) <= dist then
							features.delete_entity(v)
						end
					end
				end
				if clear_pickups then
					features.request_control_of_entities(entities.get_pickups())
					for _, v in ipairs(entities.get_pickups())
					do
						if pos:sqrlen(vector3(ENTITY.GET_ENTITY_COORDS(v, false))) <= dist then
							features.delete_entity(v)
						end
					end
				end
				clearing_area = nil
				system.notify(TRANSLATION['Info'], TRANSLATION['Clear area finished'], 0, 255, 0, 255)
				return POP_THREAD
			end, true, true)
		end
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
	local force_types = {TRANSLATION['Low'], TRANSLATION['Medium'], TRANSLATION['High']}
	local force = {}
	force[0] = 10
	force[1] = 50
	force[2] = 1000
	local blackhole_force = force[1]

	__options.bool["BlackHoleOnVehicles"] = ui.add_bool_option(TRANSLATION['On vehicles'], __submenus["BlackHole"], function(bool) on_vehs = bool
		settings.World["BlackHoleOnVehicles"] = bool
	end)
	__options.bool["BlackHoleOnPeds"] = ui.add_bool_option(TRANSLATION['On peds'], __submenus["BlackHole"], function(bool) on_peds = bool	
		settings.World["BlackHoleOnPeds"] = bool
	end)
	__options.bool["BlackHoleOnObjects"] = ui.add_bool_option(TRANSLATION['On objects'], __submenus["BlackHole"], function(bool) on_obj = bool	
		settings.World["BlackHoleOnObjects"] = bool
	end)

	__options.choose["BlackHoleForce"] = ui.add_choose(TRANSLATION['Force'], __submenus["BlackHole"], true, force_types, function(int) blackhole_force = force[int] 
		settings.World["BlackHoleForce"] = int
	end)

	ui.add_click_option(TRANSLATION['Bring to self'], __submenus["BlackHole"], function() blackhole_pos = vector3(features.get_player_coords()) + vector3.up() * 10 end)

	__options.bool['AttackBlHole'] = ui.add_bool_option(TRANSLATION['Attach to self'], __submenus["BlackHole"], function(bool) 
		CreateRemoveThread(bool, 'world_attach_blackhole', function()
			blackhole_pos = vector3(features.get_player_coords())
		end)
	end)

	local x = ui.add_num_option('X', __submenus["BlackHole"], -100000, 100000, 10, function(int) blackhole_pos.x = int end)
	local y = ui.add_num_option('Y', __submenus["BlackHole"], -100000, 100000, 10, function(int) blackhole_pos.y = int end)
	local z = ui.add_num_option('Z', __submenus["BlackHole"], -100000, 100000, 10, function(int) blackhole_pos.z = int end)

	__options.num["BlackHoleDistance"] = ui.add_num_option(TRANSLATION['Distance'], __submenus["BlackHole"], 0, 100000, 10, function(int) blackhole_dist = int
		settings.World["BlackHoleDistance"] = int
	end)

	CreateRemoveThread(true, 'world_black_hole_position', function(tick)
		ui.set_value(x, blackhole_pos.x, true)
		ui.set_value(y, blackhole_pos.y, true)
		ui.set_value(z, blackhole_pos.z, true)
		ui.set_value(x, blackhole_pos.x, false)
		ui.set_value(y, blackhole_pos.y, false)
		ui.set_value(z, blackhole_pos.z, false)
	end)

	__options.bool['BlackHoleSuckIn'] = ui.add_bool_option(TRANSLATION['Suck in'], __submenus["BlackHole"], function(bool) settings.World["BlackHoleSuckIn"] = bool end)
	__options.bool['ShowBlackHole'] = ui.add_bool_option(TRANSLATION['Show blackhole'], __submenus["BlackHole"], function(bool) settings.World["ShowBlackHole"] = bool end)

	__options.bool['BlackHole'] = ui.add_bool_option(TRANSLATION['Enable blackhole'], __submenus["BlackHole"], function(bool)
		CreateRemoveThread(bool, 'world_black_hole', function()
			local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
			if settings.World["ShowBlackHole"] then
				GRAPHICS._DRAW_SPHERE(blackhole_pos.x, blackhole_pos.y, blackhole_pos.z, 6, 0, 0, 0, 1)
			end
			for _, v in ipairs(features.get_entities())
			do
				if ((ENTITY.IS_ENTITY_A_PED(v) == 1 and on_peds) or (ENTITY.IS_ENTITY_A_VEHICLE(v) == 1 and on_vehs) or (ENTITY.IS_ENTITY_AN_OBJECT(v) == 1 and on_obj)) and PED.IS_PED_A_PLAYER(v) == NULL then
					local pos = vector3(ENTITY.GET_ENTITY_COORDS(v, false))
					local distance = pos:sqrlen(blackhole_pos)
					if distance <= math.pow(blackhole_dist, 2) then
						if not ((v == veh1 or v == veh2) and ENTITY.IS_ENTITY_A_VEHICLE(v) == 1) then
							features.request_control_once(v)
							if ENTITY.IS_ENTITY_A_PED(v) == 1 and PED.IS_PED_A_PLAYER(v) == NULL then
								PED.SET_PED_TO_RAGDOLL(v, 5000, 5000, 0, true, true, false)
							end
							if distance > 36 then
								pos = vector3(ENTITY.GET_ENTITY_COORDS(v, false))
								local dir = pos:direction_to(blackhole_pos) * blackhole_force
								ENTITY.FREEZE_ENTITY_POSITION(v, false)
								ENTITY.SET_ENTITY_VELOCITY(v, dir.x, dir.y, dir.z)
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
				local pos = vector3(ENTITY.GET_ENTITY_COORDS(v, false))
				local distance = pos:sqrlen(blackhole_pos)
				if distance <= math.pow(blackhole_dist, 2) then
					if ENTITY.IS_ENTITY_A_VEHICLE(v) == 1 and v ~= veh1 and v ~= veh2 and v ~= PLAYER.PLAYER_PED_ID() then
						features.request_control_once(v)
						if distance <= 100 then
							ENTITY.FREEZE_ENTITY_POSITION(v, false)
							local pos = vector3(ENTITY.GET_ENTITY_COORDS(v, false))
							local dir = blackhole_pos:direction_to(pos) * 100
							ENTITY.SET_ENTITY_VELOCITY(v, dir.x, dir.y, dir.z)
						end
					end
				end
			end
		end
	end)
end

__submenus["Peds"] = ui.add_submenu(TRANSLATION["Peds"])
__suboptions["Peds"] = ui.add_sub_option(TRANSLATION["Peds"], __submenus["World"] , __submenus["Peds"])

ui.add_click_option(TRANSLATION["Resurrect peds"], __submenus["Peds"], function()
	for _, v in ipairs(entities.get_peds())
	do
		if ENTITY.IS_ENTITY_DEAD(v, false) == 1 and v ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(v) == NULL then
			RevivePed(v)
		end
	end
end)

ui.add_click_option(TRANSLATION["Explode peds"], __submenus["Peds"], function()
	for _, v in ipairs(entities.get_peds())
	do
		if ENTITY.IS_ENTITY_DEAD(v, false) == NULL and v ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(v) == NULL then
			local pos = ENTITY.GET_ENTITY_COORDS(v, false)
			FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, enum.explosion.ROCKET, 10, true, false, 1.0, false)
		end
	end
end)

__options.bool["FreezePeds"] = ui.add_bool_option(TRANSLATION["Freeze peds"], __submenus["Peds"], function(bool)
	CreateRemoveThread(bool, 'freeze_peds', function()
		for _, v in ipairs(entities.get_peds())
		do
			if v ~= PLAYER.PLAYER_PED_ID() and PED.IS_PED_A_PLAYER(v) == NULL then
				TASK.CLEAR_PED_TASKS_IMMEDIATELY(v)
			end
		end
	end)
end)

__submenus["Vehicles"] = ui.add_submenu(TRANSLATION["Vehicles"])
__suboptions["Vehicles"] = ui.add_sub_option(TRANSLATION["Vehicles"], __submenus["World"] , __submenus["Vehicles"])

ui.add_click_option(TRANSLATION["Repair vehicles"], __submenus["Vehicles"], function()
	local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
	features.request_control_of_entities(entities.get_vehs())
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
	local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
	features.request_control_of_entities(entities.get_vehs())
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

__options.bool['Beyblades'] = ui.add_bool_option(TRANSLATION["Beyblades"], __submenus["Vehicles"], function(bool)
	CreateRemoveThread(bool, 'world_beyblades', function()
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		features.request_control_of_entities(entities.get_vehs())
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 then
				VEHICLE.SET_VEHICLE_REDUCE_GRIP(v, true)
				ENTITY.APPLY_FORCE_TO_ENTITY(v, 1, 1, 0, 0, 100, 100, 0, 0, true, true, true, false, true)
			end
		end
	end)
	if not bool then
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		features.request_control_of_entities(entities.get_vehs())
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

__options.bool['JumpyVehicles'] = ui.add_bool_option(TRANSLATION["Jumpy vehicles"], __submenus["Vehicles"], function(bool)
	CreateRemoveThread(bool, 'world_jumpy_vehicles', function(tick)
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		features.request_control_of_entities(entities.get_vehs())
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 then
				if tick%100 == NULL then
					local force_type = math.random(1, 5)
					if force_type == 1 then
						ENTITY.APPLY_FORCE_TO_ENTITY(v, 1, 0, 0, 1, 3, 0, 0, 0, true, true, true, false, true)
					elseif force_type == 2 then
						ENTITY.APPLY_FORCE_TO_ENTITY(v, 1, 0, 0, 1, -3, 0, 0, 0, true, true, true, false, true)
					elseif force_type == 3 then
						ENTITY.APPLY_FORCE_TO_ENTITY(v, 1, 0, 0, 1, 0, -7, 0, 0, true, true, true, false, true)
					elseif force_type == 4 then
						ENTITY.APPLY_FORCE_TO_ENTITY(v, 1, 0, 0, 1, 0, 7, 0, 0, true, true, true, false, true)
					elseif force_type == 5 then
						ENTITY.APPLY_FORCE_TO_ENTITY(v, 1, 0, 0, 5, 0, 0, 0, 0, true, true, true, false, true)
					end
				end
			end
		end
	end)
end)

__options.bool['VehiclesExplodeOnImpact'] = ui.add_bool_option(TRANSLATION["Vehicles explode on impact"], __submenus["Vehicles"], function(bool)
	CreateRemoveThread(bool, 'vehicles_explode_on_impact', function(tick)
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 then
				if ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(v) ~= NULL then
					entities.request_control(v, function()
						local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(v)
						vehicles.set_godmode(v, false)
						NETWORK.NETWORK_EXPLODE_VEHICLE(v, true, false, netId)
					end)
				end
			end
		end
	end)
end)

__options.bool['LaunchVehicles'] = ui.add_bool_option(TRANSLATION["Launch vehicles"], __submenus["Vehicles"], function(bool)
	CreateRemoveThread(bool, 'world_launch_vehicles', function(tick)
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		features.request_control_of_entities(entities.get_vehs())
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 then
				ENTITY.FREEZE_ENTITY_POSITION(v, false)
				ENTITY.SET_ENTITY_VELOCITY(v, 0, 0, 100)
			end
		end
	end)
end)

__options.bool['HornHavoc'] = ui.add_bool_option(TRANSLATION["Horn havoc"], __submenus["Vehicles"], function(bool)
	CreateRemoveThread(bool, 'world_horn_havoc', function(tick)
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		features.request_control_of_entities(entities.get_vehs())
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 then
				VEHICLE.START_VEHICLE_HORN(v, 3000, 0, false)
			end
		end
	end)
end)

__options.bool['HornBoosting'] = ui.add_bool_option(TRANSLATION["Horn boosting"], __submenus["Vehicles"], function(bool)
	CreateRemoveThread(bool, 'world_horn_boosting', function(tick)
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 then
				if AUDIO.IS_HORN_ACTIVE(v) == 1 then
					entities.request_control(v, function()
						local speed = ENTITY.GET_ENTITY_SPEED(v)
						VEHICLE.SET_VEHICLE_FORWARD_SPEED(v, speed + speed * .05 + 1)
					end)
				end
			end
		end
	end)
end)

do
	local spawned
	local ufo
	local ufo_position = vector3.zero()
	__options.bool["UFO"] = ui.add_bool_option(TRANSLATION["UFO invasion"], __submenus["World"], function(bool)
		if not spawned then
			ufo_position = vector3(features.get_offset_from_player_coords(vector3(0, 300, 200)))
		end

		if not bool and ufo then
			local out_pos = vector3(ufo_position.x + 1000, ufo_position.y, ufo_position.z + 1000)
			CreateRemoveThread(true, 'world_ufo_delete', function()
				features.request_control_of_entities(features.get_entities())
				if ENTITY.DOES_ENTITY_EXIST(ufo) == NULL then ufo = nil spawned = nil return POP_THREAD end
				local pos = vector3(ENTITY.GET_ENTITY_COORDS(ufo, false))
				if pos:sqrlen(out_pos) > 100 then 
					local move = pos:move_towards(out_pos, 50)
					entities.request_control(ufo, function()
						ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ufo, move.x, move.y, move.z, false, false, false)
					end)
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
			local pos = vector3(features.get_offset_from_player_coords(vector3(0, 200, 0)))
			if not ufo then 
				local loaded, hash = features.request_model(utils.joaat('p_spinning_anus_s'), false)
				if loaded == NULL then return end
				if not spawned then 
					pos = vector3(pos.x + 1000, pos.y, pos.z + 1000) 
				else
					pos = ufo_position
				end
				ufo = features.create_object(hash, pos)
				spawned = true
			end
			if ENTITY.DOES_ENTITY_EXIST(ufo) == NULL then ufo = nil return end
			ENTITY.SET_ENTITY_LOD_DIST(ufo, 0xFFFF)
			local pos2 = vector3(ENTITY.GET_ENTITY_COORDS(ufo, false))
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
			
			local me, veh1, veh2 = PLAYER.PLAYER_PED_ID(), vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
			features.request_control_of_entities(features.get_entities())
			for _, v in ipairs(features.get_entities())
			do
				if v ~= me and v ~= veh1 and v ~= veh2 and v ~= ufo then
						local ent_pos = vector3(ENTITY.GET_ENTITY_COORDS(v, false))
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
							ENTITY.SET_ENTITY_VELOCITY(v, 0, 0, 40)
							if ent_pos.z < ufo_position.z and ent_pos.z >= ufo_position.z - 10 then
								features.delete_entity(v)
							end
						elseif ent_pos.z < ufo_position.z - 30 then
							local pos_to = ent_pos:direction_to(ufo_position) * 100
							ENTITY.FREEZE_ENTITY_POSITION(v, false)
							ENTITY.SET_ENTITY_VELOCITY(v, pos_to.x, pos_to.y, 10)
						end
				end
			end
			
			entities.request_control(ufo, function()
				local rot = ENTITY.GET_ENTITY_ROTATION(ufo, 2)
				ENTITY.SET_ENTITY_ROTATION(ufo, rot.x, rot.y, rot.z + 1, 2, true)
				ENTITY.FREEZE_ENTITY_POSITION(ufo, true)
				ENTITY.SET_ENTITY_COLLISION(ufo, false, true)
			end)

		end)
	end)
end

do
	local distance, force, angle = 100, 30, -80
	__options.num["TornadoSize"] = ui.add_num_option(TRANSLATION["Tornado size"], __submenus["World"], 1, 6, 1, function(int) settings.World["TornadoSize"] = int 
		if int == 1 then
			distance, force, angle = 100, 30, -80
		elseif int == 2 then
			distance, force, angle = 300, 50, -83
		elseif int == 3 then
			distance, force, angle = 500, 70, -85
		elseif int == 4 then
			distance, force, angle = 1000, 90, -90
		elseif int == 5 then
			distance, force, angle = 2000, 100, -100
		elseif int == 6 then
			distance, force, angle = 10000, 1000, -150
		end
	end)

	__options.bool['Tornado'] = ui.add_bool_option(TRANSLATION["Tornado"], __submenus["World"], function(bool)
		local tornado_pos = vector3(features.get_offset_from_player_coords(vector3.forward() * 20))
		CreateRemoveThread(bool, 'world_tornado', function()
			local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
			local sqrdistance = math.pow(distance, 2)
			features.request_control_of_entities(features.get_entities())
			for _, v in ipairs(features.get_entities())
			do
				if v ~= veh1 and v ~= veh2 and PED.IS_PED_A_PLAYER(v) == NULL then
					local pos = vector3(ENTITY.GET_ENTITY_COORDS(v, false))
					if pos:sqrlen(tornado_pos) <= sqrdistance then
						if ENTITY.IS_ENTITY_A_PED(v) == 1 then
							PED.SET_PED_TO_RAGDOLL(v, 5000, 5000, 0, true, true, false)
						end
						pos = vector3(ENTITY.GET_ENTITY_COORDS(v, false))
						local offset = vector3.point_on_circle(pos:direction_to(tornado_pos):angle() + math.rad(angle), 100)
						local final_pos = pos:direction_to(tornado_pos+offset) * force
						ENTITY.FREEZE_ENTITY_POSITION(v, false)
						ENTITY.SET_ENTITY_VELOCITY(v, final_pos.x, final_pos.y, .3)
					end
				end
			end
		end)
	end)
end

__options.bool['DisablePedSpawn'] = ui.add_bool_option(TRANSLATION["Disable ped spawn"], __submenus["World"], function(bool)
	settings.World['DisablePedSpawn'] = bool
	CreateRemoveThread(bool, 'world_disable_peds', function(tick)
		PED.SET_PED_DENSITY_MULTIPLIER_THIS_FRAME(0)
	end)
end)

__options.bool['DisableVehicleSpawn'] = ui.add_bool_option(TRANSLATION["Disable vehicle spawn"], __submenus["World"], function(bool)
	settings.World['DisableVehicleSpawn'] = bool
	CreateRemoveThread(bool, 'world_disable_vehicles', function(tick)
	 	VEHICLE.SET_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME(0)
    VEHICLE.SET_PARKED_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME(0)
    VEHICLE.SET_RANDOM_VEHICLE_DENSITY_MULTIPLIER_THIS_FRAME(0)
    VEHICLE.SET_AMBIENT_VEHICLE_RANGE_MULTIPLIER_THIS_FRAME(0)
	end)
end)

do
	local scaler = 0
	opt = ui.add_num_option(TRANSLATION["Set waves height"], __submenus["World"], -1000, 1000, 1, function(int)
		WATER.SET_DEEP_OCEAN_SCALER(int/100)
	end)
	CreateRemoveThread(true, 'world_get_waves_intensity', function()
		scaler = WATER.GET_DEEP_OCEAN_SCALER()
		ui.set_value(opt, math.floor(scaler * 100), true)
	end)
end

do
	local scaler = 0
	opt = ui.add_num_option(TRANSLATION["Set rain level"], __submenus["World"], -100, 50, 1, function(int)
		MISC._SET_RAIN_LEVEL(int/100)
	end)
	CreateRemoveThread(true, 'world_get_rain_intensity', function()
		scaler = MISC.GET_RAIN_LEVEL()
		ui.set_value(opt, math.floor(scaler * 100), true)
	end)
end

do
	local scaler = 0
	opt = ui.add_num_option(TRANSLATION["Set wind speed"], __submenus["World"], -100, 100, 1, function(int)
		MISC.SET_WIND_SPEED(int/100)
	end)
	CreateRemoveThread(true, 'world_get_wind_intensity', function()
		scaler = MISC.GET_WIND_SPEED()
		ui.set_value(opt, math.floor(scaler * 100), true)
	end)
end

---------------------------------------------------------------------------------------------------------------------------------
-- Teleport
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'teleport submenu') end
__submenus["Teleport"] = ui.add_submenu(TRANSLATION["Teleport"])
__suboptions["Teleport"] = ui.add_sub_option(TRANSLATION["Teleport"], main_submenu, __submenus["Teleport"])

ui.add_click_option(TRANSLATION['Teleport to objective'], __submenus["Teleport"], function()
	local pos = features.get_blip_objective()
	if not (pos == vector3.zero()) then
		features.teleport(PLAYER.PLAYER_PED_ID(), pos.x, pos.y, pos.z)
	end
end)

ui.add_click_option(TRANSLATION['Teleport to waypoint'], __submenus["Teleport"], function()
	if HUD.IS_WAYPOINT_ACTIVE() == NULL then system.notify(TRANSLATION['Info'], TRANSLATION["No waypoint has been set"], 255, 255, 0, 255) return end
	local coords = vector3(HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8)))
	local entity = PLAYER.PLAYER_PED_ID()
	if ENTITY.IS_ENTITY_A_PED(entity) == 1 then
		if PED.IS_PED_IN_ANY_VEHICLE(entity, true) == 1 then
			entity = PED.GET_VEHICLE_PED_IS_IN(entity, false)
		end
	end
  local groundZ
	local z
	for i = 0, 100
	do
		local testZ = (i * 10.0) - 100.0
		features.teleport(entity, coords.x, coords.y, testZ)
		system.yield()
		local ptr = memory.malloc(104)
		MISC.GET_GROUND_Z_FOR_3D_COORD(coords.x, coords.y, testZ, ptr, true, true)
		groundZ = memory.read_float(ptr)
		memory.free(ptr)
		if groundZ ~= NULL then
			break
		end
	end
	if groundZ ~= NULL then
		z = groundZ
	else
		z = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false).z
	end
	features.teleport(entity, coords.x, coords.y, z)
end)

__options.num['TpForwardDist'] = ui.add_num_option(TRANSLATION["Distance"], __submenus["Teleport"], 1, 50, 1, function(int) settings.Teleport['TpForwardDist'] = int end)
ui.add_click_option(TRANSLATION['Teleport Forward'], __submenus["Teleport"], function()
	local pos = vector3(ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.PLAYER_PED_ID(), 0, settings.Teleport['TpForwardDist'], 0))
	features.teleport(PLAYER.PLAYER_PED_ID(), pos.x, pos.y, pos.z)
end)

ui.add_separator(TRANSLATION['Input coords'], __submenus["Teleport"])

do
	local tp = vector3.zero()
	ui.add_num_option('X', __submenus["Teleport"], -10000, 10000, 1, function(int) tp.x = int end)
	ui.add_num_option('Y', __submenus["Teleport"], -10000, 10000, 1, function(int) tp.y = int end)
	ui.add_num_option('Z', __submenus["Teleport"], -10000, 10000, 1, function(int) tp.z = int end)
	ui.add_click_option(TRANSLATION['Teleport'], __submenus["Teleport"], function()
		features.teleport(PLAYER.PLAYER_PED_ID(), tp.x, tp.y, tp.z)
	end)
end

ui.add_click_option(TRANSLATION['Log position'], __submenus["Teleport"], function()
	system.log('My position', tostring(vector3(features.get_player_coords())))
end)

---------------------------------------------------------------------------------------------------------------------------------
-- Weapons
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'weapons submenu') end
__submenus["Weapons"] = ui.add_submenu(TRANSLATION["Weapons"])
__suboptions["Weapons"] = ui.add_sub_option(TRANSLATION["Weapons"], main_submenu, __submenus["Weapons"])

__submenus["AimAssist"] = ui.add_submenu(TRANSLATION["Aim assist"])
__suboptions["Weapons"] = ui.add_sub_option(TRANSLATION["Aim assist"], __submenus["Weapons"], __submenus["AimAssist"])

ui.add_separator(TRANSLATION["Targets"], __submenus["AimAssist"])

__options.bool["TargetPeds"] = ui.add_bool_option(TRANSLATION['Target NPCs'], __submenus["AimAssist"], function(bool) settings.Weapons["TargetPeds"] = bool end)
__options.bool["TargetPlayers"] = ui.add_bool_option(TRANSLATION['Target players'], __submenus["AimAssist"], function(bool) settings.Weapons["TargetPlayers"] = bool end)
__options.bool["TargetEnemies"] = ui.add_bool_option(TRANSLATION['Target enemies'], __submenus["AimAssist"], function(bool) settings.Weapons["TargetEnemies"] = bool end)
__options.bool["TargetCops"] = ui.add_bool_option(TRANSLATION['Target cops'], __submenus["AimAssist"], function(bool) settings.Weapons["TargetCops"] = bool end)

do
	local bone_id = {
		[0] = 0x796e,
		[1] = 0x9995,
		[2] = 0xe0fd,
		[3] = 0x3fcf
	}
	__options.choose["AimBone"] = ui.add_choose(TRANSLATION['Bone'], __submenus["AimAssist"], true, {TRANSLATION["Head"], TRANSLATION["Neck"], TRANSLATION["Spine"], TRANSLATION["Knee"]}, function(int) settings.Weapons["AimBone"] = int end)

	ui.add_separator(TRANSLATION["Assistance"], __submenus["AimAssist"])

	__options.bool["Triggerbot"] = ui.add_bool_option(TRANSLATION['Triggerbot'], __submenus["AimAssist"], function(bool) 
		settings.Weapons["Triggerbot"] = bool 
		CreateRemoveThread(bool, "weapons_trigger",
		function()	
			if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 and ENTITY.IS_ENTITY_DEAD(PLAYER.PLAYER_PED_ID(), false) == NULL then
				local entity = features.get_aimed_ped()
				if entity == NULL then return end
				if ENTITY.IS_ENTITY_A_PED(entity) == 1 and ENTITY.IS_ENTITY_DEAD(entity, false) == NULL and not (settings.General['Exclude Friends'] and features.is_friend(features.get_player_from_ped(v))) and not features.is_excluded(features.get_player_from_ped(v)) then
					local triggered
					if settings.Weapons["TargetPlayers"] and PED.IS_PED_A_PLAYER(entity) == 1 then
						triggered = true
					end
					if settings.Weapons["TargetEnemies"] and peds.is_ped_an_enemy(entity) then
						triggered = true
					end
					if settings.Weapons["TargetCops"] and (PED.GET_PED_TYPE(entity) == 6 or PED.GET_PED_TYPE(entity) == 27) then
						triggered = true
					end
					if triggered or settings.Weapons["TargetPeds"] then
						-- PAD._SET_CONTROL_NORMAL(0, enum.input.ATTACK, 1)

						local coord = vector3(ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(entity, PED.GET_PED_BONE_INDEX(entity, bone_id[settings.Weapons["AimBone"]])))
						if not (coord == vector3.zero()) then
							if PED.IS_PED_IN_ANY_VEHICLE(entity, false) == 1 then
								coord.z = coord.z + .08
							end
							PED.SET_PED_SHOOTS_AT_COORD(PLAYER.PLAYER_PED_ID(), coord.x, coord.y, coord.z, true)
						end
					end
				end
			end
		end)
	end)

	ui.add_separator(TRANSLATION["Aimbot"], __submenus["AimAssist"])

	__options.num["AimbotDistance"] = ui.add_num_option(TRANSLATION["Distance"], __submenus["AimAssist"], 10, 1500, 10, function(int) settings.Weapons["AimbotDistance"] = int end)

	__options.bool["Aimbot"] = ui.add_bool_option(TRANSLATION['Aimbot'], __submenus["AimAssist"], function(bool) 
		settings.Weapons["Aimbot"] = bool 
		CreateRemoveThread(bool, "weapons_aimbot",
		function()	
			if ENTITY.IS_ENTITY_DEAD(PLAYER.PLAYER_PED_ID(), false) == NULL then
				local pos = vector3(features.get_player_coords())
				local entity
				local distance = (math.pow(settings.Weapons["AimbotDistance"], 2))
				local cam_dir = vector3(CAM.GET_GAMEPLAY_CAM_ROT(2)):rot_to_direction()
				for _, v in ipairs(entities.get_peds())
				do
					if v ~= PLAYER.PLAYER_PED_ID() and ENTITY.IS_ENTITY_DEAD(v, false) == NULL and ENTITY.IS_ENTITY_ON_SCREEN(v) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(features.get_player_from_ped(v))) and not features.is_excluded(features.get_player_from_ped(v)) then
						local triggered
						if settings.Weapons["TargetPlayers"] and PED.IS_PED_A_PLAYER(v) == 1 then
							triggered = true
						end
						if settings.Weapons["TargetEnemies"] and peds.is_ped_an_enemy(v) then
							triggered = true
						end
						if settings.Weapons["TargetCops"] and (PED.GET_PED_TYPE(v) == 6 or PED.GET_PED_TYPE(v) == 27) then
							triggered = true
						end
						local dist = vector3(ENTITY.GET_ENTITY_COORDS(v, false)):sqrlen(pos)
						local dir = pos:direction_to(vector3(ENTITY.GET_ENTITY_COORDS(v, false)))
						if (triggered or settings.Weapons["TargetPeds"]) and dist < distance and dir:sqrlen(cam_dir) <= .005 --[[temporary due to not working memory, change to this->GET_SCREEN_COORD_FROM_WORLD_COORD]] then
							entity = v
							distance = dist
						end
					end
				end
				if entity then
					PAD.DISABLE_CONTROL_ACTION(0, enum.input.ATTACK, true)
					PAD.DISABLE_CONTROL_ACTION(0, enum.input.ATTACK2, true)
					if not (PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.ATTACK) == 1 or PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.ATTACK2) == 1) then return end
					local coord = vector3(ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(entity, PED.GET_PED_BONE_INDEX(entity, bone_id[settings.Weapons["AimBone"]])))
					if not (coord == vector3.zero()) then
						if PED.IS_PED_IN_ANY_VEHICLE(entity, false) == 1 then
							coord.z = coord.z + .08
						end
						PED.SET_PED_SHOOTS_AT_COORD(PLAYER.PLAYER_PED_ID(), coord.x, coord.y, coord.z, true)
					end
				end
			end
		end)
	end)

	__options.bool["AutoShoot"] = ui.add_bool_option(TRANSLATION['Auto shoot'], __submenus["AimAssist"], function(bool) 
		settings.Weapons["AutoShoot"] = bool 
		CreateRemoveThread(bool, "weapons_auto_shoot",
		function()	
			if ENTITY.IS_ENTITY_DEAD(PLAYER.PLAYER_PED_ID(), false) == NULL then
				local pos = vector3(features.get_player_coords())
				local entity
				local distance = math.pow(settings.Weapons["AimbotDistance"], 2)
				for _, v in ipairs(entities.get_peds())
				do
					if v ~= PLAYER.PLAYER_PED_ID() and ENTITY.IS_ENTITY_DEAD(v, false) == NULL and not (settings.General['Exclude Friends'] and features.is_friend(features.get_player_from_ped(v))) and not features.is_excluded(features.get_player_from_ped(v)) then
						local triggered
						if settings.Weapons["TargetPlayers"] and PED.IS_PED_A_PLAYER(v) == 1 then
							triggered = true
						end
						if settings.Weapons["TargetEnemies"] and peds.is_ped_an_enemy(v) then
							triggered = true
						end
						if settings.Weapons["TargetCops"] and (PED.GET_PED_TYPE(v) == 6 or PED.GET_PED_TYPE(v) == 27) then
							triggered = true
						end
						local dist = vector3(ENTITY.GET_ENTITY_COORDS(v, false)):sqrlen(pos)
						if (triggered or settings.Weapons["TargetPeds"]) and dist < distance then
							entity = v
							distance = dist
						end
					end
				end
				if entity then
					local coord = vector3(ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(entity, PED.GET_PED_BONE_INDEX(entity, bone_id[settings.Weapons["AimBone"]])))
						if not (coord == vector3.zero()) then
							if PED.IS_PED_IN_ANY_VEHICLE(entity, false) == 1 then
								coord.z = coord.z + .08
							end
							PED.SET_PED_SHOOTS_AT_COORD(PLAYER.PLAYER_PED_ID(), coord.x, coord.y, coord.z, true)
						end
				end
			end
		end)
	end)

end

__options.bool["RapidFire"] = ui.add_bool_option(TRANSLATION['Rapid fire'], __submenus["Weapons"], function(bool)
	settings.Weapons['RapidFire'] = bool
	CreateRemoveThread(bool, 'rapid_fire',
	function()
		local ptr = memory.malloc(8)
		WEAPON.GET_CURRENT_PED_WEAPON(PLAYER.PLAYER_PED_ID(), ptr, true)
		local weaponhash = memory.read_int(ptr)
		memory.free(ptr)
		if WEAPON.GET_WEAPONTYPE_GROUP(weaponhash) == enum.weapon_group.Melee then
			return
		end
		WEAPON.REQUEST_WEAPON_ASSET(weaponhash, 31, 0)
		if WEAPON.HAS_WEAPON_ASSET_LOADED(weaponhash) == NULL then return end
		PAD.DISABLE_CONTROL_ACTION(0, enum.input.ATTACK, true)
		PAD.DISABLE_CONTROL_ACTION(0, enum.input.ATTACK2, true)
		if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.ATTACK) == 1 then
			local ped = PLAYER.PLAYER_PED_ID()
			local weapo = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(ped, 1)
			local cam_dir = vector3(CAM.GET_GAMEPLAY_CAM_ROT(2)):rot_to_direction()
			local cam_pos = vector3(CAM.GET_GAMEPLAY_CAM_COORD())
			local pos1 = cam_pos + (cam_dir * (cam_pos:len(vector3(ENTITY.GET_ENTITY_COORDS(weapo, false))) + 0.4))
			local pos2 = cam_pos + (cam_dir * 200)
			-- MISC.CLEAR_AREA_OF_PROJECTILES(pos1.x, pos1.y, pos1.z, 6, 0)
			MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z, 5, true, weaponhash, ped, true, true, 24000)
			MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z, 5, true, weaponhash, ped, true, true, 24000)
		end
	end)
end)

__options.bool["DriveGun"] = ui.add_bool_option(TRANSLATION['Drive gun'], __submenus["Weapons"], function(bool)
	settings.Weapons['DriveGun'] = bool
	CreateRemoveThread(bool, 'weapons_drivegun',
	function()
		if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 and PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) == 1 then
			local entity = features.get_aimed_entity()
			if entity == NULL then return end
			local veh
			local ped
			if ENTITY.IS_ENTITY_A_PED(entity) == 1 then
				veh = PED.GET_VEHICLE_PED_IS_IN(entity, false)
				ped = entity
			elseif ENTITY.IS_ENTITY_A_VEHICLE(entity) == 1 then
				veh = entity
			end
			if veh then
				if veh == created_preview then return end
				CreateRemoveThread(true, 'seat_change_'..thread_count, function(tick)
					if tick == 100 then return POP_THREAD end
					if ped and ped ~= PLAYER.PLAYER_PED_ID() and veh ~= NULL then
						TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
					end
					features.request_control_once(veh) 
					PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
					if VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, true) ~= PLAYER.PLAYER_PED_ID() then return end
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
	__options.bool["PickUpGun"] = ui.add_bool_option(TRANSLATION['Pick up gun'], __submenus["Weapons"], function(bool)
		settings.Weapons['PickUpGun'] = bool
		CreateRemoveThread(bool, 'weapons_pickup_gun',
		function()
			if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 then
				if not entity then
					entity = features.get_aimed_entity()
					if entity == NULL then entity = nil return end
					if ENTITY.IS_ENTITY_A_PED(entity) == 1 and PED.IS_PED_IN_ANY_VEHICLE(entity, true) == 1 then
						entity = PED.GET_VEHICLE_PED_IS_IN(entity, false)
					end
					local pos = vector3(CAM.GET_GAMEPLAY_CAM_COORD())
					distance = pos:len(vector3(ENTITY.GET_ENTITY_COORDS(entity, false)))
				end
				if gunactive then return end
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
        local rot = ENTITY.GET_ENTITY_ROTATION(entity, 2)
        if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.WEAPON_WHEEL_NEXT) == 1 then
          if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.FRONTEND_RS) == 1 then
              ENTITY.SET_ENTITY_ROTATION(entity, rot.x-1*radmult, rot.y, rot.z, 2, true)
          elseif PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.JUMP) == 1 then
              ENTITY.SET_ENTITY_ROTATION(entity, rot.x, rot.y-1*radmult, rot.z, 2, true)
          elseif PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.MULTIPLAYER_INFO) == 1 then
              ENTITY.SET_ENTITY_ROTATION(entity, rot.x, rot.y, rot.z-1*radmult, 2, true)
          else
              distance = distance - radmult
              if distance < 5 then distance = 5 end
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
        local dir = vector3(CAM.GET_GAMEPLAY_CAM_ROT(2)):rot_to_direction()
				local camcoord = vector3(CAM.GET_GAMEPLAY_CAM_COORD())
				local target_pos = camcoord + dir * distance
				ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entity, target_pos.x, target_pos.y, target_pos.z, false, false, false)
				if PAD.IS_CONTROL_JUST_PRESSED(0, enum.input.ATTACK2) == 1 then
					if ENTITY.IS_ENTITY_A_PED(entity) == 1 then
						PED.SET_PED_TO_RAGDOLL(entity, 5000, 5000, 0, true, true, false)
					end
					local force = dir * 500
					ENTITY.FREEZE_ENTITY_POSITION(entity, false)
          ENTITY.SET_ENTITY_VELOCITY(entity, force.x, force.y, force.z)
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
	__options.bool["GravityGun"] = ui.add_bool_option(TRANSLATION['Gravity gun'], __submenus["Weapons"], function(bool)
		settings.Weapons['GravityGun'] = bool
		CreateRemoveThread(bool, 'weapons_gravity_gun',
		function()
			if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 then
				if not entity then
					entity = features.get_aimed_entity()
					if entity == NULL then entity = nil return end
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
        local dir = vector3(CAM.GET_GAMEPLAY_CAM_ROT(2)):rot_to_direction()
				local camcoord = vector3(CAM.GET_GAMEPLAY_CAM_COORD())
				local target_pos = camcoord + dir * distance
				GRAPHICS._DRAW_SPHERE(target_pos.x, target_pos.y, target_pos.z, 0.2, 255, 0, 255, 0.5)
				local pos = vector3(ENTITY.GET_ENTITY_COORDS(entity, false))
				local force_to = (target_pos - pos) * 3
				ENTITY.FREEZE_ENTITY_POSITION(entity, false)
				features.request_control_once(entity)
				ENTITY.SET_ENTITY_VELOCITY(entity, force_to.x, force_to.y, force_to.z)
				if PAD.IS_CONTROL_JUST_PRESSED(0, enum.input.ATTACK2) == 1 then
					if ENTITY.IS_ENTITY_A_PED(entity) == 1 then
						PED.SET_PED_TO_RAGDOLL(entity, 5000, 5000, 0, true, true, false)
					end
					local force = dir * 500
					entities.request_control(entity, function()
						ENTITY.FREEZE_ENTITY_POSITION(entity, false)
	          ENTITY.SET_ENTITY_VELOCITY(entity, force.x, force.y, force.z)
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

__options.bool["PTFXGun"] = ui.add_bool_option(TRANSLATION["Particle FX gun"], __submenus["Weapons"], function(bool)
	settings.Weapons["PTFXGun"] = bool
	CreateRemoveThread(bool, 'weapons_ptfx_gun', function()
		if STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("scr_rcbarry2") == NULL then
			STREAMING.REQUEST_NAMED_PTFX_ASSET("scr_rcbarry2")
			return
		end
		if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) == NULL then return end
		local weapon = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(PLAYER.PLAYER_PED_ID(), false)
		GRAPHICS.USE_PARTICLE_FX_ASSET("scr_rcbarry2")
		GRAPHICS._START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY_BONE("muz_clown", weapon, 0, 0, 0, 90, 0, 0, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(weapon, "gun_muzzle"), .5, false, false, false)
	end)
end)

do
	__options.num["FlamethrowerScale"] = ui.add_num_option(TRANSLATION["Flamethrower scale"], __submenus["Weapons"], 1, 25, 1, function(int) settings.Weapons["FlamethrowerScale"] = int end)
	__options.choose["Flamethrower"] = ui.add_choose(TRANSLATION["Flamethrower"], __submenus["Weapons"], true, {TRANSLATION["None"], TRANSLATION["Orange"], TRANSLATION["Green"]}, function(int) settings.Weapons["Flamethrower"] = int end)
	local type = settings.Weapons["Flamethrower"]
	local flame
	local chip
	CreateRemoveThread(true, 'weapons_flamethrower', function() 
		if settings.Weapons["FlamethrowerScale"] == NULL then
			if flame then
				GRAPHICS.REMOVE_PARTICLE_FX(flame, true)
	      flame = nil
	      features.delete_entity(chip)
	      chip = nil
	    end
      return
		end
		if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 then
      if STREAMING.HAS_NAMED_PTFX_ASSET_LOADED("weap_xs_vehicle_weapons") == NULL then
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
      local pos_h = PED.GET_PED_BONE_COORDS(PLAYER.PLAYER_PED_ID(), 57005, 0, 0, 0)
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
    if (flame and PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == NULL) or (flame and type ~= settings.Weapons["Flamethrower"] and PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1) then
      GRAPHICS.REMOVE_PARTICLE_FX(flame, true)
      flame = nil
      features.delete_entity(chip)
      chip = nil
    end
	end)
end

do
	local vehs = {
		TRANSLATION['None']
	}
	for _, v in ipairs(vehicles.models) do
		table.insert(vehs, v[3])
	end

	local curr_model
	local spawned_vehs = {}
	__options.choose["VehicleGun"] = ui.add_choose(TRANSLATION["Vehicle gun"], __submenus["Weapons"], false, vehs, function(int) settings.Weapons["VehicleGun"] = int end)

	ui.add_click_option(TRANSLATION["Disable vehicle gun"], __submenus["Weapons"], function() ui.set_value(__options.choose["VehicleGun"], 0, false) end)

	CreateRemoveThread(true, 'weapons_vehicle_gun', function()
		if settings.Weapons["VehicleGun"] == NULL then return end
		local model = settings.Weapons["VehicleGun"]
		if not curr_model then
			if features.request_model(vehicles.models[model][2]) == NULL then return end
			curr_model = model
		elseif curr_model ~= model then
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(vehicles.models[curr_model][2])
			curr_model = nil
			return
		end
		if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) == NULL then return end
		local pos = vector3(features.get_offset_from_player_coords(vector3(0, 2, 1)))
		local rot = vector3(CAM.GET_GAMEPLAY_CAM_ROT(2))
		local dir = rot:rot_to_direction() * 500
		local veh = vehicles.spawn_vehicle(vehicles.models[model][2], pos + vector3.up() * 10)
		entities.request_control(veh, function()
			--vehicles.set_godmode(veh, true)
			ENTITY.SET_ENTITY_ALPHA(veh, 50, false)
			ENTITY.SET_ENTITY_COLLISION(veh, false, true)
			ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh, pos.x, pos.y, pos.z, false, false, false)
			ENTITY.SET_ENTITY_ROTATION(veh, rot.x, rot.y, rot.z, 2, true)
			ENTITY.SET_ENTITY_VELOCITY(veh, dir.x, dir.y, dir.z)
		end)
		spawned_vehs[veh] = os.clock()
	end)

	CreateRemoveThread(true, 'weapons_vehicle_tracker', function()
		for k, v in pairs(spawned_vehs) do
			local waittime = .1
			local class = VEHICLE.GET_VEHICLE_CLASS(k)
			if class == 16 then
				waittime = .3
			end
			if v + 5 < os.clock() then
				features.delete_entity(k)
				spawned_vehs[k] = nil
				return
			end
			entities.request_control(k, function()
				if v + waittime < os.clock() then
					ENTITY.SET_ENTITY_COLLISION(k, true, true)
				end
				if v + .3 < os.clock() then
					ENTITY.SET_ENTITY_ALPHA(k, 255, false)
				elseif v + .2 < os.clock() then
					ENTITY.SET_ENTITY_ALPHA(k, 160, false)
				elseif v + .1 < os.clock() then
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
			ENTITY.SET_ENTITY_VELOCITY(ent, force.x, force.y, force.z)
		end)
	end
	function guns.explode(ent)
		local pos = vector3(ENTITY.GET_ENTITY_COORDS(ent, false))
		if pos == vector3.zero() then return end
		FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, enum.explosion.ROCKET, 10, true, false, 1.0, false)
		if ENTITY.IS_ENTITY_A_VEHICLE(ent) == 1 then
			entities.request_control(ent, function()
				local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(ent)
				vehicles.set_godmode(ent, false)
				NETWORK.NETWORK_EXPLODE_VEHICLE(veh, true, false, netId)
			end)
		end
	end
	function guns.paint(ent)
		if ENTITY.IS_ENTITY_A_VEHICLE(ent) == 1 then
			entities.request_control(ent, function()
				local p = math.random(1, #vehicles.colors)
				VEHICLE.SET_VEHICLE_MOD_KIT(ent, 0)
				VEHICLE.SET_VEHICLE_COLOURS(ent, enum.vehicle_colors["Secret Gold"], enum.vehicle_colors["Secret Gold"])
				VEHICLE.SET_VEHICLE_EXTRA_COLOURS(ent, enum.vehicle_colors["Secret Gold"], enum.vehicle_colors["Secret Gold"])
				VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(ent, vehicles.colors[p][1], vehicles.colors[p][2], vehicles.colors[p][3])
				VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(ent, vehicles.colors[p][1], vehicles.colors[p][2], vehicles.colors[p][3])
		    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(ent, vehicles.colors[p][1], vehicles.colors[p][2], vehicles.colors[p][3])
		    VEHICLE._SET_VEHICLE_NEON_LIGHTS_COLOUR(ent, vehicles.colors[p][1], vehicles.colors[p][2], vehicles.colors[p][3])
			end)
		end
	end
	function guns.revive(ent)
		if ENTITY.IS_ENTITY_A_PED(ent) == 1 and ENTITY.IS_ENTITY_DEAD(ent, false) == 1 then
			RevivePed(ent)
		end
	end

	local action = {TRANSLATION["None"], TRANSLATION["On aim"], TRANSLATION["On shoot"]}

	__options.choose["DeleteGun"] = ui.add_choose(TRANSLATION["Delete gun"], __submenus["Weapons"], true, action, function(int) settings.Weapons["DeleteGun"] = int end)
	__options.choose["PushGun"] = ui.add_choose(TRANSLATION["Push gun"], __submenus["Weapons"], true, action, function(int) settings.Weapons["PushGun"] = int end)
	__options.choose["ExplodeGun"] = ui.add_choose(TRANSLATION["Explode gun"], __submenus["Weapons"], true, action, function(int) settings.Weapons["ExplodeGun"] = int end)
	__options.choose["PaintGun"] = ui.add_choose(TRANSLATION["Paint gun"], __submenus["Weapons"], true, action, function(int) settings.Weapons["PaintGun"] = int end)
	__options.choose["ReviveGun"] = ui.add_choose(TRANSLATION["Revive gun"], __submenus["Weapons"], true, action, function(int) settings.Weapons["ReviveGun"] = int end)

	CreateRemoveThread(true, 'weapons_guns', function()
		if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == NULL and PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) == NULL then return end
		local ent = features.get_aimed_entity()
		if ent == NULL then return end
		if ENTITY.IS_ENTITY_A_PED(ent) == 1 and PED.IS_PED_IN_ANY_VEHICLE(ent, true) == 1 then
			ent = PED.GET_VEHICLE_PED_IS_IN(ent, false)
		end
		local cam_dir = vector3(CAM.GET_GAMEPLAY_CAM_ROT(2)):rot_to_direction()

		if settings.Weapons["ReviveGun"] == 1 then
			guns.revive(ent)
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

		if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) == NULL then return end

		if settings.Weapons["ReviveGun"] == 2 then
			guns.revive(ent)
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
__suboptions["Misc"] = ui.add_sub_option(TRANSLATION["Misc"], main_submenu, __submenus["Misc"])

local train_models = {
    utils.joaat("metrotrain"), utils.joaat("freight"), utils.joaat("freightcar"), utils.joaat("freightcar2"), utils.joaat("freightcont1"), utils.joaat("freightcont2"), utils.joaat("freightgrain"), utils.joaat("tankercar")
}
system.log('Imagined Menu', 'Loading trains')
CreateRemoveThread(true, 'load_trains', function()
	for _, v in ipairs(train_models)
	do
		if features.request_model(v) == NULL then
			return
		end
	end
	system.log('Imagined Menu', 'Trains loaded')
	return POP_THREAD
end)

__submenus["ExcludedPlayers"] = ui.add_submenu(TRANSLATION["Excluded players"])
__suboptions["ExcludedPlayers"] = ui.add_sub_option(TRANSLATION["Excluded players"], __submenus["Misc"], __submenus["ExcludedPlayers"])

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
			__options.excludes[k] = ui.add_click_option(v.name, __submenus["ExcludedPlayers"], function() features.player_excludes[k] = nil;SaveExcludes();system.notify(TRANSLATION["Info"], TRANSLATION["Player removed from excludes"], 0, 255, 0, 225) end)
		end
	end
end)

__submenus["TrainDriver"] = ui.add_submenu(TRANSLATION["Train driver"])
__suboptions["TrainDriver"] = ui.add_sub_option(TRANSLATION["Train driver"], __submenus["Misc"], __submenus["TrainDriver"])

-- do
-- 	local function create_train(variation, pos, direction, inside)
-- 		local train = VEHICLE.CREATE_MISSION_TRAIN(variation, pos.x, pos.y, pos.z, false)
-- 		local carriages = {}
--     for i = 1, 100 do
--         local cart = VEHICLE.GET_TRAIN_CARRIAGE(train, i)
--         if cart == NULL then
--             break
--         end
--         table.insert(carriages, cart)
--     end
--     VEHICLE.SET_TRAIN_CRUISE_SPEED(train, 10)
--     VEHICLE.SET_TRAIN_SPEED(train, 10)
--     if inside then
--     	PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), train, -1)
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
	__options.bool["TrainsAlot"] = ui.add_bool_option(TRANSLATION["Trains alot"], __submenus["TrainDriver"], function(bool)
		settings.Misc['TrainsAlot'] = bool
		if not bool then
			VEHICLE.SET_RANDOM_TRAINS(false)
		end
		CreateRemoveThread(bool, 'misc_trains', function()
			VEHICLE.SET_RANDOM_TRAINS(true)
		end)
	end)

	__options.bool["TrainControl"] = ui.add_bool_option(TRANSLATION["Train control"], __submenus["TrainDriver"], function(bool)
		settings.Misc['TrainControl'] = bool
		if not bool then
			train = nil
		end
		CreateRemoveThread(bool, 'misc_train_driver', function()
				train = vehicles.get_player_vehicle()
				if VEHICLE.IS_THIS_MODEL_A_TRAIN(ENTITY.GET_ENTITY_MODEL(train)) == NULL then train = nil return end
				features.request_control_once(train)
		end)
	end)
	
	CreateRemoveThread(true, 'misc_train_speed', function()
		if settings.Misc['TrainControl'] and not opt and train then
			opt = ui.add_num_option(TRANSLATION["Set speed"], __submenus["TrainDriver"], -999999999, 999999999, 1, function(int)
				if train then
					VEHICLE.SET_TRAIN_CRUISE_SPEED(train, int)
			    VEHICLE.SET_TRAIN_SPEED(train, int)
				end
			end)
			opt2 = ui.add_bool_option(TRANSLATION["Derail"], __submenus["TrainDriver"], function(bool)
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
			-- ui.set_value(opt, math.floor(ENTITY.GET_ENTITY_SPEED(train)), true)
		end
	end)
end

__submenus["Reactions"] = ui.add_submenu(TRANSLATION["Reactions"])
__suboptions["Reactions"] = ui.add_sub_option(TRANSLATION["Reactions"], __submenus["Misc"], __submenus["Reactions"])

ui.add_separator(TRANSLATION["On report"] ,__submenus["Reactions"])

__options.bool["OnReportKick"] = ui.add_bool_option(TRANSLATION["Kick"], __submenus["Reactions"], function(bool) 
	settings.Misc['OnReportKick'] = bool
end)
__options.bool["OnReportCrash"] = ui.add_bool_option(TRANSLATION["Crash"], __submenus["Reactions"], function(bool) 
	settings.Misc['OnReportCrash'] = bool
end)
__options.bool["OnReportSendChat"] = ui.add_bool_option(TRANSLATION["Send chat"], __submenus["Reactions"], function(bool) 
	settings.Misc['OnReportSendChat'] = bool
end)

ui.add_separator(TRANSLATION["On votekick"] ,__submenus["Reactions"])

__options.bool["OnVotekickKick"] = ui.add_bool_option(TRANSLATION["Kick"], __submenus["Reactions"], function(bool) 
	settings.Misc['OnVotekickKick'] = bool
end)
__options.bool["OnVotekickCrash"] = ui.add_bool_option(TRANSLATION["Crash"], __submenus["Reactions"], function(bool) 
	settings.Misc['OnVotekickCrash'] = bool
end)
__options.bool["OnVotekickSendChat"] = ui.add_bool_option(TRANSLATION["Send chat"], __submenus["Reactions"], function(bool) 
	settings.Misc['OnVotekickSendChat'] = bool
end)

__submenus["Crosshair"] = ui.add_submenu(TRANSLATION["Crosshair"])
__suboptions["Crosshair"] = ui.add_sub_option(TRANSLATION["Crosshair"], __submenus["Misc"], __submenus["Crosshair"])

local crosshair_presets = {}
__options.choose["CrosshairPresets"] = ui.add_choose(TRANSLATION["Presets"], __submenus["Crosshair"], false, {TRANSLATION["Default"], TRANSLATION["Dot"], TRANSLATION["Cross"], TRANSLATION["Saved"]}, function(int)
	for _, v in ipairs(crosshair_presets)
	do
		ui.set_value(v.option, v.value[int+1], false)
	end
end)

__options.bool["CrosshairEnable"] = ui.add_bool_option(TRANSLATION["Enable"], __submenus["Crosshair"], function(bool)
	settings.Misc["CrosshairEnable"] = bool
	local dynamic_spacing = 0
	local cooldown
	local delay = 0
	CreateRemoveThread(bool, 'misc_custom_crosshair', function()
		if ui.get_value(__options.bool["FreeCam"]) then return end
		if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) == 1 then delay = os.clock() + 1.35 end
		if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) == 1 and settings.Misc["CrosshairDynamic"] then
			local add = 4
			local ptr = memory.malloc(8)
			WEAPON.GET_CURRENT_PED_WEAPON(PLAYER.PLAYER_PED_ID(), ptr, true)
			local weaponhash = memory.read_int(ptr)
			memory.free(ptr)
			local wreapon_group = WEAPON.GET_WEAPONTYPE_GROUP(weaponhash)
			if wreapon_group == enum.weapon_group.Throwables then
				add = 0
			elseif wreapon_group == enum.weapon_group.Shotgun then
				add = 15
			elseif wreapon_group == enum.weapon_group.Sniper then
				add = 20
			elseif wreapon_group == enum.weapon_group.Heavy_Weapon then
				add = 8
			end
			dynamic_spacing = dynamic_spacing < 20 and dynamic_spacing + add or dynamic_spacing
			cooldown = os.clock() + .5
		elseif cooldown and cooldown < os.clock() then
			dynamic_spacing = dynamic_spacing > 0 and dynamic_spacing - 1 or dynamic_spacing
		end
		if settings.Misc["CrosshairDisableIngame"] then
			HUD.HIDE_HUD_COMPONENT_THIS_FRAME(14)
		end
		if (PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == NULL and PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) == NULL) and not settings.Misc["CrosshairShowAllTime"] and (delay <= os.clock()) then return end
		if delay <= os.clock() then delay = 0 end
		features.draw_crosshair(settings.Misc["CrosshairWidth"], settings.Misc["CrosshairHeight"],
			settings.Misc["CrosshairSpacing"] + dynamic_spacing, settings.Misc["CrosshairThickness"],
			settings.Misc["CrosshairColorR"], settings.Misc["CrosshairColorG"], settings.Misc["CrosshairColorB"], settings.Misc["CrosshairColorA"],
			settings.Misc["CrosshairLeft"], settings.Misc["CrosshairRight"], settings.Misc["CrosshairUp"], settings.Misc["CrosshairDown"], 
			settings.Misc["CrosshairBorderThickness"], settings.Misc["CrosshairBorderColorR"], settings.Misc["CrosshairBorderColorG"], settings.Misc["CrosshairBorderColorB"], settings.Misc["CrosshairBorderColorA"],
			settings.Misc["CrosshairDot"])
	end)
end)
__options.bool["CrosshairLink"] = ui.add_bool_option(TRANSLATION["Link width & height"], __submenus["Crosshair"], function(bool) settings.Misc["CrosshairLink"] = bool end)
__options.num["CrosshairWidth"] = ui.add_num_option(TRANSLATION["Width"], __submenus["Crosshair"], 0, 500, 1, function(int) settings.Misc["CrosshairWidth"] = int  end)
__options.num["CrosshairHeight"] = ui.add_num_option(TRANSLATION["Height"], __submenus["Crosshair"], 0, 500, 1, function(int) settings.Misc["CrosshairHeight"] = int end)
__options.num["CrosshairSpacing"] = ui.add_num_option(TRANSLATION["Spacing"], __submenus["Crosshair"], 0, 500, 1, function(int) settings.Misc["CrosshairSpacing"] = int end)
__options.num["CrosshairThickness"] = ui.add_num_option(TRANSLATION["Thickness"], __submenus["Crosshair"], 0, 300, 2, function(int) settings.Misc["CrosshairThickness"] = int end)
__options.num["CrosshairColorR"] = ui.add_num_option(TRANSLATION["R"], __submenus["Crosshair"], 0, 255, 1, function(int) settings.Misc["CrosshairColorR"] = int end)
__options.num["CrosshairColorG"] = ui.add_num_option(TRANSLATION["G"], __submenus["Crosshair"], 0, 255, 1, function(int) settings.Misc["CrosshairColorG"] = int end)
__options.num["CrosshairColorB"] = ui.add_num_option(TRANSLATION["B"], __submenus["Crosshair"], 0, 255, 1, function(int) settings.Misc["CrosshairColorB"] = int end)
__options.num["CrosshairColorA"] = ui.add_num_option(TRANSLATION["A"], __submenus["Crosshair"], 0, 255, 1, function(int) settings.Misc["CrosshairColorA"] = int end)
__options.bool["CrosshairLeft"] = ui.add_bool_option(TRANSLATION["Left"], __submenus["Crosshair"], function(bool) settings.Misc["CrosshairLeft"] = bool end)
__options.bool["CrosshairRight"] = ui.add_bool_option(TRANSLATION["Right"], __submenus["Crosshair"], function(bool) settings.Misc["CrosshairRight"] = bool end)
__options.bool["CrosshairUp"] = ui.add_bool_option(TRANSLATION["Up"], __submenus["Crosshair"], function(bool) settings.Misc["CrosshairUp"] = bool end)
__options.bool["CrosshairDown"] = ui.add_bool_option(TRANSLATION["Down"], __submenus["Crosshair"], function(bool) settings.Misc["CrosshairDown"] = bool end)
__options.bool["CrosshairDot"] = ui.add_bool_option(TRANSLATION["Dot"], __submenus["Crosshair"], function(bool) settings.Misc["CrosshairDot"] = bool end)
__options.bool["CrosshairDynamic"] = ui.add_bool_option(TRANSLATION["Dynamic"], __submenus["Crosshair"], function(bool) settings.Misc["CrosshairDynamic"] = bool end)
__options.bool["CrosshairShowAllTime"] = ui.add_bool_option(TRANSLATION["Show all time"], __submenus["Crosshair"], function(bool) settings.Misc["CrosshairShowAllTime"] = bool end)
__options.bool["CrosshairDisableIngame"] = ui.add_bool_option(TRANSLATION["Disable in-game crosshair"], __submenus["Crosshair"], function(bool) settings.Misc["CrosshairDisableIngame"] = bool end)
ui.add_separator(TRANSLATION["Borders"], __submenus["Crosshair"])
__options.num["CrosshairBorderThickness"] = ui.add_num_option(TRANSLATION["Thickness"], __submenus["Crosshair"], 0, 100, 1, function(int) settings.Misc["CrosshairBorderThickness"] = int end)
__options.num["CrosshairBorderColorR"] = ui.add_num_option(TRANSLATION["R"], __submenus["Crosshair"], 0, 255, 1, function(int) settings.Misc["CrosshairBorderColorR"] = int end)
__options.num["CrosshairBorderColorG"] = ui.add_num_option(TRANSLATION["G"], __submenus["Crosshair"], 0, 255, 1, function(int) settings.Misc["CrosshairBorderColorG"] = int end)
__options.num["CrosshairBorderColorB"] = ui.add_num_option(TRANSLATION["B"], __submenus["Crosshair"], 0, 255, 1, function(int) settings.Misc["CrosshairBorderColorB"] = int end)
__options.num["CrosshairBorderColorA"] = ui.add_num_option(TRANSLATION["A"], __submenus["Crosshair"], 0, 255, 1, function(int) settings.Misc["CrosshairBorderColorA"] = int end)

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
	{option = __options.num["CrosshairColorR"],
	value = {255, 255, 180, settings.Misc["CrosshairColorR"]}},
	{option = __options.num["CrosshairColorG"],
	value = {0, 255, 255, settings.Misc["CrosshairColorG"]}},
	{option = __options.num["CrosshairColorB"],
	value = {255, 255, 0, settings.Misc["CrosshairColorB"]}},
	{option = __options.num["CrosshairColorA"],
	value = {255, 120, 255, settings.Misc["CrosshairColorA"]}},
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
	{option = __options.num["CrosshairBorderColorR"],
	value = {0, 0, 0, settings.Misc["CrosshairBorderColorR"]}},
	{option = __options.num["CrosshairBorderColorG"],
	value = {0, 0, 0, settings.Misc["CrosshairBorderColorG"]}},
	{option = __options.num["CrosshairBorderColorB"],
	value = {0, 0, 0, settings.Misc["CrosshairBorderColorB"]}},
	{option = __options.num["CrosshairBorderColorA"],
	value = {255, 70, 255, settings.Misc["CrosshairBorderColorA"]}},
	{option = __options.bool["CrosshairDisableIngame"],
	value = {true, true, true, settings.Misc["CrosshairDisableIngame"]}},
	{option = __options.bool["CrosshairShowAllTime"],
	value = {false, true, false, settings.Misc["CrosshairShowAllTime"]}}
}

CreateRemoveThread(true, 'crosshair_link', function()
	if settings.Misc["CrosshairLink"] and ui.get_value(__options.num["CrosshairWidth"]) ~= ui.get_value(__options.num["CrosshairHeight"]) then ui.set_value(__options.num["CrosshairHeight"], ui.get_value(__options.num["CrosshairWidth"]), false) end
	if settings.Misc["CrosshairLink"] and ui.get_value(__options.num["CrosshairWidth"]) ~= ui.get_value(__options.num["CrosshairHeight"]) then ui.set_value(__options.num["CrosshairWidth"], ui.get_value(__options.num["CrosshairHeight"]), false) end
end)

__options.bool["LogChat"] = ui.add_bool_option(TRANSLATION["Log chat"], __submenus["Misc"], function(bool)
	settings.Misc["LogChat"] = bool
end)

__options.bool["LockGameplayCam"] = ui.add_bool_option(TRANSLATION["Lock gameplay cam"], __submenus["Misc"], function(bool) 
	settings.Misc['LockGameplayCam'] = bool
	CreateRemoveThread(bool, 'misc_lock_camera',
	function(tick)
		if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 or PAD.GET_CONTROL_NORMAL(0, enum.input.LOOK_LR) ~= NULL or PAD.GET_CONTROL_NORMAL(0, enum.input.LOOK_UD) ~= NULL then return end
		CAM.SET_GAMEPLAY_CAM_RELATIVE_HEADING(0)
	end)
end)

__options.bool["DisableCamCenter"] = ui.add_bool_option(TRANSLATION["Disable cam centering"], __submenus["Misc"], function(bool) 
	settings.Misc['DisableCamCenter'] = bool
	local h = CAM.GET_GAMEPLAY_CAM_RELATIVE_HEADING()
	local p = CAM.GET_GAMEPLAY_CAM_RELATIVE_PITCH()
	CreateRemoveThread(bool, 'misc_disable_cam_center',
	function(tick)
		if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == 1 or PAD.GET_CONTROL_NORMAL(0, enum.input.LOOK_LR) ~= NULL or PAD.GET_CONTROL_NORMAL(0, enum.input.LOOK_UD) ~= NULL then 
			h = CAM.GET_GAMEPLAY_CAM_RELATIVE_HEADING()
			p = CAM.GET_GAMEPLAY_CAM_RELATIVE_PITCH()
		else
			CAM.SET_GAMEPLAY_CAM_RELATIVE_HEADING(h)
			CAM.SET_GAMEPLAY_CAM_RELATIVE_PITCH(p, 0)
		end
	end)
end)

__options.bool["DisableRecording"] = ui.add_bool_option(TRANSLATION["Disable recording"], __submenus["Misc"], function(bool) 
	settings.Misc['DisableRecording'] = bool
	CreateRemoveThread(bool, 'misc_disable_recording',
	function(tick)
		RECORDING._STOP_RECORDING_THIS_FRAME()
	end)
end)

__options.bool["ShootGodmodePlayers"] = ui.add_bool_option(TRANSLATION["Shoot godmode players"], __submenus["Misc"], function(bool) 
	settings.Misc['ShootGodmodePlayers'] = bool
	CreateRemoveThread(bool, 'misc_disable_god_on_aimed',
	function()
		local player = features.get_player_from_ped(features.get_aimed_ped())
		if player == -1 then return end
		if not (settings.General["Exclude Friends"] and features.is_friend(player)) and not features.is_excluded(player) then
			features.remove_god(player)
		end
	end)
end)

__options.num["SetCamDistance"] = ui.add_num_option(TRANSLATION["Set cam distance"], __submenus["Misc"], -1, 1000, 1, function(int) 
	settings.Misc['SetCamDistance'] = int
end)

do
	local defZoom = 83
	__options.num["SetMapZoom"] = ui.add_num_option(TRANSLATION["Set map zoom"], __submenus["Misc"], 1, 100, 1, function(int) 
		defZoom = int
		CreateRemoveThread(true, 'map_zoom', function()
			HUD.SET_RADAR_ZOOM_PRECISE(defZoom)
			if defZoom == 83 then return POP_THREAD end
		end)
	end)
	ui.set_value(__options.num["SetMapZoom"], defZoom, true)
end

CreateRemoveThread(true, 'set_cam_dist', function()
	if settings.Misc['SetCamDistance'] ~= -1 then
		CAM._ANIMATE_GAMEPLAY_CAM_ZOOM(1, settings.Misc['SetCamDistance'])
	end
end)

ui.add_click_option(TRANSLATION["Unload"], __submenus["Misc"], function()
	system.log('Imagined Menu', 'Unloading Imagined Menu...')
	if settings.General["AutoSave"] then SaveConfig() end
	for _, v in pairs(__options.bool)
	do
		if ui.get_value(v) then
			ui.set_value(v, false, false)
		end
	end
	if ui.get_value(__options.choose["NoClip"]) ~= NULL then
		ui.set_value(__options.choose["NoClip"], 0, false)
	end
	gRunning = false
end)

---------------------------------------------------------------------------------------------------------------------------------
-- Recovery
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'recovery submenu') end
__submenus["Recovery"] = ui.add_submenu(TRANSLATION["Recovery"])
__suboptions["Recovery"] = ui.add_sub_option(TRANSLATION["Recovery"], main_submenu, __submenus["Recovery"])

do
	__submenus["StatEditor"] = ui.add_submenu(TRANSLATION["Stat editor"])
	__suboptions["StatEditor"] = ui.add_sub_option(TRANSLATION["Stat editor"], __submenus["Recovery"], __submenus["StatEditor"])

	local stat = 1
	-- local _bool
	-- local _int
	-- local _float
	local value = 0
	local stats = {}
	local values = {'0.001', '0.01', '0.1', '1', '100', '10000', '1000000'}
	local mult = 1
	local hash

	for _, v in ipairs(enum.stats)
	do
		table.insert(stats, v.name)
	end

	__options.choose["StatName"] = ui.add_choose(TRANSLATION["Stat"], __submenus["StatEditor"], true, stats, function(int) stat = int + 1 
		-- system.notify('Comment: '..enum.stats[stat].name, enum.stats[stat].comment, 0, 255, 255, 255)
	end)

	-- __options.bool["Bool"] = ui.add_bool_option(TRANSLATION["Bool"], __submenus["StatEditor"], function(bool) _bool = bool end)
	-- __options.bool["Int"] = ui.add_bool_option(TRANSLATION["Int"], __submenus["StatEditor"], function(bool) _int = bool end)
	-- __options.bool["Float"] = ui.add_bool_option(TRANSLATION["Float"], __submenus["StatEditor"], function(bool) _float = bool end)
	__options.choose["ValueMult"] = ui.add_choose(TRANSLATION["Value multiplier"], __submenus["StatEditor"], true, values, function(int) mult = tonumber(values[int+1]) end)
	ui.set_value(__options.choose["ValueMult"], 3, true)
	__options.num["StatValue"] = ui.add_num_option(TRANSLATION["Value"], __submenus["StatEditor"], -2147483647, 2147483647, 1, function(int) value = int * mult end)
	__options.click["CurrValue"] = ui.add_click_option('0', __submenus["StatEditor"], function() end)

	CreateRemoveThread(true, 'stat_value', function()
		ui.set_name(__options.click["CurrValue"], tostring(value))
	end)

	ui.add_click_option(TRANSLATION["Change stat"], __submenus["StatEditor"], function()
		local type = enum.stats[stat].type
		if enum.stats[stat].characterStat then
			local char = globals.get_int(1574915)
			hash = utils.joaat('MP'..char..'_'..enum.stats[stat].name)
		else
			hash = utils.joaat(enum.stats[stat].name)
		end
		if type == 'bool' then
			STATS.STAT_SET_BOOL(hash, features.to_bool(value), true)
			return
		elseif type == 'float' then
			STATS.STAT_SET_FLOAT(hash, value, true)
			return
		elseif type == 'int' or type == 'u32' or type == 'u64' then
			STATS.STAT_SET_INT(hash, value, true)
			return
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
	ui.add_num_option(TRANSLATION["Player kills"], __submenus["Recovery"], -999999999, 999999999, 1, function(int) kills = int end)
	ui.add_num_option(TRANSLATION["Player deaths"], __submenus["Recovery"], -999999999, 999999999, 1, function(int) deaths = int end)
	ui.add_click_option(TRANSLATION["Set k/d"], __submenus["Recovery"], function() 
		STATS.STAT_SET_INT(utils.joaat("MPPLY_KILLS_PLAYERS"), kills, true)
    STATS.STAT_SET_INT(utils.joaat("MPPLY_DEATHS_PLAYER"), deaths, true)
	end)

	ui.add_click_option(TRANSLATION["Unlock fast-run"], __submenus["Recovery"], function()
		for _, v in ipairs(fast_run)
		do
			local char = globals.get_int(1574915)
			local hash = utils.joaat('MP'..char..'_'..v)
			STATS.STAT_SET_INT(hash, -1, true)
		end
	end)

	ui.add_click_option(TRANSLATION["Fill snacks"], __submenus["Recovery"], function()
		for _, v in ipairs(snacks)
		do
			local char = globals.get_int(1574915)
			local hash = utils.joaat('MP'..char..'_'..v[1])
			STATS.STAT_SET_INT(hash, v[2], true)
		end
	end)

	ui.add_click_option(TRANSLATION["Fill armour"], __submenus["Recovery"], function()
		for _, v in ipairs(armor)
		do
			local char = globals.get_int(1574915)
			local hash = utils.joaat('MP'..char..'_'..v[1])
			STATS.STAT_SET_INT(hash, v[2], true)
		end
	end)

end

---------------------------------------------------------------------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------------------------------------------------------------------
if settings.Dev.Enable then system.log('debug', 'settings submenu') end
__submenus["Settings"] = ui.add_submenu(TRANSLATION["Settings"])
__suboptions["Settings"] = ui.add_sub_option(TRANSLATION["Settings"], main_submenu, __submenus["Settings"])

local LANGUAGES = {}

for i = 1, #TRANSLATION_FILES do
	local text = TRANSLATION_FILES[i]:gsub('%.json', string.empty)
	text = text:sub(1,1):upper()..text:sub(2,-1):lower()
	if text == 'English' then
		text = 'English (US)'
	elseif text == 'French' then
		text = 'French (Français)'
	elseif text == 'German' then
		text = 'German (Deutsch)'
	elseif text == 'Italian' then
		text = 'Italian (Italiano)'
	elseif text == 'Spanish' then
		text = 'Spanish (Español)'
	elseif text == 'Polish' then
		text = 'Polish (Polski)'
	elseif text == 'Russian' then
		text = 'Russian (Русский)'
	elseif text == 'Korean' then
		text = 'Korean (한국인)'
	elseif text == 'Chinese' then
		text = 'Chinese (中國人)'
	elseif text == 'Japanese' then
		text = 'Japanese (日本)'
	elseif text == 'Simplified_chinese' then
		text = 'Simplified Chinese (简体中文)'
	end
	LANGUAGES[i] = text
end

__options.choose["Translation"] = ui.add_choose(TRANSLATION['Default translation'], __submenus["Settings"], true, LANGUAGES, function(i) 
	settings.General['Translation'] = TRANSLATION_FILES[i + 1] 
end)

__options.bool["Exclude Self"] = ui.add_bool_option(TRANSLATION["Exclude self"], __submenus["Settings"], function(bool) settings["General"]["Exclude Self"] = bool end)
__options.bool["Exclude Friends"] = ui.add_bool_option(TRANSLATION["Exclude friends"], __submenus["Settings"], function(bool) settings["General"]["Exclude Friends"] = bool end)
ui.add_separator(TRANSLATION['Configs'], __submenus["Settings"])
__options.click["Save Config"] = ui.add_click_option(TRANSLATION["Save config"], __submenus["Settings"], function() SaveConfig() end)
__options.click["Load Config"] = ui.add_click_option(TRANSLATION["Load config"], __submenus["Settings"], function() LoadConfig();LoadConfTog(settings) end)

ui.add_separator(TRANSLATION['Other'], __submenus["Settings"])

__options.bool["ShowControls"] = ui.add_bool_option(TRANSLATION["Show controls"], __submenus["Settings"], function(bool)
	settings.General["ShowControls"] = bool
end)

__options.bool["AutoSave"] = ui.add_bool_option(TRANSLATION["Auto save settings"], __submenus["Settings"], function(bool)
	settings.General["AutoSave"] = bool
end)

ui.add_click_option(TRANSLATION["Reset to default"], __submenus["Settings"], function()
	LoadConfTog(default)
end)

if settings.Dev.Enable then
	ui.add_separator('Dev', __submenus["Settings"])

	ui.add_click_option("Print active threads", __submenus["Settings"], function()
		local active_threads = 0
		for k, v in pairs(threads) do
			active_threads = active_threads + 1
			system.log('Imagined Menu', string.format('Thread: %s, run time: %.3fs', k, os.clock() - v[2]))
		end
		system.log('Imagined Menu', 'Active Threads: '..active_threads)
		system.log('Imagined Menu', string.format('Last tick time: %.3fs', ticktime))
	end)

	ui.add_click_option("Print avarage tick time", __submenus["Settings"], function()
		system.log('Imagined Menu', string.format('Avarage tick time: %.3fs', avgticktime))
	end)

	local threads = 300
	local loops = 10000
	ui.add_separator('Stress test', __submenus["Settings"])
	local num_th = ui.add_num_option('Threads', __submenus["Settings"], 1, 1000, 10, function(int) threads = int end)
	local num_lp = ui.add_num_option('Loops', __submenus["Settings"], 1, 1000000, 10, function(int) loops = int end)
	ui.set_value(num_th, threads, true)
	ui.set_value(num_lp, loops, true)

	ui.add_click_option("Run", __submenus["Settings"], function()
		system.log('Imagined Menu', string.format('Starting stress test on %i threads and %i loops', threads, loops))
		GetAvgTickTimes()
		for i = 1, threads do
			CreateRemoveThread(true, 'stress_test_'..thread_count, function()
				for t = 1, loops do math.sqrt(math.random(0,147483647)) end
				if not _getting_avg_tick then return POP_THREAD end
			end, true, true)
		end
	end)
end

__submenus["Credits"] = ui.add_submenu(TRANSLATION["Credits"])
__suboptions["Credits"] = ui.add_sub_option(TRANSLATION["Credits"], main_submenu, __submenus["Credits"])

ui.add_click_option(string.format(TRANSLATION['%s for scripting'], 'SATTY')..' >>', __submenus["Credits"], function() file.open("https://discordapp.com/users/274646495460851712") end)
ui.add_click_option(string.format(TRANSLATION['%s for bug finding'], 'Dr Donger')..' >>', __submenus["Credits"], function() file.open("https://discordapp.com/users/289008720485023745") end)
ui.add_click_option(string.format(TRANSLATION['%s for improving lua API'], 'ItsPxel')..' >>', __submenus["Credits"], function() file.open("https://discordapp.com/users/987421777808486500") end)
ui.add_click_option("DurtyFree >>", __submenus["Credits"], function() file.open("https://github.com/DurtyFree") end)
ui.add_click_option("Stack Overflow >>", __submenus["Credits"], function() file.open("https://stackoverflow.com") end)
ui.add_click_option("alloc8or >>", __submenus["Credits"], function() file.open("https://alloc8or.re/gta5/nativedb/") end)
if TRANSLATION[1]['Credits'] ~= string.empty then
	ui.add_click_option(string.format(TRANSLATION['%s for translation'],TRANSLATION[1]['Credits']), __submenus["Credits"], function() end)
end

for _, v in pairs(__options.bool) do
	ui.set_value(v, false, true)
end

LoadConfTog(settings)
vehicle_blacklist.load()

do
	local scaleform = GRAPHICS.REQUEST_SCALEFORM_MOVIE("mp_big_message_freemode")
  while GRAPHICS.HAS_SCALEFORM_MOVIE_LOADED(scaleform) == NULL
  do 
    system.yield()
  end
  system.log('Imagined Menu', 'Loaded successfully')
	system.notify('Imagined Menu', string.format(TRANSLATION["Welcome %s to Imagined Menu!"]..'\nVersion %s\nCredits to %s, %s and %s', PLAYER.GET_PLAYER_NAME(PLAYER.PLAYER_ID()), VERSION, 'SATTY', 'Dr Donger', 'ItsPxel'), 0, 255, 0, 255)
  AUDIO.PLAY_SOUND_FRONTEND(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true)
  local t = os.clock() + 2.5
  CreateRemoveThread(true, 'start_screen', function()
		if os.clock() <= t then
		    GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
		    GRAPHICS.DRAW_SCALEFORM_MOVIE_FULLSCREEN(scaleform, 0, 0, 0, 0, 0)
		    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING('~p~'..TRANSLATION["Welcome"])
		    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING(string.format('~b~'..TRANSLATION["Welcome %s to Imagined Menu!"], (PLAYER.GET_PLAYER_NAME(PLAYER.PLAYER_ID()):gsub('~.~', ''))))
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

CreateRemoveThread(true, 'version_check', function(tick)
	if tick == 100 then 
		if not ver_checked then system.notify('Imagined Menu', TRANSLATION['Enable "Allow http" to check for updates'], 0, 255, 0, 255) end
		return POP_THREAD
	end
	if not new_version then return end
	system.log('Imagined Menu', string.format('New version available: %s', new_version))
	system.notify('Imagined Menu', string.format(TRANSLATION['New version available: %s'], new_version), 0, 255, 0, 255)
	ui.add_click_option(TRANSLATION["Go to download"], main_submenu, function()
	file.open([[https://github.com/ProDash1998/ImaginatedMenuLua/releases/tag/lua]])
	end)
	return POP_THREAD
end)

CreateRemoveThread(true, 'main', function(tick) 
	if ENTITY.GET_ENTITY_ALPHA(PLAYER.PLAYER_PED_ID()) ~= ui.get_value(__options.num["Set Alpha"]) then
		ui.set_value(__options.num["Set Alpha"], ENTITY.GET_ENTITY_ALPHA(PLAYER.PLAYER_PED_ID()), true)
	end
	if vehicles.get_player_vehicle() ~= NULL then
		if __options.bool["InvisibleVehicle"] ~= (ENTITY.IS_ENTITY_VISIBLE(vehicles.get_player_vehicle()) == NULL) then
			ui.set_value(__options.bool["InvisibleVehicle"], ENTITY.IS_ENTITY_VISIBLE(vehicles.get_player_vehicle()) == NULL, true)
		end
		if __options.bool["DisableVehicleCollision"] ~= (ENTITY.GET_ENTITY_COLLISION_DISABLED(vehicles.get_player_vehicle()) ~= NULL) then
			ui.set_value(__options.bool["DisableVehicleCollision"], ENTITY.GET_ENTITY_COLLISION_DISABLED(vehicles.get_player_vehicle()) ~= NULL, true)
		end
		if __options.num["VehicleAlpha"] ~= ENTITY.GET_ENTITY_ALPHA(vehicles.get_player_vehicle()) then
			ui.set_value(__options.num["VehicleAlpha"], ENTITY.GET_ENTITY_ALPHA(vehicles.get_player_vehicle()), true)
		end
	end

	if tick%300==NULL then
		if settings.General["AutoSave"] then
			SaveConfig()
		end
	end
end)
local last_ticks = {}
local time
if settings.Dev.Enable then system.log('debug', 'stated') end

while gRunning 
	do
	time = os.clock()
	for k, v in pairs(threads) 
	do
		if not ticks[k] then 
			ticks[k] = 0 
		else
			ticks[k] = ticks[k] + 1
		end

		if v[1](ticks[k]) == POP_THREAD then 
			CreateRemoveThread(false, k) 
			if settings.Dev.Enable then system.log('debug', string.format('thread %s finished', k)) end
		end
	end

	system.yield()

	ticktime = os.clock() - time

	if #last_ticks == 10 then 
		table.remove(last_ticks, 1) 
	end

	table.insert(last_ticks, ticktime)
	avgticktime = features.sum_table(last_ticks) / #last_ticks

	if settings.Dev.Enable and avgticktime > settings.Dev.TickTimeLimit then
		system.notify(TRANSLATION['Warning'], TRANSLATION['Too high ticktime!'], 255, 0, 0, 255) 
	end
end
