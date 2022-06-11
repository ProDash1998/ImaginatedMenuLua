--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--
VERSION = '1.0.4'

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

local paths = {}
paths['Lua'] = getScriptDir()
paths['ImaginedMenu'] = paths['Lua']..[[\ImaginedMenu]]
paths['Library'] = paths['ImaginedMenu']..[[\lib]]
paths['Data'] = paths['ImaginedMenu']..[[\imagined_menu]]
paths['Translations'] = paths['ImaginedMenu']..[[\translations]]

local files = {
	['Config'] = paths['ImaginedMenu']..[[\config.json]],
	['Json'] = paths['Library']..[[\JSON.lua]],
	['Default'] = paths['Data']..[[\default.lua]],
	['features'] = paths['Data']..[[\features.lua]],
	['Vectors'] = paths['Data']..[[\vectors.lua]],
	['Vehicle'] = paths['Data']..[[\vehicle.lua]],
	['Enums'] = paths['Data']..[[\enums.lua]],
	['Weapons'] = paths['Data']..[[\weapons.lua]],
	['Peds'] = paths['Data']..[[\peds.lua]]
}

package.path = package.path..";"..paths['Library']..[[\?.lua]]
package.path = package.path..";"..paths['Data']..[[\?.lua]]

local json = require 'JSON'
local f = require 'default'
TRANSLATION = f.translation
local features = require 'features'
local vect = require 'vectors'
local vehicles = require 'vehicle'
local peds = require 'peds'
local weapons = require 'weapon'
local enum = require 'enums'
local vector3 = require 'vector3'
local file = require 'files'
local settings = f.settings
local default = {}

if not file.isdir(paths['Translations']) then
	file.make_dir(paths['Translations'])
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
}
string.empty = ""
local NULL = 0
local POP_THREAD = 0
local threads = {}
local thread_queue = {}
local active_threads = 0
local thread_count = 0
local ticks = {}
local ticktime = 0
local avgticktime = 0
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

local function CreateRemoveThread(...)
	local add, name, func, canqueue, highpriority = ...
	active_threads = 0
	for _ in pairs(threads) do
		active_threads = active_threads + 1
	end

	if add then
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

local blockobjects = {}

local function BlockArea(object, x, y, z, rotx, roty, rotz, invisible)

    features.request_model(object, true)
    local obj = entities.create_object(object, x, y, z)
    if obj == NULL then return end
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(obj, x, y, z, false, false, false)
    ENTITY.SET_ENTITY_ROTATION(obj, rotx, roty, rotz, 5, true)
    ENTITY.FREEZE_ENTITY_POSITION(obj,true)

    table.insert(blockobjects, obj)

    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(object)

    if not invisible then return end

    ENTITY.SET_ENTITY_VISIBLE(obj, false, false)
end

local function PlaySound(name, ref, entity)
	local entity = entity or PLAYER.PLAYER_PED_ID()
	AUDIO.PLAY_SOUND_FROM_ENTITY(-1, name, entity, ref, true, 0)
end

local function StopSounds()
	for i = 0, 1000
	do
		AUDIO.STOP_SOUND(i)
	end
end

local function BlockPassive(type)
	for i = 0, 31 do
		if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) then
			online.send_script_event(i, 1114091621, i, type)
		end
	end
end

local function InfiniteInvite(type)
	for i = 0, 31 do
			if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) then
      	online.send_script_event(i, 603406648, i, i, 4294967295, 1, 115, type, type, type)
      end
  end
end

local function IsCommand(command)
	if command:lower():find("^nf!") then return true end
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
			if loaded == NULL then return end
			local target = vect.get_offset_coords_from_entity_rot(
				PLAYER.GET_PLAYER_PED(id), 
				6, 0, true)
			local vehicle = vehicles.spawn_vehicle(hash, target, ENTITY.GET_ENTITY_HEADING(PLAYER.GET_PLAYER_PED(id)))
			if vehicle == NULL then return POP_THREAD end
			entities.request_control(vehicle, function() 
				if NETWORK.NETWORK_IS_SESSION_STARTED() == 1 then
					DECORATOR.DECOR_SET_INT(vehicle, "MPBitset", 0)
				end
				VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
				VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, "Nightfal")
			end)
			STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
			return POP_THREAD
		end, true)
	end,
	freeze = function(id, pl, bool) 
		local target = features.player_from_name(pl)
		if not target then return end
		CreateRemoveThread(true, 'cmd_freeze_'..target, function()
			if (target == PLAYER.PLAYER_ID()) or (settings.Commands["Don't Affect Friends"] and features.is_friend(target)) or (NETWORK.NETWORK_IS_PLAYER_CONNECTED(id) == NULL) or (bool == 'off') then return POP_THREAD end
			local ped = PLAYER.GET_PLAYER_PED(target)
			TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
			online.send_script_event(player, -446275082, PLAYER.PLAYER_ID(), 0, 1, 0, globals.get_int(1893551 + (1 + (online.get_selected_player() * 599) + 510)))
		end, true, true)
	end,
	island = function(id, pl)
		local target = features.player_from_name(pl)
		CreateRemoveThread(true, 'cmd_island_'..id, function()
			if (not target) or (settings.Commands["Don't Affect Friends"] and features.is_friend(target)) --[=[or (i == id)]=] then return POP_THREAD end
			online.send_script_event(target, -621279188, target, 1)
			return POP_THREAD
		end, true, true)
	end,
	kick = function(id, pl) 
		local target = features.player_from_name(pl)
		if not target then return end
		CreateRemoveThread(true, 'cmd_kick_'..id, function()
			if (not target) or (settings.Commands["Don't Affect Friends"] and features.is_friend(target)) --[=[or (i == id)]=] then return POP_THREAD end
			features.kick_player(target)
			return POP_THREAD
		end, true, true)
	end,
	crash = function(id, pl) 
		local target = features.player_from_name(pl)
		CreateRemoveThread(true, 'cmd_crash_'..id, function()
			if (not target) or (settings.Commands["Don't Affect Friends"] and features.is_friend(target)) --[=[or (i == id)]=] then return POP_THREAD end
			features.crash_player(target)
			return POP_THREAD
		end, true, true)
	end,
	explode = function(id, pl) 
		local target = features.player_from_name(pl)
		CreateRemoveThread(true, 'cmd_explode_'..id, function()
			if (not target) or (target == PLAYER.PLAYER_ID()) or (settings.Commands["Don't Affect Friends"] and features.is_friend(target)) --[=[or (i == id)--]=] then return POP_THREAD end
			local pos = features.get_player_coords(target)
			FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, enum.explosion.ROCKET, 10, true, false, 1.0, false)
			return POP_THREAD
		end, true, true)
	end,
	kickAll = function(id) 
		CreateRemoveThread(true, 'cmd_kickall_'..id, function()
			for i = 0, 31 do
				if not (settings.Commands["Don't Affect Friends"] and features.is_friend(i)) and (i ~= id) and (i ~= PLAYER.PLAYER_ID()) then
					features.kick_player(i)
				end
			end
			return POP_THREAD
		end, true, true)
	end,
	crashAll = function(id) 
		CreateRemoveThread(true, 'cmd_crashall_'..id, function()
			for i = 0, 31 do
				if not (settings.Commands["Don't Affect Friends"] and features.is_friend(i)) and (i ~= id) and (i ~= PLAYER.PLAYER_ID()) then
					features.crash_player(i)
				end
			end
			return POP_THREAD
		end, true, true)
	end,
	explodeAll = function(id) 
		CreateRemoveThread(true, 'cmd_explodeall_'..id, function()
			for i = 0, 31 do
				if not (settings.Commands["Don't Affect Friends"] and features.is_friend(i)) and (i ~= id) and (i ~= PLAYER.PLAYER_ID()) then
					local pos = features.get_player_coords(i)
					FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, enum.explosion.ROCKET, 10, true, false, 1.0, false)
				end
			end
			return POP_THREAD
		end, true, true)
	end,
	clearwanted = function(id, bool) 
		CreateRemoveThread(true, 'cmd_clearwanted_'..id, function(tick)
			if tick%5~=NULL then return end
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(id) == NULL or bool == 'off' then return POP_THREAD end
			online.send_script_event(id, -91354030, id, globals.get_int(1893551 + (1 + (id * 599) + 510)))
			online.send_script_event(id, 1722873242, id, 0, 0, NETWORK.GET_NETWORK_TIME(), 0, globals.get_int(1893551 + (1 + (id * 599) + 510)))
		end, true, true)
	end,
	offradar = function(id, bool) 
		CreateRemoveThread(true, 'cmd_offradar_'..id, function(tick)
			if tick%5~=NULL then return end
			if NETWORK.NETWORK_IS_PLAYER_CONNECTED(id) == NULL or bool == 'off' then return POP_THREAD end
			online.send_script_event(id, -391633760, id, NETWORK.GET_NETWORK_TIME() - 60, NETWORK.GET_NETWORK_TIME(), 1, 1, globals.get_int(1893551 + (1 + (id * 599) + 510)))
		end, true, true)
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
		end, true, true)
	end,
	upgrade = function(id) 
		CreateRemoveThread(true, 'cmd_upgrade_'..id, function()
			local veh = vehicles.get_player_vehicle(id)
			if veh == NULL then return POP_THREAD end
			entities.request_control(veh, function() vehicles.upgrade(veh) end)
			return POP_THREAD
		end, true, true)
	end,
	repair = function(id) 
		CreateRemoveThread(true, 'cmd_repair_'..id, function()
			local veh = vehicles.get_player_vehicle(id)
			if veh == NULL then return POP_THREAD end
			entities.request_control(veh, function() vehicles.repair(veh) end)
			return POP_THREAD
		end, true, true)
	end
}

