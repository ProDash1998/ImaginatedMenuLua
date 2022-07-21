--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--

-- Global to local
local random = math.random
local insert = table.insert
local type = type
local require = require
local tonumber = tonumber
local tostring = tostring
local ipairs = ipairs
local memory = memory
local system = system
local EVENT = EVENT
local AUDIO = AUDIO
local PED = PED
local PLAYER = PLAYER
local VEHICLE = VEHICLE
local NETWORK = NETWORK
local STREAMING = STREAMING
local utils = utils
local entities = entities
local globals = globals
local ui = ui
local ENTITY = ENTITY
local DECORATOR = DECORATOR

local features = require 'features'
local TRANSLATION = require('default').translation
local settings = require('default').settings
local s_memory = require 'script_memory'
local switch = require 'switch'
local vector3 = require 'vector3'
local enum = require 'enums'
local json = require 'JSON'
local file = require 'filesys'
local NULL = 0
local vehicles = {}
vehicles.class = {}
vehicles.class_manufacturer = {}
vehicles.class_hash = {}
vehicles.data = json:decode(file.read_all(files['VehData']))
vehicles.models = {}

vehicles.colors = {
    {255, 255, 255},
    {2, 21, 255},
    {3, 83, 255},
    {0, 255, 140},
    {94, 255, 1},
    {255, 255, 0},
    {255, 150, 5},
    {255, 62, 0},
    {255, 1, 1},
    {255, 50, 100},
    {255, 5, 190},
    {35, 1, 255},
    {15, 3, 255}
}

function vehicles.xenon_names()
    return {
        TRANSLATION["None"],
        TRANSLATION["White"],
        TRANSLATION["Blue"],
        TRANSLATION["Electric Blue"],
        TRANSLATION["Mint Green"],
        TRANSLATION["Lime Green"],
        TRANSLATION["Yellow"],
        TRANSLATION["Golden Shower"],
        TRANSLATION["Orange"],
        TRANSLATION["Red"],
        TRANSLATION["Pony Pink"],
        TRANSLATION["Hot Pink"],
        TRANSLATION["Purple"],
        TRANSLATION["Blacklight"]
    }
end

function vehicles.door_index()
    return {
        [0] = TRANSLATION["Driver's Front Door"],
        [1] = TRANSLATION["Passenger's Front Door"],
        [2] = TRANSLATION["Driver's Rear Door"],
        [3] = TRANSLATION["Passenger's Rear Door"],
        [4] = TRANSLATION["Vehicle Hood"],
        [5] = TRANSLATION["Vehicle Trunk"]
    }
end
-- vehicles.paint_classic = {}
-- for _, v in ipairs(enum.vehicle_color_classic)
-- do
--     insert(vehicles.paint_classic, v[1])
-- end
-- vehicles.paint_worn = {}
-- for _, v in ipairs(enum.vehicle_color_worn)
-- do
--     insert(vehicles.paint_worn, v[1])
-- end
-- vehicles.paint_util = {}
-- for _, v in ipairs(enum.vehicle_color_util)
-- do
--     insert(vehicles.paint_util, v[1])
-- end
-- vehicles.paint_matte = {}
-- for _, v in ipairs(enum.vehicle_color_matte)
-- do
--     insert(vehicles.paint_matte, v[1])
-- end
-- vehicles.paint_metal = {}
-- for _, v in ipairs(enum.vehicle_color_metal)
-- do
--     insert(vehicles.paint_metal, v[1])
-- end

local function hash_to_string(hash)
    for _, v in ipairs(vehicles.models) do
        if v[2] == hash then return v[1] end
    end
    return
end

