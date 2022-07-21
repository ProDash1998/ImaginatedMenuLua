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
 
  lib/inmem.lua
  lua-cache
  
  Created by Masatoshi Teruya on 14/11/07.
  
--]]

-- modules
local clone = require('util.table').clone;
local Cache = require('cache');
local time = os.time;

-- class
local InMem = require('halo').class.InMem;


function InMem:init( ttl )
    protected(self).data = {};
    
    return Cache.new( self, ttl );
end


function InMem:set( key, val, ttl )
    
    if type( val ) == 'table' then
        val = clone( val );
    end
    
    protected(self).data[key] = {
        ttl = ttl <= 0 and 0 or time() + ttl,
        val = val
    };
    
    return true;
end


function InMem:get( key, ttl )
    local data = protected(self).data;
    local item;
    
    item = data[key];
    -- not defined
    if not item then
        return nil;
    -- delete expired item
    elseif item.ttl > 0 and item.ttl <= time() then
        data[key] = nil;
        return nil;
    -- update ttl
    elseif ttl ~= nil then
        item.ttl = ttl <= 0 and 0 or time() + ttl;
    end

    return clone( item.val );
end


function InMem:delete( key )
    local data = protected(self).data;
    
    if data[key] then
        data[key] = nil;
    end
    
    return true;
end


function InMem:rename( okey, nkey )
    local data = protected(self).data;
    
    if data[okey] then
        data[nkey], data[okey] = data[okey], nil;
    end
    
    return true;
end


return InMem.exports;
