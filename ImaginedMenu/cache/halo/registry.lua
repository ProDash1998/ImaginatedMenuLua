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


  lib/registry.lua
  lua-halo
  Created by Masatoshi Teruya on 15/07/08.

--]]
--- file-scope variables
local require = require;
local loadchunk = require('loadchunk').string;
local dump = require('dump');
local getFunctionId = require('halo.util').getFunctionId;
local cloneFunction = require('halo.util').cloneFunction;
local mergeLeft = require('halo.util').mergeLeft;
local select = select;
local assert = assert;
local pcall = pcall;
local rawget = rawget;
local rawset = rawset;
local strgsub = string.gsub;
local strformat = string.format;


--- class definitions container
local REGISTRY = {};


-- protected value container
local PROTECTED = setmetatable({},{
    __mode = 'k';
});


local function setProtected( instance, val )
    PROTECTED[instance] = val;
end


local function getProtected( instance )
    return PROTECTED[instance];
end


-- default
local function DEFAULT_INIT(self) return self; end
-- template
local TMPL_PREPATE_METHOD = [==[
--
-- class %q
--
local error = error;
local rawget = rawget;
local rawset = rawset;
local setmetatable = setmetatable;
local setprotected = setprotected;
local getprotected = getprotected;
local PROPERTY_IDX = PROPERTY_IDX;

local function noNewIndex()
    error( 'attempted to assign to readonly property', 2 );
end

local function noIndex()
    error( 'attempted to access to undefined property', 2 );
end

local METHOD_IDX = %s;

do
    local BASE_IDX = {};
    local BASE = setmetatable({}, {
        __newindex = noNewIndex,
        __index = setmetatable( BASE_IDX, {
            __index = noIndex
        })
    });
    local k, fn, env;

    for k,fn in pairs( METHOD_IDX ) do
        fn, env = cloneFunction( fn );
        rawset( env, 'protected', getprotected );
        rawset( env, 'base', BASE );
        METHOD_IDX[k] = fn;
    end

    for k,fn in pairs("$BASE$") do
        rawset( BASE_IDX, k, fn );
    end
end


]==];
local TMPL_INDEX_METAMETHOD = [==[{
            __index = function( _, ... )
                return METHOD_IDX[%q]( self, ... );
            end
        }]==];
local TMPL_METHOD_METATABLE = [==[setmetatable(%s, %s)]==];
local TMPL_CONSTRUCTOR = [==[
"$PREPARE_METHOD$"

local function Constructor(...)
    local self;

    self = setmetatable(%s, %s);

    setprotected( self, %s );

    return self:init( ... );
end

return Constructor;
]==];



-- dump hook
local function dumpFilter( value, _, valueType, valueFor, _, ctx )
    -- should add function-id to FNIDX table
    if valueFor == 'val' and valueType == 'function' then
        local id = getFunctionId( value );

        rawset( ctx.fnindex, id, value );

        return strformat( '%s[%q]', ctx.prefix, id ), true;
    end

    return value;
end


local function makeTemplate( defs, env, className )
    local METHOD_IDX = env.METHOD_IDX;
    local opts = {
        fnindex = METHOD_IDX,
        prefix = 'METHOD_IDX'
    };
    local propertyOpts = {
        fnindex = env.PROPERTY_IDX,
        prefix = 'PROPERTY_IDX'
    };
    local repls = {
        ['$CONSTRUCTOR$']   = 'Constructor',
        ['$BASE$']          = '{}';
    };
    local base = rawget( defs, 'base' );
    local instance = rawget( defs, 'instance' );
    local method = rawget( instance, 'method' );
    local metamethod = rawget( instance, 'metamethod' );
    local property = rawget( instance, 'property' );
    local public = rawget( property, 'public' );
    local protected = rawget( property, 'protected' );
    local mmindex = rawget( metamethod, '__index' );
    local tmpl;

    if base then
        repls['$BASE$'] = dump( base or {}, nil, 4, dumpFilter,  opts );
    end

    -- render template of constructor
    rawset( metamethod, '__index', '$METHOD$' );
    tmpl = strformat( TMPL_CONSTRUCTOR,
        dump( public, nil, 4, dumpFilter, propertyOpts ),
        dump( metamethod, nil, 4, dumpFilter, opts ),
        dump( protected, nil, 4, dumpFilter, propertyOpts )
    );
    rawset( metamethod, '__index', nil );

    -- render template of metatable
    opts.padding = 8;
    rawset( method, 'constructor', '$CONSTRUCTOR$' );
    -- construct __index metamethod
    if mmindex then
        local id = getFunctionId( mmindex );
        -- set mmindex id
        rawset( opts.fnindex, id, mmindex );
        repls['$METHOD$'] = strformat( TMPL_METHOD_METATABLE,
                                       dump( method, nil, 4, dumpFilter, opts ),
                                       strformat( TMPL_INDEX_METAMETHOD, id ) );
    else
        repls['$METHOD$'] = dump( method, nil, 4, dumpFilter, opts );
    end
    rawset( method, 'constructor', nil );
    rawset( metamethod, '__index', mmindex );

    -- render template of private variables
    opts.padding = 0;
    repls['$PREPARE_METHOD$'] = strformat( TMPL_PREPATE_METHOD, className,
                                           dump( METHOD_IDX, nil, 4, dumpFilter,
                                                 opts ) );

    -- replace templates
    tmpl = strgsub( tmpl, '"(%$[^$"]+%$)"', repls );
    return strgsub( tmpl, '"(%$[^$"]+%$)"', repls );
end



local function preprocess( defs )
    local inheritance = rawget( defs, 'inheritance' );
    local instance = rawget( defs, 'instance' );
    local method = rawget( instance, 'method' );

    -- remove inheritance table
    if inheritance then
        rawset( defs, 'inheritance', nil );
        mergeLeft( defs, inheritance );
    end

    -- set default init function
    if not rawget( method, 'init' ) then
        rawset( method, 'init', DEFAULT_INIT );
    end
end


local function postprocess( class, defs )
    local static = rawget( defs, 'static' );

    -- copy static property and methods
    mergeLeft( class, rawget( static, 'property' ) );
    mergeLeft( class, rawget( static, 'method' ) );
end


local function setClass( class, source, pkgName, defs )
    local env = {
        METHOD_IDX = {},
        PROPERTY_IDX = {},
        cloneFunction = cloneFunction,
        getprotected = getProtected,
        setprotected = setProtected,
        error = error,
        setmetatable = setmetatable,
        pairs = pairs,
        rawget = rawget,
        rawset = rawset
    };
    local tmpl, constructor;

    -- create template
    preprocess( defs );
    tmpl = makeTemplate( defs, env, pkgName );
    -- add static properties and methods into class table
    postprocess( class, defs );

    -- create constructor
    constructor = assert(
        loadchunk( tmpl, env, strformat( '=load(halo:%s%s)', pkgName, source ) )
    );
    constructor = select( -1, assert( pcall( constructor ) ) );

    -- set constructor
    defs.static.method.new = constructor;
    class.new = constructor;
    -- check metamethod
    if next( defs.static.metamethod ) then
        setmetatable( class, defs.static.metamethod );
    end

    -- cleanup env
    for k in pairs( env ) do
        rawset( env, k, nil );
    end

    -- add to registry table
    REGISTRY[pkgName] = defs;

    return class;
end


local function getClass( className )
    return REGISTRY[className];
end


local function printRegistry()
    print( dump( REGISTRY ) );
end


return {
    setClass = setClass,
    getClass = getClass,
    printRegistry = printRegistry
};
