--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--

-- Global to local
local insert = table.insert
local require = require
local tonumber = tonumber
local tostring = tostring
local ipairs = ipairs
local pairs = pairs
local memory = memory
local system = system
local AUDIO = AUDIO
local PED = PED
local PLAYER = PLAYER
local VEHICLE = VEHICLE
local NETWORK = NETWORK
local STREAMING = STREAMING
local ui = ui
local WEAPON = WEAPON
local TASK = TASK
local OBJECT = OBJECT
local ENTITY = ENTITY
local DECORATOR = DECORATOR

local features = require 'features'
local switch = require 'switch'
local vehicles = require 'vehicle'
local vector3 = require 'vector3'
local peds = require 'peds'
local EntityDb = require 'entity_database'
local world_saver = require 'world_saver'
local TRANSLATION = require('default').translation
local settings = require('default').settings
local world_spawner = {}

local spawned = 0
local new_request = {}

function world_spawner.request(data)   
    system.notify(TRANSLATION['Info'], TRANSLATION['Waiting for models to load...'], 0, 128, 255, 255)
    for _, v in ipairs(data)
    do
        if v.model then
            local loaded, hash = features.request_model(v.model)
            if not hash then return -1 end
            if loaded == 0 then return 0 end
        end
    end
    return 1
end

function world_spawner.unload(data)   
    for _, v in ipairs(data)
    do
        if v.model then
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(v.model)
        end
    end
    return true
end

