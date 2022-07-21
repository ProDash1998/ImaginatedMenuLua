--[[

  Copyright (C) 2014-2015 Masatoshi Teruya

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


  lib/util.lua
  lua-halo
  Created by Masatoshi Teruya on 15/07/08.

--]]
--- file-scope variables
local require = require;
local loadchunk = require('loadchunk').string;
local type = type;
local assert = assert;
local tostring = tostring;
local getfenv = getfenv;
local rawget = rawget;
local rawset = rawset;
local pairs = pairs;
local ipairs = ipairs;
local iolines = io.lines;
local tblsort = table.sort;
local tblconcat = table.concat;
local getinfo = debug.getinfo;
local getlocal = debug.getlocal;
local getupvalue = debug.getupvalue;
local setupvalue = debug.setupvalue;
local strfind = string.find;
local strsub = string.sub;
local strgsub = string.gsub;
local strmatch = string.match;
local strformat = string.format;
local strdump = string.dump;
--- constants
local LUA_VERS = tonumber( _VERSION:match( 'Lua (.+)$' ) );


--- split
-- @param str
-- @param pat
-- @return arr
local function split( str, pat )
    local arr = {};
    local idx = 0;
    local cur = 1;
    local last = #str + 1;
    local head, tail = strfind( str, pat, cur );

    while head do
        if head ~= cur then
            idx = idx + 1;
            arr[idx] = strsub( str, cur, head - 1 );
        end
        cur = tail + 1;
        head, tail = strfind( str, pat, cur );
    end

    if cur < last then
        arr[idx + 1] = strsub( str, cur );
    end

    return arr;
end


local function getPackagePath()
    local lv = 1;
    local prev;

    repeat
        local info = getinfo( lv, 'nS' );

        if info then
            if info.what == 'C' and info.name == 'require' then
                return prev.source;
            end
            prev = info;
            lv = lv + 1;
        end
    until info == nil;

    return nil;
end


local function sortByLength( a, b )
    return #a > #b;
end


local function getPackageName()
    local src = getPackagePath();

    if src then
        local lpath = split( package.path, ';' );

        -- sort by length
        tblsort( lpath, sortByLength );
        -- find filepath
        for _, path in ipairs( lpath ) do
            path = strgsub( path, '%-', '%%-' );
            path = strgsub( path, '%?.+$', '(.+)[.]lua' );
            path = strmatch( src, path );
            if path then
                return strgsub( path, '/', '.' );
            end
        end
    end

    return nil;
end


local function hasImplicitSelfArg( method, info )
    -- for Lua5.2
    if LUA_VERS > 5.1 then
        return getlocal( method, 1 ) == 'self';
    -- for Lua5.1
    else
        local head, tail = info.linedefined, info.lastlinedefined;
        local lineno = 0;
        local src = {};
        local idx = 0;

        for line in iolines( strsub( info.source, 2 ) ) do
            lineno = lineno + 1;
            if lineno > tail then
                break;
            elseif lineno >= head then
                idx = idx + 1;
                src[idx] = line;
            end
        end

        src = tblconcat( src, '\n' );
        return strfind( src, '^%s*function%s[^:%s]+%s*:%s*[^%s]+%s*[(]' ) ~= nil;
    end
end


local function getFunctionId( func )
    return strformat('%s', strgsub( tostring(func), '^function: 0x0*', '' ) );
end


local function getUpvalues( fn )
    local upv = {};
    local i = 1;
    local k, v = getupvalue( fn, i );
    local env;

    while k do
        if env == nil and k == '_ENV' then
            env = v;
        end
        upv[i] = { key = k, val = v };
        i = i + 1;
        k, v = getupvalue( fn, i );
    end

    return upv, env;
end



local function getEnv( fn )
    local upv, env = getUpvalues( fn );

    if LUA_VERS > 5.1 then
        if not env then
            env = _G;
        end
    else
        env = {};
        for k,v in pairs( getfenv( fn ) or {} ) do
            env[k] = v;
        end
    end

    return upv, env;
end


local function mergeRight( dest, src )
    local tbl = type( dest ) == 'table' and dest or {};

    for k,v in pairs( src ) do
        if type( v ) == 'table' then
            rawset( tbl, k, mergeRight( tbl and rawget( tbl, k ), v ) );
        else
            rawset( tbl, k, v );
        end
    end

    return tbl;
end


local function mergeLeft( dest, src )
    local lv;

    for k,v in pairs( src ) do
        lv = rawget( dest, k );
        if not lv then
            if type( v ) == 'table' then
                rawset( dest, k, mergeRight( nil, v ) );
            else
                rawset( dest, k, v );
            end
        -- merge table
        elseif type( v ) == 'table' and type( lv ) == 'table' then
            mergeLeft( lv, v );
        end
    end
end


local function cloneFunction( fn )
    local upv, env = getEnv( fn );

    fn = strdump( fn );
    fn = assert( loadchunk( fn, env ) );
    -- copy to upvalues
    for i, kv in ipairs( upv ) do
        setupvalue( fn, i, kv.val );
    end

    return fn, env;
end


local function cloneTable( val )
    local ctbl = {};
    local idx = 1;
    local stack = {
        { tbl = ctbl, kvp = val }
    }

    while idx > 0 do
        local top = stack[idx].top;
        local key = stack[idx].key;
        local tbl = stack[idx].tbl;
        local kvp = stack[idx].kvp;

        idx = idx - 1;
        for k, v in pairs( kvp ) do
            if type( v ) == 'table' then
                idx = idx + 1;
                stack[idx] = {
                    top = tbl,
                    key = k,
                    tbl = {},
                    kvp = v
                };
            else
                tbl[k] = v;
            end
        end

        -- set clone-table at parent-table
        if top then
            top[key] = tbl;
        end
    end

    return ctbl;
end


return {
    getPackageName = getPackageName,
    hasImplicitSelfArg = hasImplicitSelfArg,
    getFunctionId = getFunctionId,
    mergeRight = mergeRight,
    mergeLeft = mergeLeft,
    cloneFunction = cloneFunction,
    cloneTable = cloneTable,
};

