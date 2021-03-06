-- Copyright © 2022 SATTY
--
-- @constructor    vector3()
-- @constructor    vector3(float)
-- @constructor    vector3(float, float, float)

local floor = math.floor
local max = math.max
local min = math.min
local sqrt = math.sqrt
local rad = math.rad
local abs = math.abs
local ceil = math.ceil
local asin = math.asin
local atan = math.atan
local atan2 = math.atan2
local sin = math.sin
local cos = math.cos
local pi = math.pi
local insert = table.insert
local type = type
local unpack = unpack
local setmetatable = setmetatable

local vector3 = {}
vector3.__index = vector3

setmetatable(vector3,
    {
        __call = function(class, ...)
            local instance = {}
            setmetatable(instance, vector3)
            instance:new(...)
            return instance
        end
    }
)

--[[bool]] function vector3.is_vector(vec)
    return getmetatable(vec) == vector3
end

--[[vector3]] function vector3.zero()
    return vector3(0, 0, 0)
end

--[[vector3]] function vector3.one(--[[float]] value)
    return vector3(1, 1, 1) * (value or 1)
end

--[[vector3]] function vector3.forward(--[[float]] value)
    return vector3(0, 1, 0) * (value or 1)
end

--[[vector3]] function vector3.back(--[[float]] value)
    return vector3(0, -1, 0) * (value or 1)
end

--[[vector3]] function vector3.right(--[[float]] value)
    return vector3(1, 0, 0) * (value or 1)
end

--[[vector3]] function vector3.left(--[[float]] value)
    return vector3(-1, 0, 0) * (value or 1)
end

--[[vector3]] function vector3.up(--[[float]] value)
    return vector3(0, 0, 1) * (value or 1)
end

--[[vector3]] function vector3.down(--[[float]] value)
    return vector3(0, 0, -1) * (value or 1)
end

--[[vector3]] function vector3:new(...)
    if #{...} == 1 and type(...) == 'table' then
        local input = ...
        self.x = input.x or 0
        self.y = input.y or 0
        self.z = input.z or 0
    elseif #{...} == 1 and type(...) == 'number' then
        local input = ...
        self.x = input
        self.y = input
        self.z = input
    else
        local x, y, z = ...
        self.x = x or 0
        self.y = y or 0
        self.z = z or 0
    end
end

--[[string]] function vector3:__tostring()
    local x = floor(self.x) == self.x and string.format("%d", self.x) or string.format("%f", self.x)
    local y = floor(self.y) == self.y and string.format("%d", self.y) or string.format("%f", self.y)
    local z = floor(self.z) == self.z and string.format("%d", self.z) or string.format("%f", self.z)
    return string.format("%s, %s, %s", x, y, z)
end

--[[vector3]] function vector3:__add(--[[vector3]] vec)
    return vector3(self.x + vec.x, self.y + vec.y, self.z + vec.z)
end

--[[vector3]] function vector3:__sub(--[[vector3]] vec)
    return vector3(self.x - vec.x, self.y - vec.y, self.z - vec.z)
end

--[[vector3]] function vector3:__unm()
    return vector3(-self.x, -self.y, -self.z)
end

--[[vector3]] function vector3:__mul(--[[float]] value)
    if type(value) == 'number' then
        return vector3(self.x * value, self.y * value, self.z * value)
    elseif type(self) == 'number' then
        return vector3(value.x * self, value.y * self, value.z * self)
    elseif vector3.is_vector(value) then
        return vector3(self.x * value.x, self.y * value.y, self.z * value.z)
    end
end

--[[vector3]] function vector3:__pow(--[[float]] value)
    if value == 2 then
        return self * self
    end
    return vector3(self.x ^ value, self.y ^ value, self.z ^ value)
end

--[[vector3]] function vector3:__div(--[[float]] value)
    return vector3(self.x / value, self.y / value, self.z / value)
end

--[[bool]] function vector3:__eq(--[[vector3]] vec)
    return (self.x == vec.x) and (self.y == vec.y) and (self.z == vec.z)
end

--[[bool]] function vector3:__lt(--[[vector3]] vec)
     return (self.x < vec.x) and (self.y < vec.y) and (self.z < vec.z)
end

--[[bool]] function vector3:__le(--[[vector3]] vec)
     return (self.x <= vec.x) and (self.y <= vec.y) and (self.z <= vec.z)
end

--[[vector3]] function vector3:inverse()
    return vector3(1 / self.x, 1 / self.y, 1 / self.z)
end

--[[vector3]] function vector3.max(--[[vector3]] ...)
    local vectors = {
        x = {},
        y = {},
        z = {}
    }
    for _, i in ipairs({...})
    do
        for k, v in pairs(i)
        do
            if k == 'x' or k == 'y' or k == 'z' then
                insert(vectors[k], v)
            end
        end
    end
    return vector3(
        max(unpack(vectors.x)),
        max(unpack(vectors.y)),
        max(unpack(vectors.z))
    )
end

--[[vector3]] function vector3.min(--[[vector3]] ...)
    local vectors = {
        x = {},
        y = {},
        z = {}
    }
   for _, i in ipairs({...})
   do
        for k, v in pairs(i)
        do
            if k == 'x' or k == 'y' or k == 'z' then
                insert(vectors[k], v)
            end
        end
    end
    return vector3(
        min(unpack(vectors.x)),
        min(unpack(vectors.y)),
        min(unpack(vectors.z))
    )
end

