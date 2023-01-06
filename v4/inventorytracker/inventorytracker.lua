--[[
* Ashita - Copyright (c) 2014 - 2016 atom0s [atom0s@live.com]
*
* This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
* To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/ or send a letter to
* Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.
*
* By using Ashita, you agree to the above license and its terms.
*
*      Attribution - You must give appropriate credit, provide a link to the license and indicate if changes were
*                    made. You must do so in any reasonable manner, but not in any way that suggests the licensor
*                    endorses you or your use.
*
*   Non-Commercial - You may not use the material (Ashita) for commercial purposes.
*
*   No-Derivatives - If you remix, transform, or build upon the material (Ashita), you may not distribute the
*                    modified material. You are, however, allowed to submit the modified works back to the original
*                    Ashita project in attempt to have it added to the original project.
*
* You may not apply legal terms or technological measures that legally restrict others
* from doing anything the license permits.
*
* No warranties are given.
]] --
addon.name = 'InventoryTracker'
addon.author = 'ayechonk'
addon.version = '1.1'

require 'common'

local default_config = {
    font = {
        family = 'Consolas',
        size = 10,
        color = math.d3dcolor(255, 255, 255, 255),
        position = {350, 350}
    },
    background = {
        color = math.d3dcolor(128, 0, 0, 0),
        visible = true
    }
};
local tp_config = default_config;

ashita.events.register("load", "load_callback1", function()
    -- Load the configuration file..
    -- tp_config = ashita.settings.load_merged(_addon.path .. '/settings.json', default_config);

    -- Create the font object..
    local f = AshitaCore:GetFontManager():Create('__invtracker_addon');
    f:SetColor(tp_config.font.color);
    f:SetFontFamily(tp_config.font.family);
    f:SetFontHeight(tp_config.font.size);
    f:SetPositionX(tp_config.font.position[1]);
    f:SetPositionY(tp_config.font.position[2]);
    f:SetText('');
    f:SetVisible(true);
    f:GetBackground():SetVisible(tp_config.background.visible);
    f:GetBackground():SetColor(tp_config.background.color);
end)

function getInventory()
    return AshitaCore:GetMemoryManager():GetInventory()
end

ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args()
    if (args[1] ~= '/inv') then
        return false
    else
        local inv = getInventory()
        local max = inv:GetContainerCountMax(0)
        local cnt = 0;
        for i = 0, max, 1 do
            local inv_entry = AshitaCore:GetDataManager():GetInventory():GetItem(0, i);
            if (inv_entry.Id ~= 0 and inv_entry.Id ~= 65535) then
                cnt = cnt + 1
                print(inv_entry.Id)
            end
        end
        print(cnt)
    end
    return true
end)

ashita.events.register('unload', 'unload_cb', function()
    AshitaCore:GetFontManager():Delete('__invtracker_addon');
end)

ashita.events.register('d3d_present', 'present_cb', function()
    local txt = 'Inventory: '
    local f = AshitaCore:GetFontManager():Get('__invtracker_addon');
    local inv = getInventory()
    local max = inv:GetContainerCountMax(0)
    local cnt = 0;
    if (max > 0) then
        for i = 0, max, 1 do
            local inv_entry = AshitaCore:GetMemoryManager():GetInventory():GetContainerItem(0, i);
            if (inv_entry ~= nil and inv_entry.Id ~= 0 and inv_entry.Id ~= 65535) then
                cnt = cnt + 1
            end
        end
        txt = txt .. tostring(cnt) .. '/' .. tostring(max)
        f:SetText(txt)
    end
end);
