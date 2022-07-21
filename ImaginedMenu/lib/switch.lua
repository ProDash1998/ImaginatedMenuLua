local switch = {}
switch.__index = switch

local setmetatable = setmetatable
local ipairs = ipairs
local select = select
local type = type

switch.__call = function(self, v, ...)
    local c = self._callbacks[v] or self._default
    if not c then return end
    return c(...)
end

function switch:case(...)
    local f = select(select('#', ...), ...)
    for _, v in ipairs({...})
    do
        if type(v) == 'function' then return self end
        if not self._callbacks[v] then
            self._callbacks[v] = f
        end
    end
end

function switch:default(f)
    self._default = f
    return self
end

return function() 
    return setmetatable({_callbacks = {}}, switch) 
end