--[[vector3]] function vector3:cross(--[[vector3]] vec)
    return vector3(
        (self.y * vec.z) - (self.z * vec.y),
        (self.z * vec.x) - (self.x * vec.z),
        (self.x * vec.y) - (self.y * vec.x)
    )
end

--[[float]] function vector3:mag()
    local v = self ^ 2
    return sqrt(v.x + v.y + v.z)
end

--[[float]] function vector3:sqrmag()
    local v = self ^ 2
    return v.x + v.y + v.z
end

--[[float]] function vector3:dot(--[[vector3]] vec)
    return (self.x * vec.x) + (self.y * vec.y) + (self.z * vec.z)
end

--[[vector3]] function vector3:rad()
    return vector3(rad(self.x), rad(self.y), rad(self.z))
end

--[[vector3]] function vector3:abs()
    return vector3(abs(self.x), abs(self.y), abs(self.z))
end

--[[vector3]] function vector3:floor()
    return vector3(floor(self.x), floor(self.y), floor(self.z))
end

--[[vector3]] function vector3:ceil()
    return vector3(ceil(self.x), ceil(self.y), ceil(self.z))
end

--[[vector3]] function vector3:norm()
    return self * (1 / self:mag())
end

--[[vector3]] function vector3:clamp(--[[vector3]] min, --[[vector3]] max)
    local x = self.x
    x = x > max.x and max.x or x
    x = x < min.x and min.x or x
    local y = self.y
    y = y > max.y and max.y or y
    y = y < min.y and min.y or y
    local z = self.z
    z = z > max.z and max.z or z
    z = z < min.z and min.z or z
    return vector3(x, y, z)
end

--[[vector3]] function vector3:lerp(--[[vector3]] vec, --[[float]] t)
    if t > 0 and t < 1 then
        return self + ((vec - self) * t)
    end
end

--Distance between 2 vectors
--[[float]] function vector3:len(--[[vector3]] vec) 
    return (self - vec):mag()
end

--[[float]] function vector3:sqrlen(--[[vector3]] vec)
    return (self - vec):sqrmag()
end

--[[vector3]] function vector3:scale(--[[vector3]] vec)
    return vector3(self.x * vec.x, self.y * vec.y, self.z * vec.z)
end

--[[vector3]] function vector3:minimize(--[[vector3]] vec)
    return vector3(
        self.x < vec.x and self.x or vec.x,
        self.y < vec.y and self.y or vec.y,
        self.z < vec.z and self.z or vec.z
    )
end

--[[vector3]] function vector3:maximize(--[[vector3]] vec)
    return vector3(
        self.x > vec.x and self.x or vec.x,
        self.y > vec.y and self.y or vec.y,
        self.z > vec.z and self.z or vec.z
    )
end

--[[vector3]] function vector3:move_towards(--[[vector3]] vec, --[[float]] maxdist)
    local v_new = vec - self
    local sqdist = vec:sqrlen(self)
    if sqdist == 0 or (maxdist >= 0 and sqdist <= maxdist ^ 2) then
        return vec
    end
    local dist = sqrt(sqdist)
    
    return vector3(
        self.x + v_new.x / dist * maxdist,
        self.y + v_new.y / dist * maxdist,
        self.z + v_new.z / dist * maxdist
    )
end

--[[vector3]] function vector3:reflect(--[[vector3]] normal)
    local factor = -2 * normal:dot(self)
    return vector3(
        factor * normal.x + self.x,
        factor * normal.y + self.y,
        factor * normal.z + self.z
    )
end

--[[vector3]] function vector3:clone()
    return vector3(self.x, self.y, self.z)
end

--[[vector3]] function vector3:to_rotation()
    return vector3(
        vector3.rad_to_deg(asin(self.z / self:mag())),
        0.0,
        vector3.rad_to_deg(-atan(self.x, self.y))
    )
end

--[[vector3]] function vector3:rot_to_direction()
    local ret = {
        z = rad(self.z),
        x = rad(self.x)
    }
    local absx = abs(cos(ret.x))
    return vector3(
        -sin(ret.z) * absx,
        cos(ret.z) * absx,
        sin(ret.x)
    )
end

--[[vector3]] function vector3:direction_to_rot()
    self = self:norm()
    return vector3(
        vector3.rad_to_deg(atan2(self.z, self.y)),
        0,
        vector3.rad_to_deg(-atan2(self.x, self.y))
    )
end

--[[vector3]] function vector3:direction_to(--[[vector3]] vec)
    local vec = vec or vector3.zero()
    if vec == self then return vector3.zero() end
    return (vec - self):norm()
end

--[[float]] function vector3:angle()
    return atan2(self.y, self.x)
end

--[[float]] function vector3.rad_to_deg(--[[float]] value)
    return value * (180 / pi)
end

--[[vector3]] function vector3:point_on_sphere(--[[float]] longitude,--[[float]] latitude,--[[float]] radius)
    local radius = radius or 1
    local u = rad(longitude)
    local v = rad(latitude)
    return vector3(radius * sin(u) * cos(v), radius * cos(u) * cos(v), radius * sin(v)) + self
end

--[[vector3]] function vector3:point_on_circle(--[[float]] angle,--[[float]] radius)
    local radius = radius or 1
    return vector3(cos(angle), sin(angle), 0) * radius + self
end

--[[array]] function vector3:points_on_circle(--[[int]] amount,--[[float]] radius)
    local points = {}
    local step = 360 / amount
    for i = 1, amount
    do
        local angle = rad(step * i)
        insert(points, self:point_on_circle(angle, radius))
    end
    return points
end

--[[float, float, float]] function vector3:get()
    return self.x, self.y, self.z
end

return vector3
