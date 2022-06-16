--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--

local file = {}

function file.make_dir(dir)
    os.execute('mkdir "" "'..dir..'\\"')
end

function file.open(path)
    os.execute('start "" "'..path..'"')
end

function file.scandir(directory)
    local i, t = 0, {}
    local pfile = io.popen('dir "'..directory..'" /b')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function file.exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

--- Check if a directory exists in this path
function file.isdir(path)
   -- "/" works on both Unix and Windows
   return file.exists(path.."/")
end

function file.readAll(file)
    local f = assert(io.open(file, "r"))
    local content = f:read("*all")
    f:close()
    return content
end

function file.write(content, path)
    local f = assert(io.open(path, 'w'))
    f:write(content)
    f:close()
end

return file