--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--

local features = require 'features'
local vehicles = require 'vehicle'
local vector3 = require 'vector3'
local peds = require 'peds'
local f = require 'default'
local EntityDb = require 'entity_database'
local settings = f.settings
local custom_vehicles = {}

local spawned = 0
local new_request = {}

local new_vehicle = {}
function custom_vehicles.get_properties(ent, first)
    local data = {
        parent = first,
        type = ENTITY.GET_ENTITY_TYPE(ent),
        model = ENTITY.GET_ENTITY_MODEL(ent),
        handle_id = ent,
        godmode = features.get_godmode(ent),
        freeze = EntityDb.entity_data[ent] and ui.get_value(EntityDb.spawned_options[ent].freeze_position) or not first,
        collision = ENTITY.GET_ENTITY_COLLISION_DISABLED(ent) == 0,
        invisible = ENTITY.IS_ENTITY_VISIBLE(ent) == 0,
        attached = ENTITY.IS_ENTITY_ATTACHED(ent) == 1,
        opacity = ENTITY.GET_ENTITY_ALPHA(ent),
        lod_dist = ENTITY.GET_ENTITY_LOD_DIST(ent),
        health = ENTITY.GET_ENTITY_HEALTH(ent)
    }
    if data.type == 1 then
        data.outfit = peds.get_outfit(ent)
        if PED.IS_PED_IN_ANY_VEHICLE(ent, false) == 1 then
            data.in_vehicle = PED.GET_VEHICLE_PED_IS_IN(ent, false)
            local seat_index = -1
            for i = -1, VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(ENTITY.GET_ENTITY_MODEL(data.in_vehicle)) - 2
            do
                if VEHICLE.GET_PED_IN_VEHICLE_SEAT(data.in_vehicle, i, true) == ent then
                    seat_index = i
                    break
                end
            end
            data.seat_index = seat_index
        end
    elseif data.type == 2 then
        local primary = memory.malloc(1)
        local secondary = memory.malloc(1)
        VEHICLE.GET_VEHICLE_COLOURS(ent, primary, secondary)
        local interior = memory.malloc(1)
        VEHICLE._GET_VEHICLE_INTERIOR_COLOR(ent, interior)
        local dashboard = memory.malloc(1)
        VEHICLE._GET_VEHICLE_DASHBOARD_COLOR(ent, dashboard)
        data.colors = {
            paint_fade = VEHICLE.GET_VEHICLE_ENVEFF_SCALE(ent),
            xenons = VEHICLE._GET_VEHICLE_XENON_LIGHTS_COLOR(ent),
            interior = memory.read_int(interior),
            dashboard = memory.read_int(dashboard),
            primary = memory.read_int(primary),
            secondary = memory.read_int(secondary),
            custom_primary = VEHICLE.GET_IS_VEHICLE_PRIMARY_COLOUR_CUSTOM(ent) == 1,
            custom_secondary = VEHICLE.GET_IS_VEHICLE_SECONDARY_COLOUR_CUSTOM(ent) == 1,
            pearl = 0,
            wheel = 0,
            tyre_smoke_r = 255,
            tyre_smoke_g = 255,
            tyre_smoke_b = 255
        }
        memory.free(primary)
        memory.free(secondary)
        memory.free(interior)
        memory.free(dashboard)
        local pearlescentColor = memory.malloc(1)
        local wheelColor = memory.malloc(1)
        local tr = memory.malloc(1)
        local tg = memory.malloc(1)
        local tb = memory.malloc(1)
        VEHICLE.GET_VEHICLE_TYRE_SMOKE_COLOR(ent, tr, tg, tb)
        VEHICLE.GET_VEHICLE_EXTRA_COLOURS(ent, pearlescentColor, wheelColor)
        data.colors.pearl = memory.read_int(pearlescentColor)
        data.colors.wheel = memory.read_int(wheelColor)
        data.colors.tyre_smoke_r = memory.read_int(tr)
        data.colors.tyre_smoke_g = memory.read_int(tg)
        data.colors.tyre_smoke_b = memory.read_int(tb)
        memory.free(pearlescentColor)
        memory.free(wheelColor)
        memory.free(tr)
        memory.free(tg)
        memory.free(tb)
        if data.colors.custom_primary then
            local r = memory.malloc(1)
            local g = memory.malloc(1)
            local b = memory.malloc(1)
            VEHICLE.GET_VEHICLE_CUSTOM_PRIMARY_COLOUR(ent, r, g, b)
            data.colors.custom_1r = memory.read_int(r)
            data.colors.custom_1g = memory.read_int(g)
            data.colors.custom_1b = memory.read_int(b)
            memory.free(r)
            memory.free(g)
            memory.free(b)
        end
        if data.colors.custom_secondary then
            local r = memory.malloc(1)
            local g = memory.malloc(1)
            local b = memory.malloc(1)
            VEHICLE.GET_VEHICLE_CUSTOM_SECONDARY_COLOUR(ent, r, g, b)
            data.colors.custom_2r = memory.read_int(r)
            data.colors.custom_2g = memory.read_int(g)
            data.colors.custom_2b = memory.read_int(b)
            memory.free(r)
            memory.free(g)
            memory.free(b)
        end
        data.number_plate_index = VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(ent)
        data.number_plate_text = VEHICLE.GET_VEHICLE_NUMBER_PLATE_TEXT(ent)
        data.wheel_type = VEHICLE.GET_VEHICLE_WHEEL_TYPE(ent)
        local nr = memory.malloc(1)
        local ng = memory.malloc(1)
        local nb = memory.malloc(1)
        VEHICLE._GET_VEHICLE_NEON_LIGHTS_COLOUR(ent, nr, ng, nb)
        data.neons = {
            left = VEHICLE._IS_VEHICLE_NEON_LIGHT_ENABLED(ent, 0),
            right = VEHICLE._IS_VEHICLE_NEON_LIGHT_ENABLED(ent, 1),
            front = VEHICLE._IS_VEHICLE_NEON_LIGHT_ENABLED(ent, 2),
            back = VEHICLE._IS_VEHICLE_NEON_LIGHT_ENABLED(ent, 3),
            r = memory.read_int(nr),
            g = memory.read_int(ng),
            b = memory.read_int(nb)
        }
        memory.free(nr)
        memory.free(ng)
        memory.free(nb)
        data.break_door = {}
        data.open_door = {}
        for i = 0, 5
        do
            data.break_door[i] = VEHICLE.IS_VEHICLE_DOOR_DAMAGED(ent, i) == 1
            data.open_door[i] = VEHICLE.GET_VEHICLE_DOOR_ANGLE_RATIO(ent, i) ~= 0
        end
        data.mods = {}
        for i = 0, 49
        do
            if i < 17 or i > 22 then
                data.mods[i] = {VEHICLE.GET_VEHICLE_MOD(ent, i), VEHICLE.GET_VEHICLE_MOD_VARIATION(ent, i) == 1}
            else
                data.mods[i] = VEHICLE.IS_TOGGLE_MOD_ON(ent, i) == 1
            end
        end
        data.bullet_proof_tyres = VEHICLE.GET_VEHICLE_TYRES_CAN_BURST(ent) == 0
        data.window_tint = VEHICLE.GET_VEHICLE_WINDOW_TINT(ent)
        data.door_lock_status = VEHICLE.GET_VEHICLE_DOOR_LOCK_STATUS(ent)
        data.engine_on = VEHICLE.GET_IS_VEHICLE_ENGINE_RUNNING(ent) == 1
        data.siren = VEHICLE.IS_VEHICLE_SIREN_ON(ent) == 1
        data.engine_sound = ""
        data.torque_multiplier = 1.0
        data.rmp_multiplier = 1.0
        data.dirt_level = VEHICLE.GET_VEHICLE_DIRT_LEVEL(ent)
        local lightsOn = memory.malloc(1)
        local highbeamsOn = memory.malloc(1)
        VEHICLE.GET_VEHICLE_LIGHTS_STATE(ent, lightsOn, highbeamsOn)
        local light_mode = 0
        if memory.read_byte(highbeamsOn) == 1 then
            light_mode = 2
        elseif memory.read_byte(lightsOn) == 1 then
            light_mode = 1
        end
        memory.free(highbeamsOn)
        memory.free(lightsOn)
        data.lights = light_mode
        data.extra = {}
        for i = 0, 20
        do
            if VEHICLE.DOES_EXTRA_EXIST(ent, i) == 1 then
                data.extra[i] = VEHICLE.IS_VEHICLE_EXTRA_TURNED_ON(ent, i) == 1
            end
        end
        data.tyres_bursted = {}
        for i = 0, 5
        do
            data.tyres_bursted[i] = VEHICLE.IS_VEHICLE_TYRE_BURST(ent, i, true) == 1  
        end
        data.livery = VEHICLE.GET_VEHICLE_LIVERY(ent)
        data.roofstate = VEHICLE.GET_CONVERTIBLE_ROOF_STATE(ent)
    elseif data.type == 3 then
        data.texture = OBJECT._GET_OBJECT_TEXTURE_VARIATION(ent)
    end
    if data.attached then
        if EntityDb.entity_data[ent] and EntityDb.entity_data[ent].is_attached then
            data.attachment = {
                attached_to = ENTITY.GET_ENTITY_ATTACHED_TO(ent),
                bone = EntityDb.entity_data[ent].attach_bone,
                pos = {
                    x = EntityDb.entity_data[ent].attachx,
                    y = EntityDb.entity_data[ent].attachy,
                    z = EntityDb.entity_data[ent].attachz
                },
                pitch = EntityDb.entity_data[ent].pitch,
                roll = EntityDb.entity_data[ent].roll, 
                yaw = EntityDb.entity_data[ent].yaw
            }
        else
            local offset = vector3(ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ent, 0, 0, VEHICLE._GET_VEHICLE_SUSPENSION_HEIGHT(ent) ~= -1 and VEHICLE._GET_VEHICLE_SUSPENSION_HEIGHT(ent) or 0))
            local offpos1 = vector3(ENTITY.GET_OFFSET_FROM_ENTITY_GIVEN_WORLD_COORDS(ent, offset.x, offset.y, offset.z))
            local offset = vector3(ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ENTITY.GET_ENTITY_ATTACHED_TO(ent), 0, 0, VEHICLE._GET_VEHICLE_SUSPENSION_HEIGHT(ENTITY.GET_ENTITY_ATTACHED_TO(ent)) ~= -1 and VEHICLE._GET_VEHICLE_SUSPENSION_HEIGHT(ENTITY.GET_ENTITY_ATTACHED_TO(ent)) or 0))
            local offpos2 = vector3(ENTITY.GET_OFFSET_FROM_ENTITY_GIVEN_WORLD_COORDS(ENTITY.GET_ENTITY_ATTACHED_TO(ent), offset.x, offset.y, offset.z))
            local pos = vector3(ENTITY.GET_ENTITY_COORDS(ent, true)) + offpos1 + offpos2
            local rot1 = vector3(ENTITY.GET_ENTITY_ROTATION(ENTITY.GET_ENTITY_ATTACHED_TO(ent), 2))
            local rot2 = vector3(ENTITY.GET_ENTITY_ROTATION(ent, 2))
            local pitch, roll, yaw = (rot2 - rot1):get()
            data.attachment = {
                attached_to = ENTITY.GET_ENTITY_ATTACHED_TO(ent),
                bone = 0,
                pos = {
                    x = ENTITY.GET_OFFSET_FROM_ENTITY_GIVEN_WORLD_COORDS(ENTITY.GET_ENTITY_ATTACHED_TO(ent), pos.x, pos.y, pos.z).x,
                    y = ENTITY.GET_OFFSET_FROM_ENTITY_GIVEN_WORLD_COORDS(ENTITY.GET_ENTITY_ATTACHED_TO(ent), pos.x, pos.y, pos.z).y,
                    z = ENTITY.GET_OFFSET_FROM_ENTITY_GIVEN_WORLD_COORDS(ENTITY.GET_ENTITY_ATTACHED_TO(ent), pos.x, pos.y, pos.z).z
                },
                pitch = pitch,
                roll = roll, 
                yaw = yaw
            }
        end
    end
    return data
