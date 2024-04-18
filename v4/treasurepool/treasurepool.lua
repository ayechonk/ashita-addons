-- Thanks to Thorny and ShiyoKozuki for the help on converting to Ashita V4

addon.name = 'TreasurePool'
addon.author = 'ayechonk'
addon.version = '1.0'

require 'common'
local imgui = require("imgui");

local player = AshitaCore:GetMemoryManager():GetPlayer();

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

-- ashita.events.register('command', 'command_cb', function(e)
-- 	local args = e.command:args()
-- 	if (args == nil) then
-- 		return false;
-- 	end
-- 	if (args[1]:lower() == '/test') then
-- 		local inventory = AshitaCore:GetMemoryManager():GetInventory()
-- 		print(inventory:GetTreasurePoolItemCount())
-- 		local titem = inventory:GetTreasurePoolItem(0);
-- 		local pool = getTreasurePool()
-- 		if (titem ~= nil) then
-- 			print(titem.ItemId)
-- 		end
-- 		return true;
-- 	end
-- 	return false
-- end);

ashita.events.register("d3d_present", "present_cb", function()
	local t = T {}
	table.insert(t, ' Treasure Pool: ')
	local f = AshitaCore:GetFontManager():Get('__treasurepool_addon');
	local pool = getTreasurePool()
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

-- ashita.register_event('command', function(cmd, type)
--     local args = cmd:args()
--     if(args[1] ~= '/tp') then
--         return false
--     else
--         local cmdlet = args[2]
--         if cmdlet == 'show' then
--             for k,v in pairs( getTreasurePool() ) do
--                 print(k .. " | " .. v.Name .. " | " .. v.item.DropTime)
--             end
--         end 
--     end
--     return true
-- end)

-- ashita.register_event('unload', function()
--     AshitaCore:GetFontManager():Delete('__treasurepool_addon');
-- end)

-- ashita.register_event('render', function()
--     local t = T{}
--     table.insert(t,' Treasure Pool: ' )
-- 	local f = AshitaCore:GetFontManager():Get('__treasurepool_addon');
--     local pool = getTreasurePool()
--     local count = getLen(pool)
--     if count == 0 then
--         tsTable = {}
--     else
--         for k,v in pairs( pool ) do
--             local lineItem = ""
--             local timeRemaining = math.floor(getTimeRemaining(v))
--             local key = k
--             if k < 10 and count > 9 then
--                 key = ' ' .. k
--             end
--             lineItem = lineItem .. ' ' .. key .. ': '  .. v.Name
--             if v.item.WinningLot > 0 then
--                 lineItem = lineItem .. ' | '.. v.item.WinningLotterName .. ":" .. v.item.WinningLot .. " "
--             end
--             lineItem = lineItem .. ' | ' .. timeRemaining             
--             if k ~= count then
--                 lineItem = lineItem .. ' '
--             end
--             local color
--             if timeRemaining < 30 then color = '|cFFFF0000|%s|r'
--             elseif timeRemaining < 120 then color = '|cFFFFFF00|%s|r'
--             else color = '|cFF00FF00|%s|r' end
--             table.insert(t,string.format(color, lineItem));
--         end
--     end
--     f:SetText(t:concat('\n'));
-- end);