function world_spawner.spawn(entity, spawn_i, pos, id)
    local data = entity[id]
    if data.reference then return end
    if new_request[spawn_i][data.handle_id] then return end
    local SpawnEntity = switch()
        :case(1, function()
            return peds.create_ped(data.model, pos)
        end)
        :case(2, function()
            return vehicles.spawn_vehicle(data.model, pos)
        end)
        :case(3, function()
            ent = features.create_object(data.model, pos)
            NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(ent), true)
            NETWORK._NETWORK_SET_ENTITY_INVISIBLE_TO_NETWORK(ent, false)
            return ent
        end)
    local ent = SpawnEntity(data.type)
    if ent == 0 then system.notify(TRANSLATION["Info"], TRANSLATION["Failed to spawn entity: "]..data.handle_id, 255, 0, 0, 255) system.log('Imagined Menu', "Failed to spawn entity model: "..data.model.." | "..tostring(STREAMING.IS_MODEL_VALID(data.model) and "Valid" or "Invalid").." | Handle: "..data.handle_id.." | Type: "..data.type) end
    EntityDb.AddEntityToDatabase(ent)
    if data.position then
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(ent, data.position.x, data.position.y, data.position.z, false, false, false)
        ENTITY.SET_ENTITY_ROTATION(ent, data.position.pitch, data.position.roll, data.position.yaw, 2, true)
    end
    if not new_request[spawn_i].parent and data.parent then
        new_request[spawn_i].parent = ent
    end
    new_request[spawn_i][data.handle_id] = ent
    if data.godmode then
        features.set_godmode(ent, data.godmode)
    end
    if data.gravity ~= nil then
        ENTITY.SET_ENTITY_HAS_GRAVITY(ent, data.gravity)
    end
    if data.dynamic ~= nil then
        ENTITY.SET_ENTITY_DYNAMIC(ent, data.dynamic)
    end
    ENTITY.SET_ENTITY_HEALTH(ent, data.health, 0)
    if data.type == 1 then
        peds.apply_outfit(data.outfit.components, data.outfit.props, ent)
        if data.godmode then
            peds.set_ped_god(ent)
        end
        if data.in_vehicle then
            PED.SET_PED_INTO_VEHICLE(ent, new_request[spawn_i][data.in_vehicle], data.seat_index)
        end
        if data.noflee then
            peds.calm_ped(ent, true)
        end
        if data.armor then
            PED.SET_PED_ARMOUR(ent, data.armor)
        end
        if data.can_ragdoll ~= nil then
            PED.SET_PED_CAN_RAGDOLL(ent, data.can_ragdoll)
            PED.SET_PED_CAN_RAGDOLL_FROM_PLAYER_IMPACT(ent, data.can_ragdoll)
        end
        if data.is_tiny then
            PED.SET_PED_CONFIG_FLAG(ent, 223, true)
        end
        if data.current_weapon then
            WEAPON.GIVE_WEAPON_TO_PED(ent, data.current_weapon, 9999, false, true)
            WEAPON.SET_CURRENT_PED_WEAPON(ent, data.current_weapon, true)
        end
        EntityDb.entity_data[ent].noflee = true
    elseif data.type == 2 then
        -- DECORATOR.DECOR_SET_INT(ent, "MPBitset", 1024)
        VEHICLE.SET_VEHICLE_MOD_KIT(ent, 0)
        vehicles.repair(ent)
        if data.godmode then
            vehicles.set_godmode(ent, data.godmode)
        end
        if data.colors.paint_fade then
            VEHICLE.SET_VEHICLE_ENVEFF_SCALE(ent, data.colors.paint_fade)
        end
        if data.colors.interior then
            VEHICLE._SET_VEHICLE_INTERIOR_COLOR(ent, data.colors.interior)
        end
        if data.colors.dashboard then
            VEHICLE._SET_VEHICLE_DASHBOARD_COLOR(ent, data.colors.dashboard)
        end
        if data.colors.xenons then
            VEHICLE._SET_VEHICLE_XENON_LIGHTS_COLOR(ent, data.colors.xenons)
        end
        VEHICLE.SET_VEHICLE_COLOURS(ent, data.colors.primary, data.colors.secondary)
        if data.colors.custom_primary then
            VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(ent, data.colors.custom_1r, data.colors.custom_1g, data.colors.custom_1b)
        end
        if data.colors.custom_secondary then
            VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(ent, data.colors.custom_2r, data.colors.custom_2g, data.colors.custom_2b)
        end
        VEHICLE.SET_VEHICLE_EXTRA_COLOURS(ent, data.colors.pearl, data.colors.wheel)
        VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(ent , data.colors.tyre_smoke_r, data.colors.tyre_smoke_g, data.colors.tyre_smoke_b)
        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(ent, data.number_plate_index)
        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(ent, data.number_plate_text)
        VEHICLE.SET_VEHICLE_WHEEL_TYPE(ent, data.wheel_type)
        if data.engine_sound ~= '' then
            AUDIO._FORCE_VEHICLE_ENGINE_AUDIO(ent, data.engine_sound)
        end
        for k, v in pairs(data.mods)
        do
            local i = tonumber(k)
            if i < 17 or i > 22 and v[1] ~= -1 then
                VEHICLE.SET_VEHICLE_MOD(ent, i, v[1], v[2])
            else
                VEHICLE.TOGGLE_VEHICLE_MOD(ent, i, v)
            end
        end

        if data.extra then
            for k, v in pairs(data.extra)
            do
                local i = tonumber(k)
                VEHICLE.SET_VEHICLE_EXTRA(ent, i, not v)
            end
        end

        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(ent, not data.bullet_proof_tyres)
        for k, v in pairs(data.tyres_bursted)
        do
            local i = tonumber(k)
            if v then
                VEHICLE.SET_VEHICLE_TYRE_BURST(ent, i, true, 1000.0)
            end
        end
        VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(ent, 0, data.neons.left == 1)
        VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(ent, 1, data.neons.right == 1)
        VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(ent, 2, data.neons.front == 1)
        VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(ent, 3, data.neons.back == 1)
        VEHICLE._SET_VEHICLE_NEON_LIGHTS_COLOUR(ent, data.neons.r, data.neons.g, data.neons.b)
        VEHICLE.SET_VEHICLE_WINDOW_TINT(ent, data.window_tint)
        VEHICLE.SET_VEHICLE_ENGINE_ON(ent, data.engine_on, true, false)
        VEHICLE.SET_VEHICLE_SIREN(ent, data.siren)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(ent, data.door_lock_status)
        VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(ent, data.torque_multiplier)
        if data.rmp_multiplier then data.rpm_multiplier = data.rmp_multiplier end
        VEHICLE.MODIFY_VEHICLE_TOP_SPEED(ent, data.rpm_multiplier)
        VEHICLE.SET_VEHICLE_DIRT_LEVEL(ent, data.dirt_level)
        VEHICLE._SET_VEHICLE_LIGHTS_MODE(ent, data.lights)
        VEHICLE.SET_VEHICLE_LIVERY(ent, data.livery)
        local Roof = switch()
            :case(0, function()
                VEHICLE.RAISE_CONVERTIBLE_ROOF(ent, true)
            end)
            :case(1, function()
                VEHICLE.LOWER_CONVERTIBLE_ROOF(ent, false)
            end)
            :case(2, function()
                VEHICLE.LOWER_CONVERTIBLE_ROOF(ent, true)
            end)
            :case(3, function()
                VEHICLE.LOWER_CONVERTIBLE_ROOF(ent, true)
                VEHICLE.RAISE_CONVERTIBLE_ROOF(ent, false)
            end)

        Roof(data.roofstate)
        for k, v in pairs(data.open_door)
        do
            local i = tonumber(k)
            if data.open_door[k] then
                VEHICLE.SET_VEHICLE_DOOR_OPEN(ent, i, false, true)
            end
            if data.break_door[k] then
                VEHICLE._SET_VEHICLE_DOOR_CAN_BREAK(ent, i, true)
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(ent, i, true)
            end
        end
        VEHICLE.SET_VEHICLE_LIGHT_MULTIPLIER(ent, data.light_mult or 1)
    elseif data.type == 3 then
        OBJECT._SET_OBJECT_TEXTURE_VARIATION(ent, data.texture)
    end

    if data.opacity ~= 255 then
        ENTITY.SET_ENTITY_ALPHA(ent, data.opacity, false)
    end
    ENTITY.SET_ENTITY_LOD_DIST(ent, data.lod_dist)
    ENTITY.FREEZE_ENTITY_POSITION(ent, data.freeze)
    if EntityDb.entity_data[ent] then
        EntityDb.entity_data[ent].freeze_position = data.freeze
    end
    ENTITY.SET_ENTITY_COLLISION(ent, data.collision, true)
    ENTITY.SET_ENTITY_VISIBLE(ent, not data.invisible, false)
    if not data.attached then return ent end
    if new_request[spawn_i][data.attachment.attached_to] == ent then return ent end -- don't attach to itself
    local found = true
    if not new_request[spawn_i][data.attachment.attached_to] then -- checks if entity to attach exist
        found = false
        for i, v in ipairs(entity)
        do
            if v.handle_id == data.attachment.attached_to then
                world_spawner.spawn(entity, spawn_i, pos, i)
                found = true
                break
            end
        end
    end
    if not found then return ent end
    ENTITY.ATTACH_ENTITY_TO_ENTITY(ent, new_request[spawn_i][data.attachment.attached_to], data.attachment.bone,
        data.attachment.pos.x, data.attachment.pos.y, data.attachment.pos.z,
        data.attachment.pitch, data.attachment.roll, data.attachment.yaw,
        false, true, data.collision, data.type == 1, 2, true
    )
    if EntityDb.entity_data[ent] then
        EntityDb.entity_data[ent].attach_bone = data.attachment.bone
        EntityDb.entity_data[ent].attachx = data.attachment.pos.x
        EntityDb.entity_data[ent].attachy = data.attachment.pos.y
        EntityDb.entity_data[ent].attachz = data.attachment.pos.z
        EntityDb.entity_data[ent].attachpitch = data.attachment.pitch
        EntityDb.entity_data[ent].attachroll = data.attachment.roll
        EntityDb.entity_data[ent].attachyaw = data.attachment.yaw
    end
    return ent
