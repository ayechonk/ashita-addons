--[[
* Ashita - Copyright (c) 2014 - 2017 atom0s [atom0s@live.com]
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
_addon.author = 'ayechonk';
_addon.name = 'Tag Tracker';
_addon.version = '1.0.0';

require 'common';
local display = true;
local currentTime;

local default_config = {
    font = {
        family = 'Consolas',
        size = 10,
        color = math.d3dcolor(255, 255, 0, 0),
        position = {350, 350}
    },
    background = {
        color = math.d3dcolor(128, 0, 0, 0),
        visible = true
    }
};

local tp_config = default_config;

local printHelp = function()
    print('Tag Tracker')
    print('/tt snooze - (WIP) hides the tracker for an hour')
    print('/tt on - shows the tracker')
    print('/tt off - hides the tracker until turned back on')
end

ashita.register_event('load', function()
    printHelp()
    -- Load the configuration file..
    tp_config = ashita.settings.load_merged(_addon.path .. '/settings.json', default_config);

    -- Create the font object..
    local f = AshitaCore:GetFontManager():Create('__addons_tag_tracker');
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

ashita.register_event('unload', function()
    AshitaCore:GetFontManager():Delete('__addons_tag_tracker');
end)

ashita.register_event('command', function(cmd, type)
    local args = cmd:args()
    if (args[1] == '/tt') then
        if (args[2] == 'snooze') then
            currentTime = os.clock();
            display = false
        elseif (args[2] == 'off') then
            display = false
            currentTime = nil
        elseif (args[2] == 'on') then
            display = true
            currentTime = nil
        elseif (args[2] == 'debug') then
            print(currentTime)
            print(os.clock())
            print(display)
        else
            printHelp()
        end
        return true
    end
    return false
end)

ashita.register_event('render', function()
    local f = AshitaCore:GetFontManager():Get('__addons_tag_tracker')
    if (currentTime ~= nil and os.clock() > currentTime + 3600) then
        display = true
        currentTime = nil
    end
    local txt = ''
    if (display) then
        local player = AshitaCore:GetDataManager():GetPlayer()
        local color = '|cFFFF0000|%s|r'
        if (player:HasKeyItem(787) == false) then
            txt = string.format(color, 'Go Get Your Imperial Army Tag!')
        end
    end
    if (f ~= nil) then
        f:SetText(txt)
    end
end);