local function HudSound(name)
    if not settings.General["HudSounds"] then return end
    CreateRemoveThread(true, 'play_hud_sound', function()
        AUDIO.PLAY_SOUND_FRONTEND(-1, name, "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        return 0
    end)
end

function vehicles.spawn_vehicle(hashname, pos, heading)
    local hash = 0
	if tonumber(hashname) then 
		hash = tonumber(hashname) 
	else
		hash = utils.joaat(hashname)
	end 
	if STREAMING.IS_MODEL_VALID(hash) == NULL then return NULL end
	local vehicle = entities.create_vehicle(hash, pos.x, pos.y, pos.z)
    -- ENTITY.SET_ENTITY_AS_MISSION_ENTITY(vehicle, false, true)
    if heading then
        ENTITY.SET_ENTITY_HEADING(vehicle, heading)
    end
    -- if NETWORK.NETWORK_IS_SESSION_STARTED() == 1 then
    --     DECORATOR.DECOR_SET_INT(vehicle, "MPBitset", 1024)
    -- end
    return vehicle
end

function vehicles.get_label_name(hashname)
    if not hashname then return 'NULL' end
    local hash = 0
    if tonumber(hashname) then 
        hash = tonumber(hashname) 
    else
        hash = utils.joaat(hashname)
    end 
    if STREAMING.IS_MODEL_VALID(hash) == NULL then return 'NULL' end
    local label = HUD._GET_LABEL_TEXT(VEHICLE.GET_DISPLAY_NAME_FROM_VEHICLE_MODEL(hash))
    return label
end

-- function vehicles.get_mod_slot_name(veh, modtype, gtx)
--     local name
--     if modtype >= 0 and modtype < #enum.vehicle_mod_slot_names then
--         local model = ENTITY.GET_ENTITY_MODEL(veh)
--         local ModType = switch()
--             :case(3, function()
--                 return model == utils.joaat("faggio3") and "TOP_ARCHCOVER" or VEHICLE.IS_THIS_MODEL_A_BIKE(model) and "CMM_MOD_S15" or enum.vehicle_mod_slot_names[modtype]
--             end)
--             :case(10, function()
--                 return model == utils.joaat("bagger") and "CMOD_SB_T" or "CMOD_MOD_ROF"
--             end)
--             :case(40, function()
--                 return model == utils.joaat("sultanrs") and "CMM_MOD_S15b" or enum.vehicle_mod_slot_names[modtype]
--             end)
--             :case(41, function()
--                 return (model == utils.joaat("sultanrs") or model == utils.joaat("banshee2")) and "CMM_MOD_S16b" or enum.vehicle_mod_slot_names[modtype]
--             end)
--             :case(42, function()
--                 return model == utils.joaat("sultanrs") and "CMM_MOD_S17b" or enum.vehicle_mod_slot_names[modtype]
--             end)
--             :case(43, function()
--                 return model == utils.joaat("sultanrs") and "CMM_MOD_S18b" or enum.vehicle_mod_slot_names[modtype]
--             end)
--             :case(44, function()
--                 return model == utils.joaat("sultanrs") and "CMM_MOD_S19b" or enum.vehicle_mod_slot_names[modtype]
--             end)
--             :case(45, function()
--                 return model == utils.joaat("slamvan3") and "CMM_MOD_S27" or enum.vehicle_mod_slot_names[modtype]
--             end)
--             :case(46, function()
--                 return model == utils.joaat("btype3") and "CMM_MOD_S21b" or enum.vehicle_mod_slot_names[modtype]
--             end)
--             :case(47, function()
--                 return model == utils.joaat("slamvan3") and "SLVAN3_RDOOR" or enum.vehicle_mod_slot_names[modtype]
--             end)
--             :default(function()
--                 return enum.vehicle_mod_slot_names[modtype]
--             end)

--         name = ModType(veh)
--     else
--         name = "INVALID"
--     end
--     if gtx then
--         return HUD.DOES_TEXT_LABEL_EXIST(name) == 1 and HUD._GET_LABEL_TEXT(name) or name
--     end
--     return name
-- end

-- function vehicles.get_mod_text_label(veh, modtype, modvalue, gtx)
--     local brakes = {"Street ", "Sport ", "Race ", "Super "}
--     -- local armor = {"CMOD_ARM_1", "CMOD_ARM_2", "CMOD_ARM_3", "CMOD_ARM_4", "CMOD_ARM_5"}
--     local suspension = {"Lowered ", "Street ", "Sport ", "Competition ", "Race "}
--     local ModType = switch()
--         :case(11, function()
--             return "EMS Upgrade " .. modvalue + 1
--         end)
--         :case(12, function()
--             return modvalue >= #brakes and "Brakes " .. modvalue + 1 or brakes[modvalue + 1]
--         end)
--         :case(14, function()
--             return modvalue >= #horns and "Horn " .. modvalue + 1 or enum.horns[modvalue + 1]
--         end)
--         :case(15, function()
--             return modvalue >= #suspension and "Suspension " .. modvalue + 1 or suspension[modvalue + 1]
--         end)
--         :case(16, function()
--              return --[[modvalue >= #armor and--]] "Armor Upgrade " .. (modvalue + 1) * 20 .. "%" --[[or (gtx and HUD.DOES_TEXT_LABEL_EXIST(armor[modvalue + 1])) and HUD._GET_LABEL_TEXT(armor[modvalue + 1]) or "Armor Upgrade " .. (modvalue + 1) * 20 .. "%"--]]
--         end)

--     local result = ModType(modtype)
--     if result then
--         system.log('debug', result)
--         return result
--     end
--     local modname = VEHICLE.GET_MOD_TEXT_LABEL(veh, modtype, modvalue)
--     system.log('debug', modname)
--     if #modname > 3 then return (HUD.DOES_TEXT_LABEL_EXIST(modname) and gxt) and HUD._GET_LABEL_TEXT(modname) or modname end

--     return enum.vehicle_mod_slot_names[modtype] .. ' ' .. modvalue + 1
-- end

function vehicles.tuning_menu(veh, sub, parent, no_sub)
    if not no_sub then
        parent.sub_mods = ui.add_submenu(TRANSLATION["Vehicle customs"])
        parent.subopt_mods = ui.add_sub_option(TRANSLATION["Vehicle customs"], sub, parent.sub_mods)
    else
        ui.hide(parent.subopt_mods, false)
    end
    VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)
    parent.tune_preset = ui.add_choose(TRANSLATION["Presets"], parent.sub_mods, false, {TRANSLATION["Stock"], TRANSLATION["Max upgrade"], TRANSLATION["Max without livery"], TRANSLATION["Performance"], TRANSLATION["Performance with spoiler"]}, function(int)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("YES")
        entities.request_control(veh, function()
            VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)
            if int == 0 then
                vehicles.stock(veh)
            elseif int == 1 then
                vehicles.upgrade(veh)
            elseif int == 2 then
                vehicles.upgrade(veh)
                VEHICLE.SET_VEHICLE_MOD(veh, 48, -1, false)
            elseif int == 3 then
                vehicles.stock(veh)
                vehicles.performance(veh)
            elseif int == 4 then
                vehicles.stock(veh)
                vehicles.performance(veh)
                local num = VEHICLE.GET_NUM_VEHICLE_MODS(veh, 0) - 1
                VEHICLE.SET_VEHICLE_MOD(veh, 0, num, false)
            end
        end)
    end)
    parent.paint_primary_sub = ui.add_submenu(TRANSLATION["Primary color"])
    parent.paint_primary_subopt = ui.add_sub_option(TRANSLATION["Primary color"], parent.sub_mods, parent.paint_primary_sub)
    parent.paint_primary_classic_sub = ui.add_submenu(TRANSLATION["Classic"])
    parent.paint_primary_classic_subopt = ui.add_sub_option(TRANSLATION["Classic"], parent.paint_primary_sub, parent.paint_primary_classic_sub)
    for _, e in ipairs(enum.vehicle_color_classic)
    do
        parent["color_primary_"..e[2]] = ui.add_click_option(e[1], parent.paint_primary_classic_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                VEHICLE.CLEAR_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh)
                local prim, sec = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_COLOURS(veh, prim, sec)
                VEHICLE.SET_VEHICLE_COLOURS(veh, e[2], memory.read_int(sec))
            end)
        end)
    end
    parent.paint_primary_worn_sub = ui.add_submenu(TRANSLATION["Worn"])
    parent.paint_primary_worn_subopt = ui.add_sub_option(TRANSLATION["Worn"], parent.paint_primary_sub, parent.paint_primary_worn_sub)
    for _, e in ipairs(enum.vehicle_color_worn)
    do
        parent["color_primary_"..e[2]] = ui.add_click_option(e[1], parent.paint_primary_worn_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                VEHICLE.CLEAR_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh)
                local prim, sec = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_COLOURS(veh, prim, sec)
                VEHICLE.SET_VEHICLE_COLOURS(veh, e[2], memory.read_int(sec))
            end)
        end)
    end
    parent.paint_primary_util_sub = ui.add_submenu(TRANSLATION["Util"])
    parent.paint_primary_util_subopt = ui.add_sub_option(TRANSLATION["Util"], parent.paint_primary_sub, parent.paint_primary_util_sub)
    for _, e in ipairs(enum.vehicle_color_util)
    do
        parent["color_primary_"..e[2]] = ui.add_click_option(e[1], parent.paint_primary_util_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                VEHICLE.CLEAR_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh)
                local prim, sec = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_COLOURS(veh, prim, sec)
                VEHICLE.SET_VEHICLE_COLOURS(veh, e[2], memory.read_int(sec))
            end)
        end)
    end
    parent.paint_primary_matte_sub = ui.add_submenu(TRANSLATION["Matte"])
    parent.paint_primary_matte_subopt = ui.add_sub_option(TRANSLATION["Matte"], parent.paint_primary_sub, parent.paint_primary_matte_sub)
    for _, e in ipairs(enum.vehicle_color_matte)
    do
        parent["color_primary_"..e[2]] = ui.add_click_option(e[1], parent.paint_primary_matte_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                VEHICLE.CLEAR_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh)
                local prim, sec = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_COLOURS(veh, prim, sec)
                VEHICLE.SET_VEHICLE_COLOURS(veh, e[2], memory.read_int(sec))
            end)
        end)
    end
    parent.paint_primary_metal_sub = ui.add_submenu(TRANSLATION["Metal"])
    parent.paint_primary_metal_subopt = ui.add_sub_option(TRANSLATION["Metal"], parent.paint_primary_sub, parent.paint_primary_metal_sub)
    for _, e in ipairs(enum.vehicle_color_metal)
    do
        parent["color_primary_"..e[2]] = ui.add_click_option(e[1], parent.paint_primary_metal_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                VEHICLE.CLEAR_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh)
                local prim, sec = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_COLOURS(veh, prim, sec)
                VEHICLE.SET_VEHICLE_COLOURS(veh, e[2], memory.read_int(sec))
            end)
        end)
    end
    parent.paint_primary_select = ui.add_num_option(TRANSLATION["Color"], parent.paint_primary_sub,  0, 160, 1, function(int)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("YES")
        entities.request_control(veh, function()
            VEHICLE.CLEAR_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh)
            local prim, sec = s_memory.allocate(2)
            VEHICLE.GET_VEHICLE_COLOURS(veh, prim, sec)
            VEHICLE.SET_VEHICLE_COLOURS(veh, int, memory.read_int(sec))
        end)
    end)
    parent.paint_primary_rgb = ui.add_color_picker(TRANSLATION["RGB"], parent.paint_primary_sub, function(color)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        entities.request_control(veh, function()
            VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, color.r, color.g, color.b)
        end)
    end)
    parent.paint_primary_apply_choose = ui.add_choose(TRANSLATION["Apply to"], parent.paint_primary_sub, false, {TRANSLATION["Secondary"], TRANSLATION["Pearlescent"], TRANSLATION["Neon"], TRANSLATION["Wheel"]}, function(int)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("YES")
        local prim, sec = s_memory.allocate(2)
        VEHICLE.GET_VEHICLE_COLOURS(veh, prim, sec)
        if int == 0 then
            VEHICLE.SET_VEHICLE_COLOURS(veh, memory.read_int(prim), memory.read_int(prim))
            if VEHICLE.GET_IS_VEHICLE_PRIMARY_COLOUR_CUSTOM(veh) then
                local r, g, b = s_memory.allocate(3)
                VEHICLE.GET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, r, g, b)
                VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, memory.read_int(r), memory.read_int(g), memory.read_int(b))
            end
        elseif int == 1 then
            local pearl, wheel = s_memory.allocate(2)
            VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
            VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, memory.read_int(prim), memory.read_int(wheel))
        elseif int == 2 then
            local r, g, b = s_memory.allocate(3)
            VEHICLE.GET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, r, g, b)
            VEHICLE._SET_VEHICLE_NEON_LIGHTS_COLOUR(veh, memory.read_int(r), memory.read_int(g), memory.read_int(b))
        elseif int == 3 then
            local pearl, wheel = s_memory.allocate(2)
            VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
            VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, memory.read_int(pearl), memory.read_int(prim))
        end
    end)
    parent.paint_secondary_sub = ui.add_submenu(TRANSLATION["Secondary color"])
    parent.paint_secondary_subopt = ui.add_sub_option(TRANSLATION["Secondary color"], parent.sub_mods, parent.paint_secondary_sub)
    parent.paint_secondary_classic_sub = ui.add_submenu(TRANSLATION["Classic"])
    parent.paint_secondary_classic_subopt = ui.add_sub_option(TRANSLATION["Classic"], parent.paint_secondary_sub, parent.paint_secondary_classic_sub)
    for _, e in ipairs(enum.vehicle_color_classic)
    do
        parent["color_secondary_"..e[2]] = ui.add_click_option(e[1], parent.paint_secondary_classic_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                VEHICLE.CLEAR_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh)
                local prim, sec = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_COLOURS(veh, prim, sec)
                VEHICLE.SET_VEHICLE_COLOURS(veh, memory.read_int(prim), e[2])
            end)
        end)
    end
    parent.paint_secondary_worn_sub = ui.add_submenu(TRANSLATION["Worn"])
    parent.paint_secondary_worn_subopt = ui.add_sub_option(TRANSLATION["Worn"], parent.paint_secondary_sub, parent.paint_secondary_worn_sub)
    for _, e in ipairs(enum.vehicle_color_worn)
    do
        parent["color_secondary_"..e[2]] = ui.add_click_option(e[1], parent.paint_secondary_worn_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                VEHICLE.CLEAR_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh)
                local prim, sec = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_COLOURS(veh, prim, sec)
                VEHICLE.SET_VEHICLE_COLOURS(veh, memory.read_int(prim), e[2])
            end)
        end)
    end
    parent.paint_secondary_util_sub = ui.add_submenu(TRANSLATION["Util"])
    parent.paint_secondary_util_subopt = ui.add_sub_option(TRANSLATION["Util"], parent.paint_secondary_sub, parent.paint_secondary_util_sub)
    for _, e in ipairs(enum.vehicle_color_util)
    do
        parent["color_secondary_"..e[2]] = ui.add_click_option(e[1], parent.paint_secondary_util_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                VEHICLE.CLEAR_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh)
                local prim, sec = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_COLOURS(veh, prim, sec)
                VEHICLE.SET_VEHICLE_COLOURS(veh, memory.read_int(prim), e[2])
            end)
        end)
    end
    parent.paint_secondary_matte_sub = ui.add_submenu(TRANSLATION["Matte"])
    parent.paint_secondary_matte_subopt = ui.add_sub_option(TRANSLATION["Matte"], parent.paint_secondary_sub, parent.paint_secondary_matte_sub)
    for _, e in ipairs(enum.vehicle_color_matte)
    do
        parent["color_secondary_"..e[2]] = ui.add_click_option(e[1], parent.paint_secondary_matte_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                VEHICLE.CLEAR_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh)
                local prim, sec = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_COLOURS(veh, prim, sec)
                VEHICLE.SET_VEHICLE_COLOURS(veh, memory.read_int(prim), e[2])
            end)
        end)
    end
    parent.paint_secondary_metal_sub = ui.add_submenu(TRANSLATION["Metal"])
    parent.paint_secondary_metal_subopt = ui.add_sub_option(TRANSLATION["Metal"], parent.paint_secondary_sub, parent.paint_secondary_metal_sub)
    for _, e in ipairs(enum.vehicle_color_metal)
    do
        parent["color_secondary_"..e[2]] = ui.add_click_option(e[1], parent.paint_secondary_metal_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                VEHICLE.CLEAR_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh)
                local prim, sec = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_COLOURS(veh, prim, sec)
                VEHICLE.SET_VEHICLE_COLOURS(veh, memory.read_int(prim), e[2])
            end)
        end)
    end
    parent.paint_secondary_select = ui.add_num_option(TRANSLATION["Color"], parent.paint_secondary_sub,  0, 160, 1, function(int)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("YES")
        entities.request_control(veh, function()
            VEHICLE.CLEAR_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh)
            local prim, sec = s_memory.allocate(2)
            VEHICLE.GET_VEHICLE_COLOURS(veh, prim, sec)
            VEHICLE.SET_VEHICLE_COLOURS(veh, memory.read_int(prim), int)
        end)
    end)
    parent.paint_secondary_rgb = ui.add_color_picker(TRANSLATION["RGB"], parent.paint_secondary_sub, function(color)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        entities.request_control(veh, function()
            VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, color.r, color.g, color.b)
        end)
    end)
    parent.paint_secondary_apply_choose = ui.add_choose(TRANSLATION["Apply to"], parent.paint_secondary_sub, false, {TRANSLATION["Primary"], TRANSLATION["Pearlescent"], TRANSLATION["Neon"], TRANSLATION["Wheel"]}, function(int)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("YES")
        local prim, sec = s_memory.allocate(2)
        VEHICLE.GET_VEHICLE_COLOURS(veh, prim, sec)
        if int == 0 then
            VEHICLE.SET_VEHICLE_COLOURS(veh, memory.read_int(sec), memory.read_int(sec))
            if VEHICLE.GET_IS_VEHICLE_SECONDARY_COLOUR_CUSTOM(veh) then
                local r, g, b = s_memory.allocate(3)
                VEHICLE.GET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, r, g, b)
                VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, memory.read_int(r), memory.read_int(g), memory.read_int(b))
            end
        elseif int == 1 then
            local pearl, wheel = s_memory.allocate(2)
            VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
            VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, memory.read_int(sec), memory.read_int(wheel))
        elseif int == 2 then
            local r, g, b = s_memory.allocate(3)
            VEHICLE.GET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, r, g, b)
            VEHICLE._SET_VEHICLE_NEON_LIGHTS_COLOUR(veh, memory.read_int(r), memory.read_int(g), memory.read_int(b))
        elseif int == 3 then
            local pearl, wheel = s_memory.allocate(2)
            VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
            VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, memory.read_int(pearl), memory.read_int(sec))
        end
    end)
    parent.paint_pearlescent_sub = ui.add_submenu(TRANSLATION["Pearlescent"])
    parent.paint_pearlescent_subopt = ui.add_sub_option(TRANSLATION["Pearlescent"], parent.sub_mods, parent.paint_pearlescent_sub)
    parent.paint_pearlescent_classic_sub = ui.add_submenu(TRANSLATION["Classic"])
    parent.paint_pearlescent_classic_subopt = ui.add_sub_option(TRANSLATION["Classic"], parent.paint_pearlescent_sub, parent.paint_pearlescent_classic_sub)
    for _, e in ipairs(enum.vehicle_color_classic)
    do
        parent["color_pearlescent_"..e[2]] = ui.add_click_option(e[1], parent.paint_pearlescent_classic_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                local pearl, wheel = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
                VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, e[2], memory.read_int(wheel))
            end)
        end)
    end
    parent.paint_pearlescent_worn_sub = ui.add_submenu(TRANSLATION["Worn"])
    parent.paint_pearlescent_worn_subopt = ui.add_sub_option(TRANSLATION["Worn"], parent.paint_pearlescent_sub, parent.paint_pearlescent_worn_sub)
    for _, e in ipairs(enum.vehicle_color_worn)
    do
        parent["color_pearlescent_"..e[2]] = ui.add_click_option(e[1], parent.paint_pearlescent_worn_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                local pearl, wheel = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
                VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, e[2], memory.read_int(wheel))
            end)
        end)
    end
    parent.paint_pearlescent_util_sub = ui.add_submenu(TRANSLATION["Util"])
    parent.paint_pearlescent_util_subopt = ui.add_sub_option(TRANSLATION["Util"], parent.paint_pearlescent_sub, parent.paint_pearlescent_util_sub)
    for _, e in ipairs(enum.vehicle_color_util)
    do
        parent["color_pearlescent_"..e[2]] = ui.add_click_option(e[1], parent.paint_pearlescent_util_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                local pearl, wheel = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
                VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, e[2], memory.read_int(wheel))
            end)
        end)
    end
    parent.paint_pearlescent_matte_sub = ui.add_submenu(TRANSLATION["Matte"])
    parent.paint_pearlescent_matte_subopt = ui.add_sub_option(TRANSLATION["Matte"], parent.paint_pearlescent_sub, parent.paint_pearlescent_matte_sub)
    for _, e in ipairs(enum.vehicle_color_matte)
    do
        parent["color_pearlescent_"..e[2]] = ui.add_click_option(e[1], parent.paint_pearlescent_matte_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                local pearl, wheel = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
                VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, e[2], memory.read_int(wheel))
            end)
        end)
    end
    parent.paint_pearlescent_metal_sub = ui.add_submenu(TRANSLATION["Metal"])
    parent.paint_pearlescent_metal_subopt = ui.add_sub_option(TRANSLATION["Metal"], parent.paint_pearlescent_sub, parent.paint_pearlescent_metal_sub)
    for _, e in ipairs(enum.vehicle_color_metal)
    do
        parent["color_pearlescent_"..e[2]] = ui.add_click_option(e[1], parent.paint_pearlescent_metal_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                local pearl, wheel = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
                VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, e[2], memory.read_int(wheel))
            end)
        end)
    end
    parent.paint_pearlescent_select = ui.add_num_option(TRANSLATION["Color"], parent.paint_pearlescent_sub, 0, 160, 1, function(int)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("YES")
        entities.request_control(veh, function()
            local pearl, wheel = s_memory.allocate(2)
            VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
            VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, int, memory.read_int(wheel))
        end)
    end)
    for i = 0, 48
    do
        if i < 17 or i > 24 then
            local num_mod = VEHICLE.GET_NUM_VEHICLE_MODS(veh, i)
            if num_mod ~= 0 then
                -- local values = {
                --  TRANSLATION["Default"]
                -- }
                -- for j = 0, num_mod - 1
                -- do
                --  insert(values, tostring(vehicles.get_mod_text_label(veh, i, j, true)))
                -- end
                parent["veh_mod_"..i] = ui.add_num_option(enum.vehicle_mod_slot_names[i], parent.sub_mods, 0, num_mod, 1, function(type)
                    if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
                    HudSound("YES")
                    entities.request_control(veh, function()
                        VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)
                        VEHICLE.SET_VEHICLE_MOD(veh, i, type - 1, false)
                    end)
                end)
            end
        end
    end
    parent.turbo = ui.add_bool_option(TRANSLATION["Turbo tuning"], parent.sub_mods, function(bool)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("TOGGLE_ON")
        entities.request_control(veh, function()
            VEHICLE.TOGGLE_VEHICLE_MOD(veh, 18, bool)
        end)
    end)
    parent.tyre_smoke = ui.add_bool_option(TRANSLATION["Tire smoke"], parent.sub_mods, function(bool)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("TOGGLE_ON")
        entities.request_control(veh, function()
            VEHICLE.TOGGLE_VEHICLE_MOD(veh, 20, bool)
        end)
    end)
    parent.xenons = ui.add_bool_option(TRANSLATION["Xenon lights"], parent.sub_mods, function(bool)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("TOGGLE_ON")
        entities.request_control(veh, function()
            VEHICLE.TOGGLE_VEHICLE_MOD(veh, 22, bool)
        end)
    end)
    parent.bulletproof_tires = ui.add_bool_option(TRANSLATION["Bulletproof tires"], parent.sub_mods, function(bool)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("TOGGLE_ON")
        entities.request_control(veh, function()
            VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh, not bool)
        end)
    end)
    parent.licence_sep = ui.add_separator(TRANSLATION["Licence plate"], parent.sub_mods)
    parent.licence_index = ui.add_choose(TRANSLATION["Index"], parent.sub_mods, true, enum.plate_index, function(type)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("YES")
        entities.request_control(veh, function()
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, type)
        end)
    end)
    parent.licence_text = ui.add_input_string(TRANSLATION["Text"], parent.sub_mods, function(text)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        entities.request_control(veh, function()
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(veh, text:sub(1,8))
        end)
        ui.set_value(parent.licence_text, text:sub(1,8):upper(), true)
    end)
    parent.extra_separator = ui.add_separator(TRANSLATION["Extra"], parent.sub_mods)
    local found
    for i = 0, 20
    do
        if VEHICLE.DOES_EXTRA_EXIST(veh, i) == 1 then
            found = true
            parent["extra_"..i] = ui.add_bool_option(TRANSLATION["Extra"]..' '..i, parent.sub_mods, function(bool)
                if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
                HudSound("TOGGLE_ON")
                entities.request_control(veh, function()
                    VEHICLE.SET_VEHICLE_EXTRA(veh, i, not bool)
                end)
            end)
        end
    end
    if not found then
        ui.remove(parent.extra_separator)
        parent.extra_separator = nil
    end
    parent.other_separator = ui.add_separator(TRANSLATION["Other"], parent.sub_mods)
    parent.window_tint = ui.add_choose(TRANSLATION["Window tint"], parent.sub_mods, true, {TRANSLATION["None"], TRANSLATION["Black"], TRANSLATION["Dark smoke"], TRANSLATION["Light smoke"], TRANSLATION["Stock"], TRANSLATION["Limo"], TRANSLATION["Green"]}, function(int)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("YES")
        entities.request_control(veh, function()
            VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, int)
        end)
    end)
    parent.xenon_color = ui.add_choose(TRANSLATION["Xenon color"], parent.sub_mods, true, vehicles.xenon_names(), function(int)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("YES")
        entities.request_control(veh, function()
            VEHICLE._SET_VEHICLE_XENON_LIGHTS_COLOR(veh, int - 1)
        end)
    end)
    parent.interior_color = ui.add_choose(TRANSLATION["Interior color"], parent.sub_mods, true, enum.vehicle_color, function(int)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("YES")
        entities.request_control(veh, function()
            VEHICLE._SET_VEHICLE_INTERIOR_COLOR(veh, int)
        end)
    end)
    parent.dashboard_color = ui.add_choose(TRANSLATION["Dashboard color"], parent.sub_mods, true, enum.vehicle_color, function(int)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("YES")
        entities.request_control(veh, function()
            VEHICLE._SET_VEHICLE_DASHBOARD_COLOR(veh, int)
        end)
    end)
    parent.neon_sub = ui.add_submenu(TRANSLATION["Neon lights"])
    parent.neon_subopt = ui.add_sub_option(TRANSLATION["Neon lights"], parent.sub_mods, parent.neon_sub)
    for i, v in ipairs({TRANSLATION["Left"], TRANSLATION["Right"], TRANSLATION["Front"], TRANSLATION["Back"]})
    do
        parent['neon_'..i-1] = ui.add_bool_option(v, parent.neon_sub, function(bool)
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("TOGGLE_ON")
            entities.request_control(veh, function()
                VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(veh, i - 1, bool)
            end)
        end)
    end
    parent.neon_rgb = ui.add_color_picker(TRANSLATION["Color"], parent.neon_sub, function(color)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        entities.request_control(veh, function()
            VEHICLE._SET_VEHICLE_NEON_LIGHTS_COLOUR(veh, color.r, color.g, color.b)
        end)
    end)
    parent.wheel_sub = ui.add_submenu(TRANSLATION["Wheels"])
    parent.wheel_subopt = ui.add_sub_option(TRANSLATION["Wheels"], parent.sub_mods, parent.wheel_sub)
    local model = ENTITY.GET_ENTITY_MODEL(veh)
    parent.custom_wheels = ui.add_bool_option(TRANSLATION["Custom wheels"], parent.wheel_sub, function(bool)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("TOGGLE_ON")
        entities.request_control(veh, function()
            if VEHICLE.IS_THIS_MODEL_A_BIKE(model) == 1 then
                VEHICLE.SET_VEHICLE_MOD(veh, 24, VEHICLE.GET_VEHICLE_MOD(veh, 24), bool)
            end
            VEHICLE.SET_VEHICLE_MOD(veh, 23, VEHICLE.GET_VEHICLE_MOD(veh, 23), bool)
        end)
    end)
    if VEHICLE.IS_THIS_MODEL_A_BIKE(model) == 1 then
        parent.wheels_front = ui.add_num_option(TRANSLATION["Front wheel"], parent.wheel_sub, 0, VEHICLE.GET_NUM_VEHICLE_MODS(veh, 23), 1, function(int)
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("YES")
            entities.request_control(veh, function()
                VEHICLE.SET_VEHICLE_WHEEL_TYPE(veh, 6)
                VEHICLE.SET_VEHICLE_MOD(veh, 23, int, ui.get_value(parent.custom_wheels))
            end)
        end)
        parent.wheels_back = ui.add_num_option(TRANSLATION["Back wheel"], parent.wheel_sub, 0, VEHICLE.GET_NUM_VEHICLE_MODS(veh, 24), 1, function(int)
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("YES")
            entities.request_control(veh, function()
                VEHICLE.SET_VEHICLE_WHEEL_TYPE(veh, 6)
                VEHICLE.SET_VEHICLE_MOD(veh, 24, int - 1, ui.get_value(parent.custom_wheels))
            end)
        end)
    else
        local wheel_types = {TRANSLATION["Sport"], TRANSLATION["Muscle"], TRANSLATION["Lowrider"], TRANSLATION["SUV"], TRANSLATION["Offroad"], TRANSLATION["Tuner"], TRANSLATION["High-End"], TRANSLATION["Benny's Originals"], TRANSLATION["Benny's Bespoke"], TRANSLATION["Open Wheel"], TRANSLATION["Street"], TRANSLATION["Track"]}
        parent.wheel_type = ui.add_choose(TRANSLATION["Wheel type"], parent.wheel_sub, true, wheel_types, function(int)
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            int = int > 5 and int + 1 or int
            HudSound("YES")
            entities.request_control(veh, function()
                VEHICLE.SET_VEHICLE_WHEEL_TYPE(veh, int)
                VEHICLE.SET_VEHICLE_MOD(veh, 23, -1, ui.get_value(parent.custom_wheels))
            end)
            -- ui.set_value(parent.wheels, 0, true)
        end)
        parent.wheels = ui.add_num_option(TRANSLATION["Rim"], parent.wheel_sub, 0, VEHICLE.GET_NUM_VEHICLE_MODS(veh, 23), 1, function(int)
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("YES")
            entities.request_control(veh, function()
                VEHICLE.SET_VEHICLE_MOD(veh, 23, int - 1, ui.get_value(parent.custom_wheels))
            end)
        end)
    end
    parent.wheel_color_sep = ui.add_separator(TRANSLATION["Color"], parent.wheel_sub)
    parent.paint_wheel_classic_sub = ui.add_submenu(TRANSLATION["Classic"])
    parent.paint_wheel_classic_subopt = ui.add_sub_option(TRANSLATION["Classic"], parent.wheel_sub, parent.paint_wheel_classic_sub)
    for _, e in ipairs(enum.vehicle_color_classic)
    do
        parent["color_wheel_"..e[2]] = ui.add_click_option(e[1], parent.paint_wheel_classic_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                local pearl, wheel = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
                VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, memory.read_int(pearl), e[2])
            end)
        end)
    end
    parent.paint_wheel_worn_sub = ui.add_submenu(TRANSLATION["Worn"])
    parent.paint_wheel_worn_subopt = ui.add_sub_option(TRANSLATION["Worn"], parent.wheel_sub, parent.paint_wheel_worn_sub)
    for _, e in ipairs(enum.vehicle_color_worn)
    do
        parent["color_wheel_"..e[2]] = ui.add_click_option(e[1], parent.paint_wheel_worn_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                local pearl, wheel = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
                VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, memory.read_int(pearl), e[2])
            end)
        end)
    end
    parent.paint_wheel_util_sub = ui.add_submenu(TRANSLATION["Util"])
    parent.paint_wheel_util_subopt = ui.add_sub_option(TRANSLATION["Util"], parent.wheel_sub, parent.paint_wheel_util_sub)
    for _, e in ipairs(enum.vehicle_color_util)
    do
        parent["color_wheel_"..e[2]] = ui.add_click_option(e[1], parent.paint_wheel_util_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                local pearl, wheel = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
                VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, memory.read_int(pearl), e[2])
            end)
        end)
    end
    parent.paint_wheel_matte_sub = ui.add_submenu(TRANSLATION["Matte"])
    parent.paint_wheel_matte_subopt = ui.add_sub_option(TRANSLATION["Matte"], parent.wheel_sub, parent.paint_wheel_matte_sub)
    for _, e in ipairs(enum.vehicle_color_matte)
    do
        parent["color_wheel_"..e[2]] = ui.add_click_option(e[1], parent.paint_wheel_matte_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                local pearl, wheel = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
                VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, memory.read_int(pearl), e[2])
            end)
        end)
    end
    parent.paint_wheel_metal_sub = ui.add_submenu(TRANSLATION["Metal"])
    parent.paint_wheel_metal_subopt = ui.add_sub_option(TRANSLATION["Metal"], parent.wheel_sub, parent.paint_wheel_metal_sub)
    for _, e in ipairs(enum.vehicle_color_metal)
    do
        parent["color_wheel_"..e[2]] = ui.add_click_option(e[1], parent.paint_wheel_metal_sub, function()
            if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
            HudSound("SELECT")
            entities.request_control(veh, function()
                local pearl, wheel = s_memory.allocate(2)
                VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
                VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, memory.read_int(pearl), e[2])
            end)
        end)
    end
    parent.wheel_color = ui.add_num_option(TRANSLATION["Wheel color"], parent.wheel_sub,  0, 160, 1, function(int)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        HudSound("YES")
        entities.request_control(veh, function()
            local pearl, wheel = s_memory.allocate(2)
            VEHICLE.GET_VEHICLE_EXTRA_COLOURS(veh, pearl, wheel)
            VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, memory.read_int(pearl), int)
        end)
    end)
    parent.tyre_smoke_color = ui.add_color_picker(TRANSLATION["Tyre smoke color"], parent.wheel_sub, function(color)
        if ENTITY.DOES_ENTITY_EXIST(veh) == 0 then return HudSound("ERROR") end
        entities.request_control(veh, function()
            VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(veh, color.r, color.g, color.b)
        end)
    end)