local function HandleCommand(command, player)
	if command[1] == 'nf!spawn' 			then cmd.spawn(id, command[2]) 							return true end
	if command[1] == 'nf!freeze' 			then cmd.freeze(id, command[2], command[3]) return true end
	if command[1] == 'nf!island' 			then cmd.island(id, command[2]) 						return true end
	if command[1] == 'nf!kick' 				then cmd.kick(id, command[2]) 							return true end
	if command[1] == 'nf!crash' 			then cmd.crash(id, command[2]) 							return true end
	if command[1] == 'nf!explode' 		then cmd.explode(id, command[2]) 						return true end
	if command[1] == 'nf!kickall' 		then cmd.kickAll(id) 												return true end
	if command[1] == 'nf!crashall' 		then cmd.crashAll(id) 											return true end
	if command[1] == 'nf!explodeall' 	then cmd.explodeAll(id) 										return true end
	if command[1] == 'nf!clearwanted' then cmd.clearwanted(id, command[2]) 				return true end
	if command[1] == 'nf!offradar' 		then cmd.offradar(id, command[2]) 					return true end
	if command[1] == 'nf!vehiclegod' 	then cmd.vehiclegod(id, command[2]) 				return true end
	if command[1] == 'nf!upgrade' 		then cmd.upgrade(id) 												return true end
	if command[1] == 'nf!repair' 			then cmd.repair(id) 												return true end
end

-- callbacks
function on_votekick(ply, target)
	if target == PLAYER.PLAYER_ID() then
		if (features.is_friend(ply) and settings.General['Exclude Friends']) then return end
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
	if (features.is_friend(ply) and settings.General['Exclude Friends']) then return end
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
    if spoofed_as_ply == -1 and IsCommand(text) then
    	local text = text:lower()
    	if settings["Commands"]["Friends Only"] and not features.is_friend(id) then return true end
    	local command = features.split(text, ' +')
    	if not settings["Commands"][command[1]] then return true end
    	if HandleCommand(command, id) then 
    		system.log('Imagined Menu', string.format("Player %s requested command %s", online.get_name(id), command[1]) )
    		system.notify(TRANSLATION['Chat command'], string.format(TRANSLATION["Player %s requested command %s"], online.get_name(id), command[1]), 100, 0, 255, 255)
    	end

    end
end
--
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
	file.write(json:encode_pretty(settings), files['Config'])
end

--settings
local function LoadConfig()
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

---------------------------------------------------------------------------------------------------------------------------------
-- Players
---------------------------------------------------------------------------------------------------------------------------------

__submenus["Imagined"] = ui.add_player_submenu(TRANSLATION["Imagined Menu"])

local main_submenu = ui.add_main_submenu(TRANSLATION["Imagined Menu"])

__submenus["SpawnVehicle"] = ui.add_submenu(TRANSLATION["Spawn vehicle"])
__suboptions["SpawnVehicle"] = ui.add_sub_option(TRANSLATION["Spawn vehicle"], __submenus["Imagined"], __submenus["SpawnVehicle"])

do
	local vehs = {}
	local god
	local upgrade
	local selected_vehicle = 0
	for _, i in ipairs(vehicles.models) do
		table.insert(vehs, i[3])
	end
	ui.add_bool_option(TRANSLATION['Spawn with godmode'],  __submenus["SpawnVehicle"], function(bool) god = bool end)
	ui.add_bool_option(TRANSLATION['Spawn upgraded'],  __submenus["SpawnVehicle"], function(bool) upgrade = bool end)

	ui.add_choose(TRANSLATION["Vehicle"], __submenus["SpawnVehicle"], true, vehs, function(i) selected_vehicle = i end)

	ui.add_click_option(TRANSLATION["Spawn"], __submenus["SpawnVehicle"], function() 
		local hash, player = vehicles.models[selected_vehicle+1][2], online.get_selected_player()
		if features.request_model(hash, true) == NULL then return end
		local target = vect.get_offset_coords_from_entity_rot(PLAYER.GET_PLAYER_PED(player), 6, 0, true)
		local vehicle = vehicles.spawn_vehicle(hash, target, ENTITY.GET_ENTITY_HEADING(PLAYER.GET_PLAYER_PED(player)))
		if vehicle == NULL then return end
		entities.request_control(vehicle, function()
			if NETWORK.NETWORK_IS_SESSION_STARTED() == 1 then
				DECORATOR.DECOR_SET_INT(vehicle, "MPBitset", 0)
			end
			vehicles.repair(vehicle)
			VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, false)
			VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(vehicle, "Nightfal")
			if god then vehicles.set_godmode(vehicle, true) end
			if upgrade then vehicles.upgrade(vehicle) end
		end)
		STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
	end)

	-- ui.add_click_option("Blame", __submenus["Imagined"], function()
	-- 	local target = online.get_selected_player()
	-- 	local ped = PLAYER.GET_PLAYER_PED(target)
	-- 	for i = 0, 31 do

	-- 		if i == PLAYER.PLAYER_ID() then goto continue end
	--         if NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == NULL then goto continue end
	--         if settings.General['Exclude Friends'] and features.is_friend(i) then goto continue end

	-- 		FIRE.ADD_OWNED_EXPLOSION(ped, 0, 0, 0, enum.explosion.ROCKET, 1, true, false, 1.0)  -- seems to give connection error

	-- 		::continue::
	-- 	end
	-- end)

ui.add_separator(TRANSLATION["Trolling"], __submenus["Imagined"])

	ui.add_click_option(TRANSLATION["Trap in invisible tube"], __submenus["Imagined"], function()
		local target = online.get_selected_player()
		features.request_model(1125864094, true)
		local pos = features.get_player_coords(target)
		BlockArea(1125864094, pos.x, pos.y, pos.z, 0, 90, 0, true)
	end)

end

