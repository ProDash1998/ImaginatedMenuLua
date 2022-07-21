--[[

  Copyright (C) 2013 Masatoshi Teruya
 
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

-- module
local format = string.format;
local match = string.match;
local sort = table.sort;
local concat = table.concat;
local getupvalue = debug.getupvalue;
local setupvalue = debug.setupvalue;
-- constants
local LUA_VERSION = tonumber( match( _VERSION, 'Lua (.+)$' ) );
local LUA_FIELDNAME_PAT = '^[a-zA-Z_][a-zA-Z0-9_]*$';
local FOR_INDEX = 'index';
local FOR_VALUE = 'value';
local FOR_CIRCULAR = 'circular';
-- default indentaion
local INDENT_LV = 4;
local RESERVED_WORD = {
    -- primitive data
    ['nil']         = true,
    ['true']        = true,
    ['false']       = true,
    -- declaraton
    ['local']       = true,
    ['function']    = true,
    -- boolean logic
    ['and']         = true,
    ['or']          = true,
    ['not']         = true,
    -- conditional statement
    ['if']          = true,
    ['elseif']      = true,
    ['else']        = true,
    -- iteration statement
    ['for']         = true,
    ['in']          = true,
    ['while']       = true,
    ['until']       = true,
    ['repeat']      = true,
    -- jump statement
    ['break']       = true,
    ['goto']        = true,
    ['return']      = true,
    -- block scope statement
    ['then']        = true,
    ['do']          = true,
    ['end']         = true
};

-- defaultCallback( value, valueType, valueFor, key, udata )
local function defaultCallback( value )
    return value;
end


local function sortIndex( a, b )
    if a.typ == b.typ then
        if a.typ == 'boolean' then
            return b.key;
        end
        
        return a.key < b.key;
    end
    
    return a.typ == 'number';
end


local function _inspect( obj, indent, nestIndent, ctx )
    local ref = tostring( obj );
    local val;
    
    -- circular reference
    if not ctx.circular[ref] then
        local res = {};
        local arr = {};
        local narr = 0;
        local fieldIndent = indent .. nestIndent;
        local arrFmt = fieldIndent .. '[%s] = %s';
        local strFmt = fieldIndent .. '%s = %s';
        local ptrFmt = fieldIndent .. '[%q] = %s';
        local t, skip, raw;
        
        -- save reference
        rawset( ctx.circular, ref, true );
        
        for k, v in pairs( obj ) do
            -- key
            val, skip = ctx.callback( k, type( k ), FOR_INDEX, nil, ctx.udata );
            if not skip then
                k = val or k;
                -- check value
                val, raw = ctx.callback( v, type( v ), FOR_VALUE, k, ctx.udata );
                v = val or v;
                -- raw value
                if raw then
                    v = tostring( v );
                else
                    t = type( v );
                    if t == 'table' then
                        v = _inspect( v, fieldIndent, nestIndent, ctx );
                    elseif t == 'string' then
                        v = format( '%q', v );
                    elseif t == 'number' or t == 'boolean' then
                        v = tostring( v );
                    else
                        v = format( '%q', tostring( v ) );
                    end
                end
                
                -- check key
                t = type( k );
                narr = narr + 1;
                if t == 'number' or t == 'boolean' then
                    v = format( arrFmt, tostring( k ), v );
                elseif t == 'string' and not RESERVED_WORD[k] and
                       match( k, LUA_FIELDNAME_PAT ) then
                    v = format( strFmt, k, v );
                else
                    k = tostring( k );
                    v = format( ptrFmt, k, v );
                    t = 'string';
                end
                arr[narr] = { typ = t, key = k, val = v };
            end
        end
        
        -- remove reference
        rawset( ctx.circular, ref, nil );
        -- concat result
        if narr > 0 then
            sort( arr, sortIndex );
            
            for i = 1, narr do
                res[i] = arr[i].val;
            end
            res[1] = '{' .. ctx.LF .. res[1];
            res = concat( res, ',' .. ctx.LF ) .. ctx.LF .. indent .. '}';
        else
            res = '{}';
        end
        
        return res;
    end
    
    val = ctx.callback( obj, type( obj ), FOR_CIRCULAR, obj, ctx.udata );
    return type( val ) == 'table' and '"<Circular ' .. ref .. '>"' or val;
end


-- opt
--  depth   : indent depth
--  padding : first indent
--  callback: callback function for each key and value
--  udata   : userdata for callback function
local function inspect( obj, opt )
    local t = type( obj );
    
    if t == 'table' then
        local indent = format( '%' .. ( opt and opt.depth or INDENT_LV ) .. 's', '' );
        local padding = format( '%' .. ( opt and opt.padding or 0 ) .. 's', '' );
        
        return _inspect( obj, padding, indent, {
            LF = indent == '' and ' ' or '\n',
            circular = {},
            callback = opt and opt.callback or defaultCallback,
            udata = opt and opt.udata or nil
        });
    end
    
    if opt and opt.callback then
        obj = opt.callback( obj, t, FOR_VALUE, nil, opt.udata );
    end
    
    return tostring( obj );
end


local function eval( src, env, ident )
    local fn, err;
    
    if LUA_VERSION > 5.1 then
        fn, err = load( src, nil, nil, env );
    else
        fn, err = loadstring( src, ident );
        if not err and env ~= nil then
            setfenv( fn, env );
        end
    end
    
    return fn, err;
end


local function evalfile( file, env, mode )
    local fn, err;
    
    if LUA_VERSION > 5.1 then
        fn, err = loadfile( file, mode, env );
    else
        fn, err = loadfile( file );
        if not err and env ~= nil then
            setfenv( fn, env );
        end
    end
    
    return fn, err;
end


local function getfnupvalues( fn )
    local upv = {};
    local i = 1;
    local k, v = getupvalue( fn, i );
    
    while k do
        upv[i] = { key = k, val = v };
        i = i + 1;
        k, v = getupvalue( fn, i );
    end
    
    return upv;
end


local function setfnupvalues( fn, upv, repl )
    local repl;
    
    for i, kv in ipairs( upv ) do
        setupvalue( fn, i, repl and repl[kv.key] or kv.val );
    end
end


local function getfnenv( fn )
    if LUA_VERSION > 5.1 then
        local i = 1;
        local k, v = getupvalue( fn, i );
        
        while k do
            if k == '_ENV' then
                return v;
            end
            i = i + 1;
            k, v = getupvalue( fn, i );
        end
    else
        return getfenv( fn );
    end
end


return {
    inspect = inspect,
    eval = eval,
    evalfile = evalfile,
    getfupvalues = getfnupvalues,
    setfupvalues = setfnupvalues,
    getfenv = getfnenv,
    ['typeof'] = require('util.typeof'),
    ['is'] = require('util.is'),
    ['string'] = require('util.string'),
    ['table'] = require('util.table')
};