end

function vehicles.fuel_get(veh)
    if veh == 0 then return 0 end
    local fuel = memory.read_float(memory.handle_to_pointer(veh) + s_memory.FuelOffset)
    return features.round(fuel, 3)
end

function vehicles.fuel_set(veh, fuel)
    if veh == 0 then return end
    memory.write_float(memory.handle_to_pointer(veh) + s_memory.FuelOffset, fuel)
end

function vehicles.gear_get(veh)
    if veh == 0 then return -1 end
    return memory.read_short(memory.handle_to_pointer(veh) + s_memory.CurrentGear)
end

function vehicles.get_rpm(veh)
    if veh == 0 then return 0 end
    local rpm = memory.read_float(memory.handle_to_pointer(veh) + s_memory.RPM)
    return features.round(rpm, 3)
end

function vehicles.set_rpm(veh, rpm)
    if veh == 0 then return end
     memory.write_float(memory.handle_to_pointer(veh) + s_memory.RPM, rpm)
end

function vehicles.get_throttle(veh)
    if veh == 0 then return 0 end
    local throttle = memory.read_float(memory.handle_to_pointer(veh) + s_memory.Throttle)
    return features.round(throttle, 3)
end

function vehicles.set_throttle(veh, throttle)
    if veh == 0 then return end
     memory.write_float(memory.handle_to_pointer(veh) + s_memory.Throttle, throttle)
