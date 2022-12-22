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
_addon.author = 'atom0s, ayechonk';
_addon.name = 'petinfo';
_addon.version = '3.2.0';

require 'common'

hasPet = false;
curTime = nil;
curTarg = nil;
checkT = {}
baseDurT = {
    [64] = 1800, -- TW
    [66] = 1200, -- EP
    [67] = 600,  -- DC
    [68] = 180,  -- EM
    [69] = 90,   -- T
    [70] = 20    -- VT
}
charmPlus = {
    [12517] = 4,
    [12646] = 5,
    [13969] = 3,
    [14097] = 2,
    [14222] = 6,
    [14481] = 6,
    [14508] = 7,
    [14898] = 3,
    [14917] = 4,
    [15080] = 5,
    [15095] = 6,
    [15110] = 4,
    [15125] = 2,
    [15140] = 3,
    [15233] = 4,
    [15253] = 5,
    [15360] = 2,
    [15569] = 6,
    [15588] = 2,
    [15673] = 3,
    [17936] = 1,
    [23383] = 35
}

----------------------------------------------------------------------------------------------------
-- func: get_display_string
-- desc: provided a integer value will add a leading '0' if it is less than 10.
-- params: unitsInt (integer) - the value what will be padding with a leading '0'.
----------------------------------------------------------------------------------------------------
local function get_display_string(unitsInt)
    if (unitsInt >= 10) then
        return unitsInt
    else
        return "0" .. unitsInt
    end
end

function getEquippedItemId(slot)
    local inventory = AshitaCore:GetDataManager():GetInventory();
    local equipment = inventory:GetEquippedItem(slot);
    local index = equipment.ItemIndex;

    if (index == 0) then
        return 0;
    end

    -- item is in inventory
    if (index < 2048) then
        return inventory:GetItem(0, index).Id;
    elseif (index < 2560) then -- wardrobe 1
        return inventory:GetItem(8, index - 2048).Id;
    elseif (index < 2816) then -- wardrobe 2
        return inventory:GetItem(10, index - 2560).Id;
    elseif (index < 3072) then -- wardrobe 3
        return inventory:GetItem(11, index - 2816).Id;
    elseif (index < 3328) then -- wardrobe 4
        return inventory:GetItem(12, index - 3072).Id;
    else -- shouldn't ever happen, but yeah.
        return 0;
    end
end

local function formatTime(totalSecs)
    local hours = math.floor(totalSecs / 3600);
    local secsMinusHours = math.floor(totalSecs % 3600);
    local mins = math.floor(secsMinusHours / 60);
    local seconds = math.floor(secsMinusHours % 60);
    local displayHours = get_display_string(hours);
    local displayMins = get_display_string(mins);
    local displaySeconds = get_display_string(seconds);
    local formattedTime = displayMins .. ':' .. displaySeconds
    if hours > 0 then
        formattedTime = displayHours .. ":" .. formattedTime
    end
    return formattedTime
end

local function calculateCharmDuration(baseDuration)
    local charmPlusAmt = 0
    for i = 0, 15 do
        local itemId = getEquippedItemId(i)
        if (itemId ~= nil and itemId ~= 0) then
            local value = charmPlus[itemId]
            if (value ~= nil) then
                charmPlusAmt = charmPlusAmt + value
            end
        end
    end
    local pctAdd = (.05 * charmPlusAmt) + 1
    return baseDuration * pctAdd
end

