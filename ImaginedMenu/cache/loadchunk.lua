--
-- Copyright (C) 2018 Masatoshi Teruya
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.
--
-- loadchunk.lua
-- lua-loadchunk
-- Created by Masatoshi Teruya on 18/04/22.
--
--- file-scope variables
local find = string.find
local load = load
local loadstring = loadstring
local loadfile = loadfile
local setfenv = setfenv
local type = type
--- constants
local LUA_VERSION = tonumber(string.match(_VERSION, 'Lua (.+)$'))

--- evalstr
-- @param src
-- @param env
-- @param ident
-- @return fn
-- @return err
local function evalstr(src, env, ident)
    if LUA_VERSION <= 5.1 then
        local fn, err = loadstring(src, ident)

        if not err and env ~= nil then
            setfenv(fn, env)
        end

        return fn, err
    elseif env ~= nil then
        return load(src, ident, nil, env)
    end

    return load(src, ident)
end

--- evalfile
-- @param file
-- @param env
-- @return fn
-- @return err
local function evalfile(file, env)
    if type(file) ~= 'string' or file == '' or find(file, '^%s+$') then
        return nil, 'file must be non-empty string'
    end

    if LUA_VERSION <= 5.1 then
        local fn, err = loadfile(file)

        if not err and env ~= nil then
            setfenv(fn, env)
        end

        return fn, err
    elseif env ~= nil then
        return loadfile(file, nil, env)
    end

    return loadfile(file)
end

return {
    string = evalstr,
    file = evalfile,
}