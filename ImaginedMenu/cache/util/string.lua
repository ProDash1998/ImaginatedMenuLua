--[[

  Copyright (C) 2014 Masatoshi Teruya
 
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
 
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
 
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.

--]]

local function charAt( self, idx )
    return self:sub( idx, idx );
end


local function charCodeAt( ... )
    return string.byte( ... );
end


local function split( self, delim )
    local arr = {};
    local last = #self + 1;
    local len = 0;
    local cur = 1;
    local head, tail = self:find( delim, cur );
    
    while head do
        if head ~= cur then
            len = len + 1;
            rawset( arr, len, self:sub( cur, head - 1 ) );
        end
        cur = tail + 1;
        head, tail = self:find( delim, cur );
    end
    
    if cur < last then
        rawset( arr, len + 1, self:sub( cur ) );
    end
    
    return arr;
end


local function trim( self )
    return self:match( '^[%s]*(.*[^%s])[%s]*$' ) or '';
end


local ORG = {};

do
    local mt = debug.getmetatable( '' );
    
    for k,v in pairs( mt.__index ) do
        ORG[k] = v;
    end
end

local function extend( overwrite )
    local mt = debug.getmetatable( '' );
    
    for k,v in pairs({
        charAt = charAt,
        charCodeAt = charCodeAt,
        split = split,
        trim = trim
    }) do
        if not mt.__index[k] or overwrite == true then
            mt.__index[k] = v;
        end
    end
    
    debug.setmetatable( '', mt );
end

local function unextend()
    local mt = debug.getmetatable( '' );
    
    mt.__index = ORG;
    
    debug.setmetatable( '', mt );
end

return {
    extend = extend,
    unextend = unextend,
    charAt = charAt,
    charCodeAt = charCodeAt,
    split = split,
    trim = trim
};
