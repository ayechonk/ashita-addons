--[[
Copyright © 2025, Chonk of HorizonXI
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of React nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL --Metra-- BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]] --
-- Big thanks to Thorny and 
addon.author = 'chonk';
addon.name = 'cookbook';
addon.version = '0.1';

require('common')
require('recipes')

UI = require('imgui')

local cb = T {
    loaded = false
}
local curRecipes = T {}
local menus = T {"auclist", "moneyctr", "inv", "bank", "equip", "loot", "delivery", "shop"}

local pGameMenu = ashita.memory.find('FFXiMain.dll', 0, "8B480C85C974??8B510885D274??3B05", 16, 0);
local function GetMenuName()
    local subPointer = ashita.memory.read_uint32(pGameMenu);
    local subValue = ashita.memory.read_uint32(subPointer);
    if (subValue == 0) then
        return nil;
    end
    local menuHeader = ashita.memory.read_uint32(subValue + 4);
    local menuName = ashita.memory.read_string(menuHeader + 0x46, 16);
    return string.gsub(menuName, '\x00', '');
end

local function isMenuOpen(currentMenuName)
    for _, m in ipairs(menus) do
        local match = string.find(currentMenuName, m)
        if (match) then
            return true
        end
    end
    return false
end

local function findRecipesWithResult(itemId)
    local recipes = T {}
    for k, r in pairs(DB.Recipes) do
        if (r.result == itemId or r.resultHq1 == itemId or r.resultHq2 == itemId or r.resultHq3 == itemId) then
            table.insert(recipes, r)
        end
    end
    return recipes;
end

local function drawImguiTable(recipes)
    if UI.BeginTable("Cookbook_Table", 2, bit.bor(ImGuiTableFlags_None), 10) then
        -- HEADERS
        UI.TableSetupColumn("Crystal", bit.bor(ImGuiTableColumnFlags_None))
        UI.TableSetupColumn("Qty", bit.bor(ImGuiTableColumnFlags_None))
        UI.TableHeadersRow()

        -- ROWS
        for _, r in ipairs(recipes) do
            UI.TableNextColumn()
            UI.Text(tostring(r.crystal))
            UI.TableNextColumn()
            UI.Text(tostring(r.resultQty))
        end
        UI.EndTable()
    end
end

local function beginDraw(recipes)
    local count = #recipes
    if count > 0 then
        UI.PushStyleVar(ImGuiStyleVar_CellPadding, {10, 3})
        UI.PushStyleVar(ImGuiStyleVar_Alpha, 0.85)
        local flags_default = bit.bor(ImGuiWindowFlags_AlwaysAutoResize, ImGuiWindowFlags_NoSavedSettings,
            ImGuiWindowFlags_NoNav)
        UI.SetNextWindowPos({400, 400}, ImGuiCond_FirstUseEver);
        if UI.Begin("Cookbook", true, flags_default) then
            drawImguiTable(recipes)
            -- local newX, newY = UI.GetWindowPos();
            -- tp.settings.x = newX
            -- tp.settings.y = newY
            UI.End()
        end
    end
end

ashita.events.register('key', 'key_callback', function(e)
    local menuName = GetMenuName()
    if (menuName ~= nil and isMenuOpen(menuName)) then
        local itemID = AshitaCore:GetMemoryManager():GetInventory():GetSelectedItemId()
        if (itemID ~= nil) then
            curRecipes = findRecipesWithResult(itemID)
        end
    else
        curRecipes = T {}
    end
end)

ashita.events.register("d3d_present", "present_cb", function()
    -- if not Ashita.Player.Is_Logged_In() then
    --     cb.loaded = false
    --     curRecipes = T{}
    -- else
    if not cb.loaded then
        -- tp.settings = settings.load()
        cb.loaded = true
    else
        beginDraw(curRecipes)
    end
    -- end
end);
