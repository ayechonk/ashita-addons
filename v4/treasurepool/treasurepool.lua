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
]] -- Thanks to Thorny and ShiyoKozuki for the help on converting to Ashita V4
-- Thanks to Metra of HorizonXI for the help on converting to imgui
addon.name = 'TreasurePool'
addon.author = 'chonk'
addon.version = '1.2'

require('common')
require('resources.player')
UI = require('imgui')
Colors = require('resources.colors')

local settings = require('settings')
local default_settings = require('resources.default_settings')

local update_settings = function(s)
    settings.save()
end

settings.register('settings', 'settings_update', update_settings);

local tp = T {
    loaded = false,
    settings = settings.load(default_settings)
}

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

local tsTable = {}

local getLineItemColor = function(timeRemaining)
    if timeRemaining < 30 then
        return Colors.Basic.RED
    elseif timeRemaining < 120 then
        return Colors.Basic.YELLOW
    else
        return Colors.Basic.GREEN
    end
end

local getLineItemText = function(poolPosition, poolItem, timeRemaining)
    local lineItem = ""

    lineItem = lineItem .. ' ' .. poolPosition .. ': ' .. poolItem.Name
    if poolItem.item.WinningLot > 0 then
        lineItem = lineItem .. ' | ' .. poolItem.item.WinningEntityName .. ":" .. poolItem.item.WinningLot .. " "
    end
    lineItem = lineItem .. ' | ' .. timeRemaining
    return lineItem
end

local getTimeRemaining = function(item)
    if item ~= nil and item.item.DropTime ~= nil then
        local x = nil
        for k, v in pairs(tsTable) do
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

local drawFontManager = function(pool)
    local t = T {}
    table.insert(t, ' Treasure Pool: ')
    local f = AshitaCore:GetFontManager():Get('__treasurepool_addon');

    local count = getLen(pool)
    if count == 0 then
        tsTable = {}
    else
        for k, v in pairs(pool) do
            local lineItem = ""
            local timeRemaining = math.floor(getTimeRemaining(v))
            local key = k
            if k < 10 and count > 9 then
                key = ' ' .. k
            end
            lineItem = lineItem .. ' ' .. key .. ': ' .. v.Name
            if v.item.WinningLot > 0 then
                lineItem = lineItem .. ' | ' .. v.item.WinningEntityName .. ":" .. v.item.WinningLot .. " "
            end
            lineItem = lineItem .. ' | ' .. timeRemaining
            if k ~= count then
                lineItem = lineItem .. ' '
            end
            local color
            if timeRemaining < 30 then
                color = '|cFFFF0000|%s|r'
            elseif timeRemaining < 120 then
                color = '|cFFFFFF00|%s|r'
            else
                color = '|cFF00FF00|%s|r'
            end
            table.insert(t, string.format(color, lineItem));
        end
    end
    f:SetText(t:concat('\n'));
end

local drawImguiTable = function(pool)
    if UI.BeginTable("TreasurePool_Table", 3, bit.bor(ImGuiTableFlags_None), 10) then
        -- HEADERS
        UI.TableSetupColumn("Item", bit.bor(ImGuiTableColumnFlags_None))
        UI.TableSetupColumn("Time", bit.bor(ImGuiTableColumnFlags_None))
        UI.TableSetupColumn("Lot", bit.bor(ImGuiTableColumnFlags_None))
        UI.TableHeadersRow()

        -- ROWS
        for k, v in pairs(pool) do
            local timeRemaining = math.floor(getTimeRemaining(v))
            local color = getLineItemColor(timeRemaining)
            local lineItem = getLineItemText(k, v, timeRemaining)

            UI.TableNextColumn()
            UI.TextColored(color, v.Name)
            UI.TableNextColumn()
            UI.TextColored(color, tostring(timeRemaining))
            UI.TableNextColumn()
            if v.item.WinningLot > 0 then
                UI.TextColored(color, v.item.WinningEntityName .. ":" .. v.item.WinningLot)
            else
                UI.Text("")
            end
        end
        UI.EndTable()
    end
end

local imguiBegin = function(pool)
    local count = getLen(pool)
    if count > 0 then
        UI.PushStyleVar(ImGuiStyleVar_CellPadding, {10, 3})
        UI.PushStyleVar(ImGuiStyleVar_Alpha, 0.85)

        local flags_default = bit.bor(ImGuiWindowFlags_AlwaysAutoResize, ImGuiWindowFlags_NoSavedSettings,
            ImGuiWindowFlags_NoNav)
        UI.SetNextWindowPos({tp.settings.x, tp.settings.y}, ImGuiCond_FirstUseEver);
        if UI.Begin("TreasurePool", true, flags_default) then
            drawImguiTable(pool)
            local newX, newY = UI.GetWindowPos();
            tp.settings.x = newX
            tp.settings.y = newY
            UI.End()
        end
    end
end

ashita.events.register("load", "load_callback1", function()
    -- Create the font object..
    local f = AshitaCore:GetFontManager():Create('__treasurepool_addon');
    f:SetColor(tp_config.font.color);
    f:SetFontFamily(tp_config.font.family);
    f:SetFontHeight(tp_config.font.size);
    f:SetPositionX(tp_config.font.position[1]);
    f:SetPositionY(tp_config.font.position[2]);
    f:SetText('');
    f:SetVisible(true);
    f:GetBackground():SetVisible(tp_config.background.visible);
    f:GetBackground():SetColor(tp_config.background.color);
end);

ashita.events.register("d3d_present", "present_cb", function()
    if not Ashita.Player.Is_Logged_In() then
        tp.loaded = false
    else
        if not tp.loaded then
            tp.settings = settings.load()
            tp.loaded = true
        else
            local pool = getTreasurePool()
            imguiBegin(pool)
            -- drawFontManager(pool)    
        end
    end
end);

ashita.events.register('unload', 'cb', function()
    AshitaCore:GetFontManager():Delete('__treasurepool_addon');
    settings.save()
end)

function compare(a, b)
    if a.item.DropTime == b.item.DropTime then
        return a.item.ItemId < b.item.ItemId
    else
        return a.item.DropTime < b.item.DropTime
    end
end

function getLen(table)
    local cnt = 0
    for _ in pairs(table) do
        cnt = cnt + 1
    end
    return cnt
end

function getTimeRemaining(item)
    if item ~= nil and item.item.DropTime ~= nil then
        local x = nil
        for k, v in pairs(tsTable) do
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
    local inventory = AshitaCore:GetMemoryManager():GetInventory()
    for i = 0, 9 do
        local titem = inventory:GetTreasurePoolItem(i);
        if titem ~= nil and titem.ItemId ~= nil then
            local rItem = resources:GetItemById(titem.ItemId)
            if (rItem ~= nil) then
                table.insert(pool, {
                    Name = rItem.Name[1],
                    item = titem
                })
            end
        end
    end
    table.sort(pool, compare)
    return pool
end
