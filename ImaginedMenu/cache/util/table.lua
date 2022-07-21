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
local typeof = require('util.typeof');
local split = require('util.string').split;

local function copy( tbl )
    local ctbl = {};
    local len = 0;
    
    for k, v in pairs( tbl ) do
        len = len + 1;
        rawset( ctbl, k, v );
    end
    
    return ctbl, len;
end


local CLONE_SAFE_VAL = {
    ['string'] = 1,
    ['number'] = 1,
    ['boolean'] = 1,
};

local function _cloneSafe( tbl )
    local ctbl = {};
    local t;
    
    for k, v in pairs( tbl ) do
        -- key type: string, unsigned int
        if typeof.string( k ) or typeof.uint( k ) then
            t = type( v );
            if t == 'table' then
                ctbl[k] = _cloneSafe( v );
            elseif CLONE_SAFE_VAL[t] then
                ctbl[k] = v;
            end
        end
    end
    
    return ctbl;
end

local function cloneSafe( val )
    local t = type( val );
    
    if t == 'table' then
        return _cloneSafe( val );
    end
    
    return CLONE_SAFE_VAL[t] and val or nil;
end


local function _clone( tbl )
    local ctbl = {};
    
    for k, v in pairs( tbl ) do
        if type( v ) == 'table' then
            ctbl[k] = _clone( v );
        else
            ctbl[k] = v;
        end
    end
    
    return ctbl;
end

local function clone( val )
    local t = type( val );
    
    if t == 'table' then
        return _clone( val );
    end
    
    return val;
end


local function _esealed()
    error( 'could not add property to sealed table' );
end

local function seal( tbl )
    tbl = copy( tbl );
    return setmetatable( tbl, {
        __newindex = _esealed
    });
end


local function _efreezed()
    error( 'could not add/modify property to freezed table' );
end

local function freeze( tbl )
    return setmetatable( {}, {
        __index = tbl,
        __newindex = _efreezed
    });
end


local function keys( tbl )
    local res = {};
    local len = 0;
    
    for k in pairs( tbl ) do
        if type( k ) == 'string' then
            len = len + 1;
            rawset( res, len, k );
        end
    end
    
    return res, len;
end


local function get( tbl, key, delim )
    local _;
    
    for _, key in ipairs( split( key, '[' .. ( delim or '.' ) .. ']' ) ) do
        if type( tbl ) ~= 'table' then
            return nil;
        elseif key:match('^%d+$') then
            tbl = tbl[key] or tbl[tonumber( key )];
        else
            tbl = tbl[key];
        end
    end
    
    return tbl;
end


local function set( tbl, key, val, delim )
    local prev = tbl;
    
    delim = delim or '.';
    key:gsub( '([^' .. delim .. ']+)', function( k )
        if k:match('^%d+$') then
            k = tonumber( k );
        end
        key = k;
        tbl = prev;
        if type( tbl[k] ) == 'table' then
            prev = tbl[k];
        else
            prev = {};
            tbl[k] = prev;
        end
    end);
    
    tbl[key] = val;
end


local function merge( tbl, ... )
    local res, len = copy( tbl );
    local k, v;
    
    -- traverse arguments
    for _, arg in ipairs({ ... }) do
        -- traverse table
        if type( arg ) == 'table' then
            k, v = next( arg );
            while k do
                -- indexed value
                if type( k ) == 'number' then
                    len = len + 1;
                    rawset( res, len, v );
                -- keyed value
                else
                    rawset( res, k, v );
                end
                k, v = next( arg, k );
            end
        -- add arg
        else
            len = len + 1;
            rawset( res, len, arg );
        end
    end
    
    return res;
end


local function _enumerate( res, tbl, toFlat, flatLv, lv, circular, prefix )
    local k,v = next( tbl );
    local NEXT_ITEM = false;
    local ref;
    
    prefix = prefix and prefix .. '.' or '';
    while k do
        if type( v ) == 'table' then
            -- check circular
            ref = tostring( v );
            if circular[ref] then
                rawset( res, prefix .. k, v );
            -- set value
            else
                if flatLv > 0 and flatLv < lv then
                    rawset( res, prefix .. k, v );
                    NEXT_ITEM = toFlat;
                end
                
                if NEXT_ITEM then
                    NEXT_ITEM = false;
                else
                    -- set address
                    rawset( circular, ref, true );
                    _enumerate( res, v, toFlat, flatLv, lv + 1, circular, prefix .. k );
                    -- remove address
                    rawset( circular, ref, nil );
                end
            end
        else
            rawset( res, prefix .. k, v );
        end
        
        k, v = next( tbl, k );
    end
    
    return res;
end

local function enumerate( tbl, lv )
    return _enumerate( {}, tbl, false, typeof.finite( lv ) and lv or 1, 2, {} );
end

local function flatten( tbl, lv )
    return _enumerate( {}, tbl, true, typeof.finite( lv ) and lv or 0, 2, {} );
end


local function align( tbl )
    local arr = {};
    local len = 0;
    
    for k, v in pairs( tbl ) do
        len = len + 1;
        rawset( arr, len, { key = k, val = v });
    end
    
    return arr, len;
end


local function each( tbl, t, fn, ... )
    local k,v = next( tbl );
    
    if t then
        while k do
            if type( k ) == t and fn( v, k, tbl, ... ) == true then
                break;
            end
            k,v = next( tbl, k );
        end
    else
        while k do
            if fn( v, k, tbl, ... ) == true then
                break;
            end
            k,v = next( tbl, k );
        end
    end
