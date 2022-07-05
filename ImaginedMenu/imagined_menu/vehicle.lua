--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--

local vector3 = require 'vector3'
local enum = require 'enums'
local json = require 'JSON'
local file = require 'files'
local NULL = 0
local vehicles = {}
vehicles.class = {}
vehicles.class_hash = {}
vehicles.data = json:decode(file.readAll(files['VehData']))
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

local function hash_to_string(hash)
    for _, v in ipairs(vehicles.models) do
        if v[2] == hash then return v[1] end
    end
    return
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

function vehicles.repair(veh)
	FIRE.STOP_ENTITY_FIRE(veh)
    VEHICLE.SET_VEHICLE_FIXED(veh)
    VEHICLE.SET_VEHICLE_DEFORMATION_FIXED(veh)
    VEHICLE.SET_VEHICLE_ENGINE_HEALTH(veh, 1000.0)
    VEHICLE.SET_VEHICLE_DIRT_LEVEL(veh, 0)
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
    for i = 0, 54 do
        local num = VEHICLE.GET_NUM_VEHICLE_MODS(veh, i)
        if i >= 17 and i <= 22 then 
            goto continue
        else
            VEHICLE.SET_VEHICLE_MOD(veh, i, num-1, false)
        end
        ::continue::
    end
    for i = 0, 3 do
        VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(veh, i, true)
    end
    local p = math.random(1, #vehicles.colors)
    VEHICLE.SET_VEHICLE_WINDOW_TINT(veh, 6)
    VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(veh, false)
    VEHICLE.SET_VEHICLE_EXTRA_COLOURS(veh, enum.vehicle_colors["Secret Gold"], enum.vehicle_colors["Secret Gold"])
    VEHICLE.SET_VEHICLE_COLOURS(veh, enum.vehicle_colors["Secret Gold"], enum.vehicle_colors["Secret Gold"])
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(veh, 5)
    VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(veh, 0, 0, 0)
    VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(veh, vehicles.colors[p][1], vehicles.colors[p][2], vehicles.colors[p][3])
    VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(veh, vehicles.colors[p][1], vehicles.colors[p][2], vehicles.colors[p][3])
    VEHICLE._SET_VEHICLE_NEON_LIGHTS_COLOUR(veh, vehicles.colors[p][1], vehicles.colors[p][2], vehicles.colors[p][3])
end

function vehicles.get_closest_vehicle(pos)
    local vehicle, distance = 0, 100000000
    for _, v in ipairs(entities.get_vehs()) do
        local dist = vector3(pos):sqrlen(vector3(ENTITY.GET_ENTITY_COORDS(v, false)))
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
	if PED.IS_PED_IN_ANY_VEHICLE(PLAYER.GET_PLAYER_PED(player), true) == NULL then return 0 end
	return PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(player), false)
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
        table.insert(vehicles.models, {v.Name, v.Hash, vehicles.get_label_name(v.Name), VEHICLE.GET_VEHICLE_CLASS_FROM_NAME(v.Hash)})
        local c = VEHICLE.GET_VEHICLE_CLASS_FROM_NAME(v.Hash)
        if not vehicles.class[c] then
            vehicles.class[c] = {}
            vehicles.class_hash[c] = {}
        end
        table.insert(vehicles.class[c], HUD._GET_LABEL_TEXT(v.Manufacturer) ~= 'NULL' and HUD._GET_LABEL_TEXT(v.Manufacturer)..' '..vehicles.get_label_name(v.Name) or vehicles.get_label_name(v.Name))
        table.insert(vehicles.class_hash[c], v.Hash)
    end
end

return vehicles