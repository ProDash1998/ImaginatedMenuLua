--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--

local vect = {}

local sin = math.sin
local cos = math.cos
local sqrt = math.sqrt
local abs = math.abs
local rad = math.rad
local asin = math.asin
local atan = math.atan
local pi = math.pi

vect.new = function(X, Y, Z)
    return {x = X or 0, y = Y or 0, z = Z or 0}
end

vect.subtract = function(a,b)
    return vect.new(a.x - b.x, a.y - b.y, a.z - b.z)
end

vect.add = function(a,b)
    return vect.new(a.x + b.x, a.y + b.y, a.z + b.z)
end

vect.mag = function(a)
    return sqrt(a.x^2 + a.y^2 + a.z^2)
end

vect.mag2 = function(a)
    return (a.x^2 + a.y^2 + a.z^2)
end

vect.norm = function(a)
    local mag = vect.mag(a)
    return vect.mult(a, 1/mag)
end

vect.mult = function(a,b)
    return vect.new(a.x*b, a.y*b, a.z*b)
end

vect.dist = function(a,b) --[[returns the distance between two coords]]
    return vect.mag(vect.subtract(a, b))
end

vect.dist2 = function(a,b)
    return vect.mag2(vect.subtract(a, b))
end

vect.tostring = function(a)
    if not a.h then a.h = 0 end
    return  string.format("{x = %.3f, y = %.3f, z = %.3f, h = %3.f}", a.x, a.y, a.z, a.h)
end

function vect.to_rotation(v)
    local mag = vect.mag(v)
    return {
        x = asin(v.z / mag) * (180 / pi),
        y = 0.0,
        z = - atan(v.x, v.y) * (180 / pi)
    }
end

function vect.get_offset_coords_from_entity_rot(entity, dist, offheading, ignore_z)
    local pos = ENTITY.GET_ENTITY_COORDS(entity, false)
    local rot = ENTITY.GET_ENTITY_ROTATION(entity, 2)
    local dist = dist or 5
    local offheading = offheading or 0
    local offz = 0
    local vector = {
        x = -sin(rad(rot.z + offheading)) * dist, 
        y = cos(rad(rot.z + offheading)) * dist,
        z = sin(rad(rot.x)) * dist
    }
    if not ignore_z then
        offz = vector.z
    end

    return {
        x = pos.x + vector.x,
        y = pos.y + vector.y,
        z = pos.z + offz
    }
end

function vect.rotation_to_direction(rotation)
    local ret = {
        z = rad(rotation.z),
        x = rad(rotation.x)
    }
    local absx = abs(cos(ret.x))
    return {
        x = -sin(ret.z) * absx,
        y = cos(ret.z) * absx,
        z = sin(ret.x)
    }
end

function vect.set_entity_face_entity(ent1, ent2, usePitch)
    local a = ENTITY.GET_ENTITY_COORDS(ent1, false)
    local b = ENTITY.GET_ENTITY_COORDS(ent2, false)
    local s = vect.subtract(b,a)
    local r = vect.to_rotation(s)
    if not usePitch then
        ENTITY.SET_ENTITY_HEADING(ent1, r.z)
    else
        ENTITY.SET_ENTITY_ROTATION(ent1, r.x, r.y, r.z, 2, true)
    end
end

return vect