do
	local spawned_jets = {}

	ui.add_bool_option(TRANSLATION["Send jets"], __submenus["Imagined"], function(bool)
		local player = online.get_selected_player()
		if bool then
			features.request_model(utils.joaat('ig_dom'), true)
			features.request_model(utils.joaat('lazer'), true)
			local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(player), false)
			spawned_jets[player] = {}
			for i = -2, 3 do
				local offcoords = vect.get_offset_coords_from_entity_rot(PLAYER.GET_PLAYER_PED(player), 300, i*60, true)
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
				vect.set_entity_face_entity(jet, PLAYER.GET_PLAYER_PED(player), true)
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

			features.unload_models(utils.joaat('lazer'),utils.joaat('ig_dom'))
		end
		if spawned_jets[player] and not bool then
			for _, v in ipairs(spawned_jets[player]) do
				features.request_control_of_entities(v)
				features.delete_entity(v[1])
				features.delete_entity(v[2])
			end
			spawned_jets[player] = nil
		end
	end)

end

ui.add_separator(TRANSLATION["Vehicle"], __submenus["Imagined"])

ui.add_click_option(TRANSLATION["Blow up vehicle"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'blow_up_vehicle_'..thread_count, function(tick)
		if tick == 50 then return POP_THREAD end
		if not features.request_control_once(veh) then return end
		local netId = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(veh)
		vehicles.set_godmode(veh, false)
		NETWORK.NETWORK_EXPLODE_VEHICLE(veh, true, false, netId)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Pop tires"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'pop_tires_'..thread_count, function(tick)
		if tick == 50 then return POP_THREAD end
		if not features.request_control_once(veh) then return end
		vehicles.set_godmode(veh, false)
    for i = 0, 5 do
      VEHICLE.SET_VEHICLE_TYRE_BURST(veh, i, true, 1000.0)
    end
		return POP_THREAD
	end)
end)

ui.add_bool_option(TRANSLATION["Set vehicle godmode"], __submenus["Imagined"], function(bool)
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'vehicle_god_on_'..thread_count, function(tick)
		if tick == 50 then return POP_THREAD end
		if not features.request_control_once(veh) then return end
		vehicles.set_godmode(veh, bool)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Rotate vehicle"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'rotate_vehicle_'..thread_count, function(tick)
		if tick == 50 then return POP_THREAD end
		if not features.request_control_once(veh) then return end
		local rot = ENTITY.GET_ENTITY_ROTATION(veh, 5)
		ENTITY.SET_ENTITY_ROTATION(veh, rot.x, rot.y, rot.z - 180, 5, true)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Flip vehicle"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'flip_vehicle_'..thread_count, function(tick)
		if tick == 50 then return POP_THREAD end
		if not features.request_control_once(veh) then return end
		local rot = ENTITY.GET_ENTITY_ROTATION(veh, 5)
		ENTITY.SET_ENTITY_ROTATION(veh, rot.x - 180, rot.y, rot.z, 5, true)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Boost forward"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'boost_forward_'..thread_count, function(tick)
		if tick == 50 then return POP_THREAD end
		if not features.request_control_once(veh) then return end
		VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, 500)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Boost backward"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'boost_backward_'..thread_count, function(tick)
		if tick == 50 then return POP_THREAD end
		if not features.request_control_once(veh) then return end
		VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, -500)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Launch up vehicle"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'launch_up_vehicle_'..thread_count, function(tick)
		if tick == 50 then return POP_THREAD end
		if not features.request_control_once(veh) then return end
		ENTITY.FREEZE_ENTITY_POSITION(veh, false)
		ENTITY.SET_ENTITY_VELOCITY(veh, 0, 0, 500)
		return POP_THREAD
	end)
end)

ui.add_click_option(TRANSLATION["Launch down vehicle"], __submenus["Imagined"], function()
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'launch_down_vehicle_'..thread_count, function(tick)
		if tick == 50 then return POP_THREAD end
		if not features.request_control_once(veh) then return end
		ENTITY.FREEZE_ENTITY_POSITION(veh, false)
		ENTITY.SET_ENTITY_VELOCITY(veh, 0, 0, -500)
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
				online.send_script_event(pid, -1026787486, pid, pid)
        online.send_script_event(pid, 578856274, pid, 0, 0, 0, 0, 1, pid, math.random(0, 2147483647))
				TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
			end
			PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
		end)
		if VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, -1, true) ~= PLAYER.PLAYER_PED_ID() then return end
		return POP_THREAD
	end)
end)

ui.add_bool_option(TRANSLATION["Start vehicle horn"], __submenus["Imagined"], function(bool)
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(bool, 'horn_vehicle_'..pid, function(tick)
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == NULL then return POP_THREAD end
		entities.request_control(veh, function()
			VEHICLE.START_VEHICLE_HORN(veh, 3000, 0, false)
		end)
	end)
end)

ui.add_bool_option(TRANSLATION["Honk boosting"], __submenus["Imagined"], function(bool)
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(bool, 'honk_boost_vehicle_'..pid, function(tick)
		if NETWORK.NETWORK_IS_PLAYER_CONNECTED(pid) == NULL then return POP_THREAD end
		if AUDIO.IS_HORN_ACTIVE(veh) == NULL then return end
		if not features.request_control_once(veh) then return end
		local speed = ENTITY.GET_ENTITY_SPEED(veh)
		VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, speed + 20)
	end)
end)

ui.add_bool_option(TRANSLATION["Lock vehicle"], __submenus["Imagined"], function(bool)
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'lock_vehicle_'..thread_count, function(tick)
		if tick == 50 then return POP_THREAD end
		if not features.request_control_once(veh) then return end
		if bool then
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 6)
	    VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 2)
	  else
	  	VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 1)
	  end
		return POP_THREAD
	end)
end)

ui.add_bool_option(TRANSLATION["Child locks"], __submenus["Imagined"], function(bool)
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'lock_vehicle_'..thread_count, function(tick)
		if tick == 50 then return POP_THREAD end
		if not features.request_control_once(veh) then return end
		if bool then
			VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 6)
	    VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 4)
	  else
	  	VEHICLE.SET_VEHICLE_DOORS_LOCKED(veh, 1)
	  end
		return POP_THREAD
	end)
end)

do
	local topspeed = 0
	ui.add_num_option(TRANSLATION["Change max speed"], __submenus["Imagined"], 0, 1000, 1, function(int) topspeed = int end)
	ui.add_click_option(TRANSLATION["Set max speed"], __submenus["Imagined"], function()
		local pid = online.get_selected_player()
		local veh = vehicles.get_player_vehicle(pid)
		if veh == NULL then return end
		CreateRemoveThread(true, 'set_max_speed_'..thread_count, function(tick)
			if tick == 50 then return POP_THREAD end
			if not features.request_control_once(veh) then return end
			ENTITY.SET_ENTITY_MAX_SPEED(veh, topspeed)
			VEHICLE.MODIFY_VEHICLE_TOP_SPEED(veh, topspeed)
			return POP_THREAD
		end)
	end)

end

ui.add_separator(TRANSLATION["Teleport"], __submenus["Imagined"])

ui.add_click_option(TRANSLATION["Teleport vehicle to waypoint"], __submenus["Imagined"], function()
	if HUD.IS_WAYPOINT_ACTIVE() == NULL then system.notify(TRANSLATION['Info'], TRANSLATION["No waypoint has been set"], 255, 128, 0, 255) return end
	local pid = online.get_selected_player()
	local veh = vehicles.get_player_vehicle(pid)
	if veh == NULL then return end
	CreateRemoveThread(true, 'teleport_vehicle_'..thread_count, function(tick)
		if tick == 100 then return POP_THREAD end
		if not features.request_control_once(veh) then return end
	  local pos = vector3(HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8)))
	  features.teleport(veh, pos.x, pos.y, 800)
		return POP_THREAD
	end)
end)