end

function vehicles.repair(veh)
	FIRE.STOP_ENTITY_FIRE(veh)
    VEHICLE.SET_VEHICLE_FIXED(veh)
    VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(veh)
    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, 1000.0)
    VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, 0)
    VEHICLE.SET_VEHICLE_ENVEFF_SCALE(veh, 0)
end

function vehicles.set_godmode(veh, bool)
	if bool then 
        vehicles.repair(veh)
    end
    VEHICLE.SET_VEHICLE_CAN_BREAK(veh, not bool)
    VEHICLE.SET_VEHICLE_CAN_BE_VISIBLY_DAMAGED(veh, not bool)
    ENTITY.SET_ENTITY_CAN_BE_DAMAGED(veh, not bool)
    ENTITY.SET_ENTITY_PROOFS(veh, bool, bool, bool, bool, bool, bool, bool, bool)
    VEHICLE.SET_VEHICLE_STRONG(veh, bool)
    VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh, not bool)
    ENTITY.SET_ENTITY_INVINCIBLE(veh, bool)
    VEHICLE._SET_VEHICLE_CAN_BE_LOCKED_ON(veh, not bool, false)
end

function vehicles.upgrade(veh)
	VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)
    VEHICLE.TOGGLE_VEHICLE_MOD(veh, 18, true)
    VEHICLE.TOGGLE_VEHICLE_MOD(veh, 20, true)
    VEHICLE.TOGGLE_VEHICLE_MOD(veh, 22, true)
    VEHICLE.SET_VEHICLE_WHEEL_TYPE(veh, 7)
    for i = 0, 54 do
        local num = VEHICLE.GET_NUM_VEHICLE_MODS(veh, i) - 1
        if i < 17 or i > 22 then 
            VEHICLE.SET_VEHICLE_MOD(veh, i, num, (i == 23 or i == 24) and true or false)
        end
    end
    for i = 0, 3 do
        VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(veh, i, true)
    end
    local p = random(1, #vehicles.colors)
    VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, 6)
    VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh, false)
    VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, 160, 160)
    VEHICLE.SET_VEHICLE_COLOURS(veh,  160, 160)
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, 5)
    VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(veh, 0, 0, 0)
    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, vehicles.colors[p][1], vehicles.colors[p][2], vehicles.colors[p][3])
    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, vehicles.colors[p][1], vehicles.colors[p][2], vehicles.colors[p][3])
    VEHICLE._SET_VEHICLE_NEON_LIGHTS_COLOUR(veh, vehicles.colors[p][1], vehicles.colors[p][2], vehicles.colors[p][3])
