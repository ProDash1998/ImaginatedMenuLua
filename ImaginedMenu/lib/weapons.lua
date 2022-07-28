--
-- made by FoxxDash/aka Ðr ÐºήgΣr & SATTY
--
-- Copyright © 2022 Imagined Menu
--

local insert = table.insert
local ipairs = ipairs

local json = require "JSON"
local filesystem = require "filesys"

local weapons = {}

weapons.data = json:decode(filesystem.read_all(files['WeaponData']))
weapons.names = {}
weapons.hashes = {}

for _, v in ipairs(weapons.data) do
    if v.Category and v.TranslatedLabel.English ~= "Invalid" then
        local name = HUD._GET_LABEL_TEXT(v.TranslatedLabel.Name)
        if v.Name == "WEAPON_DIGISCANNER" then
            name = "Digiscanner"
        end
        insert(weapons.names, name)
        insert(weapons.hashes, v.Hash)
    end
end

return weapons