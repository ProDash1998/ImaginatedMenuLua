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
-- constants
local INFINITE_POS = math.huge;
local INFINITE_NEG = -INFINITE_POS;
local type = type;
local floor = math.floor;

local function typeof( cmp, arg )
    return cmp == type( arg );
end

local function typeofNil( ... )
    return typeof( 'nil', ... );
end

local function typeofBoolean( ... )
    return typeof( 'boolean', ... );
end

local function typeofString( ... )
    return typeof( 'string', ... );
end

local function typeofNumber( ... )
    return typeof( 'number', ... );
end

local function typeofFunction( ... )
    return typeof( 'function', ... );
end

local function typeofTable( ... )
    return typeof( 'table', ... );
end

local function typeofThread( ... )
    return typeof( 'thread', ... );
end

local function typeofUserdata( ... )
    return typeof( 'userdata', ... );
end

local function typeofFinite( arg )
    return type( arg ) == 'number' and ( arg < INFINITE_POS and arg > INFINITE_NEG );
end

local function typeofUnsigned( arg )
    return type( arg ) == 'number' and ( arg < INFINITE_POS and arg >= 0 );
end

local function typeofInt( arg )
    return typeofFinite( arg ) and rawequal( floor( arg ), arg );
end

local function typeofInt8( arg )
    return typeofInt( arg ) and arg >= -128 and arg <= 127;
end

local function typeofInt16( arg )
    return typeofInt( arg ) and arg >= -32768 and arg <= 32767;
end

local function typeofInt32( arg )
    return typeofInt( arg ) and arg >= -2147483648 and arg <= 2147483647;
end

local function typeofUInt( arg )
    return typeofUnsigned( arg ) and rawequal( floor( arg ), arg );
end

local function typeofUInt8( arg )
    return typeofUInt( arg ) and arg <= 255;
end

local function typeofUInt16( arg )
    return typeofUInt( arg ) and arg <= 65535;
end

local function typeofUInt32( arg )
    return typeofUInt( arg ) and arg <= 4294967295;
end

local function typeofNaN( arg )
    return arg ~= arg;
end

local function typeofNon( arg )
    return arg == nil or arg == false or arg == 0 or arg == '' or arg ~= arg;
end


local EXPORT = {
    ['nil'] = typeofNil,
    ['boolean'] = typeofBoolean,
    ['string'] = typeofString,
    ['number'] = typeofNumber,
    ['function'] = typeofFunction,
    ['table'] = typeofTable,
    ['thread'] = typeofThread,
    ['userdata'] = typeofUserdata,
    ['finite'] = typeofFinite,
    ['unsigned'] = typeofUnsigned,
    ['int'] = typeofInt,
    ['int8'] = typeofInt8,
    ['int16'] = typeofInt16,
    ['int32'] = typeofInt32,
    ['uint'] = typeofUInt,
    ['uint8'] = typeofUInt8,
    ['uint16'] = typeofUInt16,
    ['uint32'] = typeofUInt32,
    ['nan'] = typeofNaN,
    ['non'] = typeofNon,
    -- alias
    ['Nil'] = typeofNil,
    ['Function'] = typeofFunction
};

do
    local types = {};
    
    for key in pairs( EXPORT ) do
        types['T_' .. key:upper()] = key;
    end
    
    for key, val in pairs( types ) do
        EXPORT[key] =  val;
    end
end

return EXPORT;

