--[[

  Copyright (C) 2015 Masatoshi Teruya
 
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

  lib/is.lua
  lua-util
  Created by Masatoshi Teruya on 15/09/14.

--]]
-- constants
local INFINITE_POS = math.huge;
local INFINITE_NEG = -INFINITE_POS;
local type = type;
local floor = math.floor;

-- type
local function isNil( arg )
    return type( arg ) == 'nil';
end

local function isBoolean( arg )
    return type( arg ) == 'boolean';
end

local function isString( arg )
    return type( arg ) == 'string';
end

local function isNumber( arg )
    return type( arg ) == 'number';
end

local function isFunction( arg )
    return type( arg ) == 'function';
end

local function isTable( arg )
    return type( arg ) == 'table';
end

local function isThread( arg )
    return type( arg ) == 'thread';
end

local function isUserdata( arg )
    return type( arg ) == 'userdata';
end


-- boolean
local function isTrue( arg )
    return arg == true;
end

local function isFalse( arg )
    return arg == false;
end


-- None
local function isNone( arg )
    return arg == nil or arg == false or arg == 0 or arg == '' or arg ~= arg;
end


-- arithmetic
local function isNaN( arg )
    return arg ~= arg;
end


-- integer
local function isFinite( arg )
    return type( arg ) == 'number' and ( arg < INFINITE_POS and arg > INFINITE_NEG );
end

local function isInt( arg )
    return isFinite( arg ) and rawequal( floor( arg ), arg );
end

local function isInt8( arg )
    return isInt( arg ) and arg >= -128 and arg <= 127;
end

local function isInt16( arg )
    return isInt( arg ) and arg >= -32768 and arg <= 32767;
end

local function isInt32( arg )
    return isInt( arg ) and arg >= -2147483648 and arg <= 2147483647;
end


-- unsigned integer
local function isUnsigned( arg )
    return type( arg ) == 'number' and ( arg < INFINITE_POS and arg >= 0 );
end

local function isUInt( arg )
    return isUnsigned( arg ) and rawequal( floor( arg ), arg );
end

local function isUInt8( arg )
    return isUInt( arg ) and arg <= 255;
end

local function isUInt16( arg )
    return isUInt( arg ) and arg <= 65535;
end

local function isUInt32( arg )
    return isUInt( arg ) and arg <= 4294967295;
end


local EXPORTS = {};

for k, v in pairs({
    -- type
    ['Nil'] = isNil,
    ['Boolean'] = isBoolean,
    ['String'] = isString,
    ['Number'] = isNumber,
    ['Function'] = isFunction,
    ['Table'] = isTable,
    ['Thread'] = isThread,
    ['Userdata'] = isUserdata,

    -- boolean
    ['True'] = isTrue,
    ['False'] = isFalse,

    -- None: nil | false | 0 | '' | nan
    ['None'] = isNone,

    -- arithmetic
    -- NaN
    ['NaN'] = isNaN,

    -- integer
    ['Finite'] = isFinite,
    ['Int'] = isInt,
    ['Int8'] = isInt8,
    ['Int16'] = isInt16,
    ['Int32'] = isInt32,

    -- unsigned integer
    ['Unsigned'] = isUnsigned,
    ['UInt'] = isUInt,
    ['UInt8'] = isUInt8,
    ['UInt16'] = isUInt16,
    ['UInt32'] = isUInt32
}) do
    EXPORTS[k], EXPORTS[k:lower()] = v, v;
end


return EXPORTS;
