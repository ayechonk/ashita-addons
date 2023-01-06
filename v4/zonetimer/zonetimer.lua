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

addon.author   = 'ayechonk';
addon.name     = 'zonetimer';
addon.version  = '1.0.1';

require 'common'
-- require 'date'


local currentTime = os.clock()

----------------------------------------------------------------------------------------------------
-- Configurations
----------------------------------------------------------------------------------------------------
local default_config =
{
	font =
	{
		family      = 'Consolas',
		size        = 10,
		color       = math.d3dcolor(255, 255, 255, 255),
		position    = { 0, 0 }
	},
	background =
	{
		color       = math.d3dcolor(128, 0, 0, 0),
		visible     = true
	}
};
local zt_config = default_config;

----------------------------------------------------------------------------------------------------
-- func: load
-- desc: Event called when the addon is being loaded.
----------------------------------------------------------------------------------------------------
ashita.events.register("load", "load_callback1", function()
	-- Load the configuration file..
	-- zt_config = ashita.settings.load_merged(_addon.path .. '/settings/settings.json', zt_config);

	-- Create the font object..
	local f = AshitaCore:GetFontManager():Create('__zonetimer_addon');
	f:SetColor(zt_config.font.color);
	f:SetFontFamily(zt_config.font.family);
	f:SetFontHeight(zt_config.font.size);
	f:SetPositionX(zt_config.font.position[1]);
	f:SetPositionY(zt_config.font.position[2]);
	f:SetText('');
	f:SetVisible(true);
	f:GetBackground():SetVisible(zt_config.background.visible);
	f:GetBackground():SetColor(zt_config.background.color);
end);

----------------------------------------------------------------------------------------------------
-- func: unload
-- desc: Event called when the addon is being unloaded.
----------------------------------------------------------------------------------------------------
ashita.events.register('unload', 'unload_cb', function ()
	-- -- Get the font object..
	-- local f = AshitaCore:GetFontManager():Get('__zonetimer_addon');

	-- -- Update the configuration position..
	-- zt_config.font.position = { f:GetPositionX(), f:GetPositionY() };

	-- -- Save the configuration file..
	-- ashita.settings.save(_addon.path .. '/settings/settings.json', zt_config);

	-- Delete the font object..
	AshitaCore:GetFontManager():Delete('__zonetimer_addon');
end);


----------------------------------------------------------------------------------------------------
-- func: command
-- desc: Event called when a command was entered.
----------------------------------------------------------------------------------------------------
ashita.events.register('packet_in', 'packet_in_cb', function (e)
	-- if you are changing zones, reset the current time
	if( e.id == 0x00B ) then currentTime = os.clock(); end
	return false;
end);


----------------------------------------------------------------------------------------------------
-- func: get_display_string
-- desc: provided a integer value will add a leading '0' if it is less than 10.
-- params: unitsInt (integer) - the value what will be padding with a leading '0'.
----------------------------------------------------------------------------------------------------
local function get_display_string(unitsInt)
	if ( unitsInt >= 10 ) then return unitsInt
	else return "0" .. unitsInt end
end


----------------------------------------------------------------------------------------------------
-- func: render
-- desc: Event called when the addon is being rendered.
----------------------------------------------------------------------------------------------------
ashita.events.register('d3d_present', 'present_cb', function ()

	-- Obtain the font object..
	local f = AshitaCore:GetFontManager():Get('__zonetimer_addon');

	-- Ensure we have a clock table..
	if (f == nil ) then
		return;
	end

	local totalSecs      = math.floor( os.clock() - currentTime );
	local hours          = math.floor( totalSecs / 3600 );
	local secsMinusHours = math.floor( totalSecs % 3600 );
	local mins           = math.floor( secsMinusHours / 60 );
	local seconds        = math.floor( secsMinusHours % 60 );
	
	local displayHours   = get_display_string( hours );
	local displayMins    = get_display_string( mins );
	local displaySeconds = get_display_string( seconds );

	f:SetText( " " .. displayHours .. ":" .. displayMins .. ":" .. displaySeconds  .. " "  );

end);