---------------------------------------------------------------------------------------------------------------------------------
-- Self
---------------------------------------------------------------------------------------------------------------------------------

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
			GRAPHICS.USE_PARTICLE_FX_ASSET("core")
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
					local obj = entities.create_object(hash, pos)
					ENTITY.ATTACH_ENTITY_TO_ENTITY(obj, ped, 38,
						ghostrider_chains[i][1], ghostrider_chains[i][2], ghostrider_chains[i][3],
						ghostrider_chains[i][4], ghostrider_chains[i][5], ghostrider_chains[i][6],
						false, true, false, false, 5, true)
					chains[i] = obj
				end
			end
			if not flame._self then
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
			sanctus = vehicles.spawn_vehicle(hash, pos, ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID()))
			vehicles.set_godmode(sanctus, true)
			flame.vehicle[1] = entities.create_object(chip, pos)
			flame.vehicle[2] = entities.create_object(chip, pos)
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
	__options.num["NoClipMultiplier"] = ui.add_num_option(TRANSLATION["No clip speed multiplier"], __submenus["Self"], 1, 20, 1, function(int) settings.Self["NoClipMultiplier"] = int end)

	local nocliptype = 0
	__options.choose["NoClip"] = ui.add_choose(TRANSLATION["No clip"], __submenus["Self"], true, {TRANSLATION["None"], TRANSLATION["Mouse"], TRANSLATION["Keyboard"]}, function(int)
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

    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_SUB_ASCEND) == 1 then
        multiplier = settings.Self["NoClipMultiplier"]
    end

    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_UP) == 1 then
    	local posW = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entself, 0, 1 * multiplier, 0)
      ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entself, posW.x, posW.y, posW.z, false, false, false)
    end

    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_DOWN) == 1 then
        local posS = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entself, 0, -1 * multiplier, 0)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entself, posS.x, posS.y, posS.z, false, false, false)
    end

    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_LEFT) == 1 then
    	if nocliptype == 1 then
        local posA = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entself, -1 * multiplier, 0, 0)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entself, posA.x, posA.y, posA.z, false, false, false)
      else
      	local rot = ENTITY.GET_ENTITY_ROTATION(entself, 5)
      	ENTITY.SET_ENTITY_ROTATION(entself, 0, 0, rot.z + 2, 5, true)
      end
    end

    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_YAW_RIGHT) == 1 then
    	if nocliptype == 1 then
        local posD = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(entself, 1 * multiplier, 0, 0)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entself, posD.x, posD.y, posD.z, false, false, false)
      else
      	local rot = ENTITY.GET_ENTITY_ROTATION(entself, 5)
      	ENTITY.SET_ENTITY_ROTATION(entself, 0, 0, rot.z - 2, 5, true)
      end
    end

    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_PUSHBIKE_SPRINT) == 1 then
      local posUp = ENTITY.GET_ENTITY_COORDS(entself, false)
      ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entself, posUp.x, posUp.y, posUp.z + 1 * multiplier, false, false, false)
    end

    if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_SUB_DESCEND) == 1 then
      local posDow = ENTITY.GET_ENTITY_COORDS(entself, false)
      ENTITY.SET_ENTITY_COORDS_NO_OFFSET(entself, posDow.x, posDow.y, posDow.z -1 * multiplier, false, false, false)
    end

  end)

end

__options.bool["DemiGod"] = ui.add_bool_option(TRANSLATION["Demi-god"], __submenus["Self"], function(bool) 
	settings.Self["DemiGod"] = bool
	local maxhealth = 328
	if bool then
		maxhealth = PED.GET_PED_MAX_HEALTH(PLAYER.PLAYER_PED_ID())
	end
	CreateRemoveThread(bool, 'demi_god', 
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
	CreateRemoveThread(bool, 'police_mode',
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

__options.num["Set Alpha"] = ui.add_num_option(TRANSLATION["Set alpha"], __submenus["Self"], 0, 255, 1, function(int) 
	ENTITY.SET_ENTITY_ALPHA(PLAYER.PLAYER_PED_ID(), int, false)
end)

__options.num["ForceField"] = ui.add_num_option(TRANSLATION["Force field"], __submenus["Self"], 0, 100, 1, function(int) settings.Self["ForceField"] = int end)

CreateRemoveThread(true, 'force_field', function()
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

__submenus["Session"] = ui.add_submenu(TRANSLATION["Session"])
__suboptions["Session"] = ui.add_sub_option(TRANSLATION["Session"], main_submenu, __submenus["Session"])
---------------------------------------------------------------------------------------------------------------------------------
-- Commands
---------------------------------------------------------------------------------------------------------------------------------

__submenus["Commands"] = ui.add_submenu(TRANSLATION["Commands"])
__suboptions["Commands"] = ui.add_sub_option(TRANSLATION["Commands"], __submenus["Session"], __submenus["Commands"])

__options.bool["nf!spawn"] = ui.add_bool_option("nf!spawn <Vehicle>", __submenus["Commands"], function(bool)
	settings.Commands["nf!spawn"] = bool
end)
__options.bool["nf!freeze"] = ui.add_bool_option("nf!freeze <Player/ID> <on/off>", __submenus["Commands"], function(bool)
    settings.Commands["nf!freeze"] = bool
    if not bool then
    	for i = 0, 31 do
    		CreateRemoveThread(false,"cmd_freeze_"..i)
    	end
    end
end)
__options.bool["nf!island"] = ui.add_bool_option("nf!island <Player/ID>", __submenus["Commands"], function(bool)
    settings.Commands["nf!island"] = bool
end)
__options.bool["nf!kick"] = ui.add_bool_option("nf!kick <Player/ID>", __submenus["Commands"], function(bool)
    settings.Commands["nf!kick"] = bool
end)
__options.bool["nf!crash"] = ui.add_bool_option("nf!crash <Player/ID>", __submenus["Commands"], function(bool)
    settings.Commands["nf!crash"] = bool
end)
__options.bool["nf!explode"] = ui.add_bool_option("nf!explode <Player/ID>", __submenus["Commands"], function(bool)
    settings.Commands["nf!explode"] = bool
end)
__options.bool["nf!kickall"] = ui.add_bool_option("nf!kickall", __submenus["Commands"], function(bool)
    settings.Commands["nf!kickall"] = bool
end)
__options.bool["nf!crashall"] = ui.add_bool_option("nf!crashall", __submenus["Commands"], function(bool)
    settings.Commands["nf!crashall"] = bool
end)
__options.bool["nf!explodeall"] = ui.add_bool_option("nf!explodeall", __submenus["Commands"], function(bool)
    settings.Commands["nf!explodeall"] = bool
end)
__options.bool["nf!clearwanted"] = ui.add_bool_option("nf!clearwanted <on/off>", __submenus["Commands"], function(bool)
    settings.Commands["nf!clearwanted"] = bool
    if not bool then
    	for i = 0, 31 do
    		CreateRemoveThread(false,"cmd_clearwanted_"..i)
    	end
    end
end)
__options.bool["nf!offradar"] = ui.add_bool_option("nf!offradar <on/off>", __submenus["Commands"], function(bool)
    settings.Commands["nf!offradar"] = bool
    if not bool then
    	for i = 0, 31 do
    		CreateRemoveThread(false,"cmd_offradar_"..i)
    	end
    end
end)
__options.bool["nf!vehiclegod"] = ui.add_bool_option("nf!vehiclegod <on/off>", __submenus["Commands"], function(bool)
    settings.Commands["nf!vehiclegod"] = bool
end)
__options.bool["nf!upgrade"] = ui.add_bool_option("nf!upgrade", __submenus["Commands"], function(bool)
    settings.Commands["nf!upgrade"] = bool
end)
__options.bool["nf!repair"] = ui.add_bool_option("nf!repair", __submenus["Commands"], function(bool)
    settings.Commands["nf!repair"] = bool
end)

ui.add_separator(TRANSLATION['Chat commands settings'], __submenus["Commands"])

__options.bool["Friends Only"] = ui.add_bool_option(TRANSLATION["Friends only"], __submenus["Commands"], function(bool)
	settings.Commands["Friends Only"] = bool
end)
__options.bool["Don't Affect Friends"] = ui.add_bool_option(TRANSLATION["Don't affect friends"], __submenus["Commands"], function(bool)
	settings.Commands["Don't Affect Friends"] = bool
end)
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

---------------------------------------------------------------------------------------------------------------------------------
-- Toggles
---------------------------------------------------------------------------------------------------------------------------------
ui.add_separator(TRANSLATION['Toggles'], __submenus["Session"])

__options.bool["DisableChat"] = ui.add_bool_option(TRANSLATION['Disable Chat'], __submenus["Session"], function(bool)
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
	    for i = 0, 31 do
	    		if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) then
	        	online.send_script_event(i, 1132878564, i, math.random(1, 6))
	        end
	    end
	end)
end)

__options.bool["OffRadarAll"] = ui.add_bool_option(TRANSLATION['Off radar'], __submenus["Session"], function(bool)	
	CreateRemoveThread(bool, 'session_off_radar',
	function(tick)
		if tick%5~=NULL then return end
		for i = 0, 31 do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) then
				online.send_script_event(i, -391633760, i, NETWORK.GET_NETWORK_TIME() - 60, NETWORK.GET_NETWORK_TIME(), 1, 1, globals.get_int((1893551 + (1 + (i * 599) + 510))))
			end
		end
	end)
end)

__options.bool["RemoveWantedAll"] = ui.add_bool_option(TRANSLATION['Remove wanted'], __submenus["Session"], function(bool)
	CreateRemoveThread(bool, 'session_remove_wanted',
	function()
		for i = 0, 31 do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) then
				online.send_script_event(i, -91354030, i, globals.get_int(1893551 + (1 + (i * 599) + 510)))
			end
		end
	end)
end)