end

function vehicles.stock(veh)
    for i = 0, 54 do
        VEHICLE.REMOVE_VEHICLE_MOD(veh, i)
    end
    for i = 0, 3 do
        VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(veh, i, false)
    end
    VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, 0)
    VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh, true)
    VEHICLE.CLEAR_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh)
    VEHICLE.CLEAR_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh)
    VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, -1, -1)
    VEHICLE.SET_VEHICLE_COLOURS(veh, -1, -1)
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, -1)
    VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(veh, 255, 255, 255)
    VEHICLE._SET_VEHICLE_NEON_LIGHTS_COLOUR(veh, 255, 255, 255)
end

function vehicles.performance(veh)
    VEHICLE.SET_VEHICLE_MOD_KIT(veh, 0)
    VEHICLE.TOGGLE_VEHICLE_MOD(veh, 18, true)
    for _, v in ipairs({11,12,13,15})
    do
        local num = VEHICLE.GET_NUM_VEHICLE_MODS(veh, v) - 1
        VEHICLE.SET_VEHICLE_MOD(veh, v, num, false)
    end
end

function vehicles.get_closest_vehicle(pos)
    local vehicle, distance = 0, 100000000
    for _, v in ipairs(entities.get_vehs()) do
        local dist = vector3(pos):sqrlen(features.get_entity_coords(v))
        if dist < distance then
            vehicle = v
            distance = dist 
        end
    end
    return vehicle, distance