end

local Veh
local Vehicle
local Velocity
-- local Rot
function custom_vehicles.save(veh, tick)
    if tick == 0 then
        Veh = {}
        Vehicle = features.get_parent_attachment(veh)
        Velocity = ENTITY.GET_ENTITY_VELOCITY(Vehicle)
        ENTITY.FREEZE_ENTITY_POSITION(Vehicle, true)
        -- Rot = ENTITY.GET_ENTITY_ROTATION(Vehicle, 2)
        -- ENTITY.SET_ENTITY_ROTATION(Vehicle, 0, 0, 0, 2, true)
        return
    end
    table.insert(Veh, custom_vehicles.get_properties(Vehicle, true))
    for _, v in ipairs(features.get_all_attachments(Vehicle))
    do
        table.insert(Veh, custom_vehicles.get_properties(v, false))
    end
    -- ENTITY.SET_ENTITY_ROTATION(Vehicle, Rot.x, Rot.y, Rot.z, 2, true)
    ENTITY.FREEZE_ENTITY_POSITION(Vehicle, false)
    ENTITY.SET_ENTITY_VELOCITY(Vehicle, Velocity.x, Velocity.y, Velocity.z)
    return Veh
end

function custom_vehicles.request(CustomVehicle)   
    system.notify(TRANSLATION['Info'], TRANSLATION['Waiting for models to load...'], 0, 128, 255, 255)
    for _, v in ipairs(CustomVehicle)
    do
        local loaded, hash = features.request_model(v.model)
        if not hash then return -1 end
        if loaded == 0 then return 0 end
    end
    return 1