__options.bool["BribeAuthoritiesAll"] = ui.add_bool_option(TRANSLATION['Bribe authorities'], __submenus["Session"], function(bool)
	CreateRemoveThread(bool, 'session_bribe_authorities',
	function(tick)
		if tick%5~=NULL then return end
		for i = 0, 31 do
			if not (i == PLAYER.PLAYER_ID() and settings.General["Exclude Self"]) and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) then
				online.send_script_event(i, 1722873242, i, 0, 0, NETWORK.GET_NETWORK_TIME(), 0, globals.get_int(1893551 + (1 + (i * 599) + 510)))
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
		for i = 0, 31 do
			if i ~= PLAYER.PLAYER_ID() and NETWORK.NETWORK_IS_PLAYER_CONNECTED(i) == 1 and not (settings.General['Exclude Friends'] and features.is_friend(i)) then
				online.send_script_event(i, -1704141512, i, 50000, 0, 1, globals.get_int(1893551 + (1 + (i * 599) + 510)), globals.get_int(1921039 + 9), globals.get_int(1921039 + 10), 1)
			end
		end
	end)
end)

---------------------------------------------------------------------------------------------------------------------------------
-- Vehicle
---------------------------------------------------------------------------------------------------------------------------------

__submenus["Vehicle"] = ui.add_submenu(TRANSLATION["Vehicle"])
__suboptions["Vehicle"] = ui.add_sub_option(TRANSLATION["Vehicle"], main_submenu, __submenus["Vehicle"])

ui.add_separator(TRANSLATION["Horn boost"], __submenus["Vehicle"])

__options.bool["BoostEffect"] = ui.add_bool_option(TRANSLATION["With effect"], __submenus["Vehicle"], function(bool) settings.Vehicle["BoostEffect"] = bool end)

do
	local types = {TRANSLATION['Constant'] ,TRANSLATION['Non constant']}
	__options.choose["AccelerationType"] = ui.add_choose(TRANSLATION["Acceleration type"], __submenus["Vehicle"], true, types, function(int) settings.Vehicle["AccelerationType"] = int end)
	__options.num["HornBoostPower"] = ui.add_num_option(TRANSLATION["Horn boost power"], __submenus["Vehicle"], 1, 20, 1, function(int) settings.Vehicle["HornBoostPower"] = int end)
end

__options.bool["HornBoost"] = ui.add_bool_option(TRANSLATION["Horn boost"], __submenus["Vehicle"], function(bool)
	settings.Vehicle['HornBoost'] = bool
	CreateRemoveThread(bool, 'horn_boost',
	function()
		if vehicles.get_player_vehicle() == NULL or PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_HORN) == NULL then return end
		local veh = vehicles.get_player_vehicle()
		features.request_control_once(veh)
		ENTITY.SET_ENTITY_MAX_SPEED(veh, 10000000)
		local speed = ENTITY.GET_ENTITY_SPEED(veh)
		if settings.Vehicle["BoostEffect"] then AUDIO.SET_VEHICLE_BOOST_ACTIVE(veh, true) end
		if settings.Vehicle["AccelerationType"] == NULL then
			speed = speed + settings.Vehicle["HornBoostPower"]
		elseif settings.Vehicle["AccelerationType"] == 1 then
			if speed < 1 then speed = 1 end
			speed = speed + speed * settings.Vehicle["HornBoostPower"] / 100
		end
		VEHICLE.SET_VEHICLE_FORWARD_SPEED(veh, speed)
		if settings.Vehicle["BoostEffect"] then AUDIO.SET_VEHICLE_BOOST_ACTIVE(veh, false) end
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
			local seat = vehicles.get_first_free_seat(veh)
			if settings.Vehicle["InstaEnter/ExitVehicleFroceDriver"] then seat = -1 end
			if not seat or dist > 20 or PAD.IS_CONTROL_JUST_PRESSED(0, enum.input.VEH_EXIT) == NULL then return end
			CreateRemoveThread(true, 'seat_change_'..thread_count, function(tick)
				if tick == 100 then return POP_THREAD end
				entities.request_control(veh, function()
					local ped = VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, seat, true)
					if ped and ped ~= PLAYER.PLAYER_PED_ID() then
						TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
					end
					PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, seat)
				end)
				if VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, seat, true) ~= PLAYER.PLAYER_PED_ID() then return end
				return POP_THREAD
			end)
		elseif PAD.IS_CONTROL_JUST_PRESSED(0, enum.input.VEH_EXIT) == 1 then
			TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.PLAYER_PED_ID())
		end
	end)
end)

__options.bool["InstaEnter/ExitVehicleFroceDriver"] = ui.add_bool_option(TRANSLATION["Force driver seat"], __submenus["Vehicle"], function(bool) settings.Vehicle["InstaEnter/ExitVehicleFroceDriver"] = bool end)

ui.add_separator(TRANSLATION["Other"], __submenus["Vehicle"])

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
				entities.request_control(veh, function()
				ENTITY.SET_ENTITY_ROTATION(veh, 0, 0, rot.z, 5, true)
				VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh, 0) end)
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