end

function vehicles.get_first_free_seat(vehicle)
    local max = VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle)
    for i = -1, max do
        if VEHICLE.IS_VEHICLE_SEAT_FREE(vehicle, i, true) == 1 then
            return i
        end
    end
    return
end

function vehicles.get_ped_seat(ped)
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped, false)
    local max = VEHICLE.GET_VEHICLE_MAX_NUMBER_OF_PASSENGERS(vehicle)
    for i = -1, max do
        if VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, i, true) == ped then return i end
    end
    return
end

function vehicles.get_personal_vehicle()
    return globals.get_int(2810701 + 298)
end

function vehicles.get_player_personal_veh(player)
    return globals.get_int(2703660 + (1 + (player * 1) + 173))
end

function vehicles.get_player_vehicle(player)
    local player = player or PLAYER.PLAYER_ID()
	if PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(player), false) == NULL then return 0 end
	return PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(player), false)
end

function vehicles.get_player_last_vehicle(player)
    return PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(player or PLAYER.PLAYER_ID()), true)
end

function vehicles.get_veh_index(pos, cl)
    local index = 1
    for i = 1, #vehicles.models
    do
        if vehicles.models[i][2] == vehicles.class_hash[cl][pos] then
            index = i
            break
        end
    end
    return index
end

for _, v in ipairs(vehicles.data)
do
    if v.DimensionsMin and v.DimensionsMax then
        insert(vehicles.models, {v.Name, v.Hash, vehicles.get_label_name(v.Name), VEHICLE.GET_VEHICLE_CLASS_FROM_NAME(v.Hash)})
        local c = VEHICLE.GET_VEHICLE_CLASS_FROM_NAME(v.Hash)
        if not vehicles.class[c] then
            vehicles.class[c] = {}
            vehicles.class_manufacturer[c] = {}
            vehicles.class_hash[c] = {}
        end
        local name = vehicles.get_label_name(v.Name)
        insert(vehicles.class_manufacturer[c], HUD._GET_LABEL_TEXT(v.Manufacturer) ~= 'NULL' and HUD._GET_LABEL_TEXT(v.Manufacturer)..' '..name or name)
        insert(vehicles.class[c], name)
        insert(vehicles.class_hash[c], v.Hash)
    end
end

return vehicles