----------------------------------------------------------------------------------------------------
-- func: render
-- desc: Called when the addon is rendering.
----------------------------------------------------------------------------------------------------
ashita.register_event('render', function()
    -- Obtain the local player..
    local player = GetPlayerEntity();
    if player == nil or player.PetTargetIndex == 0 then
        hasPet = false;
        curTime = nil;
        return;
    end

    -- Obtain the players pet..
    local pet = GetEntity(player.PetTargetIndex);
    if (pet == nil) then
        hasPet = false;
        curTime = nil;
        curTarg = nil;
        return;
    end

    if hasPet == false then
        curTime = os.clock();
        hasPet = true;
    end

    local charmedLevel = nil;
    local duration = nil;
    local cPet = nil;
    if curTarg ~= nil then
        cPet = checkT[curTarg];
        if cPet ~= nil then
            duration = baseDurT[cPet.con]
        end
    end

    if (duration ~= nil) then
        duration = calculateCharmDuration(duration)
    end

    local timediff = os.clock() - curTime
    if duration ~= nil then
        timediff = duration - timediff
        if timediff <= 0 then
            timediff = 0
        end
    end

    -- Display the pet information..
    imgui.SetNextWindowSize(200, 125, ImGuiSetCond_Always);
    if (imgui.Begin('PetInfo') == false) then
        imgui.End();
        return;
    end

    local pettp = AshitaCore:GetDataManager():GetPlayer():GetPetTP();
    local petmp = AshitaCore:GetDataManager():GetPlayer():GetPetMP();
    local petName = pet.Name;
    if cPet ~= nil then
        petName = petName .. ' (' .. cPet.level .. ')'
    end
    imgui.Text(petName);
    imgui.PushStyleColor(ImGuiCol_Text, 1.0, 1.0, 1.0, 1.0);
    imgui.Separator();

    imgui.PushStyleColor(ImGuiCol_PlotHistogram, 1.0, 0.61, 0.61, 0.6);

    if duration ~= nil then
        imgui.Text("Timer: ");
        imgui.SameLine();
        imgui.PushStyleColor(ImGuiCol_PlotHistogram, 0.4, 1.0, 0.4, 0.6);
        imgui.ProgressBar(timediff / duration, -1, 14, formatTime(math.floor(timediff)));
    else
        imgui.Text('Timer : ' .. formatTime(math.floor(timediff)));
    end
    imgui.PopStyleColor(2);

    -- Set the progressbar color for health.
    imgui.PushStyleColor(ImGuiCol_PlotHistogram, 1.0, 0.61, 0.61, 0.6);
    imgui.Text('Health:');
    imgui.SameLine();
    imgui.PushStyleColor(ImGuiCol_Text, 1.0, 1.0, 1.0, 1.0);
    imgui.ProgressBar(pet.HealthPercent / 100, -1, 14);
    imgui.PopStyleColor(2);

    imgui.PushStyleColor(ImGuiCol_PlotHistogram, 0.0, 0.61, 0.61, 0.6);
    imgui.Text('Magic :');
    imgui.SameLine();
    imgui.PushStyleColor(ImGuiCol_Text, 1.0, 1.0, 1.0, 1.0);
    imgui.ProgressBar(petmp / 100, -1, 14);
    imgui.PopStyleColor(2);

    imgui.PushStyleColor(ImGuiCol_PlotHistogram, 0.4, 1.0, 0.4, 0.6);
    imgui.Text('TP    :');
    imgui.SameLine();
    imgui.PushStyleColor(ImGuiCol_Text, 1.0, 1.0, 1.0, 1.0);
    imgui.ProgressBar(pettp / 3000, -1, 14, tostring(pettp));
    imgui.PopStyleColor(2);

    imgui.End();
end);

ashita.register_event('outgoing_packet', function(id, size, packet)
    if id == 0x1a and not hasPet then
        local l = struct.unpack('l', packet, 0x04 + 1); -- Monster Id
        local j = struct.unpack('i', packet, 0x0C + 1); -- Job Ability Id
        if j == 52 then
            curTarg = l
        end
    end
    return false
end);

---------------------------------------------------------------------------------------------------
-- func: incoming_packet
-- desc: Event called when the addon is asked to handle an incoming packet.
---------------------------------------------------------------------------------------------------
ashita.register_event('incoming_packet', function(id, size, packet, modified, blocked)

    if (id == 0x0029) then
        local l = struct.unpack('l', packet, 0x08 + 1); -- Monster Id
        local p = struct.unpack('l', packet, 0x0C + 1); -- Monster Level
        local v = struct.unpack('L', packet, 0x10 + 1); -- Check Type
        local m = struct.unpack('H', packet, 0x18 + 1); -- Defense and Evasion
        -- print(l ..' ' .. p..' ' .. v )
        checkT[l] = {
            con = v,
            level = p
        };
    end
    return false;
end);

ashita.register_event('command', function(cmd, type)
    local args = cmd:args();
    if (args[1] == '/pi') then
        for i = 0, 15 do
            local itemId = getEquippedItemId(i)
            if (itemId ~= nil and itemId ~= 0) then
                print(dump(ashita))
                local item = AshitaCore:GetResourceManager():GetItemById(itemId);
                print(dump(item.Extra))
            end
        end
        return true
    end
    return false;
end);

function dump(o)
    if type(o) == 'userdata' then
        return dump(getmetatable(o))
    end
    if type(o) == 'table' then
        local s = '{ '
        for k, v in pairs(o) do
            if type(k) ~= 'number' then
                k = '"' .. k .. '"'
            end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end