__options.bool["LicenceSpeedo"] = ui.add_bool_option(TRANSLATION["Licence plate speedo"], __submenus["Vehicle"], function(bool)
	settings.Vehicle['LicenceSpeedo'] = bool
	local mult = 2.236936
	local unit = 'mph'
	if MISC.SHOULD_USE_METRIC_MEASUREMENTS() == 1 then
		mult = 3.6
		unit = 'kmph'
	end
	CreateRemoveThread(bool, 'licence_speedo', function()
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
	CreateRemoveThread(bool, 'speed_bypass', function()
		local veh = vehicles.get_player_vehicle()
		if veh == NULL then return end
		ENTITY.SET_ENTITY_MAX_SPEED(veh, 10000000)
	end)
	if not bool then
		ENTITY.SET_ENTITY_MAX_SPEED(veh, 540)
	end
end)

__options.bool["VehicleJump"] = ui.add_bool_option(TRANSLATION["Vehicle jump"], __submenus["Vehicle"], function(bool)
	settings.Vehicle["VehicleJump"] = bool
	CreateRemoveThread(bool, 'vehicle_jump', function()
		local veh = vehicles.get_player_vehicle()
		if veh == NULL then return end
		PAD.DISABLE_CONTROL_ACTION(0, enum.input.VEH_HANDBRAKE, true)
		if PAD.IS_DISABLED_CONTROL_PRESSED(0, enum.input.VEH_HANDBRAKE) == 1 then
			local vel = ENTITY.GET_ENTITY_VELOCITY(veh)
      ENTITY.SET_ENTITY_VELOCITY(veh, vel.x, vel.y, vel.z + 1)
    end
	end)
end)

__options.bool["StickToGround"] = ui.add_bool_option(TRANSLATION["Stick to ground"], __submenus["Vehicle"], function(bool)
	settings.Vehicle["StickToGround"] = bool
	CreateRemoveThread(bool, 'stick_to_ground', function()
		local veh = vehicles.get_player_vehicle()
		if veh == NULL or ENTITY.IS_ENTITY_IN_AIR(veh) == NULL then return end
		VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(veh, 5)
	end)
end)

__options.bool["SlamIt"] = ui.add_bool_option(TRANSLATION["Slam it"], __submenus["Vehicle"], function(bool)
	settings.Vehicle["SlamIt"] = bool
	CreateRemoveThread(bool, 'slam_vehicle', function()
		local veh = vehicles.get_player_vehicle()
		if veh == NULL then return end
		ENTITY.APPLY_FORCE_TO_ENTITY(veh, 0, 0, 0, -30, 0, 0, 0, 0, true, false, true, false, true)
	end)
end)

do
	local types = {TRANSLATION['None'], TRANSLATION['Keyboard'], TRANSLATION['Cam fly'], TRANSLATION['Glide fly']}
	local type = 0
	__options.choose["VehicleFly"] = ui.add_choose(TRANSLATION["Vehicle fly"], __submenus["Vehicle"], true, types, function(int) type = int 
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
		elseif type == 2 then
			if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_FLY_THROTTLE_UP) == 1 then
				local force = 20
				if PAD.IS_CONTROL_PRESSED(0, enum.input.VEH_MOVE_UP_ONLY) == 1 then force = 100 end
				local dir = rot:rot_to_direction() * force
				ENTITY.SET_ENTITY_VELOCITY(veh, dir.x, dir.y, dir.z)
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
		end
	end)
end

do
	local max = -1
	local num_seat
	local _seat = -1
	CreateRemoveThread(true, 'change_vehicle_seat', function()
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
						entities.request_control(veh, function()
							PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, seat)
						end)
						if VEHICLE.GET_PED_IN_VEHICLE_SEAT(veh, seat, true) ~= PLAYER.PLAYER_PED_ID() then return end
						return POP_THREAD
					end)
				end)
			end
			local hash = ENTITY.GET_ENTITY_MODEL(veh)
			max = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(hash) - 2
			ui.set_num_max(num_seat, max)
			local _seat = vehicles.get_ped_seat(PLAYER.PLAYER_PED_ID())
			if _seat then
				ui.set_value(num_seat, _seat, true)
			end
		elseif num_seat then
			ui.remove(num_seat)
			num_seat = nil
		end
	end)
end

---------------------------------------------------------------------------------------------------------------------------------
-- World
---------------------------------------------------------------------------------------------------------------------------------