end

local function eachKey( tbl, fn, ... )
    each( tbl, 'string', fn, ... );
end

local function eachIndex( tbl, fn, ... )
    each( tbl, 'number', fn, ... );
end


-- find last index number
local function lastIndex( tbl )
    local tail;
    
    for idx in pairs( tbl ) do
        -- lua ignore the order of array
        if type( idx ) == 'number' and ( not tail or tail < idx ) then
            tail = idx;
        end
    end
    
    return tail;
end


local function pop( tbl )
    return table.remove( tbl );
end


local function push( tbl, ... )
    local args = {...};
    
    for idx = 1, #args do
        table.insert( tbl, args[idx] );
    end
    
    return #tbl;
end


local function shift( tbl )
    return table.remove( tbl, 1 );
end


local function unshift( tbl, ... )
    local args = {...};
    
    for idx = 1, #args do
        table.insert( tbl, idx, args[idx] );
    end
    
    return #tbl;
end


local function reverse( tbl )
    local len = #tbl;
    local ridx;
    
    for idx = 1, len/2 do
        ridx = len - idx + 1;
        tbl[idx], tbl[ridx] = tbl[ridx], tbl[idx];
    end
end


local function join( tbl, sep )
    local res = {};
    local len = 0;
    local k, v = next( tbl );
    local t;
    
    while k do
        if type( k ) == 'number' then
            t = type( v );
            len = len + 1;
            if t == 'string' or t == 'number' then
                rawset( res, len, v );
            else
                rawset( res, len, tostring( v ) );
            end
        end
        k, v = next( tbl, k );
    end
    
    return table.concat( res, sep ), len;
end


local function slice( tbl, head, tail )
    local res = {};
    local len = #tbl;
    
    if head < 0 then
        head = len + head + 1;
        if head < 1 then
            head = 1;
        end
    end
    
    if not tail then
        tail = len;
    elseif tail < 0 then
        tail = len + tail + 1;
    end
    
    len = 0;
    for cur = head, tail do
        len = len + 1;
        rawset( res, len, tbl[cur] );
    end
    
    return res, len;
end


local function indexOf( tbl, val, head )
    local idx;
    
    if not head then
        head = 1;
    end
    
    if head > 0 then 
        local v;
        
        idx, v = next( tbl );
        while idx do
            if type( idx ) == 'number' and idx >= head then
                if v == val then
                    return idx;
                end
            end
            idx, v = next( tbl, idx );
        end
    end
    
    return nil;
end


local function every( tbl, fn, ... )
    local k, v = next( tbl );
    
    while k do
        if type( k ) == 'number' and fn( v, k, tbl, ... ) == false then
            return false;
        end
        k, v = next( tbl, k );
    end
    
    return true;
end


local function some( tbl, fn, ... )
    local k, v = next( tbl );
    
    while k do
        if type( k ) == 'number' and fn( v, k, tbl, ... ) == true then
            return true;
        end
        k, v = next( tbl, k );
    end
    
    return false;
end


local function filter( tbl, fn, ... )
    local res = {};
    local len = 0;
    local k, v = next( tbl );
    
    while k do
        if type( k ) == 'number' and fn( v, k, tbl, ... ) == true then
            len = len + 1;
            rawset( res, len, v );
        end
        k, v = next( tbl, k );
    end
    
    return res, len;
end


local function map( tbl, fn, ... )
    local res = {};
    local len = 0;
    local k, v = next( tbl );
    
    while k do
        if type( k ) == 'number' then
            v = fn( v, k, tbl, ... );
            if v ~= nil then
                len = len + 1;
                rawset( res, len, v );
            end
        end
        k, v = next( tbl, k );
    end
    
    return res, len;
end


local function reduce( tbl, fn, initVal, ... )
    local prev = initVal;
    local k, cur = next( tbl );
    
    while k do
        if type( k ) == 'number' then
            if initVal == nil then
                prev = cur;
                initVal = prev;
            else
                prev = fn( prev, cur, k, tbl, ... );
            end
        end
        k, cur = next( tbl, k );
    end
    
    return prev;
end




local METHODS = {
    -- table
    copy = copy,
    clone = clone,
    cloneSafe = cloneSafe,
    seal = seal,
    freeze = freeze,
    keys = keys,
    get = get,
    set = set,
    merge = merge,
    enumerate = enumerate,
    flatten = flatten,
    align = align,
    each = each,
    eachKey = eachKey,
    -- array
    eachIndex = eachIndex,
    lastIndex = lastIndex,
    pop = pop,
    push = push,
    shift = shift,
    unshift = unshift,
    reverse = reverse,
    join = join,
    slice = slice,
    indexOf = indexOf,
    every = every,
    some = some,
    filter = filter,
    map = map,
    reduce = reduce,
};
local ORG, EXPORT;

local function extend( overwrite )
    for k,v in pairs( METHODS ) do
        if not table[k] or overwrite == true then
            table[k] = v;
        end
    end
end

local function unextend()
    table = ORG;
end

do
    ORG = {};
    for k,v in pairs( table ) do
        ORG[k] = v;
    end
    
    EXPORT = {
        extend = extend,
        unextend = unextend,
    };
    for k,v in pairs( METHODS ) do
        EXPORT[k] = v;
    end
end

return EXPORT;