end

function custom_vehicles.unload(CustomVehicle)   
    for _, v in ipairs(CustomVehicle)
    do
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(v.model)
    end
    return true
end

function custom_vehicles.spawn(vehicle, spawn_i, pos, id)
    local CustomVehicle = vehicle[id]
    if new_request[spawn_i][CustomVehicle.handle_id] then return end
    local ent
    if CustomVehicle.type == 1 then
        ent = peds.create_ped(CustomVehicle.model, pos)
    elseif CustomVehicle.type == 2 then
        ent = vehicles.spawn_vehicle(CustomVehicle.model, pos)
    elseif CustomVehicle.type == 3 then
        ent = features.create_object(CustomVehicle.model, pos)
        NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(ent), true)
        NETWORK._NETWORK_SET_ENTITY_INVISIBLE_TO_NETWORK(ent, false)
    end
    if settings.Vehicle["AddToDb"] then
        EntityDb.AddEntityToDatabase(ent)
    end
    if not new_request[spawn_i].parent and CustomVehicle.parent then
        new_request[spawn_i].parent = ent
    end
    new_request[spawn_i][CustomVehicle.handle_id] = ent
    if CustomVehicle.godmode then
        features.set_godmode(ent, CustomVehicle.godmode)
    end
    if CustomVehicle.type == 1 then
        peds.apply_outfit(CustomVehicle.outfit.components, CustomVehicle.outfit.props, ent)
        if CustomVehicle.godmode then
            peds.set_ped_god(ent)
        end
        if CustomVehicle.in_vehicle then
            PED.SET_PED_INTO_VEHICLE(ent, new_request[spawn_i][CustomVehicle.in_vehicle], CustomVehicle.seat_index)
        end
    elseif CustomVehicle.type == 2 then
       --  DECORATOR.DECOR_SET_INT(ent, "MPBitset", 1024)
        VEHICLE.SET_VEHICLE_MOD_KIT(ent, 0)
        vehicles.repair(ent)
        if CustomVehicle.godmode then
            vehicles.set_godmode(ent, CustomVehicle.godmode)
        end
        if CustomVehicle.colors.paint_fade then
            VEHICLE.SET_VEHICLE_ENVEFF_SCALE(ent, CustomVehicle.colors.paint_fade)
        end
        if CustomVehicle.colors.interior then
            VEHICLE._SET_VEHICLE_INTERIOR_COLOR(ent, CustomVehicle.colors.interior)
        end
        if CustomVehicle.colors.dashboard then
            VEHICLE._SET_VEHICLE_DASHBOARD_COLOR(ent, CustomVehicle.colors.dashboard)
        end
        if CustomVehicle.colors.xenons then
            VEHICLE._SET_VEHICLE_XENON_LIGHTS_COLOR(ent, CustomVehicle.colors.xenons)
        end
        VEHICLE.SET_VEHICLE_COLOURS(ent, CustomVehicle.colors.primary, CustomVehicle.colors.secondary)
        if CustomVehicle.colors.custom_primary then
            VEHICLE.SET_VEHICLE_CUSTOM_PRIMARY_COLOUR(ent, CustomVehicle.colors.custom_1r, CustomVehicle.colors.custom_1g, CustomVehicle.colors.custom_1b)
        end
        if CustomVehicle.colors.custom_secondary then
            VEHICLE.SET_VEHICLE_CUSTOM_SECONDARY_COLOUR(ent, CustomVehicle.colors.custom_2r, CustomVehicle.colors.custom_2g, CustomVehicle.colors.custom_2b)
        end
        VEHICLE.SET_VEHICLE_EXTRA_COLOURS(ent, CustomVehicle.colors.pearl, CustomVehicle.colors.wheel)
        VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(ent , CustomVehicle.colors.tyre_smoke_r, CustomVehicle.colors.tyre_smoke_g, CustomVehicle.colors.tyre_smoke_b)
        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT_INDEX(ent, CustomVehicle.number_plate_index)
        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(ent, CustomVehicle.number_plate_text)
        VEHICLE.SET_VEHICLE_WHEEL_TYPE(ent, CustomVehicle.wheel_type)
        if CustomVehicle.engine_sound ~= '' then
            AUDIO._FORCE_VEHICLE_ENGINE_AUDIO(ent, CustomVehicle.engine_sound)
        end
        for k, v in pairs(CustomVehicle.mods)
        do
            local i = tonumber(k)
            if i < 17 or i > 22 and v[1] ~= -1 then
                VEHICLE.SET_VEHICLE_MOD(ent, i, v[1], v[2])
            else
                VEHICLE.TOGGLE_VEHICLE_MOD(ent, i, v)
            end
        end

        if CustomVehicle.extra then
            for k, v in pairs(CustomVehicle.extra)
            do
                local i = tonumber(k)
                VEHICLE.SET_VEHICLE_EXTRA(ent, i, not v)
            end
        end

        VEHICLE.SET_VEHICLE_TYRES_CAN_BURST(ent, not CustomVehicle.bullet_proof_tyres)
        for k, v in pairs(CustomVehicle.tyres_bursted)
        do
            local i = tonumber(k)
            if v then
                VEHICLE.SET_VEHICLE_TYRE_BURST(ent, i, true, 1000.0)
            end
        end
        VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(ent, 0, CustomVehicle.neons.left == 1)
        VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(ent, 1, CustomVehicle.neons.right == 1)
        VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(ent, 2, CustomVehicle.neons.front == 1)
        VEHICLE._SET_VEHICLE_NEON_LIGHT_ENABLED(ent, 3, CustomVehicle.neons.back == 1)
        VEHICLE._SET_VEHICLE_NEON_LIGHTS_COLOUR(ent, CustomVehicle.neons.r, CustomVehicle.neons.g, CustomVehicle.neons.b)
        VEHICLE.SET_VEHICLE_WINDOW_TINT(ent, CustomVehicle.window_tint)
        VEHICLE.SET_VEHICLE_ENGINE_ON(ent, CustomVehicle.engine_on, true, false)
        VEHICLE.SET_VEHICLE_SIREN(ent, CustomVehicle.siren)
        VEHICLE.SET_VEHICLE_DOORS_LOCKED(ent, CustomVehicle.door_lock_status)
        VEHICLE.SET_VEHICLE_CHEAT_POWER_INCREASE(ent, CustomVehicle.torque_multiplier)
        VEHICLE.MODIFY_VEHICLE_TOP_SPEED(ent, CustomVehicle.rmp_multiplier)
        VEHICLE.SET_VEHICLE_DIRT_LEVEL(ent, CustomVehicle.dirt_level)
        ENTITY.SET_ENTITY_HEALTH(ent, CustomVehicle.health, 1)
        VEHICLE._SET_VEHICLE_LIGHTS_MODE(ent, CustomVehicle.lights)
        VEHICLE.SET_VEHICLE_LIVERY(ent, CustomVehicle.livery)
        if CustomVehicle.roofstate == 0 then
            VEHICLE.RAISE_CONVERTIBLE_ROOF(ent, true)
        elseif CustomVehicle.roofstate == 1 then
            VEHICLE.LOWER_CONVERTIBLE_ROOF(ent, false)
        elseif CustomVehicle.roofstate == 2 then
            VEHICLE.LOWER_CONVERTIBLE_ROOF(ent, true)
        elseif CustomVehicle.roofstate == 3 then
            VEHICLE.LOWER_CONVERTIBLE_ROOF(ent, true)
            VEHICLE.RAISE_CONVERTIBLE_ROOF(ent, false)
        end
        for k, v in pairs(CustomVehicle.open_door)
        do
            local i = tonumber(k)
            if CustomVehicle.open_door[k] then
                VEHICLE.SET_VEHICLE_DOOR_OPEN(ent, i, false, true)
            end
            if CustomVehicle.break_door[k] then
                VEHICLE._SET_VEHICLE_DOOR_CAN_BREAK(ent, i, true)
                VEHICLE.SET_VEHICLE_DOOR_BROKEN(ent, i, true)
            end
        end
    elseif type == 3 then
        OBJECT._SET_OBJECT_TEXTURE_VARIATION(ent, CustomVehicle.texture)
    end
    if CustomVehicle.opacity ~= 255 then
        ENTITY.SET_ENTITY_ALPHA(ent, CustomVehicle.opacity, false)
    end
    ENTITY.SET_ENTITY_LOD_DIST(ent, CustomVehicle.lod_dist)
    ENTITY.FREEZE_ENTITY_POSITION(ent, CustomVehicle.freeze)
    if EntityDb.entity_data[ent] then
        EntityDb.entity_data[ent].freeze_position = CustomVehicle.freeze
    end
    ENTITY.SET_ENTITY_COLLISION(ent, CustomVehicle.collision, true)
    ENTITY.SET_ENTITY_VISIBLE(ent, not CustomVehicle.invisible, false)
    if not CustomVehicle.attached then return end
    if new_request[spawn_i][CustomVehicle.attachment.attached_to] == ent then return end -- don't attach to itself
    local found = true
    if not new_request[spawn_i][CustomVehicle.attachment.attached_to] then -- checks if entity to attach exist
        found = false
        for i, v in ipairs(vehicle)
        do
            if v.handle_id == CustomVehicle.attachment.attached_to then
                custom_vehicles.spawn(vehicle, spawn_i, pos, i)
                found = true
                break
            end
        end
    end
    if not found then return end
    ENTITY.ATTACH_ENTITY_TO_ENTITY(ent, new_request[spawn_i][CustomVehicle.attachment.attached_to], CustomVehicle.attachment.bone,
        CustomVehicle.attachment.pos.x, CustomVehicle.attachment.pos.y, CustomVehicle.attachment.pos.z,
        CustomVehicle.attachment.pitch, CustomVehicle.attachment.roll, CustomVehicle.attachment.yaw,
        false, true, CustomVehicle.collision, CustomVehicle.type == 1, 2, true
    )
    if EntityDb.entity_data[ent] then
        EntityDb.entity_data[ent].attach_bone = CustomVehicle.attachment.bone
        EntityDb.entity_data[ent].attachx = CustomVehicle.attachment.pos.x
        EntityDb.entity_data[ent].attachy = CustomVehicle.attachment.pos.y
        EntityDb.entity_data[ent].attachz = CustomVehicle.attachment.pos.z
        EntityDb.entity_data[ent].attachpitch = CustomVehicle.attachment.pitch
        EntityDb.entity_data[ent].attachroll = CustomVehicle.attachment.roll
        EntityDb.entity_data[ent].attachyaw = CustomVehicle.attachment.yaw
    end
    return ent
end

function custom_vehicles.create(vehicle, conf, clone_damage)
    CreateRemoveThread(true, 'request_model_'..tostring(vehicle), function()
        local result = custom_vehicles.request(vehicle)
        if result == -1 then return 0 end -- invalid model
        if result == 0 then return end -- not loaded
        spawned = spawned + 1
        local spawn_i = spawned
        new_request[spawn_i] = {}
        local pos = features.get_offset_from_player_coords(vector3(0,8,0))
        for i, v in ipairs(vehicle)
        do
            custom_vehicles.spawn(vehicle, spawn_i, pos, i)
        end
        custom_vehicles.unload(vehicle)
        local prev_veh = vehicles.get_player_vehicle()
        local velocity
        if conf and settings.Vehicle["SpawnerKeepSpeed"] and settings.Vehicle["SpawnerInside"] and prev_veh ~= NULL then
            velocity = ENTITY.GET_ENTITY_VELOCITY(prev_veh)
        end
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

return custom_vehicles