end

function world_spawner.create_vehicle(vehicle, conf, clone_damage)
    CreateRemoveThread(true, 'request_model_'..tostring(vehicle), function()
        local result = world_spawner.request(vehicle)
        if result == -1 then return 0 end -- invalid model
        if result == 0 then return end -- not loaded
        spawned = spawned + 1
        local spawn_i = spawned
        new_request[spawn_i] = {}
        local pos = features.get_offset_from_player_coords(vector3(0,8,0))
        for i, v in ipairs(vehicle)
        do
            local ent = world_spawner.spawn(vehicle, spawn_i, pos, i)
            if ent and not settings.Vehicle["AddToDb"] then
                EntityDb.entity_data[ent] = nil
            end
        end
        world_spawner.unload(vehicle)
        local prev_veh = vehicles.get_player_vehicle()
        local velocity
        if conf and settings.Vehicle["SpawnerKeepSpeed"] and settings.Vehicle["SpawnerInside"] and prev_veh ~= NULL then
            velocity = ENTITY.GET_ENTITY_VELOCITY(prev_veh)
        end
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(new_request[spawn_i].parent, pos.x, pos.y, pos.z, false, false, false)
        ENTITY.SET_ENTITY_HEADING(new_request[spawn_i].parent, ENTITY.GET_ENTITY_HEADING(PLAYER.PLAYER_PED_ID()))
        if conf and settings.Vehicle["SpawnerKeepSpeed"] and settings.Vehicle["SpawnerInside"] and prev_veh ~= NULL then
            velocity = ENTITY.GET_ENTITY_VELOCITY(prev_veh)
        end
        if conf and settings.Vehicle["SpawnerDeleteOld"] and prev_veh ~= NULL then
            TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.PLAYER_PED_ID())
            features.delete_entity(prev_veh)
        end
        if velocity then
            ENTITY.SET_ENTITY_VELOCITY(new_request[spawn_i].parent, velocity.x, velocity.y, velocity.z)
        end
        if settings.Vehicle["SpawnerInside"] then
            PED.SET_PED_INTO_VEHICLE(PLAYER.PLAYER_PED_ID(), new_request[spawn_i].parent, -1)
        end
        if clone_damage then
            VEHICLE.COPY_VEHICLE_DAMAGES(clone_damage, new_request[spawn_i].parent)
        end
        return 0
    end)
end

function world_spawner.spawn_map(data, no_db)
    CreateRemoveThread(true, 'request_model_'..tostring(data), function()
        local result = world_spawner.request(data)
        if result == -1 then return 0 end -- invalid model
        if result == 0 then return end -- not loaded
        spawned = spawned + 1
        local spawn_i = spawned
        new_request[spawn_i] = {}

        for i, v in ipairs(data)
        do
            local ent = world_spawner.spawn(data, spawn_i, vector3(), i)
            if no_db and ent then
                EntityDb.entity_data[ent] = nil
            end 
        end

        return 0
    end)
end

function world_spawner.copy_entity(entity, attachments)
    local data = {}
    if attachments then
        local entity = features.get_parent_attachment(entity)
        data = {world_saver.get_properties(entity, true)}
        for _, v in ipairs(features.get_all_attachments(entity)) do
            insert(data, world_saver.get_properties(v, false))
        end
    else
        data = {world_saver.get_properties(entity, true)}
        data[1].attached = false
        data[1].in_vehicle = nil
    end
    world_spawner.spawn_map(data)
end

return world_spawner