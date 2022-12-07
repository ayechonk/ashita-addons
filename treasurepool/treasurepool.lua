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
]]--


_addon.name = 'AshitaTreasurePool'
_addon.author = 'ayechonk'
_addon.version = '1.3'

require 'common'
 
local default_config =
{
	font =
	{
		family      = 'Consolas',
		size        = 10,
		color       = math.d3dcolor(255, 0, 0, 0),
		position    = { 350, 350 }
	},
	background =
	{
		color       = math.d3dcolor(128, 0, 0, 0),
		visible     = true
	}
};
local tp_config = default_config;


local tsTable = {}

ashita.register_event('load', function()
   -- Load the configuration file..
	tp_config = ashita.settings.load_merged(_addon.path .. '/settings.json', default_config);

	-- Create the font object..
	local f = AshitaCore:GetFontManager():Create('__treasurepool_addon');
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


function compare(a,b)
    if a.item.DropTime == b.item.DropTime then
        return a.item.ItemId < b.item.ItemId
    else
        return a.item.DropTime < b.item.DropTime
    end
end

function getLen(table) 
    local cnt = 0
    for _ in pairs(table) do
        cnt = cnt +1
    end
    return cnt
end

function getTimeRemaining(item)
    if item ~= nil and item.item.DropTime ~= nil then 
        local x = nil
        for k,v in pairs(tsTable) do
            if k == item.item.DropTime then
                x = v
            end
        end
        if x == nil then
            x = os.clock() + 299
            tsTable[item.item.DropTime] = x
        end
        return x - os.clock()
    else 
        return -1
    end
end

function getTreasurePool() 
    local pool = {};
    local resources = AshitaCore:GetResourceManager();
    local inventory = AshitaCore:GetDataManager():GetInventory()
        
    for i = 0, 9 do
        local titem = inventory:GetTreasureItem(i);
        if titem ~= nil and titem.ItemId ~= nil then
            local rItem = resources:GetItemById(titem.ItemId)
            if( rItem ~= nil ) then
                table.insert(pool, { Name = rItem.Name[0], item = titem })
            end
        end
    end
    table.sort(pool, compare)
    return pool
end

ashita.register_event('command', function(cmd, type)
    local args = cmd:args()
    if(args[1] ~= '/tp') then
        return false
    else
        local cmdlet = args[2]
        if cmdlet == 'show' then
            for k,v in pairs( getTreasurePool() ) do
                print(k .. " | " .. v.Name .. " | " .. v.item.DropTime)
            end
        end 
    end
    return true
end)

ashita.register_event('unload', function()
    AshitaCore:GetFontManager():Delete('__treasurepool_addon');
end)

ashita.register_event('render', function()
    local t = T{}
    table.insert(t,' Treasure Pool: ' )
	local f = AshitaCore:GetFontManager():Get('__treasurepool_addon');
    local pool = getTreasurePool()
    local count = getLen(pool)
    if count == 0 then
        tsTable = {}
    else
        for k,v in pairs( pool ) do
            local lineItem = ""
            local timeRemaining = math.floor(getTimeRemaining(v))
            local key = k
            if k < 10 and count > 9 then
                key = ' ' .. k
            end
            lineItem = lineItem .. ' ' .. key .. ': '  .. v.Name
            if v.item.WinningLot > 0 then
                lineItem = lineItem .. ' | '.. v.item.WinningLotterName .. ":" .. v.item.WinningLot .. " "
            end
            lineItem = lineItem .. ' | ' .. timeRemaining             
            if k ~= count then
                lineItem = lineItem .. ' '
            end
            local color
            if timeRemaining < 30 then color = '|cFFFF0000|%s|r'
            elseif timeRemaining < 120 then color = '|cFFFFFF00|%s|r'
            else color = '|cFF00FF00|%s|r' end
            table.insert(t,string.format(color, lineItem));
        end
    end
    f:SetText(t:concat('\n'));
end);