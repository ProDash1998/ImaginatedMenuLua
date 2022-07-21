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
  
  cache.lua
  lua-cache
  
  Created by Masatoshi Teruya on 14/11/07.
  
--]]

-- modules
local typeof = require('util').typeof;
local KEYTYPE = {
    ['string']  = true
};
local VALTYPE = {
    ['boolean'] = true,
    ['string']  = true,
    ['table']   = true,
    ['number']  = typeof.finite,
};
local EKEYTYPE = 'key must be string';
local EVALTYPE = '%q must be boolean, string, table or finite number';
local ETTLTYPE = 'ttl must be unsigned integer';
local ERETTYPE = 'store returned an invalid value';
local ENOSUP = 'store does not supports a rename method';
-- if ttl <= 0 then forever
local DEFAULT_TTL = 3600


-- class
local Cache = require('halo').class.Cache;

function Cache:init( store, ttl )
    local own = protected( self );
    
    if ttl ~= nil and not typeof.uint( ttl ) then
        return nil, ETTLTYPE;
    -- cache storage should implement get, set and delete method
    elseif not typeof.table( store ) or 
           not typeof.Function( store.get ) or 
           not typeof.Function( store.set ) or 
           not typeof.Function( store.delete ) then
        return nil, 'store should implement get, set and delete method';
    -- optional impments
    elseif ( store.rename ~= nil and not typeof.Function( store.rename ) ) then
        return nil, 'store.rename method must be function';
    end
    
    own.ttl = ttl or DEFAULT_TTL;
    own.store = store;
    
    return self;
end


function Cache:get( key, defval, ttl )
    local val, err, t;

    -- check arguments
    if not KEYTYPE[type(key)] then
        return nil, EKEYTYPE;
    elseif ttl ~= nil and not typeof.uint( ttl ) then
        return nil, ETTLTYPE;
    end

    val, err = protected( self ).store:get( key, ttl );
    if err then
        return nil, err;
    elseif val ~= nil then
        local t = VALTYPE[type(val)];
        
        if t == true or t and t( val ) then
            return val;
        end
        
        -- store returned an invalid value
        return nil, ERETTYPE;
    -- return default value
    elseif defval ~= nil then
        local t = VALTYPE[type(defval)];
        
        if t == true or t and t( defval ) then
            return defval;
        end
        
        -- invalid default value type
        return nil, EVALTYPE:format( 'defval' );
    end
    
    return nil;
end


function Cache:set( key, val, ttl )
    local own = protected( self );
    local t = VALTYPE[type(val)];
    
    if ttl ~= nil and not typeof.uint( ttl ) then
        return false, ETTLTYPE;
    elseif not KEYTYPE[type(key)] then
        return false, EKEYTYPE;
    elseif t == true or t and t( val ) then
        -- boolean, err
        return own.store:set( key, val, ttl or own.ttl );
    end
    
    return false, EVALTYPE:format( 'val' );
end


function Cache:delete( key )
    if not KEYTYPE[type(key)] then
        return false, EKEYTYPE;
    end
    
    -- boolean, err
    return protected( self ).store:delete( key );
end


function Cache:rename( okey, nkey )
    local store = protected( self ).store;

    if not store.rename then
        return false, ENOSUP;
    elseif not KEYTYPE[type(okey)] or not KEYTYPE[type(nkey)] then
        return false, EKEYTYPE;
    end
    
    -- boolean, err
    return store:rename( okey, nkey );
end


return Cache.exports;
