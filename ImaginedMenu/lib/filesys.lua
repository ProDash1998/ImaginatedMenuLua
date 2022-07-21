--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--

local execute = os.execute
local rename = os.rename
local popen = io.popen
local open = io.open

local filesystem = {}

function filesystem.make_dir(dir)
    execute('mkdir "" "'..dir..'\\"')
end

function filesystem.open(path)
    execute('start "" "'..path..'"')
end

function filesystem.scandir(directory)
    local t = {}
    local pfile = io.popen('dir "'..directory..'" /b')
    for filename in pfile:lines() do
        table.insert(t, filename)
    end
    pfile:close()
    return t
end

function filesystem.exists(file)
    local ok, err, code = rename(file, file)
    if not ok and code == 13 then
        -- Permission denied, but it exists
        return true
    end
    return ok, err
end

function filesystem.get_size(file)
    local f = open(file, 'r')
    local current = f:seek()
    local size = f:seek("end")
    f:seek("set", current)
    f:close()
    return size
end

-- Check if a directory exists in this path
function filesystem.isdir(path)
   -- "/" works on both Unix and Windows
   return filesystem.exists(path.."/")
end

function filesystem.read_all(file)
    local f = assert(open(file, "r"))
    local content = f:read("*all")
    f:close()
    return content
end

function filesystem.write(content, path)
    local f = assert(open(path, 'w'))
    f:write(content)
    f:close()
end

return filesystem