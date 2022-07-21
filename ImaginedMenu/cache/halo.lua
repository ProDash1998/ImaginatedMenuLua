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


  halo.lua
  lua-halo
  Created by Masatoshi Teruya on 14/05/28.

--]]
--- file-scope variables
local require = require;
local type = type;
local rawget = rawget;
local getmetatable = getmetatable;
local setmetatable = setmetatable;


local function instanceof( instance, class )
    local mt = getmetatable( instance );
    return mt ~= nil and type( class ) == 'table' and
           rawget( mt.__index, 'constructor' ) == class.new;
end

return {
    class = setmetatable({},{
        __index = require('halo.class')
    }),
    instanceof = instanceof,
    printRegistry = require('halo.registry').printRegistry
};