__submenus["World"] = ui.add_submenu(TRANSLATION["World"])
__suboptions["World"] = ui.add_sub_option(TRANSLATION["World"], main_submenu, __submenus["World"])

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
			CreateRemoveThread(true, 'clear_area', function()
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
				system.notify(TRANSLATION['Info'], 'Clear area finished', 0, 255, 0, 255)
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
		CreateRemoveThread(bool, 'attach_blackhole', function()
			blackhole_pos = vector3(features.get_player_coords())
		end)
	end)

	local x = ui.add_num_option('X', __submenus["BlackHole"], -100000, 100000, 10, function(int) blackhole_pos.x = int end)
	local y = ui.add_num_option('Y', __submenus["BlackHole"], -100000, 100000, 10, function(int) blackhole_pos.y = int end)
	local z = ui.add_num_option('Z', __submenus["BlackHole"], -100000, 100000, 10, function(int) blackhole_pos.z = int end)

	__options.num["BlackHoleDistance"] = ui.add_num_option(TRANSLATION['Distance'], __submenus["BlackHole"], 0, 100000, 10, function(int) blackhole_dist = int
		settings.World["BlackHoleDistance"] = int
	end)

	CreateRemoveThread(true, 'black_hole_position', function(tick)
		ui.set_value(x, blackhole_pos.x, true)
		ui.set_value(y, blackhole_pos.y, true)
		ui.set_value(z, blackhole_pos.z, true)
		ui.set_value(x, blackhole_pos.x, false)
		ui.set_value(y, blackhole_pos.y, false)
		ui.set_value(z, blackhole_pos.z, false)
	end)

	__options.bool['BlackHoleSuckIn'] = ui.add_bool_option(TRANSLATION['Suck in'], __submenus["BlackHole"], function(bool) settings.World["BlackHoleSuckIn"] = bool end)

	__options.bool['BlackHole'] = ui.add_bool_option(TRANSLATION['Enable blackhole'], __submenus["BlackHole"], function(bool)
		CreateRemoveThread(bool, 'black_hole', function()
			local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
			for _, v in ipairs(features.get_entities())
			do
				if ((ENTITY.IS_ENTITY_A_PED(v) == 1 and on_peds) or (ENTITY.IS_ENTITY_A_VEHICLE(v) == 1 and on_vehs) or (ENTITY.IS_ENTITY_AN_OBJECT(v) == 1 and on_obj)) and PED.IS_PED_A_PLAYER(v) == NULL then
					local pos = vector3(ENTITY.GET_ENTITY_COORDS(v, false))
					local distance = pos:sqrlen(blackhole_pos)
					if distance <= math.pow(blackhole_dist, 2) then
						if not ((v == veh1 or v == veh2) and ENTITY.IS_ENTITY_A_VEHICLE(v) == 1) then
							entities.request_control(v, function()
								if ENTITY.IS_ENTITY_A_PED(v) == 1 and PED.IS_PED_A_PLAYER(v) == NULL then
									PED.SET_PED_TO_RAGDOLL(v, 5000, 5000, 0, true, true, false)
								end
								if distance > 36 then
									pos = vector3(ENTITY.GET_ENTITY_COORDS(v, false))
									local dir = pos:direction_to(blackhole_pos) * blackhole_force
									ENTITY.FREEZE_ENTITY_POSITION(v, false)
									ENTITY.SET_ENTITY_VELOCITY(v, dir.x, dir.y, dir.z)
									if ENTITY.GET_ENTITY_HEALTH(v) == 0 then
										ENTITY.SET_ENTITY_COLLISION(v, false, true)
									end
								else
									ENTITY.FREEZE_ENTITY_POSITION(v, true)
									if settings.World["BlackHoleSuckIn"] then
										features.delete_entity(v)
									end
								end
							end)
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
						entities.request_control(v, function()
							if ENTITY.GET_ENTITY_HEALTH(v) == 0 then
								ENTITY.SET_ENTITY_COLLISION(v, true, true)
							end
							if distance <= 100 then
								ENTITY.FREEZE_ENTITY_POSITION(v, false)
								local pos = vector3(ENTITY.GET_ENTITY_COORDS(v, false))
								local dir = blackhole_pos:direction_to(pos) * 100
								ENTITY.SET_ENTITY_VELOCITY(v, dir.x, dir.y, dir.z)
							end
						end)
					end
				end
			end
		end
	end)
end

__submenus["Vehicles"] = ui.add_submenu(TRANSLATION["Vehicles"])
__suboptions["Vehicles"] = ui.add_sub_option(TRANSLATION["Vehicles"], __submenus["World"] , __submenus["Vehicles"])

ui.add_click_option(TRANSLATION["Repair vehicles"], __submenus["Vehicles"], function()
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

__options.bool['Beyblades'] = ui.add_bool_option(TRANSLATION["Beyblades"], __submenus["Vehicles"], function(bool)
	CreateRemoveThread(bool, 'beyblades', function()
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 then
				entities.request_control(v, function()
					VEHICLE.SET_VEHICLE_REDUCE_GRIP(v, true)
					ENTITY.APPLY_FORCE_TO_ENTITY(v, 1, 1, 0, 0, 100, 100, 0, 0, true, true, true, false, true)
				end)
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

__options.bool['JumpyVehicles'] = ui.add_bool_option(TRANSLATION["Jumpy vehicles"], __submenus["Vehicles"], function(bool)
	CreateRemoveThread(bool, 'jumpy_vehicles', function(tick)
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 then
				entities.request_control(v, function()
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
				end)
			end
		end
	end)
end)

__options.bool['LaunchVehicles'] = ui.add_bool_option(TRANSLATION["Launch vehicles"], __submenus["Vehicles"], function(bool)
	CreateRemoveThread(bool, 'launch_vehicles', function(tick)
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 then
				entities.request_control(v, function()
					ENTITY.FREEZE_ENTITY_POSITION(v, false)
					ENTITY.SET_ENTITY_VELOCITY(v, 0, 0, 100)
				end)
			end
		end
	end)
end)

__options.bool['HornHavoc'] = ui.add_bool_option(TRANSLATION["Horn havoc"], __submenus["Vehicles"], function(bool)
	CreateRemoveThread(bool, 'horn_havoc', function(tick)
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 then
				entities.request_control(v, function()
					VEHICLE.START_VEHICLE_HORN(v, 3000, 0, false)
				end)
			end
		end
	end)
end)

__options.bool['HornBoosting'] = ui.add_bool_option(TRANSLATION["Horn boosting"], __submenus["Vehicles"], function(bool)
	CreateRemoveThread(bool, 'horn_boosting', function(tick)
		local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
		for _, v in ipairs(entities.get_vehs())
		do
			if v ~= veh1 and v ~= veh2 then
				entities.request_control(v, function()
					if AUDIO.IS_HORN_ACTIVE(v) == 1 then
						local speed = ENTITY.GET_ENTITY_SPEED(v)
						VEHICLE.SET_VEHICLE_FORWARD_SPEED(v, speed + speed * .05 + 1)
					end
				end)
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
			CreateRemoveThread(true, 'ufo_delete', function()
				for _, v in ipairs(features.get_entities())
				do
					entities.request_control(v, function()
						if ENTITY.GET_ENTITY_HEALTH(v) == 0 then
							ENTITY.SET_ENTITY_COLLISION(v, true, true)
						end
					end)
				end
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

		CreateRemoveThread(bool, 'ufo', function()
			local pos = vector3(features.get_offset_from_player_coords(vector3(0, 200, 0)))
			if not ufo then 
				local loaded, hash = features.request_model(utils.joaat('p_spinning_anus_s'), false)
				if loaded == NULL then return end
				if not spawned then 
					pos = vector3(pos.x + 1000, pos.y, pos.z + 1000) 
				else
					pos = ufo_position
				end
				ufo = entities.create_object(hash, pos)
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
			for _, v in ipairs(features.get_entities())
			do
				if v ~= me and v ~= veh1 and v ~= veh2 and v ~= ufo then
					entities.request_control(v, function()
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
							if ENTITY.GET_ENTITY_HEALTH(v) == 0 then
								ENTITY.SET_ENTITY_COLLISION(v, false, true)
							end
						end
					end)
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
		CreateRemoveThread(bool, 'tornado', function()
			local veh1, veh2 = vehicles.get_player_vehicle(), vehicles.get_personal_vehicle()
			local sqrdistance = math.pow(distance, 2)
			for _, v in ipairs(features.get_entities())
			do
				if v ~= veh1 and v ~= veh2 and PED.IS_PED_A_PLAYER(v) == NULL then
					local pos = vector3(ENTITY.GET_ENTITY_COORDS(v, false))
					if pos:sqrlen(tornado_pos) <= sqrdistance then
						entities.request_control(v, function()
							if ENTITY.IS_ENTITY_A_PED(v) == 1 then
								PED.SET_PED_TO_RAGDOLL(v, 5000, 5000, 0, true, true, false)
							end
							pos = vector3(ENTITY.GET_ENTITY_COORDS(v, false))
							local offset = vector3.point_on_circle(pos:direction_to(tornado_pos):angle() + math.rad(angle), 100)
							local final_pos = pos:direction_to(tornado_pos+offset) * force
							ENTITY.FREEZE_ENTITY_POSITION(v, false)
							ENTITY.SET_ENTITY_VELOCITY(v, final_pos.x, final_pos.y, .3)
						end)
					end
				end
			end
		end)
	end)
end

__options.bool['DisablePedSpawn'] = ui.add_bool_option(TRANSLATION["Disable ped spawn"], __submenus["World"], function(bool)
	settings.World['DisablePedSpawn'] = bool
	CreateRemoveThread(bool, 'disable_peds', function(tick)
		PED.SET_PED_DENSITY_MULTIPLIER_THIS_FRAME(0)
	end)
end)

__options.bool['DisableVehicleSpawn'] = ui.add_bool_option(TRANSLATION["Disable vehicle spawn"], __submenus["World"], function(bool)
	settings.World['DisableVehicleSpawn'] = bool
	CreateRemoveThread(bool, 'disable_vehicles', function(tick)
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
	CreateRemoveThread(true, 'get_waves_intensity', function()
		scaler = WATER.GET_DEEP_OCEAN_SCALER()
		ui.set_value(opt, math.floor(scaler * 100), true)
	end)
end

do
	local scaler = 0
	opt = ui.add_num_option(TRANSLATION["Set rain level"], __submenus["World"], -100, 50, 1, function(int)
		MISC._SET_RAIN_LEVEL(int/100)
	end)
	CreateRemoveThread(true, 'get_rain_intensity', function()
		scaler = MISC.GET_RAIN_LEVEL()
		ui.set_value(opt, math.floor(scaler * 100), true)
	end)
end

do
	local scaler = 0
	opt = ui.add_num_option(TRANSLATION["Set wind speed"], __submenus["World"], -100, 100, 1, function(int)
		MISC.SET_WIND_SPEED(int/100)
	end)
	CreateRemoveThread(true, 'get_wind_intensity', function()
		scaler = MISC.GET_WIND_SPEED()
		ui.set_value(opt, math.floor(scaler * 100), true)
	end)
end

---------------------------------------------------------------------------------------------------------------------------------
-- Teleport
---------------------------------------------------------------------------------------------------------------------------------

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
	local useGroundZ
	local z
	for i = 0, 100
	do
		local testZ = (i * 10.0) - 100.0
		features.teleport(entity, coords.x, coords.y, testZ)
		system.yield()
		local ptr = memory.malloc(4)
		useGroundZ = MISC.GET_GROUND_Z_FOR_3D_COORD(coords.x, coords.y, testZ, ptr, false, false)
		groundZ = memory.read_float(ptr)
		memory.free(ptr)
		if useGroundZ == 1 then
			break
		end
	end
	if useGroundZ == 1 then
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
				if ENTITY.IS_ENTITY_A_PED(entity) == 1 and ENTITY.IS_ENTITY_DEAD(entity, false) == NULL then
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
						--PAD._SET_CONTROL_NORMAL(0, enum.input.ATTACK, 1)

						local coord = ENTITY.GET_WORLD_POSITION_OF_ENTITY_BONE(entity, PED.GET_PED_BONE_INDEX(entity, bone_id[settings.Weapons["AimBone"]]))
						if coord.x ~= 0 and coord.y ~= 0 and coord.z ~= 0 then
							PED.SET_PED_SHOOTS_AT_COORD(PLAYER.PLAYER_PED_ID(), coord.x, coord.y, coord.z, true)
						end
					end
				end
			end
		end)
	end)
end

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
				CreateRemoveThread(true, 'seat_change_'..thread_count, function(tick)
					if tick == 100 then return POP_THREAD end
					if ped and ped ~= PLAYER.PLAYER_PED_ID() and veh ~= NULL then
						TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
					end
					entities.request_control(veh, function() 
						PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), veh, -1)
					end)
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
		CreateRemoveThread(bool, 'pickup_gun',
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
        entities.request_control(entity, function()
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
        end)
			elseif entity then
				entity = nil
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
		CreateRemoveThread(bool, 'gravity_gun',
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
        entities.request_control(entity, function()
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
					local pos = vector3(ENTITY.GET_ENTITY_COORDS(entity, false))
					local force_to = (target_pos - pos) * 20
					ENTITY.FREEZE_ENTITY_POSITION(entity, false)
					ENTITY.SET_ENTITY_VELOCITY(entity, force_to.x, force_to.y, force_to.z)
					if PAD.IS_CONTROL_JUST_PRESSED(0, enum.input.ATTACK2) == 1 then
						if ENTITY.IS_ENTITY_A_PED(entity) == 1 then
							PED.SET_PED_TO_RAGDOLL(entity, 5000, 5000, 0, true, true, false)
						end
						local force = dir * 500
						ENTITY.FREEZE_ENTITY_POSITION(entity, false)
            ENTITY.SET_ENTITY_VELOCITY(entity, force.x, force.y, force.z)
            gunactive = true
	        end
        end)
			elseif entity then
				entity = nil
			end
			gunactive = false
		end)
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
	__options.choose["VehicleGun"] = ui.add_choose(TRANSLATION["Vehicle gun"], __submenus["Weapons"], true, vehs, function(int) settings.Weapons["VehicleGun"] = int end)

	CreateRemoveThread(true, 'vehicle_gun', function()
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

	CreateRemoveThread(true, 'vehicle_tracker', function()
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

	local action = {TRANSLATION["None"], TRANSLATION["On aim"], TRANSLATION["On shoot"]}

	__options.choose["DeleteGun"] = ui.add_choose(TRANSLATION["Delete gun"], __submenus["Weapons"], true, action, function(int) settings.Weapons["DeleteGun"] = int end)
	__options.choose["PushGun"] = ui.add_choose(TRANSLATION["Push gun"], __submenus["Weapons"], true, action, function(int) settings.Weapons["PushGun"] = int end)
	__options.choose["ExplodeGun"] = ui.add_choose(TRANSLATION["Explode gun"], __submenus["Weapons"], true, action, function(int) settings.Weapons["ExplodeGun"] = int end)
	__options.choose["PaintGun"] = ui.add_choose(TRANSLATION["Paint gun"], __submenus["Weapons"], true, action, function(int) settings.Weapons["PaintGun"] = int end)

	CreateRemoveThread(true, 'guns', function()
		if PLAYER.IS_PLAYER_FREE_AIMING(PLAYER.PLAYER_ID()) == NULL and PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) == NULL then return end
		local ent = features.get_aimed_entity()
		if ent == NULL then return end
		if ENTITY.IS_ENTITY_A_PED(ent) == 1 and PED.IS_PED_IN_ANY_VEHICLE(ent, true) == 1 then
			ent = PED.GET_VEHICLE_PED_IS_IN(ent, false)
		end
		local cam_dir = vector3(CAM.GET_GAMEPLAY_CAM_ROT(2)):rot_to_direction()

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

__submenus["Misc"] = ui.add_submenu(TRANSLATION["Misc"])
__suboptions["Misc"] = ui.add_sub_option(TRANSLATION["Misc"], main_submenu, __submenus["Misc"])

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
	CreateRemoveThread(bool, 'disable_cam_center',
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

---------------------------------------------------------------------------------------------------------------------------------
-- Recovery
---------------------------------------------------------------------------------------------------------------------------------

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
	local hash

	for _, v in ipairs(enum.stats)
	do
		table.insert(stats, v.name)
	end

	__options.choose["StatName"] = ui.add_choose(TRANSLATION["Stat"], __submenus["StatEditor"], true, stats, function(int) stat = int + 1 end)

	-- __options.bool["Bool"] = ui.add_bool_option(TRANSLATION["Bool"], __submenus["StatEditor"], function(bool) _bool = bool end)
	-- __options.bool["Int"] = ui.add_bool_option(TRANSLATION["Int"], __submenus["StatEditor"], function(bool) _int = bool end)
	-- __options.bool["Float"] = ui.add_bool_option(TRANSLATION["Float"], __submenus["StatEditor"], function(bool) _float = bool end)
	__options.num["StatValue"] = ui.add_num_option(TRANSLATION["Value"], __submenus["StatEditor"], -4294967295, 4294967295, 1, function(int) value = int end)

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

---------------------------------------------------------------------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------------------------------------------------------------------

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

ui.add_click_option(string.format(TRANSLATION['%s for scripting'], 'SATTY'), __submenus["Credits"], function() end)
ui.add_click_option(string.format(TRANSLATION['%s for bug finding'], 'Dr Donger'), __submenus["Credits"], function() end)
ui.add_click_option(string.format(TRANSLATION['%s for improving lua API'], 'ItsPxel'), __submenus["Credits"], function() end)
if TRANSLATION[1]['Credits'] ~= string.empty then
	ui.add_click_option(string.format(TRANSLATION['%s for translation'],TRANSLATION[1]['Credits']), __submenus["Credits"], function() end)
end

for _, v in pairs(__options.bool) do
	ui.set_value(v, false, true)
end

LoadConfTog(settings)

do
	local scaleform = GRAPHICS.REQUEST_SCALEFORM_MOVIE("mp_big_message_freemode")
  while GRAPHICS.HAS_SCALEFORM_MOVIE_LOADED(scaleform) == NULL
  do 
    system.yield()
  end
  system.log('Imagined Menu', 'Loaded successfully')
	system.notify('Imagined Menu', string.format(TRANSLATION["Welcome %s to Imagined Menu!"]..'\nVersion %s\nCredits to %s, %s and %s', PLAYER.GET_PLAYER_NAME(PLAYER.PLAYER_ID()), VERSION, 'SATTY', 'Dr Donger', 'ItsPxel'), 0, 255, 0, 255)
  AUDIO.PLAY_SOUND_FRONTEND(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", true)
  local pos1 = features.get_offset_from_player_coords(vector3(3, 3, .5))
  local pos2 = features.get_offset_from_player_coords(vector3(-3, 3, .5))
  FIRE.ADD_EXPLOSION(pos1.x, pos1.y, pos1.z, enum.explosion.EXP_TAG_FIREWORK, 1, false, false, .0, true)
  FIRE.ADD_EXPLOSION(pos2.x, pos2.y, pos2.z, enum.explosion.EXP_TAG_FIREWORK, 1, false, false, .0, true)

  local t = os.clock() + 2.5
  CreateRemoveThread(true, 'start', function()
		if os.clock() <= t then
	    GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
	    GRAPHICS.DRAW_SCALEFORM_MOVIE_FULLSCREEN(scaleform, 0, 0, 0, 0, 0)
	    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING('~p~'..TRANSLATION["Welcome"])
	    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING(string.format('~b~'..TRANSLATION["Welcome %s to Imagined Menu!"], PLAYER.GET_PLAYER_NAME(PLAYER.PLAYER_ID())))
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
	if tick%50~=NULL then return end

	ui.set_value(__options.num["Set Alpha"], ENTITY.GET_ENTITY_ALPHA(PLAYER.PLAYER_PED_ID()), true)

	if vehicles.get_player_vehicle() ~= NULL then
		local val = false
		if ENTITY.IS_ENTITY_VISIBLE(PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(PLAYER.PLAYER_ID()), false)) == NULL then
			val = true
		end
		ui.set_value(__options.bool["InvisibleVehicle"], val, true)
	end
end)
local last_ticks = {}
local time = 0

while true 
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
