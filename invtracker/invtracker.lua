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
_addon.name = 'Inventory Tracker'
_addon.author = 'ayechonk'
_addon.version = '1.1'

require 'common'

local default_config = {
    font = {
        family = 'Consolas',
        size = 10,
        color = math.d3dcolor(255, 0, 0, 0),
        position = {350, 350}
    },
    background = {
        color = math.d3dcolor(128, 0, 0, 0),
        visible = true
    }
};
local tp_config = default_config;

ashita.register_event('load', function()
    -- Load the configuration file..
    tp_config = ashita.settings.load_merged(_addon.path .. '/settings.json', default_config);

    -- Create the font object..
    local f = AshitaCore:GetFontManager():Create('__invtracker_addon');
    f:SetColor(tp_config.font.color);
    f:SetFontFamily(tp_config.font.family);
    f:SetFontHeight(tp_config.font.size);
    f:SetPositionX(tp_config.font.position[1]);
    f:SetPositionY(tp_config.font.position[2]);
    f:SetText('');
    f:SetVisibility(true);
    f:GetBackground():SetVisibility(tp_config.background.visible);
    f:GetBackground():SetColor(tp_config.background.color);
end)

function getInventory()
    return AshitaCore:GetDataManager():GetInventory()
end

ashita.register_event('command', function(cmd, type)
    local args = cmd:args()
    if (args[1] ~= '/inv') then
        return false
    else
        local inv = getInventory()
        local max = inv:GetContainerMax(0)
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

ashita.register_event('unload', function()
    AshitaCore:GetFontManager():Delete('__invtracker_addon');
end)

ashita.register_event('render', function()
    local txt = 'Inventory: '
    local f = AshitaCore:GetFontManager():Get('__invtracker_addon');
    local inv = getInventory()
    local max = inv:GetContainerMax(0)
    local cnt = 0;
    if (max > 0) then
        for i = 0, max, 1 do
            local inv_entry = AshitaCore:GetDataManager():GetInventory():GetItem(0, i);
            if (inv_entry ~= nil and inv_entry.Id ~= 0 and inv_entry.Id ~= 65535) then
                cnt = cnt + 1
            end
        end
        txt = txt .. tostring(cnt) .. '/' .. tostring(max - 1)
        f:SetText(txt)
    end
end);
