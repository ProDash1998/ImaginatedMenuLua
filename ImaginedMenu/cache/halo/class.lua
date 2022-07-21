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


  lib/class.lua
  lua-halo
  Created by Masatoshi Teruya on 15/07/08.

--]]
--- file-scope variables
local require = require;
local cloneTable = require('halo.util').cloneTable;
local getPackageName = require('halo.util').getPackageName;
local hasImplicitSelfArg = require('halo.util').hasImplicitSelfArg;
local mergeRight = require('halo.util').mergeRight;
local setClass = require('halo.registry').setClass;
local getClass = require('halo.registry').getClass;
local type = type;
local error = error;
local assert = assert;
local pairs = pairs;
local ipairs = ipairs;
local rawget = rawget;
local rawset = rawset;
local getinfo = debug.getinfo;
local getupvalue = debug.getupvalue;
local setupvalue = debug.setupvalue;
local strformat = string.format;
local strfind = string.find;
--- constants
local INF_POS = math.huge;
local INF_NEG = -INF_POS;
--- pattern
local PTN_METAMETHOD = '^__.+';


--- isFinite
-- @param arg
-- @return ok
local function isFinite( arg )
    return type( arg ) == 'number' and ( arg < INF_POS and arg > INF_NEG );
end


local function checkNameConfliction( name, ... )
    for _, tbl in pairs({...}) do
        for key in pairs( tbl ) do
            assert(
                rawequal( key, name ) == false,
                strformat( 'field %q already defined', name )
            );
        end
    end
end


local function removeInheritance( inheritance, list )
    local except = rawget( list, 'except' );

    if except then
        local tbl;

        assert(
            type( except ) == 'table',
            'except must be type of table'
        );

        for _, scope in ipairs({ 'static', 'instance' }) do
            for _, methodName in ipairs( rawget( except, scope ) or {} ) do
                assert(
                    type( methodName ) == 'string' or isFinite( methodName ),
                    'method name must be type of string or finite number'
                );
                tbl = rawget( inheritance, scope );
                if strfind( methodName, PTN_METAMETHOD ) then
                    tbl = rawget( tbl, 'metamethod' );
                elseif scope == 'instance' then
                    tbl = rawget( tbl, 'method' );
                end

                if type( rawget( tbl, methodName ) ) == 'function' then
                    rawset( tbl, methodName, nil );
                end
            end
        end
    end
end


local function defineInheritance( defs, tbl )
    local base = {};
    local inheritance = {
        base = base
    };
    local pkg, class;

    rawset( defs, 'inheritance', inheritance );
    for _, className in ipairs( tbl ) do
        assert(
            type( className ) == 'string',
            'class name must be type of string'
        );

        -- check registry table
        class = getClass( className );
        if not class then
            -- load package by require function
            pkg = className:match( '^(.+)%.[^.]+$' );

            if pkg and type( pkg ) == 'string' then
                require( pkg );
            end

            -- recheck registry table
            class = getClass( className );
            assert( class, ('class %q is not defined'):format( className ) );
        end

        mergeRight( inheritance, class );
        rawset(
            base, className,
            mergeRight( nil, rawget( class.instance, 'method' ) )
        );
    end

    removeInheritance( inheritance, tbl );

    return true;
end


local function defineMetamethod( target, name, fn )
    local metamethod = target.metamethod;

    if metamethod[name] ~= nil then
        error( strformat( 'metamethod %q is already defined', name ) );
    end

    metamethod[name] = fn;
end


local function defineStaticMethod( static, name, fn, isMetamethod )
    if isMetamethod then
        defineMetamethod( static, name, fn );
    elseif name == 'new' then
        error( '"new" is reserved word');
    else
        local method = static.method;

        checkNameConfliction( name, method, static.property );
        rawset( method, name, fn );
    end
end


local function defineInstanceMethod( instance, name, fn, isMetamethod )
    if isMetamethod then
        defineMetamethod( instance, name, fn );
    elseif name == 'constructor' then
        error( '"constructor" is reserved word' );
    else
        local method = instance.method;

        checkNameConfliction( name, method, instance.property.public );
        rawset( method, name, fn );
    end
end


local function defineInstanceProperty( instance, tbl )
    local property = instance.property;
    local method = instance.method;
    local public = property.public;
    local protected = property.protected;

    -- public, protected
    for scope, tbl in pairs( tbl ) do
        local target = property[scope];

        if not target then
            error( strformat( 'unknown property type: %q', scope ) );
        end

        for key, val in pairs( tbl ) do
            if type( key ) ~= 'string' then
                if not isFinite( key ) then
                    error( 'field name must be string or finite number' );
                end
            elseif key == 'constructor' then
                error( '"constructor" is reserved word' );
            elseif key == 'init' then
                error( '"init" is reserved word' );
            end

            checkNameConfliction( key, public, protected, method );
            -- set field
            if type( val ) == 'table' then
                target[key] = cloneTable( val );
            else
                target[key] = val;
            end
        end
    end

    return true;
end


