--[[
* Fuck'em - Copyright (c) 2022 ayechonk [chris@honkonen.dev]
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

_addon.author   = 'ayechonk';
_addon.name     = 'loot-table';
_addon.version  = '1.0.0';

require 'common'
require 'droptable'
require 'mobtable'

config = {}

ashita.register_event('load', function()
	-- Load the configuration file..
	config = ashita.settings.load_merged(_addon.path .. '/settings/settings.json', config);

	-- Create the font object..
	local f = AshitaCore:GetFontManager():Create('__loottable_addon');
	f:SetColor(config.font.color);
	f:SetFontFamily(config.font.family);
	f:SetFontHeight(config.font.size);
	f:SetPositionX(config.font.position[1]);
	f:SetPositionY(config.font.position[2]);
	f:SetVisibility(true);
	f:GetBackground():SetVisibility(true);
	f:GetBackground():SetColor(math.d3dcolor(128, 0, 0, 0))
end);

ashita.register_event('unload', function()
	AshitaCore:GetFontManager():Delete('__loottable_addon');
end);

ashita.register_event('render',function()
	local f = AshitaCore:GetFontManager():Get('__loottable_addon');
	local target = AshitaCore:GetDataManager():GetTarget();
	local str = "";
	if target:GetTargetServerId() ~= nil then
		local mobid = target:GetTargetServerId()
		local dropid = mobTbl[mobid]
		if dropid ~= nil then
			local droptable = dropTbl[dropid]
			if droptable ~= nil then
				for k,v in pairs(droptable) do
					str = ' Group '..k..':'
					local tableper = false
					for y,z in pairs(v) do
						if tableper == false then
							str = str ..'('.. z.groupRate.."%)\n"
							tableper = true
						end
						str = str ..'  '.. formatItemName(z.name)  .. ': ' .. z.itemRate..'% \n'
					end
				end
			end
		end
	end
	f:SetText(str)
end)

function formatItemName(name) 
	return name:gsub("_"," ")
end