local function defineStaticProperty( static, tbl )
    local property = static.property;
    local method = static.method;

    for key, val in pairs( tbl ) do
        if type( key ) ~= 'string' then
            if not isFinite( key ) then
                error( 'field name must be string or finite number' );
            end
        elseif key == 'new' then
            error( 'field name "new" is reserved word' )
        end

        checkNameConfliction( key, property, method );
        -- set field
        if type( val ) == 'table' then
            property[key] = cloneTable( val );
        else
            property[key] = val;
        end
    end

    return true;
end


local function verifyMethod( name, fn )
    local info;

    assert(
        type( name ) == 'string' or isFinite( name ),
        'method name must be type of string or finite number'
    );
    assert(
        type( fn ) == 'function',
        ('method must be type of function'):format( name )
    );

    info = getinfo( fn );
    assert(
        info.what == 'Lua',
        ('method %q must be lua function'):format( name )
    );

    return hasImplicitSelfArg( fn, info );
end


local function replaceDeclUpvalue2Class( defs, decl, class )
    local idx, k, v;
    local replaceUpvalue = function( tbl )
        for _, node in ipairs({
            'metamethod',
            'method'
        }) do
            for _, fn in pairs( tbl[node] ) do
                idx = 1;
                k, v = getupvalue( fn, idx );
                while k do
                    -- lookup table upvalue
                    if type( v ) == 'table' then
                        if v == decl then
                            setupvalue( fn, idx, class );
                        elseif k == '_ENV' then
                            for ek, ev in pairs( v ) do
                                if type( ev ) == 'table' and ev == decl then
                                    v[ek] = class;
                                end
                            end
                        end
                    end

                    -- check next upvalue
                    idx = idx + 1;
                    k, v = getupvalue( fn, idx );
                end
            end
        end
    end

    replaceUpvalue( defs.instance );
    replaceUpvalue( defs.static );
end


-- declaration method table
local function createDeclarator( defs )
    local defined = {
        inheritance = false,
        static      = false,
        instance    = false
    };

    return {
        -- define inheritance
        inherits = function( tbl )
            -- cannot be defined twice
            if defined.inheritance then
                error( 'inheritance already defined' );
            -- invalid argument
            elseif type( tbl ) ~= 'table' then
                error( 'inheritance must be type of table' );
            end

            defined.inheritance = defineInheritance( defs, tbl );
        end,

        -- define property
        property = function( self, tbl )
            local scope, proc;

            -- define instance property with 'Class:property'
            if tbl then
                scope = 'instance';
                proc = defineInstanceProperty;
            -- define static property with 'Class.property'
            else
                scope = 'static';
                proc = defineStaticProperty;
                tbl = self;
            end

            if defined[scope] then
                error( strformat( '%q property already defined', scope ) );
            elseif type( tbl ) ~= 'table' then
                error( 'property must be type of table' );
            end
            defined[scope] = proc( defs[scope], tbl );
        end
    };
end


local function declClass( _, className )
    local source = getinfo( 2, 'S' ).source;
    local pkgName = getPackageName();
    local defs = {
        static = {
            property = {},
            method = {},
            metamethod = {}
        },
        instance = {
            property = {
                public = {},
                protected = {}
            },
            method = {},
            metamethod = {}
        }
    };
    local exports;

    -- check className
    if type( className ) ~= 'string' then
        error( 'class name must be string' );
    end

    -- prepend package-name
    if pkgName then
        pkgName = pkgName .. '.' .. className;
    else
        pkgName = className;
    end

    -- package.class already registered
    if getClass( pkgName ) then
        error( strformat( 'class %q already defined', className ) );
    end

    -- declaration method table
    local DECLARATOR = createDeclarator( defs );
    -- return class declarator
    local decl = {};
    local class = {};

    setmetatable( decl, {
        -- protect metatable
        __metatable = 1,
        -- declare static methods by table
        __call = function( _, tbl )
            if type( tbl ) ~= 'table' then
                error( 'method list must be table' );
            end

            for name, fn in pairs( tbl ) do
                assert(
                    not verifyMethod( name, fn ),
                    strformat( '%q is not type of static method', name )
                );
                -- define static method
                defineStaticMethod( defs.static, name, fn,
                                    strfind( name, PTN_METAMETHOD ) );
            end
        end,

        -- property/inheritance declaration or class exports
        __index = function( _, name )
            if type( name ) == 'string' then
                if name == 'exports' then
                    if exports ~= nil then
                        error(
                            strformat( 'class %q already exported', className )
                        );
                    end

                    replaceDeclUpvalue2Class( defs, decl, class );
                    exports = setClass( class, source, pkgName, defs );

                    return exports;
                end

                return DECLARATOR[name];
            end

            error( strformat( '%q is unknown declaration', name ) );
        end,

        -- method declaration
        __newindex = function( _, name, fn )
            local hasSelf = verifyMethod( name, fn );
            local scope, proc;

            if hasSelf then
                scope = 'instance';
                proc = defineInstanceMethod;
            else
                scope = 'static';
                proc = defineStaticMethod;
            end

            proc( defs[scope], name, fn, strfind( name, PTN_METAMETHOD ) );
        end
    });

    return decl;
end


return declClass;
